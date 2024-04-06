// Thanks to WCCC https://www.moddb.com/members/wccc/downloads

//1. Intro
//==========================
Howdy gang. WCCC here.
I threw some stuff together in the past day's work, making some stuff for VMD Phase 2.
Figured the community might like a controller-friendly aug option, so I'm making my tree open source.
I have a couple of tiny cheats in here, but I made sure to do this by the books for the most part.

//2. Methodology
//==========================
Anyways, here how it's meant to be used:
-Add (and if necessary, rename) OAT .uc files to your classes folder. Add .pcx textures to your textures folder, as well.
 +If necessary, move the imports actor and textures to an "Assets only" package.
  As long as the asset package is in your edit packages, it should still load fine on UI elements with how I reference them in the code.
-Decide if you want to use a player method or mutator method. Neither are meant to be taken as gospel how they're presented.
Here's some pros and cons:
 1. Player method
  Pros:
   +Can be integrated into an existing mod (that has its own player) by merely copying the executable function
   +If you include a reference to it in your customize keys menu, it can be easier to set up for players than a mutator
  Cons:
   -Highly recommended you have a customize keys menu specific for your mod. This means a custom main menu in most cases
   -Not using one makes rebinding the key a real pain to do for the lay player
   -If you don't have a player class already, installing one can make your implementation mod-unfriendly
 2. Mutator method
  Pros:
   +More mod friendly than installing a custom player class (when you wouldn't have one already)
   +Can be done AS a parallel mod to an existing experience with minimal invasiveness
  Cons:
   -Requires player to make a custom keybind to access the menu in a convenient fashion
   -Installing a mutator in singleplayer can be more or less work, depending on which experience you're injecting into.
    *For more on this, see the GameInfo example, as this was found to make the process easier.

-If you use the player method, you don't need to change anything. If you use the MUTATOR method, however, you will need
to change AliasNames(7) in the default properties of OATMenuAugSelector to be whatever command you use to open menu.
For instance, this could be "Mutate OATWindow".
Also, it is highly recommended that you use the game info class, with the custom game info example included.
If doing this, make sure to change GameInfo=OpenAugTree130.OATGameInfo
If you rename the exec function for your player, you'll ALSO need to do this. This is used for closing the menu easily.

In either case, this is perhaps best implemented by having a custom player for an existing
mod (a vanilla overhaul, for instance), drop in the executable, then update what SHOULD be
a pre-existing main menu arrangement. This is my ideal.

//3. Closing
//==========================
Hopefully, whoever reading this has some modding experience already, because this
DOES require some prior experience. If not, good luck to you. Maybe poke around
the DXCHQ discord for help with modding.

Check it out at: https://discord.gg/jCFJ3A6

//4. Change Log
//==========================
1.1:
++++++
-Now began reading buttons dynamically, as was suggested by a user. This allows for joystick support and all sorts of weird binds
-Added a noise for closing the menu
-Now, pushing the menu open button 2nd time will close it quickly.

1.2:
++++++
-Fixed one last remaining instance where closing the menu would not make a UI sound to give feedback.

1.3:
++++++
-Fixed not being able to read "mutate" commands when building key binds.
-Last aug page used is now remembered with either method, although it travels better on the player for long term memory.
-Added game info example courtesy of DefaultPlayer001's exploration of the topic.

1.4:
++++++
-As suggested, by DefaultPlayer001, the exact aug you had last selected in the window is now remembered as well.
-Fixed mutate commands still not actually being read.
-Fixed aliases detected being case sensitive... Related.
