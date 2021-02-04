class DXRKeys extends DXRActorsBase;

struct key_rule {
    var string map;
    var name key_id;
    var vector min_pos;
    var vector max_pos;
    var bool allow;
};
var config key_rule keys_rules[32];

struct door_fix {
    var string map;
    var name tag;//what about doors that don't have tags? should I use name instead?
    var bool bBreakable;
    var float minDamageThreshold;
    var float doorStrength;
    var bool bPickable;
    var float lockStrength;
};
var config door_fix door_fixes[32];

var config float min_lock_adjust, max_lock_adjust, min_door_adjust, max_door_adjust;

function CheckConfig()
{
    local int i;
    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,7) ) {
        i=0;

        keys_rules[i].map = "03_NYC_747";
        keys_rules[i].key_id = 'lebedevdoor';
        keys_rules[i].min_pos = vect(166, -99999, -99999);
        keys_rules[i].max_pos = vect(99999, 99999, 99999);
        keys_rules[i].allow = true;
        i++;

        keys_rules[i].map = "10_Paris_Chateau";
        keys_rules[i].key_id = 'duclare_chateau';
        keys_rules[i].min_pos = vect(-99999, -99999, -125);
        keys_rules[i].max_pos = vect(99999, 99999, 99999);
        keys_rules[i].allow = true;
        i++;

        keys_rules[i].map = "11_Paris_Cathedral";
        keys_rules[i].key_id = 'cath_maindoors';
        keys_rules[i].min_pos = vect(-99999, -99999, -99999);
        keys_rules[i].max_pos = vect(99999, 99999, 99999);
        keys_rules[i].allow = true;
        i++;

        keys_rules[i].map = "11_Paris_Cathedral";
        keys_rules[i].key_id = 'cathedralgatekey';
        keys_rules[i].min_pos = vect(-4907, 1802, -99999);
        keys_rules[i].max_pos = vect(99999, 99999, 99999);
        keys_rules[i].allow = true;
        i++;

        //disallow the crew quarters
        keys_rules[i].map = "14_oceanlab_lab";
        keys_rules[i].key_id = 'crewkey';
        keys_rules[i].min_pos = vect(-99999, 3034, -99999);
        keys_rules[i].max_pos = vect(3633, 99999, 99999);
        keys_rules[i].allow = false;
        i++;

        //disallow west (smaller X) of the flooded area
        keys_rules[i].map = "14_oceanlab_lab";
        keys_rules[i].key_id = 'crewkey';
        keys_rules[i].min_pos = vect(-99999, -99999, -99999);
        keys_rules[i].max_pos = vect(-414.152771, 99999, 99999);
        keys_rules[i].allow = false;
        i++;

        //allow anything to the west (smaller X) of the crew quarters, except for the flooded area
        keys_rules[i].map = "14_oceanlab_lab";
        keys_rules[i].key_id = 'crewkey';
        keys_rules[i].min_pos = vect(-414.152771, -99999, -99999);
        keys_rules[i].max_pos = vect(4856, 99999, 99999);
        keys_rules[i].allow = true;
        i++;

        //disallow flooded area
        keys_rules[i].map = "14_oceanlab_lab";
        keys_rules[i].key_id = 'storage';
        keys_rules[i].min_pos = vect(-99999, -99999, -99999);
        keys_rules[i].max_pos = vect(-414.152771, 99999, 99999);
        keys_rules[i].allow = false;
        i++;

        //disallow flooded area
        keys_rules[i].map = "14_oceanlab_lab";
        keys_rules[i].key_id = 'Glab';
        keys_rules[i].min_pos = vect(-99999, -99999, -99999);
        keys_rules[i].max_pos = vect(-414.152771, 99999, 99999);
        keys_rules[i].allow = false;
        i++;

        //disallow storage closet
        keys_rules[i].map = "14_oceanlab_lab";
        keys_rules[i].key_id = 'storage';
        keys_rules[i].min_pos = vect(528.007446, -99999, -1653.906006);
        keys_rules[i].max_pos = vect(1047.852173, 436.867401, 99999);
        keys_rules[i].allow = false;
        i++;

        //allow before greasel lab
        keys_rules[i].map = "14_oceanlab_lab";
        keys_rules[i].key_id = 'storage';
        keys_rules[i].min_pos = vect(-414.152771, -99999, -99999);
        keys_rules[i].max_pos = vect(1888, 1930.014771, 99999);
        keys_rules[i].allow = true;
        i++;
        // X < -414.152771 == flooded area...
        // X > 528.007446, X < 1047.852173, Y < 436.867401, Z > -1653.906006 == storage closet
        // 1888.000000, 544.000000, -1536.000000 == glabs door, X > -414.152771 && X < 1888 && Y < 1930.014771 == before greasel labs
        // 4856.000000, 3515.999512, -1816.000000 == crew quarters door

        i=0;
        door_fixes[i].map = "05_NYC_UNATCOHQ";
        door_fixes[i].tag = 'supplydoor';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 75;
        door_fixes[i].doorStrength = 1;
        door_fixes[i].bPickable = true;
        door_fixes[i].lockStrength = 1;
        i++;

        door_fixes[i].map = "15_area51_entrance";
        door_fixes[i].tag = 'chamber1';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 75;
        door_fixes[i].doorStrength = 1;
        door_fixes[i].bPickable = true;
        door_fixes[i].lockStrength = 1;
        i++;
        door_fixes[i].map = "15_area51_entrance";
        door_fixes[i].tag = 'chamber2';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 75;
        door_fixes[i].doorStrength = 1;
        door_fixes[i].bPickable = true;
        door_fixes[i].lockStrength = 1;
        i++;
        door_fixes[i].map = "15_area51_entrance";
        door_fixes[i].tag = 'chamber3';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 75;
        door_fixes[i].doorStrength = 1;
        door_fixes[i].bPickable = true;
        door_fixes[i].lockStrength = 1;
        i++;
        door_fixes[i].map = "15_area51_entrance";
        door_fixes[i].tag = 'chamber4';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 75;
        door_fixes[i].doorStrength = 1;
        door_fixes[i].bPickable = true;
        door_fixes[i].lockStrength = 1;
        i++;
        door_fixes[i].map = "15_area51_entrance";
        door_fixes[i].tag = 'chamber5';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 75;
        door_fixes[i].doorStrength = 1;
        door_fixes[i].bPickable = true;
        door_fixes[i].lockStrength = 1;
        i++;
        door_fixes[i].map = "15_area51_entrance";
        door_fixes[i].tag = 'chamber6';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 75;
        door_fixes[i].doorStrength = 1;
        door_fixes[i].bPickable = true;
        door_fixes[i].lockStrength = 1;
        i++;
    }
    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,8) ) {
        min_lock_adjust = 0.5;
        max_lock_adjust = 1.5;
        min_door_adjust = 0.5;
        max_door_adjust = 1.5;
    }
    for(i=0; i<ArrayCount(keys_rules); i++) {
        keys_rules[i].map = Caps(keys_rules[i].map);
    }
    for(i=0; i<ArrayCount(door_fixes); i++) {
        door_fixes[i].map = Caps(door_fixes[i].map);
    }
    Super.CheckConfig();
}

