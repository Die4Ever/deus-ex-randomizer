class DXRHordeMode extends DXRActorsBase transient;

var int wave;
var int time_to_next_wave;
var config int time_between_waves;
var bool in_wave;
var int time_in_wave;
var config int time_before_damage;
var config int damage_timer;
var config int time_before_teleport_enemies;
var config float popin_dist;
var config int skill_points_award;
var config int early_end_wave_timer;
var config int early_end_wave_enemies;
var config int items_per_wave;
var config float difficulty_per_wave;
var config float difficulty_first_wave;
var config int wine_bottles_per_enemy;
var config name default_orders;
var config name default_order_tag;
var config string map_name;
var config name remove_objects[12];
var config name unlock_doors[8];
var config name lock_doors[8];
var config vector starting_location;

struct EnemyChances {
    var string type;
    var float difficulty;
    var int minWave;
    var int maxWave;
    var int chance;
};
var config EnemyChances enemies[32];
var class<ScriptedPawn> enemyclasses[32];

struct ItemChances {
    var string type;
    var int chance;
};
var config ItemChances items[32];

function CheckConfig()
{
    local int i;
    if( ConfigOlderThan(1,6,0,3) ) {
        time_between_waves = 65;
        time_before_damage = 180;
        damage_timer = 10;
        time_before_teleport_enemies = 3;
        early_end_wave_timer = 240;
        early_end_wave_enemies = 5;
        popin_dist = 1800.0;
        skill_points_award = 2500;
        items_per_wave = 25;
        difficulty_per_wave = 1.5;
        difficulty_first_wave = 2;
        wine_bottles_per_enemy = 2;

        for(i=0; i < ArrayCount(enemies); i++) {
            enemies[i].type = "";
            enemies[i].chance = 0;
            enemies[i].minWave = 1;
            enemies[i].maxWave = 99999;
            enemies[i].difficulty = 1;
        }
        i=0;
        enemies[i].type = "Terrorist";
        enemies[i].chance = 10;
        i++;
        enemies[i].type = "UNATCOTroop";
        enemies[i].chance = 10;
        i++;
        enemies[i].type = "ThugMale";
        enemies[i].chance = 10;
        i++;
        enemies[i].type = "ThugMale2";
        enemies[i].chance = 10;
        i++;
        enemies[i].type = "ThugMale3";
        enemies[i].chance = 10;
        i++;
        enemies[i].type = "MJ12Commando";
        enemies[i].chance = 5;
        enemies[i].minWave = 3;
        enemies[i].difficulty = 2.5;
        i++;
        enemies[i].type = "MJ12Troop";
        enemies[i].chance = 5;
        enemies[i].minWave = 2;
        enemies[i].difficulty = 2;
        i++;
        enemies[i].type = "MIB";
        enemies[i].chance = 2;
        enemies[i].minWave = 4;
        enemies[i].difficulty = 2;
        /*i++;
        enemies[i].type = "WIB";//bugged animations?
        enemies[i].chance = 2;
        enemies[i].minWave = 4;
        enemies[i].difficulty = 2;*/
        i++;
        enemies[i].type = "SpiderBot2";
        enemies[i].chance = 2;
        enemies[i].minWave = 5;
        enemies[i].difficulty = 2.5;
        i++;
        enemies[i].type = "MilitaryBot";
        enemies[i].chance = 1;
        enemies[i].minWave = 10;
        enemies[i].difficulty = 5;
        i++;
        enemies[i].type = "SecurityBot2";
        enemies[i].chance = 1;
        enemies[i].minWave = 7;
        enemies[i].difficulty = 4;
        i++;
        enemies[i].type = "SecurityBot3";
        enemies[i].chance = 1;
        enemies[i].minWave = 7;
        enemies[i].difficulty = 4;
        i++;
        enemies[i].type = "SecurityBot4";
        enemies[i].chance = 1;
        enemies[i].minWave = 7;
        enemies[i].difficulty = 4;

        for(i=0; i<ArrayCount(items); i++) {
            items[i].type="";
            items[i].chance=0;
        }
        i=0;
        items[i].type = "BioelectricCell";
        items[i].chance = 6;
        i++;
        items[i].type = "CrateExplosiveSmall";
        items[i].chance = 9;
        i++;
        items[i].type = "Barrel1";
        items[i].chance = 10;
        i++;
        items[i].type = "WeaponGasGrenade";
        items[i].chance = 7;
        i++;
        items[i].type = "WeaponLAM";
        items[i].chance = 7;
        i++;
        items[i].type = "WeaponEMPGrenade";
        items[i].chance = 7;
        i++;
        items[i].type = "WeaponNanoVirusGrenade";
        items[i].chance = 7;
        i++;
        items[i].type = "FireExtinguisher";
        items[i].chance = 6;
        i++;
        items[i].type = "Ammo10mm";
        items[i].chance = 7;
        i++;
        items[i].type = "Ammo762mm";
        items[i].chance = 7;
        i++;
        items[i].type = "AmmoShell";
        items[i].chance = 7;
        i++;
        items[i].type = "Ammo3006";
        items[i].chance = 2;
        i++;
        items[i].type = "AmmoRocket";
        items[i].chance = 1;
        i++;
        items[i].type = "AmmoDartPoison";
        items[i].chance = 1;
        // and 16% more...
        i++;
        items[i].type = "AugmentationCannister";
        items[i].chance = 5;
        i++;
        items[i].type = "MedicalBot";
        items[i].chance = 5;
        i++;
        items[i].type = "MedKit";
        items[i].chance = 3;
        i++;
        items[i].type = "AugmentationUpgradeCannister";
        items[i].chance = 3;

        map_name = "11_paris_cathedral";
        starting_location = vect(-3811.785156, 2170.053223, -774.903442);
        default_orders = 'Attacking';
        default_order_tag = '';

        i=0;
        remove_objects[i++] = 'MapExit';
        remove_objects[i++] = 'ScriptedPawn';
        remove_objects[i++] = 'DataLinkTrigger';
        remove_objects[i++] = 'Teleporter';
        remove_objects[i++] = 'SecurityCamera';
        remove_objects[i++] = 'AutoTurret';

        i=0;
        lock_doors[i++] = 'BreakableGlass0';
        lock_doors[i++] = 'BreakableGlass1';
        lock_doors[i++] = 'BreakableGlass2';
        lock_doors[i++] = 'BreakableGlass3';
        lock_doors[i++] = 'DeusExMover8';
        lock_doors[i++] = 'DeusExMover9';
        lock_doors[i++] = 'DeusExMover17';

        i=0;
        unlock_doors[i++] = 'DeusExMover19';
    }
    map_name = Caps(map_name);
    Super.CheckConfig();

    for(i=0; i < ArrayCount(enemies); i++) {
        if(enemies[i].type == "") continue;
        enemyclasses[i] = class<ScriptedPawn>(GetClassFromString(enemies[i].type, class'ScriptedPawn'));
    }
}

