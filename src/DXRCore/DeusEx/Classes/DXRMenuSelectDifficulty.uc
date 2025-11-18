class DXRMenuSelectDifficulty extends DXRMenuBase;

var string MaxRandoBtnTitle, MaxRandoBtnMessage;
var string AdvancedBtnTitle, AdvancedBtnMessage;
var string ExtremeBtnTitle, ExtremeBtnMessage;
var string ImpossibleBtnTitle, ImpossibleBtnMessage;
var string GameModeBtnTitle, GameModeBtnMessage;
var string AutosaveBtnTitle, AutosaveBtnMessage;
var string SplitsBtnTitle, SplitsBtnMessage;

var config bool shownMaxRandoWarning;

var int gamemode_enum, loadout_enum, autosave_enum, difficulty_enum, mirroredmaps_wnd;

enum ERandoMessageBoxModes
{
    RMB_None,
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
    if(dxr.rando_beaten < 1) {
        actionButtons[3].btn.Hide();
    }
}

function BindControls(optional string action)
{
    local float difficulty;
    local DXRFlags f;
    local string sseed, name, help;
    local int temp, i;

    f = GetFlags();
    if(writing) {
        f.InitAdvancedDefaults();
    }

    gamemode_enum = NewMenuItem("Game Mode", "Choose a game mode!");
    for(i=0; i<50; i++) {
        temp = f.GameModeIdForSlot(i);
        if(temp==999999) continue;
        name = f.GameModeName(temp);
        if(name == "") continue;
        help = f.GameModeHelpText(temp);
        EnumOption(name, temp, f.gamemode, help);
    }

    loadout_enum = CreateLoadoutEnum(self, f);

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
        EnumOption(f.DifficultyName(i), i, f.difficulty, "placeholder so the ? button gets created");
    }// we call SetDifficulty to apply the difficulty and game mode after setting the seed, below

    autosave_enum = CreateAutosaveEnum(self, f);
    CreateCrowdControlEnum(self, f);
    CreateOnlineFeaturesEnum(self, f);
    mirroredmaps_wnd = CreateMirroredMapsSlider(self, f);

    NewMenuItem("Seed", "Enter a seed if you want to play the same game again.  Leave it blank for a random seed.");
    sseed = EditBox("", "1234567890", GetSeedHelpText());
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

static function int CreateLoadoutEnum(DXRMenuBase slf, DXRFlags f)
{
    local DXRLoadouts loadout;
    local int loadout_enum, slot, id;
    local string name, help;

    loadout_enum = slf.NewMenuItem("Loadout", "Which items and augs you start with and which are banned.");
    foreach f.AllActors(class'DXRLoadouts', loadout) { break; }
    if( loadout == None )
        slf.EnumOption("All Items Allowed", 0, f.loadout);
    else {
        for(slot = 0; slot < 30; slot++) {
            id = loadout.GetIdForSlot(slot);
            if(id < 0) break;
            name = loadout.GetName(id);
            help = loadout.LoadoutHelpText(id);
            if( name == "" ) continue;
            slf.EnumOption(name, id, f.loadout, help);
        }
    }
    return loadout_enum;
}

static function int CreateAutosaveEnum(DXRMenuBase slf, DXRFlags f)
{
#ifdef injections
    local DXRAutosave autosave;
    local int in_autosave_enum;

    foreach f.AllActors(class'DXRAutosave', autosave) { break; }// need an object to access consts
    in_autosave_enum = slf.NewMenuItem("Save Behavior", "Saves the game in case you die!");
    slf.EnumOption("Autosaves Enabled", autosave.EveryEntry, f.autosave, autosave.GetAutoSaveHelpText(autosave.EveryEntry));
    //slf.EnumOption("Autosaves-Only (Hardcore)", autosave.Hardcore, f.autosave, autosave.GetAutoSaveHelpText(autosave.Hardcore));
    slf.EnumOption("Limited Saves", autosave.LimitedSaves, f.autosave, autosave.GetAutoSaveHelpText(autosave.LimitedSaves));
    slf.EnumOption("Limited Fixed Saves", autosave.FixedSaves, f.autosave, autosave.GetAutoSaveHelpText(autosave.FixedSaves));
    slf.EnumOption("Unlimited Fixed Saves", autosave.UnlimitedFixedSaves, f.autosave, autosave.GetAutoSaveHelpText(autosave.UnlimitedFixedSaves));
    slf.EnumOption("Extreme Limited Fixed Saves", autosave.FixedSavesExtreme, f.autosave, autosave.GetAutoSaveHelpText(autosave.FixedSavesExtreme));
    slf.EnumOption("Autosaves Disabled", autosave.Disabled, f.autosave, autosave.GetAutoSaveHelpText(autosave.Disabled));
    slf.EnumOption("Ironman (All Saves Disallowed)", autosave.Ironman, f.autosave, autosave.GetAutoSaveHelpText(autosave.Ironman));

    return in_autosave_enum;
#endif
}

