class FixScriptedPawn shims ScriptedPawn;
// doesn't work with injects, because of states and : Error, DeusEx.ScriptedPawn's superclass must be Engine.Pawn, not DeusEx.ScriptedPawnBase
// could work with injectsabove or whatever https://github.com/Die4Ever/deus-ex-randomizer/issues/115
var int flareBurnTime;

var int loopCounter;
var float lastEnableCheckDestLocTime;
var int EmpHealth;

/*function IncreaseAgitation(Actor actorInstigator, optional float AgitationLevel)
{
    log(Self$" IncreaseAgitation "$actorInstigator$", "$AgitationLevel);
}*/

event Destroyed()
{
    // throw whatever remains of their inventory so it isn't lost, most applicable to MIBs and other self destructing enemies
    if(Health <=0)
        ThrowInventory(true);
    Super.Destroyed();
}

function ThrowInventory(bool gibbed)
{
    local Inventory item, nextItem;
    local bool drop, melee;

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
            class'DXRActorsBase'.static.ThrowItem(item, 1.0);
            if(gibbed)
                item.Velocity *= vect(-2, -2, 2);
            else
                item.Velocity *= vect(-1.5, -1.5, 1.5);
        }
        item = nextItem;
    }
}

function PlayDying(name damageType, vector hitLoc)
{
    local DeusExPlayer p;
    local Inventory item, nextItem;
    local bool gibbed;

    gibbed = (Health < -100) && !IsA('Robot');

    if( gibbed ) {
        p = DeusExPlayer(GetPlayerPawn());
        class'DXRStats'.static.AddGibbedKill(p);
    }

    ThrowInventory(gibbed);

    Super.PlayDying(damageType, hitLoc);
}

function Carcass SpawnCarcass()
{
    local vector loc;
    local FleshFragment chunk;
    local int i;
    local float size;

    // if we really got blown up good, gib us and don't display a carcass
    // DXRando: apply velocity and acceleration to gibs
    if ((Health < -100) && !IsA('Robot'))
    {
        size = (CollisionRadius + CollisionHeight) / 2;
        if (size > 10.0)
        {
            for (i=0; i<size/4.0; i++)
            {
                loc.X = (1-2*FRand()) * CollisionRadius;
                loc.Y = (1-2*FRand()) * CollisionRadius;
                loc.Z = (1-2*FRand()) * CollisionHeight;
                loc += Location;
                chunk = spawn(class'FleshFragment', None,, loc);
                if (chunk != None)
                {
                    chunk.DrawScale = size / 25;
                    chunk.SetCollisionSize(chunk.CollisionRadius / chunk.DrawScale, chunk.CollisionHeight / chunk.DrawScale);
                    chunk.bFixedRotationDir = True;
                    chunk.RotationRate = RotRand(False);
                    // DXRando: apply velocity and acceleration to gibs
                    chunk.Velocity += Velocity;
                    chunk.Acceleration += Acceleration;
                }
            }
        }
        return None;
    }

    return Super.SpawnCarcass();
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

    _TakeDamageBase(Damage,instigatedBy,hitLocation,momentum,baseDamageType,bPlayAnim);

    if (bBurnedToDeath) {
        p = DeusExPlayer(GetPlayerPawn());
        class'DXRStats'.static.AddBurnKill(p);
    }

    if (damageType == 'FlareFlamed') {
        flareBurnTime = 3;
    }
}

// ----------------------------------------------------------------------
// TakeDamageBase() mostly original, but modified with EmpHealth
// ----------------------------------------------------------------------

