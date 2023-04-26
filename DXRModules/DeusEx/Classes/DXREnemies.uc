class DXREnemies extends DXREnemiesShuffle;

//const FactionAny = 0;// in BAse
const FactionOther = 1;
const NSF = 2;
const UNATCO = 3;
const MJ12 = 4;

function CheckConfig()
{
    local int i;
    if( ConfigOlderThan(2,2,5,1) ) {
        enemy_multiplier = 1;
        min_rate_adjust = default.min_rate_adjust;
        max_rate_adjust = default.max_rate_adjust;

        for(i=0; i < ArrayCount(randommelees); i++ ) {
            randommelees[i].type = "";
            randommelees[i].chance = 0;
        }

        AddRandomWeapon("WeaponShuriken", 12);
        AddRandomWeapon("WeaponPistol", 5);
        AddRandomWeapon("WeaponStealthPistol", 4);
        AddRandomWeapon("WeaponAssaultGun", 10);
        AddRandomWeapon("WeaponMiniCrossbow", 5);
#ifdef gmdx
        AddRandomWeapon("#var(package).GMDXGepGun", 4);
#else
        AddRandomWeapon("WeaponGEPGun", 4);
#endif
        AddRandomWeapon("WeaponAssaultShotgun", 5);
        AddRandomWeapon("WeaponEMPGrenade", 5);
        AddRandomWeapon("WeaponFlamethrower", 4);
        AddRandomWeapon("WeaponGasGrenade", 5);
        AddRandomWeapon("WeaponHideAGun", 3);
        AddRandomWeapon("WeaponLAM", 5);
        AddRandomWeapon("WeaponLAW", 4);
        AddRandomWeapon("WeaponNanoVirusGrenade", 5);
        AddRandomWeapon("WeaponPepperGun", 4);
        AddRandomWeapon("WeaponPlasmaRifle", 7);
        AddRandomWeapon("WeaponRifle", 5);
        AddRandomWeapon("WeaponSawedOffShotgun", 6);
        AddRandomWeapon("WeaponProd", 2);

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


        defaultOrders = 'Wandering';
    }
    Super.CheckConfig();

    AddRandomEnemyType(class'#var(prefix)ThugMale', 5, FactionAny);
    AddRandomEnemyType(class'#var(prefix)ThugMale2', 5, FactionAny);
    AddRandomEnemyType(class'#var(prefix)ThugMale3', 5, FactionAny);
    AddRandomEnemyType(class'#var(prefix)Greasel', 4, FactionAny);
    AddRandomEnemyType(class'#var(prefix)Gray', 2, FactionAny);
    AddRandomEnemyType(class'#var(prefix)Karkian', 2, FactionAny);
    AddRandomEnemyType(class'#var(prefix)SpiderBot2', 2, FactionAny);//little spider
    AddRandomEnemyType(class'#var(prefix)MilitaryBot', 2, FactionAny);
    AddRandomEnemyType(class'#var(prefix)SpiderBot', 2, FactionAny);//big spider
    AddRandomEnemyType(class'#var(prefix)SecurityBot2', 2, FactionAny);//walker
    AddRandomEnemyType(class'#var(prefix)SecurityBot3', 2, FactionAny);//little guy from liberty island
    AddRandomEnemyType(class'#var(prefix)SecurityBot4', 2, FactionAny);//unused little guy

    AddRandomEnemyType(class'#var(prefix)UNATCOTroop', 10, UNATCO);
    ReadConfig();
}

function FirstEntry()
{
    local PlaceholderEnemy placeholder;
    Super.FirstEntry();

    SwapScriptedPawns(dxr.flags.settings.enemiesshuffled, true);
    // delete placeholders after doing swaps but before doing clones
    foreach AllActors(class'PlaceholderEnemy', placeholder) {
        placeholder.Destroy();
    }
    RandoEnemies(dxr.flags.settings.enemiesrandomized, dxr.flags.settings.hiddenenemiesrandomized);
    RandoCarcasses(dxr.flags.settings.swapitems);
}

