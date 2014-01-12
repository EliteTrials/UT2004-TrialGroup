/*==============================================================================
   TrialGroup
   Copyright (C) 2010 - 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupManager extends Mutator
	dependson(GroupObjective)
	cacheexempt
	hidedropdown
	hidecategories(Lighting,LightColor,Karma,Mutator,Force,Collision,Sound,Events)
	placeable;

struct sGroup
{
	var string GroupName;
	var editconst array<Controller> Members;
	var editconst float LastCountDown;

	var editconst array<GroupTaskComplete> CompletedTasks;

	var GroupInstance Instance;
};

var editconst noexport array<sGroup> Groups;
var editconst noexport array<GroupObjective> Objectives;
var editconst noexport array<GroupTaskComplete> Tasks, OptionalTasks;
var editconst const noexport Color GroupColor;
var private noexport int NextGroupId, CurrentWanderersGroupId;

var(Modules) class<GroupLocalMessage> GroupMessageClass, PlayerMessageClass, TaskMessageClass;
var(Modules) class<GroupInstance> GroupInstanceClass;
var(Modules) class<GroupInteraction> GroupInteractionClass;
var(Modules) class<GroupCounter> GroupCounterClass;
var(Modules) class<GroupRules> GroupRulesClass;
var(Modules) class<GroupPlayerLinkedReplicationInfo> GroupPlayerReplicationInfoClass;

var() int MaxGroupSize;
var() string GeneratedGroupName;
var() private editconst const noexport string Info;

// Operator from ServerBTimes.u
static final operator(101) string $( coerce string A, Color B )
{
	return A $ (Chr( 0x1B ) $ (Chr( Max( B.R, 1 )  ) $ Chr( Max( B.G, 1 ) ) $ Chr( Max( B.B, 1 ) )));
}

// Operator from ServerBTimes.u
static final operator(102) string $( Color B, coerce string A )
{
	return (Chr( 0x1B ) $ (Chr( Max( B.R, 1 ) ) $ Chr( Max( B.G, 1 ) ) $ Chr( Max( B.B, 1 ) ))) $ A;
}

event PreBeginPlay()
{
	local GroupObjective Obj;
	local GroupTrigger Tsk;
	local GroupTriggerVolume Vlu;
	local GroupTaskComplete Tk;
	local GroupTeleporter TP;

	super.PreBeginPlay();
	Level.Game.BaseMutator.AddMutator( Self );

	foreach AllActors( Class'GroupObjective', Obj )
	{
		Objectives[Objectives.Length] = Obj;
		Obj.Manager = Self;
	}

	if( Objectives.Length == 0 )
	{
		Log( "Warning: this map has no group objectives!" );
	}

	foreach AllActors( Class'GroupTrigger', Tsk )
	{
		Tk = GroupTaskComplete(Tsk);
		if( Tk != None )
		{
			if( Tk.bOptionalTask )
			{
				OptionalTasks[OptionalTasks.Length] = Tk;
			}
			else
			{
				Tasks[Tasks.Length] = Tk;
			}
		}
		Tsk.Manager = Self;
	}

	foreach AllActors( Class'GroupTeleporter', TP )
	{
		 TP.Manager = Self;
	}

	foreach AllActors( Class'GroupTriggerVolume', Vlu )
	{
		Vlu.Manager = Self;
	}
}

event PostBeginPlay()
{
	local GroupRules gr;

	super.PostBeginPlay();
	SetTimer( 5, True );

	gr = Spawn( GroupRulesClass, self );
	gr.Manager = Self;
	Level.Game.AddGameModifier( gr );
}

event Timer()
{
	// try clear groups that have became empty by leavers...
	ClearEmptyGroups();
}

final function int CreateWanderersGroup()
{
	local int groupIndex;

	groupIndex = CreateGroup( GeneratedGroupName $ "-" $ NextGroupId );
	if( groupindex == -1 )
	{
		Warn( "Failed to generate a Wanderers group" );
		return -1;
	}

	CurrentWanderersGroupId = Groups[groupIndex].Instance.GroupId;
	return groupIndex;
}

final function JoinWanderersGroup( PlayerController PC )
{
	local int groupIndex;

	groupIndex = GetGroupIndexById( CurrentWanderersGroupId );
	if( groupIndex == -1 )
	{
		groupIndex = CreateWanderersGroup();
		if( groupIndex == -1 )
		{
			Warn( "Failed to join a Wanderers group" );
			return;
		}
	}

	if( Groups[groupIndex].Members.Length == MaxGroupSize )
	{
		groupIndex = CreateWanderersGroup();
		if( groupIndex == -1 )
		{
			Warn( "Failed to generate a new Wanderers group" );
			return;
		}
	}
	JoinGroup( PC, Groups[groupIndex].GroupName );
}

function ModifyPlayer( Pawn other )
{
	local GroupPlayerLinkedReplicationInfo LRI;

	super.ModifyPlayer( other );
	if( other == None )
	{
		return;
	}

	if( ASPlayerReplicationInfo(other.PlayerReplicationInfo) != none && string(other.LastStartSpot.Class) != "BTServer_CheckPointNavigation" )
	{
		ASPlayerReplicationInfo(other.PlayerReplicationInfo).DisabledObjectivesCount = 0;
		ASPlayerReplicationInfo(other.PlayerReplicationInfo).DisabledFinalObjective = 0;
	}

	if( PlayerController(other.Controller) == none )
	{
		return;
	}

	LRI = GetGroupPlayerReplicationInfo( other.Controller );
	if( LRI != none )
	{	
		if( LRI.bIsWanderer )
		{
			JoinWanderersGroup( PlayerController(other.Controller) );
			LRI.bIsWanderer = false;
		}
		else if( LRI.PlayerGroup == none )
		{
			SendPlayerMessage( other.Controller, " Use console command 'JoinGroup <GroupName>' to join/create a group!" );
		}
	}
}

function Mutate( string MutateString, PlayerController Sender )
{
	local string groupname;

	// lol this happens to be true sometimes...
	if( Sender == None )
		return;

	if( Left( MutateString, 9 ) ~= "JoinGroup" )
	{
		groupname = Mid( MutateString, 10 );
		if( groupname != "" )
		{
			// Clear the groups of disconnected players.
			// Important to not use ClearEmptyGroup by index as it may destroy the group (about to be joined) as a result.
			ClearEmptyGroups();
			JoinGroup( Sender, groupname );
		}
		else
		{
			Sender.ClientMessage( GroupColor $ "Please specifiy a group name!" );
		}
		return;
	}
	else if( MutateString ~= "LeaveGroup" )
	{
		LeaveGroup( Sender );
		return;
	}
	else if( Left( MutateString, 14 ) ~= "GroupCountDown" )
	{
		CountDownGroup( Sender, int(Mid( MutateString, 15)) );
		return;
	}
	super.Mutate(MutateString,Sender);
}

final function JoinGroup( PlayerController PC, string groupName )
{
	local int groupindex;

	if( PC.Pawn == None )
	{
		PC.ClientMessage( GroupColor $ "Sorry you cannot join a group when you are dead!" );
		return;
	}

	if( VSize( PC.Pawn.LastStartSpot.Location - PC.Pawn.Location ) >= 200 )
	{
		PC.ClientMessage( GroupColor $ "Sorry you can only join a group when you are near your spawn location" );
		return;
	}

    groupindex = GetGroupIndexByName( groupName );
	if( groupindex != -1 )
	{
		if( GetMemberIndexbyGroupIndex( PC, groupindex ) != -1 )
		{
			PC.ClientMessage( GroupColor $ "Sorry you're already in this group!" );
		}
		else
		{
			if( Groups[groupindex].Members.Length >= MaxGroupSize )
			{
				PC.ClientMessage( GroupColor $ "Sorry the group you tried to join is at its capacity!" );
			}
			else
			{
				if( !LeaveGroup( PC ) )
				{
					PC.ClientMessage( GroupColor $ "Cannot join group. Something went wrong when leaving your previous group!" );
					return;
				}

				// Get new index, because LeaveGroup may remove empty groups, moving the index.
				groupindex = GetGroupIndexByName( groupName );
				if( groupindex == -1 )
				{
					Warn( "This should never happen. Group not found after leaving previous group!" );
					return;
				}

				GroupSendMessage( groupindex, PC.PlayerReplicationInfo.PlayerName @ "Joined your group!" );
				AddPlayerToGroup( PC, groupindex );
				SendPlayerMessage( PC, "You joined the \"" $ Groups[groupindex].GroupName $ "\" group" );
			}
		}
	}
	else
	{
		if( !LeaveGroup( PC ) )
		{
			PC.ClientMessage( GroupColor $ "Cannot create group. Something went wrong when leaving your previous group!" );
			return;
		}

		groupindex = CreateGroup( groupName, PC );
		if( groupindex == -1 )
		{
			PC.ClientMessage( GroupColor $ "Sorry something went wrong when creating the group!" );
			return;
		}
		SendPlayerMessage( PC, "You created the \"" $ Groups[groupindex].GroupName $ "\" group" );
	}
}

final function bool AddPlayerToGroup( PlayerController PC, int groupIndex )
{
	local GroupPlayerLinkedReplicationInfo LRI;

	// Log( "AddPlayerToGroup(" $ PC $ ", " $ Groups[groupindex].GroupName $ ")" );
	LRI = GetGroupPlayerReplicationInfo( PC );
	if( LRI != none )
	{
		LRI.PlayerGroup = Groups[groupindex].Instance;
		if( LRI.PlayerGroup == none )
		{
			Warn( "PlayerGroup was none when adding player to group" );
		}
		else if( LRI.PlayerGroup.Commander == none )
		{
			LRI.PlayerGroup.Commander = LRI;
		}
		else
		{
			LRI.NextMember = LRI.PlayerGroup.Commander;
			LRI.PlayerGroup.Commander = LRI;
		}
	}
	else
	{
		Warn( "Couldn't find LRI when adding player to group" );
	}
	Groups[groupindex].Members[Groups[groupindex].Members.Length] = PC;
	return true;
}

final function bool RemoveMemberFromGroup( int memberIndex, int groupIndex )
{
	local GroupPlayerLinkedReplicationInfo LRI, member;

	// Log( "RemoveMemberFromGroup(" $ Groups[groupIndex].Members[memberIndex].GetHumanReadableName() $ ", " $ Groups[groupindex].GroupName $ ")" );
	if( groupIndex >= Groups.Length || memberindex >= Groups[groupIndex].Members.Length )
	{
		return false;
	}

	LRI = GetGroupPlayerReplicationInfo( Groups[groupIndex].Members[memberindex] );
	if( LRI != none )
	{
		if( LRI.PlayerGroup != none )
		{
			if( LRI.PlayerGroup.Commander == LRI )
			{
				LRI.PlayerGroup.Commander = LRI.NextMember;
			}
			else
			{
				for( member = LRI.PlayerGroup.Commander; member != none; member = member.NextMember )
				{
					if( member.NextMember == LRI )
					{
						member.NextMember = LRI.NextMember;
						break;
					}
				}
			}
		}
		LRI.NextMember = none;
		LRI.PlayerGroup = none;
	}
	else
	{
		Warn( "Couldn't find LRI when removing player from group" );
	}
	Groups[groupIndex].Members.Remove( memberIndex, 1 );
	return true;
}

final function int CreateGroup( string groupName, optional PlayerController commander )
{
	local GroupInstance instance;
	local int groupIndex;

	// Log( "CreateGroup(" $ groupName $ ", " $ commander.GetHumanReadableName() $ ")" );
	if( GetGroupIndexByName( groupName ) != -1 )
	{
		return -1;
	}

	// Don't create a new group for commander if he/she can't leave its current group.
	if( commander != none && !LeaveGroup( commander ) )
	{
		return -1;
	}

	instance = Spawn( GroupInstanceClass, self );
	if( instance == none )
	{
		return -1;
	}

	groupIndex = Groups.Length;
	Groups.Length = groupIndex + 1;
	Groups[groupIndex].Instance = instance;
	Groups[groupIndex].GroupName = groupName;

	instance.GroupId = NextGroupId ++;
	instance.GroupName = groupName;

	if( commander != none )
	{
		AddPlayerToGroup( commander, groupindex );
	}
	return groupindex;
}

// Check if this player already is within a group in that case remove him and remove the group if it turns empty!.
final function bool LeaveGroup( PlayerController PC, optional bool bNoMessages )
{
	local int groupindex, memberindex;
	local bool vReturnValue;

	if( PC.Pawn == None )
	{
		if( !bNoMessages )
		{
			PC.ClientMessage( GroupColor $ "Sorry you cannot leave a group while you are dead!" );
		}
		return false;
	}

	if( VSize( PC.Pawn.LastStartSpot.Location - PC.Pawn.Location ) >= 200 )
	{
		if( !bNoMessages )
		{
			PC.ClientMessage( GroupColor $ "Sorry you can only leave a group if you are near your spawn location" );
		}
		return false;
	}

	groupindex = GetGroupIndexByPlayer( PC, memberindex );
	if( groupindex != -1 && memberindex != -1 )
	{
		vReturnValue = RemoveMemberFromGroup( memberindex, groupindex );
		if( !bNoMessages )
		{
			SendPlayerMessage( PC, "You left the group \"" $ Groups[groupindex].GroupName $ "\"" );
			GroupSendMessage( groupindex, PC.PlayerReplicationInfo.PlayerName @ "Left your group!" );
		}
		// Check if this group became empty, or whether the group has players that no longer exist, therefor clear those.
		ClearEmptyGroup( groupindex );
		return vReturnValue;
	}
	// else not in a group!
	return true;
}

final function CountDownGroup( PlayerController PC, int ticks )
{
	local int groupIndex;

	if( PC.Pawn == None )
	{
		PC.ClientMessage( GroupColor $ "Sorry you cannot start a countdown while you are dead!" );
		return;
	}

	groupIndex = GetGroupIndexByPlayer( PC );
	if( groupIndex != -1 )
	{
		ticks = Max( Min( ticks, 3 ), 1 );
		if( Level.TimeSeconds - Groups[groupIndex].LastCountDown >= (ticks + 0.5f) )
		{
			Groups[groupIndex].LastCountDown = Level.TimeSeconds;
			Spawn( GroupCounterClass, self ).Start( groupIndex, ticks );
		}
		else
		{
			PC.ClientMessage( GroupColor $ "Sorry you cannot start a coundown when your group's counter is active!" );
		}
	}
	else
	{
		PC.ClientMessage( GroupColor $ "Sorry you cannot start a countdown when you're not in a group!" );
	}
}

final function int GetGroupIndexByPlayer( Controller C, optional out int foundMemberIndex )
{
	local int i, m;

	for( i = 0; i < Groups.Length; ++ i )
	{
		for( m = 0; m < Groups[i].Members.Length; ++ m )
		{
			if( Groups[i].Members[m] == C )
			{
				foundMemberIndex = m;
				return i;
			}
		}
	}
	return -1;
}

final function int GetGroupIndexById( int groupId )
{
	local int i;

	for( i = 0; i < Groups.Length; ++ i )
	{
		if( Groups[i].Instance.GroupId == groupId )
		{
			return i;
		}
	}
	return -1;
}

final function int GetGroupIndexByName( string groupName )
{
	local int i;

	for( i = 0; i < Groups.Length; ++ i )
	{
		if( Groups[i].GroupName ~= groupName )
		{
			return i;
		}
	}
	return -1;
}

final function int GetMemberIndexByPlayer( Controller C )
{
	local int m, groupindex;

	groupindex = GetGroupIndexByPlayer( C );
	if( groupindex != -1 && Groups.Length > 0 )
	{
		for( m = 0; m < Groups[groupindex].Members.Length; ++ m )
		{
			if( Groups[groupindex].Members[m] == C )
			{
				return m;
			}
		}
	}
	return -1;
}

final function int GetMemberIndexByGroupIndex( Controller C, int groupIndex )
{
	local int m;

	if( groupIndex != -1 && Groups.Length > 0 )
	{
		for( m = 0; m < Groups[groupIndex].Members.Length; ++ m )
		{
			if( Groups[groupIndex].Members[m] == C )
			{
				return m;
			}
		}
	}
	return -1;
}

final function GetMembersByGroupIndex( int groupIndex, out array<Controller> members )
{
	if( groupIndex != -1 && Groups.Length > 0 )
	{
		members = Groups[groupIndex].Members;
	}
}

final function GroupSendMessage( int groupIndex, string groupMessage, optional class<GroupLocalMessage> messageClass )
{
	local int m;
	local Controller C;

	if( Groups.Length == 0 )
	{
		return;
	}

	// Group is no longer active?
	if( groupIndex >= Groups.Length )
	{
		return;
	}

	for( m = 0; m < Groups[groupIndex].Members.Length; ++ m )
	{
		if( Groups[groupIndex].Members[m] != None )
		{
			SendGroupMessage( Groups[groupIndex].Members[m], groupMessage, messageClass );
			// Check all controllers whether they are spectating this member!.
			for( C = Level.ControllerList; C != None; C = C.NextController )
			{
				// Hey not to myself(incase)
				if( C == Groups[groupIndex].Members[m] || PlayerController(C) == none )
				{
					continue;
				}

				if( PlayerController(C).RealViewTarget == Groups[groupIndex].Members[m] )
				{
					SendGroupMessage( C, groupMessage, messageClass );
				}
			}
		}
	}
}

final function SendGroupMessage( Controller C, string message, optional class<GroupLocalMessage> messageClass )
{
	local GroupPlayerLinkedReplicationInfo LRI;

	if( messageClass == none )
	{
		messageClass = GroupMessageClass;
	}

	LRI = GetGroupPlayerReplicationInfo( C );
	LRI.ClientSendMessage( messageClass, GroupColor $ message );
	// Groups[groupIndex].Instance.SetQueueMessage( message );
	//C.ReceiveLocalizedMessage( GroupMessageClass,,,, Groups[groupIndex].Instance );
}

final function SendPlayerMessage( Controller C, string message )
{
	local GroupPlayerLinkedReplicationInfo LRI;

	LRI = GetGroupPlayerReplicationInfo( C );
	LRI.ClientSendMessage( PlayerMessageClass, GroupColor $ message );
}

final function SendGlobalMessage( string message )
{
	Level.Game.Broadcast( Self, GroupColor $ message );
}

final function int GetGroupCompletedTasks( int groupIndex, bool bOptional )
{
	local int i, numtasks;

	if( Groups.Length == 0 )
	{
		return 0;
	}

	if( bOptional )
	{
		for( i = 0; i < Groups[groupIndex].CompletedTasks.Length; ++ i )
		{
			if( Groups[groupIndex].CompletedTasks[i].bOptionalTask )
			{
        		++ numtasks;
        	}
		}
	}
	else
	{
		for( i = 0; i < Groups[groupIndex].CompletedTasks.Length; ++ i )
		{
			if( !Groups[groupIndex].CompletedTasks[i].bOptionalTask )
			{
        		++ numtasks;
        	}
		}
	}
	return numtasks;
}

final function RewardGroup( int groupIndex, int objectivesAmount )
{
	local int m;
	local ASPlayerReplicationInfo ASPRI;

 	if( Groups.Length == 0 )
	{
		return;
	}

   	for( m = 0; m < Groups[groupIndex].Members.Length; ++ m )
   	{
   		ASPRI = ASPlayerReplicationInfo(Groups[groupIndex].Members[m].PlayerReplicationInfo);
   		if( ASPRI != None )
   		{
			ASPRI.DisabledObjectivesCount += objectivesAmount;
			ASPRI.Score += 10 * objectivesAmount;
			Level.Game.ScoreObjective( ASPRI, 10 * objectivesAmount );
		}
	}
}

final function bool ShouldRemoveMember( int groupIndex, int memberIndex )
{
	local Controller c;

	c = Groups[groupIndex].Members[memberIndex];
	if( c == none || c.PlayerReplicationInfo.bOnlySpectator || c.PlayerReplicationInfo.bIsSpectator )
	{
		return true;
	}
	return false;
}

final function ClearEmptyGroups()
{
	local int groupIndex;

	for( groupIndex = 0; groupIndex < Groups.Length; ++ groupIndex )
	{
		if( ClearEmptyGroup( groupIndex ) )
		{
			-- groupIndex;
		}
	}
}

final function bool ClearEmptyGroup( int groupIndex )
{
	local int m;
	local Controller member;

	for( m = 0; m < Groups[groupIndex].Members.Length; ++ m )
	{
		member = Groups[groupIndex].Members[m];
		if( ShouldRemoveMember( groupIndex, m ) && RemoveMemberFromGroup( m, groupIndex ) )
		{
			-- m;
			if( member != none )
			{
				SendPlayerMessage( member, "You left the group \"" $ Groups[groupIndex].GroupName $ "\"" );
				GroupSendMessage( groupIndex, member.PlayerReplicationInfo.PlayerName @ "Left your group!" );
			}
			else
			{
				GroupSendMessage( groupIndex, "A player has left your group!" );
			}
		}
	}

	if( Groups[groupIndex].Members.Length == 0 )
	{
		if( Groups[groupIndex].Instance != none )
		{
			Groups[groupIndex].Instance.Destroy();
		}
		Log( "Removing empty group" @ Groups[groupIndex].GroupName );
		Groups.Remove( groupIndex, 1 );
		return true;
	}
	return false;
}

simulated event Tick( float DeltaTime )
{
    local PlayerController PC;

    if( Level.NetMode == NM_DedicatedServer )
    {
    	Disable('Tick');
    	return;
    }

	PC = Level.GetLocalPlayerController();
	if( PC != None && PC.Player != None && PC.Player.InteractionMaster != None )
	{
		PC.Player.InteractionMaster.AddInteraction( string(GroupInteractionClass), PC.Player );
		Disable('Tick');
		return;
    }
}

function Reset()
{
	local int i;

	super.Reset();
	for( i = 0; i < Groups.Length; ++ i )
	{
		Groups[i].CompletedTasks.Length = 0;
	}
}

final static Function GroupPlayerLinkedReplicationInfo GetGroupPlayerReplicationInfo( Controller c )
{
	local LinkedReplicationInfo LRI;

	if( c == none )
	{
		return none;
	}

	for( LRI = C.PlayerReplicationInfo.CustomReplicationInfo; LRI != None; LRI = LRI.NextReplicationInfo )
	{
		if( GroupPlayerLinkedReplicationInfo(LRI) == none )
		{
			continue;
		}	
		return GroupPlayerLinkedReplicationInfo(LRI);
	}
	return none;
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local LinkedReplicationInfo LRI;

	if( PlayerReplicationInfo(Other) != none )
	{
		if( Other.Owner != none && MessagingSpectator(Other.Owner) == none )
		{
			LRI = Spawn( GroupPlayerReplicationInfoClass, Other.Owner );
			LRI.NextReplicationInfo = PlayerReplicationInfo(Other).CustomReplicationInfo;
			PlayerReplicationInfo(Other).CustomReplicationInfo = LRI;
		}
	}
	return true;
}

defaultproperties
{
    GroupName="TrialGroup"
    FriendlyName="Trial Group"
    Description="Provides functionality for mappers to integrate a group system which an external mutator is suposed to support for actually usage"

	MaxGroupSize=2

	GroupColor=(R=182,G=89,B=73)

	Info="To get the group system complete working you need to add a GroupObjective(Under TriggeredObjective) to your map and add the optional GroupTaskComplete(under Triggers) triggers for anti-cheating purpose, also use GroupTriggerVolume instead of PawnLimitVolume"

	RemoteRole=ROLE_SimulatedProxy
	bNoDelete=True
	bStatic=False

	GroupMessageClass=class'GroupLocalMessage'
	PlayerMessageClass=class'GroupPlayerLocalMessage'
	TaskMessageClass=class'GroupTaskLocalMessage'
	GroupInstanceClass=class'GroupInstance'
	GroupInteractionClass=class'GroupInteraction'
	GroupCounterClass=class'GroupCounter'
	GroupRulesClass=class'GroupRules'
	GroupPlayerReplicationInfoClass=class'GroupPlayerLinkedReplicationInfo'

	GeneratedGroupName="Explorers"
}
