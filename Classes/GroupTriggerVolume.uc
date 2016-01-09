/*==============================================================================
   TrialGroup
   Copyright (C) 2010 - 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupTriggerVolume extends PhysicsVolume
	hidecategories(Lighting,LightColor,Karma,Force,Sound,PhysicsVolume)
	placeable;

var editconst GroupManager Manager;
var() protected editconst const noexport string Info;

var() localized string lzPlayersMissing, lzPlayerMissing;

/**
 * Amount of group members required for this volume to be considered full.
 * If set to 0 then @MaxGroupSize will be used instead.
 */
var() int RequiredMembersCount;

/** Whether this volume wants any HUD rendering at all. */
var() bool bDisplayOnHUD;

/** If this and @bDisplayOnHUD is true, the location and distance from the viewer will be rendered on the HUD. */
var() bool bDisplayTrackingOnHUD;

/** If this and @bDisplayOnHUD is true, the progress will be rendered to any group members. */
var() bool bDisplayInfoOnHUD;

/** Does this volume trigger a group task?, only used if @bDisplayInfoOnHUD is true. */
var() bool bTriggersGroupTask;

/** Minimum time before this volume can be triggered again. */
var() float ReTriggerDelay;
var float TriggerTime;

// Fallback for outdated maps.
var deprecated string LastTriggeredByGroupName;

// replication
// {
// 	reliable if( Role == ROLE_Authority && bNetInitial )
// 		bTriggersGroupTask;
// }

// event PostBeginPlay()
// {
// 	local GroupTaskComplete task;

// 	super.PostBeginPlay();

// 	if( bDisplayInfoOnHUD && bDisplayOnHUD && !bTriggersGroupTask )
// 	{
// 		foreach DynamicActors( class'GroupTaskComplete', task, Event )
// 		{
// 			bTriggersGroupTask = true;
// 			break;
// 		}
// 	}
// }

// Operator from ServerBTimes.u
static final operator(102) string $( Color B, coerce string A )
{
	return (Chr( 0x1B ) $ (Chr( Max( B.R, 1 ) ) $ Chr( Max( B.G, 1 ) ) $ Chr( Max( B.B, 1 ) ))) $ A;
}

/**
 * Returns a list of all xPawn(Players) that are touching this volume.
 * #Client: Returns only the touches of local actors such as a player's own pawn but not any others.
 * #Server: Returns any touching xPawn.
 */
final simulated function GetPlayersInVolume( out array<Pawn> players )
{
	local int i;

	for( i = 0; i < Touching.Length; ++ i )
	{
    	if( xPawn(Touching[i]) == none )
    	{
    		continue;
    	}
		players[players.Length] = Pawn(Touching[i]);
	}
}

final function FilterPlayersByGroup( int groupIndex, out array<Pawn> members )
{
	local int i;

	for( i = 0; i < members.Length; ++ i )
	{
		if( Manager.GetMemberIndexByGroupIndex( members[i].Controller, groupIndex ) == -1 )
		{
			members.Remove(i, 1);
			-- i;
		}
	}
}

final simulated function int GetRequiredMembersCount( GroupManager groupManager )
{
	if( RequiredMembersCount > 0 )
		return RequiredMembersCount;
	return groupManager.MaxGroupSize;
}

final simulated function int GetMissingMembersCount( int membersCount, GroupManager groupManager )
{
	return GetRequiredMembersCount( groupManager ) - membersCount;
}

final function bool HasAllRequiredMembers( array<Pawn> members, out int missingCount )
{
	missingCount = GetMissingMembersCount( members.Length, Manager );
	// The group is full and all of them are in the volume!, then triggerevent...
	if( members.Length >= GetRequiredMembersCount( Manager ) && missingCount <= 0 )
	{
		return true;
	}
	return false;
}

simulated function bool AllowRendering( GroupInstance group, PlayerController viewer )
{
	return bDisplayOnHUD || (!bDisplayInfoOnHUD && !bDisplayTrackingOnHUD);
}

simulated function bool AllowInfoRendering( GroupInstance group, PlayerController viewer )
{
	return bDisplayInfoOnHUD;
}

