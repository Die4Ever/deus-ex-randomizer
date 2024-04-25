class Merchant extends #var(prefix)Businessman3;

var int lastHint;
var string greetings[5];

#ifdef vmd
function bool ShouldDoSinglePickPocket(DeusExPlayer Frobbie)
{
    return false;
}
#endif

//Oui Oui
function MakeFrench()
{
    MultiSkins[0]=Texture'DeusExCharacters.Skins.ChefTex0';
    MultiSkins[7]=Texture'DeusExCharacters.Skins.ChefTex3'; //Should he actually have the hat?
    CarcassType=Class'LeMerchantCarcass';
}

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
    local int newHint;
    local string hint, details;

    foreach AllActors(class'DXRando', dxr) {
        hints = DXRHints(dxr.FindModule(class'DXRHints'));
        break;
    }
    foreach AllObjects(class'Conversation', con) {
        if (con.description == "Merchant") {
            break;
        }
    }

    for (ce = con.eventList; ce != None; ce = ce.nextEvent) {
        if (ConEventSpeech(ce) != None) {
            ConEventSpeech(ce).conSpeech.speech = greetings[Rand(ArrayCount(greetings))];
            break;
        }
    }

    do {
        newHint = hints.GetHint();
        hint = hints.hints[newHint];
        details = hints.details[newHint];
    } until (
        newHint != lastHint &&
        hint != "Viewers, you could've prevented this with Crowd Control." &&
        hint != "Don't forget you (the viewer!) can" &&
        details != "We just shared your death publicly, go retweet it!" &&
        !(MultiSkins[0] == Texture'DeusExCharacters.Skins.ChefTex0' && hint == "If you need a Hazmat suit")
    )

    ces = class'DXRActorsBase'.static.GetSpeechEvent(con.eventList, "Hehehehe");
    ces.conSpeech.speech = "Hehehehe, thank you. Here's a tip: " $ hint @ details;
    ces = class'DXRActorsBase'.static.GetSpeechEvent(con.eventList, "Come back");
    ces.conSpeech.speech = "Come back anytime. Here's a tip: " $ hint @ details;

    lastHint = newHint;

    Super.EnterConversationState(bFirstPerson, bAvoidState);
}

defaultproperties
{
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
    ReducedDamageType=Radiation
    lastHint=-1
    greetings(0)="Whaddaya buyin'?"
    greetings(1)="Got a selection of good things on sale, stranger."
    greetings(2)="Got somethin' that might interest ya'."
    greetings(3)="Got some rare things on sale, stranger!"
    greetings(4)="Welcome!"
}
