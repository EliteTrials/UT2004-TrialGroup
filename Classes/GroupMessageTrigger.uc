/*==============================================================================
   TrialGroup
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupMessageTrigger extends GroupTrigger
	placeable;

var() private const string GroupMessage;

function Trigger( Actor other, Pawn instigator )
{
	local int groupindex;

	if( instigator == none || instigator.Controller == none )
	{
		return;
	}

	groupindex = Manager.GetGroupIndexByPlayer( instigator.Controller );
	if( groupindex != -1 )
	{
		Manager.GroupSendMessage( groupindex, Repl( GroupMessage, "%GROUPNAME%", "\"" $ Manager.Groups[groupindex].GroupName $ "\"" ) );
	}
	// else no group
}

defaultproperties
{
	GroupMessage="Goodluck to you %GROUPNAME%"
}
