class DXRLoadouts extends DXRActorsBase transient;

var int loadout;//copy locally so we don't need to make this class transient and don't need to worry about re-entering and picking up an item before DXRando loads
var config int loadouts_order[20];

struct loadouts
{
    var string name;
    var string player_message;

    var class<Inventory>    ban_types[10];
    var class<Skill>        ban_skills[10];
    var class<Augmentation> ban_augs[10];
    var class<Inventory>    allow_types[25];
    var class<Skill>        allow_skills[10];
    var class<Augmentation> allow_augs[10];
    var class<Skill>        never_ban_skills[10];
    var class<Inventory>    starting_equipment[5];
    var class<Augmentation> starting_augs[5];
    var class<Actor>        item_spawns[10];
    var int                 item_spawns_chances[10];// the % spawned in each map, max of 300%
};

var loadouts item_sets[20];

struct RandomItemStruct { var class<Inventory> type; var int chance; };
var RandomItemStruct randomitems[16];

var config int mult_items_per_level;

replication
{
    reliable if( Role == ROLE_Authority )
        loadout, mult_items_per_level;
}

//#region CheckConfig
function CheckConfig()
{
    local int i;

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
    loadouts_order[i++] = 11;
    loadouts_order[i++] = 13;
    loadouts_order[i++] = 14;
    loadouts_order[i++] = 12;

    //#region Loadout Defs
/////////////////////////////////////////////////////////////////
    //#region All Items
    AddLoadoutName(0,"All Items Allowed");
    AddStartAug(0,class'#var(prefix)AugSpeed');
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region SWTP Pure
    AddLoadoutName(1,"Stick With the Prod Pure");
    AddLoadoutPlayerMsg(1,"Stick with the prod!");
    AddInvBan(1,class'Engine.Weapon');
    AddInvBan(1,class'Engine.Ammo');
    AddSkillBan(1,class'#var(prefix)SkillWeaponHeavy');
    AddSkillBan(1,class'#var(prefix)SkillWeaponRifle');
    AddSkillBan(1,class'#var(prefix)SkillWeaponPistol');
    NeverBanSkill(1,class'#var(prefix)SkillWeaponLowTech');
    AddInvAllow(1,class'#var(prefix)WeaponProd');
    AddInvAllow(1,class'#var(prefix)AmmoBattery');
    AddInvAllow(1,class'#var(package).WeaponRubberBaton');
    AddStartInv(1,class'#var(prefix)WeaponProd');
    AddStartInv(1,class'#var(prefix)AmmoBattery');
    AddStartInv(1,class'#var(prefix)AmmoBattery');
    AddStartInv(1,class'#var(package).WeaponRubberBaton');
    AddItemSpawn(1,class'#var(prefix)WeaponProd',30);
    AddItemSpawn(1,class'#var(package).WeaponRubberBaton',20);
    AddStartAug(1,class'#var(prefix)AugStealth');
    AddStartAug(1,class'#var(prefix)AugMuscle');
    AddAugBan(1,class'#var(prefix)AugSpeed');
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region SWTP Plus
    AddLoadoutName(2,"Stick With the Prod Plus");
    AddLoadoutPlayerMsg(2,"Stick with the prod!");
    AddInvBan(2,class'Engine.Weapon');
    AddInvBan(2,class'Engine.Ammo');
    AddSkillBan(2,class'#var(prefix)SkillWeaponHeavy');
    AddSkillBan(2,class'#var(prefix)SkillWeaponRifle');
    NeverBanSkill(2,class'#var(prefix)SkillWeaponLowTech');
    NeverBanSkill(2,class'#var(prefix)SkillWeaponPistol');
    AddInvAllow(2,class'#var(prefix)WeaponProd');
    AddInvAllow(2,class'#var(prefix)AmmoBattery');
    AddInvAllow(2,class'#var(prefix)WeaponEMPGrenade');
    AddInvAllow(2,class'#var(prefix)AmmoEMPGrenade');
    AddInvAllow(2,class'#var(prefix)WeaponGasGrenade');
    AddInvAllow(2,class'#var(prefix)AmmoGasGrenade');
    AddInvAllow(2,class'#var(prefix)WeaponMiniCrossbow');
    AddInvAllow(2,class'#var(prefix)AmmoDartPoison');
    AddInvAllow(2,class'#var(prefix)WeaponNanoVirusGrenade');
    AddInvAllow(2,class'#var(prefix)AmmoNanoVirusGrenade');
    AddInvAllow(2,class'#var(prefix)WeaponPepperGun');
    AddInvAllow(2,class'#var(prefix)AmmoPepper');
    AddInvAllow(2,class'#var(package).WeaponRubberBaton');
    AddStartInv(2,class'#var(prefix)WeaponProd');
    AddStartInv(2,class'#var(prefix)AmmoBattery');
    AddStartInv(2,class'#var(package).WeaponRubberBaton');
    AddItemSpawn(2,class'#var(prefix)WeaponProd',30);
    AddItemSpawn(2,class'#var(prefix)WeaponMiniCrossbow',30);
    AddItemSpawn(2,class'#var(package).WeaponRubberBaton',20);
    AddStartAug(2,class'#var(prefix)AugStealth');
    AddStartAug(2,class'#var(prefix)AugMuscle');
    AddAugBan(2,class'#var(prefix)AugSpeed');
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Ninja JC
    AddLoadoutName(3,"Ninja JC");
    AddLoadoutPlayerMsg(3,"I am Ninja!");
    AddInvBan(3,class'Engine.Weapon');
    AddInvBan(3,class'Engine.Ammo');
    AddSkillBan(3,class'#var(prefix)SkillWeaponHeavy');
    AddSkillBan(3,class'#var(prefix)SkillWeaponRifle');
    NeverBanSkill(3,class'#var(prefix)SkillWeaponLowTech');
    AddInvAllow(3,class'#var(prefix)WeaponSword');
    AddInvAllow(3,class'#var(prefix)WeaponNanoSword');
    AddInvAllow(3,class'#var(prefix)WeaponShuriken');
    AddInvAllow(3,class'#var(prefix)AmmoShuriken');
    AddInvAllow(3,class'#var(prefix)WeaponEMPGrenade');
    AddInvAllow(3,class'#var(prefix)AmmoEMPGrenade');
    AddInvAllow(3,class'#var(prefix)WeaponGasGrenade');
    AddInvAllow(3,class'#var(prefix)AmmoGasGrenade');
    AddInvAllow(3,class'#var(prefix)WeaponNanoVirusGrenade');
    AddInvAllow(3,class'#var(prefix)AmmoNanoVirusGrenade');
    AddInvAllow(3,class'#var(prefix)WeaponPepperGun');
    AddInvAllow(3,class'#var(prefix)AmmoPepper');
    AddInvAllow(3,class'#var(prefix)WeaponLAM');
    AddInvAllow(3,class'#var(prefix)AmmoLAM');
    AddInvAllow(3,class'#var(prefix)WeaponMiniCrossbow');
    AddInvAllow(3,class'#var(prefix)AmmoDart');
    AddInvAllow(3,class'#var(prefix)AmmoDartFlare');
    AddInvAllow(3,class'#var(prefix)AmmoDartPoison');
    AddInvAllow(3,class'#var(prefix)WeaponCombatKnife');
    AddStartInv(3,class'#var(prefix)WeaponShuriken');
    AddStartInv(3,class'#var(prefix)WeaponSword');
    AddStartInv(3,class'#var(prefix)AmmoShuriken');
    AddItemSpawn(3,class'#var(prefix)WeaponShuriken',150);
    AddItemSpawn(3,class'#var(prefix)BioelectricCell',100);
    AddStartAug(3,class'#var(package).AugNinja'); //combines AugStealth and active AugSpeed
    AddAugBan(3,class'#var(prefix)AugSpeed');
    AddAugBan(3,class'#var(prefix)AugStealth');
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Don't Give GEP
    AddLoadoutName(4,"Don't Give Me the GEP Gun");
    AddLoadoutPlayerMsg(4,"Don't Give Me the GEP Gun");
    AddInvBan(4,class'#var(prefix)WeaponGEPGun');
    AddInvBan(4,class'#var(prefix)AmmoRocket');
    AddInvBan(4,class'#var(prefix)AmmoRocketWP');
    AddStartAug(4,class'#var(prefix)AugSpeed');
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Freeman Mode
    AddLoadoutName(5,"Freeman Mode");
    AddLoadoutPlayerMsg(5,"Rather than offer you the illusion of free choice, I will take the liberty of choosing for you...");
    AddInvBan(5,class'Engine.Weapon');
    AddInvBan(5,class'Engine.Ammo');
    AddSkillBan(5,class'#var(prefix)SkillWeaponHeavy');
    AddSkillBan(5,class'#var(prefix)SkillWeaponPistol');
    AddSkillBan(5,class'#var(prefix)SkillWeaponRifle');
    NeverBanSkill(5,class'#var(prefix)SkillWeaponLowTech');
    AddInvAllow(5,class'#var(prefix)WeaponCrowbar');
    AddStartInv(5,class'#var(prefix)WeaponCrowbar');
    AddStartAug(5,class'#var(prefix)AugSpeed');
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Grenades Only
    AddLoadoutName(6,"Grenades Only");
    AddLoadoutPlayerMsg(6,"Grenades Only!");
    AddInvBan(6,class'Engine.Weapon');
    AddInvBan(6,class'Engine.Ammo');
    AddSkillBan(6,class'#var(prefix)SkillWeaponHeavy');
    AddSkillBan(6,class'#var(prefix)SkillWeaponRifle');
    AddSkillBan(6,class'#var(prefix)SkillWeaponPistol');
    AddSkillBan(6,class'#var(prefix)SkillWeaponLowTech');
    NeverBanSkill(6,class'#var(prefix)SkillDemolition');
    AddInvAllow(6,class'#var(prefix)WeaponLAM');
    AddInvAllow(6,class'#var(prefix)AmmoLAM');
    AddInvAllow(6,class'#var(prefix)WeaponGasGrenade');
    AddInvAllow(6,class'#var(prefix)AmmoGasGrenade');
    AddInvAllow(6,class'#var(prefix)WeaponNanoVirusGrenade');
    AddInvAllow(6,class'#var(prefix)AmmoNanoVirusGrenade');
    AddInvAllow(6,class'#var(prefix)WeaponEMPGrenade');
    AddInvAllow(6,class'#var(prefix)AmmoEMPGrenade');
    AddInvAllow(6,class'#var(package).WeaponRubberBaton');
    AddStartInv(6,class'#var(prefix)WeaponLAM');
    AddStartInv(6,class'#var(prefix)WeaponGasGrenade');
    AddStartInv(6,class'#var(prefix)WeaponNanoVirusGrenade');
    AddStartInv(6,class'#var(prefix)WeaponEMPGrenade');
    AddStartInv(6,class'#var(package).WeaponRubberBaton');
    AddItemSpawn(6,class'#var(prefix)WeaponLAM',50);
    AddItemSpawn(6,class'#var(prefix)WeaponGasGrenade',50);
    AddItemSpawn(6,class'#var(prefix)WeaponNanoVirusGrenade',50);
    AddItemSpawn(6,class'#var(prefix)WeaponEMPGrenade',50);
    AddItemSpawn(6,class'#var(package).WeaponRubberBaton',20);
    AddStartAug(6,class'#var(prefix)AugSpeed');
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region No Pistols
    AddLoadoutName(7,"No Pistols");
    AddLoadoutPlayerMsg(7,"No Pistols");
    AddInvBan(7,class'#var(prefix)WeaponPistol');
    AddInvBan(7,class'#var(prefix)WeaponStealthPistol');
    AddInvBan(7,class'#var(prefix)Ammo10mm');
    AddStartAug(7,class'#var(prefix)AugSpeed');
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region No Swords
    AddLoadoutName(8,"No Swords");
    AddLoadoutPlayerMsg(8,"No Swords");
    AddInvBan(8,class'#var(prefix)WeaponSword');
    AddInvBan(8,class'#var(prefix)WeaponNanoSword');
    AddStartAug(8,class'#var(prefix)AugSpeed');
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Hipster JC
    AddLoadoutName(9,"Hipster JC");
    AddLoadoutPlayerMsg(9,"That's too mainstream");
    AddInvBan(9,class'#var(prefix)WeaponNanoSword');
    AddInvBan(9,class'#var(prefix)WeaponPistol');
    AddInvBan(9,class'#var(prefix)WeaponStealthPistol');
    AddInvBan(9,class'#var(prefix)Ammo10mm');
    AddInvBan(9,class'#var(prefix)WeaponGEPGun');
    AddInvBan(9,class'#var(prefix)AmmoRocket');
    AddInvBan(9,class'#var(prefix)AmmoRocketWP');
    AddInvBan(9,class'#var(prefix)WeaponModLaser');
    //AddStartAug(9,class'#var(prefix)AugSpeed'); //Speed is overused!
    AddStartAug(9,class'#var(prefix)AugEMP'); //It's actually a really good aug, guys
    AddAugBan(9,class'#var(prefix)AugSpeed');
    AddAugBan(9,class'#var(prefix)AugPower');
    AddAugBan(9,class'#var(prefix)AugHealing');

    //#endregion
/////////////////////////////////////////////////////////////////
    //#region By The Book
    AddLoadoutName(10,"By the Book");
    AddLoadoutPlayerMsg(10,"By the Book");
    AddInvBan(10,class'#var(prefix)Lockpick');
    AddInvBan(10,class'#var(prefix)Multitool');
    AddSkillBan(10,class'#var(prefix)SkillComputer');
    AddSkillBan(10,class'#var(prefix)SkillLockpicking');
    AddSkillBan(10,class'#var(prefix)SkillTech');
    AddStartAug(10,class'#var(prefix)AugStealth');
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Explosives Only
    AddLoadoutName(11,"Explosives Only");
    AddLoadoutPlayerMsg(11,"Explosives Only!");
    AddInvBan(11,class'Engine.Weapon');
    AddInvBan(11,class'Engine.Ammo');
    AddSkillBan(11,class'#var(prefix)SkillWeaponPistol');
    AddSkillBan(11,class'#var(prefix)SkillWeaponLowTech');
    NeverBanSkill(11,class'#var(prefix)SkillDemolition');
    NeverBanSkill(11,class'#var(prefix)SkillWeaponHeavy');
    AddInvAllow(11,class'#var(prefix)WeaponGEPGun');
    AddInvAllow(11,class'#var(prefix)AmmoRocket');
    AddInvAllow(11,class'#var(prefix)AmmoRocketWP');
    AddInvAllow(11,class'#var(prefix)WeaponLAW');
    AddInvAllow(11,class'#var(prefix)WeaponLAM');
    AddInvAllow(11,class'#var(prefix)AmmoLAM');
    AddInvAllow(11,class'#var(prefix)WeaponEMPGrenade');
    AddInvAllow(11,class'#var(prefix)AmmoEMPGrenade');
    AddInvAllow(11,class'#var(prefix)WeaponGasGrenade');
    AddInvAllow(11,class'#var(prefix)AmmoGasGrenade');
    AddInvAllow(11,class'#var(prefix)WeaponNanoVirusGrenade');
    AddInvAllow(11,class'#var(prefix)AmmoNanoVirusGrenade');
    AddInvAllow(11,class'#var(prefix)WeaponAssaultGun');
    AddInvAllow(11,class'#var(prefix)Ammo20mm');
    AddInvAllow(11,class'#var(package).WeaponRubberBaton');
    AddStartInv(11,class'#var(prefix)WeaponGEPGun');
    AddStartInv(11,class'#var(package).WeaponRubberBaton');
    AddItemSpawn(11,class'#var(prefix)WeaponLAW',75);
    AddItemSpawn(11,class'#var(prefix)WeaponLAM',100);
    AddItemSpawn(11,class'#var(prefix)WeaponEMPGrenade',75);
    AddItemSpawn(11,class'#var(prefix)WeaponGasGrenade',75);
    AddItemSpawn(11,class'#var(prefix)WeaponNanoVirusGrenade',75);
    AddItemSpawn(11,class'#var(package).WeaponRubberBaton',20);
    AddItemSpawn(11,class'#var(prefix)AmmoRocket',100);
    AddItemSpawn(11,class'#var(prefix)AmmoRocketWP',100);
    AddItemSpawn(11,class'#var(prefix)Ammo20mm',100);
    AddStartAug(11,class'#var(prefix)AugSpeed');
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Random Aug
    // loadout for random starting aug
    AddLoadoutName(12,"Random Starting Aug");
    AddRandomAug(12);
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Straight Edge
    AddLoadoutName(13,"Straight Edge");
    AddLoadoutPlayerMsg(13,"Keep it on the straight and narrow!");
    AddInvBan(13,class'#var(prefix)Liquor40oz');
    AddInvBan(13,class'#var(prefix)LiquorBottle');
    AddInvBan(13,class'#var(prefix)WineBottle');
    AddInvBan(13,class'#var(prefix)Cigarettes');
    AddInvBan(13,class'#var(prefix)VialCrack');
    AddStartAug(13,class'#var(prefix)AugSpeed');
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Reduced Aug Set
    AddLoadoutName(14,"Reduced Aug Set");
    BanRandomAug(14); //18 augs total, ban a third of them
    BanRandomAug(14);
    BanRandomAug(14);
    BanRandomAug(14);
    BanRandomAug(14);
    BanRandomAug(14);
    AddRandomAug(14); //and get a random aug to start
    //#endregion
/////////////////////////////////////////////////////////////////

    //#endregion

    //#region Rand Start Items
    //Random items that can be given at game start
    AddRandomItem("Medkit",10);
    AddRandomItem("Lockpick",11);
    AddRandomItem("Multitool",11);
    AddRandomItem("Flare",7);
    AddRandomItem("FireExtinguisher",8);
    AddRandomItem("SoyFood",7);
    AddRandomItem("TechGoggles",9);
    if(#defined(hx))
        AddRandomItem("#var(injectsprefix)Binoculars",10);
    else
        AddRandomItem("Binoculars",10);
    AddRandomItem("BioelectricCell",11);
    AddRandomItem("BallisticArmor",9);
    AddRandomItem("WineBottle",7);
    //#endregion

    Super.CheckConfig();

    loadout = dxr.flags.loadout;
}

//#region Struct Setup
function AddRandomItem(string rtype, int chance)
{
    local class<Actor> a;
    local int i;

    for(i=0; i < ArrayCount(randomitems); i++) {
        if( randomitems[i].type == None ) {
            a = GetClassFromString(rtype, class'Inventory');
            randomitems[i].type = class<Inventory>(a);
            randomitems[i].chance = chance;
            break;
        }
    }
}

function AddLoadoutName(int s, string name)
{
    item_sets[s].name=name;
}

function AddLoadoutPlayerMsg(int s, string msg)
{
    item_sets[s].player_message=msg;
}

function AddInvBan(int s, class<Inventory> inv)
{
    local int i;

    if( inv == None ) return;

    for(i=0; i < ArrayCount(item_sets[s].ban_types); i++) {
        if( item_sets[s].ban_types[i] == None ) {
            item_sets[s].ban_types[i] = inv;
            return;
        }
    }
}

function AddSkillBan(int s, class<Skill> skill)
{
    local int i;

    if( skill == None ) return;

    for(i=0; i < ArrayCount(item_sets[s].ban_skills); i++) {
        if( item_sets[s].ban_skills[i] == None ) {
            item_sets[s].ban_skills[i] = skill;
            return;
        }
    }
}

function AddAugBan(int s, class<Augmentation> aug)
{
    local int i;

    if( aug == None ) return;

    for(i=0; i < ArrayCount(item_sets[s].ban_augs); i++) {
        if( item_sets[s].ban_augs[i] == None ) {
            item_sets[s].ban_augs[i] = aug;
            return;
        }
    }
}

function AddInvAllow(int s, class<Inventory> inv)
{
    local int i;

    if( inv == None ) return;

    for(i=0; i < ArrayCount(item_sets[s].allow_types); i++) {
        if( item_sets[s].allow_types[i] == None ) {
            item_sets[s].allow_types[i] = inv;
            return;
        }
    }
}

function AddSkillAllow(int s, class<Skill> skill)
{
    local int i;

    if( skill == None ) return;

    for(i=0; i < ArrayCount(item_sets[s].allow_skills); i++) {
        if( item_sets[s].allow_skills[i] == None ) {
            item_sets[s].allow_skills[i] = skill;
            return;
        }
    }
}

function AddAugAllow(int s, class<Augmentation> aug)
{
    local int i;

    if( aug == None ) return;

    for(i=0; i < ArrayCount(item_sets[s].allow_augs); i++) {
        if( item_sets[s].allow_augs[i] == None ) {
            item_sets[s].allow_augs[i] = aug;
            return;
        }
    }
}


function NeverBanSkill(int s, class<Skill> skill)
{
    local int i;

    if( skill == None ) return;

    for(i=0; i < ArrayCount(item_sets[s].never_ban_skills); i++) {
        if( item_sets[s].never_ban_skills[i] == None ) {
            item_sets[s].never_ban_skills[i] = skill;
            return;
        }
    }
}

function AddStartInv(int s, class<Inventory> inv)
{
    local int i;

    if( inv == None ) return;

    for(i=0; i < ArrayCount(item_sets[s].starting_equipment); i++) {
        if( item_sets[s].starting_equipment[i] == None ) {
            item_sets[s].starting_equipment[i] = inv;
            return;
        }
    }
}

function AddStartAug(int s, class<Augmentation> aug)
{
    local int i;

    if( aug == None ) return;

    for(i=0; i < ArrayCount(item_sets[s].starting_augs); i++) {
        if( item_sets[s].starting_augs[i] == None ) {
            if(dxr.flags.IsHalloweenMode() && aug==class'#var(prefix)AugSpeed' && dxr.flags.settings.speedlevel == 0) {
                aug = class'#var(prefix)AugStealth';// this is Halloween!
            } else if(dxr.flags.settings.speedlevel == 0) {
                continue;
            }
            item_sets[s].starting_augs[i] = aug;
            return;
        }
    }
}

function AddRandomAug(int s)
{
    local int i;

    for(i=0; i < ArrayCount(item_sets[s].starting_augs); i++) {
        if( item_sets[s].starting_augs[i] == None ) {
            SetGlobalSeed("DXRLoadouts AugRandom " $ i);
            item_sets[s].starting_augs[i] = class'DXRAugmentations'.static.GetRandomAug(dxr);
            return;
        }
    }
}

function BanRandomAug(int s)
{
    local int i;

    for(i=0; i < ArrayCount(item_sets[s].ban_augs); i++) {
        if( item_sets[s].ban_augs[i] == None ) {
            SetGlobalSeed("DXRLoadouts BanAugRandom " $ i);
            item_sets[s].ban_augs[i] = class'DXRAugmentations'.static.GetRandomAug(dxr);
            return;
        }
    }
}

function AddItemSpawn(int s, class<Inventory> inv, int chances)
{
    local int i;

    if( inv == None ) return;

    for(i=0; i < ArrayCount(item_sets[s].item_spawns); i++) {
        if( item_sets[s].item_spawns[i] == None ) {
            item_sets[s].item_spawns[i] = inv;
            item_sets[s].item_spawns_chances[i] = chances;
            return;
        }
    }
}
//#endregion

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

//#region AnyEntry
function AnyEntry()
{
    local ConEventTransferObject c;

    Super.AnyEntry();
    loadout = dxr.flags.loadout;

#ifndef injections
    // TODO: fix being given items from conversations for other mods
    /*foreach AllObjects(class'ConEventTransferObject', c) {
        l(c.objectName @ c.giveObject @ c.toName);
        if( c.toName == "JCDenton" && is_banned(item_sets[loadout], c.giveObject) ) {
            l(c.objectName @ c.giveObject @ c.toName $ ", clearing");
            c.toName = "";
            c.toActor = None;
            c.failLabel = "";
        }
    }*/
#endif
}
//#endregion

function bool _is_banned(loadouts b, class<Inventory> item)
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
    return _is_banned( item_sets[loadout], item);
}

