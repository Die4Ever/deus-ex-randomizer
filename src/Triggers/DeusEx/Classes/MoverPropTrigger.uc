class MoverPropTrigger extends Trigger;

enum ESetBool
{
    SB_Noset,
    SB_True,
    SB_False
};

var() ESetBool bBreakable;
var() ESetBool bPickable;
var() ESetBool bLocked;
var() ESetBool bHighlight;
var() ESetBool bFrobbable;
var() float minDamageThreshold;
var() float doorStrength;
var() float lockStrength;

function Touch(Actor Other)
{
    Super.Touch(Other);

    if (IsRelevant(Other))
    {
        ChangeProps(Other);
        if(bTriggerOnceOnly) Destroy();
    }
}

event Trigger( Actor Other, Pawn EventInstigator )
{
    ChangeProps(EventInstigator); //I think this is more correct than Other, probably?
    if(bTriggerOnceOnly) Destroy();
}

function ESetBool BoolToVal(bool val)
{
    if (val) return SB_True;
    return SB_False;
}

function SetBreakable(bool val)
{
    bBreakable=BoolToVal(val);
}

function SetPickable(bool val)
{
    bPickable=BoolToVal(val);
}

function SetLocked(bool val)
{
    bLocked=BoolToVal(val);
}

function SetHighlight(bool val)
{
    bHighlight=BoolToVal(val);
}

function SetFrobbable(bool val)
{
    bFrobbable=BoolToVal(val);
}

function SetMinDamageThresh(float val)
{
    minDamageThreshold=val;
}

function SetDoorStrength(float val)
{
    doorStrength=val;
}

function SetLockStrength(float val)
{
    lockStrength=val;
}

function ChangeProps(Actor Other)
{
    local #var(DeusExPrefix)Mover dxm;

    foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,event){
        if (bBreakable!=SB_Noset){
            dxm.bBreakable = (bBreakable==SB_True);
        }
        if (bPickable!=SB_Noset){
            dxm.bPickable = (bPickable==SB_True);
        }
        if (bLocked!=SB_Noset){
            dxm.bLocked = (bLocked==SB_True);
        }
        if (bHighlight!=SB_Noset){
            dxm.bHighlight = (bHighlight==SB_True);
        }
        if (bFrobbable!=SB_Noset){
            dxm.bFrobbable = (bFrobbable==SB_True);
        }
        if (minDamageThreshold>=0){
            dxm.minDamageThreshold = minDamageThreshold;
        }
        if (doorStrength>=0){
            dxm.doorStrength = doorStrength;
        }
        if (lockStrength>=0){
            dxm.lockStrength = lockStrength;
        }
    }
}


defaultproperties
{
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false

    bBreakable=SB_Noset
    bPickable=SB_Noset
    bLocked=SB_Noset
    bHighlight=SB_Noset
    bFrobbable=SB_Noset
    minDamageThreshold=-1.0
    doorStrength=-1.0
    lockStrength=-1.0
}
