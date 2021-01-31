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
    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,6) ) {
        chance_clone_nonhumans = 60;
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

        AddRandomEnemyType("ThugMale", 14);
        AddRandomEnemyType("ThugMale2", 14);
        AddRandomEnemyType("ThugMale3", 14);
        AddRandomEnemyType("Greasel", 5);
        AddRandomEnemyType("Gray", 2);
        AddRandomEnemyType("Karkian", 2);
        AddRandomEnemyType("SpiderBot2", 2);//little spider
        AddRandomEnemyType("MilitaryBot", 2);
        AddRandomEnemyType("SpiderBot", 2);//big spider
        AddRandomEnemyType("SecurityBot2", 2);//walker
        AddRandomEnemyType("SecurityBot3", 2);//little guy from liberty island
        AddRandomEnemyType("SecurityBot4", 2);//unused little guy

        AddRandomWeapon("WeaponPistol", 11);
        AddRandomWeapon("WeaponAssaultGun", 11);
        AddRandomWeapon("WeaponMiniCrossbow", 10);
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
        AddRandomWeapon("WeaponShuriken", 5);
        AddRandomWeapon("WeaponProd", 2);

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
    RandoMedBotsRepairBots(dxr.flags.medbots, dxr.flags.repairbots);
    RandoEnemies(dxr.flags.enemiesrandomized);
    RandoTurrets(dxr.flags.turrets_move, dxr.flags.turrets_add);
    //SwapScriptedPawns();
}

function RandoTurrets(int percent_move, int percent_add)
{
    local AutoTurret t;
    local SecurityCamera cam;
    local ComputerSecurity c;
    local int i, hostile_turrets;
    local vector loc;

    SetSeed( "RandoTurrets move" );

    foreach AllActors(class'AutoTurret', t) {
        if( chance_single(percent_move) == false ) continue;

        loc = GetRandomPosition(t.Location, 0, 16*200);
        info("RandoTurret move "$t$" to near "$loc);
        MoveTurret(t, loc);
        cam = GetCameraForTurret(t);
        if( cam != None ) MoveCamera(cam, loc);
        if( t.bTrackPlayersOnly==true || t.bTrackPawnsOnly==false ) hostile_turrets++;
    }

    if( hostile_turrets == 0 ) return;

    SetSeed( "RandoTurrets add" );

    for(i=0; i <3 ; i++) {//need to randomize hack strengths on these
        if( chance_single(percent_add/3) == false ) continue;

        loc = GetRandomPosition();
        info("RandoTurret near "$loc);
        t = SpawnTurret(loc);
        cam = SpawnCamera(loc);
        c = SpawnSecurityComputer(loc, t, cam);
        loc = GetRandomPosition(loc, 16, 16*100);
        SpawnDatacube(loc, c);
    }
}

function GetTurretLocation(out vector loc, out rotator rotation)
{
    loc = JitterPosition(loc);
    NearestFloor(loc, 16*50, rotation);
    NearestCeiling(loc, 16*50, rotation);
    rotation.pitch -= 16384;
}

function MoveTurret(AutoTurret t, vector loc)
{
    local rotator rotation;
    local Vector v1, v2;
    local Rotator rot;

    GetTurretLocation(loc, rotation);

    t.SetLocation(loc);
    t.SetRotation(rotation);

    //to move AutoTurretGun, copied from AutoTurret.uc PreBeginPlay()
    rot = t.Rotation;
    rot.Pitch = 0;
    rot.Roll = 0;
    t.origRot = rot;
    v1.X = 0;
    v1.Y = 0;
    v1.Z = t.CollisionHeight + t.gun.Default.CollisionHeight;
    v2 = v1 >> t.Rotation;
    v2 += t.Location;
    t.gun.SetLocation(v2);
    t.gun.SetBase(t);
}

function AutoTurret SpawnTurret(vector loc)
{
    local AutoTurret t;
    local rotator rotation;

    GetTurretLocation(loc, rotation);

    t = Spawn(class'AutoTurret',,, loc, rotation);
    if( t == None ) {
        warning("SpawnTurret failed at "$loc);
        return None;
    }
    t.Tag = t.Name;
    t.bActive = false;
    t.bTrackPawnsOnly = false;
    t.bTrackPlayersOnly = true;
    info("SpawnTurret "$t$" done at ("$loc$"), ("$rotation$")");
    return t;
}

