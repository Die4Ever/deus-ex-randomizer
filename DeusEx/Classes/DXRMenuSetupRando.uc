class DXRMenuSetupRando extends DXRMenuBase;

var float combatDifficulty;

event InitWindow()
{
}

function BindControls(bool writing, optional string action)
{
    local DXRFlags f;
    local string doors_option, skills_option;
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
    /*EnumOptionString(id, "All Doors Breakable & Pickable", (f.alldoors+f.doormutuallyexclusive)$";50;50", writing, doors_option);
    EnumOptionString(id, "All Doors Breakable or Pickable", (f.alldoors+f.doormutuallyinclusive)$";100;100", writing, doors_option);
    EnumOptionString(id, "All Doors Breakable", (f.alldoors+f.doorindependent)$";100;0", writing, doors_option);
    EnumOptionString(id, "All Doors Pickable", (f.alldoors+f.doorindependent)$";0;100", writing, doors_option);*/
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

    labels[id] = "Enemy Respawn Seconds";
    helptexts[id] = "(Beta) How many seconds for enemies to respawn. Leave blank or 0 to disable";
    Slider(id, f.enemyrespawn, 0, 100, writing);
    id++;

    labels[id] = "";
    helptexts[id] = "Adjust how skill cost randomization works.";
    //would be nice to have a better way to indicate which option is initially selected here?
    skills_option = f.skills_disable_downgrades $";"$ f.skills_reroll_missions $";"$ f.skills_independent_levels;
    EnumOptionString(id, "Normal Skill Randomization", "0;0;0", writing, skills_option);
    EnumOptionString(id, "Normal Skills Every Mission", "0;1;0", writing, skills_option);
    EnumOptionString(id, "Normal Skills Every 5 Missions", "0;5;0", writing, skills_option);
    EnumOptionString(id, "Blind Skill Randomization", "5;0;100", writing, skills_option);
    EnumOptionString(id, "Blind Skills Every Mission", "5;1;100", writing, skills_option);
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

    labels[id] = "";
    helptexts[id] = "What items are banned";
    EnumOption(id, "No banned items", 0, writing);
    EnumOption(id, "Stick With the Prod", 1, writing);
    EnumOption(id, "Stick With the Prod Plus", 2, writing);
    id++;

    labels[id] = "Ammo Drops %";
    helptexts[id] = "Make ammo more scarce.";
    Slider(id, f.ammo, 0, 100, writing);
    id++;

    labels[id] = "Utility Items Drops %";
    helptexts[id] = "Make medkits, biocells, lockpicks, and multitools more scarce.";
    Slider(id, f.medkits, 0, 100, writing);
    f.biocells = f.medkits;
    f.lockpicks = f.medkits;
    f.multitools = f.medkits;
    id++;

    labels[id] = "Speed Aug Level";
    helptexts[id] = "Start the game with the Speed Enhancement augmentation.";
    Slider(id, f.speedlevel, 0, 3, writing);
    id++;

    labels[id] = "Dancing %";
    helptexts[id] = "How many characters should be dancing.";
    Slider(id, f.dancingpercent, 0, 100, writing);

    if( action == "NEXT" ) InvokeNewGameScreen(combatDifficulty, InitDxr());
}

function DXRando InitDxr()
{
    local DXRando dxr;
    dxr = player.Spawn(class'DXRando');
    dxr.player = player;
    dxr.modules[0] = flags;
    dxr.LoadFlagsModule();
    if( flags == None ) dxr.flags.InitDefaults();
    flags = dxr.flags;
    return dxr;
}

function InvokeNewGameScreen(float difficulty, DXRando dxr)
{
    local DXRMenuScreenNewGame newGame;

    newGame = DXRMenuScreenNewGame(root.InvokeMenuScreen(Class'DXRMenuScreenNewGame'));

    if (newGame != None) {
        newGame.SetDifficulty(difficulty);
        newGame.SetDxr(dxr);
    }
}

function SetDifficulty(float newDifficulty)
{
    combatDifficulty = newDifficulty;
}

defaultproperties
{
    num_rows=12
    num_cols=4
    col_width_odd=160
    col_width_even=140
    row_height=20
    padding_width=20
    padding_height=10
    //actionButtons(0)=(Align=HALIGN_Right,Action=AB_Cancel,Text="|&Back")
    //actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Next",Key="NEXT")
    //actionButtons(2)=(Action=AB_Reset)
    Title="DX Rando Options"
    ClientWidth=672
    ClientHeight=357
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
}
