class DXRKeys extends DXRActorsBase;

function FirstEntry()
{
    Super.FirstEntry();
    if( dxr.flags.keysrando == 4 )
        MoveNanoKeys4();
    else if( dxr.flags.keysrando == 2 )
        MoveNanoKeys();
}

function AnyEntry()
{
    local NanoKey k;
    Super.AnyEntry();
    AdjustRestrictions(dxr.flags.doorspickable, dxr.flags.doorsdestructible, dxr.flags.deviceshackable, dxr.flags.removeinvisiblewalls);

    foreach AllActors(class'NanoKey', k )
    {
        if ( SkipActorBase(k) ) continue;
        SetActorScale(k, 1.3);
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

        SetActorScale(k, 1.3);

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
        slot=rng(num-1);
        i=0;
        foreach AllActors(class'Inventory', a)
        {
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
    local Inventory a;
    local NanoKey k;
    local int num, i, slot;

    foreach AllActors(class'NanoKey', k )
    {
        if ( SkipActorBase(k) ) continue;

        SetActorScale(k, 1.3);

        i=0;
        num=0;
        foreach AllActors(class'Inventory', a)
        {
            if( SkipActor(a, 'Inventory') ) continue;
            if( KeyPositionGood(k, a.Location) == False ) continue;
            num++;
        }

        slot=rng(num-1);
        i=0;
        l("key "$k.KeyID$" got num "$num);
        foreach AllActors(class'Inventory', a)
        {
            if( SkipActor(a, 'Inventory') ) continue;
            if( KeyPositionGood(k, a.Location) == False ) continue;

            if(i==slot) {
                l("swapping key "$k.KeyID$" with "$a.Class);
                Swap(k, a);
                break;
            }
            i++;
        }
    }
}

function bool KeyPositionGood(NanoKey k, vector newpos)
{
    local DeusExMover d;
    local float dist;
    
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

function AdjustRestrictions(int doorspickable, int doorsdestructible, int deviceshackable, int removeinvisiblewalls)
{
    local DeusExMover d;
    local Keypoint kp;

    foreach AllActors(class'DeusExMover', d)
    {
        if( d.KeyIDNeeded != 'None' ) l("found door with KeyIDNeeded == " $ d.KeyIDNeeded);
        //if( d.KeyIDNeeded == 'None' || d.bPickable || d.bBreakable ) continue;
        if( d.bPickable || d.bBreakable ) continue;

        if( d.bPickable == false && doorspickable > 0 ) {
            d.bPickable = true;
            d.lockStrength = 1;
            d.initiallockStrength = 1;
        }
        if( d.bBreakable == false && doorsdestructible > 0 ) {
            d.bBreakable = true;
            d.minDamageThreshold = 75;
            d.doorStrength = 1;
        }
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

