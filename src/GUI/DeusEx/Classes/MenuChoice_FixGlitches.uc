//=============================================================================
// MenuChoice_FixGlitches
//=============================================================================

class MenuChoice_FixGlitches extends DXRMenuUIChoiceBool;

/*
    This menu choice controls whether or not "standard" any% glitches are still allowed or not.

    PLEASE TRY TO ENSURE THIS IS UP TO DATE IF THINGS ARE FIXED OR BROKEN, ADDED, REMOVED, ETC


    Supported:

    - Item duplication
        - If you hit the "pick up item" key many times before the highlighted object is deleted from the world, you
          will pick up multiple copies of the item.  The main issue is being able to highlight and pick up items that
          are bDeleteMe
    - LAW Rocket through surface
        - The LAW rocket spawns slightly in front of the player (ComputeProjectileStart).  If you're against a thin enough
          surface (like a window), the projectile will spawn on the other side of the window.
    - Inventory item stacking
        - Close the inventory menu while "holding" an item (aka click and hold it to move it).  Items that are picked up
          will get placed behind it.
    - Only using one multitool or lockpick
        - Start hacking or lockpicking, then open a window.  The one tool or pick will continue to pick as long as the
          menu is open, allowing you to hack or pick any possible scenario with one tool or pick.
    - User.ini Saves and Loads
        - Directly bind aliases for saving and loading from a specific save slot ("SAVEGAME 1" and "LOADGAME 1").  These
          saves can be made at any time, including while dead, enabling the "Phoenix" and "Dead Man Walking" glitches.
    - Phoenix Glitch
        - Use a User.ini Save while dead.  Loading the game will leave you with negative health (enemies can still see you,
          and any damage will kill you).  This puts you in a position to enter Dead Man Walking.
    - Dead Man Walking
        - While in the Phoenix Glitch state, heal yourself (but not above negative health, so small heals are best).  Once
          healed, enemies will no longer be able to see you and you won't trigger lasers.  You will be able to drop items,
          but not pick them up again.



    To be supported:
    - Superjump
        - Enable speed aug, then go two layers deep in the menu and back out over and over (Settings > Game Options).
          Each time you leave the second layer of menu, the jump multiplier increases
        - Fixed by our new GetJumpZ function in the Player class, as well as an adjustment to RootWindow that catches
          the original aug reactivations.
    - Pressing the final switch at Area 51
        - Crouch in front of the button for the reactors and aim at the bottom edge of the cover to reach inside and
          press the button, ending the game.
        - Currently fixed in DXRFixupM15
    - Extra Skill Points from Pistol skill
        - On the new game screen (in vanilla or Zero Rando), the pistol skill starts at Trained, but can be downgraded, returning
          some skill points.  Starting the game downgraded to Untrained will give you those skill points but bump the skill back
          up to Trained for free.
        - Currently fixed in NerfPistolSkill.uc (class DXRSkillWeaponPistol)



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
    enumText(0)="Not Fixed"
    enumText(1)="Fixed"
}
