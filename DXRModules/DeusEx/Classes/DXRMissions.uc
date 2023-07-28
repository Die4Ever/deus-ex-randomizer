class DXRMissions extends DXRActorsBase transient;

const NORMAL_GOAL = 1;
const GOAL_TYPE1 = 2;
const GOAL_TYPE2 = 4;
const GOAL_TYPE3 = 8;
const GOAL_TYPE4 = 16;
const SITTING_GOAL = 268435456;
const VANILLA_GOAL = 536870912;
const START_LOCATION = 1073741824;
const VANILLA_START = 2147483648;
const PLAYER_LOCATION = 7; // keep in sync with length of GoalLocation.positions array

var bool RandoMissionGoals;// only set on first entry

struct GoalActor {
    var name actorName;
    var EPhysics physics;
    var Actor a;// for caching
};

struct Goal {
    var string mapName;
    var string name;
    var int bitMask;
    var GoalActor actors[8];
};

struct GoalActorLocation {
    var vector pos;
    var rotator rot;
};

struct GoalLocation {
    var string mapName;
    var string name;
    var int bitMask;
    var GoalActorLocation positions[8]; // keep in sync with PLAYER_LOCATION
};

struct MutualExclusion {
    var int L1, L2;
};

struct Spoiler {
    var string goalName;
    var string goalLocation;
    var string locationMapName;
};

var Goal goals[32];
var Spoiler spoilers[32];
var GoalLocation locations[64];
var MutualExclusion mutually_exclusive[20];
var int num_goals, num_locations, num_mututally_exclusives;

var vector rando_start_loc;
var bool b_rando_start;
var bool skip_rando_start;

static function class<DXRBase> GetModuleToLoad(DXRando dxr, class<DXRBase> request)
{
    switch(dxr.dxInfo.missionNumber) {
    case 1:
        return class'DXRMissionsM01';
    case 2:
        return class'DXRMissionsM02';
    case 3:
        return class'DXRMissionsM03';
    case 4:
        return class'DXRMissionsM04';
    case 5:
        return class'DXRMissionsM05';
    case 6:
        return class'DXRMissionsM06';
    case 8:
        return class'DXRMissionsM08';
    case 9:
        return class'DXRMissionsM09';
    case 10:
    case 11:
        return class'DXRMissionsParis';
    case 12:
    case 14:
        return class'DXRMissionsVandenberg';
    case 15:
        return class'DXRMissionsM15';
    }
    return request;
}

function int InitGoals(int mission, string map);// return a salt for the seed, the default return at the end is fine if you only have 1 set of goals in the whole mission
function CreateGoal(out Goal g, GoalLocation Loc);
function DeleteGoal(Goal g, GoalLocation Loc);
function AfterMoveGoalToLocation(Goal g, GoalLocation Loc);
function PreFirstEntryMapFixes();
function MissionTimer();
function AddMissionGoals();
function AfterShuffleGoals(int goalsToLocations[32]);
function UpdateLocation(Actor a);

function Spoiler GetSpoiler(int goalID)
{
    return spoilers[goalID];
}

function AddGoalActor(int goalID, int index, name actorName, EPhysics physics)
{
    goals[goalID].actors[index].actorName = actorName;
    goals[goalID].actors[index].physics = physics;
}

function int AddGoal(string mapName, string goalName, int bitMask, name actorName, EPhysics physics)
{
    mapName = Caps(mapName);
    goals[num_goals].mapName = mapName;
    goals[num_goals].name = goalName;
    goals[num_goals].bitMask = bitMask;
    AddGoalActor(num_goals, 0, actorName, physics);
    return num_goals++;
}

function AddActorLocation(int LocID, int index, vector loc, rotator r)
{
    locations[LocID].positions[index].pos = loc;
    locations[LocID].positions[index].rot = r;
}

function int AddGoalLocation(string mapName, string name, int bitMask, vector loc, rotator r)
{
    local int i;
    local Lightbulb a;
    mapName = Caps(mapName);
    locations[num_locations].mapName = mapName;
    locations[num_locations].name = name;
    locations[num_locations].bitMask = bitMask;
    for(i=0; i<ArrayCount(locations[num_locations].positions); i++) {
        AddActorLocation(num_locations, i, loc, r);
    }

    if(name == "" && mapName == dxr.localURL) {
        a = Lightbulb(AddActor(class'Lightbulb', loc, r));
        a.bInvincible = true;
        DebugMarkKeyPosition(a, num_locations @ loc);
    }
    return num_locations++;
}

