class DXRActorsBase extends DXRBase;

var globalconfig string skipactor_types[6];
var class<Actor> _skipactor_types[6];

function CheckConfig()
{
    local class<Actor> temp_skipactor_types[6];
    local int i, t;
    if( config_version < 4 && skipactor_types[0] == "" ) {
        for(i=0; i < ArrayCount(skipactor_types); i++) {
            skipactor_types[i] = "";
        }
        i=0;
        skipactor_types[i++] = "BarrelAmbrosia";
        skipactor_types[i++] = "BarrelVirus";
        skipactor_types[i++] = "NanoKey";
    }
    Super.CheckConfig();

    //sort skipactor_types so that we only need to check until the first None
    t=0;
    for(i=0; i < ArrayCount(skipactor_types); i++) {
        if( skipactor_types[i] != "" )
            _skipactor_types[t++] = GetClassFromString(skipactor_types[i], class'Actor');
    }
}

function SwapAll(name classname)
{
    local Actor temp[4096];
    local Actor a, b;
    local int num, i, slot;

    SetSeed( "SwapAll " $ classname );
    num=0;
    foreach AllActors(class'Actor', a )
    {
        if( SkipActor(a, classname) ) continue;
        temp[num++] = a;
    }

    for(i=0; i<num; i++) {
        slot=rng(num-1);// -1 because we skip ourself
        if(slot >= i) slot++;
        Swap(temp[i], temp[slot]);
    }
}

static function vector AbsEach(vector v)
{// not a real thing in math? but it's convenient
    v.X = abs(v.X);
    v.Y = abs(v.Y);
    v.Z = abs(v.Z);
    return v;
}

static function bool AnyGreater(vector a, vector b)
{
    return a.X > b.X || a.Y > b.Y || a.Z > b.Z;
}

function bool CarriedItem(Actor a)
{// I need to check Engine.Inventory.bCarriedItem
    if( a == dxr.Player.carriedDecoration )
        return true;
    return a.Owner != None && a.Owner.IsA('Pawn');
}

static function bool IsHuman(Actor a)
{
    return HumanMilitary(a) != None || HumanThug(a) != None || HumanCivilian(a) != None;
}

static function bool IsCritter(Actor a)
{
    if( Animal(a) == None ) return false;
    return Doberman(a) == None && Gray(a) == None && Greasel(a) == None && Karkian(a) == None;
}

static function bool HasItem(Pawn p, class c)
{
    local ScriptedPawn sp;
    local int i;
    sp = ScriptedPawn(p);
    
    if( sp != None ) {
        for (i=0; i<ArrayCount(sp.InitialInventory); i++)
        {
            if ((sp.InitialInventory[i].Inventory != None) && (sp.InitialInventory[i].Count > 0))
            {
                if( sp.InitialInventory[i].Inventory.Class == c ) return True;
            }
        }
    }
    return p.FindInventoryType(c) != None;
}

static function bool HasMeleeWeapon(Pawn p)
{
    return HasItem(p, class'WeaponBaton')
        || HasItem(p, class'WeaponCombatKnife')
        || HasItem(p, class'WeaponCrowbar')
        || HasItem(p, class'WeaponSword')
        || HasItem(p, class'WeaponNanoSword');
}

static function bool IsMeleeWeapon(Inventory item)
{
    return item.IsA('WeaponBaton')
        || item.IsA('WeaponCombatKnife')
        || item.IsA('WeaponCrowbar')
        || item.IsA('WeaponSword')
        || item.IsA('WeaponNanoSword');
}

function bool SkipActorBase(Actor a)
{
    if( a == dxr.Player.carriedDecoration )
        return true;
    if( (a.Owner != None) || a.bStatic || a.bHidden || a.bMovable==False )
        return true;
    if( a.Base != None )
        return a.Base.IsA('ScriptedPawn');
    return false;
}

