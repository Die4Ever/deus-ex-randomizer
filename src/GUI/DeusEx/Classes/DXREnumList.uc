class DXREnumList extends MenuUIScreenWindow;

var DXRMenuBase parent;
var MenuUIScrollAreaWindow winScroll;
var Window controlsParent;

var int iEnum;
var int button_y_pos, x_pad, y_pad;
var bool bLeftEdgeShort;

const HELP_BTN_WIDTH = 21;
const HELP_BTN_PAD = 5;

function CreateControls()
{
    Super.CreateControls();

    winClient.SetBackground(Texture'MaskTexture'); // Texture'Solid'
    winClient.SetBackgroundStyle(DSTY_Normal);
    winClient.SetTileColorRGB(0,0,0);

    winScroll = CreateScrollAreaWindow(winClient);
    winScroll.vScale.SetThumbStep(20);
    winScroll.SetPos(0, 0);
    winScroll.SetSize(ClientWidth, ClientHeight);
    winScroll.AutoHideScrollbars(false);
    winScroll.EnableScrolling(false,true);
    controlsParent = winScroll.clipWindow;
    controlsParent = controlsParent.NewChild(class'MenuUIClientWindow');

    winScroll.vScale.SetTickPosition(0);
}

function Init(DXRMenuBase newparent, int NewiEnum, string title, string helptext, string current_value)
{
    parent = newparent;
    iEnum = NewiEnum;
    if(title != "") {
        SetTitle(title);
    }
    if(helptext != "") {
        CreateLabel(helptext);
    }
    if(current_value != "") {
        CreateLabel("Current Selection: " $ current_value);
    }
}

function Finalize()
{
    winScroll.AutoHideScrollbars(true);
}

function MenuUILabelWindow CreateLabel(string label)
{
    local MenuUILabelWindow winLabel;
    winLabel = CreateMenuLabel(x_pad, button_y_pos, label, controlsParent);
    winLabel.SetWidth(controlsParent.width - x_pad*2);
    button_y_pos += winLabel.height + y_pad;
    return winLabel;
}

function AddButton(string text, optional string help)
{
    local MenuUIActionButtonWindow mainBtn;
    local DXRMenuUIHelpButtonWindow helpBtn;
    local int mainBtnWidth, helpBtnWidth;
    local int main_x_pos,help_x_pos;

    main_x_pos = x_pad;
    if (help=="") {
        helpBtnWidth=0;
        mainBtnWidth=controlsParent.width - x_pad*2;
    } else {
        helpBtnWidth=HELP_BTN_WIDTH;
        mainBtnWidth=controlsParent.width - helpBtnWidth - HELP_BTN_PAD - x_pad*2;
        help_x_pos = main_x_pos + mainBtnWidth + HELP_BTN_PAD;
    }

    mainBtn = MenuUIActionButtonWindow(controlsParent.NewChild(Class'MenuUIActionButtonWindow'));
    mainBtn.SetButtonText(text);
    mainBtn.SetPos(x_pad, button_y_pos);
    mainBtn.SetWidth(mainBtnWidth);

    if (helpBtnWidth>0) {
        helpBtn = DXRMenuUIHelpButtonWindow(controlsParent.NewChild(Class'DXRMenuUIHelpButtonWindow'));
        helpBtn.SetButtonText("?");
        helpBtn.SetPos(help_x_pos, button_y_pos);
        helpBtn.SetWidth(helpBtnWidth);
        helpBtn.SetHelpTitle(text);
        helpBtn.SetHelpText(help);
    }

    button_y_pos += mainBtn.height + y_pad;

    if(button_y_pos > controlsParent.height) {
        controlsParent.SetHeight(button_y_pos);
    }
    winScroll.vScale.SetTickPosition(0);
}


function bool ButtonActivated( Window buttonPressed )
{
    local MenuUIActionButtonWindow button;
    local DXRMenuUIHelpButtonWindow helpButton;

    button = MenuUIActionButtonWindow(buttonPressed);
    helpButton = DXRMenuUIHelpButtonWindow(buttonPressed);
    if(button == None && helpButton == None) {
        return Super.ButtonActivated(buttonPressed);
    }

    if (helpButton!=None) {
        class'BingoHintMsgBox'.static.Create(root, helpButton.GetHelpTitle(), helpButton.GetHelpText(), 1, False, self);
        return true;
    } else {
        //SetTitle(button.buttonText);
        parent.SetEnumValue(iEnum, button.buttonText);
        root.PopWindow();
        return true;
    }
}

//So that the BingoHintMsgBox button can be handled
event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
    // Destroy the msgbox!
    DeusExRootWindow(player.rootWindow).PopWindow();

    return True;
}

function CreateLeftEdgeWindow()
{
    Super.CreateLeftEdgeWindow();
    if (bLeftEdgeActive && bLeftEdgeShort) {
        //Instead of default 16, moves the left edge up to the bottom edge of the window,
        //since there is no button on the left side
        winLeftEdge.bottomHeight=36;
    }
}

defaultproperties
{
    actionButtons(0)=(Align=HALIGN_Right,Action=AB_Cancel,Text="|&Cancel",Key="CANCEL")
    //actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Open In Browser",Key="OPEN")
    Title="Choose Option"
    ClientWidth=400
    ClientHeight=350
    button_y_pos=20
    x_pad=20
    y_pad=10
    bLeftEdgeShort=true
}
