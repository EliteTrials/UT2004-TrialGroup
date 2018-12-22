/*==============================================================================
   TrialGroup
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupTeleporter extends Teleporter
	hidecategories(Lighting,LightColor,Karma,Force,Sound)
	placeable;

var bool bEnabled_bak;

var() float DisabledTime;

event PostBeginPlay()
{
	bEnabled_bak = bEnabled;
	super.PostBeginPlay();
}

// Upgrade from super class...
simulated function PostTouch( Actor Other )
{
	local Teleporter D, Dest[16];
	local int i, groupindex, m;
	local GroupTeleportEnabler GTE;
	local GroupManager manager;

	// Teleport to a random teleporter in this local level, if more than one pick random.
	foreach AllActors( Class'Teleporter', D )
	{
		if( string(D.tag) ~= URL && D != self )
		{
			Dest[i] = D;
			++ i;
			if( i > arraycount(Dest) )
				break;
		}
	}

	i = rand(i);
	if( Dest[i] != None )
	{
		manager = class'Groupmanager'.static.Get( Level );
        groupindex = manager.GetGroupIndexByPlayer( xPawn(Other).Controller );
		if( groupindex != -1 )
		{
			// Teleport the actor into the other teleporter.
			if( Other.IsA( 'Pawn' ) )
			{
				Other.PlayTeleportEffect( false, true );
			}

			for( m = 0; m < manager.Groups[groupindex].Members.Length; ++ m )
			{
				if( manager.Groups[groupindex].Members[m].Pawn != None )
				{
					Dest[i].Accept( manager.Groups[groupindex].Members[m].Pawn, self );
				}
			}

			if( Pawn(Other) != None )
			{
				TriggerEvent( Event, self, Pawn(Other) );
			}

            Dest[i].bEnabled = false;
			GTE = Spawn( Class'GroupTeleportEnabler', self );
			GTE.DisabledTP = Dest[i];
			GTE.SetTimer( DisabledTime, false );
		}
	}
}

function Reset()
{
	super.Reset();
	bEnabled = bEnabled_bak;
}

defaultproperties
{
	DisabledTime=30.f
}
