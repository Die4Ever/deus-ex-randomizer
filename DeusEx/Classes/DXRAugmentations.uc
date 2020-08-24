class DXRAugmentations extends DXRBase;

function FirstEntry()
{
    local Augmentation anAug;

    Super.FirstEntry();

    if( dxr.localURL == "01_NYC_UNATCOISLAND" && dxr.flags.speedlevel>0 )
    {// change this so it looks if the player has the augmentation already, instead of checking the map name
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
        a.AddAugs[0] = PickRandomAug();
        a.AddAugs[1] = a.AddAugs[0];
        while( a.AddAugs[1] == a.AddAugs[0] )
        {
            a.AddAugs[1] = PickRandomAug();
        }
    }
}

function Name PickRandomAug()
{
    local int slot;
    local int skipAugSpeed;
    local int numAugs;
    numAugs=21;
    if( dxr.flags.speedlevel > 0 )
        skipAugSpeed=1;
    slot = rng(numAugs-3-skipAugSpeed) + skipAugSpeed;// exclude the 3 or 4 augs you start with, 0 is AugSpeed
    if ( slot >= 11 ) slot++;// skip AugIFF
    if ( slot >= 12 ) slot++;// skip AugLight
    if (slot >= 18 ) slot++;// skip AugDatalink
    l("Picked Aug "$ slot $"/"$numAugs$" " $ dxr.Player.AugmentationSystem.augClasses[slot].Name);
    return dxr.Player.AugmentationSystem.augClasses[slot].Name;
}