function String generateGoalLocationList()
{
    local int i,j;
    local String goalList;

    goalList = "";

    for (i=0;i<num_goals;i++){
        goalList = goalList $ goals[i].name $ ":|n";
        goalList = goalList $ "-----------------------------|n";

        for (j=0;j<num_locations;j++){
            if ((goals[i].bitMask & locations[j].bitMask) != 0) {
                goalList = goalList $ locations[j].name $ " (" $ locations[j].mapName $ ")";

                //For missions with multiple "Vanilla" locations in a single pool (eg mission 8),
                //this isn't actually as useful as it seems otherwise.  If we added unique "Vanilla Goal"
                //masks, it would be useful again
                //if ((locations[j].bitMask & VANILLA_GOAL) != 0){
                //    goalList = goalList $ " (Vanilla)";
                //}
                goalList = goalList $ "|n";
            }
        }
        goalList = goalList $ "|n";

    }

    return goalList;
}

function AddMutualExclusion(int L1, int L2)
{
    mutually_exclusive[num_mututally_exclusives].L1 = L1;
    mutually_exclusive[num_mututally_exclusives].L2 = L2;
    num_mututally_exclusives++;
}

function PreFirstEntry()
{
    local int seed;

    Super.PreFirstEntry();

    if(dxr.flags.settings.startinglocations <= 0 && dxr.flags.settings.goals <= 0)
        return;

#ifndef revision
    seed = InitGoals(dxr.dxInfo.missionNumber, dxr.localURL);
#endif

    PreFirstEntryMapFixes();

    SetGlobalSeed( "DXRMissions" $ seed );
    ShuffleGoals();
    RandoMissionGoals = true;
}

function ShuffleGoals()
{
    local int goalsToLocations[32];

    if( ArrayCount(goalsToLocations) != ArrayCount(goals) ) err("ArrayCount(goalsToLocations) != ArrayCount(goals)");

    if(num_goals == 0 && num_locations == 0) return;

    MoveActorsOut();
    ChooseGoalLocations(goalsToLocations);
    MoveActorsIn(goalsToLocations);
    // hardcoded fixes that span multiple goals
    AfterShuffleGoals(goalsToLocations);
}

function MoveActorsOut()
{
    local int g, i;
    local Actor a;
    local bool success;

    if(dxr.flags.settings.goals <= 0) return;

    for(g=0; g<num_goals; g++) {
        if( dxr.localURL != goals[g].mapName ) continue;

        for(i=0; i<ArrayCount(goals[g].actors); i++) {
            a = GetActor(goals[g].actors[i]);
            if(a == None) continue;
            a.bCollideWorld = false;
            a.bMovable = True;
            success = a.SetLocation(a.Location + vect(0,0,20000));
            if (!success){
                l("Failed to move "$a.Name$" out");
            }
        }
    }
}

function MoveActorsIn(int goalsToLocations[32])
{
    local int g, i;
    local #var(PlayerPawn) p;
    local DXRGoalMarker marker;
    local vector loc;
    local rotator rotate;

    foreach AllActors(class'DXRGoalMarker', marker) {
        marker.Destroy();
    }

    g = goalsToLocations[num_goals];
    if( dxr.flags.settings.startinglocations > 0 && g > -1 && dxr.localURL == locations[g].mapName && !skip_rando_start) {
        p = player();
        i = PLAYER_LOCATION;
        loc = locations[g].positions[i].pos;
        rotate = locations[g].positions[i].rot;
        loc = vectm(loc.X, loc.Y, loc.Z);
        rotate = rotm(rotate.pitch, rotate.yaw, rotate.roll, 16384);
        l("Moving player to " $ locations[g].name @ loc @ rotate);
        p.SetLocation(loc);
        p.SetRotation(rotate);
        rando_start_loc = p.Location;
        b_rando_start = true;
    }

    if( dxr.flags.settings.goals > 0 ) {
        for(g=0; g<num_goals; g++) {
            MoveGoalToLocation(goals[g], locations[goalsToLocations[g]]);
        }
    }
}