function bool SkipActor(Actor a, name classname)
{
    local int i;
    if( SkipActorBase(a) || ( ! a.IsA(classname) ) ) {
        return true;
    }
    for(i=0; i < ArrayCount(_skipactor_types); i++) {
        if(_skipactor_types[i] == None) break;
        if( a.IsA(_skipactor_types[i].name) ) return true;
    }
    return false;
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

    //l("swapping "$ActorToString(a)$" and "$ActorToString(b));
    l("swapping "$ActorToString(a)$" and "$ActorToString(b)$" distance == " $ VSize(a.Location - b.Location) );

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
        warning("bsuccess failed to move " $ ActorToString(b) $ " into location of " $ ActorToString(a) );

    asuccess = a.SetLocation(newloc);
    a.SetRotation(newrot);

    if( asuccess == false )
        warning("asuccess failed to move " $ ActorToString(a) $ " into location of " $ ActorToString(b) );

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

function Actor ReplaceActor(Actor oldactor, string newclassstring)
{
    local Actor a;
    local class<Actor> newclass;
    local float scalefactor;
    local float largestDim;

    newclass = class<Actor>(DynamicLoadObject(newclassstring, class'class'));
    a = Spawn(newclass,,,oldactor.Location);

    if( a == None ) {
        warning("ReplaceActor("$oldactor$", "$newclassstring$"), failed to spawn in location "$oldactor.Location);
    }

    //Get the scaling to match
    if (a.CollisionRadius > a.CollisionHeight) {
        largestDim = a.CollisionRadius;
    } else {
        largestDim = a.CollisionHeight;
    }
    scalefactor = oldactor.CollisionHeight/largestDim;
    
    //DrawScale doesn't work right for Inventory objects
    a.DrawScale = scalefactor;
    if (a.IsA('Inventory')) {
        Inventory(a).PickupViewScale = scalefactor;
    }
    
    //Floating decorations don't rotate
    if (a.IsA('DeusExDecoration')) {
        DeusExDecoration(a).bFloating = False;
    }
    
    //Get it at the right height
    a.move(a.PrePivot);
    oldactor.bHidden = true;
    oldactor.Destroy();

    return a;
}

function string ActorToString( Actor a )
{
    local string out;
    out = a.Name$"("$a.Location$")";
    if( a.Base != None && a.Base.Class!=class'LevelInfo' )
        out = out $ "(Base:"$a.Base.Name$")";
    return out;
}

static function SetActorScale(Actor a, float scale)
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

function vector GetRandomPosition(optional vector target, optional float mindist, optional float maxdist)
{
    local PathNode temp[4096];
    local PathNode p;
    local int i, num, slot;
    local float dist;

    if( maxdist <= mindist )
        maxdist = 9999999;

    foreach AllActors(class'PathNode', p) {
        dist = VSize(p.Location-target);
        if( dist < mindist ) continue;
        if( dist > maxdist ) continue;
        temp[num++] = p;
    }
    if( num == 0 ) return target;
    slot = rng(num);
    return temp[slot].Location;
}

function vector JitterPosition(vector loc)
{
    loc.X += rngfn() * 80;//5 feet in any direction
    loc.Y += rngfn() * 80;
    return loc;
}

function vector GetRandomPositionFine(optional vector target, optional float mindist, optional float maxdist)
{
    local vector loc;
    loc = GetRandomPosition(target, mindist, maxdist);
    loc = JitterPosition(loc);
    return loc;
}

function vector GetCloserPosition(vector target, vector current, optional float maxdist)
{
    local PathNode p;
    local float dist, farthest_dist, dist_move;
    local vector farthest;

    if( maxdist == 0.0 || VSize(target-current) < maxdist )
        maxdist = VSize(target-current);
    farthest = current;
    foreach AllActors(class'PathNode', p) {
        dist = VSize(target-p.Location);
        dist_move = VSize(p.Location-current);//make sure the distance that we're moving is shorter than the distance to the target (aka move forwards, not to the opposite side)
        if( dist > farthest_dist && dist < maxdist && dist > maxdist/2 && dist > dist_move ) {
            farthest_dist = dist;
            farthest = p.Location;
        }
    }
    return farthest;
}

function bool NearestSurface(vector StartTrace, out vector EndTrace, optional out vector normal)
{
    local Actor HitActor;
    local vector HitLocation, HitNormal;

    HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace);
    if ( HitActor == Level ) {
        normal = HitNormal;
        EndTrace = HitLocation;
        return true;
    }
    warning("NearestSurface failed from ("$StartTrace$") to ("$EndTrace$")");
    return false;
}

function bool NearestCeiling(out vector StartTrace, float maxdist, out rotator rotation, optional float away_from_wall)
{
    local vector EndTrace, normal, MoveOffWall;
    EndTrace = StartTrace;
    EndTrace.Z += maxdist;
    if( NearestSurface(StartTrace, EndTrace, normal) == false ) {
        warning("NearestCeiling ("$StartTrace$") failed");
        return false;
    }
    rotation = Rotator(normal);
    MoveOffWall.X = away_from_wall;
    MoveOffWall.Y = away_from_wall;
    MoveOffWall.Z = away_from_wall;
    MoveOffWall *= normal;
    StartTrace = EndTrace + MoveOffWall;
    return true;
}

