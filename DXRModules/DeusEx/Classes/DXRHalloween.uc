class DXRHalloween extends DXRActorsBase transient;

function FirstEntry()
{
    Super.FirstEntry();

    if(dxr.flags.IsHalloweenMode()) {
        // Mr. X is only for the Halloween game mode, but other things will instead be controlled by IsOctober(), such as cosmetic changes
        class'MrX'.static.Create(self);
    }
}

function ReEntry(bool IsTravel)
{
    if(IsTravel && dxr.flags.IsHalloweenMode()) {
        // recreate him if you leave the map and come back, but not if you load a save
        class'MrX'.static.Create(self);
    }
}

static function bool ResurrectCorpse(DXRActorsBase module, DeusExCarcass carc, optional String pawnname)
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
        return False;
    }

    respawnLoc = carc.Location;
    respawnLoc.Z +=livingClass.Default.CollisionHeight;

    sp = ScriptedPawn(carc.Spawn(livingClass,,,respawnLoc,carc.Rotation));

    if (sp==None){
        return False;
    }

    if(pawnname != "") {
        sp.FamiliarName = pawnname;
        sp.UnfamiliarName = sp.FamiliarName;
    } else {
        sp.FamiliarName = sp.FamiliarName $ " Zombie";
        sp.UnfamiliarName = sp.FamiliarName;
    }
    sp.bInvincible = False; //If they died, they can't have been invincible

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
    sp.ResetReactions();

    //Transfer inventory from carcass back to the pawn
    if (carc.Inventory!=None){
        do
        {
            item = carc.Inventory;
            nextItem = item.Inventory;
            carc.DeleteInventory(item);
            if ((DeusExWeapon(item) != None) && (DeusExWeapon(item).bNativeAttack))
                item.Destroy();
            else
                sp.AddInventory(item);
            item = nextItem;
        }
        until (item == None);
    }
    sp.bKeepWeaponDrawn=True;

    //Give the resurrect guy a zombie swipe (a guaranteed melee weapon)
    module.GiveItem(sp,class'WeaponZombieSwipe');

    //Pop out a little meat for fun
    for (i=0; i<10; i++)
    {
        if (FRand() > 0.2)
            carc.spawn(class'FleshFragment',,,carc.Location);
    }

    carc.Destroy();

    return True;
}
