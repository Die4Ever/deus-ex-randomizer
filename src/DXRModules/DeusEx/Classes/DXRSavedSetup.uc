class DXRSavedSetup extends DXRFlagsBase transient config(DXRSavedSetup);

var config string seedStr;
var config string startingMapStr;

var config int bingo_duration;
var config int bingo_scale;
var config int newgameplus_max_item_carryover;
var config int newgameplus_num_skill_downgrades;
var config int newgameplus_num_removed_augs;
var config int newgameplus_num_removed_weapons;
var config int clothes_looting;
var config int remove_paris_mj12;

var config FlagsSettings settings;
var config MoreFlagsSettings moresettings;

var config bool bSaved;

static function DXRSavedSetup GetObj(Actor a)
{
    local DXRSavedSetup savedSetup;

    foreach a.AllActors(class'DXRSavedSetup', savedSetup) return savedSetup;
    return a.Spawn(class'DXRSavedSetup');
}

function SaveSetup(DXRFlags other, string seed, string startingMap)
{
    seedStr = seed;
    startingMapStr = startingMap;

    config_version = other.config_version;
    gamemode = other.gamemode;
    loadout = other.loadout;
    autosave = other.autosave;
    mirroredmaps = other.mirroredmaps;
    difficulty = other.difficulty;

    bingo_duration = other.bingo_duration;
    bingo_scale = other.bingo_scale;
    newgameplus_max_item_carryover = other.newgameplus_max_item_carryover;
    newgameplus_num_skill_downgrades = other.newgameplus_num_skill_downgrades;
    newgameplus_num_removed_augs = other.newgameplus_num_removed_augs;
    newgameplus_num_removed_weapons = other.newgameplus_num_removed_weapons;
    clothes_looting = other.clothes_looting;
    remove_paris_mj12 = other.remove_paris_mj12;

    settings = other.settings;
    moresettings = other.moresettings;

    bSaved = true;

    SaveConfig();
}

function RestoreSetup(DXRFlags other)
{
    if (bSaved == false) return;

    other.gamemode = gamemode;
    other.loadout = loadout;

    if( seedStr != "" ) {
        other.seed = int(seedStr);
        other.dxr.seed = other.seed;
        other.bSetSeed = 1;
    } else {
        other.RollSeed();
    }

    other.SetDifficulty(difficulty); // do this before loading the settings just in case the saved settings are old and missing new flags

    other.autosave = autosave;
    other.mirroredmaps = mirroredmaps;
    other.difficulty = difficulty;

    other.bingo_duration = bingo_duration;
    other.bingo_scale = bingo_scale;
    other.newgameplus_max_item_carryover = newgameplus_max_item_carryover;
    other.newgameplus_num_skill_downgrades = newgameplus_num_skill_downgrades;
    other.newgameplus_num_removed_augs = newgameplus_num_removed_augs;
    other.newgameplus_num_removed_weapons = newgameplus_num_removed_weapons;
    other.clothes_looting = clothes_looting;
    other.remove_paris_mj12 = remove_paris_mj12;

    other.settings = settings;
    if(startingMapStr == "Random") moresettings.starting_map = other.moresettings.starting_map; // reuse the roll from SetDifficulty
    other.moresettings = moresettings;
}
