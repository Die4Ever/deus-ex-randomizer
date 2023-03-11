//=============================================================================
// LuciusDeBeers.
//=============================================================================
class DXRLuciusDeBeers injects LuciusDeBeers;

//From DeusExCarcass
function ChunkUp()
{
    local int i;
    local float size;
    local Vector loc;
    local FleshFragment chunk;

    // gib the carcass
    size = (CollisionRadius + CollisionHeight) / 2;
    if (size > 10.0)
    {
        for (i=0; i<size/4.0; i++)
        {
            loc.X = (1-2*FRand()) * CollisionRadius;
            loc.Y = (1-2*FRand()) * CollisionRadius;
            loc.Z = (1-2*FRand()) * CollisionHeight;
            loc += Location;
            chunk = spawn(class'FleshFragment', None,, loc);
            if (chunk != None)
            {
                chunk.DrawScale = size / 25;
                chunk.SetCollisionSize(chunk.CollisionRadius / chunk.DrawScale, chunk.CollisionHeight / chunk.DrawScale);
                chunk.bFixedRotationDir = True;
                chunk.RotationRate = RotRand(False);
            }
        }
    }
}

simulated function Frag(class<fragment> FragType, vector Momentum, float DSize, int NumFrags)
{
    //Make him a metal box so the metal fragments aren't
    //just textured with his face
    Mesh = LodMesh'DeusExDeco.CrateUnbreakableLarge';
    Super.Frag(FragType,Momentum,DSize,NumFrags);
}

// ----------------------------------------------------------------------
// RandomPitch()
//
// Repetitive sound pitch randomizer to help make some sounds
// sound less monotonous
// ----------------------------------------------------------------------

function float RandomPitch()
{
	return (1.1 - 0.2*FRand());
}

function SetDead()
{
	local DeusExPlayer player;
	player = DeusExPlayer(GetPlayerPawn());
	if (player != None)
	{
		player.flagBase.SetBool('DeBeersDead', True);
	}
}

function Scream()
{
    PlaySound(Sound'ChildDeath', SLOT_Pain,100,,, RandomPitch());
    AISendEvent('LoudNoise', EAITYPE_Audio);
}

function Destroyed()
{
    //Daddy screamed real good before he died!
    Scream();

	//Also generate gibs
    ChunkUp();

    //Set DeBeersDead flag
    SetDead();

    //Destroy as normal
    Super.Destroyed();
}

defaultproperties
{
     bInvincible=False;
}