function SecurityCamera GetCameraForTurret(AutoTurret t)
{
    local ComputerSecurity comp;
    local SecurityCamera cam;
    local int i;

    foreach AllActors(class'ComputerSecurity',comp)
    {
        for (i = 0; i < ArrayCount(comp.Views); i++)
        {
            if (comp.Views[i].turretTag == t.Tag)
            {
                foreach AllActors(class'SecurityCamera', cam, comp.Views[i].cameraTag) {
                    return cam;
                }
            }
        }
    }
    warning("GetCameraForTurret failed to find camera for turret "$t);
    return None;
}

function GetCameraLocation(out vector loc, out rotator rotation)
{
    local bool found_ceiling;
    local bool found_wall1;
    local bool found_wall2;

    loc = JitterPosition(loc);
    NearestFloor(loc, 16*50, rotation, 16);
    found_ceiling = NearestCeiling(loc, 16*50, rotation, 16);
    found_wall1 = NearestWall(loc, 16*75, rotation, 10);
    found_wall2 = NearestWall(loc, 16*75, rotation, 10, 16);
    if( found_ceiling ) rotation.pitch -= 3568;
}

function MoveCamera(SecurityCamera c, vector loc)
{
    local rotator rotation;
    
    GetCameraLocation(loc, rotation);

    c.SetLocation(loc);
    c.SetRotation(rotation);
}

function SecurityCamera SpawnCamera(vector loc)
{
    local SecurityCamera c;
    local rotator rotation;
    
    GetCameraLocation(loc, rotation);

    c = Spawn(class'SecurityCamera',,, loc, rotation);
    if( c == None ) {
        warning("SpawnCamera failed at "$loc);
        return None;
    }
    
    c.Tag = c.Name;
    c.bSwing = true;
    c.bNoAlarm = false;//true means friendly
    info("SpawnCamera "$c$" done at ("$loc$"), ("$rotation$")");
    return c;
}

function ComputerSecurity SpawnSecurityComputer(vector loc, optional AutoTurret t, optional SecurityCamera cam)
{
    local ComputerSecurity c;
    local vector v;
    local rotator rotation;
    local int i;
    info("SpawnSecurityComputer near "$loc);

    loc = JitterPosition(loc);
    NearestFloor(loc, 16*50, rotation, 16*4);
    NearestWallSearchZ(loc, 16*75, rotation, 16*3, 2);

    c = Spawn(class'ComputerSecurity',,, loc, rotation);
    if( c == None ) {
        warning("SpawnSecurityComputer failed at "$loc);
        return None;
    }
    c.Views[0].CameraTag = cam.Tag;
    c.Views[0].TurretTag = t.Tag;
    c.UserList[0].userName = String(c.Name);
    c.UserList[0].Password = class'DXRPasswords'.static.GeneratePassword(dxr, String(c.Name) );
    info("SpawnSecurityComputer "$c$" done at ("$loc$"), ("$rotation$") with password: "$c.UserList[0].Password );
    return c;
}

function Datacube SpawnDatacube(vector loc, ComputerSecurity c)
{
    local Datacube d;
    local rotator rotation;

    loc = JitterPosition(loc);
    NearestFloor(loc, 16*50, rotation);

    d = Spawn(class'Datacube',,, loc, rotation);
    if( d == None ) {
        warning("SpawnDatacube failed at "$loc);
        return None;
    }
    d.plaintext = c.Name $ " password is " $ c.UserList[0].Password;
    info("SpawnDatacube "$d$" done at ("$loc$"), ("$rotation$")");
    return d;
}

function RandoMedBotsRepairBots(int medbots, int repairbots)
{
    local RepairBot r;
    local MedicalBot m;
    local Datacube d;

    if( medbots > -1 ) {
        foreach AllActors(class'MedicalBot', m) {
            m.Destroy();
        }
        foreach AllActors(class'Datacube', d) {
            if( d.textTag == '01_Datacube09' ) d.Destroy();
        }
    }
    if( repairbots > -1 ) {
        foreach AllActors(class'RepairBot', r) {
            r.Destroy();
        }
        foreach AllActors(class'Datacube', d) {
            if( d.textTag == '03_Datacube11' ) d.Destroy();
        }
    }

    SetSeed( "RandoMedBots" );
    if( chance_single(medbots) ) {
        m = MedicalBot(SpawnNewActor(class'MedicalBot'));
        d = Datacube(SpawnNewActor(class'Datacube', m.Location, 16*50, 16*200));//minimum 50 feet away, maximum 200 feet away
        d.textTag = '01_Datacube09';
        d.bAddToVault = false;
    }

    SetSeed( "RandoRepairBots" );
    if( chance_single(repairbots) ) {
        r = RepairBot(SpawnNewActor(class'RepairBot'));
        d = Datacube(SpawnNewActor(class'Datacube', m.Location, 16*50, 16*200));
        d.textTag = '03_Datacube11';
        d.bAddToVault = false;
    }
}

