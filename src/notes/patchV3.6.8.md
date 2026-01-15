## Major Changes

- New password randomization styles!  By default, passwords will now be randomized by picking a few words from word lists instead of purely random letters and numbers.  In theory these passwords should be a bit easier to remember if not using autofill, as well as simply being more "fun".
  - If memes are disabled (such as when playing Serious Rando), password randomization will default to "Pronouncable" passwords instead.  These passwords alternate vowels and consonants (the same method used for random names) to form vaguely pronouncable passwords which should be easier to remember
  - If you want to switch password styles mid-game, do so just before leaving for a new mission (so there is no possibility of backtracking) for the least possibility of causing issues.
- You actually start the game with all of your skill points again, instead of 80% of the amount you had left over after the new game skills screen.

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
  - Infolinks will now play at normal volume instead of fading away as the player gets further from the camera.
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
- Robots will no longer drop any weapons regardless of whether they are "standard" or not.  Some robots, like the security bots in Dockyards (Mission 9), have non-standard robot weapons such as flamethrowers.  Previously, when those robots were destroyed, they would drop any of those non-standard weapons.
- Spiderbots (Or robots who have been given spiderbot weapons) will now be able to use their zap attack against enemies who are not robots.  Previously spiderbots would have only used the zap against the player or robots (particularly noticeable if you scrambled a spiderbot, they would just stand and look at their enemy without attacking).
- Enemies will no longer clone off of disabled robots (Like the ones in the robotics bay in Mission 5, or the Level 2 MJ12 Lab in Mission 6)
- Dragging a stack of items off of the inventory screen will now drop the whole stack, rather than just a single item from the stack.
- Barrels that start the level already leaking will no longer lose 1 health every time the game or map is loaded.
- Gas clouds (such as poison gas from barrels, halon from fire extinguishers, and tear gas from gas grenades) no longer block the highlighting of objects behind them.
- When meeting the Dragon Heads for drinks at the Lucky Money (Mission 6), JC will properly acknowledge that he doesn't have room for Max's drinks when his inventory is full.  If this happens, the wine will appear on the bar, rather than being lost forever.
- In Mission 8, Jordan Shea will no longer take your money if you don't have space for the Forty or Candy Bar you may try to buy from her.
- In Mission 8, Smuggler will no longer take your money if you don't have space for the Assault Shotgun that he sells.  This also fixes the same issue for the Sabot rounds and GEP rockets he sells, but currently Randomizer will not fail an ammo transfer, even if you are full on that type of ammo.
- The barrels behind the teleporter leading from the Ship Upper Decks to the Dockyard Ventilation System (Mission 9) will no longer be randomized.
- NPCs who are standing or dancing will now always try to return to their original location after leaving it for whatever reason (e.g. if they chased the player).
- Alex Jacobson will now actually appear in Tong's Lab (Mission 6) when using a Hong Kong starting map (e.g. when playing WaltonWare).
- Aggressive Defense System will now stop tracking projectiles immediately once the player runs out of bioelectric energy.
- Datacube with ALL_SHIFTS account information in Versalife offices (M06) can now be randomized anywhere in the office except for the security room.
- Bingo goals that require you to kill or knockout a specific character yourself should now be marked as failed more reliably if killed or knocked out by someone other than the player.
- Bingo goal adjustments:
  - "Ignore Paul in the 747 Hangar" now allows either a kill or knock out.
  - "I SPILL MY DRINK!" now allows either a kill or knock out.
- The time between conversations with Jock and the start of exit cutscenes has been consistently reduced to try to prevent the player from taking damage between the end of the conversation and the start of the cutscene (as often happened at the end of Mission 9 Graveyard).
- The player can no longer put random ATM accounts into debt when hacking them (they can only be reduced to a balance of 0 credits).  Account balances are actually properly emptied and synced to other ATMs in the same map when an ATM is hacked.
- The odd mechanic at Everett's house will no longer become angry at the player if he sees someone (like a zombie) trying to attack the player.
- Zombies will no longer be able to resurrect through thin floors.
- Weapons that are in the process of attacking will not actually attack if their owner dies mid-fire.
- Turrets that have been moved or randomly added will now sit idle facing the area they are supposed to be protecting.
- Turrets will now swing side to side when active and hunting targets.  This makes it possible to determine from a distance whether a turret is going to try to shoot you or not (since the light on the front of the turret is not always visible).
  - Turrets in Ocean Lab will move more abruptly for flavor purposes.
- Revision no longer soft locks with Paul ignoring you after sending the signal at NSF HQ (Mission 4).
- Revision no longer soft locks with Gordon Quick disappearing after retrieving the Dragon Tooth Sword ROM if he had been randomized somewhere outside of the Compound map.
- Split clothing randomization out of the "Memes" configuration option into a new "Fashion" option, under the "Visuals" settings menu.
- Save points are indicated in their highlight info when playing with Fixed Saves.
- Bodies that the player carries are now visible in third person and fixed camera perspectives.
- Block certain out-of-bounds locations from being selected for random placement of things (like medbots/repairbots, merchants, turrets, datacubes, etc...):
  - Beyond the teleporter at the end of Ocean Lab, leading into the UC map (Mission 14).
- The goal to find the Ambrosia in Battery Park (Mission 2) is now properly added at the start of the the level again.
- The Training Merchant (who shows up in Training) is no longer afraid of anything.
- The door in the demolitions training hallway (In the training mission) can now be highlighted to see the damage threshold.

</details>