function bool _ChooseGoalLocations(out int goalsToLocations[32])
{
    local int i, g1, g2, r, _num_locs, _num_starts;
    local int availLocs[64], goalsOrder[32];

    // build list of availLocs based on flags, also count _num_starts
    _num_locs = 0;
    _num_starts = 0;
    for(i=0; i<num_locations; i++) {
        // exclude the vanilla start locations if randomized starting locations are disabled
        if( dxr.flags.settings.startinglocations <= 0 && (VANILLA_START & locations[i].bitMask) != 0 )
            continue;
        // exclude the vanilla goal locations if randomized goal locations are disabled
        if( dxr.flags.settings.goals <= 0 && (VANILLA_GOAL & locations[i].bitMask) != 0 )
            continue;
        availLocs[_num_locs++] = i;

        if( (START_LOCATION & locations[i].bitMask) != 0)
            _num_starts++;
    }

    // choose a starting location
    goalsToLocations[num_goals] = -1;
    if(_num_starts > 0) {
        for(i=0; i<20; i++) {
            r = rng(_num_locs);
            if( (START_LOCATION & locations[availLocs[r]].bitMask) == 0)
                continue;

            goalsToLocations[num_goals] = availLocs[r];
            _num_locs--;
            availLocs[r] = availLocs[_num_locs];
            break;
        }
        if(goalsToLocations[num_goals] == -1)
            return false;
    }

    // do the goals in a random order
    for(i=0; i<num_goals; i++) {
        goalsOrder[i] = i;
    }
    for(i=0; i<num_goals; i++) {
        r = rng(num_goals);
        g1 = goalsOrder[i];
        goalsOrder[i] = goalsOrder[r];
        goalsOrder[r] = g1;
    }

    // choose the goal locations
    for(g1=0; g1<num_goals; g1++) {
        r = rng(_num_locs);
        i = goalsOrder[g1];
        goalsToLocations[i] = availLocs[r];
        if( (goals[i].bitMask & locations[availLocs[r]].bitMask) == 0)
            return false;

        spoilers[i].goalName=goals[i].name;
        spoilers[i].goalLocation=locations[availLocs[r]].name;
        spoilers[i].locationMapName=locations[availLocs[r]].mapName;

        _num_locs--;
        availLocs[r] = availLocs[_num_locs];
    }

    // check mutual exclusions
    for(i=0; i<num_mututally_exclusives; i++) {
        for(g1=0; g1<num_goals; g1++) {
            // num_goals is the player start, so we use <= instead of <
            for(g2=g1+1; g2<=num_goals; g2++) {
                if( mutually_exclusive[i].L1 == goalsToLocations[g1] && mutually_exclusive[i].L2 == goalsToLocations[g2] )
                    return false;
                if( mutually_exclusive[i].L2 == goalsToLocations[g1] && mutually_exclusive[i].L1 == goalsToLocations[g2] )
                    return false;
            }
        }
    }
    return true;
}

function ChooseGoalLocations(out int goalsToLocations[32])
{
    local int attempts;
    for(attempts=0; attempts<1000; attempts++) {
        if(_ChooseGoalLocations(goalsToLocations)) return;
    }
    err("ChooseGoalLocations took too many attempts!");
}

