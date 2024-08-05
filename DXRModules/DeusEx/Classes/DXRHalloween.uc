class DXRHalloween extends DXRActorsBase;

var #var(DeusExPrefix)Carcass carcs[256];
var float times[256];
var int num_carcs;

function FirstEntry()
{
    local #var(prefix)WHPiano piano;
    Super.FirstEntry();

    if(dxr.flags.IsHalloweenMode()) {
        // Mr. X is only for the Halloween game mode, but other things will instead be controlled by IsOctober(), such as cosmetic changes
        class'MrX'.static.Create(self);
    }
    if(IsOctober()) {
        foreach AllActors(class'#var(prefix)WHPiano', piano) {
            piano.ItemName = "Staufway Piano";
        }
    }
}

function ReEntry(bool IsTravel)
{
    if(IsTravel && dxr.flags.IsHalloweenMode()) {
        // recreate him if you leave the map and come back, but not if you load a save
        class'MrX'.static.Create(self);
    }
}

function AnyEntry()
{
    Super.AnyEntry();
    if(dxr.flags.IsHalloweenMode()) {
        SetTimer(1.0, true);
    }
}

function Timer()
{
    Super.Timer();
    if( dxr == None ) return;
    if(dxr.flags.IsHalloweenMode()) {
        CheckCarcasses();
    }
}

function CheckCarcasses()
{
    local int i;
    local #var(DeusExPrefix)Carcass carc;

    for(i=0; i < num_carcs; i++) {
        if(CheckResurrectCorpse(carcs[i], times[i])) {
            // compress the array
            num_carcs--;
            carcs[i] = carcs[num_carcs];
            times[i] = times[num_carcs];
            i--;// repeat this iteration
            continue;
        }
    }

    foreach AllActors(class'#var(DeusExPrefix)Carcass', carc) {
        for(i=0; i < num_carcs; i++) {
            if(carcs[i] == carc) {
                break;
            }
        }
        if(carcs[i] != carc) {
            carcs[num_carcs] = carc;
            times[num_carcs] = Level.TimeSeconds;
            num_carcs++;
        }
    }
}

function bool CheckResurrectCorpse(#var(DeusExPrefix)Carcass carc, float time)
{
    local float ZombieTime;

    // return true to compress the array
    if(carc == None) return true;

    ZombieTime = 20;
    if(#var(prefix)MuttCarcass(carc) != None || #var(prefix)DobermanCarcass(carc) != None) {
        // special sauce for dogs?
        ZombieTime = 2;
    }

    // wait for Zombie Time!
    if(time + ZombieTime > Level.TimeSeconds) return false;

    return ResurrectCorpse(self, carc);
}

static function bool ResurrectCorpse(DXRActorsBase module, #var(DeusExPrefix)Carcass carc, optional String pawnname)
{
    local string livingClassName;
    local class<Actor> livingClass;
    local vector respawnLoc;
    local ScriptedPawn sp,otherSP;
    local int i;
    local Inventory item, nextItem;
    local bool removeItem;

    //At least in vanilla, all carcasses are the original class name + Carcass
    livingClassName = string(carc.class.Name);
    livingClassName = module.ReplaceText(livingClassName,"Carcass","");

    livingClass = module.GetClassFromString(livingClassName,class'ScriptedPawn');

    if (livingClass==None){
        module.warning("ResurrectCorpse " $ carc $ " failed livingClass==None");
        return False;
    }

    respawnLoc = carc.Location;
    respawnLoc.Z += livingClass.Default.CollisionHeight;

    sp = ScriptedPawn(carc.Spawn(livingClass,,,respawnLoc,carc.Rotation));

    if (sp==None){
        module.warning("ResurrectCorpse " $ carc $ " failed sp==None");
        return False;
    }

    if(pawnname != "") {
        sp.FamiliarName = pawnname;
        sp.UnfamiliarName = sp.FamiliarName;
    } else {
        sp.FamiliarName = sp.FamiliarName $ " Zombie";
        sp.UnfamiliarName = sp.FamiliarName;
    }
    sp.bInvincible = false; // If they died, they can't have been invincible
    sp.bImportant = false; // already marked as dead, don't overwrite or destroy on travel
    sp.BindName = "";// Zombies don't talk
    sp.BarkBindName = "";

    //Clear out initial inventory (since that should all be in the carcass, except for native attacks)
    for (i=0;i<ArrayCount(sp.InitialInventory);i++){
        if(ClassIsChildOf(sp.InitialInventory[i].Inventory,class'#var(prefix)WeaponNPCMelee') ||
           ClassIsChildOf(sp.InitialInventory[i].Inventory,class'#var(prefix)WeaponNPCRanged')){
            continue;
        }
        switch(sp.InitialInventory[i].Inventory.Default.Mesh){
            case LodMesh'DeusExItems.InvisibleWeapon':
            case LodMesh'DeusExItems.TestBox':
            case None:
                break; //NPC weapons and NPC weapon ammo
            default:
                sp.InitialInventory[i].Inventory=None;
        }
    }

    sp.InitializePawn();

    //Make it hostile to EVERYONE.  This thing has seen the other side
    sp.SetAlliance('Resurrected');
    sp.ChangeAlly('Player',-1,True);
    foreach sp.AllActors(class'ScriptedPawn',otherSP){
        sp.ChangeAlly(otherSP.Alliance,-1,True);
    }

    module.RemoveFears(sp);
    sp.MinHealth = 0;
    sp.ResetReactions();

    //Transfer inventory from carcass back to the pawn
    item = carc.Inventory;
    do
    {
        item = carc.Inventory;
        nextItem = item.Inventory;
        carc.DeleteInventory(item);
        if (DeusExWeapon(item) != None) {// Zombies don't use weapons
            if(DeusExWeapon(item).bNativeAttack) {
                item.Destroy();
            } else {
                module.ThrowItem(item, 0.1);
            }
        }
        else {
            sp.AddInventory(item);
        }
        item = nextItem;
    }
    until (item == None);

    //Give the resurrect guy a zombie swipe (a guaranteed melee weapon)
    module.GiveItem(sp,class'WeaponZombieSwipe');
    sp.bKeepWeaponDrawn=True;

    //Pop out a little meat for fun
    for (i=0; i<10; i++)
    {
        if (FRand() > 0.2)
            carc.spawn(class'FleshFragment',,,carc.Location);
    }

    carc.Destroy();

    return True;
}
