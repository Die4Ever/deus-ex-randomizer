class DXRReduceItems extends DXRActorsBase transient;

struct _ItemReduction {
    var class<Actor> type;
    var int percent;
};

struct AmmoInfo {
    var class<Ammo> type;
    var String backupName;
};

var int mission_scaling[16];
var _ItemReduction _item_reductions[16];
var _ItemReduction _max_ammo[16];

var float min_rate_adjust, max_rate_adjust;

replication
{
    reliable if( Role == ROLE_Authority )
        mission_scaling, _item_reductions, _max_ammo, min_rate_adjust, max_rate_adjust;
}

function CheckConfig()
{
    local int i;

    if(dxr.flags.IsSpeedrunMode()) {
        min_rate_adjust = 0.5;
        max_rate_adjust = 1.5;
    } else {
        min_rate_adjust = 0.4;
        max_rate_adjust = 1.6;
    }

    for(i=0; i < ArrayCount(mission_scaling); i++) {
        mission_scaling[i] = 100;
    }

    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        i=0;
        _item_reductions[i].type = class'#var(prefix)Ammo10mm';
        _item_reductions[i].percent = 85;
        i++;

        _item_reductions[i].type = class'#var(prefix)AmmoPlasma';
        _item_reductions[i].percent = 130;
        i++;

        _item_reductions[i].type = class'#var(prefix)Ammo762mm';
        _item_reductions[i].percent = 85;
        i++;

        _item_reductions[i].type = class'#var(prefix)AmmoShell';
        _item_reductions[i].percent = 85;
        i++;

        _item_reductions[i].type = class'#var(prefix)AmmoDart';
        _item_reductions[i].percent = 120;
        i++;

        _item_reductions[i].type = class'#var(prefix)AmmoDartFlare';
        _item_reductions[i].percent = 120;
        i++;

        i=0;
        _max_ammo[i].type = class'#var(prefix)Ammo10mm';
        _max_ammo[i].percent = 60;
        i++;

        _max_ammo[i].type = class'#var(prefix)AmmoPlasma';
        _max_ammo[i].percent = 130;
        i++;

        _max_ammo[i].type = class'#var(prefix)Ammo762mm';
        _max_ammo[i].percent = 85;
        i++;

        _max_ammo[i].type = class'#var(prefix)AmmoShell';
        _max_ammo[i].percent = 85;
        i++;

        _max_ammo[i].type = class'#var(prefix)AmmoDart';
        _max_ammo[i].percent = 130;
        i++;

        _max_ammo[i].type = class'#var(prefix)AmmoDartFlare';
        _max_ammo[i].percent = 130;
        i++;
    }

    Super.CheckConfig();
}

function PostFirstEntry()
{
    local int mission, scale;
    Super.PostFirstEntry();

    if(dxr.flags.settings.ammo==100
        && dxr.flags.settings.multitools==100
        && dxr.flags.settings.lockpicks==100
        && dxr.flags.settings.biocells==100
        && dxr.flags.settings.medkits==100
    ) {
        if(dxr.flags.IsOneItemMode()) OneItemMode();
        return;
    }

    mission = Clamp(dxr.dxInfo.missionNumber, 0, ArrayCount(mission_scaling)-1);
    scale = mission_scaling[mission];

    ReduceAmmo(class'Ammo', float(dxr.flags.settings.ammo*scale)/100.0/100.0);

    ReduceSpawns(class'#var(prefix)Multitool', dxr.flags.settings.multitools*scale/100);
    ReduceSpawns(class'#var(prefix)Lockpick', dxr.flags.settings.lockpicks*scale/100);
    ReduceSpawns(class'#var(prefix)BioelectricCell', dxr.flags.settings.biocells*scale/100);
    ReduceSpawns(class'#var(prefix)MedKit', dxr.flags.settings.medkits*scale/100);

    SetAllMaxCopies(scale);
    SetTimer(1.0, true);

    if(dxr.flags.IsOneItemMode()) OneItemMode();
}

