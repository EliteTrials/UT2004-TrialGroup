/*==============================================================================
   TrialGroup
   Copyright (C) 2016 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupWaizer extends Projector;

var Actor WaizedTarget;
var bool bIsOurs;
var Actor Eye;
var GroupInstance OwnerGroup;

var() Sound MarkSound;

final function bool IsRelevantToGroup( /**xPawn*/Actor target )
{
	local int groupIndex;
	local GroupManager manager;

	if( Pawn(target) == none || Pawn(target).Controller == none )
	{
		// Log( "Invalid target!" @ target );
		return false;
	}

	manager = class'GroupManager'.static.Get(target.Level);
	groupIndex = manager.GetGroupIndexByPlayer( Pawn(target).Controller );
	return groupIndex != -1 && manager.Groups[groupIndex].Instance == OwnerGroup;
}

replication
{
	reliable if( bNetInitial )
		WaizedTarget;

	reliable if( bNetInitial && IsRelevantToGroup( Level.ReplicationViewTarget ) )
		bIsOurs;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	if( Level.NetMode != NM_DedicatedServer )
	{
		PlaySound( MarkSound, SLOT_INTERACT, 160, true, 600 );
		Eye = Spawn( class'GroupWaizerEye', self,, Location, Rotation );
	}
}

simulated function Render( Canvas C )
{
	local vector screenPos;
	local HUD_Assault hud;
	local float scl;

	if( WaizedTarget == none )
	{
		return;
	}

	hud = HUD_Assault(Level.GetLocalPlayerController().myHUD);
	if( hud == none )
	{
		// The current match appears not to be using the Assault HUD.
		return;
	}
	screenPos = C.WorldToScreen( Location );
	C.DrawColor.R = 255;
	C.DrawColor.G = 127;
	C.DrawColor.B = 0;
	C.DrawColor.A = 255;
	if( !bIsOurs )
	{
		C.DrawColor.A = 25;
	}
	scl = hud.HudScale;
	hud.HudScale = 1.0f + (Eye.DrawScale/3.0f);
	hud.DrawActorTracking( C, self, false, screenPos );
	hud.HudScale = scl;

	if( !WaizedTarget.IsA('Mover') )
	{
		return;
	}

	if( class'GroupInteraction'.static.IsTargetInView( C, Level.GetLocalPlayerController(), Location, 3000 ) )
	{
		C.DrawActor( WaizedTarget, true, true );
	}
}

simulated event Destroyed()
{
	super.Destroyed();
	if( Eye != none )
	{
		Eye.Destroy();
	}
}

defaultproperties
{
	bNetInitialRotation=true
	bNetTemporary=true
	bAlwaysRelevant=True
	bOnlyOwnerSee=false
	RemoteRole=ROLE_SimulatedProxy
	bStatic=false
	bNoDelete=false
	bGameRelevant=true
	LifeSpan=3

	ProjTexture=Combiner'Target'
	DrawScale=0.2
	FOV=1
	MaxTraceDistance=200
	FrameBufferBlendingOp=PB_AlphaBlend
	MaterialBlendingOp=PB_None
	bProjectBSP=true
	bProjectStaticMesh=true
	bProjectTerrain=true
	bProjectActor=false
	bGradient=false
	GradientTexture=GRADIENT_Clip
	bDynamicAttach=true
	bClipBSP=true
	bClipStaticMesh=true

	MarkSound=Sound'2K4MenuSounds.Generic.msfxFade'

	LightType=LT_Pulse
	bDynamicLight=true
	LightPhase=5
	LightRadius=4
	LightSaturation=25
	LightHue=24
	LightBrightness=180
}