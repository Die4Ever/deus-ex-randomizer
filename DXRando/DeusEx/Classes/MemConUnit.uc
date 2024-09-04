class MemConUnit extends DeusExPickup;

function BeginPlay()
{
    //Have to dynamically load the texture...
    //Doesn't work if I just set this texture in the defaultproperties
    MultiSkins[1] = Texture(DynamicLoadObject("Extras.Matrix_A00", class'Texture'));
}

defaultproperties
{
     maxCopies=5
     bCanHaveMultipleCopies=True
     bActivatable=False
     ItemName="Memory Containment Unit"
     ItemArticle="a"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.VialAmbrosia'
     PickupViewMesh=LodMesh'DeusExItems.VialAmbrosia'
     ThirdPersonMesh=LodMesh'DeusExItems.VialAmbrosia'
     LandSound=Sound'DeusExSounds.Generic.GlassHit1'
     Icon=Texture'BeltIconMemConUnit'
     largeIcon=Texture'LargeIconMemConUnit'
     largeIconWidth=18
     largeIconHeight=44
     Description="This item is capable of capturing and containing your memories, allowing you to save the game one time."
     beltDescription="MCU"
     Mesh=LodMesh'DeusExItems.VialAmbrosia'
     CollisionRadius=5.0
     CollisionHeight=9.5
     PickupViewScale=2.0
     Mass=2.000000
     Buoyancy=3.000000
     MultiSkins(0)=Texture'MemConUnitTex1'
     MultiSkins(1)=Texture'DeusExDeco.Skins.AlarmLightTex7'
}
