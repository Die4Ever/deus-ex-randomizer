class DXRPlayer injects Human;
//class DXRPlayer shims DeusExPlayer;

var DXRando dxr;
var DXRLoadouts loadout;
var bool bOnLadder;
var transient string nextMap;
var laserEmitter aimLaser;
var bool bDoomMode;
var bool bAutorun;
var float autorunTime;
var bool bBlockAnimations;
var transient bool bUpgradeAugs;

var Rotator ShakeRotator;

var travel int LastBrowsedAugPage, LastBrowsedAug; //OAT, 1/12/24: By popular demand.

function ClientMessage(coerce string msg, optional Name type, optional bool bBeep)
{
    local DXRStats stats;
    local string timer;

    // HACK: 2 spaces because destroyed item pickups do ClientMessage( Item.PickupMessage @ Item.itemArticle @ Item.ItemName, 'Pickup' );
    if( msg == "  " ) return;

    if(type != 'ERROR') { // don't need to log errors twice
        stats = DXRStats(DXRFindModule(class'DXRStats'));
        if(stats != None) {
            timer = stats.fmtTimeToString(stats.GetTotalAllTime());
        }
        log("ClientMessage: " $ msg @ timer, class.name);
    }
    Super.ClientMessage(msg, type, bBeep);
    if(type != 'ERROR') { // don't need errors to hit telemetry twice
        class'DXRTelemetry'.static.SendLog(GetDXR(), self, "INFO", msg);
    }

    // trying to make these likely to work with all languages...
    if( InStr(msg, Left(InventoryFull, 22))!=-1 // You don't have enough
        || InStr(msg, Left(TooMuchAmmo, 24))!=-1 // You already have enough
        || InStr(msg, Left(CanCarryOnlyOne, 19))!=-1 // You can only carry
        || InStr(msg, Left(class'DeusExCarcass'.default.msgCannotPickup, 18))!=-1 // You cannot pickup
        || msg == InventoryFull
        || msg == TooHeavyToLift
        || msg == CannotLift
        || msg == NoRoomToLift
        || msg == CannotDropHere
        || msg == HandsFull
        || msg == class'DeusExPickup'.default.msgTooMany
        || msg == class'DeusExCarcass'.default.msgEmpty
    ) {
        bBeep = true;
    }

    if(type == 'ERROR') {
        DeusExRootWindow(rootWindow).hud.msgLog.PlayLogSound(Sound'DeusExSounds.Generic.Buzz1');
    }
    else if(bBeep) {
        // we don't want to override more important log sounds like Sound'LogSkillPoints'
        if(DeusExRootWindow(rootWindow).hud.msgLog.logSoundToPlay == None)
            DeusExRootWindow(rootWindow).hud.msgLog.PlayLogSound(Sound'Menu_Focus');
    }
}

function PlayerMove( float DeltaTime )
{
    log("ERROR: "$Self$".PlayerMove("$DeltaTime$"), state: "$GetStateName());
    ClientMessage("ERROR: "$Self$".PlayerMove("$DeltaTime$"), state: "$GetStateName());
    GotoState('PlayerWalking');
}

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local CCResidentEvilCam reCam;

    reCam = CCResidentEvilCam(ViewTarget);

    if (reCam!=None){
        CameraRotation = reCam.Rotation;
        CameraLocation = reCam.Location;
        return;
    } else {
        Super.PlayerCalcView(ViewActor,CameraLocation,CameraRotation);
        if (bDoomMode && (!InConversation())){
            CameraRotation.Pitch=0;
            ViewRotation.Pitch=0;
        }
    }
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
    local vector View,HitLocation,HitNormal;
    local float ViewDist;

    Dist = Dist/1.25; //Bring the camera in a bit closer than normal

    CameraRotation = ViewRotation;
    CameraLocation.Z+=BaseEyeHeight; //Adjust camera center to eye height
    View = vect(1,-0.2,0) >> CameraRotation; //Slightly offset the view to the right (so it's over the shoulder)
    if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
        ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
    else
        ViewDist = Dist;
    CameraLocation -= (ViewDist - 30) * View;
}

event ClientTravel( string URL, ETravelType TravelType, bool bItems )
{
    nextMap = URL;
    log("ClientTravel " $ URL @ TravelType @ bItems);
    Super.ClientTravel(URL, TravelType, bItems);
}

function ResetGoals()
{
	local DeusExGoal goal;
	local DeusExGoal goalNext;
    local bool isOldGoal;

    GetDXR();



	goal = FirstGoal;

	while( goal != None )
	{
		goalNext = goal.next;
        isOldGoal = (goal.goalMission < (dxr.dxInfo.missionNumber-1));

		// Delete:
		// 1) Completed Primary Goals
        // 2) Any Primary Goals two or more missions old
		// 3) ALL Secondary Goals

		if ((!goal.IsPrimaryGoal()) || (goal.IsPrimaryGoal() && (goal.IsCompleted() || isOldGoal)))
			DeleteGoal(goal);

		goal = goalNext;
	}
}

function DXRando GetDXR()
{
    if( dxr == None ) dxr = class'DXRando'.default.dxr;
    return dxr;
}

function DXRBase DXRFindModule(class<DXRBase> class, optional bool bSilent)
{
    local DXRBase m;
    if( dxr == None ) GetDXR();
    if( dxr != None ) m = dxr.FindModule(class, bSilent);
    return m;
}

// just wrap some stuff in an if statement for flag Rando_newgameplus_loops
exec function StartNewGame(String startMap)
{
    if (DeusExRootWindow(rootWindow) != None)
        DeusExRootWindow(rootWindow).ClearWindowStack();

    // Set a flag designating that we're traveling,
    // so MissionScript can check and not call FirstFrame() for this map.
    flagBase.SetBool('PlayerTraveling', True, True, 0);

    GetDXR();
    dxr.DXRInit();
    dxr.info( Self$" StartNewGame("$startMap$") found "$dxr$", dxr.flagbase: "$dxr.flagbase$", dxr.flags.newgameplus_loops: "$dxr.flags.newgameplus_loops);

    if( dxr.flags.newgameplus_loops == 0 ) {
        SaveSkillPoints();
        ResetPlayer();
    }
    DeleteSaveGameFiles();

    bStartingNewGame = True;

    // Send the player to the specified map!
    if (startMap == "")
        Level.Game.SendPlayer(Self, "01_NYC_UNATCOIsland");		// TODO: Must be stored somewhere!
    else
        Level.Game.SendPlayer(Self, startMap);
}

function ShowIntro(optional bool bStartNewGame)
{
    local DXRMapVariants maps;
    local string intro;

    if (DeusExRootWindow(rootWindow) != None)
        DeusExRootWindow(rootWindow).ClearWindowStack();

    bStartNewGameAfterIntro = bStartNewGame;

    // Make sure all augmentations are OFF before going into the intro
    AugmentationSystem.DeactivateAll();

    // Reset the player
    intro = "00_Intro";
    maps = DXRMapVariants(DXRFindModule(class'DXRMapVariants'));
    if(maps != None)
        intro = maps.VaryMap(intro);
    Level.Game.SendPlayer(Self, intro);
}

exec function ShowMainMenu()
{
    local DeusExLevelInfo info;
    local MissionEndgame Script;

    // DXRando: close multiplayer style skills and augs screens

    if (bBuySkills || bUpgradeAugs) // close the DXMP style skills/augs screens
    {
        bBuySkills = false;
        bUpgradeAugs = false;
        return;
    }

    // DXRando: we just don't want to do vanilla behavior during the intro (misison 98)
    // escape skips the conversation which still skips the intro anyways
    // the vanilla code would skip the intro here as well even before the conversation started, which could also mean before flags are cleared
    info = GetLevelInfo();
    if ((info != None) && (info.MissionNumber == 98)) {
        return;
    }
    else if ((info != None) && (info.MissionNumber == 99))
    {
        foreach AllActors(class'MissionEndgame', Script)
            break;

        // DXRando: make sure we have Script.Flags before skipping to avoid crashes
        if (Script != None && Script.Flags != None)
            Script.FinishCinematic();
        return;
    }
    Super.ShowMainMenu();
}

