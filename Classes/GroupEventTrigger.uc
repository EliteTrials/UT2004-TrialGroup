/*==============================================================================
   TrialGroup
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupEventTrigger extends GroupTrigger
	placeable;

function Trigger( Actor Other, Pawn Instigator )
{
	local int m, groupindex;

	if( Instigator == None || Instigator.Controller == None )
	{
		return;
	}

	groupindex = Manager.GetGroupIndexByPlayer( Instigator.Controller );
	if( groupindex != -1 )
	{
		// Get all members to trigger the specified event so that all can be effected by the ...
		// Can fail if the trigger has a delay.
		for( m = 0; m < Manager.Groups[groupindex].Members.Length; ++ m )
		{
			if( Manager.Groups[groupindex].Members[m].Pawn != None )
			{
				TriggerEvent( Event, self, Manager.Groups[groupindex].Members[m].Pawn );
			}
		}
	}
	// else no group
}
