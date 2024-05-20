class DXRBlackHelicopter injects BlackHelicopter;

singular function SupportActor(Actor standingActor)
{
	// kill whatever lands on the blades
	if (standingActor != None)
		standingActor.TakeDamage(10000, None, standingActor.Location, vect(0,0,0), 'Helicopter'); //Just change the damage type
}

//From DeusExCarcass
function ChunkUp()
{
    local int i;
    local float size;
    local Vector loc;
    local FleshFragment chunk;

    // gib the carcass
    //size = (CollisionRadius + CollisionHeight) / 2; //We don't want helicopter sized gibs
    size = (class'Jock'.Default.CollisionRadius + class'Jock'.Default.CollisionHeight) / 2; //Jock-sized Gibs!
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

function float RandomPitch()
{
    return (1.1 - 0.2*FRand());
}

function Scream()
{
    local DXRando dxr;

    foreach AllActors(class'DXRando',dxr){break;}
    if (dxr==None) return;
    if(!class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) return;

    //Increase the radius from the default 4096 just so you can hear it from a distance
    PlaySound(Sound'ChildDeath', SLOT_Pain,100,,9000, RandomPitch());
    AISendEvent('LoudNoise', EAITYPE_Audio);
}

function Destroyed()
{
    //Daddy screamed real good before he died!
    Scream();

    //Also generate gibs
    ChunkUp();

    //Destroy as normal
    Super.Destroyed();
}

/////////////////////////////////////////////////////////////
///////////////States copied from base class/////////////////
//////Including these allows old save games to load//////////
/////////////////////////////////////////////////////////////


auto state Flying
{
	function BeginState()
	{
		Super.BeginState();
		LoopAnim('Fly');
	}
}

defaultproperties
{
    CollisionRadius=360
}
