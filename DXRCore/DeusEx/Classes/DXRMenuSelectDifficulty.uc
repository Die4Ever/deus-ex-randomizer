class DXRMenuSelectDifficulty extends DXRMenuBase;

var string MaxRandoBtnTitle, MaxRandoBtnMessage;
var string AdvancedBtnTitle, AdvancedBtnMessage;
var string ExtremeBtnTitle, ExtremeBtnMessage;
var string ImpossibleBtnTitle, ImpossibleBtnMessage;

var int gamemode_enum, autosave_enum;

enum ERandoMessageBoxModes
{
    RMB_MaxRando,
    RMB_Advanced,
    RMB_Difficulty,// choosing Extreme or Impossible
};
var ERandoMessageBoxModes nextScreenNum;

event InitWindow()
{
    Super.InitWindow();
    GetDxr();
    Init(GetDxr());
}

function BindControls(optional string action)
{
    local float difficulty;
    local DXRFlags f;
    local string sseed, ts;
    local DXRLoadouts loadout;
    local DXRTelemetry t;
    local DXRCrowdControl cc;
    local int temp, i;
#ifdef injections
    local DXRAutosave autosave;
    local bool mirrored_maps_files_found;
#endif

    f = GetFlags();
    if(writing) {
        f.InitAdvancedDefaults();
    }

    gamemode_enum = NewMenuItem("Game Mode", "Choose a game mode!");
    for(i=0; i<20; i++) {
        temp = f.GameModeIdForSlot(i);
        if(temp==999999) continue;
        ts = f.GameModeName(temp);
        if(ts != "")
            EnumOption(ts, temp, f.gamemode);
    }

    NewMenuItem("Loadout", "Which items and augs you start with and which are banned.");
    foreach f.AllActors(class'DXRLoadouts', loadout) { break; }
    if( loadout == None )
        EnumOption("All Items Allowed", 0, f.loadout);
    else {
        for(i=0; i < 20; i++) {
            temp = loadout.GetIdForSlot(i);
            ts = loadout.GetName(temp);
            if( ts == "" ) continue;
            EnumOption(ts, temp, f.loadout);
        }
    }

    if( #defined(vmd) )
        NewMenuItem("Randomizer Difficulty", "Difficulty determines the default settings for the randomizer."$BR$"Hard is recommended for Deus Ex veterans.");
    else
        NewMenuItem("Difficulty", "Difficulty determines the default settings for the randomizer."$BR$"Hard is recommended for Deus Ex veterans.");

    if( f.VersionIsStable() ) {
        i=1;
        if(f.difficulty == 0) {
            f.difficulty = 1;
        }
    }
    else {
        i=0;
    }

    for( i=i; i < ArrayCount(f.difficulty_names); i++ ) {
        if( f.difficulty_names[i] == "" ) continue;
        EnumOption(f.difficulty_names[i], i, f.difficulty);
    }// we write the difficulty and gamemode after setting the seed...

#ifdef injections
    foreach f.AllActors(class'DXRAutosave', autosave) { break; }// need an object to access consts
    autosave_enum = NewMenuItem("Save Behavior", "Saves the game in case you die!");
    EnumOption("Autosave Every Entry", autosave.EveryEntry, f.autosave);
    EnumOption("Autosave First Entry", autosave.FirstEntry, f.autosave);
    EnumOption("Autosaves-Only (Hardcore)", autosave.Hardcore, f.autosave);
    EnumOption("Extra Safe (1+GB per playthrough)", autosave.ExtraSafe, f.autosave);
    EnumOption("Limited Saves", autosave.LimitedSaves, f.autosave);
    EnumOption("Limited Fixed Saves", autosave.FixedSaves, f.autosave);
    EnumOption("Unlimited Fixed Saves", autosave.UnlimitedFixedSaves, f.autosave);
    EnumOption("Extreme Limited Fixed Saves", autosave.FixedSavesExtreme, f.autosave);
    EnumOption("Autosaves Disabled", autosave.Disabled, f.autosave);
#endif

    NewMenuItem("Crowd Control", "Let your Twitch/YouTube/Discord viewers troll you or help you!" $BR$ "See their website crowdcontrol.live");
    //EnumOption("Enabled (Anonymous)", 2, f.crowdcontrol);
    EnumOption("Enabled (Streaming)", 1, f.crowdcontrol);
    EnumOption("Offline Simulated", 3, f.crowdcontrol);
    EnumOption("Streaming and Simulated", 4, f.crowdcontrol);
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

#ifdef injections
    mirrored_maps_files_found = class'DXRMapVariants'.static.MirrorMapsAvailable();

    if(mirrored_maps_files_found) {
        NewMenuItem("Mirrored Maps %", "Enable mirrored maps if you have the files downloaded for them.");
        if(f.mirroredmaps == -1 && f.IsZeroRando()) {
            f.mirroredmaps = 0; // default to 0% because of Zero Rando
        } else if(f.mirroredmaps == -1) {
            f.mirroredmaps = 50; // default to 50% when the files are installed
        }
        Slider(f.mirroredmaps, 0, 100);
    } else {
        // use -1 to indicate not installed, because this gets saved to the config
        f.mirroredmaps = -1;
        NewMenuItem("", "Use the installer to download the mirrored map files, or go to the unreal-map-flipper Releases page on Github");
        EnumOption("Mirror Map Files Not Found", -1, f.mirroredmaps);
    }
#else
    //Disable mirrored maps entirely if map variants aren't supported
    f.mirroredmaps=-1;
#endif

    NewMenuItem("Seed", "Enter a seed if you want to play the same game again. Leave it blank for a random seed.");
    sseed = EditBox("", "1234567890");
    if( sseed != "" ) {
        f.seed = int(sseed);
        dxr.seed = f.seed;
        f.bSetSeed = 1;
    } else {
        f.RollSeed();
    }

    if(writing) {
        // need to call flags.SetDifficulty to apply the game mode's and difficulty's settings, after setting the seed and before going to the next screen
        f.SetDifficulty(f.difficulty);
        if( action == "ADVANCED" ) {
            HandleAdvancedButton();
        }
        else if( action == "MAXRANDO" ) {
            HandleMaxRandoButton();
        }
        else {
            HandleNewGameButton();
        }
    }
}

function string SetEnumValue(int e, string text)
{
    // HACK: this allows you to override the autosave option instead of SetDifficulty forcing it by game mode
    Super.SetEnumValue(e, text);
    if(e == gamemode_enum && #defined(injections)) {
        if(InStr(text, "Halloween")!=-1)
        {
            Super.SetEnumValue(autosave_enum, "Limited Fixed Saves");
        }
        else if(InStr(text, "Hardcore")==-1 && InStr(text, "Horde")==-1)
        {
            Super.SetEnumValue(autosave_enum, "Autosave Every Entry");
        }
    }
}

function EnumListAddButton(DXREnumList list, string title, string val, string prev)
{
    if(title == "Game Mode") {
        if(InStr(prev, "WaltonWare")==-1 && InStr(val, "WaltonWare")!=-1) {
            list.CreateLabel("WaltonWare modes");
        }
        else if(InStr(prev, "Zero Rando")==-1 && InStr(val, "Zero Rando")!=-1) {
            list.CreateLabel("Reduced Randomization modes");
        } else if(prev == "Randomizer Medium") {
            list.CreateLabel("Other game modes");
        }
    }
    list.AddButton(val);
}

function HandleNewGameButton()
{
    local DXRFlags f;
    f = GetFlags();

    if(dxr.rando_beaten == 0 && f.DifficultyName(f.difficulty) ~= "Extreme") {
        nextScreenNum=RMB_Difficulty;
        root.MessageBox(ExtremeBtnTitle,ExtremeBtnMessage,0,False,Self);
    }
    else if(dxr.rando_beaten == 0 && f.DifficultyName(f.difficulty) ~= "Impossible") {
        nextScreenNum=RMB_Difficulty;
        root.MessageBox(ImpossibleBtnTitle,ImpossibleBtnMessage,0,False,Self);
    }
    else {
        DoNewGameScreen();
    }
}

function DoNewGameScreen()
{
    local float difficulty;
    local DXRFlags f;
    f = GetFlags();
#ifndef hx
        // TODO: menus for HX?
        difficulty = f.settings.CombatDifficulty;
#endif

    _InvokeNewGameScreen(difficulty);
}

function HandleMaxRandoButton()
{
    if (dxr.rando_beaten != 0){
        DoMaxRandoButtonConfirm();
    } else {
        nextScreenNum=RMB_MaxRando;
        root.MessageBox(MaxRandoBtnTitle,MaxRandoBtnMessage,0,False,Self);
    }
}

function DoMaxRandoButtonConfirm()
{
    local DXRFlags f;
    f = GetFlags();
    f.ExecMaxRando();
    DoNewGameScreen();
}

function HandleAdvancedButton()
{
    if (dxr.rando_beaten != 0){
        DoAdvancedButtonConfirm();
    } else {
        nextScreenNum=RMB_Advanced;
        root.MessageBox(AdvancedBtnTitle,AdvancedBtnMessage,0,False,Self);
    }
}

function DoAdvancedButtonConfirm()
{
#ifndef hx
    NewGameSetup(GetFlags().settings.CombatDifficulty);
#endif
}

event bool BoxOptionSelected(Window button, int buttonNumber)
{
    root.PopWindow();

    switch (nextScreenNum){
        case RMB_MaxRando:
            if (buttonNumber==0){
                DoMaxRandoButtonConfirm();
            }
            return true;
        case RMB_Advanced:
            if (buttonNumber==0){
                DoAdvancedButtonConfirm();
            }
            return true;
        case RMB_Difficulty:
            if (buttonNumber==0){
                DoNewGameScreen();
            }
            return true;
    }

    return Super.BoxOptionSelected(button,buttonNumber);
}

event DestroyWindow()
{
    if(#defined(vmd)) {
        Player.ConsoleCommand("Open DXOnly");
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
    actionButtons(3)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Max Rando",Key="MAXRANDO")
    Title="DX Rando Options"
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
    num_rows=9
    num_cols=2
    col_width_odd=140
    col_width_even=260
    row_height=20
    padding_width=20
    padding_height=10
    MaxRandoBtnTitle="Are you sure?"
    MaxRandoBtnMessage="It appears you're new to DX Randomizer.  Max Rando will randomize all the settings, which will likely result in a bad first time experience.  Are you sure you want to proceed?"
    AdvancedBtnTitle="Advanced Settings?"
    AdvancedBtnMessage="It appears you're new to DX Randomizer.  We recommend playing with default settings for a better first time experience.  Are you sure you want to adjust advanced settings?"
    ExtremeBtnTitle="Extreme Difficulty?"
    ExtremeBtnMessage="It appears you're new to DX Randomizer.  Extreme difficulty means fewer items, less ammo, more enemies, higher skill costs, fewer medbots, and many other challenges.  Are you sure?"
    ImpossibleBtnTitle="Impossible Difficulty?"
    ImpossibleBtnMessage="It appears you're new to DX Randomizer.  Impossible difficulty means fewer items, less ammo, more enemies, higher skill costs, fewer medbots, and many other challenges.  Are you sure?"
}
