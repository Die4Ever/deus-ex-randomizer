
## Major Changes

- Fixed Area 51 Sectors 2 and 3 goals rando locations not working
- The Ballistic Protection aug now uses slightly less energy (when Augs Balance Changes are enabled), and has a shorter auto linger time (when Semi-Automatic Augs are enabled)
- On WaltonWare Gas Station, Ocean Lab, and Silo starts you can backtrack to Carla in Vandenberg (at the vanilla start, on the roof of the Command Center) to get the Vandenberg map

## Revision

<details>
<summary>Click to expand Revision Changes</summary>

- Added support for autorun in Revision.  At the moment, it is not configurable through the in-game keybinds and must be manually configured.
  - In the RevisionUser.ini file, go to the \[Extension.InputExt\] section and find the key you want to bind to enable autorun.  Change it so that it maps to ToggleAutorun, eg. to make C enable autorun: `C=ToggleAutorun`
- Doors into the LaGuardia hangar (on both sides) are no longer potentially destroyable
- The keypad on the helipad-side door to the LaGuardia hangar can no longer be hacked

</details>

## Minor Changes

<details>
<summary>Click to expand Minor Changes</summary>

- Zombie Merchants are no longer ignored by the AI
- Hazmat suits can no longer be marked as Trash while being used in Zero Rando (or when balance changes are disabled)
- Added book color and open/closed information to bingo goals help texts
- Fixed a quick aug menu exploit to get infinite upgrades while paused
- Swapped NPCs get their `DesiredRotation` set when swapped, along with their regular `Rotation`.  This fixes enemies sometimes facing the wrong direction, like the Terrorists in the Mission 2 Hotel, or the guards near the elevator in the LaGuardia Helibase
- Semicolons are no longer allowed in save names in vanilla
  - If you had a save file with a semicolon in the name, it should now be possible to load the save properly
- DXVK updated to v2.7.1
- The installer is now smarter about installing extra dependencies
- The installers for Vanilla Fixer and Zero Rando have been simplified.  They now also provide the option to enable balance changes (Zero Rando Plus)
- Fixed an issue with loading saves that have high max health or energy
- The Max Rando warning is always shown, instead of being based on the number of times you've beaten the game (which only showed you the explanation if you clicked it on your first playthrough)
- Fixed an issue where auto augs could still be effective when your energy was a rounding error away from 0

</details>
