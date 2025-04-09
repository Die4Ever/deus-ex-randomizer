class DXRLoadouts extends DXRActorsBase transient;

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

var loadouts item_set;

struct RandomItemStruct { var class<Inventory> type; var int chance; };
var RandomItemStruct randomitems[16];

var config int mult_items_per_level;

replication
{
    reliable if( Role == ROLE_Authority )
        mult_items_per_level;
}

//#region CheckConfig
function CheckConfig()
{
    mult_items_per_level = 1;

    LoadoutInfo(dxr.flags.loadout);

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
}

function int GetIdForSlot(int i)
{
    switch(i) {
        case 0: return 0;
        case 1: return 2;
        case 2: return 1;
        case 3: return 3;
        case 4: return 10;
        case 5: return 9;
        case 6: return 4;
        case 7: return 7;
        case 8: return 8;
        case 9: return 6;
        case 10: return 5;
        case 11: return 11;
        case 12: return 13;
        case 13: return 14;
        case 14: return 12;
    }
    return i;
}

function string LoadoutInfo(int loadout, optional bool get_name)
{
    local int i;
    local string name;

    //#region Loadout Defs

    //ALWAYS allow AmmoNone, it gets looted from Melee weapons and stuff
    AddInvAllow(class'#var(prefix)AmmoNone');

    switch(loadout) {
/////////////////////////////////////////////////////////////////
    //#region All Items
    case 0:
        name = "All Items Allowed";
        if(get_name) return name;
        AddStandardAugSet();
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region SWTP Pure
    case 1:
        name = "Stick With the Prod Pure";
        if(get_name) return name;
        AddLoadoutPlayerMsg("Stick with the prod!");
        AddInvBan(class'Engine.Weapon');
        AddInvBan(class'Engine.Ammo');
        AddSkillBan(class'#var(prefix)SkillWeaponHeavy');
        AddSkillBan(class'#var(prefix)SkillWeaponRifle');
        AddSkillBan(class'#var(prefix)SkillWeaponPistol');
        NeverBanSkill(class'#var(prefix)SkillWeaponLowTech');
        AddInvAllow(class'#var(prefix)WeaponProd');
        AddInvAllow(class'#var(prefix)AmmoBattery');
        AddInvAllow(class'#var(package).WeaponRubberBaton');
        AddStartInv(class'#var(prefix)WeaponProd');
        AddStartInv(class'#var(prefix)AmmoBattery');
        AddStartInv(class'#var(prefix)AmmoBattery');
        AddStartInv(class'#var(package).WeaponRubberBaton');
        AddItemSpawn(class'#var(prefix)WeaponProd',30);
        AddItemSpawn(class'#var(package).WeaponRubberBaton',20);
        AddStartAug(class'#var(prefix)AugStealth');
        AddStartAug(class'#var(prefix)AugMuscle');
        #ifdef injections
            AddStartAug(class'AugInfraVision');
            AddAugAllow(class'AugVision');
        #endif
        AddAugBan(class'#var(prefix)AugSpeed');
        AddAugAllow(class'AugJump');
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region SWTP Plus
    case 2:
        name = "Stick With the Prod Plus";
        if(get_name) return name;
        AddLoadoutPlayerMsg("Stick with the prod!");
        AddInvBan(class'Engine.Weapon');
        AddInvBan(class'Engine.Ammo');
        AddSkillBan(class'#var(prefix)SkillWeaponHeavy');
        AddSkillBan(class'#var(prefix)SkillWeaponRifle');
        NeverBanSkill(class'#var(prefix)SkillWeaponLowTech');
        NeverBanSkill(class'#var(prefix)SkillWeaponPistol');
        AddInvAllow(class'#var(prefix)WeaponProd');
        AddInvAllow(class'#var(prefix)AmmoBattery');
        AddInvAllow(class'#var(prefix)WeaponEMPGrenade');
        AddInvAllow(class'#var(prefix)AmmoEMPGrenade');
        AddInvAllow(class'#var(prefix)WeaponGasGrenade');
        AddInvAllow(class'#var(prefix)AmmoGasGrenade');
        AddInvAllow(class'#var(prefix)WeaponMiniCrossbow');
        AddInvAllow(class'#var(prefix)AmmoDartPoison');
        AddInvAllow(class'#var(prefix)WeaponNanoVirusGrenade');
        AddInvAllow(class'#var(prefix)AmmoNanoVirusGrenade');
        AddInvAllow(class'#var(prefix)WeaponPepperGun');
        AddInvAllow(class'#var(prefix)AmmoPepper');
        AddInvAllow(class'#var(package).WeaponRubberBaton');
        AddStartInv(class'#var(prefix)WeaponProd');
        AddStartInv(class'#var(prefix)AmmoBattery');
        AddStartInv(class'#var(package).WeaponRubberBaton');
        AddItemSpawn(class'#var(prefix)WeaponProd',30);
        AddItemSpawn(class'#var(prefix)WeaponMiniCrossbow',30);
        AddItemSpawn(class'#var(package).WeaponRubberBaton',20);
        AddStartAug(class'#var(prefix)AugStealth');
        AddStartAug(class'#var(prefix)AugMuscle');
        #ifdef injections
            AddStartAug(class'AugInfraVision');
            AddAugAllow(class'AugVision');
        #endif
        AddAugBan(class'#var(prefix)AugSpeed');
        AddAugAllow(class'AugJump');
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Ninja JC
    case 3:
        name = "Ninja JC";
        if(get_name) return name;
        AddLoadoutPlayerMsg("I am Ninja!");
        AddInvBan(class'Engine.Weapon');
        AddInvBan(class'Engine.Ammo');
        AddSkillBan(class'#var(prefix)SkillWeaponHeavy');
        AddSkillBan(class'#var(prefix)SkillWeaponRifle');
        NeverBanSkill(class'#var(prefix)SkillWeaponLowTech');
        AddInvAllow(class'#var(prefix)WeaponSword');
        AddInvAllow(class'#var(prefix)WeaponNanoSword');
        AddInvAllow(class'#var(prefix)WeaponShuriken');
        AddInvAllow(class'#var(prefix)AmmoShuriken');
        AddInvAllow(class'#var(prefix)WeaponEMPGrenade');
        AddInvAllow(class'#var(prefix)AmmoEMPGrenade');
        AddInvAllow(class'#var(prefix)WeaponGasGrenade');
        AddInvAllow(class'#var(prefix)AmmoGasGrenade');
        AddInvAllow(class'#var(prefix)WeaponNanoVirusGrenade');
        AddInvAllow(class'#var(prefix)AmmoNanoVirusGrenade');
        AddInvAllow(class'#var(prefix)WeaponPepperGun');
        AddInvAllow(class'#var(prefix)AmmoPepper');
        AddInvAllow(class'#var(prefix)WeaponLAM');
        AddInvAllow(class'#var(prefix)AmmoLAM');
        AddInvAllow(class'#var(prefix)WeaponMiniCrossbow');
        AddInvAllow(class'#var(prefix)AmmoDart');
        AddInvAllow(class'#var(prefix)AmmoDartFlare');
        AddInvAllow(class'#var(prefix)AmmoDartPoison');
        AddInvAllow(class'#var(prefix)WeaponCombatKnife');
        AddStartInv(class'#var(prefix)WeaponShuriken');
        AddStartInv(class'#var(prefix)WeaponSword');
        AddStartInv(class'#var(prefix)AmmoShuriken');
        AddItemSpawn(class'#var(prefix)WeaponShuriken',150);
        AddItemSpawn(class'#var(prefix)BioelectricCell',100);
        AddStartAug(class'#var(package).AugNinja'); //combines AugStealth and active AugSpeed
        AddAugBan(class'#var(prefix)AugSpeed');
        AddAugBan(class'#var(prefix)AugStealth');
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Don't Give GEP
    case 4:
        name = "Don't Give Me the GEP Gun";
        if(get_name) return name;
        AddLoadoutPlayerMsg("Don't Give Me the GEP Gun");
        AddInvBan(class'#var(prefix)WeaponGEPGun');
        AddInvBan(class'#var(prefix)AmmoRocket');
        AddInvBan(class'#var(prefix)AmmoRocketWP');
        AddStandardAugSet();
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Freeman Mode
    case 5:
        name = "Freeman Mode";
        if(get_name) return name;
        AddLoadoutPlayerMsg("Rather than offer you the illusion of free choice, I will take the liberty of choosing for you...");
        AddInvBan(class'Engine.Weapon');
        AddInvBan(class'Engine.Ammo');
        AddSkillBan(class'#var(prefix)SkillWeaponHeavy');
        AddSkillBan(class'#var(prefix)SkillWeaponPistol');
        AddSkillBan(class'#var(prefix)SkillWeaponRifle');
        NeverBanSkill(class'#var(prefix)SkillWeaponLowTech');
        AddInvAllow(class'#var(prefix)WeaponCrowbar');
        AddStartInv(class'#var(prefix)WeaponCrowbar');
        AddStandardAugSet();
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Grenades Only
    case 6:
        name = "Grenades Only";
        if(get_name) return name;
        AddLoadoutPlayerMsg("Grenades Only!");
        AddInvBan(class'Engine.Weapon');
        AddInvBan(class'Engine.Ammo');
        AddSkillBan(class'#var(prefix)SkillWeaponHeavy');
        AddSkillBan(class'#var(prefix)SkillWeaponRifle');
        AddSkillBan(class'#var(prefix)SkillWeaponPistol');
        AddSkillBan(class'#var(prefix)SkillWeaponLowTech');
        NeverBanSkill(class'#var(prefix)SkillDemolition');
        AddInvAllow(class'#var(prefix)WeaponLAM');
        AddInvAllow(class'#var(prefix)AmmoLAM');
        AddInvAllow(class'#var(prefix)WeaponGasGrenade');
        AddInvAllow(class'#var(prefix)AmmoGasGrenade');
        AddInvAllow(class'#var(prefix)WeaponNanoVirusGrenade');
        AddInvAllow(class'#var(prefix)AmmoNanoVirusGrenade');
        AddInvAllow(class'#var(prefix)WeaponEMPGrenade');
        AddInvAllow(class'#var(prefix)AmmoEMPGrenade');
        AddInvAllow(class'#var(package).WeaponRubberBaton');
        AddStartInv(class'#var(prefix)WeaponLAM');
        AddStartInv(class'#var(prefix)WeaponGasGrenade');
        AddStartInv(class'#var(prefix)WeaponNanoVirusGrenade');
        AddStartInv(class'#var(prefix)WeaponEMPGrenade');
        AddStartInv(class'#var(package).WeaponRubberBaton');
        AddItemSpawn(class'#var(prefix)WeaponLAM',50);
        AddItemSpawn(class'#var(prefix)WeaponGasGrenade',50);
        AddItemSpawn(class'#var(prefix)WeaponNanoVirusGrenade',50);
        AddItemSpawn(class'#var(prefix)WeaponEMPGrenade',50);
        AddItemSpawn(class'#var(package).WeaponRubberBaton',20);
        AddStandardAugSet();
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region No Pistols
    case 7:
        name = "No Pistols";
        if(get_name) return name;
        AddLoadoutPlayerMsg("No Pistols");
        AddInvBan(class'#var(prefix)WeaponPistol');
        AddInvBan(class'#var(prefix)WeaponStealthPistol');
        AddInvBan(class'#var(prefix)Ammo10mm');
        AddStandardAugSet();
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region No Swords
    case 8:
        name = "No Swords";
        if(get_name) return name;
        AddLoadoutPlayerMsg("No Swords");
        AddInvBan(class'#var(prefix)WeaponSword');
        AddInvBan(class'#var(prefix)WeaponNanoSword');
        AddStandardAugSet();
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Hipster JC
    case 9:
        name = "Hipster JC";
        if(get_name) return name;
        AddLoadoutPlayerMsg("That's too mainstream");
        AddInvBan(class'#var(prefix)WeaponNanoSword');
        AddInvBan(class'#var(prefix)WeaponPistol');
        AddInvBan(class'#var(prefix)WeaponStealthPistol');
        AddInvBan(class'#var(prefix)Ammo10mm');
        AddInvBan(class'#var(prefix)WeaponGEPGun');
        AddInvBan(class'#var(prefix)AmmoRocket');
        AddInvBan(class'#var(prefix)AmmoRocketWP');
        AddInvBan(class'#var(prefix)WeaponModLaser');
        //AddStartAug(class'#var(prefix)AugSpeed'); //Speed is overused!
        AddStartAug(class'#var(prefix)AugEMP'); //It's actually a really good aug, guys
        AddAugBan(class'#var(prefix)AugSpeed');
        AddAugBan(class'#var(prefix)AugPower');
        AddAugBan(class'#var(prefix)AugHealing');
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region By The Book
    case 10:
        name = "By the Book";
        if(get_name) return name;
        AddLoadoutPlayerMsg("By the Book");
        AddInvBan(class'#var(prefix)Lockpick');
        AddInvBan(class'#var(prefix)Multitool');
        AddSkillBan(class'#var(prefix)SkillComputer');
        AddSkillBan(class'#var(prefix)SkillLockpicking');
        AddSkillBan(class'#var(prefix)SkillTech');
        AddStartAug(class'#var(prefix)AugStealth');
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Explosives Only
    case 11:
        name = "Explosives Only";
        if(get_name) return name;
        AddLoadoutPlayerMsg("Explosives Only!");
        AddInvBan(class'Engine.Weapon');
        AddInvBan(class'Engine.Ammo');
        AddSkillBan(class'#var(prefix)SkillWeaponPistol');
        AddSkillBan(class'#var(prefix)SkillWeaponLowTech');
        NeverBanSkill(class'#var(prefix)SkillDemolition');
        NeverBanSkill(class'#var(prefix)SkillWeaponHeavy');
        AddInvAllow(class'#var(prefix)WeaponGEPGun');
        AddInvAllow(class'#var(prefix)AmmoRocket');
        AddInvAllow(class'#var(prefix)AmmoRocketWP');
        AddInvAllow(class'#var(prefix)WeaponLAW');
        AddInvAllow(class'#var(prefix)WeaponLAM');
        AddInvAllow(class'#var(prefix)AmmoLAM');
        AddInvAllow(class'#var(prefix)WeaponEMPGrenade');
        AddInvAllow(class'#var(prefix)AmmoEMPGrenade');
        AddInvAllow(class'#var(prefix)WeaponGasGrenade');
        AddInvAllow(class'#var(prefix)AmmoGasGrenade');
        AddInvAllow(class'#var(prefix)WeaponNanoVirusGrenade');
        AddInvAllow(class'#var(prefix)AmmoNanoVirusGrenade');
        AddInvAllow(class'#var(prefix)WeaponAssaultGun');
        AddInvAllow(class'#var(prefix)Ammo20mm');
        AddInvAllow(class'#var(package).WeaponRubberBaton');
        AddStartInv(class'#var(prefix)WeaponGEPGun');
        AddStartInv(class'#var(package).WeaponRubberBaton');
        AddItemSpawn(class'#var(prefix)WeaponLAW',75);
        AddItemSpawn(class'#var(prefix)WeaponLAM',100);
        AddItemSpawn(class'#var(prefix)WeaponEMPGrenade',75);
        AddItemSpawn(class'#var(prefix)WeaponGasGrenade',75);
        AddItemSpawn(class'#var(prefix)WeaponNanoVirusGrenade',75);
        AddItemSpawn(class'#var(package).WeaponRubberBaton',20);
        AddItemSpawn(class'#var(prefix)AmmoRocket',100);
        AddItemSpawn(class'#var(prefix)AmmoRocketWP',100);
        AddItemSpawn(class'#var(prefix)Ammo20mm',100);
        AddStandardAugSet();
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Random Aug
    case 12:
        // loadout for random starting aug
        name = "Random Starting Aug";
        if(get_name) return name;
        AddRandomAug();
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Straight Edge
    case 13:
        name = "Straight Edge";
        if(get_name) return name;
        AddLoadoutPlayerMsg("Keep it on the straight and narrow!");
        AddInvBan(class'#var(prefix)Liquor40oz');
        AddInvBan(class'#var(prefix)LiquorBottle');
        AddInvBan(class'#var(prefix)WineBottle');
        AddInvBan(class'#var(prefix)Cigarettes');
        AddInvBan(class'#var(prefix)VialCrack');
        AddStandardAugSet();
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Reduced Aug Set
    case 14:
        name = "Reduced Aug Set";
        if(get_name) return name;
        BanRandomAugs(6); //18 augs total, ban a third of them
        AddRandomAug(); //and get a random aug to start
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region The Three Leg Augs
    case 15:
        name = "The Three Leg Augs";
        if(get_name) return name;
        AddAugBan(class'#var(prefix)AugSpeed');
        BanRandomAugs(6); // set bans before adding new augs, focus on the new leg augs

        AddAugAllow(class'AugStealth');
        AddAugAllow(class'AugOnlySpeed');
        AddAugAllow(class'AugJump');
        AddAugAllow(class'AugOnlySpeed');

        SetGlobalSeed("DXRLoadouts random leg aug");
        switch(rng(3)) {
        case 0: AddStartAug(class'AugOnlySpeed'); break;
        case 1: AddStartAug(class'AugJump'); break;
        case 2: AddStartAug(class'AugStealth'); break;
        }
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Speedrun
    case 16:
        name = "Speed Enhancement";
        if(get_name) return name;
        AddStartAug(class'#var(prefix)AugSpeed');
        return name;
    //#endregion
/////////////////////////////////////////////////////////////////
    //#region Vision
    #ifdef injections
    case 17:
        name = "My Vision Is Augmented";
        if(get_name) return name;
        BanRandomAugs(6);
        AddStandardAugSet();
        AddAugAllow(class'#var(prefix)AugVision');
        AddAugAllow(class'AugVisionShort');
        AddAugAllow(class'AugInfraVision');
        AddAugAllow(class'AugMotionSensor');
        SetGlobalSeed("DXRLoadouts my vision is augmented");
        switch(rng(3)) {
        case 0: AddStartAug(class'AugVisionShort'); break;
        case 1: AddStartAug(class'AugInfraVision'); break;
        case 2: AddStartAug(class'AugMotionSensor'); break;
        }
        return name;
    #endif
    //#endregion
/////////////////////////////////////////////////////////////////
    }
    return "";
}

