## Major Changes

- Added our new 2nd dumbest game mode
- In WaltonWare, Jock will now also appear at Battery Park in Mission 3 after dealing with Lebedev, in addition to the original location in the Airfield.
- The sewer exit leaving the inside of the Mission 9 dry dock now has a keypad instead of a button in modes outside of Entrance Randomizer.  The keypad uses Jenny's number, so the code can be found in the dockyards.
- Important characters that get killed in the intro cinematic on New Game Plus will no longer stay dead into the new loop.  This prevents potential softlocks from occuring if characters required for progression (like Manderley) aren't present.
- The location of Jock is now randomized when leaving the graveyard at the end of Mission 9.
- Third-Person and Fixed Camera camera modes now show the targeting reticules at the end of the aiming laser to know how accurate shots will be.

## Minor Changes

<details>
<summary>Click to expand Minor Changes</summary>

- Bingo goals that require the use of drugs or alcohol will no longer be available when those items are banned (e.g. in the Straight Edge loadout).
- Tweaked weapon placements for different FoVs and ultra-widescreen.
- Alarm lights now count for the "Light Vandalism" bingo goal, if they are breakable.
- Fixed mirrored rotation of the Limited/Fixed Saves ATM that was added to the gas station, and moved it forwards slightly to get away from some bad collision detection.
- Fixed possible crashes with flag names generated for Merchant conversations that exceeded the maximum length.
  - If you have already encountered the Merchant in a map in an in-progress game when you upgrade, he may be a bit confused about what he has available to sell to you.
- Block certain out-of-bounds locations from being selected for random placement of things (like medbots/repairbots, merchants, turrets, datacubes, etc...):
  - Outside of the walls of the UNATCO compound in Missions 3, 4, and 5
  - Beyond the level transitions between the Wan Chai Market and the Lucky Money
  - Beyond the door to the Vandenberg Computer area from Cmd
- Removed collision from teleporters so they don't block pawns or items.
- The Bingo Viewer now has an option to always keep the window on top (under the Display menu).
- Looking at Weeping Anna will no longer interrupt her death animation.
- For GMDX we now set Hardcore mode when starting a game with combat difficulty 4 or higher (such as when selecting Impossible/Realistic difficulty).
- Fixed randomizing some of GMDX's invisible objects.
- Fixed a bug with conversations referencing the player's kill counts in Mission 1 and Mission 2.
- Added a timed race to Vandenberg Tunnels (in both the forward and backward directions): See how fast you can go!
- UNATCO Troopers that appear in Mission 3, after meeting Lebedev, will no longer hate seeing carcasses (which typically makes them hate the player).
- The bingo goal for returning to UNATCO HQ in the boat after Mission 2 no longer appears unless the bingo board spans more than 1 Mission.
- Possible fix for some timed races (e.g. Catacombs or Reverse Catacombs) where the Mastodon messages were reporting the player losing over 9000% health.
- Fixed installer failing with Documents path issues
- The key for the cabinet in the Mission 2 Free Clinic is now adjusted more reliably and should now work properly in Vanilla? Madder!.
- The description for the Energy Shield augmentation now mentions that it works against explosive damage as well.  This is vanilla behavior, so just makes the description more accurate to its functionality.
- Fix the carcass in the collapsed Canal Road tunnel (under Canals) so that it doesn't lose the aug upgrade can when the biocell he is also holding gets removed by DXRReduceItems.
- Killing Anna Navarre without using her killswitch will now fail the bingo goal to kill her with her killswitch.
- Jack-o'-lanterns no longer support any significant weight, collapsing if heavy things are on top of them (like trash bags).
- Added a copy of the UNATCO Closet Key to UNATCO HQ in Mission 5.
- Skill points originally associated with finding Paul or your equipment in Mission 5 now get moved along with Paul and your equipment when Goals Rando is enabled.
- Bingo goal for entering the gas station ceiling no longer requires going to the center of the ceiling (It will trigger as soon as you enter, regardless of which entrance is used).
- Bingo goal trigger points for visiting the ends of the cranes on the superfreighter adjusted to be a bit more clear.  Also adjusted the skill point and infolink triggers present on one of the cranes to match the location of the bingo goal trigger.
- Added a button to the top of the dumbwaiter shaft in Chateau DuClare, in case you end up on top of the dumbwaiter while it's moving to the top.  This one's for you, Krickraken.
- Switching to "Vanilla" gameplay style in Revision is now blocked, because Randomizer is not compatible with this mode.  "Normal" (Standard Revision gameplay), "Shifter", "Biomod", and "Human Revolution" gameplay styles are still available.
- It is once again possible to exit or skip the credits with the Escape button.
- Entrance Rando setting now carries through New Game Plus, so you will be able to keep playing in Entrance Rando forever.  Enjoy WaltonWare Entrance Rando!
- Highlighting a credit chit will show many credits it holds.
- More consistent projectile damage calculations when using very low randomization percents (e.g. 0% Damage).
- Removed extra soda, liquor, and cigarettes added to Mission 3 Battery Park.  The locations of these added items will still be available for items to randomize into.
- New Game Plus will no longer remove any weapons that your loadout made you start the game with (e.g. you will no longer be able to lose your sword in Ninja JC mode).
- Howard Strong will now always be in the silo map unless you have Entrance Rando enabled and have not yet completed the previous goals.
- Fixed Stalker setting not carrying over across New Game Plus.
- Improved performance by reducing amount of config writing.
- Open Aug Tree puts auto augs at the end of the list
- WaltonWare starts after Vandenberg Command give the keypad code for the Vandenberg Command backup power
- Speedrun splits no longer complain about mismatch flags when the PB is blank
- Speedrun Training mode no longer uses realtime menus, and ensures the Speed Enhancement loadout.
- Enabled reflections and anisotropic filtering for D3D9 and OpenGL by default.
- Added bingo goals:
  - Question Joe Greene in Mission 2
  - Ask Joe Greene for help after the apartment is raided in Mission 4
  - Withdraw money from ATMs
  - Destroy the UNATCO flags in Mission 5 UNATCO HQ
  - Sit on a bench in the Free Clinic atrium
- Moved 1 item location for items taken away in Mission 5, when placed in the surgery ward.
- Improvements to the "Play Music" menu in the legend cheat:
  - It actually plays the song you asked for, instead of a randomized one.
  - It now shows all the music choices available, including from Unreal and Unreal Tournament.
- Aim laser improvements (for camera modes other than first person):
  - Aim laser no longer shows up during conversations or cutscenes.
  - Aim laser now becomes a light blue color when holding a grenade and you are close enough to a surface to plant it.
  - Aim laser ignores death markers and continues through them.
- When in third-person camera mode, using spy drone will no longer force the camera back into your head.
- Removed purple line from the back of the UNATCO helmet.
- Activating Spy Drone while moving no longer keeps some momentum.
- Stalkers no longer count as innocents for the purposes of bingo.
- Temporary fix for Bobby crashes.
- Improved fallback positioning of Fixed Camera locations when there isn't a good wall location nearby.
</details>
