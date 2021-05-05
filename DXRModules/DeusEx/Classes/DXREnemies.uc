class DXREnemies extends DXRActorsBase;

var config int enemy_multiplier;

struct RandomWeaponStruct { var string type; var int chance; };
struct _RandomWeaponStruct { var class<DeusExWeapon> type; var float chance; };
var config RandomWeaponStruct randommelees[8];
var _RandomWeaponStruct _randommelees[8];
var config RandomWeaponStruct randomweapons[32];
var _RandomWeaponStruct _randomweapons[32];

struct RandomEnemyStruct { var string type; var int chance; };
struct _RandomEnemyStruct { var class<ScriptedPawn> type; var float chance; };
var config RandomEnemyStruct randomenemies[32];
var _RandomEnemyStruct _randomenemies[32];

var config name defaultOrders;
var config float min_rate_adjust, max_rate_adjust;

function CheckConfig()
{
    local int i;
    if( config_version < class'DXRFlags'.static.VersionToInt(1,5,6) ) {
        enemy_multiplier = 1;
        min_rate_adjust = default.min_rate_adjust;
        max_rate_adjust = default.max_rate_adjust;

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

        AddRandomEnemyType("ThugMale", 14);
        AddRandomEnemyType("ThugMale2", 14);
        AddRandomEnemyType("ThugMale3", 14);
        AddRandomEnemyType("Greasel", 4);
        AddRandomEnemyType("Gray", 2);
        AddRandomEnemyType("Karkian", 2);
        AddRandomEnemyType("SpiderBot2", 2);//little spider
        AddRandomEnemyType("MilitaryBot", 2);
        AddRandomEnemyType("SpiderBot", 2);//big spider
        AddRandomEnemyType("SecurityBot2", 2);//walker
        AddRandomEnemyType("SecurityBot3", 2);//little guy from liberty island
        AddRandomEnemyType("SecurityBot4", 2);//unused little guy

        AddRandomWeapon("WeaponShuriken", 12);
        AddRandomWeapon("WeaponPistol", 10);
        AddRandomWeapon("WeaponAssaultGun", 10);
        AddRandomWeapon("WeaponMiniCrossbow", 5);
        AddRandomWeapon("WeaponGEPGun", 4);
        AddRandomWeapon("WeaponAssaultShotgun", 5);
        AddRandomWeapon("WeaponEMPGrenade", 5);
        AddRandomWeapon("WeaponFlamethrower", 4);
        AddRandomWeapon("WeaponGasGrenade", 5);
        AddRandomWeapon("WeaponHideAGun", 5);
        AddRandomWeapon("WeaponLAM", 5);
        AddRandomWeapon("WeaponLAW", 4);
        AddRandomWeapon("WeaponNanoVirusGrenade", 5);
        AddRandomWeapon("WeaponPepperGun", 4);
        AddRandomWeapon("WeaponPlasmaRifle", 5);
        AddRandomWeapon("WeaponRifle", 5);
        AddRandomWeapon("WeaponSawedOffShotgun", 5);
        AddRandomWeapon("WeaponProd", 2);

        AddRandomMelee("WeaponBaton", 25);
        AddRandomMelee("WeaponCombatKnife", 25);
        AddRandomMelee("WeaponCrowbar", 25);
        AddRandomMelee("WeaponSword", 25);

        defaultOrders = 'Wandering';
    }
    Super.CheckConfig();

    ReadConfig();
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
    //SwapScriptedPawns();
    RandoCarcasses();
}

