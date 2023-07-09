class DXRBinoculars injects #var(prefix)Binoculars;

var int watchTime;
var Actor lastWatched;

state Activated
{
    function BeginState()
    {
        Super.BeginState();

        SetTimer(0.25,True);
    }
}

state DeActivated
{
    function BeginState()
    {
        Super.BeginState();

        SetTimer(0,False);
    }
}

simulated function Timer()
{
    local #var(PlayerPawn) peeper;
    local Vector HitNormal, HitLocation, StartTrace, EndTrace;
    local Actor peepee;// pronounced peep-ee, not pee-pee
    local DXRando dxr;
    local bool newPeepee;

    peeper = #var(PlayerPawn)(Owner);

    //Peeping logic happens here
    StartTrace = peeper.Location;
    StartTrace.Z += peeper.BaseEyeHeight;

    //A distance of 20000 is more than sufficient for Liberty Island,
    //which is basically the worst case scenario
    EndTrace = StartTrace + 20000 * Vector(peeper.ViewRotation);

    peepee = Trace(HitLocation, HitNormal, EndTrace, StartTrace, True);

    //peeper.ClientMessage("Peeping "$peepee.Name$" in state "$peepee.GetStateName());

    foreach AllActors(class'DXRando', dxr) {break;}

    if (dxr==None){
        return;
    }

    if (peepee!=lastWatched)
    {
        lastWatched = peepee;
        watchTime=0;

        if (lastWatched!=None){
            newPeepee = True;
        }

    } else {
        newPeepee = False;
    }

    if (newPeepee){
        //This should probably only trigger once per thing - TODO, will probably be tracked in DXREvents and PlayerDataItem, like function ReadText(name textTag)
        class'DXREvents'.static.MarkBingo(dxr,peepee.Class.Name$"_peeped");

        if (ScriptedPawn(peepee)!=None){
            class'DXREvents'.static.MarkBingo(dxr,"PawnState_"$peepee.GetStateName());
        }
    } else {
        watchTime++;
        if(watchTime>=4){
            watchTime=0;
            class'DXREvents'.static.MarkBingo(dxr,peepee.Class.Name$"_peeptime");
        }
    }
}
