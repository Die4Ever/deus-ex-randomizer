class DXRFlagsNGPMaxRando extends DXRFlagsBase transient;

simulated function ExecMaxRando()
{
    // set local seed
    // set a flag to save that we are in Max Rando mode
    info("ExecMaxRando()");
    SetGlobalSeed("ExecMaxRando " $ dxr.seed); // include the seed number in the CRC
    maxrando = 1;

    RandomizeSettings(False);
}

//Initialize the values that get tweaked by max rando
simulated function InitMaxRandoSettings()
{
    local FlagsSettings difficulty_settings;
    local MoreFlagsSettings more_difficulty_settings;
    difficulty_settings = DXRFlags(self).GetDifficulty(difficulty);
    more_difficulty_settings = DXRFlags(self).GetMoreDifficulty(difficulty);

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
    moresettings.reanimation = more_difficulty_settings.reanimation;
    settings.health = difficulty_settings.health;
    settings.energy = difficulty_settings.energy;
}

//Randomize the values.  If forceMenuOptions is set, we will only allow the values to be set to
//the options available in DXRMenuSetupRando
simulated function RandomizeSettings(bool forceMenuOptions)
{
    local bool isHalloween;

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

    if (forceMenuOptions) {
        switch(rng(5)) {
            case 0: settings.doorsdestructible = 0; break;
            case 1: settings.doorsdestructible = 25; break;
            case 2: settings.doorsdestructible = 40; break;
            case 3: settings.doorsdestructible = 70; break;
            default: settings.doorsdestructible = 100; break;
        }
        switch(rng(5)) {
            case 0: settings.doorspickable = 0; break;
            case 1: settings.doorspickable = 25; break;
            case 2: settings.doorspickable = 40; break;
            case 3: settings.doorspickable = 70; break;
            default: settings.doorspickable = 100; break;
        }
    } else {
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

    isHalloween = DXRFlags(self).IsHalloweenMode(); // this cast is pretty nasty
    if(isHalloween) {
        moresettings.reanimation = rng(10) + 15;
    } else if (chance_single(33)) {
        if (chance_single(50)) {
            settings.enemyrespawn = rng(120) + 120;
        } else {
            moresettings.reanimation = rng(15) + 15;
        }
    } else {
        settings.enemyrespawn = 0;
        moresettings.reanimation = 0;
    }

    //HX shouldn't max rando into respawns or resurrection
    //on the first loop, unless you're in Halloween mode
    if (#defined(hx) && !isHalloween && newgameplus_loops==0){
        settings.enemyrespawn = 0;
        moresettings.reanimation = 0;
    }

    if(rngb()) {
        settings.bot_weapons = 50;
    } else {
        settings.bot_weapons = 0;
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

    settings.min_weapon_dmg += 10; // prevent it from going too low
    MaxRandoValPair(settings.min_weapon_dmg, settings.max_weapon_dmg, 1.5);
    MaxRandoValPair(settings.min_weapon_shottime, settings.max_weapon_shottime);

    settings.aug_value_rando = 100;

    if (autosave != 5) { // don't steal health from players in ironman mode
        settings.health += rng(100) - 50;
    }

    MaxRandoVal(settings.energy);
}

function NewGamePlus()
{
    local #var(PlayerPawn) p;
    local DataStorage ds;
    local DXRSkills skills;
    local DXRAugmentations augs;
    local DXRLoadouts loadouts;
    local DXRStats stats;
    local int i;
    local int randomStart;
    local int oldseed;
    local int augsToRemove,randoSlotAugsRemoved;

    if( flagsversion == 0 ) {
        warning("NewGamePlus() flagsversion == 0");
        LoadFlags();
    }
    p = player();

    info("NewGamePlus()");
    if(gamemode != DXRFlags(self).GroundhogDay) {
        seed++;
        dxr.seed = seed;
    }
    NewPlaythroughId();
    ds = class'DataStorage'.static.GetObj(dxr);
    if( ds != None ) ds.playthrough_id = playthrough_id;
    newgameplus_loops++;
    bingoBoardRoll=0;
    p.saveCount=0;
    randomStart = settings.starting_map;

    if(gamemode != DXRFlags(self).GroundhogDay) {
        NGPlusFlags(p);
    }
    SetGlobalSeed("NewGamePlus " $ dxr.seed);
    if (randomStart!=0 && gamemode != DXRFlags(self).GroundhogDay){
        settings.starting_map = class'DXRStartMap'.static.ChooseRandomStartMap(self, randomStart);
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
    class'DXRActorsBase'.static.ClearDataVaultImages(p);

    l("NewGamePlus skill points was "$p.SkillPointsAvail);
    SetGlobalSeed("NewGamePlus skills " $ dxr.seed);
    skills = DXRSkills(dxr.FindModule(class'DXRSkills'));
    if( skills != None ) {
        for(i = 0; i < newgameplus_num_skill_downgrades; i++)
            skills.DowngradeRandomSkill(p);
        p.SkillPointsAvail = p.SkillPointsAvail * 0.8;
    }
    else p.SkillPointsAvail = 0;
    p.SkillPointsTotal = 0; //This value doesn't seem to actually get used in vanilla, but we use it for scoring
    l("NewGamePlus skill points is now "$p.SkillPointsAvail);

    augs = DXRAugmentations(dxr.FindModule(class'DXRAugmentations'));
    augsToRemove = newgameplus_num_removed_augs;
    if (augs!=None) {
        oldseed = SetGlobalSeed("CleanupAugSlotRando"); //This seed doesn't really matter, just want to get the current seed

        augs.RandoAllAugs(); //Apply the new aug randomization (so we know what slot the augs will end up in)
        randoSlotAugsRemoved = augs.CleanUpAugSlots(p); //Remove augs that no longer fit due to the newly assigned slots
        l("CleanUpAugSlots removed "$randoSlotAugsRemoved$" augs due to new aug slot assignments");
        augsToRemove = augsToRemove - randoSlotAugsRemoved; //Count those removed augs towards the augs to remove for the new loop

        augs.FixAugHotkeys(p,false); //Hotkeys will have totally changed after randomizing the slots, make sure they're corrected

        ReapplySeed(oldseed);
    }

    SetGlobalSeed("NewGamePlus augs " $ dxr.seed);
    for (i = 0; i < augsToRemove; i++)
        if( augs != None )
            augs.RemoveRandomAug(p);
    loadouts = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
    if(loadouts != None) {// maybe the player uninstalled Running Enhancement in favor of Speed Enhancement, but it just got taken away
        loadouts.AddStartingAugs(p);
    }

    SetGlobalSeed("NewGamePlus items " $ dxr.seed);
    MaxMultipleItems(p, newgameplus_max_item_carryover);
    ClearInHand(p);
    for (i = 0; i < newgameplus_num_removed_weapons; i++)
        RemoveRandomWeapon(p);

    p.AugmentationSystem.DeactivateAll();

    stats = DXRStats(dxr.FindModule(class'DXRStats'));
    i = stats.GetTotalAllTime();
    newgameplus_retries_time += (i - newgameplus_total_time) - stats.GetTotalTime(dxr);
    newgameplus_total_time = i;

    info("NewGamePlus() deleting all flags");
    f.DeleteAllFlags();
    DeusExRootWindow(p.rootWindow).ResetFlags();
    info("NewGamePlus() deleted all flags");
    SaveFlags();
    p.bStartNewGameAfterIntro = true;
    class'PlayerDataItem'.static.ResetData(p);
    Level.Game.SendPlayer(p, "00_intro");
}

simulated function NGPlusFlags(#var(PlayerPawn) p)
{
    local int old_bingo_scale, old_bingo_duration, old_clothes_looting;
    local float exp;
    local FlagsSettings oldsettings;
    local MoreFlagsSettings oldmoresettings;

    oldsettings = settings;
    oldmoresettings = moresettings;
    exp = 1;
    // always enable maxrando when doing NG+?
    maxrando = 1;
    if(maxrando > 0) {
        // rollback settings to the default for the current difficulty
        // we only want to do this on maxrando because we want to retain the user's custom choices
        old_bingo_scale = bingo_scale;
        old_bingo_duration = bingo_duration;
        old_clothes_looting = clothes_looting;
        SetDifficulty(difficulty);
        ExecMaxRando();
        settings.bingo_win = oldsettings.bingo_win;
        settings.bingo_freespaces = oldsettings.bingo_freespaces;
        bingo_scale = old_bingo_scale;
        bingo_duration = old_bingo_duration;
        moresettings.newgameplus_curve_scalar = oldmoresettings.newgameplus_curve_scalar;
        settings.menus_pause = oldsettings.menus_pause;
        moresettings.aug_loc_rando = oldmoresettings.aug_loc_rando;
        moresettings.splits_overlay = oldmoresettings.splits_overlay;
        clothes_looting = old_clothes_looting;

        // increase difficulty on each flag like exp = newgameplus_loops; x *= 1.2 ^ exp;
        exp = newgameplus_loops;
    }

    dxr.SetSeed(dxr.Crc("NG+ curve tweak " $ (seed - newgameplus_loops)));
    rng(9);// advance the rng
#ifdef hx
    p.CombatDifficulty = 3;// I don't think NG+ works in HX anyways?
#else
    p.CombatDifficulty = DXRFlags(self).GetDifficulty(difficulty).CombatDifficulty;
#endif

    p.CombatDifficulty = NewGamePlusVal(p.CombatDifficulty, 1.3, exp, 0, 15, False); // Anything over 15 is kind of unreasonably impossible
    settings.minskill = NewGamePlusVal(settings.minskill, 1.1, exp, 10, 400, True);
    settings.maxskill = NewGamePlusVal(settings.maxskill, 1.1, exp, 10, 700, True);
    settings.enemiesrandomized = NewGamePlusVal(settings.enemiesrandomized, 1.2, exp, 10, 1000, True);
    settings.enemystats = NewGamePlusVal(settings.enemystats, 1.2, exp, 5, 100, True);
    settings.hiddenenemiesrandomized = NewGamePlusVal(settings.hiddenenemiesrandomized, 1.2, exp, 10, 1000, True);
    if(oldsettings.ammo > 0) settings.ammo = NewGamePlusVal(settings.ammo, 0.9, exp, 5, 100, True);
    if(oldsettings.medkits > 0) settings.medkits = NewGamePlusVal(settings.medkits, 0.9, exp, 5, 100, True);
    if(oldsettings.multitools > 0) settings.multitools = NewGamePlusVal(settings.multitools, 0.9, exp, 5, 100, True);
    if(oldsettings.lockpicks > 0) settings.lockpicks = NewGamePlusVal(settings.lockpicks, 0.9, exp, 5, 100, True);
    if(oldsettings.biocells > 0) settings.biocells = NewGamePlusVal(settings.biocells, 0.9, exp, 5, 100, True);
    if(oldsettings.medbots > 0) settings.medbots = NewGamePlusVal(settings.medbots, 0.9, exp, 3, 100, True);
    if(oldsettings.repairbots > 0) settings.repairbots = NewGamePlusVal(settings.repairbots, 0.9, exp, 6, 100, True);
    settings.turrets_add = NewGamePlusVal(settings.turrets_add, 1.3, exp, 3, 1000, True);
    settings.merchants = NewGamePlusVal(settings.merchants, 0.9, exp, 5, 100, True);
}

simulated function MaxMultipleItems(#var(PlayerPawn) p, int maxcopies)
{
    local Inventory i, i2, next;
    local int num;

    for(i=p.Inventory; i!=None; i=i.Inventory) {
        num=1;
        for(i2=i.Inventory; i2!=None; i2=next) {
            next = i2.Inventory;
            if(i2.class.name != i.class.name) continue;
            num++;
            if(num > maxcopies) {
                i2.Destroy();
            }
        }
    }
}

simulated function ClearInHand(#var(PlayerPawn) p)
{
    if(POVCorpse(p.InHand)!=None) {
        p.InHand.Destroy();
    }
    p.SetInHand(None);
    p.SetInHandPending(None);
    p.bInHandTransition = False;
    p.LastinHand = None;
    p.ClientinHandPending = None;
    p.inHandPending = None;
    p.inHand = None;
}

simulated function RemoveRandomWeapon(#var(PlayerPawn) p)
{
    local Inventory i, next;
    local Weapon weaps[64];
    local int numWeaps, slot;
    local DXRLoadouts loadout;
    local class<Inventory> startingItem;

    loadout = DXRLoadouts(class'DXRLoadouts'.static.Find());
    if (loadout!=None){
        startingItem = loadout.get_starting_item();
    }

    for( i = p.Inventory; i != None; i = next ) {
        next = i.Inventory;
        if( Weapon(i) == None ) continue;
        if (i.Class==startingItem) continue; //Don't take away your loadout starting item
        if (i.Class==class'#var(package).WeaponRubberBaton') continue; //Don't take away the rubber baton, that's just rude
        weaps[numWeaps++] = Weapon(i);
    }

    // don't take the player's only weapon
    if( numWeaps <= 1 ) return;

    SetSeed( "RemoveRandomWeapon " $ numWeaps );

    slot = rng(numWeaps);
    info("RemoveRandomWeapon("$p$") Removing weapon "$weaps[slot]$", numWeaps was "$numWeaps);
    p.DeleteInventory(weaps[slot]);
    weaps[slot].Destroy();
}

simulated function MaxRandoVal(out int val, optional float scaler)
{
    if(scaler == 0) scaler = 2;
    val = rngrecip(val, scaler);
}

simulated function MaxRandoValPair(out int min, out int max, optional float min_scaler, optional float max_scaler)
{
    local int i;

    MaxRandoVal(min, min_scaler);
    MaxRandoVal(max, max_scaler);

    if(min > max) {
        i = min;
        min = max;
        max = i;
    }

    i = self.Max(1, min*0.1);
    if(max-min <= i*2) {
        min -= i;
        max += i;
    }
}

function float NewGamePlusVal(float val, float curve, float exp, float min, float max, bool doTweak)
{
    local bool increases;
    local float tweak;

    increases = curve > 1.0;

    curve = (curve - 1.0) * float(moresettings.newgameplus_curve_scalar) / 100.0; // chop off 1 and scale the rest based on the scalar setting
    if (doTweak) {
        tweak = rngfn() * curve * 0.3; // generate a tweak with a range based on the scaled curve
        curve += tweak;
    }
    curve += 1.0; // restore the 1

    if (increases) {
        curve = FMax(curve, 1.02);
    } else {
        curve = FMin(curve, 0.98);
    }
    val = val * curve ** exp;

    return FClamp(val, min, max);
}

function ExtendedTests()
{
    local int val, i, oldSeed, prev;
    local float fval, old_scaling;
    local string s;

    Super.ExtendedTests();

    oldSeed = dxr.seed;
    dxr.seed = 123456;
    SetGlobalSeed("NG+ tests");

    old_scaling = moresettings.newgameplus_curve_scalar;
    moresettings.newgameplus_curve_scalar = 100;

    val = NewGamePlusVal(5, 1.2, 3, 1, 100, False);
    test(val > 5, "NewGamePlusVal 1.2 goes up");

    val = NewGamePlusVal(5, 0.8, 3, 1, 100, False);
    test(val < 5, "NewGamePlusVal 1.2 goes down");

    val = NewGamePlusVal(5, 0.8, 3, 5, 100, False);
    testint(val, 5, "NewGamePlusVal with minimum stays the same"); // can't explain that!

    val = NewGamePlusVal(5, 1.2, 3, 1, 5, False);
    testint(val, 5, "NewGamePlusVal 1.2 with maximum");

    val = NewGamePlusVal(0, 1.2, 3, -10, 100, False);
    testint(val, 0, "NewGamePlusVal 1.2 val==0");

    val = NewGamePlusVal(-5, 1.2, 3, -6, 100, False);
    testint(val, -6, "NewGamePlusVal 1.2 negative value");

    s = "";
    prev = -1;
    for(i=0; i<20; i++) {
        dxr.seed = 403203 + i;
        prev = class'DXRStartMap'.static.ChooseRandomStartMap(self, prev);
        s = s @ (prev&0xFF);
    }
    l("DXRStartMap 403203 " $ s);
    for(i=0; i<1000; i++) {
        dxr.seed = 403203 + i;
        prev = class'DXRStartMap'.static.ChooseRandomStartMap(self, -1);
        test((prev&0xFF) > 19, "DXRStartMap no liberty island");
        //test((prev&0xFF) > 29, "DXRStartMap M01 or M02");
    }
    dxr.seed = oldSeed;

    oldSeed = dxr.SetSeed(9876); // first two rngfn values are: 0.759380, -0.177720

    fval = NewGamePlusVal(50.0, 0.99, 3, 0, 100, True);
    test(fval < 50.0, "NewGamePlusVal doesn't switch from decreasing to increasing");

    fval = NewGamePlusVal(50.0, 1.01, 3, 0, 100, True);
    test(fval > 50.0, "NewGamePlusVal doesn't switch from increasing to decreasing");

    moresettings.newgameplus_curve_scalar = old_scaling;

    dxr.SetSeed(oldSeed);
}
