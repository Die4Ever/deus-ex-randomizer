class DXRPoolball injects #var(prefix)Poolball;


function Bump(actor Other)
{
	local Vector HitNormal;

    //Vanilla had logic for making sure this only happened once within a 0.2 second limit
    //Presumably faster machines make that 0.02 timer pointless and I guess the balls were
    //hitting each other really fast or something?  I dunno man.
	if (Other.IsA('#var(prefix)Poolball'))
	{
        PlaySound(sound'PoolballClack', SLOT_None);
        HitNormal = Normal(Location - Other.Location);
        Velocity = (HitNormal * VSize(Other.Velocity)) / 1.01;
        Velocity.Z = 0;
	}
}
