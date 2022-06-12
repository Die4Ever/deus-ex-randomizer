class DXRReduceItems extends DXRActorsBase;

struct sReduceAmmo {
    var string type;
    var int percent;
};
struct sReduceItem {
    var string type;
    var int percent;
};
struct sSetMax {
    var string type;
    var int percent;
};
struct sMaxAmmo {
    var string type;
    var int percent;
};

var config int mission_scaling[16];
var config sReduceAmmo ammo_reductions[16];
var config sReduceItem reduce_items[16];
var config sSetMax max_copies[16];
var config sMaxAmmo max_ammo[16];

var config float min_rate_adjust, max_rate_adjust;

replication
{
    reliable if( Role == ROLE_Authority )
        mission_scaling, ammo_reductions, reduce_items, max_copies, max_ammo, min_rate_adjust, max_rate_adjust;
}

function CheckConfig()
{
    local int i;
    if( ConfigOlderThan(1,6,4,8) ) {
        min_rate_adjust = default.min_rate_adjust;
        max_rate_adjust = default.max_rate_adjust;

        for(i=0; i < ArrayCount(mission_scaling); i++) {
            mission_scaling[i] = 100;
        }
        for(i=0; i < ArrayCount(ammo_reductions); i++) {
            ammo_reductions[i].type = "";
        }
        for(i=0; i < ArrayCount(reduce_items); i++) {
            reduce_items[i].type = "";
        }
        for(i=0; i < ArrayCount(max_copies); i++) {
            max_copies[i].type = "";
        }
        for(i=0; i < ArrayCount(max_ammo); i++) {
            max_ammo[i].type = "";
        }

        i=0;
        ammo_reductions[i].type = "Ammo10mm";
        ammo_reductions[i].percent = 80;

        i=0;
        max_ammo[i].type = "Ammo10mm";
        max_ammo[i].percent = 30;
    }
    Super.CheckConfig();
}

function PostFirstEntry()
{
    local int i, mission, scale;
    local class<Actor> c;
    Super.PostFirstEntry();

    mission = Clamp(dxr.dxInfo.missionNumber, 0, ArrayCount(mission_scaling)-1);
    scale = mission_scaling[mission];

    ReduceAmmo(class'Ammo', float(dxr.flags.settings.ammo*scale)/100.0/100.0);

    ReduceSpawns(class'#var(prefix)Multitool', dxr.flags.settings.multitools*scale/100);
    ReduceSpawns(class'#var(prefix)Lockpick', dxr.flags.settings.lockpicks*scale/100);
    ReduceSpawns(class'#var(prefix)BioelectricCell', dxr.flags.settings.biocells*scale/100);
    ReduceSpawns(class'#var(prefix)MedKit', dxr.flags.settings.medkits*scale/100);

    for(i=0; i < ArrayCount(ammo_reductions); i++) {
        if( ammo_reductions[i].type == "" ) continue;
        c = GetClassFromString( ammo_reductions[i].type, class'Ammo' );
        ReduceAmmo(class<Ammo>(c), float(ammo_reductions[i].percent*scale)/100.0/100.0 );
    }
    for(i=0; i < ArrayCount(reduce_items); i++) {
        if( reduce_items[i].type == "" ) continue;
        c = GetClassFromString( reduce_items[i].type, class'Actor' );
        ReduceSpawns(c, reduce_items[i].percent*scale/100 );
    }
    SetAllMaxCopies(scale);
    SetTimer(1.0, true);
}

function ReduceItem(Actor a)
{
    local int i, mission, scale;
    local class<Actor> c;

    mission = Clamp(dxr.dxInfo.missionNumber, 0, ArrayCount(mission_scaling)-1);
    scale = mission_scaling[mission];

    if( Ammo(a) != None ) {
        _ReduceAmmo(Ammo(a), float(dxr.flags.settings.ammo*scale)/100.0/100.0);
    }
    else if( Weapon(a) != None ) {
        _ReduceWeaponAmmo(Weapon(a), float(dxr.flags.settings.ammo*scale)/100.0/100.0);
    }
    else if( #var(prefix)Multitool(a) != None ) {
        _ReduceSpawns(a, dxr.flags.settings.multitools*scale/100);
    }
    else if( #var(prefix)Lockpick(a) != None ) {
        _ReduceSpawns(a, dxr.flags.settings.lockpicks*scale/100);
    }
    else if( #var(prefix)BioelectricCell(a) != None ) {
        _ReduceSpawns(a, dxr.flags.settings.biocells*scale/100);
    }
    else if( #var(prefix)MedKit(a) != None ) {
        _ReduceSpawns(a, dxr.flags.settings.medkits*scale/100);
    }
}

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    Super.PlayerAnyEntry(p);
    SetTimer(1.0, true);
}

simulated function Timer()
{
    local int mission, scale;
    Super.Timer();
    if( dxr == None ) return;

    mission = Clamp(dxr.dxInfo.missionNumber, 0, ArrayCount(mission_scaling)-1);
    scale = mission_scaling[mission];
    SetAllMaxCopies(scale);
}