function bool _is_skill_banned(loadouts b, class<Skill> skill)
{
    local int i;

    for(i=0; i < ArrayCount(b.allow_skills); i++ ) {
        if( b.allow_skills[i] != None && ClassIsChildOf(skill, b.allow_skills[i]) ) {
            return false;
        }
    }

    for(i=0; i < ArrayCount(b.ban_skills); i++ ) {
        if( b.ban_skills[i] != None && ClassIsChildOf(skill, b.ban_skills[i]) ) {
            return true;
        }
    }

    return false;
}

function bool is_skill_banned(int loadoutNum, class<Skill> skill)
{
    return _is_skill_banned( item_sets[loadoutNum], skill);
}

function bool _is_aug_banned(loadouts b, class<Augmentation> aug)
{
    local int i;

    for(i=0; i < ArrayCount(b.allow_augs); i++ ) {
        if( b.allow_augs[i] != None && ClassIsChildOf(aug, b.allow_augs[i]) ) {
            return false;
        }
    }

    for(i=0; i < ArrayCount(b.ban_augs); i++ ) {
        if( b.ban_augs[i] != None && ClassIsChildOf(aug, b.ban_augs[i]) ) {
            return true;
        }
    }

    return false;
}

function bool is_aug_banned(int loadoutNum, class<Augmentation> aug)
{
    return _is_aug_banned( item_sets[loadoutNum], aug);
}

