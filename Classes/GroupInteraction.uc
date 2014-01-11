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

function PostRender( Canvas C )
{
	local GroupPlayerLinkedReplicationInfo LRI, myLRI;
	local HUD hud;
	local vector av;
	// local vector bv;
	local float dist, xl, yl;
	// local float x, y;
	local string s;
	local PlayerController target;
	local Pawn pawn;
	// local Pawn b;
	local vector camLoc, dir, aX, aY, aZ;
	local rotator camRot;
	local GroupInstance group;

	if( ViewportOwner.Actor.myHUD.bShowScoreBoard || ViewportOwner.Actor.myHUD.bHideHUD || ViewportOwner.Actor.PlayerReplicationInfo == None )
		return;

	// C.SetPos( 600, 0 );
	// C.DrawText( ViewportOwner.Actor.ViewTarget @ ViewportOwner.Actor.RealViewTarget );
	if( Pawn(ViewportOwner.Actor.ViewTarget) != none )
	{
		target = PlayerController(Pawn(ViewportOwner.Actor.ViewTarget).Controller);
	}
	else
	{
		target = ViewportOwner.Actor;
	}

	myLRI = class'GroupManager'.static.GetGroupPlayerReplicationInfo( target );
	if( myLRI == none )
	{
		return;
	}

	hud = ViewportOwner.Actor.myHUD;
	foreach target.DynamicActors( class'GroupInstance', group )
	{
		for( LRI = group.Commander; LRI != none; LRI = LRI.NextMember )
		{
			// C.SetPos( 0, y );
			// C.DrawText( LRI );
			// y += 20;

			pawn = LRI.Pawn;
			if( pawn == none || ViewportOwner.Actor.ViewTarget == none )
			{
				continue;
			}

			if( pawn.bHidden || pawn.bDeleteMe )
			{
				continue;
			}

			C.GetCameraLocation( camLoc, camRot );
			dir = pawn.Location - camLoc;
			dist = VSize( dir );
			if( dist > ViewportOwner.Actor.TeamBeaconMaxDist || !ViewportOwner.Actor.FastTrace( pawn.Location, camLoc ) )
			{
				continue;
			}

			GetAxes( ViewportOwner.Actor.ViewTarget.Rotation, aX, aY, aZ );
			dir /= dist;
			if( !((dir dot aX) > 0.6) )
			{
				continue;
			}

			if( dist < ViewportOwner.Actor.TeamBeaconPlayerInfoMaxDist*0.4f )
			{
				if( LRI != myLRI )
				{
					av = C.WorldToScreen( pawn.Location );
					C.DrawColor = LRI.PlayerGroup.GroupColor;
					if( group == myLRI.PlayerGroup )
					{						
						C.DrawColor.A = 120;
						class'HUD_Assault'.static.Draw_2DCollisionBox( C, pawn, av, LRI.PlayerGroup.GroupName, pawn.DrawScale, true );

						s = ":" $ dist / 128 $ "m";
						C.TextSize( s, xl, yl );
						C.SetPos( av.x - xl*0.5, av.y );
						C.DrawColor.A = 100;
						C.DrawTextClipped( s );
					}
					else
					{
						C.DrawColor.A = 60;
						class'HUD_Assault'.static.Draw_2DCollisionBox( C, pawn, av, LRI.PlayerGroup.GroupName, pawn.DrawScale, true );
					}
				}
			}
		}
	}
}

defaultproperties
{
	bVisible=true
	bRequiresTick=true
}
