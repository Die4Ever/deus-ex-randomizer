class DXREnemyRespawn extends DXRActorsBase;

struct InitialAllianceInfo  {
	var() Name  AllianceName;
	var() float AllianceLevel;
	var() bool  bPermanent;
};

struct InventoryItem  {
	var() class<Inventory> Inventory;
	var() int              Count;
};

struct OriginalEnemy {
    var class <ScriptedPawn> c;
    var vector loc;
    var rotator rot;
    var ScriptedPawn sp;
    var name alliance;
    var InitialAllianceInfo InitialAlliances[8];
    var InventoryItem InitialInventory[8];
    var name orders;
    var name ordertag;
    var name tag;
    var bool bHateCarcass, bHateDistress, bHateHacking, bHateIndirectInjury, bHateInjury, bHateShot, bHateWeapon;
    var bool bFearCarcass, bFearDistress, bFearHacking, bFearIndirectInjury, bFearInjury, bFearShot, bFearWeapon, bFearAlarm, bFearProjectiles;
    var int time_died;
};
var OriginalEnemy enemies[128];
var int time;
var config name dont_respawn[8];

function FirstEntry()
{
    local ScriptedPawn p;
    local int i, a;
    Super.FirstEntry();

    if( dxr.flags.enemyrespawn <= 0 ) return;
    if( dxr.flags.gamemode != 0 && dxr.flags.gamemode != 1 ) return;

    time=0;
    foreach AllActors(class'ScriptedPawn', p) {
        SaveRespawn(p, i);
    }

    SetTimer(1.0, true);
}

function SaveRespawn(ScriptedPawn p, out int i)
{
    local int a;
    if( p.IsA('Animal') && !p.IsA('Greasel') && !p.IsA('Karkian') && !p.IsA('Gray') && !p.IsA('Doberman') ) return;
    if( p.bImportant || p.bInvincible || p.bHidden ) return;

    for(a=0; a < ArrayCount(dont_respawn); a++) {
        if( p.IsA(dont_respawn[a])) return;
    }

    if( i >= ArrayCount(enemies) ) {
        err("exceeded size of enemies array! "$i);
        i++;
        return;
    }

    enemies[i].c = p.class;
    enemies[i].sp = p;
    enemies[i].loc = p.Location;
    enemies[i].rot = p.Rotation;
    enemies[i].alliance = p.alliance;
    for(a=0; a < ArrayCount(p.InitialAlliances); a++) {
        enemies[i].InitialAlliances[a].AllianceName = p.InitialAlliances[a].AllianceName;
        enemies[i].InitialAlliances[a].AllianceLevel = p.InitialAlliances[a].AllianceLevel;
        enemies[i].InitialAlliances[a].bPermanent = p.InitialAlliances[a].bPermanent;
    }
    for(a=0; a < ArrayCount(p.InitialInventory); a++) {
        enemies[i].InitialInventory[a].Inventory = p.InitialInventory[a].Inventory;
        enemies[i].InitialInventory[a].Count = p.InitialInventory[a].Count;
    }
    enemies[i].orders = p.orders;
    enemies[i].ordertag = p.ordertag;
    enemies[i].tag = p.tag;

    enemies[i].bHateCarcass = p.bHateCarcass;
    enemies[i].bHateDistress = p.bHateDistress;
    enemies[i].bHateHacking = p.bHateHacking;
    enemies[i].bHateIndirectInjury = p.bHateIndirectInjury;
    enemies[i].bHateInjury = p.bHateInjury;
    enemies[i].bHateShot = p.bHateShot;
    enemies[i].bHateWeapon = p.bHateWeapon;
    enemies[i].bFearCarcass = p.bFearCarcass;
    enemies[i].bFearDistress = p.bFearDistress;
    enemies[i].bFearHacking = p.bFearHacking;
    enemies[i].bFearIndirectInjury = p.bFearIndirectInjury;
    enemies[i].bFearInjury = p.bFearInjury;
    enemies[i].bFearShot = p.bFearShot;
    enemies[i].bFearWeapon = p.bFearWeapon;
    enemies[i].bFearAlarm = p.bFearAlarm;
    enemies[i].bFearProjectiles = p.bFearProjectiles;
    i++;
}

