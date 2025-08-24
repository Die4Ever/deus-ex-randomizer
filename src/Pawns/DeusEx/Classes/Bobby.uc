class Bobby extends DXRStalker;

//TODO Ideas
//
// - Maybe it would be interesting/creepy/spooky if he was really fast when he runs away?
// - He should maybe have a special knife that's more effective?
// - Maybe rather than wandering (like Mr. H), he should be sitting around and stand up when you approach
//   - Maybe he could even only start chasing you after you've seen him, then let him go out of LoS
//   - if this is the case, we might want to make sure his alliance is neutral until he becomes "active",
//     so that you can't easily differentiate him from a "doll" version that won't chase


//Mostly from Robot - he's a doll, so these things don't work on him
function bool IgnoreDamageType(Name damageType)
{
    if ((damageType == 'TearGas') || (damageType == 'HalonGas') || (damageType == 'PoisonGas') || (damageType == 'Radiation'))
        return True;
    else if ((damageType == 'Poison') || (damageType == 'PoisonEffect'))
        return True;
    else
        return False;
}

//Don't play breathing animations
function TweenToWaiting(float tweentime)
{
//    ClientMessage("TweenToWaiting()");
    if (Region.Zone.bWaterZone)
        TweenAnimPivot('Tread', tweentime, GetSwimPivot());
    else
    {
        TweenAnimPivot('BreatheLight', tweentime);
        //if (HasTwoHandedWeapon())
        //    TweenAnimPivot('BreatheLight2H', tweentime);
        //else
        //    TweenAnimPivot('BreatheLight', tweentime);
    }
}

function PlayWaiting()
{
//    ClientMessage("PlayWaiting()");
    if (Region.Zone.bWaterZone)
        LoopAnimPivot('Tread', , 0.3, , GetSwimPivot());
    else
    {
        TweenAnimPivot('BreatheLight',0); //Tween to the breathing animation, but don't actually play it
        //if (HasTwoHandedWeapon())
        //    LoopAnimPivot('BreatheLight2H', , 0.3);
        //else
        //    LoopAnimPivot('BreatheLight', , 0.3);
    }
}

//GMK_DressShirt doesn't actually have a sitting animation ¯\_(ツ)_/¯
function PlaySitting()
{
    //ClientMessage("PlaySitting()");
    //LoopAnimPivot('SitBreathe', , 0.15);
    LoopAnimPivot('SitStill', , 0.15); //Have fun T-Posing
}

defaultproperties
{
    DrawScale=0.6
    CollisionRadius=10.000000
    CollisionHeight=19.000000
    Mass=45
    Buoyancy=50
    WalkSound=Sound'DeusExSounds.Robot.SpiderBot2Walk'
    Health=100
    HealthHead=100
    HealthTorso=100
    HealthLegLeft=100
    HealthLegRight=100
    HealthArmLeft=100
    HealthArmRight=100
    bShowPain=False
    UnderWaterTime=-1.000000
    BindName="Bobby"
    MinHealth=10
    FleeHealth=10
    bInvincible=false
    FamiliarName="Bobby"
    UnfamiliarName="Bobby"
    Texture=Texture'DeusExItems.Skins.BlackMaskTex'
    Mesh=LodMesh'DeusExCharacters.GMK_DressShirt'
    MultiSkins(0)=Texture'BobbyFace'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.BobPageTex1'
    MultiSkins(2)=Texture'BobbyPants'
    MultiSkins(3)=Texture'BobbyFace'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
    InitialInventory(0)=(Inventory=class'#var(prefix)WeaponCombatKnife')
    InitialInventory(1)=(Inventory=None)
    InitialInventory(2)=(Inventory=None)
    InitialInventory(3)=(Inventory=None)
    InitialInventory(4)=(Inventory=None)
    Alliance=Stalkers
    InitialAlliances(0)=(AllianceName=Player,AllianceLevel=-1,bPermanent=True)
    HearingThreshold=0
    walkAnimMult=1.572265625
    runAnimMult=0.9
    bCanStrafe=false
    CarcassType=Class'BobbyCarcass'
    WalkingSpeed=0.350000
    BurnPeriod=0.000000
    GroundSpeed=210.000000
    BaseEyeHeight=15.6
    HitSound1=Sound'ChildPainMedium';
    HitSound2=Sound'ChildPainLarge';
    Die=Sound'ChildDeath';
}
