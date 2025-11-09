class DXRJackOLantern extends #var(DeusExPrefix)Decoration;

function BeginPlay()
{
    Super.BeginPlay();
    SetSkin(Rand(5));
}

function NewSkin()
{
    local Texture oldTexture;

    oldTexture = MultiSkins[0];
    while(MultiSkins[0] == oldTexture) {
        SetSkin(Rand(5));
    }
}

function SetSkin(int skinNum)
{
    switch(skinNum){
        case 0:
            MultiSkins[0]=Texture'PumpkinTex';
            break;
        case 1:
            MultiSkins[0]=Texture'PumpkinTex2';
            break;
        case 2:
            MultiSkins[0]=Texture'PumpkinTex3';
            break;
        case 3:
            MultiSkins[0]=Texture'PumpkinTex4';
            break;
        case 4:
            MultiSkins[0]=Texture'PumpkinTex5';
            break;
    }
}

function bool CheckCarve(Pawn EventInstigator, name DamageType)
{
    if(EventInstigator == None) return false;
    if(#var(prefix)WeaponCombatKnife(EventInstigator.Weapon) == None && #var(prefix)WeaponSword(EventInstigator.Weapon) == None) return false;
    if(DeusExWeapon(EventInstigator.Weapon).WeaponDamageType() != DamageType) return false; // make sure it's not chained damage, aka knife to TNT

    NewSkin();
    return true;
}

auto state Active
{
    function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
    {
        if(!CheckCarve(EventInstigator, DamageType) && Damage<HitPoints) Damage=HitPoints;
        Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
    }
}

state Burning
{
    function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
    {
        if(!CheckCarve(EventInstigator, DamageType) && Damage<HitPoints) Damage=HitPoints;
        Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
    }
}

simulated function Frag(class<fragment> FragType, vector Momentum, float DSize, int NumFrags)
{
    //Plastic Fragments look more like pumpkin chunks
    //The generically calculated DSize is a bit small for how a pumpkin shatters
    //Calculates too few frags
    Super.Frag(FragType,Momentum,DSize*1.5,NumFrags*4);
}

function SupportActor(Actor standingActor)
{
    if (standingActor != None && standingActor.Mass>=35){
        bCanBeBase=False;
        TakeDamage(HitPoints,standingActor.Instigator, standingActor.Location, 0.2*standingActor.Velocity, 'stomped');
    }
    Super.SupportActor(standingActor);
}

function ResetScaleGlow()
{// don't darken when damaged
    ScaleGlow = default.ScaleGlow;
}

defaultproperties
{
     HitPoints=7
     FragType=class'JackOLanternFragment'
     ItemName="Jack-O'-Lantern"
     Mesh=LodMesh'DeusExDeco.Poolball'
     MultiSkins(0)=Texture'PumpkinTex'
     CollisionRadius=10
     CollisionHeight=9
     DrawScale=6
     Mass=7
     Buoyancy=9
     LightType=LT_SubtlePulse
     LightPeriod=45
     LightEffect=LE_FireWaver
     LightBrightness=100
     LightHue=33
     LightSaturation=175
     LightRadius=5
     ScaleGlow=2.0
     bUnlit=True
}
