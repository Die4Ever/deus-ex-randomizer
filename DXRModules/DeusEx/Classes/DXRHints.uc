class DXRHints extends DXRBase transient;

var #var PlayerPawn  _player;

// if this hints array is too long, then no one will ever see the best hints
var string hints[100];
var string details[100];
var int numHints;

simulated function InitHints()
{
    local int mission;
    local string map;

    mission = dxr.dxInfo.missionNumber;
    map = dxr.localURL;
    if(mission < 1 || mission > 50) {
        return; // mission number is invalid
    }

    AddHint("Alcohol and medkits will heal your legs first", "if they are completely broken");
    AddHint("You can carry 5 fire extinguishers in 1 inventory slot.", "They are very useful for stealthily killing multiple enemies.");
    AddHint("Use everything at your disposal, like TNT crates.", "Randomizer makes this even more of a strategy/puzzle game.");
    AddHint("A vending machine can provide you with 20 health worth of food.", "Eat up!");
    AddHint("Pepper spray and fire extinguishers can incapacitate an enemy", "letting you sneak past them");
    AddHint("Ever tried to extinguish a fire with a toilet?", "How about a urinal or a shower?");
    AddHint("Items like ballistic armor and rebreathers now free up", "the inventory spaceimmediately when you equip them.");
    AddHint("Items like hazmat suits and thermoptic camo now free up", "the inventory space immediately when you equip them.");
    AddHint("The large metal crates are now destructible.", "They have 2000 hp.");
    AddHint("Hacking computers now uses 5 bioelectric energy per second.");
    AddHint("Make sure to read the descriptions for skills, augmentations, and items.", "Randomizer adds some extra info.");
    AddHint("Spy Drone aug has improved speed", "and the emp blast now also does explosive damage.");
    AddHint("The PS20 has been upgraded to the PS40", "and does significantly more damage.");
    AddHint("Flare darts now set enemies on fire for 3 seconds.");
    AddHint("Thowing knives deal more damage,", "and their speed and range increase with your low-tech skill.");
    AddHint("Read the pop-up text on doors to see how many", "hit from your equiped weapon to break it.");

    if(dxr.flags.settings.medbots > 0) {
        AddHint("Medbots are randomized.", "Don't expect to find them in the usual locations.");
    }
    else if(dxr.flags.settings.medbots == 0) {
        AddHint("Medbots are disabled.", "Good luck.");
    }
    if(dxr.flags.settings.repairbots > 0) {
        AddHint("Repair bots are randomized.", "Don't expect to find them in the usual locations.");
    }
    else if(dxr.flags.settings.repairbots == 0) {
        AddHint("Repair bots are disabled.", "Good luck.");
    }
    if(dxr.flags.crowdcontrol > 0) {
        AddHint("Viewers, you could've prevented this with Crowd Control.", "Or maybe you caused it.");
        AddHint("Don't forget you (the viewer!) can", "use Crowd Control to influence the game!");
    }
    
    if (dxr.flags.settings.goals > 0) {
        AddHint("Check the Deus Ex Randomizer wiki for information about randomized objective locations!");
    }
    
    if(mission <= 4) {
        AddHint("Melee attacks from behind do bonus damage!");
        AddHint("The flashlight (F12) no longer consumes energy when used.", "Go wild with it!");
        AddHint("The flashlight (F12) can be used to attract the attention of guards");
        AddHint("Don't hoard items.", "You'll find more!");
    }
    else if(mission <= 9) {
        AddHint("Don't hoard items.", "You'll find more!");
    }
    else if(mission <= 15) {
        AddHint("Try not dying.");
        AddHint("Don't hoard items.", "What are you saving them for?");
    }

    // ~= is case insensitive equality
    switch(dxr.dxInfo.missionNumber) {
        case 1:
            if(map ~= "01_NYC_UNATCOIsland") {
                if(dxr.flags.settings.passwordsrandomized > 0)
                    AddHint("Passwords have been randomized.", "Don't even try smashthestate!");
                if(dxr.flags.settings.goals > 0)
                    AddHint("The location of the terrorist commander is randomized.");
            }
            break;
        case 2:
            break;
        case 3:
            break;
        case 4:
            if (map ~= "04_NYC_NSFHQ") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("The location of the computer to open","the door on the roof is randomized.");
            }

            break;
        case 5:
            if (map ~= "05_NYC_UnatcoMJ12Lab") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("Pauls location in the lab is randomized.");
            } else if (map ~= "05_NYC_UnatcoHQ") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("Alex Jacobsons location in UNATCO HQ is randomized.");
            }

            break;
        case 6:
            if (map ~= "06_hongkong_mj12lab") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("The location of the computer with the ROM Encoding is randomized.");
            } else if (map ~= "06_HongKong_WanChai_Street") {
                AddHint("The Dragon Tooth Sword is randomized, but you need to","open the case in Maggie Chow's apartment to proceed");
            }
            break;
        case 8:
            break;
        case 9:
            if (map ~= "09_nyc_graveyard") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("The location of the signal jammer is randomized.");
            } else if (map ~= "09_nyc_shipbelow") {
                 if(dxr.flags.settings.goals > 0)
                    AddHint("The locations of the tri-hull weld points are randomized.");
           
            }

            break;
        case 10:
