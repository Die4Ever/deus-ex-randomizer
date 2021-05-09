#ifdef hx
class DXRMenuBase expands MenuUIScreenWindow config(HXRando);
#else
class DXRMenuBase expands MenuUIScreenWindow config(DXRando);
#endif

var MenuUIInfoButtonWindow winNameBorder;

struct EnumBtn {
    var MenuUIActionButtonWindow btn;
    var string values[32];
    var int value;
};
var EnumBtn enums[64];

var MenuUIScrollAreaWindow winScroll;
var Window controlsParent;
var MenuUILabelWindow winHelp;
var bool bHelpAlwaysOn;

var int id;
//var int numwnds;
var Window wnds[64];
var String labels[64];
var String helptexts[64];

var DXRando dxr;
var DXRFlags flags;

var config int config_version;

var config int num_rows;
var config int num_cols;
var config int col_width_even;
var config int col_width_odd;
var config int row_height;
var config int padding_width;
var config int padding_height;

event Init(DXRando d)
{
    local vector coords;
    dxr = d;
    flags = dxr.flags;

    CheckConfig();

    coords = _GetCoords(num_rows, num_cols);
    ClientWidth = coords.X;
    ClientHeight = min(coords.Y, 500);

    Super.InitWindow();

    InitHelp();

    controlsParent = winClient;
    winScroll = CreateScrollAreaWindow(winClient);
    winScroll.vScale.SetThumbStep(20);
    winScroll.SetPos(0, 0);
    winScroll.SetSize(ClientWidth, ClientHeight + _GetY(0) - _GetY(1) );
    //winScroll.AutoHideScrollbars(false);
    winScroll.EnableScrolling(false,true);
    controlsParent = winScroll.clipWindow;
    controlsParent = controlsParent.NewChild(class'MenuUIClientWindow');
    coords = _GetCoords(num_rows-1, num_cols);// num_rows-1 cause no help text inside the scroll area
    controlsParent.SetSize(coords.X, coords.Y);

    ResetToDefaults();
    BindControls(false);

    // Need to do this because of the edit control used for 
    // saving games.
    SetMouseFocusMode(MFOCUS_Click);
    if( wnds[0] != None ) SetFocusWindow(wnds[0]);
    winScroll.vScale.SetTickPosition(0);

    Show();

    StyleChanged();
}

function DXRFlags InitFlags()
{
    if( flags != None ) return flags;
    flags = player.Spawn(class'DXRFlags', None);
    flags.InitDefaults();
    return flags;
}

function DXRando InitDxr()
{
    if( dxr != None ) return dxr;
    
    log("InitDxr has player "$player);
    dxr = player.Spawn(class'DXRando', None);
    log("InitDxr got "$dxr);
#ifdef hx
    //player() = HXHuman(player);
#else
    dxr.flagbase = #var PlayerPawn (player).FlagBase;
#endif
    if( dxr.flagbase == None ) log("ERROR: flagbase "$dxr.flagbase$" not found", name);

    InitFlags();
    if( flags != None ) {
        dxr.modules[0] = flags;
        dxr.num_modules = 1;
    }
    dxr.LoadFlagsModule();
    if( flags == None ) dxr.flags.InitDefaults();
    flags = dxr.flags;
    return dxr;
}

function InvokeNewGameScreen(float difficulty, DXRando dxr)
{
    local DXRMenuScreenNewGame newGame;

    newGame = DXRMenuScreenNewGame(root.InvokeMenuScreen(Class'DXRMenuScreenNewGame'));

    if (newGame != None) {
        newGame.SetDifficulty(difficulty);
        newGame.SetDxr(dxr);
    }
}

function CheckConfig()
{
    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
        log(Self$": upgraded config from "$config_version$" to "$class'DXRFlags'.static.VersionNumber());
        config_version = class'DXRFlags'.static.VersionNumber();
        SaveConfig();
    }
}