static function int CreateCrowdControlEnum(DXRMenuBase slf, DXRFlags f)
{
    local int e;

    e = slf.NewMenuItem("Crowd Control", "Let your Twitch/YouTube/Discord viewers troll you or help you!" $Chr(10)$ "See their website crowdcontrol.live");
    //EnumOption("Enabled (Anonymous)", 2, f.crowdcontrol, GetCrowdControlHelpText(2));
    slf.EnumOption("Enabled (Streaming)", 1, f.crowdcontrol, GetCrowdControlHelpText(1));
    slf.EnumOption("Offline Simulated", 3, f.crowdcontrol, GetCrowdControlHelpText(3));
    slf.EnumOption("Streaming and Simulated", 4, f.crowdcontrol, GetCrowdControlHelpText(4));
    slf.EnumOption("Disabled", 0, f.crowdcontrol, GetCrowdControlHelpText(0));
    return e;
}

static function int CreateOnlineFeaturesEnum(DXRMenuBase slf, DXRFlags f)
{
    local DXRTelemetry t;
    local int temp, e;

    foreach f.AllActors(class'DXRTelemetry', t) { break; }
    if( t == None ) t = f.Spawn(class'DXRTelemetry');
    t.CheckConfig();
    if(t.enabled && t.death_markers)
        temp = 2;
    else if(t.enabled)
        temp = 1;
    else
        temp = 0;
    e = slf.NewMenuItem("Online Features", "Death Markers, send error reports,"$Chr(10)$" and get notified about updates!");
    if( slf.EnumOption("All Enabled", 2, temp, GetOnlineFeaturesHelpText(2)) ) {
        t.set_enabled(true, true);
    }
    if( slf.EnumOption("Enabled, Death Markers Hidden", 1, temp, GetOnlineFeaturesHelpText(1)) ) {
        t.set_enabled(true, false);
    }
    if( slf.EnumOption("Disabled", 0, temp, GetOnlineFeaturesHelpText(0)) ) {
        t.set_enabled(false, true);
    }
    return e;
}

static function int CreateMirroredMapsSlider(DXRMenuBase slf, DXRFlags f)
{
    local bool mirrored_maps_files_found;
    local int mirroredmaps_wnd;
#ifdef injections
    mirrored_maps_files_found = class'DXRMapVariants'.static.MirrorMapsAvailable();

    if(mirrored_maps_files_found) {
        mirroredmaps_wnd = slf.NewMenuItem("Mirrored Maps %", "Enable mirrored maps if you have the files downloaded for them.");
        if(f.mirroredmaps == -1 && f.IsZeroRando()) {
            f.mirroredmaps = 0; // default to 0% because of Zero Rando
        } else if(f.mirroredmaps == -1) {
            f.mirroredmaps = 50; // default to 50% when the files are installed
        }
        slf.Slider(f.mirroredmaps, 0, 100,GetMirroredMapsHelpText(true));
    } else {
        // use -1 to indicate not installed, because this gets saved to the config
        f.mirroredmaps = -1;
        slf.NewMenuItem("", "Use the installer to download the mirrored map files, or go to the unreal-map-flipper Releases page on Github");
        slf.EnumOption("Mirror Map Files Not Found", -1, f.mirroredmaps, GetMirroredMapsHelpText(false));
    }
#else
    //Disable mirrored maps entirely if map variants aren't supported
    f.mirroredmaps=-1;
#endif
    return mirroredmaps_wnd;
}