function ReadConfig()
{
    local int i, num;
    local float total, target_total;
    local class<Actor> a;

    total=0;
    target_total=0;
    num=0;
    for(i=0; i < ArrayCount(randommelees); i++) {
        if( randommelees[i].type != "" ) {
            a = GetClassFromString(randommelees[i].type, class'DeusExWeapon');
            if( a == None ) continue;
            _randommelees[num].type = class<DeusExWeapon>(a);
            _randommelees[num].chance = rngrangeseeded(randommelees[i].chance, min_rate_adjust, max_rate_adjust, a.name);
            total += _randommelees[num].chance;
            target_total += randommelees[i].chance;
            num++;
        }
    }
    for(i=0; i < num; i++) {
        _randommelees[i].chance *= target_total / total;
        //l(_randommelees[i].type$": "$_randommelees[i].chance);
    }

    total=0;
    num=0;
    for(i=0; i < ArrayCount(randomweapons); i++) {
        if( randomweapons[i].type != "" ) {
            a = GetClassFromString(randomweapons[i].type, class'DeusExWeapon');
            if( a == None ) continue;
            _randomweapons[num].type = class<DeusExWeapon>(a);
            _randomweapons[num].chance = rngrangeseeded(randomweapons[i].chance, min_rate_adjust, max_rate_adjust, a.name);
            total += _randomweapons[num].chance;
            num++;
        }
    }
    for(i=0; i < num; i++) {
        _randomweapons[i].chance *= 100.0/total;
        //l(_randomweapons[i].type$": "$_randomweapons[i].chance);
    }

    total=0;
    num=0;
    for(i=0; i < ArrayCount(randomenemies); i++) {
        if( randomenemies[i].type != "" ) {
            a = GetClassFromString(randomenemies[i].type, class'ScriptedPawn');
            if( a == None ) continue;
            _randomenemies[num].type = class<ScriptedPawn>(a);
            _randomenemies[num].chance = rngrangeseeded(randomenemies[i].chance, min_rate_adjust, max_rate_adjust, a.name);
            total += _randomenemies[num].chance;
            num++;
        }
    }
    for(i=0; i < num; i++) {
        _randomenemies[i].chance *= 100.0/total;
        //l(_randomenemies[i].type$": "$_randomenemies[i].chance);
    }
}

function AddDXRCredits(CreditsWindow cw) 
{
    local int i;

    cw.PrintHeader( dxr.flags.enemiesrandomized $ "% Added Enemies");
    for(i=0; i < ArrayCount(_randomenemies); i++) {
        if( _randomenemies[i].type == None ) continue;
        cw.PrintText(_randomenemies[i].type.default.FamiliarName $ ": " $ FloatToString(_randomenemies[i].chance, 1) $ "%" );
    }
    cw.PrintLn();

    cw.PrintHeader("Extra Weapons For Enemies");
    for(i=0; i < ArrayCount(_randomweapons); i++) {
        if( _randomweapons[i].type == None ) continue;
        cw.PrintText( _randomweapons[i].type.default.ItemName $ ": " $ FloatToString(_randomweapons[i].chance, 1) $ "%" );
    }
    cw.PrintLn();

    cw.PrintHeader("Melee Weapons For Enemies");
    for(i=0; i < ArrayCount(_randommelees); i++) {
        if( _randommelees[i].type == None ) continue;
        cw.PrintText( _randommelees[i].type.default.ItemName $ ": " $ FloatToString(_randommelees[i].chance, 1) $ "%" );
    }
    cw.PrintLn();
}

function _RandomWeaponStruct GetWeaponConfig(int i)
{
    if( i < ArrayCount(_randomweapons) )
        return _randomweapons[i];
}

function RandoCarcasses()
{
    local DeusExCarcass c;
    local Inventory item, nextItem;

    SetSeed( "RandoCarcasses" );

    foreach AllActors(class'DeusExCarcass', c) {
        item = c.Inventory;
        while( item != None ) {
            nextItem = item.Inventory;
            if( chance_single(50) && !item.IsA('NanoKey') ) {
                c.DeleteInventory(item);
                item.Destroy();
            }
            item = nextItem;
        }
    }
}

