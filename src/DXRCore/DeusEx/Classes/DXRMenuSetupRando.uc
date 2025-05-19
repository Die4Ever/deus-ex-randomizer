class DXRMenuSetupRando extends DXRMenuBase;

var float combatDifficulty;

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
    local string doors_option, s;
    local int iDifficulty, i;
    local bool bMatched;
    f = GetFlags();

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

    //Make sure the starting map values match those in DXRStartMap
    NewMenuItem("Starting Map", "What level you will start in.");
    for(i=0; i<160; i++) {
        if(i == 10) continue;// Liberty Island dupe
        s = class'DXRStartMap'.static.GetStartingMapName(i);
        if(s != "") {
            EnumOption(s, i, f.settings.starting_map);
        }
    }
    if(f.settings.starting_map > 0) {
        EnumOption("Random", f.settings.starting_map, f.settings.starting_map);
    }
    else if(EnumOption("Random", -1)) {
        f.settings.starting_map = class'DXRStartMap'.static.ChooseRandomStartMap(f, 0);
    }

    BreakLine();

    NewMenuItem("Player Health", "Max health for each body part of the player.");
    Slider(f.settings.health, 1, 10000);

    NewMenuItem("Player Energy", "Max bioelectric energy for the player.");
    Slider(f.settings.energy, 0, 10000);

    BreakLine();

#ifndef hx
    NewMenuItem("", "Randomize starting locations on certain maps.");
    EnumOption("Randomize Starting Locations", 100, f.settings.startinglocations);
    EnumOption("Unchanged Starting Locations", 0, f.settings.startinglocations);
#endif

    NewMenuItem("", "Randomize goal locations on certain maps.");
    EnumOption("Randomize Goal Locations", 100, f.settings.goals);
    EnumOption("Unchanged Goal Locations", 0, f.settings.goals);
    EnumOption("Goal Location Hints", 101, f.settings.goals);
    EnumOption("Goal Location Spoilers", 102, f.settings.goals);

    BreakLine();
#ifndef hx
    NewMenuItem("The Merchant Chance %", "The chance for The Merchant to appear in each map."$BR$"If The Merchant dies then he stays dead for the rest of the game.");
    Slider(f.settings.merchants, 0, 100,GetMerchantHelpText());
#endif

    NewMenuItem("Dancing %", "How many characters should be dancing.");
    Slider(f.settings.dancingpercent, 0, 100);

    NewMenuItem("Spoiler Buttons", "Allow the use of spoiler buttons (Spoilers remain hidden until you choose to view them).");
    EnumOption("Available", 1, f.settings.spoilers);
    EnumOption("Disallowed", 0, f.settings.spoilers);

    NewMenuItem("Menus Pause Game", "Should the game keep playing while a menu is open?");
    EnumOption("Pause", 1, f.settings.menus_pause);
    EnumOption("Don't Pause", 0, f.settings.menus_pause);

    NewMenuItem("Camera Mode", "What camera mode should be used");
    EnumOption("First Person", 0, f.moresettings.camera_mode);
    EnumOption("Third Person", 1, f.moresettings.camera_mode);
    if(#defined(vanilla || revision)) {
        EnumOption("Fixed Camera", 2, f.moresettings.camera_mode);
    }

    NewMenuItem("Splits Overlay", "Splits and total game time overlay");
    EnumOption("Don't Show", 0, f.moresettings.splits_overlay);
    EnumOption("Show", 1, f.moresettings.splits_overlay);

#ifdef vanilla
    NewMenuItem("Clothes Looting", "Should clothes need to be looted first, or start with all of them?");
    EnumOption("Full Closet", 0, f.clothes_looting, GetClothesLootingHelpText(0));
    EnumOption("Looting Needed", 1, f.clothes_looting, GetClothesLootingHelpText(1));
