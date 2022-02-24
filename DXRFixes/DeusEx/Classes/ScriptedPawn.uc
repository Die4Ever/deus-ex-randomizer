class ScriptedPawn shims ScriptedPawn;
// doesn't work with injects, because of states and : Error, DeusEx.ScriptedPawn's superclass must be Engine.Pawn, not DeusEx.ScriptedPawnBase
// could work with injectsabove or whatever https://github.com/Die4Ever/deus-ex-randomizer/issues/115
var int flareBurnTime;

var int loopCounter;
var Actor prevDest;
var Actor prevprevDest;

/*function IncreaseAgitation(Actor actorInstigator, optional float AgitationLevel)
{
    log(Self$" IncreaseAgitation "$actorInstigator$", "$AgitationLevel);
}*/

function PlayDying(name damageType, vector hitLoc)
{
    local DeusExPlayer p;
    local Inventory item, nextItem;
    local bool gibbed, drop, melee;

    gibbed = (Health < -100) && !IsA('Robot');

    if( gibbed ) {
        p = DeusExPlayer(GetPlayerPawn());
        class'DXRStats'.static.AddGibbedKill(p);
    }

    item = Inventory;
    while( item != None ) {
        nextItem = item.Inventory;
        melee = class'DXRActorsBase'.static.IsMeleeWeapon(item);
        drop = (item.IsA('NanoKey') && gibbed) || (melee && !gibbed) || (gibbed && item.bDisplayableInv);
        if( DeusExWeapon(item) != None && DeusExWeapon(item).bNativeAttack )
            drop = false;
        if( Ammo(item) != None )
            drop = false;
        if( drop ) {
            class'DXRActorsBase'.static.ThrowItem(self, item, 1.0);
            if(gibbed)
                item.Velocity *= vect(-2, -2, 2);
            else
                item.Velocity *= vect(-1.5, -1.5, 1.5);
        }
        item = nextItem;
    }

    Super.PlayDying(damageType, hitLoc);
}

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType,
                        bool bPlayAnim)
{
    local name baseDamageType;
    local DeusExPlayer p;

    if (damageType == 'FlareFlamed') {
        baseDamageType = 'Flamed';
    } else {
        baseDamageType = damageType;
    }

    Super.TakeDamageBase(Damage,instigatedBy,hitLocation,momentum,baseDamageType,bPlayAnim);

    if (bBurnedToDeath) {
        p = DeusExPlayer(GetPlayerPawn());
        class'DXRStats'.static.AddBurnKill(p);
    }

    if (damageType == 'FlareFlamed') {
        flareBurnTime = 3;
    }
}

function UpdateFire()
{
    Super.UpdateFire();
    if (flareBurnTime > 0) {
        flareBurnTime -= 1;
        if (flareBurnTime == 0) {
            ExtinguishFire();
        }
    }
}

// HACK: will need to improve the compiler in order to actually fix state code
function EnableCheckDestLoc(bool bEnable)
{
    local DXRando dxr;
    local Actor tMoveTarget;
    local string message;

    Super.EnableCheckDestLoc(bEnable);

    if( !bEnable ) return;
    if( GetStateName() != 'Patrolling' ) {
        loopCounter=0;
        return;
    }

    // don't do any fix if the destPoint is not one of the 2 most recent ones
    // when I saw the crash, the pawn would alternate between attempting 2 different destPoints, but the FindPathToward would fail for both of them
    if( prevprevDest == destPoint ) {
        prevprevDest = prevDest;
        prevDest = destPoint;
    }
    else if( prevDest != destPoint ) {
        prevprevDest = prevDest;
        prevDest = destPoint;
        loopCounter=0;
        return;
    }

    tMoveTarget = FindPathToward(destPoint);
    if( tMoveTarget != None ) {
        loopCounter=0;
        prevprevDest = None;
        prevDest = None;
        return;
    }

    loopCounter++;

    if( loopCounter > 10 ) {
        message = "EnableCheckDestLoc, bEnable: "$bEnable$", loopCounter: "$loopCounter$", destPoint: "$destPoint$", tMoveTarget: "$tMoveTarget$", MoveTarget: "$MoveTarget;
        log(self$": WARNING: "$message);
        foreach AllActors(class'DXRando', dxr) break;
        if( dxr != None ) class'DXRTelemetry'.static.SendLog(None, Self, "WARNING", message);

        //calling the BackOff() function also works and makes them attempt to patrol again after, but I expect it would always just fail over and over
        SetOrders('Wandering', '', true);
        loopCounter=0;
    }
}

function float GetPawnAlliance(Pawn p)
{
    local int i;

    for(i=0; i<ArrayCount(AlliancesEx); i++) {
        if(AlliancesEx[i].AllianceName == p.Alliance)
            return AlliancesEx[i].AllianceLevel;
    }
    return 0;
}
