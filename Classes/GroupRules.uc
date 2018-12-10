/*==============================================================================
   TrialGroup
   Copyright (C) 2010 - 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupRules extends GameRules;

var GroupManager Manager;

// function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
// {
// 	local Teleporter Tel;

// 	// Copy from gameinfo FindPlayerStart,
// 	// - we override this to ensure that our logic has priority over MutBestTimes' FindPlayerStart
// 	// - which will always return the first found PlayerStart and thus prevent "incomingName" from being handled.
// 	if( incomingName != "" )
//         foreach AllActors( class'Teleporter', Tel )
//             if( string(Tel.Tag) ~= incomingName )
//                 return Tel;

// 	return super.FindPlayerStart( Player, InTeam, incomingName );
// }

function bool PreventDeath( Pawn killed, Controller killer, class<DamageType> damageType, vector hitLocation )
{
	local array<PlayerController> Members;
	local int i;
	local GroupInstance playerGroup;

	if( killed != none && killed.Controller != none && !Level.Game.bGameEnded )
	{
   		i = Manager.GetGroupIndexByPlayer( killed.Controller );
   		if( i != -1 )
   		{
			playerGroup = Manager.Groups[i].Instance;
			if( class<Suicided>(damageType) == none && playerGroup.GroupCheckPoint != none )
			{
				FetchFromHell(killed.Controller, playerGroup);
				return true;
			}

			playerGroup.GroupCheckPoint = none;
   			Manager.Groups[i].CompletedTasks.Length = 0;
	   		Manager.GetMembersByGroupIndex( i, Members );
	  		for( i = 0; i < Members.Length; ++ i )
	  		{
	  			// Not myself ofc!
	  			if( Members[i].Pawn != None && Members[i].Pawn != killed )
	  			{
	  				RespawnPlayer( Members[i].Pawn );
	  			}
	  		}
	  	}
	}
	return super.PreventDeath( killed, killer, damageType, hitLocation );
}

function bool PreventSever( Pawn killed, Name boneName, int damage, class<DamageType> damageType )
{
	local int i;
	local GroupInstance playerGroup;

	if( killed != none && killed.Controller != none && !Level.Game.bGameEnded )
	{
   		i = Manager.GetGroupIndexByPlayer( killed.Controller );
   		if( i != -1 )
   		{
			playerGroup = Manager.Groups[i].Instance;
			return class<Suicided>(damageType) == none && playerGroup.GroupCheckPoint != none;
		}
	}
	return super.PreventSever( killed, boneName, damage, damageType );
}

private final function FetchFromHell( Controller player, GroupInstance playerGroup )
{
	local Teleporter checkpoint;

	checkpoint = playerGroup.GroupCheckPoint;
	checkpoint.Accept( player.Pawn, none );
}

private final function RespawnPlayer( Pawn player )
{
	Level.Game.RestartPlayer( player.Controller );
	player.Controller.PawnDied( player );
	if( player != none )
		player.Destroy();
}