function bool HandleItemPickup(Actor FrobTarget, optional bool bSearchOnly)
{
    local bool bCanPickup,banned;
    local #var(DeusExPrefix)Weapon weap,ownedWeapon;
    local int ammoAvail,ammoToAdd,ammoRemaining;
    local class<Ammo> defAmmoClass;
    local #var(DeusExPrefix)Ammo ownAmmo;
    local bool isThrown;
    local #var(DeusExPrefix)Pickup pickup,ownedPickup;
    local #var(prefix)WeaponMod mod;

    if( loadout == None ) loadout = DXRLoadouts(DXRFindModule(class'DXRLoadouts', true));
    if ( loadout != None && Inventory(FrobTarget) != None && loadout.ban(self, Inventory(FrobTarget)) ) {
        FrobTarget.Destroy();
        return true;
    }

    //Try to apply the mod being picked up to the currently held weapon
    if (class'MenuChoice_AutoWeaponMods'.default.enabled){
        mod = #var(prefix)WeaponMod(FrobTarget);
        weap = #var(DeusExPrefix)Weapon(inHand);
        if (mod!=None && weap!=None){
            if (mod.CanUpgradeWeapon(weap)){
                mod.ApplyMod(weap);
                ClientMessage(mod.ItemName$" applied to "$weap.ItemName,, true);
                if (mod.IsA('WeaponModLaser') && class'MenuChoice_AutoLaser'.default.enabled){
                    weap.LaserOn();
                }
                mod.DestroyMod();
                return true;
            }
        }
    }

    //Preemptively remove default ammo from gun if that's banned (but the gun is not)
    weap = #var(DeusExPrefix)Weapon(FrobTarget);
    if (weapon!=None && weap.PickUpAmmoCount!=0){
        if (weap.AmmoNames[0]==None){
            defAmmoClass=weap.AmmoName;
        } else {
            defAmmoClass=weap.AmmoNames[0];
        }

        if (defAmmoClass!=class'#var(prefix)AmmoNone'){
            banned=False;
            if (loadout!=None){
                banned = loadout.is_banned(defAmmoClass);
            }
            if (banned){
                weap.PickUpAmmoCount=0; //Remove the ammo from the gun
            }
        }
    }

    bCanPickup = Super.HandleItemPickup(FrobTarget, bSearchOnly);

    if (bCanPickup==False && weap!=None && weap.PickUpAmmoCount!=0){
        ownedWeapon=#var(DeusExPrefix)Weapon(FindInventoryType(FrobTarget.Class));
        //You can't pick up the weapon, but let's yoink the ammo
        if (ownedWeapon==None){
            ammoAvail = weap.PickUpAmmoCount;
            if (weap.AmmoNames[0]==None){
                defAmmoClass=weap.AmmoName;
            } else {
                defAmmoClass=weap.AmmoNames[0];
            }

            isThrown = ClassIsChildOf(weap.ProjectileClass,class'ThrownProjectile') || weap.ProjectileClass==class'Shuriken';

            if (defAmmoClass!=class'#var(prefix)AmmoNone' && !isThrown){
                ownAmmo = #var(DeusExPrefix)Ammo(FindInventoryType(defAmmoClass));

                banned=False;
                if (loadout!=None){
                    banned = loadout.is_banned(defAmmoClass);
                }

                if (!banned){
                    if (ownAmmo==None){
                        ownAmmo = #var(DeusExPrefix)Ammo(Spawn(defAmmoClass));
                        AddInventory(ownAmmo);
                        ownAmmo.BecomeItem();
                        ownAmmo.AmmoAmount=0;
                        ownAmmo.GotoState('Idle2');
                    }

                    ammoRemaining=0;
                    ammoToAdd = ammoAvail;
                    if (ownAmmo.AmmoAmount+ammoAvail > ownAmmo.MaxAmmo) {
                        ammoToAdd = ownAmmo.MaxAmmo - ownAmmo.AmmoAmount;
                        ammoRemaining = ammoAvail - ammoToAdd;
                    }

                    ownAmmo.AddAmmo(ammoToAdd);
                    weap.PickUpAmmoCount=ammoRemaining;
                    if (ammoToAdd>0){
                        ClientMessage("Took "$ammoToAdd$" "$ownAmmo.ItemName$" from "$weap.ItemName,, true);
                    }
                    UpdateBeltText(weap);
                } else {
                    weap.PickUpAmmoCount=0; //Remove the ammo from the gun
                }
            }
        }
    }

    pickup = #var(DeusExPrefix)Pickup(FrobTarget);
    if (pickup!=None && pickup.Owner!=Self && pickup.maxCopies>1){
        //Pickup failed
        banned=False;
        if (loadout!=None){
            banned = loadout.is_banned(class<#var(DeusExPrefix)Pickup>(FrobTarget.Class));
        }

        if (!banned){
            ownedPickup=#var(DeusExPrefix)Pickup(FindInventoryType(FrobTarget.Class));
            if (ownedPickup!=None && (ownedPickup.NumCopies+pickup.NumCopies)>ownedPickup.maxCopies){
                ammoToAdd=ownedPickup.maxCopies - ownedPickup.NumCopies;
                if (ammoToAdd!=0){
                    pickup.NumCopies = (ownedPickup.NumCopies+pickup.NumCopies)-ownedPickup.maxCopies;
                    ownedPickup.NumCopies = ownedPickup.maxCopies;
                    UpdateBeltText(ownedPickup);
                    ClientMessage("Picked up "$ammoToAdd$" of the "$pickup.ItemName,, true);
                }
            }
        }

    }

    return bCanPickup;
}

function GrabDecoration()
{
    if (class'MenuChoice_DecoPickupBehaviour'.Default.enabled==True && inHand!=None){
        PutInHand(None);
        UpdateInHand();
        //This could return so that it doesn't say "your hands are full" if
        //your inHand has a put down time, but it's kind of nice if you're
        //carrying something without a put down time (like fire extinguishers)
    }
    Super.GrabDecoration();
}

function bool ShouldAddToBelt(inventory NewItem)
{
    local DeusExRootWindow root;
    local #var(prefix)HUDObjectBelt belt;
    local Inventory beltItem;
    local int i;

    //Belt is locked, don't add anything
    if (!class'MenuChoice_LockBelt'.static.AddToBelt(NewItem)) return False;

    root = DeusExRootWindow(rootWindow);
    belt = root.hud.belt;

    //Don't add an item to the belt if you have another one
    //of the same item on the belt already
    for (i=0;i<ArrayCount(belt.objects);i++){
        beltItem = belt.objects[i].GetItem();
        if (beltItem==None) continue;
        if (beltItem==NewItem) continue; //The new item will have already been added to the belt by the time we get here, so ignore ourself
        if (beltItem.class==NewItem.class) return False; //There's another of the same class already on the belt, get outta here!
    }

    return True;
}

function bool AddInventory( inventory NewItem )
{
    local bool retval;
    local DeusExRootWindow root;

    if( loadout == None ) loadout = DXRLoadouts(DXRFindModule(class'DXRLoadouts'));
    if ( loadout != None && loadout.ban(self, NewItem) ) {
        NewItem.Destroy();
        return true;
    }

    retval = Super.AddInventory(NewItem);

    if (NewItem.bInObjectBelt){ //Item was added to the belt automatically
        if (!ShouldAddToBelt(NewItem)) { //Do we actually want it on the belt?
            root = DeusExRootWindow(rootWindow);
            if (root!=None){
                root.hud.belt.RemoveObjectFromBelt(NewItem); //Get that thing off my belt!
            }
        }
    }

    return retval;
}

// copied a lot from DeusExPlayer DeleteInventory
function bool HideInventory(inventory item)
{
    local DeusExRootWindow root;
    local PersonaScreenInventory winInv;

    item.bDisplayableInv = false;

    // If the item was inHand, clear the inHand
    if (inHand == item)
    {
        SetInHand(None);
        SetInHandPending(None);
    }

    // Make sure the item is removed from the inventory grid
    RemoveItemFromSlot(item);

    root = DeusExRootWindow(rootWindow);

    if (root != None)
    {
        // If the inventory screen is active, we need to send notification
        // that the item is being removed
        winInv = PersonaScreenInventory(root.GetTopWindow());
        if (winInv != None)
            winInv.InventoryDeleted(item);

        // Remove the item from the object belt
        if (root != None)
            root.DeleteInventory(item);
      else //In multiplayer, we often don't have a root window when creating corpse, so hand delete
      {
         item.bInObjectBelt = false;
         item.beltPos = -1;
      }
    }
}

#ifdef transcended
function DeusExNote AddNote( optional String strNote, optional Bool bUserNote, optional bool bShowInLog, optional String strSource)
#else
function DeusExNote AddNote( optional String strNote, optional Bool bUserNote, optional bool bShowInLog )
#endif
{
    local DeusExLevelInfo info;
    local DeusExNote newNote;
#ifdef transcended
    newNote = Super.AddNote(strNote, bUserNote, bShowInLog, strSource);
#else
    newNote = Super.AddNote(strNote, bUserNote, bShowInLog);

    info = GetLevelInfo();
    if (info != None) {
        newNote.mission = info.MissionNumber;
        newNote.level_name = Caps(info.mapName);
        log("AddNote: new note mission: "$newNote.mission$", level name: "$newNote.level_name);
    }
#endif

    return newNote;
}

function float GetJumpZ()
{
    local float f, jump, jumpVal;
    local Augmentation aug, jumpAug;

    f = 1;
    for(aug=AugmentationSystem.FirstAug; aug!=None; aug=aug.next) {
        switch(aug.class) {
        case class'AugSpeed':
            f = FMax(f, aug.GetAugLevelValue());
            break;
        case class'AugNinja':
            f = FMax(f, aug.GetAugLevelValue());
            break;
        case class'AugJump':
            jumpVal = aug.PreviewAugLevelValue();
            jump = FMax(jump, jumpVal); // don't tick it unless this is our best choice, don't waste the player's energy
            if (jump==jumpVal || jumpAug==None){
                jumpAug = aug; //Store the jump aug that is actually best
            }
            break;
        }
    }

    if(jump > f) {
        jumpAug.TickUse();
        f = jump;
    }
    return default.JumpZ * f;
}

function DoJump( optional float F )
{
    local DeusExWeapon w;
    local float scaleFactor, augLevel;

    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) augLevel = AugmentationSystem.GetAugLevelValue(class'AugMuscle') * 1.3;
    if(augLevel < 1) augLevel = 1;
    if ((CarriedDecoration != None) && (CarriedDecoration.Mass > 20.0 * augLevel))
        return;
    else if (bForceDuck || IsLeaning())
        return;

    if (Physics == PHYS_Walking)
    {
        if ( Role == ROLE_Authority )
            PlaySound(JumpSound, SLOT_None, 1.5, true, 1200, 1.0 - 0.2*FRand() );
        if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
            MakeNoise(0.1 * Level.Game.Difficulty);
        PlayInAir();

        JumpZ = GetJumpZ();
        Velocity.Z = JumpZ;

        if ( Level.NetMode != NM_Standalone )
        {
            augLevel = JumpZ / default.JumpZ;
            w = DeusExWeapon(InHand);
            if (augLevel > 1 && w != None && w.Mass > 30.0)
            {
                scaleFactor = 1.0 - FClamp( ((w.Mass - 30.0)/55.0), 0.0, 0.5 );
                Velocity.Z *= scaleFactor;
            }
        }

        // reduce the jump velocity if you are crouching
//		if (bIsCrouching)
//			Velocity.Z *= 0.9;

        if ( Base != Level )
            Velocity.Z += Base.Velocity.Z;
        SetPhysics(PHYS_Falling);
        if ( bCountJumps && (Role == ROLE_Authority) )
            Inventory.OwnerJumped();

        class'DXRStats'.static.AddJump(self);
    }
}

