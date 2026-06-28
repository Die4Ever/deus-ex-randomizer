## Major Changes


## GMDX Major Changes
  - When loading an old save, you may experience some oddities until you progress to a new map.  We would recommend progressing until the end of a mission before updating, or start a new game.

<details>
<summary>Click to expand GMDX Major Changes</summary>

  - Fixed Camera option now available.
  - Third Person camera option now shows over the shoulder instead of looking at JC's butt.
  - Assistive aiming laser now available for non-first-person camera modes.
  - Larger heals are now more balanced across the body, instead of focusing on one limb at a time.
  - Automatic Weapon Mod Apply now available.  Right click a weapon mod while holding a weapon that can have that mod applied to it to instantly apply that mod to the weapon.

  </details>


## Minor Changes

<details>
<summary>Click to expand Minor Changes</summary>

  - If a new bingo board is generated after Mission 4, the "Take down Sandra Renton" bingo goal will fail immediately depending on if she left New York or not.
  - "Make Soup" bingo goal properly detects bodies that spawn already inside the hot tub (For example, if zombies resurrect in the water and then are killed again).
  - If a third person conversation is interrupted, it will attempt to play through as much of the remainder of the conversation as possible.  This helps avoid some situations where a conversation that would normally end with the speaker becoming hostile might be left in a friendly state if the conversation is interrupted.
  - UNATCO HQ armory door is permanently locked and unbreakable until Mission 5.
  - New option added to show or hide the bingo board.  Zero Rando and Zero Rando Plus will hide the board by default to avoid spoilers.
  - Death Markers won't highlight if you have something in your hands.
  - Prison manifest with the list of equipment taken away from you (Mission 5) will now properly appear on mirrored maps.
  - GMDX/VMD: Enemies who get helmets randomly added or removed will properly take damage as though they do or do not have helmets.

</details>

## GMDX Minor Changes

<details>
<summary>Click to expand Minor Changes</summary>

  - Using a scope on the GEP Gun will no longer allow you to see through walls.
  - GEP Gun scope issues will now be fixed for WP rockets, and regular rockets are fixed when playing with Item Balance disabled (such as in Zero Rando).
  - Items won't randomize onto the apartment balconies at NSF HQ (Mission 4).
  - Keypad to access Tim's closet in Vandenberg Command (Mission 12) now works again alongside the escape button inside.
  - Bingo goals will be updated appropriately when consuming foods with left click (straight from the world).
  - Scramble grenades will now toggle your augs randomly.
  - Scope Blackout and Scope Scale options are now available.
  - "Death Cam" options are now available for GMDX.
  - Crowd Control "Wine-Glazed Bullets" effect now available
  - Crowd Control camera effects now available (Resident Evil mode, Barrel Roll, Sideways, Upside Down, Doom Mode)
  - Crowd Control damage effects now available (Double Damage, Half Damage)
  - Fire damage now ticks less frequently to make it slightly more survivable.
  - Additional colour schemes for HUD and Menus.
  - It is no longer possible to interact with certain objects through walls (such as switches).
  - Weapons are now correctly marked as "Modified" if they have Rate of Fire, Damage, or Full Auto mods applied.
  - Added ShowBingoWindow exec function to GMDXRandoPlayer so it can be manually bound to a hotkey.
    - In the User.ini file, go to the \[Engine.Input\] section and find the key you want to bind to open the bingo screen.  Change it so that it maps to ShowBingoWindow, eg. to make B open the window: `B=ShowBingoWindow`
  - The password will no longer be unintentionally learned for the security computer in Smuggler's lair (Missions 2, 4, and 8).
  - Anna Navarre will no longer slowly walk towards you in Battery Park (Mission 2) when goal randomization is enabled.

</details>
