class HordeModeCrate extends DXRBigContainers;

defaultproperties
{
    ItemName="Horde Supply Crate"
    Skin=Texture'BlankWoodenCrate'
    HitPoints=1
    FragType=Class'DeusEx.WoodFragment'
    bBlockSight=True
    Mesh=LodMesh'DeusExDeco.CrateBreakableMed'
    DrawScale=0.75
    CollisionRadius=25.000000
    CollisionHeight=18.000000
    Mass=37.500000
    Buoyancy=60.000000
    MaxContentCount=10
    ContentTypeLimit=3
    DropStacks=false //Helps items get distributed better if left on the floor
}
