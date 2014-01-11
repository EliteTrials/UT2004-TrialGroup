/*==============================================================================
   TrialGroup
   Copyright (C) 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupPlayerLinkedReplicationInfo extends LinkedReplicationInfo;

var bool bIsWanderer;
var string ClientMessage;

var GroupInstance PlayerGroup;
var Pawn Pawn;
var GroupPlayerLinkedReplicationInfo NextMember;

replication
{
	reliable if( Role == ROLE_Authority )
		ClientSendMessage;

	reliable if( bNetDirty )
		PlayerGroup, NextMember, Pawn;
}

simulated event PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	if( Role < ROLE_Authority )
	{
		SetOwner( Level.GetLocalPlayerController() );
	}
}

simulated function ClientSendMessage( class<GroupLocalMessage> messageClass, string message )
{
	ClientMessage = message;
	PlayerController(Owner).ReceiveLocalizedMessage( messageClass,,,, self );
	PlayerController(Owner).Player.Console.Message( message, 1.0 );
}

defaultproperties
{
	bIsWanderer=true
}