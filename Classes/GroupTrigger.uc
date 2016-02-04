/*==============================================================================
   TrialGroup
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupTrigger extends Triggers
	hidecategories(Lighting,LightColor,Karma,Force,Collision,Sound);

var editconst noexport GroupManager Manager;

event PostBeginPlay()
{
	super.PostBeginPlay();
	Manager = class'GroupManager'.static.Get( Level );
}