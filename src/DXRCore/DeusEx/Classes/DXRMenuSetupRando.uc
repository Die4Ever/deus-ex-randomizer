class DXRMenuSetupRando extends DXRMenuBase;

var float combatDifficulty;
var int gamemode_enum, starting_locations, goals_rando;
var bool showMode, showLoadout, showAutosave, showCrowdControl, showOnlineFeatures, showMirroredMaps;

var string SplitsBtnTitle, SplitsBtnMessage;

enum ERandoMessageBoxModes
{
    RMB_None,
    RMB_NewGame,// starting with splits with a different flagshash
};
var ERandoMessageBoxModes nextScreenNum;

event InitWindow()
{
    Super.InitWindow();
}

//If changing ranges in this menu, make sure to update any clamped ranges in DXRFlags ScoreFlags function to match
function BindControls(optional string action)
{
    local DXRFlags f;
    local string s;
    local int iDifficulty, i;
    local bool bMatched;
    f = GetFlags();

    CreateBasicOptions(f);

    NewGroup("General");

    if( ! #defined(vmd) ) {
        NewMenuItem("Combat Difficulty %", "Multiply the damage the player takes.  The original game uses 400% for realistic.");
        iDifficulty = int(combatDifficulty * 100.0);
        Slider(iDifficulty, 0, 10000, GetCombatDifficultyHelpText());
        combatDifficulty = float(iDifficulty) / 100.0;
    #ifndef hx
        f.settings.CombatDifficulty = combatDifficulty;
    #endif
    }

    CreateSeedInput(f);

    //Make sure the starting map values match those in DXRStartMap
    NewMenuItem("Starting Map", "What level you will start in.");
    bMatched = false;
    for(i=0; i<160; i++) {
        if(i == 10) continue;// Liberty Island dupe
        s = class'DXRStartMap'.static.GetStartingMapName(i);
        if(s != "") {
            bMatched = EnumOption(s, i, f.moresettings.starting_map) || bMatched;
        }
    }
    if(f.moresettings.starting_map != 0 && !bMatched) {
        if(writing) f.moresettings.starting_map = class'DXRStartMap'.static.ChooseRandomStartMap(f, -1); // reroll to make sure we respect the current seed which could've been changed in the input box above
        EnumOption("Random", f.moresettings.starting_map, f.moresettings.starting_map);
    }
    else if(EnumOption("Random", -1)) {
        f.moresettings.starting_map = class'DXRStartMap'.static.ChooseRandomStartMap(f, 0);
    }

    BreakLine();

    NewMenuItem("Player Health", "Max health for each body part of the player.");
    Slider(f.settings.health, 1, 10000, GetGenericHelpText("playerhealth"));

    NewMenuItem("Player Energy", "Max bioelectric energy for the player.");
    Slider(f.settings.energy, 0, 10000, GetGenericHelpText("playerenergy"));

    BreakLine();

#ifndef hx
    starting_locations = NewMenuItem("", "Randomize starting locations on certain maps.");
    EnumOption("Randomize Starting Locations", 100, f.settings.startinglocations, GetStartingLocationsHelpText(100));
    EnumOption("Unchanged Starting Locations", 0, f.settings.startinglocations, GetStartingLocationsHelpText(0));
#endif

    goals_rando = NewMenuItem("", "Randomize goal locations on certain maps.");
    EnumOption("Randomize Goal Locations", 100, f.settings.goals, GetGoalRandoHelpText(100));
    EnumOption("Unchanged Goal Locations", 0, f.settings.goals, GetGoalRandoHelpText(0));
    EnumOption("Goal Location Hints", 101, f.settings.goals, GetGoalRandoHelpText(101));
    EnumOption("Goal Location Spoilers", 102, f.settings.goals, GetGoalRandoHelpText(102));
    EnumOption("Serious Goal Locations", 200, f.settings.goals, GetGoalRandoHelpText(200));

    BreakLine();
#ifndef hx
    NewMenuItem("The Merchant Chance %", "The chance for The Merchant to appear in each map."$BR$"If The Merchant dies then he stays dead for the rest of the game.");
    Slider(f.settings.merchants, 0, 100,GetGenericHelpText("merchant"));
#endif

    NewMenuItem("Dancing %", "How many characters should be dancing.");
    Slider(f.settings.dancingpercent, 0, 100);

    NewMenuItem("Spoiler Buttons", "Allow the use of spoiler buttons (Spoilers remain hidden until you choose to view them).");
    EnumOption("Available", 1, f.moresettings.spoilers,GetSpoilerButtonHelpText(1));
    EnumOption("Disallowed", 0, f.moresettings.spoilers,GetSpoilerButtonHelpText(0));

    NewMenuItem("Menus Pause Game", "Should the game keep playing while a menu is open?");
    EnumOption("Pause", 1, f.moresettings.menus_pause);
    EnumOption("Don't Pause", 0, f.moresettings.menus_pause);

    NewMenuItem("Camera Mode", "What camera mode should be used");
    EnumOption("First Person", 0, f.moresettings.camera_mode,GetCameraModeHelpText(0));
    EnumOption("Third Person", 1, f.moresettings.camera_mode,GetCameraModeHelpText(1));
    if(#defined(vanilla || revision)) {
        EnumOption("Fixed Camera", 2, f.moresettings.camera_mode,GetCameraModeHelpText(2));
    }

    NewMenuItem("Splits Overlay", "Splits and total game time overlay");
    EnumOption("Don't Show", 0, f.moresettings.splits_overlay,GetGenericHelpText("splitsoverlay"));
    EnumOption("Show", 1, f.moresettings.splits_overlay,GetGenericHelpText("splitsoverlay"));

#ifdef vanilla
    NewMenuItem("Clothes Looting", "Should clothes need to be looted first, or start with all of them?");
    EnumOption("Full Closet", 0, f.clothes_looting, GetClothesLootingHelpText(0));
    EnumOption("Looting Needed", 1, f.clothes_looting, GetClothesLootingHelpText(1));

    NewMenuItem("Entrance Randomization", "Level transitions are randomized so they will take you to a different level than usual (within the same mission).");
    EnumOption("Disabled", 0, f.moresettings.entrance_rando, GetEntranceRandoHelpText(0));
    EnumOption("Enabled", 100, f.moresettings.entrance_rando, GetEntranceRandoHelpText(100));
#endif

    NewGroup("Bingo");

    NewMenuItem("Bingo Win", "How many completed lines to instantly win (or progress in Mean Bingo Machine mode).");
    Slider(f.settings.bingo_win, 0, 12, GetGenericHelpText("bingowin"));

    NewMenuItem("Bingo Scale %", "How difficult should bingo goals be?");
    Slider(f.bingo_scale, 0, 100, GetGenericHelpText("bingoscale"));

    NewMenuItem("Bingo Freespaces", "Should the center be a Free Space, or even more Free Spaces?");
    EnumOption("0 Free Spaces", 0, f.settings.bingo_freespaces);
    EnumOption("1 Free Space", 1, f.settings.bingo_freespaces);
    EnumOption("2 Free Spaces", 2, f.settings.bingo_freespaces);
    EnumOption("3 Free Spaces", 3, f.settings.bingo_freespaces);
    EnumOption("4 Free Spaces", 4, f.settings.bingo_freespaces);
    EnumOption("5 Free Spaces", 5, f.settings.bingo_freespaces);

    NewMenuItem("Bingo Duration", "How many missions should the bingo goals last for?");
    EnumOption("End of Game", 0, f.bingo_duration, GetBingoDurationHelpText(0));
    EnumOption("1 Mission",   1, f.bingo_duration, GetBingoDurationHelpText(1));
    EnumOption("2 Missions",  2, f.bingo_duration, GetBingoDurationHelpText(2));
    EnumOption("3 Missions",  3, f.bingo_duration, GetBingoDurationHelpText(3));
    EnumOption("4 Missions",  4, f.bingo_duration, GetBingoDurationHelpText(4));
    EnumOption("5 Missions",  5, f.bingo_duration, GetBingoDurationHelpText(5));
    EnumOption("7 Missions",  7, f.bingo_duration, GetBingoDurationHelpText(7));
    EnumOption("10 Missions", 10, f.bingo_duration, GetBingoDurationHelpText(10));

    NewGroup("Medical Bots and Repair Bots");

    NewMenuItem("Medbots", "Percentage chance for a medbot to spawn in a map (vanilla is about 14%).");
    Slider(f.settings.medbots, -1, 100,GetGenericHelpText("medbots"));

    NewMenuItem("Augbots", "Percentage chance for a zero-heals medbot to spawn in a map if a regular one doesn't.");
    Slider(f.moresettings.empty_medbots, 0, 100, GetGenericHelpText("augbots"));

    NewMenuItem("Repair Bots", "Percentage chance for a repair bot to spawn in a map (vanilla is about 14%).");
    Slider(f.settings.repairbots, -1, 100,GetGenericHelpText("repairbots"));

    if(!#defined(vmd)) {
        NewMenuItem("Medbot Uses", "Number of times you can use an individual medbot to heal.");
        Slider(f.settings.medbotuses, 0, 10,GetGenericHelpText("medbotuses"));

        NewMenuItem("Repair Bot Uses", "Number of times you can use an individual repair bot to restore energy.");
        Slider(f.settings.repairbotuses, 0, 10,GetGenericHelpText("repairbotuses"));
    }

    NewMenuItem("Medbot Cooldowns", "Individual: Each Medbot has its own healing cooldown."$BR$"Global: All Medbots have the same cooldown.");
    EnumOption("Unchanged", 0, f.settings.medbotcooldowns, GetGoodBotHelpText("med","cooldown",0));
    EnumOption("Individual", 1, f.settings.medbotcooldowns, GetGoodBotHelpText("med","cooldown",1));
    EnumOption("Global", 2, f.settings.medbotcooldowns, GetGoodBotHelpText("med","cooldown",2));

    NewMenuItem("Repair Bot Cooldowns", "Individual: Each Repair Bot has its own charge cooldown."$BR$"Global: All Repair Bots have the same cooldown.");
    EnumOption("Unchanged", 0, f.settings.repairbotcooldowns, GetGoodBotHelpText("repair","cooldown",0));
    EnumOption("Individual", 1, f.settings.repairbotcooldowns, GetGoodBotHelpText("repair","cooldown",1));
    EnumOption("Global", 2, f.settings.repairbotcooldowns, GetGoodBotHelpText("repair","cooldown",2));

    NewMenuItem("Medbot Heal Amount", "Individual: Each Medbot has its own healing amount."$BR$"Global: All Medbots have the same amount.");
    EnumOption("Unchanged", 0, f.settings.medbotamount, GetGoodBotHelpText("med","amount",0));
    EnumOption("Individual", 1, f.settings.medbotamount, GetGoodBotHelpText("med","amount",1));
    EnumOption("Global", 2, f.settings.medbotamount, GetGoodBotHelpText("med","amount",2));

    NewMenuItem("Repair Bot Charge Amount", "Individual: Each Repair Bot has its own charge amount."$BR$"Global: All Repair Bots have the same amount.");
    EnumOption("Unchanged", 0, f.settings.repairbotamount, GetGoodBotHelpText("repair","amount",0));
    EnumOption("Individual", 1, f.settings.repairbotamount, GetGoodBotHelpText("repair","amount",1));
    EnumOption("Global", 2, f.settings.repairbotamount, GetGoodBotHelpText("repair","amount",2));

    NewGroup("Doors and Keys");

    NewMenuItem("Doors To Make Breakable", "How many normally undefeatable doors to make breakable.", true);
    bMatched = EnumOptionMatched("All Undefeatable Doors Breakable", 100, f.settings.doorsdestructible);
    bMatched = EnumOptionMatched("Many Undefeatable Doors Breakable", 70, f.settings.doorsdestructible) || bMatched;
    bMatched = EnumOptionMatched("Some Undefeatable Doors Breakable", 40, f.settings.doorsdestructible) || bMatched;
    bMatched = EnumOptionMatched("Few Undefeatable Doors Breakable", 25, f.settings.doorsdestructible) || bMatched;
    bMatched = EnumOptionMatched("Keep Undefeatable Doors Unbreakable", 0, f.settings.doorsdestructible) || bMatched;
    if(!bMatched) EnumOption("Custom " $ f.settings.doorsdestructible $ "% Undefeatable Doors Breakable", f.settings.doorsdestructible, f.settings.doorsdestructible);

    NewMenuItem("Doors To Make Pickable", "How many normally undefeatable doors to make pickable.", true);
    bMatched = EnumOptionMatched("All Undefeatable Doors Pickable", 100, f.settings.doorspickable);
    bMatched = EnumOptionMatched("Many Undefeatable Doors Pickable", 70, f.settings.doorspickable) || bMatched;
    bMatched = EnumOptionMatched("Some Undefeatable Doors Pickable", 40, f.settings.doorspickable) || bMatched;
    bMatched = EnumOptionMatched("Few Undefeatable Doors Pickable", 25, f.settings.doorspickable) || bMatched;
    bMatched = EnumOptionMatched("Keep Undefeatable Doors Unpickable", 0, f.settings.doorspickable) || bMatched;
    if(!bMatched) EnumOption("Custom " $ f.settings.doorspickable $ "% Undefeatable Doors Pickable", f.settings.doorspickable, f.settings.doorspickable);

    BreakLine();

    NewMenuItem("NanoKey Locations", "Move keys around the map."$BR$"Experimental allows keys to be swapped with containers.");
    if(EnumOption("Experimental", 100, f.settings.keys_containers))
        f.settings.keysrando = 4;
    else
        f.settings.keys_containers = 0;
    EnumOption("Randomized", 4, f.settings.keysrando);
    EnumOption("Unchanged", 0, f.settings.keysrando);

    NewGroup("Passwords");

    NewMenuItem("Electronic Devices %", "Provide additional options for keypads and electronic panels by making them hackable.");
    Slider(f.settings.deviceshackable, 0, 100);

    NewMenuItem("Passwords", "Forces you to look for passwords and passcodes.", true);
    EnumOption("Unchanged Passwords", 0, f.settings.passwordsrandomized,GetPasswordRandoHelpText(0));
    EnumOption("Randomized Passwords", 100, f.settings.passwordsrandomized,GetPasswordRandoHelpText(100));
    EnumOption("Randomized Passwords (Pronouncable)", 200, f.settings.passwordsrandomized,GetPasswordRandoHelpText(200));
    EnumOption("Randomized Passwords (Random Words)", 300, f.settings.passwordsrandomized,GetPasswordRandoHelpText(300));

    NewMenuItem("Datacubes Locations", "Moves datacubes and other information objects around the map."$BR$"Experimental allows datacubes to be swapped with containers.");
    if(EnumOption("Experimental", 100, f.settings.infodevices_containers))
        f.settings.infodevices = 100;
    else
        f.settings.infodevices_containers = 0;
    EnumOption("Randomized", 100, f.settings.infodevices);
    EnumOption("Unchanged", 0, f.settings.infodevices);

    NewGroup("Enemies");

    NewMenuItem("Enemy Randomization %", "How many additional enemies to add and how much to randomize their weapons.");
    Slider(f.settings.enemiesrandomized, 0, 1000);
    f.settings.hiddenenemiesrandomized = f.settings.enemiesrandomized;

    NewMenuItem("Enemy Stats Boost %", "How much to boost enemy accuracy, reload speed, aggression, and helmets.");
    Slider(f.settings.enemystats, 0, 100);

    NewMenuItem("Enemy Shuffling %", "Shuffle enemies around the map.");
    Slider(f.settings.enemiesshuffled, 0, 100);

    NewMenuItem("Enemy Weapons Variety %", "Should enemies be using weapons that normally exist in the map?");
    Slider(f.moresettings.enemies_weapons, 0, 100, GetGenericHelpText("enemyweaponsvariety"));

    NewMenuItem("Robot Weapons Rando %", "Allow robots to get randomized weapons.");
    Slider(f.settings.bot_weapons, 0, 100);

    NewMenuItem("Non-Human Chance %", "Reduce the chance of new enemies being non-humans.");
    Slider(f.settings.enemies_nonhumans, 0, 100, GetGenericHelpText("nonhumanenemies"));

    NewMenuItem("Enemy Respawn Seconds", "How many seconds for enemies to respawn.  Leave blank or 0 to disable.");
    Slider(f.settings.enemyrespawn, 0, 3600, GetGenericHelpText("enemyrespawn"));

    NewMenuItem("Move Turrets", "Randomizes locations of turrets, cameras, and security computers for them.");
    Slider(f.settings.turrets_move, 0, 100);

    NewMenuItem("Add Turrets", "Randomly adds turrets, cameras, and security computers for them.");
    Slider(f.settings.turrets_add, 0, 10000, GetGenericHelpText("addturrets"));

    NewMenuItem("Paris Chill %", "Chance to remove all MJ12 from the Champs-Elysees.");
    Slider(f.remove_paris_mj12, 0, 100, GetGenericHelpText("parischill"));

    NewMenuItem("Reanimation Seconds", "Approximately how many seconds for corpses to come back as zombies.  Leave blank or 0 to disable.");
    Slider(f.moresettings.reanimation, 0, 3600, GetGenericHelpText("reanimation"));

    NewMenuItem("", "Stalkers cannot be permanently killed, but if they take enough damage then they will go away for a while.");
    EnumOption("Stalkers are nowhere to be seen.", 0, f.moresettings.stalkers, GetStalkerHelpText(0));
    EnumOption("Mr. H will haunt you.", 0x00040001, f.moresettings.stalkers, GetStalkerHelpText(0x00040001));
    EnumOption("Weeping Anna will haunt you.", 0x00040002, f.moresettings.stalkers, GetStalkerHelpText(0x00040002));
    EnumOption("Mr. H and Weeping Anna will haunt you.", 0x00040003, f.moresettings.stalkers, GetStalkerHelpText(0x00040003));
    EnumOption("Bobbys will haunt you.", 0x00040004, f.moresettings.stalkers, GetStalkerHelpText(0x00040004));
    EnumOption("Mr. H and Bobbys will haunt you.", 0x00040005, f.moresettings.stalkers, GetStalkerHelpText(0x00040005));
    EnumOption("Weeping Anna and Bobbys will haunt you.", 0x00040006, f.moresettings.stalkers, GetStalkerHelpText(0x00040006));
    EnumOption("Stalkers will haunt you.", 0x0004FFFF, f.moresettings.stalkers, GetStalkerHelpText(0x0004FFFF)); // 1x
    EnumOption("More stalkers will haunt you.", 0x0008FFFF, f.moresettings.stalkers, GetStalkerHelpText(0x0008FFFF)); // 2x
    EnumOption("Many stalkers will haunt you.", 0x0010FFFF, f.moresettings.stalkers, GetStalkerHelpText(0x0010FFFF)); // 4x
    EnumOption("Too many stalkers will haunt you.", 0x0028FFFF, f.moresettings.stalkers, GetStalkerHelpText(0x0028FFFF)); // 10x

    NewMenuItem("", "Allow non-humans to get randomized stats.");
    EnumOption("Unchanged Non-human Stats", 0, f.settings.bot_stats, GetGenericHelpText("nonhumanstatsunchanged"));
    EnumOption("Random Non-human Stats", 100, f.settings.bot_stats, GetGenericHelpText("nonhumanstatsrandom"));


    NewGroup("Skills");

    NewMenuItem("", "Disallow downgrades to prevent scouting ahead in the new game screen.");
    EnumOption("Allow Downgrades On New Game Screen", 0, f.settings.skills_disable_downgrades);
    EnumOption("Disallow Downgrades On New Game Screen", 5, f.settings.skills_disable_downgrades);

    NewMenuItem("", "How often to reroll skill costs.");
    EnumOption("Don't Reroll Skill Costs", 0, f.settings.skills_reroll_missions, GetSkillRerollHelpText(0));
    EnumOption("Reroll Skill Costs Every Mission", 1, f.settings.skills_reroll_missions, GetSkillRerollHelpText(1));
    EnumOption("Reroll Skill Costs Every 2 Missions", 2, f.settings.skills_reroll_missions, GetSkillRerollHelpText(2));
    EnumOption("Reroll Skill Costs Every 3 Missions", 3, f.settings.skills_reroll_missions, GetSkillRerollHelpText(3));
    EnumOption("Reroll Skill Costs Every 4 Missions", 4, f.settings.skills_reroll_missions, GetSkillRerollHelpText(4));
    EnumOption("Reroll Skill Costs Every 5 Missions", 5, f.settings.skills_reroll_missions, GetSkillRerollHelpText(5));
    EnumOption("Reroll Skill Costs Every 8 Missions", 8, f.settings.skills_reroll_missions, GetSkillRerollHelpText(8));
    if(f.settings.skills_reroll_missions > 5 && f.settings.skills_reroll_missions != 8) {
        EnumOption("Reroll Skill Costs Every " $ f.settings.skills_reroll_missions $ " Missions",
            f.settings.skills_reroll_missions, f.settings.skills_reroll_missions
        );
    }

    NewMenuItem("", "Predictability of skill level cost scaling.");
    EnumOption("Relative Skill Level Costs", 0, f.settings.skills_independent_levels, GetSkillLevelCostsHelpText(0));
    EnumOption("Unpredictable Skill Level Costs", 1, f.settings.skills_independent_levels, GetSkillLevelCostsHelpText(1));

    BreakLine();

    NewMenuItem("Minimum Skill Cost %", "Minimum cost for skills in percentage of the original cost.");
    Slider(f.settings.minskill, 1, 1000);

    NewMenuItem("Maximum Skill Cost %", "Maximum cost for skills in percentage of the original cost.");
    Slider(f.settings.maxskill, 1, 1000);

    NewMenuItem("Banned Skills %", "Chance of a skill having a cost of 99,999 points.");
    Slider(f.settings.banned_skills, 0, 100, GetGenericHelpText("bannedskills"));

    NewMenuItem("Banned Skill Levels %", "Chance of a certain level of a skill having a cost of 99,999 points.");
    Slider(f.settings.banned_skill_levels, 0, 100, GetGenericHelpText("bannedskilllevels"));

    NewMenuItem("Skill Strength Rando %", "How much to randomize the strength of skills.");
    Slider(f.settings.skill_value_rando, 0, 100);// this is actually a wet/dry scale, so the range should be 0 to 100%

    NewGroup("Items");

    NewMenuItem("Ammo Drops %", "Make ammo more scarce.");
    Slider(f.settings.ammo, 0, 100);

    NewMenuItem("Multitools Drops %", "Make multitools more scarce.");
    Slider(f.settings.multitools, 0, 100);

    NewMenuItem("Lockpicks Drops %", "Make lockpicks more scarce.");
    Slider(f.settings.lockpicks, 0, 100);

    NewMenuItem("Bioelectric Cells Drops %", "Make bioelectric cells more scarce.");
    Slider(f.settings.biocells, 0, 100);

    NewMenuItem("Medkit Drops %", "Make medkits more scarce.");
    Slider(f.settings.medkits, 0, 100);

    NewMenuItem("Starting Equipment", "How many random items you start with.");
    Slider(f.settings.equipment, 0, 10);

    NewMenuItem("Swap Items %", "The chance for item positions to be swapped.");
    Slider(f.settings.swapitems, 0, 100);

    NewMenuItem("Swap Containers %", "The chance for container positions to be swapped.");
    Slider(f.settings.swapcontainers, 0, 100, GetGenericHelpText("swapcontainers"));

    NewMenuItem("Swap Grenades %", "The chance for grenades on walls to have their type randomized.");
    Slider(f.moresettings.grenadeswap, 0, 100);

    BreakLine();
    NewMenuItem("Min Weapon Damage %", "The minimum damage for weapons.");
    Slider(f.settings.min_weapon_dmg, 0, 500);

    NewMenuItem("Max Weapon Damage %", "The maximum damage for weapons.");
    Slider(f.settings.max_weapon_dmg, 0, 500);

    BreakLine();
    NewMenuItem("Min Weapon Shot Time %", "The minimum shot time / firing speed for weapons.");
    Slider(f.settings.min_weapon_shottime, 0, 500, GetShotTimeHelpText(false));

    NewMenuItem("Max Weapon Shot Time %", "The maximum shot time / firing speed for weapons.");
    Slider(f.settings.max_weapon_shottime, 0, 500, GetShotTimeHelpText(true));

    NewMenuItem("JC's Prison Pocket", "Keep all your items when getting captured.");
    EnumOption("Disabled", 0, f.settings.prison_pocket,GetPrisonPocketHelpText(0));
    EnumOption("Unaugmented", 1, f.settings.prison_pocket,GetPrisonPocketHelpText(1));// Keep the first single-slot item in your belt
    EnumOption("Augmented", 100, f.settings.prison_pocket,GetPrisonPocketHelpText(100));// maybe the number could be set to the number of items to keep?

    NewGroup("Augmentations");

    NewMenuItem("Starting Aug Level", "What level your starting augs (Check your loadout!) should start at.");
    Slider(f.settings.speedlevel, 0, 4);

    NewMenuItem("Aug Cans Randomized %", "The chance for aug cannisters to have their contents changed.");
    Slider(f.settings.augcans, 0, 100, GetGenericHelpText("augcanrando"));

    NewMenuItem("Aug Strength Rando %", "How much to randomize the strength of augmentations.");
    Slider(f.settings.aug_value_rando, 0, 100);// this is a wet/dry scale, 0 to 100%

    NewMenuItem("Aug Slot Rando", "Randomize the body parts augs can be installed into");
    EnumOption("Disabled", 0, f.moresettings.aug_loc_rando, GetAugSlotRandoHelpText(0));
    EnumOption("Balanced", 200, f.moresettings.aug_loc_rando, GetAugSlotRandoHelpText(200));
    EnumOption("Unbalanced", 100, f.moresettings.aug_loc_rando, GetAugSlotRandoHelpText(100));

    NewGroup("New Game+");

    NewMenuItem("Scaling %", "Scales the curve of New Game+ changes over successive loops."$BR$"Set to -1 to disable New Game+.  100% is default.");
    Slider(f.moresettings.newgameplus_curve_scalar, -1, 200);
    NewMenuItem("Max Item Carryover", "Maximum number of the same item that can carry over between loops, not including stackable items.");
    Slider(f.newgameplus_max_item_carryover, 0, 30);
    NewMenuItem("Skill Downgrades", "Number of skill level downgrades per loop.");
    Slider(f.newgameplus_num_skill_downgrades, 0, 33);
    NewMenuItem("Augmentations Removed", "Number of augmentations removed per loop.");
    Slider(f.newgameplus_num_removed_augs, 0, 8);
    NewMenuItem("Weapons Removed", "Number of weapons removed per loop.");
    Slider(f.newgameplus_num_removed_weapons, 0, 18);

    switch(action) {
        case "NEXT":
            HandleNewGameButton();
            break;
        case "RANDOMIZE":
            RandomizeOptions();
            break;
        case "RESTORE":
            RestoreOptions();
            break;
        case "SAVE":
            SaveOptions();
            break;
    }
}