function Actor GetActor(out GoalActor ga)
{
    local Actor a;
    if( ga.actorName == '' ) return None;

    foreach AllActors(class'Actor', a) {
#ifdef hx
        if(a.GetPropertyText("PrecessorName") == string(ga.actorName)) {
#else
        if(a.name == ga.actorName) {
#endif
            ga.a = a;
            return a;
        }
    }
    return None;
}

function AnyEntry()
{
    local int seed;
    local int goalsToLocations[32];

    // since DXRMissions is transient, recreate this data for the hint system
    Super.AnyEntry();
    if(dxr.flags.settings.startinglocations <= 0 && dxr.flags.settings.goals <= 0)
        return;

    SetTimer(1, true);
    if(num_goals != 0 || num_locations != 0) return;// we don't need to re-InitGoals if we already have them

#ifndef revision
    seed = InitGoals(dxr.dxInfo.missionNumber, dxr.localURL);
#endif

    SetGlobalSeed( "DXRMissions" $ seed );
    ChooseGoalLocations(goalsToLocations);
}


function Timer()
{
    Super.Timer();
    if( dxr == None ) return;
    MissionTimer();
    if (RandoMissionGoals && !dxr.flagbase.GetBool('PlayerTraveling')){
        //Secondary objectives get cleared if added in pre/postFirstEntry due to the MissionScript, the MissionsScript also clears the PlayerTraveling flag
        AddMissionGoals();
        RandoMissionGoals=false;
    }
}

function UpdateGoalWithRandoInfo(name goalName, string text)
{
    local string goalText;
    local DeusExGoal goal;
    local int randoPos;

    if(player(true)==None) return;// don't spam HX logs

    goal = player().FindGoal(goalName);
    if(goal == None) return;

    randoPos = InStr(goal.text, "Rando: ");
    if(randoPos != -1) return;

    text = goal.text $ "|nRando: " $ text;
    goal.SetText(text);
    player().ClientMessage("Goal Updated - Check DataVault For Details",, true);
}

function _UpdateLocation(Actor a, string goalName)
{
    local int g, l;

    // make sure locations have been chosen
    AnyEntry();

    for(g=0; g < num_goals; g++) {
        if(spoilers[g].goalName != goalName) continue;
        break;
    }
    if(g>=num_goals) return;
    for(l=0; l < num_locations; l++) {
        if(spoilers[g].goalLocation != locations[l].name) continue;
        break;
    }
    if(l>=num_locations) return;

    goals[g].actors[0].a = a;
    MoveGoalToLocation(goals[g], locations[l]);
}

function MoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local int i;
    local Actor a;
    local ScriptedPawn sp;
    local string result;
    local DXRGoalMarker marker;

    result = g.name $ " to " $ Loc.name;
    info("Moving " $ result $ " (" $ Loc.mapName @ Loc.positions[0].pos $")");

    if(g.mapName == dxr.localURL && Loc.mapName != dxr.localURL) {
        // delete from map
        for(i=0; i<ArrayCount(g.actors); i++) {
            a = g.actors[i].a;
            if(a == None) continue;
            a.Event = '';
            a.Destroy();
        }

        DeleteGoal(g, Loc);
        return;
    }
    else if(g.mapName != dxr.localURL && Loc.mapName == dxr.localURL) {
        CreateGoal(g, Loc);
        info("CreateGoal " $ g.name @ Loc.name @ g.actors[0].a);
    }

    for(i=0; i<ArrayCount(g.actors); i++) {
        a = g.actors[i].a;
        if(a == None) continue;
        a.bVisionImportant = true;// for AugVision
        a.bIsSecretGoal = true;// to prevent swapping
        if(ElectronicDevices(a) != None)
            ElectronicDevices(a).ItemName = g.name;
        MoveActor(a, Loc.positions[i].pos, Loc.positions[i].rot, g.actors[i].physics);
    }

    if( (Loc.bitMask & SITTING_GOAL) != 0) {
        sp = ScriptedPawn(g.actors[0].a);
        if(sp != None)
            sp.SetOrders('Sitting');
    }

    if(Loc.mapName == dxr.localURL) {
        marker = DXRGoalMarker(Spawnm(class'DXRGoalMarker',,, Loc.positions[0].pos));
        marker.BindName = g.name $ " (" $ Loc.name $ ")";
        AfterMoveGoalToLocation(g, Loc);
    }
}

