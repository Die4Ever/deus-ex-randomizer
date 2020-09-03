class DXREnemies extends DXRActorsBase;

var config int chance_clone_nonhumans;

struct RandomWeaponStruct { var class<Weapon> type; var int chance; };
var config RandomWeaponStruct randommelee[8];
var config RandomWeaponStruct randomweapons[32];

struct RandomEnemyStruct { var class<ScriptedPawn> type; var int chance; };
var config RandomEnemyStruct randomenemies[32];

var config name defaultOrders;

function CheckConfig()
{
    local int i;
    if( config_version == 0 ) {
        chance_clone_nonhumans = 90;

        for(i=0; i < ArrayCount(randommelee); i++ ) {
            randommelee[i].type = None;
            randommelee[i].chance = 0;
        }
        for(i=0; i < ArrayCount(randomenemies); i++ ) {
            randomenemies[i].type = None;
            randomenemies[i].chance = 0;
            randomenemies[i].type = None;
            randomenemies[i].chance = 0;
        }

        i=0;
        randomenemies[i].type = class'ThugMale';
        randomenemies[i++].chance = 10;
        randomenemies[i].type = class'ThugMale2';
        randomenemies[i++].chance = 10;
        randomenemies[i].type = class'ThugMale3';
        randomenemies[i++].chance = 10;
        randomenemies[i].type = class'Greasel';
        randomenemies[i++].chance = 8;
        randomenemies[i].type = class'Gray';
        randomenemies[i++].chance = 4;
        randomenemies[i].type = class'Karkian';
        randomenemies[i++].chance = 4;
        randomenemies[i].type = class'SpiderBot';
        randomenemies[i++].chance = 8;
        randomenemies[i].type = class'MilitaryBot';
        randomenemies[i++].chance = 4;
        randomenemies[i].type = class'SpiderBot2';
        randomenemies[i++].chance = 4;
        randomenemies[i].type = class'SecurityBot2';
        randomenemies[i++].chance = 4;
        randomenemies[i].type = class'SecurityBot3';
        randomenemies[i++].chance = 4;
        randomenemies[i].type = class'SecurityBot4';
        randomenemies[i++].chance = 4;

        i=0;
        randomweapons[i].type = class'WeaponPistol';
        randomweapons[i++].chance = 11;
        randomweapons[i].type = class'WeaponAssaultGun';
        randomweapons[i++].chance = 11;
        randomweapons[i].type = class'WeaponMiniCrossbow';
        randomweapons[i++].chance = 11;
        randomweapons[i].type = class'WeaponGEPGun';
        randomweapons[i++].chance = 4;
        randomweapons[i].type = class'WeaponAssaultShotgun';
        randomweapons[i++].chance = 5;
        randomweapons[i].type = class'WeaponEMPGrenade';
        randomweapons[i++].chance = 5;
        randomweapons[i].type = class'WeaponFlamethrower';
        randomweapons[i++].chance = 4;
        randomweapons[i].type = class'WeaponGasGrenade';
        randomweapons[i++].chance = 5;
        randomweapons[i].type = class'WeaponHideAGun';
        randomweapons[i++].chance = 5;
        randomweapons[i].type = class'WeaponLAM';
        randomweapons[i++].chance = 5;
        randomweapons[i].type = class'WeaponLAW';
        randomweapons[i++].chance = 4;
        randomweapons[i].type = class'WeaponNanoVirusGrenade';
        randomweapons[i++].chance = 5;
        randomweapons[i].type = class'WeaponPepperGun';
        randomweapons[i++].chance = 5;
        randomweapons[i].type = class'WeaponPlasmaRifle';
        randomweapons[i++].chance = 5;
        randomweapons[i].type = class'WeaponRifle';
        randomweapons[i++].chance = 5;
        randomweapons[i].type = class'WeaponRifle';
        randomweapons[i++].chance = 5;
        randomweapons[i].type = class'WeaponSawedOffShotgun';
        randomweapons[i++].chance = 5;
        randomweapons[i].type = class'WeaponShuriken';
        randomweapons[i++].chance = 5;

        i=0;
        randommelee[i].type = class'WeaponBaton';
        randommelee[i++].chance = 25;
        randommelee[i].type = class'WeaponCombatKnife';
        randommelee[i++].chance = 25;
        randommelee[i].type = class'WeaponCrowbar';
        randommelee[i++].chance = 25;
        randommelee[i].type = class'WeaponSword';
        randommelee[i++].chance = 25;

        defaultOrders = 'Wandering';
    }
    Super.CheckConfig();
}

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
    {// even hidden pawns?
        if( pawn.bHidden ) continue;
        p = ScriptedPawn(pawn);
        if( p != None && p.bImportant ) continue;
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
    local int r, i;
    r = initchance();
    for(i=0; i < ArrayCount(randomenemies); i++ ) {
        if( chance( randomenemies[i].chance, r ) ) newclass = randomenemies[i].type;
    }

    chance_remaining(r);// else keep the same class

    if( chance_single(chance_clone_nonhumans)==False && newclass == None && IsHuman(base) == False ) return None;

    n = CloneScriptedPawn(base, newclass);
    if( n != None ) RandomizeSP(n, percent);
    //else RandomizeSize(n);
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

    n.Orders = defaultOrders;
    n.HomeTag = 'Start';

    RandomizeSize(n);

    return n;
}

