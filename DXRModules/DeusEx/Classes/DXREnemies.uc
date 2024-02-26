class DXREnemies extends DXREnemiesShuffle;

//const FactionAny = 0;// in Base
const FactionOther = 1;
const NSF = 2;
const UNATCO = 3;
const MJ12 = 4;
const Police = 5;
//const FactionsEnd = 6;// end of the factions list, defined in Base

function CheckConfig()
{
    local int i;
    if( ConfigOlderThan(2,5,0,9) ) {
        enemy_multiplier = 1;
        min_rate_adjust = 0.1;
        max_rate_adjust = 3.0;

        for(i=0; i < ArrayCount(randomweapons); i++ ) {
            randomweapons[i].type = "";
            randomweapons[i].chance = 0;
        }
        for(i=0; i < ArrayCount(randommelees); i++ ) {
            randommelees[i].type = "";
            randommelees[i].chance = 0;
        }

        AddRandomWeapon("WeaponShuriken", 10);
        AddRandomWeapon("WeaponPistol", 6);
        AddRandomWeapon("WeaponStealthPistol", 4);
        AddRandomWeapon("WeaponAssaultGun", 12);
        AddRandomWeapon("WeaponMiniCrossbow", 6);
#ifdef gmdx
        AddRandomWeapon("#var(package).GMDXGepGun", 4);
#else
        AddRandomWeapon("WeaponGEPGun", 4);
#endif
        AddRandomWeapon("WeaponAssaultShotgun", 6);
        AddRandomWeapon("WeaponEMPGrenade", 4);
        AddRandomWeapon("WeaponFlamethrower", 4);
        AddRandomWeapon("WeaponGasGrenade", 4);
        AddRandomWeapon("WeaponHideAGun", 3);
        AddRandomWeapon("WeaponLAM", 5);
        AddRandomWeapon("WeaponLAW", 4);
        AddRandomWeapon("WeaponNanoVirusGrenade", 4);
        AddRandomWeapon("WeaponPepperGun", 2);
        AddRandomWeapon("WeaponPlasmaRifle", 6);
        AddRandomWeapon("WeaponRifle", 6);
        AddRandomWeapon("WeaponSawedOffShotgun", 7);
        AddRandomWeapon("WeaponProd", 3);

        AddRandomMelee("WeaponBaton", 15);
        AddRandomMelee("WeaponCombatKnife", 65);
        AddRandomMelee("WeaponCrowbar", 15);
        AddRandomMelee("WeaponSword", 5);

        AddRandomBotWeapon("WeaponRobotMachinegun", 60);
        AddRandomBotWeapon("WeaponRobotRocket", 10);
        AddRandomBotWeapon("WeaponMJ12Rocket", 10);
        AddRandomBotWeapon("WeaponSpiderBot", 5);
        AddRandomBotWeapon("WeaponSpiderBot2", 5);
        AddRandomBotWeapon("WeaponFlamethrower", 5);
        AddRandomBotWeapon("WeaponPlasmaRifle", 5);
        //AddRandomBotWeapon("WeaponGraySpit", 5);  //Gray Spit doesn't seem to work immediately

        defaultOrders = 'DynamicPatrolling';
    }
    Super.CheckConfig();

    AddRandomEnemyType(class'#var(prefix)Greasel', 4, FactionAny);
    AddRandomEnemyType(class'#var(prefix)KarkianBaby', 1, FactionAny);
    AddRandomEnemyType(class'#var(prefix)Karkian', 1, FactionAny);
    AddRandomEnemyType(class'#var(prefix)SecurityBot2', 2, FactionAny);//walker
    AddRandomEnemyType(class'#var(prefix)SecurityBot3', 2, FactionAny);//little guy from liberty island
    AddRandomEnemyType(class'#var(prefix)SecurityBot4', 2, FactionAny);//unused little guy

    AddRandomEnemyType(class'#var(prefix)UNATCOTroop', 10, UNATCO);
    AddRandomEnemyType(class'UNATCOClone1', 10, UNATCO);
    AddRandomEnemyType(class'UNATCOClone2', 10, UNATCO);
    AddRandomEnemyType(class'UNATCOClone3', 10, UNATCO);
    AddRandomEnemyType(class'UNATCOClone4', 10, UNATCO);
    AddRandomEnemyType(class'#var(prefix)RiotCop', 5, UNATCO);
    AddRandomEnemyType(class'#var(prefix)MilitaryBot', 2, UNATCO);
    AddRandomEnemyType(class'#var(prefix)SpiderBot2', 1, UNATCO);//little spider
    AddRandomEnemyType(class'UNATCOCloneAugShield1', 2, UNATCO);
    AddRandomEnemyType(class'UNATCOCloneAugTough1', 2, UNATCO);
    AddRandomEnemyType(class'UNATCOCloneAugStealth1', 2, UNATCO);

    AddRandomEnemyType(class'#var(prefix)MJ12Troop', 10, MJ12);
    AddRandomEnemyType(class'#var(prefix)MJ12Commando', 2, MJ12);
    AddRandomEnemyType(class'MJ12Clone1', 7, MJ12);// MJ12 Executioner is strong
    AddRandomEnemyType(class'MJ12Clone2', 10, MJ12);
    AddRandomEnemyType(class'MJ12Clone3', 10, MJ12);
    AddRandomEnemyType(class'MJ12Clone4', 10, MJ12);
    AddRandomEnemyType(class'#var(prefix)MilitaryBot', 2, MJ12);
    AddRandomEnemyType(class'#var(prefix)SpiderBot2', 2, MJ12);//little spider
    AddRandomEnemyType(class'#var(prefix)SpiderBot', 2, MJ12);//big spider
    AddRandomEnemyType(class'GrayBaby', 1, MJ12);
    if(dxr.dxInfo.missionNumber == 10 || dxr.dxInfo.missionNumber == 11) {
        AddRandomEnemyType(class'#var(prefix)Gray', 1, MJ12);
        AddRandomEnemyType(class'FrenchGray', 1, MJ12);
    } else {
        AddRandomEnemyType(class'#var(prefix)Gray', 2, MJ12);
    }
    AddRandomEnemyType(class'#var(prefix)MIB', 1, MJ12);
    AddRandomEnemyType(class'MJ12CloneAugShield1', 2.5, MJ12);
    AddRandomEnemyType(class'MJ12CloneAugTough1', 2.5, MJ12);
    AddRandomEnemyType(class'MJ12CloneAugStealth1', 2.5, MJ12);

    AddRandomEnemyType(class'#var(prefix)Terrorist', 10, NSF);
    AddRandomEnemyType(class'NSFClone1', 10, NSF);
    AddRandomEnemyType(class'NSFClone2', 10, NSF);
    AddRandomEnemyType(class'NSFClone3', 10, NSF);
    AddRandomEnemyType(class'NSFClone4', 10, NSF);
    AddRandomEnemyType(class'#var(prefix)ThugMale', 5, NSF);
    AddRandomEnemyType(class'#var(prefix)ThugMale2', 5, NSF);
    AddRandomEnemyType(class'#var(prefix)ThugMale3', 5, NSF);
    AddRandomEnemyType(class'NSFCloneAugShield1', 1.5, NSF);
    AddRandomEnemyType(class'NSFCloneAugTough1', 1.5, NSF);
    AddRandomEnemyType(class'NSFCloneAugStealth1', 1.5, NSF);

    AddRandomEnemyType(class'#var(prefix)Gray', 1, FactionOther);
    AddRandomEnemyType(class'GrayBaby', 1, FactionOther);
    AddRandomEnemyType(class'#var(prefix)ThugMale', 5, FactionOther);
    AddRandomEnemyType(class'#var(prefix)ThugMale2', 5, FactionOther);
    AddRandomEnemyType(class'#var(prefix)ThugMale3', 5, FactionOther);
    AddRandomEnemyType(class'#var(prefix)SpiderBot2', 1, FactionOther);//little spider

    AddRandomEnemyType(class'#var(prefix)Cop', 10, Police);
    AddRandomEnemyType(class'#var(prefix)RiotCop', 10, Police);
    AddRandomEnemyType(class'#var(prefix)Doberman', 5, Police);
    AddRandomEnemyType(class'#var(prefix)SecretService', 1, Police);

    ReadConfig();
}

