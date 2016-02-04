/*==============================================================================
   TrialGroup
   Copyright (C) 2010 - 2016 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupRadar extends Info
	placeable;

#exec obj load file="Radar.utx" package="TrialGroup"
#exec TEXTURE IMPORT NAME=RadarBorder FILE=Resources\RadarBorder.dds MIPS=OFF ALPHA=1 LODSET=5 DXT=5 UCLAMPMODE=TC_Clamp VCLAMPMODE=TC_Clamp

const BorderThickness = 14;
const MarkerSize = 12;
const PlayerArrowSize = 96;

var float RadarWidth, RadarAngle, ZoomScale;
var Shader RadarMap;
var TexRotator RadarMapRotator;
var ScriptedTexture MapRenderTexture;
var TexRotator PlayerArrow;
var Material PlayerMarker;
var Material FiendMarker;
var TexRotator RadarBorder;

var private int MapTextureSize;
var() Texture MapTexture;
var() vector MapCenter;
var() vector MapNorth;
var() float MapRange;
var() float RadarRange;

var protected transient float RX, RY, RW, RH;
var protected transient PlayerController PlayerOwner;
var protected transient Actor ViewTarget;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	if( Level.NetMode != NM_DedicatedServer )
	{
		if( MapTexture == none )
		{
			MapTexture = Texture'Engine.WhiteSquareTexture';
		}
		MapRenderTexture.Client = self;
		MapTextureSize = MapTexture.MaterialUSize();
		// Shader(RadarMap.Material).Diffuse = MapRenderTexture;
	}
}

simulated function Render( Canvas C, PlayerController PC )
{
	RW = RadarWidth*0.5 * C.ClipX;
	RH = RW;

	RX = 8;
	RY = 8;

	MapRenderTexture.SetSize( RW, RH );

	PlayerOwner = PC;
	ViewTarget = PC.ViewTarget;
	FixHud();
	DrawMap( C );
}

simulated function FixHud()
{
	local HUD_Assault hud;

	hud = HUD_Assault(PlayerOwner.myHUD);
	if( hud != none )
	{
		hud.RoundTimeBackGround.DrawPivot = DP_UpperLeft;
		hud.RoundTimeBackGround.PosX = -100;
		hud.RoundTimeBackGround.PosY = -100;
		hud.RoundTimeBackgroundDisc.DrawPivot = DP_UpperLeft;
		hud.RoundTimeBackgroundDisc.PosX = -100;
		hud.RoundTimeBackgroundDisc.PosY = -100;
		hud.RoundTimeSeparator.DrawPivot = DP_UpperLeft;
		hud.RoundTimeSeparator.PosX = -100;
		hud.RoundTimeSeparator.PosY = -100;
		hud.RoundTimeIcon.DrawPivot = DP_UpperLeft;
		hud.RoundTimeIcon.PosX = -100;
		hud.RoundTimeIcon.PosY = -100;
		hud.RoundTimeMinutes.DrawPivot = DP_UpperLeft;
		hud.RoundTimeMinutes.PosX = -100;
		hud.RoundTimeMinutes.PosY = -100;
		hud.RoundTimeSeconds.DrawPivot = DP_UpperLeft;
		hud.RoundTimeSeconds.PosX = -100;
		hud.RoundTimeSeconds.PosY = -100;

		hud.ReinforceBackGround.DrawPivot = DP_UpperLeft;
		hud.ReinforceBackGround.PosX = -100;
		hud.ReinforceBackGround.PosY = -100;
		hud.ReinforceBackgroundDisc.DrawPivot = DP_UpperLeft;
		hud.ReinforceBackgroundDisc.PosX = -100;
		hud.ReinforceBackgroundDisc.PosY = -100;
		hud.ReinforceIcon.DrawPivot = DP_UpperLeft;
		hud.ReinforceIcon.PosX = -100;
		hud.ReinforceIcon.PosY = -100;
		hud.ReinforceSprNum.DrawPivot = DP_UpperLeft;
		hud.ReinforceSprNum.PosX = -100;
		hud.ReinforceSprNum.PosY = -100;
		hud.ReinforcePulse.DrawPivot = DP_UpperLeft;
		hud.ReinforcePulse.PosX = -100;
		hud.ReinforcePulse.PosY = -100;

		hud.TeleportBackGround.DrawPivot = DP_UpperLeft;
		hud.TeleportBackGround.PosX = -100;
		hud.TeleportBackGround.PosY = -100;
		hud.TeleportBackgroundDisc.DrawPivot = DP_UpperLeft;
		hud.TeleportBackgroundDisc.PosX = -100;
		hud.TeleportBackgroundDisc.PosY = -100;
		hud.TeleportIcon.DrawPivot = DP_UpperLeft;
		hud.TeleportIcon.PosX = -100;
		hud.TeleportIcon.PosY = -100;
		hud.TeleportSprNum.DrawPivot = DP_UpperLeft;
		hud.TeleportSprNum.PosX = -100;
		hud.TeleportSprNum.PosY = -100;
		hud.TeleportPulse.DrawPivot = DP_UpperLeft;
		hud.TeleportPulse.PosX = -100;
		hud.TeleportPulse.PosY = -100;

		hud.VSBackground.DrawPivot = DP_UpperLeft;
		hud.VSBackground.PosX = -100;
		hud.VSBackground.PosY = -100;
		hud.VSIcon.DrawPivot = DP_UpperLeft;
		hud.VSIcon.PosX = -100;
		hud.VSIcon.PosY = -100;
		hud.VSPulse.DrawPivot = DP_UpperLeft;
		hud.VSPulse.PosX = -100;
		hud.VSPulse.PosY = -100;
		hud.VSBackgroundDisc.DrawPivot = DP_UpperLeft;
		hud.VSBackgroundDisc.PosX = -100;
		hud.VSBackgroundDisc.PosY = -100;
	}
}

simulated function Vector GetMapPosFor( Vector pos, optional float clampRange )
{
	local Vector rel, dir, v;
	local float angle;
	local float dist;

	rel = pos - ViewTarget.Location;
	dir = rel;
	dir.z = 0;
	dist = RW/RadarRange*(VSize( dir )*ZoomScale);

	if( dist > RW*0.5 - BorderThickness )
	{
		v.z = -1;
		dist = RW*(clampRange/RadarRange)*0.5;
	}

	angle = rotator(dir).Yaw*(pi/32768);
	v.x = dist*cos( angle );
	v.y = dist*sin( angle );
	return v;
}

simulated function RenderTexture( ScriptedTexture tex )
{
	local float playerDist,
				playerAngle,
				distInPixels,
				minimapVisibleSize,
				x, y;
	local Vector playerDir;

	playerDir = (MapCenter - ViewTarget.Location);
	playerDir.z = 0;
	playerDist = VSize(playerDir);
	playerAngle = rotator(playerDir).Yaw*(pi/32768);
	distInPixels = playerDist/MapRange*MapTextureSize;
	minimapVisibleSize = RadarRange/MapRange*MapTextureSize;

	x = MapTextureSize/2 - distInPixels*cos(playerAngle) - minimapVisibleSize*0.5;
	y = MapTextureSize/2 - distInPixels*sin(playerAngle) - minimapVisibleSize*0.5;
	// RadarMapRotator.Rotation.Yaw = -ViewTarget.Rotation.Yaw - 16384;
	// RadarMapRotator.UOffset = x;
	// RadarMapRotator.VOffset = y;
	tex.DrawTile( 0, 0, RW, RH, x, y, minimapVisibleSize, minimapVisibleSize, MapTexture, class'HUD'.default.WhiteColor );
}

simulated function DrawMap( Canvas C )
{
	local Actor a;
	local xPawn p;
	local GroupTaskComplete gtc;
	local Vector x, y, z, v;
	local float nYaw;

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.DrawColor.A = 255;

	C.SetPos( RX, RY );
	C.DrawTile( RadarMap, RW, RH, 0, 0, RadarMap.MaterialUSize(), RadarMap.MaterialVSize() );

	// nYaw = -rotator(Vector(ViewTarget.Rotation) - MapNorth*MapRange).Yaw - 16384;
	GetAxes( ViewTarget.Rotation, x, y, z );
	nYaw = asin(y dot MapNorth)*10430.3783504704527;
	RadarBorder.Rotation.Yaw = nYaw;

	C.SetPos( RX, RY );
	C.DrawColor.R = 10;
	C.DrawColor.G = 10;
	C.DrawColor.B = 20;
	C.DrawColor.A = 200;
	C.DrawTile( RadarBorder, RW, RH, 0, 0, 256, 256 );

	foreach DynamicActors( class'Actor', a )
	{
		if( a.IsA('Monster') )
		{
			v = GetMapPosFor( a.Location );
			if( v.z == -1 )
			{
				continue;
			}

			if( a.Texture == Texture'XEffects.RedMarker_t' )
			{
				DrawMarker( C, v.x, v.y, class'HUD'.default.RedColor, FiendMarker, 1.0 );
			}
			else
			{
				DrawMarker( C, v.x, v.y, class'HUD'.default.RedColor, a.Texture, 1.0 );
			}
		}
		else if( a.IsA('xPawn') )
		{
			p = xPawn(a);
			if( p.Health <= 0 || p == ViewTarget )
			{
				continue;
			}

			v = GetMapPosFor( a.Location );
			if( v.z == -1 )
			{
				continue;
			}

			DrawPlayer( C, p, v.x, v.y );
		}
		else if( a.IsA('GroupTaskComplete') )
		{
			gtc = GroupTaskComplete(a);
			v = GetMapPosFor( a.Location, RadarRange );
			// if( v.z == -1 )
			// {
			// 	continue;
			// }

			DrawMarker( C, v.x, v.y, class'HUD'.default.PurpleColor, PlayerMarker, 1.0 );
		}
	}

	v = GetMapPosFor( MapCenter*-vector(ViewTarget.Rotation) + (MapNorth*MapRange), RadarRange );
	DrawMarker( C, v.x, v.y, class'HUD'.default.RedColor, PlayerMarker, 1.0 );

	// Render self
	DrawPlayer( C, Pawn(ViewTarget), 0, 0, true );
	DrawWalls( C, Pawn(ViewTarget) );
}

simulated function DrawPlayer( Canvas C, Pawn p, float x, float y, optional bool isOwner )
{
	local float x1, y1;
	local float markW, markH, w, h;

	markW = MarkerSize*ZoomScale;
	markH = MarkerSize*ZoomScale;

	if( isOwner )
	{
		// markW *= 2;
		// markH *= 2;
		w = PlayerArrowSize*ZoomScale;
		h = PlayerArrowSize*ZoomScale;
		x1 = (RX + RW*0.5 + (x - w*0.5)) - markW*0.5;
		y1 = (RY + RH*0.5 + (y - h*0.5));
		// angle = ViewTarget.Rotation.Yaw*(pi/32768);
		PlayerArrow.Rotation.Yaw = -ViewTarget.Rotation.Yaw - 16384;
		C.SetPos( x1 + markW/2*cos( RadarAngle ), y1 + markH/2*sin( RadarAngle ) );
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		C.DrawColor.A = 166;
		C.DrawTile( PlayerArrow, w, h, 0, 0, 64, 64 );
	}

	x1 = (RX + RW*0.5 + (x - markW*0.5));
	y1 = (RY + RH*0.5 + (y - markH*0.5));

	C.SetPos( x1, y1 );
	C.DrawColor.R = 0x15;
	C.DrawColor.G = 0x93;
	C.DrawColor.B = 0xA9;
	C.DrawColor.A = 255;
	C.DrawTile( PlayerMarker, markW, markH, 0, 0, 16, 16 );
}

simulated function DrawMarker( Canvas C, float x, float y, color clr, Material icon, float scaling )
{
	local float w, h;

	w = MarkerSize*scaling*ZoomScale;
	h = MarkerSize*scaling*ZoomScale;

	x = (RX + RW*0.5 + x - w*0.5);
	y = (RY + RH*0.5 + y - h*0.5);

	C.DrawColor = clr;
	C.DrawColor.A = 255;

	C.SetPos( x, y );
	C.DrawTile( icon, w, h, 0, 0, icon.MaterialUSize(), icon.MaterialVSize() );
}

simulated function DrawWalls( Canvas C, Pawn p )
{
	// local vector x, y, z, hitLocation, hitNormal, pos;
	// local float w;

	// w = 32;
	// GetAxes( rotator(vect(1, 0, 0)), x, y, z );
	// if( p.Trace( hitLocation, hitNormal, y*RadarRange ) == Level ){
	// 	pos = GetMapPosFor( hitLocation );
	// 	C.SetPos( (RX + RW*0.5 + pos.x), (RY + RH*0.5 + pos.y - w*0.5) );
	// 	C.DrawColor = class'HUD'.default.WhiteColor;
	// 	C.DrawLine( 1, w );
	// 	C.DrawText( "y" );
	// }

	// if( p.Trace( hitLocation, hitNormal, x*RadarRange ) == Level ){
	// 	pos = GetMapPosFor( hitLocation );
	// 	C.SetPos( (RX + RW*0.5 + pos.x - w*0.5), (RY + RH*0.5 + pos.y) );
	// 	C.DrawColor = class'HUD'.default.WhiteColor;
	// 	C.DrawLine( 1, w );
	// 	C.DrawText( "x" );
	// }

	// if( p.Trace( hitLocation, hitNormal, -(y*RadarRange) ) == Level ){
	// 	pos = GetMapPosFor( hitLocation );
	// 	C.SetPos( (RX + RW*0.5 + pos.x - w*0.5), (RY + RH*0.5 + pos.y) );
	// 	C.DrawColor = class'HUD'.default.WhiteColor;
	// 	C.DrawLine( 3, w );
	// 	C.DrawText( "-y" );
	// }

	// if( p.Trace( hitLocation, hitNormal, -(x*RadarRange) ) == Level ){
	// 	pos = GetMapPosFor( hitLocation );
	// 	C.SetPos( (RX + RW*0.5 + pos.x), (RY + RH*0.5 + pos.y - w*0.5) );
	// 	C.DrawColor = class'HUD'.default.WhiteColor;
	// 	C.DrawLine( 1, w );
	// 	C.DrawText( "-x" );
	// }
}

defaultproperties
{
	bDirectional=true
    bHidden=true
    RemoteRole=ROLE_None

    RadarRange=2400.00
    RadarWidth=0.25
    ZoomScale=1.0

    MapRange=8000
    MapNorth=(Y=1.0)

    begin object name=oMapRender class=ScriptedTexture
    	UClampMode=TC_Clamp
    	VClampMode=TC_Clamp
    	UClamp=1024
    	VClamp=1024
    end object
    MapRenderTexture=oMapRender

    begin object name=oPostMapRender class=TexRotator
    	Material=oMapRender
    	UOffset=512
    	VOffset=512
    end object
    RadarMapRotator=oPostMapRender

    begin object name=oMapShader class=Shader
    	Diffuse=oPostMapRender
    	Opacity=Texture'RadarMask'
    	OutputBlending=OB_Masked
    end object
    RadarMap=oMapShader

    begin object name=oRadarBorder class=TexRotator
    	Material=RadarBorder
    	UOffset=128
    	VOffset=128
    end object
    RadarBorder=oRadarBorder

    begin object name=oPlayerArrow class=TexRotator
    	Material=Texture'RadarSpot'
    	UOffset=32
    	VOffset=32
    end object
    PlayerArrow=oPlayerArrow
    PlayerMarker=Texture'RadarDot'
    FiendMarker=Texture'RadarFiend'

    // MapTexture=Texture'ONS-Torlan.BackgroundImage'
}