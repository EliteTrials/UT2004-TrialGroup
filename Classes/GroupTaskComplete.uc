/*==============================================================================
   TrialGroup
   Copyright (C) 2010 - 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupTaskComplete extends GroupTrigger
	placeable;

#exec obj load file="GameSounds.uax";

/** The name of this task, this property was used to identify whether a group had completed it already. But now it's only part of a message. */
var() localized string TaskName;

/** A broadcasted message to the instigator's group for when this task is completed. */
var() localized string TaskMessage;

/** Determines whether this is an optional task. Optional tasks don't have to be completed by a group to finish the map. */
var() const bool bOptionalTask;

/** The higher, the more points that will be awarded to every group's members. */
var() const enum EOptionalTaskReward
{
	OTR_One,
	OTR_Two,
	OTR_Three,
	OTR_Four,
	OTR_Five
} OptionalTaskReward;

/** Sound to broadcast to all members when the task gets completed. */
var() Sound CompletedAnnouncement;

/** The event to instigate if instigator has no group. */
var(Events) private const name EventWhenNoGroup;

/** The event to instigate when the task is completed for the first time (on a group basis). */
var(Events) private const name EventWhenInitialTaskComplete;

/** The event to instigate when the task was already completed. */
var(Events) private const name EventWhenAlreadyComplete;

/** The complete message to broadcast to the instigator's group members. */
var() localized string lzCompleteMessage;

/** Any death cause except for "suicide" will respawn the dying player to a Teleporter with a matching tag. */
var() name CheckPointTag;

event PostBeginPlay()
{
	super.PostBeginPlay();

	if( Manager != none )
	{
		Manager.RegisterTask( self );
	}
}

function Trigger( Actor Other, Pawn instigator )
{
	local int i, groupIndex;
	local string s;
	local Teleporter tele;

	if( instigator == none || instigator.Controller == none )
	{
		Warn( "A group task was triggered without an instigator!" );
		return;
	}

	groupIndex = Manager.GetGroupIndexByPlayer( instigator.Controller );
	if( groupIndex != -1 )
	{
		for( i = 0; i < Manager.Groups[groupIndex].CompletedTasks.Length; ++ i )
		{
			if( Manager.Groups[groupIndex].CompletedTasks[i] == self )
			{
				// Already completed!
				if( EventWhenAlreadyComplete != '' )
				{
					TriggerEvent( EventWhenAlreadyComplete, self, instigator );
				}
				return;
			}
		}

		if( CheckPointTag != '' )
		{
			// FindPlayerStart involves too many dynamic conditions due mutators so we look it up directly.
			foreach AllActors( class'Teleporter', tele )
				if( tele.Tag == CheckPointTag )
				{
					Manager.Groups[groupIndex].Instance.GroupCheckPoint = tele;
				}

			// Manager.Groups[groupIndex].Instance.GroupCheckPoint = Teleporter(Level.Game.FindPlayerStart(
			// 	instigator.Controller,
			// 	instigator.GetTeamNum(),
			// 	string(CheckPointTag)
			// ));
		}
		Manager.Groups[groupIndex].CompletedTasks[Manager.Groups[groupIndex].CompletedTasks.Length] = self;
		s = Repl(Repl(Repl(lzCompleteMessage,
			"%name%", Taskname),
			"%n", Manager.GetGroupCompletedTasks( groupIndex, false )),
			"%c", Manager.Tasks.Length
		);
		Manager.GroupSendMessage( groupIndex, s, Manager.TaskMessageClass );
		Manager.GroupPlaySound( groupIndex, CompletedAnnouncement );

		if( TaskMessage != "" )
		{
			Manager.GroupSendMessage( groupIndex, TaskMessage );
		}

		if( bOptionalTask )
		{
			Manager.RewardGroup( groupIndex, OptionalTaskReward + 1 );
		}
		else
		{
			Manager.RewardGroup( groupIndex, 1 );
		}

		if( EventWhenInitialTaskComplete != '' )
		{
			TriggerEvent( EventWhenInitialTaskComplete, self, instigator );
		}
	}
	else
	{
		if( EventWhenNoGroup != '' )
		{
			TriggerEvent( EventWhenNoGroup, self, instigator );
		}
	}
	// else no group
}

defaultproperties
{
	lzCompleteMessage="%name% (%n/%c)"
	TaskName="Escape The Caves"
	TaskMessage=""
	bOptionalTask=false
	OptionalTaskReward=OTR_Two
	CompletedAnnouncement=GameSounds.DDAverted

	bGameRelevant=true
	bNoDelete=true
}
