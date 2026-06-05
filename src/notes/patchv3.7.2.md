## Major Changes

- New game mode: Speedrun Shuffle!  This is the same as Speedrun Mode, but you only play a few missions, in random order.

## Minor Changes

<details>
<summary>Click to expand Minor Changes</summary>

- The level transition from Airfield to the Hangar (Mission 3) is no longer able to be used from the outside of the bridge when "Glitches for Speedruns" are set to "Allowed".
- Bingo Viewer changes:
  - Goals can be marked to help you keep track of what line you're aiming for.
    - Left click to mark a goal
    - Right click to unmark it
    - Drag to mark/unmark an entire bingo line
  - The window no longer locks up temporarily when moved or resized on certain systems.
  - Font size more accurately scales to best fit the tile size.
  - The green progress bars now fit to the edges of their tile
- The level transition from Airfield to the Hangar (Mission 3) is no longer able to be used from the outside of the bridge when "Glitches for Speedruns" are set to "Fixed".
- NPCs will now react to projectiles regardless of whether they're immune or not if "Glitches for Speedruns" is set to "Allowed"
- When the "Camera Mode" is set to "Third Person", the camera will now shake when heavy enemies (such as Military Bots) walk near you.
- More interesting camera angles when talking to The Merchant (or Le Merchant).
- Sam Carter only gives you one case of shotgun shells instead of 3 in Mission 4.
- "Use x Rebreathers" bingo goal will only be available in Mission 3 when Entrance Randomization is enabled.
- "Invert Mouse" Crowd Control effect will now properly restore your mouse controls if you load a save made during the effect after the effect ends.
- Teleporters between maps will now properly show whether the destination map is mirrored or not (The arrow in the icon will point left for mirrored maps, or right for normal maps).
- The Crowd Control setting in the Randomizer Setup or Advanced Settings pages will now be automatically enabled if Crowd Control connects to the game while in those menus.
- The instant death zone in the fan shaft on the surface of Area 51 (Mission 15) will always be gone after loading a game if the fan was destroyed.  This was a bug that popped up intermittently, related to specific save timing after destroying the fan.
- Barrels will no longer play their push sound forever after being pushed once.
- "Experimental Subject Cells" Key in the Versalife Level 1 Labs (Mission 6) will no longer randomize into the locked cabinet in the lab.
- "UC Shutdown Code" datacube in the Versalife Level 1 Labs (Mission 6) will no longer randomize into any locked areas.
- Tong will no longer tell you that you've found one of the weld points if you've already destroyed one (Mission 9).
- Crowd Control effects will no longer sometimes set off grenades planted by the player.
- Randomly spawned "SecurityBot4" (The treaded bot with yellow shoulders) will now use a modified texture with gray shoulders instead.  In GMDX, this helps to distinguish these bots from the similar looking ones that have rockets and can cloak.
- "Flickering Lights" setting now prevents electricity emitters from flickering as well.
- More locations for items to be randomized around Maggie's and Jock's apartments (Mission 6).
- The datacube with Maggie's birthday is guaranteed to be in her apartment (Mission 6)
- Bingo goals that require using a ranged weapon to shoot something will no longer be given when using loadouts that don't allow any ranged weapons to be used.
- Bingo goals that require looking at an image will be marked as soon as the image is viewed, instead of when the window is closed.  This also fixes an issue where sometimes the image wouldn't get marked as viewed, depending on how the window was closed.
- The "New Image" icon in the list on the "Images" menu will disappear when you click off of the image to another one.
- "The Three Leg Augs" and "My Vision Is Augmented" loadouts will now default to Balanced Aug Slot Randomization instead of Unbalanced.
- "Goal Locations" and "Goal Spoilers" buttons will no longer appear on the "Images" menu when you have no images to view.
- Items that are randomized into a location "inside" a crate (Or if a crate is randomized into a location that overlaps an item) will get pushed to the top of the crate instead of being hidden inside it.
- New "Death Cam" options under Rando > Visuals (Vanilla and Revision only).
  - "Spinning Camera (Original)": When you die the camera will spin over your dead body.
  - "Spinning Camera (Slowed)": When you die the camera will spin over your dead body more slowly.
  - "Overhead Camera (No Spin)": When you die the camera will hover over your dead body.
  - "Show Killer (Kill Cam)": When you die, the camera will follow the person who killed you.
