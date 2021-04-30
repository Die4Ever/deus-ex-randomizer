class DXRMenuSetupRando extends DXRMenuBase;

var float combatDifficulty;

event InitWindow()
{
    Super.InitWindow();
}

function CheckConfig()
{
    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
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

function BindControls(bool writing, optional string action)
{
    local DXRFlags f;
    local string doors_option, skills_option, locations_option;
    local int iDifficulty;
    Super.BindControls(writing, action);
    f = InitFlags();

    labels[id] = "Brightness (0-255) +";
    helptexts[id] = "Increase the brightness of dark areas.";
    Slider(id, f.brightness, 0, 255, writing);
    id++;

    doors_option = f.doorsmode $ ";" $ f.doorsdestructible $ ";" $ f.doorspickable;

    labels[id] = "";
    helptexts[id] = "Additional options to get through doors that normally can't be destroyed or lockpicked.";
    //I could make this dual column? "Key-Only Doors" on the left and then "Breakable or Pickable" on the right? or should it be 2 rows?
    EnumOptionString(id, "Key-Only Doors Breakable or Pickable", (f.keyonlydoors+f.doormutuallyexclusive)$";50;50", writing, doors_option);
    EnumOptionString(id, "Key-Only Doors Breakable & Pickable", (f.keyonlydoors+f.doormutuallyinclusive)$";100;100", writing, doors_option);
    EnumOptionString(id, "Key-Only Doors Breakable", (f.keyonlydoors+f.doorindependent)$";100;0", writing, doors_option);
    EnumOptionString(id, "Key-Only Doors Pickable", (f.keyonlydoors+f.doorindependent)$";0;100", writing, doors_option);
    EnumOptionString(id, "Some Doors Breakable or Pickable", (f.keyonlydoors+f.doormutuallyexclusive)$";25;25", writing, doors_option);
    EnumOptionString(id, "Some Doors Breakable & Pickable", (f.keyonlydoors+f.doormutuallyinclusive)$";50;50", writing, doors_option);
    EnumOptionString(id, "Some Doors Breakable", (f.keyonlydoors+f.doorindependent)$";50;0", writing, doors_option);
    EnumOptionString(id, "Some Doors Pickable", (f.keyonlydoors+f.doorindependent)$";0;50", writing, doors_option);
    EnumOptionString(id, "Undefeatable Doors Breakable or Pickable", (f.undefeatabledoors+f.doormutuallyexclusive)$";50;50", writing, doors_option);
    EnumOptionString(id, "Undefeatable Doors Breakable & Pickable", (f.undefeatabledoors+f.doormutuallyinclusive)$";100;100", writing, doors_option);
    EnumOptionString(id, "Undefeatable Doors Breakable", (f.undefeatabledoors+f.doorindependent)$";100;0", writing, doors_option);
    EnumOptionString(id, "Undefeatable Doors Pickable", (f.undefeatabledoors+f.doorindependent)$";0;100", writing, doors_option);
    EnumOptionString(id, "Doors Unchanged", "0;0;0", writing, doors_option);
    EnumOptionString(id, "All Doors Breakable or Pickable", (f.alldoors+f.doormutuallyexclusive)$";50;50", writing, doors_option);
    EnumOptionString(id, "All Doors Breakable & Pickable", (f.alldoors+f.doormutuallyinclusive)$";100;100", writing, doors_option);
    EnumOptionString(id, "All Doors Breakable", (f.alldoors+f.doorindependent)$";100;0", writing, doors_option);
    EnumOptionString(id, "All Doors Pickable", (f.alldoors+f.doorindependent)$";0;100", writing, doors_option);
    f.doorsmode = UnpackInt(doors_option);
    f.doorsdestructible = UnpackInt(doors_option);
    f.doorspickable = UnpackInt(doors_option);
    id++;

    labels[id] = "NanoKey Locations";
    helptexts[id] = "Move keys around the map.";
    EnumOption(id, "Randomized", 4, writing, f.keysrando);
    EnumOption(id, "Unchanged", 0, writing, f.keysrando);
    id++;

    labels[id] = "Electronic Devices";
    helptexts[id] = "Provide additional options for keypads and electronic panels.";
    EnumOption(id, "All Hackable", 100, writing, f.deviceshackable);
    EnumOption(id, "Some Hackable", 50, writing, f.deviceshackable);
    EnumOption(id, "Unchanged", 0, writing, f.deviceshackable);
    id++;

    labels[id] = "Passwords";
    helptexts[id] = "Forces you to look for passwords and passcodes.";
    EnumOption(id, "Randomized", 100, writing, f.passwordsrandomized);
    EnumOption(id, "Unchanged", 0, writing, f.passwordsrandomized);
    id++;

    labels[id] = "Datacubes Locations";
    helptexts[id] = "Moves datacubes and other information objects around the map.";
    EnumOption(id, "Randomized", 100, writing, f.infodevices);
    EnumOption(id, "Unchanged", 0, writing, f.infodevices);
    id++;

    labels[id] = "Enemy Randomization %";
    helptexts[id] = "How many additional enemies to add and how much to randomize their weapons.";
    Slider(id, f.enemiesrandomized, 0, 100, writing);
    id++;

    labels[id] = "Non-Human Chance %";
    helptexts[id] = "Reduce the chance of new enemies being non-humans.";
    Slider(id, f.enemies_nonhumans, 0, 100, writing);
    id++;

    labels[id] = "Enemy Respawn Seconds";
    helptexts[id] = "(Beta) How many seconds for enemies to respawn. Leave blank or 0 to disable";
    Slider(id, f.enemyrespawn, 0, 100, writing);
    id++;

    labels[id] = "";
    helptexts[id] = "Adjust how skill cost randomization works.";
    skills_option = f.skills_disable_downgrades $";"$ f.skills_reroll_missions $";"$ f.skills_independent_levels;
    EnumOptionString(id, "Normal Skill Randomization", "0;0;0", writing, skills_option);
    EnumOptionString(id, "Normal Skills Every Mission", "0;1;0", writing, skills_option);
    EnumOptionString(id, "Normal Skills Every 2 Missions", "0;2;0", writing, skills_option);
    EnumOptionString(id, "Normal Skills Every 3 Missions", "0;3;0", writing, skills_option);
    EnumOptionString(id, "Normal Skills Every 5 Missions", "0;5;0", writing, skills_option);
    EnumOptionString(id, "Blind Skill Randomization", "5;0;100", writing, skills_option);
    EnumOptionString(id, "Blind Skills Every Mission", "5;1;100", writing, skills_option);
    EnumOptionString(id, "Blind Skills Every 2 Missions", "5;2;100", writing, skills_option);
    EnumOptionString(id, "Blind Skills Every 3 Missions", "5;3;100", writing, skills_option);
    EnumOptionString(id, "Blind Skills Every 5 Missions", "5;5;100", writing, skills_option);
    f.skills_disable_downgrades = UnpackInt(skills_option);
    f.skills_reroll_missions = UnpackInt(skills_option);
    f.skills_independent_levels = UnpackInt(skills_option);
    id++;

    labels[id] = "Minimum Skill Cost %";
    helptexts[id] = "Minimum cost for skills in percentage of the original cost.";
    Slider(id, f.minskill, 0, 1000, writing);
    id++;

    labels[id] = "Maximum Skill Cost %";
    helptexts[id] = "Maximum cost for skills in percentage of the original cost.";
    Slider(id, f.maxskill, 0, 1000, writing);
    id++;

    labels[id] = "Banned Skills %";
    helptexts[id] = "Chance of a skill having a cost of 99,999 points.";
    Slider(id, f.banned_skills, 0, 100, writing);
    id++;

    labels[id] = "Banned Skill Levels %";
    helptexts[id] = "Chance of a certain level of a skill having a cost of 99,999 points.";
    Slider(id, f.banned_skill_levels, 0, 100, writing);
    id++;

    iDifficulty = int(combatDifficulty * 100.0);
    labels[id] = "Combat Difficulty %";
    helptexts[id] = "Multiply the damage the player takes. The original game uses 400% for realistic.";
    Slider(id, iDifficulty, 0, 500, writing);
    combatDifficulty = float(iDifficulty) / 100.0;
    id++;

    labels[id] = "Ammo Drops %";
    helptexts[id] = "Make ammo more scarce.";
    Slider(id, f.ammo, 0, 100, writing);
    id++;

    labels[id] = "Multitools Drops %";
    helptexts[id] = "Make multitools more scarce.";
    Slider(id, f.multitools, 0, 100, writing);
    id++;

    labels[id] = "Lockpicks Drops %";
    helptexts[id] = "Make lockpicks more scarce.";
    Slider(id, f.lockpicks, 0, 100, writing);
    id++;

    labels[id] = "Bioelectric Cells Drops %";
    helptexts[id] = "Make bioelectric cells more scarce.";
    Slider(id, f.biocells, 0, 100, writing);
    id++;

    labels[id] = "Medkit Drops %";
    helptexts[id] = "Make medkits more scarce.";
    Slider(id, f.medkits, 0, 100, writing);
    id++;

    labels[id] = "Speed Aug Level";
    helptexts[id] = "Start the game with the Speed Enhancement augmentation.";
    Slider(id, f.speedlevel, 0, 3, writing);
    id++;

    labels[id] = "Dancing %";
    helptexts[id] = "How many characters should be dancing.";
    Slider(id, f.dancingpercent, 0, 100, writing);
    id++;

    labels[id] = "Starting Equipment";
    helptexts[id] = "How many random items you start with";
    Slider(id, f.equipment, 0, 10, writing);
    id++;

    labels[id] = "";
    locations_option = f.startinglocations $";"$ f.goals;
    helptexts[id] = "Randomize goal locations, starting locations, or both";
    EnumOptionString(id, "Randomize Goal and Starting Locations", "100;100", writing, locations_option);
    EnumOptionString(id, "Randomize Starting Locations", "100;0", writing, locations_option);
    EnumOptionString(id, "Randomize Goal Locations", "0;100", writing, locations_option);
    EnumOptionString(id, "Unchanged Goal and Starting Locations", "0;0", writing, locations_option);
    f.startinglocations = UnpackInt(locations_option);
    f.goals = UnpackInt(locations_option);
    id++;

    labels[id] = "Medbots";
    helptexts[id] = "Percentage chance for a medbot to spawn in a map (vanilla is about 14%)";
    Slider(id, f.medbots, 0, 100, writing);
    id++;

    labels[id] = "Repair bots";
    helptexts[id] = "Percentage chance for a repair bot to spawn in a map (vanilla is about 14%)";
    Slider(id, f.repairbots, 0, 100, writing);
    id++;

    labels[id] = "Move Turrets";
    helptexts[id] = "Randomizes locations of turrets, cameras, and security computers for them.";
    Slider(id, f.turrets_move, 0, 100, writing);
    id++;

    labels[id] = "Add Turrets";
    helptexts[id] = "Randomly adds turrets, cameras, and security computers for them.";
    Slider(id, f.turrets_add, 0, 100, writing);
    id++;

    labels[id] = "The Merchant Chance %";
    helptexts[id] = "The chance for The Merchant to appear in each map.";
    Slider(id, f.merchants, 0, 100, writing);
    id++;

    labels[id] = "";
    helptexts[id] = "Help with finding passwords from your notes.";
    EnumOption(id, "Autofill Passwords", 2, writing, f.codes_mode);
    EnumOption(id, "Mark Known Passwords", 1, writing, f.codes_mode);
    EnumOption(id, "No Assistance With Passwords", 0, writing, f.codes_mode);
    id++;

    if( action == "NEXT" ) InvokeNewGameScreen(combatDifficulty, InitDxr());
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
