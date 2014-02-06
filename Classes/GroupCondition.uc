//==============================================================================
//	GroupCondition (C) 2014 Eliot Van Uytfanghe All Rights Reserved.
//  A condition with multi conditions that need to be true for every group's member.
//==============================================================================
class GroupCondition extends LCA_Condition;

/** List of conditions the Instigator's group's members will be tested against. */
var() editinlinenotify export array<LCA_Condition> Conditions;
var() bool bOnlyTestIfTriggeredByGroupFirstMember;

function bool TestConditions( out int i, Pawn Player )
{
	for( i = 0; i < Conditions.Length; ++ i )
	{
		if( Conditions[i] != none )
		{
			if( !Conditions[i].GetCondition( Player ) )
			{
				return false;
			}
		}
	}
	return true;
}

function bool GetCondition( Actor other )
{
	local GroupManager GM;
	local Mutator M;
	local int i, condIndex;
	local int groupIndex;

	if( Pawn(other) == none )
		return false;

	for( M = other.Level.Game.BaseMutator; M != none; M = M.NextMutator )
	{
		if( GroupManager(M) != none )
		{
			GM = GroupManager(M);
			break;
		}
	}

	if( GM == none )
	{
		return false;
	}

	groupIndex = GM.GetGroupIndexByPlayer( Pawn(other).Controller );
	if( groupIndex == -1 )
	{
		return false;
	}

	if( bOnlyTestIfTriggeredByGroupFirstMember && Pawn(other) != GM.Groups[groupIndex].Members[0].Pawn )
	{	
		return false;
	}

 	for( i = 0; i < GM.Groups[groupIndex].Members.Length; ++ i )
 	{
 		if( GM.Groups[groupIndex].Members[i] == none || GM.Groups[groupIndex].Members[i].Pawn == none )
 		{
 			return false;
 		}

 		if( !TestConditions( condIndex, GM.Groups[groupIndex].Members[i].Pawn ) )
 		{
 			return false;
 		}
 	}
	return true;
}

function string GetDeniedMessage()
{
	return "Your group didn't meet the required conditions.";
}
