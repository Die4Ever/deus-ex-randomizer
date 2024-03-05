class DXRMenuSelectDifficulty extends DXRMenuBase;

var DXRFlags tempFlags;

var string MaxRandoBtnTitle;
var string MaxRandoBtnMessage;
var string AdvancedBtnTitle;
var string AdvancedBtnMessage;

enum ERandoMessageBoxModes
{
	RMB_MaxRando,
	RMB_Advanced,
};
var ERandoMessageBoxModes nextScreenNum;

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
    local string sseed, ts;
    local DXRLoadouts loadout;
    local DXRTelemetry t;
    local DXRCrowdControl cc;
    local int temp, i;
#ifdef injections
    local DXRAutosave autosave;
    local bool mirrored_maps_files_found;
#endif

    f = InitFlags();

    NewMenuItem("Game Mode", "Choose a game mode!");
    for(i=0; i<20; i++) {
        temp = f.GameModeIdForSlot(i);
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

    if( f.VersionIsStable() )
        i=1;
    else
        i=0;

    for( i=i; i < ArrayCount(f.difficulty_names); i++ ) {
        if( f.difficulty_names[i] == "" ) continue;
        EnumOption(f.difficulty_names[i], i, f.difficulty);
    }// we write the difficulty and gamemode after setting the seed...

#ifdef injections
    foreach f.AllActors(class'DXRAutosave', autosave) { break; }// need an object to access consts
    NewMenuItem("Autosave", "Saves the game in case you die!");
    EnumOption("Every Entry", autosave.EveryEntry, f.autosave);
    EnumOption("First Entry", autosave.FirstEntry, f.autosave);
    EnumOption("Autosaves-Only (Hardcore)", autosave.Hardcore, f.autosave);
    EnumOption("Extra Safe (1+GB per playthrough)", autosave.ExtraSafe, f.autosave);
    EnumOption("Off", autosave.Disabled, f.autosave);
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
        f.mirroredmaps = 50;// default to 50% when files are available
        Slider(f.mirroredmaps, 0, 100);
    } else {
        NewMenuItem("", "Use the installer to download the mirrored map files, or go to the unreal-map-flipper Releases page on Github");
        EnumOption("Mirror Map Files Not Found", 0, f.mirroredmaps);
    }
#endif

    NewMenuItem("Seed", "Enter a seed if you want to play the same game again.");
    sseed = EditBox("", "1234567890");
    if( sseed != "" ) {
        f.seed = int(sseed);
        dxr.seed = f.seed;
        f.bSetSeed = 1;
    } else {
        f.RollSeed();
    }

    if(writing) {
#ifndef hx
        // we write the difficulty and gamemode after setting the seed, TODO: menus for HX?
        difficulty = f.SetDifficulty(f.difficulty).CombatDifficulty;
#endif
        if( action == "ADVANCED" ) HandleAdvancedButton(f);//NewGameSetup(difficulty);
        else if( action == "MAXRANDO" ) {
            HandleMaxRandoButton(f);
            //f.ExecMaxRando();
            //_InvokeNewGameScreen(difficulty, InitDxr());
        }
        else _InvokeNewGameScreen(difficulty, InitDxr());
    }
}

function HandleMaxRandoButton(DXRFlags f)
{
    local DXRMessageBoxWindow msgBox;
    tempFlags = f;

    if (class'DXRando'.default.rando_beaten){
        DoMaxRandoButtonConfirm();
    } else {
        nextScreenNum=RMB_MaxRando;
        root.MessageBox(MaxRandoBtnTitle,MaxRandoBtnMessage,0,False,Self);
    }
}

function DoMaxRandoButtonConfirm()
{
    tempFlags.ExecMaxRando();
#ifndef hx
    _InvokeNewGameScreen(tempFlags.settings.CombatDifficulty, InitDxr());
#endif
}

function HandleAdvancedButton(DXRFlags f)
{
    local DXRMessageBoxWindow msgBox;
    tempFlags = f;

    if (class'DXRando'.default.rando_beaten){
        DoAdvancedButtonConfirm();
    } else {
        nextScreenNum=RMB_Advanced;
        root.MessageBox(AdvancedBtnTitle,AdvancedBtnMessage,0,False,Self);
    }
}

function DoAdvancedButtonConfirm()
{
#ifndef hx
    NewGameSetup(tempFlags.settings.CombatDifficulty);
#endif
}

event bool BoxOptionSelected(Window button, int buttonNumber)
{
    root.PopWindow();

    switch (nextScreenNum){
        case RMB_MaxRando:
            if (buttonNumber==0){
                DoMaxRandoButtonConfirm();
                return true;
            } else {
                return true;
            }
            break;
        case RMB_Advanced:
            if (buttonNumber==0){
                DoAdvancedButtonConfirm();
                return true;
            } else {
                return true;
            }
            break;
    }

    return Super.BoxOptionSelected(button,buttonNumber);
}

function InvokeNewGameScreen(float difficulty)
{
    _InvokeNewGameScreen(difficulty, InitDxr());
}

event DestroyWindow()
{
#ifdef vmd
    Player.ConsoleCommand("Open DXOnly");
#endif
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
    MaxRandoBtnMessage="It appears you haven't beaten DX Randomizer. Max Rando will randomize all the settings, which will likely result in a bad first time experience.  Are you sure you want to proceed?"
    AdvancedBtnTitle="Advanced Settings?"
    AdvancedBtnMessage="It appears you haven't beaten DX Randomizer.  We recommend playing with default settings for a better first time experience.  Are you sure you want to adjust advanced settings?"

}
