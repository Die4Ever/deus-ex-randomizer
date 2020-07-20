class DXREnemies extends DXRActorsBase;

function FirstEntry()
{
    Super.FirstEntry();
    RandoEnemies(dxr.flags.enemiesrandomized);
}

function RandoEnemies(int percent)
{
    local int i;
    local ScriptedPawn p;
    local ScriptedPawn n;
    local ScriptedPawn newsp;
    local Pawn pawn;

    l("RandoEnemies "$percent);

    SetSeed( "RandoEnemies" );

    foreach AllActors(class'Pawn', pawn)
    {// even hidden and important pawns?
        RandomizeSize(pawn);
    }

    foreach AllActors(class'ScriptedPawn', p)
    {
        if( p == newsp ) break;
        if( SkipActor(p, 'ScriptedPawn') ) continue;
        if( p.bImportant || p.bInvincible ) continue;
        //if( IsInitialEnemy(p) == False ) continue;

        if( rng(100) < percent ) RandomizeSP(p, percent);

        if( rng(100) >= percent ) continue;

        n = RandomEnemy(p, percent);
        if( newsp == None ) newsp = n;
    }
}

function ScriptedPawn RandomEnemy(ScriptedPawn base, int percent)
{
    local class<ScriptedPawn> newclass;
    local ScriptedPawn n;
    local int r;
    r = initchance();
    if( chance(5, r) ) newclass = class'Gray';
    if( chance(5, r) ) newclass = class'Karkian';
    if( chance(10, r) ) newclass = class'Greasel';
    if( chance(5, r) ) newclass = class'MilitaryBot';
    if( chance(10, r) ) newclass = class'SpiderBot';
    if( chance(5, r) ) newclass = class'SpiderBot2';
    if( chance(10, r) ) newclass = class'ThugMale';
    if( chance(10, r) ) newclass = class'ThugMale2';
    if( chance(10, r) ) newclass = class'ThugMale3';
    if( chance(5, r) ) newclass = class'SecurityBot2';
    if( chance(5, r) ) newclass = class'SecurityBot3';
    if( chance(5, r) ) newclass = class'SecurityBot4';

    chance(15, r);// else keep the same class

    n = CloneScriptedPawn(base, newclass);
    if( n != None && rng(100) < percent ) RandomizeSP(n, percent);
    return n;
}

function bool IsInitialEnemy(ScriptedPawn p)
{
    local int i;

    return p.GetPawnAllianceType(dxr.Player) == ALLIANCE_Hostile;
}

function ScriptedPawn CloneScriptedPawn(ScriptedPawn p, optional class<ScriptedPawn> newclass)
{
    local int i;
    local ScriptedPawn n;
    local float radius;
    local vector loc;
    local Inventory inv;
    local NanoKey k1, k2;

    if( p == None ) {
        l("p == None?");
        return None;
    }
    if( newclass == None ) newclass = p.class;
    radius = p.CollisionRadius;
    loc = p.Location + (radius*vect(3, 1, 0));
    // find a different location?
    n = Spawn(newclass,,, loc );
    if( n == None ) {
        l("failed to clone "$ActorToString(p)$" into class "$newclass$" into "$loc);
        return None;
    }

    l("cloning "$ActorToString(p)$" into class "$newclass$" got "$ActorToString(n));

    n.Alliance = p.Alliance;
    for(i=0; i<ArrayCount(n.InitialAlliances); i++ )
    {
        n.InitialAlliances[i] = p.InitialAlliances[i];
    }

    /*if( newclass == p.Class ) {
        for(i=0; i<ArrayCount(n.InitialInventory); i++ )
        {
            n.InitialInventory[i] = p.InitialInventory[i];
        }
    }*/
    
    inv = p.Inventory;
    while( inv != None ) {
        k1 = NanoKey(inv);
        if( k1 != None )
        {
            k2 = Spawn(class'NanoKey', n);
            k2.KeyID = k1.KeyID;
            k2.Description = k1.Description;
            k2.SkinColor = k1.SkinColor;
            k2.InitialState = k1.InitialState;
            k2.GiveTo(n);
            k2.SetBase(n);
        }
        inv = inv.Inventory;
    }

    //Orders = 'Patrolling', Engine.PatrolPoint with Nextpatrol?
    //bReactAlarm, bReactCarcass, bReactDistress, bReactFutz, bReactLoudNoise, bReactPresence, bReactProjectiles, bReactShot
    //bFearAlarm, bFearCarcass, bFearDistress, bFearHacking, bFearIndirectInjury, bFearInjury, bFearProjectiles, bFearShot, bFearWeapon

    n.Orders = 'Wandering';
    n.HomeTag = 'Start';

    RandomizeSize(n);

    return n;
}

function RandomizeSP(ScriptedPawn p, int percent)
{
    local class<Weapon> wclass;
    local Weapon w;
    local int r;

    if( p == None ) return;

    //p.Orders = 'Wandering';
    //p.HomeTag = 'Start';
    p.SurprisePeriod *= float(rng(100)/100)+0.3;

    if( HumanMilitary(p) == None && HumanThug(p) == None && HumanCivilian(p) == None ) return; // only give random weapons to humans

    r = initchance();
    if( chance(5, r) ) wclass = class'WeaponGEPGun';
    if( chance(10, r) ) wclass = class'WeaponAssaultGun';
    if( chance(5, r) ) wclass = class'WeaponAssaultShotgun';
    if( chance(5, r) ) wclass = class'WeaponEMPGrenade';
    if( chance(5, r) ) wclass = class'WeaponFlamethrower';
    if( chance(5, r) ) wclass = class'WeaponGasGrenade';
    if( chance(5, r) ) wclass = class'WeaponHideAGun';
    if( chance(5, r) ) wclass = class'WeaponLAM';
    if( chance(5, r) ) wclass = class'WeaponLAW';
    if( chance(10, r) ) wclass = class'WeaponMiniCrossbow';
    if( chance(5, r) ) wclass = class'WeaponNanoVirusGrenade';
    if( chance(5, r) ) wclass = class'WeaponPepperGun';
    if( chance(5, r) ) wclass = class'WeaponPlasmaRifle';
    if( chance(5, r) ) wclass = class'WeaponRifle';
    if( chance(5, r) ) wclass = class'WeaponSawedOffShotgun';
    if( chance(5, r) ) wclass = class'WeaponShuriken';
    if( chance(10, r) ) wclass = class'WeaponPistol';
    //if( chance(5, r) ) wclass = class'WeaponSword';

    w = Spawn(wclass, p);
    w.GiveTo(p);
    w.SetBase(p);

    if( w.AmmoName != None ) {
        w.AmmoType = spawn(w.AmmoName);
        w.AmmoType.InitialState='Idle2';
        w.AmmoType.GiveTo(p);
        w.AmmoType.SetBase(p);
    }

    p.SetupWeapon(false);
}

function RandomizeSize(Actor a)
{
    //l("RandomizeSize "$a$", DrawScale=="$a.DrawScale$", Fatness=="$a.Fatness);
    SetActorScale(a, float(rng(200))/1000 + 0.9);
    a.Fatness = rng(20) + 120;
}