// MakeNoise does nothing
function Landed(vector HitNormal)
{
    local vector legLocation;
    local Augmentation aug;
    local int augLevel;
    local float augReduce, dmg, softener;
    local DolphinJumpTrigger dolphin;

    softener = 1;
    /*if(class'MenuChoice_BalanceAugs'.static.IsEnabled() && AugmentationSystem != None)
    {
        augReduce = AugmentationSystem.GetAugLevelValue(class'AugStealth');
        if(augReduce != -1) softener = (1-augReduce)/4 + 0.75;
    }*/

    //Note - physics changes type to PHYS_Walking by default for landed pawns
    PlayLanded(Velocity.Z);
    if (Velocity.Z < -1.4 * default.JumpZ && (Velocity.Z * softener < -700) && (ReducedDamageType != 'All')) {
        JumpZ = GetJumpZ();
    }
    if (Velocity.Z < -1.4 * JumpZ)
    {
        //MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
        if ((Velocity.Z * softener < -700) && (ReducedDamageType != 'All'))
            if ( Role == ROLE_Authority )
            {
                // check our jump augmentation and reduce falling damage if we have it
                // jump augmentation doesn't exist anymore - use Speed instaed
                // reduce an absolute amount of damage instead of a relative amount
                augReduce = 0;
                if (AugmentationSystem != None)
                {
                    augLevel = AugmentationSystem.GetClassLevel(class'AugSpeed');
                    aug = AugmentationSystem.FindAugmentation(class'AugJump');
                    if(aug != None && aug.IsTicked()) { // this will be IsTicked if GetJumpZ() determined this was our best pick
                        augLevel = Max(augLevel, aug.GetClassLevel());
                    }
                    augLevel = Max(augLevel, AugmentationSystem.GetClassLevel(class'AugNinja'));
                    if (augLevel >= 0)
                        augReduce = 15 * (augLevel+1);
                }

                dmg = FMax((-0.16 * (Velocity.Z + 700)) - augReduce, 0);
                dmg *= softener;
                legLocation = Location + vect(-1,0,-1);			// damage left leg
                TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');

                legLocation = Location + vect(1,0,-1);			// damage right leg
                TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');

                dmg = FMax((-0.06 * (Velocity.Z + 700)) - augReduce, 0);
                dmg *= softener;
                legLocation = Location + vect(0,0,1);			// damage torso
                TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');
            }
    }
    //else if ( (Level.Game != None) && (Level.Game.Difficulty > 1) && (Velocity.Z > 0.5 * JumpZ) )
        //MakeNoise(0.1 * Level.Game.Difficulty);
    bJustLanded = true;

    foreach AllActors(class'DolphinJumpTrigger', dolphin) {
        dolphin.SelfDestruct();
    }
}

function bool CanInstantLeftClick(DeusExPickup item)
{
    if (inHand!=None) return false;

    if (item==None) return false;
    if (item.bActivatable==False) return false;
    if (item.GetStateName()=='Activated') return false;
    if (item.Owner == self) return false;// we already own the item?
    if (item.bDeleteMe) return false;// just in case!

    if (Binoculars(item)!=None) return false; //Unzooming requires left clicking the binocs again
    if (class'MenuChoice_BalanceItems'.static.IsDisabled() && ChargedPickup(item) != None) return false;
    return true;
}

exec function ParseLeftClick()
{
    local DeusExPickup item;

    Super.ParseLeftClick();
    item = DeusExPickup(FrobTarget);
    if (item != None && CanInstantLeftClick(item))
    {
        InstantlyUseItem(item);
        FrobTarget = None;
    }
}

function InstantlyUseItem(DeusExPickup item)
{
    local Actor A;
    local DeusExPickup p;
    local int i;
    local DXRLoadouts loadout;

    if(item == None) return;

    //Check if it's banned
    loadout = DXRLoadouts(class'DXRLoadouts'.static.Find());
    if ( loadout != None && loadout.ban(self, item) ) {
        item.Destroy();
        return;
    }

    //Only consume one of the things if it's in a stack.
    //Spawn an individual one to split it from the stack before using it.
    if (item.NumCopies>1){
        p = Spawn(item.Class,,,item.Location,item.Rotation);
        p.NumCopies=1;
        item.NumCopies--;
        InstantlyUseItem(p);
        return;
    }

    foreach item.BasedActors(class'Actor', A)
        A.SetBase(None);
    // So that any effects get applied to you
    item.SetOwner(self);
    item.SetBase(self);
    // add to the player's inventory, so ChargedPickups travel across maps
    item.BecomeItem();
    item.bDisplayableInv = false;
    item.Inventory = Inventory;
    Inventory = item;
    if(FireExtinguisher(item) != None) {
        // this was buggy with multiple, but it doesn't make sense and wouldn't be useful to use multiple at once anyways
        // this shouldn't get hit anymore, but still do this, just in case
        item.NumCopies = 1;
    }

    //In theory this should only be one, but just in case we slipped through the case above...
    for(i=item.NumCopies; i > 0; i--) {
        item.Activate();
    }
}

exec function ParseRightClick()
{
    local bool handled;
    local #var(DeusExPrefix)Mover dxm;
    handled=False;

    if (RestrictInput())
        return;

    if (#var(DeusExPrefix)Mover(FrobTarget) != None){ //If it's a door...
        dxm=#var(DeusExPrefix)Mover(FrobTarget);
        //That is locked and you have the key
        if (dxm.bLocked && dxm.KeyIDNeeded != '' && KeyRing.HasKey(dxm.KeyIDNeeded)){
            //And you aren't carrying anything
            if (CarriedDecoration==None){
                handled=True;
                PutInHand(KeyRing);
                UpdateInHand();
            }
        }
    }

    //PET THE ANIMAL
    if (Animal(FrobTarget)!=None){
        handled=True;
        FrobTarget.Frob(self, None);
    }

    if (!handled){
        Super.ParseRightClick();
    }
}

//A whole lot of copy paste just to add one "if (bDrop)" check to change the dropVect
exec function bool DropItem(optional Inventory inv, optional bool bDrop)
{
	local Inventory item;
	local Inventory previousItemInHand;
	local Vector X, Y, Z, dropVect;
	local float size, mult;
	local bool bDropped;
	local bool bRemovedFromSlots;
	local int  itemPosX, itemPosY;

	bDropped = True;

	if (RestrictInput())
		return False;

	if (inv == None)
	{
		previousItemInHand = inHand;
		item = inHand;
	}
	else
	{
		item = inv;
	}

	if (item != None)
	{
		GetAxes(Rotation, X, Y, Z);

        //Make dropping things from the inventory easier...
        if (bDrop){
            dropVect = Location;
        } else {
		    dropVect = Location + (CollisionRadius + 2*item.CollisionRadius) * X;
            dropVect.Z += BaseEyeHeight;
        }


		// check to see if we're blocked by terrain
		if (!FastTrace(dropVect))
		{
			ClientMessage(CannotDropHere,, true);
			return False;
		}

		// don't drop it if it's in a strange state
		if (item.IsA('DeusExWeapon'))
		{
			if (!DeusExWeapon(item).IsInState('Idle') && !DeusExWeapon(item).IsInState('Idle2') &&
				!DeusExWeapon(item).IsInState('DownWeapon') && !DeusExWeapon(item).IsInState('Reload'))
			{
				return False;
			}
			else		// make sure the scope/laser are turned off
			{
				DeusExWeapon(item).ScopeOff();
				DeusExWeapon(item).LaserOff();
			}
		}

		// Don't allow active ChargedPickups to be dropped
		if ((item.IsA('ChargedPickup')) && (ChargedPickup(item).IsActive()))
        {
			return False;
        }

		// don't let us throw away the nanokeyring
		if (item.IsA('NanoKeyRing'))
        {
			return False;
        }

		// take it out of our hand
		if (item == inHand)
			PutInHand(None);

		// handle throwing pickups that stack
		if (item.IsA('DeusExPickup'))
		{
			// turn it off if it is on
			if (DeusExPickup(item).bActive)
				DeusExPickup(item).Activate();

			DeusExPickup(item).NumCopies--;
			UpdateBeltText(item);

			if (DeusExPickup(item).NumCopies > 0)
			{
				// put it back in our hand, but only if it was in our
				// hand originally!!!
				if (previousItemInHand == item)
					PutInHand(previousItemInHand);

				item = Spawn(item.Class, Owner);
			}
			else
			{
				// Keep track of this so we can undo it
				// if necessary
				bRemovedFromSlots = True;
				itemPosX = item.invPosX;
				itemPosY = item.invPosY;

				// Remove it from the inventory slot grid
				RemoveItemFromSlot(item);

				// make sure we have one copy to throw!
				DeusExPickup(item).NumCopies = 1;
			}
		}
		else
		{
			// Keep track of this so we can undo it
			// if necessary
			bRemovedFromSlots = True;
			itemPosX = item.invPosX;
			itemPosY = item.invPosY;

			// Remove it from the inventory slot grid
			RemoveItemFromSlot(item);
		}

        // throw velocity is based on augmentation
        if (AugmentationSystem != None)
        {
            mult = AugmentationSystem.GetAugLevelValue(class'AugMuscle');
            if (mult == -1.0)
                mult = 1.0;
        }

        if (bDrop)
        {
            item.Velocity = VRand() * 30;

            // play the correct anim
            PlayPickupAnim(item.Location);
        }
        else
        {
            item.Velocity = Vector(ViewRotation) * mult * 300 + vect(0,0,220) + 40 * VRand();

            // play a throw anim
            PlayAnim('Attack',,0.1);
        }

        GetAxes(ViewRotation, X, Y, Z);
        dropVect = Location + 0.8 * CollisionRadius * X;
        dropVect.Z += BaseEyeHeight;

        // if we are a corpse, spawn the actual carcass
        if (item.IsA('POVCorpse'))
        {
            if(POVCorpse(item).Drop(dropVect) != None) {
                // must circumvent PutInHand() since it won't allow
                // things in hand when you're carrying a corpse
                SetInHandPending(None);
                item = None;
            }
        }
        else
        {
            if (FastTrace(dropVect))
            {
                item.DropFrom(dropVect);
                item.bFixedRotationDir = True;
                item.RotationRate.Pitch = (32768 - Rand(65536)) * 4.0;
                item.RotationRate.Yaw = (32768 - Rand(65536)) * 4.0;
            }
        }


		// if we failed to drop it, put it back inHand
		if (item != None)
		{
			if (((inHand == None) || (inHandPending == None)) && (item.Physics != PHYS_Falling))
			{
				PutInHand(item);
				ClientMessage(CannotDropHere,, true);
				bDropped = False;
			}
			else
			{
				item.Instigator = Self;
			}
		}
	}
	else if (CarriedDecoration != None)
	{
		DropDecoration();

		// play a throw anim
		PlayAnim('Attack',,0.1);
	}

	// If the drop failed and we removed the item from the inventory
	// grid, then we need to stick it back where it came from so
	// the inventory doesn't get fucked up.

	if ((bRemovedFromSlots) && (item != None) && (!bDropped))
	{
        //DEUS_EX AMSD Use the function call for this, helps multiplayer
        PlaceItemInSlot(item, itemPosX, itemPosY);
	}

	return bDropped;
}