function AnyEntry()
{
    local Actor a;
    local Teleporter t;
    local DeusExMover d;
    local DXREnemies dxre;
    local Inventory item;
    local int i;

    if( dxr.flags.gamemode != 2 ) return;
    Super.AnyEntry();
    if( dxr.dxInfo.missionNumber>0 && dxr.localURL != map_name ) {
        Level.Game.SendPlayer(player(), map_name);
        return;
    }
    else if( dxr.localURL != map_name ) {
        return;
    }

    player().SetLocation(starting_location);

    dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
    if( dxre == None ) {
        err("Could not find DXREnemies! This is required for Horde Mode.");
    }

    class'DXRAugmentations'.static.AddAug( player(), class'AugSpeed', dxr.flags.settings.speedlevel );
    dxre.GiveRandomWeapon(player());
    dxre.GiveRandomWeapon(player());
    dxre.GiveRandomMeleeWeapon(player());
    GiveItem(player(), class'Medkit');
    GiveItem(player(), class'FireExtinguisher');
    time_to_next_wave = time_between_waves;

    foreach AllActors(class'Teleporter', t) {
        t.bEnabled = false;// seems like teleporters are baked into the level's collision, so destroying them at runtime has no effect
    }
    foreach AllActors(class'Actor', a) {
        for(i=0; i < ArrayCount(remove_objects); i++) {
            if( a.IsA(remove_objects[i]) )
                a.Destroy();
        }
    }

    foreach AllActors(class'DeusExMover', d) {
        for(i=0; i < ArrayCount(unlock_doors); i++) {
            if( d.Name == unlock_doors[i] )
                d.bLocked = false;
        }
        for(i=0; i < ArrayCount(lock_doors); i++) {
            if( d.Name == lock_doors[i] ) {
                d.bBreakable = false;
                d.bPickable = false;
                d.bLocked = true;
            }
        }
    }

    SetTimer(1.0, true);

    GenerateItems();
}

