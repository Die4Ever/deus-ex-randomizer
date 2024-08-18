class DXRJackOLantern extends #var(DeusExPrefix)Decoration;

simulated function Frag(class<fragment> FragType, vector Momentum, float DSize, int NumFrags)
{
    //Plastic Fragments look more like pumpkin chunks
    //The generically calculated DSize is a bit small for how a pumpkin shatters
    //Calculates too few frags
    Super.Frag(class'DeusEx.PlasticFragment',Momentum,DSize*1.5,NumFrags*4);
}

defaultproperties
{
     FragType=class'DeusEx.FleshFragment'
     ItemName="Jack-O'-Lantern"
     Mesh=LodMesh'DeusExDeco.Poolball'
     MultiSkins(0)=Texture'PumpkinTex'
     CollisionRadius=10
     CollisionHeight=8
     DrawScale=6
     Mass=15.000000
     Buoyancy=2.000000
     LightType=LT_SubtlePulse
     LightPeriod=45
     LightEffect=LE_FireWaver
     LightBrightness=100
     LightHue=33
     LightSaturation=175
     LightRadius=5
     ScaleGlow=2.0;
     bUnlit=True
}
