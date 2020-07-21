class MenuSetupRando expands MenuUIScreenWindow;

var MenuUIInfoButtonWindow winNameBorder;
var float combatDifficulty;

struct EnumBtn {
    var MenuUIActionButtonWindow btn;
    var string values[16];
    var int value;
};

var EnumBtn enums[32];
var int RandoKeys, RandoDoors, RandoDevices, RandoPasswords, Autosave, RemoveInvisWalls, RandoInfoDevices;

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

event InitWindow()
{
	Super.InitWindow();

	ResetToDefaults();

	// Need to do this because of the edit control used for 
	// saving games.
	SetMouseFocusMode(MFOCUS_Click);

	Show();
	SetFocusWindow(editSeed);
	editSeed.SetSelectedArea(0, Len(editSeed.GetText()));
	combatDifficulty = player.Default.CombatDifficulty;

	StyleChanged();
}

event DestroyWindow()
{
}

function CreateControls()
{
    local int row;
    local EnumBtn btnRandoKeys, btnRandoDoors, btnRandoDevices, btnRandoPasswords, btnAutosave, btnInfoDevs;
    local DXRFlags flags;
	Super.CreateControls();

    Title = "DX Rando "$ class'DXRFlags'.static.VersionString() $" Options";
    SetTitle(Title);

    row = 0;
	editSeed = CreateEdit(row++, "Seed", "1234567890");

    btnAutosave.values[0] = "First Entry";
    btnAutosave.values[1] = "Every Entry";
    //btnAutosave.values[0] = "Off";
    btnAutosave.values[2] = "Off";
    Autosave = CreateEnum(row++, "Autosave", btnAutosave);

    editBrightness = CreateSlider(row++, "Brightness +", 5, 0, 25);

    btnRandoKeys.values[0] = "Smart";
    btnRandoKeys.values[1] = "On";
    btnRandoKeys.values[2] = "Off";
    RandoKeys = CreateEnum(row++, "Key Randomization", btnRandoKeys);

    btnRandoDoors.values[0] = "Both";
    btnRandoDoors.values[1] = "Destructible";
    btnRandoDoors.values[2] = "Pickable";
    //btnRandoDoors.values[3] = "Either";
    btnRandoDoors.values[3] = "Unchanged";
    RandoDoors = CreateEnum(row++, "Key-Only Doors", btnRandoDoors);

    btnRandoDevices.values[0] = "All Hackable";
    //btnRandoDevices.values[1] = "Some Hackable";
    btnRandoDevices.values[1] = "Unchanged";
    RandoDevices = CreateEnum(row++, "Electronic Devices", btnRandoDevices);

    btnRandoPasswords.values[0] = "Randomized";
    btnRandoPasswords.values[1] = "Unchanged";
    RandoPasswords = CreateEnum(row++, "Passwords", btnRandoPasswords);

    btnInfoDevs.values[0] = "Unchanged";
    btnInfoDevs.values[1] = "Randomized";
    RandoInfoDevices = CreateEnum(row++, "Datacubes", btnInfoDevs);

    editEnemyRando = CreateSlider(row++, "Enemy Randomization %", 30, 0, 100);
    editMinSkill = CreateSlider(row++, "Minimum Skill Cost %", 25, 0, 500);
    editMaxSkill = CreateSlider(row++, "Maximum Skill Cost %", 300, 0, 500);
    editAmmo = CreateSlider(row++, "Ammo Drops %", 80);
    editMultitools = CreateSlider(row++, "Multitools Drops %", 80);
    editLockpicks = CreateSlider(row++, "Lockpicks Drops %", 80);
    editBioCells = CreateSlider(row++, "Bioelectric Cells Drops %", 80);
    editMedkits = CreateSlider(row++, "Medkit Drops %", 80);
    editSpeedLevel = CreateSlider(row++, "Speed Aug Level", 1, 0, 3);

    RemoveInvisWalls = CreateEnum(row++, "Remove Invisible Walls");
}

function vector GetCoords(int row, int col)
{
    local vector v;
    if( row >= 10 ) {
        row -= 10;
        col += 2;
    }
    v.x = col * 168 + 21;
    v.y = row * 34 + 17;
    return v;
}

function CreateLabel(int row, string label)
{
    local MenuUILabelWindow winLabel;
    local vector coords;
    coords = GetCoords(row, 0);
	winLabel = CreateMenuLabel( coords.x, coords.y+4, label, winClient);
    //winLabel.SetFont(Font'FontTiny');
}

function MenuUIEditWindow CreateEdit(int row, string label, string filterString, optional string deflt )
{
    local MenuUIEditWindow edit;
    local vector coords;

    CreateLabel(row, label);

    coords = GetCoords(row, 1);
	edit = CreateMenuEditWindow(coords.x, coords.y, 126, 10, winClient);

	edit.SetText(deflt);
    edit.SetFilter(filterString);
	//edit.SetSensitivity(False);

    return edit;
}

function MenuUIEditWindow CreateSlider(int row, string label, optional int deflt, optional int min, optional int max )
{
    return CreateEdit(row, label, "1234567890", string(deflt));
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
    //slider.winScaleManager.SetWidth(126);
    //slider.winSlider.SetScaleTexture(slider.defaultScaleTexture, 50, 21, 8, 8);
    //slider.winScaleManager.StretchScaleField(true);
    //slider.winSlider.EnableStretchedScale(true);
    //slider.winSlider.SetWidth(50);
    slider.winSlider.SetScaleTexture(slider.defaultScaleTexture, 50, 21, 8, 8);

    return slider;*/
}

