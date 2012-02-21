/*==============================================================================
   TrialGroup
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupTriggerVolume extends PhysicsVolume
	hidecategories(Lighting,LightColor,Karma,Force,Sound,PhysicsVolume)
	placeable;

var editconst noexport GroupManager Manager;
var editconst noexport string LastTriggeredByGroupName;

//var() const int MaxIdleTime;
//var() private const name EventWhenIdle;

var() private editconst const noexport string Info;

// Operator from ServerBTimes.u
static final operator(102) string $( Color B, coerce string A )
{
	return (Chr( 0x1B ) $ (Chr( Max( B.R, 1 ) ) $ Chr( Max( B.G, 1 ) ) $ Chr( Max( B.B, 1 ) ))) $ A;
}

/*event PreBeginPlay()
{
	Super.PreBeginPlay();
	if( MaxIdleTime == 0f )
	{
		Disable( 'Tick' );
	}
} */

event PawnEnteredVolume( Pawn Other )
{
	local int i, missingmembers, groupindex;
	local array<Controller> foundmembers;
	local xPawn P;
	local array<Controller> Members;

	if( xPawn(Other) == None || Other.Controller == None )
	{
		return;
	}

    groupindex = Manager.GetGroupIndexByPlayer( Other.Controller );
	if( groupindex != -1 )
	{
		for( i = 0; i < Touching.Length; ++ i )
		{
        	if( Touching[i].IsA('xPawn') )
        	{
        		P = xPawn(Touching[i]);
        		Members[Members.Length] = P.Controller;
        	}
		}

		// Because we are comparing by members length to find out whether the group is fulll, it is important to clear all None references.
    	Manager.ClearEmptyGroup( groupindex );

		/*i = Members.Length;
		Members.Length = i + 1;
		Members[i].C = Other.Controller;
		Members[i].EnterTime = Level.TimeSeconds;*/

		for( i = 0; i < Members.Length; ++ i )
		{
			if( Manager.GetMemberIndexByGroupIndex( Members[i], groupindex ) != -1 )
			{
				foundmembers[foundmembers.Length] = Members[i];
			}
		}

		missingmembers = (Manager.Groups[groupindex].Members.Length - foundmembers.Length);

		// The group is full and all of them are in the volume!, then triggerevent...
		if( foundmembers.Length == Manager.MaxGroupSize && missingmembers == 0 )
		{
			TriggerEvent( Event, Self, Other );
			LastTriggeredByGroupName = Manager.Groups[groupindex].GroupName;
		}
		else	// Let the group/member know what happened...
		{
			for( i = 0; i < foundmembers.Length; ++ i )
			{
				PlayerController(foundmembers[i]).ClientMessage( Class'GroupManager'.Default.GroupColor $ "You need" @ missingmembers @ "more members in this volume!" );
			}
		}
	}
	else
	{
		xPawn(Other).ClientMessage( Class'GroupManager'.Default.GroupColor $ "Sorry you cannot contribute to this volume because you are not in a group!" );
	}
}

/*event PawnLeavingVolume( Pawn Other )
{
	local int i;

	if( xPawn(Other) == None )
	{
		return;
	}

	for( i = 0; i < Members.Length; ++ i )
	{
		if( Members[i].C == Other.Controller )
		{
			Members.Remove( i, 1 );
			break;
		}
	}
}*/

/*event Tick( float DeltaTime )
{
	local int i;
	local NavigationPoint NewSpawn;

	for( i = 0; i < Members.Length; ++ i )
	{
		if( Level.TimeSeconds - Members[i].EnterTime >= MaxIdleTime )
		{
			if( EventWhenIdle != '' )
			{
				TriggerEvent( EventWhenIdle, Self, Members[i].C.Pawn );

				NewSpawn = Level.Game.FindPlayerStart( Members[i].C, xPawn(Members[i].C.Pawn).GetTeamNum() );
        		if( NewSpawn != None )
        		{
        			xPawn(Members[i].C.Pawn).SetLocation( NewSpawn.Location );
        			xPawn(Members[i].C.Pawn).SetRotation( NewSpawn.Rotation );

        			xPawn(Members[i].C.Pawn).ClientMessage( Class'GroupManager'.Default.GroupColor $ "You have been teleported back to your spawn location because of camping longer than" @ MaxIdleTime );
        			xPawn(Members[i].C.Pawn).PlayTeleportEffect( False, True );
        		}
			}
		}
	}
}*/

function Reset()
{
	Super.Reset();
	LastTriggeredByGroupName = "";
	//Members.Length = 0;
}

defaultproperties
{
	Info="All members of a group(group must also be full) must enter this volume in order to cause the volume to trigger the specified event"
	//bStatic=False
}
