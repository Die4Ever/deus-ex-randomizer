class DXRMenuSetupRando extends DXRMenuBase;

var float combatDifficulty;

event InitWindow()
{
    Super.InitWindow();
}

//If changing ranges in this menu, make sure to update any clamped ranges in DXRFlags ScoreFlags function to match
function BindControls(optional string action)
{
    local DXRFlags f;
    local string doors_option, s;
    local int iDifficulty, doors_type, doors_exclusivity, doors_probability, door_type_prob_choice, doorsdestructible, doorspickable, i;
    f = GetFlags();

    NewGroup("General");

    if( ! #defined(vmd) ) {
        NewMenuItem("Combat Difficulty %", "Multiply the damage the player takes. The original game uses 400% for realistic.");
        iDifficulty = int(combatDifficulty * 100.0);
        Slider(iDifficulty, 0, 10000);
        combatDifficulty = float(iDifficulty) / 100.0;
    }

    //Make sure the starting map values match those in DXRStartMap
    NewMenuItem("Starting Map", "What level you will start in.");
    for(i=0; i<160; i++) {
        if(i == 10) continue;// Liberty Island dupe
        s = class'DXRStartMap'.static.GetStartingMapName(i);
        if(s != "") {
            EnumOption(s, i, f.settings.starting_map);
        }
    }
    if(f.settings.starting_map > 0) {
        EnumOption("Random", f.settings.starting_map, f.settings.starting_map);
    }
    else if(EnumOption("Random", -1)) {
        f.settings.starting_map = class'DXRStartMap'.static.ChooseRandomStartMap(f, 0);
    }

    BreakLine();

    NewMenuItem("Player Health", "Max health for each body part of the player.");
    Slider(f.settings.health, 1, 10000);

    NewMenuItem("Player Energy", "Max bioelectric energy for the player.");
    Slider(f.settings.energy, 0, 10000);

    BreakLine();

#ifndef hx
    NewMenuItem("", "Randomize starting locations on certain maps.");
    EnumOption("Randomize Starting Locations", 100, f.settings.startinglocations);
    EnumOption("Unchanged Starting Locations", 0, f.settings.startinglocations);
#endif

    NewMenuItem("", "Randomize goal locations on certain maps.");
    EnumOption("Randomize Goal Locations", 100, f.settings.goals);
    EnumOption("Unchanged Goal Locations", 0, f.settings.goals);

    BreakLine();
#ifndef hx
    NewMenuItem("The Merchant Chance %", "The chance for The Merchant to appear in each map."$BR$"If The Merchant dies then he stays dead for the rest of the game.");
    Slider(f.settings.merchants, 0, 100);
#endif

    NewMenuItem("Dancing %", "How many characters should be dancing.");
    Slider(f.settings.dancingpercent, 0, 100);

    NewMenuItem("Spoiler Buttons", "Allow the use of spoiler buttons (Spoilers remain hidden until you choose to view them).");
    EnumOption("Available", 1, f.settings.spoilers);
    EnumOption("Disallowed", 0, f.settings.spoilers);

    NewMenuItem("Menus Pause Game", "Should the game keep playing while a menu is open?");
    EnumOption("Pause", 1, f.settings.menus_pause);
    EnumOption("Don't Pause", 0, f.settings.menus_pause);

    NewGroup("Bingo");

    NewMenuItem("Bingo Win", "How many completed lines to instantly win.");
    Slider(f.settings.bingo_win, 0, 12);

    NewMenuItem("Bingo Scale %", "How difficult should bingo goals be?");
    Slider(f.bingo_scale, 0, 100);

    NewMenuItem("Bingo Freespace", "Should the center be a Free Space, or even more Free Spaces?");
    EnumOption("Enabled", 1, f.settings.bingo_freespaces);
    EnumOption("Disabled", 0, f.settings.bingo_freespaces);
    EnumOption("2 Free Spaces", 2, f.settings.bingo_freespaces);
    EnumOption("3 Free Spaces", 3, f.settings.bingo_freespaces);
    EnumOption("4 Free Spaces", 4, f.settings.bingo_freespaces);
    EnumOption("5 Free Spaces", 5, f.settings.bingo_freespaces);

    NewMenuItem("Bingo Duration", "How many missions should the bingo goals last for?");
    EnumOption("End of Game", 0, f.bingo_duration);
    EnumOption("1 Mission",   1, f.bingo_duration);
    EnumOption("2 Missions",  2, f.bingo_duration);
    EnumOption("3 Missions",  3, f.bingo_duration);
    EnumOption("4 Missions",  4, f.bingo_duration);
    EnumOption("5 Missions",  5, f.bingo_duration);

    NewGroup("Medical Bots and Repair Bots");

    NewMenuItem("Medbots", "Percentage chance for a medbot to spawn in a map (vanilla is about 14%).");
    Slider(f.settings.medbots, -1, 100);

    NewMenuItem("Augbots", "Percentage chance for a zero-heals medbot to spawn in a map if a regular one doesn't.");
    Slider(f.moresettings.empty_medbots, 0, 100);

    NewMenuItem("Repair Bots", "Percentage chance for a repair bot to spawn in a map (vanilla is about 14%).");
    Slider(f.settings.repairbots, -1, 100);

    if(!#defined(vmd)) {
        NewMenuItem("Medbot Uses", "Number of times you can use an individual medbot to heal.");
        Slider(f.settings.medbotuses, 0, 10);

        NewMenuItem("Repair Bot Uses", "Number of times you can use an individual repair bot to restore energy.");
        Slider(f.settings.repairbotuses, 0, 10);
    }

    NewMenuItem("Medbot Cooldowns", "Individual: Each Medbot has its own healing cooldown."$BR$"Global: All Medbots have the same cooldown.");
    EnumOption("Unchanged", 0, f.settings.medbotcooldowns);
    EnumOption("Individual", 1, f.settings.medbotcooldowns);
    EnumOption("Global", 2, f.settings.medbotcooldowns);

    NewMenuItem("Repair Bot Cooldowns", "Individual: Each Repair Bot has its own charge cooldown."$BR$"Global: All Repair Bots have the same cooldown.");
    EnumOption("Unchanged", 0, f.settings.repairbotcooldowns);
    EnumOption("Individual", 1, f.settings.repairbotcooldowns);
    EnumOption("Global", 2, f.settings.repairbotcooldowns);

    NewMenuItem("Medbot Heal Amount", "Individual: Each Medbot has its own healing amount."$BR$"Global: All Medbots have the same amount.");
    EnumOption("Unchanged", 0, f.settings.medbotamount);
    EnumOption("Individual", 1, f.settings.medbotamount);
    EnumOption("Global", 2, f.settings.medbotamount);

    NewMenuItem("Repair Bot Charge Amount", "Individual: Each Repair Bot has its own charge amount."$BR$"Global: All Repair Bots have the same amount.");
    EnumOption("Unchanged", 0, f.settings.repairbotamount);
    EnumOption("Individual", 1, f.settings.repairbotamount);
    EnumOption("Global", 2, f.settings.repairbotamount);

    NewGroup("Doors and Keys");

    NewMenuItem("Doors To Change", "Which doors to provide additional options to get through.", true);

    doors_type = f.settings.doorsmode  & 0xffffff00;// keep it in the high bytes
    doors_exclusivity = f.settings.doorsmode & 0xff;// just the low byte
    doors_probability = f.settings.doorsdestructible + f.settings.doorspickable;// we'll use this for scaling later
    if(doors_exclusivity != f.doormutuallyexclusive)
        doors_probability /= 2;
    door_type_prob_choice = doors_type + doors_probability;

    EnumOption("All Key-Only Doors", f.keyonlydoors + 100, door_type_prob_choice);
    EnumOption("Many Key-Only Doors", f.keyonlydoors + 70, door_type_prob_choice);
    EnumOption("Some Key-Only Doors", f.keyonlydoors + 40, door_type_prob_choice);
    EnumOption("Few Key-Only Doors", f.keyonlydoors + 25, door_type_prob_choice);
    EnumOption("All Undefeatable Doors", f.undefeatabledoors + 100, door_type_prob_choice);
    EnumOption("Many Undefeatable Doors", f.undefeatabledoors + 70, door_type_prob_choice);
    EnumOption("Some Undefeatable Doors", f.undefeatabledoors + 40, door_type_prob_choice);
    EnumOption("Few Undefeatable Doors", f.undefeatabledoors + 25, door_type_prob_choice);
    EnumOption("All Doors", f.alldoors + 100, door_type_prob_choice);
    EnumOption("Many Doors", f.alldoors + 70, door_type_prob_choice);
    EnumOption("Some Doors", f.alldoors + 40, door_type_prob_choice);
    EnumOption("Few Doors", f.alldoors + 25, door_type_prob_choice);

    doorsdestructible = f.settings.doorsdestructible * 100 / doors_probability;
    doorspickable = f.settings.doorspickable * 100 / doors_probability;
    doors_option = doors_exclusivity $ ";" $ doorsdestructible $ ";" $ doorspickable;
    NewMenuItem("Door Adjustments", "What to do with those doors.", true);
    EnumOptionString("Breakable or Pickable", f.doormutuallyexclusive $";50;50", doors_option);
    EnumOptionString("Breakable & Pickable", f.doormutuallyinclusive $";100;100", doors_option);
    EnumOptionString("Breakable and/or Pickable", f.doorindependent $";100;100", doors_option);
    EnumOptionString("Breakable", f.doorindependent$";100;0", doors_option);
    EnumOptionString("Pickable", f.doorindependent$";0;100", doors_option);
    EnumOptionString("Don't Change Doors", f.doorindependent$";0;0", doors_option);
    f.settings.doorsmode = UnpackInt(doors_option) + (door_type_prob_choice & 0xffffff00);
    f.settings.doorsdestructible = UnpackInt(doors_option);
    f.settings.doorspickable = UnpackInt(doors_option);

    // scale the probability by our total probability before (based on All/Many/Some/etc)
    f.settings.doorsdestructible = f.settings.doorsdestructible * 100 / doors_probability;
    f.settings.doorspickable = f.settings.doorspickable * 100 / doors_probability;

    BreakLine();

    NewMenuItem("NanoKey Locations", "Move keys around the map."$BR$"Experimental allows keys to be swapped with containers.");
    if(EnumOption("Experimental", 100, f.settings.keys_containers))
        f.settings.keysrando = 4;
    else
        f.settings.keys_containers = 0;
    EnumOption("Randomized", 4, f.settings.keysrando);
    EnumOption("Unchanged", 0, f.settings.keysrando);

    NewGroup("Passwords");

    NewMenuItem("Electronic Devices", "Provide additional options for keypads and electronic panels.");
    EnumOption("All Hackable", 100, f.settings.deviceshackable);
    EnumOption("Many Hackable", 75, f.settings.deviceshackable);
    EnumOption("Some Hackable", 50, f.settings.deviceshackable);
    EnumOption("Few Hackable", 25, f.settings.deviceshackable);
    EnumOption("Unchanged", 0, f.settings.deviceshackable);

    NewMenuItem("Passwords", "Forces you to look for passwords and passcodes.");
    EnumOption("Randomized", 100, f.settings.passwordsrandomized);
    EnumOption("Unchanged", 0, f.settings.passwordsrandomized);

    NewMenuItem("Datacubes Locations", "Moves datacubes and other information objects around the map."$BR$"Experimental allows datacubes to be swapped with containers.");
    if(EnumOption("Experimental", 100, f.settings.infodevices_containers))
        f.settings.infodevices = 100;
    else
        f.settings.infodevices_containers = 0;
    EnumOption("Randomized", 100, f.settings.infodevices);
    EnumOption("Unchanged", 0, f.settings.infodevices);

    NewGroup("Enemies");

    NewMenuItem("Enemy Randomization %", "How many additional enemies to add and how much to randomize their weapons.");
    Slider(f.settings.enemiesrandomized, 0, 1000);
    f.settings.hiddenenemiesrandomized = f.settings.enemiesrandomized;

    NewMenuItem("Enemy Stats Boost %", "How much to boost enemy accuracy, reload speed, aggression, and helmets.");
    Slider(f.settings.enemystats, 0, 100);

    NewMenuItem("Enemy Shuffling %", "Shuffle enemies around the map.");
    Slider(f.settings.enemiesshuffled, 0, 100);

    NewMenuItem("Non-Human Chance %", "Reduce the chance of new enemies being non-humans.");
    Slider(f.settings.enemies_nonhumans, 0, 100);

    NewMenuItem("Enemy Respawn Seconds", "(Beta) How many seconds for enemies to respawn. Leave blank or 0 to disable.");
    Slider(f.settings.enemyrespawn, 0, 10000);

    NewMenuItem("Move Turrets", "Randomizes locations of turrets, cameras, and security computers for them.");
    Slider(f.settings.turrets_move, 0, 100);

    NewMenuItem("Add Turrets", "Randomly adds turrets, cameras, and security computers for them.");
    Slider(f.settings.turrets_add, 0, 10000);

    NewMenuItem("", "Allow robots to get randomized weapons.");
    EnumOption("Unchanged Robot Weapons", 0, f.settings.bot_weapons);
    EnumOption("Random Robot Weapons", 4, f.settings.bot_weapons);

    NewMenuItem("", "Allow non-humans to get randomized stats.");
    EnumOption("Unchanged Non-human Stats", 0, f.settings.bot_stats);
    EnumOption("Random Non-human Stats", 100, f.settings.bot_stats);

    NewMenuItem("Paris Chill %", "Removes MJ12 from the Champs-Elysees.");
    Slider(f.moresettings.remove_paris_mj12, 0, 100);


    NewGroup("Skills");

    NewMenuItem("", "Disallow downgrades to prevent scouting ahead in the new game screen.");
    EnumOption("Allow Downgrades On New Game Screen", 0, f.settings.skills_disable_downgrades);
    EnumOption("Disallow Downgrades On New Game Screen", 5, f.settings.skills_disable_downgrades);

    NewMenuItem("", "How often to reroll skill costs.");
    EnumOption("Don't Reroll Skill Costs", 0, f.settings.skills_reroll_missions);
    EnumOption("Reroll Skill Costs Every Mission", 1, f.settings.skills_reroll_missions);
    EnumOption("Reroll Skill Costs Every 2 Missions", 2, f.settings.skills_reroll_missions);
    EnumOption("Reroll Skill Costs Every 3 Missions", 3, f.settings.skills_reroll_missions);
    EnumOption("Reroll Skill Costs Every 4 Missions", 4, f.settings.skills_reroll_missions);
    EnumOption("Reroll Skill Costs Every 5 Missions", 5, f.settings.skills_reroll_missions);

    NewMenuItem("", "Predictability of skill level cost scaling.");
    EnumOption("Relative Skill Level Costs", 0, f.settings.skills_independent_levels);
    EnumOption("Unpredictable Skill Level Costs", 1, f.settings.skills_independent_levels);

    BreakLine();

    NewMenuItem("Minimum Skill Cost %", "Minimum cost for skills in percentage of the original cost.");
    Slider(f.settings.minskill, 50, 1000);

    NewMenuItem("Maximum Skill Cost %", "Maximum cost for skills in percentage of the original cost.");
    Slider(f.settings.maxskill, 50, 1000);

    NewMenuItem("Banned Skills %", "Chance of a skill having a cost of 99,999 points.");
    Slider(f.settings.banned_skills, 0, 100);

    NewMenuItem("Banned Skill Levels %", "Chance of a certain level of a skill having a cost of 99,999 points.");
    Slider(f.settings.banned_skill_levels, 0, 100);

    NewMenuItem("Skill Strength Rando %", "How much to randomize the strength of skills.");
    Slider(f.settings.skill_value_rando, 0, 100);// this is actually a wet/dry scale, so the range should be 0 to 100%

    NewGroup("Items");

    NewMenuItem("Ammo Drops %", "Make ammo more scarce.");
    Slider(f.settings.ammo, 0, 100);

    NewMenuItem("Multitools Drops %", "Make multitools more scarce.");
    Slider(f.settings.multitools, 0, 100);

    NewMenuItem("Lockpicks Drops %", "Make lockpicks more scarce.");
    Slider(f.settings.lockpicks, 0, 100);

    NewMenuItem("Bioelectric Cells Drops %", "Make bioelectric cells more scarce.");
    Slider(f.settings.biocells, 0, 100);

    NewMenuItem("Medkit Drops %", "Make medkits more scarce.");
    Slider(f.settings.medkits, 0, 100);

    NewMenuItem("Starting Equipment", "How many random items you start with.");
    Slider(f.settings.equipment, 0, 10);

    NewMenuItem("Swap Items %", "The chance for item positions to be swapped.");
    Slider(f.settings.swapitems, 0, 100);

    NewMenuItem("Swap Containers %", "The chance for container positions to be swapped.");
    Slider(f.settings.swapcontainers, 0, 100);

    NewMenuItem("Swap Grenades %", "The chance for grenades on walls to have their type randomized.");
    Slider(f.moresettings.grenadeswap, 0, 100);

    BreakLine();
    NewMenuItem("Min Weapon Damage %", "The minmum damage for weapons.");
    Slider(f.settings.min_weapon_dmg, 0, 500);

    NewMenuItem("Max Weapon Damage %", "The maximum damage for weapons.");
    Slider(f.settings.max_weapon_dmg, 0, 500);

    BreakLine();
    NewMenuItem("Min Weapon Shot Time %", "The minmum shot time / firing speed for weapons.");
    Slider(f.settings.min_weapon_shottime, 0, 500);

    NewMenuItem("Max Weapon Shot Time %", "The maximum shot time / firing speed for weapons.");
    Slider(f.settings.max_weapon_shottime, 0, 500);

    NewMenuItem("JC's Prison Pocket", "Keep all your items when getting captured.");
    EnumOption("Disabled", 0, f.settings.prison_pocket);
    //EnumOption("Unaugmented", 1, f.settings.prison_pocket);// TODO: can keep the item in the top left inventory slot, if it's 1 slot
    EnumOption("Augmented", 100, f.settings.prison_pocket);// maybe the number could be set to the number of items to keep?

    NewGroup("Augmentations");

    NewMenuItem("Speed Aug Level", "Start the game with the Speed Enhancement augmentation.");
    Slider(f.settings.speedlevel, 0, 4);

    NewMenuItem("Aug Cans Randomized %", "The chance for aug cannisters to have their contents changed.");
    Slider(f.settings.augcans, 0, 100);

    NewMenuItem("Aug Strength Rando %", "How much to randomize the strength of augmentations.");
    Slider(f.settings.aug_value_rando, 0, 100);// this is a wet/dry scale, 0 to 100%

    NewGroup("New Game+");

    NewMenuItem("Scaling %", "Scales the curve of New Game+ changes over successive loops.");
    Slider(f.moresettings.newgameplus_curve_scalar, 0, 200);
    NewMenuItem("Max Item Carryover", "Maximum number of the same item that can carry over between loops, not including stackable items.");
    Slider(f.newgameplus_max_item_carryover, 0, 30);
    NewMenuItem("Skill Downgrades", "Number of skill level downgrades per loop.");
    Slider(f.newgameplus_num_skill_downgrades, 0, 33);
    NewMenuItem("Augmentations Removed", "Number of augmentations removed per loop.");
    Slider(f.newgameplus_num_removed_augs, 0, 8);
    NewMenuItem("Weapons Removed", "Number of weapons removed per loop.");
    Slider(f.newgameplus_num_removed_weapons, 0, 18);

    if( action == "NEXT" ) _InvokeNewGameScreen(combatDifficulty);
    if( action == "RANDOMIZE" ) RandomizeOptions();
}

function RandomizeOptions()
{
    local int scrollPos;
    local DXRFlags f;
    f = GetFlags();

    scrollPos = winScroll.vScale.GetTickPosition();

    _BindControls(True);
    f.InitMaxRandoSettings();
    f.RandomizeSettings(True);
    _BindControls(False);

    //Scroll to same position again
    winScroll.vScale.SetTickPosition(scrollPos);
}

function SetDifficulty(float newDifficulty)
{
    combatDifficulty = newDifficulty;
}

defaultproperties
{
    num_rows=13
    num_cols=4
    col_width_odd=160
    col_width_even=140
    row_height=20
    padding_width=20
    padding_height=10
    Title="DX Rando Options"
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
    actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel,Text="|&Back")
    actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Next",Key="NEXT")
    actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Randomize",Key="RANDOMIZE")

}
