class DXREnemiesBase extends DXRActorsBase abstract;

var int enemy_multiplier;

struct _RandomWeaponStruct { var class<DeusExWeapon> type; var float chance; };
var transient _RandomWeaponStruct _randommelees[8];
var transient _RandomWeaponStruct _randomweapons[32];
var transient _RandomWeaponStruct _randomsidearms[8];
var transient _RandomWeaponStruct _randombotweapons[32];

struct _RandomEnemyStruct { var class<ScriptedPawn> type; var float chance; var int faction; };
var transient _RandomEnemyStruct _randomenemies[128];

var name defaultOrders;
var float min_rate_adjust, max_rate_adjust;

struct WatchEnterWorld {
    var ScriptedPawn watch, target;
};

// for hidden/not in world pawns, TODO: put these in a separate actor so we can make DXREnemies transient
var WatchEnterWorld watches[100];
var int num_watches;

replication
{
    reliable if( Role == ROLE_Authority )
        _randommelees, _randomweapons, _randomsidearms, _randombotweapons;
}

const FactionAny = 0;
const FactionsEnd = 6;// end of the factions list
function int GetFactionId(ScriptedPawn p);
function RandomizeSP(ScriptedPawn p, int percent);
function CheckHelmet(ScriptedPawn p);

function AddRandomBotWeapon(class<DeusExWeapon> t, int c)
{
    local int i;
    for(i=0; i < ArrayCount(_randombotweapons); i++) {
        if( _randombotweapons[i].type == None ) {
            _randombotweapons[i].type = t;
            _randombotweapons[i].chance = c;
            return;
        }
    }
}

function AddRandomWeapon(class<DeusExWeapon> t, int c)
{
    local int i;
    for(i=0; i < ArrayCount(_randomweapons); i++) {
        if( _randomweapons[i].type == None ) {
            _randomweapons[i].type = t;
            _randomweapons[i].chance = c;
            return;
        }
    }
}

function AddRandomSidearm(class<DeusExWeapon> t, int c)
{
    local int i;
    for(i=0; i < ArrayCount(_randomsidearms); i++) {
        if( _randomsidearms[i].type == None ) {
            _randomsidearms[i].type = t;
            _randomsidearms[i].chance = c;
            return;
        }
    }
}

function AddRandomMelee(class<DeusExWeapon> t, int c)
{
    local int i;
    for(i=0; i < ArrayCount(_randommelees); i++) {
        if( _randommelees[i].type == None ) {
            _randommelees[i].type = t;
            _randommelees[i].chance = c;
            return;
        }
    }
}

function AddRandomEnemyType(class<ScriptedPawn> t, float c, int faction)
{
    local int i;
    if(faction == FactionAny) {
        for(i=faction+1; i < FactionsEnd; i++) {
            AddRandomEnemyType(t, c, i);
        }
        return;
    }
    for(i=0; i < ArrayCount(_randomenemies); i++) {
        if( _randomenemies[i].type == None ) {
            _randomenemies[i].type = t;
            _randomenemies[i].chance = rngrangeseeded(c, min_rate_adjust, max_rate_adjust, t.name) ** 2;
            _randomenemies[i].faction = faction;
            return;
        }
    }
}

