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
    local #var(PlayerPawn) peeper;
    local Vector HitNormal, HitLocation, StartTrace, EndTrace, Reflection;
    local Actor peepee;// pronounced peep-ee, not pee-pee
    local Actor target;
    local bool newPeepee, newPeepTex, hitMirror;
    local name texName,texGroup;
    local int flags, i, distRemaining;


    peeper = #var(PlayerPawn)(Player);

    //Peeping logic happens here
    //A distance of 20000 is more than sufficient for Liberty Island,
    //which is basically the worst case scenario
    StartTrace = peeper.Location;
    StartTrace.Z += peeper.BaseEyeHeight;
    distRemaining=20000;
    EndTrace = StartTrace + distRemaining * Vector(peeper.ViewRotation);


    while (distRemaining>0){
        //peeper.ClientMessage("Distance Remaining: "$distRemaining);

        target=None;
        hitMirror = false;

        //peepee = Trace(HitLocation, HitNormal, EndTrace, StartTrace, True);
        foreach Player.TraceTexture(class'Actor',target,texName,texGroup,flags,HitLocation,HitNormal,EndTrace,StartTrace){
            //if (target==Player.Level){
            //    peeper.ClientMessage("Hit level tex "$texName$" with flags "$flags);
            //}
            if (BingoTrigger(target)!=None && BingoTrigger(target).bPeepable){
                peepee = target;
                break;
            }
            else if (((target.DrawType == DT_None) || target.bHidden) && target!=Player.Level)
            {
                // Keep tracing past invisible things
            }
            else if (target==Player.Level && ((flags & 0x08000000) != 0)) //PF_Mirrored
            {
                hitMirror = true;
                break;
            }
            else if (target==Player.Level && (((flags&0x00000004)!=0) || ((flags&0x00000001)!=0))) //PF_Translucent or PF_Invisible
            {
                //Skip invisible or translucent masked textures, as long as they aren't also mirrors
                //It won't actually trace beyond the level, it seems, so this doesn't actually help
                //But also make sure it isn't a fake mirror zone
                if (class'FakeMirrorInfo'.static.IsPointInMirrorZone(Player,HitLocation)){
                    hitMirror = true;
                    //peeper.ClientMessage("Hit fake mirror on transparent thing "$HitLocation);
                    break;
                }

            } else if (target==Player.Level){
                if (class'FakeMirrorInfo'.static.IsPointInMirrorZone(Player,HitLocation)){
                    hitMirror = true;
                    //peeper.ClientMessage("Hit fake mirror "$HitLocation);
                    break;
                }
            }
            else
            {
                if (#var(DeusExPrefix)Mover(target)!=None){
                    if (class'FakeMirrorInfo'.static.IsPointInMirrorZone(Player,HitLocation)){
                        hitMirror = true;
                        //peeper.ClientMessage("Hit fake mirror attached to mover "$HitLocation);
                        break;
                    }
                }
                peepee = target;
                break;
            }
        }

        distRemaining=distRemaining-VSize(HitLocation-StartTrace);

        //If it didn't hit a mirror, stop immediately, otherwise keep trying to trace
        if (hitMirror == false) {
            break;
        }

        //peeper.ClientMessage("Hit a reflective surface, continuing");

        Reflection = MirrorVectorByNormal(Normal(HitLocation - StartTrace), HitNormal);
        StartTrace=HitLocation+HitNormal;
        EndTrace=Reflection * distRemaining;
    }


    //peeper.ClientMessage("Peeping "$peepee.Name$" in state "$peepee.GetStateName());

    if(peepee.IsA('LevelInfo')){
        peepee=None;
    }

    if (peepee!=None && peepee!=lastWatched)
    {
        lastWatched = peepee;
        lastWatchedTex = '';
        watchTime=0;

        if (lastWatched!=None){
            newPeepee = True;
            newPeepTex = False;
        }
    } else if (peepee==None && texName!=lastWatchedTex) {
        lastWatchedTex=texName;
        lastWatched=peepee;
        watchTime=0;

        if (lastWatchedTex!=''){
            newPeepee = False;
            newPeepTex = True;
        }
    } else {
        newPeepee = False;
        newPeepTex = False;
    }

    if (newPeepee){
        //peeper.ClientMessage("New peeped actor is "$peepee.class.Name);
        //This should probably only trigger once per thing - TODO, will probably be tracked in DXREvents and PlayerDataItem, like function ReadText(name textTag)
        class'DXREvents'.static.MarkBingo(peepee.Class.Name$"_peeped");

        if (ScriptedPawn(peepee)!=None){
            class'DXREvents'.static.MarkBingo("PawnState_"$peepee.GetStateName());
            class'DXREvents'.static.MarkBingo("PawnAnim_"$peepee.AnimSequence);
        } else if (#var(PlayerPawn)(peepee)!=None){
            class'DXREvents'.static.MarkBingo("PlayerPeeped");
        }

        if (BingoTrigger(peepee)!=None){
            BingoTrigger(peepee).Peep();
        }
    } else if (newPeepTex) {
        //peeper.ClientMessage("New peeped texture is "$lastWatchedTex);
        class'DXREvents'.static.MarkBingo(lastWatchedTex$"_peepedtex");
    } else {
        watchTime++;
        if(watchTime>=4){
            watchTime=0;
            class'DXREvents'.static.MarkBingo(peepee.Class.Name$"_peeptime");
        }
    }
}