function CreateBasicOptions(DXRFlags f)
{
    local int i, temp;

    NewGroup("Basic");

    if (showMode) gamemode_enum = class'DXRMenuSelectDifficulty'.static.CreateGameModeEnum(self, f);
    if (showLoadout) class'DXRMenuSelectDifficulty'.static.CreateLoadoutEnum(self, f);
    if (showAutosave) class'DXRMenuSelectDifficulty'.static.CreateAutosaveEnum(self, f);
    if (showCrowdControl) class'DXRMenuSelectDifficulty'.static.CreateCrowdControlEnum(self, f);
    if (showOnlineFeatures) class'DXRMenuSelectDifficulty'.static.CreateOnlineFeaturesEnum(self, f);
    if (showMirroredMaps) class'DXRMenuSelectDifficulty'.static.CreateMirroredMapsSlider(self, f);
}

function CreateSeedInput(DXRFlags f)
{
    local string sseed;

    NewMenuItem("Seed", "Enter a seed if you want to play the same game again.  Leave it blank for a random seed.");
    if(class == class'DXRMenuReSetupRando') sseed = string(f.seed);
    sseed = EditBox(sseed, "1234567890", GetGenericHelpText("seed"));
    if( sseed != "" ) {
        f.seed = int(sseed);
        dxr.seed = f.seed;
        f.bSetSeed = 1;
    } else {
        f.RollSeed();
    }
}