event HeadZoneChange(ZoneInfo newHeadZone)
{
    if (HeadRegion.Zone.bWaterZone && !newHeadZone.bWaterZone)
    {
        class'DolphinJumpTrigger'.static.CreateDolphin(self);
    }
    Super.HeadZoneChange(newHeadZone);
}

event WalkTexture( Texture Texture, vector StepLocation, vector StepNormal )
{
    local DolphinJumpTrigger dolphin;
    if ( Texture!=None && Texture.Outer!=None && Texture.Outer.Name=='Ladder' ) {
        if(!bOnLadder) {
            foreach AllActors(class'DolphinJumpTrigger', dolphin) {
                dolphin.SelfDestruct();
            }
        }
        bOnLadder = True;
    }
    else
        bOnLadder = False;
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
    class'DXREvents'.static.AddPlayerDeath(GetDXR(), self, Killer, damageType, HitLocation);
    Super.Died(Killer,damageType,HitLocation);
}

function bool IsHighlighted(actor A)
{
    local bool wasBehind,highlight;

    wasBehind = bBehindView;
    bBehindView = False;
    highlight = Super.IsHighlighted(A);
    if (LaserTrigger(A)!=None || BeamTrigger(A)!=None){
        highlight=True;
    }
    bBehindView = wasBehind;
    return highlight;
}

function bool IsFrobbable(actor A)
{
    if (!A.bHidden)
        if (A.IsA('BeamTrigger') || A.IsA('LaserTrigger'))
            return True;

    return Super.IsFrobbable(A);
}

function HighlightCenterObject()
{
    if (IsInState('Dying'))
        return;

    HighlightCenterObjectMain();
    HighlightCenterObjectLaser();
}

function HighlightCenterObjectMain()
{
    local Actor target, t;
    local int fails;
    local float dist, dist2;

    target = HighlightCenterObjectRay(vect(0,0,0), dist);

    if(LevelInfo(target) != None) target = None;

    if(target != None && Brush(target) == None && class'MenuChoice_FixGlitches'.default.enabled) {
        t = HighlightCenterObjectRay(vect(0,-0.2,1.5), dist2);
        fails += int(t!=target && dist2 < dist && (LevelInfo(t)!=None || Brush(t)!=None));

        t = HighlightCenterObjectRay(vect(0,-1,-1), dist2);
        fails += int(t!=target && dist2 < dist && (LevelInfo(t)!=None || Brush(t)!=None));

        t = HighlightCenterObjectRay(vect(0,1.5,-0.5), dist2);
        fails += int(t!=target && dist2 < dist && (LevelInfo(t)!=None || Brush(t)!=None));

        if(fails > 1) target = None;
    }

    // DXRando: if we already have a frob target, and the player looks away such as that no item is being
    // traced, we still wait for the full 100ms vanilla duration before clearing the frob
    // target.
    //
    // note that this means we don't wait for the full 100ms vanilla duration if the player is
    // rapidly changing frob target.
    if (FrobTime < 0.1 && FrobTarget != None && target == None && !FrobTarget.bDeleteMe)
    {
        return;
    }

    FrobTarget = target;
    FrobTime = 0; // reset our frob timer
}

function Actor HighlightCenterObjectRay(vector offset, out float smallestTargetDist)
{
    local Actor target, smallestTarget;
    local DeathMarker dm;
    local Vector HitLoc, HitNormal, StartTrace, EndTrace;
    local float minSize;
    local bool bFirstTarget;

    // DXRando: we do the trace every frame, unlike the vanilla behaviour of doing it every 100ms

    // figure out how far ahead we should trace
    StartTrace = Location + (offset >> ViewRotation);
    EndTrace = StartTrace + (Vector(ViewRotation) * MaxFrobDistance);

    // adjust for the eye height
    StartTrace.Z += BaseEyeHeight;
    EndTrace.Z += BaseEyeHeight;

    smallestTarget = None;
    minSize = 99999;
    smallestTargetDist = 99999;
    bFirstTarget = True;

    // find the object that we are looking at
    // make sure we don't select the object that we're carrying
    // use the last traced object as the target...this will handle
    // smaller items under larger items for example
    // ScriptedPawns always have precedence, though
    foreach TraceActors(class'Actor', target, HitLoc, HitNormal, EndTrace, StartTrace)
    {
        if(DeathMarker(target) != None) {
            if(dm == None && target.CollisionRadius < minSize) {
                dm = DeathMarker(target);
                if(bFirstTarget) smallestTargetDist = VSize(Location-HitLoc);
            }
            continue;
        }
        if (IsFrobbable(target) && (target != CarriedDecoration))
        {
            if (target.IsA('ScriptedPawn'))
            {
                smallestTarget = target;
                smallestTargetDist = VSize(Location-HitLoc);
                break;
            }
            else if (target.IsA('Mover'))
            {
                if(bFirstTarget) {
                    smallestTarget = target;
                    smallestTargetDist = VSize(Location-HitLoc);
                }
                break;
            }
            else if (target.CollisionRadius < minSize)
            {
                minSize = target.CollisionRadius;
                smallestTarget = target;
                bFirstTarget = False;
                smallestTargetDist = VSize(Location-HitLoc);
            }
        }
        else if(LevelInfo(target) != None || Brush(target) != None) {
            if(bFirstTarget && dm==None) {
                smallestTargetDist = VSize(Location-HitLoc);
                smallestTarget = Level;
            }
            minSize = -1; // don't allow any actors after this, but do allow Movers
        }
    }

    if(smallestTarget == None || LevelInfo(target) != None) {
        return dm;
    }

    return smallestTarget;
}

function HighlightCenterObjectLaser()
{
    local Vector loc;

    //Activate the aim laser any time you aren't seeing through your eyes
    if (class'DXRAimLaserEmitter'.static.AimLaserShouldBeOn(self)){
        if (aimLaser==None){
            aimLaser = Spawn(class'DXRAimLaserEmitter', Self, , Location, Pawn(Owner).ViewRotation);
            if (aimLaser == None) {
                ClientMessage("Failed to spawn aim laser?");
            }
        }

        loc = Location;
        loc.Z+=BaseEyeHeight;
        loc = loc + vector(ViewRotation) * (CollisionRadius/2);
        aimLaser.SetLocation(loc);
        aimLaser.SetRotation(ViewRotation);
        aimLaser.proxy.DistanceFromPlayer=0; //Make sure the laser doesn't get frozen

        aimLaser.TurnOn();

    } else {
        if (aimLaser!=None){
            aimLaser.TurnOff();
        }
    }
}

exec function CrowdControlAnon()
{
    local DXRCrowdControl cc;
    local DXRFlags f;

    foreach AllActors(class'DXRCrowdControl',cc)
    {
        cc.link.anon = True;
    }
    foreach AllActors(class'DXRFlags',f)
    {
        f.crowdcontrol = 2;
        f.f.SetInt('Rando_crowdcontrol',2,,999);
    }

    ClientMessage("Now hiding Crowd Control names");

}

exec function CrowdControlNames()
{
    local DXRCrowdControl cc;
    local DXRFlags f;

    foreach AllActors(class'DXRCrowdControl',cc)
    {
        cc.link.anon = False;
    }
    foreach AllActors(class'DXRFlags',f)
    {
        f.crowdcontrol = 1;
        f.f.SetInt('Rando_crowdcontrol',1,,999);
    }
    ClientMessage("Now showing Crowd Control names");
}

exec function CheatsOn()
{
    bCheatsEnabled = true;
    ClientMessage("Cheats Enabled");
}

