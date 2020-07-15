class DXRKeys extends DXRActorsBase;

function FirstEntry()
{
    Super.FirstEntry();
    MoveNanoKeys(dxr.flags.keysrando);
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

function MoveNanoKeys(int mode)
{
    local Inventory a;
    local NanoKey k;
    local DeusExMover d;
    local int num, i, slot;
    local vector doorloc, distkey, distdoor;

    num=0;

    // 0=off, 1=dumb, 2=smart, 3=copies
    if( mode == 0 ) return;

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
