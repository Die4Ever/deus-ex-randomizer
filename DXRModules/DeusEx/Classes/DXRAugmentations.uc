class DXRAugmentations extends DXRBase transient;

var config float min_aug_str;
var config float max_aug_str;

replication
{
    reliable if( Role==ROLE_Authority )
        min_aug_str, max_aug_str;
}

function CheckConfig()
{
    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,8) ) {
        min_aug_str = default.min_aug_str;
        max_aug_str = default.max_aug_str;
    }
    Super.CheckConfig();
}

function FirstEntry()
{
    Super.FirstEntry();

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

simulated function PlayerAnyEntry(#var PlayerPawn  p)
{
    local Augmentation a;
    Super.PlayerAnyEntry(p);
    foreach AllActors(class'Augmentation', a) {
        RandoAug(a);
    }
}

static function AddAug(DeusExPlayer player, class<Augmentation> aclass, int level)
{
    local Augmentation anAug;
    local AugmentationManager am;

    am = player.AugmentationSystem;
    anAug = am.FindAugmentation(aclass);
    if( anAug == None ) {
        for( anAug = am.FirstAug; anAug != None; anAug = anAug.next ) {
            if( anAug.next == None ) {
                anAug.next = am.Spawn(aclass, am);
                anAug = anAug.next;
                if( anAug != None )
                    anAug.player = player;
                break;
            }
        }
    }

    anAug = am.FindAugmentation(aclass);
    if( anAug != None && anAug.bHasIt == False && level>0 )
    {
        anAug = am.GivePlayerAugmentation(aclass);
        anAug.CurrentLevel = min(level-1, anAug.MaxLevel);
    }
}

function RandomizeAugCannisters()
{
    local #var prefix AugmentationCannister a;

    if( dxr.flagbase == None ) return;

    SetSeed( "RandomizeAugCannisters" );

    foreach AllActors(class'#var prefix AugmentationCannister', a)
    {
        if( DeusExPlayer(a.Owner) != None ) continue;
        RandomizeAugCannister(dxr, a);
    }
}

function static RandomizeAugCannister(DXRando dxr, #var prefix AugmentationCannister a)
{
    local int attempts;
    a.AddAugs[0] = PickRandomAug(dxr);
    a.AddAugs[1] = a.AddAugs[0];
    for( attempts = 0; attempts<100 && a.AddAugs[1] == a.AddAugs[0]; attempts++ )
    {
        a.AddAugs[1] = PickRandomAug(dxr);
    }

    if( a.AddAugs[0] == '#var prefix AugSpeed' || a.AddAugs[1] == '#var prefix AugSpeed' ) {
        dxr.flags.player().ClientMessage("Speed Enhancement is in this area.",, true);
    }
}

function static Name PickRandomAug(DXRando dxr)
{
    local int slot;
    local int skipAugSpeed;
    local int numAugs;
    local Name AugName;
    numAugs=21;
    if( dxr.flags.speedlevel > 0 )
        skipAugSpeed=1;
    slot = staticrng(dxr, numAugs-3-skipAugSpeed) + skipAugSpeed;// exclude the 3 or 4 augs you start with, 0 is AugSpeed
    if ( slot >= 11 ) slot++;// skip AugIFF
    if ( slot >= 12 ) slot++;// skip AugLight
    if (slot >= 18 ) slot++;// skip AugDatalink
    AugName = class'#var prefix AugmentationManager'.default.augClasses[slot].Name;
    log("Picked Aug "$ slot $"/"$numAugs$" " $ AugName, 'DXRAugmentations');
    return AugName;
}

simulated function RandoAug(Augmentation a)
{
    local int oldseed;
    if( dxr == None ) return;

    if( #var prefix AugSpeed(a) != None || #var prefix AugLight(a) != None || #var prefix AugHeartLung(a) != None
    || #var prefix AugIFF(a) != None || #var prefix AugDatalink(a) != None || AugNinja(a) != None )
        return;
    oldseed = dxr.SetSeed( dxr.Crc(dxr.seed $ "RandoAug " $ a.class.name ) );

    RandoLevelValues(a, min_aug_str, max_aug_str, a.Description);

    dxr.SetSeed(oldseed);
}

simulated function string DescriptionLevel(Actor act, int i, out string word)
{
    local Augmentation a;
    local float f;

    a = Augmentation(act);
    if( a == None ) {
        err("DescriptionLevel failed for aug "$act);
        return "err";
    }

    if( a.Class == class'#var prefix AugAqualung') {
        word = "Breath";
        return int(a.LevelValues[i]) $" sec";
    }
    else if( a.Class == class'#var prefix AugCombat') {
        word = "Damage";
        return int(a.LevelValues[i] * 100.0) $"%";
    }
    else if( a.Class == class'#var prefix AugBallistic' || a.Class == class'#var prefix AugEMP' || a.Class == class'#var prefix AugEnviro' || a.Class == class'#var prefix AugShield') {
        word = "Damage Reduction";
        return int( (1.0 - a.LevelValues[i]) * 100.0 ) $ "%";
    }
    else if( a.Class == class'#var prefix AugCloak' || a.Class == class'#var prefix AugRadarTrans') {
        word = "Energy Use";
        return int(a.EnergyRate * a.LevelValues[i]) $" per min";
    }
    else if( a.Class == class'#var prefix AugDefense') {
        word = "Distance";
        return int(a.LevelValues[i] / 16.0) $" ft";
    }
    else if( a.Class == class'#var prefix AugDrone') {
        word = "Values";
        return string(int(a.LevelValues[i]));
    }
    else if( a.Class == class'#var prefix AugHealing') {
        word = "Healing";
        return int(a.LevelValues[i]) $ " HP";
    }
    else if( a.Class == class'#var prefix AugMuscle') {
        word = "Strength";
        return int(a.LevelValues[i] * 100.0) $ "%";
    }
    else if( a.Class == class'#var prefix AugPower') {
        word = "Energy";
        return int(a.LevelValues[i] * 100.0) $ "%";
    }
    else if( a.Class == class'#var prefix AugSpeed' || a.Class == class'AugNinja') {
        word = "Speed";
        return int(a.LevelValues[i] * 100.0) $ "%";
    }
    else if( a.Class == class'#var prefix AugStealth') {
        word = "Noise";
        return int(a.LevelValues[i] * 100.0) $ "%";
    }
    else if( a.Class == class'#var prefix AugTarget') {
        word = "Damage";
        f = -2.0 * a.LevelValues[i] + 1.0;
        return int(f * 100.0) $ "%";
    }
    else if( a.Class == class'#var prefix AugVision') {
        word = "Distance";
        if(i<2) return "--";
        return int(a.LevelValues[i] / 16.0) $" ft";
    }
    else {
        err("DescriptionLevel failed for aug "$a);
        return "err";
    }
}

simulated function RemoveRandomAug(#var PlayerPawn  p)
{
    local Augmentation a, augs[64];
    local AugmentationManager am;
    local int numAugs, slot;

    am = p.AugmentationSystem;

    for( a = am.FirstAug; a != None; a = a.next ) {
        if( !a.bHasIt ) continue;
        if( a.CurrentLevel == 0 ) continue;

        if( #var prefix AugSpeed(a) != None || #var prefix AugLight(a) != None
            || #var prefix AugIFF(a) != None || #var prefix AugDatalink(a) != None || AugNinja(a) != None
        ) continue;

        augs[numAugs++] = a;
    }

    if( numAugs == 0 ) return;

    SetSeed( "RemoveRandomAug " $ numAugs );
    slot = rng(numAugs);
    a = augs[slot];
    info("RemoveRandomAug("$p$") Removing aug "$a$", numAugs was "$numAugs);
    am.AugLocs[a.AugmentationLocation].augCount--;
    p.RemoveAugmentationDisplay(a);
    a.Deactivate();
    a.CurrentLevel = 0;
    a.bHasIt = false;
}

defaultproperties
{
    min_aug_str=0.5
    max_aug_str=1.5
}