exec function CheatsOff()
{
    bCheatsEnabled = false;
    ClientMessage("Cheats Disabled");
}

//Just a copy of PlayersOnly, but doesn't need cheats and faster to type (In case of lockups after a save)
exec function po()
{
    if ( Level.Netmode != NM_Standalone )
        return;

    Level.bPlayersOnly = !Level.bPlayersOnly;
}

//fast version of EditActor class=classname
exec function ea(Name ClassName)
{
    ConsoleCommand("editactor class=" $ ClassName);
}

exec function MoveClass(Name ClassName, int x, int y, int z)
{
    local Actor a;
    local class<Actor> objclass;
    local string holdName;
    local Vector v;

    if (instr(ClassName, ".") == -1)
        holdName = "DeusEx." $ ClassName;
    else
        holdName = string(ClassName);

    objclass = class<actor>(DynamicLoadObject(holdName, class'Class'));
    v.X = x;
    v.Y = y;
    v.Z = z;
    foreach AllActors(objclass, a) {
        a.SetLocation(a.Location + v);
    }
}

exec function RotateClass(Name ClassName, int pitch, int yaw, int roll)
{
    local Actor a;
    local class<Actor> objclass;
    local string holdName;
    local Rotator r;

    if (instr(ClassName, ".") == -1)
        holdName = "DeusEx." $ ClassName;
    else
        holdName = string(ClassName);

    objclass = class<actor>(DynamicLoadObject(holdName, class'Class'));
    foreach AllActors(objclass, a) {
        r = a.Rotation;
        r.Pitch += pitch;
        r.Yaw += yaw;
        r.Roll += roll;
        a.SetRotation(r);
    }
}

exec function crate(optional string name)
{
    local CrateUnbreakableSmall c;
    local ActorDisplayWindow actorDisplay;
    c = Spawn(class'CrateUnbreakableSmall');
    if(name != "") c.ItemName = name;
    actorDisplay = DeusExRootWindow(rootWindow).actorDisplay;
    if(actorDisplay.GetViewClass() == None && !class'DXRVersion'.static.VersionIsStable()) {
        actorDisplay.SetViewClass(class'CrateUnbreakableSmall');
        actorDisplay.ShowLOS(false);
        actorDisplay.ShowPos(true);
    }
    CarriedDecoration = c;
    PutCarriedDecorationInHand();
}

exec function FixAugHotkeys()
{
    class'DXRAugmentations'.static.FixAugHotkeys(self,true);
}

exec function ShuffleGoals()
{
    local DXRMissions missions;

    foreach AllActors(class'DXRMissions',missions)
    {
        missions.SetGlobalSeed(FRand());
        missions.ShuffleGoals();
    }
}

exec function MoveGoalLocation( int locNumber, coerce string goalName)
{
    local DXRMissions missions;

    foreach AllActors(class'DXRMissions',missions)
    {
        if (missions.MoveGoalTo(goalName,locNumber)==true){
            ClientMessage("Successfully moved goal");
        } else {
            ClientMessage("Failed to move goal");
        }
    }
}

exec function AllPasswords()
{
    local Computers c;
    local Keypad k;
    local ATM a;
    local int i;

    foreach AllActors(class'Computers',c){
        for (i=0;i<ArrayCount(c.knownAccount);i++){
            c.SetAccountKnown(i);
        }
    }

    foreach AllActors(class'Keypad',k){
        k.bCodeKnown = True;
    }

    foreach AllActors(class'ATM',a){
        for (i=0;i<ArrayCount(a.knownAccount);i++){
            a.SetAccountKnown(i);
        }
    }
    ClientMessage("Set all account passwords to known");
}

exec function SetSkillValues(float value)
{
    local Skill s;
    local int i;

    foreach AllActors(class'Skill', s) {
        for(i=0; i<ArrayCount(s.LevelValues); i++)
            s.LevelValues[i] = value;
    }
}

exec function Mirror()
{
    local string s;
    local DXRMapVariants maps;

    maps = DXRMapVariants(DXRFindModule(class'DXRMapVariants'));
    if(maps == None) {
        log("ERROR: Mirror cheat failed to find DXRMapVariants");
        return;
    }

    if(maps.coords_mult.X==1 && maps.coords_mult.Y==1) {
        s = GetDXR().localURL $ "_-1_1_1.dx";
    } else {
        s = maps.CleanupMapName(GetDXR().localURL);
    }
    class'DynamicTeleporter'.static.SetDestPos(self, Location, maps.coords_mult);
    log("Mirror cheat " $ maps @ GetURLMap() @ s @ Location @ maps.coords_mult);
    flagBase.SetBool('PlayerTraveling', True, True, 0);
    Level.Game.SendPlayer(Self, s);
}

exec function slowmo(float s)
{
    if (!bCheatsEnabled)
        return;
    s = FMax(s, 0.0001);// regular slomo cheat only goes down to 0.1, but 0 gives a black screen
    Level.Game.GameSpeed = s;
    Level.TimeDilation = s;
    Level.Game.SetTimer(s, true);
    if(s == 1) {// slomo always saves the configs but I don't see a point in saving anything except regular speed
        Level.Game.SaveConfig();
        Level.Game.GameReplicationInfo.SaveConfig();
    }
}

exec function animtrack()
{// a single command to start work on DXRAnimTracker
    local DXRAnimTracker a;
    local int i;

    slowmo(0.1);
    SetPause(true);
    ReducedDamageType = 'All';
    foreach AllActors(class'DXRAnimTracker', a) {
        a.edit();
    }
    ea('DXRAnimTracker');
}

//========= MUSIC STUFF
function _ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
    Super.ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);
}

// only called by GameInfo::PostLogin()
function ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
    local DXRMusicPlayer m;
    if (GetDXR()==None){ //Probably only during ENDGAME4?
        log("Couldn't find a DXR so we can set the music to " $ NewSong);
        return;
    }
    m = DXRMusicPlayer(dxr.LoadModule(class'DXRMusicPlayer'));// this can get called before the module is loaded
    if (m==None){
        log("WARNING: DXRMusicPlayer module not found");
        _ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);
        return;
    } else {
        m.ClientSetMusic(self, NewSong, NewSection, NewCdTrack, NewTransition);
    }
}

//=========== END OF MUSIC STUFF

function UpdateRotation(float DeltaTime, float maxPitch)
{
    local DataStorage datastorage;
    local int rollAmount;
    datastorage = class'DataStorage'.static.GetObjFromPlayer(self);
    if(datastorage != None) rollAmount = int(datastorage.GetConfigKey('cc_cameraRoll'));

    if(rollAmount == 0) {
        Super.UpdateRotation(DeltaTime,maxPitch);
        return;
    }

    //Track and handle shake rotation as though we are always right-ways up
    //Carry the Yaw over, since the shake doesn't adjust that, so it resets you
    //to Yaw 0 when a roll starts otherwise (Issue #608)
    ShakeRotator.Yaw = ViewRotation.Yaw;
    ViewRotation = ShakeRotator;
    Super.UpdateRotation(DeltaTime,maxPitch);
    ShakeRotator = ViewRotation;

    //Apply any roll after figuring out (and storing) the current shake state
    ViewRotation.Roll += rollAmount;
}

// LDDP: for Lay D Denton compatibility
simulated function PreBeginPlay()
{
    Super.PreBeginPlay();
}

