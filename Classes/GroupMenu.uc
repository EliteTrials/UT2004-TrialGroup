/*==============================================================================
   TrialGroup
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class GroupMenu extends MidGamePanel;

var automated GUIButton b_Join, b_Leave, b_CountDown;
var automated GUIEditBox eb_Join;
var automated GUIScrollTextBox eb_Desc;
var automated GUINumericEdit ne_Count;

function InitComponent( GUIController InController, GUIComponent InOwner )
{
	super.InitComponent(InController,InOwner);
	eb_Desc.MyScrollText.NewText = "Group is a new mode made by Eliot Van Uytfanghe(Idea by Haydon ' Billa ' Jamieson) for trials where you have to complete together tasks with a group to complete the level, here in this menu you can join a group, leave your group and start a group counter." $
	"||<List of group commands>|" $
	"    JoinGroup|" $
	"    LeaveGroup|" $
	"    GroupCountDown|" $
	"    GroupGO - Macro for a instant GO!|" $
	"    GroupFast - Macro for a fast counter|" $
	"    GroupSlow - Macro for a slow counter|" $
	"||<Map group rules>|" $
	"    1. The map may not be completable under 1:30 min i.e. because this isn't solo but group(that inherits the solo mode) the map may not be made for speedrunning|" $
	"    2. The map may only have a maximum of 5 tasks per 1 minute of map|" $
	"    3. The map must have atleast 7 tasks|" $
	"    4. The map must meet decent quality i.e. not some kind of wannabe nor may look like a sparkette/xen skyrider map|" $
	"    5. The map may not have any secrets that give advantages|" $
	"    6. The map must force players to be on the attackers team|" $
	"    7. Optional tasks bonus points may not be too high if the task is easy|" $
	"|ÿIf your map does not meet one rule of the above list, then your map will be(and should be) refused on our serverÿÿÿ" $
	"||Downloads, Tutorials and information about the Group mode can be found on http://elitetrial.clanservers.com/"
	;
	eb_Desc.MyScrollBar.AlignThumb();
	eb_Desc.MyScrollBar.UpdateGripPosition( 0 );
}

// Not Yet Implemented
/*function InitPanel()
{
	Super.InitPanel();
}*/

function bool OnClick( GUIComponent Sender )
{
	if( Sender == b_Join )
	{
		PlayerOwner().ConsoleCommand( "JoinGroup" @ eb_Join.TextStr );
		return True;
	}
	else if( Sender == b_Leave )
	{
		PlayerOwner().ConsoleCommand( "LeaveGroup" );
		return True;
	}
	else if( Sender == b_CountDown )
	{
		PlayerOwner().ConsoleCommand( "GroupCountDown" @ ne_Count.Value );
		return True;
	}
	return False;
}

defaultproperties
{
	Begin Object Class=GUIScrollTextBox Name=Desc
		WinWidth	=	0.98
		WinHeight	=	0.825
		WinLeft		=	0.01
		WinTop		=	0.01
		bBoundToParent=False
		bScaleToParent=False
		StyleName="NoBackground"
        bNoTeletype=true
        bNeverFocus=true
	End Object
	eb_Desc=Desc

	Begin Object Class=GUIButton Name=CountDown
		Hint="Start a group counter with the specified value"
		Caption="Start group counter"
		WinWidth	=	0.25
		WinHeight	=	0.040000
		WinLeft		=	0.010000
		WinTop		=	0.850000
		OnClick=OnClick
		bBoundToParent=False
		bScaleToParent=False
	End Object
	b_CountDown=CountDown

	Begin Object Class=GUINumericEdit Name=CountValue
		Hint="The amount of seconds the group counter takes to finish"
		WinWidth	=	0.07
		WinHeight	=	0.040000
		WinLeft		=	0.265000
		WinTop		=	0.850000
		MinValue=1
		MaxValue=3
		Value="3"
		bBoundToParent=False
		bScaleToParent=False
	End Object
	ne_Count=CountValue

	Begin Object Class=GUIButton Name=Join
		Hint="Join the specified group"
		Caption="Join Group"
		WinWidth	=	0.162500
		WinHeight	=	0.040000
		WinLeft		=	0.010000
		WinTop		=	0.910000
		OnClick=OnClick
		bBoundToParent=False
		bScaleToParent=False
	End Object
	b_Join=Join

	Begin Object Class=GUIEditBox Name=Group
		Hint="The name of a group to join"
		WinWidth	=	0.23
		WinHeight	=	0.040000
		WinLeft		=	0.18
		WinTop		=	0.910000
		bBoundToParent=False
		bScaleToParent=False
	End Object
	eb_Join=Group

	Begin Object Class=GUIButton Name=Leave
		Hint="Leave your current group"
		Caption="Leave Group"
		WinWidth	=	0.182500
		WinHeight	=	0.040000
		WinLeft		=	0.42
		WinTop		=	0.910000
		OnClick=OnClick
		bBoundToParent=False
		bScaleToParent=False
	End Object
	b_Leave=Leave
}
