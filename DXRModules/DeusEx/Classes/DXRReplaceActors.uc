class DXRReplaceActors extends DXRActorsBase transient;

function PostFirstEntry()
{
    Super.PostFirstEntry();
    ReplaceActors();
}

function ReplaceActors()
{
    local Actor a;
    foreach AllActors(class'Actor', a) {
        if( #var(prefix)InformationDevices(a) != None ) {
            ReplaceInformationDevice(#var(prefix)InformationDevices(a));
        }
        else if( #var(prefix)AllianceTrigger(a) != None ) {
            ReplaceAllianceTrigger(#var(prefix)AllianceTrigger(a));
        }
        else if( #var(prefix)ShakeTrigger(a) != None ) {
            ReplaceShakeTrigger(#var(prefix)ShakeTrigger(a));
        }
        else if( #var(prefix)ClothesRack(a) != None ) {
            ReplaceClothesRack(#var(prefix)ClothesRack(a));
        }
        else if( a.class==class'#var(prefix)Toilet') {
            ReplaceToilet(#var(prefix)Toilet(a));
        }
        else if( a.class==class'#var(prefix)Toilet2') {
            ReplaceToilet2(#var(prefix)Toilet2(a));
        }
        else if( #var(prefix)ShowerFaucet(a) != None ) {
            ReplaceShowerFaucet(#var(prefix)ShowerFaucet(a));
        }
        else if( #var(prefix)ShipsWheel(a) != None ) {
            ReplaceShipsWheel(#var(prefix)ShipsWheel(a));
        }
        else if( a.class==class'#var(prefix)WaterCooler' ) {
            ReplaceWaterCooler(#var(prefix)WaterCooler(a));
        }
        else if( a.class==class'#var(prefix)WaterFountain' ) {
            ReplaceWaterFountain(#var(prefix)WaterFountain(a));
        }
        else if( #var(prefix)Keypad(a) != None ) {
            ReplaceKeypad(#var(prefix)Keypad(a));
        }
        else if( #var(prefix)WHPiano(a) != None ) {
            ReplacePiano(#var(prefix)WHPiano(a));
        }
        else if( #var(prefix)MissionEndgame(a) != None && !#defined(hx) ) {
            ReplaceMissionEndgame(#var(prefix)MissionEndgame(a));
        }
#ifdef revision
        else if( RevisionMissionEndgame(a) != None) {
            ReplaceRevMissionEndgame(RevisionMissionEndgame(a));
        }
        else if( RevisionMissionIntro(a) != None) {
            ReplaceRevMissionIntro(RevisionMissionIntro(a));
        }
#endif
        else if( #var(prefix)MissionIntro(a) != None ) {
            ReplaceMissionIntro(#var(prefix)MissionIntro(a));
        }
        else if( #var(prefix)Poolball(a) != None ) {
            ReplacePoolball(#var(prefix)Poolball(a));
        }
        else if( #var(prefix)Pinball(a) != None ) {
            ReplaceGenericDecoration(a,class'DXRPinball');
        }
        else if( #var(prefix)Trashbag(a) != None ) {
            ReplaceGenericDecoration(a,class'DXRTrashbag');
        }
        else if( #var(prefix)Trashbag2(a) != None ) {
            ReplaceGenericDecoration(a,class'DXRTrashbag2');
        }
        else if( #var(prefix)ComputerPublic(a) != None ) {
            ReplaceComputerPublic(#var(prefix)ComputerPublic(a));
        }
#ifndef hx
        else if( #var(prefix)ComputerPersonal(a) != None ) {
            ReplaceComputerPersonal(#var(prefix)ComputerPersonal(a));
        }
        else if( #var(prefix)ComputerSecurity(a) != None ) {
            ReplaceComputerSecurity(#var(prefix)ComputerSecurity(a));
        }
        else if( #var(prefix)ATM(a) != None ) {
            ReplaceATM(#var(prefix)ATM(a));
        }
#endif
#ifdef hx
        else if( #var(prefix)Binoculars(a) != None ) {
            ReplaceBinoculars(#var(prefix)Binoculars(a));
        }
#endif
        else if( #var(prefix)Faucet(a) != None ) {
            ReplaceFaucet(#var(prefix)Faucet(a));
        }
        else if( #var(prefix)BarrelFire(a) != None ) {
            ReplaceGenericDecoration(a,class'DXRBarrelFire');
        }
        else if( #var(prefix)BoneSkull(a) != None ) {
            ReplaceGenericDecoration(a,class'DXRSkull');
        }
        else if( #var(prefix)BoneFemur(a) != None ) {
            ReplaceGenericDecoration(a,class'DXRFemur');
        }
        else if( a.class==class'#var(prefix)VendingMachine' ) {
            ReplaceVendingMachine(#var(prefix)VendingMachine(a));
        }
#ifdef gmdx
        else if( WeaponGEPGun(a) != None ) {
            ReplaceGepGun(WeaponGEPGun(a));
        }
#endif
        //Leave this at the end of the list (or at least make sure there are no containers after it)
        else if( #var(prefix)Containers(a) != None ) {
            ReplaceContainerContents(#var(prefix)Containers(a));
        }
    }
}
#ifdef revision
function class<Actor> ReplaceClassName(class<Actor> inv)
#else
function class<inventory> ReplaceClassName(class<inventory> inv)
#endif
{
    switch(inv){
#ifdef hx
        case class'#var(prefix)Binoculars':
            return class'DXRBinoculars';
#endif
        default:
            return inv;
    }
    return inv;
}

function ReplaceContainerContents(#var(prefix)Containers a)
{
    local int i;

    a.contents = ReplaceClassName(a.contents);
    a.content2 = ReplaceClassName(a.content2);
    a.content3 = ReplaceClassName(a.content3);
}


function ReplaceInformationDevice(#var(prefix)InformationDevices a)
{
    local DXRInformationDevices n;
    n = DXRInformationDevices(SpawnReplacement(a, class'DXRInformationDevices'));
    if(n == None)
        return;

    if (#defined(hx)){
        //HX bingo reading goals get marked when added to vault.  Just add all of them.
        n.bAddToVault = True;
    } else {
        n.bAddToVault = a.bAddToVault;
    }
    n.TextPackage = a.TextPackage;
    n.textTag = a.textTag;
    n.imageClass = a.imageClass;
    n.msgNoText = a.msgNoText;
    n.ImageLabel = a.ImageLabel;
    n.AddedToDatavaultLabel = a.AddedToDatavaultLabel;
#ifdef revision
    n.TextPackage = a.TextPackage;
#endif
    ReplaceDeusExDecoration(a, n);

    a.Destroy();
}

function ReplaceKeypad(#var(prefix)Keypad a)
{
    local DXRKeypad n;
#ifndef hx
    if(a.IsA('DXRKeypad'))
        return;

    n = DXRKeypad(SpawnReplacement(a, class'DXRKeypad'));
    if(n==None)
        return;
    n.validCode = a.validCode;
    n.successSound = a.successSound; //I doubt this is ever changed from default, but let's be safe
    n.failureSound = a.failureSound; //I doubt this is ever changed from default, but let's be safe
    n.FailEvent = a.FailEvent;
    n.bToggleLock = a.bToggleLock;
    n.hackStrength = a.hackStrength;
    n.initialhackStrength = a.initialhackStrength;
    n.bHackable = a.bHackable;

    //Make it look like the right kind of keypad
    n.Mesh = a.Mesh;
    n.SetCollisionSize(a.CollisionRadius,a.CollisionHeight);

    ReplaceDeusExDecoration(a, n);
    a.Destroy();
#endif
}

function ReplaceFaucet(#var(prefix)Faucet a)
{
    local DXRFaucet n;
    local DeusExPlayer dxp;
    if(a.IsA('DXRFaucet'))
        return;

    n = DXRFaucet(SpawnReplacement(a, class'DXRFaucet'));
    if(n==None)
        return;
    ReplaceDeusExDecoration(a, n);
    n.bOpen = a.bOpen;
    n.waterGen.bSpewing = a.waterGen.bSpewing;
    n.waterGen.SoundVolume = a.waterGen.SoundVolume;
    a.Destroy();
}


function ReplacePiano(#var(prefix)WHPiano a)
{
    local DXRPiano n;
    if(a.IsA('DXRPiano'))
        return;

    n = DXRPiano(SpawnReplacement(a, class'DXRPiano'));
    if(n==None)
        return;
    ReplaceDeusExDecoration(a, n);
    n.HitPoints=n.Default.HitPoints; //Since the new piano has more hitpoints than the original...
    a.Destroy();
}

function ReplaceBinoculars(#var(prefix)Binoculars a)
{
    local DXRBinoculars n;
    if(a.IsA('DXRBinoculars'))
        return;

    n = DXRBinoculars(SpawnReplacement(a, class'DXRBinoculars'));
    if(n==None)
        return;
    ReplacePickup(a, n);
    a.Destroy();
}

function ReplaceGEPGun(WeaponGEPGUN a)
{
#ifndef hx
    local GMDXGepGun n;
    n = GMDXGepGun(SpawnReplacement(a, class'GMDXGepGun'));
    if(n == None)
        return;

    ReplaceWeapon(a, n);
    a.Destroy();
#endif
}

function ReplaceAllianceTrigger(#var(prefix)AllianceTrigger a)
{
    local DXRAllianceTrigger n;
    local int i;
    n = DXRAllianceTrigger(SpawnReplacement(a, class'DXRAllianceTrigger'));
    if(n == None)
        return;

    n.Alliance = a.Alliance;
    for(i=0; i<ArrayCount(a.Alliances); i++) {
        n.Alliances[i].AllianceName = a.Alliances[i].AllianceName;
        n.Alliances[i].AllianceLevel = a.Alliances[i].AllianceLevel;
        n.Alliances[i].bPermanent = a.Alliances[i].bPermanent;
    }

    ReplaceTrigger(a, n);
    a.Destroy();
}

function ReplaceShakeTrigger(#var(prefix)ShakeTrigger a)
{
    local DXRShakeTrigger n;
    local int i;
    n = DXRShakeTrigger(SpawnReplacement(a, class'DXRShakeTrigger'));
    if(n == None)
        return;

    n.shakeTime = a.shakeTime;
    n.shakeRollMagnitude = a.shakeRollMagnitude;
    n.shakeVertMagnitude = a.shakeVertMagnitude;

    ReplaceTrigger(a, n);
    a.Destroy();
}

function ReplaceShipsWheel(#var(prefix)ShipsWheel a)
{
    local DXRShipsWheel n;
    n = DXRShipsWheel(SpawnReplacement(a, class'DXRShipsWheel'));
    if(n == None)
        return;

    // probably doesn't need this since it's all defaults
    //ReplaceDecoration(a, n);

    a.Destroy();
}

function ReplaceWaterFountain(#var(prefix)WaterFountain a)
{
    local DXRWaterFountain n;
    n = DXRWaterFountain(SpawnReplacement(a, class'DXRWaterFountain'));
    if(n == None)
        return;

    // probably doesn't need this since it's all defaults
    //ReplaceDecoration(a, n);

    a.Destroy();
}

function ReplaceWaterCooler(#var(prefix)WaterCooler a)
{
    local DXRWaterCooler n;
    n = DXRWaterCooler(SpawnReplacement(a, class'DXRWaterCooler'));
    if(n == None)
        return;

    // probably doesn't need this since it's all defaults
    //ReplaceDecoration(a, n);

    a.Destroy();
}

function ReplaceVendingMachine(#var(prefix)VendingMachine a)
{
    local DXRVendingMachine n;
    n = DXRVendingMachine(SpawnReplacement(a, class'DXRVendingMachine'));
    if(n == None)
        return;

    n.SkinColor=a.SkinColor;
    n.PreBeginPlay();
    n.BeginPlay();
    // probably doesn't need this since it's all defaults
    //ReplaceDecoration(a, n);

    a.Destroy();
}

function ReplacePoolball(#var(prefix)Poolball a)
{
    local DXRPoolball n;
    n = DXRPoolball(SpawnReplacement(a, class'DXRPoolball'));
    if(n == None)
        return;

    n.SkinColor = a.SkinColor;
    n.Skin = a.Skin;
    // probably doesn't need this since it's all defaults
    //ReplaceDecoration(a, n);

    a.Destroy();
}

function ReplaceGenericDecoration(Actor a, class<Actor> newClass)
{
    local Actor n;

    n = SpawnReplacement(a, newClass);

    if (#var(DeusExPrefix)Decoration(a)!=None){
        ReplaceDeusExDecoration(#var(DeusExPrefix)Decoration(a),#var(DeusExPrefix)Decoration(n));
    }

    if(n == None)
        return;

    a.Destroy();
}

function ReplaceToilet(#var(prefix)Toilet a)
{
    local DXRToilet n;
    n = DXRToilet(SpawnReplacement(a, class'DXRToilet'));
    if(n == None)
        return;

    n.SkinColor = a.SkinColor;
    n.Skin = a.Skin;
    // probably doesn't need this since it's all defaults
    //ReplaceDecoration(a, n);

    a.Destroy();
}

function ReplaceToilet2(#var(prefix)Toilet2 a)
{
    local DXRToilet2 n;
    n = DXRToilet2(SpawnReplacement(a, class'DXRToilet2'));
    if(n == None)
        return;

    n.SkinColor = a.SkinColor;
    n.Skin = a.Skin;
    // probably doesn't need this since it's all defaults
    //ReplaceDecoration(a, n);
#ifdef hx
    n.PrecessorName = a.PrecessorName;
#endif
    a.Destroy();
}

function ReplaceShowerFaucet(#var(prefix)ShowerFaucet a)
{
    local DXRShowerFaucet n;
    local int i;
    n = DXRShowerFaucet(SpawnReplacement(a, class'DXRShowerFaucet'));
    if(n == None)
        return;

    n.Skin = a.Skin;
    for(i=0; i<ArrayCount(n.waterGen); i++) {
        n.waterGen[i] = a.waterGen[i];
        a.waterGen[i] = None;
    }
    for(i=0; i<ArrayCount(n.sprayOffsets); i++) {
        n.sprayOffsets[i] = a.sprayOffsets[i];
    }
    // probably doesn't need this since it's all defaults
    //ReplaceDecoration(a, n);
#ifdef hx
    n.PrecessorName = a.PrecessorName;
#endif
    a.Destroy();
}

function ReplaceClothesRack(#var(prefix)ClothesRack a)
{
    local DXRClothesRack n;
    n = DXRClothesRack(SpawnReplacement(a, class'DXRClothesRack'));
    if(n == None)
        return;

    n.SkinColor = a.SkinColor;
    n.Skin = a.Skin;
    // probably doesn't need this since it's all defaults
    //ReplaceDecoration(a, n);
#ifdef hx
    n.PrecessorName = a.PrecessorName;
#endif
    a.Destroy();
}

function ReplaceTrigger(#var(prefix)Trigger a, #var(prefix)Trigger n)
{
    n.TriggerType = a.TriggerType;
    n.Message = a.Message;
    n.bTriggerOnceOnly = a.bTriggerOnceOnly;
    n.bInitiallyActive = a.bInitiallyActive;
    n.ClassProximityType = a.ClassProximityType;
    n.RepeatTriggerTime = a.RepeatTriggerTime;
    n.ReTriggerDelay = a.ReTriggerDelay;
    n.TriggerTime = a.TriggerTime;
    n.DamageThreshold = a.DamageThreshold;
    n.TriggerActor = a.TriggerActor;
    n.TriggerActor2 = a.TriggerActor2;
}

function #var(DeusExPrefix)Weapon ReplaceWeapon(#var(DeusExPrefix)Weapon a, #var(DeusExPrefix)Weapon n)
{
    local ScriptedPawn owner;
    local bool bWasDrawn;
    owner = ScriptedPawn(a.Owner);
    if(owner != None && owner.Weapon == a) {
        bWasDrawn = true;
    }
    a.Destroy();
    if(owner != None) {
        GiveExistingItem(owner, n);
        if(bWasDrawn) {
            owner.SetupWeapon(true, true);
            owner.SetWeapon(n);
        }
    }
}

function #var(DeusExPrefix)Pickup ReplacePickup(#var(DeusExPrefix)Pickup a, #var(DeusExPrefix)Pickup n)
{
    local ScriptedPawn owner;
    local #var(PlayerPawn) player;
    local bool bWasDrawn;
    owner = ScriptedPawn(a.Owner);
    player = #var(PlayerPawn)(a.Owner);
    a.Destroy();
    if(owner != None) {
        GiveExistingItem(owner, n);
    } else if (player != None) {
        GiveExistingItem(player, n);
    }
}


function ReplaceDeusExDecoration(#var(DeusExPrefix)Decoration a, #var(DeusExPrefix)Decoration n)
{
#ifdef hx
    n.PrecessorName = a.PrecessorName;
    n.bClientHighlight = a.bClientHighlight;
#endif
    n.bInvincible = a.bInvincible;
    n.HitPoints = a.HitPoints;
    n.minDamageThreshold = a.minDamageThreshold;
    n.FragType = a.FragType;
    n.bFlammable = a.bFlammable;
    n.Flammability = a.Flammability;
    n.explosionDamage = a.explosionDamage;
    n.explosionRadius = a.explosionRadius;
    n.bHighlight = a.bHighlight;
    n.ItemArticle = a.ItemArticle;
    n.ItemName = a.ItemName;
    n.bTravel = a.bTravel;
    n.bFloating = a.bFloating;
    n.origRot = a.origRot;
    n.moverTag = a.moverTag;
    n.bCanBeBase = a.bCanBeBase;
    n.bGenerateFlies = a.bGenerateFlies;
    n.pushSoundId = a.pushSoundId;

    ReplaceDecoration(a, n);
}

function ReplaceDecoration(Decoration a, Decoration n)
{
    n.bPushable = a.bPushable;
    n.EffectWhenDestroyed = a.EffectWhenDestroyed;
    /*
var() bool bOnlyTriggerable;
var bool bSplash;
var bool bBobbing;
var bool bWasCarried;
var() sound PushSound;
var const int	 numLandings; // Used by engine physics.
var() class<inventory> contents;
var() class<inventory> content2;
var() class<inventory> content3;
var() sound EndPushSound;
var bool bPushSoundPlaying;

// DEUS_EX AJY
// Converstion Crap
var Float   BaseEyeHeight;
*/
}

function ReplaceMissionEndgame(#var(prefix)MissionEndgame a)
{
    local DXRMissionEndgame n;
    if(DXRMissionEndgame(a) != None) return;

    n = DXRMissionEndgame(SpawnReplacement(a, class'DXRMissionEndgame'));
    if(n == None)
        return;

    a.Destroy();
}

#ifdef revision
function ReplaceRevMissionEndgame(RevisionMissionEndgame a)
{
    //Theoretically, we'd want to replace with a DXRRevMissionEndgame,
    //except that RevJCDentonMale doesn't let you skip to the ending
    //when it's on a RevisionMissionEndgame, so let's not do this for now

    local DXRRevMissionEndgame n;
    local DXRMissionEndgame n2;

    if (dxr.localURL!="ENDGAME4" && dxr.localURL!="ENDGAME4REV"){
        if(DXRRevMissionEndgame(a) != None) return;

        n = DXRRevMissionEndgame(SpawnReplacement(a, class'DXRRevMissionEndgame'));
        if(n == None)
            return;

        a.Destroy();
    } else {
        //if(DXRRevMissionEndgame(a) != None) return;

        n2 = DXRMissionEndgame(SpawnReplacement(a, class'DXRMissionEndgame'));
        if(n2 == None)
            return;

        a.Destroy();
    }
}

function ReplaceRevMissionIntro(RevisionMissionIntro a)
{
    local DXRRevMissionIntro n;

    if(DXRRevMissionIntro(a) != None) return;

    n = DXRRevMissionIntro(SpawnReplacement(a, class'DXRRevMissionIntro'));
    if(n == None)
        return;

    a.Destroy();
}

#endif

function ReplaceMissionIntro(#var(prefix)MissionIntro a)
{
    local DXRMissionIntro n;
    if(DXRMissionIntro(a) != None) return;

    n = DXRMissionIntro(SpawnReplacement(a, class'DXRMissionIntro'));
    if(n == None)
        return;

    a.Destroy();
}

function ReplaceComputerPublic(#var(prefix)ComputerPublic a)
{
    local DXRComputerPublic n;

    n = DXRComputerPublic(SpawnReplacement(a, class'DXRComputerPublic'));
    if(n == None)
        return;

    n.bulletinTag = a.bulletinTag;

    a.Destroy();
}

function ReplaceComputerPersonal(#var(prefix)ComputerPersonal a)
{
    local DXRComputerPersonal n;
    local int i;

    n = DXRComputerPersonal(SpawnReplacement(a, class'DXRComputerPersonal'));
    if(n == None)
        return;

    ReplaceComputers(a,n);

    a.Destroy();
}

function ReplaceComputerSecurity(#var(prefix)ComputerSecurity a)
{
    local DXRComputerSecurity n;
    local int i;

    n = DXRComputerSecurity(SpawnReplacement(a, class'DXRComputerSecurity'));
    if(n == None)
        return;

    ReplaceComputers(a,n);

    for (i=0;i<ArrayCount(n.Views);i++){
        n.Views[i].titleString=a.Views[i].titleString;
        n.Views[i].cameraTag=a.Views[i].cameraTag;
        n.Views[i].turretTag=a.Views[i].turretTag;
        n.Views[i].doorTag=a.Views[i].doorTag;
    }

    a.Destroy();
}

function ReplaceATM(#var(prefix)ATM a)
{
    local DXRATM n;
    local int i;

    n = DXRATM(SpawnReplacement(a, class'DXRATM'));
    if(n == None)
        return;

#ifndef hx
    for (i=0;i<ArrayCount(n.userList);i++){
        n.userList[i].accountNumber=a.userList[i].accountNumber;
        n.userList[i].PIN=a.userList[i].PIN;
        n.userList[i].balance=a.userList[i].balance;
    }
#endif

    n.lockoutDelay=a.lockoutDelay;

    a.Destroy();
}

function ReplaceComputers(#var(prefix)Computers a, #var(prefix)Computers n)
{
    local int i;

    for(i=0;i<ArrayCount(n.specialOptions);i++){
        n.specialOptions[i].Text=a.specialOptions[i].Text;
        n.specialOptions[i].TriggerText=a.specialOptions[i].TriggerText;
        n.specialOptions[i].userName=a.specialOptions[i].userName;
        n.specialOptions[i].TriggerEvent=a.specialOptions[i].TriggerEvent;
        n.specialOptions[i].UnTriggerEvent=a.specialOptions[i].UnTriggerEvent;
        n.specialOptions[i].bTriggerOnceOnly=a.specialOptions[i].bTriggerOnceOnly;
        n.specialOptions[i].bAlreadyTriggered=a.specialOptions[i].bAlreadyTriggered;
    }

    for(i=0;i<ArrayCount(n.userList);i++){
        n.userList[i].userName=a.userList[i].userName;
        n.userList[i].password=a.userList[i].password;
        n.userList[i].accessLevel=a.userList[i].accessLevel;
    }

    n.bOn = a.bOn;
    n.bAnimating=a.bAnimating;
    n.bLockedOut=a.bLockedOut;
    n.lockoutDelay=a.lockoutDelay;
    n.lockoutTime=a.lockoutTime;
    n.lastHackTime=a.lastHackTime;
    n.msgLockedOut=a.msgLockedOut;
    n.nodeName=a.nodeName;
    n.titleString=a.titleString;
    n.titleTexture=a.titleTexture;
    n.TextPackage=a.TextPackage;

    n.ComputerNode=a.ComputerNode;

    n.lastAlarmTime=a.lastAlarmTime;
    n.alarmTimeout=a.alarmTimeout;
    n.CompInUseMsg=a.CompInUseMsg;
}
