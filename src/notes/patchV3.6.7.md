## Major Changes

- Added our new 2nd dumbest game mode
- In WaltonWare, Jock will now also appear at Battery Park in Mission 3 after dealing with Lebedev, in addition to the original location in the Airfield.
- The sewer exit leaving the inside of the Mission 9 dry dock now has a keypad instead of a button in modes outside of Entrance Randomizer.  The keypad uses Jenny's number, so the code can be found in the dockyards.

## Minor Changes

<details>
<summary>Click to expand Minor Changes</summary>

- Goals that require the use of drugs or alcohol will no longer be available when those items are banned (eg. in the Straight Edge loadout)
- Tweaked weapon placements for different FoVs and ultra-widescreen
- Alarm lights now count for the "Light Vandalism" bingo goal, if they are breakable
- Fixed mirrored rotation of Limited/Fixed Saves ATM that was added to the gas station, and moved it forwards slightly to get away from some bad collision detection
- Fixed possible crashes with flag names generated for Merchant conversations that exceeded the maximum length.
  - If you have already encountered the Merchant in a map in an in-progress game when you upgrade, he may be a bit confused about what he has available to sell to you.
- Block certain out-of-bounds locations from being selected for random placement of things (like medbots/repairbots, merchants, turrets, datacubes, etc...)
  - Outside of the walls of the UNATCO compound in missions 3, 4, and 5
  - Beyond the level transitions between the Wan Chai Market and the Lucky Money
  - Beyond the door to the Vandenberg Computer area from Cmd
- Removed collision from teleporters so they don't block pawns or items
- The Bingo Viewer now has an option to always keep the window on top (Under the Display menu)
- Looking at Weeping Anna will no longer interrupt her death animation
- For GMDX we now set Hardcore mode when playing on combatDifficulty 4 or higher
- Fixed randomizing some of GMDX's invisible objects
- Fixed bug with conversations referencing player's kill counts in M01 and M02
- Added a timed race to Vandenberg Tunnels (in both the forward and backward directions):  See how fast you can go!
- UNATCO Troopers that appear in Mission 3, after meeting Lebedev, will no longer hate seeing carcasses (which typically makes them hate the player)
- The bingo goal for returning to UNATCO HQ in the boat after Mission 2 no longer appears unless the bingo board spans more than 1 mission.
- Possible fix for some timed races (eg. Catacombs or Reverse Catacombs) where the Mastodon messages were reporting the player losing over 9000% health.
- Fixed installer failing with Documents path issues
- The key for the cabinet in the Mission 2 Free Clinic is now adjusted more reliably and should now work properly in Vanilla? Madder!
- Add two new bingo goals for interacting with Joe Greene in Mission 2 and 4.
- The description for the Energy Shield augmentation now mentions that it works against explosive damage as well.  This is vanilla behaviour, so just makes the description more accurate to its functionality.
- Fix the carcass in the collapsed Canal Road tunnel (under Canals) so that it doesn't lose the aug upgrade can when the biocell he is also holding gets removed by DXRReduceItems.
- Killing Anna Navarre without using her killswitch will now fail the bingo goal to kill her with her killswitch.
- Jack O Lanterns no longer support any significant weight, collapsing if heavy things are on top of them (like trash bags).
- Added a copy of the UNATCO Closet Key to UNATCO HQ in mission 5.
- Skill points originally associated with finding Paul and your equipment in mission 5 now get moved along with Paul and your equipment when Goals Rando is enabled.
- Bingo goal for entering the gas station ceiling no longer requires going to the center of the ceiling (It will trigger as soon as you enter, regardless of which entrance is used)
- Bingo goal trigger points for visiting the ends of the cranes on the superfreighter adjusted to be a bit more clear.  Also adjusted the skill point and infolink triggers present on one of the cranes to match the location of the bingo goal trigger.
- Added a button to the top of the dumbwaiter shaft in the DuClare chateau, in case you end up on top of the dumbwaiter while it's moving to the top.  This one's for you, Krickraken.
- Switching to "Vanilla" gameplay style in Revision is now blocked, because Randomizer is not compatible with this mode.  "Normal" (Standard Revision gameplay), "Shifter", "Biomod", and "Human Revolution" gameplay styles are still available.
- It is once again possible to exit or skip the credits with the Escape button.
</details>
