## Major Changes

- New game mode: Speedrun Shuffle!  This is the same as Speedrun Mode, but the order of the missions is shuffled.
- New game mode: Mr. Page's Nice Bingo Machine!  This is a combination of Normal Randomizer and the Mean Bingo Machine, making it a great starting point for people to learn bingo.
- The new game screen now shows recommended presets.
- You can pet the robots! (Except for Medical and Repair Bots)

## Minor Changes

<details>
<summary>Click to expand Minor Changes</summary>

- Robots can now be randomly given a pistol weapon or a radioactive weapon.
- Updated speedrun splits notes defaults.
- In vanilla, bingo goals for destroying robots can now also be completed by disabling the robots as well.
- Area 51 sniper in tower is activated immediately if you start in the tower instead of starting to move after 9 seconds.
- Improved some RNG to be more evenly distributed.
- Rando Lite no longer has added merchants.
- "Songs Played" count on piano highlight info no longer shows if Memes are disabled, since this also disables the additional songs to be played.
- Some doors that have pneumatic sounds now break into metal fragments instead of wood, such as the Ocean Lab surface map sub bay doors.
- Fixed the size of some objects that replace the Earth being grasped by the hand statue.
- The 350 skill points for redirecting the missile in Silo (Mission 14) can no longer be acquired by walking in the right spot in the command center.  The skill points will now be properly given only when actually redirecting the missile from the launch computer.
- Changes to October Cosmetics settings
  - Spooks (spiderwebs and jack-o'-lanterns) and red screen tint can now be turned on or off separately in global settings
  - Spooks are now correctly turned off in Halloween modes, when disabled in global settings
  - Spooks are now correctly turned on when not in Halloween mode or October, when enabled in global settings
- Improved faction detection when cloning enemies.  Bots in the Airfield (Mission 3) should now clone NSF-related enemies, and spiderbots in the Vandenberg Tunnels (Mission 12) should now spawn MJ12-related enemies.
- Enemies cloned from the NSF in Mission 3 will now be cleaned up better in non-vanilla versions of the randomizer.
- "Send him back to the people" bingo goal now gets marked as failed as soon as Leo Gold disappears from the game.
- Bingo help window now shows the available missions as a list with human readable names.  If the goal is active in the current mission, the mission will be clearly marked in the window.  In Zero Rando, missions beyond the current one will only be listed as ??? to avoid spoilers.
- New Bingo Goals:
  - "Spoils of War": Buy something from Tech Sergeant Kaplan in Mission 1.
  - "We're Cops": Tell Tech Sergeant Kaplan you're going to take a minimum-force approach in Mission 1.
  - "Bench Warmer": Sit on 3 benches scattered around Liberty Island (Mission 1).
  - "Peace Keeping Occupation": Speak to Gunther after completing a mission (Mission 2, 3, or 4).
  - "Who will help the widow's son?": Speak to the Freemason in the Free Clinic (Mission 2).
  - "Pet x Cleaner Bots": Pet enough cleaner bots (Missions 1, 2, 3, 4, 8).
  - "Pet x Commercial Grade Security Bots": Pet enough commercial grade security bots (Missions 1, 2, 3, 4, 8, 11, 15).
  - "Crawl under the super freighter helipad": Crawl through the tunnel connecting the electrical room to the helipad (Mission 9).
  - "Raise the bridge in engineering": Use the keypad next to the bridge in the superfreighter engine room to raise it.
  - "Our Country 'Tis of Thee": Listen to the bum in Battery Park sing his whole rendition of My Country 'Tis of Thee (Mission 2)
- Mission starts inside the Ocean Lab or at Silo (Mission 14) will now start with the sub bay doors open in the Sub Base.  Silo starts will also start with the sub bay doors open in the Ocean Lab itself.
- Randomly placed datacubes (such as Medbot or Repairbot hints) should no longer be able to get placed in unreachable areas (Such as underneath the shanty town huts in Mission 2 Battery Park).
- Synthetic Heart aug improvements and fixes:
  - Aug levels are always shown as the actual level, instead of the effective level if being boosted by Synthetic Heart (In other words, an aug will show the same level whether Synthetic Heart is active or not).  The extra level from Synthetic Heart is shown as a plus sign next to the aug level when the aug is being boosted.
  - It is now possible to fully upgrade an aug while Synthetic Heart is active.
  - Augs that are removed (Such as at the end of a game or if removed at a Medical Bot) while being boosted by Synthetic Heart will no longer be already in a boosted state when reinstalled, resulting in them being at an effective level 0.  This is most obvious when Synthetic Heart is active when the aug is reinstalled.
  - Crowd Control can no longer downgrade an aug to level 0 if it is being boosted by Synthetic Heart.
- New Aug Slot Rando option: Balanced. Keeps the proportional number of augs per slot as close to default as possible.
- Zombies raised from corpses of the player (or corpses of Crowd Control player clones) now get the proper face skin and hit sounds.
- Troops that are fleeing during the apartment raid in Mission 4 are now considered dead for the purposes of stopping the raid (So you won't need to hunt down that one troop hiding in a corner to have it counted as being completed).
- Paul's fashion should now be immaculate after uncloaking and in death.
- Paul and JC's corpses will now correctly use the "floating" mesh if clothes are changed while the body is in the water
- "Who Needs Rock?" bingo goal progress is now properly marked when trading zyme to Lenny after getting a LAM from El Rey.
- Karkians in the MJ12 Lab (Mission 5) will now properly go hostile and try to escape regardless of how the door is opened.
- Player clones spawned by Crowd Control can now use defensive augs, speed, cloak, medkits, biocells, and fire extinguishers that the player had when the clone was spawned.
- Smuggler's bot starts "standing" instead of "idle", which means he will still react to threats when Smuggler knows you (and he becomes pettable).
- Paul actually disappears after talking to you and going to the train in Mission 2.
- Conversations that play while in first person will now try to trigger other events that happen after a voice line gets interrupted.  This fixes/improves some cases where you get items, notes, or flags get set after the voice line plays (for example, the trooper that gives you LAMs in the training mission, or Nicolette giving a password note when in the study of Chateau DuClare).
- The Crowd Control setting will now automatically be enabled if there is a session connected when starting a new game.
- When playing with Toggle Crouch disabled, you can now crouch while jumping.  This was already possible when Toggle Crouch was enabled.
- "Let Aimee and Le Merchant Live" bingo goal now gets properly marked as completed when traveling to another map other than Denfert-Rochereau.  This fixes the goal with Entrance Randomization, where it would previously only be marked completed when you get to the Catacombs tunnels.
- Open Aug Tree can no longer be opened on the title screen.
- "AL" will now appear over the oxygen meter when swimming underwater while Aqualung is active (Manually or automatically).
- The electrical panel in the basement of the NSF Warehouse (Mission 2) near the sewer entrance will properly disable the nearby laser triggers, as well as disable the rest of the basement lasers (Without disabling unrelated lasers elsewhere in the map).
- Items that don't exist in the inventory grid will not be counted for the purposes of removing items beyond the "Max Item Carryover" limit.  For example, with a "Max Item Carryover" of 5, you can wear 1 ballistic armor through the end of a loop while holding 5 unused ballistic armors in your inventory and not lose any of them due to the limit.
- In Mission 3, the Sewer Door and East Gate keys now drop from enemies before they're removed after dealing with Lebedev.
- Charged Pickups (things like ballistic armor, thermoptic camo, tech goggles) no longer count down their timers while in cutscenes (Like game endings or helicopter rides).
- Items like fire extinguishers or armors that are in use when finishing the game will be removed when starting New Game Plus.
- Items should no longer be lost sometimes when dropped and picked up again quickly (GEP Gun juggling, for example).
- Adjustments to the alliances of everybody in the Versalife offices.  Security guards should now spawn police-related clones, and the commandos that show up later will spawn MJ12-related clones.  Workers with weapons will spawn more generic clones.
- Zombies will now resurrect with the same head gear as they had before (Helmets, visors, or lack thereof).
- New Loadout: "No Rifles".  Assault Rifle, Assault Shotgun, Sniper Rifle, and Sawed-Off Shotgun are banned, along with their associated ammos.
- Enemies will no longer use a PS40 at extremely close range.
- More reliable timer storage across crashes.
- Fix patrol points in the 'Ton Hotel in Mission 8 so that the riot cops actually patrol the hotel.
- "Getting Colder..." infolink from Alex in Mission 1 UNATCO HQ actually works if you leave his office without talking to him.
- Values in the Environmental Training skill description align better.
- Smuggler's elevator button in the final New York mission no longer moves around.
- Added buttons for Save Settings and Restore Settings on the Advanced New Game screen.
- Stackable items marked as Junk will now get picked up if they're already in your inventory.
- Gordon Quick and Max Chen will try to move back to the temple if they are lured away while waiting for you to start the ceremony (Mission 6).
</details>
