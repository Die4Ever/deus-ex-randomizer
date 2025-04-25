class #var(injectsprefix)Poolball injects #var(prefix)Poolball;


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

function SetSkin(int skinNum){
    switch(skinNum){
        case 0:
            SkinColor=SC_1;
            break;
        case 1:
            SkinColor=SC_2;
            break;
        case 2:
            SkinColor=SC_3;
            break;
        case 3:
            SkinColor=SC_4;
            break;
        case 4:
            SkinColor=SC_5;
            break;
        case 5:
            SkinColor=SC_6;
            break;
        case 6:
            SkinColor=SC_7;
            break;
        case 7:
            SkinColor=SC_8;
            break;
        case 8:
            SkinColor=SC_9;
            break;
        case 9:
            SkinColor=SC_10;
            break;
        case 10:
            SkinColor=SC_11;
            break;
        case 11:
            SkinColor=SC_12;
            break;
        case 12:
            SkinColor=SC_13;
            break;
        case 13:
            SkinColor=SC_14;
            break;
        case 14:
            SkinColor=SC_15;
            break;
        case 15:
            SkinColor=SC_Cue;
            break;
    }
    BeginPlay();
}