function FirstEntry()
{
    Super.FirstEntry();
    if( dxr.flags.keysrando == 4 )
        MoveNanoKeys4();
    else if( dxr.flags.keysrando == 2 )
        MoveNanoKeys();

    RandomizeDoors();
}

function AnyEntry()
{
    local NanoKey k;
    Super.AnyEntry();
    AdjustRestrictions(dxr.flags.doorsmode, dxr.flags.doorspickable, dxr.flags.doorsdestructible, dxr.flags.deviceshackable, dxr.flags.removeinvisiblewalls);

    foreach AllActors(class'NanoKey', k )
    {
        if ( SkipActorBase(k) ) continue;
        SetActorScale(k, 1.3);
    }
}

function RandomizeDoors()
{
    local DeusExMover d;

    SetSeed( "RandomizeDoors" );

    foreach AllActors(class'DeusExMover', d) {
        if( d.bPickable ) {
            d.lockStrength = FClamp(rngrange(d.lockStrength, min_lock_adjust, max_lock_adjust), 0, 1);
        }
        if( d.bBreakable ) {
            d.doorStrength = FClamp(rngrange(d.doorStrength, min_door_adjust, max_door_adjust), 0, 1);
        }
    }
}

function MoveNanoKeys()
{
    local Inventory a;
    local NanoKey k;
    local DeusExMover d;
    local int num, i, slot;
    local vector doorloc, distkey, distdoor;

    num=0;

    SetSeed( "MoveNanoKeys" );

    foreach AllActors(class'NanoKey', k )
    {
        if ( SkipActorBase(k) ) continue;

        doorloc = vect(99999, 99999, 99999);
        foreach AllActors(class'DeusExMover', d)
        {
            if( d.KeyIDNeeded == k.KeyID ) {
                doorloc = d.Location;
                break;
            }
        }
        i=0;
        num=0;
        foreach AllActors(class'Inventory', a)
        {
            if( SkipActor(a, 'Inventory') ) continue;
            distkey = AbsEach(a.Location - k.Location);
            distdoor = AbsEach(a.Location - doorloc);
            if ( AnyGreater( distkey, distdoor ) ) continue;
            num++;
        }
        slot=rng(num-1);// -1 because we skip ourself
        i=0;
        foreach AllActors(class'Inventory', a)
        {
            if( a == k ) continue;
            if( SkipActor(a, 'Inventory') ) continue;
            distkey = AbsEach(a.Location - k.Location);
            distdoor = AbsEach(a.Location - doorloc);
            if ( AnyGreater( distkey, distdoor ) ) continue;

            if(i==slot) {
                l("swapping key "$k.KeyID$" (distdoor "$distdoor$", distkey "$distkey$") with "$a.Class);
                Swap(k, a);
                break;
            }
            i++;
        }
    }
}