#endif

    NewGroup("Bingo");

    NewMenuItem("Bingo Win", "How many completed lines to instantly win (or progress in Mean Bingo Machine mode).");
    Slider(f.settings.bingo_win, 0, 12);

    NewMenuItem("Bingo Scale %", "How difficult should bingo goals be?");
    Slider(f.bingo_scale, 0, 100, GetBingoScaleHelpText());

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

    NewGroup("Medical Bots and Repair Bots");

    NewMenuItem("Medbots", "Percentage chance for a medbot to spawn in a map (vanilla is about 14%).");
    Slider(f.settings.medbots, -1, 100,GetMedBotHelpText());

    NewMenuItem("Augbots", "Percentage chance for a zero-heals medbot to spawn in a map if a regular one doesn't.");
    Slider(f.moresettings.empty_medbots, 0, 100, GetAugbotsHelpText());

    NewMenuItem("Repair Bots", "Percentage chance for a repair bot to spawn in a map (vanilla is about 14%).");
    Slider(f.settings.repairbots, -1, 100,GetRepairBotHelpText());

    if(!#defined(vmd)) {
        NewMenuItem("Medbot Uses", "Number of times you can use an individual medbot to heal.");
        Slider(f.settings.medbotuses, 0, 10);

        NewMenuItem("Repair Bot Uses", "Number of times you can use an individual repair bot to restore energy.");
        Slider(f.settings.repairbotuses, 0, 10);
    }

    NewMenuItem("Medbot Cooldowns", "Individual: Each Medbot has its own healing cooldown."$BR$"Global: All Medbots have the same cooldown.");
    EnumOption("Unchanged", 0, f.settings.medbotcooldowns);
    EnumOption("Individual", 1, f.settings.medbotcooldowns);
    EnumOption("Global", 2, f.settings.medbotcooldowns);

    NewMenuItem("Repair Bot Cooldowns", "Individual: Each Repair Bot has its own charge cooldown."$BR$"Global: All Repair Bots have the same cooldown.");
    EnumOption("Unchanged", 0, f.settings.repairbotcooldowns);
    EnumOption("Individual", 1, f.settings.repairbotcooldowns);
    EnumOption("Global", 2, f.settings.repairbotcooldowns);

    NewMenuItem("Medbot Heal Amount", "Individual: Each Medbot has its own healing amount."$BR$"Global: All Medbots have the same amount.");
    EnumOption("Unchanged", 0, f.settings.medbotamount);
    EnumOption("Individual", 1, f.settings.medbotamount);
    EnumOption("Global", 2, f.settings.medbotamount);

    NewMenuItem("Repair Bot Charge Amount", "Individual: Each Repair Bot has its own charge amount."$BR$"Global: All Repair Bots have the same amount.");
    EnumOption("Unchanged", 0, f.settings.repairbotamount);
    EnumOption("Individual", 1, f.settings.repairbotamount);
    EnumOption("Global", 2, f.settings.repairbotamount);

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

    NewMenuItem("Passwords", "Forces you to look for passwords and passcodes.");
    EnumOption("Randomized", 100, f.settings.passwordsrandomized);
    EnumOption("Unchanged", 0, f.settings.passwordsrandomized);

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
    Slider(f.moresettings.enemies_weapons, 0, 100, GetEnemyWeaponsVarietyHelpText());

    NewMenuItem("Robot Weapons Rando %", "Allow robots to get randomized weapons.");
    Slider(f.settings.bot_weapons, 0, 100);

    NewMenuItem("Non-Human Chance %", "Reduce the chance of new enemies being non-humans.");
    Slider(f.settings.enemies_nonhumans, 0, 100);

    NewMenuItem("Enemy Respawn Seconds", "How many seconds for enemies to respawn.  Leave blank or 0 to disable.");
    Slider(f.settings.enemyrespawn, 0, 3600);

    NewMenuItem("Reanimation Seconds", "Approximately how many seconds for corpses to come back as zombies.  Leave blank or 0 to disable.");
    Slider(f.moresettings.reanimation, 0, 3600);

    NewMenuItem("Move Turrets", "Randomizes locations of turrets, cameras, and security computers for them.");
    Slider(f.settings.turrets_move, 0, 100);

    NewMenuItem("Add Turrets", "Randomly adds turrets, cameras, and security computers for them.");
    Slider(f.settings.turrets_add, 0, 10000, GetAddTurretsHelpText());

    NewMenuItem("", "Allow non-humans to get randomized stats.");
    EnumOption("Unchanged Non-human Stats", 0, f.settings.bot_stats);
    EnumOption("Random Non-human Stats", 100, f.settings.bot_stats);

    NewMenuItem("Paris Chill %", "Chance to remove all MJ12 from the Champs-Elysees.");
    Slider(f.remove_paris_mj12, 0, 100);


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
    if(f.settings.skills_reroll_missions > 5) {
        EnumOption("Reroll Skill Costs Every " $ f.settings.skills_reroll_missions $ " Missions",
            f.settings.skills_reroll_missions, f.settings.skills_reroll_missions
        );
    }

    NewMenuItem("", "Predictability of skill level cost scaling.");
    EnumOption("Relative Skill Level Costs", 0, f.settings.skills_independent_levels, GetSkillLevelCostsHelpText(0));
    EnumOption("Unpredictable Skill Level Costs", 1, f.settings.skills_independent_levels, GetSkillLevelCostsHelpText(1));

    BreakLine();

    NewMenuItem("Minimum Skill Cost %", "Minimum cost for skills in percentage of the original cost.");
    Slider(f.settings.minskill, 50, 1000);

    NewMenuItem("Maximum Skill Cost %", "Maximum cost for skills in percentage of the original cost.");
    Slider(f.settings.maxskill, 50, 1000);

    NewMenuItem("Banned Skills %", "Chance of a skill having a cost of 99,999 points.");
    Slider(f.settings.banned_skills, 0, 100, GetBannedSkillsHelpText());

    NewMenuItem("Banned Skill Levels %", "Chance of a certain level of a skill having a cost of 99,999 points.");
    Slider(f.settings.banned_skill_levels, 0, 100, GetBannedSkillLevelsHelpText());

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
    Slider(f.settings.swapcontainers, 0, 100,GetSwapContainersHelpText());

    NewMenuItem("Swap Grenades %", "The chance for grenades on walls to have their type randomized.");
    Slider(f.settings.grenadeswap, 0, 100);

    BreakLine();
    NewMenuItem("Min Weapon Damage %", "The minimum damage for weapons.");
    Slider(f.settings.min_weapon_dmg, 0, 500);

    NewMenuItem("Max Weapon Damage %", "The maximum damage for weapons.");
    Slider(f.settings.max_weapon_dmg, 0, 500);

    BreakLine();
    NewMenuItem("Min Weapon Shot Time %", "The minimum shot time / firing speed for weapons.");
    Slider(f.settings.min_weapon_shottime, 0, 500,GetShotTimeHelpText(false));

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
    Slider(f.settings.augcans, 0, 100, GetAugCansRandoHelpText());

    NewMenuItem("Aug Strength Rando %", "How much to randomize the strength of augmentations.");
    Slider(f.settings.aug_value_rando, 0, 100);// this is a wet/dry scale, 0 to 100%

    NewMenuItem("Aug Slot Rando %", "The chance for each aug to randomize the body part it can be installed into");
    Slider(f.moresettings.aug_loc_rando, 0, 100, GetAugSlotRandoHelpText());

    NewGroup("New Game+");

    NewMenuItem("Scaling %", "Scales the curve of New Game+ changes over successive loops.  Set to -1 to disable.  100% is default.");
    Slider(f.moresettings.newgameplus_curve_scalar, -1, 200);
    NewMenuItem("Max Item Carryover", "Maximum number of the same item that can carry over between loops, not including stackable items.");
    Slider(f.newgameplus_max_item_carryover, 0, 30);
    NewMenuItem("Skill Downgrades", "Number of skill level downgrades per loop.");
    Slider(f.newgameplus_num_skill_downgrades, 0, 33);
    NewMenuItem("Augmentations Removed", "Number of augmentations removed per loop.");
    Slider(f.newgameplus_num_removed_augs, 0, 8);
    NewMenuItem("Weapons Removed", "Number of weapons removed per loop.");
    Slider(f.newgameplus_num_removed_weapons, 0, 18);

    if( action == "NEXT" ) HandleNewGameButton();
    if( action == "RANDOMIZE" ) RandomizeOptions();
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