function Timer()
{
    if( player().Health <= 0 ) {
        player().ShowHud(true);
        l("You died on wave "$wave);
        player().ClientMessage("You died on wave "$wave,, true);
        //SetTimer(0, false);
        return;
    }

    if( in_wave )
        InWaveTick();
    else
        OutOfWaveTick();
}

function InWaveTick()
{
    local ScriptedPawn p;
    local int numScriptedPawns;
    local float dist, ratio;

    foreach AllActors(class'ScriptedPawn', p, 'hordeenemy') {
        if( p.IsA('Animal') ) continue;
        if( (time_in_wave+numScriptedPawns) % 5 == 0 ) p.SetOrders(default_orders, default_order_tag);
        p.bStasis = false;
        dist = VSize(p.Location-player().Location);
        if( dist > popin_dist ) {
            ratio = dist/popin_dist;
            p.GroundSpeed = p.class.default.GroundSpeed * ratio*ratio;
        } else {
            p.GroundSpeed = p.class.default.GroundSpeed;
        }
        numScriptedPawns++;
    }

    if( numScriptedPawns == 0 || ( time_in_wave > early_end_wave_timer && numScriptedPawns <= early_end_wave_enemies ) ) {
        if( numScriptedPawns > 0 ) {
            player().ClientMessage("Moving on. Warning: there are still "$numScriptedPawns$" enemies!",, true);
        }
        EndWave();
        return;
    }

    time_in_wave++;
    NotifyPlayerPawns(numScriptedPawns);

    if( time_in_wave >= time_before_damage && time_in_wave%damage_timer == 0 ) {
        player().TakeDamage(1, player(), player().Location, vect(0,0,0), 'Shocked');
        PlaySound(sound'ProdFire');
        PlaySound(sound'MalePainSmall');
    }
    else {
        NotifyPlayerTimer(time_before_damage-time_in_wave, (time_before_damage-time_in_wave) $ " seconds until shocking.");
    }
    if( time_in_wave > time_before_teleport_enemies ) {
        GetOverHere();
    }
}

function OutOfWaveTick()
{
    time_to_next_wave--;
    NotifyPlayerTime();

    if( time_to_next_wave <= 0 ) {
        StartWave();        
    }
}

function StartWave()
{
    local MedicalBot mb;
    local DeusExCarcass c;
    local int num_carcasses;
    local int num_items;
    local Inventory item;
    local Weapon w;
    foreach AllActors(class'MedicalBot', mb) {
        mb.TakeDamage(10000, mb, mb.Location, vect(0,0,0), 'Exploded');
    }
    foreach AllActors(class'DeusExCarcass', c) {
        num_items = 0;
        for( item = c.Inventory; item != None; item = item.Inventory) {
            if( ! IsMeleeWeapon(item) )
                num_items++;
        }
        if( num_items == 0 ) c.Destroy();//TakeDamage(10000, None, c.Location, vect(0,0,0), 'Exploded');
        else num_carcasses++;
    }
    if( num_carcasses > 50 ) {
        foreach AllActors(class'DeusExCarcass', c) {
            //c.TakeDamage(10000, None, c.Location, vect(0,0,0), 'Exploded');
            c.Destroy();
        }
    }
    num_items=0;
    foreach AllActors(class'Weapon', w) {
        if( w.Owner != None ) continue;
        if( ! IsMeleeWeapon(w) ) continue;
        num_items++;
        w.Destroy();

    }
    in_wave = true;
    time_in_wave = 0;
    wave++;
    GenerateEnemies();
}