simulated function SetAllMaxCopies(int scale)
{
    local int i;
    local class<Actor> c;
    if( dxr == None ) return;
    SetMaxAmmo( class'Ammo', dxr.flags.settings.ammo*scale/100 );

    SetMaxCopies(class'#var(prefix)FireExtinguisher', 125);// just make sure to apply the enviro skill, HACK: 125% to counteract the normal 80%
    SetMaxCopies(class'#var(prefix)Multitool', dxr.flags.settings.multitools*scale/100 );
    SetMaxCopies(class'#var(prefix)Lockpick', dxr.flags.settings.lockpicks*scale/100 );
    SetMaxCopies(class'#var(prefix)BioelectricCell', dxr.flags.settings.biocells*scale/100 );
    SetMaxCopies(class'#var(prefix)MedKit', dxr.flags.settings.medkits*scale/100 );

    for(i=0; i < ArrayCount(max_copies); i++) {
        if( max_copies[i].type == "" ) continue;
        c = GetClassFromString( max_copies[i].type, class'#var(prefix)DeusExPickup' );
        SetMaxCopies( class<#var(prefix)DeusExPickup>(c), max_copies[i].percent*scale/100 );
    }
    for(i=0; i < ArrayCount(max_ammo); i++) {
        if( max_ammo[i].type == "" ) continue;
        c = GetClassFromString( max_ammo[i].type, class'Ammo' );
        SetMaxAmmo( class<Ammo>(c), max_ammo[i].percent*scale/100 );
    }
}

function _ReduceWeaponAmmo(Weapon w, float mult)
{
    local int i;
    local float tmult;
    if( w.AmmoName == None || w.PickupAmmoCount <= 0 ) return;

    tmult = rngrangeseeded(mult, min_rate_adjust, max_rate_adjust, w.AmmoName);
    i = Clamp(float(w.PickupAmmoCount) * tmult, 1, 1000);
    l("reducing ammo in "$ActorToString(w)$" from "$w.PickupAmmoCount$" down to "$i$", tmult: "$tmult);
    w.PickupAmmoCount = i;
}

function _ReduceAmmo(Ammo a, float mult)
{
    local int i;
    local float tmult;
    if( a.AmmoAmount <= 0 || CarriedItem(a) ) return;

    tmult = rngrangeseeded(mult, min_rate_adjust, max_rate_adjust, a.class.name);
    i = Clamp(float(a.AmmoAmount) * tmult, 1, 1000);
    l("reducing ammo in "$ActorToString(a)$" from "$a.AmmoAmount$" down to "$i$", tmult: "$tmult);
    a.AmmoAmount = i;
}

function ReduceAmmo(class<Ammo> type, float mult)
{
    local Weapon w;
    local Ammo a;

    l("ReduceAmmo "$mult);
    SetSeed( "ReduceAmmo" );

    foreach AllActors(class'Weapon', w)
    {
        if( w.AmmoName != type && ClassIsChildOf(w.AmmoName, type) == false ) continue;
        _ReduceWeaponAmmo(w, mult);
    }

    foreach AllActors(class'Ammo', a)
    {
        if( ! a.IsA(type.name) ) continue;
        _ReduceAmmo(a, mult);
    }

    ReduceSpawnsInContainers(type, mult*100.0 );
}

function _ReduceSpawns(Actor a, float percent)
{
    local float tperc;
    tperc = rngrangeseeded(percent, min_rate_adjust, max_rate_adjust, a.class.name);
    if( !chance_single(tperc) )
    {
        l("destroying "$ActorToString(a)$", tperc: "$tperc);
        DestroyActor( a );
    }
}

function ReduceSpawns(class<Actor> classname, float percent)
{
    local Actor a;

    SetSeed( "ReduceSpawns " $ classname );

    foreach AllActors(class'Actor', a)
    {
        //if( SkipActor(a, classname.name) ) continue;
        if( PlayerPawn(a) != None ) continue;
        if( PlayerPawn(a.Owner) != None ) continue;
        if( ! a.IsA(classname.name) ) continue;

        _ReduceSpawns(a, percent);
    }

    ReduceSpawnsInContainers(classname, percent);
}

function ReduceSpawnsInContainers(class<Actor> classname, float percent)
{
    local Containers d;
    local float tperc;

    SetSeed( "ReduceSpawnsInContainers " $ classname.Name );

    foreach AllActors(class'Containers', d)
    {
        if( ClassIsChildOf( d.Content3, classname) ) {
            tperc = rngrangeseeded(percent, min_rate_adjust, max_rate_adjust, d.Content3.name);
            if( !chance_single(tperc) ) {
                l("ReduceSpawnsInContainers container "$ActorToString(d)$" removing content3 "$d.Content3$", tperc: "$tperc);
                d.Content3 = None;
            }
        }
        if( ClassIsChildOf( d.Content2, classname) ) {
            tperc = rngrangeseeded(percent, min_rate_adjust, max_rate_adjust, d.Content2.name);
            if( !chance_single(tperc) ) {
                l("ReduceSpawnsInContainers container "$ActorToString(d)$" removing content2 "$d.Content2$", tperc: "$tperc);
                d.Content2 = d.Content3;
            }
        }
        if( ClassIsChildOf( d.Contents, classname) ) {
            tperc = rngrangeseeded(percent, min_rate_adjust, max_rate_adjust, d.Contents.name);
            if( !chance_single(tperc) ) {
                l("ReduceSpawnsInContainers container "$ActorToString(d)$" removing contents "$d.Contents$", tperc: "$tperc);
                d.Contents = d.Content2;
                if( d.Contents == None ) {
#ifndef vmd
                    d.Contents = class'Flare';
#endif
                }
            }
        }
    }
}

simulated function SetMaxCopies(class<DeusExPickup> type, int percent)
{
    local #var(prefix)DeusExPickup p;
    local int maxCopies;

    foreach AllActors(class'#var(prefix)DeusExPickup', p) {
        if( ! p.IsA(type.name) ) continue;

        p.maxCopies = float(p.default.maxCopies) * float(percent) / 100.0 * 0.8;
        if( #defined(balance) && DeusExPlayer(p.Owner) != None && #var(prefix)FireExtinguisher(p) != None )
            p.maxCopies += DeusExPlayer(p.Owner).SkillSystem.GetSkillLevel(class'#var(prefix)SkillEnviro');

#ifdef vmd
        maxCopies = p.VMDConfigureMaxCopies();
#else
        maxCopies = p.maxCopies;
#endif

        if( p.NumCopies > maxCopies ) p.NumCopies = maxCopies;
    }
}

simulated function SetMaxAmmo(class<Ammo> type, int percent)
{
    local Ammo a;
    local int maxAmmo;

    foreach AllActors(class'Ammo', a) {
        if( ! a.IsA(type.name) ) continue;
        a.MaxAmmo = float(a.default.MaxAmmo) * float(percent) / 100.0 * 0.8;

        if( #defined(balance) && DeusExPlayer(a.Owner) != None
            && (AmmoEMPGrenade(a) != None || AmmoGasGrenade(a) != None || AmmoLAM(a) != None || AmmoNanoVirusGrenade(a) != None )
        ) {
            a.MaxAmmo += DeusExPlayer(a.Owner).SkillSystem.GetSkillLevel(class'#var(prefix)SkillDemolition');
        }

#ifdef vmd
        maxAmmo = DeusExAmmo(a).VMDConfigureMaxAmmo();
#else
        maxAmmo = a.MaxAmmo;
#endif

        if( a.AmmoAmount > maxAmmo ) a.AmmoAmount = maxAmmo;
    }
}

simulated function AddDXRCredits(CreditsWindow cw)
{
    local int i;
    local DXREnemies e;
    local class<DeusExWeapon> w;
    cw.PrintHeader( "Items" );

    PrintItemRate(cw, class'Multitool', dxr.flags.settings.multitools);
    PrintItemRate(cw, class'Lockpick', dxr.flags.settings.lockpicks);
    PrintItemRate(cw, class'BioelectricCell', dxr.flags.settings.biocells);
    PrintItemRate(cw, class'MedKit', dxr.flags.settings.medkits);

    cw.PrintLn();

    cw.PrintHeader( "Ammo: "$dxr.flags.settings.ammo$"%" );
    e = DXREnemies(dxr.FindModule(class'DXREnemies'));
    if(e != None) {
        for(i=0; i < 100; i++) {
            w = e.GetWeaponConfig(i).type;
            if( w == None ) break;
            PrintAmmoRates(cw, w);
        }
    }

    cw.PrintLn();
}

simulated function PrintAmmoRates(CreditsWindow cw, class<DeusExWeapon> w)
{
    local class<Ammo> a;
    local int i;

    a = w.default.AmmoName;
    PrintItemRate(cw, a, dxr.flags.settings.ammo, true, w.default.ItemName $ " Ammo");
    for(i=0; i<ArrayCount(w.default.AmmoNames); i++) {
        if( w.default.AmmoNames[i] != a )
            PrintItemRate(cw, w.default.AmmoNames[i], dxr.flags.settings.ammo, true, w.default.ItemName $ " Ammo");
    }
}

simulated function PrintItemRate(CreditsWindow cw, class<Inventory> c, int percent, optional bool AllowIncrease, optional string BackupName)
{
    local float tperc;
    local string ItemName;

    if( c == None ) return;
    if( c == class'DeusEx.AmmoNone' ) return;

    tperc = rngrangeseeded(percent, min_rate_adjust, max_rate_adjust, c.name);
    if( ! AllowIncrease && tperc > 100 )
        tperc = Clamp( tperc, 0, 100 );
    else if( tperc < 0 )
        tperc = 0;

    ItemName = c.default.ItemName;
    if( ItemName == class'DeusExAmmo'.default.ItemName )
        ItemName = BackupName;
    if( Len(ItemName) == 0 )
        ItemName = string(c.Name);
    cw.PrintText( ItemName $ " : " $ FloatToString(tperc, 1) $ "%" );
}

defaultproperties
{
    bAlwaysTick=True
    min_rate_adjust=0.5
    max_rate_adjust=1.5
}
