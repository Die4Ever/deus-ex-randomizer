
## Major Changes

- Fixed Area 51 Sectors 2 and 3 goals rando locations not working.
- Ballistic Protection aug now uses slightly less energy (when Augs Balance Changes are enabled), and has a shorter auto linger time (when Semi-Automatic Augs are enabled).
- On WaltonWare M12/M14 starts past Vandenberg Command, you can backtrack to Carla to get the map.

## Revision

<details>
<summary>Click to expand Revision Changes</summary>

- Added support for autorun in Revision.  At the moment, it is not configurable through the in-game keybinds and must be manually configured.
  - In the RevisionUser.ini file, go to the \[Extension.InputExt\] section and find the key you want to bind to enable autorun.  Change it so that it maps to ToggleAutorun, eg. to make C enable autorun: `C=ToggleAutorun`
- Doors into the M03 hangar (on both sides) are no longer potentially destroyable
- Keypad on the helipad-side door to the M03 hangar can no longer be hacked

</details>

## Minor Changes

<details>
<summary>Click to expand Minor Changes</summary>

- Zombie merchants are no longer ignored by the AI
- Hazmat suits can no longer be marked as Trash while being used in Zero Rando (or when balance changes are disabled)
- Added book colours and open/closed information to bingo goals help texts.
- Fixed quick aug menu exploit with infinite upgrades while paused.
- Swapped NPCs get their DesiredRotation set when swapped, along with their regular Rotation.  This fixes some enemies who would sometimes be facing the wrong direction, like the terrorists in the M02 Hotel, or the guards near the elevator in the M03 Airfield Helibase.
- Semicolons are no longer allowed in save names in vanilla (The original logic to do this was incorrect)

</details>
