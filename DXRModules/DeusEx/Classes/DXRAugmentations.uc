class DXRAugmentations extends DXRBase transient;

var config float min_aug_weaken, max_aug_str;

replication
{
    reliable if( Role==ROLE_Authority )
        min_aug_weaken, max_aug_str;
}

function CheckConfig()
{
    if( ConfigOlderThan(1,6,0,5) ) {
        min_aug_weaken = default.min_aug_weaken;
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
        if( ! chance_single(dxr.flags.settings.augcans) ) continue;
        RandomizeAugCannister(dxr, a);
    }
}

function static _DefaultAugsMask(DXRando dxr, out int banned[50], out int numAugs)
{
    local DXRLoadouts loadouts;
    local class<Augmentation> a;
    local int i;

    loadouts = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
    for(i=0; i<ArrayCount(class'#var prefix AugmentationManager'.default.augClasses); i++) {
        if( banned[i] == 1 ) continue;
        a = class'#var prefix AugmentationManager'.default.augClasses[i];
        if( a == None ) {
            banned[i] = 1;
            continue;
        }
        if( a.default.AugmentationLocation == LOC_Default ) {
            banned[i] = 1;
            continue;
        }
        if( loadouts != None ) {
            if( loadouts.StartedWithAug(a) ) {
                banned[i] = 1;
                continue;
            }
        }
        numAugs++;
    }
}

function static RandomizeAugCannister(DXRando dxr, #var prefix AugmentationCannister a)
{
    local int numAugs;
    local int banned[50];

    _DefaultAugsMask(dxr, banned, numAugs);

    a.AddAugs[0] = PickRandomAug(dxr, banned, numAugs);
    a.AddAugs[1] = PickRandomAug(dxr, banned, numAugs);

    if( a.AddAugs[0] == '#var prefix AugSpeed' || a.AddAugs[1] == '#var prefix AugSpeed' ) {
        dxr.flags.player().ClientMessage("Speed Enhancement is in this area.",, true);
    }
}

function static Name PickRandomAug(DXRando dxr, out int banned[50], out int numAugs)
{
    local int slot, i, r;
    local Name AugName;
    r = staticrng(dxr, numAugs);
    for(i=0; i < ArrayCount(class'#var prefix AugmentationManager'.default.augClasses); i++) {
        if( banned[i] == 1 ) continue;
        if( slot == r )
            break;
        slot++;
    }
    slot = i;
    if( slot >= ArrayCount(class'#var prefix AugmentationManager'.default.augClasses) )
        dxr.err("PickRandomAug WTF "$slot);
    AugName = class'#var prefix AugmentationManager'.default.augClasses[slot].Name;
    log("Picked Aug "$ slot $"/"$numAugs$" " $ AugName, 'DXRAugmentations');
    banned[slot] = 1;
    numAugs--;
    return AugName;
}

simulated function RandoAug(Augmentation a)
{
    local float aug_value_rando;
    if( dxr == None ) return;

    if( #var prefix AugSpeed(a) != None || #var prefix AugLight(a) != None || #var prefix AugHeartLung(a) != None
    || #var prefix AugIFF(a) != None || #var prefix AugDatalink(a) != None || AugNinja(a) != None )
        return;

    aug_value_rando = float(dxr.flags.settings.aug_value_rando) / 100.0;
    RandoLevelValues(a, min_aug_weaken, max_aug_str, aug_value_rando, a.Description);
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
    local Augmentation a, b, augs[64];
    local AugmentationManager am;
    local DXRLoadouts loadouts;
    local int numAugs, slot;

    am = p.AugmentationSystem;
    loadouts = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));

    for( a = am.FirstAug; a != None; a = a.next ) {
        if( !a.bHasIt ) continue;
        if( a.AugmentationLocation == LOC_Default ) continue;

        if( #var prefix AugLight(a) != None || #var prefix AugIFF(a) != None || #var prefix AugDatalink(a) != None )
            continue;

        if( loadouts != None && loadouts.StartedWithAug(a.class) )
            continue;

        augs[numAugs++] = a;
    }

    if( numAugs == 0 ) return;

    SetSeed( "RemoveRandomAug " $ numAugs );
    slot = rng(numAugs);
    a = augs[slot];
    info("RemoveRandomAug("$p$") Removing aug "$a$" from "$am$", numAugs was "$numAugs);
    a.Deactivate();
    a.CurrentLevel = 0;
    a.bHasIt = false;
    am.AugLocs[a.AugmentationLocation].augCount--;
    p.RemoveAugmentationDisplay(a);

    // walk back the hotkey numbers
    slot = am.AugLocs[a.AugmentationLocation].KeyBase + 1;
    for( b = am.FirstAug; b != None; b = b.next ) {
        if( b.bHasIt && a.AugmentationLocation == b.AugmentationLocation )
            b.HotKeyNum = slot++;
    }
}

function ExtendedTests()
{
    local int i;
    local #var prefix AugmentationCannister a;

    Super.ExtendedTests();

    a = Spawn(class'#var prefix AugmentationCannister');
    SetSeed( self );
    for(i=0;i<100;i++) {
        RandomizeAugCannister(dxr, a);
        test( a.AddAugs[0] != '', "a.AddAugs[0] == "$a.AddAugs[0] );
        test( a.AddAugs[1] != '', "a.AddAugs[1] == "$a.AddAugs[1] );
        test( a.AddAugs[0] != a.AddAugs[1], "a.AddAugs[0] == "$a.AddAugs[0]$", a.AddAugs[1] == "$a.AddAugs[1] );
    }
    a.Destroy();
}

defaultproperties
{
    min_aug_weaken=0.3
    max_aug_str=1.0
}