function bool EnumOption(int id, string label, int value, bool writing, optional out int output)
{
    local int i;

    if( writing ) {
        if( label == GetEnumValue(id) ) {
            output = value;
            return true;
        }
        return false;
    } else {
        for(i=0; i<ArrayCount(enums[id].values); i++) {
            if( enums[id].values[i] == "" ) {
                enums[id].values[i] = label;
                break;
            }
        }
        if ( enums[id].btn == None ) {
            enums[id].btn = CreateEnum(id, labels[id], helptexts[id], enums[id]);
            wnds[id] = enums[id].btn;
        }
        if( output == value ) {
            enums[id].btn.SetButtonText(label);
            enums[id].value = i;
        }
    }
    return false;
}

function bool EnumOptionString(int id, string label, string value, bool writing, optional out string output)
{
    local int i;

    if( writing ) {
        if( label == GetEnumValue(id) ) {
            output = value;
            return true;
        }
        return false;
    } else {
        for(i=0; i<ArrayCount(enums[id].values); i++) {
            if( enums[id].values[i] == "" ) {
                enums[id].values[i] = label;
                break;
            }
        }
        if ( enums[id].btn == None ) {
            enums[id].btn = CreateEnum(id, labels[id], helptexts[id], enums[id]);
            wnds[id] = enums[id].btn;
        }
        if( output == value ) {
            enums[id].btn.SetButtonText(label);
            enums[id].value = i;
        }
    }
    return false;
}

function string EditBox(int id, string value, string pattern, bool writing)
{
    if( writing ) {
        return MenuUIEditWindow(wnds[id]).GetText();
    } else {
        if ( wnds[id] == None ) {
            wnds[id] = CreateEdit(id, labels[id], helptexts[id], pattern, value);
        }
    }
    return value;
}

function int Slider(int id, out int value, int min, int max, bool writing)
{
    if( writing ) {
        value = GetSliderValue(MenuUIEditWindow(wnds[id]));
        return value;
    } else {
        if ( wnds[id] == None ) {
            wnds[id] = CreateSlider(id, labels[id], helptexts[id], value, min, max);
        }
    }
    return value;
}

static function int UnpackInt(out string s)
{
    local int i, ret, l;
    l = Len(s);
    for(i=0; i<l; i++) {
        if( Mid(s, i, 1) == ";" ) {
            ret = int(Left(s, i));
            s = Mid(s, i+1);
            return ret;
        }
    }
    ret = int(s);
    s="";
    return ret;
}

function ProcessAction(String actionKey)
{
    BindControls(true, actionKey);
}

function ResetToDefaults()
{
    //delete all controls and run BindControls(false) again?
}

function BindControls(bool writing, optional string action)
{
    id=0;
}

function InitHelp()
{
    local MenuUILabelWindow winLabel;
    local vector coords;
    bHelpAlwaysOn = True;
    coords = _GetCoords(num_rows-1, 0);
    coords.y = ClientHeight + _GetY(0) - _GetY(1);
    winHelp = CreateMenuLabel( coords.x, coords.y+4, "", winClient);
}

event DestroyWindow()
{
}

function CreateControls()
{
    Super.CreateControls();
    Title = "Deus Ex Randomizer "$ class'DXRFlags'.static.VersionString();
    SetTitle(Title);
    //if(flags == None) return;
    //BindControls(false);
}

function vector GetCoords(int row, int col)
{
    col += (row % (num_cols/2)) * 2;
    row /= max(num_cols/2, 1);

    if( _GetY(row+1) > controlsParent.height ) {
        controlsParent.SetSize( controlsParent.width, _GetY(row+1) );
    }
    return _GetCoords(row, col);
}

function vector _GetCoords(int row, int col)
{
    local vector v;
    v.x = _GetX(col);
    v.y = _GetY(row);
    return v;
}

function int _GetY(int row)
{
    return row * row_height + row*padding_height + padding_height;
}

