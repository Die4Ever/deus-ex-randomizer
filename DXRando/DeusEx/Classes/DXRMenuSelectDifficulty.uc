class DXRMenuSelectDifficulty extends DXRMenuBase;

event InitWindow()
{
    Super.InitWindow();
    InitDxr();
    Init(InitDxr());
}

function BindControls(optional string action)
{
    local float difficulty;
    local DXRFlags f;
    local string sseed;
    local DXRLoadouts loadout;
    local DXRTelemetry t;
    local DXRCrowdControl cc;
    local int temp, i;

    f = InitFlags();

#ifdef vanilla
    NewMenuItem("", "Choose a game mode!");
    EnumOption("Original Story", 0, f.gamemode);
    EnumOption("Entrance Randomization", 1, f.gamemode);
    EnumOption("Horde Mode", 2, f.gamemode);
    //EnumOption("Kill Bob Page (Alpha)", 3, f.gamemode);
    //EnumOption("How About Some Soy Food?", 6, f.gamemode);
    //EnumOption("Max Rando", 7, f.gamemode);
#endif

#ifdef injections
    NewMenuItem("", "Which items and augs you start with and which are banned.");
    foreach f.AllActors(class'DXRLoadouts', loadout) { break; }
    if( loadout == None )
        EnumOption("All Items Allowed", 0, f.loadout);
    else {
        for(i=0; i < 20; i++) {
            if( loadout.GetName(i) == "" ) continue;
            EnumOption(loadout.GetName(i), i, f.loadout);
        }
    }
#endif

    NewMenuItem("Difficulty", "Difficulty determines the default settings for the randomizer."$BR$"Hard is recommended for Deus Ex verterans.");
    if( (InStr(f.VersionString(), "Alpha")>=0 || InStr(f.VersionString(), "Beta")>=0) )
        i=0;
    else
        i=1;

    for( i=i; i < ArrayCount(f.difficulty_names); i++ ) {
        if( f.difficulty_names[i] == "" ) continue;
        EnumOption(f.difficulty_names[i], i, f.difficulty);
    }
#ifndef hx
    // TODO: menus for HX?
    if(writing)
        difficulty = f.SetDifficulty(f.difficulty).CombatDifficulty;
#endif

#ifdef injections
    NewMenuItem("Autosave", "Saves the game in case you die!");
    EnumOption("Every Entry", 2, f.autosave);
    EnumOption("First Entry", 1, f.autosave);
    EnumOption("Autosaves-Only (Hardcore)", 3, f.autosave);
    EnumOption("Off", 0, f.autosave);
#endif

    NewMenuItem("Crowd Control", "Let your Twitch viewers troll you or help you!");
    EnumOption("Enabled (Anonymous)", 2, f.crowdcontrol);
    EnumOption("Enabled (With Names)", 1, f.crowdcontrol);
    EnumOption("Disabled", 0, f.crowdcontrol);

    foreach f.AllActors(class'DXRTelemetry', t) { break; }
    if( t == None ) t = f.Spawn(class'DXRTelemetry');
    t.CheckConfig();
    if(t.enabled && t.death_markers)
        temp = 2;
    else if(t.enabled)
        temp = 1;
    else
        temp = 0;
    NewMenuItem("Online Features", "Death Markers, send error reports,"$BR$" and get notified about updates!");
    if( EnumOption("All Enabled", 2, temp) ) {
        t.set_enabled(true, true);
    }
    if( EnumOption("Enabled, Death Markers Hidden", 1, temp) ) {
        t.set_enabled(true, false);
    }
    if( EnumOption("Disabled", 0, temp) ) {
        t.set_enabled(false, true);
    }

    NewMenuItem("Seed", "Enter a seed if you want to play the same game again.");
    sseed = EditBox("", "1234567890");
    if( sseed != "" ) {
        f.seed = int(sseed);
        dxr.seed = f.seed;
    } else {
        f.RollSeed();
    }

    if(writing) {
        if( action == "ADVANCED" ) NewGameSetup(difficulty);
        else _InvokeNewGameScreen(difficulty, InitDxr());
    }
}

function InvokeNewGameScreen(float difficulty)
{
    _InvokeNewGameScreen(difficulty, InitDxr());
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
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
    num_rows=8;
    num_cols=2;
    col_width_odd=160;
    col_width_even=240;
    row_height=20;
    padding_width=20;
    padding_height=10;
}
