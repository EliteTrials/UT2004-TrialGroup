/*==============================================================================
   TrialGroup
   Copyright (C) 2010 - 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupMultiVolumesManager extends Info
	placeable;

var() edfindable array<edfindable GroupMultiTriggerVolume> Links;

var() localized string lzLinksNeed, lzLinkNeed;
var() localized string lzPartition;

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

// TODO: Sync code practice with GroupTriggerVolume.
function bool LinkEntered( GroupMultiTriggerVolume V, int groupIndex, Pawn Other )
{
	local int i, missingCount, filledlinks;
	local array<Pawn> members;

	if( V.HasAllMembers( groupindex, missingCount, members ) )
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
            // v.Manager.GroupSendMessage( groupindex, "All links successfully exceeded!" );
			TriggerEvent( Event, self, Other );
			for( i = 0; i < Links.Length; ++ i )
			{
				// We call TriggerEvent from Links[i] incase of overriden behavior.
				Links[i].TriggerEvent( Links[i].Event, Links[i], Other );
			}
		}
		else
		{
			missingCount = Links.Length - filledlinks;
            v.Manager.GroupSendMessage( groupindex,
            	Eval( missingCount > 1,
            		Repl( lzLinksNeed, "%MISSINGLINKS%", missingCount ),
            		lzLinkNeed
            	),
            	v.Manager.GroupProgressMessageClass
        	);
            TriggerEvent( v.EventWhenFilledButNotAll, v, Other );
		}
		return true;
	}
	else
	{
		v.NotifyMembersMissing( members, missingCount );
		if( missingCount == 0 )
		{
        	v.Manager.GroupSendMessage( groupindex, Repl(lzPartition, "%n", missingCount), v.Manager.GroupProgressMessageClass );
		}
	}
	return false;
}

defaultproperties
{
	lzLinksNeed="%MISSINGLINKS% more links need to be filled!"
	lzLinkNeed="One more link needs to be filled!"
	lzPartition="Another partition is in need of %n more members!"
}