/*==============================================================================
   TrialGroup
   Copyright (C) 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupLocalMessage extends LocalMessage;

static function string GetString( optional int Switch, 
	optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2,
	optional Object Source )
{
	if( GroupInstance(Source) != none )
	{
		return GroupInstance(Source).GetQueueMessage();
	}
	return GroupPlayerLinkedReplicationInfo(Source).ClientMessage;
}

/**static function RenderComplexMessage(
    Canvas C,
    out float XL,
    out float YL,
    optional String MessageString,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	local bool pForceAlpha;
	local byte pStyle;

	pForceAlpha = C.bForceAlpha;
	C.bForceAlpha = true;
	C.ForcedAlpha = 1.0 - C.DrawColor.A/255;
	pStyle = C.Style;
	C.Style = ERenderStyle.STY_Alpha;
	C.DrawTextClipped( MessageString, false );	
	C.bForceAlpha = pForceAlpha;
	C.Style = pStyle;
}*/

defaultproperties
{
	bIsConsoleMessage=false
	bFadeMessage=true
	// bComplexString=true

	PosX=0.5
	PosY=0.15
	LifeTime=3
	FontSize=-2

	StackMode=SM_Down
}
