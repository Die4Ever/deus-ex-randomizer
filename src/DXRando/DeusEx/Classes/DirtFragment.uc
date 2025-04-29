class DirtFragment extends DeusExFragment;

auto state Flying
{
    function BeginState()
    {
        Super.BeginState();

        Velocity = VRand() * 300;
        DrawScale = FRand() + 1.5;
    }
}

function BeginPlay()
{
    local Texture tex;
    Super.BeginPlay();

    //Pick a random dirt texture
    switch(Rand(2)){
        case 0:
            tex=Texture(DynamicLoadObject("CoreTexEarth.Earth.DrtyBrwnEarth_A", class'Texture'));
            break;
        case 1:
            tex=Texture(DynamicLoadObject("CoreTexEarth.Earth.LakeBed_A", class'Texture'));
            break;
    }
    MultiSkins[0] = tex;
}

defaultproperties
{
     Fragments(0)=LodMesh'DeusExItems.FleshFragment1'
     Fragments(1)=LodMesh'DeusExItems.FleshFragment2'
     Fragments(2)=LodMesh'DeusExItems.FleshFragment3'
     Fragments(3)=LodMesh'DeusExItems.FleshFragment4'
     numFragmentTypes=4
     elasticity=0.400000
     ImpactSound=Sound'DeusExSounds.Generic.RockHit1'
     MiscSound=Sound'DeusExSounds.Generic.RockHit2'
     Mesh=LodMesh'DeusExItems.FleshFragment1'
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     Mass=5.000000
     Buoyancy=5.500000
     bVisionImportant=True
}