function bool EnumOptionMatched(string label, int value, optional out int output, optional string helpText)
{
    EnumOption(label, value, output, helpText);
    return value == output;
}

function RandomizeOptions()
{
    local int scrollPos;
    local DXRFlags f;
    f = GetFlags();

    scrollPos = winScroll.vScale.GetTickPosition();

    _BindControls(True);
    f.InitMaxRandoSettings();
    f.RandomizeSettings(True);
    _BindControls(False);

    //Scroll to same position again
    winScroll.vScale.SetTickPosition(scrollPos);
}

function SaveOptions()
{
    local DXRSavedSetup savedSetup;

    savedSetup = GetSavedSetup();
    savedSetup.Save( GetTextWindowText(GetIdFromLabel("Seed")), GetEnumValue(GetIdFromLabel("Starting Map")) );
}

function RestoreOptions()
{
    local int scrollPos;
    local DXRFlags flags;
    local DXRSavedSetup savedSetup;

    flags = GetFlags();
    savedSetup = GetSavedSetup();

    if (savedSetup.bSaved == false) return;

    scrollPos = winScroll.vScale.GetTickPosition();

    _BindControls(True);
    savedSetup.Restore();
    _BindControls(False);

    SetTextWindowText(GetIdFromLabel("Seed"), savedSetup.seedStr);
    SetEnumValue(GetIdFromLabel("Starting Map"), savedSetup.startingMapStr);
    SetDifficulty(flags.settings.CombatDifficulty);

    //Scroll to same position again
    winScroll.vScale.SetTickPosition(scrollPos);
}

