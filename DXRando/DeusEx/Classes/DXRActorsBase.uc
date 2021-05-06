class DXRActorsBase extends DXRBase;

var globalconfig string skipactor_types[6];
var class<Actor> _skipactor_types[6];

struct LocationNormal {
    var vector loc;
    var vector norm;
};

struct FMinMax {
    var float min;
    var float max;
};

struct safe_rule {
    var string map;
    var name item_name;
    var vector min_pos;
    var vector max_pos;
    var bool allow;
};

function CheckConfig()
{
    local class<Actor> temp_skipactor_types[6];
    local int i, t;
    if( config_version < class'DXRFlags'.static.VersionToInt(1,5,6) ) {
        for(i=0; i < ArrayCount(skipactor_types); i++) {
            skipactor_types[i] = "";
        }
        i=0;
        skipactor_types[i++] = "BarrelAmbrosia";
        skipactor_types[i++] = "NanoKey";
#ifdef hx
        // since it's not put into a player's inventory, it's not automatically skipped, although it's bHidden so it should be skipped anyways
        skipactor_types[i++] = "HXRandomizer.DataStorage";
#endif
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
    if( PlayerPawn(a.Base) != None )
        return true;
    return a.Owner != None && a.Owner.IsA('Pawn');
}

static function bool IsHuman(Actor a)
{
    return HumanMilitary(a) != None || HumanThug(a) != None || HumanCivilian(a) != None;
}

static function bool IsCritter(Actor a)
{
    if( CleanerBot(a) != None ) return true;
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

static function bool HasItemSubclass(Pawn p, class<Inventory> c)
{
    local Inventory Inv;
    local ScriptedPawn sp;
    local int i;
    sp = ScriptedPawn(p);
    
    if( sp != None ) {
        for (i=0; i<ArrayCount(sp.InitialInventory); i++)
        {
            if ((sp.InitialInventory[i].Inventory != None) && (sp.InitialInventory[i].Count > 0))
            {
                if( ClassIsChildOf(sp.InitialInventory[i].Inventory.Class, c) ) return True;
            }
        }
    }

    for( Inv=p.Inventory; Inv!=None; Inv=Inv.Inventory )   
		if ( ClassIsChildOf(Inv.class, c) )
			return true;
	return false;
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

static function inventory GiveItem(Pawn p, class<Inventory> iclass, optional int add_ammo)
{
    local inventory anItem;
    local DeusExPlayer player;
    local DeusExWeapon w;
    local int i;

    player = DeusExPlayer(p);
    if( class<Ammo>(iclass) != None ) {
        anItem = p.FindInventoryType(iclass);
        if( anItem != None ) {
            Ammo(anItem).AmmoAmount += Class<Ammo>(iclass).default.AmmoAmount;
            if( player != None )
                player.UpdateAmmoBeltText(Ammo(anItem));
            return anItem;
        }
    }

    anItem = p.Spawn(iclass, p);
    if( anItem == None ) return None;
    anItem.InitialState='Idle2';
    anItem.SetLocation(p.Location);
    if( player != None ) {
        player.FrobTarget = anItem;
        player.ParseRightClick();
    } else {
        anItem.GiveTo(p);
        anItem.SetBase(p);
    }

    w = DeusExWeapon(anItem);
    if( add_ammo > 0 && w != None ) {
        if ( (w.AmmoName != None) && (w.AmmoName != Class'AmmoNone') )
        {
            for(i=0; i<add_ammo; i++)
                w.AmmoType = DeusExAmmo(GiveItem(p, w.AmmoName));
        }
    }

    if( player != None )
        player.UpdateBeltText(anItem);

    return anItem;
}

static function ThrowItem(Actor a, Inventory item)
{
    if( Pawn(a) != None )
        Pawn(a).DeleteInventory(item);
    item.DropFrom(a.Location + VRand()*32);
    // kinda copied from DeusExPlayer DropItem function
    item.Velocity = vector(a.rotation) * 300 + vect(0,0,220) + VRand()*32;
}

function bool SkipActorBase(Actor a)
{
    if( (a.Owner != None) || a.bStatic || a.bHidden || a.bMovable==False )
        return true;
    if( ScriptedPawn(a.Base) != None )
        return true;
    if( PlayerPawn(a.Base) != None )
        return true;
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

function bool SetActorLocation(Actor a, vector newloc)
{
    local ScriptedPawn p;

    if( ! a.SetLocation(newloc) ) return false;

    p = ScriptedPawn(a);
    if( p != None && p.Orders == 'Patrolling' ) {
        p.SetOrders('Wandering');
        p.HomeTag = 'Start';
        p.HomeLoc = p.Location;
    }

    return true;
}

function RemoveFears(ScriptedPawn p)
{
    if( p == None ) {
        err("RemoveFears "$p);
        return;
    }
    p.bFearHacking = false;
    p.bFearWeapon = false;
    p.bFearShot = false;
    p.bFearInjury = false;
    p.bFearIndirectInjury = false;
    p.bFearCarcass = false;
    p.bFearDistress = false;
    p.bFearAlarm = false;
    p.bFearProjectiles = false;
}

function bool Swap(Actor a, Actor b)
{
    local vector newloc, oldloc;
    local rotator newrot;
    local bool asuccess, bsuccess;
    local Actor abase, bbase;
    local bool AbCollideActors, AbBlockActors, AbBlockPlayers;
    local EPhysics aphysics, bphysics;

    if( a == b ) return true;

    l("swapping "$ActorToString(a)$" and "$ActorToString(b)$" distance == " $ VSize(a.Location - b.Location) );

    AbCollideActors = a.bCollideActors;
    AbBlockActors = a.bBlockActors;
    AbBlockPlayers = a.bBlockPlayers;
    a.SetCollision(false, false, false);

    oldloc = a.Location;
    newloc = b.Location;

    bsuccess = SetActorLocation(b, oldloc + (b.CollisionHeight - a.CollisionHeight) * vect(0,0,1) );
    a.SetCollision(AbCollideActors, AbBlockActors, AbBlockPlayers);
    if( bsuccess == false ) {
        warning("bsuccess failed to move " $ ActorToString(b) $ " into location of " $ ActorToString(a) );
        return false;
    }

    asuccess = SetActorLocation(a, newloc + (a.CollisionHeight - b.CollisionHeight) * vect(0,0,1));
    if( asuccess == false ) {
        warning("asuccess failed to move " $ ActorToString(a) $ " into location of " $ ActorToString(b) );
        SetActorLocation(b, newloc);
        return false;
    }

    newrot = b.Rotation;
    b.SetRotation(a.Rotation);
    a.SetRotation(newrot);

    aphysics = a.Physics;
    bphysics = b.Physics;
    abase = a.Base;
    bbase = b.Base;

    a.SetPhysics(bphysics);
    if(abase != bbase) a.SetBase(bbase);
    b.SetPhysics(aphysics);
    if(abase != bbase) b.SetBase(abase);

    return true;
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
    local vector loc;
    local float scalefactor;
    local float largestDim;

    loc = oldactor.Location;
    newclass = class<Actor>(DynamicLoadObject(newclassstring, class'class'));
    if( newclass.default.bStatic ) warning(newclassstring $ " defaults to bStatic, Spawn probably won't work");
    a = Spawn(newclass,,,loc);

    if( a == None ) {
        warning("ReplaceActor("$oldactor$", "$newclassstring$"), failed to spawn in location "$oldactor.Location);
        return None;
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

function Conversation GetConversation(Name conName)
{
    local Conversation c;
    foreach AllObjects(class'Conversation', c) {
        if( c.conName == conName ) return c;
    }
    return None;
}

static function DeusExDecoration _AddSwitch(Actor a, vector loc, rotator rotate, name Event)
{
    local DeusExDecoration d;
    d = DeusExDecoration( _AddActor(a, class'Switch2', loc, rotate) );
    d.Event = Event;
    return d;
}

function DeusExDecoration AddSwitch(vector loc, rotator rotate, name Event)
{
    return _AddSwitch(Self, loc, rotate, Event);
}

static function Actor _AddActor(Actor a, class<Actor> c, vector loc, rotator rotate)
{
    local Actor d;
    local bool oldCollideWorld;
    d = a.Spawn(c,,, loc, rotate );
    oldCollideWorld = d.bCollideWorld;
    d.bCollideWorld = false;
    d.SetLocation(loc);
    d.SetRotation(rotate);
    d.bCollideWorld = oldCollideWorld;
    return d;
}

function Containers AddBox(class<Containers> c, vector loc, optional rotator rotate)
{
    local Containers box;
    box = Containers(_AddActor(Self, c, loc, rotate));
    box.bInvincible = true;
    return box;
}

function string ActorToString( Actor a )
{
    local string out;
    out = a.Class.Name$"."$a.Name$"("$a.Location$")";
    if( a.Base != None && a.Base.Class!=class'LevelInfo' )
        out = out $ "(Base:"$a.Base.Name$")";
    return out;
}

static function SetActorScale(Actor a, float scale)
{
    local Vector newloc;

    newloc = a.Location + ( (a.CollisionHeight*scale - a.CollisionHeight*a.DrawScale) * vect(0,0,1) );
    a.SetLocation(newloc);
    a.SetCollisionSize(a.CollisionRadius, a.CollisionHeight / a.DrawScale * scale);
    a.DrawScale = scale;
}

function vector GetRandomPosition(optional vector target, optional float mindist, optional float maxdist, optional bool allowWater, optional bool allowPain)
{
    local PathNode temp[4096];
    local PathNode p;
    local int i, num, slot;
    local float dist;

    if( maxdist <= mindist )
        maxdist = 9999999;

    foreach AllActors(class'PathNode', p) {
        if( (!allowWater) && p.Region.Zone.bWaterZone ) continue;
        if( (!allowPain) && (p.Region.Zone.bKillZone || p.Region.Zone.bPainZone ) ) continue;
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
    loc.X += rngfn() * 160.0;//10 feet in any direction
    loc.Y += rngfn() * 160.0;
    return loc;
}

function vector GetRandomPositionFine(optional vector target, optional float mindist, optional float maxdist, optional bool allowWater, optional bool allowPain)
{
    local vector loc;
    loc = GetRandomPosition(target, mindist, maxdist, allowWater, allowPain);
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

//I could have fuzzy logic and allow these Is___Normal functions to have overlap? or make them more strict where some normals don't classify as any of these?
function bool IsWallNormal(vector n)
{
    return n.Z > -0.5 && n.Z < 0.5;
}

function bool IsFloorNormal(vector n)
{
    return n.Z > 0.5;
}

function bool IsCeilingNormal(vector n)
{
    return n.Z < -0.5;
}

function bool NearestSurface(vector StartTrace, vector EndTrace, out LocationNormal ret)
{
    local Actor HitActor;
    local vector HitLocation, HitNormal;

    HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
    if( StartTrace == HitLocation ) {
        return false;
    }
    if ( HitActor == Level ) {
        ret.loc = HitLocation;
        ret.norm = HitNormal;
        return true;
    }
    return false;
}

function float GetDistanceFromSurface(vector StartTrace, vector EndTrace)
{
    local LocationNormal locnorm;
    locnorm.loc = EndTrace;
    NearestSurface(StartTrace, EndTrace, locnorm);
    return VSize( StartTrace - locnorm.loc );
}

function bool NearestCeiling(out LocationNormal out, FMinMax distrange, optional float away_from_wall)
{
    local vector EndTrace, MoveOffWall;
    EndTrace = out.loc;
    EndTrace.Z += distrange.max;
    if( NearestSurface(out.loc + (vect(0,0,1)*distrange.min), EndTrace, out) == false ) {
        return false;
    }
    if( ! IsCeilingNormal(out.norm) ) {
        return false;
    }
    MoveOffWall.X = away_from_wall;
    MoveOffWall.Y = away_from_wall;
    MoveOffWall.Z = away_from_wall;
    MoveOffWall *= out.norm;
    out.loc += MoveOffWall;
    return true;
}

function bool NearestFloor(out LocationNormal out, FMinMax distrange, optional float away_from_wall)
{
    local vector EndTrace, MoveOffWall;
    EndTrace = out.loc;
    EndTrace.Z -= distrange.max;
    if( NearestSurface(out.loc - (vect(0,0,1)*distrange.min), EndTrace, out) == false ) {
        return false;
    }
    if( ! IsFloorNormal(out.norm) ) {
        return false;
    }
    MoveOffWall.X = away_from_wall;
    MoveOffWall.Y = away_from_wall;
    MoveOffWall.Z = away_from_wall;
    MoveOffWall *= out.norm;
    out.loc += MoveOffWall;
    return true;
}

function bool _FindWallAlongNormal(out LocationNormal out, vector against, FMinMax distrange)
{
    local LocationNormal t, ret;
    local vector end, along;
    local float closest_dist, dist;
    local int i;

    closest_dist = distrange.max;
    along = Normal(against cross vect(0, 0, 1));

    for(i=0; i<2; i++) {
        end = out.loc;
        along *= -1;//negative first and then positive
        end += along * closest_dist;
        t = out;
        t.loc += along * distrange.min;
        if( NearestSurface(t.loc, end, t) ) {
            if( IsWallNormal(t.norm) ) {
                ret = t;
                dist = VSize(t.loc - out.loc);
                closest_dist = dist;
            }
        }
    }

    if( closest_dist >= distrange.max ) {
        return false;
    }
    out = ret;
    return true;
}

function bool _NearestWall(out LocationNormal out, FMinMax distrange)
{
    local LocationNormal t, ret;
    local vector along;
    local float closest_dist, dist;
    local int i;

    closest_dist = distrange.max;
    along = vect(1,0,0);//first we do the X axis

    for(i=0; i<2; i++) {
        t = out;
        if( _FindWallAlongNormal(t, along, distrange) ) {
            dist = VSize(t.loc - out.loc);
            if( dist < closest_dist ) {
                ret = t;
                closest_dist = dist;
            }
        }
        along = vect(0,1,0);//next we do the Y axis
    }

    if( closest_dist >= distrange.max ) {
        return false;
    }
    out = ret;
    return true;
}

function bool NearestWall(out LocationNormal out, FMinMax distrange, optional float away_from_wall)
{
    local vector MoveOffWall, normal;
    
    if( _NearestWall(out, distrange) == false ) {
        return false;
    }
    MoveOffWall.X = away_from_wall;
    MoveOffWall.Y = away_from_wall;
    MoveOffWall.Z = away_from_wall;
    MoveOffWall *= out.norm;
    out.loc += MoveOffWall;
    return true;
}

function bool NearestWallSearchZ(out LocationNormal out, FMinMax distrange, float z_range, vector target, optional float away_from_wall)
{
    local LocationNormal wall, ret;
    local vector MoveOffWall;
    local float closest_dist, dist;
    local int i;
    local float len;

    closest_dist = distrange.max;
    len = 4.0;// 4 checks plus the center
    for(i=0; i<5; i++) {
        wall = out;
        wall.loc.Z += z_range * (Float(i) / len * 2.0 - 1.0);
        if( _NearestWall(wall, distrange) ) {
            dist = VSize(wall.loc - target);
            if( dist < closest_dist && dist >= distrange.min ) {
                closest_dist = dist;
                ret = wall;
            }
        }
    }

    if( closest_dist >= distrange.max ) {
        return false;
    }
    MoveOffWall.X = away_from_wall;
    MoveOffWall.Y = away_from_wall;
    MoveOffWall.Z = away_from_wall;
    MoveOffWall *= ret.norm;
    ret.loc += MoveOffWall;
    out = ret;
    return true;
}

function bool NearestCornerSearchZ(out LocationNormal out, FMinMax distrange, vector against, float z_range, vector target, optional float away_from_wall)
{
    local LocationNormal wall, ret;
    local vector MoveOffWall;
    local float closest_dist, dist;
    local int i;
    local float len;

    closest_dist = distrange.max;
    len = 4.0;// 4 checks plus the center
    for(i=0; i<5; i++) {
        wall = out;
        wall.loc.Z += z_range * (Float(i) / len * 2.0 - 1.0);
        if( _FindWallAlongNormal(wall, against, distrange) ) {
            dist = VSize(wall.loc - target);
            if( dist < closest_dist && dist >= distrange.min ) {
                closest_dist = dist;
                ret = wall;
            }
        }
    }

    if( closest_dist >= distrange.max ) {
        return false;
    }
    MoveOffWall.X = away_from_wall;
    MoveOffWall.Y = away_from_wall;
    MoveOffWall.Z = away_from_wall;
    MoveOffWall *= ret.norm;
    ret.loc += MoveOffWall;
    out = ret;
    return true;
}

function Vector GetCenter(Actor test)
{
    local Vector MinVect, MaxVect;

    test.GetBoundingBox(MinVect, MaxVect);
    return (MinVect+MaxVect)/2;
}

function int GetSafeRule(safe_rule rules[32], name item_name, vector newpos)
{
    local int i;

    for(i=0; i<ArrayCount(rules); i++) {
        if( item_name != rules[i].item_name ) continue;
        if( dxr.localURL != rules[i].map ) continue;
        if( AnyGreater( rules[i].min_pos, newpos ) ) continue;
        if( AnyGreater( newpos, rules[i].max_pos ) ) continue;
        return i;
    }
    return -1;
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