simulated function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();

    //Make sure the aug and skill quick menus are closed when you re-enter a map.
    //bUpgradeAugs is added by Rando so is transient, but bBuySkills is vanilla
    bUpgradeAugs=False;
    bBuySkills=False;
}
function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
    Super.PlayTakeHitSound(Damage, damageType, Mult);
}
function TweenToRunning(float tweentime)
{
    if(bBlockAnimations){return;}

    Super.TweenToRunning(tweentime);
}
function PlayWalking()
{
    local float newhumanAnimRate;

    if(bBlockAnimations){return;}

    newhumanAnimRate = humanAnimRate;

    // UnPhysic.cpp walk speed changed by proportion 0.7/0.3 (2.33), but that looks too goofy (fast as hell), so we'll try something a little slower
    if ( Level.NetMode != NM_Standalone )
        newhumanAnimRate = humanAnimRate * 1.75;

    //	ClientMessage("PlayWalking()");
    if(!HasAnim('CrouchWalk'))
        LoopAnim('Walk', newhumanAnimRate);
    else if (bForceDuck || bCrouchOn)
        LoopAnim('CrouchWalk', newhumanAnimRate);
    else
    {
        if (HasTwoHandedWeapon())
            LoopAnim('Walk2H', newhumanAnimRate);
        else
            LoopAnim('Walk', newhumanAnimRate);
    }
}
function TweenToWalking(float tweentime)
{
    if(!HasAnim('CrouchWalk'))
        TweenAnim('Walk', tweentime);
    else
        Super.TweenToWalking(tweentime);
}
function PlayFiring()
{
    Super.PlayFiring();
}
function TweenToWaiting(float tweentime)
{
    //	ClientMessage("TweenToWaiting()");

    if(bBlockAnimations){return;}

    if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
    {
        if (IsFiring())
            LoopAnim('TreadShoot');
        else
            LoopAnim('Tread');
    }
    else if (HasAnim('CrouchWalk') && (IsLeaning() || bForceDuck))
        TweenAnim('CrouchWalk', tweentime);
    else if (((AnimSequence == 'Pickup') && bAnimFinished) || ((AnimSequence != 'Pickup') && !IsFiring()))
    {
        if (HasTwoHandedWeapon())
            TweenAnim('BreatheLight2H', tweentime);
        else
            TweenAnim('BreatheLight', tweentime);
    }
}
function UpdateAnimRate( float augValue )
{
    Super.UpdateAnimRate(augValue);
}
function PlayDying(name damageType, vector hitLoc)
{
    SetCollision(false,false,false);
    Super.PlayDying(damageType, hitLoc);
}
function TweenToSwimming(float tweentime)
{
    Super.TweenToSwimming(tweentime);
}
function PlayDyingSound()
{
    Super.PlayDyingSound();
}
function Gasp()
{
    Super.Gasp();
}
function float RandomPitch()
{
    return Super.RandomPitch();
}
function PlayWeaponSwitch(Weapon newWeapon)
{
    Super.PlayWeaponSwitch(newWeapon);
}
function PlayCrawling()
{
    //	ClientMessage("PlayCrawling()");
    if(bBlockAnimations){return;}

    if (IsFiring())
        LoopAnim('CrouchShoot');
    else if(HasAnim('CrouchWalk'))
        LoopAnim('CrouchWalk');
}
function PlayRising()
{
    Super.PlayRising();
}
function PlayDuck()
{
    //	ClientMessage("PlayDuck()");
    if(bBlockAnimations){return;}

    if ((AnimSequence != 'Crouch') && (AnimSequence != 'CrouchWalk'))
    {
        if (IsFiring())
            PlayAnim('CrouchShoot',,0.1);
        else
            PlayAnim('Crouch',,0.1);
    }
    else if(HasAnim('CrouchWalk'))
        TweenAnim('CrouchWalk', 0.1);
}
function PlayLanded(float impactVel)
{
    Super.PlayLanded(impactVel);
}
function PlayInAir()
{
    Super.PlayInAir();
}
function PlaySwimming()
{
    Super.PlaySwimming();
}
function PlayWaiting()
{
//	ClientMessage("PlayWaiting()");

    if(bBlockAnimations){return;}

    if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
    {
        if (IsFiring())
            LoopAnim('TreadShoot');
        else
            LoopAnim('Tread');
    }
    else if (HasAnim('CrouchWalk') && (IsLeaning() || bForceDuck))
        TweenAnim('CrouchWalk', 0.1);
    else if (!IsFiring())
    {
        if (HasTwoHandedWeapon())
            LoopAnim('BreatheLight2H');
        else
            LoopAnim('BreatheLight');
    }
}
function PlayRunning()
{
    if(bBlockAnimations){return;}

    Super.PlayRunning();
}
function PlayTurning()
{
    if(!HasAnim('CrouchWalk'))
        TweenAnim('Walk', 0.1);
    else
        Super.PlayTurning();
}
function Bool HasTwoHandedWeapon()
{
    return Super.HasTwoHandedWeapon();
}
function Bool IsFiring()
{
    return Super.IsFiring();
}

function bool IsThemeAdded(Class<ColorTheme> themeClass)
{
    local ColorTheme curTheme;
    local ColorTheme prevTheme;
    local Bool bDeleted;

    bDeleted    = False;
    curTheme = ThemeManager.FirstColorTheme;

    while(curTheme != None)
    {
        if ((curTheme.GetThemeName() == themeClass.default.themeName) && (curTheme.IsSystemTheme() == themeClass.default.bSystemTheme) && curTheme.themeType == themeClass.default.themeType)
        {
            return True;
        }

        curTheme = curTheme.next;
    }
    return False;

}

function AddColorTheme(Class<ColorTheme> themeClass)
{
    if(IsThemeAdded(themeClass)==False){
        ThemeManager.AddTheme(themeClass);
    }
}

function CreateColorThemeManager()
{
    local ColorTheme theme;
    Super.CreateColorThemeManager();

    AddColorTheme(Class'ColorThemeHUD_HotDogStand');
    AddColorTheme(Class'ColorThemeMenu_HotDogStand');
    AddColorTheme(Class'ColorThemeHUD_Black');
    AddColorTheme(Class'ColorThemeMenu_Black');
    AddColorTheme(Class'ColorThemeHUD_Rando');
    AddColorTheme(Class'ColorThemeMenu_Rando');
    AddColorTheme(Class'ColorThemeHUD_Swirl');
    AddColorTheme(Class'ColorThemeMenu_Swirl');
    AddColorTheme(Class'ColorThemeHUD_Health');
    AddColorTheme(Class'ColorThemeMenu_Health');
}

// ----------------------------------------------------------------------
// RemoveItemDuringConversation()
// The only difference here is that we no longer remove the item from the inventory grid
// ----------------------------------------------------------------------

function RemoveItemDuringConversation(Inventory item)
{
	if (item != None)
	{
		// take it out of our hand
		if (item == inHand)
			PutInHand(None);

		// Make sure it's removed from the inventory grid
		//RemoveItemFromSlot(item);  //RANDO: How about we actually don't

		// Make sure the item is deactivated!
		if (item.IsA('DeusExWeapon'))
		{
			DeusExWeapon(item).ScopeOff();
			DeusExWeapon(item).LaserOff();
		}
		else if (item.IsA('DeusExPickup'))
		{
			// turn it off if it is on
			if (DeusExPickup(item).bActive)
				DeusExPickup(item).Activate();
		}

		if (conPlay != None)
			conPlay.SetInHand(None);
	}
}

function SetTurretState(AutoTurret turret, bool bActive, bool bDisabled)
{
    Super.SetTurretState(turret,bActive,bDisabled);

    turret.bActiveOrig = bActive;
}

function SetTurretTrackMode(ComputerSecurity computer, AutoTurret turret, bool bTrackPlayers, bool bTrackPawns)
{
    Super.SetTurretTrackMode(computer,turret,bTrackPlayers,bTrackPawns);

    //Using a computer will clear any craziness, just for simplicity
    turret.bTrackPawnsOnlyOrig = bTrackPawns;
    turret.bTrackPlayersOnlyOrig = bTrackPlayers;
    turret.CrazedTimer = 0;
    turret.bActive = turret.bActiveOrig;
}

function MakePlayerIgnored(bool bNewIgnore)
{
    Super.MakePlayerIgnored(bNewIgnore);

    //Update ammo count in the belt
    //This function gets called at the end of conversations, which could have given you ammo
    DeusExRootWindow(rootWindow).hud.belt.UpdateObjectText(0);
}

exec function ShowBingoWindow()
{
	if (RestrictInput())
		return;

   if ((Level.NetMode != NM_Standalone) && (bBeltIsMPInventory))
   {
      ClientMessage("Bingo screen disabled in multiplayer");
      return;
   }

	InvokeUIScreen(Class'PersonaScreenBingo');
}

exec function ActivateAllAutoAugs()
{
    if (AugmentationSystem != None)
        AugmentationSystem.ActivateAllAutoAugs();
}

// OpenAugTree by WCCC
exec function OpenControllerAugWindow()
{
    local DeusExRootWindow Root;
    local OATMenuAugsSelector TarWindow;

    Root = DeusExRootWindow(RootWindow);
    if (Root != None)
    {
        TarWindow = OATMenuAugsSelector(Root.InvokeMenuScreen(Class'OATMenuAugsSelector', false));
        if (TarWindow != None)
        {
            if (LastBrowsedAugPage > -1)
            {
                TarWindow.LoadAugPage(LastBrowsedAugPage);
            }
            if (LastBrowsedAug > -1)
            {
                TarWindow.SelectedAug = LastBrowsedAug;
                TarWindow.UpdateHighlighterPos();
            }
        }
    }
}


function HandleWalking()
{
    PlayerPawnHandleWalking();

    if (bAlwaysRun)
        bIsWalking = (bRun != 0) || (bDuck != 0);
    else
        bIsWalking = (bRun == 0) || (bDuck != 0);

    // handle the toggle walk key
    if (bToggleWalk)
        bIsWalking = !bIsWalking;

    if (bToggleCrouch)
    {
        if (!bCrouchOn && !bWasCrouchOn && (bDuck != 0))
        {
            bCrouchOn = True;
        }
        else if (bCrouchOn && !bWasCrouchOn && (bDuck == 0))
        {
            bWasCrouchOn = True;
        }
        else if (bCrouchOn && bWasCrouchOn && (bDuck == 0) && (lastbDuck != 0))
        {
            bCrouchOn = False;
            bWasCrouchOn = False;
        }

        if (bCrouchOn)
        {
            bIsCrouching = True;
            bDuck = 1;
        }

        lastbDuck = bDuck;
    }
}

// DXRando: PlayerPawn.HandleWalking, but with ForcePutCarriedDecorationInHand() instead of DropDecoration()
function PlayerPawnHandleWalking()
{
    local rotator carried;

    // this is changed from Unreal -- default is now walk - DEUS_EX CNN
    bIsWalking = ((bRun == 0) || (bDuck != 0)) && !Region.Zone.IsA('WarpZoneInfo');

    if ( CarriedDecoration != None )
    {
        if ( (Role == ROLE_Authority) && (standingcount == 0) )
            CarriedDecoration = None;
        if ( CarriedDecoration != None ) //verify its still in front
        {
            bIsWalking = true;
            if ( Role == ROLE_Authority )
            {
                carried = Rotator(CarriedDecoration.Location - Location);
                carried.Yaw = ((carried.Yaw & 65535) - (Rotation.Yaw & 65535)) & 65535;
                if ( (carried.Yaw > 3072) && (carried.Yaw < 62463) )
                    ForcePutCarriedDecorationInHand();
            }
        }
    }
}


