class DXRBinoculars injects #var(prefix)Binoculars;

var int watchTime;
var Actor lastWatched;
var name lastWatchedTex;

state Activated
{
    function BeginState()
    {
        Super.BeginState();

        //Only use this logic when we don't replace
        //the ScopeView with DXRandoRootWindow
        if(#defined(hx)){
            lastWatched = None;
            SetTimer(0.25,True);
        }
    }
}

state DeActivated
{
    function BeginState()
    {
        Super.BeginState();

        if (#defined(hx)){
            SetTimer(0,False);
            lastWatched = None;
        }
    }
}

simulated function PreTravel()
{
    if(Owner != None && GetStateName() == 'Activated')
        GoToState('DeActivated');
}

simulated function Timer()
{
    local #var(PlayerPawn) peeper;
    local Vector HitNormal, HitLocation, StartTrace, EndTrace, Reflection;
    local Actor peepee;// pronounced peep-ee, not pee-pee
    local Actor target;
    local bool newPeepee, newPeepTex;
    local name texName,texGroup;
    local int flags, i, distRemaining;


    peeper = #var(PlayerPawn)(Owner);

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

        //peepee = Trace(HitLocation, HitNormal, EndTrace, StartTrace, True);
        foreach TraceTexture(class'Actor',target,texName,texGroup,flags,HitLocation,HitNormal,EndTrace,StartTrace){
            //if (target==Level){
            //    peeper.ClientMessage("Hit level tex "$texName$" with flags "$flags);
            //}
            if (BingoTrigger(target)!=None && BingoTrigger(target).bPeepable){
                peepee = target;
                break;
            }
            else if (((target.DrawType == DT_None) || target.bHidden) && target!=Level)
            {
                // Keep tracing past invisible things
            }
            else if (target==Level && ((flags & 0x08000000) != 0))
            {
                break;
            }
            else if (target==Level && (((flags&0x00000004)!=0) || ((flags&0x00000001)!=0)))
            {
                //Skip invisible or translucent masked textures, as long as they aren't also mirrors
                //It won't actually trace beyond the level, it seems, so this doesn't actually help
            }
            else
            {
                peepee = target;
                break;
            }
        }

        distRemaining=distRemaining-VSize(HitLocation-StartTrace);

        //If it didn't hit a mirror, stop immediately, otherwise keep trying to trace
        if ((flags & 0x08000000) == 0) {
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

function PostPostBeginPlay()
{
    Description="A pair of military binoculars.|n|n<UNATCO OPS FILE NOTE PO64-SNAP>|nHello there! The reason I invited you here is this NPC Report. I'd like for you to watch characters for the NPC Report. I'm counting on you, JC!|n-- Professor Oak|n<END NOTE>";

}
