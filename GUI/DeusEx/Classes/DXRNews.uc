class DXRNews extends MenuUIClientWindow;

var MenuUIScrollAreaWindow scroll;
var Window controlsParent;
var MenuUINormalLargeTextWindow newsheaders[5];// keep array sizes in sync with DXRTelemetry
var MenuUINormalLargeTextWindow newstexts[5];
var DXRTelemetry tel;

function CreateNews(Actor a, int newX, int newY, int ClientWidth, int ClientHeight)
{
    local int i;

    SetPos(newX, newY);
    SetSize(ClientWidth, ClientHeight);
    SetBackground(Texture'MaskTexture');
    SetBackgroundStyle(DSTY_Modulated);
    SetTileColorRGB(0,0,0);
    controlsParent = self;

    scroll = MenuUIScrollAreaWindow(controlsParent.NewChild(Class'MenuUIScrollAreaWindow'));
    scroll.SetPos(0, 0);
    scroll.SetSize(ClientWidth, ClientHeight);
    scroll.EnableScrolling(false, true);
    scroll.vScale.SetThumbStep(20);

    controlsParent = scroll.clipWindow;
    controlsParent = controlsParent.NewChild(class'MenuUIClientWindow');
    controlsParent.SetHeight(ClientHeight+200);// init with the scrollbar so it's part of our width
    scroll.ResizeChild();

    for(i=0; i<ArrayCount(newsheaders); i++) {
        newsheaders[i] = MenuUINormalLargeTextWindow(controlsParent.NewChild(Class'MenuUINormalLargeTextWindow'));
        newsheaders[i].SetWidth(controlsParent.width);
        newsheaders[i].SetFont(Font'FontMenuTitle');
        newsheaders[i].SetTextMargins(4, 8);
        newsheaders[i].SetWordWrap(True);
        newsheaders[i].SetTextAlignments(HALIGN_Left, VALIGN_Top);
        newsheaders[i].SetVerticalSpacing(2);

        newstexts[i] = MenuUINormalLargeTextWindow(controlsParent.NewChild(Class'MenuUINormalLargeTextWindow'));
        newstexts[i].SetWidth(controlsParent.width);
        newstexts[i].SetFont(Font'FontMenuHeaders_DS');
        newstexts[i].SetTextMargins(12, 8);
        newstexts[i].SetWordWrap(True);
        newstexts[i].SetTextAlignments(HALIGN_Left, VALIGN_Top);
        newstexts[i].SetVerticalSpacing(2);
    }

    // TODO: add a button to open in browser

    foreach a.AllActors(class'DXRTelemetry', tel) {
        Set(tel);
        break;
    }
}

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
    if(!bool(player.ConsoleCommand("get MenuChoice_ShowNews show_news")))
        return false;
    if(tel == None || tel.enabled == false) return false;
    if( tel.dxr.localURL == "DX" || tel.dxr.localURL == "DXONLY" ) return true;
    return false;
}