// a lot like the vanilla PutCarriedDecorationInHand()
function ForcePutCarriedDecorationInHand()
{
    local vector lookDir, upDir;

    if (CarriedDecoration != None)
    {
        lookDir = Vector(Rotation);
        lookDir.Z = 0;
        upDir = vect(0,0,0);
        upDir.Z = CollisionHeight / 2;		// put it up near eye level
        CarriedDecoration.SetPhysics(PHYS_None);
        CarriedDecoration.SetCollision(False, False, False);
        CarriedDecoration.bCollideWorld = False;

        if ( CarriedDecoration.SetLocation(Location + upDir + (0.5 * CollisionRadius + CarriedDecoration.CollisionRadius) * lookDir) )
        {
            CarriedDecoration.SetBase(self);
            // make it translucent
            CarriedDecoration.Style = STY_Translucent;
            CarriedDecoration.ScaleGlow = 1.0;
            CarriedDecoration.bUnlit = True;

            if(FrobTarget == CarriedDecoration) FrobTarget = None;
        }
        else
        {
            log("ERROR: Why would ForcePutCarriedDecorationInHand() fail? " $ CarriedDecoration);
            CarriedDecoration = None;
        }
    }
}

// DXRando: like vanilla, except better order of operations for the decoration's BaseChange event
function DropDecoration()
{
    local Decoration dec;// DXRando
    local Vector X, Y, Z, dropVect, origLoc, HitLocation, HitNormal, extent;
    local float velscale, size, mult;
    local bool bSuccess;
    local Actor hitActor;

    if(CarriedDecoration == None) return;
    bSuccess = False;
    dec = CarriedDecoration;

    origLoc = CarriedDecoration.Location;
    GetAxes(Rotation, X, Y, Z);

    // if we are highlighting something, try to place the object on the target
    if ((FrobTarget != None) && !FrobTarget.IsA('Pawn'))
    {
        CarriedDecoration.Velocity = vect(0,0,0);

        // try to drop the object about one foot above the target
        size = FrobTarget.CollisionRadius - CarriedDecoration.CollisionRadius * 2;
        dropVect.X = size/2 - FRand() * size;
        dropVect.Y = size/2 - FRand() * size;
        dropVect.Z = FrobTarget.CollisionHeight + CarriedDecoration.CollisionHeight + 16;
        dropVect += FrobTarget.Location;
    }
    else
    {
        // throw velocity is based on augmentation
        if (AugmentationSystem != None)
        {
            mult = AugmentationSystem.GetAugLevelValue(class'AugMuscle');
            if (mult == -1.0)
                mult = 1.0;
        }

        if (IsLeaning())
            CarriedDecoration.Velocity = vect(0,0,0);
        else
            CarriedDecoration.Velocity = Vector(ViewRotation) * mult * 500 + vect(0,0,220) + 40 * VRand();

        // scale it based on the mass
        velscale = FClamp(CarriedDecoration.Mass / 20.0, 1.0, 40.0);

        CarriedDecoration.Velocity /= velscale;
        dropVect = Location + (CarriedDecoration.CollisionRadius + CollisionRadius + 4) * X;
        dropVect.Z += BaseEyeHeight;
    }

    // is anything blocking the drop point? (like thin doors)
    if (FastTrace(dropVect))
    {
        CarriedDecoration.SetCollision(True, True, True);
        CarriedDecoration.bCollideWorld = True;

        // check to see if there's space there
        extent.X = CarriedDecoration.CollisionRadius;
        extent.Y = CarriedDecoration.CollisionRadius;
        extent.Z = 1;
        hitActor = Trace(HitLocation, HitNormal, dropVect, CarriedDecoration.Location, True, extent);
        CarriedDecoration = None;

        if ((hitActor == None) && dec.SetLocation(dropVect)) {
            bSuccess = True;
        }
        else
        {
            CarriedDecoration = dec;
            CarriedDecoration.SetCollision(False, False, False);
            CarriedDecoration.bCollideWorld = False;
        }
    }

    // if we can drop it here, then drop it
    if (bSuccess)
    {
        FinishDrop(dec);
    }
    else
    {
        // otherwise, don't drop it and display a message
        CarriedDecoration.SetLocation(origLoc);
        ForcePutCarriedDecorationInHand();
        ClientMessage(CannotDropHere);
    }
}

function FinishDrop(Decoration dec)
{
    dec.SetCollision(True, True, True);
    dec.bCollideWorld = True;

    dec.bWasCarried = True;
    dec.SetBase(None);
    dec.SetPhysics(PHYS_Falling);
    dec.Instigator = Self;

    // turn off translucency
    dec.Style = dec.Default.Style;
    dec.bUnlit = dec.Default.bUnlit;
    if (dec.IsA('DeusExDecoration'))
        DeusExDecoration(dec).ResetScaleGlow();
}

function bool SetBasedPawnSize(float newRadius, float newHeight)
{
    local bool success, oldWaterZone;
    local Decoration dec;
    dec = CarriedDecoration;
    CarriedDecoration = None;

    oldWaterZone = Region.Zone.bWaterZone;
    success = Super.SetBasedPawnSize(newRadius, newHeight);

    if(dec != None) {
        if(Region.Zone.bWaterZone && !oldWaterZone) {
            CarriedDecoration = dec;
            DropDecoration();
        } else {
            CarriedDecoration = dec;
            ForcePutCarriedDecorationInHand();
        }
    }
    return success;
}


event TravelPostAccept()
{
    Super.TravelPostAccept();
    if(bCrouchOn && bToggleCrouch && !flagBase.GetBool('PlayerTraveling')) {
        bWasCrouchOn = false;
        bDuck = 1;
    }
}


exec function ToggleAutorun()
{
    bAutorun = !bAutorun;
    autorunTime = Level.TimeSeconds;
}

event PlayerInput( float DeltaTime )
{
    if (!InConversation()) {
        if(bAutorun) {
            if(aBaseY == 0 || autorunTime > Level.TimeSeconds-1) {
                aBaseY = 3000;
            } else {
                bAutorun = false;
            }
        }
        Super.PlayerInput(DeltaTime);
    }
}

exec function RemoveBeltItem()
{
    RemoveObjectFromBelt(InHand);
}

exec function AllSkillPoints()
{
    if (!bCheatsEnabled)
        return;

    SkillPointsTotal = 999999;
    SkillPointsAvail = 999999;
}

exec function QuickSave()
{
    local DeusExLevelInfo info;
    local int slot;

    if( !class'DXRAutosave'.static.AllowManualSaves(self) ) return;

    info = GetLevelInfo();

    //Same logic from DeusExPlayer, so we can add a log message if the quick save succeeded or not
    if (((info != None) && (info.MissionNumber < 0)) ||
        ((IsInState('Dying')) || (IsInState('Paralyzed')) || (IsInState('Interpolating'))) ||
        (dataLinkPlay != None) || (Level.Netmode != NM_Standalone))
    {
        ClientMessage("Cannot quick save during infolink!",, true);
    } else {
        class'DXRAutosave'.static.UseSaveItem(self);
        slot = GetQuickSave(true);
        if(info==None) SaveGame(slot, QuickSaveGameTitle);
        else SaveGame(slot, QuickSaveGameTitle @ info.MissionLocation);
        ClientMessage("Quick Saved",, true);
    }
}

function QuickLoadConfirmed()
{
   if (Level.Netmode != NM_Standalone)
      return;
    if(class'MenuChoice_LoadLatest'.default.enabled) {
        LoadLatestConfirmed();
    } else {
        LoadGame(GetQuickSave(false));
    }
}

exec function LoadLatest()
{
   //Don't allow in multiplayer.
    if (Level.Netmode != NM_Standalone)
        return;

    if (DeusExRootWindow(rootWindow) != None)
        DeusExRootWindow(rootWindow).ConfirmLoadLatest();
}

function int GetQuickSave(bool oldest)
{
    local int i;
    i = GetSaveSlotByTimestamp(oldest, -5, 0, oldest);
    if(i==-9999) i = -1;
    return i;
}

function LoadLatestConfirmed()
{
    local int saveIndex;

    if (Level.Netmode != NM_Standalone)
        return;

    saveIndex = GetSaveSlotByTimestamp(false, -6, 9999999);
    if(saveIndex != -9999) {
        LoadGame(saveIndex);
    }
}

function int GetSaveSlotByTimestamp(bool oldest, int start, int end, optional bool getEmpty)
{
    local int saveIndex;
    local DeusExSaveInfo saveInfo;
    local GameDirectory saveDir;
    local int winningYear, winningTime, winningSave, time; // split the year into its own int so we don't have to worry about integer overflow
    local bool isWinner;

    saveDir = GetSaveGameDirectory();
    winningSave = -9999;
    if(oldest) winningYear = 999999999; // shout-outs to anyone still playing in the year 999999999

    for(saveIndex=start; saveIndex<saveDir.GetDirCount() && saveIndex<end; saveIndex++)
    {
        if(saveIndex == -2 || saveIndex == -4 || saveIndex == 0) continue; // slots -2 and -4 are broken for some reason
        if(saveIndex < 0) {
            saveInfo = saveDir.GetSaveInfo(saveIndex);
            if (saveInfo == None && getEmpty) return saveIndex; // this only works if saveIndex < 0
        } else {
            saveInfo = saveDir.GetSaveInfoFromDirectoryIndex(saveIndex);
        }
        if (saveInfo == None) continue;

        time = saveInfo.Second + saveInfo.Minute*60 + saveInfo.Hour*3600 + saveInfo.Day*86400 + saveInfo.Month*2678400;

        if(oldest) isWinner = saveInfo.Year < winningYear || (saveInfo.Year == winningYear && time < winningTime);
        else isWinner = saveInfo.Year > winningYear || (saveInfo.Year == winningYear && time > winningTime);

        if(isWinner) {
            winningYear = saveInfo.Year;
            winningTime = time;
            winningSave = saveInfo.DirectoryIndex;
        }

        saveDir.DeleteSaveInfo(saveInfo);
    }

    CriticalDelete(saveDir);

    return winningSave;
}