function SetDifficulty(float newDifficulty)
{
    combatDifficulty = newDifficulty;
}

function HandleNewGameButton()
{
    local DXRFlags f;
    f = GetFlags();

    if(!class'HUDSpeedrunSplits'.static.CheckFlags(f)) {
        nextScreenNum=RMB_NewGame;
        class'BingoHintMsgBox'.static.Create(root, SplitsBtnTitle,SplitsBtnMessage,0,False,Self);
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

//#region Help Text Fns
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

function string GetAugCansRandoHelpText()
{
    local string msg;

    msg =       "The chance for each augmentation canister to have its contents randomized.  At 100%, all aug cans will have random contents.  Likewise, 0% will leave all aug cans with their original contents.|n";
    msg = msg $ "|n";
    msg = msg $ "When randomized, the contents of the can will be selected from the augs available based on your selected game mode and loadout.";

    return msg;
}

function string GetAugSlotRandoHelpText()
{
    local string msg;

    msg =       "The chance for each augmentation to get a randomized aug location, allowing them to be installed in a different body part than normal.  "$"At 100%, all augs will be assigned random body parts.  Likewise, at 0%, all augs will be able to be installed in their original location.|n";
    msg = msg $ "|n";
    msg = msg $ "Using values between 0% and 100% may result in some body parts being overloaded or other ones lacking in choices,"$" since augs are unlikely to randomize into the slots that were newly freed by other randomized augs.";

    return msg;
}

function string GetMerchantHelpText()
{
    local string msg;

    msg =       "The chance for The Merchant to appear in each map.  At 100%, The Merchant will appear in every map.  At 0%, The Merchant will not appear at all.  "$"If you kill or knock out The Merchant, he will not appear again.|n";
    msg = msg $ "|n";
    msg = msg $ "The Merchant will have various useful items available for sale, which will be different every map.  "$"When using loadouts, The Merchant will not sell any banned items and may have additional items available (based on the loadout).";

    return msg;
}

function string GetBingoScaleHelpText()
{
    local string msg;

    msg =       "Bingo Scale adjusts the number of times a bingo task needs to be done before completing the square.|n";
    msg = msg $ "|n";
    msg = msg $ "For example, a goal to 'Drink 100 Cans of Soda' at 50% Bingo Scale would become 'Drink 50 Cans of Soda'.  Goal amounts will not drop below 1.";

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

function string GetAugbotsHelpText()
{
    local string msg;

    msg =       "The chance of an augbot being spawned in each map.  Augbots will only be spawned if a medical bot was NOT spawned in the map (based on the 'Medbots %' setting).|n";
    msg = msg $ "|n";
    msg = msg $ "A hint datacube will be spawned near the Augbot saying that it has been delivered nearby, which can help you find it.|n";
    msg = msg $ "|n";
    msg = msg $ "Augbots look like a blue medical bot but are only able to install augmentations.  They are unable to heal the player at all.";

    return msg;
}

function string GetRepairBotHelpText()
{
    local string msg;

    msg =       "The chance of a Repair Bot being spawned in each map.|n";
    msg = msg $ "|n";
    msg = msg $ "A hint datacube will be spawned near the Repair Bot saying that it has been delivered nearby, which can help you find it.|n";

    return msg;
}

function string GetMedBotHelpText()
{
    local string msg;

    msg =       "The chance of a Medical Bot being spawned in each map.|n";
    msg = msg $ "|n";
    msg = msg $ "A hint datacube will be spawned near the Medical Bot saying that it has been delivered nearby, which can help you find it.|n";

    return msg;
}

function string GetEnemyWeaponsVarietyHelpText()
{
    local string msg;

    msg =       "How varied do you want the weapons to be in each map, relative to the original game?  At 0%, enemies will only be given weapons present in the original level.  ";
    msg = msg $ "At 100%, enemies will be given weapons based on the weapon weighting decided by the randomizer.  Values in between will blend the two pools of weapon choices together.";

    return msg;
}

function string GetSwapContainersHelpText()
{
    local string msg;

    msg =       "The chance of each container to be shuffled in the map.|n";
    msg = msg $ "|n";
    msg = msg $ "Containers include obvious things like wooden crates, but also include things like metal crates, barrels, wicker baskets, trash cans, and trash bags.";

    return msg;
}

function string GetBannedSkillsHelpText()
{
    local string msg;

    msg =       "The chance of each skill to be entirely banned.  Bans will get rerolled along with skill costs.|n";
    msg = msg $ "|n";
    msg = msg $ "When banned, you will not be allowed to upgrade the skill at all.";

    return msg;
}

function string GetBannedSkillLevelsHelpText()
{
    local string msg;

    msg =       "The chance for any skill level for each skill to be banned.  Bans will get rerolled along with skill costs.|n";
    msg = msg $ "|n";
    msg = msg $ "When a skill level is banned, you will not be allowed to upgrade the skill beyond that banned level.  The upgrade from Untrained to Trained will never be banned by this setting.";

    return msg;
}

function string GetAddTurretsHelpText()
{
    local string msg;

    msg =       "The chances to add extra turrets, cameras, and security computers.|n";
    msg = msg $ "|n";
    msg = msg $ "Every additional 100% gives another chance to spawn a turret/camera/computer combo (meaning more added turrets).";

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
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
    actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel,Text="|&Back")
    actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Next",Key="NEXT")
    actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Randomize",Key="RANDOMIZE")
    SplitsBtnTitle="Mismatched Splits!"
    SplitsBtnMessage="It appears that your DXRSplits.ini file is for different settings than this.|n|nAre you sure you want to continue?"
}
