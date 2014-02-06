//==============================================================================
//	GroupTaskCondition (C) 2010 Eliot Van Uytfanghe All Rights Reserved.
//==============================================================================
class GroupTaskCondition extends LCA_Condition;

var() string GroupTaskName;

function bool GetCondition( Actor Other )
{
	local GroupManager GM;
	local Mutator M;
	local int groupindex;
	local int i;

	if( Pawn(Other) == none )
		return false;

	for( M = Other.Level.Game.BaseMutator; M != none; M = M.NextMutator )
	{
		if( GroupManager(M) != none )
		{
			GM = GroupManager(M);
			break;
		}
	}

	if( GM != none )
	{
		groupindex = GM.GetGroupIndexByPlayer( Pawn(Other).Controller );
		if( groupindex != -1 )
		{
         	for( i = 0; i < GM.Groups[groupindex].CompletedTasks.Length; ++ i )
         	{
         		if( GM.Groups[groupindex].CompletedTasks[i].TaskName ~= GroupTask )
         		{
         			return true;
         		}
         	}
		}
	}
	return false;
}

function string GetDeniedMessage()
{
	return "You must have the group task" @ GroupTaskName @ "completed.";
}