function EndWave()
{
    in_wave=false;
    time_to_next_wave = time_between_waves;
    player().SkillPointsAdd(skill_points_award);
    GenerateItems();
}

function GetOverHere()
{
    local ScriptedPawn p;
    local int i, time_overdue;
    local vector loc;
    local float dist, maxdist;

    time_overdue = time_in_wave-time_before_teleport_enemies;
    maxdist = popin_dist - float(time_overdue*5);
    foreach AllActors(class'ScriptedPawn', p, 'hordeenemy') {
        if( p.IsA('Animal') ) continue;

        p.bStasis = false;
        dist = VSize(player().Location-p.Location);
        if( (time_in_wave+i) % 7 == 0 && p.CanSee(player()) == false && dist > maxdist ) {
            loc = GetCloserPosition(player().Location, p.Location, maxdist*2);
            loc.X += rngfn() * 50;
            loc.Y += rngfn() * 50;
            p.SetLocation( loc );
        }
        else if( (time_in_wave+i) % 13 == 0 && p.CanSee(player()) == false && dist > maxdist*2 ) {
            loc = GetRandomPosition(player().Location, maxdist, dist);
            loc.X += rngfn() * 50;
            loc.Y += rngfn() * 50;
            p.SetLocation(loc);
        }
        i++;
    }
}

function NotifyPlayerTimer(int time, string text)
{
    if(time<0) return;

    if(
        ( time % 30 == 0 )
        || (time < 60 && time % 10 == 0)
        || (time <= 10)
    ) {
        player().ClientMessage(text);
    }
}

function NotifyPlayerPawns(int numScriptedPawns)
{
    //if( numScriptedPawns > 10 ) return;
    if( time_in_wave % 3 != 0 ) return;

    if( numScriptedPawns == 1 )
        player().ClientMessage("Wave "$wave$": " $ numScriptedPawns $ " enemy remaining.");
    else
        player().ClientMessage("Wave "$wave$": " $ numScriptedPawns $ " enemies remaining.");
}

function NotifyPlayerTime()
{
    if( time_to_next_wave == 1 )
        NotifyPlayerTimer(time_to_next_wave, "Wave "$ (wave+1) $" in " $ time_to_next_wave $ " second.");
    else
        NotifyPlayerTimer(time_to_next_wave, "Wave "$ (wave+1) $" in " $ time_to_next_wave $ " seconds.");
}

function GenerateEnemies()
{
    local DXREnemies dxre;
    local int i, numEnemies;
    local float difficulty, maxdifficulty;
    
    dxr.SetSeed( dxr.seed + wave + dxr.Crc( "Horde GenerateEnemies") );
    dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
    if( dxre == None ) {
        return;
    }

    maxdifficulty = float(wave-1)*difficulty_per_wave + difficulty_first_wave;
    numEnemies = int(maxdifficulty*2);
    for(i=0; i<numEnemies || difficulty < 0.1 ; i++) {
        difficulty += GenerateEnemy(dxre);
        if( difficulty > maxdifficulty ) break;
    }
}

function float GenerateEnemy(DXREnemies dxre)
{
    local class<ScriptedPawn> c;
    local ScriptedPawn p;
    local int i;
    local float difficulty, dist, r;
    local vector loc;

    r = initchance();
    for(i=0; i < ArrayCount(enemies); i++ ) {
        if( enemies[i].minWave > wave ) continue;
        if( enemies[i].maxWave < wave ) continue;
        if( chance( enemies[i].chance, r ) ) {
            c = enemyclasses[i];
            difficulty = enemies[i].difficulty;
        }
    }
    chance_remaining(r);

    if( c == None ) {
        return 0;
    }
    p = None;
    for(i=0; i < 10 && p == None; i++ ) {
        loc = GetRandomPosition(player().Location, popin_dist*0.8, popin_dist*2.5);
        loc.X += rngfn() * 25;
        loc.Y += rngfn() * 25;
        p = Spawn(c,, 'hordeenemy', loc );
    }
    if(p==None) {
        l("failed to spawn "$c$" at "$loc);
        return 0;
    }

    p.Intelligence = BRAINS_Human;
    p.MinHealth = 0;//never flee from battle
    SetAlliance(p);
    p.SetOrders(default_orders, default_order_tag);
    dxre.RandomizeSP(p, 100);
    GiveRandomItems(p);
    p.InitializeInventory();
    p.bStasis = false;

    return difficulty;
}

