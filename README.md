# TrialGroup for Unreal Tournament 2004

A set of useful and necessary tools for level designers to make GTR (Group Trials) maps. Released circa 2010.

[![GitHub all releases](https://img.shields.io/github/downloads/EliteTrials/UT2004-TrialGroup/total)](https://github.com/EliteTrials/UT2004-TrialGroup/releases)

## Usage for Players

### Console Commands

- JoinGroup \<GroupName\> ```Join or create a specific group by name!```
- LeaveGroup
- GroupCountDown [Seconds]
- GroupGO ```Initiates a shortened countdown to GO!```
- GroupFast
- GroupSlow
- ShowGroupMembers
- Waize ```Summons a marker to where you are pointing```

Tip! Bind a shortcut for **GroupGO** using ```set input Q GroupGO```.

### Key Bindings

- [F] ```Initiates Waize```

## Usage for Level Designers

### Tools

    GroupManager (Info->Mutator)
        This actor is needed for your map to function as a Group trials map. This actor also lets you choose the number of players a group must consist of.
        
    GroupTriggerVolume
        A touch volume, but restricted to a group. Its event will be instigated when all members of the group are inside the volume.
        
    GroupMultiTriggerVolume
        Just like the GroupTriggerVolume, but can instead be linked to another GroupMultiTriggerVolume in order to split up the group. A GroupMultiVolumesManager (Actor->Info) is required to link your volumes.
        
    GroupTaskComplete (Triggers->GroupTrigger)
        Similar to Assault's TriggeredObjective, this actor lets you define an objective that can only be completed by instigating it with an event from another actor such as a GroupTriggerVolume, ShoortTarget, or anything else you can come up with!
        Tasks may be used to reward players, or prevent groups from skipping ahead of a room.
        The task can be configured as required.
        
    GroupEventTrigger (Triggers->GroupTrigger)
        Similar to a traditional trigger but is instead performed for each member of the group. e.g. If you wish to give a weapon to every member of a group, after one member triggers an event, then it is recommended that you use this trigger to instigate the weapon give event, this will then perform the event for each member of the group that instigated this trigger.
        
    GroupObjective (NavigationPoint->...->GameObjective)
        This is an adapted version of Assault's ProximityObjective. When touched, it will complete the map for each member of the group. It also requires that the group has completed all of the placed tasks that are marked not-optional. 
        
    GroupTeleporter (NavigationPoint->...->Teleporter)
        Unlike the standard Teleporter, a group teleporter will just teleport all the group members along with it.

## Quirks

If you wish for your map to have solo records, you must make sure that you have placed only one GroupObjective in your map. Your map should also be prefixed with "GTR-MapName" or the older accepted form "AS-Group-MapName"

## Gameplay sample

Some examples of the **trigger** tools being used in various **GTR** maps:

- GTR-EpicFailures (A crazy 10-people group trials map)
> [![Watch the video](https://img.youtube.com/vi/cVDr_BNKmC4/hqdefault.jpg)](https://youtu.be/cVDr_BNKmC4)

- GTR-GeometryBasics
> [![Watch the video](https://img.youtube.com/vi/yfIcML7SpyU/hqdefault.jpg)](https://youtu.be/yfIcML7SpyU)

## Maps of Fame

**In no particular order**

- GTR-EgyptianRush-Classic (GTR-EgyptianRush)
- GTR-EgyptianRush-Prelude
- GTR-GeometricAbsolution (GTR-GeometryBasics-Pt2)
- GTR-GeometryBasics
- GTR-GSGShooterTech
- GTR-Hostility
- GTR-Hostility2
- GTR-IceWastes
- GTR-MothershipKran
- GTR-TheEldoraPassages
- GTR-TheBastionOfChizra
- GTR-ForgottenTemple
- GTR-EpicFailures
- GTR-MastersOfDodge

- GTR-FractalMap (Billa, Unreleased 2015)
- GTR-Yoke (EliotVU, Unreleased 2015)
- GTR-Dungeon (Billa, Unreleased 2016)


## Credits

- **Haydon 'Billa' Jamieson** for taking the initiaitve to develop a group trials mode, and for designing a majority of the maps.