function AnyEntry()
{
    local int i;
    Super.AnyEntry();

    if( dxr.flags.gamemode != 0 && dxr.flags.gamemode != 1 ) return;

    if( dxr.flags.enemyrespawn <= 0 ) return;

    /*for(i=0; i < ArrayCount(enemies); i++) {
        if( enemies[i].sp == None || enemies[i].sp.health <= 0  ) {
            Respawn(enemies[i]);
        }
    }*/
    SetTimer(1.0, true);
}

function Timer()
{
    local int i;
    Super.Timer();

    time++;
    for(i=0; i < ArrayCount(enemies); i++) {
        if( enemies[i].c == None ) break;
        else if( ( enemies[i].sp == None || enemies[i].sp.health <= 0 ) && enemies[i].time_died == 0 ) {
            enemies[i].time_died = time;
        }
        else if( ( enemies[i].sp == None || enemies[i].sp.health <= 0 ) && time - enemies[i].time_died > dxr.flags.enemyrespawn ) {
            Respawn(enemies[i]);
        }
    }
}

function ScriptedPawn Respawn(out OriginalEnemy enemy)
{
    local DXREnemies dxre;
    local DXRNames dxrn;
    local ScriptedPawn p;
    local int i;

    if( enemy.c == None ) return None;
    enemy.time_died = 0;
    p = Spawn(enemy.c,, enemy.tag, enemy.loc, enemy.rot);
    if( p == None ) return None;

    enemy.sp = p;
    p.alliance = enemy.alliance;
    for(i=0; i < ArrayCount(p.InitialAlliances); i++) {
        p.InitialAlliances[i].AllianceName = enemy.InitialAlliances[i].AllianceName;
        p.InitialAlliances[i].AllianceLevel = enemy.InitialAlliances[i].AllianceLevel;
        p.InitialAlliances[i].bPermanent = enemy.InitialAlliances[i].bPermanent;
    }
    for(i=0; i < ArrayCount(p.InitialInventory); i++) {
        p.InitialInventory[i].Inventory = enemy.InitialInventory[i].Inventory;
        p.InitialInventory[i].Count = enemy.InitialInventory[i].Count;
    }
    p.orders = enemy.orders;
    p.ordertag = enemy.ordertag;

    p.bHateCarcass = enemy.bHateCarcass;
    p.bHateDistress = enemy.bHateDistress;
    p.bHateHacking = enemy.bHateHacking;
    p.bHateIndirectInjury = enemy.bHateIndirectInjury;
    p.bHateInjury = enemy.bHateInjury;
    p.bHateShot = enemy.bHateShot;
    p.bHateWeapon = enemy.bHateWeapon;
    p.bFearCarcass = enemy.bFearCarcass;
    p.bFearDistress = enemy.bFearDistress;
    p.bFearHacking = enemy.bFearHacking;
    p.bFearIndirectInjury = enemy.bFearIndirectInjury;
    p.bFearInjury = enemy.bFearInjury;
    p.bFearShot = enemy.bFearShot;
    p.bFearWeapon = enemy.bFearWeapon;
    p.bFearAlarm = enemy.bFearAlarm;
    p.bFearProjectiles = enemy.bFearProjectiles;
    
    p.InitializeInventory();
    p.InitializeAlliances();

    dxrn = DXRNames(dxr.FindModule(class'DXRNames'));
    if( dxrn != None ) {
        p.UnfamiliarName = dxrn.RandomName(p);
        p.FamiliarName = p.UnfamiliarName;
    }

    dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
    if( dxre != None ) {
        dxre.RandomizeSP(p, 100);
    }
    return p;
}

