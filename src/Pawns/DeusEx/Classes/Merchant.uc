class Merchant extends #var(prefix)Businessman3;

var int lastHint;
var string greetings[4];

#ifdef vmd
function bool ShouldDoSinglePickPocket(DeusExPlayer Frobbie)
{
    return false;
}
#endif

#ifdef revision
function bool FilterDamageType(Pawn instigatedBy, Vector hitLocation,
                               Vector offset, Name damageType, optional bool bTestOnly)
#else
function bool FilterDamageType(Pawn instigatedBy, Vector hitLocation,
                               Vector offset, Name damageType)
#endif
{
    // Merchants aren't affected by radiation barrels
    if(damageType == 'Radiation')
        return false;
    return Super.FilterDamageType(instigatedBy, hitLocation, offset, damageType);
}

function EnterConversationState(bool bFirstPerson, optional bool bAvoidState)
{
    local DXRando dxr;
    local DXRHints hints;
    local Conversation con;
    local ConEvent ce;
    local ConEventSpeech ces;
    local int newHint, i;
    local string hint, details;

    con = ConListItem(ConListItems).con;

    for (ce = con.eventList; ce != None; ce = ce.nextEvent) {
        if (ConEventSpeech(ce) != None) {
            ConEventSpeech(ce).conSpeech.speech = greetings[Rand(ArrayCount(greetings))];
            break;
        }
    }

    hints = DXRHints(class'DXRHints'.static.Find());

    if(hints != None) {
        for(i=0; i<100; i++) {
            newHint = hints.GetHint(false,hint,details,true);
            if(newHint != lastHint) break;
        }
        if(i>=100) hint = "";
    }

    if(hint!="") {
        ces = class'DXRActorsBase'.static.GetSpeechEvent(con.eventList, "Hehehehe");
        ces.conSpeech.speech = "Hehehehe, thank you.  Here's a tip: " $ hint @ details;
        ces = class'DXRActorsBase'.static.GetSpeechEvent(con.eventList, "Come back");
        ces.conSpeech.speech = "Come back anytime.  Here's a tip: " $ hint @ details;
        ces = class'DXRActorsBase'.static.GetSpeechEvent(con.eventList, "Not enough cash");
        ces.conSpeech.speech = "Not enough cash, stranger.  Here's a tip: " $ hint @ details;
    }

    lastHint = newHint;

    Super.EnterConversationState(bFirstPerson, bAvoidState);
}

defaultproperties
{
    FamiliarName="The Merchant"
    UnfamiliarName="The Merchant"
    CarcassType=Class'MerchantCarcass'
    bImportant=True
    bDetectable=false
    bIgnore=true
    RaiseAlarm=RAISEALARM_Never
    Health=200
    HealthArmLeft=200
    HealthArmRight=200
    HealthHead=200
    HealthLegLeft=200
    HealthLegRight=200
    HealthTorso=200
    HomeTag=Start  //Makes him return to his original location (HomeLoc)
    ReducedDamageType=Radiation
    lastHint=-1
    greetings(0)="Whaddaya buyin'?"
    greetings(1)="Got a selection of good things on sale, stranger."
    greetings(2)="Got somethin' that might interest ya'."
    greetings(3)="Got some rare things on sale, stranger!"
}
