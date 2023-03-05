class DXREnemies extends DXRActorsBase;

var config int enemy_multiplier;

struct RandomWeaponStruct { var string type; var int chance; };
struct _RandomWeaponStruct { var class<DeusExWeapon> type; var float chance; };
var config RandomWeaponStruct randommelees[8];
var _RandomWeaponStruct _randommelees[8];
var config RandomWeaponStruct randomweapons[32];
var _RandomWeaponStruct _randomweapons[32];
var config RandomWeaponStruct randombotweapons[32];
var _RandomWeaponStruct _randombotweapons[32];

struct RandomEnemyStruct { var string type; var int chance; };
struct _RandomEnemyStruct { var class<ScriptedPawn> type; var float chance; };
var config RandomEnemyStruct randomenemies[32];
var _RandomEnemyStruct _randomenemies[32];

var config name defaultOrders;
var config float min_rate_adjust, max_rate_adjust;

struct WatchEnterWorld {
    var ScriptedPawn watch, target;
};

// for hidden/not in world pawns
var WatchEnterWorld watches[100];
var int num_watches;

replication
{
    reliable if( Role == ROLE_Authority )
        _randommelees, _randomweapons, _randombotweapons;
}

function CheckConfig()
{
    local int i;
    if( ConfigOlderThan(2,2,5,1) ) {
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
        AddRandomWeapon("WeaponPistol", 5);
        AddRandomWeapon("WeaponStealthPistol", 4);
        AddRandomWeapon("WeaponAssaultGun", 10);
        AddRandomWeapon("WeaponMiniCrossbow", 5);
#ifdef gmdx
        AddRandomWeapon("#var(package).GMDXGepGun", 4);
#else
        AddRandomWeapon("WeaponGEPGun", 4);
#endif
        AddRandomWeapon("WeaponAssaultShotgun", 5);
        AddRandomWeapon("WeaponEMPGrenade", 5);
        AddRandomWeapon("WeaponFlamethrower", 4);
        AddRandomWeapon("WeaponGasGrenade", 5);
        AddRandomWeapon("WeaponHideAGun", 3);
        AddRandomWeapon("WeaponLAM", 5);
        AddRandomWeapon("WeaponLAW", 4);
        AddRandomWeapon("WeaponNanoVirusGrenade", 5);
        AddRandomWeapon("WeaponPepperGun", 4);
        AddRandomWeapon("WeaponPlasmaRifle", 7);
        AddRandomWeapon("WeaponRifle", 5);
        AddRandomWeapon("WeaponSawedOffShotgun", 6);
        AddRandomWeapon("WeaponProd", 2);

        AddRandomMelee("WeaponBaton", 15);
        AddRandomMelee("WeaponCombatKnife", 65);
        AddRandomMelee("WeaponCrowbar", 15);
        AddRandomMelee("WeaponSword", 5);

        AddRandomBotWeapon("WeaponRobotMachinegun", 60);
        AddRandomBotWeapon("WeaponRobotRocket", 10);
        AddRandomBotWeapon("WeaponMJ12Rocket", 10);
        AddRandomBotWeapon("WeaponSpiderBot", 5);
        AddRandomBotWeapon("WeaponSpiderBot2", 5);
        AddRandomBotWeapon("WeaponFlamethrower", 5);
        AddRandomBotWeapon("WeaponPlasmaRifle", 5);
        //AddRandomBotWeapon("WeaponGraySpit", 5);  //Gray Spit doesn't seem to work immediately


        defaultOrders = 'Wandering';
    }
    Super.CheckConfig();

    ReadConfig();
}

