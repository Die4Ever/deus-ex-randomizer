class DXRDoors extends DXRActorsBase transient;

struct door_fix {
    var name tag;//what about doors that don't have tags? should I use name instead?
    var bool bBreakable;
    var float minDamageThreshold;
    var float doorStrength;
    var bool bPickable;
    var float lockStrength;
    var bool bHighlight;
};
var door_fix door_fixes[16];

var float min_lock_adjust, max_lock_adjust, min_door_adjust, max_door_adjust, min_mindmg_adjust, max_mindmg_adjust;

function CheckConfig()
{
    local int i;

    switch(dxr.localURL) {
    case "02_NYC_STREET":
    case "04_NYC_STREET":
    case "08_NYC_STREET":
        // SmugglersFrontDoor for all 3 maps
        door_fixes[i].tag = 'SmugglersFrontDoor';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 60;
        door_fixes[i].doorStrength = 1;
        door_fixes[i].bPickable = true;
        door_fixes[i].lockStrength = 1;
        door_fixes[i].bHighlight = true;
        i++;
        break;

    case "02_NYC_SMUG":
    case "04_NYC_SMUG":
    case "08_NYC_SMUG":
        // Always make smugglers stash highlightable and breakable
        door_fixes[i].tag = 'mirrordoor';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 5;
        door_fixes[i].doorStrength = 0.6;
        door_fixes[i].bHighlight = true;
        i++;
        break;

    case "04_NYC_NSFHQ":
        // door to the basement
        door_fixes[i].tag = 'ExitDoor';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 0;// 0 uses a random value instead
        door_fixes[i].doorStrength = 0;
        door_fixes[i].bPickable = true;
        door_fixes[i].lockStrength = 0;
        door_fixes[i].bHighlight = true;
        i++;

        // doors to the computer room
        door_fixes[i].tag = 'SlidingDoor1Move';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 20;// 0 uses a random value instead
        door_fixes[i].doorStrength = 0.5;
        door_fixes[i].bPickable = false;
        door_fixes[i].lockStrength = 0;
        door_fixes[i].bHighlight = false;
        i++;

        door_fixes[i] = door_fixes[i-1];
        door_fixes[i].tag = 'SlidingDoor2Move';
        i++;
        break;

    case "05_NYC_UNATCOHQ":
        // just in case General Carter's door gets stuck on something
        door_fixes[i].tag = 'supplydoor';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 60;
        door_fixes[i].doorStrength = 1;
        door_fixes[i].bPickable = true;
        door_fixes[i].lockStrength = 1;
        door_fixes[i].bHighlight = true;
        i++;
        break;

    case "06_HONGKONG_WANCHAI_MARKET":
        // Make sure random people don't bust down Tong's gate
        door_fixes[i].tag = 'compound_gate';
        door_fixes[i].bBreakable = false;
        door_fixes[i].bPickable = false;
        door_fixes[i].bHighlight = false;
        i++;
        break;

    case "06_HONGKONG_WANCHAI_STREET":
        //Make sure the display case isn't highlightable
        door_fixes[i].tag = 'DispalyCase';
        door_fixes[i].bBreakable = false;
        door_fixes[i].bPickable = false;
        door_fixes[i].bHighlight = false;
        i++;

    case "06_HongKong_MJ12lab":
        // Elevator doors
        door_fixes[i].tag = 'eledoor02';
        door_fixes[i].bBreakable = true;
        door_fixes[i].bPickable = false;
        door_fixes[i].bHighlight = true;
        door_fixes[i].minDamageThreshold = 1;
        door_fixes[i].doorStrength = 0.01;
        i++;
        break;

    case "09_NYC_SHIP":
        // don't break the ramp up to the ship!
        door_fixes[i].tag = 'ShipRamp';
        door_fixes[i].bBreakable = false;
        door_fixes[i].minDamageThreshold = 60;
        door_fixes[i].doorStrength = 1;
        door_fixes[i].bPickable = false;
        door_fixes[i].lockStrength = 1;
        door_fixes[i].bHighlight = false;
        i++;
        break;

    case "09_NYC_SHIPBELOW":
        // don't randomize the weld points
        door_fixes[i].tag = 'ShipBreech';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 55;
        door_fixes[i].doorStrength = 0.5;
        door_fixes[i].bPickable = false;
        door_fixes[i].lockStrength = 1;
        door_fixes[i].bHighlight = true;
        i++;
        break;

    case "09_NYC_GRAVEYARD":
        // don't randomize the EMOff transmitter
        door_fixes[i].tag = 'BreakableWall';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 1;
        door_fixes[i].doorStrength = 0.15;
        door_fixes[i].bPickable = false;
        door_fixes[i].lockStrength = 1;
        door_fixes[i].bHighlight = true;
        i++;
        break;

    case "10_Paris_Chateau":
        // make chateau cellar undefeatable, if you have lenient doors rules then you won't be going down here anyways
        door_fixes[i].tag = 'duclare_chateau_cellar';
        door_fixes[i].bBreakable = false;
        door_fixes[i].minDamageThreshold = 100;
        door_fixes[i].doorStrength = 1;
        door_fixes[i].bPickable = false;
        door_fixes[i].lockStrength = 1;
        door_fixes[i].bHighlight = true;
        i++;
        break;

    case "12_VANDENBERG_GAS":
        // Always make the junkyard doors weak and breakable
        door_fixes[i].tag = 'junkyard_doors';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 1;
        door_fixes[i].doorStrength = 0.1;
        door_fixes[i].bHighlight = true;
        i++;
        break;

    case "15_area51_entrance":
        // area 51 chambers, in vanilla you can't find the codes for all of these and sometimes the NanoKey you need is in one of them
        door_fixes[i].tag = 'chamber1';
        door_fixes[i].bBreakable = true;
        door_fixes[i].minDamageThreshold = 60;
        door_fixes[i].doorStrength = 1;
        door_fixes[i].bPickable = true;
        door_fixes[i].lockStrength = 1;
        door_fixes[i].bHighlight = true;
        i++;
        door_fixes[i] = door_fixes[i-1];
        door_fixes[i].tag = 'chamber2';
        i++;
        door_fixes[i] = door_fixes[i-1];
        door_fixes[i].tag = 'chamber3';
        i++;
        door_fixes[i] = door_fixes[i-1];
        door_fixes[i].tag = 'chamber4';
        i++;
        door_fixes[i] = door_fixes[i-1];
        door_fixes[i].tag = 'chamber5';
        i++;
        door_fixes[i] = door_fixes[i-1];
        door_fixes[i].tag = 'chamber6';
        i++;
        break;

    case "15_area51_page":
        //Make it so the exploding door doesn't become breakable
        door_fixes[i].tag = 'door_clone_exit';
        door_fixes[i].bBreakable = false;
        door_fixes[i].bPickable = false;
        door_fixes[i].bHighlight = false;
        i++;
        break;
    }

    min_lock_adjust=0.4;
    max_lock_adjust=1.5;
    min_door_adjust=0.4;
    max_door_adjust=1.5;
    min_mindmg_adjust=0.3;
    max_mindmg_adjust=1.2;

    Super.CheckConfig();
}