function MoveNanoKeys4()
{
    local DeusExCarcass carc;
    local Inventory a;
    local Containers c;
    local NanoKey k;
    local int num, i, slot;

    SetSeed( "MoveNanoKeys4" );

    foreach AllActors(class'DeusExCarcass', carc) {
        carc.DropKeys();
    }

    foreach AllActors(class'NanoKey', k )
    {
        if ( SkipActorBase(k) ) continue;

        i=0;
        num=0;
        foreach AllActors(class'Inventory', a)
        {
            if( a == k ) continue;
            if( SkipActor(a, 'Inventory') ) continue;
            if( KeyPositionGood(k, a.Location) == False ) continue;
            num++;
        }
        /*foreach AllActors(class'Containers', c)
        {
            if( SkipActor(c, 'Containers') ) continue;
            if( KeyPositionGood(k, c.Location) == False ) continue;
            num++;
        }*/

        slot=rng(num+1);// +1 for vanilla
        if(slot==0) {
            l("not swapping key "$k.KeyID);
            continue;
        }
        slot--;
        i=0;
        l("key "$k.KeyID$" got num "$num);
        foreach AllActors(class'Inventory', a)
        {
            if( a == k ) continue;
            if( SkipActor(a, 'Inventory') ) continue;
            if( KeyPositionGood(k, a.Location) == False ) continue;

            if(i==slot) {
                l("swapping key "$k.KeyID$" with "$a);
                Swap(k, a);
                break;
            }
            i++;
        }
        /*if(i==slot) continue;
        foreach AllActors(class'Containers', c)
        {
            if( SkipActor(c, 'Containers') ) continue;
            if( KeyPositionGood(k, c.Location) == False ) continue;

            if(i==slot) {
                l("swapping key "$k.KeyID$" with "$c.Class);
                Swap(k, c);
                break;
            }
            i++;
        }*/
    }
}

