class DXRMenuSelectDifficulty extends DXRMenuBase;

var string MaxRandoBtnTitle, MaxRandoBtnMessage;
var string AdvancedBtnTitle, AdvancedBtnMessage;
var string ExtremeBtnTitle, ExtremeBtnMessage;
var string ImpossibleBtnTitle, ImpossibleBtnMessage;
var string GameModeBtnTitle, GameModeBtnMessage;
var string AutosaveBtnTitle, AutosaveBtnMessage;
var string SplitsBtnTitle, SplitsBtnMessage;

var int gamemode_enum, loadout_enum, autosave_enum, difficulty_enum, mirroredmaps_wnd;

enum ERandoMessageBoxModes
{
    RMB_MaxRando,
    RMB_Advanced,
    RMB_NewGame,// choosing Extreme or Impossible, or starting with splits with a different flagshash
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
    local string sseed, ts, tht;
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
    for(i=0; i<50; i++) {
        temp = f.GameModeIdForSlot(i);
        if(temp==999999) continue;
        ts = f.GameModeName(temp);
        if(ts != "")
            EnumOption(ts, temp, f.gamemode);
    }

    // KEEP IN SYNC WITH DXRMenuReSetupRando.uc
    loadout_enum = NewMenuItem("Loadout", "Which items and augs you start with and which are banned.");
    foreach f.AllActors(class'DXRLoadouts', loadout) { break; }
    if( loadout == None )
        EnumOption("All Items Allowed", 0, f.loadout);
    else {
        for(i=0; i < 20; i++) {
            temp = loadout.GetIdForSlot(i);
            ts = loadout.GetName(temp);
            tht = loadout.LoadoutHelpText(temp);
            if( ts == "" ) continue;
            EnumOption(ts, temp, f.loadout, tht);
        }
    }