function FirstEntry()
{
    local PlaceholderEnemy placeholder;
    local #var(prefix)ScriptedPawn sp;

    Super.FirstEntry();

    SetSeed("DXREnemies FirstEntry");
    if(dxr.localURL == "10_PARIS_METRO" && chance_single(dxr.flags.moresettings.remove_paris_mj12)) {
        foreach AllActors(class'#var(prefix)ScriptedPawn', sp) {
            if(sp.Alliance=='mj12') {
                sp.Event='';
                sp.bHidden=true;
                sp.Destroy();
            }
        }
    }

    SwapScriptedPawns(dxr.flags.settings.enemiesshuffled, true);
    // delete placeholders after doing swaps but before doing clones
    foreach AllActors(class'PlaceholderEnemy', placeholder) {
        placeholder.Destroy();
    }
    RandoEnemies(dxr.flags.settings.enemiesrandomized, dxr.flags.settings.hiddenenemiesrandomized);
    RandoCarcasses(dxr.flags.settings.swapitems);
    GivePatrols();
}

function RandoEnemies(int percent, int hidden_percent)
{
    // TODO: later when hidden_percent is well tested, we can get rid of it and _perc
    local int i, _perc, num_enemies, e, new_enemies, r;
    local ScriptedPawn p;
    local ScriptedPawn enemies[128];

    l("RandoEnemies "$percent@hidden_percent@dxr.flags.settings.enemystats);
    if(percent <= 0 && hidden_percent <= 0 && dxr.flags.settings.enemystats <= 0)
        return;

    SetSeed( "RandoEnemies" );

    foreach AllActors(class'ScriptedPawn', p)
    {
#ifdef gmdx
        if( SpiderBot2(p) != None && SpiderBot2(p).bUpsideDown ) continue;
#endif
        if(!p.bImportant) {
            RandomizeSize(p);
        }

        if( IsCritter(p) ) continue;
        if( HasItemSubclass(p, class'Weapon') == false ) continue;//don't randomize neutral npcs that don't already have weapons

        enemies[num_enemies++] = p;
    }

    for(e=0; e<num_enemies; e++)
    {
        p = enemies[e];
        if(p.bHasCloak) p.CloakThreshold = p.Health - 10;// make Anna and Walt cloak quickly
        _perc = percent;
        if(p.bHidden) _perc = hidden_percent;

        if( _perc>=100 || chance_single(_perc) ) RandomizeSP(p, _perc);
        CheckHelmet(p);

        if(p.bImportant && p.Tag != 'RaidingCommando') continue;
        if(p.bInvincible) continue;
        if( p.Region.Zone.bWaterZone || p.Region.Zone.bPainZone ) continue;

        if( _perc < 100 && chance_single(_perc) == false ) continue;

        r = rng(enemy_multiplier*100+_perc);
        for(i = r/100; i >= 0; i--) {
            if(RandomEnemy(p, _perc) != None) new_enemies++;
        }
    }

    l("RandoEnemies num_enemies == " $ num_enemies $ ", new_enemies == " $ new_enemies $ ", percent == " $ percent);
}