function bool KeyPositionGood(NanoKey k, vector newpos)
{
    local DeusExMover d;
    local float dist;
    local int i, matches;

    for(i=0; i<ArrayCount(keys_rules); i++) {
        if( k.KeyID != keys_rules[i].key_id ) continue;
        if( dxr.localURL != keys_rules[i].map ) continue;
        //err("found it");
        matches++;
        if( AnyGreater( keys_rules[i].min_pos, newpos ) ) continue;//return ! keys_rules[i].allow;
        if( AnyGreater( newpos, keys_rules[i].max_pos ) ) continue;//return ! keys_rules[i].allow;
        return keys_rules[i].allow;
    }
    //if( matches > 0 ) return false;

    dist = VSize( k.Location - newpos );
    if( dist > 5000 ) return False;

    foreach AllActors(class'DeusExMover', d)
    {
        if( d.KeyIDNeeded == 'None' ) continue;
        else if( d.KeyIDNeeded != k.KeyID )
        {
            //if( PositionIsSafeLenient(k.Location, d, newpos) == False ) return False;
        }
        else if( PositionIsSafe(k.Location, d, newpos) == False ) return False;
    }
    //l("KeyPositionGood ("$ActorToString(k)$", "$newpos$") returning True with distance: "$dist);
    return True;
}

function AdjustRestrictions(int doorsmode, int doorspickable, int doorsdestructible, int deviceshackable, int removeinvisiblewalls)
{
    local Keypoint kp;
    SetSeed( "AdjustRestrictions" );

    switch( (doorsmode/256) ) {
        case 1:
            AdjustUndefeatableDoors(doorsmode%256, doorspickable, doorsdestructible);
            break;
        case 2:
            AdjustAllDoors(doorsmode%256, doorspickable, doorsdestructible);
            break;
        case 3:
            AdjustKeyOnlyDoors(doorsmode%256, doorspickable, doorsdestructible);
            break;
        case 4:
            AdjustHighlightableDoors(doorsmode%256, doorspickable, doorsdestructible);
            break;
        default:
            break;
    }

    if( removeinvisiblewalls == 1 ) {
        foreach AllActors(class'Engine.Keypoint', kp)
        {
            if( kp.bBlockPlayers ) {
                l("found invisible wall "$ActorToString(kp));
                kp.bBlockPlayers=false;
            }
        }
    }

    ApplyDoorFixes();
}

function ApplyDoorFixes()
{
    local DeusExMover d;
    local int i;

    foreach AllActors(class'DeusExMover', d) {
        for(i=0; i<ArrayCount(door_fixes); i++) {
            if( door_fixes[i].tag != d.Tag ) continue;
            if( dxr.localURL != door_fixes[i].map ) continue;

            if( door_fixes[i].bPickable ) MakePickable(d);
            d.bPickable = door_fixes[i].bPickable;
            d.lockStrength = door_fixes[i].lockStrength;
            if( door_fixes[i].bBreakable ) MakeDestructible(d);
            d.bBreakable = door_fixes[i].bBreakable;
            d.minDamageThreshold = door_fixes[i].minDamageThreshold;
            d.doorStrength = door_fixes[i].doorStrength;
        }
    }
}

function AdjustUndefeatableDoors(int exclusivitymode, int doorspickable, int doorsdestructible)
{
    local DeusExMover d;

    foreach AllActors(class'DeusExMover', d)
    {
        if( d.bPickable || d.bBreakable ) continue;
        AdjustDoor(d, exclusivitymode, doorspickable, doorsdestructible);
    }
}

function AdjustAllDoors(int exclusivitymode, int doorspickable, int doorsdestructible)
{
    local DeusExMover d;

    foreach AllActors(class'DeusExMover', d)
    {
        if( d.bHighlight == false || d.bFrobbable == false ) {
            d.bPickable = false;
            d.bLocked = true;
            d.bHighlight = true;
            d.bFrobbable = true;
        }
        AdjustDoor(d, exclusivitymode, doorspickable, doorsdestructible);
    }
}

