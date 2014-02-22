/*==============================================================================
   TrialGroup
   Copyright (C) 2010 - 2014 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupMultiVolumesManager extends Info
	placeable;

var() edfindable array<edfindable GroupMultiTriggerVolume> Links;

var() localized const string lzLinksNeed;
var() localized const string lzPlayersMissing;
var() localized const string lzPartition;

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
	local int i, missingmembers, filledlinks;
	local array<Controller> foundmembers;

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
            // v.Manager.GroupSendMessage( groupindex, "All links successfully exceeded!" );
			TriggerEvent( event, self, Other );
			for( i = 0; i < Links.Length; ++ i )
			{
				// We call TriggerEvent from Links[i] incase of overriden behavior.
				Links[i].TriggerEvent( Links[i].event, Links[i], Other );
			}
		}
		else
		{
            v.Manager.GroupSendMessage( groupindex, Repl( lzLinksNeed, "%MISSINGLINKS%", Links.Length - filledlinks ), v.Manager.GroupProgressMessageClass );
            TriggerEvent( v.EventWhenFilledButNotAll, v, Other );
		}
		return true;
	}
	else
	{
		// Let the group/member know what happened...
		for( i = 0; i < foundmembers.Length; ++ i )
		{
			v.Manager.SendPlayerMessage( foundmembers[i], Eval(
				missingmembers > 1,
				foundmembers.Length $ "/" $ v.GetRequiredMembersCount( v.Manager ) $ ", " $ missingmembers $ " more members required",
				foundmembers.Length $ "/" $ v.GetRequiredMembersCount( v.Manager ) $ ", one more member required"
			), v.Manager.GroupProgressMessageClass );
		}

		if( missingmembers == 0 )
		{
        	v.Manager.GroupSendMessage( groupindex, Repl(lzPartition, "%n", missingmembers), v.Manager.GroupProgressMessageClass );
		}
	}
	return false;
}

defaultproperties
{
	lzLinksNeed="%MISSINGLINKS% more links need to be filled!"
	lzPartition="Another partition is in need of %n more people!"
}