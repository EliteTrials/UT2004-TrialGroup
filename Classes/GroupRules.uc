/*==============================================================================
   TrialGroup
   Copyright (C) 2010 - 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupRules extends GameRules;

var GroupManager Manager;

function bool PreventDeath( Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation )
{
	local array<PlayerController> Members;
	local int i;

	if( Killed != None && Killed.Controller != None && !Level.Game.bGameEnded )
	{
   		i = Manager.GetGroupIndexByPlayer( Killed.Controller );
   		if( i != -1 )
   		{
   			Manager.Groups[i].CompletedTasks.Length = 0;
	   		Manager.GetMembersByGroupIndex( i, Members );
	  		for( i = 0; i < Members.Length; ++ i )
	  		{
	  			// Not myself ofc!
	  			if( Members[i].Pawn != None && Members[i].Pawn != Killed )
	  			{
	  				RespawnPlayer( Members[i].Pawn );
	  			}
	  		}
	  	}
	}
	return Super.PreventDeath(Killed,Killer,damageType,HitLocation);
}

private final function RespawnPlayer( Pawn player )
{
	Level.Game.RestartPlayer( player.Controller );
	player.Controller.PawnDied( player );
	if( player != None )
		player.Destroy();
}