function int _GetX(int col)
{
    local int width;
    width = col_width_even + col_width_odd;
    width *= col/2;
    width += int(col%2) * col_width_odd;//I use col_width_odd here because it's 0-indexed
    width += padding_width*col + padding_width;
    return width;
}

function int GetWidth(int row, int col, int cols)
{
    while( row >= num_rows-1 ) {
        row -= num_rows-1;
        col += 2;
    }
    return _GetX(col+cols) - _GetX(col) - padding_width;
}

function MenuUILabelWindow CreateLabel(int row, string label)
{
    local MenuUILabelWindow winLabel;
    local vector coords;
    coords = GetCoords(row, 0);
    winLabel = CreateMenuLabel( coords.x, coords.y+4, label, controlsParent);
    return winLabel;
}

// copied from MenuUIWindow.uc
function MenuUIEditWindow CreateMenuEditWindow(int posX, int posY, int editWidth, int maxChars, Window winParent)
{
    local MenuUIInfoButtonWindow btnInfo;
    local ClipWindow             clipName;
    local MenuUIEditWindow       newEdit;

    // Create an info button behind this sucker
    btnInfo = MenuUIInfoButtonWindow(winParent.NewChild(Class'MenuUIInfoButtonWindow'));
    btnInfo.SetPos(posX, posY);
    btnInfo.SetWidth(editWidth);
    btnInfo.SetSensitivity(False);

    // the original code foolishly uses winClient here instead of the winParent argument
    clipName = ClipWindow(winParent.newChild(Class'ClipWindow'));
    clipName.SetWidth(editWidth - 8);
    clipName.ForceChildSize(False, True);
    clipName.SetPos(posX + 4, posY + 5);

    newEdit = MenuUIEditWindow(clipName.NewChild(Class'MenuUIEditWindow'));
    newEdit.SetMaxSize(maxChars);

    return newEdit;
}

function MenuUIEditWindow CreateEdit(int row, string label, string helptext, string filterString, optional string deflt )
{
    local MenuUIEditWindow edit;
    local vector coords;

    CreateLabel(row, label);

    coords = GetCoords(row, 1);
    edit = CreateMenuEditWindow(coords.x, coords.y, GetWidth(row, 1, 1), 10, controlsParent);

    edit.SetText(deflt);
    edit.SetFilter(filterString);
    //edit.SetSensitivity(False);

    //wnds[numwnds] = edit;
    //helptexts[numwnds] = helptext;
    //numwnds++;

    return edit;
}

function MenuUIEditWindow CreateSlider(int row, string label, string helptext, optional int deflt, optional int min, optional int max )
{
    return CreateEdit(row, label, helptext, "1234567890", string(deflt));
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
    slider = MenuUISliderButtonWindow(controlsParent.NewChild(Class'MenuUISliderButtonWindow'));
    slider.SetPos(coords.x, coords.y);
    slider.SetTicks(numTicks, min, max);
    slider.winSlider.SetValue(deflt);
    for(i=0; i<numTicks; i++) {
        slider.winSlider.SetEnumeration(i, string(i*mult)$"%" );
    }
    //slider.winScaleManager.SetWidth(GetWidth(row, 1, 1));
    //slider.winSlider.SetScaleTexture(slider.defaultScaleTexture, 50, 21, 8, 8);
    //slider.winScaleManager.StretchScaleField(true);
    //slider.winSlider.EnableStretchedScale(true);
    //slider.winSlider.SetWidth(50);
    slider.winSlider.SetScaleTexture(slider.defaultScaleTexture, 50, 21, 8, 8);

    return slider;*/
}

