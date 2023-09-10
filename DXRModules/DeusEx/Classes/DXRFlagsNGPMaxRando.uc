class DXRFlagsNGPMaxRando extends DXRFlagsBase transient;


simulated function ExecMaxRando()
{
    // set local seed
    // set a flag to save that we are in Max Rando mode
    info("ExecMaxRando()");
    SetGlobalSeed("ExecMaxRando");
    maxrando = 1;

    RandomizeSettings(False);
}

//Initialize the values that get tweaked by max rando
simulated function InitMaxRandoSettings()
{
    local FlagsSettings difficulty_settings;
    difficulty_settings = DXRFlags(self).GetDifficulty(difficulty);

    settings.merchants = difficulty_settings.merchants;
    settings.dancingpercent = difficulty_settings.dancingpercent;
    settings.medbots = difficulty_settings.medbots;
    settings.repairbots = difficulty_settings.repairbots;
    settings.enemiesrandomized=difficulty_settings.enemiesrandomized;
    settings.enemystats=difficulty_settings.enemystats;
    settings.enemies_nonhumans=difficulty_settings.enemies_nonhumans;
    settings.bot_weapons=difficulty_settings.bot_weapons;
    settings.bot_stats=difficulty_settings.bot_stats;
    settings.turrets_move=difficulty_settings.turrets_move;
    settings.turrets_add=difficulty_settings.turrets_add;
    settings.skills_reroll_missions=difficulty_settings.skills_reroll_missions;
    settings.minskill=difficulty_settings.minskill;
    settings.maxskill=difficulty_settings.maxskill;
    settings.banned_skills=difficulty_settings.banned_skills;
    settings.banned_skill_levels=difficulty_settings.banned_skill_levels;
    settings.ammo=difficulty_settings.ammo;
    settings.multitools=difficulty_settings.multitools;
    settings.lockpicks=difficulty_settings.lockpicks;
    settings.biocells=difficulty_settings.biocells;
    settings.medkits=difficulty_settings.medkits;
    settings.equipment = difficulty_settings.equipment;
    settings.min_weapon_dmg=difficulty_settings.min_weapon_dmg;
    settings.max_weapon_dmg=difficulty_settings.max_weapon_dmg;
    settings.min_weapon_shottime=difficulty_settings.min_weapon_shottime;
    settings.max_weapon_shottime=difficulty_settings.max_weapon_shottime;
    settings.enemyrespawn = difficulty_settings.enemyrespawn;
    settings.health = difficulty_settings.health;
    settings.energy = difficulty_settings.energy;
}

//Randomize the values.  If forceMenuOptions is set, we will only allow the values to be set to
//the options available in DXRMenuSetupRando
simulated function RandomizeSettings(bool forceMenuOptions)
{
    info("RandomizeSettings("$string(forceMenuOptions)$")");

    // change the flags normally configurable on the Advanced Settings page, but try to keep the difficulty balanced
    // also make sure to randomize the doors mode and stuff
    MaxRandoVal(settings.merchants);
    MaxRandoVal(settings.dancingpercent);
    MaxRandoVal(settings.medbots);
    MaxRandoVal(settings.repairbots);

    settings.medbotuses = rng(7) + 1;
    settings.repairbotuses = rng(7) + 1;

    settings.medbotcooldowns = int(rngb()) + 1;// 1 or 2
    settings.repairbotcooldowns = int(rngb()) + 1;
    settings.medbotamount = int(rngb()) + 1;
    settings.repairbotamount = int(rngb()) + 1;

    if (forceMenuOptions){
        //Eventually we can add logic to randomize between the door menu options
    } else {
        settings.doorsmode = undefeatabledoors + doorindependent;
        settings.doorsdestructible = rng(100);
        settings.doorspickable = rng(100);
    }

    /* To match the menu options, we just randomize between 0, 25, 50, 75, and 100 */
    if (forceMenuOptions){
        settings.deviceshackable = rng(5)*25;
    } else {
        settings.deviceshackable = rng(100);
    }

    MaxRandoVal(settings.enemiesrandomized);
    settings.hiddenenemiesrandomized = settings.enemiesrandomized;
    MaxRandoVal(settings.enemystats);
    settings.enemiesshuffled = 100;
    MaxRandoVal(settings.enemies_nonhumans);

    if(rngb()) {
        settings.enemyrespawn = rng(120) + 120;
    } else {
        settings.enemyrespawn = 0;
    }

    if(rngb()) {
        settings.bot_weapons = 4;
    } else {
        settings.enemyrespawn = 0;
    }

    if(rngb()) {
        settings.bot_stats = 100;
    } else {
        settings.bot_stats = 0;
    }

    MaxRandoVal(settings.turrets_move);
    MaxRandoVal(settings.turrets_add);

    MaxRandoVal(settings.skills_reroll_missions);
    settings.skills_independent_levels = int(rngb());
    MaxRandoValPair(settings.minskill, settings.maxskill);
    MaxRandoVal(settings.banned_skills);
    MaxRandoVal(settings.banned_skill_levels);
    settings.skill_value_rando = 100;

    MaxRandoVal(settings.ammo);
    MaxRandoVal(settings.multitools);
    MaxRandoVal(settings.lockpicks);
    MaxRandoVal(settings.biocells);
    MaxRandoVal(settings.medkits);
    settings.equipment += int(rngb());

    MaxRandoValPair(settings.min_weapon_dmg, settings.max_weapon_dmg);
    MaxRandoValPair(settings.min_weapon_shottime, settings.max_weapon_shottime);

    settings.aug_value_rando = 100;

    settings.health += rng(100) - 50;
    MaxRandoVal(settings.energy);
}

