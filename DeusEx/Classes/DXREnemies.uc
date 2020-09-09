class DXREnemies extends DXRActorsBase;

var config int chance_clone_nonhumans;
var config int enemy_multiplier;

struct RandomWeaponStruct { var string type; var int chance; };
struct _RandomWeaponStruct { var class<DeusExWeapon> type; var int chance; };
var config RandomWeaponStruct randommelees[8];
var _RandomWeaponStruct _randommelees[8];
var config RandomWeaponStruct randomweapons[32];
var _RandomWeaponStruct _randomweapons[32];

struct RandomEnemyStruct { var string type; var int chance; };
struct _RandomEnemyStruct { var class<ScriptedPawn> type; var int chance; };
var config RandomEnemyStruct randomenemies[32];
var _RandomEnemyStruct _randomenemies[32];

var config name defaultOrders;

function CheckConfig()
{
    local int i;
    local class<Actor> a;
    if( config_version == 0 ) {
        chance_clone_nonhumans = 70;
        enemy_multiplier = 1;

        for(i=0; i < ArrayCount(randommelees); i++ ) {
            randommelees[i].type = "";
            randommelees[i].chance = 0;
        }
        for(i=0; i < ArrayCount(randomenemies); i++ ) {
            randomweapons[i].type = "";
            randomweapons[i].chance = 0;
            randomenemies[i].type = "";
            randomenemies[i].chance = 0;
        }

        AddRandomEnemyType("ThugMale", 10);
        AddRandomEnemyType("ThugMale2", 10);
        AddRandomEnemyType("ThugMale3", 10);
        AddRandomEnemyType("Greasel", 6);
        AddRandomEnemyType("Gray", 3);
        AddRandomEnemyType("Karkian", 3);
        AddRandomEnemyType("SpiderBot", 6);
        AddRandomEnemyType("MilitaryBot", 3);
        AddRandomEnemyType("SpiderBot2", 3);
        AddRandomEnemyType("SecurityBot2", 3);
        AddRandomEnemyType("SecurityBot3", 3);
        AddRandomEnemyType("SecurityBot4", 3);

        AddRandomWeapon("WeaponPistol", 11);
        AddRandomWeapon("WeaponAssaultGun", 11);
        AddRandomWeapon("WeaponMiniCrossbow", 11);
        AddRandomWeapon("WeaponGEPGun", 4);
        AddRandomWeapon("WeaponAssaultShotgun", 5);
        AddRandomWeapon("WeaponEMPGrenade", 5);
        AddRandomWeapon("WeaponFlamethrower", 4);
        AddRandomWeapon("WeaponGasGrenade", 5);
        AddRandomWeapon("WeaponHideAGun", 5);
        AddRandomWeapon("WeaponLAM", 5);
        AddRandomWeapon("WeaponLAW", 4);
        AddRandomWeapon("WeaponNanoVirusGrenade", 5);
        AddRandomWeapon("WeaponPepperGun", 5);
        AddRandomWeapon("WeaponPlasmaRifle", 5);
        AddRandomWeapon("WeaponRifle", 5);
        AddRandomWeapon("WeaponSawedOffShotgun", 5);
        AddRandomWeapon("WeaponShuriken", 5);

        AddRandomMelee("WeaponBaton", 25);
        AddRandomMelee("WeaponCombatKnife", 25);
        AddRandomMelee("WeaponCrowbar", 25);
        AddRandomMelee("WeaponSword", 25);

        defaultOrders = 'Wandering';
    }
    Super.CheckConfig();

    for(i=0; i < ArrayCount(randommelees); i++) {
        if( randommelees[i].type != "" ) {
            a = GetClassFromString(randommelees[i].type, class'DeusExWeapon');
            _randommelees[i].type = class<DeusExWeapon>(a);
            _randommelees[i].chance = randommelees[i].chance;
        }
    }
    for(i=0; i < ArrayCount(randomweapons); i++) {
        if( randomweapons[i].type != "" ) {
            a = GetClassFromString(randomweapons[i].type, class'DeusExWeapon');
            _randomweapons[i].type = class<DeusExWeapon>(a);
            _randomweapons[i].chance = randomweapons[i].chance;
        }
    }
    for(i=0; i < ArrayCount(randomenemies); i++) {
        if( randomenemies[i].type != "" ) {
            a = GetClassFromString(randomenemies[i].type, class'ScriptedPawn');
            _randomenemies[i].type = class<ScriptedPawn>(a);
            _randomenemies[i].chance = randomenemies[i].chance;
        }
    }
}

