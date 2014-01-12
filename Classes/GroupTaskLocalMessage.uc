/*==============================================================================
   TrialGroup
   Copyright (C) 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupTaskLocalMessage extends GroupLocalMessage;

// Copy of Message_Awards.uc, we want identical matching graphics.
static function RenderComplexMessage( 
    Canvas Canvas, 
    out float XL,
    out float YL,
    optional String MessageString,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	local byte	Alpha;
	local float	IconSize;

	Canvas.DrawTextClipped( MessageString, false );

	if ( Switch == 0 )
	{
		IconSize			= YL * 2;
		Alpha				= Canvas.DrawColor.A;		// Backup Alpha if message fades out
		Canvas.DrawColor	= Canvas.MakeColor(255, 255, 255);
		Canvas.DrawColor.A	= Alpha;

		Canvas.SetPos( Canvas.CurX - IconSize - YL*0.33, Canvas.CurY + YL*0.5 - IconSize*0.5 );
		Canvas.DrawTile( Texture'AS_FX_TX.Icons.ScoreBoard_Objective_Final', IconSize, IconSize, 0, 0, 128, 128);
	}
}

defaultproperties
{
	bComplexString=true

	PosY=0.30
	LifeTime=4
	FontSize=-1
}