function ReadConfig()
{
    local int i, nums[32], nummelees[8], numsides[8], totalweaps, totalmelees, totalsides;
    local float total, f, c, totals[16];
    local class<Actor> a;
    local DeusExWeapon w;

    // count existing in level
    foreach AllActors(class'DeusExWeapon', w) {
        if(PlayerPawn(w.Owner)!=None) continue;
        if(ScriptedPawn(w.Owner)!=None && ScriptedPawn(w.Owner).bInvincible) continue;
        for(i=0; i < ArrayCount(_randommelees); i++) {
            if(_randommelees[i].type == w.class) {
                nummelees[i]++;
                totalmelees++;
            }
        }
        for(i=0; i < ArrayCount(_randomweapons); i++) {
            if(_randomweapons[i].type == w.class) {
                nums[i]++;
                totalweaps++;
            }
        }
        for(i=0; i < ArrayCount(_randomsidearms); i++) {
            if(_randomsidearms[i].type == w.class) {
                numsides[i]++;
                totalsides++;
            }
        }
    }

    if(totalmelees==0) {
        for(i=0; i < ArrayCount(_randommelees); i++) {
            if(_randommelees[i].type == class'#var(prefix)WeaponCombatKnife') {
                nummelees[i]++;
                totalmelees++;
                break;
            }
        }
    }
    if(totalweaps==0) {
        for(i=0; i < ArrayCount(_randomweapons); i++) {
            if(_randomweapons[i].type == class'#var(prefix)WeaponPistol') {
                nums[i]++;
                totalweaps++;
                break;
            }
        }
    }
    if(totalsides==0) {
        for(i=0; i < ArrayCount(_randomsidearms); i++) {
            if(_randomsidearms[i].type == class'#var(prefix)WeaponPistol') {
                numsides[i]++;
                totalsides++;
                break;
            }
        }
    }

    total=0;
    f = float(dxr.flags.moresettings.enemies_weapons) / 100.0;
    for(i=0; i < ArrayCount(_randommelees); i++) {
        if( _randommelees[i].type != None ) {
            _randommelees[i].chance = rngrangeseeded(_randommelees[i].chance, min_rate_adjust, max_rate_adjust, _randommelees[i].type.name) ** 2;
            c = _randommelees[i].chance * f;
            c += float(nummelees[i]) / float(totalmelees) * (1.0-f) * 100.0;
            _randommelees[i].chance = c;
            total += c;
        }
    }
    for(i=0; i < ArrayCount(_randommelees); i++) {
        if(_randommelees[i].type != None) {
            _randommelees[i].chance *= 100 / total;
        }
    }

    total=0;
    for(i=0; i < ArrayCount(_randomweapons); i++) {
        if( _randomweapons[i].type != None ) {
            _randomweapons[i].chance = rngrangeseeded(_randomweapons[i].chance, min_rate_adjust, max_rate_adjust, _randomweapons[i].type.name) ** 2;
            c = _randomweapons[i].chance * f;
            c += float(nums[i]) / float(totalweaps) * (1.0-f) * 100.0;
            _randomweapons[i].chance = c;
            total += c;
        }
    }
    for(i=0; i < ArrayCount(_randomweapons); i++) {
        if(_randomweapons[i].type != None) {
            _randomweapons[i].chance *= 100.0 / total;
        }
    }

    total=0;
    for(i=0; i < ArrayCount(_randomsidearms); i++) {
        if( _randomsidearms[i].type != None ) {
            _randomsidearms[i].chance = rngrangeseeded(_randomsidearms[i].chance, min_rate_adjust, max_rate_adjust, _randomsidearms[i].type.name) ** 2;
            c = _randomsidearms[i].chance * f;
            c += float(nums[i]) / float(totalweaps) * (1.0-f) * 100.0;
            _randomsidearms[i].chance = c;
            total += c;
        }
    }
    for(i=0; i < ArrayCount(_randomsidearms); i++) {
        if(_randomsidearms[i].type != None) {
            _randomsidearms[i].chance *= 100.0 / total;
        }
    }

    total=0;
    for(i=0; i < ArrayCount(_randombotweapons); i++) {
        if( _randombotweapons[i].type != None ) {
            _randombotweapons[i].chance = rngrangeseeded(_randombotweapons[i].chance, min_rate_adjust, max_rate_adjust, _randombotweapons[i].type.name) ** 2;
            total += _randombotweapons[i].chance;
        }
    }
    for(i=0; i < ArrayCount(_randombotweapons); i++) {
        if(_randombotweapons[i].type != None) {
            _randombotweapons[i].chance *= 100.0/total;
        }
    }

    for(i=0; i < ArrayCount(_randomenemies); i++) {
        if( _randomenemies[i].type == None ) continue;
        totals[_randomenemies[i].faction] += _randomenemies[i].chance;
    }
    for(i=0; i < ArrayCount(_randomenemies); i++) {
        total = totals[_randomenemies[i].faction];
        _randomenemies[i].chance *= 100.0/total;
    }
}