function AddRandomWeapon(string t, int c)
{
    local int i;
    for(i=0; i < ArrayCount(randomweapons); i++) {
        if( randomweapons[i].type == "" ) {
            randomweapons[i].type = t;
            randomweapons[i].chance = c;
            return;
        }
    }
}

function AddRandomMelee(string t, int c)
{
    local int i;
    for(i=0; i < ArrayCount(randommelees); i++) {
        if( randommelees[i].type == "" ) {
            randommelees[i].type = t;
            randommelees[i].chance = c;
            return;
        }
    }
}

function AddRandomEnemyType(string t, int c)
{
    local int i;
    for(i=0; i < ArrayCount(randomenemies); i++) {
        if( randomenemies[i].type == "" ) {
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
    for(i=0; i < ArrayCount(_randomenemies); i++ ) {
        if( chance( _randomenemies[i].chance, r ) ) newclass = _randomenemies[i].type;
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
    n.InitializeInventory();

    RandomizeSize(n);

    return n;
}

function RandomizeSP(ScriptedPawn p, int percent)
{
    if( p == None ) return;

    p.SurprisePeriod *= float(rng(100)/100)+0.4;

    if( IsHuman(p) == False ) return; // only give random weapons to humans
    if( p.IsA('MJ12Commando') ) return;

    GiveRandomWeapon(p);
    GiveRandomMeleeWeapon(p);
    p.SetupWeapon(false);
}

function GiveRandomWeapon(Pawn p)
{
    local class<DeusExWeapon> wclass;
    local Ammo a;
    local DeusExWeapon w;
    local int r, i;
    r = initchance();
    for(i=0; i < ArrayCount(_randomweapons); i++ ) {
        if( chance( _randomweapons[i].chance, r ) ) wclass = _randomweapons[i].type;
    }

    if( HasItem(p, wclass) )
        return;

    w = Spawn(wclass, p);
    w.GiveTo(p);
    w.SetBase(p);

    if( w.AmmoName != None ) {
        a = spawn(w.AmmoName);
        w.AmmoType = a;
        w.AmmoType.InitialState='Idle2';
        w.AmmoType.GiveTo(p);
        w.AmmoType.SetBase(p);
    }

    for(i=0; i < ArrayCount(w.AmmoNames); i++) {
        if(rng(3) == 0 && w.AmmoNames[i] != None) {
            a = spawn(w.AmmoNames[i]);
            a.GiveTo(p);
            a.SetBase(p);
        }
    }
}

function GiveRandomMeleeWeapon(Pawn p)
{
    local class<Weapon> wclass;
    local Weapon w;
    local int r, i;

    if
    (
        ( HasItem(p, class'WeaponBaton')
        || HasItem(p, class'WeaponCombatKnife')
        || HasItem(p, class'WeaponCrowbar')
        || HasItem(p, class'WeaponSword')
        || HasItem(p, class'WeaponNanoSword')
        )
    )
        return;

    r = initchance();
    for(i=0; i < ArrayCount(_randommelees); i++ ) {
        if( _randommelees[i].type == None ) continue;
        if( chance( _randommelees[i].chance, r ) ) wclass = _randommelees[i].type;

        if( HasItem(p, _randommelees[i].type) ) {
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
