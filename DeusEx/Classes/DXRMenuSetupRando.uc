class DXRMenuSetupRando expands MenuUIScreenWindow config(DXRando);

var MenuUIInfoButtonWindow winNameBorder;
var float combatDifficulty;

struct EnumBtn {
    var MenuUIActionButtonWindow btn;
    var string values[32];
    var int value;
};

var EnumBtn enums[32];
var int GameMode, RandoKeys, RandoDoors, RandoDevices, RandoPasswords, Autosave, RemoveInvisWalls, RandoInfoDevices;

var MenuUIEditWindow editSeed;
var MenuUIEditWindow editBrightness;
var MenuUIEditWindow editMinSkill;
var MenuUIEditWindow editMaxSkill;
var MenuUIEditWindow editAmmo;
var MenuUIEditWindow editMultitools;
var MenuUIEditWindow editLockpicks;
var MenuUIEditWindow editBioCells;
var MenuUIEditWindow editMedkits;
var MenuUIEditWindow editSpeedLevel;
var MenuUIEditWindow editEnemyRando;
var MenuUIEditWindow editDancingPercent;

var MenuUILabelWindow winHelp;
var bool bHelpAlwaysOn;

var int numwnds;
var Window wnds[64];
var String helptexts[64];

var config int config_version;

var config int num_rows;
var config int num_cols;
var config int col_width_even;
var config int col_width_odd;
var config int row_height;
var config int padding_width;
var config int padding_height;

event InitWindow()
{
    local vector coords;

    CheckConfig();

    coords = _GetCoords(num_rows, num_cols);
    ClientWidth = coords.X;
    ClientHeight = coords.Y;
    Super.InitWindow();

    ResetToDefaults();

    // Need to do this because of the edit control used for 
    // saving games.
    SetMouseFocusMode(MFOCUS_Click);

    InitHelp();
    Show();
    SetFocusWindow(editSeed);
    editSeed.SetSelectedArea(0, Len(editSeed.GetText()));
    combatDifficulty = player.Default.CombatDifficulty;

    StyleChanged();
}

function DXRando InitDxr()
{
    local DXRando dxr;
    dxr = player.Spawn(class'DXRando');
    dxr.player = player;
    dxr.LoadFlagsModule();
    dxr.flags.InitDefaults();
    return dxr;
}

function CheckConfig()
{
    if( config_version == 0 ) {
    }
    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
        config_version = class'DXRFlags'.static.VersionNumber();
        SaveConfig();
    }
}

function InitHelp()
{
    local MenuUILabelWindow winLabel;
    local vector coords;
    bHelpAlwaysOn = True;
    coords = _GetCoords(num_rows-1, 0);
    winHelp = CreateMenuLabel( coords.x, coords.y+4, "", winClient);
}

event DestroyWindow()
{
}

