/*==============================================================================
   TrialGroup
   Copyright (C) 2010 Eliot Van Uytfanghe

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
};

var editconst noexport array<sGroup> Groups;
var editconst noexport array<GroupObjective> Objectives;
var editconst noexport array<GroupTaskComplete> Tasks, OptionalTasks;
var editconst const noexport Color GroupColor;

var() const int MaxGroupSize;

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
	SetTimer( 120, True );
	Timer();

	gr = Spawn( Class'GroupRules', Self );
	gr.Manager = Self;
	Level.Game.AddGameModifier( gr );
}

event Timer()
{
	Level.Game.Broadcast( Self, GroupColor $ " Use 'Mutate JoinGroup <GroupName>' or 'Mutate LeaveGroup' in order to play this grouping map!" );

	// try clear groups that have became empty by leavers...
	ClearEmptyGroups();
}

function ModifyPlayer( Pawn Other )
{
	super.ModifyPlayer( Other );
	if( Other == None )
	{
		return;
	}

	if( ASPlayerReplicationInfo(Other.PlayerReplicationInfo) != None && string(Other.LastStartSpot.Class) != "BTServer_CheckPointNavigation" )
	{
		ASPlayerReplicationInfo(Other.PlayerReplicationInfo).DisabledObjectivesCount = 0;
		ASPlayerReplicationInfo(Other.PlayerReplicationInfo).DisabledFinalObjective = 0;
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
		if( Objectives.Length == 0 )
		{
			Sender.ClientMessage( GroupColor $ "Sorry this feature is disabled because this map does not support the grouping system!" );
			return;
		}

		LeaveGroup( Sender, true );

		groupname = Mid( MutateString, 10 );
		if( groupname != "" )
		{
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
		if( Objectives.Length == 0 )
		{
			Sender.ClientMessage( GroupColor $ "Sorry this feature is disabled because this map does not support the grouping system!" );
			return;
		}

		LeaveGroup( Sender );
		return;
	}
	else if( Left( MutateString, 14 ) ~= "GroupCountDown" )
	{
		if( Objectives.Length == 0 )
		{
			Sender.ClientMessage( GroupColor $ "Sorry this feature is disabled because this map does not support the grouping system!" );
			return;
		}

		CountDownGroup( Sender, int(Mid( MutateString, 15)) );
		return;
	}
	super.Mutate(MutateString,Sender);
}

final function JoinGroup( PlayerController PC, string groupName )
{
	local int groupindex, fmi;

	if( PC.Pawn == None )
	{
		PC.ClientMessage( GroupColor $ "Sorry you cannot join any group while you are dead!" );
		return;
	}

	if( VSize( PC.Pawn.LastStartSpot.Location - PC.Pawn.Location ) >= 100 )
	{
		PC.ClientMessage( GroupColor $ "Sorry you can only join a group when you are near spawn" );
		return;
	}

    groupindex = GetGroupIndexByName( groupName );
	if( groupindex != -1 )
	{
		fmi = GetMemberIndexbyGroupIndex( PC, groupindex );
		if( fmi != -1 )
		{
			PC.ClientMessage( GroupColor $ "Sorry you already are in this group!" );
		}
		else
		{
			if( Groups[groupindex].Members.Length >= MaxGroupSize )
			{
				PC.ClientMessage( GroupColor $ "Sorry the group you tried to join is at its capacity!" );
			}
			else
			{
				GroupSendMessage( groupindex, PC.PlayerReplicationInfo.PlayerName @ "Joined your group!" );

				Groups[groupindex].Members[Groups[groupindex].Members.Length] = PC;
				PC.ClientMessage( GroupColor $ "You joined the group" @ Groups[groupindex].GroupName );

				Level.Game.Broadcast( Self, GroupColor $ PC.PlayerReplicationInfo.PlayerName @ "Joined the group" @ Groups[groupindex].GroupName );
			}
		}
	}
	else
	{
		groupindex = Groups.Length;
		Groups.Length = groupindex + 1;
		Groups[groupindex].GroupName = groupName;
		Groups[groupindex].Members[Groups[groupindex].Members.Length] = PC;
		PC.ClientMessage( GroupColor $ "You created the group" @ Groups[groupindex].GroupName $ ", you need" @ MaxGroupSize - 1 @ "more members for a functional group" );
		Level.Game.Broadcast( Self, GroupColor $ PC.PlayerReplicationInfo.PlayerName @ "Created the group" @ Groups[groupindex].GroupName );
	}
}

// Check if this player already is within a group in that case remove him and remove the group if it turns empty!.
final function LeaveGroup( PlayerController PC, optional bool bNoMessages )
{
	local int groupindex, memberindex;

	if( PC.Pawn == None )
	{
		if( !bNoMessages )
		{
			PC.ClientMessage( GroupColor $ "Sorry you cannot leave a group while you are dead!" );
		}
		return;
	}

	if( VSize( PC.Pawn.LastStartSpot.Location - PC.Pawn.Location ) >= 100 )
	{
		if( !bNoMessages )
		{
			PC.ClientMessage( GroupColor $ "Sorry you can only leave a group when you are near spawn" );
		}
		return;
	}

	groupindex = GetGroupIndexByPlayer( PC, memberindex );
	if( groupindex != -1 && memberindex != -1 )
	{
		Groups[groupindex].Members.Remove( memberindex, 1 );
		if( !bNoMessages )
		{
			PC.ClientMessage( GroupColor $ "You left the group" @ Groups[groupindex].GroupName );
			GroupSendMessage( groupindex, PC.PlayerReplicationInfo.PlayerName @ "Left your group!" );
			Level.Game.Broadcast( Self, GroupColor $ PC.PlayerReplicationInfo.PlayerName @ "Left the group" @ Groups[groupindex].GroupName );
		}
		// Check if this group became empty, or whether the group has players that no longer exist, therefor clear those.
		ClearEmptyGroup( groupindex );
	}
	// else not in a group!
}

final function CountDownGroup( PlayerController PC, int Amount )
{
	local GroupCounter Counter;
	local int groupindex;

	if( PC.Pawn == None )
	{
		PC.ClientMessage( GroupColor $ "Sorry you cannot start a countdown while you are dead!" );
		return;
	}

	Amount = Max( Min( Amount, 3 ), 1 );
	groupindex = GetGroupIndexByPlayer( PC );
	if( groupindex != -1 )
	{
		if( Level.TimeSeconds - Groups[groupindex].LastCountDown >= (Amount + 0.5f) )
		{
			Counter = Spawn( Class'GroupCounter', Self );
			Counter.Members = Groups[groupindex].Members;
			Counter.Counts = Amount;
			Groups[groupindex].LastCountDown = Level.TimeSeconds;
			Counter.Start();
		}
		else
		{
			PC.ClientMessage( GroupColor $ "Sorry you cannot start a coundown while your group's counter is active!" );
		}
	}
	else
	{
		PC.ClientMessage( GroupColor $ "Sorry you cannot start a countdown because your not in a group!" );
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

final function int GetGroupIndexByName( string groupName )
{
	local int i, m;

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

final function GroupSendMessage( int groupIndex, string groupMessage )
{
	local int m;
	local Controller C;

	if( Groups.Length == 0 )
	{
		return;
	}

	for( m = 0; m < Groups[groupIndex].Members.Length; ++ m )
	{
		if( Groups[groupIndex].Members[m] != None )
		{
			PlayerController(Groups[groupIndex].Members[m]).ClientMessage( GroupColor $ groupMessage );

			// Check all controllers whether they are spectating this member!.
			for( C = Level.ControllerList; C != None; C = C.NextController )
			{
				// Hey not to myself(incase)
				if( C == Groups[groupIndex].Members[m] )
				{
					continue;
				}

				if( PlayerController(C).RealViewTarget == Groups[groupIndex].Members[m] )
				{
					PlayerController(C).ClientMessage( GroupColor $ groupMessage );
				}
			}
		}
	}
}

final function int GetGroupCompletedTasks( int groupIndex, bool bOptional )
{
	local int i, numtasks, t;

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

final function ClearEmptyGroups()
{
	local int i, m;

	for( i = 0; i < Groups.Length; ++ i )
	{
		for( m = 0; m < Groups[i].Members.Length; ++ m )
		{
			if( Groups[i].Members[m] == None )
			{
				Groups[i].Members.Remove( m, 1 );
				-- m;
			}
		}

		if( Groups[i].Members.Length == 0 )
		{
			Groups.Remove( i, 1 );
			-- i;
		}
	}
}

final function ClearEmptyGroup( int groupIndex )
{
	local int m;

	if( Groups.Length == 0 )
	{
		return;
	}

	for( m = 0; m < Groups[groupIndex].Members.Length; ++ m )
	{
		if( Groups[groupIndex].Members[m] == None )
		{
			Groups[groupIndex].Members.Remove( m, 1 );
			-- m;
		}
	}

	if( Groups[groupIndex].Members.Length == 0 )
	{
		Groups.Remove( groupIndex, 1 );
	}
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
		PC.Player.InteractionMaster.AddInteraction( string( Class'GroupInteraction' ), PC.Player );
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
}
