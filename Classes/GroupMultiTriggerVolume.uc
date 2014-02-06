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
var() const name EventWhenFilledButNotAll;

event PawnEnteredVolume( Pawn Other )
{
	local int groupindex;

	if( xPawn(Other) == none || Other.Controller == none )
	{
		return;
	}

    groupindex = Manager.GetGroupIndexByPlayer( Other.Controller );
	if( groupindex != -1 )
	{
		// Because we are comparing by members length to find out whether the group is fulll, it is important to clear all None references.
    	Manager.ClearEmptyGroup( groupindex );
    	if( LinkManager != none )
    	{
    		LinkManager.LinkEntered( self, groupIndex, Other );
    	}
	}
	else
	{
		xPawn(Other).ClientMessage( class'GroupManager'.default.GroupColor $ "Sorry you cannot contribute to this volume because you are not in a group!" );
	}
}

// TODO: Sync code practice with GroupTriggerVolume.
/** Check if a partition of groupIndex is in touch with this volume. */
function bool HasAllMembers( int groupIndex, optional out int missingMembers, optional out array<Controller> foundMembers )
{
	local array<Controller> members;
	local int i;

	// First build up a list of all touching players.
	for( i = 0; i < Touching.Length; ++ i )
	{
    	if( xPawn(Touching[i]) != none )
    	{
    		members[members.Length] = xPawn(Touching[i]).Controller;
    	}
	}

	// Check the touching players list for members of groupIndex, and add to foundMembers.
	for( i = 0; i < members.Length; ++ i )
	{
		if( Manager.GetMemberIndexByGroupIndex( members[i], groupIndex ) != -1 )
		{
			foundMembers[foundMembers.Length] = members[i];
		}
	}

	// Calc how many members aren't found.
	missingMembers = (RequiredMembersCount - Min( foundMembers.Length, RequiredMembersCount ));
	// Return True if we found more members than need and that the group is indeed at it capacity.
	return (foundMembers.Length >= RequiredMembersCount && Manager.Groups[groupIndex].Members.Length == Manager.MaxGroupSize);
}

defaultproperties
{
	Info="Atleast an amount of (RequiredMembersCount) members of a group(group must also be full) must enter this volume in order to cause the volume to trigger the specified event."
}
