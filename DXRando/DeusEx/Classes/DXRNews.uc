class DXRNews extends MenuUIScreenWindow;

var MenuUIScrollAreaWindow scroll;
var MenuUINormalLargeTextWindow text;
var DXRBase callbackModule;

event InitWindow()
{
    Super.InitWindow();
}

function CreateControls()
{
    local int i;
    Super.CreateControls();

    winClient.SetBackground(Texture'Solid');
    winClient.SetBackgroundStyle(DSTY_Normal);
    winClient.SetTileColorRGB(0,0,0);

    scroll = MenuUIScrollAreaWindow(winClient.NewChild(Class'MenuUIScrollAreaWindow'));
    scroll.SetPos(0, 0);
    scroll.SetSize(ClientWidth, ClientHeight);

    text = MenuUINormalLargeTextWindow(scroll.ClipWindow.NewChild(Class'MenuUINormalLargeTextWindow'));
    text.SetTextMargins(4, 4);
    text.SetWordWrap(True);
    text.SetTextAlignments(HALIGN_Left, VALIGN_Top);
    text.SetVerticalSpacing(8);
}

function Set(DXRBase callback, string newtitle, string newtext)
{
    callbackModule = callback;
    SetTitle(newtitle);
    text.SetText(newtext);
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