//#region AdjustFlags

static function AdjustFlags(DXRFlags flags, int loadout)
{
    switch(loadout) {
    case 15:
        //The Three Leg Augs
        flags.moresettings.aug_loc_rando = 100;
        break;
    case 17:
        //My Vision Is Augmented
        flags.moresettings.aug_loc_rando = 100;
        break;
    }
}

//#endregion

//#region Loadout Help
function string LoadoutHelpText(int loadout)
{
    local string helpText;

    switch(loadout) {
    case 0:
        //All Items Allowed
        return "All items and augs are allowed.  You start with the Running Enhancement augmentation, and the Jump Enhancement aug is also available.";
    case 1:
        //SWTP Pure
        helpText = "The only weapon allowed is the Riot Prod and the Rubber Baton (which is unable to deal damage to anything but the environment).  ";
        #ifdef injections
        helpText = helpText $ "You start with Run Silent, Microfibral Muscle, and Infravision augmentations.  ";
        #else
        helpText = helpText $ "You start with Run Silent and Microfibral Muscle augmentations.  ";
        #endif
        helpText = helpText $ "Speed Enhancement augmentation is banned.  Running Enhancement and Jump Enhancement augs are available.";
        return helpText;
    case 2:
        //SWTP Plus
        helpText = "The only weapons allowed are the Riot Prod, mini-crossbow (with tranquilizer darts), EMP Grenades, Gas Grenades, Scrambler Grenades, Pepper Spray, and the Rubber Baton (which is unable to deal damage to anything but the environment).  ";
        #ifdef injections
        helpText = helpText $ "You start with Run Silent, Microfibral Muscle, and Infravision augmentations.  ";
        #else
        helpText = helpText $ "You start with Run Silent and Microfibral Muscle augmentations.  ";
        #endif
        helpText = helpText $ "Speed Enhancement augmentation is banned.  Running Enhancement and Jump Enhancement augs are available.";
        return helpText;
    case 3:
        //Ninja JC
        helpText = "Become the ninja!  Use throwing knives, swords, mini-crossbows, and grenades to bypass and eliminate your enemies!  ";
        helpText = helpText $ "Speed Enhancement and Run Silent augmentations are banned, but you start with the Ninja augmentation instead, which combines the functionality of both!";
        return helpText;
    case 4:
        //Don't give me the GEP Gun
        return "All items and augs are allowed except for the GEP Gun.  You start with the Running Enhancement augmentation, and the Jump Enhancement aug is also available.";
    case 5:
        //Freeman Mode
        return "The only weapon allowed is the Crowbar.  You start with the Running Enhancement augmentation, and the Jump Enhancement aug is also available.";
    case 6:
        //Grenades Only
        return "The only weapons allowed are grenades and the Rubber Baton (which is unable to deal damage to anything but the environment).  You start with the Running Enhancement augmentation, and the Jump Enhancement aug is also available.";
    case 7:
        //No Pistols
        return "All items and augs are allowed except for the Pistol and Stealth Pistol.  You start with the Running Enhancement augmentation, and the Jump Enhancement aug is also available.";
    case 8:
        //No Swords
        return "All items and augs are allowed except for the Sword and Dragon Tooth Sword.  You start with the Running Enhancement augmentation, and the Jump Enhancement aug is also available.";
    case 9:
        //Hipster JC
        helpText = "JC used things before they were cool, so he doesn't want to use them any more.  In terms of weapons, JC won't use the Dragon Tooth Sword, Pistol, Stealth Pistol, GEP Gun, or Laser Modifications.  ";
        helpText = helpText $ "JC also won't use the Speed Enhancement, Power Recirculator, or Regeneration augmentations.  ";
        helpText = helpText $ "You start with the EMP Shield augmentation (JC is using it before it gets cool).";
        return helpText;
    case 10:
        //By the Book
        return "Follow UNATCO protocol!  All items and augs are allowed except for the Lockpick and Multitool.  The Computers skill is banned to prevent hacking.  You start with the Run Silent augmentation.";
    case 11:
        //Explosives Only
        return "The only weapons allowed are grenades, GEP Gun, Assault Rifle with 20mm ammo, and the Rubber Baton (which is unable to deal damage to anything but the environment).  "$"You start with the Running Enhancement augmentation, and the Jump Enhancement aug is also available.";
    case 12:
        //Random Starting Aug
        return "All items and augs are allowed.  You start with a randomly selected augmentation.";
    case 13:
        //Straight Edge
        return "All items and augs are allowed except for alcohol, cigarettes, and zyme.  You start with the Running Enhancement augmentation, and the Jump Enhancement aug is also available.";
    case 14:
        //Reduced Aug Set
        return "All items are allowed.  Six randomly selected augs are banned, and you start with a randomly selected augmentation.";
    case 15:
        //The Three Leg Augs
        return "All items are allowed.  Speed Enhancement and six randomly selected augs are banned.  You start with one of the Running Enhancement, Jump Enhancement, or Run Silent augmentations." $ CR() $ CR() $ "Enables Aug Slot Rando by default.";
    case 16:
        //Speed Enhancement
        return "The old-fashioned DXRando experience!  All items and augs are allowed.  You start with the Speed Enhancement augmentation.";
    #ifdef injections
    case 17:
        //My Vision Is Augmented
        return "All items are allowed.  Six randomly selected augs are banned.  You start with one of the Short Vision Enhancement, InfraVision, or Motion Sensor augmentations.  "$"Running Enhancement and Jump Enhancement augs are also available." $ CR() $ CR() $ "Enables Aug Slot Rando by default.";
    #endif
    }

    return "";
}
//#endregion