function SetDifficulty(float newDifficulty)
{
    combatDifficulty = newDifficulty;
}

function HandleNewGameButton()
{
    local string s;
    local DXRFlags f;
    f = GetFlags();

    if(!class'HUDSpeedrunSplits'.static.CheckFlags(f)) {
        nextScreenNum=RMB_NewGame;
        s = Sprintf(SplitsBtnMessage, class'HUDSpeedrunSplits'.static.GetPB());
        class'BingoHintMsgBox'.static.Create(root, SplitsBtnTitle, s, 0, False, Self);
    }
    else {
        DoNewGameScreen();
    }
}

function DoNewGameScreen()
{
    _InvokeNewGameScreen(combatDifficulty);
}

function bool CheckClickHelpBtn( Window buttonPressed )
{
    if (Super.CheckClickHelpBtn(buttonPressed)){
        nextScreenNum=RMB_None; //Don't go anywhere after interacting with a help window button
        return true;
    }
    return false;
}

event bool BoxOptionSelected(Window button, int buttonNumber)
{
    root.PopWindow();

    switch (nextScreenNum){
        case RMB_NewGame:
            if (buttonNumber==0){
                DoNewGameScreen();
            }
            return true;
        case RMB_None:
            return true;
    }

    return Super.BoxOptionSelected(button,buttonNumber);
}