function bool MoveActor(Actor a, vector loc, rotator rotation, EPhysics p)
{
    local #var(prefix)ScriptedPawn sp;
    local Mover m;
    local bool success, oldbCollideWorld;
    local #var(prefix)Vehicles v;
    local int offset;

    loc = vectm(loc.X, loc.Y, loc.Z);
    if(Brush(a) == None) {// brushes/movers get negative scaling, so their rotation doesn't need to be adjusted
        offset = GetRotationOffset(a.class);
        rotation = rotm(rotation.pitch, rotation.yaw, rotation.roll, offset);
    }

    l("moving " $ a $ " from (" $ a.location $ ") to (" $ loc $ ")" );
    oldbCollideWorld = a.bCollideWorld;
    if(p == PHYS_None || p == PHYS_MovingBrush) a.bCollideWorld = false;
    a.bMovable=True;
    success = a.SetLocation(loc);
    if( success == false ) {
        a.bCollideWorld = oldbCollideWorld;
        warning("failed to move "$a$" to "$loc);
        return false;
    }
    a.SetRotation(rotation);
    a.SetPhysics(p);
    if(p == PHYS_None || p == PHYS_MovingBrush) a.bCollideWorld = oldbCollideWorld;

    sp = #var(prefix)ScriptedPawn(a);
    v = #var(prefix)Vehicles(a);
    m = Mover(a);

    if( sp != None ) {
        if(sp.Orders == 'Patrolling')
            sp.SetOrders('Wandering');
        if(sp.Orders == 'Sitting')
            sp.SetOrders('Standing');
        sp.HomeLoc = sp.Location;
        sp.HomeRot = vector(sp.Rotation);
        sp.DesiredRotation = rotation;
        if (!sp.bInWorld){
            sp.SetPhysics(PHYS_None);
            sp.WorldPosition = sp.Location;
            sp.SetLocation(sp.Location+vect(0,0,20000));
        }
        else a.bCollideWorld = true;
    }
    else if ( v != None ) {
#ifndef hx
        if (!v.bInWorld){
            v.WorldPosition = v.Location;
            v.SetLocation(v.Location+vect(0,0,20000));
        }
        else a.bCollideWorld = true;
#endif
    }
    else if( m != None ) {
        m.BasePos = a.Location;
        m.BaseRot = a.Rotation;
    } else {
        a.bCollideWorld = true;
    }

    return true;
}

function bool MoveGoalTo(string goalName, int locNumber)
{
    local int i;

    for(i=0; i<num_goals; i++) {
        if(goalName == goals[i].name) {
            MoveGoalToLocation(goals[i], locations[locNumber]);
            player().ClientMessage("Goal Location: "$locations[locNumber].name);
            return true;
        }
    }
    return false;
}

static function bool IsCloseToRandomStart(DXRando dxr, vector loc)
{
    local float too_close, dist;
    local DXRMissions m;
    local vector v;

    too_close = 75*16;

    m = DXRMissions(dxr.FindModule(class'DXRMissions'));
    if( m != None && m.b_rando_start ) {
        if( dxr.localURL == "01_NYC_UNATCOISLAND" ) {
            // Harley Filben Dock
            v = dxr.flags.vectm(1297.173096, -10257.972656, -287.428131);
            if( 160 > VSize(m.rando_start_loc - v) )
                too_close = 150 * 16;
        }
        dist = VSize(m.rando_start_loc - loc);
        return dist < too_close;
    }
    return false;
}

static function bool IsCloseToStart(DXRando dxr, vector loc)
{
    local PlayerStart ps;
    local Teleporter t;
    local float too_close, dist;
    local DXRMissions m;
    local vector v;

    too_close = 75*16;

    m = DXRMissions(dxr.FindModule(class'DXRMissions'));
    if( dxr.localURL == "12_VANDENBERG_GAS" ) {
        // Tiffany
        v = dxr.flags.vectm(168.601334, 607.866882, -980.902832);
        if ( VSize(v - loc) < 75*16 ) return true;
    }
    if( m != None && m.b_rando_start ) {
        return IsCloseToRandomStart(dxr, loc);
    }
    else {
        too_close = 120 * 16;// worst cases are 05 jail and 06 helibase?
        foreach dxr.RadiusActors(class'PlayerStart', ps, too_close, loc) {
            dist = VSize(loc-ps.location);
            if( dist < too_close ) return true;
        }
    }

    too_close = 75 * 16;
    foreach dxr.RadiusActors(class'Teleporter', t, too_close, loc) {
        if( t.Tag == '' ) continue;
        dist = VSize(loc-t.location);
        if( dist < too_close ) return true;
    }

    return false;
}

//tests to ensure that there are more goal locations than movable actors for each map
function RunTests()
{
    local int i, total;
    Super.RunTests();
}
