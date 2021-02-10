class DXRBannedItems extends DXRBase;

var int banneditems;//copy locally so we don't need to make this class transient and don't need to worry about re-entering and picking up an item before DXRando loads

struct bans
{
    var string name;
    var string player_message;

    var string bans;
    var string allows;
    var string starting_equipments;
};
var config bans item_sets[10];

struct _bans
{
    var class<Inventory> ban_types[10];
    var class<Inventory> allow_types[10];
    var class<Inventory> starting_equipment[5];
};

var _bans _item_sets[10];

function CheckConfig()
{
    local string temp;
    local int i, s;
    local class<Actor> a;
    if( config_version < class'DXRFlags'.static.VersionToInt(1,5,1) ) {
        config_version = 0;
        for(i=0; i < ArrayCount(item_sets); i++) {
            item_sets[i].name = "";
            item_sets[i].player_message = "";
            
            item_sets[i].bans = "";
            item_sets[i].allows = "";
            item_sets[i].starting_equipments = "";
        }

        item_sets[0].name = "No items banned";

        item_sets[1].name = "Stick With the Prod";
        item_sets[1].player_message = "Stick with the prod!";
        item_sets[1].bans = "Engine.Weapon";
        item_sets[1].allows = "WeaponProd";
        item_sets[1].starting_equipments = "WeaponProd";

        item_sets[2].name = "Stick With the Prod Plus";
        item_sets[2].player_message = "Stick with the prod!";
        item_sets[2].bans = "Engine.Weapon,AmmoDart";
        item_sets[2].allows = "WeaponProd,WeaponEMPGrenade,WeaponGasGrenade,WeaponMiniCrossbow,AmmoDartPoison,WeaponNanoVirusGrenade,WeaponPepperGun";
        item_sets[2].starting_equipments = "WeaponProd";

        item_sets[3].name = "Ninja JC";
        item_sets[3].player_message = "I am Ninja";
        item_sets[3].bans = "Engine.Weapon";
        item_sets[3].allows = "WeaponSword,WeaponShuriken";
        item_sets[3].starting_equipments = "WeaponShuriken,WeaponSword,AmmoShuriken,AmmoShuriken,AmmoShuriken";

        item_sets[4].name = "Don't Give Me The GEP Gun";
        item_sets[4].player_message = "Don't Give Me The GEP Gun";
        item_sets[4].bans = "WeaponGEPGun";
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
    }

    banneditems = dxr.flags.banneditems;
}

function AddBan(int s, string type)
{
    local class<Actor> a;
    local int i;

    if( type == "" ) return;

    for(i=0; i < ArrayCount(_item_sets[s].ban_types); i++) {
        if( _item_sets[s].ban_types[i] == None ) {
            a = GetClassFromString(type, class'Inventory');
            l("AddBan "$s$", "$i$", "$a);
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
            l("AddAllow "$s$", "$i$", "$a);
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
            l("AddStart "$s$", "$i$", "$a);
            _item_sets[s].starting_equipment[i] = class<Inventory>(a);
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
    banneditems = dxr.flags.banneditems;
}

function bool is_banned(_bans b, Inventory item)
{
    local int i;

    for(i=0; i < ArrayCount(b.allow_types); i++ ) {
        //l("is_banned allow_types["$i$"] == "$b.allow_types[i]);
        if( b.allow_types[i] != None && item.IsA(b.allow_types[i].name) ) {
            return false;
        }
    }

    for(i=0; i < ArrayCount(b.ban_types); i++ ) {
        //l("is_banned ban_types["$i$"] == "$b.ban_types[i]);
        if( b.ban_types[i] != None && item.IsA(b.ban_types[i].name) ) {
            return true;
        }
    }

    return false;
}

function bool ban(DeusExPlayer player, Inventory item)
{
    //l("is_banned( "$banneditems$", "$item$")");
    if ( is_banned( _item_sets[banneditems], item) ) {
        if( item_sets[banneditems].player_message != "" ) {
            player.ClientMessage(item_sets[banneditems].player_message);
        }
        l("is_banned( "$banneditems$", "$item$") true");
        return true;
    }
    err("is_banned( "$banneditems$", "$item$") false");
}

function AddStartingEquipment(Pawn p)
{
    local class<Inventory> iclass;
    local Inventory item;
    local Ammo a;
    local DeusExWeapon w;
    local int i, k;

    for(i=0; i < ArrayCount(_item_sets[banneditems].starting_equipment); i++) {
        iclass = _item_sets[banneditems].starting_equipment[i];
        l("AddStartingEquipment "$banneditems$", "$iclass);
        if( iclass == None ) continue;

        if( class<DeusExAmmo>(iclass) == None && class'DXRActorsBase'.static.HasItem(p, iclass) )
            continue;

        l("AddStartingEquipment "$banneditems$", "$iclass);

        item = p.Spawn(iclass, p);
        a.InitialState='Idle2';
        item.BecomeItem();
        item.GotoState('Idle2');
        item.GiveTo(p);
        item.SetBase(p);

        w = DeusExWeapon(item);
        if( w == None ) continue;
        if( w.AmmoName != None ) {
            a = p.spawn(w.AmmoName);
            w.AmmoType = a;
            a.InitialState='Idle2';
            a.BecomeItem();
            a.GotoState('Idle2');
            a.GiveTo(p);
            a.SetBase(p);
        }

        for(k=0; k < ArrayCount(w.AmmoNames); k++) {
            if(rng(3) == 0 && w.AmmoNames[k] != None) {
                a = p.spawn(w.AmmoNames[k]);
                a.InitialState='Idle2';
                a.BecomeItem();
                a.GotoState('Idle2');
                a.GiveTo(p);
                a.SetBase(p);
            }
        }
    }
}