function FirstEntry()
{
    local #var(DeusExPrefix)Mover d, d2;

    Super.FirstEntry();

    RandomizeDoors();
    AdjustRestrictions(dxr.flags.settings.doorsmode, dxr.flags.settings.doorspickable, dxr.flags.settings.doorsdestructible, dxr.flags.settings.deviceshackable);

    // copy to pairs/sets of doors
    foreach AllActors(class'#var(DeusExPrefix)Mover', d) {
        if (d.Tag == '' || d.Tag == 'DeusExMover') continue;

        foreach AllActors(class'#var(DeusExPrefix)Mover', d2, d.tag) {
            if(d==d2) continue;
            d2.minDamageThreshold = d.minDamageThreshold;
            d2.bPickable = d.bPickable;
            d2.lockStrength = d.lockStrength;
            d2.initiallockStrength = d.initiallockStrength;
            d2.bBreakable = d.bBreakable;
            d2.doorStrength = d.doorStrength;
        }
    }
}

function RandomizeDoors()
{
    local #var(DeusExPrefix)Mover d;

    SetSeed( "RandomizeDoors" );

    foreach AllActors(class'#var(DeusExPrefix)Mover', d) {
        // vanilla knife does 5 damage, we need to ensure that glass is always easily breakable, especially for Stick With the Prod
        if(d.minDamageThreshold <= 5)
            d.minDamageThreshold = 0;

        if( d.bPickable ) {
            d.lockStrength = rngrange(d.lockStrength, min_lock_adjust, max_lock_adjust);
            d.lockStrength = Clamp(d.lockStrength*100, 1, 100)/100.0;
            d.initiallockStrength = d.lockStrength;
        }
        if( d.bBreakable ) {
            d.doorStrength = rngrange(d.doorStrength, min_door_adjust, max_door_adjust);
            d.doorStrength = Clamp(d.doorStrength*100, 1, 100)/100.0;
            d.minDamageThreshold = rngrange(d.minDamageThreshold, min_mindmg_adjust, max_mindmg_adjust);
#ifndef injections
            // without injections we can't augment the highlight window to show mindamagethreshold, so keep it simple for the player
            if(d.minDamageThreshold>0)
                d.minDamageThreshold = d.doorStrength * 60;
#endif
        }
    }
}

function AdjustRestrictions(int doorsmode, int doorspickable, int doorsdestructible, int deviceshackable)
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

    ApplyDoorFixes();
}

