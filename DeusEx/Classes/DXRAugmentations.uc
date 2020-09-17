class DXRAugmentations extends DXRBase;

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
