class DXRDoors extends DXRActorsBase transient;

enum ESetBool
{
    SB_Noset,
    SB_True,
    SB_False
};

struct door_fix {
    var name tag;
    var name event;
    var vector location;
    var ESetBool breakable;
    var float minDamageThreshold;
    var float doorStrength;
    var ESetBool pickable;
    var float lockStrength;
    var ESetBool highlight;
    var class<Fragment> fragmentClass;
};
var door_fix door_fixes[16];
var int num_door_fixes;

struct FragmentGuess {
    var Sound sound;
    var class<Fragment> fragmentClass;
};
var FragmentGuess fragmentGuesses[30];

var float min_lock_adjust, max_lock_adjust, min_door_adjust, max_door_adjust, min_mindmg_adjust, max_mindmg_adjust;

function CheckConfig()
{
    SetDoorFixes();

    min_lock_adjust=0.4;
    max_lock_adjust=1.5;
    min_door_adjust=0.4;
    max_door_adjust=1.5;
    min_mindmg_adjust=0.3;
    max_mindmg_adjust=1.2;

    if(dxr.flags.settings.doorspickable <= 0 && dxr.flags.IsZeroRando()) {
        min_lock_adjust=1;
        max_lock_adjust=1;
    }
    if(dxr.flags.settings.doorsdestructible <= 0 && dxr.flags.IsZeroRando()) {
        min_door_adjust=1;
        max_door_adjust=1;
        min_mindmg_adjust=1;
        max_mindmg_adjust=1;
    }

    Super.CheckConfig();
}

