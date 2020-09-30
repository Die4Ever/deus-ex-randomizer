# Deus Ex Randomizer

Copy the `DeusEx.u` file into your `Deus Ex\System\` folder, which is probably `C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\System` (make a backup of the original `DeusEx.u`)

Recommended to use it with [Kentie's Deus Exe Launcher](http://www.kentie.net/article/dxguide/), or [Han's Launcher](https://coding.hanfling.de/launch/#binaries). I play with OpenGL renderer because the Direct3D renderers have trouble on newer Nvidia drivers.

The Deus Ex Speedup Fix mod allows you to disable the fps cap (the fps cap can cause stutters) https://steamcommunity.com/sharedfiles/filedetails/?id=2048525175 If you use that mod, then edit your `Documents\Deus Ex\System\DeusEx.ini` file and search for `FPSLimit=` and set it to 0 to manually remove the fps cap because I've noticed that Kentie's Launcher doesn't always do it correctly.

Currently in v1.4.4, DXRando randomizes
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
    * Horde Mode is in beta and mostly I think it just needs balancing.
    * Rearranged Levels is in alpha and is incomplete.
* making all or some of the doors that normally require a key also lockpickable and/or destructible
* making all keypads hackable.
* making enemies respawn
* reducing the drop rate for ammo, multitools, lockpicks, medkits, and bioelectric cells
* starting the game with the running speed augmentation
* autosave
* removing invisible walls

When you start a new game, you will see this settings screen
![options](https://i.imgur.com/02GEJUY.png)

For the randomized passwords, you can copy-paste from the Goals/Notes screen.

Check out the releases page here https://github.com/Die4Ever/deus-ex-randomizer/releases

Join the Randomizer Central Discord for discussion https://discord.gg/ybMj3vs or message me directly Die4Ever#6351

If you want to play with the `DXRando.ini` config file (in your `Documents\Deus Ex\System\` folder), then you can look at the [wiki for reference](https://github.com/Die4Ever/deus-ex-randomizer/wiki/DXRando.ini-config)
