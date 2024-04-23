class DXRMenuBase extends MenuUIScreenWindow;

var MenuUIInfoButtonWindow winNameBorder;

struct EnumBtn {
    var MenuUIActionButtonWindow btn;

#ifdef allstarts
    var string values[64];
#else
    var string values[32];
#endif

    var int value;
};
var EnumBtn enums[128];

var MenuUIScrollAreaWindow winScroll;
var Window controlsParent;
var MenuUILabelWindow winHelp;
var bool bHelpAlwaysOn;

var int id;
var bool writing;

var Window wnds[128];
var String labels[128];
var int hide_labels[128];
var String helptexts[128];

var DXRando dxr;
var DXRFlags flags;

var Texture background_texture, help_background_texture;
var color background, help_background;
var EDrawStyle background_style, help_background_style;

var int num_rows;
var int num_cols;
var int col_width_even;
var int col_width_odd;
var int row_height;
var int padding_width;
var int padding_height;
var Font groupHeaderFont;
var int groupHeaderX;
var int groupHeaderY;

var string BR;// line break

event Init(DXRando d)
{
    local vector coords;
    local int i;
    dxr = d;
    flags = dxr.flags;
    BR = Chr(10);

    coords = _GetCoords(num_rows, num_cols);
    ClientWidth = coords.X;
    ClientHeight = min(coords.Y, 500);

    Super.InitWindow();

    InitHelp();

    winClient.SetBackground(background_texture);
    winClient.SetBackgroundStyle(background_style);
    winClient.SetTileColor(background);

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
    _BindControls(false);

    // Need to do this because of the edit control used for
    // saving games.
    SetMouseFocusMode(MFOCUS_Click);
    for(i=0; i<ArrayCount(wnds); i++) {
        if( wnds[i] != None ) {
            SetFocusWindow(wnds[i]);
            break;
        }
    }
    winScroll.vScale.SetTickPosition(0);

    Show();

    StyleChanged();
}

function DXRFlags GetFlags()
{
    if( flags != None ) return flags;
    log(Self$".GetFlags calling GetDxr");
    GetDxr();
    return flags;
}

function DXRando GetDxr()
{
    if( dxr != None ) return dxr;

    log("GetDxr has player "$player);
#ifdef vmd
    // vmd loads a separate level for character creation
    foreach player.AllActors(class'DXRando', dxr) { break; }
#else
    dxr = player.Spawn(class'DXRando', None);
#endif
    log("GetDxr got "$dxr);
    dxr.CrcInit();
#ifdef hx
    //player() = HXHuman(player);
#else
    dxr.flagbase = #var(PlayerPawn)(player).FlagBase;
#endif
    if( dxr.flagbase == None ) log("ERROR: flagbase "$dxr.flagbase$" not found", name);

    dxr.LoadFlagsModule();
    flags = dxr.flags;
    flags.InitDefaults();
    return dxr;
}

function _InvokeNewGameScreen(float difficulty)
{
    local DXRMenuScreenNewGame newGame;
#ifdef vmd
    log("ERROR: "$self$"._InvokeNewGameScreen in VMD");
    return;
#endif

    newGame = DXRMenuScreenNewGame(root.InvokeMenuScreen(Class'DXRMenuScreenNewGame'));

    if (newGame != None) {
#ifdef gmdx
        newGame.SetDifficulty(difficulty, dxr.flags.autosave == 3);
#else
        newGame.SetDifficulty(difficulty);
#endif
        newGame.SetDxr(dxr);
    }
}

function NewMenuItem(string label, string helptext, optional bool hide_label)
{
    id++;
    labels[id] = label;
    hide_labels[id] = int(hide_label);
    helptexts[id] = helptext;
    log(Self @ label);
}

function BreakLine()
{
    local int width;
    width = num_cols / 2;
    while((id+1) % width != 0) id++;
}

function Indent()
{// ensure we're not in the left column
    local int width;
    width = num_cols / 2;
    if((id+1) % width == 0) id++;
}

function NewGroup(string text)
{
    local MenuUILabelWindow winLabel;
    local int width;
    local vector coords;

    width = num_cols / 2;
    if(id != -1)
        id += width;
    BreakLine();
    id++;

    coords = GetCoords(id, 0);
    winLabel = CreateMenuLabel(coords.x + groupHeaderX, coords.y + groupHeaderY, text, controlsParent);
    winLabel.SetFont(groupHeaderFont);
    BreakLine();
}

function bool EnumOption(string label, int value, optional out int output)
{
    local int i;
    local string s;

    if( writing ) {
        if( label == GetEnumValue(id) ) {
            log(self$"    EnumOption: "$label$", changing from "$output$" to "$value);
            output = value;
            return true;
        }
        return false;
    } else {
        for(i=0; i<ArrayCount(enums[id].values); i++) {
            if( enums[id].values[i] == label){
                break;
            } else if( enums[id].values[i] == "" ) {
                enums[id].values[i] = label;
                break;
            }
        }
        if ( enums[id].btn == None ) {
            if(hide_labels[id]==0) s = labels[id];
            enums[id].btn = CreateEnum(id, s, helptexts[id], enums[id]);
            wnds[id] = enums[id].btn;
        }
         log(self$"    EnumOption: "$label$" == "$value$" compared to default of "$output);
        if( output == value ) {
            enums[id].btn.SetButtonText(label);
            enums[id].value = i;
        }
    }
    return false;
}

