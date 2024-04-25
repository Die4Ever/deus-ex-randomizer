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
    local Conversation con;
    local ConEventSpeech ces;
    local DXRHints hints;
    local int newHint;
    local DXRando dxr;

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
    } until (newHint != lastHint - 1);

    ces = class'DXRActorsBase'.static.GetSpeechEvent(con.eventList, "Hehehehe");
    ces.conSpeech.speech = "Hehehehe, thank you. Here's a tip: " $ hints.hints[newHint] @ hints.details[newHint];
    ces = class'DXRActorsBase'.static.GetSpeechEvent(con.eventList, "Come back");
    ces.conSpeech.speech = "Come back anytime. Here's a tip: " $ hints.hints[newHint] @ hints.details[newHint];

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
