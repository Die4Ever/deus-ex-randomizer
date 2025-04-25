class DXRWeaponWhip extends DeusExWeapon;

// WIP, maybe not feasible...
var transient DXRAnimTracker tracker;

simulated function Tick(float deltaTime)
{
    local vector loc;
    local rotator rot;
    local Pawn pawn;
    local Vector offset, X, Y, Z;

    pawn = Pawn(Owner);

    Super.Tick(deltaTime);

    // don't do any of this if this weapon isn't currently in use
    if (pawn == None || pawn.Weapon != self)
    {
        if(tracker != None) {
            tracker.Destroy();
            tracker = None;
        }
        return;
    }

    if(tracker == None) {
        tracker = class'DXRAnimTracker'.static.Create(pawn, "first person");
    }
}


simulated function PlaySelectiveFiring()
{
    local Pawn aPawn;
    local float rnd;
    local Name anim;

    anim = 'Attack';

    if (( Level.NetMode == NM_Standalone ) || ( DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())) )
    {
        if (bAutomatic)
            LoopAnim(anim,, 0.1);
        else
            PlayAnim(anim,,0.1);
    }
    else if ( Role == ROLE_Authority )
    {
        for ( aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.nextPawn )
        {
            if ( aPawn.IsA('DeusExPlayer') && ( DeusExPlayer(Owner) != DeusExPlayer(aPawn) ) )
            {
                // If they can't see the weapon, don't bother
                if ( DeusExPlayer(aPawn).FastTrace( DeusExPlayer(aPawn).Location, Location ))
                    DeusExPlayer(aPawn).ClientPlayAnimation( Self, anim, 0.1, bAutomatic );
            }
        }
    }
}


function name WeaponDamageType()
{
    return 'KnockedOut';
}

defaultproperties
{
    LowAmmoWaterMark=0
    GoverningSkill=Class'DeusEx.SkillWeaponLowTech'
    NoiseLevel=0.050000
    reloadTime=0.000000
    HitDamage=0
    maxRange=80
    AccurateRange=80
    BaseAccuracy=1.000000
    bPenetrating=False
    bHasMuzzleFlash=False
    bHandToHand=True
    bFallbackWeapon=True
    bEmitWeaponDrawn=False
    AmmoName=Class'DeusEx.AmmoNone'
    ReloadCount=0
    bInstantHit=True
    FireOffset=(X=24.000000,Y=14.000000,Z=-17.000000)
    ThirdPersonScale=0.001
    shakemag=20.000000
    FireSound=Sound'DeusExSounds.Weapons.BatonFire'
    SelectSound=Sound'DeusExSounds.Weapons.BatonSelect'
    Misc1Sound=Sound'DeusExSounds.Weapons.BatonHitFlesh'
    Misc2Sound=Sound'DeusExSounds.Weapons.BatonHitHard'
    Misc3Sound=Sound'DeusExSounds.Weapons.BatonHitSoft'
    InventoryGroup=666
    ItemName="Whip"
    PlayerViewOffset=(X=24.000000,Y=-14.000000,Z=-17.000000)
    PlayerViewMesh=LodMesh'DeusExItems.Baton'
    PickupViewMesh=LodMesh'DeusExItems.BatonPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.Baton3rd'
    Icon=Texture'DeusExUI.Icons.BeltIconBaton'
    largeIcon=Texture'DeusExUI.Icons.LargeIconBaton'
    largeIconWidth=46
    largeIconHeight=47
    Description="A physics-based whip!"
    beltDescription="WHIP"
    Mesh=LodMesh'DeusExItems.BatonPickup'
    CollisionRadius=14.000000
    CollisionHeight=1.000000
}
