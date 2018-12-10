/*==============================================================================
   TrialGroup
   Copyright (C) 2010 - 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupObjective extends TriggeredObjective
	hidecategories(Lighting,LightColor,Karma,Force,Collision,Sound)
	placeable;

var editconst noexport GroupManager Manager;

// Operator from ServerBTimes.u
static final operator(102) string $( Color B, coerce string A )
{
	return (Chr( 0x1B ) $ (Chr( Max( B.R, 1 ) ) $ Chr( Max( B.G, 1 ) ) $ Chr( Max( B.B, 1 ) ))) $ A;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	Manager = class'GroupManager'.static.Get( Level );
}

function Trigger( Actor other, Pawn instigator )
{
	local int m, groupIndex;

	if( bDisabled || instigator == none || instigator.Controller == none || !UnrealMPGameInfo(Level.Game).CanDisableObjective( self ) )
	{
		return;
	}

    groupIndex = Manager.GetGroupIndexByPlayer( instigator.Controller );
    if( groupIndex != -1 )
    {
    	// Because we are comparing by members length to find out whether a group is full, it is important to ensure that empty groups or disconnected players have been dereferenced!
    	Manager.ClearEmptyGroup( groupIndex );

    	if( Manager.Groups[groupIndex].Members.Length != Manager.MaxGroupSize )
    	{
    		xPawn(instigator).ClientMessage( class'GroupManager'.default.GroupColor $ "The group you are in is not at its capacity! You need a group size of" @ Manager.MaxGroupSize );
    		return;
    	}

		if( Manager.Tasks.Length != Manager.GetGroupCompletedTasks( groupIndex, false ) )
		{
			xPawn(instigator).ClientMessage( class'GroupManager'.default.GroupColor $ "You haven't completed all the group tasks yet!" );
			return;
		}

		// Give the objective's reward to each member of the group. The instigator is ignored here because he or she will be rewarded by the game ender reward.
		for( m = 0; m < Manager.Groups[groupIndex].Members.Length; ++ m )
		{
			if( Manager.Groups[groupIndex].Members[m] != instigator.Controller )
			{
				if( ASPlayerReplicationInfo(Manager.Groups[groupIndex].Members[m].PlayerReplicationInfo) != none )
				{
					++ ASPlayerReplicationInfo(Manager.Groups[groupIndex].Members[m].PlayerReplicationInfo).DisabledObjectivesCount;
					++ ASPlayerReplicationInfo(Manager.Groups[groupIndex].Members[m].PlayerReplicationInfo).DisabledFinalObjective;
				}
			}
		}
		Manager.Groups[groupindex].CompletedTasks.Length = 0;
		Manager.Groups[groupindex].Instance.GroupCheckPoint = none;
		DisableObjective( instigator );
	}
	else
	{
		xPawn(instigator).ClientMessage( class'GroupManager'.default.GroupColor $ "Sorry you cannot complete the objective until you join a group!" );
	}
}

defaultproperties
{
	Objective_Info_Attacker="Group Objective"
	Objective_Info_Defender=""
	ObjectiveDescription="Trigger Objective with a group to disable it."
	ObjectiveName="Group Objective"
}
