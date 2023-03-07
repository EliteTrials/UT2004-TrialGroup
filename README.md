# TrialGroup for Unreal Tournament 2004

A set of useful and necessary tools for level designers to make GTR (Group Trials) maps. Released circa 2010.

[![GitHub all releases](https://img.shields.io/github/downloads/EliteTrials/UT2004-TrialGroup/total)](https://github.com/EliteTrials/UT2004-TrialGroup/releases)

## Usage for Players

### Console Commands

- JoinGroup \<GroupName\> `Join or create a specific group by name!`
- LeaveGroup
- GroupCountDown [Seconds]
- GroupGO `Initiates a shortened countdown to GO!`
- GroupFast
- GroupSlow
- ShowGroupMembers
- Waize `Summons a marker to where you are pointing`

Tip! Bind a shortcut for **GroupGO** using `set input Q GroupGO`.

### Key Bindings

- [F] `Initiates Waize`

## Usage for Level Designers

If you wish for your map to have solo records, you must make sure that you have placed only one GroupObjective in your map. Your map should also be prefixed with "GTR-MapName" or the older accepted form "AS-Group-MapName"

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

## Maps of Fame

**In no particular order**

- GTR-EgyptianRush-Classic (Formerly GTR-EgyptianRush)
  > Rush your way through this Egyptian temple with a Team Mate and escape! Map created 25/4/2010 Classic version includes DMSG noob filter.
  >
  >  ![Shot00005](https://user-images.githubusercontent.com/808593/223332791-d20065e6-c9e4-416a-aa2b-12223b7eb17b.png)
  
- GTR-EgyptianRush-Prelude
  > You've stumbled across a cave and decided to explore it with your fellow group members can you complete the Egyptian Rush?
  >
  > ![Shot00006](https://user-images.githubusercontent.com/808593/223332845-5fd41af9-96e2-484b-b70c-05e2ec2cab70.png)

- GTR-GeometricAbsolution (Formerly GTR-GeometryBasics-Pt2)
  > Welcome to Absolution, the uniform sister facility of Geometric-Basic, your only task is A-to-B. Good luck!
 
- GTR-GeometryBasics
  > A simple group map taking you back to the bare basics of group trials, for those who are new to the game mode.
  
- GTR-GSGShooterTech
  > This test facility was build for the purpose of pitting two people against eachother with the big twist of teamwork, the idea is to race the end of this blood stained puzzle of a test facility for the prize of escaping alive but it isn't that straight forward, some rooms require perfect synchronicity and others pure teamwork. Can you beat the monster that is GSG.
   
- GTR-Hostility
  > ![Shot00009](https://user-images.githubusercontent.com/808593/223341160-e9145a62-63c2-4931-90f4-4309507e6d29.png)


- GTR-Hostility2
  > Welcome back to the friendship running, frustration building team exorcise that is the Hostility Test Facility
  > 
  > ![Shot00012](https://user-images.githubusercontent.com/808593/223341206-ab6b4bc2-bf78-4b61-9c10-b2f547cdba0a.png)

- GTR-IceWastes

- GTR-MothershipKran
  > Welcome to the Skaarj Mothership Kran, sister ship to the galactic brood carrier, the ship is war-torn and old, much of which is still damaged from previous encounters with space marines which has dwindled the number of skaarj aboard. As you awake to the sound of your door being beaten, there is a revolution, the young green rankless skaarj are defecting and now is your best chance to get out and find a way to take controll of the ship, passages have been unlocked and doors busted open, explore the dark halls of the Mothership Kran, but beware, the guards are alert and looking for you!

- GTR-TheEldoraPassages
  > Welcome to the Eldora Passages, you have made your way here through The Eldora Well, located deep under the Glathriel Village, your task is to find out what is at the end of these passages and locate the Nali locals have gone missing exploring these passages.
  >
  > ![Shot00008](https://user-images.githubusercontent.com/808593/223337333-0a5001ba-e3ac-4f14-bf74-53b348549c10.png) ![Shot00007](https://user-images.githubusercontent.com/808593/223337344-edd8c9f1-c41a-4fdb-b445-7ae1ed4ed29d.png)

- GTR-TheBastionOfChizra

- GTR-ForgottenTemple

- GTR-EpicFailures

- GTR-MastersOfDodge

- GTR-FractalMap (Billa, Unreleased 2015)

- GTR-Yoke (EliotVU, Unreleased 2015)
  > A 2-player map, each player must choose their favorite weapon(s), each weapon can only be picked up by one player.
  >
  > Will you go for the **Momentum Reflector Gun** or the **Assault Rifle**? More weapons can be acquired in later stages.
  >
  > ![Shot00003](https://user-images.githubusercontent.com/808593/223329499-862d94a9-2e9d-4442-9526-0697d5dd7041.png)
  
- GTR-Dungeon (Billa, Unreleased 2016)

## Gameplay sample

Some examples of the **trigger** tools being used in various **GTR** maps:

- GTR-EpicFailures (A crazy 10-people group trials map)
  > [![Watch the video](https://img.youtube.com/vi/cVDr_BNKmC4/hqdefault.jpg)](https://youtu.be/cVDr_BNKmC4)

- GTR-GeometryBasics
  > [![Watch the video](https://img.youtube.com/vi/yfIcML7SpyU/hqdefault.jpg)](https://youtu.be/yfIcML7SpyU)

## Credits

- **Haydon ' Billa ' Jamieson** for taking the initiaitve to develop a group trials mode, and for designing a majority of the maps.
