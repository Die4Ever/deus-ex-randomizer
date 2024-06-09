class DXRMissionEndgame injects #var(prefix)MissionEndgame;

#ifdef gmdx
var name TarEndgameConvo;
var float DelayTimer;
#elseif revision
var name TarEndgameConvo;
var float DelayTimer;
#endif

function bool IsFemale()
{
#ifdef vmd
    if ((VMDBufferPlayer(Player) != None) && (VMDBufferPlayer(Player).bAssignedFemale))
        return true;
#elseif vanilla
    if ((Human(Player) != None) && (Human(Player).bMadeFemale))
        return true;
#endif
    return false;
}

// DON'T DO THIS STUFF FOR HX!
#ifndef hx
function PostPostBeginPlay()
{
    savedSoundVolume = SoundVolume;
    Super.PostPostBeginPlay();
}

// ----------------------------------------------------------------------
// InitStateMachine()
// ----------------------------------------------------------------------

function InitStateMachine()
{
    Super(MissionScript).InitStateMachine();

    // Destroy all flags!
    //if (flags != None)
    //    flags.DeleteAllFlags();

    // Set the PlayerTraveling flag (always want it set for
    // the intro and endgames)
    flags.SetBool('PlayerTraveling', True, True, 0);
}

// ----------------------------------------------------------------------
// FirstFrame()
//
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
    Super(MissionScript).FirstFrame();

    endgameTimer = 0.0;

    if (Player != None)
    {
        TarEndgameConvo = 'Barf';
        DelayTimer = 0.05;

        //LDDP, 11/3/21: Barf.
        //Player.StartConversationByName(UseConvo, Player, False, True);

        // Make sure all the flags are deleted.
        //DeusExRootWindow(Player.rootWindow).ResetFlags();

        // turn down the sound so we can hear the speech
        savedSoundVolume = SoundVolume;
        SoundVolume = 32;
        Player.SetInstantSoundVolume(SoundVolume);
    }
}

function Tick(float DT)
{
    local bool bFemale;
    local name UseConvo;

    Super(MissionScript).Tick(DT);

    //LDDP, 11/3/21: Barf, part 2.
    if (TarEndgameConvo == 'Barf')
    {
        if (DelayTimer > 0)
        {
            DelayTimer -= DT;
        }
        else
        {
            //LDDP, 10/26/21: Parse this on the fly, and reset flags AFTER playing the right conversation, NOT before.
            //if ((Player.FlagBase != None) && (Player.FlagBase.GetBool('LDDPJCIsFemale')))
            bFemale = IsFemale();

            // Start the conversation
            switch(LocalURL)
            {
                case "ENDGAME1":
                    UseConvo = 'Endgame1';
                    if (bFemale) UseConvo = 'FemJCEndgame1';
                break;
                case "ENDGAME2":
                    UseConvo = 'Endgame2';
                    if (bFemale) UseConvo = 'FemJCEndgame2';
                break;
                case "ENDGAME3":
                    UseConvo = 'Endgame3';
                    if (bFemale) UseConvo = 'FemJCEndgame3';
                break;
            }
            TarEndgameConvo = UseConvo;

            Player.StartConversationByName(TarEndgameConvo, Player, False, True);

            //LDDP, 11/3/21: Make sure all the flags are deleted, now that flags manager is here.
            //DeusExRootWindow(Player.rootWindow).ResetFlags();
        }
    }
}

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

    foreach AllActors(class'DXRando',dxr) break;

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

            quoteDisplay.AddMessage(quote);
            quoteDisplay.AddMessage(attrib);

            quoteDisplay.StartMessage();
        }
    }
}
#endif
