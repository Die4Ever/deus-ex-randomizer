class DXRLoadouts extends DXRActorsBase transient;

var int loadout;//copy locally so we don't need to make this class transient and don't need to worry about re-entering and picking up an item before DXRando loads

struct loadouts
{
    var string name;
    var string player_message;

    var string bans;
    var string allows;
    var string starting_equipments;
    var string starting_augs;
    var string item_spawns;
};
var config loadouts item_sets[20];
var config int loadouts_order[20];

struct _loadouts
{
    var class<Inventory>    ban_types[10];
    var class<Inventory>    allow_types[10];
    var class<Inventory>    starting_equipment[5];
    var class<Augmentation> starting_augs[5];
    var class<Actor>        item_spawns[10];
    var int                 item_spawns_chances[10];// the % spawned in each map, max of 300%
};

var _loadouts __item_sets[20];

struct RandomItemStruct { var string type; var int chance; };
struct _RandomItemStruct { var class<Inventory> type; var int chance; };
var config RandomItemStruct randomitems[16];
var _RandomItemStruct _randomitems[16];

var config int mult_items_per_level;

replication
{
    reliable if( Role == ROLE_Authority )
        loadout, mult_items_per_level;
}

function CheckConfig()
{
    local string temp;
    local int i, s;
    local class<Actor> a;
    if( ConfigOlderThan(2,6,2,4) ) {
        mult_items_per_level = 1;

        for(i=0; i < ArrayCount(loadouts_order); i++) {
            loadouts_order[i] = i;
        }
        i=0;
        loadouts_order[i++] = 0;
        loadouts_order[i++] = 2;
        loadouts_order[i++] = 1;
        loadouts_order[i++] = 3;
        loadouts_order[i++] = 10;
        loadouts_order[i++] = 9;
        loadouts_order[i++] = 4;
        loadouts_order[i++] = 7;
        loadouts_order[i++] = 8;
        loadouts_order[i++] = 6;
        loadouts_order[i++] = 5;

        for(i=0; i < ArrayCount(item_sets); i++) {
            item_sets[i].name = "";
            item_sets[i].player_message = "";

            item_sets[i].bans = "";
            item_sets[i].allows = "";
            item_sets[i].starting_equipments = "";
            item_sets[i].starting_augs = "AugSpeed";
            item_sets[i].item_spawns = "";
        }
        for(i=0; i < ArrayCount(randomitems); i++ ) {
            randomitems[i].type = "";
            randomitems[i].chance = 0;
        }

        item_sets[0].name = "All Items Allowed";

        item_sets[1].name = "Stick With the Prod Pure";
        item_sets[1].player_message = "Stick with the prod!";
        item_sets[1].bans = "Engine.Weapon";
        item_sets[1].allows = "WeaponProd";
        item_sets[1].starting_equipments = "WeaponProd,AmmoBattery,AmmoBattery";
        item_sets[1].starting_augs = "AugStealth,AugMuscle";
        item_sets[1].item_spawns = "WeaponProd,30";

        item_sets[2].name = "Stick With the Prod Plus";
        item_sets[2].player_message = "Stick with the prod!";
        item_sets[2].bans = "Engine.Weapon,AmmoDart";
        item_sets[2].allows = "WeaponProd,WeaponEMPGrenade,WeaponGasGrenade,WeaponMiniCrossbow,AmmoDartPoison,WeaponNanoVirusGrenade,WeaponPepperGun,#var(package).WeaponRubberBaton";
        item_sets[2].starting_equipments = "WeaponProd,AmmoBattery,#var(package).WeaponRubberBaton";
        item_sets[2].starting_augs = "AugStealth,AugMuscle";
        item_sets[2].item_spawns = "WeaponProd,30,WeaponMiniCrossbow,30,#var(package).WeaponRubberBaton,20";

        item_sets[3].name = "Ninja JC";
        item_sets[3].player_message = "I am Ninja!";
        item_sets[3].bans = "Engine.Weapon";
        item_sets[3].allows = "WeaponSword,WeaponNanoSword,WeaponShuriken,WeaponEMPGrenade,WeaponGasGrenade,WeaponNanoVirusGrenade,WeaponPepperGun,WeaponLAM,WeaponMiniCrossbow,WeaponCombatKnife";
        item_sets[3].starting_equipments = "WeaponShuriken,WeaponSword,AmmoShuriken";
#ifdef vanilla
        item_sets[3].starting_augs = "AugNinja";//combines AugStealth and active AugSpeed
#else
        item_sets[3].starting_augs = "#var(package).AugNinja";//combines AugStealth and active AugSpeed
#endif
        item_sets[3].item_spawns = "WeaponShuriken,150,BioelectricCell,100";

        item_sets[4].name = "Don't Give Me the GEP Gun";
        item_sets[4].player_message = "Don't Give Me the GEP Gun";
        item_sets[4].bans = "WeaponGEPGun";

        item_sets[5].name = "Freeman Mode";
        item_sets[5].player_message = "Rather than offer you the illusion of free choice, I will take the liberty of choosing for you...";
        item_sets[5].bans = "Engine.Weapon";
        item_sets[5].allows = "WeaponCrowbar";
        item_sets[5].starting_equipments = "WeaponCrowbar";

        item_sets[6].name = "Grenades Only";
        item_sets[6].player_message = "Grenades Only!";
        item_sets[6].bans = "Engine.Weapon";
        item_sets[6].allows = "WeaponLAM,WeaponGasGrenade,WeaponNanoVirusGrenade,WeaponEMPGrenade,#var(package).WeaponRubberBaton";
        item_sets[6].starting_equipments = "WeaponLAM,WeaponGasGrenade,WeaponNanoVirusGrenade,WeaponEMPGrenade,#var(package).WeaponRubberBaton";
        item_sets[6].item_spawns = "WeaponLAM,50,WeaponGasGrenade,50,WeaponNanoVirusGrenade,50,WeaponEMPGrenade,50,#var(package).WeaponRubberBaton,20";

        item_sets[7].name = "No Pistols";
        item_sets[7].player_message = "No Pistols";
        item_sets[7].bans = "WeaponPistol,WeaponStealthPistol";

        item_sets[8].name = "No Swords";
        item_sets[8].player_message = "No Swords";
        item_sets[8].bans = "WeaponSword,WeaponNanoSword";

        item_sets[9].name = "No Overpowered Weapons";
        item_sets[9].player_message = "No Overpowered Weapons";
        item_sets[9].bans = "WeaponSword,WeaponNanoSword,WeaponPistol,WeaponStealthPistol,WeaponGEPGun,WeaponPepperGun";

        item_sets[10].name = "By the Book";
        item_sets[10].player_message = "By the Book";
        item_sets[10].bans = "Lockpick,Multitool";
        item_sets[10].starting_augs = "AugStealth";

        item_sets[11].name = "Explosives Only";
        item_sets[11].player_message = "Explosives Only!";
        item_sets[11].bans = "Engine.Weapon,Ammo762mm";
        item_sets[11].allows =
            "WeaponGEPGun,WeaponLAW,WeaponLAM,WeaponEMPGrenade,WeaponGasGrenade," $
            "WeaponNanoVirusGrenade,WeaponAssaultGun,#var(package).WeaponRubberBaton";
        item_sets[11].starting_equipments = "WeaponGEPGun,#var(package).WeaponRubberBaton";
        item_sets[11].item_spawns =
            "WeaponLAW,75,WeaponLAM,100,WeaponEMPGrenade,75,WeaponGasGrenade,75," $
            "WeaponNanoVirusGrenade,75,#var(package).WeaponRubberBaton,20,AmmoRocket,100,AmmoRocketWP,100,Ammo20mm,100";

        i=0;

        randomitems[i].type = "Medkit";
        randomitems[i].chance = 10;
        i++;

        randomitems[i].type = "Lockpick";
        randomitems[i].chance = 11;
        i++;

        randomitems[i].type = "Multitool";
        randomitems[i].chance = 11;
        i++;

        randomitems[i].type = "Flare";
        randomitems[i].chance = 7;
        i++;

        randomitems[i].type = "FireExtinguisher";
        randomitems[i].chance = 8;
        i++;

        randomitems[i].type = "SoyFood";
        randomitems[i].chance = 7;
        i++;

        randomitems[i].type = "TechGoggles";
        randomitems[i].chance = 9;
        i++;

        if(#defined(hx))
            randomitems[i].type = "#var(injectsprefix)Binoculars";
        else
            randomitems[i].type = "Binoculars";
        randomitems[i].chance = 10;
        i++;

        randomitems[i].type = "BioelectricCell";
        randomitems[i].chance = 11;
        i++;

        randomitems[i].type = "BallisticArmor";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "WineBottle";
        randomitems[i].chance = 7;
        i++;
    }
    Super.CheckConfig();

    for(s=0; s < ArrayCount(item_sets); s++) {
        temp = item_sets[s].bans;
        while( temp != "" ) {
            AddBan(s, UnpackString(temp) );
        }

        temp = item_sets[s].allows;
        while( temp != "" ) {
            AddAllow(s, UnpackString(temp) );
        }

        temp = item_sets[s].starting_equipments;
        while( temp != "" ) {
            AddStart(s, UnpackString(temp) );
        }

        temp = item_sets[s].starting_augs;
        while( temp != "" ) {
            AddAug(s, UnpackString(temp) );
        }

        temp = item_sets[s].item_spawns;
        while( temp != "" ) {
            AddItemSpawn(s, UnpackString(temp), int(UnpackString(temp)));
        }
    }

    for(i=0; i < ArrayCount(randomitems); i++) {
        if( randomitems[i].type != "" ) {
            a = GetClassFromString(randomitems[i].type, class'Inventory');
            _randomitems[i].type = class<Inventory>(a);
            _randomitems[i].chance = randomitems[i].chance;
        }
    }

    loadout = dxr.flags.loadout;
}

function AddBan(int s, string type)
{
    local class<Actor> a;
    local int i;

    if( type == "" ) return;

    for(i=0; i < ArrayCount(__item_sets[s].ban_types); i++) {
        if( __item_sets[s].ban_types[i] == None ) {
            a = GetClassFromString(type, class'Inventory');
            __item_sets[s].ban_types[i] = class<Inventory>(a);
            return;
        }
    }
}

function AddAllow(int s, string type)
{
    local class<Actor> a;
    local int i;

    if( type == "" ) return;

    for(i=0; i < ArrayCount(__item_sets[s].allow_types); i++) {
        if( __item_sets[s].allow_types[i] == None ) {
            a = GetClassFromString(type, class'Inventory');
            __item_sets[s].allow_types[i] = class<Inventory>(a);
            return;
        }
    }
}

function AddStart(int s, string type)
{
    local class<Actor> a;
    local int i;

    if( type == "" ) return;

    for(i=0; i < ArrayCount(__item_sets[s].starting_equipment); i++) {
        if( __item_sets[s].starting_equipment[i] == None ) {
            a = GetClassFromString(type, class'Inventory');
            __item_sets[s].starting_equipment[i] = class<Inventory>(a);
            return;
        }
    }
}

function AddAug(int s, string type)
{
    local class<Actor> a;
    local int i;

    if( type == "" ) return;

    for(i=0; i < ArrayCount(__item_sets[s].starting_augs); i++) {
        if( __item_sets[s].starting_augs[i] == None ) {
            a = GetClassFromString(type, class'Augmentation');
            __item_sets[s].starting_augs[i] = class<Augmentation>(a);
            return;
        }
    }
}

function AddItemSpawn(int s, string type, int chances)
{
    local class<Actor> a;
    local int i;

    if( type == "" ) return;

    for(i=0; i < ArrayCount(__item_sets[s].item_spawns); i++) {
        if( __item_sets[s].item_spawns[i] == None ) {
            a = GetClassFromString(type, class'Actor');
            __item_sets[s].item_spawns[i] = a;
            __item_sets[s].item_spawns_chances[i] = chances;
            return;
        }
    }
}

function int GetIdForSlot(int i)
{
    if( i < 0 || i >= ArrayCount(loadouts_order) ) return -1;
    return loadouts_order[i];
}

function string GetName(int i)
{
    if( i < 0 || i >= ArrayCount(item_sets) ) return "";
    return item_sets[i].name;
}

function AnyEntry()
{
    local ConEventTransferObject c;

    Super.AnyEntry();
    loadout = dxr.flags.loadout;

#ifndef injections
    // TODO: fix being given items from conversations for other mods
    /*foreach AllObjects(class'ConEventTransferObject', c) {
        l(c.objectName @ c.giveObject @ c.toName);
        if( c.toName == "JCDenton" && is_banned(__item_sets[loadout], c.giveObject) ) {
            l(c.objectName @ c.giveObject @ c.toName $ ", clearing");
            c.toName = "";
            c.toActor = None;
            c.failLabel = "";
        }
    }*/
#endif
}

function bool _is_banned(_loadouts b, class<Inventory> item)
{
    local int i;

    for(i=0; i < ArrayCount(b.allow_types); i++ ) {
        if( b.allow_types[i] != None && ClassIsChildOf(item, b.allow_types[i]) ) {
            return false;
        }
    }

    for(i=0; i < ArrayCount(b.ban_types); i++ ) {
        if( b.ban_types[i] != None && ClassIsChildOf(item, b.ban_types[i]) ) {
            return true;
        }
    }

    return false;
}

function bool is_banned(class<Inventory> item)
{
    return _is_banned( __item_sets[loadout], item);
}

function class<Inventory> get_starting_item()
{
    return __item_sets[loadout].starting_equipment[0];
}

function bool ban(DeusExPlayer player, Inventory item)
{
    local bool bFixGlitches;

    if(IsMeleeWeapon(item) && Carcass(item.Owner) != None && player.FindInventoryType(item.class) != None) {
        return true;
    } else if ( _is_banned( __item_sets[loadout], item.class) ) {
        if( item_sets[loadout].player_message != "" ) {
            //item.ItemName = item.ItemName $ ", " $ item_sets[loadout].player_message;
            player.ClientMessage(item_sets[loadout].player_message, 'Pickup', true);
        }
        return true;
    } else if(item.bDeleteMe) {
        if(class'MenuChoice_FixGlitches'.default.enabled) {
            return true;
        }
        else {
            //Only try to detect duping on items that aren't banned anyway
            //Banned things will get marked for deletion, but might not be gone
            //if you frob multiple times kind of quickly, giving a false positive
            class'DXRStats'.static.AddCheatOffense(player);
        }
    }

    return false;
}

function AdjustWeapon(DeusExWeapon w)
{
    switch( item_sets[loadout].name ) {
        case "Ninja JC":
            NinjaAdjustWeapon(w);
            break;
    }
}

function NinjaAdjustWeapon(DeusExWeapon w)
{
#ifdef injections
    local DXRWeapon ws;
    ws = DXRWeapon(w);
    class'Shuriken'.default.blood_mult = 2;
    switch(w.Class) {
        case class'WeaponSword':
            ws.blood_mult = 3;
            ws.default.blood_mult = 3;
            ws.anim_speed = 1.2;
            ws.default.anim_speed = 1.2;
            w.ShotTime=0.01;
            w.default.ShotTime=0.01;
            w.maxRange = 110;
            w.default.maxRange = 110;
            w.AccurateRange = 110;
            w.default.AccurateRange = 110;
            break;
        case class'WeaponNanoSword':
            ws.blood_mult = 4;
            ws.default.blood_mult = 4;
            w.ShotTime=0.01;
            w.default.ShotTime=0.01;
            w.maxRange = 110;
            w.default.maxRange = 110;
            w.AccurateRange = 110;
            w.default.AccurateRange = 110;
            break;
        case class'WeaponShuriken':
            ws.anim_speed = 1.1;
            ws.default.anim_speed = 1.1;
            WeaponShuriken(ws).auto_pickup = true;
            //ws.DrawScale = 2;
            ws.SetCollisionSize(16, ws.default.CollisionHeight*2);
            break;
        default:
            ws.blood_mult = 2;
    }
#endif
}

function FirstEntry()
{
    Super.FirstEntry();

    SpawnItems();
}

simulated function PlayerLogin(#var(PlayerPawn) p)
{
    Super.PlayerLogin(p);
    RandoStartingEquipment(p, false);
}

simulated function PlayerRespawn(#var(PlayerPawn) p)
{
    Super.PlayerRespawn(p);
    RandoStartingEquipment(p, true);
}

function bool StartedWithAug(class<Augmentation> a)
{
    local class<Augmentation> aclass;
    local int i;
    for(i=0; i < ArrayCount(__item_sets[loadout].starting_augs); i++) {
        aclass = __item_sets[loadout].starting_augs[i];
        if( aclass == None ) continue;
        if( aclass == a ) return true;

        if( a.default.AugmentationLocation == LOC_Default )
            return true;

        //speed, stealth, ninja, muscle...
        if( aclass.default.AugmentationLocation == a.default.AugmentationLocation ) {
            if( class'#var(prefix)AugmentationManager'.default.AugLocs[a.default.AugmentationLocation].NumSlots == 1 )
                return true;
        }
    }
    return false;
}

function AddStartingEquipment(DeusExPlayer p, bool bFrob)
{
    local class<Inventory> iclass;
    local class<Augmentation> aclass;
    local Inventory item;
    local Ammo a;
    local DeusExWeapon w;
    local int i, k;

    for(i=0; i < ArrayCount(__item_sets[loadout].starting_equipment); i++) {
        iclass = __item_sets[loadout].starting_equipment[i];
        if( iclass == None ) continue;

        if( class<DeusExAmmo>(iclass) == None && class'DXRActorsBase'.static.HasItem(p, iclass) )
            continue;

        item = GiveItem( p, iclass );
        if( bFrob && item != None ) item.Frob( p, None );
    }

    for(i=0; i < ArrayCount(__item_sets[loadout].starting_augs); i++) {
        aclass = __item_sets[loadout].starting_augs[i];
        if( aclass == None ) continue;
        class'DXRAugmentations'.static.AddAug( p, aclass, dxr.flags.settings.speedlevel );
    }
}

function RandoStartingEquipment(#var(PlayerPawn) player, bool respawn)
{
    local Inventory item, anItem;
    local DXREnemies dxre;
    local int i, start_amount;

    if( dxr.flags.settings.equipment == 0 ) return;
    if( dxr.dxInfo.missionNumber == 0 ) return;

    l("RandoStartingEquipment");
    SetGlobalSeed("RandoStartingEquipment");//independent of map/mission

    start_amount = dxr.flags.settings.equipment;

    if (dxr.flags.settings.starting_map != 0) {
        start_amount += 1 + dxr.flags.settings.starting_map / 30;
    }

    dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));

    item = player.Inventory;
    while(item != None)
    {
        anItem = item;
        item = item.Inventory;
        l("RandoStartingEquipment("$player$") checking item "$anItem$", bDisplayableInv: "$anItem.bDisplayableInv);
        if( Ammo(anItem) == None && ! anItem.bDisplayableInv ) continue;
        if( #var(prefix)NanoKeyRing(anItem) != None ) continue;
        if( dxre == None && Weapon(anItem) != None ) continue;
        if( dxre == None && Ammo(anItem) != None ) continue;
        l("RandoStartingEquipment("$player$") removing item: "$anItem);
        player.DeleteInventory(anItem);
        anItem.Destroy();
    }

#ifdef gmdx
    player.RepairInventory();
#endif
    AddStartingEquipment(player, respawn);

    for(i=0; i < start_amount; i++) {
        _RandoStartingEquipment(player, dxre, respawn);
    }

    class'DXRStartMap'.static.AddStartingAugs(dxr,player);
}

function Inventory _GiveRandoStartingItem(#var(PlayerPawn) player, Inventory item, bool bFrob)
{
    local DeusExWeapon w;

    if(item == None) return None;

    if(is_banned(item.class)) {
        info("_RandoStartingEquipment " $item$" is banned!");
        item.Destroy();
        return None;
    }

    if( bFrob ) {
        item.SetLocation(player.Location);
        item.Frob( player, None );
    }

    w = DeusExWeapon(item);
    if ( w != None && (w.AmmoName != None) && (w.AmmoName != Class'AmmoNone') )
    {
        w.AmmoType = DeusExAmmo(GiveItem(player, w.AmmoName));
        if( bFrob && w.AmmoType != None )
            w.AmmoType.Frob( player, None );
    }
    return item;
}

function class<Inventory> _GetRandomUtilityItem()
{
    local int i;
    local float r;
    local class<Inventory> iclass;

    r = initchance();
    for(i=0; i < ArrayCount(_randomitems); i++ ) {
        if( _randomitems[i].type == None ) continue;
        if( chance( _randomitems[i].chance, r ) ) iclass = _randomitems[i].type;
    }
    return iclass;
}

function _RandoStartingEquipment(#var(PlayerPawn) player, DXREnemies dxre, bool bFrob)
{
    local int i;
    local Inventory item;
    local class<Inventory> iclass;

    if(dxre != None) {
        for(i=0; i<100; i++) {
            iclass = dxre.GiveRandomWeaponClass(player, true);
            if(iclass == None || is_banned(iclass)) continue;
            item = GiveItem(player, iclass);
            item = _GiveRandoStartingItem(player, item, bFrob);
            if(item != None) break;
        }

        for(i=0; i<100; i++) {
            iclass = dxre.GiveRandomMeleeWeaponClass(player, false);
            if(iclass == None || is_banned(iclass)) continue;
            item = GiveItem(player, iclass);
            item = _GiveRandoStartingItem(player, item, bFrob);
            if(item != None) break;
        }
    }

    for(i=0; i<100; i++) {
        iclass = _GetRandomUtilityItem();
        if(iclass == None) continue;
        if(is_banned(iclass)) continue;
        item = GiveItem(player, iclass);
        item = _GiveRandoStartingItem(player, item, bFrob);
        if(item != None) break;
    }
}

function SpawnItems()
{
    local vector loc;
    local Actor a;
    local class<Actor> aclass;
    local DXRReduceItems reducer;
    local int i, j, chance, max;
    l("SpawnItems()");
    SetSeed("SpawnItems()");

    reducer = DXRReduceItems(dxr.FindModule(class'DXRReduceItems'));

    for(i=0;i<ArrayCount(__item_sets[loadout].item_spawns);i++) {
        aclass = __item_sets[loadout].item_spawns[i];
        if( aclass == None ) continue;
        chance = __item_sets[loadout].item_spawns_chances[i];
        if( chance <= 0 ) continue;

        chance /= 3;
        if(chance <= 0) chance=1;
        for(j=0;j<mult_items_per_level*3;j++) {
            if( chance_single(chance) ) {
                loc = GetRandomPositionFine();
                a = Spawn(aclass,,, loc);
                l("SpawnItems() spawned "$a$" at "$loc);
                if( reducer != None && Inventory(a) != None )
                    reducer.ReduceItem(Inventory(a));
            }
        }
    }

    if( reducer != None )
        reducer.Timer();
}

function RunTests()
{
    local int i, total;
    Super.RunTests();

    total=0;
    for(i=0; i < ArrayCount(randomitems); i++ ) {
        total += randomitems[i].chance;
    }
    test( total <= 100, "config randomitems chances, check total "$total);
}
