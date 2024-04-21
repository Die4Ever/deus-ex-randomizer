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

    telem = DXRTelemetry(dxr.FindModule(class'DXRTelemetry'));
    if(telem == None || telem.enabled == false || mission < 1)
        AddHint("Check out https://botsin.space/@DXRandoActivity!","Make sure \"Online Features\" are enabled to show up yourself!");
    else
        AddHint("Check out https://botsin.space/@DXRandoActivity!", "We just shared your death publicly, go retweet it!");

    if(dxr.flags.crowdcontrol > 0) {
        AddHint("Viewers, you could've prevented this with Crowd Control.", "Or maybe you caused it.");
        AddHint("Don't forget you (the viewer!) can", "use Crowd Control to influence the game!");
    }

    if (dxr.flags.settings.goals > 0) {
        AddHint("Check the Deus Ex Randomizer wiki", "for information about randomized objective locations and more!");
    }

    if( dxr.flags.settings.skills_reroll_missions == 1 ) {
        AddHint("Skill costs reroll every mission.", "Check them often, especially the BANNED skills.");
    } else if( dxr.flags.settings.skills_reroll_missions > 0 ) {
        AddHint("Skill costs reroll every "$ dxr.flags.settings.skills_reroll_missions $" missions.", "You're currently in mission "$mission$".");
    }

    AddHint("Attaching a LAM or Gas Grenade to a wall can be very strong!", "Also try to lure enemies into them.");
    AddHint("You don't trigger your own grenades.", "Setup traps without fear.");
    AddHint("Use sabot shotgun rounds to kill the little spider bots.");
    AddHint("Grab a plasma rifle, blast everything in sight,", "then go get your items back.");
    if(dxr.flags.settings.energy != 100) {
        AddHint("Your max energy is "$dxr.flags.settings.energy$" points.", "Your energy meter shows percent relative to this value.");
    }
    if(#defined(injections)) {
        AddHint("Grays have strong resistance to fire and plasma,", "but it will eventually kill them!");
        AddHint("Weapon animation speeds now improve with skills,", "especially grenades with Demolition skill.");
        AddHint("Grenades can now be attached to the floor", "or even on a door!");
        AddHint("Attaching a grenade to a wall increases its", "blast radius and damage, especially with high skill.");
        AddHint("You can safely save during infolinks!", "Give it a shot, Tong won't mind!");
        AddHint("Red lasers will always set off an alarm", "Blue lasers won't, but will trigger something else!");
        AddHint("Everything except an NPC will set off a laser!", "Better be careful around them!");
        AddHint("Enemies with gold visors are resistant to gas", "so you might need to deal with them differently!");
        AddHint("Enemies with helmets take less damage from headshots", "so you might need to be more careful!");
        if (class'MenuChoice_AutoWeaponMods'.default.enabled){
            AddHint("Picking up a weapon mod while holding a weapon", "will automatically apply it to that weapon!");
        }
    }

    if(mission <= 3) {
        if(dxr.flags.settings.enemiesrandomized > 0) {
            AddHint("Some NSF terrorists are visibly augmented.", "Watch out for their special capabilities!");
        }
    } else if(mission <= 4) {
        if(dxr.flags.settings.enemiesrandomized > 0) {
            AddHint("Some UNATCO troops are visibly augmented.", "They explode when they die, so watch out!");
        }
    } else {
        if(dxr.flags.settings.enemiesrandomized > 0) {
            AddHint("Some UNATCO and MJ12 troops are visibly augmented.", "They explode when they die, so watch out!");
        }
    }

    if(mission <= 5) {
        AddHint("Melee attacks from behind do bonus damage!");
        AddHint("Don't hoard items.", "You'll find more!");
        AddHint("Have you looked at your Bingo Board?", "Find it in the middle bar of your Goals/Notes screen.");

        AddHint("Use everything at your disposal, like TNT crates.", "Randomizer makes this even more of a strategy/puzzle game.");
        AddHint("A vending machine can provide you with 20 health worth of food.", "Eat up!");
        AddHint("Pepper spray and fire extinguishers can incapacitate an enemy", "letting you sneak past them.");
        AddHint("The medium and large metal crates are now destructible.", "They have 500 hp.");
        AddHint("Datacubes and nanokeys give off a glow.", "Keep your eyes open for it!");

        if(!dxr.flags.IsZeroRando())
            AddHint("Make sure to read the descriptions for skills, augs, and items.", "Randomizer adds some extra info.");
        if(dxr.flags.settings.min_weapon_dmg != dxr.flags.settings.max_weapon_dmg || dxr.flags.settings.min_weapon_shottime != dxr.flags.settings.max_weapon_shottime)
            AddHint("Each type of weapon gets randomized stats!", "Make sure to check one of each type.");

        if(#defined(injections) || #defined(vmd) || #defined(gmdx)) {
            AddHint("You can left click on items to use them without picking them up.", "Great for eating to recover health or putting on armor!");
        }

        if(#defined(injections)) {
            AddHint("The flashlight (F12) no longer consumes energy when used.", "Go wild with it!");
            AddHint("The flashlight (F12) can be used to attract the attention of guards.", "It doesn't cost any energy!");
            AddHint("Alcohol and medkits will heal your legs first", "if they are completely broken.");
            AddHint("You can carry 5 fire extinguishers in 1 inventory slot.", "They are very useful for stealthily killing multiple enemies.");
            AddHint("Ever tried to extinguish a fire with a toilet?", "How about a urinal or a shower?");
            AddHint("Items like ballistic armor and rebreathers now free up", "the inventory space immediately when you equip them.");
            AddHint("Items like hazmat suits and thermoptic camo now free up", "the inventory space immediately when you equip them.");
            AddHint("Try using a hazmat suit", "against plasma, fire, and gas attacks.");
            AddHint("Hacking computers now uses 5 bioelectric energy per second.");
            AddHint("Spy Drone aug has improved speed", "and it's easier to control.");
            AddHint("The PS20 has been upgraded to the PS40", "and does significantly more damage.");
            AddHint("Flare darts now set enemies on fire for 3 seconds.");
            AddHint("Thowing knives deal more damage,", "and their speed and range increase with your low-tech skill.");
            AddHint("Read the pop-up text on doors to see how many", "hits from your equiped weapon to break it.");
            AddHint("Vision Enhancement Aug and Tech Goggles can now see through walls", "even at level 1, and they stack.");
            AddHint("Vision Enhancement Aug can see goal items through walls at level 2.", "Use it to see what's inside locked boxes.");
        } else {
            AddHint("The flashlight (F12) can be used to attract the attention of guards.");
        }

        if(dxr.flags.IsEntranceRando()) {
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

        if(!#defined(vmd)) {
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
    }
    else if(mission <= 11) {
        AddHint("Don't hoard items.", "You'll find more!");
        if(!dxr.flags.IsZeroRando())
            AddHint("Make sure to read the descriptions for skills, augs, and items.", "Randomizer adds some extra info.");
        if(#defined(injections)) {
            AddHint("Vision Enhancement Aug and Tech Goggles can now see through walls", "even at level 1, and they stack.");
            AddHint("Vision Enhancement Aug can see goal items through walls at level 2.", "Use it to see what's inside locked boxes.");
            AddHint("You can left click on items to use them without picking them up.", "Great for eating to recover health or putting on armor!");
        }
    }
    else if(mission <= 14) {
        // maybe you should be hoarding items here until Area 51 lol
        AddHint("Now might actually be a good time to hoard items.", "You might need them for the end.");
    }
    else {
        AddHint("Try not dying.");
        AddHint("Don't hoard items.", "What are you saving them for?");
        AddHint("Spend your skill points!");
    }

    // ~= is case insensitive equality
    switch(dxr.dxInfo.missionNumber) {
    case 1:
        if(map ~= "01_NYC_UNATCOIsland") {
            if(dxr.flags.settings.passwordsrandomized > 0)
                AddHint("Passwords have been randomized.", "Don't even try smashthestate!");
            if(dxr.flags.settings.goals > 0){
                AddHint("The locations of the terrorist commander and boat are randomized.", "Check the Goal Randomization page on our Wiki.");
                if(#defined(injections)) {
                    AddHint("The map of the island can show possible goal locations.", "Give it a try!");
                }
            }
        }
        break;

    case 2:
        if(map ~= "02_NYC_BatteryPark") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The location of the Ambrosia barrel is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
        else if(map ~= "02_NYC_Warehouse") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The locations of the generator, computer, and Jock are randomized.", "Check the Goal Randomization page on our Wiki.");
            AddHint("There are lots of enemies here!", "Look for thermoptic camo to help.");
            AddHint("There are lots of enemies here!", "Look for ballistic armor to help.");
            AddHint("There are lots of enemies here!", "Look for fire extinguishers to stun enemies.");
        }
        break;

    case 3:
        switch(map) {
        case "03_NYC_BatteryPark":
            if(dxr.flags.settings.goals > 0)
                AddHint("The locations of Harley and Curly are randomized.", "Check the Goal Randomization page on our Wiki.");
            break;
        case "03_NYC_BrooklynBridgeStation":
            if(dxr.flags.settings.goals > 0)
                AddHint("The locations of some NPCs on this map are randomized.", "Check the Goal Randomization page on our Wiki.");
            break;
        case "03_NYC_Airfield":
            if(dxr.flags.settings.goals > 0){
                AddHint("The location of the NSF soldier with the East Gate key is randomized.", "Check the Goal Randomization page on our Wiki.");
                if(#defined(injections)) {
                    AddHint("The map of the airfield can show possible goal locations.", "Give it a try!");
                }
            }
            break;
        case "03_NYC_747":
            AddHint("Anna will no longer trigger a LAM", "while she's allied to you!");
            break;
        }
        break;

    case 4:
        if (map ~= "04_NYC_NSFHQ") {
            if(dxr.flags.settings.goals > 0){
                AddHint("The location of the computer to align the satellites is randomized.", "Check the Goal Randomization page on our Wiki.");
                AddHint("The location of the computer to send the signal is randomized.", "Check the Goal Randomization page on our Wiki.");
            }
        } else if(dxr.flags.settings.goals > 0) {
            AddHint("Anna Navarre's location is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
        break;

    case 5:
        if (map ~= "05_NYC_UnatcoMJ12Lab") {
            if(dxr.flags.settings.goals > 0) {
                AddHint("Paul's location in the lab is randomized.", "Check the Goal Randomization page on our Wiki.");
                AddHint("Your equipment could be in either", "the armory, or the surgery ward.");
                if(#defined(injections)) {
                    AddHint("The map of the lab can show possible goal locations.", "Give it a try!");
                }
            }
        } else if (map ~= "05_NYC_UnatcoHQ") {
            if(dxr.flags.settings.goals > 0) {
                AddHint("Alex Jacobson's location in UNATCO HQ is randomized.", "Check the Goal Randomization page on our Wiki.");
                AddHint("The locations for Anna's killphrase are randomized in UNATCO HQ.", "Check the Goal Randomization page on our Wiki.");
                AddHint("Jaime Reyes's location in UNATCO HQ is randomized.", "Check the Goal Randomization page on our Wiki.");
            }
        } else if (map ~= "05_NYC_UNATCOISLAND") {
            if(!dxr.flags.IsReducedRando()) {
                AddHint("Private Lloyd has been promoted to Master Sergeant!", "Be careful!");
            }
        }
        break;

    case 6:
        if (map ~= "06_hongkong_mj12lab") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The location of the computer with the ROM Encoding is randomized.", "Check the Goal Randomization page on our Wiki.");
        } else if (map ~= "06_HongKong_WanChai_Street") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The Dragon Tooth Sword is randomized in Hong Kong.","Open the case in Maggie Chow's apartment for a hint.");
        } else if (map ~= "06_HongKong_VersaLife") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The locations of some VersaLife employees are randomized.", "Check the Goal Randomization page on our Wiki.");
        } else if (map ~= "06_HONGKONG_WANCHAI_UNDERWORLD") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The location of Max Chen in the Lucky Money Club is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
        break;

    case 8:
        if(dxr.flags.settings.goals > 0){
            AddHint("The locations of Filben, Greene, and Vinny are randomized.", "Check the Goal Randomization page on our Wiki.");
            AddHint("The start location of the raid has been randomized.", "Look for the black vans!");
            AddHint("The location of Jock when leaving is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
        break;

    case 9:
        if (map ~= "09_nyc_graveyard") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The location of the signal jammer is randomized.", "Check the Goal Randomization page on our Wiki.");
        } else if (map ~= "09_nyc_shipbelow") {
            if(dxr.flags.settings.goals > 0){
                AddHint("The locations of the tri-hull weld points are randomized.", "Check the Goal Randomization page on our Wiki.");
                AddHint("The location of the bilge pump computer is randomized.", "Check the Goal Randomization page on our Wiki.");
                if(#defined(injections)) {
                    AddHint("The map of the ship can show possible goal locations.", " Give it a try!");
                }
            }
        } else if (map ~= "09_nyc_dockyard") {
            if(dxr.flags.settings.goals > 0) {
                if(dxr.flagbase.GetBool('MS_ShipBreeched'))
                    AddHint("The location of Jock is randomized.", "Check the Goal Randomization page on our Wiki.");
                else
                    AddHint("The location of Jock will be randomized.", "Check the Goal Randomization page on our Wiki.");
            }
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
        if(dxr.flags.settings.goals > 0 && (map ~= "10_paris_metro" || map ~= "10_paris_club")) {
            AddHint("The location of Nicolette DuClare is randomized.", "Check the Goal Randomization page on our Wiki.");
            if(#defined(injections)) {
                    AddHint("The street map can show possible goal locations.", "Give it a try!");
            }
        }
        if(dxr.flags.settings.goals > 0 && (map ~= "10_Paris_Catacombs_Tunnels")) {
            if(#defined(injections)) {
                    AddHint("The map of the catacombs can show possible goal locations.", "Give it a try!");
            }
            AddHint("Agent Hela will always have two copies of the sewer key.", "She will be carrying one and keep another nearby.");
            AddHint("The location of Agent Hela is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
        break;

    case 11:
        if (map ~= "11_paris_cathedral") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The location of Gunther and the computer is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
#ifdef injections
        if( dxr.FindModule(class'DXRBacktracking') != None && map != "11_PARIS_EVERETT" ) {
            AddHint("Randomizer has enabled extra backtracking.", "You will be able to go back to previous Paris levels.");
        }
        AddHint("There's wine everywhere in Paris,", "it can be a decent source of health and energy.");
#else
        AddHint("There's wine everywhere in Paris,", "it can be a decent source of health.");
#endif
        break;

    case 12:
        if (map ~= "12_vandenberg_cmd") {
            if(dxr.flags.settings.goals > 0) {
                AddHint("The locations of the power generator keypads and Jock are randomized.", "Check the Goal Randomization page on our Wiki.");
            }
        }
#ifdef injections
        if( dxr.FindModule(class'DXRBacktracking') != None ) {
            AddHint("Randomizer has enabled extra backtracking.", "You will be able to come back here later.");
        }
#endif
        break;

    case 14:
        if (map ~= "14_oceanlab_silo") {
            if(dxr.flags.settings.goals > 0) {
                AddHint("Howard Strong is now on a random floor of the missile silo.", "Check the Goal Randomization page on our Wiki.");
                AddHint("Howard Strong will only show up if you've done your objectives!", "Been to the Ocean Lab UC and merged Helios?");
                AddHint("Jock will pick you up at a random location.", "Check the Goal Randomization page on our Wiki.");
            }
        }
        else if (map ~= "14_OceanLab_UC") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The location of the UC schematics computer is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
        if (map ~= "14_OCEANLAB_LAB" || map ~= "14_VANDENBERG_SUB" || map ~= "14_OCEANLAB_UC") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The location of Walton Simons is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
#ifdef injections
        if( dxr.FindModule(class'DXRBacktracking') != None ) {
            AddHint("Randomizer has enabled extra backtracking.", "You will be able to go back to Vandenberg.");
        }
#endif
        break;

    case 15:
        AddHint("Area 51 has great signage,", "read the signs to know where to go.");
        if (map ~= "15_AREA51_BUNKER") {
            if(dxr.flags.settings.goals > 0) {
                AddHint("The location of Walton Simons is randomized.", "Check the Goal Randomization page on our Wiki.");
                AddHint("The location of blast doors computer is randomized.", "Check the Goal Randomization page on our Wiki.");
            }

            AddHint("The path jumping down past the fan has been made more difficult", "than in vanilla. Be warned.");
        }
        else if (map ~= "15_Area51_Entrance") {
            AddHint("You are in Sector 2.", "Find the key so that you can make your way to Sector 3.");
        }
        else if (map ~= "15_Area51_Final") {
            AddHint("You are in Sector 3.", "This is where the Aquinas Hub and Reactor Lab are.");
            AddHint("There's a datacube with the code for the Reactor Lab.", "The mechanic there will give you the code for the Aquinas Hub.");
        }
        else if (map ~= "15_Area51_Page") {
            AddHint("You are in Sector 4 with Bob Page. This is where the", "Aquinas Router, Coolant Controls, and Blue Fusion Reactors are.");
            AddHint("You are in Sector 4. The UCs will constantly spawn new enemies,", "but they can be closed off.");
        }
#ifdef injections
        if( dxr.FindModule(class'DXRBacktracking') != None ) {
            AddHint("Randomizer has enabled extra backtracking.", "You will be able to move more freely through Area 51.");
        }
#endif
        break;
    }
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
    local DXRBigMessage m;
#ifdef hx
    // for hx, the DXRBigMessage is bugged, so just disable the timer and PlayerRespawn will enable it again
    SetTimer(0, false);
    return;
#endif
    SetTimer(15, true);
    if( recursion > 10 ) {
        info("ShowHint reached max recursion " $ recursion);
        return;
    }
    hint = GetHint();

    m = class'DXRBigMessage'.static.CreateBigMessage(_player, self, hints[hint], details[hint]);
    if(m == None) {
        ShowHint(++recursion);
        return;
    }
    m.line3 = "Deaths: "$class'DXRStats'.static.GetDataStorageStat(dxr, "DXRStats_deaths")$", Loads: "$class'DXRStats'.static.GetDataStorageStat(dxr, "DXRStats_loads");
    m.bottomText = "(Hint "$hint$" / "$numHints$", many hints are context sensitive)";
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
