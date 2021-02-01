class DXRBannedItems extends DXRBase;
//maybe this stuff should be globalconfig so it could be statically requested?
var config string stick_with_the_prod_player_message;
var config string stick_with_the_prod_bans[10];
var config string stick_with_the_prod_allows[10];

var config string stick_with_the_prod_plus_player_message;
var config string stick_with_the_prod_plus_bans[10];
var config string stick_with_the_prod_plus_allows[10];

var int banneditems;//copy locally so we don't need to make this class transient and don't need to worry about re-entering and picking up an item before DXRando loads

struct _bans
{
    var class<Inventory> ban_types[10];
    var class<Inventory> allow_types[10];
};

var _bans _stick_with_the_prod;
var _bans _stick_with_the_prod_plus;

function CheckConfig()
{
    local int i;
    local class<Actor> a;
    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,6) ) {
        stick_with_the_prod_player_message = "Stick with the prod!";
        stick_with_the_prod_plus_player_message = "Stick with the prod!";
        for(i=0; i < ArrayCount(stick_with_the_prod_bans); i++ ) {
            stick_with_the_prod_bans[i] = "";
            stick_with_the_prod_plus_bans[i] = "";
        }
        for(i=0; i < ArrayCount(stick_with_the_prod_allows); i++ ) {
            stick_with_the_prod_allows[i] = "";
            stick_with_the_prod_plus_allows[i] = "";
        }

        stick_with_the_prod_bans[0] = "Engine.Weapon";
        stick_with_the_prod_allows[0] = "WeaponProd";

        stick_with_the_prod_plus_bans[0] = "Engine.Weapon";
        stick_with_the_prod_plus_bans[1] = "AmmoDart";
        i=0;
        stick_with_the_prod_plus_allows[i++] = "WeaponProd";
        stick_with_the_prod_plus_allows[i++] = "WeaponEMPGrenade";
        stick_with_the_prod_plus_allows[i++] = "WeaponGasGrenade";
        stick_with_the_prod_plus_allows[i++] = "WeaponMiniCrossbow";
        stick_with_the_prod_plus_allows[i++] = "AmmoDartPoison";
        stick_with_the_prod_plus_allows[i++] = "WeaponNanoVirusGrenade";
        stick_with_the_prod_plus_allows[i++] = "WeaponPepperGun";
    }
    Super.CheckConfig();

    for(i=0; i < ArrayCount(stick_with_the_prod_bans); i++ ) {
        if( stick_with_the_prod_bans[i] != "" ) {
            a = GetClassFromString(stick_with_the_prod_bans[i], class'Inventory');
            _stick_with_the_prod.ban_types[i] = class<Inventory>(a);
        }
    }
    for(i=0; i < ArrayCount(stick_with_the_prod_allows); i++ ) {
        if( stick_with_the_prod_allows[i] != "" ) {
            a = GetClassFromString(stick_with_the_prod_allows[i], class'Inventory');
            _stick_with_the_prod.allow_types[i] = class<Inventory>(a);
        }
    }

    for(i=0; i < ArrayCount(stick_with_the_prod_plus_bans); i++ ) {
        if( stick_with_the_prod_plus_bans[i] != "" ) {
            a = GetClassFromString(stick_with_the_prod_plus_bans[i], class'Inventory');
            _stick_with_the_prod_plus.ban_types[i] = class<Inventory>(a);
        }
    }
    for(i=0; i < ArrayCount(stick_with_the_prod_plus_allows); i++ ) {
        if( stick_with_the_prod_plus_allows[i] != "" ) {
            a = GetClassFromString(stick_with_the_prod_plus_allows[i], class'Inventory');
            _stick_with_the_prod_plus.allow_types[i] = class<Inventory>(a);
        }
    }
}

function AnyEntry()
{
    Super.AnyEntry();
    banneditems = dxr.flags.banneditems;
}

function bool is_banned(_bans b, Inventory item)
{
    local bool found_ban;
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
    if( banneditems == 1 ) {
        if ( is_banned( _stick_with_the_prod, item) ) {
            player.ClientMessage(stick_with_the_prod_player_message);
            return true;
        }
    }
    else if( banneditems == 2 ) {
        if ( is_banned( _stick_with_the_prod_plus, item) ) {
            player.ClientMessage(stick_with_the_prod_plus_player_message);
            return true;
        }
    }
}

function AddStartingEquipment(Pawn p)
{
    local class<DeusExWeapon> wclass;
    local Ammo a;
    local DeusExWeapon w;
    local int i;

    if( banneditems == 1 || banneditems == 2 ) {
        wclass = class'WeaponProd';
        if( class'DXRActorsBase'.static.HasItem(p, wclass) )
            return;

        w = p.Spawn(wclass, p);
        w.GiveTo(p);
        w.SetBase(p);

        if( w.AmmoName != None ) {
            a = p.spawn(w.AmmoName);
            w.AmmoType = a;
            w.AmmoType.InitialState='Idle2';
            w.AmmoType.GiveTo(p);
            w.AmmoType.SetBase(p);
        }

        for(i=0; i < ArrayCount(w.AmmoNames); i++) {
            if(rng(3) == 0 && w.AmmoNames[i] != None) {
                a = p.spawn(w.AmmoNames[i]);
                a.GiveTo(p);
                a.SetBase(p);
            }
        }
    }
}
