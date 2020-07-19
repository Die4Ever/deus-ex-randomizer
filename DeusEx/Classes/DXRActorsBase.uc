class DXRActorsBase extends DXRBase;

var Pawn pawn;

function SpawnPawn()
{
    local Pawn p;
    if( pawn == None ) foreach AllActors(class'Pawn', p, 'DXRSpawnPawn') { pawn = p; }

    if( pawn == None ) {
        l("SpawnPawn");
        pawn = Spawn(class'ThugMale', None, 'DXRSpawnPawn', vect(0,0,50) );
        pawn.bHidden = True;
        pawn.Tag = 'DXRSpawnPawn';
        pawn.DrawScale = 0.1;
        pawn.SetCollision(false, false, false);
        //SetCollisionSize( float NewRadius, float NewHeight );
    }
}

/*function BeginPlay()
{
    Super.BeginPlay();
    SpawnPawn();
}

function PreBeginPlay()
{
    Super.PreBeginPlay();
    SpawnPawn();
}*/

function FirstEntry()
{
    Super.FirstEntry();
    SpawnPawn();
}

function ReEntry()
{
    Super.ReEntry();
    SpawnPawn();
}

function AnyEntry()
{
    Super.AnyEntry();
    SpawnPawn();
}

function PreTravel()
{
    /*if( pawn != None ) {
        pawn.Destroy();
        pawn = None;
    }*/
    Self.Destroy();
    Super.PreTravel();
}

event Destroyed()
{
    /*if( pawn != None ) {
        pawn.Destroy();
        pawn = None;
    }*/
    Super.Destroyed();
}

function SwapAll(name classname)
{
    local Actor a, b;
    local int num, i, slot;

    SetSeed( "SwapAll " $ classname );
    num=0;
    foreach AllActors(class'Actor', a )
    {
        if( SkipActor(a, classname) ) continue;
        num++;
    }

    foreach AllActors(class'Actor', a )
    {
        if( SkipActor(a, classname) ) continue;

        i=0;
        slot=rng(num-1);
        foreach AllActors(class'Actor', b )
        {
            if( SkipActor(b, classname) ) continue;

            if(i==slot) {
                Swap(a, b);
                break;
            }
            i++;
        }
    }
}

function vector AbsEach(vector v)
{// not a real thing in math? but it's convenient
    v.X = abs(v.X);
    v.Y = abs(v.Y);
    v.Z = abs(v.Z);
    return v;
}

function bool AnyGreater(vector a, vector b)
{
    return a.X > b.X || a.Y > b.Y || a.Z > b.Z;
}

function bool CarriedItem(Actor a)
{// I need to check Engine.Inventory.bCarriedItem
    return a.Owner != None && a.Owner.IsA('Pawn');
}

function bool SkipActorBase(Actor a)
{
    if( (a.Owner != None) || a.bStatic || a.bHidden || a.bMovable==False )
        return true;
    if( a.Base != None )
        return a.Base.IsA('ScriptedPawn');
    return false;
}

function bool SkipActor(Actor a, name classname)
{
    return SkipActorBase(a) || ( ! a.IsA(classname) ) || a.IsA('BarrelAmbrosia') || a.IsA('BarrelVirus') || a.IsA('NanoKey');
}

function Swap(Actor a, Actor b)
{
    local vector newloc;
    local rotator newrot;
    local bool asuccess, bsuccess;
    local Actor abase, bbase;
    local bool AbCollideActors, AbBlockActors, AbBlockPlayers, BbCollideActors, BbBlockActors, BbBlockPlayers;
    local EPhysics aphysics, bphysics;

    if( a == b ) return;

    l("swapping "$ActorToString(a)$" and "$ActorToString(b));

    // https://docs.unrealengine.com/udk/Two/ActorVariables.html#Advanced
    // native(262) final function SetCollision( optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers );
    AbCollideActors = a.bCollideActors;
    AbBlockActors = a.bBlockActors;
    AbBlockPlayers = a.bBlockPlayers;
    BbCollideActors = b.bCollideActors;
    BbBlockActors = b.bBlockActors;
    BbBlockPlayers = b.bBlockPlayers;
    a.SetCollision(false, false, false);
    b.SetCollision(false, false, false);

    newloc = b.Location + (a.CollisionHeight - b.CollisionHeight) * vect(0,0,1);
    newrot = b.Rotation;

    bsuccess = b.SetLocation(a.Location + (b.CollisionHeight - a.CollisionHeight) * vect(0,0,1) );
    b.SetRotation(a.Rotation);

    if( bsuccess == false )
        l("failed to move " $ ActorToString(b) $ " into location of " $ ActorToString(a) );

    asuccess = a.SetLocation(newloc);
    a.SetRotation(newrot);

    if( asuccess == false )
        l("failed to move " $ ActorToString(a) $ " into location of " $ ActorToString(b) );

    aphysics = a.Physics;
    bphysics = b.Physics;
    abase = a.Base;
    bbase = b.Base;

    if(asuccess)
    {
        a.SetPhysics(bphysics);
        if(abase != bbase) a.SetBase(bbase);
    }
    if(bsuccess)
    {
        b.SetPhysics(aphysics);
        if(abase != bbase) b.SetBase(abase);
    }

    a.SetCollision(AbCollideActors, AbBlockActors, AbBlockPlayers);
    b.SetCollision(BbCollideActors, BbBlockActors, BbBlockPlayers);
}

