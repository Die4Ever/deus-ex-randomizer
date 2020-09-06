class DXRReduceItems extends DXRActorsBase;

struct sReduceAmmo {
    var class<Ammo> type;
    var int percent;
};
struct sReduceItem {
    var class<Actor> type;
    var int percent;
};
struct sSetMax {
    var class<DeusExPickup> type;
    var int percent;
};
struct sMaxAmmo {
    var class<Ammo> type;
    var int percent;
};

var config int mission_scaling[16];
var config sReduceAmmo ammo_reductions[16];
var config sReduceItem reduce_items[16];
var config sSetMax max_copies[16];
var config sMaxAmmo max_ammo[16];

function CheckConfig()
{
    local int i;
    if( config_version == 0 ) {
        for(i=0; i < ArrayCount(mission_scaling); i++) {
            mission_scaling[i] = 100;
        }
        for(i=0; i < ArrayCount(ammo_reductions); i++) {
            ammo_reductions[i].type = None;
        }
        for(i=0; i < ArrayCount(reduce_items); i++) {
            reduce_items[i].type = None;
        }
        for(i=0; i < ArrayCount(max_copies); i++) {
            max_copies[i].type = None;
        }
        for(i=0; i < ArrayCount(max_ammo); i++) {
            max_ammo[i].type = None;
        }
    }
    Super.CheckConfig();
}

function FirstEntry()
{
    local int i, mission, scale;
    Super.FirstEntry();

    mission = Clamp(dxr.dxInfo.missionNumber, 0, ArrayCount(mission_scaling)-1);
    scale = mission_scaling[mission];

    ReduceAmmo(class'Ammo', float(dxr.flags.ammo*scale)/100.0/100.0);
    SetMaxAmmo( class'Ammo', dxr.flags.ammo*scale/100 );

    ReduceSpawns(class'Multitool', dxr.flags.multitools*scale/100);
    ReduceSpawns(class'Lockpick', dxr.flags.lockpicks*scale/100);
    ReduceSpawns(class'BioelectricCell', dxr.flags.biocells*scale/100);
    ReduceSpawns(class'MedKit', dxr.flags.medkits*scale/100);

    SetMaxCopies(class'Multitool', dxr.flags.multitools*scale/100);
    SetMaxCopies(class'Lockpick', dxr.flags.lockpicks*scale/100);
    SetMaxCopies(class'BioelectricCell', dxr.flags.biocells*scale/100);
    SetMaxCopies(class'MedKit', dxr.flags.medkits*scale/100);

    for(i=0; i < ArrayCount(ammo_reductions); i++) {
        if( ammo_reductions[i].type == None ) continue;
        ReduceAmmo(ammo_reductions[i].type, float(ammo_reductions[i].percent*scale)/100.0/100.0 );
    }
    for(i=0; i < ArrayCount(reduce_items); i++) {
        if( reduce_items[i].type == None ) continue;
        ReduceSpawns(reduce_items[i].type, reduce_items[i].percent*scale/100 );
    }
    for(i=0; i < ArrayCount(max_copies); i++) {
        if( max_copies[i].type == None ) continue;
        SetMaxCopies( max_copies[i].type, max_copies[i].percent*scale/100 );
    }
    for(i=0; i < ArrayCount(max_ammo); i++) {
        if( max_ammo[i].type == None ) continue;
        SetMaxAmmo( max_ammo[i].type, max_ammo[i].percent*scale/100 );
    }
    SetTimer(1.0, true);
}

function Timer()
{
    local int i, mission, scale;
    Super.Timer();

    mission = Clamp(dxr.dxInfo.missionNumber, 0, ArrayCount(mission_scaling)-1);
    scale = mission_scaling[mission];

    SetMaxCopies(class'Multitool', dxr.flags.multitools*scale/100 );
    SetMaxCopies(class'Lockpick', dxr.flags.lockpicks*scale/100 );
    SetMaxCopies(class'BioelectricCell', dxr.flags.biocells*scale/100 );
    SetMaxCopies(class'MedKit', dxr.flags.medkits*scale/100 );

    for(i=0; i < ArrayCount(max_copies); i++) {
        if( max_copies[i].type == None ) continue;
        SetMaxCopies( max_copies[i].type, max_copies[i].percent*scale/100 );
    }
    for(i=0; i < ArrayCount(max_ammo); i++) {
        if( max_ammo[i].type == None ) continue;
        SetMaxAmmo( max_ammo[i].type, max_ammo[i].percent*scale/100 );
    }
}

