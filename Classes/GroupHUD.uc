/*==============================================================================
   TrialGroup
   Copyright (C) 2010 - 2016 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupHUD extends HudOverlay;

var() GroupManager Manager; // Set by GroupInteraction;

// SET on render phase
var() transient HUD_Assault hud;
var() transient GroupInstance myGroup;
var() transient GroupPlayerLinkedReplicationInfo myLRI;
var() transient PlayerController myPC;
var() transient GroupTaskComplete LastTask;

simulated function Render( Canvas C )
{
	local Actor target;

	hud = HUD_Assault(Owner);
	if( hud == none )
		return;

	FixHud();

	myPC = Level.GetLocalPlayerController();
	target = myPC.ViewTarget;
	if( xPawn(target) != none )
	{
		myLRI = class'GroupManager'.static.GetGroupPlayerReplicationInfo( xPawn(target).PlayerReplicationInfo );
	}
	else if( xPlayer(target) != none )
	{
		myLRI = class'GroupManager'.static.GetGroupPlayerReplicationInfo( xPlayer(target).PlayerReplicationInfo );
	}
	if( myLRI == none || target == none )
	{
		return;
	}
	myGroup = myLRI.PlayerGroup;

	RenderCurrentTask( C );
}

simulated function FixHud()
{
}

simulated function RenderCurrentTask( Canvas C )
{
	// local float x, y, xl, yl;
	local GroupTaskComplete task;
	// local bool lastB;

	task = GetCurrentTask( myPC.ViewTarget );
	if( task == none || hud.CurrentObjective == none )
	{
		return;
	}

	// Ugly thing to do... but this is way takes the least effort :D!
	if( task != LastTask )
	{
		hud.CurrentObjective.Objective_Info_Attacker = task.TaskName;
		// hud.HighlightCurrentObjective( false );
		hud.AttackerProgressUpdateTime = 1;
		LastTask = task;
	}

	// C.Font = hud.GetMediumFont( C.ClipX*hud.HUDScale );
	// C.StrLen( task.TaskName, xl, yl );
	// x = C.ClipX*0.5 - xl*0.5;
	// y = 164*hud.HUDScale + yl*0.5;
	// C.SetPos( x, y );
	// C.DrawColor = GetGroupColor();
	// C.DrawText( task.TaskName );
}

simulated function Color GetGroupColor()
{
	if( myLRI.PlayerGroup == none )
	{
		return class'GroupManager'.default.GroupColor;
	}
	return myLRI.PlayerGroup.GroupColor;
}

simulated function GroupTaskComplete GetCurrentTask( Actor target )
{
	return Manager.GetClosestTask( target.Location );
}

defaultproperties
{

}