simulated function RenderInfo( Canvas C, GroupInstance group, PlayerController viewer )
{
	local int membersIn;
	local array<Pawn> members;

	// temp
	local int i;
	local string s;
	local float xl, yl;
	local Vector screenPos;

	GetPlayersInVolume( members );
	for( i = 0; i < members.Length; ++ i )
	{
		if( !group.IsMember( members[i] ) )
		{
			continue;
		}
		++ membersIn;
	}
	s = membersIn $ "/" $ GetRequiredMembersCount( group.Manager );

	screenPos = C.WorldToScreen( Location );
	C.StrLen( s, xl, yl );
	C.SetPos( screenPos.X - xl*0.5, screenPos.Y - yl*0.5 );
	C.DrawColor = group.GroupColor;
	C.DrawTextClipped( s );

	if( bTriggersGroupTask )
	{
		RenderTask( C, xl, yl );
	}
}

simulated function RenderTask( Canvas C, float xl, float yl )
{
	local float	iconSize;

	iconSize = yl*2;
	C.SetPos( C.CurX - iconSize - yl*0.33, C.CurY + yl*0.5 - iconSize*0.5 );
	C.DrawColor = class'HUD'.default.WhiteColor;
	C.DrawTile( Texture'AS_FX_TX.Icons.ScoreBoard_Objective_Final', iconSize, iconSize, 0, 0, 128, 128 );
}

simulated function bool AllowTrackingRendering( GroupInstance group, PlayerController viewer )
{
	return bDisplayTrackingOnHUD;
}

simulated function RenderTracking( Canvas C, HUD_Assault hud, GroupInstance group, PlayerController viewer )
{
	local Vector screenPos;

	screenPos = C.WorldToScreen( Location );
	C.DrawColor = group.GroupColor;
	C.DrawColor.A = 50;
	hud.DrawActorTracking( C, self, false, screenPos );
}

event PawnEnteredVolume( Pawn other )
{
	local int missingMembersCount, groupIndex;
	local array<Pawn> members;

	if( xPawn(other) == none || !other.IsPlayerPawn() )
	{
		return;
	}

    groupIndex = Manager.GetGroupIndexByPlayer( other.Controller );
	if( groupIndex == -1 )
	{
		xPawn(other).ClientMessage( class'GroupManager'.default.GroupColor $ "Sorry you cannot contribute until you join a group!" );
		return;
	}

	GetPlayersInVolume( members );
	// Because we are comparing by members length to find out whether the group is full, it is important to clear all None references.
	Manager.ClearEmptyGroup( groupIndex );
	FilterPlayersByGroup( groupIndex, members );

	if( Manager.Groups[groupIndex].Members.Length == Manager.MaxGroupSize
		&& HasAllRequiredMembers( members, missingMembersCount ) )
	{
		if( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
		{
			return;
		}
		TriggerTime = Level.TimeSeconds;
		TriggerEvent( Event, self, other );
	}
	else
	{
		NotifyMembersMissing( members, missingMembersCount );
	}
}

function NotifyMembersMissing( array<Pawn> members, int missingMembersCount )
{
	local int i;

	for( i = 0; i < members.Length; ++ i )
	{
		Manager.SendPlayerMessage(
			members[i].Controller,
			Eval(
				missingMembersCount > 1,
				Repl(Repl(Repl(lzPlayersMissing, "%a", members.Length), "%b", GetRequiredMembersCount( Manager )), "%n", missingMembersCount),
				Repl(Repl(lzPlayerMissing, "%a", members.Length), "%b", GetRequiredMembersCount( Manager ))
			),
			Manager.GroupProgressMessageClass
		);
	}
}

defaultproperties
{
	Info="All members of a group(group must also be full) have to enter this volume to trigger its event."

	bDisplayOnHUD=true
	bDisplayTrackingOnHUD=true
	bDisplayInfoOnHUD=true
	bTriggersGroupTask=false

	ReTriggerDelay=0.0

	lzPlayersMissing="%a/%b, %n more members are required"
	lzPlayerMissing="%a/%b, one more member is required"
}
