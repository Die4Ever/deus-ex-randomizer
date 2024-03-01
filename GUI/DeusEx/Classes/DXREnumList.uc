class DXREnumList extends MenuUIScreenWindow;

var DXRMenuBase parent;
var MenuUIScrollAreaWindow winScroll;
var Window controlsParent;

var int iEnum;
var int button_y_pos, x_pad, y_pad;

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

function AddButton(string text)
{
    local MenuUIActionButtonWindow btn;

    btn = MenuUIActionButtonWindow(controlsParent.NewChild(Class'MenuUIActionButtonWindow'));
    btn.SetButtonText(text);
    btn.SetPos(x_pad, button_y_pos);
    button_y_pos += btn.height + y_pad;
    btn.SetWidth(controlsParent.width - x_pad*2);

    if(button_y_pos > controlsParent.height) {
        controlsParent.SetHeight(button_y_pos);
    }
    winScroll.vScale.SetTickPosition(0);
}


function bool ButtonActivated( Window buttonPressed )
{
    local MenuUIActionButtonWindow button;

    button = MenuUIActionButtonWindow(buttonPressed);
    if(button == None) {
        return Super.ButtonActivated(buttonPressed);
    }

    //SetTitle(button.buttonText);
    parent.SetEnumValue(iEnum, button.buttonText);
    root.PopWindow();
    return true;
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
}
