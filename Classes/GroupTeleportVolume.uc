//==============================================================================
//	GroupTeleportVolume (C) 2010 Eliot Van Uytfanghe All Rights Reserved.
//==============================================================================
class GroupTeleportVolume extends LCA_TeleportVolume;

var() localized string lzTeleportMessage;

simulated event PostTouch( Actor Other )
{
	local Teleporter TP;
	local array<Teleporter> TPList;
	local int i, groupindex, l;
	local array<Controller> newbs;
	local GroupManager GM;

	super(LCA_Volumes).PostTouch( Other );
	if( Pawn(Other) != none )
	{
		GM = GetGM();
		if( GM == none )
			return;

		groupindex = GM.GetGroupIndexByPlayer( Pawn(Other).Controller );
		if( groupindex == -1 )
			return;

		foreach AllActors( class'Teleporter', TP, Destination )
		{
			TPList[TPList.Length] = TP;
		}

		if( TPList.Length == 0 )
		{
			return;
		}

     	i = Rand( TPList.Length );

    	GM.GetMembersByGroupIndex( groupindex, newbs );
		for( l = 0; l < newbs.Length; ++ l )
		{
			if( newbs[l].Pawn != none )
			{
	     		newbs[l].Pawn.PlayTeleportEffect( false, true );
		     	TPList[i].Accept( newbs[l].Pawn, self );

	     		TriggerEvent( Event, self, newbs[l].Pawn );
	     		// Ensure the player can jump twice.
	     		if( newbs[l].Pawn.Physics == PHYS_Walking )
	 			{
	     			newbs[l].Pawn.Landed( vect( 0, 0, 0 ) );
				}
			}
		}

		// lzTeleportMessage = "%o triggered a group teleport"
		GM.GroupSendMessage( groupindex, Repl(lzTeleportMessage, "%o", Pawn(Other).Controller.GetHumanReadableName()) );
	}
}

simulated function GroupManager GetGM()
{
	local Mutator M;
	for( M = Level.Game.BaseMutator; M != none; M = M.NextMutator )
	{
		if( GroupManager(M) != none )
		{
			return GroupManager(M);
		}
	}
	return none;
}

defaultproperties
{
	lzTeleportMessage="%o triggered a group teleport"
}