function CreateControls()
{
    local int i;
    local int row;
    local EnumBtn btnGameMode, btnRandoKeys, btnRandoDoors, btnRandoDevices, btnRandoPasswords, btnAutosave, btnInfoDevs;
    Super.CreateControls();

    Title = "DX Rando "$ class'DXRFlags'.static.VersionString() $" Options";
    SetTitle(Title);

    row = 0;
    editSeed = CreateEdit(row++, "Seed", "Enter a seed if you want to play the same game again.", "1234567890");

    btnAutosave.values[0] = "First Entry";
    btnAutosave.values[1] = "Every Entry";
    //btnAutosave.values[0] = "Off";
    btnAutosave.values[2] = "Off";
    Autosave = CreateEnum(row++, "Autosave", "Saves the game in case you die!", btnAutosave);

    editBrightness = CreateSlider(row++, "Brightness (0-255) +", "Increase the brightness of dark areas.", 10, 0, 255);

    i=0;
    btnGameMode.values[i++] = "Original Story";
    btnGameMode.values[i++] = "Original Story, Rearranged Levels (Beta)";
    btnGameMode.values[i++] = "Horde Mode (Beta)";
    /*btnGameMode.values[i++] = "Kill Bob Page";
    btnGameMode.values[i++] = "How About Some Soy Food?";
    btnGameMode.values[i++] = "Horde Mode";//defending the paris cathedral could be really cool
    btnGameMode.values[i++] = "Stick With the Prod";*/
    GameMode = CreateEnum(row++, "", "Choose a game mode!", btnGameMode);

    i=0;
    btnRandoDoors.values[i++] = "Undefeatable Doors Destructible & Pickable";
    btnRandoDoors.values[i++] = "Undefeatable Doors Destructible or Pickable";
    btnRandoDoors.values[i++] = "Undefeatable Doors Destructible";
    btnRandoDoors.values[i++] = "Undefeatable Doors Pickable";
    btnRandoDoors.values[i++] = "Doors Unchanged";
    btnRandoDoors.values[i++] = "Key-Only Doors Destructible & Pickable";
    btnRandoDoors.values[i++] = "Key-Only Doors Destructible or Pickable";
    btnRandoDoors.values[i++] = "Key-Only Doors Destructible";
    btnRandoDoors.values[i++] = "Key-Only Doors Pickable";
    /*btnRandoDoors.values[i++] = "All Doors Destructible & Pickable";
    btnRandoDoors.values[i++] = "All Doors Destructible or Pickable";
    btnRandoDoors.values[i++] = "All Doors Destructible";
    btnRandoDoors.values[i++] = "All Doors Pickable";*/
    btnRandoDoors.values[i++] = "Some Doors Destructible & Pickable";
    btnRandoDoors.values[i++] = "Some Doors Destructible or Pickable";
    btnRandoDoors.values[i++] = "Some Doors Destructible";
    btnRandoDoors.values[i++] = "Some Doors Pickable";
    RandoDoors = CreateEnum(row++, "", "Additional options to get through doors that normally can't be destroyed or lockpicked.", btnRandoDoors);

    btnRandoKeys.values[0] = "On";
    //btnRandoKeys.values[1] = "On";
    btnRandoKeys.values[1] = "Off";
    RandoKeys = CreateEnum(row++, "Key Randomization", "Move keys around the map.", btnRandoKeys);

    btnRandoDevices.values[0] = "All Hackable";
    //btnRandoDevices.values[1] = "Some Hackable";
    btnRandoDevices.values[1] = "Unchanged";
    RandoDevices = CreateEnum(row++, "Electronic Devices", "Provide additional options for keypads and electronic panels.", btnRandoDevices);

    btnRandoPasswords.values[0] = "Randomized";
    btnRandoPasswords.values[1] = "Unchanged";
    RandoPasswords = CreateEnum(row++, "Passwords", "Forces you to look for passwords and passcodes.", btnRandoPasswords);

    btnInfoDevs.values[0] = "Randomized";
    btnInfoDevs.values[1] = "Unchanged";
    RandoInfoDevices = CreateEnum(row++, "Datacubes", "Moves datacubes and other information objects around the map.", btnInfoDevs);

    editMinSkill = CreateSlider(row++, "Minimum Skill Cost %", "Minimum cost for skills in percentage of the original cost.", 25, 0, 500);
    editMaxSkill = CreateSlider(row++, "Maximum Skill Cost %", "Maximum cost for skills in percentage of the original cost.", 300, 0, 500);

    editEnemyRando = CreateSlider(row++, "Enemy Randomization %", "How many additional enemies to add and how much to randomize their weapons.", 35, 0, 100);
    editAmmo = CreateSlider(row++, "Ammo Drops %", "Make ammo more scarce.", 90);
    editMultitools = CreateSlider(row++, "Multitools Drops %", "Make multitools more scarce.", 80);
    editLockpicks = CreateSlider(row++, "Lockpicks Drops %", "Make lockpicks more scarce.", 80);
    editBioCells = CreateSlider(row++, "Bioelectric Cells Drops %", "Make bioelectric cells more scarce.", 80);
    editMedkits = CreateSlider(row++, "Medkit Drops %", "Make medkits more scarce.", 90);
    editSpeedLevel = CreateSlider(row++, "Speed Aug Level", "Start the game with the Speed Enhancement augmentation.", 1, 0, 3);

    RemoveInvisWalls = CreateEnum(row++, "Remove Invisible Walls", "Allows you to get around some areas where it looks like you should be able to.");

    editDancingPercent = CreateSlider(row++, "Dancing %", "How many characters should be dancing.", 25, 0, 100);
}

