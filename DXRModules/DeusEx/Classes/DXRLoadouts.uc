class DXRLoadouts extends DXRActorsBase;

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
var config loadouts item_sets[10];

struct _loadouts
{
    var class<Inventory>    ban_types[10];
    var class<Inventory>    allow_types[10];
    var class<Inventory>    starting_equipment[5];
    var class<Augmentation> starting_augs[5];
    var class<Actor>        item_spawns[5];
    var int                 item_spawns_chances[5];
};

var _loadouts _item_sets[10];

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
    if( ConfigOlderThan(1,6,4,7) ) {
        mult_items_per_level = 1;

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
        //item_sets[1].item_spawns = "CrateExplosiveSmall,2";

        item_sets[2].name = "Stick With the Prod Plus";
        item_sets[2].player_message = "Stick with the prod!";
        item_sets[2].bans = "Engine.Weapon,AmmoDart";
        item_sets[2].allows = "WeaponProd,WeaponEMPGrenade,WeaponGasGrenade,WeaponMiniCrossbow,AmmoDartPoison,WeaponNanoVirusGrenade,WeaponPepperGun";
        item_sets[2].starting_equipments = "WeaponProd,AmmoBattery";
        item_sets[2].starting_augs = "AugStealth,AugMuscle";
        //item_sets[2].item_spawns = "CrateExplosiveSmall,2";

        item_sets[3].name = "Ninja JC";
        item_sets[3].player_message = "I am Ninja!";
        item_sets[3].bans = "Engine.Weapon";
        item_sets[3].allows = "WeaponSword,WeaponNanoSword,WeaponShuriken,WeaponEMPGrenade,WeaponGasGrenade,WeaponNanoVirusGrenade,WeaponPepperGun,WeaponLAM";
        item_sets[3].starting_equipments = "WeaponShuriken,WeaponSword,AmmoShuriken";
#ifdef vanilla
        item_sets[3].starting_augs = "AugNinja";//combines AugStealth and active AugSpeed
#else
        item_sets[3].starting_augs = "#var package .AugNinja";//combines AugStealth and active AugSpeed
#endif
        item_sets[3].item_spawns = "WeaponShuriken,5,BioelectricCell,2";

        item_sets[4].name = "Don't Give Me the GEP Gun";
        item_sets[4].player_message = "Don't Give Me the GEP Gun";
        item_sets[4].bans = "WeaponGEPGun";

        item_sets[5].name = "Freeman Mode";
        item_sets[5].player_message = "Rather than offer you the illusion of free choice, I will take the liberty of choosing for you...";
        item_sets[5].bans = "Engine.Weapon";
        item_sets[5].allows = "WeaponCrowbar";
        item_sets[5].starting_equipments = "WeaponCrowbar";

        item_sets[6].name = "Grenades Only";
        item_sets[6].player_message = "Grenades Only";
        item_sets[6].bans = "Engine.Weapon";
        item_sets[6].allows = "WeaponLAM,WeaponGasGrenade,WeaponNanoVirusGrenade,WeaponEMPGrenade";
        item_sets[6].starting_equipments = "WeaponLAM,WeaponGasGrenade,WeaponNanoVirusGrenade,WeaponEMPGrenade";

        item_sets[7].name = "No Pistols";
        item_sets[7].player_message = "No Pistols";
        item_sets[7].bans = "WeaponPistol,WeaponStealthPistol";

        i=0;

        randomitems[i].type = "Medkit";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "Lockpick";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "Multitool";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "Flare";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "FireExtinguisher";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "SoyFood";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "TechGoggles";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "Binoculars";
        randomitems[i].chance = 10;
        i++;

        randomitems[i].type = "BioelectricCell";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "BallisticArmor";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "WineBottle";
        randomitems[i].chance = 9;
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

    for(i=0; i < ArrayCount(_item_sets[s].ban_types); i++) {
        if( _item_sets[s].ban_types[i] == None ) {
            a = GetClassFromString(type, class'Inventory');
            _item_sets[s].ban_types[i] = class<Inventory>(a);
            return;
        }
    }
}