function string SetEnumValue(int e, string text)
{
    local int modeId, i;
    local DXRFlags f;

    if (e == gamemode_enum) {
        f = GetFlags();
        f.SetGameMode(f.GameModeIdForName(text));
    }

    return Super.SetEnumValue(e, text);
}

//#region Help Text Fns

//A simple spot to add basic help text that doesn't change based on settings
function String GetGenericHelpText(string opt)
{
    local string msg;

    switch(opt){
    case "seed":
        msg =       "The 'Seed' is the number used to initialize all the randomization in the game.  Given the same seed and settings, you will be able to replay the exact same game - or race against other players!|n";
        msg = msg $ "|n";
        msg = msg $ "If the Seed field is left blank, a random seed will be chosen for you.";
        break;
    case "augcanrando":
        msg =       "The chance for each augmentation canister to have its contents randomized.  At 100%, all aug cans will have random contents.  Likewise, 0% will leave all aug cans with their original contents.|n";
        msg = msg $ "|n";
        msg = msg $ "When randomized, the contents of the can will be selected from the augs available based on your selected game mode and loadout.";
        break;
    case "augslotrando":
        msg =       "The chance for each augmentation to get a randomized aug location, allowing them to be installed in a different body part than normal.  "$"At 100%, all augs will be assigned random body parts.  Likewise, at 0%, all augs will be able to be installed in their original location.|n";
        msg = msg $ "|n";
        msg = msg $ "Using values between 0% and 100% may result in some body parts being overloaded or other ones lacking in choices,"$" since augs are unlikely to randomize into the slots that were newly freed by other randomized augs.";
        break;
    case "merchant":
        msg =       "The chance for The Merchant to appear in each map.  At 100%, The Merchant will appear in every map.  At 0%, The Merchant will not appear at all.  "$"If you kill or knock out The Merchant, he will not appear again.|n";
        msg = msg $ "|n";
        msg = msg $ "The Merchant will have various useful items available for sale, which will be different every map.  "$"When using loadouts, The Merchant will not sell any banned items and may have additional items available (based on the loadout).";
        break;
    case "bingoscale":
        msg =       "Bingo Scale adjusts the number of times a bingo task needs to be done before completing the square.|n";
        msg = msg $ "|n";
        msg = msg $ "For example, a goal to 'Drink 100 Cans of Soda' at 50% Bingo Scale would become 'Drink 50 Cans of Soda'.  Goal amounts will not drop below 1.";
        break;
    case "augbots":
        msg =       "The chance of an augbot being spawned in each map.  Augbots will only be spawned if a medical bot was NOT spawned in the map (based on the 'Medbots %' setting).|n";
        msg = msg $ "|n";
        msg = msg $ "A hint datacube will be spawned near the Augbot saying that it has been delivered nearby, which can help you find it.|n";
        msg = msg $ "|n";
        msg = msg $ "Augbots look like a blue medical bot but are only able to install augmentations.  They are unable to heal the player at all.";
        break;
    case "repairbots":
        msg =       "The chance of a Repair Bot being spawned in each map.  Vanilla is about 14%.|n";
        msg = msg $ "|n";
        msg = msg $ "A hint datacube will be spawned near the Repair Bot saying that it has been delivered nearby, which can help you find it.|n";
        break;
    case "medbots":
        msg =       "The chance of a Medical Bot being spawned in each map.  Vanilla is about 14%.|n";
        msg = msg $ "|n";
        msg = msg $ "A hint datacube will be spawned near the Medical Bot saying that it has been delivered nearby, which can help you find it.|n";
        break;
    case "enemyweaponsvariety":
        msg =       "How varied do you want the weapons to be in each map, relative to the original game?  At 0%, enemies will only be given weapons present in the original level.  ";
        msg = msg $ "At 100%, enemies will be given weapons based on the weapon weighting decided by the randomizer.  Values in between will blend the two pools of weapon choices together.";
        break;
    case "swapcontainers":
        msg =       "The chance of each container to be shuffled in the map.|n";
        msg = msg $ "|n";
        msg = msg $ "Containers include obvious things like wooden crates, but also include things like metal crates, barrels, wicker baskets, trash cans, and trash bags.";
        break;
    case "bannedskills":
        msg =       "The chance of each skill to be entirely banned.  Bans will get rerolled along with skill costs.|n";
        msg = msg $ "|n";
        msg = msg $ "When banned, you will not be allowed to upgrade the skill at all.";
        break;
    case "bannedskilllevels":
        msg =       "The chance for any skill level for each skill to be banned.  Bans will get rerolled along with skill costs.|n";
        msg = msg $ "|n";
        msg = msg $ "When a skill level is banned, you will not be allowed to upgrade the skill beyond that banned level.  The upgrade from Untrained to Trained will never be banned by this setting.";
        break;
    case "addturrets":
        msg =       "The chances to add extra turrets, cameras, and security computers.|n";
        msg = msg $ "|n";
        msg = msg $ "Every additional 100% gives another chance to spawn a turret/camera/computer combo (meaning more added turrets).";
        break;
    case "playerhealth":
        msg =       "The maximum amount of health that the player has in each body part.  The vanilla setting is 100 health per body part.";
        break;
    case "playerenergy":
        msg =       "The maximum amount of bioelectric energy that the player has.  The vanilla setting is 100 energy.";
        break;
    case "splitsoverlay":
        msg =       "Choose whether or not to show an in-game speedrun timer.  You can edit DXRSplits.ini to adjust how your splits display in-game.";
        //TODO: THIS DESCRIPTION CERTAINLY COULD BE EXPANDED TO EXPLAIN DXRSplits.ini AND THE THINGS YOU CAN MODIFY IN THERE
        break;
    case "bingowin":
        msg =       "This setting determines how many lines of bingo you must complete in your game.|n";
        msg = msg $ "|n";
        msg = msg $ "In a typical game, completing this number of bingo lines will win the game instantly.|n";
        msg = msg $ "In Mean Bingo Machine mode, completing this number of bingo lines will allow you to progress to the next mission.|n";
        break;
    case "medbotuses":
        msg =       "This setting lets you select how many times each individual medbot can be used to heal the player.";
        break;
    case "repairbotuses":
        msg =       "This setting lets you select how many times each individual repair bot can be used to recharge the players energy.";
        break;
    case "enemyrespawn":
        msg =       "When enemies are killed or knocked unconscious, a new enemy will respawn at the original location after this many seconds.";
        break;
    case "reanimation":
        msg =       "When enemies are killed, they will be reanimated after this many seconds as zombies that attack with their hands and are hostile to everything around them.|n";
        msg = msg $ "|n";
        msg = msg $ "Unconscious enemies will not be reanimated.  Corpses can be destroyed (or relocated!) to prevent zombies from appearing!";
        break;
    case "nonhumanenemies":
        msg =       "What percentage of non-human enemies should actually be added?|n";
        msg = msg $ "|n";
        msg = msg $ "At 100%, all non-human clones will actually be spawned.  At 0%, no non-human clones will be created.|n";
        msg = msg $ "Lower values will result in less additional non-human enemies.";
        break;
    case "parischill":
        msg =       "This setting sets the odds of all MJ12 troops being removed from the streets of Paris.  This setting will carry through New Game Plus, giving a chance for some loops to have enemies and others to not have any.";
        break;
    case "nonhumanstatsunchanged":
        msg =       "Non-human enemies (Animals and robots) will not have randomized stats.";
        break;
    case "nonhumanstatsrandom":
        msg =       "Non-human enemies (Animals and robots) will have randomized stats, such as how long they are surprised, weapon accuracy, and ground speed.";
        break;
    default:
        log("GetGenericHelpText: No help text available for "$opt);
        break;
    }

    return msg;
}