- Regular spinning death cameras will continue to spin forever, instead of stopping after 8 seconds (Vanilla and Revision only).
- When the "Flickering Lights" setting is set to "Epilepsy Safe", lights that flicker *extremely* quickly will now pulse at a slower rate to ensure they don't still look like they're flickering.
- Leo Gold (the terrorist commander in Mission 1) will now be fearless in all game modes, instead of only when Goal Randomization is enabled.
- Non-Vanilla fixes and improvements:
  - When playing a mod that uses Confix (Such as GMDX or Vanilla? Madder!), Harley talk to you after finishing Mission 1 if you didn't talk to him or Paul before finishing the mission.
  - A large number of bingo goals have had their available missions adjusted in GMDX and Revision to match which missions they can actually be completed in.
  - Non-Vanilla mods can now use the fully enhanced Randomizer "Show Classes" window in the "Legend" cheat window.
  - Non-Vanilla mods now get an "open doors" symbol in elevators with an "open door" button.
  - When entering a map for the first time with the password or code to a computer or keypad, the password will be correctly marked as known.
- Revision fixes and improvements:
  - Revision can no longer change the "Gameplay Style" to "Vanilla" by cycling through the options backwards.
  - Revision now shows more useful descriptions of the randomized values of the "Life Leech", "Radiation Discharge", "Auto-Counter", and "AimBot" augs.
- GMDX fixes and improvements:
  - Enable "Flickering Lights" setting
  - Enabled "Goal Textures" setting to allow adjusting the textures on some randomized goal computers for better visibility.
  - Augbots will now properly show with their blue skin and will glow red by default.
  - Medical Bots will now properly count their number of uses.
  - The window for recharging at a Repair Bot now properly updates the bio energy bar immediately.
  - The first conversation with Paul (Mission 1) is no longer skipped.  Instead, the option to get the free weapon from him is stitched out of the conversation (like in Vanilla Rando), and you can still speak with him to get the map of the island.
  - The value of the Stealth skill is now shown in a more interpretable format (based on your walk speed).
  - More useful descriptions of the randomized values of the "EMSP" (Dash) and "Energy Transference" augs are now shown.
  - The button behind the Flight Deck door in the Hong Kong Helibase (Mission 6) now actually opens the flight deck door instead of a vent in the barracks.
  - Beheaded corpses that are trying to zombify will no longer cause error messages, but will also no longer try to be reanimated.  Zombie rules say that if the head is gone, they can't come back.
  - Scripted grenades that get thrown into vents will not be set off by Aggressive Defense System before being thrown.
  - Some inaccessible items in the Paris Cathedral (Mission 11) will no longer be randomized.
  - Minor randomized goal location adjustments to account for items or geometry in GMDX maps that aren't present in vanilla maps.
  - Hardcore settings become unlocked when you finish the game.
  - Added an exit button to the Hong Kong Helibase barracks (Mission 6).
  - Smugglers bots in Mission 8 are no longer permanently hostile when Moderate Map Balance changes are enabled.  They will only be hostile if you have not spoken to Smuggler before this mission.
  - Boxes near the end of Versalife Level 2 Labs (Mission 6) will no longer be randomized to prevent softlocks when unmovable items are randomized into those locations.
  - Upgrades to the EUAS (IFF) aug will actually display on screen (Light level and environmental hazard warnings).
- Vanilla? Madder! 2.0 fixes and improvements
  - Objects will no longer be sometimes left without collision when they are replaced by the Randomizer.
  - The conversation in the intro will actually start playing.
  - Backing out of the New Game screen will no longer cause the game to crash.
  - The "Character Setup" screen will now be considered a title screen, so Crowd Control effects will not function there, and Crowd Control will be able to connect while on that screen.
  - Skill costs shown on the "Character Setup" screen will now match the ones you see when you enter the game.
  - Turrets that have been moved will now have their guns placed in the correct location.
  - Scopes (Either binoculars or on a weapon) will now properly mark bingo goals.
  - Scopes (Either binoculars or on a weapon) will now look the same as they do in non-randomized Vanilla? Madder!
  - Key location randomization rules for Ocean Lab "Storage" key (Mission 14) will now be properly applied.
- New Bingo Goals:
  - "Advertising Works!": Look at enough advertising billboards through the game with binoculars or a scope.
  - "Support Local Business": Look at enough "Old China Hand" signs through Hong Kong with binoculars or a scope.
  - "Catch the News": Watch enough TV newscasts through the game with binoculars or a scope.
  - "Signs of the End": Look at the signs marking the different endings in Area 51 Sector 4.
  - "Construction Inspector": Look at the UC Control signs in Area 51 Sector 4.
  - "Fire it up!": Use the pipe flame button in the coolant area of Area 51 Sector 4 (Mission 15).
</details>

## Intra-Patch Changes

- In Speedrun Shuffle mode, highlight text now shows the next map you will be going to when looking at the game endings in Mission 15.
- Lebedev's surrender conversation doesn't play if Anna's already dead in Speedrun Shuffle.
- Some flickering lights that weren't being caught by the "Flickering Lights" setting in GMDX will now also be adjusted.
- Full Game Shuffle now correctly gives you all 13 missions instead of just 12.
