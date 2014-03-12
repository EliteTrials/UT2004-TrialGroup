/*==============================================================================
   TrialGroup
   Copyright (C) 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupPlayerLinkedReplicationInfo extends LinkedReplicationInfo;

var bool bIsWanderer;
var string ClientMessage;

var int PlayerGroupId;
var GroupInstance PlayerGroup;
var Pawn Pawn;
var GroupPlayerLinkedReplicationInfo NextMember;

replication
{
	reliable if( Role == ROLE_Authority )
		ClientSendMessage;

	reliable if( Role == ROLE_Authority )
		PlayerGroupId, PlayerGroup, NextMember, Pawn;
}

simulated event PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	if( Role < ROLE_Authority )
	{
		SetOwner( Level.GetLocalPlayerController() );
	}
	else
	{
		SetTimer( 0.5, true );
		Timer();
	}
}

simulated function ClientSendMessage( class<GroupLocalMessage> messageClass, string message )
{
	ClientMessage = message;
	PlayerController(Owner).ReceiveLocalizedMessage( messageClass,,,, self );
	PlayerController(Owner).Player.Console.Message( message, 1.0 );
}

event Timer()
{
	if( Owner == none )
	{
		SetTimer( 0.0, false );
		return;
	}

	if( Pawn == none && Controller(Owner).Pawn != none )
	{
		Pawn = Controller(Owner).Pawn;
	}
}

defaultproperties
{
	bIsWanderer=true

	// Overkill, but neccessary to replicate property @Base -- Deprecated, use @PlayerGroupId instead to help clients to scan the map for the correct instance.
	//bSkipActorPropertyReplication=false
	//bReplicateMovement=true
	PlayerGroupId=-1
}