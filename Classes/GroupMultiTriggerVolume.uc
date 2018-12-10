/*==============================================================================
   TrialGroup
   Copyright (C) 2010 - 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupMultiTriggerVolume extends GroupTriggerVolume;

// Fallback for outdated maps.
var deprecated editconst const byte RequiredMembers;

var GroupMultiVolumesManager LinkManager;

/**
 * The event name to instigate if this volume is filled but the other linked volumes are not.
 * Note: This is not affected by @ReTriggerDelay;
 */
var(Events) name EventWhenFilledButNotAll;

event PawnEnteredVolume( Pawn other )
{
	local int groupIndex;

	if( xPawn(other) == none || !other.IsPlayerPawn() )
	{
		return;
	}

    groupIndex = Manager.GetGroupIndexByPlayer( other.Controller );
	if( groupIndex != -1 )
	{
		// Because we are comparing by members length to find out whether the group is full, it's important to clear all None references.
    	Manager.ClearEmptyGroup( groupIndex );
    	if( LinkManager != none )
    	{
    		LinkManager.LinkEntered( self, groupIndex, other );
    	}
	}
	else
	{
		xPawn(other).ClientMessage( class'GroupManager'.default.GroupColor $ "Sorry you cannot contribute until you join a group!" );
	}
}

simulated event TriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	if( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
	{
		return;
	}
	TriggerTime = Level.TimeSeconds;
	super.TriggerEvent( EventName, Other, EventInstigator );
}

// TODO: Sync code practice with GroupTriggerVolume.
/** Check if a partition of groupIndex is in touch with this volume. */
function bool HasAllMembers( int groupIndex, optional out int missingMembers, optional out array<Pawn> members )
{
	GetPlayersInVolume( members );
	FilterPlayersByGroup( groupIndex, members );

	// Calc how many members aren't found.
	missingMembers = (RequiredMembersCount - Min( members.Length, RequiredMembersCount ));
	// Return True if we found more members than need and that the group is indeed at it capacity.
	return (members.Length >= RequiredMembersCount && Manager.Groups[groupIndex].Members.Length == Manager.MaxGroupSize);
}

defaultproperties
{
	Info="At least an amount of @RequiredMembersCount members of a group must enter this volume in order to trigger its event."
}
