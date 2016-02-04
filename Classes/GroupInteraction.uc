/*==============================================================================
   TrialGroup
   Copyright (C) 2010 - 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupInteraction extends Interaction;

var private editconst noexport bool bMenuModified;
var private editconst noexport float LastCmdTime;
const ASHUD = class'HUD_Assault';

var protected GroupRadar Radar;
var protected GroupManager Manager;
var protected GroupHud gHud;

event Initialized()
{
	super.Initialized();
	foreach ViewportOwner.Actor.AllActors( class'GroupRadar', Radar )
	{
		break;
	}

	foreach ViewportOwner.Actor.AllActors( class'GroupManager', Manager )
	{
		break;
	}


	if( Radar == none )
	{
		Radar = ViewportOwner.Actor.Spawn( class'GroupRadar', ViewportOwner.Actor );
	}
	else
	{
		Radar.SetOwner( ViewportOwner.Actor );
	}

	gHud = ViewportOwner.Actor.Spawn( class'GroupHUD' );
	gHud.Manager = Manager;
	ViewportOwner.Actor.myHUD.AddHudOverlay( gHud );
}

event NotifyLevelChange()
{
	Radar = none;
	gHud = none;
	Master.RemoveInteraction( Self );
}

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
	local HUD_Assault gamehud;
	local Vector av;
	local float dist, xl, yl;
	local string s;
	local Actor target;
	local Pawn pawn;
	local GroupInstance group;
	local bool bIsMemberOfMyGroup;
	local byte bIsInSight;
	local GroupTriggerVolume volume;
	local GroupInstance myGroup;

	if( ViewportOwner.Actor.myHUD.bShowScoreBoard || ViewportOwner.Actor.myHUD.bHideHUD || ViewportOwner.Actor.PlayerReplicationInfo == None )
		return;

	target = ViewportOwner.Actor.ViewTarget;
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

	hud = ViewportOwner.Actor.myHUD;
	gamehud = HUD_Assault(hud);
	if( myGroup != none )
	{
		foreach target.Region.Zone.ZoneActors( class'GroupTriggerVolume', volume )
		{
			if( !volume.AllowRendering( myGroup, ViewportOwner.Actor ) )
			{
				continue;
			}

			if( volume.AllowInfoRendering( myGroup, ViewportOwner.Actor ) && IsTargetInView( C, target, volume.Location, ViewportOwner.Actor.TeamBeaconMaxDist, bIsInSight, dist ) && bIsInSight == 1
				)
			{
				volume.RenderInfo( C, myGroup, ViewportOwner.Actor );
				continue;
			}

			if( dist <= ViewportOwner.Actor.TeamBeaconMaxDist && volume.AllowTrackingRendering( myGroup, ViewportOwner.Actor ) )
			{
				volume.RenderTracking( C, gamehud, myGroup, ViewportOwner.Actor );
			}
		}
	}

	foreach target.DynamicActors( class'GroupInstance', group )
	{
		for( LRI = group.Commander; LRI != none; LRI = LRI.NextMember )
		{
			if( LRI == myLRI )
			{
				continue;
			}

			pawn = LRI.Pawn;
			if( pawn == none || pawn.bHidden || pawn.bDeleteMe )
			{
				continue;
			}

			if( !IsTargetInView( C, target, pawn.Location, ViewportOwner.Actor.TeamBeaconMaxDist, bIsInSight, dist ) )
			{
				continue;
			}

			bIsMemberOfMyGroup = group == myGroup;
			av = C.WorldToScreen( pawn.Location );
			C.DrawColor = LRI.PlayerGroup.GroupColor;
			if( bIsMemberOfMyGroup )
			{
				s = Eval( bIsInSight == 1, LRI.PlayerGroup.GroupName, pawn.PlayerReplicationInfo.PlayerName );
				if( bIsInSight == 1 )
				{
					C.DrawColor.A = 130;
				}
				else
				{
					C.DrawColor.A = 60;
				}
			}
			else
			{
				s = LRI.PlayerGroup.GroupName;
				C.DrawColor.A = 90;
			}

			ASHUD.static.Draw_2DCollisionBox( C, pawn, av, s, pawn.DrawScale, true );
			if( bIsMemberOfMyGroup && bIsInSight == 0 && dist < ViewportOwner.Actor.TeamBeaconPlayerInfoMaxDist )
			{
				s = ASHUD.default.IP_Bracket_Open $ int(dist/128) $ ASHUD.default.MetersString $ ASHUD.default.IP_Bracket_Close;
				C.TextSize( s, xl, yl );
				C.SetPos( av.x - xl*0.5, av.y );
				C.DrawColor.A = 150;
				C.DrawTextClipped( s );
			}
		}
	}

	if( Radar != none )
	{
		Radar.Render( C, ViewportOwner.Actor );
	}
}

final static function bool IsTargetInView( Canvas C, Actor viewer, Vector targetlocation, float maxDistance, optional out byte bIsVisible, optional out float distance )
{
	local Rotator camRot;
	local Vector camLoc, dir, x, y, z;

	C.GetCameraLocation( camLoc, camRot );
	dir = targetlocation - camLoc;
	distance = VSize( dir );
	if( distance > maxDistance )
	{
		return false;
	}

	GetAxes( viewer.Rotation, x, y, z );
	if( (dir/distance) dot x <= 0.6 )
	{
		return false;
	}

	bIsVisible = byte(viewer.FastTrace( targetlocation, camLoc ));
	return true;
}

exec function LogPosition()
{
	ViewportOwner.Actor.ClientMessage( "Pos:" @ ViewportOwner.Actor.Pawn.Location );
}

defaultproperties
{
	bVisible=true
	bRequiresTick=true
}