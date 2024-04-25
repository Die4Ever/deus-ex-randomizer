class Merchant extends #var(prefix)Businessman3;

var int lastHint;

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

function Frob(Actor frobber, Inventory frobWith)
{
    local DXRando dxr;
    local DXRHints hints;
    local Conversation con;
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

    do {
        newHint = hints.GetHint();
        hint = hints.hints[newHint];
        details = hints.details[newHint];
    } until (
        newHint != lastHint - 1 &&
        hint != "Viewers, you could've prevented this with Crowd Control." &&
        hint != "Don't forget you (the viewer!) can" &&
        details != "We just shared your death publicly, go retweet it!" &&
        !(MultiSkins[0] == Texture'DeusExCharacters.Skins.ChefTex0' && hint == "If you need a Hazmat suit")
    )

    ces = class'DXRActorsBase'.static.GetSpeechEvent(con.eventList, "Hehehehe");
    ces.conSpeech.speech = "Hehehehe, thank you. Here's a tip: " $ hint @ details;
    ces = class'DXRActorsBase'.static.GetSpeechEvent(con.eventList, "Come back");
    ces.conSpeech.speech = "Come back anytime. Here's a tip: " $ hint @ details;

    // offset newHint by 1 so that 0 always indicates unassigned, otherwise hint 0 can never be chosen first
    lastHint = newHint + 1;

    Super.Frob(frobber, frobWith);
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
}
