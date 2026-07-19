class DXRMissionEndgamePiggyback extends DXRMissionPiggyback;

var float endgameDelays[3];
var float endgameTimer;
var bool ourQuotePrinted;
var HUDMissionStartTextDisplay ourQuoteDisplay;

function Init(MissionScript orig)
{
    Super.Init(orig);

    baseScript.SetPropertyText("bQuotePrinted","True"); //Mark the quotes as already having been printed, we'll handle that ourselves
}

function Timer()
{
    if (baseScript.flags==None) return;

    if (baseScript.flags.GetBool('Endgame1_Played'))
    {
        if (!ourQuotePrinted)
            PrintEndgameQuote(0);

        endgameTimer += checkTime;

        if (endgameTimer > endgameDelays[0]){
            DestroyQuoteDisplay();
            ForceCinematicFinished('Endgame1_Played');
        }
    }
    else if (baseScript.flags.GetBool('Endgame2_Played'))
    {
        if (!ourQuotePrinted)
            PrintEndgameQuote(1);

        endgameTimer += checkTime;

        if (endgameTimer > endgameDelays[1]){
            DestroyQuoteDisplay();
            ForceCinematicFinished('Endgame2_Played');
        }
    }
    else if (baseScript.flags.GetBool('Endgame3_Played'))
    {
        if (!ourQuotePrinted)
            PrintEndgameQuote(2);

        endgameTimer += checkTime;

        if (endgameTimer > endgameDelays[2]){
            DestroyQuoteDisplay();
            ForceCinematicFinished('Endgame3_Played');
        }
    }
    else if (baseScript.localURL == "ENDGAME4" || baseScript.localURL == "ENDGAME4REV")
    {
        endgameTimer += checkTime;
        if (!ourQuotePrinted && endgameTimer > 5) {
            endgameDelays[2]=70.0;
            PrintEndgameQuote(2);
        }

        if (endgameTimer > 75) {
            DestroyQuoteDisplay();
            ForceCinematicFinished('Endgame2_Played');
        }
    }

    if (ourQuoteDisplay!=None && CreditsAreOpen()){
        DestroyQuoteDisplay();
    }
}

function bool CreditsAreOpen()
{
    local DeusExRootWindow root;
    root = DeusExRootWindow(baseScript.Player.rootWindow);
    if (root != None && CreditsWindow(root.GetTopWindow())!=None){
        return true;
    }
    return false;

}

function ForceCinematicFinished(name endingFlag)
{
    baseScript.flags.SetBool('Endgame2_Played',True);
    baseScript.SetPropertyText("endgameTimer","9999999");
}

function DestroyQuoteDisplay()
{
    if (ourQuoteDisplay != None)
    {
        ourQuoteDisplay.Destroy();
        ourQuoteDisplay = None;
    }

}

function PrintEndgameQuote(int num)
{
    local int i;
    local DeusExRootWindow root;
    local EndgameQuoteManager qMgr;
    local DXRando dxr;
    local string quote, attrib;

    ourQuotePrinted = True;
    baseScript.flags.SetBool('EndgameExplosions', False);

    dxr = class'DXRando'.default.dxr;

    qMgr = Spawn(class'EndgameQuoteManager');
    qMgr.LoadQuotes();

    root = DeusExRootWindow(baseScript.Player.rootWindow);
    if (root != None)
    {
        ourQuoteDisplay = HUDMissionStartTextDisplay(root.NewChild(Class'HUDMissionStartTextDisplay', True));
        if (ourQuoteDisplay != None)
        {
            ourQuoteDisplay.displayTime = endgameDelays[num];
            ourQuoteDisplay.SetWindowAlignments(HALIGN_Center, VALIGN_Center);

            if (dxr.flags.IsReducedRando()){
                quote = class'MissionEndgame'.Default.endgameQuote[num*2];
                attrib = class'MissionEndgame'.Default.endgameQuote[num*2 + 1];
            } else {
                qMgr.PickRandomQuote(quote, attrib);
            }

            //Revision overrides the HUDMissionStartTextDisplay class with a version
            //that forces all the text onto one line (Why?).  Manually force the message
            //to multiple lines like in vanilla, since it looks nicer
            //ourQuoteDisplay.AddMessage(quote);
            //ourQuoteDisplay.AddMessage(attrib);
            ourQuoteDisplay.message = quote $ "|n" $ attrib;

            ourQuoteDisplay.StartMessage();
        }
    }
}

defaultproperties
{
     endgameDelays(0)=12.500000 //These endgame delays are half a second shorter than the originals
     endgameDelays(1)=13.000000
     endgameDelays(2)=10.000000
}