function string GetSkillRerollHelpText(int reroll)
{
    switch (reroll){
        case 0:
            return "Skill costs are never rerolled!|n"$
                   "|n" $
                   "You're stuck with what you get at the start of the game!";
        case 1:
            return "Skill costs are rerolled every mission!";
        case 2:
            return "Skill costs are rerolled every 2 missions.|n" $
                   "|n" $
                   "Check at:|n"$
                   " ~ The first visit to Battery Park|n" $
                   " ~ Arriving at Hell's Kitchen to see Paul|n" $
                   " ~ Hong Kong|n" $
                   " ~ Return to NYC|n" $
                   " ~ Paris|n" $
                   " ~ Vandenberg|n" $
                   " ~ OceanLab";
        case 3:
            return "Skill costs are rerolled every 3 missions.|n" $
                   "|n" $
                   "Check at:|n"$
                   " ~ The second visit to Battery Park (Searching for Lebedev)|n" $
                   " ~ Hong Kong|n" $
                   " ~ Superfreighter|n" $
                   " ~ Vandenberg|n" $
                   " ~ Area 51";
        case 4:
            return "Skill costs are rerolled every 4 missions.|n" $
                   "|n" $
                   "Check at:|n"$
                   " ~ Arriving at Hell's Kitchen to see Paul|n" $
                   " ~ Return to NYC|n" $
                   " ~ Vandenberg";
        case 5:
            return "Skill costs are rerolled every 5 missions.|n" $
                   "|n" $
                   "Check at:|n"$
                   " ~ MJ12 Jail|n" $
                   " ~ Paris|n" $
                   " ~ Area 51";
        case 8:
            return "Skill costs are rerolled every 8 missions.|n" $
                   "|n" $
                   "Check at: Return to NYC";
    }
    return "";
}

function string GetCombatDifficultyHelpText()
{
    local string msg;

    msg =       "Combat Difficulty is generally a multiplier on damage that the player receives.|n";
    msg = msg $ "|n";
    msg = msg $ " ~ Damage from bullets and melee weapons are multiplied directly|n";
    if (class'MenuChoice_BalanceEtc'.static.IsEnabled()){
        msg = msg $ " ~ Damage from fire is multiplied directly|n";
        msg = msg $ " ~ Damage from other sources is multiplied by (CombatDifficulty/5)+80%|n";  //See BalancePlayer::DXReduceDamage
    }

    return msg;
}

