//=============================================================================
// MenuChoice_FixGlitches
//=============================================================================

class MenuChoice_FixGlitches extends DXRMenuUIChoiceBool;

/*
    This menu choice controls whether or not "standard" any% glitches are still allowed or not.

    PLEASE TRY TO ENSURE THIS IS UP TO DATE IF THINGS ARE FIXED OR BROKEN, ADDED, REMOVED, ETC


    Supported:

    - Item duplication (GLITCHFIX-01)
        - If you hit the "pick up item" key many times before the highlighted object is deleted from the world, you
          will pick up multiple copies of the item.  The main issue is being able to highlight and pick up items that
          are bDeleteMe
    - LAW Rocket through surface (GLITCHFIX-02)
        - The LAW rocket spawns slightly in front of the player (ComputeProjectileStart).  If you're against a thin enough
          surface (like a window), the projectile will spawn on the other side of the window.
    - Inventory item stacking (GLITCHFIX-03)
        - Close the inventory menu while "holding" an item (aka click and hold it to move it).  Items that are picked up
          will get placed behind it.
    - Only using one multitool or lockpick (GLITCHFIX-04)
        - Start hacking or lockpicking, then open a window.  The one tool or pick will continue to pick as long as the
          menu is open, allowing you to hack or pick any possible scenario with one tool or pick.
    - User.ini Saves and Loads (GLITCHFIX-05)
        - Directly bind aliases for saving and loading from a specific save slot ("SAVEGAME 1" and "LOADGAME 1").  These
          saves can be made at any time, including while dead, enabling the "Phoenix" and "Dead Man Walking" glitches.
    - Phoenix Glitch (GLITCHFIX-06)
        - Use a User.ini Save while dead.  Loading the game will leave you with negative health (enemies can still see you,
          and any damage will kill you).  This puts you in a position to enter Dead Man Walking.
    - Dead Man Walking (GLITCHFIX-07)
        - While in the Phoenix Glitch state, heal yourself (but not above negative health, so small heals are best).  Once
          healed, enemies will no longer be able to see you and you won't trigger lasers.  You will be able to drop items,
          but not pick them up again.
    - Extra Skill Points from Pistol skill (GLITCHFIX-08)
        - On the new game screen (in vanilla or Zero Rando), the pistol skill starts at Trained, but can be downgraded, returning
          some skill points.  Starting the game downgraded to Untrained will give you those skill points but bump the skill back
          up to Trained for free.
    - Pressing the final switch at Area 51 (GLITCHFIX-09)
        - Crouch in front of the button for the reactors and aim at the bottom edge of the cover to reach inside and
          press the button, ending the game.
        - This is kind of a very specific example of GLITCHFIX-15
    - Superjump (GLITCHFIX-10)
        - Enable speed aug, then go two layers deep in the menu and back out over and over (Settings > Game Options).
          Each time you leave the second layer of menu, the jump multiplier increases
        - Fixed by our new GetJumpZ function in the Player class, as well as an adjustment to RootWindow that catches
          the original aug reactivations.
    - Enter the hangar from outside the bridge (GLITCHFIX-11)
        - The radius of the teleporter inside the bridge from M03 Airfield into the Hangar extends outside of the bridge between
          the barracks and the hangar itself, so you could jump into it from the outside with a superjump
    - Skip through lasers by quicksaving while moving (GLITCHFIX-12)
        - Run towards a laser tripwire, then do a quicksave while right next to the laser.  Keep holding forwards, and when the
          save finishes, you will appear forward on the other side of the laser (without having triggered it)
    - Spook Lloyd through the UNATCO HQ front door with a gas grenade (GLITCHFIX-13)
        - Throwing a gas grenade into a corner near the front door of UNATCO HQ in Mission 1 will cause gas to be spawned inside
          near Lloyd, who will then run to the (locked) door and open it from the inside.
    - Reuse one-time weapons like the LAW (GLITCHFIX-14)
        - If you fire a LAW, then exit the map before the LAW has been put away, you will keep the LAW on the other side of the
          level transition.  This is used to spam LAW rockets down the length of the 747, dodging in and out of the front door
          of the plane.
        - A feature where we remove in-flight projectiles is also disabled when this glitch is allowed
    - Interacting with objects through narrow gaps (GLITCHFIX-15)
        - When aiming at objects to interact with, the trace from your eyes to the target is infinitely thin, so it can reach
          between the map geometry and movers.
        - This is a more general issue which includes GLITCHFIX-09
    - Shooting the MapExit in Vandenberg (GLITCHFIX-16)
        - MapExit's don't check *what* touches them when they have collision enabled and will always teleport the player when touched
          in those cases.  The MapExit near the helicopter location out front of Vandenberg Command has collision enabled, so it can
          be hit by any object, including projectiles or the *tracers* from instant hit weapons (like the assault rifle).



    Not Supported:

    - Glitchy Save
        - Description below taken from another document...
        - While in the last line of dialogue with a character hold the [ button (LeftBracket) to save the game and let go
          after you see the 'Saving' text. By loading this save you will reload any adjacent areas connected to the level,
          resetting them and allowing you to regain areas from it. Loading this glitchy save and re-entering the area it will
          created will softlock the game, make you invulnerable to any damage, will keep you stuck in the area you were in and
          not load any map exits and will considerably slow down your move speed. While you are in this state you are trapped in
          the area and starting a new game and entering that area will also trap you. If this happens you will need to restart
          your game to be able to make a new one without this happening.
        - Glitchy save breaks the mission script, so basically just ruins all the rando.  Fundamentally incompatible.
    - Keep All Items in M05 Jail
        - Use the glitchy save to stop item removal or go to the inventory on the first frame of the map and drop all your items
          on the floor to prevent them from being taken
        - Using the Glitchy Save breaks things (see above), so not supported
        - Use the "Prison Pocket" : "Augmented" option under the advanced settings to keep all items automatically instead.



*/

defaultproperties
{
    enabled=True
    defaultvalue=True
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Fix glitches used for speedruns."
    actionText="Glitches For Speedruns"
    enumText(0)="Allowed"
    enumText(1)="Fixed"
}
