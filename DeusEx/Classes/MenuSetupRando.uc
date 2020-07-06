class MenuSetupRando expands MenuUIScreenWindow;

var MenuUIInfoButtonWindow winNameBorder;
var float combatDifficulty;

struct EnumBtn {
    var MenuUIActionButtonWindow btn;
    var string values[16];
    var int value;
};

var EnumBtn enums[32];
var int RandoKeys, RandoDoors, RandoDevices, RandoPasswords;

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
    local EnumBtn btnRandoKeys, btnRandoDoors, btnRandoDevices, btnRandoPasswords;
	Super.CreateControls();

    row = 0;
	editSeed = CreateEdit(row++, "Seed", "1234567890");
    editBrightness = CreateSlider(row++, "Brightness +", 5, 0, 25);

    btnRandoKeys.values[0] = "Off";
    btnRandoKeys.values[1] = "Smart";
    RandoKeys = CreateEnum(row++, "Key Randomization", btnRandoKeys);

    btnRandoDoors.values[0] = "Unchanged";
    btnRandoDoors.values[1] = "Destructible";
    btnRandoDoors.values[2] = "Pickable";
    //btnRandoDoors.values[3] = "Either";
    btnRandoDoors.values[3] = "Both";
    RandoDoors = CreateEnum(row++, "Key-Only Doors", btnRandoDoors);

    btnRandoDevices.values[0] = "Unchanged";
    //btnRandoDevices.values[1] = "Some Hackable";
    btnRandoDevices.values[1] = "All Hackable";
    RandoDevices = CreateEnum(row++, "Electronic Devices", btnRandoDevices);

    btnRandoPasswords.values[0] = "Randomized";
    btnRandoPasswords.values[1] = "Unchanged";
    RandoPasswords = CreateEnum(row++, "Passwords", btnRandoPasswords);

    editMinSkill = CreateSlider(row++, "Minimum Skill Cost %", 25, 0, 500);
    editMaxSkill = CreateSlider(row++, "Maximum Skill Cost %", 400, 0, 500);
    editAmmo = CreateSlider(row++, "Ammo Drops %", 100);
    editMultitools = CreateSlider(row++, "Multitools Drops %", 70);
    editLockpicks = CreateSlider(row++, "Lockpicks Drops %", 70);
    editBioCells = CreateSlider(row++, "Bioelectric Cells Drops %", 80);
    editMedkits = CreateSlider(row++, "Medkit Drops %", 80);
    editSpeedLevel = CreateSlider(row++, "Speed Aug Level", 1, 0, 3);
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

function int CreateEnum(int row, string label, EnumBtn e)
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
    local string sseed, keys, doors, devices, passwords;
    local MissionNewGame ms;

	if (actionKey == "NEXT")
	{
		sseed = editSeed.GetText();
        if( sseed == "" ) seed = Rand(10000000);
        else seed = int(sseed);

        keys = GetEnumValue(RandoKeys);
        doors = GetEnumValue(RandoDoors);
        devices = GetEnumValue(RandoDevices);
        passwords = GetEnumValue(RandoPasswords);

        ms = player.Spawn(class'MissionNewGame');
        ms.seed = seed;
        log("DXRando setting seed to "$seed);
        ms.brightness = GetSliderValue(editBrightness);
        ms.minskill = GetSliderValue(editMinSkill);
        ms.maxskill = GetSliderValue(editMaxSkill);
        ms.ammo = GetSliderValue(editAmmo);
        ms.multitools = GetSliderValue(editMultitools);
        ms.lockpicks = GetSliderValue(editLockpicks);
        ms.biocells = GetSliderValue(editBioCells);
        ms.medkits = GetSliderValue(editMedkits);
        ms.speedlevel = GetSliderValue(editSpeedLevel);

        if( keys == "Off" ) ms.keysrando = 0;
        else if( keys == "Dumb" ) ms.keysrando = 1;
        else if( keys == "Smart" ) ms.keysrando = 2;
        else if( keys == "Copy" ) ms.keysrando = 3;

        if( doors == "Unchanged" ) {}
        else if( doors == "Destructible" ) ms.doorsdestructible = 100;
        else if( doors == "Pickable" ) ms.doorspickable = 100;
        else if( doors == "Either" ) {
            ms.doorsdestructible = 50;
            ms.doorspickable = 50;
        }
        else if( doors == "Both" ) {
            ms.doorsdestructible = 100;
            ms.doorspickable = 100;
        }

        if( devices == "Unchanged" ) ms.deviceshackable = 0;
        else if( devices == "Some Hackable" ) ms.deviceshackable = 50;
        else if( devices == "All Hackable" ) ms.deviceshackable = 100;

        if( passwords == "Randomized" ) ms.passwordsrandomized = 100;
        else if( passwords == "Unchanged" ) ms.passwordsrandomized = 0;

        ms.player = player;
        ms.flags = player.FlagBase;
        //ms.SaveFlags();
        //ms.Destroy();
        InvokeNewGameScreen(combatDifficulty, ms);
	}
}

function InvokeNewGameScreen(float difficulty, MissionNewGame ms)
{
	local MenuScreenNewGameRando newGame;

	newGame = MenuScreenNewGameRando(root.InvokeMenuScreen(Class'MenuScreenNewGameRando'));

	if (newGame != None) {
		newGame.SetDifficulty(difficulty);
        newGame.SetMs(ms);
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
    Title="DX Rando v1.0 Options"
    ClientWidth=672
    ClientHeight=357
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
}