function ReduceAmmo(class<Ammo> type, float mult)
{
    local Weapon w;
    local Ammo a;
    local int i;

    l("ReduceAmmo "$mult);
    SetSeed( "ReduceAmmo" );

    if( mult ~= 1 ) return;

    foreach AllActors(class'Weapon', w)
    {
        if( w.AmmoName != type && ClassIsChildOf(w.AmmoName, type) == false ) continue;
        if( w.PickupAmmoCount > 0 ) {
            i = Clamp(float(w.PickupAmmoCount) * mult, 1, 1000);
            l("reducing ammo in "$ActorToString(w)$" from "$w.PickupAmmoCount$" down to "$i);
            w.PickupAmmoCount = i;
        }
    }

    foreach AllActors(class'Ammo', a)
    {
        if( ! a.IsA(type.name) ) continue;
        if( a.AmmoAmount > 0 && ( ! CarriedItem(a) ) ) {
            i = Clamp(float(a.AmmoAmount) * mult, 1, 1000);
            l("reducing ammo in "$ActorToString(a)$" from "$a.AmmoAmount$" down to "$i);
            a.AmmoAmount = i;
        }
    }

    ReduceSpawnsInContainers(type, int(mult*100.0) );
}

function ReduceSpawns(class<Actor> classname, int percent)
{
    local Actor a;

    if( percent >= 100 ) return;

    SetSeed( "ReduceSpawns " $ classname );

    foreach AllActors(class'Actor', a)
    {
        //if( SkipActor(a, classname.name) ) continue;
        if( a == dxr.Player ) continue;
        if( a.Owner == dxr.Player ) continue;
        if( ! a.IsA(classname.name) ) continue;

        if( rng(100) >= percent )
        {
            l("destroying "$ActorToString(a));
            DestroyActor( a );
        }
    }

    ReduceSpawnsInContainers(classname, percent);
}

function ReduceSpawnsInContainers(class<Actor> classname, int percent)
{
    local Containers d;

    if( percent >= 100 ) return;

    SetSeed( "ReduceSpawnsInContainers " $ classname.Name );

    foreach AllActors(class'Containers', d)
    {
        //l("found Decoration " $ d.Name $ " with Contents: " $ d.Contents $ ", looking for " $ classname.Name);
        if( rng(100) >= percent ) {
            if( ClassIsChildOf( classname, d.Contents) ) {
                l("ReduceSpawnsInContainers container "$ActorToString(d)$" removing contents "$d.Contents);
                d.Contents = d.Content2;
            }
            if( ClassIsChildOf( classname, d.Contents) ) {
                l("ReduceSpawnsInContainers container "$ActorToString(d)$" removing contents "$d.Content2);
                d.Content2 = d.Content3;
            }
            if( ClassIsChildOf( classname, d.Contents) ) {
                l("ReduceSpawnsInContainers container "$ActorToString(d)$" removing contents "$d.Content3);
                d.Content3 = None;
            }
        }
    }
}

function SetMaxCopies(class<DeusExPickup> type, int percent)
{
    local DeusExPickup p;
    foreach AllActors(class'DeusExPickup', p) {
        if( ! p.IsA(type.name) ) continue;
        p.maxCopies = p.default.maxCopies * percent / 100;
    }
}

function SetMaxAmmo(class<Ammo> type, int percent)
{
    local Ammo a;
    foreach AllActors(class'Ammo', a) {
        if( ! a.IsA(type.name) ) continue;
        a.MaxAmmo = a.default.MaxAmmo * percent / 100;
    }
}

defaultproperties
{
}