function GameDirectory GetSaveGameDirectory()
{
    local GameDirectory saveDir;

    // Create our Map Directory class
    saveDir = CreateGameDirectoryObject();
    saveDir.SetDirType(saveDir.EGameDirectoryTypes.GD_SaveGames);
    saveDir.GetGameDirectory();

    return saveDir;
}

exec function SaveGameCmd(int saveIndex, optional String saveDesc)
{
    local DeusExSaveInfo saveInfo;
    local GameDirectory saveDir;
    local int i;

    // saving to slot 0 asks the native code to look for an empty slot, but it doesn't search beyond slot 1000 https://github.com/Die4Ever/deus-ex-randomizer/issues/891
    if(saveIndex == 0) {
        saveDir = GetSaveGameDirectory();
        for(i=1; i<999999; i++) {
            saveInfo = saveDir.GetSaveInfo(i);
            if(saveInfo == None) {
                saveIndex = i;
                break;
            }
            saveDir.DeleteSaveInfo(saveInfo);
        }
        CriticalDelete(saveDir);
    }
    SaveGame(saveIndex, saveDesc);
}

exec function Inv() // INVisible and INVincible
{
    if (bDetectable == false && ReducedDamageType == 'All') { // only toggle off if both are on
        Invisible(false);
        God();
    } else {
        if (bDetectable)
            Invisible(true);
        if (ReducedDamageType != 'All')
            God();
    }
}

exec function Tcl() // toggle clipping, name borrowed from Gamebryo
{
    if (bCollideWorld) {
        Ghost();
    } else {
        Walk();
        ClientMessage("You feel corporeal");
    }
}

exec function PlayerLoc()
{
    ClientMessage("Player location: (" $ Location.x $ ", " $ Location.y $ ", " $ Location.z $ ")");
}

exec function PlayerRot()
{
    ClientMessage("Player rotation: (" $ Rotation.pitch $ ", " $ Rotation.yaw $ ", " $ Rotation.roll $ ")");
}

exec function LootActions()
{
    local string lootActions, msg;
    local int idx;

    lootActions = class'DataStorage'.static.GetObj(GetDXR()).GetConfigKey("loot_actions");

    // basically just adds a space after every comma
    lootActions = Mid(lootActions, 1);
    while (lootActions != "") {
        idx = InStr(lootActions, ",");
        msg = msg $ Left(lootActions, idx) $ ", ";
        lootActions = Mid(lootActions, idx + 1);
    }
    msg = Left(msg, Len(msg) - 2);

    ClientMessage("Loot actions: " $ msg);
}

function bool ConsumableWouldHelp(Inventory item) {
    if (health < default.health) {
        if (MedKit(item) != None || SoyFood(item) != None || Candybar(item) != None || Sodacan(item) != None) {
            return true;
        }
        if (HealingItem(item) != None && HealingItem(item).health > 0) {
            return true;
        }
    }

    if (energy < default.energy) {
        if (BioElectricCell(item) != None) {
            return true;
        }
        if (HealingItem(item) != None && HealingItem(item).energy > 0) {
            return true;
        }
    }

    return false;
}


// ----------------------------------------------------------------------
// InvokeUIScreen()
//
// Calls DeusExRootWindow::InvokeUIScreen(), but first make sure
// a modifier (Alt, Shift, Ctrl) key isn't being held down.
// DXRando: how about, no? fix alt+tab bug where the RootWindow still thinks the alt key is held down
// ----------------------------------------------------------------------

function InvokeUIScreen(Class<DeusExBaseWindow> windowClass)
{
    local DeusExRootWindow root;
    local Window w;
    root = DeusExRootWindow(rootWindow);
    if (root != None)
    {
        //if ( root.IsKeyDown( IK_Alt ) || root.IsKeyDown( IK_Shift ) || root.IsKeyDown( IK_Ctrl ))
        //    return;

        root.InvokeUIScreen(windowClass);
    }
}

function PreTravel()
{
    local DeusExRootWindow root;

    root = DeusExRootWindow(rootWindow);

    //Opening URLs triggers pretravel, but we aren't actually traveling, so don't
    if (class'DXRando'.default.dxr!=None && class'DXRando'.default.dxr.bIsOpeningURL) return;

    //Don't clear the stack if the top of the stack is the Credits.
    //We're pretraveling as part of the DestroyWindow call chain
    if (root!=None && CreditsWindow(root.GetTopWindow())==None){
        root.ClearWindowStack();
    }

    //Disable autorun
    bAutorun=False;

    if (inHand!=None && inHand.IsA('DeusExWeapon'))
    {
        //Turn the laser off to prevent the laser spot from sticking around
        //when you come back.  Maybe it would be better to just directly
        //remove the LaserSpot's, but this is a simple solution for now.
        if (class'MenuChoice_AutoLaser'.default.enabled){
            DeusExWeapon(inHand).LaserOff();
        }
    }

    Super.PreTravel();
}

exec function BuySkills()
{
    // First turn off scores if we're heading into skill menu
    if ( !bBuySkills )
        ClientTurnOffScores();

    bBuySkills = !bBuySkills;
    if (bBuySkills){
        bUpgradeAugs=False;
    }
    BuySkillSound( 2 );
}

exec function UpgradeAugs()
{
    // First turn off scores if we're heading into aug menu
    if ( !bUpgradeAugs )
        ClientTurnOffScores();

    bUpgradeAugs = !bUpgradeAugs;
    if (bUpgradeAugs){
        bBuySkills=False;
    }
    BuySkillSound( 2 );
}

exec function AugAdd(class<Augmentation> aWantedAug)
{ // this works better than vanilla's for augs that aren't part of the default set
    if (!bCheatsEnabled)
        return;
    class'DXRAugmentations'.static.AddAug(self, aWantedAug, 1);
}

//Copied from vanilla
exec function ActivateBelt(int objectNum)
{
    local DeusExRootWindow root;

    if (RestrictInput())
        return;

    if (bBuySkills || bUpgradeAugs) //This used to have a check for multiplayer as well
    {
        root = DeusExRootWindow(rootWindow);
        if ( root != None )
        {
            if ( root.hud.hms.OverrideBelt( Self, objectNum ))
                return;
        }
    }

    if (CarriedDecoration == None)
    {
        root = DeusExRootWindow(rootWindow);
        if (root != None)
            root.ActivateObjectInBelt(objectNum);
    }
}

function CompleteBingoGoal(PlayerDataItem data, int x, int y)
{
    local string event;
    local int progress, max;

    data.GetBingoSpot(x, y, event,, progress, max);
    while (progress < max) {
        class'DXREventsBase'.static.MarkBingo(event);
        progress++;
    }
}

exec function BingoGoal(int x, int y)
{
    CompleteBingoGoal(class'PlayerDataItem'.static.GiveItem(self), x, y);
}

exec function Bingo(int line)
{
    local PlayerDataItem data;

    data = class'PlayerDataItem'.static.GiveItem(self);
    if (line >= 0 && line < 5) {
        CompleteBingoGoal(data, line, 0);
        CompleteBingoGoal(data, line, 1);
        CompleteBingoGoal(data, line, 2);
        CompleteBingoGoal(data, line, 3);
        CompleteBingoGoal(data, line, 4);
    } else if (line >= 5 && line < 10) {
        CompleteBingoGoal(data, 0, line - 5);
        CompleteBingoGoal(data, 1, line - 5);
        CompleteBingoGoal(data, 2, line - 5);
        CompleteBingoGoal(data, 3, line - 5);
        CompleteBingoGoal(data, 4, line - 5);
    } else if (line == 10) {
        CompleteBingoGoal(data, 0, 0);
        CompleteBingoGoal(data, 1, 1);
        CompleteBingoGoal(data, 2, 2);
        CompleteBingoGoal(data, 3, 3);
        CompleteBingoGoal(data, 4, 4);
    } else if (line == 11) {
        CompleteBingoGoal(data, 0, 4);
        CompleteBingoGoal(data, 1, 3);
        CompleteBingoGoal(data, 2, 2);
        CompleteBingoGoal(data, 3, 1);
        CompleteBingoGoal(data, 4, 0);
    }
}

exec function AllBingos()
{
    local PlayerDataItem data;
    local int x, y;

    data = class'PlayerDataItem'.static.GiveItem(self);
    for (x = 0; x < 5; x++) {
        for (y = 0; y < 5; y++) {
            CompleteBingoGoal(data, x, y);
        }
    }
}

state CheatFlying
{
ignores SeePlayer, HearNoise, Bump, TakeDamage;
    event PlayerTick( float DeltaTime )
    {
        super.PlayerTick(DeltaTime);
        DrugEffects(deltaTime); //Drunk and on drugs happy funtime
        Bleed(deltaTime);   //Make blood drops happen
        HighlightCenterObject();  //Make object highlighting actually happen
        UpdateDynamicMusic(deltaTime); //Make sure the music can still change states while flying around
        UpdateWarrenEMPField(deltaTime);
        MultiplayerTick(deltaTime); //UpdateInHand, Poison, burning, shields, etc
        FrobTime += deltaTime; //Make sure we keep track of how long you've been highlighting things

        CheckActiveConversationRadius(); // Check if player has walked outside a first-person convo.
        CheckActorDistances(); // Check if all the people involved in a conversation are in a reasonable radius

        UpdateTimePlayed(deltaTime); //The timer for the game save

    }
}

defaultproperties
{
    SkillPointsTotal=6575
    SkillPointsAvail=6575
    LastBrowsedAugPage=-1 //OAT, 1/12/24: Hack so backtracking levels doesn't sometimes forget which page you saved last.
    LastBrowsedAug=-1 //OAT, same idea here.
}

// ---
