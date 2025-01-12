class MemConUnit extends DeusExPickup;

function BeginPlay()
{
    //Have to dynamically load the texture...
    //Doesn't work if I just set this texture in the defaultproperties
    MultiSkins[1] = Texture(DynamicLoadObject("Extras.Matrix_A00", class'Texture'));
}

#ifdef injections
function PostPostBeginPlay()
{
    local DXRAutosave m;
    Super.PostPostBeginPlay();

    m = DXRAutosave(class'DXRAutosave'.static.Find());

    if (m==None) return;

    Description = default.Description;
    if(m.FixedSavesExtreme == m.dxr.flags.autosave){
        Description="This item is capable of capturing and containing half of your memories, requiring 2 of them to save the game one time. The only freebie autosave you get is at the very start of the game.";
    }
    if (m.IsFixedSaves()){
        Description=Description
            $ "|n|nYou must have an ATM, personal computer, public terminal, or security computer highlighted in order to save your game. You do not need to open the computer, just look at it. Then you can use the normal Save Game menu or the Quicksave button."
            $ "|n|nSometimes you might want to backtrack to save."
            $ "|n|nRemember that if you die not all is lost, because you now have a better plan!";
    }
}
#endif

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
     Description="This item is capable of capturing and containing your memories, allowing you to save the game one time. The only freebie autosave you get is at the very start of the game."
     beltDescription="MCU"
     Mesh=LodMesh'DeusExItems.VialAmbrosia'
     CollisionRadius=5.0
     CollisionHeight=9.5
     PickupViewScale=2.0
     Mass=7
     Buoyancy=8
     MultiSkins(0)=Texture'MemConUnitTex1'
     MultiSkins(1)=Texture'DeusExDeco.Skins.AlarmLightTex7'
}