function RandoEnemies(int percent, int hidden_percent)
{
    // TODO: later when hidden_percent is well tested, we can get rid of it and _perc
    local int i, _perc;
    local ScriptedPawn p;
    local ScriptedPawn n;
    local ScriptedPawn newsp;

    l("RandoEnemies "$percent);

    SetSeed( "RandoEnemies" );
    if(percent <= 0) return;

    foreach AllActors(class'ScriptedPawn', p)
    {
        if( p != None && p.bImportant ) continue;
#ifdef gmdx
        if( SpiderBot2(p) != None && SpiderBot2(p).bUpsideDown ) continue;
#endif
        RandomizeSize(p);
    }

    foreach AllActors(class'ScriptedPawn', p)
    {
        if( p == newsp ) break;
        if( IsCritter(p) ) continue;
        //if( SkipActor(p, 'ScriptedPawn') ) continue;
        //if( IsInitialEnemy(p) == False ) continue;
#ifdef gmdx
        if( SpiderBot2(p) != None && SpiderBot2(p).bUpsideDown ) continue;
#endif

        if( HasItemSubclass(p, class'Weapon') == false ) continue;//don't randomize neutral npcs that don't already have weapons

        if(p.bHasCloak) p.CloakThreshold = p.Health - 10;// make Anna and Walt cloak quickly
        _perc = percent;
        if(p.bHidden) _perc = hidden_percent;

        if( chance_single(_perc) ) RandomizeSP(p, _perc);
        CheckHelmet(p);

        if(p.bImportant && p.Tag != 'RaidingCommando') continue;
        if(p.bInvincible) continue;
        if( p.Region.Zone.bWaterZone || p.Region.Zone.bPainZone ) continue;

        if( chance_single(_perc) == false ) continue;

        for(i = rng(enemy_multiplier*100+_perc)/100; i >= 0; i--) {
            n = RandomEnemy(p, _perc);
            if( newsp == None ) newsp = n;
        }
    }
}

function int GetFactionId(ScriptedPawn p)
{
    switch(p.class) {
    case class'#var(prefix)UNATCOTroop':
        return UNATCO;
    }
    switch(p.Alliance) {
    case 'UNATCO':
        return UNATCO;
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
        p.BaseAccuracy -= FClamp(rngf() * float(dxr.flags.settings.enemystats)/200.0, 0, 0.5);
    }

    if(p.RaiseAlarm==RAISEALARM_BeforeAttacking && chance_single(dxr.flags.settings.enemystats)) {
        p.RaiseAlarm = RAISEALARM_BeforeFleeing;
    }

    if( IsCritter(p) ) return; // only give random weapons to humans and robots
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
    if(p.Mesh != LodMesh'DeusExCharacters.GM_Jumpsuit')  return;

    switch(p.MultiSkins[6]) {
    case Texture'DeusExItems.Skins.PinkMaskTex':
    case Texture'DeusExCharacters.Skins.GogglesTex1':
        if(chance_single(dxr.flags.settings.enemystats)) {
            p.MultiSkins[6] = Texture'DeusExCharacters.Skins.MechanicTex3';
        }
        break;
    default:
        if(!chance_single(dxr.flags.settings.enemystats)) {
            p.MultiSkins[5] = Texture'DeusExItems.Skins.GrayMaskTex';
            p.MultiSkins[6] = Texture'DeusExItems.Skins.PinkMaskTex';
            p.Texture = Texture'DeusExItems.Skins.PinkMaskTex';
        }
    }
}

function AddDXRCredits(CreditsWindow cw)
{
    local int i;
    local string weaponName;
    if(dxr.flags.IsZeroRando()) return;

    cw.PrintHeader( dxr.flags.settings.enemiesrandomized $ "% Added Enemies");
    for(i=0; i < ArrayCount(_randomenemies); i++) {
        if( _randomenemies[i].type == None ) continue;
        cw.PrintText(_randomenemies[i].type.default.FamiliarName $ ": " $ FloatToString(_randomenemies[i].chance, 1) $ "%" );
    }
    cw.PrintLn();

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