function string GetBingoDurationHelpText(int duration)
{
    local string msg;

    msg = "The bingo board will be generated using goals ";

    if (duration==0){
        msg = msg $ "from your starting point until the end of the game.";
    } else if (duration==1){
        msg = msg $ "from the same mission as your chosen starting point.";
    } else {
        msg = msg $ "from the next "$duration$" missions from your chosen starting point (including the mission you start in).";
    }
    msg = msg $ "|n|n";
    if (duration==1){
        msg = msg $ "Goals that span multiple missions will not be available.";
    } else {
        msg = msg $ "Any goals that span multiple missions (eg. Bringing the Terrorist Commander to a bar) will only be available if the start and end points are within the range of your bingo duration.";
    }

    if (duration>0){
        msg = msg $ "|n|n";
        msg = msg $ "Bingo Goal amounts will be scaled down based on the Bingo Duration setting.";
    }

    return msg;
}

function string GetClothesLootingHelpText(int loot)
{
    local string msg;

    if (loot==0){ //Full Closet
        msg="JC starts with all possible clothing choices.  When outfits are randomized at the start of a mission or at a clothes rack, they will be selected from all the choices.";
    } else if (loot==1){ //Looting Needed
        msg="JC starts with the original trenchcoat outfit and the UNATCO uniform.  Clothes can be looted from bodies or found on clothes racks.  "$"When outfits are randomized at the start of a mission or when using a clothes rack, the outfit will be selected from clothes that you have found through the game.";
    }

    return msg;
}

function string GetSpoilerButtonHelpText(int spoil)
{
    local string msg;

    if (spoil==0){ //Disallowed
        msg="Spoiler buttons will not be available for goal locations or entrance randomizer.  You will still be able to use the 'Goal Locations' or 'Entrances' buttons to see the lists of possible locations or entrances.";
    } else if (spoil==1){ //Available
        msg="Spoiler buttons will be available on the Goals screen and the Images screen (for certain images).  The 'Goal Spoilers' and 'Entrance Spoilers' buttons will show you the exact locations and connections so you can proceed with the game.";
    }

    return msg;
}

function string GetCameraModeHelpText(int mode)
{
    local string msg;

    if (mode==0){ //First Person
        msg="The game will be played in a first-person perspective (as originally designed).";
    } else if (mode==1){ //Third Person
        msg="The game will be played in a third-person over-the-shoulder perspective.  A laser will be emitted from your face to indicate where you are aiming and will change color like the crosshairs.";
    } else if (mode==2){ //Fixed Camera
        msg="The game will be played with a camera that stays in a fixed position, like classic survival horror games.  The camera will follow your movement and reposition when you move out of line of sight."$"  A laser will be emitted from your face to indicate where you are aiming and will change color like the crosshairs.";
    }

    return msg;

}

function string GetSkillLevelCostsHelpText(int mode)
{
    local string msg;

    switch(mode){
        case 0: //Relative Skill Level Costs
            msg = "The cost of each skill level (for a single skill) are multiplied by the same random value.";
            break;
        case 1: //Unpredictable Skill Level Costs
            msg = "The cost of each skill level (for a single skill) are multiplied by a different random value.";
            break;
    }

    return msg;
}

function string GetShotTimeHelpText(bool max)
{
    local string msg;


    if (max){
        msg =   "The highest the shot time value on weapons will be able to randomized to.|n";
    } else {
        msg =   "The lowest the shot time value on weapons will be able to randomized to.|n";
    }
    msg = msg $ "|n";
    msg = msg $ "The 'shot time' is the amount of time it takes for a weapon to fire a single shot.  A lower shot time means the weapon fires more quickly (ie. has a faster fire rate).  A higher shot time means it fires slower (lower fire rate)";

    return msg;
}

function string GetPrisonPocketHelpText(int val)
{
    switch (val)
    {
        case 0: //Disabled
            return "If taken to prison, all of your items will be taken away from you.";
        case 1: //Unaugmented
            return "If taken to prison, all items will be taken away from you except for the first single slot item in your belt.";
        case 100: //Augmented
            return "If taken to prison, you will keep all of your items.";
    }
    return "";
}

function string GetAugSlotRandoHelpText(int val)
{
    switch (val)
    {
        case 0: //Disabled
            return "Augs get installed into their default body parts.";
        case 100: //Unbalanced
            return "Augs get installed into random body parts, with a chance for body parts to have more or fewer aug types than default.";
        case 200: //Balanced
            return "Augs get installed into random body parts, with the default number of aug types per body part maintained.";
    }
}

function string GetPasswordRandoHelpText(int val)
{
    switch(val){
        case 0: //Unchanged
            return "Passwords are unchanged from the original game.";
        case 100: //Randomized
            return "Passwords are randomized.  Keypads get randomized numeric code with an equal length to the original code.  ATM accounts get a randomized numeric PIN."$"  Computers get a randomized password made up of random letters and numbers.";
        case 200: //Randomized (Pronouncable)
            return "Passwords are randomized.  Keypads get randomized numeric code with an equal length to the original code.  ATM accounts get a randomized numeric PIN."$"  Computers get a randomized password made up of alternating vowels and consonants to form somewhat pronouncable words.";
        case 300: //Randomized (Random Words)
            return "Passwords are randomized.  Keypads get randomized numeric code with an equal length to the original code.  ATM accounts get a randomized numeric PIN."$"  Computers get a randomized password made up of two or three randomly selected words.";
    }
    return "";
}

function string GetEntranceRandoHelpText(int mode)
{
    local string msg;

    switch(mode){
        case 0: //Entrance Randomization Disabled
            msg = "Entrance Randomization is disabled.  All level transitions will take you to the original destination levels.";
            break;
        case 100: //Entrance Randomization Enabled
            msg = "Entrance Randomization is enabled.  Transitions between levels will take you to another randomly selected level transition within the same mission.|n";
            msg = msg $ "|n";
            msg = msg $ "Both Paris missions (missions 11 and 12) are merged together, as are Vandenberg and Ocean Lab (12 and 14).";

            break;
    }

    return msg;
}

