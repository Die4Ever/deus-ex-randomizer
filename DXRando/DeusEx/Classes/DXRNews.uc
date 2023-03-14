class DXRNews extends MenuUIScreenWindow;

var MenuUIScrollAreaWindow scroll;
var Window controlsParent;
var MenuUILabelWindow header;
var MenuUINormalLargeTextWindow text;
var DXRBase callbackModule;

event InitWindow()
{
    Super.InitWindow();
}

function CreateControls()
{
    Super.CreateControls();

    winClient.SetBackground(Texture'Solid');
    winClient.SetBackgroundStyle(DSTY_Normal);
    winClient.SetTileColorRGB(0,0,0);

    scroll = MenuUIScrollAreaWindow(winClient.NewChild(Class'MenuUIScrollAreaWindow'));
    scroll.SetPos(0, 0);
    scroll.SetSize(ClientWidth, ClientHeight);
    scroll.vScale.SetThumbStep(20);

    controlsParent = scroll.clipWindow;
    controlsParent = controlsParent.NewChild(class'MenuUIClientWindow');

    header = CreateMenuLabel(0, 0, "Header", controlsParent);
    header.SetFont(Font'FontMenuTitle');
    header.SetTextMargins(8, 8);

    text = MenuUINormalLargeTextWindow(controlsParent.NewChild(Class'MenuUINormalLargeTextWindow'));
    text.SetPos(0, header.y + header.height + 16);
    text.SetFont(Font'FontMenuHeaders_DS');
    text.SetTextMargins(16, 8);
    text.SetWordWrap(True);
    text.SetTextAlignments(HALIGN_Left, VALIGN_Top);
    text.SetVerticalSpacing(2);
}

function Set(DXRBase callback, string newtitle, string newheader, string newtext)
{
    callbackModule = callback;
    SetTitle(newtitle);
    header.SetText(newheader);
    text.SetText(newtext);

    controlsParent.SetSize(controlsParent.width, text.y + text.height);
}

function Append(string newtext)
{
    text.AppendText(CR() $ newtext);
}

function ProcessAction(String actionKey)
{
    log(self@"ProcessAction"@actionKey);
    if(callbackModule==None) return;

    switch(actionKey) {
    case "Open Browser":
        callbackModule.MessageBoxClicked(0, 0);
        break;

    case "Cancel":
        callbackModule.MessageBoxClicked(1, 0);
        break;
    }
}

function DestroyWindow()
{
   Super.DestroyWindow();
}

defaultproperties
{
    actionButtons(0)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Cancel",Key="Cancel")
    actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Open Browser",Key="Open Browser")
    Title="News"
    ClientWidth=556
    ClientHeight=283
}
