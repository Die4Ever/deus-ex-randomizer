class MenuSelectDifficulty extends DXRMenuBase;

event InitWindow()
{
    Super.InitWindow();
    InitDxr();
    Init(InitDxr());
}

function BindControls(bool writing, optional string action)
{
    local float difficulty;
    local DXRFlags f;
    local string sseed;
    Super.BindControls(writing);

    f = InitFlags();

    labels[id] = "";
    helptexts[id] = "Choose a game mode!";
    EnumOption(id, "Original Story", 0, writing, f.gamemode);
    EnumOption(id, "Original Story, Rearranged Levels (Beta)", 1, writing, f.gamemode);
    EnumOption(id, "Horde Mode (Beta)", 2, writing, f.gamemode);
    //EnumOption(id, "Kill Bob Page (Alpha)", 3, writing, f.gamemode);
    //EnumOption(id, "How About Some Soy Food?", 6, writing, f.gamemode);
    //EnumOption(id, "Max Rando", 7, writing, f.gamemode);
    id++;

    labels[id] = "Difficulty";
    helptexts[id] = "Difficulty determines the default settings for the randomizer.";
    if( (InStr(f.VersionString(), "Alpha")>=0 || InStr(f.VersionString(), "Beta")>=0) && EnumOption(id, "Super Easy QA", 1, writing) ) {
        difficulty=0;
        f.doorsmode = f.keyonlydoors + f.doormutuallyinclusive;
        f.doorsdestructible = 100;
        f.doorspickable = 100;
        f.deviceshackable = 100;
        f.passwordsrandomized = 100;
        f.infodevices = 100;
        f.enemiesrandomized = 20;
        f.skills_disable_downgrades = 0;
        f.skills_reroll_missions = 0;
        f.skills_independent_levels = 0;
        f.minskill = 0;
        f.maxskill = 1;
        f.ammo = 100;
        f.medkits = 100;
        f.biocells = f.medkits;
        f.lockpicks = f.medkits;
        f.multitools = f.medkits;
        f.speedlevel = 4;
        f.startinglocations = 100;
        f.goals = 100;
        f.equipment = 5;
        f.medbots = 100;
        f.repairbots = 100;
    }
    if( EnumOption(id, "Easy", 1, writing) ) {
        difficulty=1;
        f.doorsmode = f.keyonlydoors + f.doormutuallyinclusive;
        f.doorsdestructible = 100;
        f.doorspickable = 100;
        f.deviceshackable = 100;
        f.passwordsrandomized = 100;
        f.infodevices = 100;
        f.enemiesrandomized = 20;
        f.skills_disable_downgrades = 0;
        f.skills_reroll_missions = 0;
        f.skills_independent_levels = 0;
        f.minskill = 25;
        f.maxskill = 200;
        f.ammo = 100;
        f.medkits = 100;
        f.biocells = f.medkits;
        f.lockpicks = f.medkits;
        f.multitools = f.medkits;
        f.speedlevel = 2;
        f.startinglocations = 100;
        f.goals = 100;
        f.equipment = 2;
        f.medbots = 20;
        f.repairbots = 20;
    }
    if( EnumOption(id, "Normal", 0, writing) ) {
        difficulty=1.25;
        f.doorsmode = f.keyonlydoors + f.doormutuallyexclusive;
        f.doorsdestructible = 50;
        f.doorspickable = 50;
        f.deviceshackable = 100;
        f.passwordsrandomized = 100;
        f.infodevices = 100;
        f.enemiesrandomized = 35;
        f.skills_disable_downgrades = 0;
        f.skills_reroll_missions = 0;
        f.skills_independent_levels = 0;
        f.minskill = 25;
        f.maxskill = 300;
        f.ammo = 80;
        f.medkits = 80;
        f.biocells = f.medkits;
        f.lockpicks = f.medkits;
        f.multitools = f.medkits;
        f.speedlevel = 1;
        f.startinglocations = 100;
        f.goals = 100;
        f.equipment = 1;
        f.medbots = 15;
        f.repairbots = 15;
    }
    if( EnumOption(id, "Hard", 2, writing) ) {
        difficulty=1.5;
        f.doorsmode = f.keyonlydoors + f.doormutuallyexclusive;
        f.doorsdestructible = 25;
        f.doorspickable = 25;
        f.deviceshackable = 50;
        f.passwordsrandomized = 100;
        f.infodevices = 100;
        f.enemiesrandomized = 50;
        f.skills_disable_downgrades = 5;
        f.skills_reroll_missions = 5;
        f.skills_independent_levels = 100;
        f.minskill = 25;
        f.maxskill = 300;
        f.ammo = 70;
        f.medkits = 70;
        f.biocells = f.medkits;
        f.lockpicks = f.medkits;
        f.multitools = f.medkits;
        f.speedlevel = 1;
        f.startinglocations = 100;
        f.goals = 100;
        f.equipment = 1;
        f.medbots = 10;
        f.repairbots = 10;
    }
    if( EnumOption(id, "Extreme", 3, writing) ) {
        difficulty=2;
        f.doorsmode = f.keyonlydoors + f.doormutuallyexclusive;
        f.doorsdestructible = 25;
        f.doorspickable = 25;
        f.deviceshackable = 50;
        f.passwordsrandomized = 100;
        f.infodevices = 100;
        f.enemiesrandomized = 70;
        f.skills_disable_downgrades = 5;
        f.skills_reroll_missions = 5;
        f.skills_independent_levels = 100;
        f.minskill = 25;
        f.maxskill = 400;
        f.ammo = 50;
        f.medkits = 50;
        f.biocells = f.medkits;
        f.lockpicks = f.medkits;
        f.multitools = f.medkits;
        f.speedlevel = 1;
        f.startinglocations = 100;
        f.goals = 100;
        f.equipment = 1;
        f.medbots = 5;
        f.repairbots = 5;
    }
    id++;

    labels[id] = "Autosave";
    helptexts[id] = "Saves the game in case you die!";
    EnumOption(id, "Every Entry", 2, writing, f.autosave);
    EnumOption(id, "First Entry", 1, writing, f.autosave);
    EnumOption(id, "Off", 0, writing, f.autosave);
    id++;

    labels[id] = "";
    helptexts[id] = "What items are banned";
    EnumOption(id, "No items banned", 0, writing, f.banneditems);
    EnumOption(id, "Stick With the Prod", 1, writing, f.banneditems);
    EnumOption(id, "Stick With the Prod Plus", 2, writing, f.banneditems);
    //EnumOption(id, "Don't Give Me The GEP Gun", 3, writing, f.banneditems);//maybe I can request these from a function like class'DXRBannedItems'.static.GetBannedItemsDescription()
    id++;

    labels[id] = "Seed";
    helptexts[id] = "Enter a seed if you want to play the same game again.";
    sseed = EditBox(id, "", "1234567890", writing);
    if( sseed != "" ) {
        f.seed = int(sseed);
        dxr.seed = f.seed;
    } else {
        f.RollSeed();
    }
    id++;

    if(writing) {
        if( action == "ADVANCED" ) NewGameSetup(difficulty);
        else InvokeNewGameScreen(difficulty, InitDxr());
    }
}

function NewGameSetup(float difficulty)
{
    local DXRMenuSetupRando newGame;

    newGame = DXRMenuSetupRando(root.InvokeMenuScreen(Class'DXRMenuSetupRando'));

    if (newGame != None) {
        newGame.SetDifficulty(difficulty);
        newGame.Init(dxr);
    }
}

defaultproperties
{
    num_rows=6
    num_cols=2
    col_width_odd=160
    col_width_even=220
    row_height=20
    padding_width=20
    padding_height=10
    actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Advanced",Key="ADVANCED")
    Title="DX Rando Options"
    ClientWidth=672
    ClientHeight=357
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
}
