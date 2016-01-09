/*==============================================================================
   TrialGroup
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupEventTrigger extends GroupTrigger
	placeable;

function Trigger( Actor other, Pawn instigator )
{
	local int m, groupIndex;

	if( instigator == none || instigator.Controller == none )
	{
		return;
	}

	groupIndex = Manager.GetGroupIndexByPlayer( instigator.Controller );
	if( groupIndex != -1 )
	{
		// Get all members to trigger the specified event so that all can be effected by the ...
		// Can fail if the trigger has a delay.
		for( m = 0; m < Manager.Groups[groupIndex].Members.Length; ++ m )
		{
			if( Manager.Groups[groupIndex].Members[m].Pawn != none )
			{
				TriggerEvent( Event, self, Manager.Groups[groupIndex].Members[m].Pawn );
			}
		}
	}
	// else no group
}