function Actor SpawnNewActor(class<Actor> c, optional vector target, optional float mindist, optional float maxdist)
{
    local Actor a;
    local vector loc;
    loc = GetRandomPositionFine(target, mindist, maxdist);
    a = Spawn(c,,, loc );
    if( a == None ) warning("SpawnNewActor "$c$" failed at "$loc);
    return a;
}

function SwapScriptedPawns()
{
    local ScriptedPawn a, b;
    local int num, i, slot;

    SetSeed( "SwapScriptedPawns" );
    num=0;
    foreach AllActors(class'ScriptedPawn', a )
    {
        if( a.bHidden || a.bStatic ) continue;
        if( a.bImportant ) continue;
        if( IsCritter(a) ) continue;
        num++;
    }

    foreach AllActors(class'ScriptedPawn', a )
    {
        if( a.bHidden || a.bStatic ) continue;
        if( a.bImportant ) continue;
        if( IsCritter(a) ) continue;

        i=0;
        slot=rng(num);// -1 because we skip ourself, but +1 for vanilla
        if(slot==0) {
            l("not swapping "$a);
            continue;
        }
        slot--;
        foreach AllActors(class'ScriptedPawn', b )
        {
            if( a == b ) continue;
            if( b.bHidden || b.bStatic ) continue;
            if( b.bImportant ) continue;
            if( IsCritter(b) ) continue;

            if(i==slot) {
                a.Orders = defaultOrders;
                b.Orders = defaultOrders;
                Swap(a, b);
                break;
            }
            i++;
        }
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

        if( rng(100) < percent ) RandomizeSP(p, percent);

        if( rng(100) >= percent ) continue;

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
    local int r, i;
    r = initchance();
    for(i=0; i < ArrayCount(_randomenemies); i++ ) {
        if( chance( _randomenemies[i].chance, r ) ) newclass = _randomenemies[i].type;
    }

    chance_remaining(r);// else keep the same class

    if( chance_single(chance_clone_nonhumans)==False && newclass == None && IsHuman(base) == False ) return None;

    n = CloneScriptedPawn(base, newclass);
    l("new RandomEnemy("$base$", "$percent$") == "$n);
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
        loc_offset.X = rngfn() * 5 * Sqrt(float(enemy_multiplier));
        loc_offset.Y = rngfn() * 5 * Sqrt(float(enemy_multiplier));
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
    n.InitializeAlliances();

    RandomizeSize(n);

    return n;
}

function RandomizeSP(ScriptedPawn p, int percent)
{
    if( p == None ) return;

    l("RandomizeSP("$p$", "$percent$")");
    p.SurprisePeriod *= float(rng(100)/100)+0.4;

    if( IsHuman(p) == False ) return; // only give random weapons to humans
    if( p.IsA('MJ12Commando') || p.IsA('WIB') ) return;

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
    chance_remaining(r);

    if( HasItem(p, wclass) )
        return;

    if( wclass == None ) {
        l("not giving a random weapon to "$p); return;
    }

    w = Spawn(wclass, p);
    l("GiveRandomWeapon("$p$") "$wclass$", "$w);
    w.GiveTo(p);
    w.SetBase(p);

    if( w.AmmoName != None ) {
        a = spawn(w.AmmoName);
        l("GiveRandomWeapon("$p$") ammo "$a);
        w.AmmoType = a;
        w.AmmoType.InitialState='Idle2';
        w.AmmoType.GiveTo(p);
        w.AmmoType.SetBase(p);
    }

    for(i=0; i < ArrayCount(w.AmmoNames); i++) {
        if(rng(3) == 0 && w.AmmoNames[i] != None) {
            a = spawn(w.AmmoNames[i]);
            l("GiveRandomWeapon("$p$") alt ammo "$a);
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

    if(HasMeleeWeapon(p))
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
    l("GiveRandomMeleeWeapon("$p$") "$w);
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
    results += testint( total, 100, "config randomweapons chances, check total "$total);
    total=0;
    for(i=0; i < ArrayCount(randommelees); i++ ) {
        total += randommelees[i].chance;
    }
    results += testint( total, 100, "config randommelees chances, check total "$total);

    return results;
}
