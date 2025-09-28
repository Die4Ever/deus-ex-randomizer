class WeepingAnna extends DXRStalker;

// will only move when not seen

var float OldAnimRate;
var int SpottedSoundId;
var float SpottedSoundTimer;
var float LastSeen;

const RecentlySeenTime=30.0;

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
    Spawn(class'WeepingAnnaLight'); // tiny light, fade in and fade out quickly, almost a strobe
    if(SpottedSoundId>0) StopSound(SpottedSoundId);
    SpottedSoundId = PlaySound(Sound'DeusExSounds.Generic.GlassBreakSmall',, 2,, 600, 0.5);
    SpottedSoundTimer = 0.2;

Idle:
    Acceleration=vect(0,0,0);
    DesiredRotation=Rotation;
    OldAnimRate=AnimRate;
    AnimRate=0;
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

function bool AnyNearPlayerInConvOrCut(float MaxDist)
{
    local #var(PlayerPawn) p;
    foreach RadiusActors(class'#var(PlayerPawn)', p, MaxDist) {
        switch(p.GetStateName()) {
            case 'Conversation':
            case 'Paralyzed':
            case 'Interpolating':
            case 'Dying':
                return true;
        }
    }
    return false;
}

function bool RecentlySeen()
{
    return (Level.TimeSeconds - LastSeen) < RecentlySeenTime;
}

function InitializePawn()
{
    Super.InitializePawn();
    GotoState('Sleeping', 'Idle'); // skip the light and sound effect of being spotted
}

function CheckWakeup(float deltaSeconds)
{
    local bool bSeen, inConv;
    local #var(PlayerPawn) seer;
    local name StateName;

    seer = AnyPlayerCanSeeMe(self, 99999, false); // don't respect camo, something something quantum locked (also the player wants to look at them)
    inConv = AnyNearPlayerInConvOrCut(99999); //Check to see if anyone is in a conversation or cutscene that changes vision
    StateName = GetStateName();

    if (seer!=None){
        LastSeen=Level.TimeSeconds;
    }

    if((seer!=None || inConv) && StateName!='Sleeping')
    {
        if(seer!=None){
            ChangeAlly('Player', -1, false); // we won't fight until we've been seen once
            SetEnemy(seer, Level.TimeSeconds, true);
        }
        GotoState('Sleeping');
    }
    if(seer==None && !inConv && StateName=='Sleeping') {
        GotoState('Wakeup');
    }
}

function PlayFootStep()
{
    // silent
}

//#region Animations
function PlayAnimPivot(name Sequence, optional float Rate, optional float TweenTime,
                       optional vector NewPrePivot)
{
    SelectPose();
}

function LoopAnimPivot(name Sequence, optional float Rate, optional float TweenTime, optional float MinRate,
                       optional vector NewPrePivot)
{
    SelectPose();
}

function TweenAnimPivot(name Sequence, float TweenTime,
                        optional vector NewPrePivot)
{
    SelectPose();
}
//#endregion

function PlayDying(name DamageType, vector HitLoc)
{
    Super.PlayDying(DamageType,HitLoc);
    ShatterBody();
}

function Carcass SpawnCarcass()
{
    ShatterBody();
    return None;
}

function ShatterBody()
{
    local int i;
    local bool spawnit;

    //Break into rock fragments
    for(i=0;i<16;i++){
        if(i<10){
            spawnit=true;
        } else {
            spawnit=(FRand()<0.5);
        }

        if(spawnit){
            if(FRand()<0.5){
                spawn(class'Rockchip',,,Location);
            } else {
                spawn(class'BigRockFragment',,,Location);
            }
        }
    }

}

//#region Posing
function GoToAnimFrame(name Sequence,float AnimFrame)
{
    PlayAnim(Sequence);
    AnimFrame=AnimFrame;
    AnimRate=0.0;

}

