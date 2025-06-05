class #var(injectsprefix)Poolball injects #var(prefix)Poolball;

var transient float lastBump;

function Bump(actor Other)
{
    local Vector HitNormal;
    local #var(injectsprefix)Poolball otherball;

    //Use this as a "don't do the collision stuff" toggle
    if (bJustHit) return;
    if (lastBump >= Level.TimeSeconds) return;

    // DXRando: Vanilla had logic for making sure this only happened once within a 0.2 second limit
    //Presumably faster machines make that 0.02 timer pointless and I guess the balls were
    //hitting each other really fast or something?  I dunno man.
    if (!Other.IsA('#var(injectsprefix)Poolball')) return;

    otherball = #var(injectsprefix)Poolball(Other);
    otherball.lastBump = Level.TimeSeconds + 1;
    lastBump = Level.TimeSeconds + 1;

    PlaySound(sound'PoolballClack', SLOT_None);

    HitNormal = Normal(Location - Other.Location);
    Velocity += (HitNormal * VSize(Other.Velocity)) * 0.99;

    HitNormal = Normal(Other.Location - Location);
    if(otherball.SkinColor==SC_Cue) {
        Other.Velocity = Other.Velocity * 0.6 + (HitNormal * VSize(Velocity)) * 0.5;
    } else {
        Other.Velocity = Other.Velocity * 0.1 + (HitNormal * VSize(Velocity)) * 0.89;
    }

    Velocity.Z = 0;
    Other.Velocity.Z = 0;
}

event HitWall(vector HitNormal, actor HitWall)
{
    local Vector newloc;

    // if we hit the ground, make sure we are rolling
    if (HitNormal.Z == 1.0)
    {
        SetPhysics(PHYS_Rolling, HitWall);
        if (Physics == PHYS_Rolling)
        {
            bFixedRotationDir = False;
            Velocity = vect(0,0,0);
            return;
        }
    }

    Velocity = 0.8 * ((Velocity dot HitNormal) * HitNormal * (-2.0) + Velocity); // Reflect off Wall w/damping, DXRando: *0.8 instead of *0.9
    Velocity.Z = 0;
    newloc = Location + HitNormal;	// move it out from the wall a bit
    SetLocation(newloc);
}

function Frob(Actor Frobber, Inventory frobWith)
{
    if(class'MenuChoice_BalanceEtc'.static.IsEnabled()){
        if (Class==class'#var(injectsprefix)Poolball' && SkinColor!=SC_Cue) return; //No frobbing non-cue pool balls!
    }

    Super.Frob(Frobber,frobWith);
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