function SwapScriptedPawns()
{
    local ScriptedPawn temp[512];
    local ScriptedPawn a;
    local int num, i, slot;

    SetSeed( "SwapScriptedPawns" );
    num=0;
    foreach AllActors(class'ScriptedPawn', a )
    {
        if( a.bHidden || a.bStatic ) continue;
        if( a.bImportant ) continue;
        if( IsCritter(a) ) continue;
        temp[num++] = a;
    }

    l("SwapScriptedPawns num: "$num);
    for(i=0; i<num; i++) {
        slot=rng(num);// -1 because we skip ourself, but +1 for vanilla
        if(slot==0) {
            l("not swapping "$ActorToString(temp[i]));
            continue;
        }
        slot--;
        if(slot >= i) slot++;
        l("SwapScriptedPawns swapping "$i@ActorToString(temp[i])$" with "$slot@ActorToString(temp[slot]));
        Swap(temp[i], temp[slot]);
    }
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
        if( p.bImportant || p.bInvincible ) continue;
        if( IsCritter(p) ) continue;
        if( SkipActor(p, 'ScriptedPawn') ) continue;
        //if( IsInitialEnemy(p) == False ) continue;

        if( HasItemSubclass(p, class'Weapon') == false ) continue;//don't randomize neutral npcs that don't already have weapons
        if( chance_single(percent) ) RandomizeSP(p, percent);

        if( chance_single(percent) == false ) continue;

        for(i = rng(enemy_multiplier*100+percent)/100; i >= 0; i--) {
            n = RandomEnemy(p, percent);
            if( newsp == None ) newsp = n;
        }
    }
}

function ScriptedPawn RandomEnemy(ScriptedPawn base, int percent)
{
    local class<ScriptedPawn> newclass;
    local ScriptedPawn n;
    local int i;
    local float r;
    r = initchance();
    for(i=0; i < ArrayCount(_randomenemies); i++ ) {
        if( _randomenemies[i].type == None ) break;
        if( chance( _randomenemies[i].chance, r ) ) newclass = _randomenemies[i].type;
    }

    chance_remaining(r);// else keep the same class

    if( chance_single(dxr.flags.enemies_nonhumans)==False && newclass == None && IsHuman(base) == False ) return None;

    n = CloneScriptedPawn(base, newclass);
    l("new RandomEnemy("$base$", "$percent$") == "$n);
    if( n != None ) RandomizeSP(n, percent);
    //else RandomizeSize(n);
    return n;
}

function bool IsInitialEnemy(ScriptedPawn p)
{
    local int i;

    return p.GetPawnAllianceType(player()) == ALLIANCE_Hostile;
}

function ScriptedPawn CloneScriptedPawn(ScriptedPawn p, optional class<ScriptedPawn> newclass)
{
    local int i;
    local ScriptedPawn n;
    local float radius;
    local vector loc, loc_offset;
    local Inventory inv;
    local NanoKey k1, k2;
    local name newtag;

    if( p == None ) {
        l("p == None?");
        return None;
    }
    if( newclass == None ) newclass = p.class;
    newtag = StringToName(p.Tag $ "_clone");
    radius = p.CollisionRadius + newclass.default.CollisionRadius;
    for(i=0; i<10; i++) {
        loc_offset.X = 1 + rngf() * 3 * Sqrt(float(enemy_multiplier+1));
        loc_offset.Y = 1 + rngf() * 3 * Sqrt(float(enemy_multiplier+1));
        if( chance_single(50) ) loc_offset *= -1;
        loc = p.Location + (radius*loc_offset);
        if( class'DXRMissions'.static.IsCloseToStart(dxr, loc) ) {
            info("CloneScriptedPawn "$loc$" is too close to start!");
            continue;
        }
        n = Spawn(newclass,, newtag, loc );
        if( n != None ) break;
    }
    if( n == None ) {
        l("failed to clone "$ActorToString(p)$" into class "$newclass$" into "$loc);
        return None;
    }
    l("cloning "$ActorToString(p)$" into class "$newclass$" got "$ActorToString(n));

    if( IsHuman(p) && IsHuman(n) && p.BarkBindName != "" && n.BarkBindName == "" ) n.BarkBindName = p.BarkBindName;
    class'DXRNames'.static.GiveRandomName(dxr, n);
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

    n.bHateCarcass = p.bHateCarcass;
    n.bHateDistress = p.bHateDistress;
    n.bHateHacking = p.bHateHacking;
    n.bHateIndirectInjury = p.bHateIndirectInjury;
    n.bHateInjury = p.bHateInjury;
    n.bHateShot = p.bHateShot;
    n.bHateWeapon = p.bHateWeapon;
    n.bFearCarcass = p.bFearCarcass;
    n.bFearDistress = p.bFearDistress;
    n.bFearHacking = p.bFearHacking;
    n.bFearIndirectInjury = p.bFearIndirectInjury;
    n.bFearInjury = p.bFearInjury;
    n.bFearShot = p.bFearShot;
    n.bFearWeapon = p.bFearWeapon;
    n.bFearAlarm = p.bFearAlarm;
    n.bFearProjectiles = p.bFearProjectiles;

    n.bReactFutz = p.bReactFutz;
    n.bReactPresence = p.bReactPresence;
    n.bReactLoudNoise = p.bReactLoudNoise;
    n.bReactAlarm = p.bReactAlarm;
    n.bReactShot = p.bReactShot;
    n.bReactCarcass = p.bReactCarcass;
    n.bReactDistress = p.bReactDistress;
    n.bReactProjectiles = p.bReactProjectiles;

    n.Orders = defaultOrders;
    n.HomeTag = 'Start';
    n.InitializeAlliances();

    RandomizeSize(n);

    return n;
}