function bool _allow_skill_ban(loadouts b, class<Skill> skill)
{
    local int i;

    for(i=0; i < ArrayCount(b.never_ban_skills); i++ ) {
        if( b.never_ban_skills[i] != None && ClassIsChildOf(skill, b.never_ban_skills[i]) ) {
            return false;
        }
    }

    return true;
}

function bool allow_skill_ban(int loadoutNum, class<Skill> skill)
{
    return _allow_skill_ban( item_sets[loadoutNum], skill);
}

function class<Inventory> get_starting_item()
{
    return item_sets[loadout].starting_equipment[0];
}

function bool ban(DeusExPlayer player, Inventory item)
{
    local bool bFixGlitches;

    if(IsMeleeWeapon(item) && Carcass(item.Owner) != None && player.FindInventoryType(item.class) != None) {
        return true;
    } else if ( _is_banned( item_sets[loadout], item.class) ) {
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

//#region Adjust Weapons
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
//#endregion

//#region FirstEntry
function FirstEntry()
{
    Super.FirstEntry();

    SpawnItems();

    #ifdef injections
    if (dxr.dxInfo.missionNumber == 98) {
        class'MenuChoice_LootActionUseless'.static.SetActions();
        class'MenuChoice_LootActionFoodSoda'.static.SetActions();
        class'MenuChoice_LootActionAlcohol'.static.SetActions();
        class'MenuChoice_LootActionMelee'.static.SetActions();
        class'MenuChoice_LootActionMisc'.static.SetActions();
    }
    #endif
}
//#endregion

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
    local int i;

    if( a.default.AugmentationLocation == LOC_Default ) // we don't rando things into default slots anyways
        return true;

    for(i=0; i < ArrayCount(item_sets[loadout].starting_augs); i++) {
        if( item_sets[loadout].starting_augs[i] == a ) return true;
    }
    return false;
}

// used for determining aug can contents
function bool IsAugBanned(class<Augmentation> a)
{
    //Always allow augs you started with
    if(StartedWithAug(a)) return true;

    //Ban Run Silent aug in speedruns with aug slot rando disabled
    if(dxr.flags.IsSpeedrunMode() && dxr.flags.moresettings.aug_loc_rando==0 && class<#var(prefix)AugStealth>(a)!=None) return true;

    //Otherwise rely on aug ban/allow rules per loadout
    return is_aug_banned(loadout,a);
}

//#region Starting Equipmt
function AddStartingEquipment(DeusExPlayer p, bool bFrob)
{
    local class<Inventory> iclass;
    local class<Augmentation> aclass;
    local Inventory item;
    local Ammo a;
    local DeusExWeapon w;
    local int i, k, auglevel;

    for(i=0; i < ArrayCount(item_sets[loadout].starting_equipment); i++) {
        iclass = item_sets[loadout].starting_equipment[i];
        if( iclass == None ) continue;

        if( class<DeusExAmmo>(iclass) == None && class'DXRActorsBase'.static.HasItem(p, iclass) )
            continue;

        item = GiveItem( p, iclass );
        if( bFrob && item != None ) item.Frob( p, None );
    }

    auglevel = dxr.flags.settings.speedlevel;
    if(dxr.flags.IsHalloweenMode()) {
        if(auglevel == 0) {
            auglevel = 1;
        }
    }
    for(i=0; i < ArrayCount(item_sets[loadout].starting_augs); i++) {
        aclass = item_sets[loadout].starting_augs[i];
        if( aclass == None ) continue;
        class'DXRAugmentations'.static.AddAug( p, aclass, auglevel );
    }
}

function RandoStartingEquipment(#var(PlayerPawn) player, bool respawn)
{
    local Inventory item, nextItem;
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

    for(item = player.Inventory; item != None; item=nextItem) {
        nextItem = item.Inventory;
        l("RandoStartingEquipment("$player$") checking item "$item$", bDisplayableInv: "$item.bDisplayableInv);
        if( Ammo(item) == None && ! item.bDisplayableInv ) continue;
        if( #var(prefix)NanoKeyRing(item) != None ) continue;
        if( dxre == None && Weapon(item) != None ) continue;
        if( dxre == None && Ammo(item) != None ) continue;
        if( MemConUnit(item) != None ) continue;
        l("RandoStartingEquipment("$player$") removing item: "$item);
        player.DeleteInventory(item);
        item.Destroy();
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
    for(i=0; i < ArrayCount(randomitems); i++ ) {
        if( randomitems[i].type == None ) continue;
        if( chance( randomitems[i].chance, r ) ) iclass = randomitems[i].type;
    }
    chance_remaining(r);
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
//#endregion

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

    for(i=0;i<ArrayCount(item_sets[loadout].item_spawns);i++) {
        aclass = item_sets[loadout].item_spawns[i];
        if( aclass == None ) continue;
        chance = item_sets[loadout].item_spawns_chances[i];
        if( chance <= 0 ) continue;

        chance /= 3;
        if(chance <= 0) chance=1;
        for(j=0;j<mult_items_per_level*3;j++) {
            if( chance_single(chance) ) {
                loc = GetRandomPositionFine();
                if (ClassIsChildOf(aclass,class'Inventory')){
                    a = SpawnItemInContainer(self,class<Inventory>(aclass),loc,,0.5);
                    l("SpawnItems() spawned "$a$" at "$loc$" with "$aclass$" inside");
                } else {
                    a = Spawn(aclass,,, loc);
                    l("SpawnItems() spawned "$a$" at "$loc);
                }

                if( reducer != None ) {
                    if (Inventory(a) != None) {
                        reducer.ReduceItem(Inventory(a));
                    } else if (#var(prefix)Containers(a) != None) {
                        reducer.ReduceItemInContainer(#var(prefix)Containers(a),class<Inventory>(aclass));
                    }
                }
            }
        }
    }

    if( reducer != None )
        reducer.Timer();
}

static function int GetLootAction(
    class<Inventory> itemClass,
    optional DataStorage storage,
    optional out string lootActions,
    optional out int strIdx
) {
    if (storage == None)
        storage = class'DataStorage'.static.GetObj(class'DXRando'.default.dxr);

    lootActions = storage.GetConfigKey("loot_actions");
    strIdx = InStr(lootActions, "," $ itemClass.name $ "=");
    if (strIdx != -1) {
        return Int(Mid(lootActions, strIdx + Len(itemClass.name) + 2, 1));
    }
    return 0;
}

static function SetLootAction(class<Inventory> itemClass, int action, optional DataStorage storage)
{
    local string lootActions, leftPart, rightPart;
    local int strIdx;

    if (storage == None) {
        storage = class'DataStorage'.static.GetObj(class'DXRando'.default.dxr);
    }
    if (GetLootAction(itemClass, storage, lootActions, strIdx) == action) {
        return;
    }

    if (lootActions == "") {
        lootActions = "," $ itemClass.name $ "=" $ action $ ",";
    } else if (strIdx == -1) {
        lootActions = lootActions $ itemClass.name $ "=" $ action $ ",";
    } else {
        leftPart = Left(lootActions, strIdx + Len(itemClass.name) + 2);
        rightPart = Mid(lootActions, strIdx + Len(itemClass.name) + 3);
        lootActions = leftPart $ action $ rightPart;
    }
    storage.SetConfig("loot_actions", lootActions, 3600*24*366);
}

function GetItemSpawns(out class<Actor> spawns[10], out int chances[10])
{
    local int i;

    for (i=0;i<ArrayCount(spawns);i++) {
        spawns[i]=item_sets[loadout].item_spawns[i];
        chances[i]=item_sets[loadout].item_spawns_chances[i];
    }
}

function RunTests()
{
    local int i, total;
    Super.RunTests();

    total=0;
    for(i=0; i < ArrayCount(randomitems); i++ ) {
        total += randomitems[i].chance;
    }
    test( total <= 100, "randomitems chances, check total "$total);
}
