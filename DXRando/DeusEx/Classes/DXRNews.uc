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