function int GetFactionId(ScriptedPawn p)
{
    switch(p.class) {
    case class'#var(prefix)UNATCOTroop':
        return UNATCO;
    case class'#var(prefix)MJ12Troop':
    case class'#var(prefix)MJ12Commando':
    case class'#var(prefix)MIB':
    case class'#var(prefix)WIB':
        return MJ12;
    case class'#var(prefix)Terrorist':
        return NSF;
    case class'#var(prefix)Cop':
    case class'#var(prefix)RiotCop':
        return Police;
    }
    switch(p.Alliance) {
    case 'UNATCO':
        return UNATCO;
    case 'MJ12':
        return MJ12;
    case 'NSF':
        return NSF;
    case 'Cops':
        return Police;
    }
    return FactionOther;
}

function RandomizeSP(ScriptedPawn p, int percent)
{
    local int numWeapons,i;

    if( p == None ) return;

    l("RandomizeSP("$p$", "$percent$")");
    if( IsHuman(p.class) || dxr.flags.settings.bot_stats>0 ) {
        p.SurprisePeriod = rngrange(p.SurprisePeriod+0.1, 0.3, 1.2);
        p.GroundSpeed = rngrange(p.GroundSpeed, 0.9, 1.1);
        p.BaseAccuracy -= FClamp(rngf() * float(dxr.flags.settings.enemystats)/300.0, 0, 0.3);
        p.BaseAccuracy = FClamp(p.BaseAccuracy, 0, 2);//ensure BaseAccuracy doesn't go below 0
    }

    if(p.RaiseAlarm==RAISEALARM_BeforeAttacking && chance_single(dxr.flags.settings.enemystats)) {
        p.RaiseAlarm = RAISEALARM_BeforeFleeing;
    }

    if( IsCritter(p) ) return; // only give random weapons to humans and robots
    // TODO: if p.bIsFemale then give only 1 handed weapons?
    if( p.IsA('MJ12Commando') || p.IsA('WIB') ) return;

    if( IsHuman(p.class)) {
        if(!p.bImportant) {
            RemoveItem(p, class'Weapon');
            RemoveItem(p, class'Ammo');
        }

        GiveRandomWeapon(p, false, 2);
        if( chance_single(50) )
            GiveRandomWeapon(p, false, 2);
        GiveRandomMeleeWeapon(p);
        p.SetupWeapon(false);
    } else if (IsRobot(p.Class) && dxr.flags.settings.bot_weapons!=0) {
        numWeapons = GetWeaponCount(p);

        //Maybe it would be better if the bots *didn't* get their baseline weapons removed?
        RemoveItem(p, class'Weapon');
        RemoveItem(p, class'Ammo');

        //Since bots don't have melee weapons, they should get more ammo to compensate
        for (i=0;i<numWeapons;i++){
            GiveRandomBotWeapon(p, false, 6); //Give as many weapons as the bot defaults with
        }
        if( chance_single(50) ) //Give a chance for a bonus weapon
            GiveRandomBotWeapon(p, false, 6);
        p.SetupWeapon(false);
    }
}

