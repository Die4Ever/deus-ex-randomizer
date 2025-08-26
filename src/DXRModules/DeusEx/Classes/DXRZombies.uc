class DXRZombies extends DXRActorsBase;

var #var(DeusExPrefix)Carcass carcs[256];
var int num_carcs;
var float times[256], curtime;

function ReEntry(bool IsTravel)
{
    if(curtime~=0) {
        curtime = Level.TimeSeconds;// when updating the game
    }
}

function AnyEntry()
{
    Super.AnyEntry();
    if(dxr.flags.moresettings.reanimation > 0) {
        SetTimer(1.0, true);
    }
}

function Timer()
{
    Super.Timer();
    if(dxr != None && dxr.flags.moresettings.reanimation > 0) {
        CheckCarcasses();
    }
}

function CheckCarcasses()
{
    local int i;
    local #var(DeusExPrefix)Carcass carc;
    local float zombie_time, dog_zombie_time;

    if( dxr.flags.moresettings.reanimation <= 0 ) return;
    curtime += 1;
    zombie_time = dxr.flags.moresettings.reanimation - 5;
    zombie_time = FClamp(zombie_time, 1, 10000);
    dog_zombie_time = zombie_time / 5;

    for(i=0; i < num_carcs; i++) {
        if(CheckReanimateCorpse(carcs[i], times[i])) {
            // compress the array
            num_carcs--;
            carcs[i] = carcs[num_carcs];
            times[i] = times[num_carcs];
            i--;// repeat this iteration
            continue;
        }
    }

    foreach AllActors(class'#var(DeusExPrefix)Carcass', carc) {
        if(carc.Tag != 'ForceZombie') {
            if(#var(prefix)PigeonCarcass(carc) != None || #var(prefix)SeagullCarcass(carc) != None
               || #var(prefix)RatCarcass(carc) != None || #var(prefix)CatCarcass(carc) != None)
            {
                // skip critter carcasses, TODO: maybe find the PawnGenerator and increase its PawnCount so we can have zombie rats and birds without there being infinity of them? or track a maximum number of zombie critters here? cats have an override on the Attacking state
                continue;
            }
            if(carc.bNotDead || carc.bInvincible || carc.bHidden) {
                continue;
            }
        }
        if(carc.bDeleteMe) continue;
        for(i=0; i < num_carcs; i++) {
            if(carcs[i] == carc) {
                break;
            }
        }
        if(carcs[i] != carc) {
            carcs[num_carcs] = carc;
            if(#var(prefix)DobermanCarcass(carc) != None || #var(prefix)MuttCarcass(carc) != None) { // special sauce for dogs
                times[num_carcs] = curtime + dog_zombie_time + (FRand() * dxr.flags.moresettings.reanimation * 0.1);
            } else {
                times[num_carcs] = curtime + zombie_time + (FRand() * dxr.flags.moresettings.reanimation * 0.5);
            }
            carc.MaxDamage = 0.1 * carc.Mass;// easier to destroy carcasses
            num_carcs++;
        }
    }
}

#ifdef injections
function float _GetZombieTime(#var(DeusExPrefix)Carcass carc)
{
    local int i;
    local float zombie_time, dog_zombie_time;

    for(i=0; i < num_carcs; i++) {
        if(carcs[i] == carc) {
            return times[i];
        }
    }

    zombie_time = dxr.flags.moresettings.reanimation - 5;
    zombie_time = FClamp(zombie_time, 1, 10000);
    dog_zombie_time = zombie_time / 5;

    if(#var(prefix)DobermanCarcass(carc) != None || #var(prefix)MuttCarcass(carc) != None) { // special sauce for dogs
        return curtime + dog_zombie_time + FRand()*2;
    } else {
        return curtime + zombie_time + FRand()*10;
    }
}

static function float GetZombieTime(#var(DeusExPrefix)Carcass carc)
{
    local DXRZombies zombies;

    zombies = DXRZombies(Find());
    if(zombies == None) return carc.Level.TimeSeconds + 20;
    return zombies._GetZombieTime(carc);
}

function _SetZombieTime(#var(DeusExPrefix)Carcass carc, float time)
{
    local int i;

    if(dxr.flags.moresettings.reanimation <= 0) return;

    for(i=0; i < num_carcs; i++) {
        if(carcs[i] == carc) {
            times[i] = FMin(times[i], time);
            return;
        }
    }

    carcs[num_carcs] = carc;
    times[num_carcs] = time;
    carc.MaxDamage = 0.1 * carc.Mass;// easier to destroy carcasses
    num_carcs++;
}

static function SetZombieTime(#var(DeusExPrefix)Carcass carc, float time)
{
    local DXRZombies zombies;

    zombies = DXRZombies(class'DXRando'.default.dxr.FindModule(class'DXRZombies'));
    if(zombies == None) return;
    zombies._SetZombieTime(carc, time);
}
#endif

function bool CheckReanimateCorpse(#var(DeusExPrefix)Carcass carc, float time)
{
    // return true to compress the array
    if(carc == None) return true;
    if(carc.bDeleteMe) return true;
    if(!carc.bHidden && carc.bNotDead) return true; //only allow hidden "unconscious" bodies to respawn

    // wait for Zombie Time!
    if(time > curtime) return false;

    return ReanimateCorpse(self, carc);
}

static function string GetPawnClassNameFromCarcass(DXRActorsBase module, class<#var(DeusExPrefix)Carcass> carcClass)
{
    local string livingClassName;
    local int i;

    //For handling special cases that we're too lazy to make unique living classes for
    switch(carcClass){
#ifdef hx
        case class'HXJCDentonCarcass':
#else
        case class'#var(prefix)JCDentonMaleCarcass':
#endif
            return "#var(prefix)JCDouble";
        default:
            //Standard carcass with a matching living class
            //(We should probably strive for this to be the norm)
            //At least in vanilla, all carcasses are the original class name + Carcass
            livingClassName = string(carcClass);
            livingClassName = module.ReplaceText(livingClassName,"NametagCarcass","Carcass");// for our Aug guys

            //Strip everything Carcass onwards (Revision has things like MJ12TroopCarcassA, MJ12TroopCarcassB... )
            i = module.InStr(livingClassName,"Carcass");
            livingClassName = module.Left(livingClassName,i);
            //livingClassName = module.ReplaceText(livingClassName,"Carcass","");
            return livingClassName;
    }
}

static function bool ReanimateCorpse(DXRActorsBase module, #var(DeusExPrefix)Carcass carc, optional String pawnname)
{
    local string livingClassName, origClassName;
    local class<Actor> livingClass;
    local vector respawnLoc;
    local ScriptedPawn sp,otherSP;
    local class<DeusExFragment> fragClass;
    local int i, numFrags;
    local Inventory item, nextItem;
    local name origAllianceName;
    #ifndef vmd
    local DXRFashionManager fashion;
    #endif
    local bool removeItem;
    local string s;

    if(carc==None || carc.bDeleteMe) return False;

    livingClassName = GetPawnClassNameFromCarcass(module, carc.class);
    livingClass = module.GetClassFromString(livingClassName,class'ScriptedPawn',true);

#ifdef revision
    if (livingClass == None) {
        origClassName=livingClassName;
        i = InStr(livingClassName, ".");
        if( i != -1 ) {
            livingClassName = Mid(livingClassName,i+1);
            livingClassName = "DeusEx."$livingClassName;
            livingClass = module.GetClassFromString(livingClassName,class'ScriptedPawn',true);

            if (livingClass==None){
                module.err("failed to load class "$origClassName); //The class we just tried to load will be printed outside ifdef
            }
        }
    }
#endif


    if (livingClass==None){
        module.err("failed to load class "$livingClassName); //GetClassFromString would normally print this
        module.warning("ReanimateCorpse " $ carc $ " failed livingClass==None");
        return False;
    }

    respawnLoc = carc.Location;
    respawnLoc.Z += livingClass.Default.CollisionHeight;

    sp = ScriptedPawn(carc.Spawn(livingClass,,,respawnLoc,carc.Rotation));

    if (sp==None){
        module.warning("ReanimateCorpse " $ carc $ " failed sp==None");
        return False;
    }

    if(pawnname != "") {
        sp.FamiliarName = pawnname;
        sp.UnfamiliarName = sp.FamiliarName;
    } else {
        if(#defined(injections)) {
            s = ReplaceText(carc.itemName, " (Dead)", "");
            s = ReplaceText(s, " (Dead?)", "");
            sp.FamiliarName = s $ "'s Zombie";
        }
        else {
            sp.FamiliarName = sp.FamiliarName $ " Zombie";
        }
        sp.UnfamiliarName = sp.FamiliarName;
    }
    sp.bInvincible = false; // If they died, they can't have been invincible
    sp.bImportant = false; // already marked as dead, don't overwrite or destroy on travel
    sp.bDetectable = true;
    sp.bIgnore = false;
    sp.BindName = "";// Zombies don't talk
    sp.BarkBindName = "";

    sp.DrawScale = carc.DrawScale;
    sp.SetCollisionSize(sp.CollisionRadius*sp.DrawScale, sp.CollisionHeight*sp.DrawScale);
    sp.Fatness = carc.Fatness;

    //Clear out initial inventory (since that should all be in the carcass)
    for (i=0;i<ArrayCount(sp.InitialInventory);i++){
        sp.InitialInventory[i].Inventory=None;
    }

    for (i=0;i<8;i++){
        if (#defined(hx)){
            //Make the alliance neutral, since we can't clear it entirely
            sp.ChangeAlly(sp.InitialAlliances[i].AllianceName,0.0,);
        }
        sp.InitialAlliances[i].AllianceName='';
        sp.InitialAlliances[i].AllianceLevel=0;
    }
    sp.InitialAlliances[0].AllianceName = 'Player';
    sp.InitialAlliances[0].AllianceLevel = -1;

    if (#defined(hx)){
        //HX will have already initialized the pawn.
        //Remove their initialized inventory
        //They'll be given their zombie swipe later
        for(item = sp.Inventory; item != None; item = nextItem)
        {
            nextItem = item.Inventory;
            sp.DeleteInventory(item);
            item.Destroy();
        }

    }

    sp.bInitialized = false; //For HX
    sp.InitializePawn();

    //Make it hostile to EVERYONE.  This thing has seen the other side
    origAllianceName = sp.Alliance;
    sp.SetAlliance('Resurrected');
    sp.ChangeAlly('Resurrected', 1, true, false);
    if (#defined(hx)){
        //Clear the old alliance, since ChangeAlly forces same alliance
        //to always be friendly
        sp.ChangeAlly(origAllianceName,0.0,);
    }
    module.HateEveryone(sp, 'MrH');
    module.RemoveFears(sp);
    if(#var(prefix)Animal(sp) != None) {
        #var(prefix)Animal(sp).bFleeBigPawns = false;
    }
    sp.MinHealth = 0;
    sp.ResetReactions();
    sp.bCanStrafe = false;// messes with melee attack animations, especially on commandos

    if(sp.Intelligence==BRAINS_HUMAN) {
        sp.Intelligence = BRAINS_MAMMAL;
    }
    sp.RaiseAlarm = RAISEALARM_Never;

    //Transfer inventory from carcass back to the pawn
    for(item = carc.Inventory; item != None; item = nextItem)
    {
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
    }

    #ifndef vmd
    if(#var(prefix)JCDouble(sp)!=None || #var(prefix)PaulDenton(sp)!=None) {
        foreach sp.AllActors(class'DXRFashionManager', fashion) { break; }
        i = 0;
        if(#var(prefix)PaulDenton(sp)!=None) i = 1;
        if(fashion!=None) fashion.ApplyClothing(sp, i);
    }
    #endif

    //Give the resurrected guy a zombie swipe (a guaranteed melee weapon)
    module.GiveItem(sp,class'WeaponZombieSwipe');
    sp.bKeepWeaponDrawn=True;

    //Pop out an appropriate fragment type
    if (carc.bNotDead){
        if (carc.bHidden){
            //Hidden "unconscious" bodies dig out of the ground
            fragClass = class'DirtFragment';
            numFrags=20;
        }
    } else {
        //Dead bodies explode meat
        fragClass = class'FleshFragment';
        numFrags=10;
    }

    if (fragClass!=None && numFrags>0){
        for (i=0; i<numFrags; i++)
        {
            if (FRand() > 0.2)
                carc.spawn(fragClass,,,carc.Location);
        }
    }

    carc.Destroy();

    return True;
}