function bool NearestFloor(out vector StartTrace, float maxdist, out rotator rotation, optional float away_from_wall)
{
    local vector EndTrace, normal, MoveOffWall;
    EndTrace = StartTrace;
    EndTrace.Z -= maxdist;
    if( NearestSurface(StartTrace, EndTrace, normal) == false ) {
        warning("NearestFloor ("$StartTrace$") failed");
        return false;
    }
    rotation = Rotator(normal);
    MoveOffWall.X = away_from_wall;
    MoveOffWall.Y = away_from_wall;
    MoveOffWall.Z = away_from_wall;
    MoveOffWall *= normal;
    StartTrace = EndTrace + MoveOffWall;
    return true;
}

function bool NearestWall(out vector StartTrace, float maxdist, out rotator rotation, optional float away_from_wall, optional float mindist)
{
    local vector MoveOffWall;
    local vector walls[4];
    local vector normals[4];
    local int successes[4];
    local float closest_dist, dist;
    local int i, closest;

    walls[i] = StartTrace;
    walls[i].X += maxdist;
    successes[i] = int(NearestSurface(StartTrace, walls[i], normals[i]));
    i++;

    walls[i] = StartTrace;
    walls[i].X -= maxdist;
    successes[i] = int(NearestSurface(StartTrace, walls[i], normals[i]));
    i++;

    walls[i] = StartTrace;
    walls[i].Y += maxdist;
    successes[i] = int(NearestSurface(StartTrace, walls[i], normals[i]));
    i++;

    walls[i] = StartTrace;
    walls[i].Y -= maxdist;
    successes[i] = int(NearestSurface(StartTrace, walls[i], normals[i]));
    i++;

    closest_dist = maxdist+1;
    for(i=0; i<ArrayCount(walls); i++) {
        if( successes[i] == 0 ) continue;
        dist = VSize(walls[i] - StartTrace);
        if( dist < closest_dist && dist >= mindist ) {
            closest_dist = dist;
            closest = i;
        }
    }

    if( closest_dist > maxdist ) {
        warning("NearestWall ("$StartTrace$") failed with mindist: "$mindist$", maxdist: "$maxdist);
        return false;
    }
    rotation = Rotator(normals[closest]);
    MoveOffWall.X = away_from_wall;
    MoveOffWall.Y = away_from_wall;
    MoveOffWall.Z = away_from_wall;
    MoveOffWall *= normals[closest];
    StartTrace = walls[closest] + MoveOffWall;
    return true;
}

function Vector GetCenter(Actor test)
{
    local Vector MinVect, MaxVect;

    test.GetBoundingBox(MinVect, MaxVect);
    return (MinVect+MaxVect)/2;
}

function bool _PositionIsSafeOctant(Vector oldloc, Vector TestPoint, Vector newloc)
{
    local Vector distsold, diststest, distsoldtest;
    //l("results += testbool( _PositionIsSafeOctant(vect("$oldloc$"), vect("$ TestPoint $"), vect("$newloc$")), truefalse, \"test\");");
    distsoldtest = AbsEach(oldloc - TestPoint);
    distsold = AbsEach(newloc - oldloc) - (distsoldtest*0.999);
    diststest = AbsEach(newloc - TestPoint);
    if ( AnyGreater( distsold, diststest ) ) return False;
    return True;
}

function bool PositionIsSafe(Vector oldloc, Actor test, Vector newloc)
{// https://github.com/Die4Ever/deus-ex-randomizer/wiki#smarter-key-randomization
    local Vector TestPoint;
    local float distold, disttest;

    TestPoint = GetCenter(test);

    distold = VSize(newloc - oldloc);
    disttest = VSize(newloc - TestPoint);

    return _PositionIsSafeOctant(oldloc, TestPoint, newloc);
}

function bool PositionIsSafeLenient(Vector oldloc, Actor test, Vector newloc)
{// https://github.com/Die4Ever/deus-ex-randomizer/wiki#smarter-key-randomization
    return _PositionIsSafeOctant(oldloc, GetCenter(test), newloc);
}

defaultproperties
{
}
