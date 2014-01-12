/*==============================================================================
   TrialGroup
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupTaskComplete extends GroupTrigger
	placeable;

var() const string TaskName;
var() const bool bOptionalTask;
var() const enum EOptionalTaskReward
{
	OTR_One,
	OTR_Two,
	OTR_Three,
	OTR_Four,
	OTR_Five
} OptionalTaskReward;
var() private editconst const noexport string Info;
var() private const name EventWhenNoGroup;
var() private const name EventWhenInitialTaskComplete;
var() private const name EventWhenAlreadyComplete;

function Trigger( Actor Other, Pawn Instigator )
{
	local int i, groupindex;
	local string optionalmsg;

	if( Instigator == None || Instigator.Controller == None )
	{
		return;
	}

	groupindex = Manager.GetGroupIndexByPlayer( Instigator.Controller );
	if( groupindex != -1 )
	{
		for( i = 0; i < Manager.Groups[groupindex].CompletedTasks.Length; ++ i )
		{
			if( Manager.Groups[groupindex].CompletedTasks[i].TaskName == TaskName )
			{
				// Already completed!
				if( EventWhenAlreadyComplete != '' )
				{
					TriggerEvent( EventWhenAlreadyComplete, Self, Instigator );
				}
				return;
			}
		}

		Manager.Groups[groupindex].CompletedTasks[Manager.Groups[groupindex].CompletedTasks.Length] = self;
		if( Manager.OptionalTasks.Length > 0 )
		{
			optionalmsg = "(" $ Manager.GetGroupCompletedTasks( groupindex, True ) $ "/" $ Manager.OptionalTasks.Length $ ")";
		}
		Manager.GroupSendMessage( groupindex, TaskName @ "(" $ Manager.GetGroupCompletedTasks( groupindex, False ) $ "/" $ Manager.Tasks.Length $ ")" @ optionalmsg @ "completed!", Manager.TaskMessageClass );

		if( bOptionalTask )
		{
			Manager.RewardGroup( groupindex, OptionalTaskReward + 1 );
		}
		else
		{
			Manager.RewardGroup( groupindex, 1 );
		}

		if( EventWhenInitialTaskComplete != '' )
		{
			TriggerEvent( EventWhenInitialTaskComplete, Self, Instigator );
		}
	}
	else
	{
		if( EventWhenNoGroup != '' )
		{
			TriggerEvent( EventWhenNoGroup, Self, Instigator );
		}
	}
	// else no group
}

defaultproperties
{
	TaskName="e.g. ShieldGun Sync (1)"
	bOptionalTask=False
	OptionalTaskReward=OTR_Two
	Info="Input a unique taskname for each GroupTaskComplete trigger!", NOT-YET-COMPLETE"
}