function SetDoorFixes()
{
    if(dxr.flags.settings.doorspickable==0 && dxr.flags.settings.doorsdestructible==0 && !class'MenuChoice_BalanceMaps'.static.MinorEnabled())
    {
        return;
    }

    num_door_fixes = 0;

    //#region minor door fix
    switch(dxr.localURL) {
    case "02_NYC_BATTERYPARK":
        door_fixes[num_door_fixes].tag = 'KioskDoor';
        door_fixes[num_door_fixes].fragmentClass = class'MetalFragment';
        num_door_fixes++;
        break;

    case "02_NYC_WAREHOUSE":
        door_fixes[num_door_fixes].tag = 'Generator';
        door_fixes[num_door_fixes].breakable = SB_True;
        door_fixes[num_door_fixes].pickable = SB_False;
        door_fixes[num_door_fixes].highlight = SB_True;
        num_door_fixes++;
        break;

    case "04_NYC_NSFHQ":
        door_fixes[num_door_fixes].tag = 'TurretDoor1';
        door_fixes[num_door_fixes].fragmentClass = class'Rockchip';
        num_door_fixes++;

        door_fixes[num_door_fixes].tag = 'TurretDoor2';
        door_fixes[num_door_fixes].fragmentClass = class'Rockchip';
        num_door_fixes++;

        door_fixes[num_door_fixes].tag = 'TurretDoor3';
        door_fixes[num_door_fixes].fragmentClass = class'Rockchip';
        num_door_fixes++;
        break;

    case "06_HONGKONG_WANCHAI_MARKET":
        // Make sure random people don't bust down Tong's gate
        door_fixes[num_door_fixes].tag = 'compound_gate';
        door_fixes[num_door_fixes].breakable = SB_False;
        door_fixes[num_door_fixes].pickable = SB_False;
        door_fixes[num_door_fixes].highlight = SB_False;
        num_door_fixes++;
        break;

    case "06_HONGKONG_WANCHAI_STREET":
        //Make sure the display case isn't highlightable
        door_fixes[num_door_fixes].tag = 'DispalyCase';
        door_fixes[num_door_fixes].breakable = SB_False;
        door_fixes[num_door_fixes].pickable = SB_False;
        door_fixes[num_door_fixes].highlight = SB_False;
        num_door_fixes++;

    case "06_HONGKONG_MJ12LAB":
        // Elevator doors to overlook area
        door_fixes[num_door_fixes].tag = 'eledoor02';
        door_fixes[num_door_fixes].breakable = SB_True;
        door_fixes[num_door_fixes].pickable = SB_False;
        door_fixes[num_door_fixes].highlight = SB_True;
        door_fixes[num_door_fixes].minDamageThreshold = 1;
        door_fixes[num_door_fixes].doorStrength = 0.01;
        num_door_fixes++;
        break;

    case "06_HONGKONG_STORAGE":
        // breaking these doors open allows you to skip the computer, which is very confusing for players
        door_fixes[num_door_fixes].tag = 'UC_Chamber_Door';
        door_fixes[num_door_fixes].breakable = SB_False;
        door_fixes[num_door_fixes].pickable = SB_False;
        door_fixes[num_door_fixes].highlight = SB_False;
        num_door_fixes++;
        break;

    case "09_NYC_SHIP":
        // don't break the ramp up to the ship!
        door_fixes[num_door_fixes].tag = 'ShipRamp';
        door_fixes[num_door_fixes].breakable = SB_False;
        door_fixes[num_door_fixes].minDamageThreshold = 60;
        door_fixes[num_door_fixes].doorStrength = 1;
        door_fixes[num_door_fixes].pickable = SB_False;
        door_fixes[num_door_fixes].lockStrength = 1;
        door_fixes[num_door_fixes].highlight = SB_False;
        num_door_fixes++;
        break;

    case "09_NYC_SHIPBELOW":
        // don't randomize the weld points
        door_fixes[num_door_fixes].tag = 'ShipBreech';
        door_fixes[num_door_fixes].breakable = SB_True;
        door_fixes[num_door_fixes].minDamageThreshold = 55;
        door_fixes[num_door_fixes].doorStrength = 0.5;
        door_fixes[num_door_fixes].pickable = SB_False;
        door_fixes[num_door_fixes].lockStrength = 1;
        door_fixes[num_door_fixes].highlight = SB_True;
        num_door_fixes++;
        break;

    case "09_NYC_GRAVEYARD":
        // don't randomize the EMOff transmitter, or the bookcase
        door_fixes[num_door_fixes].tag = 'BreakableWall';
        door_fixes[num_door_fixes].breakable = SB_True;
        door_fixes[num_door_fixes].minDamageThreshold = 1;
        door_fixes[num_door_fixes].doorStrength = 0.15;
        door_fixes[num_door_fixes].pickable = SB_False;
        door_fixes[num_door_fixes].lockStrength = 1;
        door_fixes[num_door_fixes].highlight = SB_True;
        num_door_fixes++;

        door_fixes[num_door_fixes].tag = 'Bookcase';
        door_fixes[num_door_fixes].breakable = SB_True;
        door_fixes[num_door_fixes].minDamageThreshold = 1;
        door_fixes[num_door_fixes].doorStrength = 0.15;
        door_fixes[num_door_fixes].pickable = SB_False;
        door_fixes[num_door_fixes].lockStrength = 1;
        door_fixes[num_door_fixes].highlight = SB_False;
        num_door_fixes++;

        door_fixes[num_door_fixes].location = vectm(-1962.0, -94.0, -268.0);
        door_fixes[num_door_fixes].fragmentClass = class'Rockchip';
        num_door_fixes++;

        door_fixes[num_door_fixes].location = vectm(-1962.0, -670.0, -268.0);
        door_fixes[num_door_fixes].fragmentClass = class'Rockchip';
        num_door_fixes++;

        door_fixes[num_door_fixes].location = vectm(-1506.0, -970.0, -268.0);
        door_fixes[num_door_fixes].fragmentClass = class'Rockchip';
        num_door_fixes++;

        door_fixes[num_door_fixes].location = vectm(-1502.0, 202.0, -268.0);
        door_fixes[num_door_fixes].fragmentClass = class'Rockchip';
        num_door_fixes++;
        break;

    case "10_PARIS_CATACOMBS_TUNNELS":
        door_fixes[num_door_fixes].tag = 'SilSecretDoor';
        door_fixes[num_door_fixes].fragmentClass = class'Rockchip';
        num_door_fixes++;

        door_fixes[num_door_fixes].event = 'SilSecretDoor';
        door_fixes[num_door_fixes].breakable = SB_False;
        num_door_fixes++;
        break;

    case "10_PARIS_CHATEAU":
        // make chateau cellar undefeatable, if you have lenient doors rules then you won't be going down here anyways
        door_fixes[num_door_fixes].tag = 'duclare_chateau_cellar';
        door_fixes[num_door_fixes].breakable = SB_False;
        door_fixes[num_door_fixes].minDamageThreshold = 100;
        door_fixes[num_door_fixes].doorStrength = 1;
        door_fixes[num_door_fixes].pickable = SB_False;
        door_fixes[num_door_fixes].lockStrength = 1;
        door_fixes[num_door_fixes].highlight = SB_True;
        num_door_fixes++;
        break;

    case "11_PARIS_CATHEDRAL":
        door_fixes[num_door_fixes].tag = 'secretdoor01';
        door_fixes[num_door_fixes].fragmentClass = class'Rockchip';
        num_door_fixes++;
        break;

    case "11_PARIS_EVERETT":
        door_fixes[num_door_fixes].tag = 'AI_room';
        door_fixes[num_door_fixes].fragmentClass = class'MetalFragment';
        num_door_fixes++;
        break;

    case "15_AREA51_FINAL":
        // aquinas hub access, makes tong ending somewhat more viable
        door_fixes[num_door_fixes].tag = 'blastdoor_upper';
        door_fixes[num_door_fixes].breakable = SB_False;
        door_fixes[num_door_fixes].pickable = SB_False;
        door_fixes[num_door_fixes].highlight = SB_True;
        num_door_fixes++;
        break;

    case "15_AREA51_PAGE":
        //Make it so the exploding door doesn't become breakable
        door_fixes[num_door_fixes].tag = 'door_clone_exit';
        door_fixes[num_door_fixes].breakable = SB_False;
        door_fixes[num_door_fixes].pickable = SB_False;
        door_fixes[num_door_fixes].highlight = SB_False;
        num_door_fixes++;

        // Don't let the player close the set of double doors to the gray room
        door_fixes[num_door_fixes].tag = 'GreyDoors';
        door_fixes[num_door_fixes].highlight = SB_False;
        num_door_fixes++;

        //This is already the case in vanilla, but align Revision to it.
        //Make sure the Helios door itself can't be interacted with (keypad is still viable, or computer)
        door_fixes[num_door_fixes].tag = 'door_helios_room';
        door_fixes[num_door_fixes].highlight = SB_False;
        door_fixes[num_door_fixes].breakable = SB_False;
        door_fixes[num_door_fixes].pickable = SB_False;
        num_door_fixes++;
        break;
    }

    if(dxr.flags.settings.doorspickable==0 && dxr.flags.settings.doorsdestructible==0 && !class'MenuChoice_BalanceMaps'.static.MajorEnabled())
    {
        return;
    }

    //#region major door fix
    switch(dxr.localURL) {
    case "02_NYC_STREET":
    case "04_NYC_STREET":
    case "08_NYC_STREET":
        // SmugglersFrontDoor for all 3 maps
        door_fixes[num_door_fixes].tag = 'SmugglersFrontDoor';
        door_fixes[num_door_fixes].breakable = SB_True;
        door_fixes[num_door_fixes].minDamageThreshold = 60;
        door_fixes[num_door_fixes].doorStrength = 1;
        door_fixes[num_door_fixes].pickable = SB_True;
        door_fixes[num_door_fixes].lockStrength = 1;
        door_fixes[num_door_fixes].highlight = SB_True;
        num_door_fixes++;
        break;

    case "02_NYC_SMUG":
    case "04_NYC_SMUG":
    case "08_NYC_SMUG":
        // Always make smugglers stash highlightable and breakable
        door_fixes[num_door_fixes].tag = 'mirrordoor';
        door_fixes[num_door_fixes].breakable = SB_True;
        door_fixes[num_door_fixes].minDamageThreshold = 5;
        door_fixes[num_door_fixes].doorStrength = 0.6;
        door_fixes[num_door_fixes].highlight = SB_True;
        num_door_fixes++;
        break;

    case "04_NYC_NSFHQ":
        // door to the basement
        door_fixes[num_door_fixes].tag = 'ExitDoor';
        door_fixes[num_door_fixes].breakable = SB_True;
        door_fixes[num_door_fixes].minDamageThreshold = 0;// 0 uses a random value instead
        door_fixes[num_door_fixes].doorStrength = 0;
        door_fixes[num_door_fixes].pickable = SB_True;
        door_fixes[num_door_fixes].lockStrength = 0;
        door_fixes[num_door_fixes].highlight = SB_True;
        num_door_fixes++;

        // doors to the computer room
        door_fixes[num_door_fixes].tag = 'SlidingDoor1Move';
        door_fixes[num_door_fixes].breakable = SB_True;
        door_fixes[num_door_fixes].minDamageThreshold = 20;// 0 uses a random value instead
        door_fixes[num_door_fixes].doorStrength = 0.5;
        door_fixes[num_door_fixes].pickable = SB_False;
        door_fixes[num_door_fixes].lockStrength = 0;
        door_fixes[num_door_fixes].highlight = SB_False;
        num_door_fixes++;

        door_fixes[num_door_fixes] = door_fixes[num_door_fixes-1];
        door_fixes[num_door_fixes].tag = 'SlidingDoor2Move';
        num_door_fixes++;
        break;

    case "05_NYC_UNATCOHQ":
        // just in case General Carter's door gets stuck on something
        door_fixes[num_door_fixes].tag = 'supplydoor';
        door_fixes[num_door_fixes].breakable = SB_True;
        door_fixes[num_door_fixes].minDamageThreshold = 60;
        door_fixes[num_door_fixes].doorStrength = 1;
        door_fixes[num_door_fixes].pickable = SB_True;
        door_fixes[num_door_fixes].lockStrength = 1;
        door_fixes[num_door_fixes].highlight = SB_True;
        num_door_fixes++;
        break;

    case "12_VANDENBERG_GAS":
        // Always make the junkyard doors weak and breakable
        door_fixes[num_door_fixes].tag = 'junkyard_doors';
        door_fixes[num_door_fixes].breakable = SB_True;
        door_fixes[num_door_fixes].minDamageThreshold = 1;
        door_fixes[num_door_fixes].doorStrength = 0.1;
        door_fixes[num_door_fixes].highlight = SB_True;
        num_door_fixes++;
        break;

    case "15_AREA51_ENTRANCE":
        // area 51 chambers, in vanilla you can't find the codes for all of these and sometimes the NanoKey you need is in one of them
        door_fixes[num_door_fixes].tag = 'chamber1';
        door_fixes[num_door_fixes].breakable = SB_True;
        door_fixes[num_door_fixes].minDamageThreshold = 60;
        door_fixes[num_door_fixes].doorStrength = 1;
        door_fixes[num_door_fixes].pickable = SB_True;
        door_fixes[num_door_fixes].lockStrength = 1;
        door_fixes[num_door_fixes].highlight = SB_True;
        num_door_fixes++;
        door_fixes[num_door_fixes] = door_fixes[num_door_fixes-1];
        door_fixes[num_door_fixes].tag = 'chamber2';
        num_door_fixes++;
        door_fixes[num_door_fixes] = door_fixes[num_door_fixes-1];
        door_fixes[num_door_fixes].tag = 'chamber3';
        num_door_fixes++;
        door_fixes[num_door_fixes] = door_fixes[num_door_fixes-1];
        door_fixes[num_door_fixes].tag = 'chamber4';
        num_door_fixes++;
        door_fixes[num_door_fixes] = door_fixes[num_door_fixes-1];
        door_fixes[num_door_fixes].tag = 'chamber5';
        num_door_fixes++;
        door_fixes[num_door_fixes] = door_fixes[num_door_fixes-1];
        door_fixes[num_door_fixes].tag = 'chamber6';
        num_door_fixes++;
        break;
    }
}