function AddAllow(int s, string type)
{
    local class<Actor> a;
    local int i;

    if( type == "" ) return;

    for(i=0; i < ArrayCount(_item_sets[s].allow_types); i++) {
        if( _item_sets[s].allow_types[i] == None ) {
            a = GetClassFromString(type, class'Inventory');
            _item_sets[s].allow_types[i] = class<Inventory>(a);
            return;
        }
    }
}

function AddStart(int s, string type)
{
    local class<Actor> a;
    local int i;

    if( type == "" ) return;

    for(i=0; i < ArrayCount(_item_sets[s].starting_equipment); i++) {
        if( _item_sets[s].starting_equipment[i] == None ) {
            a = GetClassFromString(type, class'Inventory');
            _item_sets[s].starting_equipment[i] = class<Inventory>(a);
            return;
        }
    }
}

function AddAug(int s, string type)
{
    local class<Actor> a;
    local int i;

    if( type == "" ) return;

    for(i=0; i < ArrayCount(_item_sets[s].starting_augs); i++) {
        if( _item_sets[s].starting_augs[i] == None ) {
            a = GetClassFromString(type, class'Augmentation');
            _item_sets[s].starting_augs[i] = class<Augmentation>(a);
            return;
        }
    }
}

function AddItemSpawn(int s, string type, int chances)
{
    local class<Actor> a;
    local int i;

    if( type == "" ) return;

    for(i=0; i < ArrayCount(_item_sets[s].item_spawns); i++) {
        if( _item_sets[s].item_spawns[i] == None ) {
            a = GetClassFromString(type, class'Actor');
            _item_sets[s].item_spawns[i] = a;
            _item_sets[s].item_spawns_chances[i] = chances;
            return;
        }
    }
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
        if( c.toName == "JCDenton" && is_banned(_item_sets[loadout], c.giveObject) ) {
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
    return _is_banned( _item_sets[loadout], item);
}

function class<Inventory> get_starting_item()
{
    return _item_sets[loadout].starting_equipment[0];
}

function bool ban(DeusExPlayer player, Inventory item)
{
    if ( _is_banned( _item_sets[loadout], item.class) ) {
        if( item_sets[loadout].player_message != "" ) {
            //item.ItemName = item.ItemName $ ", " $ item_sets[loadout].player_message;
            player.ClientMessage(item_sets[loadout].player_message, 'Pickup', true);
        }
        return true;
    }
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
            ws.anim_speed = 1.3;
            ws.default.anim_speed = 1.3;
            w.ShotTime=0;
            w.default.ShotTime=0;
            w.maxRange = 110;
            w.default.maxRange = 110;
            w.AccurateRange = 110;
            w.default.AccurateRange = 110;
            break;
        case class'WeaponNanoSword':
            ws.blood_mult = 4;
            ws.default.blood_mult = 4;
            w.ShotTime=0;
            w.default.ShotTime=0;
            w.maxRange = 110;
            w.default.maxRange = 110;
            w.AccurateRange = 110;
            w.default.AccurateRange = 110;
            break;
        case class'WeaponShuriken':
            ws.anim_speed = 1.3;
            ws.default.anim_speed = 1.3;
            break;
    }
#endif
}

function FirstEntry()
{
    Super.FirstEntry();

    SpawnItems();
}

