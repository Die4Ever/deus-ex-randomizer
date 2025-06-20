class DXRAugmentations extends DXRBase transient;

var float min_aug_weaken, max_aug_str;

replication
{
    reliable if( Role==ROLE_Authority )
        min_aug_weaken, max_aug_str;
}

function FirstEntry()
{
    Super.FirstEntry();

    RandomizeAugCannisters();
}

function AnyEntry()
{
    Super.AnyEntry();

    RandoAllAugs();
}

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    Super.PlayerAnyEntry(p);

    CreateAugmentations(p);
    RandoAllAugs();
}

simulated function CreateAugmentations(#var(PlayerPawn) p)
{
    local DXRLoadouts loadouts;
    local int numAugs, i, matched[50];
    local Augmentation anAug;
    local Augmentation LastAug;
    local AugmentationManager augman;
    local class<Augmentation> augs[50];

    loadouts = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
    if(loadouts == None) return;
    for(i=0; i<ArrayCount(augs); i++) {
        augs[numAugs] = loadouts.GetExtraAug(i);
        if(augs[numAugs] != None) numAugs++;
    }

    augman = p.AugmentationSystem;
    for(LastAug = augman.FirstAug; LastAug.next != None; LastAug = LastAug.next) {
        for(i=0; i<numAugs; i++) {
            if(LastAug.class == augs[i]) {
                matched[i] = 1;
                break;
            }
        }
    }

    for(i=0; i<numAugs; i++) {
        if(matched[i] == 1) continue;

        anAug = Spawn(augs[i], augman);
        anAug.Player = p;

        if (anAug == None) continue;

        if (augman.FirstAug == None) {
            augman.FirstAug = anAug;
        } else {
            LastAug.next = anAug;
        }

        LastAug  = anAug;
    }
}

simulated function RandoAllAugs()
{
    local Augmentation a;

    foreach AllActors(class'Augmentation', a) {
        RandoAug(a);
    }

    CleanUpAugCounts(player()); //Recount the number of augs in each slot
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
    // Deactivate() skips bAlwaysActive augs
    aug.bIsActive = false;
    if(aug.IsInState('Active')) {
        aug.GotoState('Inactive');
    }
    aug.bHasIt = False;
    aug.CurrentLevel=0;

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

static function RedrawAugMenu(DeusExPlayer player)
{
#ifdef injections
    local #var(injectsprefix)PersonaScreenAugmentations augScreen;

    if (DeusExRootWindow(player.rootWindow)==None) return;

    augScreen = #var(injectsprefix)PersonaScreenAugmentations(DeusExRootWindow(player.rootWindow).GetTopWindow());
    if (augScreen==None) return;

    augScreen.RedrawAugmentations();
#endif
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

function static _DefaultAugsMask(DXRando dxr, out class<Augmentation> allowed[50], out int numAugs)
{
    local DXRLoadouts loadouts;
    local class<Augmentation> a;
    local int i, k;
    local bool exists;

    numAugs = 0;
    loadouts = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
    for(i=0; i<ArrayCount(class'#var(prefix)AugmentationManager'.default.augClasses); i++) {
        a = class'#var(prefix)AugmentationManager'.default.augClasses[i];
        if( a == None ) {
            continue;
        }
        if( a.default.AugmentationLocation == LOC_Default ) {
            continue;
        }
        if( loadouts != None ) {
            if(loadouts.IsAugBanned(a)) {
                continue;
            }
        }
        allowed[numAugs++] = a;
    }
    if(loadouts != None) {
        for(i=0; true; i++) {
            a = loadouts.GetExtraAug(i);
            if(a==None) break;
            exists = false;
            for(k=0; k<numAugs; k++) {
                if(allowed[k] == a) {
                    exists = true;
                    break;
                }
            }
            if(exists) continue;
            allowed[numAugs++] = a;
        }
    }
}

function static AddRandomAugs(DXRando dxr, DeusExPlayer p, int num)
{
    local int numAugs;
    local class<Augmentation> allowed[50];
    local int i,j;
    local class<Augmentation> augClass;
    local bool augOk;
    local Augmentation anAug;

    _DefaultAugsMask(dxr, allowed, numAugs);

    for (i=0;i<num;i++)
    {
        augOk=False;
        for (j=0;j<5&&!augOk;j++){
            augClass = PickRandomAug(dxr, allowed, numAugs);
            anAug = p.AugmentationSystem.FindAugmentation(augClass);
            augOk = !p.AugmentationSystem.AreSlotsFull(anAug);
        }
        if (augOk){
            AddAug(p, augClass, 1);
            dxr.l("Randomly added aug "$augClass);
        } else {
            dxr.l("Failed to find random aug to add");
        }
    }
}

function static class<Augmentation> GetRandomAug(DXRando dxr)
{
    local int numAugs;
    local class<Augmentation> allowed[50];

    _DefaultAugsMask(dxr, allowed, numAugs);
    return PickRandomAug(dxr, allowed, numAugs);
}

function static bool AugCanBeUpgraded(Augmentation anAug)
{
    return anAug.bHasIt && anAug.CurrentLevel < anAug.MaxLevel;
}

function static UpgradeAug(Augmentation anAug)
{
    local bool wasActive;

    if (!AugCanBeUpgraded(anAug)){
        return;
    }

    wasActive=anAug.bIsActive;

    anAug.CurrentLevel++;

    if(wasActive){
    #ifdef injections
        anAug.Reset();
    #else
        anAug.Deactivate();
        anAug.Activate();
    #endif
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
        if (AugCanBeUpgraded(anAug)){
            augs[numAugs++]=anAug.class;
        }
        anAug=anAug.next;
    }

    //Pick a random aug from the list to upgrade
    i = staticrng(dxr,numAugs);

    anAug = p.AugmentationSystem.FindAugmentation(augs[i]);

    UpgradeAug(anAug);
}

function static RandomizeAugCannister(DXRando dxr, #var(prefix)AugmentationCannister a)
{
    local int numAugs;
    local class<Augmentation> allowed[50];
    local class<Augmentation> augs[2];

    _DefaultAugsMask(dxr, allowed, numAugs);

    augs[0] = PickRandomAug(dxr, allowed, numAugs);
    augs[1] = PickRandomAug(dxr, allowed, numAugs);

    a.AddAugs[0] = augs[0].Name;
    a.AddAugs[1] = augs[1].Name;
}

// HX uses the regular Augmentation base class
function static class<Augmentation> PickRandomAug(DXRando dxr, out class<Augmentation> allowed[50], out int numAugs)
{
    local int slot, i, r;
    local class<Augmentation> aug;
    r = staticrng(dxr, numAugs);
    for(i=0; i < ArrayCount(allowed); i++) {
        if( allowed[i] == None ) continue;
        if( slot == r )
            break;
        slot++;
    }
    slot = i;
    if( slot >= ArrayCount(allowed) )
        dxr.err("PickRandomAug failed "$slot);
    aug = allowed[slot];
    dxr.l("Picked Aug "$ slot $"/"$numAugs$" " $ aug.Name);
    allowed[slot] = None;
    numAugs--;
    return aug;
}

//Weighted to match the number of slots per location
simulated function PickRandomAugLocation(Augmentation a)
{
    switch (rng(9)){
        case 0:
            a.AugmentationLocation = LOC_Cranial;
            break;
        case 1:
            a.AugmentationLocation = LOC_Eye;
            break;
        case 2:
        case 3:
        case 4:
            a.AugmentationLocation = LOC_Torso;
            break;
        case 5:
            a.AugmentationLocation = LOC_Arm;
            break;
        case 6:
             a.AugmentationLocation = LOC_Leg;
             break;
        case 7:
        case 8:
            a.AugmentationLocation = LOC_Subdermal;
            break;
    }
}

simulated function RandoAug(Augmentation a)
{
    local float aug_value_wet_dry;
    local string add_desc;
    if( dxr == None ) return;

#ifdef vanilla
    a.SetAutomatic();// fixes descriptions/balance now that we have loaded flags
#endif

    SetGlobalSeed("RandoAugLoc " $ a.class.name);
    if (a.AugmentationLocation!=LOC_Default && chance_single(dxr.flags.moresettings.aug_loc_rando)){
        PickRandomAugLocation(a);
    } else {
        //Make sure it's set to the default location if not randomizing
        //(This allows it to revert in a later loop)
        a.AugmentationLocation = a.Default.AugmentationLocation;
    }

#ifdef injections
    if(a.activationCost >= 1) {
        add_desc = "DXRando: Activating this aug instantly burns " $ int(a.activationCost) $ " energy in order to prevent abuse. ";
    }
    else if( a.class==class'#var(prefix)AugVision' && class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        add_desc = "DXRando: You can see characters, goals, items, datacubes, vehicles, crates, and electronic devices through walls. ";
    }
    else if( #var(prefix)AugLight(a) != None && class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        if(!class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
            // don't change it
        } else if(dxr.flags.IsHalloweenMode()) {
            add_desc = "DXRando: The light costs more energy in Halloween modes. Can be upgraded to level 2 which costs no energy and is brighter. ";
        } else {
            if(a.CurrentLevel<1) {
                a.CurrentLevel = 1;
                a.PostPostBeginPlay();
            }
            add_desc = "DXRando: The light is much brighter and doesn't use any energy. ";
        }
    }
    else if( #var(prefix)AugAqualung(a) != None ) {
        return;
    }
#endif

    if( add_desc != "" && InStr(a.Description, add_desc) == -1 ) {
        a.Description = add_desc $ "|n|n" $ a.Description;
    }

    if(#var(prefix)AugLight(a) != None || #var(prefix)AugIFF(a) != None || #var(prefix)AugDatalink(a) != None )
        return; // default augs

    aug_value_wet_dry = float(dxr.flags.settings.aug_value_rando) / 100.0;
    if(( aug_value_wet_dry > 0
        && ( #var(prefix)AugVision(a) != None || #var(prefix)AugMuscle(a) != None)
        || (#var(prefix)AugHeartLung(a) != None && !#defined(injections)) )
    ) {
        // don't randomize vision aug strength and instead randomize its energy usage
        // so it can be used for speedrun strategies with specific spots to check from
        // aug muscle picking up heavy items is confusing when the strength is randomized, just randomize the energy cost
        // synth heart in non-vanilla, can't randomize its strength, just randomize energy cost
        SetGlobalSeed("RandoAug " $ a.class.name);
        a.energyRate = int(rngrange(a.default.energyRate, 0.5, 1.5));
        aug_value_wet_dry = 0;
        add_desc = add_desc $ "Energy Rate: "$int(a.energyRate)$" Units/Minute";
    }

    if(dxr.flags.IsStrongAugsMode()) {
        RandoLevelValues(a, -2, 3, aug_value_wet_dry, a.Description, add_desc);
    } else {
        if(#var(prefix)AugSpeed(a) != None || AugNinja(a) != None || AugOnlySpeed(a) != None || AugJump(a) != None) {
            aug_value_wet_dry = 0;
        }
        RandoLevelValues(a, min_aug_weaken, max_aug_str, aug_value_wet_dry, a.Description, add_desc);
    }
}

static simulated function string DescriptionLevelExtended(Actor act, int i, out string word, out float val, float defaultval, out string shortDisplay)
{
    local Augmentation a;
    local float f, speed, dmg, blastRad;
    local string r;

    if(val==-1) { // -1 is reserved for no aug
        if(val < defaultval) val=-1.01;
        else val=0.99;
    }

    a = Augmentation(act);
    if( a == None ) {
        log("ERROR: DescriptionLevel failed for aug "$act);
        shortDisplay = "err";
        return shortDisplay;
    }

    if( a.Class == class'#var(prefix)AugAqualung') {
        word = "Breath";
        shortDisplay=int(val) $" sec";
        return shortDisplay;
    }
    else if( a.Class == class'#var(prefix)AugCombat'
#ifdef gmdx
    || a.Class == class'AugCombatStrength'
#endif
    ) {
        word = "Damage";
        shortDisplay = int(val * 100.0) $"%";
        return shortDisplay;
    }
    else if( a.Class == class'#var(prefix)AugBallistic' || a.Class == class'#var(prefix)AugEMP' || a.Class == class'#var(prefix)AugEnviro' || a.Class == class'#var(prefix)AugShield') {
        word = "Damage Reduction";
        if(#defined(injections) && #var(prefix)AugEMP(a)!=None && i==3) val = 0; // max level always 0%
        if(val < 0) {
            val = 0;
        }
        shortDisplay=int( (1.0 - val) * 100.0 ) $ "%";
        return shortDisplay;
    }
    else if( a.Class == class'#var(prefix)AugCloak' || a.Class == class'#var(prefix)AugRadarTrans') {
        word = "Energy Use";
        shortDisplay=int(a.EnergyRate * val) $"/min"; //Slightly shorter display
        return int(a.EnergyRate * val) $" per min";
    }
    else if( a.Class == class'#var(prefix)AugDefense') {
        word = "Distance";
        shortDisplay=int(class'DXRActorsBase'.static.GetRealDistance(val)) @ class'DXRActorsBase'.static.GetDistanceUnit();
        return shortDisplay;
    }
    else if( a.Class == class'#var(prefix)AugDrone') {
        word = "Drone Stats:|n            Speed / Damage / Blast Radius";

        f = val;

        switch(i) {
        case 0: r =       "Level 1:  "; break;
        case 1: r = "|n    Level 2: "; break;
        case 2: r = "|n    Level 3: "; break;
        case 3: r = "|n    Level 4: "; break;
        }

        if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
            //Keep in line with BalancePlayer::SetDroneStats()
            speed = 5 * val;
            dmg = 2 * val;
            blastRad = 4 * val;
        } else {
            speed = 3 * val;
            dmg = 5 * val;
            blastRad = 8 * val;
        }
        speed = class'DXRActorsBase'.static.GetRealSpeed(speed, false);
        blastRad = class'DXRActorsBase'.static.GetRealDistance(blastRad);

        r = r $ int(speed) @ class'DXRActorsBase'.static.GetSpeedUnit(false);
        r = r $ " / ";
        r = r $ int(dmg);
        r = r $ " / ";
        r = r $ int(blastRad) @ class'DXRActorsBase'.static.GetDistanceUnit();

        shortDisplay=string(int(dmg)); //Show damage as the short value
        return r;
    }
    else if( a.Class == class'#var(prefix)AugHealing') {
        if(#defined(injections)) word = "Max Health Cap";
        if(#defined(injections) && val > 100 && val > class'DXRando'.default.dxr.flags.settings.health) {
            val = FMax(100, class'DXRando'.default.dxr.flags.settings.health);
        }
        else word = "Healing";
        shortDisplay=int(val) $ " HP";
        return shortDisplay;
    }
    else if( a.Class == class'#var(prefix)AugMuscle') {
        word = "Strength";
        shortDisplay=int(val * 100.0) $ "%";
        return shortDisplay;
    }
    else if( a.Class == class'#var(prefix)AugPower' || (a.Class == class'#var(prefix)AugHeartLung' && #defined(injections))) {
        word = "Energy";
        shortDisplay=int(val * 100.0) $ "%";
        return shortDisplay;
    }
    else if( a.Class == class'#var(prefix)AugSpeed' || a.Class == class'AugNinja' || a.Class == class'AugOnlySpeed') {
        word = "Speed";
        shortDisplay=int(val * 100.0) $ "%";
        return shortDisplay;
    }
    else if( a.Class == class'AugJump') {
        word = "Jump Height";
        shortDisplay=int(val * 100.0) $ "%";
        return shortDisplay;
    }
    else if( a.Class == class'#var(prefix)AugStealth') {
        if(#defined(vmd175)) {
            word = "Energy Cost Per Minute";
            shortDisplay=string(int(a.energyRate * val + 0.5));
            return shortDisplay;
        }
        if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
            word = "Speed";
        } else {
            word = "Noise";
            val = FMax(val, 0);
            if(#defined(injections) && i==3) val = 0; // max level always 0% noise
        }
        shortDisplay=int(val * 100.0) $ "%";
        return shortDisplay;
    }
    else if( a.Class == class'#var(prefix)AugTarget') {
        word = "Damage";
        f = -2.0 * val + 1.0;
        shortDisplay=int(f * 100.0) $ "%";
        return shortDisplay;
    }
    else if(#var(prefix)AugVision(a) != None) { // allow subclasses
        word = "See-through walls distance";
        if(!#defined(balance) && i<2) return "--";
        if(val < 0)
            val = 0;
        shortDisplay=int(class'DXRActorsBase'.static.GetRealDistance(val)) @ class'DXRActorsBase'.static.GetDistanceUnit();
        return shortDisplay;
    }
    else if( a.Class == class'#var(prefix)AugHeartLung') {
        word = "Energy Usage";
        shortDisplay=Max(int(val * 100.0), 0) $ "%";
        return shortDisplay;
    }
    else if( a.Class == class'#var(prefix)AugLight') {
        word = "";
        shortDisplay = "";
        return "";
    }

#ifdef gmdx
    else if( a.Class == class'AugBallisticPassive') {
        word = "Damage Reduction";
        if(val < 0) {
            val = 0;
        }
        shortDisplay=int( (1.0 - val) * 100.0 ) $ "%";
        return shortDisplay;
    }
    else if( a.Class == class'AugIcarus' || a.Class == class'AugEnergyTransfer' || a.Class.Name == 'AugMetabolism' || a.Class.Name == 'AugAimbot' ) {
        // TODO: improve description
        word = "Values";
        shortDisplay=string(val);
        return shortDisplay;
    }
    else if( a.Class.Name == 'AugAmmoCap' ) {
        word = "Ammo Cap";
        f = val*100.0;
        shortDisplay="+" $ string(int(f)) $ "%";
        return shortDisplay;
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
        word = "Values";
        shortDisplay=string(val);
        return shortDisplay;
    }
#endif

    else {
        return Super.DescriptionLevelExtended(act, i, word, val, defaultval, shortDisplay);
    }
}

simulated function CleanUpAugCounts(#var(PlayerPawn) p)
{
    local int i;
    local Augmentation a;
    local AugmentationManager am;

    am = p.AugmentationSystem;

    //Clear out the existing augCounts in each slot, since the slots were randomized...
    for (i=0;i<ArrayCount(am.AugLocs);i++){
        am.AugLocs[i].augCount=0;
    }

    //Recount the official augCount per aug slot
    for (a=am.FirstAug; a!=None; a = a.next ) {
        if (!a.bHasIt) continue;
        am.AugLocs[a.AugmentationLocation].augCount++;
    }
}

simulated function int CleanUpAugSlots(#var(PlayerPawn) p)
{
    local int numAugs[7]; //Count of the number of augs in each slot
    local int augsRemoved, i, j;
    local Augmentation a;
    local AugmentationManager am;

    am = p.AugmentationSystem;

    //Get a count of how many augs you have in each slot
    for (a=am.FirstAug; a!=None; a = a.next ) {
        if (!a.bHasIt) continue;
        if (a.AugmentationLocation == LOC_Default) continue;
        numAugs[a.AugmentationLocation]++;
    }

    //Determine how many augs need to be removed from each slot
    for (i=0;i<ArrayCount(numAugs);i++){
        numAugs[i] = Max(numAugs[i]-am.AugLocs[i].NumSlots,0);
        for (j=0;j<numAugs[i];j++){
            RemoveRandomAug(p,true,i);
            augsRemoved++;
        }
    }

    return augsRemoved;

}

static simulated function FixAugHotkeys(PlayerPawn player, bool verbose)
{
    local AugmentationManager am;
    local int hotkeynums[7], loc;
    local Augmentation a;
    local #var(PlayerPawn) p;

    p = #var(PlayerPawn)(player);

    am = p.AugmentationSystem;
    for(loc=0; loc<ArrayCount(am.AugLocs); loc++) {
        hotkeynums[loc] = am.AugLocs[loc].KeyBase + 1;
    }
    for( a = am.FirstAug; a != None; a = a.next ) {
        if( !a.bHasIt ) continue;
        loc = a.AugmentationLocation;
        if( a.AugmentationLocation == LOC_Default ) continue;
        if (verbose){
            p.ClientMessage(a.AugmentationName$" will bind to F"$hotkeynums[loc]);
        }
        a.HotKeyNum = hotkeynums[loc]++;
    }

    am.RefreshAugDisplay();
}

simulated function RemoveRandomAug(#var(PlayerPawn) p, optional bool singleSlot, optional byte slotToRemove)
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
        if (singleSlot && a.AugmentationLocation!=slotToRemove) continue;

        if( #var(prefix)AugLight(a) != None || #var(prefix)AugIFF(a) != None || #var(prefix)AugDatalink(a) != None )
            continue;

        if( loadouts != None && loadouts.StartedWithAug(a.class) )
            continue;

        augs[numAugs++] = a;
    }

    if( numAugs == 0 ) return;

    SetGlobalSeed( "RemoveRandomAug " $ numAugs );
    slot = rng(numAugs);
    a = augs[slot];
    info("RemoveRandomAug("$p$") Removing aug "$a$" from "$am$", numAugs was "$numAugs);
    RemoveAug(p,a);
}

function ExtendedTests()
{
    local int i;
    local #var(prefix)AugmentationCannister a;
    local AugmentationManager augman;
    local Augmentation aug;
    local bool found0, found1;

    Super.ExtendedTests();

    augman = player().AugmentationSystem;
    a = Spawn(class'#var(prefix)AugmentationCannister');
    SetSeed( self );
    for(i=0;i<100;i++) {
        RandomizeAugCannister(dxr, a);
        test( a.AddAugs[0] != '', "a.AddAugs[0] == "$a.AddAugs[0] );
        test( a.AddAugs[1] != '', "a.AddAugs[1] == "$a.AddAugs[1] );
        test( a.AddAugs[0] != a.AddAugs[1], "a.AddAugs[0] == "$a.AddAugs[0]$", a.AddAugs[1] == "$a.AddAugs[1] );

        found0 = false;
        found1 = false;
        for(aug=augman.FirstAug; aug!=None; aug=aug.next) {
            if(aug.class.name == a.AddAugs[0]) found0 = true;
            if(aug.class.name == a.AddAugs[1]) found1 = true;
        }
        test(found0, "found a.AddAugs[0] " $ a.AddAugs[0]);
        test(found1, "found a.AddAugs[1] " $ a.AddAugs[1]);
    }
    a.Destroy();
}

defaultproperties
{
    min_aug_weaken=0.3
    max_aug_str=1.0
}