function bool EnumOptionString(string label, string value, optional out string output)
{
    local int i;
    local string s;

    if( writing ) {
        if( label == GetEnumValue(id) ) {
            log(self$"    EnumOptionString: "$label$", changing from "$output$" to "$value);
            output = value;
            return true;
        }
        return false;
    } else {
        for(i=0; i<ArrayCount(enums[id].values); i++) {
            if( enums[id].values[i] == label){
                break;
            } else if( enums[id].values[i] == "" ) {
                enums[id].values[i] = label;
                break;
            }
        }
        if ( enums[id].btn == None ) {
            if(hide_labels[id]==0) s = labels[id];
            enums[id].btn = CreateEnum(id, s, helptexts[id], enums[id]);
            wnds[id] = enums[id].btn;
        }
        log(self$"    EnumOptionString: "$label$" == "$value$" compared to default of "$output);
        if( output == value ) {
            enums[id].btn.SetButtonText(label);
            enums[id].value = i;
        }
    }
    return false;
}

function string EditBox(string value, string pattern)
{
    local string s;

    if( writing ) {
        return MenuUIEditWindow(wnds[id]).GetText();
    } else {
        if ( wnds[id] == None ) {
            if(hide_labels[id]==0) s = labels[id];
            wnds[id] = CreateEdit(id, s, helptexts[id], pattern, value);
        }
    }
    return value;
}

function int Slider(out int value, int min, int max)
{
    local int output;
    local string s;

    if( writing ) {
        output = GetSliderValue(MenuUIEditWindow(wnds[id]));
        output = Clamp(output, min, max);
        log(Self$"    Slider: changing from "$value$" to "$output );
        value = output;
        return value;
    } else {
        if ( wnds[id] == None ) {
            if(hide_labels[id]==0) s = labels[id];
            wnds[id] = CreateSlider(id, s, helptexts[id], value, min, max);
        } else {
            MenuUIEditWindow(wnds[id]).SetText(string(value));
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
    _BindControls(true, actionKey);
}

function ResetToDefaults()
{
    //delete all controls and run BindControls(false) again?
}

function _BindControls(bool newwriting, optional string action)
{
    // start at -1 because NewMenuItem increments before adding
    id = -1;
    writing = newwriting;
    BindControls(action);
}

function BindControls(optional string action)
{
    // override in subclasses
}

function InitHelp()
{
    local MenuUILabelWindow winLabel;
    local vector coords;

    bHelpAlwaysOn = True;
    coords = _GetCoords(num_rows-1, 0);
    coords.y = ClientHeight + _GetY(0) - _GetY(1);
    winHelp = CreateMenuLabel(0 /*coords.x - padding_width*/, coords.y/*+4*/, "", winClient);
    winHelp.SetHeight(_GetY(1) - _GetY(0));
    winHelp.SetWidth(ClientWidth);
    winHelp.SetTextAlignments(HALIGN_Center, VALIGN_Center);

    winHelp.SetBackground(help_background_texture);
    winHelp.SetBackgroundStyle(help_background_style);
    winHelp.SetTileColor(help_background);
}

event DestroyWindow()
{
}

function CreateControls()
{
    Super.CreateControls();
    Title = "Deus Ex Randomizer "$ class'DXRVersion'.static.VersionString();
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
    if(InStr(helptexts[row], BR)==-1)
        helptexts[row] = helptexts[row] $ BR $ min $ " to " $ max;
    else
        helptexts[row] = helptexts[row] $ ", " $ min $ " to " $ max;
    return CreateEdit(row, label, helptext, "-1234567890", string(deflt));
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
    btn.SetWordWrap(false);
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
    local int i;

    for(i=0; i<ArrayCount(enums); i++) {
        if( buttonPressed == enums[i].btn ) {
            ClickEnum(i, rightClick);
            return true;
        }
    }
    return false;
}

function ClickEnum(int iEnum, bool rightClick)
{
    local EnumBtn e;
    local int numValues, i;
    local DXREnumList list;

    e = enums[iEnum];

    for(i=0; i<ArrayCount(e.values); i++) {
        if(e.values[i] != "") {
            numValues++;
        }
    }

    if(numValues > 5) {
        list = DXREnumList(root.InvokeUIScreen(class'DXREnumList'));
        list.Init(self, iEnum, labels[iEnum], helptexts[iEnum], e.values[e.value]);
        for(i=0; i<ArrayCount(e.values); i++) {
            if(e.values[i] != "") {
                list.AddButton(e.values[i]);
            }
        }
        list.Finalize();
        return;
    }

    if(rightClick) { // cycle backwards
        e.value--;
        if( e.value < 0 ) e.value = ArrayCount(e.values)-1;
        while( e.values[e.value] == "" ) {
            e.value--;
        }
    } else { // cycle forwards
        e.value++;
        e.value = e.value % ArrayCount(e.values);
        while( e.values[e.value] == "" ) {
            e.value++;
            e.value = e.value % ArrayCount(e.values);
        }
    }
    e.btn.SetButtonText(e.values[e.value]);
    enums[iEnum] = e;
}

function int GetSliderValue(MenuUIEditWindow w)
{
    return int(w.GetText());
}

function string GetEnumValue(int e)
{
    return enums[e].values[enums[e].value];
}

function string SetEnumValue(int e, string text)
{
    local int i;
    for(i=0; i<ArrayCount(enums[e].values); i++) {
        if(enums[e].values[i] == text) {
            enums[e].value = i;
            enums[e].btn.SetButtonText(text);
        }
    }
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
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
    groupHeaderFont=Font'FontMenuExtraLarge'
    groupHeaderX=-10
    groupHeaderY=-3
    background=(R=0,G=0,B=0,A=255)
    background_style=DSTY_Modulated
    background_texture=Texture'MaskTexture'
    help_background=(R=10,G=10,B=10,A=255)
    help_background_style=DSTY_Modulated
    help_background_texture=Texture'MaskTexture'
}
