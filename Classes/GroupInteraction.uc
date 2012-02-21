/*==============================================================================
   TrialGroup
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupInteraction extends Interaction;

var private editconst noexport bool bMenuModified;
var private editconst noexport float LastCmdTime;

event NotifyLevelChange()
{
	Master.RemoveInteraction( Self );
}

//	NOTE: When using this function in your code you should credit me(see license)for this function out of respect!.
final private function ModifyMenu()
{
	local UT2K4PlayerLoginMenu Menu;
	local GUITabPanel Panel;

	Menu = UT2K4PlayerLoginMenu(GUIController(ViewportOwner.Actor.Player.GUIController).FindPersistentMenuByName( UnrealPlayer(ViewportOwner.Actor).LoginMenuClass ));
	if( Menu != None )
	{
		Panel = Menu.c_Main.AddTab( "Group Manager", string( Class'GroupMenu' ),, "Manage Groups" );
		bMenuModified = True;

		Disable( 'Tick' );
		bRequiresTick = False;
		//Master.RemoveInteraction( Self );
	}
}

function Tick( float DeltaTime )
{
	if( !bMenuModified )
		ModifyMenu();
}

exec function JoinGroup( string groupName )
{
	if( ViewportOwner.Actor.Level.TimeSeconds - LastCmdTime < 0.5f )
	{
		return;
	}
	ViewportOwner.Actor.Mutate( "JoinGroup" @ groupName );
	LastCmdTime = ViewportOwner.Actor.Level.TimeSeconds;
}

exec function LeaveGroup()
{
	if( ViewportOwner.Actor.Level.TimeSeconds - LastCmdTime < 0.5f )
	{
		return;
	}
	ViewportOwner.Actor.Mutate( "LeaveGroup" );
	LastCmdTime = ViewportOwner.Actor.Level.TimeSeconds;
}

exec function GroupCountDown( optional int amount )
{
	if( ViewportOwner.Actor.Level.TimeSeconds - LastCmdTime < 0.5f )
	{
		return;
	}
	ViewportOwner.Actor.Mutate( "GroupCountDown" @ amount );
	LastCmdTime = ViewportOwner.Actor.Level.TimeSeconds;
}

exec function ShowGroupMembers()
{
	if( ViewportOwner.Actor.Level.TimeSeconds - LastCmdTime < 0.5f )
	{
		return;
	}
	ViewportOwner.Actor.Mutate( "ShowGroupMembers" );
	LastCmdTime = ViewportOwner.Actor.Level.TimeSeconds;
}

exec function GroupGO()
{
	GroupCountDown( 1 );
}

exec function GroupFast()
{
	GroupCountDown( 2 );
}

exec function GroupSlow()
{
	GroupCountDown( 3 );
}

defaultproperties
{
	bRequiresTick=True
}
