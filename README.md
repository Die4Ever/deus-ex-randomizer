# Deus Ex Randomizer

This is a mod for the original Deus Ex that takes everything and shuffles it all around to make it like a new game every time but with the same great story. The goal is to increase the replayability and strategy.

### If the game is not running well, even for vanilla Deus Ex, see the recommended tweaks below.

## Installation Instructions
<details>
<summary>Click to expand Installation Instructions...</summary>

Download the `DeusEx.u` file from the releases page here https://github.com/Die4Ever/deus-ex-randomizer/releases

Then copy the `DeusEx.u` file into your `Deus Ex\System\` folder, which is probably `C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\System` (make a backup of the original `DeusEx.u`).
</details>

## Installation Instructions for Lay D Denton
<details>
<summary>Click to expand Lay D Denton Installation Instructions...</summary>

[Download Lay D Denton version 1.1 or newer from here](https://www.moddb.com/mods/the-lay-d-denton-project/downloads)

Install Lay D Denton by copying all the files into your Deus Ex folder.

Download Deus Ex Randomizers's `DeusEx.u` file from the releases page here https://github.com/Die4Ever/deus-ex-randomizer/releases

Then copy Deus Ex Randomizers's `DeusEx.u` file into your `Deus Ex\System\` folder, which is probably `C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\System`. This will overwrite the `DeusEx.u` file from Lay D Denton.
</details>

## Installation Instructions for GMDX
<details>
<summary>Click to expand GMDX Installation Instructions...</summary>

Install GMDX from https://www.moddb.com/mods/gmdx/downloads/gmdxv90-release

Or v10 https://www.moddb.com/mods/gmdx-v10-community-update/downloads/gmdxv10-092020-update

Or RSD https://www.moddb.com/mods/gmdx/addons/version-rsd-beta-10-future-official-update

Download `GMDXRandomizer.u` from the releases page here https://github.com/Die4Ever/deus-ex-randomizer/releases

Copy `GMDXRandomizer.u` into the game's `System` folder, which is probably `C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\System`

Edit the `GMDX.ini` file which is probably in `%UserProfile%\Documents\Deus Ex\GMDXv9\System` or `%UserProfile%\Documents\Deus Ex\GMDXvRSD\System`, or `GMDXv10.ini` which is probably in `C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\System`

In the `[Engine.Engine]` section, change `DefaultGame` from `DefaultGame=DeusEx.DeusExGameInfo` to `DefaultGame=GMDXRandomizer.DXRandoGameInfo` and change `Root` from `Root=DeusEx.DeusExRootWindow` to `Root=GMDXRandomizer.DXRandoRootWindow`

GMDX Randomizer is in early alpha testing and does not support all of the features that the vanilla randomizer has.
</details>

## Installation Instructions for Revision
<details>
<summary>Click to expand Revision Installation Instructions...</summary>

Install Revision [from Steam](https://store.steampowered.com/app/397550/Deus_Ex_Revision/) or [their ModDB page](https://www.moddb.com/mods/deus-ex-revision/downloads/deus-ex-revision)

Download `RevRandomizer.u` from the releases page here https://github.com/Die4Ever/deus-ex-randomizer/releases

Copy `RevRandomizer.u` into the game's `Revision\System` folder, which is probably `C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\Revision\System`

Edit the `Revision.ini` file which is probably in `C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\Revision\System`

In the `[Engine.Engine]` section, change `DefaultGame` from `DefaultGame=Revision.RevGameInfo` to `DefaultGame=RevRandomizer.DXRandoGameInfo` and change `Root` from `Root=Revision.RevRootWindow` to `Root=RevRandomizer.DXRandoRootWindow`

Revision Randomizer is in early alpha testing and does not support all of the features that the vanilla randomizer has.
</details>

## Installation Instructions for Vanilla? Madder.
<details>
<summary>Click to expand Vanilla? Madder. Installation Instructions...</summary>

Install VMD Phase 1.5 (v1.56) from https://www.moddb.com/mods/vanilla-madder-actual-phase-1/downloads/vmd-phase-15-installer-v156

Download `VMDRandomizer.u` from the releases page here https://github.com/Die4Ever/deus-ex-randomizer/releases

Copy `VMDRandomizer.u` into the game's `System` folder, which is probably `C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\System`

Edit the `VMDSim.ini` file which is probably in `C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\System`

In the `[Engine.Engine]` section, change `DefaultGame` from `DefaultGame=DeusEx.DeusExGameInfo` to `DefaultGame=VMDRandomizer.DXRandoGameInfo` and change `Root` from `Root=DeusEx.DeusExRootWindow` to `Root=VMDRandomizer.DXRandoRootWindow`

VMD Randomizer is in early alpha testing and does not support all of the features that the vanilla randomizer has.
</details>

## Installation Instructions for HX (Co-op)
<details>
<summary>Click to expand HX Installation Instructions...</summary>

Make sure to use the DeusEx.u file from the original game for co-op.

First download and install HX-0.9.89.4.zip from https://builds.hx.hanfling.de/testing/

Then copy `HXRandomizer.u` and `HXRandomizer.int` into the `System` directory of the game.

HXRandomizer is in early alpha testing and does not support all of the features that the single player vanilla randomizer has.

#### Co-op Teaser

[![Co-op Teaser](https://img.youtube.com/vi/YwgKlt5N70A/0.jpg)](https://www.youtube.com/watch?v=YwgKlt5N70A)

</details>

## v2.0 Trailer

<a href="https://youtu.be/XsoIKbn_suE" target="_blank">
<img src="https://i.imgur.com/Rssbzpl.jpg" alt="v2.0 Trailer" height="300"/></a>

## DXRando randomizes
* locations of goals, NPCs, and some starting locations
* medbots and repair bots (with hint datacubes near them)
* adding and moving turrets, cameras, security computers, and datacubes for them
* starting equipment, bioelectric energy, and credits
* moving enemies around, adding and changing enemies/characters, giving them random names and making some of them dance
* changing the locations of items/boxes/NanoKeys/datacubes around the map
* passwords and passcodes
* exp costs for skills
    * option for rerolling every mission
    * option for disabling the Downgrade button on the new game screen, to prevent looking ahead
* what augmentations are in each canister
* the strength and lockpick strength for doors
* the hack strength for keypads
* the strength of augmentations and skills (make sure to read their descriptions)
* the damage and firing speed of weapon types (make sure to read the description for one of each type)
* JC's and Paul's clothes
* randomly adds "The Merchant"

## There are also settings for
* Crowd Control! Let your viewers troll you or help you! NOW PLAYABLE! https://crowdcontrol.live/guides/DeusEx
    * If you want to try some of the Crowd Control features without actually streaming, you can try the "OfflineCrowdControl.py" script to randomly send Crowd Control messages to your local game!  Requires Python 3.8 or above
* New Game+ - after beating the game play it again keeping your items, skills, and augs, but with increased difficulty and a new seed
    * takes away 1 random augmentation, and 1 of your weapons
    * takes away half your skill points and 5 random skill levels, so the player has to choose which ones to level up first
* new game modes!
    * Entrance Randomization - changes what level each teleporter takes you to, but keeps it within the same mission.
    * Horde Mode - fight for your life to see how long you can survive in the Paris Cathedral.
* challenge mode loadouts!
    * Stick With the Prod Pure means the only weapon you get is the stun prod (hint: throw a crate straight up into the air to break it)
        * Stick With the Prod Plus also allows EMP grenades, gas grenades, scramble grenades, pepper gun, and tranq darts
    * Ninja JC - the only weapons allowed are throwing knives, swords, pepper spray, and grenades. You also get a Ninja Augmentation which gives you speed and stealth at the same time
    * Don't Give Me the GEP Gun - bans the GEP gun
    * Freeman Mode - only weapon allowed is the crowbar
    * Grenades Only
    * No Pistols - for people who think the pistol is OP
* Max Rando - randomize the randomizer's settings!
* An integrated Bingo board (on the Goals screen there's a Bingo button in the top right)
* Co-op when combined with the HX mod (Alpha)
* making all or some of the doors that normally require a key also lockpickable and/or destructible
* making all or some keypads hackable.
* reducing the drop rate for ammo, multitools, lockpicks, medkits, and bioelectric cells
* autosave
* making enemies respawn
* starting the game with the running speed augmentation
* optional hardcore Autosave-Only mode, no save-scumming allowed!
* autofill passwords options
* [Death Markers](https://github.com/Die4Ever/deus-ex-randomizer/wiki/Death-Markers) - see where other players have died!

## New Game Menus

<details>
<summary>When you click New Game, you will see this settings screen:</summary>

![options](https://i.imgur.com/tMdOLY1.jpg)

</details>

If you click Next then it will use default settings based on your difficulty choice.

<details>
<summary>But if you click Advanced then you will see these settings:</summary>

![advanced options](https://i.imgur.com/kxJyToG.jpg)

</details>

## Balance Chances

DXRando features many small but impactful balance changes that can expand your tactical options.

The large metal crates are now destructible with 2000hp. Alcohol now fixes dead legs. Things that normally aren't useful have been buffed, such as hazmat suits, ballistic armor, environmental skill, and the spy drone augmentation. And more balance changes to maximize variety for many replays!

[See the full list of balance changes here in the wiki so you may be better able to adapt to the unique challenges DXRando generates.](https://github.com/Die4Ever/deus-ex-randomizer/wiki/Balance-Changes)

## Recommended tweaks for running Deus Ex on modern computers
<details>
<summary>Click to expand performance fixes...</summary>

Recommended to use it with [Kentie's Deus Exe Launcher](http://www.kentie.net/article/dxguide/), or [Han's Launcher](https://coding.hanfling.de/launch/#binaries). Play with OpenGL renderer because the Direct3D renderers have trouble on newer Nvidia drivers unless you use the [Deus Ex Speedup Fix mod. The Deus Ex Speedup Fix mod (download at the bottom of linked page)](https://steamcommunity.com/sharedfiles/filedetails/?id=2048525175) allows you to disable the fps cap (the fps cap in the game can cause stutters, but capping frame rate in nvidia control panel works perfectly) If you use that mod, then edit your `Documents\Deus Ex\System\DeusEx.ini` file and search for `FPSLimit=` and set it to 0 to manually remove the fps cap because I've noticed that Kentie's Launcher doesn't always do it correctly, and also disable vsync with your graphics driver. If you use the speedup fix then you'll probably want to use the [Direct3D 10](https://kentie.net/article/d3d10drv/) or [Direct3D 11](https://kentie.net/article/d3d11drv/index.htm) renderer. I use my graphics driver to enforce a 120fps limit with Direct3D 10.

</details>

---

Join the [discord channel for discussion](https://discord.gg/daQVyAp2ds) or [follow my Twitter @Die4EverDM](https://twitter.com/Die4EverDM).

If you want to play with the `DXRando.ini` config file (in your `Documents\Deus Ex\System\` folder), then you can look at the [wiki for reference](https://github.com/Die4Ever/deus-ex-randomizer/wiki/DXRando.ini-config)
