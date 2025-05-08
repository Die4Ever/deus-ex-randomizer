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
    local float scopeWidth, scopeHeight;

    Super(Window).DrawWindow(gc);

    if (GetRootWindow().parentPawn != None)
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

    fromX = (width-scopeWidth)/2;
    fromY = (height-scopeHeight)/2;
    toX   = fromX + scopeWidth;
    toY   = fromY + scopeHeight;

    if (bBinocs)
    {
        gc.SetTileColor(colLines);
        gc.SetStyle(DSTY_Masked);
        gc.DrawTexture(fromX,       fromY, 256, scopeHeight, 0, 0, Texture'HUDBinocularCrosshair_1');
        gc.DrawTexture(fromX + 256, fromY, 256, scopeHeight, 0, 0, Texture'HUDBinocularCrosshair_2');
    }
    else
    {
        gc.SetStyle(DSTY_Modulated);
        gc.DrawTexture(fromX, fromY, scopeWidth, scopeHeight, 0, 0, Texture'HUDScopeView2');
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