function AdjustKeyOnlyDoors(int exclusivitymode, int doorspickable, int doorsdestructible)
{
    local DeusExMover d;

    foreach AllActors(class'DeusExMover', d)
    {
        if( d.bHighlight == false || d.bFrobbable == false ) continue;
        if( d.KeyIDNeeded == 'None' || d.bPickable || d.bBreakable ) continue;
        AdjustDoor(d, exclusivitymode, doorspickable, doorsdestructible);
    }
}

function AdjustHighlightableDoors(int exclusivitymode, int doorspickable, int doorsdestructible)
{
    local DeusExMover d;

    foreach AllActors(class'DeusExMover', d)
    {
        if( d.bHighlight == false || d.bFrobbable == false ) continue;
        AdjustDoor(d, exclusivitymode, doorspickable, doorsdestructible);
    }
}

function AdjustDoor(DeusExMover d, int exclusivitymode, int doorspickable, int doorsdestructible)
{
    local int r;
    switch(exclusivitymode) {
        // mutually inclusive (they always go together)
        case 1:
            if( chance_single( (doorspickable + doorsdestructible) / 2 ) ) {
                MakePickable(d);
                MakeDestructible(d);
            }
            break;
        // independent
        case 2:
            if( chance_single(doorspickable) ) {
                MakePickable(d);
            }
            if( chance_single(doorsdestructible) ) {
                MakeDestructible(d);
            }
            break;
        // mutually exclusive
        case 3:
            r = initchance();
            if( chance(doorspickable, r) ) {
                MakePickable(d);
            }
            if( chance(doorsdestructible, r) ) {
                MakeDestructible(d);
            }
            chance_remaining(r);
            break;
        default:
            break;
    }
}

static function MakePickable(DeusExMover d)
{
    if( d.bHighlight == false || d.bFrobbable == false ) {
        d.bPickable = false;
        d.bLocked = true;
        d.bHighlight = true;
        d.bFrobbable = true;
    }
    if( d.bPickable == false ) {
        d.bPickable = true;
        d.lockStrength = 1;
        d.initiallockStrength = 1;
    }
}

static function MakeDestructible(DeusExMover d)
{
    if( d.bHighlight == false || d.bFrobbable == false ) {
        d.bPickable = false;
        d.bLocked = true;
        d.bHighlight = true;
        //d.bFrobbable = true;
    }
    if( d.bBreakable == false ) {
        d.bBreakable = true;
        d.minDamageThreshold = 75;
        d.doorStrength = 1;
    }
}

