TrialGroup
==========

A trials mode for Assault on UT2004. First released in 2010.

The New Tools
==

    GroupManager
        This actor must be placed once for your map to be function as a Group trials map. This actor also lets you choose the number of players a group has to consist of.
        
    GroupTriggerVolume
        A touch volume but restricted to one specific group. This actor's event will be instigated when all members of a group are inside this volume.
        
    GroupLinkedTriggerVolume
        Just like the GroupTriggerVolume but can instead be linked to another GroupLinkedTriggerVolume in order to split up the group.
        
    GroupTaskComplete
        Similar to Assault's TriggeredObjective, this actor lets you define an objective that can only be completed by instigating it with event from another actor such as a GroupTriggerVolume, ShoortTarget, or anything you can come up with!
        Tasks can used to reward players or prevent groups from skipping ahead of a room, because the task completion may be configured as required by the GroupObjective actor.
        
    GroupEventTrigger
        Similar to a traditional trigger but instigated by every member of a group. e.g. If you wish to give a weapon to every member of a group after one member triggers an event, then it is recommended that you use this trigger to instigate the weapon give event, this will then perform the event for each member of the group that instigated this trigger.
        
    GroupObjective
        This is an adapted version of Assault's ProximityObjective. When touched, it complete the map for each member of a group, it also requires that that group has completed all of the placed tasks that are marked not-optional. 

