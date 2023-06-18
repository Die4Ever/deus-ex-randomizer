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

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    local Augmentation a;
    Super.PlayerAnyEntry(p);
    foreach AllActors(class'Augmentation', a) {
        RandoAug(a);
    }
}

function PostFirstEntry()
{
    local TechGoggles goggles;
    local AugVision aug;
    local string goggles_desc;

    Super.PostFirstEntry();

#ifdef injections
    aug = AugVision(player().AugmentationSystem.GetAug(class'AugVision'));
    foreach AllActors(class'TechGoggles', goggles) {
        goggles.Description = class'TechGoggles'.static.CalcDescription(aug);
    }
#endif
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

static function RemoveAug(DeusExPlayer player, Augmentation aug)
{
    local int slot;
    local Augmentation b;
    local AugmentationManager am;

    am = player.AugmentationSystem;

    if (aug == None) {
       return; //Shouldn't happen
    }

    if (!aug.bHasIt)
    {
        return; //Also shouldn't happen
    }

    aug.Deactivate();
    aug.bHasIt = False;

    // Manage our AugLocs[] array
    player.AugmentationSystem.AugLocs[aug.AugmentationLocation].augCount--;

    //Icon lookup is BY HOTKEY, so make sure to remove the icon before the hotkey
    player.RemoveAugmentationDisplay(aug);

    // Assign hot key back to default
    aug.HotKeyNum = aug.Default.HotKeyNum;

    // walk back the hotkey numbers
    // This is needed for multi-slot locations like the torso.
    // Hotkeys will double up if you remove one that isn't the last hotkey
    slot = am.AugLocs[aug.AugmentationLocation].KeyBase + 1;
    for( b = am.FirstAug; b != None; b = b.next ) {
        if( b.bHasIt && aug.AugmentationLocation == b.AugmentationLocation )
            b.HotKeyNum = slot++;
    }

    // This is needed, otherwise the side-of-screen aug display gets confused
    // when you add a new aug
    am.RefreshAugDisplay();

}

function RandomizeAugCannisters()
{
    local #var(prefix)AugmentationCannister a;

    if( dxr.flagbase == None ) return;

    SetSeed( "RandomizeAugCannisters" );

    foreach AllActors(class'#var(prefix)AugmentationCannister', a)
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
    for(i=0; i<ArrayCount(class'#var(prefix)AugmentationManager'.default.augClasses); i++) {
        if( banned[i] == 1 ) continue;
        a = class'#var(prefix)AugmentationManager'.default.augClasses[i];
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

function static AddRandomAugs(DXRando dxr, DeusExPlayer p, int num)
{
    local int numAugs;
    local int banned[50];
    local int i,j;
    local class<Augmentation> augClass;
    local bool augOk;
    local Augmentation anAug;

    _DefaultAugsMask(dxr, banned, numAugs);

    for (i=0;i<num;i++)
    {
        augOk=False;
        for (j=0;j<5&&!augOk;j++){
            augClass = PickRandomAug(dxr, banned, numAugs);
            anAug = p.AugmentationSystem.FindAugmentation(augClass);
            augOk = !p.AugmentationSystem.AreSlotsFull(anAug);
        }
        if (augOk){
            AddAug(p, augClass, 1);
            log("Randomly added aug "$augClass);
        } else {
            log("Failed to find random aug to add");
        }
    }
}

function static UpgradeRandomAug(DXRando dxr, DeusExPlayer p)
{
    local class<Augmentation> augs[12];
    local int numAugs, i;
    local Augmentation anAug;
    local bool wasActive;

    numAugs = 0;
    anAug = p.AugmentationSystem.FirstAug;
    //Find all upgradable augs
    while(anAug != None)
    {
        if (anAug.bHasIt && anAug.CanBeUpgraded()){
            augs[numAugs++]=anAug.class;
        }
        anAug=anAug.next;
    }

    //Pick a random aug from the list to upgrade
    i = staticrng(dxr,numAugs);

    anAug = p.AugmentationSystem.FindAugmentation(augs[i]);

    wasActive=anAug.bIsActive;
    if (anAug.bIsActive){
        anAug.Deactivate();
    }

    anAug.CurrentLevel++;

    if(wasActive){
        anAug.Activate();
    }
}

function static RandomizeAugCannister(DXRando dxr, #var(prefix)AugmentationCannister a)
{
    local int numAugs;
    local int banned[50];
    local class<Augmentation> augs[2];

    _DefaultAugsMask(dxr, banned, numAugs);

    augs[0] = PickRandomAug(dxr, banned, numAugs);
    augs[1] = PickRandomAug(dxr, banned, numAugs);

    a.AddAugs[0] = augs[0].Name;
    a.AddAugs[1] = augs[1].Name;

    if(augs[0] != None && augs[1] != None)
        a.ItemName = a.ItemName $": "$ augs[0].default.AugmentationName $ " / " $ augs[1].default.AugmentationName;
    else if(augs[0] != None)
        a.ItemName = a.ItemName $": "$ augs[0].default.AugmentationName;
    else if(augs[1] != None)
        a.ItemName = a.ItemName $": "$ augs[1].default.AugmentationName;

    if( (a.AddAugs[0] == '#var(prefix)AugSpeed' || a.AddAugs[1] == '#var(prefix)AugSpeed') && !dxr.flags.IsReducedRando() ) {
        dxr.flags.player().ClientMessage("Speed Enhancement is in this area.",, true);
    }
}

// HX uses the regular Augmentation base class
function static class<Augmentation> PickRandomAug(DXRando dxr, out int banned[50], out int numAugs)
{
    local int slot, i, r;
    local class<Augmentation> aug;
    r = staticrng(dxr, numAugs);
    for(i=0; i < ArrayCount(class'#var(prefix)AugmentationManager'.default.augClasses); i++) {
        if( banned[i] == 1 ) continue;
        if( slot == r )
            break;
        slot++;
    }
    slot = i;
    if( slot >= ArrayCount(class'#var(prefix)AugmentationManager'.default.augClasses) )
        dxr.err("PickRandomAug WTF "$slot);
    aug = class'#var(prefix)AugmentationManager'.default.augClasses[slot];
    log("Picked Aug "$ slot $"/"$numAugs$" " $ aug.Name, 'DXRAugmentations');
    banned[slot] = 1;
    numAugs--;
    return aug;
}

simulated function RandoAug(Augmentation a)
{
    local float aug_value_wet_dry;
    local string add_desc;
    if( dxr == None ) return;

#ifdef injections
    if( #var(prefix)AugSpeed(a) != None ) {
        add_desc = "DXRando: Activating this aug instantly burns 1 energy in order to prevent abuse. ";
    }
    else if( #var(prefix)AugVision(a) != None ) {
        add_desc = "DXRando: At level 1 you can see characters and goals. At level 2 you can also see items, datacubes, vehicles, crates, and electronic devices. ";
    }
    else if( #var(prefix)AugLight(a) != None ) {
        add_desc = "DXRando: The light is much brighter and doesn't use any energy. ";
    }
#endif

    if( add_desc != "" && InStr(a.Description, add_desc) == -1 ) {
        a.Description = add_desc $ "|n|n" $ a.Description;
    }

    if( #var(prefix)AugSpeed(a) != None || #var(prefix)AugLight(a) != None || #var(prefix)AugHeartLung(a) != None
    || #var(prefix)AugIFF(a) != None || #var(prefix)AugDatalink(a) != None || AugNinja(a) != None )
        return;

    aug_value_wet_dry = float(dxr.flags.settings.aug_value_rando) / 100.0;
    if((#var(prefix)AugVision(a) != None || #var(prefix)AugMuscle(a) != None) && aug_value_wet_dry > 0) {
        // don't randomize vision aug strength and instead randomize its energy usage
        // so it can be used for speedrun strategies with specific spots to check from
        // aug muscle picking up heavy items is confusing when the strength is randomized, just randomize the energy cost
        a.energyRate = int(rngrange(a.default.energyRate, 0.5, 1.5));
        aug_value_wet_dry = 0;
        add_desc = add_desc $ "Energy Rate: "$int(a.energyRate)$" Units/Minute";
    }
    RandoLevelValues(a, min_aug_weaken, max_aug_str, aug_value_wet_dry, a.Description, add_desc);
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

    if( a.Class == class'#var(prefix)AugAqualung') {
        word = "Breath";
        return int(a.LevelValues[i]) $" sec";
    }
    else if( a.Class == class'#var(prefix)AugCombat'
#ifdef gmdx
    || a.Class == class'AugCombatStrength'
#endif
    ) {
        word = "Damage";
        return int(a.LevelValues[i] * 100.0) $"%";
    }
    else if( a.Class == class'#var(prefix)AugBallistic' || a.Class == class'#var(prefix)AugEMP' || a.Class == class'#var(prefix)AugEnviro' || a.Class == class'#var(prefix)AugShield') {
        word = "Damage Reduction";
        return int( (1.0 - a.LevelValues[i]) * 100.0 ) $ "%";
    }
    else if( a.Class == class'#var(prefix)AugCloak' || a.Class == class'#var(prefix)AugRadarTrans') {
        word = "Energy Use";
        return int(a.EnergyRate * a.LevelValues[i]) $" per min";
    }
    else if( a.Class == class'#var(prefix)AugDefense') {
        word = "Distance";
        return int(a.LevelValues[i] / 16.0) $" ft";
    }
    else if( a.Class == class'#var(prefix)AugDrone') {
        // TODO: improve description
        word = "Values";
        return string(int(a.LevelValues[i]));
    }
    else if( a.Class == class'#var(prefix)AugHealing') {
        if(#defined(injections)) word = "Max Health Cap";
        else word = "Healing";
        return int(a.LevelValues[i]) $ " HP";
    }
    else if( a.Class == class'#var(prefix)AugMuscle') {
        word = "Strength";
        return int(a.LevelValues[i] * 100.0) $ "%";
    }
    else if( a.Class == class'#var(prefix)AugPower') {
        word = "Energy";
        return int(a.LevelValues[i] * 100.0) $ "%";
    }
    else if( a.Class == class'#var(prefix)AugSpeed' || a.Class == class'AugNinja') {
        word = "Speed";
        return int(a.LevelValues[i] * 100.0) $ "%";
    }
    else if( a.Class == class'#var(prefix)AugStealth') {
        if(#defined(vmd175)) {
            word = "Energy Cost Per Minute";
            return string(int(a.energyRate * a.LevelValues[i] + 0.5));
        }
        word = "Noise";
        return int(a.LevelValues[i] * 100.0) $ "%";
    }
    else if( a.Class == class'#var(prefix)AugTarget') {
        word = "Damage";
        f = -2.0 * a.LevelValues[i] + 1.0;
        return int(f * 100.0) $ "%";
    }
    else if( a.Class == class'#var(prefix)AugVision') {
        word = "See-through walls distance";
        if(!#defined(balance) && i<2) return "--";
        if(a.LevelValues[i] < 0)
            a.LevelValues[i] = 0;
        return int(a.LevelValues[i] / 16.0) $" ft";
    }

#ifdef gmdx
    else if( a.Class == class'AugBallisticPassive') {
        word = "Damage Reduction";
        return int( (1.0 - a.LevelValues[i]) * 100.0 ) $ "%";
    }
    else if( a.Class == class'AugIcarus' || a.Class == class'AugEnergyTransfer' || a.Class.Name == 'AugMetabolism' || a.Class.Name == 'AugAimbot' ) {
        // TODO: improve description
        word = "Values";
        return string(a.LevelValues[i]);
    }
    else if( a.Class.Name == 'AugAmmoCap' ) {
        word = "Ammo Cap";
        f = a.LevelValues[i]*100.0;
        return "+" $ string(int(f)) $ "%";
    }
#endif

#ifdef revision
    // TODO: actual descriptions
    else if(
        a.Class.Name == 'AugAimbot'
        || a.Class.Name == 'AugLeech'
        || a.Class.Name == 'AugRadiation'
        || a.Class.Name == 'AugAutoCounter'
        || a.Class.Name == 'AugDefenseNPC'
        || a.Class.Name == 'AugDefenseHeli'
    ) {
        word = "% of Normal";
        f = a.LevelValues[i] / a.default.LevelValues[i];
        return int(f * 100.0) $ "%";
    }
#endif

    else {
        return Super.DescriptionLevel(act, i, word);
    }
}

simulated function RemoveRandomAug(#var(PlayerPawn) p)
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

        if( #var(prefix)AugLight(a) != None || #var(prefix)AugIFF(a) != None || #var(prefix)AugDatalink(a) != None )
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
    RemoveAug(p,a);
}

function ExtendedTests()
{
    local int i;
    local #var(prefix)AugmentationCannister a;

    Super.ExtendedTests();

    a = Spawn(class'#var(prefix)AugmentationCannister');
    SetSeed( self );
    for(i=0;i<50;i++) {
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
