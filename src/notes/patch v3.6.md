# New Game Modes

- Serious Rando and Memes changes:
  - added new "Serious Rando" game mode, same as Full Rando but with some goal locations disabled, and memes disabled by default
  - Animals don't sit in chairs when memes disabled
  - Certain goal locations and behaviors will no longer be used in serious mode:
    - Liberty Island (M01) - Leo won't appear on the South Dock or in Jail
    - Warehouse (M02) - Jock won't appear in the sewers
    - Hong Kong (M06) - Max Chen won't appear in the bathroom
    - Return to NYC (M08) - Jock won't appear in the alley or near the back entrance to Smuggler
    - Dockyard (M09) - Jock won't appear in the warehouse or in the sewer
    - Paris (M10) - Nicolette will no longer be dancing, and she won't use a smoke bomb after being talked to in the streets
    - Silo (M14) - Jock will no longer appear at the bottom of the silo or in the command room
- New experimental gamemode Groundhog Day
  - In Groundhog Day mode, your seed and settings will not be changed when completing the game and going to New Game+.  Refine your run with each loop as you learn goal and item locations!

# Major Changes

- Area 51 (M15) Sector 3/4 starts delete enemies on the elevator at the end of Sector 2 for backtracking
- Options for auto enabling auto augs when installed (all auto augs, protection augs, damage resistance augs)
  - Damage Resistance augs are Ballistic Protection, EMP Shield, Environmental Resistance, and Energy Shield
  - Protection augs are the Damage Resistance augs plus Aggressive Defense System