function _TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType,
                        bool bPlayAnim)
{
    local int          actualDamage;
    local Vector       offset;
    local float        origHealth;
    local EHitLocation hitPos;
    local float        shieldMult;

    // use the hitlocation to determine where the pawn is hit
    // transform the worldspace hitlocation into objectspace
    // in objectspace, remember X is front to back
    // Y is side to side, and Z is top to bottom
    offset = (hitLocation - Location) << Rotation;

    if (!CanShowPain())
        bPlayAnim = false;

    // Prevent injury if the NPC is intangible
    if (!bBlockActors && !bBlockPlayers && !bCollideActors)
        return;

    // No damage + no damage type = no reaction
    if ((Damage <= 0) && (damageType == 'None'))
        return;

    // DXRando EmpHealth to disable shields
    if(damageType=='EMP') EmpHealth -= Damage;

    // Block certain damage types; perform special ops on others
    if (!FilterDamageType(instigatedBy, hitLocation, offset, damageType))
        return;

    actualDamage = ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType);

    // DXRando check EmpHealth
    shieldMult = 1.0;
    if (actualDamage > 0 && EmpHealth > 0)
    {
        shieldMult = ShieldDamage(damageType);
        if (shieldMult > 0)
            actualDamage = Max(int(actualDamage*shieldMult), 1);
        else
            actualDamage = 0;
        if (shieldMult < 1.0)
            DrawShield();
    }

    // Impart momentum, DXRando multiply momentum by damage
    // pick the smaller between Damage and actualDamage so that stealth hits don't do insane knockback
    // and hits absorbed by shields do less knockback
    momentum *= FMax(1, loge(loge(FMin(Damage, actualDamage))+1.0)*7.0);
    ImpartMomentum(momentum, instigatedBy);

    origHealth = Health;

    hitPos = HandleDamage(actualDamage, hitLocation, offset, damageType);
    if (!bPlayAnim || (actualDamage <= 0))
        hitPos = HITLOC_None;

    if (bCanBleed)
        if ((damageType != 'Stunned') && (damageType != 'TearGas') && (damageType != 'HalonGas') &&
            (damageType != 'PoisonGas') && (damageType != 'Radiation') && (damageType != 'EMP') &&
            (damageType != 'NanoVirus') && (damageType != 'Drowned') && (damageType != 'KnockedOut') &&
            (damageType != 'Poison') && (damageType != 'PoisonEffect'))
            bleedRate += (origHealth-Health)/(0.3*Default.Health);  // 1/3 of default health = bleed profusely

    if (CarriedDecoration != None)
        DropDecoration();

    if ((actualDamage > 0) && (damageType == 'Poison'))
        StartPoison(Damage, instigatedBy);

    if (Health <= 0)
    {
        ClearNextState();
        //PlayDeathHit(actualDamage, hitLocation, damageType);
        if ( actualDamage > mass )
            Health = -1 * actualDamage;
        SetEnemy(instigatedBy, 0, true);

        // gib us if we get blown up
        if (DamageType == 'Exploded')
            Health = -10000;
        else
            Health = -1;

        Died(instigatedBy, damageType, HitLocation);

        if ((DamageType == 'Flamed') || (DamageType == 'Burned'))
        {
            bBurnedToDeath = true;
            ScaleGlow *= 0.1;  // blacken the corpse
        }
        else
            bBurnedToDeath = false;

        return;
    }

    // play a hit sound
    if (DamageType != 'Stunned')
        PlayTakeHitSound(actualDamage, damageType, 1);

    // DXRando don't CatchFire if the shield reduced the burning damage
    if ((DamageType == 'Flamed') && !bOnFire && shieldMult >= 1.0)
        CatchFire();

    ReactToInjury(instigatedBy, damageType, hitPos);
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
    class'DXREvents'.static.AddPawnDeath(self, Killer, damageType, HitLocation);
    Super.Died(Killer,damageType,HitLocation);
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
    local string message;

    Super.EnableCheckDestLoc(bEnable);

    if( !bEnable ) return;
    if( GetStateName() != 'Patrolling' ) {
        loopCounter=0;
        return;
    }

    // prevent runaway loops by keeping track of how many times this is called in the same frame/tick
    if(lastEnableCheckDestLocTime == Level.TimeSeconds) {
        loopCounter++;
    } else {
        lastEnableCheckDestLocTime = Level.TimeSeconds;
        loopCounter = 0;
    }

    if( loopCounter > 10 ) {
        message = "EnableCheckDestLoc, bEnable: "$bEnable$", loopCounter: "$loopCounter$", destPoint: "$destPoint$", lastEnableCheckDestLocTime: "$lastEnableCheckDestLocTime;
        log(self$": WARNING: "$message);
        foreach AllActors(class'DXRando', dxr) break;
        if( dxr != None ) class'DXRTelemetry'.static.SendLog(dxr, Self, "WARNING", message);

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

function PrintAlliances()
{
    local int i;
    log("PrintAlliances: "$alliance, name);
    for(i=0; i<ArrayCount(AlliancesEx); i++)
        log("PrintAlliances "$i$": " $ AlliancesEx[i].AllianceName @ AlliancesEx[i].AllianceLevel @ AlliancesEx[i].bPermanent, name);
}

state Dying
{
    ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, Timer, TakeDamage;
Begin:
    //WaitForLanding();// DXRando: spawn the carcass immediately instead, otherwise the knockback can look funny, the carcass inherits momentum anyways
    MoveFallingBody();

    DesiredRotation.Pitch = 0;
    DesiredRotation.Roll  = 0;

    // if we don't gib, then wait for the animation to finish
    if ((Health > -100) && !IsA('Robot'))
        FinishAnim();

    SetWeapon(None);

    bHidden = True;

    Acceleration = vect(0,0,0);
    SpawnCarcass();
    Destroy();
}

defaultproperties
{
    EmpHealth=50
}