function MenuUIActionButtonWindow CreateBtn(int row, string label, string text)
{
    local MenuUIActionButtonWindow btn;
    local vector coords;

    CreateLabel(row, label);

    coords = GetCoords(row, 1);
    btn = MenuUIActionButtonWindow(winClient.NewChild(Class'MenuUIActionButtonWindow'));
    btn.SetButtonText(text);
	btn.SetPos(coords.x, coords.y);
	btn.SetWidth(126);
    //btn.SetFont(Font'FontTiny');

    return btn;
}

function int CreateEnum(int row, string label, optional EnumBtn e)
{
    local int i;
    e.value=0;
    if(e.values[0] == "") {
        e.values[0] = "Off";
        e.values[1] = "On";
    }
    e.btn = CreateBtn(row, label, e.values[e.value]);

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
    if( e.value >= ArrayCount(e.values) ) {
        e.value=0;
    }
    else if( e.values[e.value] == "" ) {
        e.value=0;
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
	local int seed;
    local string sseed, keys, doors, devices, passwords, autosavevalue, inviswalls, infodevs;
    local DXRando dxr;

	if (actionKey == "NEXT")
	{
		sseed = editSeed.GetText();

        keys = GetEnumValue(RandoKeys);
        doors = GetEnumValue(RandoDoors);
        devices = GetEnumValue(RandoDevices);
        passwords = GetEnumValue(RandoPasswords);
        infodevs = GetEnumValue(RandoInfoDevices);

        dxr = player.Spawn(class'DXRando');
        dxr.player = player;
        dxr.LoadFlagsModule();
        dxr.flags.InitDefaults();
        if( sseed != "" ) {
            seed = int(sseed);
            dxr.flags.seed = seed;
            dxr.seed = seed;
        }
        log("DXRando setting seed to "$seed);
        dxr.flags.brightness = GetSliderValue(editBrightness);
        dxr.flags.minskill = GetSliderValue(editMinSkill);
        dxr.flags.maxskill = GetSliderValue(editMaxSkill);
        dxr.flags.ammo = GetSliderValue(editAmmo);
        dxr.flags.multitools = GetSliderValue(editMultitools);
        dxr.flags.lockpicks = GetSliderValue(editLockpicks);
        dxr.flags.biocells = GetSliderValue(editBioCells);
        dxr.flags.medkits = GetSliderValue(editMedkits);
        dxr.flags.speedlevel = GetSliderValue(editSpeedLevel);

        if( keys == "Off" ) dxr.flags.keysrando = 0;
        else if( keys == "Dumb" ) dxr.flags.keysrando = 1;
        else if( keys == "On" ) dxr.flags.keysrando = 2;
        else if( keys == "Copy" ) dxr.flags.keysrando = 3;
        else if( keys == "Smart" ) dxr.flags.keysrando = 4;

        if( doors == "Unchanged" ) {}
        else if( doors == "Destructible" ) dxr.flags.doorsdestructible = 100;
        else if( doors == "Pickable" ) dxr.flags.doorspickable = 100;
        else if( doors == "Either" ) {
            dxr.flags.doorsdestructible = 50;
            dxr.flags.doorspickable = 50;
        }
        else if( doors == "Both" ) {
            dxr.flags.doorsdestructible = 100;
            dxr.flags.doorspickable = 100;
        }

        if( devices == "Unchanged" ) dxr.flags.deviceshackable = 0;
        else if( devices == "Some Hackable" ) dxr.flags.deviceshackable = 50;
        else if( devices == "All Hackable" ) dxr.flags.deviceshackable = 100;

        if( passwords == "Randomized" ) dxr.flags.passwordsrandomized = 100;
        else if( passwords == "Unchanged" ) dxr.flags.passwordsrandomized = 0;

        dxr.flags.enemiesrandomized = GetSliderValue(editEnemyRando);
        autosavevalue = GetEnumValue(Autosave);
        if( autosavevalue == "Off" ) dxr.flags.autosave = 0;
        else if( autosavevalue == "First Entry" ) dxr.flags.autosave = 1;
        else if( autosavevalue == "Every Entry" ) dxr.flags.autosave = 2;

        inviswalls = GetEnumValue(RemoveInvisWalls);
        if( inviswalls == "Off" ) dxr.flags.removeinvisiblewalls = 0;
        else if( inviswalls == "On" ) dxr.flags.removeinvisiblewalls = 1;

        if( infodevs == "Unchanged" ) dxr.flags.infodevices = 0;
        else if( infodevs == "Randomized" ) dxr.flags.infodevices = 100;

        //dxr.flags.flags = player.FlagBase;
        InvokeNewGameScreen(combatDifficulty, dxr);
	}
}

function InvokeNewGameScreen(float difficulty, DXRando dxr)
{
	local MenuScreenNewGameRando newGame;

	newGame = MenuScreenNewGameRando(root.InvokeMenuScreen(Class'MenuScreenNewGameRando'));

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

defaultproperties
{
    actionButtons(0)=(Align=HALIGN_Right,Action=AB_Cancel)
    actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Next",Key="NEXT")
    actionButtons(2)=(Action=AB_Reset)
    Title="DX Rando Options"
    ClientWidth=672
    ClientHeight=357
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
}
