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
var() private editconst const noexport string Info;

// Operator from ServerBTimes.u
static final operator(102) string $( Color B, coerce string A )
{
	return (Chr( 0x1B ) $ (Chr( Max( B.R, 1 ) ) $ Chr( Max( B.G, 1 ) ) $ Chr( Max( B.B, 1 ) ))) $ A;
}

function Trigger( Actor Other, Pawn Instigator )
{
	local int m, groupindex;

	if( bDisabled || Instigator == None || Instigator.Controller == None || !UnrealMPGameInfo(Level.Game).CanDisableObjective( Self ) )
	{
		return;
	}

    groupindex = Manager.GetGroupIndexByPlayer( Instigator.Controller );
    if( groupindex != -1 )
    {
    	// Because we are comparing by members length to find out whether the group is fulll, it is important to clear all None references.
    	Manager.ClearEmptyGroup( groupindex );

    	if( Manager.Groups[groupindex].Members.Length != Manager.MaxGroupSize )
    	{
    		xPawn(Instigator).ClientMessage( Class'GroupManager'.Default.GroupColor $ "The group you are in is not at its capacity!, you need a group of size" @ Manager.MaxGroupSize );
    		return;
    	}

		if( Manager.Tasks.Length != Manager.GetGroupCompletedTasks( groupindex, False ) )
		{
			xPawn(Instigator).ClientMessage( Class'GroupManager'.Default.GroupColor $ "The group you are in has not completed all group tasks yet!" );
			return;
		}

		// Give everyone a reward except the instigator because the instigator will get one by the gameinfo class!.
		for( m = 0; m < Manager.Groups[groupindex].Members.Length; ++ m )
		{
			if( Manager.Groups[groupindex].Members[m] != Instigator.Controller )
			{
				if( ASPlayerReplicationInfo(Manager.Groups[groupindex].Members[m].PlayerReplicationInfo) != None )
				{
					++ ASPlayerReplicationInfo(Manager.Groups[groupindex].Members[m].PlayerReplicationInfo).DisabledObjectivesCount;
					++ ASPlayerReplicationInfo(Manager.Groups[groupindex].Members[m].PlayerReplicationInfo).DisabledFinalObjective;
				}
			}
		}
		DisableObjective( Instigator );
	}
	else
	{
		xPawn(Instigator).ClientMessage( Class'GroupManager'.Default.GroupColor $ "Sorry you cannot complete the objective, because you're not in a group!" );
	}
}

defaultproperties
{
	Objective_Info_Attacker="Group Objective"
	Objective_Info_Defender=""
	ObjectiveDescription="Trigger Objective with a group to disable it."
	ObjectiveName="Group Objective"

	Info="You must name your map AS-Group-* in order for this to function with BTimes. Warning: This objective has to be the final objective."
}