function vector GetCoords(int row, int col)
{
    while( row >= num_rows-1 ) {
        row -= num_rows-1;
        col += 2;
    }
    return _GetCoords(row, col);
}

function vector _GetCoords(int row, int col)
{
    local vector v;
    v.x = _GetX(col);// col * col_width + col*padding_width + padding_width;
    v.y = row * row_height + row*padding_height + padding_height;
    return v;
}

function int _GetX(int col)
{
    local int width;
    width = col_width_even + col_width_odd;
    width *= col/2;
    width += int(col%2) * col_width_odd;//I use col_width_odd here because it's 0-indexed
    width += padding_width*col + padding_width;
    return width;
}

function int GetWidth(int row, int col, int cols)
{
    while( row >= num_rows-1 ) {
        row -= num_rows-1;
        col += 2;
    }
    return _GetX(col+cols) - _GetX(col) - padding_width;
}

function MenuUILabelWindow CreateLabel(int row, string label)
{
    local MenuUILabelWindow winLabel;
    local vector coords;
    coords = GetCoords(row, 0);
    winLabel = CreateMenuLabel( coords.x, coords.y+4, label, winClient);
    return winLabel;
}

function MenuUIEditWindow CreateEdit(int row, string label, string helptext, string filterString, optional string deflt )
{
    local MenuUIEditWindow edit;
    local vector coords;

    CreateLabel(row, label);

    coords = GetCoords(row, 1);
    edit = CreateMenuEditWindow(coords.x, coords.y, GetWidth(row, 1, 1), 10, winClient);

    edit.SetText(deflt);
    edit.SetFilter(filterString);
    //edit.SetSensitivity(False);

    wnds[numwnds] = edit;
    helptexts[numwnds] = helptext;
    numwnds++;

    return edit;
}

function MenuUIEditWindow CreateSlider(int row, string label, string helptext, optional int deflt, optional int min, optional int max )
{
    return CreateEdit(row, label, helptext, "1234567890", string(deflt));
    /*local MenuUISliderButtonWindow slider;
    local vector coords;
    local int numTicks;
    local int i;
    local int mult;

    if(max==0) max=100;
    if( (max-min) < 80 ) mult=1;
    else mult=5;
    numTicks=(max - min)/mult + 1;

    CreateLabel(row, label);

    coords = GetCoords(row, 1);
    slider = MenuUISliderButtonWindow(winClient.NewChild(Class'MenuUISliderButtonWindow'));
    slider.SetPos(coords.x, coords.y);
    slider.SetTicks(numTicks, min, max);
    slider.winSlider.SetValue(deflt);
    for(i=0; i<numTicks; i++) {
        slider.winSlider.SetEnumeration(i, string(i*mult)$"%" );
    }
    //slider.winScaleManager.SetWidth(GetWidth(row, 1, 1));
    //slider.winSlider.SetScaleTexture(slider.defaultScaleTexture, 50, 21, 8, 8);
    //slider.winScaleManager.StretchScaleField(true);
    //slider.winSlider.EnableStretchedScale(true);
    //slider.winSlider.SetWidth(50);
    slider.winSlider.SetScaleTexture(slider.defaultScaleTexture, 50, 21, 8, 8);

    return slider;*/
}