function _RandomWeaponStruct GetWeaponConfig(int i)
{
    if( i < ArrayCount(_randomweapons) )
        return _randomweapons[i];
}

function RandoCarcasses(int chance)
{
    local #var(DeusExPrefix)Carcass c;
    local Inventory item, nextItem;

    SetSeed( "RandoCarcasses" );

    foreach AllActors(class'#var(DeusExPrefix)Carcass', c) {
        if( ! chance_single(chance) ) continue;

        item = c.Inventory;
        while( item != None ) {
            nextItem = item.Inventory;
            if( chance_single(50) && #var(prefix)NanoKey(item)==None && #var(prefix)AugmentationCannister(item)==None && #var(prefix)AugmentationUpgradeCannister(item)==None ) {
                c.DeleteInventory(item);
                item.Destroy();
            }
            item = nextItem;
        }
    }
}

function ScriptedPawn RandomEnemy(ScriptedPawn base, int percent)
{
    local class<ScriptedPawn> newclass;
    local ScriptedPawn n;
    local int i, faction, oldSeed;
    local float r;
    faction = GetFactionId(base);
    r = initchance();
    for(i=0; i < ArrayCount(_randomenemies); i++ ) {
        if( _randomenemies[i].type == None ) break;
        if( _randomenemies[i].faction != faction ) continue;
        if( chance( _randomenemies[i].chance, r ) ) newclass = _randomenemies[i].type;
    }

    chance_remaining(r);// else keep the same class

    if( newclass == None && IsHuman(base.class) == false && chance_single(dxr.flags.settings.enemies_nonhumans)==false ) return None;
    if( IsHuman(newclass) == false && chance_single(dxr.flags.settings.enemies_nonhumans)==false ) return None;

    oldSeed = BranchSeed(base $ newclass);
    n = CloneScriptedPawn(base, newclass);
    l("new RandomEnemy("$base$", "$percent$") == "$n);
    if( n != None ) {
        RandomizeSP(n, percent);
        CheckHelmet(n);
    }
    //else RandomizeSize(n);
    ReapplySeed(oldSeed);
    return n;
}

function bool IsSpawnPointGood(vector loc, class<ScriptedPawn> newclass)
{
    local LocationNormal locnorm;
    local FMinMax distrange;

    locnorm.loc = loc;
    distrange.min = -16 * 5;
    distrange.max = 16 * 20;
    return NearestFloor(locnorm, distrange);
}

