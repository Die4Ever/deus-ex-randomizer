# Deus Ex Randomizer

### Currently in v1.4.7, DXRando randomizes
* adding and changing characters, giving them random names and making some of them dance
* changing the locations of items/boxes/NanoKeys around the map
* passwords and passcodes (they get updated in your Goals/Notes screen)
* the locations of datacubes
* exp costs for skills
    * option for rerolling every mission
    * option for disabling the Downgrade button on the new game screen, to prevent looking ahead
* what augmentations are in each canister

There are also settings for
* new game modes!
    * Stick With the Prod means the only weapon you get is the stun prod (hint: throw a crate straight up into the air to break it)
        * Stick With the Prod Plus also allows EMP grenades, gas grenades, scramble grenades, pepper gun, and tranq darts
    * Horde Mode is in beta and mostly I think it just needs balancing.
    * Rearranged Levels is in alpha and is incomplete.
* making all or some of the doors that normally require a key also lockpickable and/or destructible
* making all keypads hackable.
* making enemies respawn
* reducing the drop rate for ammo, multitools, lockpicks, medkits, and bioelectric cells
* starting the game with the running speed augmentation
* autosave
* removing invisible walls

#### When you click New Game, you will see this settings screen:
![options](https://i.imgur.com/XYOCRo3.png)

#### If you click Next then it will use default settings based on your difficulty choice. But if you click Advanced then you will see these settings:
![advanced options](https://i.imgur.com/cNxR0UX.png)

For the randomized passwords, you can copy-paste from the Goals/Notes screen.

I've also made some balance tweaks. Hacking computers now uses bioelectric energy. The healing aug gives less health. Level 1 of the speed aug has been buffed, but max level remains the same. Dragon's Tooth Sword now does much less damage, but if you aim for the head you can still kill most enemies in 1 hit. Spy Drone aug has improved speed and the emp blast now also does explosive damage. Fire extinguishers now stack in your inventory. Also the PS20 has been upgraded to the PS40 and does significantly more damage.

### Installation Instructions

Download the `DeusEx.u` file from the releases page here https://github.com/Die4Ever/deus-ex-randomizer/releases

Then copy the `DeusEx.u` file into your `Deus Ex\System\` folder, which is probably `C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\System` (make a backup of the original `DeusEx.u`)

Recommended to use it with [Kentie's Deus Exe Launcher](http://www.kentie.net/article/dxguide/), or [Han's Launcher](https://coding.hanfling.de/launch/#binaries). Play with OpenGL renderer because the Direct3D renderers have trouble on newer Nvidia drivers unless you use the Deus Ex Speedup Fix mod. The Deus Ex Speedup Fix mod allows you to disable the fps cap (the fps cap in the game can cause stutters, but capping frame rate in nvidia control panel works perfectly) https://steamcommunity.com/sharedfiles/filedetails/?id=2048525175 If you use that mod, then edit your `Documents\Deus Ex\System\DeusEx.ini` file and search for `FPSLimit=` and set it to 0 to manually remove the fps cap because I've noticed that Kentie's Launcher doesn't always do it correctly.

Join the Randomizer Central Discord for discussion https://discord.gg/ybMj3vs or message me directly Die4Ever#6351

If you want to play with the `DXRando.ini` config file (in your `Documents\Deus Ex\System\` folder), then you can look at the [wiki for reference](https://github.com/Die4Ever/deus-ex-randomizer/wiki/DXRando.ini-config)