function string GetGoodBotHelpText(string botType, string setting, int mode)
{
    local string msg;

    if (botType=="med") {
        if (setting=="cooldown"){
            switch(mode){
                case 0: //Unchanged
                    msg = "Medical Bot cooldowns after healing will be the same as in the original game (60 seconds).";
                    break;
                case 1: //Individual
                    msg = "Each Medical Bot will have its own randomly selected cooldown.  This cooldown will remain consistent after every heal.";
                    break;
                case 2: //Global
                    msg = "All Medical Bots will use the same single randomly selected cooldown.  This cooldown will remain consistent after every heal.";
                    break;
            }
        }else if (setting=="amount"){
            switch(mode){
                case 0: //Unchanged
                    msg = "Medical Bots will heal for the same amount as they did in the original game (300 health).";
                    break;
                case 1: //Individual
                    msg = "Each Medical Bot will have its own randomly selected heal amount.  This amount will be the same for all heals.";
                    break;
                case 2: //Global
                    msg = "All Medical Bots will use the same single randomly selected heal amount.  This amount will be the same for all heals.";
                    break;
            }
        }
    } else if (botType=="repair"){
        if (setting=="cooldown"){
            switch(mode){
                case 0: //Unchanged
                    msg = "Repair Bot cooldowns after charging will be the same as in the original game (60 seconds).";
                    break;
                case 1: //Individual
                    msg = "Each Repair Bot will have its own randomly selected cooldown.  This cooldown will remain consistent after every charge.";
                    break;
                case 2: //Global
                    msg = "All Repair Bots will use the same single randomly selected cooldown.  This cooldown will remain consistent after every charge.";
                    break;
            }
        }else if (setting=="amount"){
            switch(mode){
                case 0: //Unchanged
                    msg = "Repair Bots will recharge for the same amount as they did in the original game (75 energy).";
                    break;
                case 1: //Individual
                    msg = "Each Repair Bot will have its own randomly selected recharge amount.  This amount will be the same for all recharges.";
                    break;
                case 2: //Global
                    msg = "All Repair Bots will use the same single randomly selected recharge amount.  This amount will be the same for all recharges.";
                    break;
            }
        }
    }

    return msg;
}

function string GetStalkerHelpText(int mode)
{
    local string msg;
    local bool anna,bobby,mrh;

    msg = "";

    //This could probably actually parse the information out of
    //this encoded value, but I'm too lazy for now...
    switch(mode){
        case 0:
            msg = msg $ "2023 style :(";
            break;
        case 0x00040001:
            msg = msg $ "2024 style.  Each map will have one Mr. H.";
            mrh=true;
            break;
        case 0x00040002:
            msg = msg $ "Each map will have one Weeping Anna.";
            anna=true;
            break;
        case 0x00040003:
            msg = msg $ "Each map will have either a Mr. H or a Weeping Anna.";
            mrh=true;
            anna=true;
            break;
        case 0x00040004:
            msg = msg $ "Each map will have a set of Bobbys.";
            bobby=true;
            break;
        case 0x00040005:
            msg = msg $ "Each map will either have one Mr. H, or a set of Bobbys.";
            mrh=true;
            bobby=true;
            break;
        case 0x00040006:
            msg = msg $ "Just the new ones.  Each map will either have one Weeping Anna, or a set of Bobbys.";
            anna=true;
            bobby=true;
            break;
        case 0x0004FFFF:
            msg = msg $ "Halloween 2025 style!  Each map will either have one Mr. H, one Weeping Anna, or a set of Bobbys.";
            mrh=true;
            anna=true;
            bobby=true;
            break;
        case 0x0008FFFF:
            msg = msg $ "You might get 2 different types of stalkers in the same maps!";
            mrh=true;
            anna=true;
            bobby=true;
            break;
        case 0x0010FFFF:
            msg = msg $ "You might get all types of stalkers in the same maps!";
            mrh=true;
            anna=true;
            bobby=true;
            break;
        case 0x0028FFFF:
            msg = msg $ "You don't actually think this is a good idea, do you?";
            mrh=true;
            anna=true;
            bobby=true;
            break;
    }

    //Append information for the relevant stalkers
    if (mrh){
        msg = msg $ "|n";
        msg = msg $ "|n";
        msg = msg $ "Mr. H is a hulking menace who will stalk you through each level.  While he cannot be killed, he will retreat if he takes enough damage.  After a while, he will recover his health and return to the hunt.";
    }

    if (anna){
        msg = msg $ "|n";
        msg = msg $ "|n";
        msg = msg $ "Weeping Anna is a creature that doesn't exist while being observed.  As soon as they are seen, they freeze into rock.  When not being observed, they are fast.  Faster than you could believe.  Don't turn your back, don't look away, and don't blink!";
    }

    if (bobby){
        msg = msg $ "|n";
        msg = msg $ "|n";
        msg = msg $ "Bobby is your friend till the end!  Bundles of Bobby dolls will be scattered around the levels.  Some of those will be regular dolls, while others...";
    }

    return msg;
}

function string GetStartingLocationsHelpText(int mode)
{
    local string msg;

    msg = "";

    switch(mode)
    {
        case 0: //Unchanged
            msg = msg $ "The player starts each mission in the same spot they normally would in the original game.";
            break;
        case 100: //Randomized
            msg = msg $ "The player will start some missions in randomized locations.";
            break;
    }

    return msg;
}

function string GetGoalRandoHelpText(int mode)
{
    local string msg;

    msg = "";

    switch(mode)
    {
        case 0: //Unchanged
            msg = msg $ "Goal locations are unchanged from the original game.";
            break;
        case 100: //Randomized
            msg = msg $ "Some mission goals, important characters, or important things will be randomized between a selection of locations.  These locations will not necessarily always be on the same map as they originally were.";
            break;
        case 101: //Goal Location Hints
            msg = msg $ "Some mission goals, important characters, or important things will be randomized between a selection of locations.  These locations will not necessarily always be on the same map as they originally were.|n";
            msg = msg $ "|n";
            msg = msg $ "Markers will be shown on screen to indicate all the possible locations to check to find the randomized goals.";
            break;
        case 102: //Goal Location Spoilers
            msg = msg $ "Some mission goals, important characters, or important things will be randomized between a selection of locations.  These locations will not necessarily always be on the same map as they originally were.|n";
            msg = msg $ "|n";
            msg = msg $ "Markers will be shown on screen to indicate the locations of the randomized goals.";
            break;
        case 200: //Serious
            msg = msg $ "Some mission goals, important characters, or important things will be randomized between a selection of locations.  These locations will not necessarily always be on the same map as they originally were.|n";
            msg = msg $ "|n";
            msg = msg $ "The silly goal locations have been removed from the pool of options, so goals will only be randomized into more plausible locations.";
            break;
    }

    return msg;
}
//#endregion

defaultproperties
{
    num_rows=13
    num_cols=4
    col_width_odd=160
    col_width_even=140
    row_height=20
    padding_width=20
    padding_height=10
    Title="DX Rando Options"
    bEscapeSavesSettings=False
    actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel,Text="|&Back")
    actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Next",Key="NEXT")
    actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Randomize",Key="RANDOMIZE")
    actionButtons(3)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Restore Settings",Key="RESTORE")
    actionButtons(4)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Save Settings",Key="SAVE")
    SplitsBtnTitle="Mismatched Splits!"
    SplitsBtnMessage="It appears that your DXRSplits.ini file is for different settings than this.|n|nThe PB is %s.|n|nAre you sure you want to continue?"
    showMode=True
    showLoadout=True
    showAutosave=True
    showCrowdControl=True
    showOnlineFeatures=True
    showMirroredMaps=True
}