function MenuUIActionButtonWindow CreateBtn(int row, string label, string helptext, string text)
{
    local MenuUIActionButtonWindow btn;
    local vector coords;

    if( label != "" ) CreateLabel(row, label);

    btn = MenuUIActionButtonWindow(winClient.NewChild(Class'MenuUIActionButtonWindow'));
    btn.SetButtonText(text);
    if( label == "" ) {
        coords = GetCoords(row, 0);
        btn.SetPos(coords.x, coords.y);
        btn.SetWidth(GetWidth(row, 0, 2));
    }
    else {
        coords = GetCoords(row, 1);
        btn.SetPos(coords.x, coords.y);
        btn.SetWidth(GetWidth(row, 1, 1));
    }
    //btn.SetFont(Font'FontTiny');

    wnds[numwnds] = btn;
    helptexts[numwnds] = helptext;
    numwnds++;

    return btn;
}

function int CreateEnum(int row, string label, string helptext, optional EnumBtn e)
{
    local int i;
    if(e.values[0] == "") {
        e.values[0] = "Off";
        e.values[1] = "On";
    }
    for( e.value=0; e.value < ArrayCount(e.values); e.value++ ) {
        if(e.values[e.value] != "") break;
    }
    e.btn = CreateBtn(row, label, helptext, e.values[e.value]);

    for(i=0; i<ArrayCount(enums); i++)
    {
        if(enums[i].btn == None) {
            enums[i] = e;
            return i;
            break;
        }
    }
}

function bool ButtonActivated( Window buttonPressed )
{
    local bool bHandled;
    bHandled = True;

    if( CheckClickEnum(buttonPressed) ) { }
    else {
        bHandled = False;
    }

    if ( !bHandled )
        bHandled = Super.ButtonActivated(buttonPressed);

    return bHandled;
}

function bool CheckClickEnum( Window buttonPressed )
{
    local EnumBtn e;
    local int i;

    for(i=0; i<ArrayCount(enums); i++) {
        e=enums[i];
        if( buttonPressed == e.btn ) {
            enums[i] = ClickEnum(e);
            return true;
        }
    }
    return false;
}

function EnumBtn ClickEnum(EnumBtn e)
{
    e.value++;
    e.value = e.value % ArrayCount(e.values);
    while( e.values[e.value] == "" ) {
        e.value++;
        e.value = e.value % ArrayCount(e.values);
    }
    e.btn.SetButtonText(e.values[e.value]);
    return e;
}

function ResetToDefaults()
{
    editSeed.SetText("");
}

function int GetSliderValue(MenuUIEditWindow w)
{
    return int(w.GetText());
}

function string GetEnumValue(int e)
{
    return enums[e].values[enums[e].value];
}