function AddRandomBotWeapon(string t, int c)
{
    local int i;
    for(i=0; i < ArrayCount(randombotweapons); i++) {
        if( randombotweapons[i].type == "" ) {
            randombotweapons[i].type = t;
            randombotweapons[i].chance = c;
            return;
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
    SwapScriptedPawns(dxr.flags.settings.enemiesshuffled, true);
    RandoEnemies(dxr.flags.settings.enemiesrandomized, dxr.flags.settings.hiddenenemiesrandomized);
    RandoCarcasses(dxr.flags.settings.swapitems);
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
    for(i=0; i < ArrayCount(randombotweapons); i++) {
        if( randombotweapons[i].type != "" ) {
            a = GetClassFromString(randombotweapons[i].type, class'DeusExWeapon');
            if( a == None ) continue;
            _randombotweapons[num].type = class<DeusExWeapon>(a);
            _randombotweapons[num].chance = rngrangeseeded(randombotweapons[i].chance, min_rate_adjust, max_rate_adjust, a.name);
            total += _randombotweapons[num].chance;
            num++;
        }
    }
    for(i=0; i < num; i++) {
        _randombotweapons[i].chance *= 100.0/total;
        //l(_randombotweapons[i].type$": "$randombotweapons[i].chance);
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
    local string weaponName;

    cw.PrintHeader( dxr.flags.settings.enemiesrandomized $ "% Added Enemies");
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

    if(dxr.flags.settings.bot_weapons!=0) {
        cw.PrintHeader("Extra Weapons For Robots");
        for(i=0; i < ArrayCount(_randombotweapons); i++) {
            if( _randombotweapons[i].type == None ) continue;
            weaponName = _randombotweapons[i].type.default.ItemName;
            if (InStr(weaponName,"DEFAULT WEAPON NAME")!=-1){  //Many NPC weapons don't have proper names set
                weaponName = String(_randombotweapons[i].type.default.Class);
            }
            cw.PrintText( weaponName $ ": " $ FloatToString(_randombotweapons[i].chance, 1) $ "%" );
        }
        cw.PrintLn();
    }
}

function _RandomWeaponStruct GetWeaponConfig(int i)
{
    if( i < ArrayCount(_randomweapons) )
        return _randomweapons[i];
}

function RandoCarcasses(int chance)
{
    local DeusExCarcass c;
    local Inventory item, nextItem;

    SetSeed( "RandoCarcasses" );

    foreach AllActors(class'DeusExCarcass', c) {
        if( ! chance_single(chance) ) continue;

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

function SwapItems(Pawn a, Pawn b)
{
    local Inventory item, newa[64], newb[64];
    local int i, numa, numb;

    for(item=a.Inventory; item != None; item=item.Inventory) {
        if(Weapon(item) == None && Ammo(item) == None) {
            if(item.Owner == a)
                a.DeleteInventory(item);
            newb[numb++] = item;
        }
    }
    for(item=b.Inventory; item != None; item=item.Inventory) {
        if(Weapon(item) == None && Ammo(item) == None) {
            if(item.Owner == b)
                b.DeleteInventory(item);
            newa[numa++] = item;
        }
    }

    for(i=0; i<numa; i++) {
        item = GiveExistingItem(a, newa[i]);
        if(Robot(a) != None)
            ThrowItem(item, 0.1);
    }
    for(i=0; i<numb; i++) {
        item = GiveExistingItem(b, newb[i]);
        if(Robot(b) != None)
            ThrowItem(item, 0.1);
    }
}

function SwapScriptedPawns(int percent, bool enemies)
{
    local ScriptedPawn temp[512];
    local ScriptedPawn a;
    local name exceptTag;
    local int num, i, slot;

    SetSeed( "SwapScriptedPawns" );
    num=0;
    if(dxr.localURL ~= "14_OCEANLAB_SILO") {
        exceptTag = 'Doberman';
    }
    foreach AllActors(class'ScriptedPawn', a )
    {
        if( a.bHidden || a.bStatic ) continue;
        if( a.bImportant ) continue;
        if( IsCritter(a) ) continue;
        if( IsInitialEnemy(a) != enemies ) continue;
        if( !chance_single(percent) ) continue;
        if( a.Region.Zone.bWaterZone || a.Region.Zone.bPainZone ) continue;
        if( exceptTag != '' && a.Tag == exceptTag ) continue;
        if( class'DXRMissions'.static.IsCloseToStart(dxr, a.Location) ) continue;
#ifdef gmdx
        if( SpiderBot2(a) != None && SpiderBot2(a).bUpsideDown ) continue;
#endif
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

        if( !Swap(temp[i], temp[slot], true) ) {
            l("SwapScriptedPawns failed swapping "$i@ActorToString(temp[i])$" with "$slot@ActorToString(temp[slot]));
            continue;
        }

        l("SwapScriptedPawns swapping "$i@ActorToString(temp[i])$" with "$slot@ActorToString(temp[slot]));

        // TODO: swap non-weapons/ammo inventory, only need to swap nanokeys?
        SwapItems(temp[i], temp[slot]);
        if( temp[i].Tag != 'enemy_bot' && temp[slot].Tag != 'enemy_bot' ) // 12_VANDENBERG_CMD fix, see Mission12.uc https://discord.com/channels/823629359931195394/823629360929046530/974454774034497567
            SwapNames(temp[i].Tag, temp[slot].Tag);
        SwapNames(temp[i].Event, temp[slot].Event);
        SwapNames(temp[i].AlarmTag, temp[slot].AlarmTag);
        SwapNames(temp[i].SharedAlarmTag, temp[slot].SharedAlarmTag);
        SwapNames(temp[i].HomeTag, temp[slot].HomeTag);
        SwapVector(temp[i].HomeLoc, temp[slot].HomeLoc);
        SwapVector(temp[i].HomeRot, temp[slot].HomeRot);
        SwapProperty(temp[i], temp[slot], "HomeExtent");
        SwapProperty(temp[i], temp[slot], "bUseHome");
        SwapNames(temp[i].Orders, temp[slot].Orders);
        SwapNames(temp[i].OrderTag, temp[slot].OrderTag);
        SwapProperty(temp[i], temp[slot], "RaiseAlarm");

        ResetOrders(temp[i]);
        ResetOrders(temp[slot]);
    }
}

function RandoEnemies(int percent, int hidden_percent)
{
    // TODO: later when hidden_percent is well tested, we can get rid of it and _perc
    local int i, _perc;
    local ScriptedPawn p;
    local ScriptedPawn n;
    local ScriptedPawn newsp;

    l("RandoEnemies "$percent);

    SetSeed( "RandoEnemies" );
    if(percent <= 0) return;

    foreach AllActors(class'ScriptedPawn', p)
    {
        if( p != None && p.bImportant ) continue;
#ifdef gmdx
        if( SpiderBot2(p) != None && SpiderBot2(p).bUpsideDown ) continue;
#endif
        RandomizeSize(p);
    }

    foreach AllActors(class'ScriptedPawn', p)
    {
        if( p == newsp ) break;
        if( IsCritter(p) ) continue;
        //if( SkipActor(p, 'ScriptedPawn') ) continue;
        //if( IsInitialEnemy(p) == False ) continue;
#ifdef gmdx
        if( SpiderBot2(p) != None && SpiderBot2(p).bUpsideDown ) continue;
#endif

        if( HasItemSubclass(p, class'Weapon') == false ) continue;//don't randomize neutral npcs that don't already have weapons

        _perc = percent;
        if(p.bHidden) _perc = hidden_percent;

        if( chance_single(_perc) ) RandomizeSP(p, _perc);

        if(p.bImportant && p.Tag != 'RaidingCommando') continue;
        if(p.bInvincible) continue;
        if( p.Region.Zone.bWaterZone || p.Region.Zone.bPainZone ) continue;

        if( chance_single(_perc) == false ) continue;

        for(i = rng(enemy_multiplier*100+_perc)/100; i >= 0; i--) {
            n = RandomEnemy(p, _perc);
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

    if( newclass == None && IsHuman(base.class) == false && chance_single(dxr.flags.settings.enemies_nonhumans)==false ) return None;
    if( IsHuman(newclass) == false && chance_single(dxr.flags.settings.enemies_nonhumans)==false ) return None;

    n = CloneScriptedPawn(base, newclass);
    l("new RandomEnemy("$base$", "$percent$") == "$n);
    if( n != None ) RandomizeSP(n, percent);
    //else RandomizeSize(n);
    return n;
}

function bool IsInitialEnemy(ScriptedPawn p)
{
    local int i;

    return p.GetAllianceType( class'#var(PlayerPawn)'.default.Alliance ) == ALLIANCE_Hostile;
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

        if(p.bInWorld)
            loc = p.Location + (radius*loc_offset);
        else
            loc = p.WorldPosition + (radius*loc_offset);

        if( p.bInWorld == true && class'DXRMissions'.static.IsCloseToStart(dxr, loc) ) {
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
#ifdef hx
    // HACK: HXThugMale is missing the CarcassType
    if( n.class == class'HXThugMale' && n.CarcassType == None )
        n.CarcassType = class'HXThugMaleCarcass';
#endif

    if( IsHuman(p.class) && IsHuman(n.class) && p.BarkBindName != "" && n.BarkBindName == "" ) n.BarkBindName = p.BarkBindName;
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

    if(!p.bInWorld) {
        n.bHidden = true;
        n.bInWorld = false;
        if(num_watches >= ArrayCount(watches)) {
            // this can happen if someone cranks up the settings too high
            warning("num_watches >= ArrayCount(watches): "$num_watches $", "$ ArrayCount(watches));
        } else {
            watches[num_watches].watch = p;
            watches[num_watches].target = n;
            num_watches++;
            SetTimer(1, true);
        }
    } else if(p.bHidden) {
        err(p$" is hidden but in world?");
        n.bHidden = true;
    }

    return n;
}

function Timer() {
    local int i;
    local WatchEnterWorld w;
    Super.Timer();

    for(i=0; i<num_watches; i++) {
        w = watches[i];
        if(w.watch != None && w.watch.bInWorld) {
            w.target.EnterWorld();
            w.watch = None;
        }
        if(w.watch == None) {
            watches[i] = watches[--num_watches];
            i--;
        }
    }
}

function int GetWeaponCount(ScriptedPawn sp)
{
    local int i,count;
    count=0;
    for (i=0; i<ArrayCount(sp.InitialInventory); i++)
    {
        if ((sp.InitialInventory[i].Inventory != None) && (sp.InitialInventory[i].Count > 0))
        {
            if( ClassIsChildOf(sp.InitialInventory[i].inventory, class'Weapon') ) {
                count++;
            }
        }
    }
    return count;
}

function RandomizeSP(ScriptedPawn p, int percent)
{
    local int numWeapons,i;

    if( p == None ) return;

    l("RandomizeSP("$p$", "$percent$")");
    if( IsHuman(p.class) || dxr.flags.settings.bot_stats>0 ) {
        p.SurprisePeriod = rngrange(p.SurprisePeriod+0.1, 0.3, 1.2);
        p.GroundSpeed = rngrange(p.GroundSpeed, 0.9, 1.1);
        p.BaseAccuracy -= FClamp(rngf() * float(percent)/100.0, 0, 0.8);
    }

    if( IsCritter(p) ) return; // only give random weapons to humans and robots
    if( p.IsA('MJ12Commando') || p.IsA('WIB') ) return;


    if( IsHuman(p.class)) {
        RemoveItem(p, class'Weapon');
        RemoveItem(p, class'Ammo');

        GiveRandomWeapon(p, false, 2);
        if( chance_single(50) )
            GiveRandomWeapon(p, false, 2);
        GiveRandomMeleeWeapon(p);
        p.SetupWeapon(false);
    } else if (IsRobot(p.Class) && dxr.flags.settings.bot_weapons!=0) {
        numWeapons = GetWeaponCount(p);

        //Maybe it would be better if the bots *didn't* get their baseline weapons removed?
        RemoveItem(p, class'Weapon');
        RemoveItem(p, class'Ammo');

        //Since bots don't have melee weapons, they should get more ammo to compensate
        for (i=0;i<numWeapons;i++){
            GiveRandomBotWeapon(p, false, 6); //Give as many weapons as the bot defaults with
        }
        if( chance_single(50) ) //Give a chance for a bonus weapon
            GiveRandomBotWeapon(p, false, 6);
        p.SetupWeapon(false);
    }
}

//Will attempt to find a different weapon if dupes aren't allowed
function inventory GiveRandomBotWeapon(Pawn p, optional bool allow_dupes, optional int add_ammo)
{
    local class<DeusExWeapon> wclass;
    local Ammo a;
    local int i;
    local float r;
    local int findWeaponAttempts;

    findWeaponAttempts = 15;

    while(findWeaponAttempts>0){
        r = initchance();
        for(i=0; i < ArrayCount(_randombotweapons); i++ ) {
            if( _randombotweapons[i].type == None ) break;
            if( chance( _randombotweapons[i].chance, r ) ) wclass = _randombotweapons[i].type;
        }
        chance_remaining(r);

        if( (!allow_dupes) && HasItem(p, wclass) ){
            findWeaponAttempts--;
            wclass = None;
        } else {
            findWeaponAttempts = 0;
        }

    }

    if( wclass == None ) {
        warning("not giving a random weapon to "$p);
        return None;
    }

    l("GiveRandomBotWeapon "$p$", "$wclass.Name$", "$add_ammo);
    return GiveItem( p, wclass, add_ammo );
}

function inventory GiveRandomWeapon(Pawn p, optional bool allow_dupes, optional int add_ammo)
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

    if( (!allow_dupes) && p!=None && HasItem(p, wclass) )
        return None;

    if( wclass == None ) {
        warning("not giving a random weapon to "$p);
        return None;
    }

    l("GiveRandomWeapon "$p$", "$wclass.Name$", "$add_ammo);
    if(p!=None)
        return GiveItem( p, wclass, add_ammo );
    else
        return Spawn(wclass);
}

function inventory GiveRandomMeleeWeapon(Pawn p, optional bool allow_dupes)
{
    local class<Weapon> wclass;
    local int i;
    local float r;

    if( (!allow_dupes) && p!=None && HasMeleeWeapon(p))
        return None;

    r = initchance();
    for(i=0; i < ArrayCount(_randommelees); i++ ) {
        if( _randommelees[i].type == None ) break;
        if( chance( _randommelees[i].chance, r ) ) wclass = _randommelees[i].type;

        if( (!allow_dupes) && HasItem(p, _randommelees[i].type) ) {
            chance_remaining(r);
            return None;
        }
    }

    l("GiveRandomMeleeWeapon "$p$", "$wclass.Name);
    if(p!=None)
        return GiveItem(p, wclass);
    else
        return Spawn(wclass);
}

function RandomizeSize(Actor a)
{
    local Decoration carried;
    local DeusExPlayer p;
    local float scale;

    p = DeusExPlayer(a);
    if( p != None && p.carriedDecoration != None ) {
        carried = p.carriedDecoration;
        p.DropDecoration();
        carried.SetPhysics(PHYS_None);
    }

    scale = rngrange(1, 0.9, 1.1);
    SetActorScale(a, scale);
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