function int RunTests()
{
    local int results;
    results = Super.RunTests();

    //1d tests
    results += testbool( _PositionIsSafeOctant(vect(1,0,0), vect(0,0,0), vect(0.2,0,0)), true, "1d test" );

    results += testbool( _PositionIsSafeOctant(vect(1,0,0), vect(0,0,0), vect(2,0,0)), true, "1d test" );
    results += testbool( _PositionIsSafeOctant(vect(1,0,0), vect(0,0,0), vect(-2,0,0)), false, "1d test" );

    results += testbool( _PositionIsSafeOctant(vect(1,0,0), vect(0,0,0), vect(0,0,0)), false, "1d test" );
    results += testbool( _PositionIsSafeOctant(vect(1,0,0), vect(0,0,0), vect(-0.001,0,0)), false, "1d test" );

    results += testbool( _PositionIsSafeOctant(vect(0.1,0,0), vect(0,0,0), vect(0,0,0)), false, "1d test" );
    results += testbool( _PositionIsSafeOctant(vect(0.1,0,0), vect(0,0,0), vect(-0.001,0,0)), false, "1d test" );

    results += testbool( _PositionIsSafeOctant(vect(0.1,0,0), vect(0,0,0), vect(0.01,0,0)), true, "1d test" );
    results += testbool( _PositionIsSafeOctant(vect(0.1,0,0), vect(0,0,0), vect(0.011,0,0)), true, "1d test" );

    results += testbool( _PositionIsSafeOctant(vect(1,0,0), vect(4,0,0), vect(2,0,0)), true, "1d test" );
    results += testbool( _PositionIsSafeOctant(vect(-1,0,0), vect(4,0,0), vect(-2,0,0)), true, "1d test" );

    //2d tests
    results += testbool( _PositionIsSafeOctant(vect(-5,-5,0), vect(-10,-10,0), vect(0,0,0)), true, "2d test" );
    results += testbool( _PositionIsSafeOctant(vect(-5,-5,0), vect(-10,-10,0), vect(-90,0,0)), false, "2d test" );
    results += testbool( _PositionIsSafeOctant(vect(-5,-5,0), vect(-10,-10,0), vect(0,-90,0)), false, "2d test" );
    results += testbool( _PositionIsSafeOctant(vect(-5,-5,0), vect(-10,-10,0), vect(-11,-11,0)), false, "2d test" );

    //3d tests
    results += testbool( _PositionIsSafeOctant(vect(1,-5,2), vect(0,0,0), vect(1,-3,1000)), true, "3d test" );
    results += testbool( _PositionIsSafeOctant(vect(1,-5,2), vect(0,0,0), vect(10.5,-0.8,100)), true, "3d test" );
    results += testbool( _PositionIsSafeOctant(vect(1,-5,2), vect(0,0,0), vect(10.5,-0.6,100)), true, "3d test" );
    results += testbool( _PositionIsSafeOctant(vect(1,-5,2), vect(0,0,0), vect(0.1,-0.1,10000)), true, "3d test" );

    //real numbers from 10_Paris_Chateau
    results += testbool( _PositionIsSafeOctant(vect(1299.113892,791.412354,435.917358), vect(1376.000000,1100.000000,-192.000000), vect(1254.237061,774.329773,422.100922)), true, "Chateau test");
    results += testbool( _PositionIsSafeOctant(vect(1299.113892,791.412354,435.917358), vect(1376.000000,1100.000000,-192.000000), vect(1297.832275,777.074097,436.520996)), true, "Chateau test");
    results += testbool( _PositionIsSafeOctant(vect(1299.113892,791.412354,435.917358), vect(1376.000000,1100.000000,-192.000000), vect(1442.119873,3275.193359,-526.853638)), false, "Chateau test");

    //real numbers from OceanLab
    results += testbool( _PositionIsSafeOctant(vect(3013.000732,2131.418213,-1792.079956), vect(4824,3528,-1752), vect(1590.162842,269.466125,-1578.974854)), false, "OceanLab test" );
    results += testbool( _PositionIsSafeOctant(vect(3013.000732,2131.418213,-1792.079956), vect(4824,3528,-1752), vect(-2588.39917,-5.10672,-1793.654907)), true, "OceanLab test" );
    results += testbool( _PositionIsSafeOctant(vect(3013.000732,2131.418213,-1792.079956), vect(4824,3528,-1752), vect(3037.546875,2127.136963,-1791.484619)), true, "OceanLab test" );
    results += testbool( _PositionIsSafeOctant(vect(3013.000732,2131.418213,-1792.079956), vect(4824,3528,-1752), vect(-2618.925049,-122.853104,-1833.302734)), true, "OceanLab test" );

    results += testbool( _PositionIsSafeOctant(vect(-2588.39917,-5.10672,-1794.256958), vect(1048,80,-1544), vect(785.475647,-79.326523,-1601.681763)), true, "OceanLab test" );
    results += testbool( _PositionIsSafeOctant(vect(1237.800659,112.333527,-1625.307007), vect(1880.000000,552.000000,-1544.000000), vect(-2620.478516,-19.642990,-1795.483643)), true, "OceanLab test" );

    return results;
}