function ProcessAction(String actionKey)
{
    local DXRando dxr;
    local DXRFlags f;
    local int seed;
    local string sseed, sgamemode, keys, doors, devices, passwords, autosavevalue, inviswalls, infodevs;
    local int undefeatabledoors, keyonlydoors, alldoors, highlightabledoors;
    local int doormutuallyinclusive, doorindependent, doormutuallyexclusive;

    if (actionKey == "NEXT")
    {
        dxr = InitDxr();
        f = dxr.flags;
        sseed = editSeed.GetText();

        sgamemode = GetEnumValue(GameMode);
        keys = GetEnumValue(RandoKeys);
        doors = GetEnumValue(RandoDoors);
        devices = GetEnumValue(RandoDevices);
        passwords = GetEnumValue(RandoPasswords);
        infodevs = GetEnumValue(RandoInfoDevices);

        f.InitDefaults();
        if( sseed != "" ) {
            seed = int(sseed);
            f.seed = seed;
            dxr.seed = seed;
        }
        log("DXRando setting seed to "$seed);
        f.brightness = GetSliderValue(editBrightness);
        f.minskill = GetSliderValue(editMinSkill);
        f.maxskill = GetSliderValue(editMaxSkill);
        f.ammo = GetSliderValue(editAmmo);
        f.multitools = GetSliderValue(editMultitools);
        f.lockpicks = GetSliderValue(editLockpicks);
        f.biocells = GetSliderValue(editBioCells);
        f.medkits = GetSliderValue(editMedkits);
        f.speedlevel = GetSliderValue(editSpeedLevel);
        f.dancingpercent = GetSliderValue(editDancingPercent);

        if( sgamemode == "Original Story" )
            f.gamemode = 0;
        else if( sgamemode == "Original Story, Rearranged Levels (Beta)" )
            f.gamemode = 1;
        else if( sgamemode == "Horde Mode (Beta)" )
            f.gamemode = 2;

        if( keys == "Off" ) f.keysrando = 0;
        else if( keys == "Dumb" ) f.keysrando = 2;
        else if( keys == "On" ) f.keysrando = 4;
        else if( keys == "Copy" ) f.keysrando = 3;
        else if( keys == "Smart" ) f.keysrando = 4;

        undefeatabledoors = 1*256;
        alldoors = 2*256;
        keyonlydoors = 3*256;
        highlightabledoors = 4*256;
        doormutuallyinclusive = 1;
        doorindependent = 2;
        doormutuallyexclusive = 3;

        if( doors == "Doors Unchanged" ) {
            f.doorsmode = 0;
            f.doorsdestructible = 0;
            f.doorspickable = 0;
        }
        else if( doors == "Undefeatable Doors Destructible" ) {
            f.doorsmode = undefeatabledoors+doorindependent;
            f.doorsdestructible = 100;
            f.doorspickable = 0;
        }
        else if( doors == "Undefeatable Doors Pickable" ) {
            f.doorsmode = undefeatabledoors+doorindependent;
            f.doorspickable = 100;
            f.doorsdestructible = 0;
        }
        else if( doors == "Undefeatable Doors Destructible or Pickable" ) {
            f.doorsmode = undefeatabledoors+doormutuallyexclusive;
            f.doorsdestructible = 50;
            f.doorspickable = 50;
        }
        else if( doors == "Undefeatable Doors Destructible & Pickable" ) {
            f.doorsmode = undefeatabledoors+doormutuallyinclusive;
            f.doorsdestructible = 100;
            f.doorspickable = 100;
        }
        else if( doors == "Key-Only Doors Destructible" ) {
            f.doorsmode = keyonlydoors+doorindependent;
            f.doorsdestructible = 100;
            f.doorspickable = 0;
        }
        else if( doors == "Key-Only Doors Pickable" ) {
            f.doorsmode = keyonlydoors+doorindependent;
            f.doorspickable = 100;
            f.doorsdestructible = 0;
        }
        else if( doors == "Key-Only Doors Destructible or Pickable" ) {
            f.doorsmode = keyonlydoors+doormutuallyexclusive;
            f.doorsdestructible = 50;
            f.doorspickable = 50;
        }
        else if( doors == "Key-Only Doors Destructible & Pickable" ) {
            f.doorsmode = keyonlydoors+doormutuallyinclusive;
            f.doorsdestructible = 100;
            f.doorspickable = 100;
        }
        else if( doors == "All Doors Destructible" ) {
            f.doorsmode = alldoors+doorindependent;
            f.doorsdestructible = 100;
            f.doorspickable = 0;
        }
        else if( doors == "All Doors Pickable" ) {
            f.doorsmode = alldoors+doorindependent;
            f.doorspickable = 100;
            f.doorsdestructible = 0;
        }
        else if( doors == "All Doors Destructible or Pickable" ) {
            f.doorsmode = alldoors+doormutuallyexclusive;
            f.doorsdestructible = 50;
            f.doorspickable = 50;
        }
        else if( doors == "All Doors Destructible & Pickable" ) {
            f.doorsmode = alldoors+doormutuallyinclusive;
            f.doorsdestructible = 100;
            f.doorspickable = 100;
        }
        else if( doors == "Some Doors Destructible" ) {
            f.doorsmode = highlightabledoors+doorindependent;
            f.doorsdestructible = 50;
            f.doorspickable = 0;
        }
        else if( doors == "Some Doors Pickable" ) {
            f.doorsmode = highlightabledoors+doorindependent;
            f.doorspickable = 50;
            f.doorsdestructible = 0;
        }
        else if( doors == "Some Doors Destructible or Pickable" ) {
            f.doorsmode = highlightabledoors+doormutuallyexclusive;
            f.doorsdestructible = 25;
            f.doorspickable = 25;
        }
        else if( doors == "Some Doors Destructible & Pickable" ) {
            f.doorsmode = highlightabledoors+doormutuallyinclusive;
            f.doorsdestructible = 50;
            f.doorspickable = 50;
        }

        if( devices == "Unchanged" ) f.deviceshackable = 0;
        else if( devices == "Some Hackable" ) f.deviceshackable = 50;
        else if( devices == "All Hackable" ) f.deviceshackable = 100;

        if( passwords == "Randomized" ) f.passwordsrandomized = 100;
        else if( passwords == "Unchanged" ) f.passwordsrandomized = 0;

        f.enemiesrandomized = GetSliderValue(editEnemyRando);
        autosavevalue = GetEnumValue(Autosave);
        if( autosavevalue == "Off" ) f.autosave = 0;
        else if( autosavevalue == "First Entry" ) f.autosave = 1;
        else if( autosavevalue == "Every Entry" ) f.autosave = 2;

        inviswalls = GetEnumValue(RemoveInvisWalls);
        if( inviswalls == "Off" ) f.removeinvisiblewalls = 0;
        else if( inviswalls == "On" ) f.removeinvisiblewalls = 1;

        if( infodevs == "Unchanged" ) f.infodevices = 0;
        else if( infodevs == "Randomized" ) f.infodevices = 100;

        //f.flags = player.FlagBase;
        InvokeNewGameScreen(combatDifficulty, dxr);
    }
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

/*function SaveSettings()
{
    editSeed.GetText();
}*/

function CancelScreen()
{
    Super.CancelScreen();
}

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
    // Destroy the msgbox!  
    root.PopWindow();

    editSeed.SetText("");
    editSeed.MoveInsertionPoint(MOVEINSERT_End);
    editSeed.SetSelectedArea(0, Len(editSeed.GetText()));
    SetFocusWindow(editSeed);

    return True;
}

