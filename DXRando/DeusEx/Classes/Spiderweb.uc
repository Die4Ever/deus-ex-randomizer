class Spiderweb extends DeusExDecal;

simulated event BeginPlay()
{
}

simulated function PostBeginPlay()
{
}

defaultproperties
{
    Mesh=LodMesh'DeusExItems.FlatFX'
    Skin=Texture'Spiderweb'
    Physics=PHYS_None
    bCollideWorld=False
    bCollideActors=False
    bBlockActors=False
    bBlockPlayers=False
    bAttached=False
    bImportant=False
    bUnlit=False
    MultiDecalLevel=0
    DrawType=DT_Mesh
    Style=STY_Translucent
    ScaleGlow=0.1
}