function MenuUIActionButtonWindow CreateBtn(int row, string label, string helptext, string text)
{
    local MenuUIActionButtonWindow btn;
    local vector coords;

    if( label != "" ) CreateLabel(row, label);

    btn = MenuUIActionButtonWindow(controlsParent.NewChild(Class'MenuUIActionButtonWindow'));
    btn.SetButtonText(text);
    if( label == "" ) {
        coords = GetCoords(row, 0);
        btn.SetPos(coords.x, coords.y);
        btn.SetWidth(GetWidth(row, 0, 2));
    }
    else {
        coords = GetCoords(row, 1);
        btn.SetPos(coords.x, coords.y);
        btn.SetWidth(GetWidth(row, 1, 1));
    }
    //btn.SetFont(Font'FontTiny');

    //wnds[numwnds] = btn;
    //helptexts[numwnds] = helptext;
    //numwnds++;

    return btn;
}

function MenuUIActionButtonWindow CreateEnum(int row, string label, string helptext, optional EnumBtn e)
{
    local int i;
    if(e.values[0] == "") {
        e.values[0] = "Off";
        e.values[1] = "On";
    }
    for( e.value=0; e.value < ArrayCount(e.values); e.value++ ) {
        if(e.values[e.value] != "") break;
    }
    e.btn = CreateBtn(row, label, helptext, e.values[e.value]);
    e.btn.EnableRightMouseClick();
    return e.btn;
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

function bool ButtonActivatedRight( Window buttonPressed )
{
    local bool bHandled;
    bHandled = True;

    if( CheckClickEnum(buttonPressed, true) ) { }
    else {
        bHandled = False;
    }

    if ( !bHandled )
        bHandled = Super.ButtonActivated(buttonPressed);

    return bHandled;
}

function bool CheckClickEnum( Window buttonPressed, optional bool rightClick )
{
    local EnumBtn e;
    local int i;

    for(i=0; i<ArrayCount(enums); i++) {
        e=enums[i];
        if( buttonPressed == e.btn ) {
            if( rightClick ) enums[i] = RightClickEnum(e);
            else enums[i] = ClickEnum(e);
            return true;
        }
    }
    return false;
}

function EnumBtn ClickEnum(EnumBtn e)
{
    e.value++;
    e.value = e.value % ArrayCount(e.values);
    while( e.values[e.value] == "" ) {
        e.value++;
        e.value = e.value % ArrayCount(e.values);
    }
    e.btn.SetButtonText(e.values[e.value]);
    return e;
}

function EnumBtn RightClickEnum(EnumBtn e)
{
    e.value--;
    if( e.value < 0 ) e.value = ArrayCount(e.values)-1;
    while( e.values[e.value] == "" ) {
        e.value--;
    }
    e.btn.SetButtonText(e.values[e.value]);
    return e;
}

function int GetSliderValue(MenuUIEditWindow w)
{
    return int(w.GetText());
}

function string GetEnumValue(int e)
{
    return enums[e].values[enums[e].value];
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

// ----------------------------------------------------------------------
// FocusEnteredDescendant() : Called when a descendant window gets focus
// ----------------------------------------------------------------------

event FocusEnteredDescendant(Window enterWindow)
{
    local int i;
    
    if( enterWindow == None ) return;

    for(i=0;i<ArrayCount(wnds);i++) {
        if( wnds[i] == enterWindow ) {
            winHelp.Show();
            winHelp.SetText(helptexts[i]);
            return;
        }
    }
}


// ----------------------------------------------------------------------
// FocusLeftDescendant() : Called when a descendant window loses focus
// ----------------------------------------------------------------------

event FocusLeftDescendant(Window leaveWindow)
{
    if ((winHelp != None) && (!bHelpAlwaysOn))
        winHelp.Hide();

    currentChoice = None;
}

defaultproperties
{
    num_rows=12
    num_cols=4
    col_width_odd=160
    col_width_even=140
    row_height=20
    padding_width=20
    padding_height=10
    actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel,Text="|&Back")
    actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Next",Key="NEXT")
    //actionButtons(2)=(Action=AB_Reset)
    Title="DX Rando Options"
    ClientWidth=672
    ClientHeight=357
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
}