//Pick from preselected frames of animation
//Makes the poses more fun, and lets us get a bit more diversity
function SelectPose()
{
    local Name SeqName;
    local float FrameNum;

    if (!RecentlySeen() && !IsInState('Attacking')){
        //Revert to "weeping" pose if you haven't seen them for a while
        GoToAnimFrame('RubEyes',0.12);
        return;
    }

    switch(Rand(27))
    {
        case 0:
            SeqName='Attack';
            FrameNum=0.0;
            break;
        case 1:
            SeqName='Attack';
            FrameNum=0.05;
            break;
        case 2:
            SeqName='Attack';
            FrameNum=0.15;
            break;
        case 3:
            SeqName='Attack';
            FrameNum=0.3;
            break;
        case 4:
            SeqName='Attack';
            FrameNum=0.4;
            break;
        case 5:
            SeqName='Attack';
            FrameNum=0.55;
            break;
        case 6:
            SeqName='Shoot';
            FrameNum=0.0;
            break;
        case 7:
            SeqName='Shoot';
            FrameNum=0.3;
            break;
        case 8:
            SeqName='Run';
            FrameNum=0.15;
            break;
        case 9:
            SeqName='Run';
            FrameNum=0.25;
            break;
        case 10:
            SeqName='Run';
            FrameNum=0.6;
            break;
        case 11:
            SeqName='Run';
            FrameNum=0.75;
            break;
        case 12:
            SeqName='Panic';
            FrameNum=0.25;
            break;
        case 13:
            SeqName='Panic';
            FrameNum=0.75;
            break;
        case 14:
            SeqName='PushButton';
            FrameNum=0.25;
            break;
        case 15:
            SeqName='PushButton';
            FrameNum=0.5;
            break;
        case 16:
            SeqName='CowerBegin';
            FrameNum=0.15;
            break;
        case 17:
            SeqName='AttackSide';
            FrameNum=0.2;
            break;
        case 18:
            SeqName='AttackSide';
            FrameNum=0.3;
            break;
        case 19:
            SeqName='AttackSide';
            FrameNum=0.5;
            break;
        case 20:
            SeqName='AttackSide';
            FrameNum=0.6;
            break;
        case 21:
            SeqName='Walk';
            FrameNum=0.1;
            break;
        case 22:
            SeqName='Jump';
            FrameNum=0.2;
            break;
        case 23:
            SeqName='HitHeadBack';
            FrameNum=0.3;
            break;
        case 24:
            SeqName='HitTorsoBack';
            FrameNum=0.4;
            break;
        case 25:
            SeqName='HitTorso';
            FrameNum=0.8;
            break;
        case 26:
            SeqName='GestureBoth';
            FrameNum=0.4;
            break;
    }

    GoToAnimFrame(SeqName,FrameNum);
}
//#endregion

defaultproperties
{
    CarcassType=Class'DeusEx.AnnaNavarreCarcass'
    WalkingSpeed=1
    walkAnimMult=2
    GroundSpeed=700
    AccelRate=1500
    runAnimMult=2
    SurprisePeriod=0.1
    HearingThreshold=0
    bKeepWeaponDrawn=True // maybe faster response?
    BaseAccuracy=0.1

    CloseCombatMult=0.500000
    BaseAssHeight=-19.64
    InitialInventory(0)=(Inventory=class'WeaponWeepingAnnaPunch')
    InitialInventory(1)=(Inventory=None)
    InitialInventory(2)=(Inventory=None)
    InitialInventory(3)=(Inventory=None)
    InitialInventory(4)=(Inventory=None)
    bCanStrafe=false
    BurnPeriod=0.000000
    bIsFemale=True
    BaseEyeHeight=41.45
    Health=300
    HealthHead=400
    HealthTorso=300
    HealthLegLeft=300
    HealthLegRight=300
    HealthArmLeft=300
    HealthArmRight=300
    Mesh=LodMesh'DeusExCharacters.GFM_TShirtPants'
    DrawScale=1.2
    MultiSkins(0)=Texture'WeepingAnnaFace'
    MultiSkins(1)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(2)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(3)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(4)=Texture'DeusExItems.Skins.BlackMaskTex'
    MultiSkins(5)=Texture'WeepingAnnaFace'
    MultiSkins(6)=Texture'WeepingAnnaPants'
    MultiSkins(7)=Texture'WeepingAnnaShirt'
    CollisionHeight=51.6
    CollisionRadius=20 // Anna is 22, skinnier makes easier pathing?
    Mass=250 // Anna is 150
    Buoyancy=0
    FamiliarName="Weeping Anna"
    UnfamiliarName="Weeping Anna"
    Alliance=WeepingAnna
    InitialAlliances(0)=(AllianceName=Player,AllianceLevel=0,bPermanent=False)
    AnimSequence=RubEyes
    AnimFrame=0.12
    AnimRate=0.0
    LastSeen=-100.0
}
