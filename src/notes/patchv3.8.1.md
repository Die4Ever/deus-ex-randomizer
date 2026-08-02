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
  - Hardcore mode will no longer be enabled based purely on the selected difficulty.  Instead, there is an option under the Advanced settings of the New Game screen.  This setting allows you to select between Off, Overwhelming Odds, Hardcore, and Hardcore+.  These settings will get initialized on a new game based on the settings you have selected in the GMDX Options menu.
  - A new option under the Advanced settings of the New Game screen to enable or disable the stamina system.  Zero Rando will default to using the same system to determine if stamina should be enabled or not (Either if the "Stamina System" option in the GMDX settings is enabled, or if you're playing Hardcore).  Outside of Zero Rando, the stamina system will be disabled by default.

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
  - Alarm sounder panels will become confused when hit by EMP damage, even when not actively sounding an alarm.  While confused, the panel will not be able to be used by enemies.
  - Very minor tweaks to weapon positioning based on selected FOV.
  - Removed an invisible door in the corner of the bilge pump room (Mission 9) that could be highlighted and did nothing.
  - "Kill Cam" will no longer show your first person perspective arm over your body when you die.
  - Flares can no longer be activated again with left click while already lit on the ground.
  - "Key Assistance" option will now show what key was used to lock or unlock a door.
  - Randomized grenades will keep their original detection radius.
  - The installer will now enable mirror reflections for the Direct3D 9 renderer, and disable OneXBlending for the OpenGL renderer to improve brightness.
  - "Go into Alex's closet" bingo goal will no longer be marked as complete when you use the keypad and will instead still need you to actually enter the closet.
  - It is no longer possible to infinitely stockpile "how long you've been standing" for weapon accuracy bonuses.  You can now accumulate up to 20 seconds of standing time before it is capped.  Standing time will also no longer increase while reloading.
  - GMDX/VMD: Enemies who get helmets randomly added or removed will properly take damage as though they do or do not have helmets.
  - Revision: Reloading a small scoped weapon just before starting a conversation will no longer cause the scope to appear again mid-conversation.
  - Vanilla/Revision/GMDX: Conversations can now start while using the scope on a weapon.
  - Dance party ending for bingo wins now works properly and continues on to New Game Plus for non-vanilla mods.
  - Revision: It is now possible to skip the quote shown after an ending when using Revision maps, to go into the credits immediately.
  - Revision: Some items in inaccessible parts of the New York streets (Mission 2, 4, and 8) will no longer be randomized (to prevent important items from being shuffled out of the play area).
  - Revision: Charged pickups (Ballistic armor, hazmat suits, thermoptic camo, and tech goggles) can no longer be instantly used by left clicking on them.

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
    - In the GMDXUser.ini file, go to the \[Engine.Input\] section and find the key you want to bind to open the bingo screen.  Change it so that it maps to ShowBingoWindow, eg. to make B open the window: `B=ShowBingoWindow`
  - Added ToggleAutorun exec function to GMDXRandoPlayer so it can be manually bound to a hotkey.
    - In the GMDXUser.ini file, go to the \[Engine.Input\] section and find the key you want to bind to begin autorunning.  Change it so that it maps to ToggleAutorun, eg. to make V begin autorunning: `V=ToggleAutorun`
  - The password will no longer be unintentionally learned for the security computer in Smuggler's lair (Missions 2, 4, and 8).
  - Anna Navarre will no longer slowly walk towards you in Battery Park (Mission 2) when goal randomization is enabled.
  - Locations of UNATCO Troops when returning to New York (Mission 8) will not be adjusted in Zero Rando.
  - Acceleration will no longer be maintained when activating Spy Drone (Which caused you to slowly move while controlling the drone).
  - Movement speed reductions will now be based on your selected maximum health instead of fixed health values assuming a maximum health of 100.
  - Slamming into a wall at high speed will no longer damage the player.
  - The key to Lebedev's private quarters will no longer randomize into the locked bedroom at the front of the 747 (Mission 3).
  - Paul will now actually stay dead if he dies in the raid, but you finish it and leave the hotel.

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
  - Bingo goals for using vending machines will now work as expected.
  - When using Revision maps, the ending cutscenes will show a randomized quote at the end instead of the original quotes.  The dance party ending will now show a quote after a moment and eventually continue to the credits.

</details>


## Intra-Patch Changes

- Intros and Outros won't get stuck if you try to skip them.
- GMDX: Mantling actually works again.
- GMDX: Left clicking on charged pickups (Ballistic armor, hazmat suits, thermoptic camo, and tech goggles) will use the original GMDX behaviour instead of instantly wearing the armor.
- GMDX: Repairbots will actually limit the number of times they can be used (instead of decrementing the number of uses into negative numbers).
- GMDX: Red screen overlay doesn't appear when you die with the "Show Killer" death cam option enabled.
