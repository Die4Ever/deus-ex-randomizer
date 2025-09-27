class WeepingAnna extends DXRStalker;

// will only move when not seen

var float OldAnimRate;
var int SpottedSoundId;
var float SpottedSoundTimer;

function Tick(float delta)
{
    Super.Tick(delta);
    bDetectable=false; // HACK: idk why these need to be set again
    bIgnore=true;
    CheckWakeup(delta);

    if(SpottedSoundTimer > 0) {
        SpottedSoundTimer -= delta;
        if(SpottedSoundTimer <= 0) {
            if(SpottedSoundId>0) {
                StopSound(SpottedSoundId);
                SpottedSoundId=0;
            }
        }
    }
}

state Sleeping
{
    ignores bump, frob, reacttoinjury;
    function BeginState()
    {
        BlockReactions(true);
        bCanConverse = False;
        EnableCheckDestLoc(false);
    }
    function EndState()
    {
        ResetReactions();
        bCanConverse = True;
    }

    function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
    {
        // can't be damaged here
    }

Begin:
    Acceleration=vect(0,0,0);
    DesiredRotation=Rotation;
    OldAnimRate=AnimRate;
    AnimRate=0;
    Spawn(class'WeepingAnnaLight'); // tiny light, fade in and fade out quickly, almost a strobe
    if(SpottedSoundId>0) StopSound(SpottedSoundId);
    SpottedSoundId = PlaySound(Sound'DeusExSounds.Generic.GlassBreakSmall',, 2,, 600, 0.5);
    SpottedSoundTimer = 0.2;
}

state Wakeup
{
Begin:
    if(AnimRate==0) AnimRate=OldAnimRate;
    if(Enemy!=None) {
        LookAtActor(Enemy,true,true,true);
        Sleep(0.1);
    }
    bDetectable=true;
    bIgnore=false;
    SetOrders('Wandering');
    if(Enemy!=None) HandleSighting(Enemy);
    else GotoState('Seeking');
}

function CheckWakeup(float deltaSeconds)
{
    local bool bSeen;
    local #var(PlayerPawn) seer;
    local name StateName;

    seer = AnyPlayerCanSeeMe(99999, false); // don't respect camo, something something quantum locked (also the player wants to look at them)
    StateName = GetStateName();

    if(seer!=None && StateName!='Sleeping')
    {
        ChangeAlly('Player', -1, false); // we won't fight until we've been seen once
        SetEnemy(seer, Level.TimeSeconds);
        GotoState('Sleeping');
    }
    if(seer==None && StateName=='Sleeping') {
        GotoState('Wakeup');
    }
}

function PlayFootStep()
{
    // silent
}

defaultproperties
{
    CarcassType=Class'DeusEx.AnnaNavarreCarcass'
    WalkingSpeed=0.8
    walkAnimMult=1.9
    GroundSpeed=500
    runAnimMult=1.7
    SurprisePeriod=0.1
    HearingThreshold=0

    CloseCombatMult=0.500000
    BaseAssHeight=-18.000000
    InitialInventory(0)=(Inventory=class'WeaponMrHPunch')
    InitialInventory(1)=(Inventory=None)
    InitialInventory(2)=(Inventory=None)
    InitialInventory(3)=(Inventory=None)
    InitialInventory(4)=(Inventory=None)
    bCanStrafe=false
    BurnPeriod=5.000000
    bHasCloak=True
    CloakThreshold=100
    bIsFemale=True
    BaseEyeHeight=38.000000
    Health=300
    HealthHead=400
    HealthTorso=300
    HealthLegLeft=300
    HealthLegRight=300
    HealthArmLeft=300
    HealthArmRight=300
    Mesh=LodMesh'DeusExCharacters.GFM_TShirtPants'
    DrawScale=1.100000
    MultiSkins(0)=Texture'DeusExCharacters.Skins.AnnaNavarreTex0'
    MultiSkins(1)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(2)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(3)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(4)=Texture'DeusExItems.Skins.BlackMaskTex'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.AnnaNavarreTex0'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.PantsTex9'
    MultiSkins(7)=Texture'DeusExCharacters.Skins.AnnaNavarreTex1'
    CollisionHeight=47.299999
    FamiliarName="Weeping Anna"
    UnfamiliarName="Weeping Anna"
    Alliance=WeepingAnna
    InitialAlliances(0)=(AllianceName=Player,AllianceLevel=0,bPermanent=True)
}
