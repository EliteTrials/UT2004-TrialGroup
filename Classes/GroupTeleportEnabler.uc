/*==============================================================================
   TrialGroup
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupTeleportEnabler extends Info
	hidedropdown
	cacheexempt
	notplaceable;

var editconst noexport Teleporter DisabledTP;

event Timer()
{
	if( DisabledTP != None )
	{
		DisabledTP.bEnabled = true;
		Destroy();
	}
}

defaultproperties
{
	bNoDelete=false
	bStatic=false
}