function bool ClassIsA(class<actor> class, class<Actor> testclass)
{
    return ClassIsChildOf( testclass, class );
    // there must be a better way to do this... native(258) static final function bool ClassIsChildOf( class TestClass, class ParentClass );
    /*local actor a;
    local bool ret;
    if(class == None) return ret;

    //return class<testclass>(class) != None;

    a = Spawn(class);
    ret = a.IsA(testclass);
    a.Destroy();
    return ret;*/
}

function bool DestroyActor( Actor d )
{
	// If this item is in an inventory chain, unlink it.
    local Decoration downer;

    if( d.IsA('Inventory') && d.Owner != None && d.Owner.IsA('Pawn') )
    {
        Pawn(d.Owner).DeleteInventory( Inventory(d) );
    }
    return d.Destroy();
}

function string ActorToString( Actor a )
{
    local string out;
    out = a.Class.Name$":"$a.Name$"("$a.Location$")";
    if( a.Base != None && a.Base.Class!=class'LevelInfo' )
        out = out $ "(Base:"$a.Base.Class$":"$a.Base.Name$")";
    return out;
}

function SetActorScale(Actor a, float scale)
{
    local bool AbCollideActors, AbBlockActors, AbBlockPlayers;
    local Vector newloc;
    
    AbCollideActors = a.bCollideActors;
    AbBlockActors = a.bBlockActors;
    AbBlockPlayers = a.bBlockPlayers;
    a.SetCollision(false, false, false);
    newloc = a.Location + ( (a.CollisionHeight*scale - a.CollisionHeight*a.DrawScale) * vect(0,0,1) );
    a.SetCollisionSize(a.CollisionRadius, a.CollisionHeight / a.DrawScale * scale);
    a.DrawScale = scale;
    a.SetLocation(newloc);
    a.SetCollision(AbCollideActors, AbBlockActors, AbBlockPlayers);
}

function bool TraceDoor(DeusExMover door, vector start, vector end, vector extent)
{
    local DeusExMover d;
    local vector hitloc, hitnorm;
    //do a Trace instead of foreach TraceActors
    foreach TraceActors(class'DeusExMover', d, hitloc, hitnorm, end, start, extent)
    {
        if( d == door ) return True;
    }

    return False;
}

function bool PlayerCanPath(Actor from, Actor to, DeusExMover door)
{
    local Pawn a;
    local bool ret, bsuccess;
    local NavigationPoint np;
    local Actor next, end;
    local int i;
    local float keydoordist, nextdist, enddist, tdist, tdoordist;
    local vector hitloc, hitnorm, extent;

    l(".PlayerCanPath( "$from$", "$ActorToString(to)$", "$ActorToString(door)$" )");

    keydoordist = VSize( from.Location - door.Location );
    keydoordist *= keydoordist;
    next = from;
    nextdist = VSize(to.Location - from.Location);

    foreach RadiusActors(class'NavigationPoint', np, 1500, from.Location)
    {
        tdist = VSize(np.Location - from.Location);
        tdoordist = VSize( np.Location - door.Location );// - keydoordist;//bias the distance so the cutoff line intersects the key
        tdoordist *= tdoordist;
        //l( "finding start point - "$ActorToString(np)$", tdist=="$tdist$", tdoordist=="$tdoordist$", keydoordist=="$keydoordist$", modified tdoordist=="$(tdoordist-keydoordist) );
        if( tdist < nextdist && (tdoordist-keydoordist) > (tdist*tdist) ) {
            next = np;
            nextdist = tdist;
        }
    }
    a = pawn;

    end = to;
    enddist = VSize(end.Location - from.Location);
    /*foreach RadiusActors(class'NavigationPoint', np, 1500, to.Location)
    {
        tdist = VSize(np.Location - to.Location);
        if( tdist < enddist ) {
            end = np;
            enddist = tdist;
        }
    }*/

    extent = vect(500, 500, 500);

    do {
        nextdist = VSize(next.Location - end.Location);
        foreach RadiusActors(class'NavigationPoint', np, 1500, next.Location)
        {
            tdist = VSize(np.Location - end.Location);
            l("RadiusActors np: "$ActorToString(np)$", tdist: "$tdist);
            if( tdist < nextdist ) {
                next = np;
                nextdist = tdist;
            }
        }
        bsuccess = a.SetLocation( next.Location );
        l( "next == "$ActorToString(next)$", bsuccess == "$bsuccess$", end == "$ActorToString(end)$", dist == " $nextdist );
        if( bsuccess == False ) break;

        if( a.ActorReachable( end ) ) {
            ret = true;
            break;
        }
        next = a.FindPathTo(end.Location);
        i++;
    } until( next == None || next==end || i>30 );

    if( ret ) l("PlayerCanPath("$ActorToString(from)$", "$ActorToString(to)$" returning "$ret);

    return ret;
}