function OneItemMode()
{
    local Inventory item, nextItem, items[1024];
    local #var(prefix)Containers d;
    local class<Actor> contents[1024];
    local class<Inventory> newclass;
    local #var(DeusExPrefix)Carcass carc;
    local int num, numcontents, i, slot;
    local vector loc;
    local rotator rot;
    local EPhysics phys;
    local Actor base;
    local bool bOwned;
    local DXRAugmentations dxraugs;

    foreach AllActors(class'Inventory', item) {
        if(item.bIsSecretGoal) continue;
        if(Pawn(item.Owner) != None) continue;
        if(item.bDeleteMe) continue;
        if(#var(prefix)NanoKey(item) != None) continue;
        items[num++] = item;
    }

    foreach AllActors(class'#var(prefix)Containers', d) {
        if (#var(PlayerPawn)(d.base)!=None) continue;
        if(d.Contents!=None) contents[numcontents++] = d.Contents;
        if(d.Content2!=None) contents[numcontents++] = d.Content2;
        if(d.Content3!=None) contents[numcontents++] = d.Content3;
    }

    if(num+numcontents <= 1) return;
    while(newclass==None) {
        slot = rng(num+numcontents);
        if(slot<num) newclass = items[slot].class;
        else newclass = class<Inventory>(contents[slot-num]);
    }

    for(i=0; i<num; i++) {
        if(i==slot) continue;
        item = items[i];
        if(item.class == newclass) continue;
        loc = item.Location;
        loc.Z -= item.CollisionHeight;
        rot = item.Rotation;
        phys = item.physics;
        base = item.Base;
        bOwned = item.bOwned;
        carc = #var(DeusExPrefix)Carcass(item.Owner);
        if(carc != None) carc.DeleteInventory(item);
        item.Destroy();

        loc.Z += newclass.default.CollisionHeight;

        item = Spawn(newclass,,, loc, rot);
        if(item==None) continue;
        item.SetPhysics(phys);
        item.SetBase(base);
        item.bOwned = bOwned;

        if(carc!=None) {
            item.BecomeItem();
            carc.AddInventory(item);
            item.GotoState('Idle2');
        }
    }

    foreach AllActors(class'#var(prefix)Containers', d) {
        if (#var(PlayerPawn)(d.base)!=None) continue;
        if(d.Contents==None && d.Content2==None && d.Content3==None) continue;
        d.Contents = newclass;
        d.Content2 = None;
        d.Content3 = None;
    }

    dxraugs = DXRAugmentations(class'DXRAugmentations'.static.Find());
    dxraugs.RandomizeAugCannisters();
}

function ReduceItem(Inventory a)
{
    local int mission, scale;

    if(a.bIsSecretGoal) return;

    mission = Clamp(dxr.dxInfo.missionNumber, 0, ArrayCount(mission_scaling)-1);
    scale = mission_scaling[mission];

    if( Ammo(a) != None ) {
        _ReduceAmmo(Ammo(a), float(dxr.flags.settings.ammo*scale)/100.0/100.0);
    }
    else if( Weapon(a) != None ) {
        _ReduceWeaponAmmo(Weapon(a), float(dxr.flags.settings.ammo*scale)/100.0/100.0);
    }
    else if( #var(prefix)Multitool(a) != None ) {
        _ReduceSpawn(a, dxr.flags.settings.multitools*scale/100);
    }
    else if( #var(prefix)Lockpick(a) != None ) {
        _ReduceSpawn(a, dxr.flags.settings.lockpicks*scale/100);
    }
    else if( #var(prefix)BioelectricCell(a) != None ) {
        _ReduceSpawn(a, dxr.flags.settings.biocells*scale/100);
    }
    else if( #var(prefix)MedKit(a) != None ) {
        _ReduceSpawn(a, dxr.flags.settings.medkits*scale/100);
    } else if( _GetItemMult(_item_reductions, a.class) != 1.0 ) {
        _ReduceSpawn(a, 1.0);
    }
}

function ReduceItemInContainer(#var(prefix)Containers c, class<Inventory> a)
{
    local int mission, scale;

    if(c.bIsSecretGoal) return;

    mission = Clamp(dxr.dxInfo.missionNumber, 0, ArrayCount(mission_scaling)-1);
    scale = mission_scaling[mission];

    if( ClassIsChildOf(a,class'Ammo') ) {
        ReduceSpawnInSingleContainer(c, a, float(dxr.flags.settings.ammo*scale)/100.0/100.0, true);
    }
    else if( ClassIsChildOf(a,class'#var(prefix)Multitool') ) {
        ReduceSpawnInSingleContainer(c, a, dxr.flags.settings.multitools*scale/100, true);
    }
    else if( ClassIsChildOf(a,class'#var(prefix)Lockpick') ) {
        ReduceSpawnInSingleContainer(c, a, dxr.flags.settings.lockpicks*scale/100, true);
    }
    else if( ClassIsChildOf(a,class'#var(prefix)BioelectricCell') ) {
        ReduceSpawnInSingleContainer(c, a, dxr.flags.settings.biocells*scale/100, true);
    }
    else if( ClassIsChildOf(a,class'#var(prefix)Medkit') ) {
        ReduceSpawnInSingleContainer(c, a, dxr.flags.settings.medkits*scale/100, true);
    }
    else if( _GetItemMult(_item_reductions, a) != 1.0 ) {
        ReduceSpawnInSingleContainer(c, a, 1.0, true);
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
    if( dxr == None ) return;
    SetMaxAmmo( class'Ammo', dxr.flags.settings.ammo*scale/100 );

    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        SetMaxCopies(class'#var(prefix)FireExtinguisher', 125);// just make sure to apply the enviro skill, HACK: 125% to counteract the normal 80%
    }
    SetMaxCopies(class'#var(prefix)Multitool', dxr.flags.settings.multitools*scale/100 );
    SetMaxCopies(class'#var(prefix)Lockpick', dxr.flags.settings.lockpicks*scale/100 );
    SetMaxCopies(class'#var(prefix)BioelectricCell', dxr.flags.settings.biocells*scale/100 );
    SetMaxCopies(class'#var(prefix)MedKit', dxr.flags.settings.medkits*scale/100 );
}

function float _GetItemMult(_ItemReduction reductions[16], class<Actor> item)
{
    local int i;
    local float mult;

    mult = 1.0;
    for(i=0; i < ArrayCount(reductions); i++) {
        if( reductions[i].type == None ) continue;
        if( ClassIsChildOf(item, reductions[i].type) )
            mult *= float(reductions[i].percent) / 100.0;
    }
    return mult;
}

function int ApplyItemMult(int count, float mult)
{
    local float f;
    local int i;
    f = FClamp(float(count) * mult, 1, 1000);
    if(rngf() < (f%1.0)) {// DXRando: random rounding, 1.9 is more likely to round up than 1.1 is
        f += 0.999;
    }
    i = f;
    l("    reducing from " $ count $ " to " $ i $ " (" $ f $ ") with mult " $ mult);
    return i;
}

function _ReduceWeaponAmmo(Weapon w, float mult)
{
    if( w.AmmoName == None || w.PickupAmmoCount <= 0 ) return;
    // don't reduce weapon PickupAmmoCount owned by Robots? does this matter?
    if(#var(prefix)Robot(w.Owner) != None) return;
    if( w.bIsSecretGoal ) return;

    mult *= _GetItemMult(_item_reductions, w.AmmoName);
    mult = rngrangeseeded(mult, min_rate_adjust, max_rate_adjust, w.AmmoName);
    // owned weapons get their PickupAmmoCount reduced a bit more, otherwise looting bodies gives too much
    if(Pawn(w.Owner) != None)
        mult *= 0.7;
    l("reducing ammo in "$ActorToString(w)$" from "$w.PickupAmmoCount);
    w.PickupAmmoCount = ApplyItemMult(w.PickupAmmoCount, mult);
}

function _ReduceAmmo(Ammo a, float mult)
{
    // don't reduce ammo owned by pawns
    if( a.AmmoAmount <= 0 || CarriedItem(a) ) return;
    if( a.bIsSecretGoal ) return;

    mult *= _GetItemMult(_item_reductions, a.class);
    mult = rngrangeseeded(mult, min_rate_adjust, max_rate_adjust, a.class.name);
    l("reducing ammo in "$ActorToString(a)$" from "$a.AmmoAmount);
    a.AmmoAmount = ApplyItemMult(a.AmmoAmount, mult);
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

function _ReduceSpawn(Inventory a, float percent)
{
    local float tperc;

    percent *= _GetItemMult(_item_reductions, a.class);
    tperc = rngrangeseeded(percent, min_rate_adjust, max_rate_adjust, a.class.name);
    if( !chance_single(tperc) )
    {
        l("destroying "$ActorToString(a)$", tperc: "$tperc);
        DestroyActor( a );
    }
}

function ReduceSpawns(class<Inventory> classname, float percent)
{
    local Actor a;

    SetSeed( "ReduceSpawns " $ classname );

    foreach AllActors(classname, a)
    {
        if( PlayerPawn(a) != None ) continue;
        if( PlayerPawn(a.Owner) != None ) continue;
        if( Merchant(a.Owner) != None ) continue;
        if(a.bIsSecretGoal) continue;

        _ReduceSpawn(Inventory(a), percent);
    }

    ReduceSpawnsInContainers(classname, percent);
}

function bool _ReduceSpawnInContainer(#var(prefix)Containers d, class<Inventory> classname, float percent, class<Actor> item)
{
    local float tperc;

    if( !ClassIsChildOf(item, classname) )
        return false;

    percent *= _GetItemMult(_item_reductions, item);
    tperc = rngrangeseeded(percent, min_rate_adjust, max_rate_adjust, item.name);
    if( ! chance_single(tperc) ) {
        l("_ReduceSpawnInContainer container "$ActorToString(d)$" removing "$item$", tperc: "$tperc$", percent: "$percent);
        return true;
    }
    return false;
}

function ReduceSpawnInSingleContainer(#var(prefix)Containers d, class<Inventory> classname, float percent, optional bool deleteWhenEmpty)
{
    if (#var(PlayerPawn)(d.base)!=None){
        return; //Skip boxes the player might have carried across levels
    }

    if(d.Content3 == None && d.Content2 == None && d.Contents == None)
        return;

    if( d.Content3 != None && _ReduceSpawnInContainer(d, classname, percent, d.Content3) )
        d.Content3 = None;

    if( d.Content2 != None && _ReduceSpawnInContainer(d, classname, percent, d.Content2) )
        d.Content2 = None;

    if( d.Contents != None && _ReduceSpawnInContainer(d, classname, percent, d.Contents) )
        d.Contents = None;

    if(d.Content2 == None)
        d.Content2 = d.Content3;
    if(d.Contents == None)
        d.Contents = d.Content2;

    if(d.Contents == None) {
        if (!deleteWhenEmpty) {
            l("ReduceSpawnsInContainers downgrading "$d$" to a cardboard box");
            SpawnReplacement(d, class'#var(prefix)BoxMedium', true);// we don't care if this succeeds or not
        } else {
            l("ReduceSpawnsInContainers destroying "$d$" since it will be empty.");
        }
        d.Event = '';
        d.Destroy();
    }
}

function ReduceSpawnsInContainers(class<Inventory> classname, float percent, optional bool deleteWhenEmpty)
{
    local #var(prefix)Containers d;

    SetSeed( "ReduceSpawnsInContainers " $ classname.Name );

    foreach AllActors(class'#var(prefix)Containers', d)
    {
        ReduceSpawnInSingleContainer(d, classname, percent, deleteWhenEmpty);
    }
}

simulated function SetMaxCopies(class<DeusExPickup> type, int percent)
{
    local #var(prefix)DeusExPickup p;
    local #var(PlayerPawn) owner;
    local int maxCopies;
    local float f;

    percent = Clamp(percent, 10, 1000);

    foreach AllActors(class'#var(prefix)DeusExPickup', p) {
        if( ! p.IsA(type.name) ) continue;

        f = float(percent) / 100.0;
        f *= _GetItemMult(_item_reductions, p.class);
        f *= float(p.default.maxCopies);
        if(percent < 100) {
            f *= rngrangeseeded(1, 0.8, 1.2, p.class.name) * 0.8;
        }
        p.maxCopies = Clamp(f, 1, p.default.maxCopies*10);
        owner = #var(PlayerPawn)(p.Owner);
        if(owner == None)
            owner = player(true);
        if( #defined(balance) && owner != None && #var(prefix)FireExtinguisher(p) != None && class'MenuChoice_BalanceSkills'.static.IsEnabled() )
            p.maxCopies += owner.SkillSystem.GetSkillLevel(class'#var(prefix)SkillEnviro');

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
    local #var(PlayerPawn) owner;
    local Ammo a;
    local int maxAmmo;
    local float f;

    percent = Clamp(percent, 10, 1000);

    foreach AllActors(class'Ammo', a) {
        if( ! a.IsA(type.name) ) continue;

        f = float(percent) / 100.0;
        f *= _GetItemMult(_max_ammo, a.class);
        f *= float(a.default.MaxAmmo);
        if(percent < 100) {
            f *= rngrangeseeded(1, 0.8, 1.2, a.class.name) * 0.8;
        }
        a.MaxAmmo = Clamp(f, 1, a.default.MaxAmmo*10);

        owner = #var(PlayerPawn)(a.Owner);
        if(owner == None)
            owner = player(true);
        if( #defined(balance) && owner != None && class'MenuChoice_BalanceSkills'.static.IsEnabled()
            && (AmmoEMPGrenade(a) != None || AmmoGasGrenade(a) != None || AmmoLAM(a) != None || AmmoNanoVirusGrenade(a) != None )
        ) {
            a.MaxAmmo += owner.SkillSystem.GetSkillLevel(class'#var(prefix)SkillDemolition');
        }

#ifdef vmd
        maxAmmo = DeusExAmmo(a).VMDConfigureMaxAmmo();
#else
        maxAmmo = a.MaxAmmo;
#endif

        // don't reduce ammo of pawns
        if( ScriptedPawn(a.Owner)==None && a.AmmoAmount > maxAmmo ) a.AmmoAmount = maxAmmo;
    }
}

simulated function AddDXRCredits(CreditsWindow cw)
{
    //local int i;
    local DXREnemies e;
    //local class<DeusExWeapon> w;
    if(dxr.flags.IsZeroRando()) return;
    cw.PrintHeader( "Items" );

    PrintItemRate(cw, class'Multitool', dxr.flags.settings.multitools);
    PrintItemRate(cw, class'Lockpick', dxr.flags.settings.lockpicks);
    PrintItemRate(cw, class'BioelectricCell', dxr.flags.settings.biocells);
    PrintItemRate(cw, class'MedKit', dxr.flags.settings.medkits);

    cw.PrintLn();

    cw.PrintHeader( "Ammo: "$dxr.flags.settings.ammo$"%" );
    e = DXREnemies(dxr.FindModule(class'DXREnemies'));
    if(e != None) {
        GatherAmmoRates(cw,e);
    }

    cw.PrintLn();
}


simulated function GatherAmmoRates(CreditsWindow cw, DXREnemies e)
{
    local int i,j;
    local class<DeusExWeapon> w;
    local AmmoInfo ammoTypes[50];


    for(i=0; i < 100; i++) {
        w = e.GetWeaponConfig(i).type;
        if( w == None ) break;

        AddAmmoInfo(w.Default.AmmoName,w,ammoTypes);
        for(j=0; j<ArrayCount(w.default.AmmoNames); j++) {
            AddAmmoInfo(w.default.AmmoNames[j],w,ammoTypes);
        }
    }

    for(i=0;i<ArrayCount(ammoTypes);i++){
        if (ammoTypes[i].type==None) break;
        PrintItemRate(cw, ammoTypes[i].type, dxr.flags.settings.ammo, true, ammoTypes[i].backupName);
    }
}

simulated function AddAmmoInfo(class<Ammo> a, class<DeusExWeapon> w, out AmmoInfo types[50])
{
    local int i;

    if (a==None) return;

    for (i=0;i<ArrayCount(types);i++)
    {
        if (types[i].type==a) return; //Type is already in the list
        if (types[i].type!=None) continue; //Keep going

        //Didn't find ourself and we reached an empty spot in the list
        types[i].type=a;
        types[i].backupName=w.default.ItemName $ " Ammo";
        return;
    }
    //list is full, I guess?
}

simulated function PrintItemRate(CreditsWindow cw, class<Inventory> c, int percent, optional bool AllowIncrease, optional string BackupName)
{
    local float tperc;
    local string ItemName;

    if( c == None ) return;
    if( c == class'DeusEx.AmmoNone' ) return;

    tperc = percent;
    tperc *= _GetItemMult(_item_reductions, c);
    tperc = rngrangeseeded(tperc, min_rate_adjust, max_rate_adjust, c.name);
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
}
