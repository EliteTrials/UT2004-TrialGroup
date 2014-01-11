/*==============================================================================
   TrialGroup
   Copyright (C) 2010 - 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupCounter extends Info
	transient;

var GroupManager Manager;
var protected int GroupIndex;
var protected int _TicksCount;
var private int _TickIndex;

var() localized string CountMessage;
var() localized string GoMessage;

// Operator from ServerBTimes.u
static final operator(101) string $( coerce string A, Color B )
{
	return A $ (Chr( 0x1B ) $ (Chr( Max( B.R, 1 )  ) $ Chr( Max( B.G, 1 ) ) $ Chr( Max( B.B, 1 ) )));
}

// Operator from ServerBTimes.u
static final operator(102) string $( Color B, coerce string A )
{
	return (Chr( 0x1B ) $ (Chr( Max( B.R, 1 ) ) $ Chr( Max( B.G, 1 ) ) $ Chr( Max( B.B, 1 ) ))) $ A;
}

event PreBeginPlay()
{
	super.PreBeginPlay();
	Manager = GroupManager(Owner);
}

function Start( int groupIndex, int ticks )
{
	_TicksCount = ticks;
	GroupIndex = groupIndex;
	GotoState( 'CountDown' );
}

state CountDown
{
	function BeginState();

Begin:
	Sleep( 0.25f );
	for( _TickIndex = 0; _TickIndex < _TicksCount; ++ _TickIndex )
	{
		Manager.GroupSendMessage( GroupIndex, Repl(CountMessage, "%i", _TicksCount - _TickIndex) );
		Sleep( 1.f );
	}

	Manager.GroupSendMessage( GroupIndex, class'HUD'.default.RedColor $ GoMessage );
	Destroy();
}

defaultproperties
{
	CountMessage="%i..."
	GoMessage="GO!"
}
