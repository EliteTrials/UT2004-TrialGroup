/*==============================================================================
   TrialGroup
   Copyright (C) 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupInstance extends ReplicationInfo;

var GroupManager Manager;
var int GroupId;
var string GroupName;
var Color GroupColor;

var GroupPlayerLinkedReplicationInfo Commander;
var private string QueueMessage;

replication
{
	reliable if( IsRelevantToGroup( Level.ReplicationViewTarget ) )
		QueueMessage;

	reliable if( bNetDirty )
		Commander;

	reliable if( bNetInitial )
		GroupId, GroupName, GroupColor, Manager;
}

event PreBeginPlay()
{
	super.PreBeginPlay();
	Manager = GroupManager(Owner);
	GroupColor.A = 255;
	GroupColor.R = Rand( 255 );
	GroupColor.G = Rand( 255 );
	GroupColor.B = Rand( 255 );
}

final simulated function bool IsMember( Pawn pawn )
{
	local GroupPlayerLinkedReplicationInfo LRI;

	for( LRI = Commander; LRI != none; LRI = LRI.NextMember )
	{
		if( LRI.Pawn == pawn )
		{
			return true;
		}
	}
	return false;
}

final function bool IsRelevantToGroup( /**xPawn*/Actor target )
{
	local int groupIndex;

	if( Pawn(target) == none || Pawn(target).Controller == none )
	{
		// Log( "Invalid target!" @ target );
		return false;
	}

	groupIndex = Manager.GetGroupIndexByPlayer( Pawn(target).Controller );	
	return groupIndex != -1 && Manager.Groups[groupIndex].Instance == self;
}

final simulated function SetQueueMessage( string message )
{
	QueueMessage = message;
	NetUpdateTime = Level.TimeSeconds - 1;
}

final simulated function string GetQueueMessage()
{
	return QueueMessage;
}