- Fixed a bug where tranq darts were sometimes dealing lethal damage
- Some bingo-relevant books are now color coded for easier recognition (The Man Who Was Thursday now has a red cover, and Jacob's Shadow is now purple).  This can be controlled by the Goal Textures setting.
- NG+/WW reduced skills churn
  - NG+ does 2 skill downgrades instead of 3
  - WaltonWare crates have 33% fewer skill points
  - NG+ takes away 20% of your unspent skill points instead of 25%
- Max Rando/NG+ prevent min_weapon_dmg from going too low, old range was 25% to 100%, now it's 40% to 90%
- `MaxRandoValPair` now has more separation between min and max (like for the min/max weapon damage, or min/max skill costs)
- Pool tables are much improved
- Removed Vandenberg start location at front gate (where you find Jock after you completed your goals in the non-Randomized game)
- Added Vandenberg start location on roof of the comms building
- Bingo boards generated for Mr. Page's Mean Bingo Machine now only have 1 free space instead of 5.
- Randomly selected starting locations for New Game+ will try to avoid repeating recently used start locations more.  This also includes repeat UNATCO HQ or Hell's Kitchen starts (even across different visits)
- WaltonWare crates will now give medkits depending on your start location and your maximum health
- Added scaling and blackout options for scopes and binoculars, with a cool automatic "Fit to Screen" option that doesn't rely on fixed size textures and adapts to any screen resolution/ratio
- Proper handling of Ford Schick being unable to give you the aug upgrade can when your inventory is full
- Make sure Shannon is always present in M01, regardless of gender #1280
- Many "Kill Person X" goals are changed to "Take Down Person X", allowing both kills and knockouts instead of just kills.  Bingo boards from older versions will be upgraded to this.

# Bingo / WaltonWare / NG+ Minor Changes

- Bingo Viewer application improvements!
  - Bingo Viewer will now automatically load the last used file, rather than prompting to select a file every time it opens
  - If your bingo file contains data from multiple mods (eg. Vanilla and GMDX), it will remember the mod you selected to use last time
  - Bingo Viewer now has menus which allow you to open a new bingo file, change the selected mod, reset your window size, or select your JSON Push destination (for marathon use)
  - Bingo Viewer will now create a settings file
  - Performance tweaks
- NG+ crates subtract unspent skill points and credits instead of silently taking them away in NG+
  - (instead of NG+ silently taking away unspent skill points from the player, now it tries to remove them from the WW crate first)
- Fewer datacubes in Area51 Entrance and Page (#1244 and #1245)
- Hong Kong main quest bingo goals aren't given for early starts
- Bingo goals for buying from The Merchant and Le Merchant
- The `ChangeClothes` bingo goal is never as failed when clothes looting is enabled
- The `IgnitePawn` bingo goal is no longer allowed with restricted loadouts
- The `GibbedPawn` bingo goal requires that the player is the one who did it
- Bingo goals can no longer be completed during cutscenes (Intro and endings)
- New smaller scale Pool bingo goals.  These will be swapped in when bingo duration is low, instead of the multi-table goals.
- All books, datacubes, and newspapers can now show a summary of what they are when highlighted.  These summaries are only visible when password assistance is enabled
- Add French Exit signs to the Emergency Exit bingo goal (and extra goal info for those who don't speak French)
- Tweaked when some bingo goals can appear, based on settings and version of the randomizer being used (eg. Revision)
  - The "Flush Toilets" bingo goal can now be completed in M15 in Revision
  - "Extinguish yourself with running water" is no longer allowed with short bingo durations
  - "Extinguish yourself with running water" is no longer marked as completable in M02, as there is no running water on the same map as burning barrels
  - Enabling clothes looting takes the added clothes racks into account for the "Change Clothes" bingo goal in vanilla
- Reduced the maximum for the bingo goal to kill the sailors in the Lucky Money, since the maximum was previously based on the number of sailors present in the LDDP version of the map (one extra sailor)
- The bingo goal to go to the ends of both cranes on the superfreighter now correctly always requires you to go to both
- Increased CollisionHeight for birds
- Fixed the Advanced menu breaking the Random Starting Map default for WaltonWare
- Added several new bingo goals (particularly around M05 Jail)
- Minor fixes for carrying WaltonWare crates across maps
- Fixed a bug with carrying a corpse across NG+
- The Versalife Labs 2 start location gives you the computer password so you can move forwards or backwards
- Bingo goals for reading books and stuff are now mutually exclusive
- Blocked the 747 Suspension Crate datacube from being in the Suspension Crate
- Improved/compartmentalized NG+ seeding
- Pianos now avoid recently skipped songs, and have stronger weights for required songs

# Minor Changes

- Entrance Rando is now an advanced setting, and some Entrance Rando game modes have been removed
- Various speech restorations
- Paul hotel raid depends on minor map balance, binoculars depend on moderate
- The goal to find the Ambrosia is given immediately when entering M02 Battery Park, rather than getting it from speaking to Anna
- Ambrosia barrels will now be shuffled with other containers, except when they are a mission goal (M02 and M03)
- Flashlight brightness is slightly reduced (but it's still brighter than vanilla)
- Upgrading active augs no longer makes deactivation and activation sounds
- DXVK 2.7, smarter compatibility checks with vulkaninfo
- Enemy respawning will no longer display an error message when there are a large number of enemies present (eg. Serious Sam mode).  The limit on the number of respawning enemies has been reduced.
- Fixed changing enemy respawn to 0 during a game
- Memory Containment Units (MCUs) for limited save games will now try harder to find a valid location to spawn before giving up.
- When all items are removed from a crate, the cardboard box that replaces it will match the size of the original crate
- Harley Filben will still talk to the player on Liberty Island if using Confix (eg. GMDX) and you didn't get the password from Paul first.'
  - Note: Confix is NOT required or recommended for use with vanilla Randomizer
- Memory Containment Units will be ignored for the purposes of the Unaugmented Prison Pocket setting, allowing you to keep another item.  Memory Containment Units will always be allowed to be kept.
- Vandenberg Cmd move "near pipes" start to a higher level, so the start locations are more equal
- Make sure the guard inside the front door of Dockyards is friendly if you come in some way other than the front door (if you helped Vinny)
- Speedrun splits view changes:
  - Added %combatdifficulty to `HUDSpeedrunSplits`
  - Don't show a mismatched splits warning in WaltonWare
  - Mismatched splits warning dialog now shows PB
  - WaltonWare doesn't write to splits file
  - Fixed some spacing issues
  - The WaltonWare timer now shows tenths of a second for WR tie breakers
- ScriptedPawn can be ignited by flaming barrel if they stand on it
- Guy in the Old China Hand no longer gives FemJC the Versalife Maps for free if Paul is alive
- Camille (the dancer in the Paris club) will now be able to talk to you even if Antoine (the biocell guy) is dead
- Added a datacube with info about fixed and limited saves to JC's office in M01 UNATCO HQ
- Enemies are slightly more likely to receive a baton and slightly less likely to receive a combat knife when being given random weapons
- The Hanging Lantern in Maggie's apartment is now invincible, so you can always get to the MJ12 area
- Added help buttons to Spoiler Button and Camera Mode advanced settings
- Goals on the goal screen will still show their description when completed, rather than being changed to blank
- Bathroom mirrors in M03 Airfield Helibase will now work as expected for binocular-based bingo goals
- Don't show Goal Location markers for start locations

# Zero Rando

- Zero Rando has more vanilla authentic damage types for Hazmats
- Zero Rando allows using computers from too far away again, and disables the animation speedup that compensates for it (back to vanilla behavior)
- Explosive barrel damage unchanged for Zero Rando (unless you have the new barrel textures enabled or BalanceEtc)
- Removed `DXRDoors` `door_fixes` from Zero Rando
- The player portrait on the new game screen doesn't get randmized in Zero Rando
- Laser positions in M04/M08 Hell's Kitchen sewers are now only adjusted when Moderate Map Balance Changes are enabled (meaning they are no longer adjusted in Zero Rando)

# Crowd Control

- Additional messages for dropped pamphlets
- Crowd Control grenades are now thrown at the player from a random location around them, rather than being dropped at their feet
- Crowd Control thrown grenades show the viewer name when highlighted
- Grenades thrown by Crowd Control now detonate at the normal speed, instead of very slowly.
- Crowd Control effects don't start when the player is dead
- The "Disable Jump" Crowd Control effect now works again in vanilla
- Crowd Control won't allow giving the player a weapon they already have (except for ones where the weapon pickup acts like the ammo, like grenades or throwing knives)

# HX Fixes

- HX will now generate the bingo board based on the starting map selected when hosting the server
- Replaced grenades in HX no longer beep at the start of the level #1255
- Sub base doors and the UC door switches will now be aligned properly again
- Gordon's Intercom will no longer fall to the floor
- Added a short delay between setting flags and starting infolinks after NSF HQ message broadcasted and UC schematics downloaded in Ocean Lab.  This lets them work properly in HX without any noticeable difference otherwise #1263
- M04 Anna and M14 Walton will properly start out of world in HX #1251
- All spawned datacubes in HX should now be added to your datavault when read
- HX won't enable enemy resurrection or reanimation on the first loop
- Zombies are properly initialized in HX #1247
- Ensure cloned pawns are marked as not initialized before trying to initialize them (Not strictly required for vanilla, but needed for HX to ensure they go out of world and get correct alliances) #1251 #1248
- Don't populate the bingo board with question marks in HX #1252
- Maggie's piano in HX now says who played a song and broadcasts it to all players #1255
- HX will now use the proper triggers to start Infolinks, preventing softlocks (particularly when finding the Dragon's Tooth Sword)
- HX now considers itself to use the vanilla maps, so it will no longer unintentionally do things intended for Revision
- HK Basketball bingo trigger finds the proper original trigger #1255
- The Lucky Money Freezer Door now gets attached to the security computer in HX #1255
- Sam Carter is now fearless in HX
- Infolinks will now start properly when initiated from Randomizer code
- Jock will now appear as expected when completing Silo
- More various fixes for HX Randomizer
- Ensure that `BingoFrobber`s are "always relevant" to ensure the ones that are out of world are present on HX clients #1257

# Revision

- Updateed mission masks for some bingo goals in Revision to account for what exists in the Revision Maps
- Added CheatsOn, CheatsOff, and AllPasswords cheats to the Revision player class
- Addded ShowBingoWindow exec function to RevRandoPlayer so it can be manually bound to a hotkey
  - In the User.ini file, go to the \[Engine.Input\] section and find the key you want to bind to open the bingo screen.  Change it so that it maps to ShowBingoWindow, eg. to make B open the window: `B=ShowBingoWindow`
- The "Go to the third floor of the Ton" bingo goal in Revision now allows going up the stairs instead (in M08, where the stairs are accessible)