function ClearDataVaultImages()
{
    local DataVaultImage image;

    while (player().FirstImage!=None){
        image = player().FirstImage;
        player().FirstImage=image.nextImage;
        //Theoretically if we were being more discriminating with the image deletion,
        //we'd want to also fix the prevImage value, but since we're just trashing
        //everything, it's unnecessary
        image.Destroy();
    }
}

function NewGamePlus()
{
    local #var(PlayerPawn) p;
    local DataStorage ds;
    local DXRSkills skills;
    local DXRWeapons weapons;
    local DXRAugmentations augs;
    local int i, bingo_win,bingo_freespaces;
    local float exp;
    local int randomStart;

    if( flagsversion == 0 ) {
        warning("NewGamePlus() flagsversion == 0");
        LoadFlags();
    }
    p = player();

    info("NewGamePlus()");
    seed++;
    dxr.seed = seed;
    NewPlaythroughId();
    ds = class'DataStorage'.static.GetObj(dxr);
    if( ds != None ) ds.playthrough_id = playthrough_id;
    newgameplus_loops++;
    bingoBoardRoll=0;
    p.saveCount=0;
    exp = 1;
    randomStart = settings.starting_map;
    bingo_win = settings.bingo_win;
    bingo_freespaces = settings.bingo_freespaces;

    // always enable maxrando when doing NG+?
    maxrando = 1;
    if(maxrando > 0) {
        // rollback settings to the default for the current difficulty
        // we only want to do this on maxrando because we want to retain the user's custom choices
        SetDifficulty(difficulty);
        ExecMaxRando();
        // increase difficulty on each flag like exp = newgameplus_loops; x *= 1.2 ^ exp;
        exp = newgameplus_loops;
    }

    SetGlobalSeed("NewGamePlus");
    p.CombatDifficulty=FClamp(p.CombatDifficulty*1.3,0,15); //Anything over 15 is kind of unreasonably impossible
    NewGamePlusVal(settings.minskill, 1.2, exp, 1000);
    NewGamePlusVal(settings.maxskill, 1.2, exp, 1500);
    NewGamePlusVal(settings.enemiesrandomized, 1.2, exp, 1500);
    NewGamePlusVal(settings.enemystats, 1.2, exp, 100);
    NewGamePlusVal(settings.hiddenenemiesrandomized, 1.2, exp, 1500);
    NewGamePlusVal(settings.ammo, 0.9, exp);
    NewGamePlusVal(settings.medkits, 0.8, exp);
    NewGamePlusVal(settings.multitools, 0.8, exp);
    NewGamePlusVal(settings.lockpicks, 0.8, exp);
    NewGamePlusVal(settings.biocells, 0.8, exp);
    NewGamePlusVal(settings.medbots, 0.8, exp);
    NewGamePlusVal(settings.repairbots, 0.8, exp);
    NewGamePlusVal(settings.turrets_add, 1.3, exp, 1000);
    NewGamePlusVal(settings.merchants, 0.9, exp);
    settings.bingo_win = bingo_win;
    settings.bingo_freespaces = bingo_freespaces;
    if (randomStart!=0){
        settings.starting_map = class'DXRStartMap'.static.ChooseRandomStartMap(dxr,randomStart);
    }

    if (p.KeyRing != None)
    {
        p.KeyRing.RemoveAllKeys();
        if ((Role == ROLE_Authority) && (Level.NetMode != NM_Standalone))
        {
            p.KeyRing.ClientRemoveAllKeys();
        }
    }
    p.DeleteAllNotes();
    p.DeleteAllGoals();
    p.ResetConversationHistory();
    p.SetInHandPending(None);
    p.SetInHand(None);
    p.bInHandTransition = False;
    p.RestoreAllHealth();
    ClearDataVaultImages();

    skills = DXRSkills(dxr.FindModule(class'DXRSkills'));
    if( skills != None ) {
        for(i=0; i<5; i++)
            skills.DowngradeRandomSkill(p);
        p.SkillPointsAvail /= 2;
    }
    else p.SkillPointsAvail = 0;
    p.SkillPointsTotal = 0; //This value doesn't seem to actually get used in vanilla, but we use it for scoring

    augs = DXRAugmentations(dxr.FindModule(class'DXRAugmentations'));
    if( augs != None )
        augs.RemoveRandomAug(p);

    // TODO: do this in the intro instead of in the credits?
    weapons = DXRWeapons(dxr.FindModule(class'DXRWeapons'));
    if( weapons != None )
        weapons.RemoveRandomWeapon(p);

    //Should you actually get fresh augs and credits on a NG+ non-vanilla start map?
    //Technically it should make up for levels you skipped past, so maybe?
    class'DXRStartMap'.static.AddStartingCredits(dxr,p);
    class'DXRStartMap'.static.AddStartingAugs(dxr,p);
    class'DXRStartMap'.static.AddStartingSkillPoints(dxr,p);

    info("NewGamePlus() deleting all flags");
    f.DeleteAllFlags();
    DeusExRootWindow(p.rootWindow).ResetFlags();
    info("NewGamePlus() deleted all flags");
    SaveFlags();
    p.bStartNewGameAfterIntro = true;
    class'PlayerDataItem'.static.ResetData(p);
    Level.Game.SendPlayer(p, "00_intro");
}
