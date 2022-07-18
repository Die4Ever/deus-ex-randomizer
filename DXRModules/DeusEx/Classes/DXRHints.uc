class DXRHints extends DXRBase transient;

var #var(PlayerPawn) _player;

// if this hints array is too long, then no one will ever see the best hints
var string hints[100];
var string details[100];
var int numHints;

simulated function InitHints()
{
    local DXRTelemetry telem;
    local int mission;
    local string map;

    numHints = 0;
    mission = dxr.dxInfo.missionNumber;
    map = dxr.localURL;
    if(mission < 0 || mission > 50) {
        return; // mission number is invalid
    }

    AddHint("Use everything at your disposal, like TNT crates.", "Randomizer makes this even more of a strategy/puzzle game.");
    AddHint("A vending machine can provide you with 20 health worth of food.", "Eat up!");
    AddHint("Pepper spray and fire extinguishers can incapacitate an enemy", "letting you sneak past them");
    AddHint("The large metal crates are now destructible.", "They have 2000 hp.");
    AddHint("Make sure to read the descriptions for skills, augs, and items.", "Randomizer adds some extra info.");
    AddHint("Each type of weapon gets randomized stats!", "Make sure to check one of each type.");

    telem = DXRTelemetry(dxr.FindModule(class'DXRTelemetry'));
    if(telem == None || telem.enabled == false || mission < 1)
        AddHint("Check out @DXRandoActivity on Twitter!","Make sure \"Online Features\" are enabled to show up yourself!");
    else
        AddHint("Check out @DXRandoActivity on Twitter!", "We just shared your death publicly, go retweet it!");

    if(#defined(injections)) {
        AddHint("Alcohol and medkits will heal your legs first", "if they are completely broken");
        AddHint("You can carry 5 fire extinguishers in 1 inventory slot.", "They are very useful for stealthily killing multiple enemies.");
        AddHint("Ever tried to extinguish a fire with a toilet?", "How about a urinal or a shower?");
        AddHint("Items like ballistic armor and rebreathers now free up", "the inventory space immediately when you equip them.");
        AddHint("Items like hazmat suits and thermoptic camo now free up", "the inventory space immediately when you equip them.");
        AddHint("Hacking computers now uses 5 bioelectric energy per second.");
        AddHint("Spy Drone aug has improved speed", "and the emp blast now also does explosive damage.");
        AddHint("The PS20 has been upgraded to the PS40", "and does significantly more damage.");
        AddHint("Flare darts now set enemies on fire for 3 seconds.");
        AddHint("Thowing knives deal more damage,", "and their speed and range increase with your low-tech skill.");
        AddHint("Read the pop-up text on doors to see how many", "hits from your equiped weapon to break it.");
        AddHint("Vision Enhancement Aug and Tech Goggles can now see through walls", "even at level 1, and they stack.");
        AddHint("Vision Enhancement Aug can see goal items through walls at level 2.", "Use it to see what's inside locked boxes.");
    }

    if(dxr.flags.gamemode == 1) {
        AddHint("Entrance Randomizer is enabled,", "check the wiki on our GitHub for help.");
    }

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

    if (dxr.flags.settings.medbotuses==1) {
        AddHint("Each medbot can heal you one time!","Use it wisely!");
    } else if (dxr.flags.settings.medbotuses>1 && dxr.flags.settings.medbotuses <30) {
        AddHint("Each medbot can heal you "$dxr.flags.settings.medbotuses$" times!","Use them wisely!");
    }

    if (dxr.flags.settings.repairbotuses == 1) {
        AddHint("Each repair bot can recharge you one time!","Use it wisely!");
    } else if (dxr.flags.settings.repairbotuses>1 && dxr.flags.settings.repairbotuses <30){
        AddHint("Each repair bot can recharge you "$dxr.flags.settings.repairbotuses$" times!","Use them wisely!");
    }

    if (dxr.flags.settings.medbotcooldowns == 1) { //Individual
        AddHint("Medbots have a randomized cooldown.", "Each one is different, so pay attention!");
    } else if (dxr.flags.settings.medbotcooldowns == 2) { //Global
        AddHint("Medbots have a randomized cooldown", "The cooldown is the same for all of them!");
    }

    if (dxr.flags.settings.repairbotcooldowns == 1) { //Individual
        AddHint("Repair bots have a randomized cooldown.", "Each one is different, so pay attention!");
    } else if (dxr.flags.settings.repairbotcooldowns == 2) { //Global
        AddHint("Repair bots have a randomized cooldown", "The cooldown is the same for all of them!");
    }

    if (dxr.flags.settings.medbotamount == 1) { //Individual
        AddHint("Medbots have a randomized heal amount.", "Each one is different, so pay attention!");
    } else if (dxr.flags.settings.medbotamount == 2) { //Global
        AddHint("Medbots have a randomized heal amount", "The amount is the same for all of them!");
    }

    if (dxr.flags.settings.repairbotamount == 1) { //Individual
        AddHint("Repair bots have a randomized recharge amount.", "Each one is different, so pay attention!");
    } else if (dxr.flags.settings.repairbotamount == 2) { //Global
        AddHint("Repair bots have a randomized recharge amount", "The amount is the same for all of them!");
    }

    if(dxr.flags.crowdcontrol > 0) {
        AddHint("Viewers, you could've prevented this with Crowd Control.", "Or maybe you caused it.");
        AddHint("Don't forget you (the viewer!) can", "use Crowd Control to influence the game!");
    }

    if (dxr.flags.settings.goals > 0) {
        AddHint("Check the Deus Ex Randomizer wiki", "for information about randomized objective locations!");
    }

    if( dxr.flags.settings.skills_reroll_missions == 1 ) {
        AddHint("Skill costs reroll every mission.", "Check them often, especially the BANNED skills.");
    } else if( dxr.flags.settings.skills_reroll_missions > 0 ) {
        AddHint("Skill costs reroll every "$ dxr.flags.settings.skills_reroll_missions $" missions.", "You're currently in mission "$mission$".");
    }

    if(mission <= 4) {
        if(#defined(injections))
            AddHint("The flashlight (F12) no longer consumes energy when used.", "Go wild with it!");
        AddHint("Melee attacks from behind do bonus damage!");
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
            if(map ~= "10_Paris_Catacombs") {
                AddHint("If you need a Hazmat suit", "Le Merchant has one for sale.");
                AddHint("You can kill Le Merchant and loot him", "if you don't have enough money.");
            }
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
#endif
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

simulated function PlayerAnyEntry(#var(PlayerPawn) player)
{
    local int i;
    local string msg;

    Super.PlayerAnyEntry(player);
    _player = player;
    InitHints();

    if(dxr.localURL ~= "00_Training") {
        for(i=0;i<numHints;i++) {
            msg = hints[i];
            if(Len(details[i]) > 0) {
                msg = msg $ "|n" $ details[i];
            }
            player.AddNote(msg, false, i==numHints-1);
        }
        player.ClientMessage("Press G or F2 to check your Goals/Notes screen!");
    }
}

simulated function int GetHint()
{
    // don't use the stable rng that we use for other things, needs to be different every time
    return Rand(numHints);
}

simulated function ShowHint(optional int recursion)
{
    local int hint;
    local string deathcounter;
#ifdef hx
    // for hx, the DXRBigMessage is bugged, so just disable the timer and PlayerRespawn will enable it again
    SetTimer(0, false);
    return;
#endif

    SetTimer(15, true);
    if( recursion > 10 ) {
        err("ShowHint reached max recursion " $ recursion);
        return;
    }
    hint = GetHint();

    deathcounter = "Deaths: "$class'DXRStats'.static.GetDataStorageStat(dxr, 'DXRStats_deaths');
    if(class'DXRBigMessage'.static.CreateBigMessage(_player, self, hints[hint], details[hint], deathcounter) == None)
        ShowHint(recursion++);
}

simulated function Timer()
{
    if(_player == None) {
        SetTimer(0, false);
        return;
    }
    if(class'DXRBigMessage'.static.GetCurrentBigMessage(_player) != None) {
        ShowHint();
    }
    else {
        SetTimer(0, false);
    }
}

static function AddDeath(DXRando dxr, #var(PlayerPawn) player)
{
    local DXRHints hints;
    hints = DXRHints(dxr.FindModule(class'DXRHints'));
    if(hints != None) {
        hints._player = player;
        hints.ShowHint();
    }
}

function RunTests()
{
    local int i, ln;
    Super.RunTests();

    test(numHints <= arrayCount(hints), "numHints within bounds");

    for(i=0; i<numHints; i++) {
        ln = Len(hints[i]);
        test(ln < 70, "length " $ ln $ " of hint: "$hints[i]);

        ln = Len(details[i]);
        test(ln < 70, "length " $ ln $ " of hint detail: "$details[i]);
    }
}