function ApplyDoorFixes()
{
    local #var(DeusExPrefix)Mover d;
    local int i;

    foreach AllActors(class'#var(DeusExPrefix)Mover', d) {
        for(i=0; i<ArrayCount(door_fixes); i++) {
            if( door_fixes[i].tag != d.Tag ) continue;

            if( door_fixes[i].bPickable ) MakePickable(d);
            d.bPickable = door_fixes[i].bPickable;
            if(door_fixes[i].lockStrength > 0 )
                d.lockStrength = door_fixes[i].lockStrength;

            d.initiallockStrength = d.lockStrength;
            if( door_fixes[i].bBreakable ) MakeDestructible(d);
            d.bBreakable = door_fixes[i].bBreakable;
            if(door_fixes[i].minDamageThreshold > 0)
                d.minDamageThreshold = door_fixes[i].minDamageThreshold;
            if(door_fixes[i].doorStrength > 0)
                d.doorStrength = door_fixes[i].doorStrength;

            if(door_fixes[i].bHighlight==false){
                d.bFrobbable = false;
                d.bHighlight = false;
            }
        }
    }
}

function AdjustUndefeatableDoors(int exclusivitymode, int doorspickable, int doorsdestructible)
{
    local #var(DeusExPrefix)Mover d;

    foreach AllActors(class'#var(DeusExPrefix)Mover', d)
    {
        if( DoorIsPickable(d) || d.bBreakable ) continue;
        if( !d.bIsDoor && d.KeyIDNeeded == '' && !d.bHighlight && !d.bFrobbable ) continue;
        AdjustDoor(d, exclusivitymode, doorspickable, doorsdestructible);
    }
}

function AdjustAllDoors(int exclusivitymode, int doorspickable, int doorsdestructible)
{
    local #var(DeusExPrefix)Mover d;

    foreach AllActors(class'#var(DeusExPrefix)Mover', d)
    {
        if( !d.bIsDoor && d.KeyIDNeeded == '' && !d.bHighlight && !d.bFrobbable ) continue;
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
    local #var(DeusExPrefix)Mover d;

    foreach AllActors(class'#var(DeusExPrefix)Mover', d)
    {
        if( d.bHighlight == false || d.bFrobbable == false ) continue;
        if( d.KeyIDNeeded == 'None' || DoorIsPickable(d) || d.bBreakable ) continue;
        AdjustDoor(d, exclusivitymode, doorspickable, doorsdestructible);
    }
}

function AdjustHighlightableDoors(int exclusivitymode, int doorspickable, int doorsdestructible)
{
    local #var(DeusExPrefix)Mover d;

    foreach AllActors(class'#var(DeusExPrefix)Mover', d)
    {
        if( d.bHighlight == false || d.bFrobbable == false ) continue;
        AdjustDoor(d, exclusivitymode, doorspickable, doorsdestructible);
    }
}

function AdjustDoor(#var(DeusExPrefix)Mover d, int exclusivitymode, int doorspickable, int doorsdestructible)
{
    local float r;
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

static function bool DoorIsPickable(#var(DeusExPrefix)Mover d)
{// maybe also needs to be bLocked?
    return d.bFrobbable && d.bHighlight && d.bPickable;
}

function MakePickable(#var(DeusExPrefix)Mover d)
{
    if( d.bHighlight == false || d.bFrobbable == false ) {
        d.bPickable = false;
        d.bLocked = true;
        d.bHighlight = true;
        d.bFrobbable = true;
    }
    if( d.bPickable == false ) {
        d.bPickable = true;
        d.lockStrength = rngrange(0.7, min_lock_adjust, max_lock_adjust);
        d.lockStrength = Clamp(d.lockStrength*100, 1, 100)/100.0;
        d.initiallockStrength = d.lockStrength;
    }
}

static function StaticMakePickable(#var(DeusExPrefix)Mover d)
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

function MakeDestructible(#var(DeusExPrefix)Mover d)
{
    if( d.bHighlight == false || d.bFrobbable == false ) {
        d.bPickable = false;
        d.bLocked = true;
        d.bHighlight = true;
        //d.bFrobbable = true;
    }
    if( d.bBreakable == false ) {
        d.bBreakable = true;
        d.minDamageThreshold = rngrange(55, min_mindmg_adjust, max_mindmg_adjust);
        d.doorStrength = FClamp(rngrange(0.8, min_door_adjust, max_door_adjust), 0, 1);
        d.doorStrength = int(d.doorStrength*100)/100.0;
#ifndef injections
        d.minDamageThreshold = d.doorStrength * 70;
#endif
    }
}

static function StaticMakeDestructible(#var(DeusExPrefix)Mover d)
{
    if( d.bHighlight == false || d.bFrobbable == false ) {
        d.bPickable = false;
        d.bLocked = true;
        d.bHighlight = true;
        //d.bFrobbable = true;
    }
    if( d.bBreakable == false ) {
        d.bBreakable = true;
        d.minDamageThreshold = 60;
        d.doorStrength = 1;
    }
}