function GiveRandomItems(ScriptedPawn p)
{
    local DeusExPickup item;

    item = DeusExPickup(GiveItem(p, class'WineBottle'));// this is how Paris works in real life, right?
    item.numCopies = wine_bottles_per_enemy;
}

function SetAlliance(ScriptedPawn p)
{
    local int i;
    p.Alliance = 'horde';
    for(i=0; i<ArrayCount(p.InitialAlliances); i++ )
    {
        p.InitialAlliances[i].AllianceName = '';
        p.InitialAlliances[i].AllianceLevel = 0;
    }
    /*for(i=0; i<ArrayCount(p.AlliancesEx); i++ ) {
        p.AlliancesEx[i].AllianceName = '';
    }*/
    p.InitialAlliances[0].AllianceName = 'horde';
    p.InitialAlliances[0].AllianceLevel = 1;
    p.InitialAlliances[0].bPermanent = true;

    p.InitialAlliances[1].AllianceName = player().Alliance;
    p.InitialAlliances[1].AllianceLevel = -1;
    p.InitialAlliances[1].bPermanent = true;

    p.SetAlliance(p.Alliance);
    p.InitializeAlliances();
    //p.SetEnemy(player(), 0, true);
}

function GenerateItems()
{
    local int i;
    dxr.SetSeed( dxr.seed + wave + dxr.Crc( "Horde GenerateItems") );
    for(i=0;i<items_per_wave;i++) {
        GenerateItem();
    }
}

function GenerateItem()
{
    local int i, num;
    local Actor a;
    local class<Actor> c;
    local vector loc;
    local #var prefix AugmentationCannister aug;
    local Barrel1 barrel;
    local DeusExMover d;
    local float r;
    r = initchance();
    for(i=0; i < ArrayCount(items); i++) {
        if( chance(items[i].chance, r) ) c = GetClassFromString(items[i].type, class'Actor');
    }
    foreach AllActors(class'Actor', a) {
        if( a.class != c ) continue;

        num++;
        if( num > items_per_wave/2 ) {
            loc = GetRandomItemPosition();
            a.SetLocation(loc);
        }
        if( num > items_per_wave )
            break;
    }
    if( num > items_per_wave ) {
        l("already have too many of "$c.name);
        return;
    }
    for(i=0; i<10 && a == None; i++) {
        loc = GetRandomItemPosition();
        a = Spawn(c,,, loc);
    }
    if(c==None) {
        l("failed to spawn "$c$" at "$loc);
        return ;
    }

    aug = #var prefix AugmentationCannister(a);
    barrel = Barrel1(a);

    if( aug != None ) {
        class'DXRAugmentations'.static.RandomizeAugCannister(dxr, aug);
    }
    else if( barrel != None ) {
        barrel.SkinColor = SC_Poison;
        barrel.BeginPlay();
    }
}

function vector GetRandomItemPosition()
{
    local DeusExMover d;
    local vector loc;
    local int i;

    for(i=0; i<10; i++) {
        loc = GetRandomPosition();
        loc.X += rngfn() * 25;
        loc.Y += rngfn() * 25;
        d = None;
        foreach RadiusActors(class'DeusExMover', d, 150.0, loc) {
            break;
        }
        if( d == None ) return loc;
    }

    return vect(0,0,0);
}

function RunTests()
{
    local int i, total;
    Super.RunTests();

    total=0;
    for(i=0; i < ArrayCount(enemies); i++ ) {
        total += enemies[i].chance;
    }
    test( total <= 100, "config enemies chances, check total "$total);
    total=0;
    for(i=0; i < ArrayCount(items); i++ ) {
        total += items[i].chance;
    }
    testint( total, 100, "config items chances, check total adds up to 100%");
}
