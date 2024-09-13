class DXRJackOLantern extends #var(DeusExPrefix)Decoration;

function BeginPlay()
{
    Super.BeginPlay();
    SetSkin(Rand(5));
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

simulated function Frag(class<fragment> FragType, vector Momentum, float DSize, int NumFrags)
{
    //Plastic Fragments look more like pumpkin chunks
    //The generically calculated DSize is a bit small for how a pumpkin shatters
    //Calculates too few frags
    Super.Frag(class'JackOLanternFragment',Momentum,DSize*1.5,NumFrags*4);
}

function ResetScaleGlow()
{// don't darken when damaged
    ScaleGlow = default.ScaleGlow;
}

defaultproperties
{
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
