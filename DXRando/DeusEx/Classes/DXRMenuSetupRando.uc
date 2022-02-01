class DXRMenuSetupRando extends DXRMenuBase;

var float combatDifficulty;

event InitWindow()
{
    Super.InitWindow();
}

function CheckConfig()
{
    if( config_version < class'DXRVersion'.static.VersionNumber() ) {
        num_rows=default.num_rows;
        num_cols=default.num_cols;
        col_width_odd=default.col_width_odd;
        col_width_even=default.col_width_even;
        row_height=default.row_height;
        padding_width=default.padding_width;
        padding_height=default.padding_height;
    }
    Super.CheckConfig();
}

function BindControls(optional string action)
{
    local DXRFlags f;
    local string doors_option;
    local int iDifficulty, doors_type;
    f = InitFlags();

    NewGroup("General");
    NewMenuItem("Brightness (0-255) +", "Increase the brightness of dark areas.");
    Slider(f.brightness, 0, 255);

    NewMenuItem("Combat Difficulty %", "Multiply the damage the player takes. The original game uses 400% for realistic.");
    iDifficulty = int(combatDifficulty * 100.0);
    Slider(iDifficulty, 0, 500);
    combatDifficulty = float(iDifficulty) / 100.0;

#ifndef hx
    NewMenuItem("", "Randomize starting locations on certain maps");
    EnumOption("Randomize Starting Locations", 100, f.settings.startinglocations);
    EnumOption("Unchanged Starting Locations", 0, f.settings.startinglocations);
#endif
    
    NewMenuItem("", "Randomize goal locations on certain maps");
    EnumOption("Randomize Goal Locations", 100, f.settings.goals);
    EnumOption("Unchanged Goal Locations", 0, f.settings.goals);

#ifdef vanilla
    NewMenuItem("The Merchant Chance %", "The chance for The Merchant to appear in each map.");
    Slider(f.settings.merchants, 0, 100);
#endif

    NewMenuItem("Dancing %", "How many characters should be dancing.");
    Slider(f.settings.dancingpercent, 0, 100);

    NewGroup("Medical Bots and Repair Bots");

    NewMenuItem("Medbots", "Percentage chance for a medbot to spawn in a map (vanilla is about 14%)");
    Slider(f.settings.medbots, -1, 100);

    NewMenuItem("Repair Bots", "Percentage chance for a repair bot to spawn in a map (vanilla is about 14%)");
    Slider(f.settings.repairbots, -1, 100);

#ifdef vanilla
    NewMenuItem("Medbot Uses", "Number of times you can use an individual medbot to heal");
    Slider(f.settings.medbotuses, 0, 10);

    NewMenuItem("Repair Bot Uses", "Number of times you can use an individual repair bot to restore energy");
    Slider(f.settings.repairbotuses, 0, 10);
#endif

    NewMenuItem("Medbot Cooldowns", "Individual: Each Medbot has its own healing cooldown.  Global: All Medbots have the same cooldown");
    EnumOption("Unchanged", 0, f.settings.medbotcooldowns);
    EnumOption("Individual", 1, f.settings.medbotcooldowns);
    EnumOption("Global", 2, f.settings.medbotcooldowns);

    NewMenuItem("Repair Bot Cooldowns", "Individual: Each Repair Bot has its own charge cooldown.  Global: All Repair Bots have the same cooldown");
    EnumOption("Unchanged", 0, f.settings.repairbotcooldowns);
    EnumOption("Individual", 1, f.settings.repairbotcooldowns);
    EnumOption("Global", 2, f.settings.repairbotcooldowns);

    NewMenuItem("Medbot Heal Amount", "Individual: Each Medbot has its own healing amount.  Global: All Medbots have the same amount");
    EnumOption("Unchanged", 0, f.settings.medbotamount);
    EnumOption("Individual", 1, f.settings.medbotamount);
    EnumOption("Global", 2, f.settings.medbotamount);

    NewMenuItem("Repair Bot Charge Amount", "Individual: Each Repair Bot has its own charge amount.  Global: All Repair Bots have the same amount");
    EnumOption("Unchanged", 0, f.settings.repairbotamount);
    EnumOption("Individual", 1, f.settings.repairbotamount);
    EnumOption("Global", 2, f.settings.repairbotamount);

    NewGroup("Doors and Keys");

    NewMenuItem("", "Which doors to provide additional options to get through.");
    doors_type = f.settings.doorsmode / 256 * 256;
    if( f.settings.doorsdestructible + f.settings.doorspickable == 50 )
        doors_type += 1;
    EnumOption("Key-Only Doors", f.keyonlydoors, doors_type);
    EnumOption("Some Key-Only Doors", f.keyonlydoors + 1, doors_type);
    EnumOption("Undefeatable Doors", f.undefeatabledoors, doors_type);
    EnumOption("Some Undefeatable Doors", f.undefeatabledoors + 1, doors_type);
    EnumOption("All Doors", f.alldoors, doors_type);
    EnumOption("Many Doors", f.alldoors + 1, doors_type);

    doors_option = int(f.settings.doorsmode % 256) $ ";" $ f.settings.doorsdestructible $ ";" $ f.settings.doorspickable;
    NewMenuItem("", "What to do with those doors.");
    EnumOptionString("Breakable or Pickable", f.doormutuallyexclusive$";50;50", doors_option);
    EnumOptionString("Breakable & Pickable", f.doormutuallyinclusive$";100;100", doors_option);
    EnumOptionString("Breakable", f.doorindependent$";100;0", doors_option);
    EnumOptionString("Pickable", f.doorindependent$";0;100", doors_option);
    EnumOptionString("Don't Change Doors", f.doorindependent$";0;0", doors_option);
    f.settings.doorsmode = UnpackInt(doors_option);
    f.settings.doorsdestructible = UnpackInt(doors_option);
    f.settings.doorspickable = UnpackInt(doors_option);
    if(doors_type % 2 == 1) {
        doors_type--;
        f.settings.doorsdestructible /= 2;
        f.settings.doorspickable /= 2;
    }
    f.settings.doorsmode += doors_type;

    BreakLine();

    NewMenuItem("NanoKey Locations", "Move keys around the map.");
    EnumOption("Randomized", 4, f.settings.keysrando);
    EnumOption("Unchanged", 0, f.settings.keysrando);

    NewGroup("Passwords");
#ifdef injections
    NewMenuItem("", "Help with finding passwords from your notes.");
    EnumOption("Autofill Passwords", 2, f.codes_mode);
    EnumOption("Mark Known Passwords", 1, f.codes_mode);
    EnumOption("No Assistance With Passwords", 0, f.codes_mode);
#endif

    NewMenuItem("Electronic Devices", "Provide additional options for keypads and electronic panels.");
    EnumOption("All Hackable", 100, f.settings.deviceshackable);
    EnumOption("Some Hackable", 50, f.settings.deviceshackable);
    EnumOption("Unchanged", 0, f.settings.deviceshackable);

    NewMenuItem("Passwords", "Forces you to look for passwords and passcodes.");
    EnumOption("Randomized", 100, f.settings.passwordsrandomized);
    EnumOption("Unchanged", 0, f.settings.passwordsrandomized);

    NewMenuItem("Datacubes Locations", "Moves datacubes and other information objects around the map.");
    EnumOption("Randomized", 100, f.settings.infodevices);
    EnumOption("Unchanged", 0, f.settings.infodevices);

    NewGroup("Enemies");
    NewMenuItem("Enemy Randomization %", "How many additional enemies to add and how much to randomize their weapons.");
    Slider(f.settings.enemiesrandomized, 0, 100);

    NewMenuItem("Non-Human Chance %", "Reduce the chance of new enemies being non-humans.");
    Slider(f.settings.enemies_nonhumans, 0, 100);

    NewMenuItem("Enemy Respawn Seconds", "(Beta) How many seconds for enemies to respawn. Leave blank or 0 to disable");
    Slider(f.settings.enemyrespawn, 0, 100);

    NewMenuItem("Move Turrets", "Randomizes locations of turrets, cameras, and security computers for them.");
    Slider(f.settings.turrets_move, 0, 100);

    NewMenuItem("Add Turrets", "Randomly adds turrets, cameras, and security computers for them.");
    Slider(f.settings.turrets_add, 0, 100);

    NewGroup("Skills");
    NewMenuItem("", "Disallow downgrades to prevent scouting ahead in the new game screen.");
    EnumOption("Allow Downgrades On New Game Screen", 0, f.settings.skills_disable_downgrades);
    EnumOption("Disallow Downgrades On New Game Screen", 5, f.settings.skills_disable_downgrades);

    NewMenuItem("", "How often to reroll skill costs.");
    EnumOption("Don't Reroll Skill Costs", 0, f.settings.skills_reroll_missions);
    EnumOption("Reroll Skill Costs Every Mission", 1, f.settings.skills_reroll_missions);
    EnumOption("Reroll Skill Costs Every 2 Missions", 2, f.settings.skills_reroll_missions);
    EnumOption("Reroll Skill Costs Every 3 Missions", 3, f.settings.skills_reroll_missions);
    EnumOption("Reroll Skill Costs Every 5 Missions", 5, f.settings.skills_reroll_missions);

    NewMenuItem("", "Predictability of skill level cost scaling.");
    EnumOption("Relative Skill Level Costs", 0, f.settings.skills_independent_levels);
    EnumOption("Unpredictable Skill Level Costs", 1, f.settings.skills_independent_levels);

    BreakLine();

    NewMenuItem("Minimum Skill Cost %", "Minimum cost for skills in percentage of the original cost.");
    Slider(f.settings.minskill, 0, 1000);

    NewMenuItem("Maximum Skill Cost %", "Maximum cost for skills in percentage of the original cost.");
    Slider(f.settings.maxskill, 0, 1000);

    NewMenuItem("Banned Skills %", "Chance of a skill having a cost of 99,999 points.");
    Slider(f.settings.banned_skills, 0, 100);

    NewMenuItem("Banned Skill Levels %", "Chance of a certain level of a skill having a cost of 99,999 points.");
    Slider(f.settings.banned_skill_levels, 0, 100);

    NewMenuItem("Skill Strength Rando %", "How much to randomize the strength of skills.");
    Slider(f.settings.skill_value_rando, 0, 300);

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

    NewMenuItem("Starting Equipment", "How many random items you start with");
    Slider(f.settings.equipment, 0, 10);

    NewMenuItem("Swap Items %", "The chance for item positions to be swapped.");
    Slider(f.settings.swapitems, 0, 100);

    NewMenuItem("Swap Containers %", "The chance for container positions to be swapped.");
    Slider(f.settings.swapcontainers, 0, 100);

    BreakLine();
    NewMenuItem("Min Weapon Damage %", "The minmum damage for weapons.");
    Slider(f.settings.min_weapon_dmg, 0, 300);

    NewMenuItem("Max Weapon Damage %", "The maximum damage for weapons.");
    Slider(f.settings.max_weapon_dmg, 0, 300);

    BreakLine();
    NewMenuItem("Min Weapon Shot Time %", "The minmum shot time / firing speed for weapons.");
    Slider(f.settings.min_weapon_shottime, 0, 300);

    NewMenuItem("Max Weapon Shot Time %", "The maximum shot time / firing speed for weapons.");
    Slider(f.settings.max_weapon_shottime, 0, 300);

    NewGroup("Augmentations");
    NewMenuItem("Speed Aug Level", "Start the game with the Speed Enhancement augmentation.");
    Slider(f.settings.speedlevel, 0, 3);

    NewMenuItem("Aug Cans Randomized %", "The chance for aug cannisters to have their contents changed.");
    Slider(f.settings.augcans, 0, 100);

    NewMenuItem("Aug Strength Rando %", "How much to randomize the strength of augmentations.");
    Slider(f.settings.aug_value_rando, 0, 300);

    if( action == "NEXT" ) _InvokeNewGameScreen(combatDifficulty, InitDxr());
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
    ClientWidth=672
    ClientHeight=357
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
}