function RandomizeSP(ScriptedPawn p, int percent)
{
    if( p == None ) return;

    l("RandomizeSP("$p$", "$percent$")");
    p.SurprisePeriod = rngrange(p.SurprisePeriod+0.1, 0.3, 1.2);

    if( IsHuman(p) == False ) return; // only give random weapons to humans
    if( p.IsA('MJ12Commando') || p.IsA('WIB') ) return;

    GiveRandomWeapon(p, false, 2);
    GiveRandomMeleeWeapon(p);
    p.SetupWeapon(false);
}

function GiveRandomWeapon(Pawn p, optional bool allow_dupes, optional int add_ammo)
{
    local class<DeusExWeapon> wclass;
    local Ammo a;
    local int i;
    local float r;
    r = initchance();
    for(i=0; i < ArrayCount(_randomweapons); i++ ) {
        if( _randomweapons[i].type == None ) break;
        if( chance( _randomweapons[i].chance, r ) ) wclass = _randomweapons[i].type;
    }
    chance_remaining(r);

    if( (!allow_dupes) && HasItem(p, wclass) )
        return;

    if( wclass == None ) {
        l("not giving a random weapon to "$p); return;
    }

    GiveItem( p, wclass, add_ammo );
}

function GiveRandomMeleeWeapon(Pawn p, optional bool allow_dupes)
{
    local class<Weapon> wclass;
    local int i;
    local float r;

    if( (!allow_dupes) && HasMeleeWeapon(p))
        return;

    r = initchance();
    for(i=0; i < ArrayCount(_randommelees); i++ ) {
        if( _randommelees[i].type == None ) break;
        if( chance( _randommelees[i].chance, r ) ) wclass = _randommelees[i].type;

        if( (!allow_dupes) && HasItem(p, _randommelees[i].type) ) {
            chance_remaining(r);
            return;
        }
    }

    GiveItem(p, wclass);
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

    SetActorScale(a, rngrange(1, 0.9, 1.1));
    a.Fatness = rng(20) + 120;

    if( carried != None ) {
        p.carriedDecoration = carried;
        p.PutCarriedDecorationInHand();
    }
}

function RunTests()
{
    local int i, total;
    Super.RunTests();

    total=0;
    for(i=0; i < ArrayCount(randomenemies); i++ ) {
        total += randomenemies[i].chance;
    }
    test( total <= 100, "config randomenemies chances, check total "$total);
    total=0;
    for(i=0; i < ArrayCount(randomweapons); i++ ) {
        total += randomweapons[i].chance;
    }
    testint( total, 100, "config randomweapons chances, check total "$total);
    total=0;
    for(i=0; i < ArrayCount(randommelees); i++ ) {
        total += randommelees[i].chance;
    }
    testint( total, 100, "config randommelees chances, check total "$total);
}

defaultproperties
{
    min_rate_adjust=0.5
    max_rate_adjust=1.5
}