function AddStandardAugSet()
{
    AddStartAug(class'AugOnlySpeed');
    AddAugAllow(class'AugStealth'); // I think this needs to be explicitly allowed because of the shared leg slot
    AddAugAllow(class'AugOnlySpeed');
    AddAugAllow(class'AugJump');
    AddAugAllow(class'#var(prefix)AugSpeed');
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

function AddLoadoutPlayerMsg(string msg)
{
    item_set.player_message=msg;
}

function AddInvBan(class<Inventory> inv)
{
    local int i;

    if( inv == None ) return;

    for(i=0; i < ArrayCount(item_set.ban_types); i++) {
        if( item_set.ban_types[i] == None ) {
            item_set.ban_types[i] = inv;
            return;
        }
    }
}

function AddSkillBan(class<Skill> skill)
{
    local int i;

    if( skill == None ) return;

    for(i=0; i < ArrayCount(item_set.ban_skills); i++) {
        if( item_set.ban_skills[i] == None ) {
            item_set.ban_skills[i] = skill;
            return;
        }
    }
}

function AddAugBan(class<Augmentation> aug)
{
    local int i;

    if( aug == None ) return;

    for(i=0; i < ArrayCount(item_set.ban_augs); i++) {
        if( item_set.ban_augs[i] == None ) {
            item_set.ban_augs[i] = aug;
            return;
        }
    }
}

function AddInvAllow(class<Inventory> inv)
{
    local int i;

    if( inv == None ) return;

    for(i=0; i < ArrayCount(item_set.allow_types); i++) {
        if( item_set.allow_types[i] == None ) {
            item_set.allow_types[i] = inv;
            return;
        }
    }
}

function AddSkillAllow(class<Skill> skill)
{
    local int i;

    if( skill == None ) return;

    for(i=0; i < ArrayCount(item_set.allow_skills); i++) {
        if( item_set.allow_skills[i] == None ) {
            item_set.allow_skills[i] = skill;
            return;
        }
    }
}

function AddAugAllow(class<Augmentation> aug)
{
    local int i;

    if( aug == None ) return;

    for(i=0; i < ArrayCount(item_set.allow_augs); i++) {
        if( item_set.allow_augs[i] == None ) {
            item_set.allow_augs[i] = aug;
            return;
        }
    }
}

function CreateAugmentations(#var(PlayerPawn) p)
{ // needed for pulling augmentation descriptions
    local int i;

    for(i=0; i < ArrayCount(item_set.allow_augs); i++) {
        if( item_set.allow_augs[i] == None ) continue;
        CreateAugmentation(p, item_set.allow_augs[i]);
    }
}

function CreateAugmentation(DeusExPlayer player, class<Augmentation> AddAug)
{
    local int augIndex;
    local Augmentation anAug;
    local Augmentation LastAug;
    local AugmentationManager augman;

    augman = player.AugmentationSystem;
    for(LastAug = augman.FirstAug; LastAug.next != None; LastAug = LastAug.next) {
        if(LastAug.class == AddAug) return;
    }

    anAug = Spawn(AddAug, augman);
    anAug.Player = player;

    if (anAug != None)
    {
        if (augman.FirstAug == None)
        {
            augman.FirstAug = anAug;
        }
        else
        {
            LastAug.next = anAug;
        }

        LastAug  = anAug;
    }
}


function NeverBanSkill(class<Skill> skill)
{
    local int i;

    if( skill == None ) return;

    for(i=0; i < ArrayCount(item_set.never_ban_skills); i++) {
        if( item_set.never_ban_skills[i] == None ) {
            item_set.never_ban_skills[i] = skill;
            return;
        }
    }
}

function AddStartInv(class<Inventory> inv)
{
    local int i;

    if( inv == None ) return;

    for(i=0; i < ArrayCount(item_set.starting_equipment); i++) {
        if( item_set.starting_equipment[i] == None ) {
            item_set.starting_equipment[i] = inv;
            return;
        }
    }
}

function AddStartAug(class<Augmentation> aug)
{
    local int i;

    if( aug == None ) return;

    for(i=0; i < ArrayCount(item_set.starting_augs); i++) {
        if( item_set.starting_augs[i] == None ) {
            if(dxr.flags.IsHalloweenMode() && (aug==class'AugOnlySpeed' || aug==class'#var(prefix)AugSpeed') && dxr.flags.settings.speedlevel == 0) {
                aug = class'#var(prefix)AugStealth';// this is Halloween!
            } else if(dxr.flags.settings.speedlevel == 0) {
                continue;
            }
            item_set.starting_augs[i] = aug;
            return;
        }
    }
}

function AddRandomAug()
{
    local int i;

    for(i=0; i < ArrayCount(item_set.starting_augs); i++) {
        if( item_set.starting_augs[i] == None ) {
            SetGlobalSeed("DXRLoadouts AugRandom " $ i);
            item_set.starting_augs[i] = class'DXRAugmentations'.static.GetRandomAug(dxr);
            return;
        }
    }
}

function BanRandomAugs(int num)
{
    local int i;

    while(num-- > 0) {
        for(i=0; i < ArrayCount(item_set.ban_augs); i++) {
            if( item_set.ban_augs[i] == None ) {
                SetGlobalSeed("DXRLoadouts BanAugRandom " $ i);
                item_set.ban_augs[i] = class'DXRAugmentations'.static.GetRandomAug(dxr);
                return;
            }
        }
    }
}

function AddItemSpawn(class<Inventory> inv, int chances)
{
    local int i;

    if( inv == None ) return;

    for(i=0; i < ArrayCount(item_set.item_spawns); i++) {
        if( item_set.item_spawns[i] == None ) {
            item_set.item_spawns[i] = inv;
            item_set.item_spawns_chances[i] = chances;
            return;
        }
    }
}
//#endregion

function string GetName(int i)
{
    return LoadoutInfo(i, true);
}

//#region AnyEntry
function AnyEntry()
{
    local ConEventTransferObject c;

    Super.AnyEntry();

#ifndef injections
    // TODO: fix being given items from conversations for other mods
    /*foreach AllObjects(class'ConEventTransferObject', c) {
        l(c.objectName @ c.giveObject @ c.toName);
        if( c.toName == "JCDenton" && is_banned(item_set, c.giveObject) ) {
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
    return _is_banned(item_set, item);
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

function bool is_skill_banned(class<Skill> skill)
{
    return _is_skill_banned(item_set, skill);
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

function bool is_aug_banned(class<Augmentation> aug)
{
    return _is_aug_banned(item_set, aug);
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
    return _allow_skill_ban(item_set, skill);
}

function class<Inventory> get_starting_item()
{
    return item_set.starting_equipment[0];
}

function bool ban(DeusExPlayer player, Inventory item)
{
    local bool bFixGlitches;

    if(IsMeleeWeapon(item) && Carcass(item.Owner) != None && player.FindInventoryType(item.class) != None) {
        return true;
    } else if ( _is_banned( item_set, item.class) ) {
        if( item_set.player_message != "" ) {
            //item.ItemName = item.ItemName $ ", " $ item_set.player_message;
            player.ClientMessage(item_set.player_message, 'Pickup', true);
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
    switch(dxr.flags.loadout) {
        case 3:
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
    CreateAugmentations(p);
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

    for(i=0; i < ArrayCount(item_set.starting_augs); i++) {
        if( item_set.starting_augs[i] == a ) return true;
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
    return is_aug_banned(a);
}

function class<Augmentation> GetExtraAug(int i)
{ // we add augs to the AugmentationManager, but not its default list
    if(i >= ArrayCount(item_set.allow_augs)) return None;
    return item_set.allow_augs[i];
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

    for(i=0; i < ArrayCount(item_set.starting_equipment); i++) {
        iclass = item_set.starting_equipment[i];
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
    for(i=0; i < ArrayCount(item_set.starting_augs); i++) {
        aclass = item_set.starting_augs[i];
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

    if(dxr.dxInfo.MissionNumber < 0) return;

    l("SpawnItems()");
    SetSeed("SpawnItems()");

    reducer = DXRReduceItems(dxr.FindModule(class'DXRReduceItems'));

    for(i=0;i<ArrayCount(item_set.item_spawns);i++) {
        aclass = item_set.item_spawns[i];
        if( aclass == None ) continue;
        chance = item_set.item_spawns_chances[i];
        if( chance <= 0 ) continue;

        chance /= 3;
        if(chance <= 0) chance=1;
        for(j=0;j<mult_items_per_level*3;j++) {
            if( chance_single(chance) ) {
                loc = GetRandomPositionFine();
                if (ClassIsChildOf(aclass,class'Inventory')){
                    //75% is pretty close to the size of a CrateUnbreakableSmall
                    a = SpawnItemInContainer(self,class<Inventory>(aclass),loc,,0.75);
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
        spawns[i]=item_set.item_spawns[i];
        chances[i]=item_set.item_spawns_chances[i];
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