    if( #defined(vmd) )
        difficulty_enum = NewMenuItem("Randomizer Difficulty", "Difficulty determines the default settings for the randomizer."$BR$"Hard is recommended for Deus Ex veterans.");
    else
        difficulty_enum = NewMenuItem("Difficulty", "Difficulty determines the default settings for the randomizer."$BR$"Hard is recommended for Deus Ex veterans.");

    if( f.VersionIsStable() && !#bool(hx) ) {
        i=1;
        if(f.difficulty <= 0) {
            f.difficulty = 1;
        }
    }
    else {
        i=0;
    }

    for( i=i; i < ArrayCount(f.difficulty_names); i++ ) {
        EnumOption(f.DifficultyName(i), i, f.difficulty);
    }// we write the difficulty and gamemode after setting the seed...

#ifdef injections
    // KEEP IN SYNC WITH DXRMenuReSetupRando.uc
    foreach f.AllActors(class'DXRAutosave', autosave) { break; }// need an object to access consts
    autosave_enum = NewMenuItem("Save Behavior", "Saves the game in case you die!");
    EnumOption("Autosave Every Entry", autosave.EveryEntry, f.autosave, GetAutoSaveHelpText(autosave,autosave.EveryEntry));
    EnumOption("Autosave First Entry", autosave.FirstEntry, f.autosave, GetAutoSaveHelpText(autosave,autosave.FirstEntry));
    EnumOption("Autosaves-Only (Hardcore)", autosave.Hardcore, f.autosave, GetAutoSaveHelpText(autosave,autosave.Hardcore));
    EnumOption("Extra Safe (1+GB per playthrough)", autosave.ExtraSafe, f.autosave, GetAutoSaveHelpText(autosave,autosave.ExtraSafe));
    EnumOption("Limited Saves", autosave.LimitedSaves, f.autosave, GetAutoSaveHelpText(autosave,autosave.LimitedSaves));
    EnumOption("Limited Fixed Saves", autosave.FixedSaves, f.autosave, GetAutoSaveHelpText(autosave,autosave.FixedSaves));
    EnumOption("Unlimited Fixed Saves", autosave.UnlimitedFixedSaves, f.autosave, GetAutoSaveHelpText(autosave,autosave.UnlimitedFixedSaves));
    EnumOption("Extreme Limited Fixed Saves", autosave.FixedSavesExtreme, f.autosave, GetAutoSaveHelpText(autosave,autosave.FixedSavesExtreme));
    EnumOption("Autosaves Disabled", autosave.Disabled, f.autosave, GetAutoSaveHelpText(autosave,autosave.Disabled));
#endif

    // KEEP IN SYNC WITH DXRMenuReSetupRando.uc
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
    // KEEP IN SYNC WITH DXRMenuReSetupRando.uc
    mirrored_maps_files_found = class'DXRMapVariants'.static.MirrorMapsAvailable();

    if(mirrored_maps_files_found) {
        mirroredmaps_wnd = NewMenuItem("Mirrored Maps %", "Enable mirrored maps if you have the files downloaded for them.");
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

    NewMenuItem("Seed", "Enter a seed if you want to play the same game again.  Leave it blank for a random seed.");
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
    local int i, temp;
    local string old, s;
    local DXRFlags f;
    local bool oldZeroRando;

    // HACK: this allows you to override the autosave option instead of SetDifficulty forcing it by game mode
    old = Super.SetEnumValue(e, text);
    if(text == old) return old;

    if(e == gamemode_enum && autosave_enum != 0) {
        if(InStr(text, "Halloween")!=-1)
        {
            Super.SetEnumValue(autosave_enum, "Limited Fixed Saves");
        }
        else if(InStr(text, "Hardcore")==-1 && InStr(text, "Horde")==-1)
        {
            Super.SetEnumValue(autosave_enum, "Autosave Every Entry");
        }
    }
    if(e == gamemode_enum) {
        f = GetFlags();
        oldZeroRando = f.IsZeroRando();
        for(i=0; i<50; i++) {
            temp = f.GameModeIdForSlot(i);
            if(temp==999999) continue;
            if(f.GameModeName(temp) == text) {
                f.gamemode = temp;
            }
        }
        if(f.IsZeroRando() != oldZeroRando) {
            i = 0;
            if( f.VersionIsStable() && !#bool(hx)) {
                i = 1;
            }
            for( i=i; i < ArrayCount(f.difficulty_names); i++ ) {
                enums[difficulty_enum].values[i] = f.DifficultyName(i);
            }
            Super.SetEnumValue(difficulty_enum, f.DifficultyName(1));

            if(f.IsZeroRando() && mirroredmaps_wnd>0) {
                MenuUIEditWindow(wnds[mirroredmaps_wnd]).SetText("0");
            }
        }
        if(f.IsSpeedrunMode() && InStr(GetEnumValue(loadout_enum), "All Items Allowed")!=-1)
        {
            Super.SetEnumValue(loadout_enum, "Speed Enhancement");
        }
    }

    return old;
}

function EnumListAddButton(DXREnumList list, string title, string val, string help, string prev)
{
    if(title == "Game Mode") {
        if(InStr(prev, "WaltonWare")==-1 && InStr(val, "WaltonWare")!=-1) {
            list.CreateLabel("Bingo modes");
        }
        else if(InStr(prev, "Zero Rando")==-1 && InStr(val, "Zero Rando")!=-1) {
            list.CreateLabel("Reduced Randomization modes");
        } else if(prev == "Randomizer Medium") {
            list.CreateLabel("Other game modes");
        }
    }
    list.AddButton(val, help);
}

function HandleNewGameButton()
{
    local string s;
    local DXRFlags f;
    f = GetFlags();

    if(!class'HUDSpeedrunSplits'.static.CheckFlags(f)) {
        nextScreenNum=RMB_NewGame;
        class'BingoHintMsgBox'.static.Create(root, SplitsBtnTitle,SplitsBtnMessage,0,False,Self);
    }
    else if(dxr.rando_beaten == 0 && f.DifficultyName(f.difficulty) ~= "Extreme") {
        nextScreenNum=RMB_NewGame;
        class'BingoHintMsgBox'.static.Create(root, ExtremeBtnTitle,ExtremeBtnMessage,0,False,Self);
    }
    else if(dxr.rando_beaten == 0 && f.DifficultyName(f.difficulty) ~= "Impossible") {
        nextScreenNum=RMB_NewGame;
        class'BingoHintMsgBox'.static.Create(root, ImpossibleBtnTitle,ImpossibleBtnMessage,0,False,Self);
    }
    else if(dxr.rando_beaten == 0 && autosave_enum>0 && GetEnumValue(autosave_enum)!="Autosave Every Entry" && GetEnumValue(autosave_enum)!="Extra Safe (1+GB per playthrough)") {
        nextScreenNum=RMB_NewGame;
        s = Sprintf(AutosaveBtnMessage, GetEnumValue(autosave_enum));
        class'BingoHintMsgBox'.static.Create(root, AutosaveBtnTitle, s, 0, False, self);
    }
    else if(dxr.rando_beaten == 0 && f.GameModeName(f.gamemode) != "Normal Randomizer" && !f.IsReducedRando()) {
        nextScreenNum=RMB_NewGame;
        s = Sprintf(GameModeBtnMessage, f.GameModeName(f.gamemode));
        class'BingoHintMsgBox'.static.Create(root, GameModeBtnTitle, s, 0, False, self);
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
        class'BingoHintMsgBox'.static.Create(root, MaxRandoBtnTitle,MaxRandoBtnMessage,0,False,Self);
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
        case RMB_NewGame:
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

#ifdef injections
static function string GetAutoSaveHelpText(DXRAutosave autosave, coerce int choice)
{
    switch (choice)
    {
        case autosave.EveryEntry:
            return "The game will automatically save after every level transition.  You are allowed to save manually whenever you would like.  Autosaves are cleared when you progress to the next mission.";
        case autosave.FirstEntry:
            return "The game will only automatically save the first time you enter a new level.  You are allowed to save manually whenever you would like.  Autosaves are cleared when you progress to the next mission.";
        case autosave.Hardcore:
            return "The game will automatically save the first time you enter a level.  No manual saves are allowed.  Autosaves are cleared when you progress to the next mission.";
        case autosave.ExtraSafe:
            return "The game will automatically save after every level transition.  You are allowed to save manually whenever you would like.  Autosaves are never cleared.";
        case autosave.LimitedSaves:
            return "The game will only autosave once at the start of the game.  Manual saves are allowed at any time, but require a Memory Containment Unit.  Memory Containment Units can be found randomly placed around levels.";
        case autosave.FixedSaves:
            return "The game will only autosave once at the start of the game.  Manual saves are only allowed when looking at a computer and require a Memory Containment Unit.  Memory Containment Units can be found randomly placed around levels.";
        case autosave.UnlimitedFixedSaves:
            return "The game will only autosave once at the start of the game.  Manual saves are only allowed when looking at a computer, but you are allowed to save as much as you would like.";
        case autosave.FixedSavesExtreme:
            return "The game will only autosave once at the start of the game.  Manual saves are only allowed when looking at a computer and require two(?) Memory Containment Units.  Memory Containment Units can be found randomly placed around levels.";
        case autosave.Disabled:
            return "The game will not automatically save.  You are allowed to save manually whenever you would like.";
        default:
            return ""; //This will mean the help button won't appear
    }
}
#endif

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
    MaxRandoBtnMessage="It appears you're new to DX Randomizer.|n|nMax Rando will randomize all the settings, including ammo and equipment scarcity, which will likely result in a bad first time experience.|nBy continuing, you waive your right to ragequit.|n|nAre you sure you want to proceed?"
    AdvancedBtnTitle="Advanced Settings?"
    AdvancedBtnMessage="It appears you're new to DX Randomizer.|n|nWe recommend playing with default settings for a better first time experience.|nBy continuing, you waive your right to ragequit.|n|nAre you sure you want to adjust advanced settings?"
    ExtremeBtnTitle="Extreme Difficulty?"
    ExtremeBtnMessage="It appears you're new to DX Randomizer.|n|nExtreme difficulty means fewer items, less ammo, more enemies, higher skill costs, fewer medbots, and many other challenges.|nBy continuing, you waive your right to ragequit.|n|nAre you sure you want to play Extreme difficulty?"
    ImpossibleBtnTitle="Impossible Difficulty?"
    ImpossibleBtnMessage="It appears you're new to DX Randomizer.|n|nImpossible difficulty means fewer items, less ammo, more enemies, higher skill costs, fewer medbots, and many other challenges.|nBy continuing, you waive your right to ragequit.|n|nAre you sure you want to play Impossible difficulty?"
    GameModeBtnTitle="Advanced Game Mode?"
    GameModeBtnMessage="It appears you're new to DX Randomizer.|n|nThis game mode is confusing and difficult for new DXRando players.  We suggest starting with Normal Randomizer or one of the Reduced Randomization modes instead.|nBy continuing, you waive your right to ragequit.|n|nAre you sure you want to continue with %s?"
    AutosaveBtnTitle="Autosave?"
    AutosaveBtnMessage="It appears you're new to DX Randomizer.|n|nWe suggest starting with the default option for Autosave Every Entry.|nBy continuing, you waive your right to ragequit.|n|nAre you sure you want to continue with %s?"
    SplitsBtnTitle="Mismatched Splits!"
    SplitsBtnMessage="It appears that your DXRSplits.ini file is for different settings than this.|n|nAre you sure you want to continue?"
}