function RandomizeSP(ScriptedPawn p, int percent)
{
    local class<Weapon> wclass;
    local Weapon w;
    local int r, i;

    if( p == None ) return;

    p.SurprisePeriod *= float(rng(100)/100)+0.3;

    if( IsHuman(p) == False ) return; // only give random weapons to humans

    r = initchance();
    for(i=0; i < ArrayCount(randomweapons); i++ ) {
        if( chance( randomweapons[i].chance, r ) ) wclass = randomweapons[i].type;
    }

    w = Spawn(wclass, p);
    w.GiveTo(p);
    w.SetBase(p);

    if( w.AmmoName != None ) {
        w.AmmoType = spawn(w.AmmoName);
        w.AmmoType.InitialState='Idle2';
        w.AmmoType.GiveTo(p);
        w.AmmoType.SetBase(p);
    }

    GiveRandomMeleeWeapon(p);

    p.SetupWeapon(false);
}

function GiveRandomMeleeWeapon(ScriptedPawn p)
{
    local class<Weapon> wclass;
    local Weapon w;
    local int r, i;

    if
    (
        HasItem(p, class'WeaponBaton')
        || HasItem(p, class'WeaponCombatKnife')
        || HasItem(p, class'WeaponCrowbar')
        || HasItem(p, class'WeaponSword')
        || HasItem(p, class'WeaponNanoSword')
    )
        return;

    r = initchance();
    for(i=0; i < ArrayCount(randomweapons); i++ ) {
        if( randommelee[i].type == None ) continue;
        if( chance( randommelee[i].chance, r ) ) wclass = randommelee[i].type;

        if( HasItem(p, randommelee[i].type) ) {
            chance_remaining(r);
            return;
        }
    }

    w = Spawn(wclass, p);
    w.GiveTo(p);
    w.SetBase(p);
}

function RandomizeSize(Actor a)
{
    local Decoration carried;
    local DeusExPlayer p;

    p = DeusExPlayer(a);
    if( p != None && p.carriedDecoration != None ) {
        carried = p.carriedDecoration;
        p.DropDecoration();
        carried.SetPhysics(PHYS_None);
    }
    SetActorScale(a, float(rng(200))/1000 + 0.9);
    a.Fatness = rng(20) + 120;

    if( carried != None ) {
        p.carriedDecoration = carried;
        p.PutCarriedDecorationInHand();
    }
}
