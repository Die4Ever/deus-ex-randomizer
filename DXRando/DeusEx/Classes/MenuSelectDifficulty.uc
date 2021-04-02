class MenuSelectDifficulty extends DXRMenuBase;

event InitWindow()
{
    Super.InitWindow();
    InitDxr();
    Init(InitDxr());
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
    local float difficulty;
    local DXRFlags f;
    local string sseed;
    local DXRLoadouts loadout;
    local DXRTelemetry t;
    local DXRCrowdControl cc;
    local int temp, i;

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

    labels[id] = "";
    helptexts[id] = "Which items and augs you start with and which are banned.";
    foreach f.AllActors(class'DXRLoadouts', loadout) { break; }
    if( loadout == None )
        EnumOption(id, "Default Loadout", 0, writing, f.loadout);
    else {
        for(i=0; i < 20; i++) {
            if( loadout.GetName(i) == "" ) continue;
            EnumOption(id, loadout.GetName(i), i, writing, f.loadout);
        }
    }
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
        f.skills_reroll_missions = 1;
        f.skills_independent_levels = 0;
        f.minskill = 0;
        f.maxskill = 1;
        f.ammo = 90;
        f.medkits = 90;
        f.biocells = f.medkits;
        f.lockpicks = f.medkits;
        f.multitools = f.medkits;
        f.speedlevel = 4;
        f.startinglocations = 100;
        f.goals = 100;
        f.equipment = 5;
        f.medbots = 100;
        f.repairbots = 100;
        f.turrets_move = 100;
        f.turrets_add = 50;
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
        f.skills_reroll_missions = 5;
        f.skills_independent_levels = 0;
        f.minskill = 25;
        f.maxskill = 150;
        f.ammo = 90;
        f.medkits = 90;
        f.biocells = f.medkits;
        f.lockpicks = f.medkits;
        f.multitools = f.medkits;
        f.speedlevel = 2;
        f.startinglocations = 100;
        f.goals = 100;
        f.equipment = 4;
        f.medbots = 35;
        f.repairbots = 35;
        f.turrets_move = 50;
        f.turrets_add = 30;
    }
    if( EnumOption(id, "Normal", 0, writing) ) {
        difficulty=1.5;
        f.doorsmode = f.keyonlydoors + f.doormutuallyexclusive;
        f.doorsdestructible = 50;
        f.doorspickable = 50;
        f.deviceshackable = 100;
        f.passwordsrandomized = 100;
        f.infodevices = 100;
        f.enemiesrandomized = 30;
        f.skills_disable_downgrades = 0;
        f.skills_reroll_missions = 5;
        f.skills_independent_levels = 0;
        f.minskill = 50;
        f.maxskill = 300;
        f.ammo = 75;
        f.medkits = 70;
        f.biocells = f.medkits;
        f.lockpicks = f.medkits;
        f.multitools = f.medkits;
        f.speedlevel = 1;
        f.startinglocations = 100;
        f.goals = 100;
        f.equipment = 2;
        f.medbots = 25;
        f.repairbots = 25;
        f.turrets_move = 50;
        f.turrets_add = 70;
    }
    if( EnumOption(id, "Hard", 2, writing) ) {
        difficulty=2;
        f.doorsmode = f.keyonlydoors + f.doormutuallyexclusive;
        f.doorsdestructible = 25;
        f.doorspickable = 25;
        f.deviceshackable = 50;
        f.passwordsrandomized = 100;
        f.infodevices = 100;
        f.enemiesrandomized = 40;
        f.skills_disable_downgrades = 5;
        f.skills_reroll_missions = 5;
        f.skills_independent_levels = 100;
        f.minskill = 50;
        f.maxskill = 300;
        f.ammo = 60;
        f.medkits = 60;
        f.biocells = 50;
        f.lockpicks = 50;
        f.multitools = 50;
        f.speedlevel = 1;
        f.startinglocations = 100;
        f.goals = 100;
        f.equipment = 1;
        f.medbots = 20;
        f.repairbots = 20;
        f.turrets_move = 50;
        f.turrets_add = 120;
    }
    if( EnumOption(id, "Extreme", 3, writing) ) {
        difficulty=3;
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
        f.minskill = 50;
        f.maxskill = 400;
        f.ammo = 40;
        f.medkits = 50;
        f.biocells = 30;
        f.lockpicks = 30;
        f.multitools = 30;
        f.speedlevel = 1;
        f.startinglocations = 100;
        f.goals = 100;
        f.equipment = 1;
        f.medbots = 15;
        f.repairbots = 15;
        f.turrets_move = 50;
        f.turrets_add = 200;
    }
    id++;

    labels[id] = "Autosave";
    helptexts[id] = "Saves the game in case you die!";
    EnumOption(id, "Every Entry", 2, writing, f.autosave);
    EnumOption(id, "First Entry", 1, writing, f.autosave);
    EnumOption(id, "Autosaves-Only (Hardcore)", 3, writing, f.autosave);
    EnumOption(id, "Off", 0, writing, f.autosave);
    id++;

    labels[id] = "Crowd Control";
    helptexts[id] = "Let your Twitch viewers troll you or help you!";
    EnumOption(id, "Enabled (Anonymous)", 2, writing, f.crowdcontrol);
    EnumOption(id, "Enabled (With Names)", 1, writing, f.crowdcontrol);
    EnumOption(id, "Disabled", 0, writing, f.crowdcontrol);
    id++;

    foreach f.AllActors(class'DXRTelemetry', t) { break; }
    if( t == None ) t = f.Spawn(class'DXRTelemetry');
    t.CheckConfig();
    temp = Int(t.enabled);
    labels[id] = "Help us improve";
    helptexts[id] = "Send error reports and get notified about updates!";
    if( EnumOption(id, "Enabled", 1, writing, temp) ) {
        t.set_enabled(true);
    }
    if( EnumOption(id, "Disabled", 0, writing, temp) ) {
        t.set_enabled(false);
    }
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
    actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Advanced",Key="ADVANCED")
    Title="DX Rando Options"
    ClientWidth=672
    ClientHeight=357
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
    num_rows=8;
    num_cols=2;
    col_width_odd=160;
    col_width_even=220;
    row_height=20;
    padding_width=20;
    padding_height=10;
}
