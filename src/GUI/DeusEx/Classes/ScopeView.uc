#ifdef revision
class DXRScopeView extends RevScopeView;
#else
class DXRScopeView injects DeusExScopeView;
#endif

var int watchTime;
var Actor lastWatched;
var name lastWatchedTex;
var int watchTimerId;

event DrawWindow(GC gc)
{
    local float fromX, toX;
    local float fromY, toY;
    local float screenHeight, scopeWidth, scopeHeight, scopeMult, scopeMult2, scopeMultInt, scopeMultFirstDec;
    local bool blackOut;
    local Actor a;

    Super(Window).DrawWindow(gc);

    a = GetRootWindow().parentPawn;
    if (a != None)
    {
        if (player.IsInState('Dying'))
            return;
    }

    // Figure out where to put everything
    if (bBinocs)
        scopeWidth  = 512;
    else
        scopeWidth  = 256;

    scopeHeight = 256;

    scopeMult = class'MenuChoice_ScopeScaling'.static.GetScopeScale();
    blackOut  = class'MenuChoice_ScopeBlackout'.static.IsEnabled(a);

    if (scopeMult < 0){
        //Fit to screen, calculate scope mult value
        //Round to the nearest 0.5 so that the scaling at least looks nice

        //-1.0 = Fit to the maximum screen size
        //-2.0 = scale to not overlap the item belt

        screenHeight = height;
        if (scopeMult==-2.0){ //Should we avoid overlapping the item belt?  Should this be an option?
            screenHeight -= DeusExRootWindow(GetRootWindow()).hud.belt.height;
        }

        scopeMult  = screenHeight / scopeHeight;
        scopeMult2 = width / scopeWidth;

        //Binocular texture(s) is wider than tall, so account for that scale as well
        scopeMult = FMin(scopeMult,scopeMult2);
        if (scopeMult < 1.0){ scopeMult = 1.0; }

        scopeMultInt = float(class'DXRInfo'.static.TruncateFloat(scopeMult,0));
        scopeMultFirstDec = float(class'DXRInfo'.static.TruncateFloat(scopeMult,1)) - scopeMultInt;

        scopeMult = scopeMultInt;
        if (scopeMultFirstDec>0.5){
            scopeMult += 0.5;
        }
    }

    fromX = (width- (scopeWidth * scopeMult))/2;
    fromY = (height-(scopeHeight * scopeMult))/2;
    toX   = fromX + (scopeWidth * scopeMult);
    toY   = fromY + (scopeHeight * scopeMult);

    gc.SetTileColorRGB(0, 0, 0);
    gc.SetStyle(DSTY_Normal);

    if (blackOut){
        //Make the rest of the screen black
        gc.DrawPattern(0, 0, width, fromY, 0, 0, Texture'Solid');
        gc.DrawPattern(0, toY, width, fromY, 0, 0, Texture'Solid');
        gc.DrawPattern(0, fromY, fromX, (scopeHeight*scopeMult), 0, 0, Texture'Solid');
        gc.DrawPattern(toX, fromY, fromX, (scopeHeight*scopeMult), 0, 0, Texture'Solid');
    }

    if (bBinocs)
    {
        if (blackOut) {
            //Draw the binocular shaped edges
            gc.SetStyle(DSTY_Modulated);
            gc.DrawStretchedTexture(fromX,                   fromY, (256 * scopeMult), (scopeHeight * scopeMult), 0, 0, 256, scopeHeight, Texture'HUDBinocularView_1');
            gc.DrawStretchedTexture(fromX + (256*scopeMult), fromY, (256 * scopeMult), (scopeHeight * scopeMult), 0, 0, 256, scopeHeight, Texture'HUDBinocularView_2');
        }

        gc.SetTileColor(colLines);
        gc.SetStyle(DSTY_Translucent);  //Masked rounds the edges of the texture when stretching, translucent doesn't
        gc.DrawStretchedTexture(fromX,                   fromY, (256 * scopeMult), (scopeHeight * scopeMult), 0, 0, 256, scopeHeight, Texture'HUDBinocularCrosshair_1');
        gc.DrawStretchedTexture(fromX + (256*scopeMult), fromY, (256 * scopeMult), (scopeHeight * scopeMult), 0, 0, 256, scopeHeight, Texture'HUDBinocularCrosshair_2');
    }
    else
    {
        gc.SetStyle(DSTY_Modulated);
        if (blackOut){
            //Scope, but with black edges around it (only to the 256x256 square though)
            gc.DrawStretchedTexture(fromX, fromY, scopeWidth*scopeMult, scopeHeight*scopeMult, 0, 0, scopeWidth, scopeHeight, Texture'HUDScopeView');

            //Also draw the scope lines
            gc.SetTileColor(colLines);
            gc.SetStyle(DSTY_Translucent);  //Masked rounds the edges of the texture when stretching, translucent doesn't
            gc.DrawStretchedTexture(fromX, fromY, scopeWidth*scopeMult, scopeHeight*scopeMult, 0, 0, scopeWidth, scopeHeight, Texture'HUDScopeCrosshair');
        } else {
            //Scope with no blacked out edges
            gc.DrawStretchedTexture(fromX, fromY, scopeWidth*scopeMult, scopeHeight*scopeMult, 0, 0, scopeWidth, scopeHeight, Texture'HUDScopeView2');
        }
    }
}

function ActivateView(int newFOV, bool bNewBinocs, bool bInstant)
{
    Super.ActivateView(newFOV,bNewBinocs,bInstant);
    if (bViewVisible){
        lastWatched = None;
        //SetTimer(0.25,True);
        watchTimerId=AddTimer(0.25,true,0,'PeepTimer');
    }
}

function DeactivateView()
{
    Super.DeactivateView();
    if (!bViewVisible){
        //SetTimer(0,False);
        RemoveTimer(watchTimerId);
        watchTimerId=0;
        lastWatched = None;
    }
}

simulated function PeepTimer(int timerID, int invocations, int clientData)
{
    class'#var(injectsprefix)Binoculars'.static.PeepTimer(#var(PlayerPawn)(Player), watchTime, lastWatched, lastWatchedTex);
}
