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

function BeginPlay()
{
    Super.BeginPlay();
    if(InStr(BindName, "LDDP")==0) {
        if(!class'DXRMenuScreenNewGame'.static.HasLDDPInstalled()) {
            Destroy();
        }
    }
}

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
        if(class'MenuChoice_ThrowMelee'.default.enabled)
            melee = class'DXRActorsBase'.static.IsMeleeWeapon(item);
        drop = (item.IsA('NanoKey') && gibbed) || (melee && !gibbed) || (gibbed && item.bDisplayableInv);
        if( DeusExWeapon(item) != None && DeusExWeapon(item).bNativeAttack )
            drop = false;
        if( Ammo(item) != None )
            drop = false;
        if( drop ) {
            class'DXRActorsBase'.static.ThrowItem(item, 0.3);
            if(gibbed)
                item.Velocity *= vect(-10, -10, 10);
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
    local Vector X, Y, Z;
	local float dotp;

    gibbed = (Health < -100) && Robot(self) == None;

    if( gibbed ) {
        p = DeusExPlayer(GetPlayerPawn());
        class'DXRStats'.static.AddGibbedKill(p);
    }

    ThrowInventory(gibbed);

    // DXRando: modified vanilla code below to support animals being knocked unconscious

	if (Region.Zone.bWaterZone)
		PlayAnimPivot('WaterDeath',, 0.1);
	else if (bSitting)  // if sitting, always fall forward
		PlayAnimPivot('DeathFront',, 0.1);
	else {
		GetAxes(Rotation, X, Y, Z);
		dotp = (Location - HitLoc) dot X;

		// die from the correct side
		if (dotp < 0.0)		// shot from the front, fall back
			PlayAnimPivot('DeathBack',, 0.1);
		else				// shot from the back, fall front
			PlayAnimPivot('DeathFront',, 0.1);
	}

    bStunned = class'DXRActorsBase'.static.CanKnockUnconscious(self, damageType);

	if (bStunned && Animal(self) == None) {
		if (bIsFemale)
			PlaySound(Sound'FemaleUnconscious', SLOT_Pain,,,, RandomPitch());
		else
			PlaySound(Sound'MaleUnconscious', SLOT_Pain,,,, RandomPitch());
	}
	else {
		PlayDyingSound();
	}
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
    local Human h;
    local bool wasOnFire;

    if (damageType == 'FlareFlamed') {
        baseDamageType = 'Flamed';
    } else {
        baseDamageType = damageType;
    }

    wasOnFire=bOnFire;

    _TakeDamageBase(Damage,instigatedBy,hitLocation,momentum,baseDamageType,bPlayAnim);

    if (!wasOnFire && bOnFire && instigatedBy==GetPlayerPawn()){
        h = Human(GetPlayerPawn());
        class'DXREvents'.static.MarkBingo(h.dxr,"IgnitedPawn");
    }

    if (bBurnedToDeath) {
        if (p==None){
            p = DeusExPlayer(GetPlayerPawn());
        }
        class'DXRStats'.static.AddBurnKill(p);
    }

    if (damageType == 'FlareFlamed') {
        flareBurnTime = 3;
    }

    if ((Health < -100) && !IsA('Robot') && !IsA('Animal'))
	{
        if (h==None){
            h = Human(GetPlayerPawn());
            class'DXREvents'.static.MarkBingo(h.dxr,"GibbedPawn");
        }
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
    local float        mult;

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

    if(!bInvincible && damageType != 'Stunned' && damageType != 'TearGas' && damageType != 'HalonGas' &&
            damageType != 'PoisonGas' && damageType != 'Radiation' && damageType != 'EMP' &&
            damageType != 'NanoVirus' && damageType != 'Drowned' &&
            damageType != 'Poison' && damageType != 'PoisonEffect')
    {
        // Impart momentum, DXRando multiply momentum by damage
        // pick the smaller between Damage and actualDamage so that stealth hits don't do insane knockback
        // and hits absorbed by shields do less knockback
        mult = FMin(Damage, actualDamage);
        mult += loge(mult);
        mult *= 0.3;
        if(mult > 0) {
            momentum *= mult;
            SetPhysics(PHYS_Falling);
            // need to lift off the ground cause once they land and start walking that overrides their velocity
            momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
            Velocity += momentum / Mass;
        }
    }

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

// ----------------------------------------------------------------------
// HandleDamage()
// ----------------------------------------------------------------------

function EHitLocation HandleDamage(int actualDamage, Vector hitLocation, Vector offset, name damageType)
{
    local EHitLocation hitPos;
    local float        headOffsetZ, headOffsetY, armOffset;

    // calculate our hit extents
    headOffsetZ = CollisionHeight * 0.7;
    headOffsetY = CollisionRadius * 0.3;
    armOffset   = CollisionRadius * 0.35;

    hitPos = HITLOC_None;

    if (actualDamage > 0)
    {
        if (offset.z > headOffsetZ)		// head
        {
            // narrow the head region
            if ((Abs(offset.x) < headOffsetY) || (Abs(offset.y) < headOffsetY))
            {
                // don't allow headshots with stunning weapons
                if ((damageType == 'Stunned') || (damageType == 'KnockedOut'))
                    HealthHead -= actualDamage * 2;// DXRando: 2x damage like torso
                else if(damageType == 'Sabot')
                    HealthHead -= actualDamage * 8;// DXRando: sabot ignores helmets, but this is still awkward with robots having heads?
                else// DXRando: helmet good, basically a nerf to the pistol especially for late game
                    HealthHead -= actualDamage * HeadDamageMult();
                if (offset.x < 0.0)
                    hitPos = HITLOC_HeadBack;
                else
                    hitPos = HITLOC_HeadFront;
            }
            else  // sides of head treated as torso
            {
                HealthTorso -= actualDamage * 2;
                if (offset.x < 0.0)
                    hitPos = HITLOC_TorsoBack;
                else
                    hitPos = HITLOC_TorsoFront;
            }
        }
        else if (offset.z < 0.0)	// legs
        {
            if (offset.y > 0.0)
            {
                HealthLegRight -= actualDamage * 2;
                if (offset.x < 0.0)
                    hitPos = HITLOC_RightLegBack;
                else
                    hitPos = HITLOC_RightLegFront;
            }
            else
            {
                HealthLegLeft -= actualDamage * 2;
                if (offset.x < 0.0)
                    hitPos = HITLOC_LeftLegBack;
                else
                    hitPos = HITLOC_LeftLegFront;
            }

             // if this part is already dead, damage the adjacent part
            if ((HealthLegRight < 0) && (HealthLegLeft > 0))
            {
                HealthLegLeft += HealthLegRight;
                HealthLegRight = 0;
            }
            else if ((HealthLegLeft < 0) && (HealthLegRight > 0))
            {
                HealthLegRight += HealthLegLeft;
                HealthLegLeft = 0;
            }

            if (HealthLegLeft < 0)
            {
                HealthTorso += HealthLegLeft;
                HealthLegLeft = 0;
            }
            if (HealthLegRight < 0)
            {
                HealthTorso += HealthLegRight;
                HealthLegRight = 0;
            }
        }
        else						// arms and torso
        {
            if (offset.y > armOffset)
            {
                HealthArmRight -= actualDamage * 2;
                if (offset.x < 0.0)
                    hitPos = HITLOC_RightArmBack;
                else
                    hitPos = HITLOC_RightArmFront;
            }
            else if (offset.y < -armOffset)
            {
                HealthArmLeft -= actualDamage * 2;
                if (offset.x < 0.0)
                    hitPos = HITLOC_LeftArmBack;
                else
                    hitPos = HITLOC_LeftArmFront;
            }
            else
            {
                HealthTorso -= actualDamage * 2;
                if (offset.x < 0.0)
                    hitPos = HITLOC_TorsoBack;
                else
                    hitPos = HITLOC_TorsoFront;
            }

            // if this part is already dead, damage the adjacent part
            if (HealthArmLeft < 0)
            {
                HealthTorso += HealthArmLeft;
                HealthArmLeft = 0;
            }
            if (HealthArmRight < 0)
            {
                HealthTorso += HealthArmRight;
                HealthArmRight = 0;
            }
        }
    }

    GenerateTotalHealth();

    return hitPos;
}

function int HeadDamageMult()
{
    if(MJ12Commando(self) != None) return 6;// their head is just as armored as the rest of them, don't need much buff?

    // check for helmet
    if(Mesh == LodMesh'DeusExCharacters.GM_Jumpsuit') {
        switch(MultiSkins[6]) {
        case Texture'DeusExItems.Skins.PinkMaskTex':
        case Texture'DeusExCharacters.Skins.GogglesTex1':
            return 8;// no helmet
        }
        return 4;// helmet
    }
    return 8;// 8x gives vanilla damage
}

function GotoDisabledState(name damageType, EHitLocation hitPos)
{
    if ((damageType == 'TearGas' || damageType == 'HalonGas')
        && Texture == Texture'DeusExCharacters.Skins.VisorTex1'
        && Mesh == LodMesh'DeusExCharacters.GM_Jumpsuit')
        return;
    Super.GotoDisabledState(damageType, hitPos);
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

function Bool HasTwoHandedWeapon()
{
    if(bIsFemale || Mesh==LodMesh'DeusExCharacters.GM_DressShirt_S' || Mesh==LodMesh'DeusExCharacters.GM_Trench_F' || Mesh==LodMesh'DeusExCharacters.GM_Scubasuit')
        return False;
    if ((Weapon != None) && (Weapon.Mass >= 30))
        return True;
    else
        return False;
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
    for(i=0; i<ArrayCount(AlliancesEx); i++) {
        if(AlliancesEx[i].AllianceName == '') continue;
        log("PrintAlliances "$i$": " $ AlliancesEx[i].AllianceName @ AlliancesEx[i].AllianceLevel @ AlliancesEx[i].bPermanent, name);
    }
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

    SpawnCarcass();
    Destroy();
}

function bool IsProjectileDangerous(DeusExProjectile projectile)
{
    //If they're mostly immune, don't consider it a threat
    if (ShieldDamage(projectile.damageType)<0.25){
        return False;
    }

    //Same deal here
    if (ModifyDamage(100,self,vect(0,0,0),vect(0,0,0),projectile.damageType)<=25){
        return False;
    }

    return Super.IsProjectileDangerous(projectile);
}

function SupportActor(Actor standingActor)
{
    local float  zVelocity;
	local float  baseMass;
	local float  standingMass;
	local vector damagePoint;
	local float  damage;
	local vector newVelocity;
	local float  angle;

    //Friendly stomp logic
    if (WillTakeStompDamage(standingActor)==false && PlayerPawn(standingActor)!=None){
        if (!((Physics == PHYS_Swimming) && Region.Zone.bWaterZone)){
            standingMass = FMax(1, standingActor.Mass);
            baseMass     = FMax(1, Mass);
            zVelocity    = standingActor.Velocity.Z;
            damagePoint  = Location + vect(0,0,1)*(CollisionHeight-1);
            damage       = (1 - (standingMass/baseMass) * (zVelocity/100));

            //Bouncing around on top of someone's head happens at around -55 zVelocity.  Giving some slop,
            // -75 seems like a reasonable cut off point for determining if it was an intentional stomp.
            //Human mass (which determines the standingMass) is 150.  10000 is a nice number though, so we'll
            //go with -66 being the cutoff point instead.
            if ((zVelocity*standingMass <= -10000)){
                TakeDamage(damage, standingActor.Instigator, damagePoint, 0.2*standingActor.Velocity, 'stomped');
            }
        }
    }

    //ScriptedPawns can't stomp other ScriptedPawns
    if (ScriptedPawn(standingActor)==None){
        Super.SupportActor(standingActor);
    } else {
        //Still bounce them off
        angle = FRand()*Pi*2;
        newVelocity.X = cos(angle);
        newVelocity.Y = sin(angle);
        newVelocity.Z = 0;
        newVelocity *= FRand()*25 + 25;
        newVelocity += standingActor.Velocity;
        newVelocity.Z = 50;
        standingActor.Velocity = newVelocity;
        standingActor.SetPhysics(PHYS_Falling);
    }
}


state Sitting
{
    function FollowSeatFallbackOrders()
    {
        FindBestSeat();
        if (IsSeatValid(SeatActor)){
            GotoState('Sitting', 'Begin');
        }else{
            if (SeatDesperation()){
                GotoState('Wandering');
            }
        }
    }

    function bool SeatDesperation()
    {
        local Seat aSeat,closestSeat;
        local int bestSlot;
        local float closeSeatDist;

        closestSeat = None;
        closeSeatDist = 9999;

        foreach self.RadiusActors(class'Seat',aSeat,160){
            if (VSize(aSeat.Location-Location)<closeSeatDist){
                closestSeat = aSeat;
            }
        }

        if (closestSeat==None){
            return true;
        }

        //Find seat slot
        bestSlot = -1;
        bestSlot = FindBestSlot(closestSeat,closeSeatDist);

        if (bestSlot<0){
            return true;
        }

        SeatActor = closestSeat;
        SeatActor.sittingActor[bestSlot]=self;
        SeatLocation = SeatActor.Location;
        bSeatLocationValid=true;
        SeatSlot = bestSlot;
        GotoState('Sitting','CircleToFront');

        return false;
    }

}

defaultproperties
{
    EmpHealth=50
    FearSustainTime=15
}
