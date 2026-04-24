class DXRSavedSetup extends DXRFlagsBase transient config(DXRSavedSetup);

var config #var(flagvarprefix) string seedStr;
var config #var(flagvarprefix) string startingMapStr;

var config #var(flagvarprefix) int bingo_duration;
var config #var(flagvarprefix) int bingo_scale;
var config #var(flagvarprefix) int newgameplus_max_item_carryover;
var config #var(flagvarprefix) int newgameplus_num_skill_downgrades;
var config #var(flagvarprefix) int newgameplus_num_removed_augs;
var config #var(flagvarprefix) int newgameplus_num_removed_weapons;
var config #var(flagvarprefix) int clothes_looting;
var config #var(flagvarprefix) int remove_paris_mj12;

var config #var(flagvarprefix) FlagsSettings settings;
var config #var(flagvarprefix) MoreFlagsSettings moresettings;

var config #var(flagvarprefix) bool bSaved;

simulated function Save(string seedStr, string startingMapStr)
{
    self.seedStr = seedStr;
    self.startingMapStr = startingMapStr;

    gamemode = dxr.flags.gamemode;
    loadout = dxr.flags.loadout;
    autosave = dxr.flags.autosave;
    mirroredmaps = dxr.flags.mirroredmaps;
    difficulty = dxr.flags.difficulty;

    bingo_duration = dxr.flags.bingo_duration;
    bingo_scale = dxr.flags.bingo_scale;
    newgameplus_max_item_carryover = dxr.flags.newgameplus_max_item_carryover;
    newgameplus_num_skill_downgrades = dxr.flags.newgameplus_num_skill_downgrades;
    newgameplus_num_removed_augs = dxr.flags.newgameplus_num_removed_augs;
    newgameplus_num_removed_weapons = dxr.flags.newgameplus_num_removed_weapons;
    clothes_looting = dxr.flags.clothes_looting;
    remove_paris_mj12 = dxr.flags.remove_paris_mj12;

    settings = dxr.flags.settings;
    moresettings = dxr.flags.moresettings;

    bSaved = true;

    SaveConfig();
}

simulated function Restore()
{
    dxr.flags.gamemode = gamemode;
    dxr.flags.loadout = loadout;
    dxr.flags.autosave = autosave;
    dxr.flags.mirroredmaps = mirroredmaps;
    dxr.flags.difficulty = difficulty;

    dxr.flags.bingo_duration = bingo_duration;
    dxr.flags.bingo_scale = bingo_scale;
    dxr.flags.newgameplus_max_item_carryover = newgameplus_max_item_carryover;
    dxr.flags.newgameplus_num_skill_downgrades = newgameplus_num_skill_downgrades;
    dxr.flags.newgameplus_num_removed_augs = newgameplus_num_removed_augs;
    dxr.flags.newgameplus_num_removed_weapons = newgameplus_num_removed_weapons;
    dxr.flags.clothes_looting = clothes_looting;
    dxr.flags.remove_paris_mj12 = remove_paris_mj12;

    dxr.flags.settings = settings;
    dxr.flags.moresettings = moresettings;
}