function string GetHelpText(DXRMenuUIHelpButtonWindow helpButton)
{
    local DXRFlags f;
    local int i;
    local string s;

    if(helpButton.row == difficulty_enum) {
        s = GetEnumValue(difficulty_enum);
        f = GetFlags();
        for( i=0; i < ArrayCount(f.difficulty_names); i++ ) {
            if(s == f.DifficultyName(i)) {
                f.SetDifficulty(i);
                break;
            }
        }
        return f.DifficultyDesc(f.difficulty);
    }
    return helpButton.GetHelpText();
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
            Super.SetEnumValue(autosave_enum, "Autosaves Enabled");
        }
        else if(InStr(text, "Hardcore")!=-1)
        {
            Super.SetEnumValue(autosave_enum, "Ironman (All Saves Disallowed)");
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
            f.difficulty = 1;

            if(f.IsZeroRando() && mirroredmaps_wnd>0) {
                MenuUIEditWindow(wnds[mirroredmaps_wnd]).SetText("0");
            }
        }
        f.SetDifficulty(f.difficulty);
        if((f.IsSpeedrunMode() && InStr(GetEnumValue(loadout_enum), "All Items Allowed")!=-1) || text=="Speedrun Training Mode") // Speedrun Training will always force it instead of remembering your old setting
        {
            Super.SetEnumValue(loadout_enum, "Speed Enhancement");
        }
    }
    if(e == difficulty_enum) {
        f = GetFlags();
        for( i=0; i < ArrayCount(f.difficulty_names); i++ ) {
            if(text == f.DifficultyName(i)) {
                f.SetDifficulty(i);
                break;
            }
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
    else if(title == "Loadout") {
        LoadoutsGrouping(list, val, prev);
    }
    list.AddButton(val, help);
}

static function LoadoutsGrouping(DXREnumList list, string val, string prev)
{
    if(InStr(prev, "Stick With the Prod")==-1 && InStr(val, "Stick With the Prod")!=-1)
        list.CreateLabel("Challenge Loadouts");
    else if(val == "Ninja JC")
        list.CreateLabel("Silly Loadouts");
}

function HandleNewGameButton()
{
    local string s;
    local DXRFlags f;
    f = GetFlags();

    if(!class'HUDSpeedrunSplits'.static.CheckFlags(f)) {
        nextScreenNum=RMB_NewGame;
        s = Sprintf(SplitsBtnMessage, class'HUDSpeedrunSplits'.static.GetPB());
        class'BingoHintMsgBox'.static.Create(root, SplitsBtnTitle, s, 0, False, Self);
    }
    else if(dxr.rando_beaten == 0 && f.DifficultyName(f.difficulty) ~= "Extreme") {
        nextScreenNum=RMB_NewGame;
        class'BingoHintMsgBox'.static.Create(root, ExtremeBtnTitle,ExtremeBtnMessage,0,False,Self);
    }
    else if(dxr.rando_beaten == 0 && f.DifficultyName(f.difficulty) ~= "Impossible") {
        nextScreenNum=RMB_NewGame;
        class'BingoHintMsgBox'.static.Create(root, ImpossibleBtnTitle,ImpossibleBtnMessage,0,False,Self);
    }
    else if(dxr.rando_beaten == 0 && autosave_enum>0 && GetEnumValue(autosave_enum)!="Autosaves Enabled" && GetEnumValue(autosave_enum)!="Extra Safe (1+GB per playthrough)") {
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
    if (shownMaxRandoWarning){
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

function bool CheckClickHelpBtn( Window buttonPressed )
{
    if (Super.CheckClickHelpBtn(buttonPressed)){
        nextScreenNum=RMB_None; //Don't go anywhere after interacting with a help window button
        return true;
    }
    return false;
}

event bool BoxOptionSelected(Window button, int buttonNumber)
{
    root.PopWindow();

    switch (nextScreenNum){
        case RMB_MaxRando:
            if (buttonNumber==0){
                //shownMaxRandoWarning = true;
                //SaveConfig();
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
        case RMB_None:
            //Do nothing
            return true;
    }

    return Super.BoxOptionSelected(button,buttonNumber);
}

event DestroyWindow()
{
    if(#defined(vmd175)) {
        Player.ConsoleCommand("Open DXOnly");
    }
}

function CancelScreen()
{
    log(self $ " CancelScreen() " $ dxr);
    if(dxr != None) {
        GetFlags().Destroy();
        flags = None;
        dxr.Destroy();
        dxr = None;
    }
    Super.CancelScreen();
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

static function string GetSeedHelpText()
{
    local string msg;

    msg =       "The 'Seed' is the number used to initialize all the randomization in the game.  Given the same seed and settings, you will be able to replay the exact same game - or race against other players!|n";
    msg = msg $ "|n";
    msg = msg $ "If the Seed field is left blank, a random seed will be chosen for you.";

    return msg;
}

static function string GetOnlineFeaturesHelpText(int mode)
{
    local string msg;

    msg = "";

    switch(mode){
        case 0: //Disabled
            msg = msg $ "The game will not communicate with the Deus Ex Randomizer server at all.  No messages will be posted on the DX Rando Activity Mastodon feed, and no death markers will appear.";
            break;
        case 1: //Enabled (Death Markers Hidden)
            msg = msg $ "The game will occasionally send messages to the Deus Ex Randomizer server to log deaths and certain actions.  Death messages will be posted on the DX Rando Activity Mastodon feed,"$" along with posts about certain things that the player does.  Death markers will NOT show up in game.";
            break;
        case 2: //Enabled
            msg = msg $ "The game will occasionally send messages to the Deus Ex Randomizer server to log deaths and certain actions.  Death messages will be posted on the DX Rando Activity Mastodon feed,"$" along with posts about certain things that the player does.  Death markers will show up in game where players have recently died.";
            break;
    }

    return msg;
}

static function string GetCrowdControlHelpText(int mode)
{
    local string msg;

    msg = "";

    switch(mode){
        case 0: //Disabled
            msg = msg $ "Crowd Control is entirely disabled.  The Crowd Control client will not be able to connect to your game and effects will not occur.";
            break;
        case 1: //Enabled (Streaming)
            msg = msg $ "Crowd Control will be enabled in your game.  Connect using the Crowd Control app on your computer so that people viewing your stream will be able to interact with you.|n";
            msg = msg $ "|n";
            msg = msg $ "See CrowdControl.Live for more details about the Crowd Control app.";
            break;
        case 2: //Enabled (Anonymous) (not actually available)
            msg = msg $ "";
            break;
        case 3: //Offline Simulated
            msg = msg $ "Simulated Crowd Control will be enabled in your game.  Instead of using the Crowd Control app, the game will randomly select effects and inflict them upon you.";
            break;
        case 4: //Streaming and Simulated
            msg = msg $ "Both real and simulated Crowd Control will be enabled in your game.  You can connect using the Crowd Control app on your computer so that people viewing your stream will be able to interact with you.  "$"In addition, the game will randomly select effects and inflict them upon you.|n";
            msg = msg $ "|n";
            msg = msg $ "See CrowdControl.Live for more details about the Crowd Control app.";
            break;
    }

    return msg;
}

static function string GetMirroredMapsHelpText(bool installed)
{
    local string msg;

    msg = "The chances of each map being a mirrored version instead of the original.  Mirrored maps are horizontally mirrored (so left is right and right is left).  "$"Trick your mind into experiencing the original maps for the very first time again!";
    if (!installed){
        msg = msg $ "|n|nMirrored Maps are not installed!  Run the Deus Ex Randomizer installer again to download them if you want to try them out!";
    }

    return msg;
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
    AutosaveBtnMessage="It appears you're new to DX Randomizer.|n|nWe suggest starting with the default option for Autosaves Enabled.|nBy continuing, you waive your right to ragequit.|n|nAre you sure you want to continue with %s?"
    SplitsBtnTitle="Mismatched Splits!"
    SplitsBtnMessage="It appears that your DXRSplits.ini file is for different settings than this.|n|nThe PB is %s.|n|nAre you sure you want to continue?"
}
