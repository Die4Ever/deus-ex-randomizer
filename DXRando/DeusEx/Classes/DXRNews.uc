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

<<<<<<< HEAD
function int SetText(int i, string newdate, string newheader, string newtext, int y)
{
    if(newdate != "")
        newheader = newdate $ ": " $ newheader;

    newsheaders[i].SetPos(0, y);
    newsheaders[i].SetText(newheader);
    newsheaders[i].ResizeChild();
    if(newheader != "")
        y += newsheaders[i].height;

    if(newtext != "")
        newtext = newtext $ "|n";
    newstexts[i].SetPos(0, y);
    newstexts[i].SetText(newtext);
    newstexts[i].ResizeChild();
    if(newtext != "")
        y += newstexts[i].height;

    return y;
}

function Set(DXRTelemetry tele)
{
    local int i, y;
    tel = tele;

    if(tel != None) {
        for(i=0; i<ArrayCount(newsheaders); i++) {
            y = SetText(i, tel.newsdates[i], tel.newsheaders[i], tel.newstexts[i], y);
        }
        // TODO: add a button to open in browser
    } else {
        y = SetText(0, "", "Loading News...", "", y);
    }

    controlsParent.SetHeight(y);
}

function bool HasNews()
{
    if(tel == None || tel.enabled == false) return false;
    if( tel.dxr.localURL == "DX" || tel.dxr.localURL == "DXONLY" ) return true;
    return false;
=======
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
>>>>>>> bb61e1e (better update notifications (#248))
}
