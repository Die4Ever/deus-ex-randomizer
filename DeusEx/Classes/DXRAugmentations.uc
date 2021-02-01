class DXRAugmentations extends DXRBase transient;

var config float min_aug_str;
var config float max_aug_str;

function CheckConfig()
{
    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,8) ) {
        min_aug_str = 0.5;
        max_aug_str = 1.5;
    }
    Super.CheckConfig();
}

function FirstEntry()
{
    local Augmentation anAug;

    Super.FirstEntry();

    anAug = dxr.Player.AugmentationSystem.FindAugmentation(class'AugSpeed');

    if( anAug != None && anAug.bHasIt == False && dxr.flags.speedlevel>0 )
    {
        anAug = dxr.Player.AugmentationSystem.GivePlayerAugmentation(class'AugSpeed');
        anAug.CurrentLevel = min(dxr.flags.speedlevel-1, anAug.MaxLevel);
    }

    RandomizeAugCannisters();
}

function AnyEntry()
{
    local Augmentation a;
    Super.AnyEntry();

    foreach AllActors(class'Augmentation', a) {
        RandoAug(a);
    }
}

function RandomizeAugCannisters()
{
    local AugmentationCannister a;

    if( dxr.Player == None ) return;

    SetSeed( "RandomizeAugCannisters" );

    foreach AllActors(class'AugmentationCannister', a)
    {
        if( a.Owner == dxr.Player ) continue;
        RandomizeAugCannister(dxr, a);
    }
}

function static RandomizeAugCannister(DXRando dxr, AugmentationCannister a)
{
    a.AddAugs[0] = PickRandomAug(dxr);
    a.AddAugs[1] = a.AddAugs[0];
    while( a.AddAugs[1] == a.AddAugs[0] )
    {
        a.AddAugs[1] = PickRandomAug(dxr);
    }

    if( a.AddAugs[0] == 'AugSpeed' || a.AddAugs[1] == 'AugSpeed' ) {
        dxr.Player.ClientMessage("Speed Enhancement is in this area.");
    }
}

function static Name PickRandomAug(DXRando dxr)
{
    local int slot;
    local int skipAugSpeed;
    local int numAugs;
    numAugs=21;
    if( dxr.flags.speedlevel > 0 )
        skipAugSpeed=1;
    slot = staticrng(dxr, numAugs-3-skipAugSpeed) + skipAugSpeed;// exclude the 3 or 4 augs you start with, 0 is AugSpeed
    if ( slot >= 11 ) slot++;// skip AugIFF
    if ( slot >= 12 ) slot++;// skip AugLight
    if (slot >= 18 ) slot++;// skip AugDatalink
    log("Picked Aug "$ slot $"/"$numAugs$" " $ dxr.Player.AugmentationSystem.augClasses[slot].Name, 'DXRAugmentations');
    return dxr.Player.AugmentationSystem.augClasses[slot].Name;
}

function RandoAug(Augmentation a)
{
    local int oldseed;
    local string s;
    if( dxr == None ) return;
    if( AugSpeed(a) != None || AugLight(a) != None ) return;
    oldseed = dxr.SetSeed( dxr.Crc(dxr.seed $ "RandoAug " $ a.class.name ) );
    s = RandoLevelValues(a.LevelValues, a.default.LevelValues, min_aug_str, max_aug_str);
    if( InStr(a.Description, s) == -1 )
        a.Description = a.Description $ "|n|n" $ s;
    dxr.SetSeed(oldseed);
}
