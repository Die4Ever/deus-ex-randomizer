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
  - It is no longer possible to softlock yourself out of the Tong ending if you move across the Reactor lab control room too fast after activating the reactors. (Fixes a baseline GMDX bug)

  </details>


## Minor Changes

<details>
<summary>Click to expand Minor Changes</summary>

  - New option to show speedrun splits overlay without saving, similar to Speedrun Shuffle mode.
  - If a new bingo board is generated after Mission 4, the "Take down Sandra Renton" bingo goal will fail immediately depending on if she left New York or not.
  - "Make Soup" bingo goal properly detects bodies that spawn already inside the hot tub (For example, if zombies resurrect in the water and then are killed again).
  - If a third person conversation is interrupted, it will attempt to play through as much of the remainder of the conversation as possible.  This helps avoid some situations where a conversation that would normally end with the speaker becoming hostile might be left in a friendly state if the conversation is interrupted.
  - UNATCO HQ armory door is permanently locked and unbreakable until Mission 5.
  - New option added to show or hide the bingo board.  Zero Rando and Zero Rando Plus will hide the board by default to avoid spoilers.
  - Death Markers won't highlight if you have something in your hands.
  - Prison manifest with the list of equipment taken away from you (Mission 5) will now properly appear on mirrored maps.
  - Bots and The Merchant will no longer be able to spawn in the following locations:
    - On the far side of the walls/gates in Denfert-Rochereau (Paris, Mission 10).
    - In the small room with a desk before the construction area in the Ocean Lab (Mission 14).
  - Certain weapon mods applied to weapons will no longer be lost when loading save games or traveling to new levels.
  - Randomly spawned medbots and repair bots should no longer spawn in (or over) the water.
  - The dancing guy in the Underworld Bar (Mission 2/4/8) will no longer appear in Zero Rando.
  - Some passwords that would not be learned properly when password randomization was disabled (eg. Zero Rando) will now be learned.
  - Some passwords will get replaced in their original text in a more clean fashion (just replacing the password instead of a whole phrase).
  - Trash paper that spawns from destroyed barrels and trash cans won't be on fire if spawned in water.  This prevents a crash when destroying burning barrels that are floating in water.
  - GMDX/VMD: Enemies who get helmets randomly added or removed will properly take damage as though they do or do not have helmets.

</details>

## GMDX Minor Changes

<details>
<summary>Click to expand GMDX Minor Changes</summary>

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
  - Locations of UNATCO Troops when returning to New York (Mission 8) will not be adjusted in Zero Rando.
  - Acceleration will no longer be maintained when activating Spy Drone (Which caused you to slowly move while controlling the drone).
  - Movement speed reductions will now be based on your selected maximum health instead of fixed health values assuming a maximum health of 100.

</details>

## VMD Minor Changes

<details>
<summary>Click to expand VMD Minor Changes</summary>

  - Some items that were placed decoratively (like weapons) in Revision maps will now be able to be picked up.
  - In Revision maps, Jock's name won't be randomized.
  - Certain randomized goals (Such as the generator in Mission 2) will no longer be moved out of the world.
  - Jock will appear as expected after speaking to Stanton Dowd in Mission 8 when playing on Revision maps.
  - The subway keypad in Mission 4 on Revision maps will be able to be interacted with after the raid.
  - Many small tweaks for Revision maps will properly be applied, instead of applying some Vanilla map tweaks to the Revision maps.
  - Exit teleporter at the end of the Vandenberg Tunnels (Mission 12) will be placed in the correct location on Revision maps.
  - Phones in Revision maps will work for making phone calls for bingo.
  - Many elevator buttons in Revision maps will no longer be missing.

</details>


## Intra-Patch Changes

- Intros and Outros won't get stuck if you try to skip them.
