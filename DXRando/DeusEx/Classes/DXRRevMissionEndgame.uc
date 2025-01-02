#compileif revision
class DXRRevMissionEndgame extends RevisionMissionEndgame;

function Timer()
{
    Super.Timer();

    if (localURL == "ENDGAME4" || localURL == "ENDGAME4REV") {
        endgameTimer += checkTime;

        if (!bQuotePrinted && endgameTimer > 5) {
            endgameDelays[2]=70.0;
            PrintEndgameQuote(2);
        }

        if (endgameTimer > 75) {
            FinishCinematic();
        }
    }
}

function PrintEndgameQuote(int num)
{
    local int i;
    local DeusExRootWindow root;
    local EndgameQuoteManager qMgr;
    local DXRando dxr;
    local string quote, attrib;

    bQuotePrinted = True;
    flags.SetBool('EndgameExplosions', False);

    dxr = class'DXRando'.default.dxr;

    qMgr = Spawn(class'EndgameQuoteManager');
    qMgr.LoadQuotes();

    root = DeusExRootWindow(Player.rootWindow);
    if (root != None)
    {
        quoteDisplay = HUDMissionStartTextDisplay(root.NewChild(Class'HUDMissionStartTextDisplay', True));
        if (quoteDisplay != None)
        {
            quoteDisplay.displayTime = endgameDelays[num];
            quoteDisplay.SetWindowAlignments(HALIGN_Center, VALIGN_Center);

            if (dxr.flags.IsReducedRando()){
                quote = endgameQuote[num*2];
                attrib = endgameQuote[num*2 + 1];
            } else {
                qMgr.PickRandomQuote(quote, attrib);
            }

            //Revision overrides the HUDMissionStartTextDisplay class with a version
            //that forces all the text onto one line (Why?).  Manually force the message
            //to multiple lines like in vanilla, since it looks nicer
            //quoteDisplay.AddMessage(quote);
            //quoteDisplay.AddMessage(attrib);
            quoteDisplay.message = quote $ "|n" $ attrib;

            quoteDisplay.StartMessage();
        }
    }
}
