## Major Changes

- TBD

## Minor Changes

<details>
<summary>Click to expand Minor Changes</summary>

- Improvements to Fixed Camera mode:
  - The camera location will now persist through saves and loads.
  - The camera will now focus on the person speaking during conversations.
  - The camera will now respect the reduced FOV from drinking alcohol and adjust the view accordingly to keep the target on screen.
  - The camera will now roll back and forth while drunk.
  - The camera will now shake when it normally would in first person (e.g. while the superfreighter is exploding in Mission 9).
  - The camera can now flip upside down, sideways, or roll from Crowd Control effects.  These effects are blocked while forced into fixed cameras from Crowd Control itself, but are functional if intentionally playing in Fixed Camera mode.
  - The camera will now be blocked by unmovable decorations (like vans and helicopters) as though they were walls, causing the camera to quickly adjust to allow the player to see themself.
  - The camera *can* be blocked by movable decorations (like crates), but the camera will only adjust if the player stops moving behind them.  This helps avoid unnecessary camera changes when the player is navigating through a busy room.
  - "Doom Mode" Crowd Control effect now works properly in combination with Fixed Cameras.  The player is unable to aim up or down, but the fixed camera itself is still able to tilt.
- Aim laser no longer shows up during conversations or cutscenes in Revision.
- Fixed infinite conversation loop in Mission 5 MJ12 Lab when you buy everything from Sven the mechanic.
- Fixed a bug where characters would patrol to a point and then start wandering, instead of standing still.  In particular, this fixes an issue if you aren't standing near the jail cell window in Mission 5 when Anna shows up (if she's still alive), as previously she would wander away.
- Add a button to open the door to the UNATCO HQ front door desk from the inside in Mission 1.  All other versions of UNATCO HQ (Missions 3, 4, 5) already have a button to open the door from the inside.
- Aug/Med/Repair Bots and Merchants will no longer spawn in certain dangerous locations:
  - Near the arcing electricity in the Airfield (Mission 3)
  - In the electrical room on the superfreighter (Mission 9)
  - Near the broken electrical box in the Paris Catacombs (Mission 10).
  - In the electrified room in the Vandenberg Command Center (Mission 12).
  - Outside the door of Vandenberg Command Center in the inaccessible duplicate of the main hall (Mission 12).
- The teleporter to leave the Vandenberg Command Center is now slightly larger to hopefully make it less possible to sneak past.
- Jock now flies faster during the exit cutscenes from the graveyard in Mission 9 and from the gas station in Mission 12.
- Bingo goal for learning Maggie's birthday is now properly marked when reading the relevant datacube.
- Fixed an issue where going two layers deep into the menus (E.g. Settings > Controls) would set your default FOV to whatever the current FOV was at the time you entered the menu.  This caused issues if you went into the menus while drunk or using a scope.  This would sometimes cause your game to be slightly zoomed in, or your weapon to not appear until you switch to another one.
- When New Game Plus removes a weapon, the chosen weapon is no longer dependent on the order in which you picked up the weapons.
</details>
