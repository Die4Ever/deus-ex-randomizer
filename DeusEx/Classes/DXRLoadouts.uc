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
};
var config loadouts item_sets[10];

struct _loadouts
{
    var class<Inventory> ban_types[10];
    var class<Inventory> allow_types[10];
    var class<Inventory> starting_equipment[5];
    var class<Augmentation> starting_augs[5];
};

var _loadouts _item_sets[10];

struct RandomItemStruct { var string type; var int chance; };
struct _RandomItemStruct { var class<Inventory> type; var int chance; };
var config RandomItemStruct randomitems[16];
var _RandomItemStruct _randomitems[16];

function CheckConfig()
{
    local string temp;
    local int i, s;
    local class<Actor> a;
    if( config_version < class'DXRFlags'.static.VersionToInt(1,5,1) ) {
        for(i=0; i < ArrayCount(item_sets); i++) {
            item_sets[i].name = "";
            item_sets[i].player_message = "";
            
            item_sets[i].bans = "";
            item_sets[i].allows = "";
            item_sets[i].starting_equipments = "";
            item_sets[i].starting_augs = "AugSpeed";
        }
        for(i=0; i < ArrayCount(randomitems); i++ ) {
            randomitems[i].type = "";
            randomitems[i].chance = 0;
        }

        item_sets[0].name = "Randomized Loadout with Running Speed";

        item_sets[1].name = "Stick With the Prod";
        item_sets[1].player_message = "stick with the prod!";
        item_sets[1].bans = "Engine.Weapon";
        item_sets[1].allows = "WeaponProd";
        item_sets[1].starting_equipments = "WeaponProd,AmmoBattery,AmmoBattery,AmmoBattery";

        item_sets[2].name = "Stick With the Prod Plus";
        item_sets[2].player_message = "stick with the prod!";
        item_sets[2].bans = "Engine.Weapon,AmmoDart";
        item_sets[2].allows = "WeaponProd,WeaponEMPGrenade,WeaponGasGrenade,WeaponMiniCrossbow,AmmoDartPoison,WeaponNanoVirusGrenade,WeaponPepperGun";
        item_sets[2].starting_equipments = "WeaponProd,AmmoBattery";

        item_sets[3].name = "Ninja JC";
        item_sets[3].player_message = "I am Ninja!";
        item_sets[3].bans = "Engine.Weapon";
        item_sets[3].allows = "WeaponSword,WeaponShuriken";
        item_sets[3].starting_equipments = "WeaponShuriken,WeaponSword,AmmoShuriken,AmmoShuriken";
        //item_sets[3].starting_augs = "AugNinja";//combines (passive?) AugStealth and active AugSpeed?

        item_sets[4].name = "Don't Give Me The GEP Gun";
        item_sets[4].player_message = "Don't Give Me The GEP Gun";
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

function string GetName(int i)
{
    if( i < 0 || i >= ArrayCount(item_sets) ) return "";
    return item_sets[i].name;
}

function AnyEntry()
{
    Super.AnyEntry();
    loadout = dxr.flags.loadout;
}

function bool is_banned(_loadouts b, Inventory item)
{
    local int i;

    for(i=0; i < ArrayCount(b.allow_types); i++ ) {
        if( b.allow_types[i] != None && item.IsA(b.allow_types[i].name) ) {
            return false;
        }
    }

    for(i=0; i < ArrayCount(b.ban_types); i++ ) {
        if( b.ban_types[i] != None && item.IsA(b.ban_types[i].name) ) {
            return true;
        }
    }

    return false;
}

function bool ban(DeusExPlayer player, Inventory item)
{
    if ( is_banned( _item_sets[loadout], item) ) {
        if( item_sets[loadout].player_message != "" ) {
            item.ItemName = item.ItemName $ ", " $ item_sets[loadout].player_message;
        }
        return true;
    }
}

function FirstEntry()
{
    Super.FirstEntry();

    if( dxr.localURL == "01_NYC_UNATCOISLAND" ) {
        RandoStartingEquipment(dxr.player);
    }
}

function AddStartingEquipment(Pawn p)
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

        GiveItem( p, iclass );
    }

    for(i=0; i < ArrayCount(_item_sets[loadout].starting_augs); i++) {
        aclass = _item_sets[loadout].starting_augs[i];
        if( aclass == None ) continue;
        class'DXRAugmentations'.static.AddAug( dxr.player, aclass, dxr.flags.speedlevel );
    }
}

function RandoStartingEquipment(DeusExPlayer player)
{
    local Inventory item, anItem;
    local DXREnemies dxre;
    local int i;

    if( dxr.flags.equipment == 0 ) return;

    l("RandoStartingEquipment");
    dxr.SetSeed( dxr.Crc(dxr.seed $ " RandoStartingEquipment") );//independent of map/mission

    dxr.player.energy = rng(75)+25;
    dxr.player.Credits = rng(200);

    dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));

    item = player.Inventory;
    while(item != None)
    {
        anItem = item;
        item = item.Inventory;
        if( NanoKeyRing(anItem) != None ) continue;
        if( dxre == None && DeusExWeapon(anItem) != None ) continue;
        if( dxre == None && Ammo(anItem) != None ) continue;
        player.DeleteInventory(anItem);
        anItem.Destroy();
    }

    AddStartingEquipment(player);

    for(i=0; i < dxr.flags.equipment; i++) {
        _RandoStartingEquipment(player, dxre);
    }
}

function _RandoStartingEquipment(DeusExPlayer player, DXREnemies dxre)
{
    local int i, r;
    local Inventory item;
    local class<Inventory> iclass;

    if(dxre != None) {
        dxre.GiveRandomWeapon(player);
        dxre.GiveRandomMeleeWeapon(player);
    }

    r = initchance();
    for(i=0; i < ArrayCount(_randomitems); i++ ) {
        if( _randomitems[i].type == None ) continue;
        if( chance( _randomitems[i].chance, r ) ) iclass = _randomitems[i].type;
    }

    if( iclass == None ) return;
    GiveItem(player, iclass);
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
