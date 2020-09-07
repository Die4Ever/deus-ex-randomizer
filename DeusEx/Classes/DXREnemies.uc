class DXREnemies extends DXRActorsBase;

var config int chance_clone_nonhumans;
var config int enemy_multiplier;

struct RandomWeaponStruct { var class<Weapon> type; var int chance; };
var config RandomWeaponStruct randommelees[8];
var config RandomWeaponStruct randomweapons[32];

struct RandomEnemyStruct { var class<ScriptedPawn> type; var int chance; };
var config RandomEnemyStruct randomenemies[32];

var config name defaultOrders;

function CheckConfig()
{
    local int i;
    if( config_version == 0 ) {
        chance_clone_nonhumans = 70;
        enemy_multiplier = 1;

        for(i=0; i < ArrayCount(randommelees); i++ ) {
            randommelees[i].type = None;
            randommelees[i].chance = 0;
        }
        for(i=0; i < ArrayCount(randomenemies); i++ ) {
            randomenemies[i].type = None;
            randomenemies[i].chance = 0;
            randomenemies[i].type = None;
            randomenemies[i].chance = 0;
        }

        AddRandomEnemyType(class'ThugMale', 10);
        AddRandomEnemyType(class'ThugMale2', 10);
        AddRandomEnemyType(class'ThugMale3', 10);
        AddRandomEnemyType(class'Greasel', 6);
        AddRandomEnemyType(class'Gray', 3);
        AddRandomEnemyType(class'Karkian', 3);
        AddRandomEnemyType(class'SpiderBot', 6);
        AddRandomEnemyType(class'MilitaryBot', 3);
        AddRandomEnemyType(class'SpiderBot2', 3);
        AddRandomEnemyType(class'SecurityBot2', 3);
        AddRandomEnemyType(class'SecurityBot3', 3);
        AddRandomEnemyType(class'SecurityBot4', 3);

        AddRandomWeapon(class'WeaponPistol', 11);
        AddRandomWeapon(class'WeaponAssaultGun', 11);
        AddRandomWeapon(class'WeaponMiniCrossbow', 11);
        AddRandomWeapon(class'WeaponGEPGun', 4);
        AddRandomWeapon(class'WeaponAssaultShotgun', 5);
        AddRandomWeapon(class'WeaponEMPGrenade', 5);
        AddRandomWeapon(class'WeaponFlamethrower', 4);
        AddRandomWeapon(class'WeaponGasGrenade', 5);
        AddRandomWeapon(class'WeaponHideAGun', 5);
        AddRandomWeapon(class'WeaponLAM', 5);
        AddRandomWeapon(class'WeaponLAW', 4);
        AddRandomWeapon(class'WeaponNanoVirusGrenade', 5);
        AddRandomWeapon(class'WeaponPepperGun', 5);
        AddRandomWeapon(class'WeaponPlasmaRifle', 5);
        AddRandomWeapon(class'WeaponRifle', 5);
        AddRandomWeapon(class'WeaponSawedOffShotgun', 5);
        AddRandomWeapon(class'WeaponShuriken', 5);

        AddRandomMelee(class'WeaponBaton', 25);
        AddRandomMelee(class'WeaponCombatKnife', 25);
        AddRandomMelee(class'WeaponCrowbar', 25);
        AddRandomMelee(class'WeaponSword', 25);

        defaultOrders = 'Wandering';
    }
    Super.CheckConfig();
}

function AddRandomWeapon(class<Weapon> t, int c)
{
    local int i;
    for(i=0; i < ArrayCount(randomweapons); i++) {
        if( randomweapons[i].type == None ) {
            randomweapons[i].type = t;
            randomweapons[i].chance = c;
            return;
        }
    }
}

function AddRandomMelee(class<Weapon> t, int c)
{
    local int i;
    for(i=0; i < ArrayCount(randommelees); i++) {
        if( randommelees[i].type == None ) {
            randommelees[i].type = t;
            randommelees[i].chance = c;
            return;
        }
    }
}

function AddRandomEnemyType(class<ScriptedPawn> t, int c)
{
    local int i;
    for(i=0; i < ArrayCount(randomenemies); i++) {
        if( randomenemies[i].type == None ) {
            randomenemies[i].type = t;
            randomenemies[i].chance = c;
            return;
        }
    }
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

        for(i = rng(enemy_multiplier+percent/100); i >= 0; i--) {
            n = RandomEnemy(p, percent);
            if( newsp == None ) newsp = n;
        }
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
    local vector loc, loc_offset;
    local Inventory inv;
    local NanoKey k1, k2;

    if( p == None ) {
        l("p == None?");
        return None;
    }
    if( newclass == None ) newclass = p.class;
    radius = p.CollisionRadius;
    loc_offset = vect( 3, 3, 5);
    for(i=0; i<10; i++) {
        loc_offset.X = float(rng(50000))/10000.0 * Sqrt(float(enemy_multiplier));
        loc_offset.Y = float(rng(50000))/10000.0 * Sqrt(float(enemy_multiplier));
        if( rng(2) == 0 ) loc_offset.X *= -1;
        if( rng(2) == 0 ) loc_offset.Y *= -1;
        loc = p.Location + (radius*loc_offset);
        n = Spawn(newclass,,, loc );
        if( n != None ) break;
    }
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

    p.SurprisePeriod *= float(rng(100)/100)+0.4;

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
    for(i=0; i < ArrayCount(randommelees); i++ ) {
        if( randommelees[i].type == None ) continue;
        if( chance( randommelees[i].chance, r ) ) wclass = randommelees[i].type;

        if( HasItem(p, randommelees[i].type) ) {
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

function int RunTests()
{
    local int results, i, total;
    results = Super.RunTests();

    total=0;
    for(i=0; i < ArrayCount(randomenemies); i++ ) {
        total += randomenemies[i].chance;
    }
    results += test( total <= 100, "config randomenemies chances, check total "$total);
    total=0;
    for(i=0; i < ArrayCount(randomweapons); i++ ) {
        total += randomweapons[i].chance;
    }
    results += test( total <= 100, "config randomweapons chances, check total "$total);
    total=0;
    for(i=0; i < ArrayCount(randommelees); i++ ) {
        total += randommelees[i].chance;
    }
    results += test( total <= 100, "config randommelees chances, check total "$total);

    return results;
}
