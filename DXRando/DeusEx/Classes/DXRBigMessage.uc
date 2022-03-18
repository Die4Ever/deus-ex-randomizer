class DXRBigMessage extends DeusExBaseWindow;

var Color redColor, blueColor, whiteColor, greenColor, BrightRedColor;
var bool bDestroy;
var float lockoutTime;
var string message;
var string detail;
var DXRHints hints;

const msgY = 0.25;
const kpStartY = 0.4;

const kpColumn1X = 0.20;
const kpColumn2X = 0.60;

static function DXRBigMessage GetCurrentBigMessage(#var PlayerPawn  player) {
    local DXRBigMessage m;
    local DeusExRootWindow root;

    root = DeusExRootWindow(player.rootWindow);
    if ( root == None )
        return None;

    return DXRBigMessage(root.GetTopWindow());
}

static function DXRBigMessage CreateBigMessage(#var PlayerPawn  player, DXRHints hints, string message, string detail) {
    local DXRBigMessage m;
    local DeusExRootWindow root;

    root = DeusExRootWindow(player.rootWindow);
    if ( root == None )
        return None;

    m = GetCurrentBigMessage(player);
    if ( m != None ) {
        if( m.message == message && m.detail == detail )
            return None;
        root.PopWindow();
        root.ShowHud(false);
    }

    m = DXRBigMessage(root.InvokeUIScreen(Class'DXRBigMessage', True));
    if ( m != None )
    {
        m.message = message;
        m.detail = detail;
        m.hints = hints;
    }
    return m;
}

event InitWindow()
{
    Super.InitWindow();
    bDestroy = false;
    SetWindowAlignments(HALIGN_Full, VALIGN_Full);
    Show();
    root.ShowCursor(False);
    lockoutTime = Player.Level.Timeseconds + 1.0;
}

event DestroyWindow()
{
    root.ShowCursor( True );
    Super.DestroyWindow();
}

event DrawWindow(GC gc)
{
    local float w, h, cury;

    // this prevents DeusExPlayer Dying state PlayerCalcView() from timing out
    if(Player.Level.Timeseconds - player.FrobTime > 7.9) {
        player.FrobTime = Player.Level.Timeseconds - 7.9;
    }

    gc.SetTextColor( RedColor );
    gc.SetFont(Font'FontMenuExtraLarge');
    gc.GetTextExtent( 0, w, h, message );
    cury = msgY * height;
    gc.DrawText( (width*0.5) - (w*0.5), cury, w, h, message );

    if(detail != "") {
        cury += h;
        gc.GetTextExtent( 0, w, h, detail );
        gc.DrawText( (width*0.5) - (w*0.5), cury, w, h, detail );
    }

    cury = msgY * height + h * 3.0;
    gc.GetTextExtent( 0, w, h, "Press right for another hint." );
    gc.DrawText( (width*0.5) - (w*0.5), cury, w, h, "Press right for another hint." );

    Super.DrawWindow(gc);
}

function Remove()
{
    if ( !bDestroy )
    {
        bDestroy = True;
        root.PopWindow();
#ifndef hx
        Player.ShowMainMenu();
#endif
    }
}

event bool MouseButtonReleased(float pointX, float pointY, EInputKey button, int numClicks)
{
    if ( Player.Level.Timeseconds > lockoutTime )
        Remove();
    return True;
}

//Find what key is bound to the given action
function string FindKeyBinding(string binding)
{
    local int i;
    local string KeyName;
    local string Alias;

    for (i=0;i<255;i++){
        KeyName = Player.ConsoleCommand("KEYNAME "$i);
        if (KeyName!="") {
            Alias = Player.ConsoleCommand("KEYBINDING "$KeyName);
            if (Alias ~= binding) { //Case-insensitive, just to be nice
                return KeyName;
            }
        }
    }
    return "";
}

//Find what action is bound to the given key
function string GetKeyAssigned(EInputKey key)
{
    // based on DeusExRootWindow.IsKeyAssigned
    local int pos;
    local string InputKeyName;
    local string Alias;

    InputKeyName = mid(string(GetEnum(enum'EInputKey',key)),3);

    return Caps(Player.ConsoleCommand("KEYBINDING " $ InputKeyName));
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
    local string command;
    if(key == IK_Escape) {
        Remove();
        // idk why escape requires me to call ShowMainMenu twice but it works
        Player.ShowMainMenu();
        return True;
    }
    else if(key == IK_Space && Player.Level.Timeseconds > lockoutTime) {
        Remove();
        return True;
    }
    else {
        command = GetKeyAssigned(key);
        if( command ~= "QuickLoad" || InStr(command, "LOADGAME") != -1 ) {
            player.ConsoleCommand(command);
            return true;
        }
        else if( hints != None && (command ~= "StrafeRight" || command ~= "TurnRight") ) {
            hints.ShowHint();
            return true;
        }
        return Super.VirtualKeyPressed(key, bRepeat);
    }
}

defaultproperties
{
    RedColor=(R=128)
    blueColor=(B=255)
    WhiteColor=(R=255,G=255,B=255)
    GreenColor=(G=255)
    BrightRedColor=(R=255)
}
