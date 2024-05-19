class Carcass2 injects DeusExCarcass;
// HACK to fix compatibility with Lay D Denton
// Lay D Denton expects the DeusExCarcass class to have Mesh2 and Mesh3 in them, but the engine isn't smart enough to look in the parent class

var(Display) mesh Mesh2; // mesh for secondary carcass
var(Display) mesh Mesh3; // mesh for floating carcass

simulated function PreBeginPlay()
{
    Super.PreBeginPlay();
    if(Mesh2 != None)
        SetMesh2(Mesh2);
    if(Mesh3 != None)
        SetMesh3(Mesh3);
}

//Fixes carcasses disappearing after loading a game
simulated function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    if(Mesh2 != None)
        SetMesh2(Mesh2);
    if(Mesh3 != None)
        SetMesh3(Mesh3);
}

function ZoneChange(ZoneInfo NewZone)
{
    if(Mesh3 != None)
        SetMesh3(Mesh3);

    Super.ZoneChange(NewZone);

    //Make sure it updates with the Mesh3 from this class
    if (NewZone.bWaterZone)
        Mesh = Mesh3;
}

function InitFor(Actor Other)
{
    if(Mesh2 != None)
        SetMesh2(Mesh2);

    Super.InitFor(Other);

    //Make sure it updates with the Mesh2 from this class
    if (Other.AnimSequence == 'DeathFront')
        Mesh = Mesh2;

}
