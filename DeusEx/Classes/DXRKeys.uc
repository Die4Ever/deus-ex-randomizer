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

    foreach AllActors(class'DeusExMover', d)
    {
        if( d.KeyIDNeeded != k.KeyID ) continue;
        if( PositionIsSafe(k.Location, d, newpos) == False ) return False;
    }
    return True;
}

function AdjustRestrictions(int doorspickable, int doorsdestructible, int deviceshackable, int removeinvisiblewalls)
{
    local DeusExMover d;
    local Keypoint kp;

    foreach AllActors(class'DeusExMover', d)
    {
        if( (d.KeyIDNeeded$"") == "None" || d.bPickable || d.bBreakable ) continue;

        if( d.bPickable == false && doorspickable > 0 ) {
            d.bPickable = true;
            d.lockStrength = 1;
            d.initiallockStrength = 1;
        }
        if( d.bBreakable == false && doorsdestructible > 0 ) {
            d.bBreakable = true;
            d.minDamageThreshold = 50;
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
