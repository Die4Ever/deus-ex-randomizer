//=============================================================================
// FrictionTrigger.
// For setting a zone to use a different ground friction while you're in the
// trigger radius (mainly for the silo slide, but maybe useful somewhere else
// too?)
//=============================================================================
class FrictionTrigger expands Trigger;

var() float outFriction;
var() float inFriction;

const ICE_FRICTION = 0.001;


function Touch(Actor Other)
{
    Super.Touch(Other);

    if (IsRelevant(Other))
    {
        ChangeFriction(inFriction);
    }
}

function Untouch(Actor Other)
{
    Super.Touch(Other);

    if (IsRelevant(Other))
    {
        ChangeFriction(outFriction);
    }
}

function ChangeFriction(float newFriction)
{
    Region.Zone.ZoneGroundFriction=newFriction;
}

static function FrictionTrigger Create(Actor a, float inFric, vector loc, float rad, float height)
{
    local FrictionTrigger ft;

    ft = a.Spawn(class'FrictionTrigger',,,loc);
    ft.inFriction=inFric;
    ft.outFriction=ft.Region.Zone.ZoneGroundFriction; //Takes on the default zone friction

    ft.SetCollisionSize(rad,height);

    return ft;
}

static function FrictionTrigger CreateIce(Actor a, vector loc, float rad, float height)
{
    return Create(a, ICE_FRICTION, loc, rad, height);
}

defaultproperties
{
    TriggerType=TT_PlayerProximity
}