#ifdef injections
            if( dxr.FindModule(class'DXRBacktracking') != None ) {
                AddHint("Randomizer has enabled extra backtracking.", "You will be able to come back here later.");
            }
            AddHint("There's wine everywhere in Paris,", "it can be a decent source of health and energy.");
#else
            AddHint("There's wine everywhere in Paris,", "it can be a decent source of health.");
#endif
            break;
        case 11:
            if (map ~= "11_paris_cathedral") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("The location of Gunther and the computer is randomized.");
            }
#ifdef injections
            if( dxr.FindModule(class'DXRBacktracking') != None ) {
                AddHint("Randomizer has enabled extra backtracking.", "You will be able to go back to previous Paris levels.");
            }
            AddHint("There's wine everywhere in Paris,", "it can be a decent source of health and energy.");
#else
            AddHint("There's wine everywhere in Paris,", "it can be a decent source of health.");
#endif

            break;
        case 12:
            if (map ~= "12_vandenberg_cmd") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("The locations of the power generator keypads are randomized.");
            }
#ifdef injections
            if( dxr.FindModule(class'DXRBacktracking') != None ) {
                AddHint("Randomizer has enabled extra backtracking.", "You will be able to come back here later.");
            }
#else
            break;
        case 14:
            if (map ~= "14_oceanlab_silo") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("Howard Strong is now on a random floor of the missile silo.");
            }
#ifdef injections
            if( dxr.FindModule(class'DXRBacktracking') != None ) {
                AddHint("Randomizer has enabled extra backtracking.", "You will be able to go back to Vandenberg.");
            }
#endif

            break;
        case 15:
#ifdef injections
            if( dxr.FindModule(class'DXRBacktracking') != None ) {
                AddHint("Randomizer has enabled extra backtracking.", "You will be able to move more freely through Area 51.");
            }
#endif
            break;
    };
}

simulated function AddHint(string hint, optional string detail)
{
    hints[numHints] = hint;
    details[numHints] = detail;
    numHints++;
}

simulated function PlayerRespawn(#var PlayerPawn  player)
{
    Super.PlayerRespawn(player);
    _player = player;
    SetTimer(1, true);
}

simulated function PlayerAnyEntry(#var PlayerPawn  player)
{
    Super.PlayerAnyEntry(player);
    if(numHints==0) {
        InitHints();
    }
    _player = player;
    SetTimer(1, true);
}

simulated function int GetHint()
{
    // don't use the stable rng that we use for other things, needs to be different every time
    return Rand(numHints);
}

simulated function ShowHint(optional int recursion)
{
    local int hint;
    SetTimer(15, true);
    if( recursion > 10 ) {
        error("ShowHint reached max recursion " $ recursion);
        return;
    }
    hint = GetHint();

    if(class'DXRBigMessage'.static.CreateBigMessage(_player, self, hints[hint], details[hint]) == None)
        ShowHint(recursion++);
}

simulated function Timer()
{
    if(_player == None) {
        SetTimer(0, false);
        return;
    }
    if(_player.IsInState('Dying'))
        ShowHint();
}

function RunTests()
{
    local int i, ln;
    Super.RunTests();

    test(numHints <= arrayCount(hints), "numHints within bounds");

    for(i=0; i<numHints; i++) {
        ln = Len(hints[i]);
        test(ln < 100, "length " $ ln $ " of hint: "$hints[i]);

        ln = Len(details[i]);
        test(ln < 100, "length " $ ln $ " of hint detail: "$details[i]);
    }
}