function bool SkipDoorStatCopy(#var(DeusExPrefix)Mover d)
{
    if (d.Tag == '') return true;
    if (d.Tag == d.class.Name ) return true;

#ifdef hx
    //Class names explicitly expressed here for clarity
    if (HXBreakableGlass(d)!=None) {
        if (d.Tag=='BreakableGlass') return true;
    } else if (HXBreakableWall(d)!=None) {
        if (d.Tag=='BreakableWall') return true;
    } else { //Must be an HXMover
        if (d.Tag=='DeusExMover') return true;
    }
#endif

    return False;
}

//#region FirstEntry
function FirstEntry()
{
    local #var(DeusExPrefix)Mover d, d2;

    Super.FirstEntry();

    RandomizeDoors();
    GuessFragmentClasses(dxr.flags.settings.doorsdestructible);
    AdjustRestrictions(dxr.flags.settings.doorspickable, dxr.flags.settings.doorsdestructible, dxr.flags.settings.deviceshackable);

    // copy to pairs/sets of doors
    foreach AllActors(class'#var(DeusExPrefix)Mover', d) {
        if (SkipDoorStatCopy(d) ) continue;

        foreach AllActors(class'#var(DeusExPrefix)Mover', d2, d.tag) {
            if(d==d2) continue;
            d2.minDamageThreshold = d.minDamageThreshold;
            d2.bPickable = d.bPickable;
            d2.lockStrength = d.lockStrength;
            d2.initiallockStrength = d.initiallockStrength;
            d2.bBreakable = d.bBreakable;
            d2.doorStrength = d.doorStrength;
            d2.bFrobbable = d.bFrobbable;
            d2.bHighlight = d.bHighlight;
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
            d.minDamageThreshold = 1;// apparently people thought 0 was weird, 1 is functionally the same

        if( d.bPickable && d.lockStrength>0 ) {
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
            if(d.minDamageThreshold > 1)
                d.minDamageThreshold = d.doorStrength * 60;
#endif
            d.minDamageThreshold = Max(d.minDamageThreshold, 1); // don't use 0 because people thought it was weird
        }
    }
}

function GuessFragmentClasses(int doorsdestructible)
{
    local #var(DeusExPrefix)Mover d;

    if (doorsdestructible <= 0) return;

    foreach AllActors(class'#var(DeusExPrefix)Mover', d) {
        if (!d.bBreakable) {
            d.FragmentClass = GuessFragmentClass(d);
        }
    }
}

static function class<Fragment> GuessFragmentClass(#var(DeusExPrefix)Mover mov)
{
    local class<Fragment> fragmentClass;
    local FragmentGuess guess;
    local int i;

    if (#var(prefix)BreakableGlass(mov) != None || #var(prefix)BreakableWall(mov) != None) {
        return mov.FragmentClass;
    }

    for (i = 0; i < ArrayCount(default.fragmentGuesses); i++) {
        guess = default.fragmentGuesses[i];
        if (
            mov.ExplodeSound1 == guess.sound
            || mov.ExplodeSound2 == guess.sound
            || mov.OpeningSound == guess.sound
            || mov.ClosingSound == guess.sound
            || mov.ClosedSound == guess.sound
            || mov.MoveAmbientSound == guess.sound
        ) {
            fragmentClass = guess.fragmentClass;
            break;
        }
    }

    if (fragmentClass != None) {
        if (fragmentClass != mov.fragmentClass) {
            log("Guessing that " $ mov $ " fragmentClass should be '" $ fragmentClass $ "' instead of '" $ mov.fragmentClass $ "'");
        }
        return fragmentClass;
    }

    return mov.FragmentClass;
}

function AdjustRestrictions(int doorspickable, int doorsdestructible, int deviceshackable)
{
    local Keypoint kp;
    SetSeed( "AdjustRestrictions" );

    AdjustUndefeatableDoors(doorspickable, doorsdestructible);

    ApplyDoorFixes();
}

function ApplyDoorFixes()
{
    local #var(DeusExPrefix)Mover d;
    local int i;
    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(class'DXRando'.default.dxr.player);

    foreach AllActors(class'#var(DeusExPrefix)Mover', d) {
        for(i=0; i<num_door_fixes; i++) {
            if(
                (door_fixes[i].tag != '' && door_fixes[i].tag != d.Tag)
                || (door_fixes[i].event != '' && door_fixes[i].event != d.Event)
                || (door_fixes[i].location != vect(0,0,0) && VanillaMaps && VSize(door_fixes[i].location - d.Location) > 0.0001)
            ) continue;

            if(door_fixes[i].pickable == SB_True)
                MakePickable(d);
            else if(door_fixes[i].pickable == SB_False)
                d.bPickable = false;

            if(door_fixes[i].lockStrength > 0)
                d.lockStrength = door_fixes[i].lockStrength;
            d.initiallockStrength = d.lockStrength;

            if(door_fixes[i].breakable == SB_True)
                MakeDestructible(d);
            else if (door_fixes[i].breakable == SB_False)
                d.bBreakable = false;

            if(door_fixes[i].minDamageThreshold > 0)
                d.minDamageThreshold = door_fixes[i].minDamageThreshold;

            if(door_fixes[i].doorStrength > 0)
                d.doorStrength = door_fixes[i].doorStrength;

            if (door_fixes[i].highlight == SB_True) {
                d.bHighlight = true;
            } else if (door_fixes[i].highlight == SB_False) {
                d.bFrobbable = false;
                d.bHighlight = false;
            }

            if (door_fixes[i].fragmentClass != None && VanillaMaps)
                d.fragmentClass = door_fixes[i].fragmentClass;
        }
    }
}

function AdjustUndefeatableDoors(int doorspickable, int doorsdestructible)
{
    local #var(DeusExPrefix)Mover d;

    foreach AllActors(class'#var(DeusExPrefix)Mover', d)
    {
        if( DoorIsPickable(d) || d.bBreakable ) continue;
        if( !d.bIsDoor && d.KeyIDNeeded == '' && !d.bHighlight && !d.bFrobbable ) continue;
        AdjustDoor(d, doorspickable, doorsdestructible);
    }
}

function AdjustDoor(#var(DeusExPrefix)Mover d, int doorspickable, int doorsdestructible)
{
    if( chance_single(doorspickable) ) {
        MakePickable(d);
    }
    if( chance_single(doorsdestructible) ) {
        MakeDestructible(d);
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

defaultproperties
{
    // in order of proportion, then number of occurances.
    // in no cases here would vanilla unbreakable DeusExMovers have their FragmentClass changed to anything but 'MetalFragment' from something else
    fragmentGuesses(0)=(sound=sound'Pneumatic1Open',fragmentClass=class'MetalFragment')
    fragmentGuesses(1)=(sound=sound'Pneumatic1Close',fragmentClass=class'MetalFragment')
    fragmentGuesses(2)=(sound=sound'Pneumatic2Open',fragmentClass=class'MetalFragment')
    fragmentGuesses(3)=(sound=sound'Pneumatic2Close',fragmentClass=class'MetalFragment')
    fragmentGuesses(4)=(sound=sound'Pneumatic3Open',fragmentClass=class'MetalFragment')
    fragmentGuesses(5)=(sound=sound'Pneumatic3Close',fragmentClass=class'MetalFragment')
    // fragmentGuesses()=(sound=sound'GlassBreakLarge',fragmentClass=class'GlassFragment') // 100.00% (241 / 241)
    // fragmentGuesses()=(sound=sound'WoodDoor2Close',fragmentClass=class'WoodFragment')   // 100.00%   (67 / 67)
    fragmentGuesses(6)=(sound=sound'SmallExplosion2',fragmentClass=class'MetalFragment')   // 100.00%   (66 / 66)
    fragmentGuesses(7)=(sound=sound'MediumExplosion1',fragmentClass=class'MetalFragment')  // 100.00%   (63 / 63)
    fragmentGuesses(8)=(sound=sound'MediumExplosion2',fragmentClass=class'MetalFragment')  // 100.00%   (53 / 53)
    fragmentGuesses(9)=(sound=sound'MetalHit1',fragmentClass=class'MetalFragment')         // 100.00%   (15 / 15)
    fragmentGuesses(10)=(sound=sound'MetalHit2',fragmentClass=class'MetalFragment')        // 100.00%   (15 / 15)
    // fragmentGuesses()=(sound=sound'WoodDrawerMove',fragmentClass=class'WoodFragment')   // 100.00%   (15 / 15)
    fragmentGuesses(11)=(sound=sound'LargeElevStop',fragmentClass=class'MetalFragment')    // 100.00%   (14 / 14)
    fragmentGuesses(12)=(sound=sound'LargeElevMove',fragmentClass=class'MetalFragment')    // 100.00%     (8 / 8)
    fragmentGuesses(13)=(sound=sound'GarageDoorMove',fragmentClass=class'MetalFragment')   // 100.00%     (7 / 7)
    // fragmentGuesses()=(sound=sound'WoodDrawerOpen',fragmentClass=class'WoodFragment')   // 100.00%     (6 / 6)
    // fragmentGuesses()=(sound=sound'WoodSlide2Open',fragmentClass=class'WoodFragment')   // 100.00%     (3 / 3)
    // fragmentGuesses()=(sound=sound'MetalDrawerClos',fragmentClass=class'WoodFragment')  // 100.00%     (2 / 2)
    // fragmentGuesses()=(sound=sound'WoodSlide2Close',fragmentClass=class'WoodFragment')  // 100.00%     (2 / 2)
    // fragmentGuesses()=(sound=sound'WoodSlide2Move',fragmentClass=class'WoodFragment')   // 100.00%     (2 / 2)
    fragmentGuesses(14)=(sound=sound'LargeExplosion2',fragmentClass=class'MetalFragment')  // 100.00%     (2 / 2)
    // fragmentGuesses()=(sound=sound'SmallElevMove',fragmentClass=class'WoodFragment')    // 100.00%     (1 / 1)
    fragmentGuesses(15)=(sound=sound'SmallElevStop',fragmentClass=class'MetalFragment')    // 100.00%     (1 / 1)
    // fragmentGuesses()=(sound=sound'GlassBreakSmall',fragmentClass=class'GlassFragment') //  98.71% (230 / 233)
    fragmentGuesses(16)=(sound=sound'SmallExplosion1',fragmentClass=class'MetalFragment')  //  94.53% (121 / 128)
    // fragmentGuesses()=(sound=sound'WoodBreakLarge',fragmentClass=class'WoodFragment')   //  90.53% (258 / 285)
    // fragmentGuesses()=(sound=sound'WoodBreakSmall',fragmentClass=class'WoodFragment')   //  90.21% (258 / 286)
    // fragmentGuesses()=(sound=sound'WoodDoor2Open',fragmentClass=class'WoodFragment')    //  88.57%   (62 / 70)
    fragmentGuesses(17)=(sound=sound'LargeExplosion1',fragmentClass=class'MetalFragment')  //  86.79%   (46 / 53)
    // fragmentGuesses()=(sound=sound'WoodDrawerClose',fragmentClass=class'WoodFragment')  //  86.67%   (26 / 30)
    fragmentGuesses(18)=(sound=sound'MetalDoorOpen',fragmentClass=class'MetalFragment')    //  81.25%   (65 / 80)
    fragmentGuesses(19)=(sound=sound'SlideDoorMove',fragmentClass=class'MetalFragment')    //  81.25%   (13 / 16)
    // fragmentGuesses()=(sound=sound'WoodDoorOpen',fragmentClass=class'WoodFragment')     //  80.85%   (76 / 94)
    // fragmentGuesses()=(sound=sound'MetalLockerOpen',fragmentClass=class'GlassFragment') //  80.00%     (4 / 5)
    // fragmentGuesses()=(sound=sound'MetalLockerClos',fragmentClass=class'GlassFragment') //  80.00%     (4 / 5)
    fragmentGuesses(20)=(sound=sound'MetalDoorClose',fragmentClass=class'MetalFragment')   //  79.02% (113 / 143)
    fragmentGuesses(21)=(sound=sound'GarageDoorOpen',fragmentClass=class'MetalFragment')   //  77.78%     (7 / 9)
    fragmentGuesses(22)=(sound=sound'GarageDoorClose',fragmentClass=class'MetalFragment')  //  77.78%     (7 / 9)
    fragmentGuesses(23)=(sound=sound'MetalDoorMove',fragmentClass=class'MetalFragment')    //  76.84% (136 / 177)
    // fragmentGuesses()=(sound=sound'WoodDoor2Move',fragmentClass=class'WoodFragment')    //  75.00%   (24 / 32)
    fragmentGuesses(24)=(sound=sound'StoneSlide2Open',fragmentClass=class'MetalFragment')  //  75.00%     (3 / 4)
    fragmentGuesses(25)=(sound=sound'WoodSlide1Move',fragmentClass=class'MetalFragment')   //  75.00%     (3 / 4)
    // fragmentGuesses()=(sound=sound'WoodDoorClose',fragmentClass=class'WoodFragment')    //  74.55%   (41 / 55)
    // fragmentGuesses()=(sound=sound'WoodSlide1Close',fragmentClass=class'WoodFragment')  //  72.73%   (16 / 22)
    // fragmentGuesses()=(sound=sound'StallDoorOpen',fragmentClass=class'WoodFragment')    //  64.71%   (11 / 17)
    fragmentGuesses(26)=(sound=sound'SlideDoorClose',fragmentClass=class'MetalFragment')   //  62.50%   (15 / 24)
    // fragmentGuesses()=(sound=sound'StallDoorClose',fragmentClass=class'WoodFragment')   //  60.00%    (9 / 15)
    fragmentGuesses(27)=(sound=sound'StoneSlide2Move',fragmentClass=class'MetalFragment')  //  60.00%     (3 / 5)
    fragmentGuesses(28)=(sound=sound'SlideDoorOpen',fragmentClass=class'MetalFragment')    //  57.58%   (19 / 33)

    fragmentGuesses(29)=(sound=sound'StoneSlide1Open',fragmentClass=class'Rockchip')
}