simulated function PlayerLogin(#var PlayerPawn  p)
{
    Super.PlayerLogin(p);
    RandoStartingEquipment(p, false);
}

simulated function PlayerRespawn(#var PlayerPawn  p)
{
    Super.PlayerRespawn(p);
    RandoStartingEquipment(p, true);
}

function bool StartedWithAug(class<Augmentation> a)
{
    local class<Augmentation> aclass;
    local int i;
    for(i=0; i < ArrayCount(_item_sets[loadout].starting_augs); i++) {
        aclass = _item_sets[loadout].starting_augs[i];
        if( aclass == None ) continue;
        if( aclass == a ) return true;

        if( a.default.AugmentationLocation == LOC_Default )
            return true;

        //speed, stealth, ninja, muscle...
        if( aclass.default.AugmentationLocation == a.default.AugmentationLocation ) {
            if( class'#var prefix AugmentationManager'.default.AugLocs[a.default.AugmentationLocation].NumSlots == 1 )
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

    for(i=0; i < ArrayCount(_item_sets[loadout].starting_equipment); i++) {
        iclass = _item_sets[loadout].starting_equipment[i];
        if( iclass == None ) continue;

        if( class<DeusExAmmo>(iclass) == None && class'DXRActorsBase'.static.HasItem(p, iclass) )
            continue;

        item = GiveItem( p, iclass );
        if( bFrob && item != None ) item.Frob( p, None );
    }

    for(i=0; i < ArrayCount(_item_sets[loadout].starting_augs); i++) {
        aclass = _item_sets[loadout].starting_augs[i];
        if( aclass == None ) continue;
        class'DXRAugmentations'.static.AddAug( p, aclass, dxr.flags.settings.speedlevel );
    }
}

function RandoStartingEquipment(DeusExPlayer player, bool respawn)
{
    local Inventory item, anItem;
    local DXREnemies dxre;
    local int i;

    if( dxr.flags.settings.equipment == 0 ) return;
    if( dxr.dxInfo.missionNumber == 0 ) return;

    l("RandoStartingEquipment");
    SetGlobalSeed("RandoStartingEquipment");//independent of map/mission

    player.energy = rng(75)+25;
    player.Credits = rng(200);

    dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));

    item = player.Inventory;
    while(item != None)
    {
        anItem = item;
        item = item.Inventory;
        l("RandoStartingEquipment("$player$") checking item "$anItem$", bDisplayableInv: "$anItem.bDisplayableInv);
        if( Ammo(anItem) == None && ! anItem.bDisplayableInv ) continue;
        if( #var prefix NanoKeyRing(anItem) != None ) continue;
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

    for(i=0; i < dxr.flags.settings.equipment; i++) {
        _RandoStartingEquipment(player, dxre, respawn);
    }
}

function _RandoStartingEquipment(DeusExPlayer player, DXREnemies dxre, bool bFrob)
{
    local int i;
    local float r;
    local Inventory item;
    local DeusExWeapon w;
    local class<Inventory> iclass;

    if(dxre != None) {
        item = dxre.GiveRandomWeapon(player, true);
        if( bFrob && item != None ) item.Frob( player, None );
        w = DeusExWeapon(item);
        if ( w != None && (w.AmmoName != None) && (w.AmmoName != Class'AmmoNone') )
        {
            w.AmmoType = DeusExAmmo(GiveItem(player, w.AmmoName));
            if( bFrob && w.AmmoType != None )
                w.AmmoType.Frob( player, None );
        }

        item = dxre.GiveRandomMeleeWeapon(player);
        if( bFrob && item != None ) item.Frob( player, None );
    }

    r = initchance();
    for(i=0; i < ArrayCount(_randomitems); i++ ) {
        if( _randomitems[i].type == None ) continue;
        if( chance( _randomitems[i].chance, r ) ) iclass = _randomitems[i].type;
    }

    if( iclass == None ) return;
    item = GiveItem(player, iclass);
    if( bFrob && item != None ) item.Frob( player, None );
}

function SpawnItems()
{
    local vector loc;
    local Actor a;
    local class<Actor> aclass;
    local DXRReduceItems reducer;
    local int i, j, chance;
    l("SpawnItems()");
    SetSeed("SpawnItems()");

    reducer = DXRReduceItems(dxr.FindModule(class'DXRReduceItems'));

    for(i=0;i<ArrayCount(_item_sets[loadout].item_spawns);i++) {
        aclass = _item_sets[loadout].item_spawns[i];
        if( aclass == None ) continue;
        chance = _item_sets[loadout].item_spawns_chances[i];
        if( chance <= 0 ) continue;

        for(j=0;j<mult_items_per_level*chance*2;j++) {
            if( chance_single(50) ) {
                loc = GetRandomPositionFine();
                a = Spawn(aclass,,, loc);
                if( reducer != None && a != None )
                    reducer.ReduceItem(a);
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