function ScriptedPawn CloneScriptedPawn(ScriptedPawn p, optional class<ScriptedPawn> newclass)
{
    local int i;
    local ScriptedPawn n;
    local float radius, num_enemies;
    local vector loc, loc_offset;
    local Inventory inv;
    local NanoKey k1, k2;
    local name newtag, oldAlliance;
    local ZoneInfo zone;

    if( p == None ) {
        l("p == None?");
        return None;
    }
    if( newclass == None ) newclass = p.class;

    if(p.bInWorld)
        loc = p.Location + loc_offset;
    else
        loc = p.WorldPosition + loc_offset;
    if(!IsSpawnPointGood(loc, newclass) || (p.bInWorld == true && class'DXRMissions'.static.IsCloseToStart(dxr, loc))) {
        l("CloneScriptedPawn "$p$" is in a bad spot for cloning");
        return None;
    }

    newtag = StringToName(p.Tag $ "_clone");
    radius = (p.CollisionRadius + newclass.default.CollisionRadius) * 3.0;// combined radius, and * 3 for some personal space
    num_enemies = float(enemy_multiplier) * float(dxr.flags.settings.enemiesrandomized+100) / 100.0;
    radius *= Sqrt(num_enemies+1.0);
    for(i=0; i<20; i++) {
        // rngfn_min_dist to add a minimum distance from the 0, but also allow negative numbers
        loc_offset.X = rngfn_min_dist(0.5);
        loc_offset.Y = rngfn_min_dist(0.5);
        // the combined radius of these characters, multiplied by the square root of the number of enemies
        loc_offset *= radius;
        loc_offset.Z = 16;// a foot above the ground, allows them to more easily spawn on stairs?

        if(p.bInWorld)
            loc = p.Location + loc_offset;
        else
            loc = p.WorldPosition + loc_offset;

        if(!IsSpawnPointGood(loc, newclass)) {
            l("CloneScriptedPawn "$loc$" is no good!");
            continue;
        }

        if( p.bInWorld == true && class'DXRMissions'.static.IsCloseToStart(dxr, loc) ) {
            l("CloneScriptedPawn "$loc$" is too close to start!");
            continue;
        }

        zone = GetZone(loc);
        if(zone.bWaterZone || zone.bPainZone) {
            l("CloneScriptedPawn "$loc$" bad zone " $ zone @ zone.bWaterZone @ zone.bPainZone);
            continue;
        }

        n = Spawn(newclass,, newtag, loc );
        if( n != None ) {
            if(VSize(n.Location - loc) > 160) {
                // distance greater than 10 feet from desired location
                warning("CloneScriptedPawn "$n@n.Location$" is too far from desired "$loc);
                n.Destroy();
                n = None;
                continue;
            }
            else break;// we're good!
        }
    }
    if( n == None ) {
        l("CloneScriptedPawn failed to clone "$ActorToString(p)$" into class "$newclass$" into "$loc);
        return None;
    }
    l("CloneScriptedPawn "$ActorToString(p)$" into class "$newclass$" got "$ActorToString(n));
#ifdef hx
    // HACK: HXThugMale is missing the CarcassType
    if( n.class == class'HXThugMale' && n.CarcassType == None )
        n.CarcassType = class'HXThugMaleCarcass';
#endif

    if( IsHuman(p.class) && IsHuman(n.class) && p.BarkBindName != "" && n.BarkBindName == "" ) n.BarkBindName = p.BarkBindName;
    class'DXRNames'.static.GiveRandomName(dxr, n);
    oldAlliance = n.Alliance;
    n.Alliance = p.Alliance;
    if(oldAlliance != '') {
        n.ChangeAlly(oldAlliance, 0, false);
    }
    for(i=0; i<ArrayCount(n.InitialAlliances); i++ )
    {
        // clear default initial alliances
        if(n.InitialAlliances[i].AllianceName != '') {
            n.ChangeAlly(n.InitialAlliances[i].AllianceName, 0, false);
        }
        // instead copy alliances from parent, below we call n.InitializeAlliances()
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

    if(p.bInWorld)
        n.Orders = defaultOrders;
    else
        n.Orders = 'Wandering';
    n.HomeTag = 'Start';

    n.bInWorld = p.bInWorld;
    RandomizeSize(n);
    n.InitializePawn();

    if(!p.bInWorld) {
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

function AnyEntry()
{
    Super.AnyEntry();
    if(num_watches > 0) SetTimer(1, true);
}

function Timer() {
    local int i;
    local WatchEnterWorld w;
    Super.Timer();

    for(i=0; i<num_watches; i++) {
        w = watches[i];
        if(w.target != None && (w.watch==None || w.watch.bInWorld)) {
            w.target.EnterWorld();
            w.target.Falling();
            w.watch = None;
        }
        if(w.watch == None) {
            watches[i] = watches[--num_watches];
            i--;
        }
    }

    if(num_watches == 0) SetTimer(0, false);
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
        warning("not giving a random weapon to bot "$p);
        return None;
    }

    l("GiveRandomBotWeapon "$p$", "$wclass.Name$", "$add_ammo);
    return GiveItem( p, wclass, add_ammo );
}

function class<Weapon> GiveRandomWeaponClass(Pawn p, optional bool allow_dupes)
{
    local class<Weapon> wclass;
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

    return wclass;
}

function inventory GiveRandomWeapon(Pawn p, optional bool allow_dupes, optional int add_ammo)
{
    local class<Weapon> wclass;

    wclass = GiveRandomWeaponClass(p, allow_dupes);
    if(wclass == None) return None;

    l("GiveRandomWeapon "$p$", "$wclass.Name$", "$add_ammo);
    if(p!=None) {
        if(wclass==class'#var(prefix)WeaponMiniCrossbow' && rngb()) GiveItem(p, class'AmmoDart', 0);
        return GiveItem( p, wclass, add_ammo );
    } else
        return Spawn(wclass);
}

function class<Weapon> GiveRandomSidearmClass(Pawn p, optional bool allow_dupes)
{
    local class<Weapon> wclass;
    local int i;
    local float r;
    r = initchance();
    for(i=0; i < ArrayCount(_randomsidearms); i++ ) {
        if( _randomsidearms[i].type == None ) break;
        if( chance( _randomsidearms[i].chance, r ) ) wclass = _randomsidearms[i].type;
    }
    chance_remaining(r);

    if( (!allow_dupes) && p!=None && HasItem(p, wclass) )
        return None;

    if( wclass == None ) {
        warning("not giving a random sidearm to "$p);
        return None;
    }

    return wclass;
}

function inventory GiveRandomSidearm(Pawn p, optional bool allow_dupes, optional int add_ammo)
{
    local class<Weapon> wclass;

    wclass = GiveRandomSidearmClass(p, allow_dupes);
    if(wclass == None) return None;

    l("GiveRandomSidearm "$p$", "$wclass.Name$", "$add_ammo);
    if(p!=None) {
        if(wclass==class'#var(prefix)WeaponMiniCrossbow' && rngb()) GiveItem(p, class'AmmoDart', 0);
        return GiveItem( p, wclass, add_ammo );
    } else
        return Spawn(wclass);
}

function class<Weapon> GiveRandomMeleeWeaponClass(Pawn p, optional bool allow_dupes)
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

    chance_remaining(r);
    return wclass;
}

function inventory GiveRandomMeleeWeapon(Pawn p, optional bool allow_dupes)
{
    local class<Weapon> wclass;

    wclass = GiveRandomMeleeWeaponClass(p, allow_dupes);
    if(wclass == None) return None;

    l("GiveRandomMeleeWeapon "$p$", "$wclass.Name);
    if(p!=None)
        return GiveItem(p, wclass);
    else
        return Spawn(wclass);
}

function RunTests()
{
    local int i;
    local float total;
    Super.RunTests();

    total=0;
    for(i=0; i < ArrayCount(_randomenemies); i++ ) {
        if(_randomenemies[i].type == None) continue;
        total += _randomenemies[i].chance;
        test( _randomenemies[i].faction > FactionAny, "_randomenemies["$i$"].faction > FactionAny" );
        test( _randomenemies[i].faction < FactionsEnd, "_randomenemies["$i$"].faction < FactionsEnd" );
    }
    //test( total <= 100, "config randomenemies chances, check total "$total);// TODO: fix this test again
    total=0;
    for(i=0; i < ArrayCount(_randomweapons); i++ ) {
        total += _randomweapons[i].chance;
    }
    testfloat( total, 100, "_randomweapons chances, check total "$total);
    total=0;
    for(i=0; i < ArrayCount(_randommelees); i++ ) {
        total += _randommelees[i].chance;
    }
    testfloat( total, 100, "_randommelees chances, check total "$total);
    total=0;
    for(i=0; i < ArrayCount(_randombotweapons); i++ ) {
        total += _randombotweapons[i].chance;
    }
    testfloat( total, 100, "_randombotweapons chances, check total "$total);
}
