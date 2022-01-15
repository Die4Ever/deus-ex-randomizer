class DXRBigMessage extends DeusExBaseWindow;

var Color redColor, blueColor, whiteColor, greenColor, BrightRedColor;
var bool bDestroy;
var float lockoutTime;
var string message;
var string detail;

const msgY = 0.25;
const kpStartY = 0.4;

const kpColumn1X = 0.20;
const kpColumn2X = 0.60;

static function CreateBigMessage(#var PlayerPawn  player, string message, string detail) {
    local DXRBigMessage m;
    local DeusExRootWindow root;

    root = DeusExRootWindow(player.rootWindow);
    if ( root != None )
    {
        m = DXRBigMessage(root.InvokeUIScreen(Class'DXRBigMessage', True));
        if ( m != None )
        {
            m.message = message;
            m.detail = detail;
        }
    }
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

    if(detail == "") {
        gc.SetTextColor( RedColor );
        gc.SetFont(Font'FontMenuExtraLarge');
        gc.GetTextExtent( 0, w, h, message );
        gc.DrawText( (width*0.5) - (w*0.5), msgY * height, w, h, message );
    } else {
        gc.SetTextColor( RedColor );
        gc.SetFont(Font'FontMenuExtraLarge');

        gc.GetTextExtent( 0, w, h, message );
        cury = msgY * height;
        gc.DrawText( (width*0.5) - (w*0.5), cury, w, h, message );
        cury += h;

        gc.GetTextExtent( 0, w, h, detail );
        gc.DrawText( (width*0.5) - (w*0.5), cury, w, h, detail );
    }

    Super.DrawWindow(gc);
}

function Remove()
{
    if ( !bDestroy )
    {
        bDestroy = True;
        root.PopWindow();
        Player.ShowMainMenu();
    }
}

event bool MouseButtonReleased(float pointX, float pointY, EInputKey button, int numClicks)
{
    if ( Player.Level.Timeseconds > lockoutTime )
        Remove();
    return True;
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
    if(key == IK_Escape) {
        Remove();
        return True;
    }
    else
        return Super.VirtualKeyPressed(key, bRepeat);
}

defaultproperties
{
    RedColor=(R=128)
    blueColor=(B=255)
    WhiteColor=(R=255,G=255,B=255)
    GreenColor=(G=255)
    BrightRedColor=(R=255)
}
