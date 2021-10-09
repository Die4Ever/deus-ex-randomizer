class Carcass2 injects DeusExCarcass;
// HACK to fix compatibility with Lay D Denton
// Lay D Denton expects the DeusExCarcass class to have Mesh2 and Mesh3 in them, but the engine isn't smart enough to look in the parent class

var(Display) mesh Mesh2; // mesh for secondary carcass
var(Display) mesh Mesh3; // mesh for floating carcass

simulated function PreBeginPlay()
{
    SetMesh2(Mesh2);
    SetMesh3(Mesh3);
}
