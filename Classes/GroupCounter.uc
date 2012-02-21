/*==============================================================================
   TrialGroup
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupCounter extends Info
	notplaceable
	hidedropdown
	transient;

var editconst array<Controller> Members;
var editconst int Counts;
var private editconst int index, loop;

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

function Start()
{
	GotoState( 'CountDown' );
}

state CountDown
{
	function BeginState();
Begin:
	Sleep( 0.5f );
	for( loop = 0; loop < Counts; ++ loop )
	{
		for( index = 0; index < Members.Length; ++ index )
		{
			PlayerController(Members[index]).ClientMessage( Class'GroupManager'.Default.GroupColor $ "CountDown: " $ Counts - loop $ "..." );
		}
		Sleep( 1.f );
	}
	for( index = 0; index < Members.Length; ++ index )
	{
		PlayerController(Members[index]).ClientMessage( Class'GroupManager'.Default.GroupColor $ "CountDown: " $ Class'HUD'.Default.RedColor $ "GO!" );
	}
	Destroy();
}
