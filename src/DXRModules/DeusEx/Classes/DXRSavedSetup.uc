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

static function DXRSavedSetup GetObj(Actor a)
{
    local DXRSavedSetup savedSetup;

    foreach a.AllActors(class'DXRSavedSetup', savedSetup) return savedSetup;
    return a.Spawn(class'DXRSavedSetup');
}
