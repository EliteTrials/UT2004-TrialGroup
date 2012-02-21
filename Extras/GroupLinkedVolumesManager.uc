/*==============================================================================
   TrialGroup_Extra
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupLinkedVolumesManager extends Info
	placeable;

var() edfindable array<GroupLinkedTriggerVolume> Links;
var() localized const string lzLinksNeed;
var() localized const string lzPlayersMissing;

// Operator from ServerBTimes.u
static final operator(102) string $( Color B, coerce string A )
{
	return (Chr( 0x1B ) $ (Chr( Max( B.R, 1 ) ) $ Chr( Max( B.G, 1 ) ) $ Chr( Max( B.B, 1 ) ))) $ A;
}

event PreBeginPlay()
{
	local int i;

	super.PreBeginPlay();

	for( i = 0; i < Links.Length; ++ i )
	{
		Links[i].LinkManager = self;
	}
}

function LinkEntered( GroupLinkedTriggerVolume V, int groupIndex, Pawn Other )
{
	local int i, missingmembers, filledlinks;
	local array<Controller> foundmembers;
	local string s;

	if( V.HasAllMembers( groupindex, missingmembers, foundmembers ) )
	{
		++ filledlinks;
		for( i = 0; i < Links.Length; ++ i )
		{
			if( Links[i] != V && Links[i].HasAllMembers( groupindex ) )
			{
				++ filledlinks;
			}
		}

		if( filledlinks == Links.Length )
		{
            v.Manager.GroupSendMessage( groupindex, "All links successfully exceeded!" );
			TriggerEvent( event, self, Other );
			for( i = 0; i < Links.Length; ++ i )
			{
				Links[i].LastTriggeredByGroupName = V.Manager.Groups[groupindex].GroupName;

				// We call TriggerEvent from Links[i] incase of overriden behavior.
				Links[i].TriggerEvent( Links[i].event, Links[i], Other );
			}
		}
		else
		{       
            v.Manager.GroupSendMessage( groupindex, Repl( lzLinksNeed, "%MISSINGLINKS%", Links.Length - filledlinks ) );
		}
	}
	else	// Let the group/member know what happened...
	{
		s = class'GroupManager'.default.GroupColor $ "You need" @ missingmembers @ "more members in this volume!";
		for( i = 0; i < foundmembers.Length; ++ i )
		{
			PlayerController(foundmembers[i]).ClientMessage( s );
		}
        
        v.Manager.GroupSendMessage( groupindex, "Another partition of the group is in need of " @ missingmembers @ "more people!" );
	}
}

defaultproperties
{
	lzLinksNeed="%MISSINGLINKS% more links need to be filled!"
	bGameRelevant=true
}