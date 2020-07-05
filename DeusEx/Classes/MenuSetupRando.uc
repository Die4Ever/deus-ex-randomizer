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
    editBrightness = CreateEdit(row++, "Brightness +", "1234567890", "5");

    btnRandoKeys.values[0] = "Off";
    btnRandoKeys.values[1] = "Smart";
    RandoKeys = CreateEnum(row++, "Key Randomization", btnRandoKeys);

    btnRandoDoors.values[0] = "Unchanged";
    btnRandoDoors.values[1] = "Destructible";
    btnRandoDoors.values[2] = "Pickable";
    btnRandoDoors.values[3] = "Either";
    btnRandoDoors.values[4] = "Both";
    RandoDoors = CreateEnum(row++, "Key-Only Doors", btnRandoDoors);

    btnRandoDevices.values[0] = "Unchanged";
    btnRandoDevices.values[1] = "Some Hackable";
    btnRandoDevices.values[2] = "All Hackable";
    RandoDevices = CreateEnum(row++, "Electronic Devices", btnRandoDevices);

    btnRandoPasswords.values[0] = "Randomized";
    btnRandoPasswords.values[1] = "Unchanged";
    RandoPasswords = CreateEnum(row++, "Passwords", btnRandoPasswords);

    editMinSkill = CreateEdit(row++, "Minimum Skill Cost %", "1234567890", "25");
    editMaxSkill = CreateEdit(row++, "Maximum Skill Cost %", "1234567890", "400");
    editAmmo = CreateEdit(row++, "Ammo Drops %", "1234567890", "80");
    editMultitools = CreateEdit(row++, "Multitools Drops %", "1234567890", "70");
    editLockpicks = CreateEdit(row++, "Lockpicks Drops %", "1234567890", "70");
    editBioCells = CreateEdit(row++, "Bioelectric Cells Drops %", "1234567890", "80");
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
	CreateMenuLabel( coords.x, coords.y+4, label, winClient);
    winLabel.SetFont(Font'FontTiny');
}

function MenuUIEditWindow CreateEdit(int row, string label, string filterString, optional string text )
{
    local MenuUIEditWindow edit;
    local vector coords;

    CreateLabel(row, label);

    coords = GetCoords(row, 1);
	edit = CreateMenuEditWindow(coords.x, coords.y, 126, 10, winClient);

	edit.SetText(text);
    edit.SetFilter(filterString);
	//edit.SetSensitivity(False);

    return edit;
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
    btn.SetFont(Font'FontTiny');

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

function ProcessAction(String actionKey)
{
	local int seed;
    local string sseed;
    local MissionNewGame ms;

	if (actionKey == "NEXT")
	{
		sseed = editSeed.GetText();
        if( sseed == "" ) seed = Rand(10000000);
        else seed = int(sseed);

        ms = player.Spawn(class'MissionNewGame');
        ms.SaveFlags(player, seed);
        ms.Destroy();
        InvokeNewGameScreen(combatDifficulty);
	}
}

function InvokeNewGameScreen(float difficulty)
{
	local MenuScreenNewGameRando newGame;

	newGame = MenuScreenNewGameRando(root.InvokeMenuScreen(Class'MenuScreenNewGameRando'));

	if (newGame != None)
		newGame.SetDifficulty(difficulty);
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