function CheckHelmet(ScriptedPawn p)
{
    local int helmet_chance, visor_chance;
    if(p.Mesh != LodMesh'DeusExCharacters.GM_Jumpsuit') return;
    // tough augs don't need helmets
    if(NSFCloneAugTough1(p) != None || UNATCOCloneAugTough1(p) != None || MJ12CloneAugTough1(p) != None) return;

    // divide chances by 2 to lean towards vanilla
    // that way the game gets harder as you progress to enemies that typically have helmets

    if(#defined(injections)) // visors only work in vanilla due to our change in ScriptedPawn, so leave the chance to 0 for other mods
        visor_chance = dxr.flags.settings.enemystats / 3;

    // augs shouldn't get visors that cover their face
    if(NSFCloneAugStealth1(p) != None || NSFCloneAugTough1(p) != None || NSFCloneAugShield1(p) != None
        || UNATCOCloneAugStealth1(p) != None || UNATCOCloneAugTough1(p) != None || UNATCOCloneAugShield1(p) != None
        || MJ12CloneAugStealth1(p) != None || MJ12CloneAugTough1(p) != None || MJ12CloneAugShield1(p) != None
    ) {
        visor_chance = 0;
    }

    switch(p.MultiSkins[6]) {
    case Texture'DeusExItems.Skins.PinkMaskTex':
    case Texture'DeusExCharacters.Skins.GogglesTex1':
        // add helmet
        helmet_chance = dxr.flags.settings.enemystats / 2;
        if(chance_single(helmet_chance)) {
            if(rngb())
                p.MultiSkins[6] = Texture'#var(package).DXRandoPawns.NSFHelmet';
            else
                p.MultiSkins[6] = Texture'#var(package).DXRandoPawns.PlainRiotHelmet';
            if(chance_single(visor_chance)) {
                p.Texture = Texture'DeusExCharacters.Skins.VisorTex1';
            }
        }
        break;
    default:
        // remove helmet, enemystats of 0 means 50% chance to remove helmet, enemystats of 100 means 0% chance to remove helmet
        helmet_chance = (100 - dxr.flags.settings.enemystats) / 2;
        if(chance_single(helmet_chance)) {
            p.MultiSkins[5] = Texture'DeusExItems.Skins.GrayMaskTex';
            p.MultiSkins[6] = Texture'DeusExItems.Skins.PinkMaskTex';
            p.Texture = Texture'DeusExItems.Skins.PinkMaskTex';
        } else if(chance_single(visor_chance)) {
            p.Texture = Texture'DeusExCharacters.Skins.VisorTex1';
            if(p.MultiSkins[6]==Texture'DeusExCharacters.Skins.MJ12TroopTex4'){
                //Remove the vanilla goggles if they get a visor
                p.MultiSkins[6]=Texture'#var(package).DXRandoPawns.MJ12TroopTex4NoGoggles';
            }
        }
    }
}

function AddDXRCredits(CreditsWindow cw)
{
    local int i, f;
    local string weaponName, factionName;
    if(dxr.flags.IsZeroRando()) return;

    for(f=FactionAny+1; f<FactionsEnd; f++) {
        switch(f) {
        case FactionOther:
            factionName = "Other";
            break;
        case NSF:
            factionName = "NSF";
            break;
        case UNATCO:
            factionName = "UNATCO";
            break;
        case MJ12:
            factionName = "MJ12";
            break;
        case Police:
            factionName = "Police";
            break;
        default:
            factionName = "Faction "$f;
        }
        cw.PrintHeader( dxr.flags.settings.enemiesrandomized $ "% Added Enemies for "$factionName);
        for(i=0; i < ArrayCount(_randomenemies); i++) {
            if( _randomenemies[i].type == None || _randomenemies[i].faction != f ) continue;
            cw.PrintText(_randomenemies[i].type.default.FamiliarName $ ": " $ FloatToString(_randomenemies[i].chance, 1) $ "%" );
        }
        cw.PrintLn();
    }

    cw.PrintHeader("Extra Weapons For Enemies");
    for(i=0; i < ArrayCount(_randomweapons); i++) {
        if( _randomweapons[i].type == None ) continue;
        cw.PrintText( _randomweapons[i].type.default.ItemName $ ": " $ FloatToString(_randomweapons[i].chance, 1) $ "%" );
    }
    cw.PrintLn();

    cw.PrintHeader("Melee Weapons For Enemies");
    for(i=0; i < ArrayCount(_randommelees); i++) {
        if( _randommelees[i].type == None ) continue;
        cw.PrintText( _randommelees[i].type.default.ItemName $ ": " $ FloatToString(_randommelees[i].chance, 1) $ "%" );
    }
    cw.PrintLn();

    if(dxr.flags.settings.bot_weapons!=0) {
        cw.PrintHeader("Extra Weapons For Robots");
        for(i=0; i < ArrayCount(_randombotweapons); i++) {
            if( _randombotweapons[i].type == None ) continue;
            weaponName = _randombotweapons[i].type.default.ItemName;
            if (InStr(weaponName,"DEFAULT WEAPON NAME")!=-1){  //Many NPC weapons don't have proper names set
                weaponName = String(_randombotweapons[i].type.default.Class);
            }
            cw.PrintText( weaponName $ ": " $ FloatToString(_randombotweapons[i].chance, 1) $ "%" );
        }
        cw.PrintLn();
    }
}
