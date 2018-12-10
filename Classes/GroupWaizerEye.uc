/*==============================================================================
   TrialGroup
   Copyright (C) 2016 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupWaizerEye extends Actor;

var transient bool bScalingUp;
var() float ScalingSpeed, DesiredDrawScale, InitDrawScale;

simulated event PostBeginPlay()
{
	SetDrawScale( InitDrawScale );
	bScalingUp = true;
}

simulated event Tick( float deltaTime )
{
	if( bScalingUp )
	{
		SetDrawScale( DrawScale + 1.0*ScalingSpeed*deltaTime );
		if( DrawScale >= DesiredDrawScale )
		{
			bScalingUp = false;
		}
	}
	else if( DrawScale > default.DrawScale )
	{
		SetDrawScale( DrawScale - InitDrawScale*ScalingSpeed/Owner.LifeSpan*deltaTime );
	}
}

defaultproperties
{
	DesiredDrawScale=3.0
	InitDrawScale=2.0
	DrawScale=1.0
	ScalingSpeed=2.5
	bHidden=false
	bNoDelete=false
	bStatic=false
	Texture=Texture'Engine.S_Camera'
}