event StyleChanged()
{
    local ColorTheme theme;
    local Color colButtonFace;

    Super.StyleChanged();

    theme = player.ThemeManager.GetCurrentMenuColorTheme();

    // check MenuScreenAdjustColorsExample?

    // Title colors
    colButtonFace = theme.GetColorFromName('MenuColor_ButtonFace');

    /*btnLeftArrow.SetButtonColors(colButtonFace, colButtonFace, colButtonFace,
                                 colButtonFace, colButtonFace, colButtonFace);
    btnRightArrow.SetButtonColors(colButtonFace, colButtonFace, colButtonFace,
                                  colButtonFace, colButtonFace, colButtonFace);*/
}

function SetDifficulty(float newDifficulty)
{
    combatDifficulty = newDifficulty;
}

// ----------------------------------------------------------------------
// FocusEnteredDescendant() : Called when a descendant window gets focus
// ----------------------------------------------------------------------

event FocusEnteredDescendant(Window enterWindow)
{
    local int i;
    for(i=0;i<ArrayCount(wnds);i++) {
        if( wnds[i] == enterWindow ) {
            winHelp.Show();
            winHelp.SetText(helptexts[i]);
            return;
        }
    }
}


// ----------------------------------------------------------------------
// FocusLeftDescendant() : Called when a descendant window loses focus
// ----------------------------------------------------------------------

event FocusLeftDescendant(Window leaveWindow)
{
    if ((winHelp != None) && (!bHelpAlwaysOn))
        winHelp.Hide();

    currentChoice = None;
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
    actionButtons(0)=(Align=HALIGN_Right,Action=AB_Cancel,Text="|&Back")
    actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Next",Key="NEXT")
    //actionButtons(2)=(Action=AB_Reset)
    Title="DX Rando Options"
    ClientWidth=672
    ClientHeight=357
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
}
