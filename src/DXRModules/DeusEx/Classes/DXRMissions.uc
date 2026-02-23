class DXRMissions extends DXRActorsBase transient;

const NORMAL_GOAL = 1;
const GOAL_TYPE1 = 2;
const GOAL_TYPE2 = 4;
const GOAL_TYPE3 = 8;
const GOAL_TYPE4 = 16;
const ALWAYS_CREATE = 134217728;
const SITTING_GOAL = 268435456;
const VANILLA_GOAL = 536870912;
const START_LOCATION = 1073741824;
const VANILLA_START = -2147483648;
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

struct MapImageGoalMarkers {
    var class<DataVaultImage> image;
    var string    goalName;
    var int    locNum;
    var String markerLetter;
    var String helpText;
    var int    posX;
    var int    posY;
};

struct GoalLocation {
    var string mapName;
    var string name;
    var int bitMask;
    var GoalActorLocation positions[8]; // keep in sync with PLAYER_LOCATION
    var MapImageGoalMarkers mapMarker;
    var float weight; // in percent, 0% to 100%
};

struct MutualExclusion {
    var int L1, L2;
};

struct Spoiler {
    var string goalName;
    var string goalLocation;
    var string locationMapName;
    var int locationId;
};


var Goal goals[32];
var Spoiler spoilers[32];
var GoalLocation locations[64];
var MutualExclusion mutually_exclusive[32];
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
function int InitGoalsRev(int mission, string map);// return a salt for the seed, the default return at the end is fine if you only have 1 set of goals in the whole mission
function CreateGoal(out Goal g, GoalLocation Loc);
function AfterMoveGoalToLocation(Goal g, GoalLocation Loc);
function AfterMoveGoalToOtherMap(Goal g, GoalLocation Loc);
function AfterMovePlayerToStartLocation(GoalLocation Loc);
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

function ReplaceGoalActor(Actor a, Actor n)
{
    local int i,j;
    local bool bTextures;
    if (num_goals==0) return;

    bTextures = class'MenuChoice_GoalTextures'.static.IsEnabled();

    for (i=0;i<num_goals;i++)
    {
        for (j=0;j<ArrayCount(goals[i].actors);j++){
            if (goals[i].actors[j].a==a) {
                goals[i].actors[j].a=n;
                DignifyGoalActor(goals[i],n,bTextures); //Make sure the newly replaced actor has the right skins
                l("Replacing Goal Actor "$a$" with newly replaced actor "$n);
                return; //Presumably no actors exist in multiple goals?
            }
        }
    }
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
    locations[num_locations].weight = 100;
    for(i=0; i<ArrayCount(locations[num_locations].positions); i++) {
        AddActorLocation(num_locations, i, loc, r);
    }

    if(name == "" && mapName == dxr.localURL) {
        a = Lightbulb(AddActor(class'Lightbulb', loc, r));
        a.bInvincible = true;
        DebugMarkKeyActor(a, num_locations @ loc);
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

function AddMapMarker(class<DataVaultImage> image, int posX, int posY, String markerLetter, string goalName, int locNum, String helpText)
{
    locations[locNum].mapMarker.image=image;
    locations[locNum].mapMarker.goalName=goalName;
    locations[locNum].mapMarker.locNum=locNum;
    locations[locNum].mapMarker.markerLetter=markerLetter;
    locations[locNum].mapMarker.helpText=helpText;
    locations[locNum].mapMarker.posX=posX;
    locations[locNum].mapMarker.posY=posY;
}

function bool MapHasGoalMarkers(class<DataVaultImage> image)
{
    local int i;
    for (i=0;i<num_locations;i++){
        if (locations[i].mapMarker.image==image){
            return True;
        }
    }
    return False;
}

function int PopulateMapMarkerNotes(class<DataVaultImage> image, out DXRDataVaultMapImageNote notes[32])
{
    local int i,numNotes;
    for (i=0;i<num_locations;i++){
        if (locations[i].mapMarker.image==image){
            notes[numNotes].noteText=locations[i].mapMarker.markerLetter;
            notes[numNotes].posX=locations[i].mapMarker.posX;
            notes[numNotes].posY=locations[i].mapMarker.posY;
            notes[numNotes].HelpTitle=locations[i].mapMarker.goalName;
            notes[numNotes].HelpText=locations[i].mapMarker.helpText;
            notes[numNotes].bExpanded=True;
            numNotes++;
        }
    }
    return numNotes;
}

function int PopulateMapMarkerSpoilers(class<DataVaultImage> image, out DXRDataVaultMapImageNote notes[32])
{
    local int i,goalLoc,numNotes;
    local string goalName;

    for (i=0;i<num_goals;i++){
        goalLoc = GetSpoiler(i).locationId;
        goalName = GetSpoiler(i).goalName;

        if (locations[goalLoc].mapMarker.image==image){
            notes[numNotes].noteText=locations[goalLoc].mapMarker.markerLetter;
            notes[numNotes].posX=locations[goalLoc].mapMarker.posX;
            notes[numNotes].posY=locations[goalLoc].mapMarker.posY;
            notes[numNotes].HelpTitle=goalName;
            notes[numNotes].HelpText=locations[goalLoc].mapMarker.helpText;
            notes[numNotes].bExpanded=True;
            numNotes++;
        }
    }
    return numNotes;
}

//#region mutexes
function AddMutualExclusion(int L1, int L2)
{
    local int i;

    for(i=0; i<num_mututally_exclusives; i++) {
        if(mutually_exclusive[i].L1 == L1 && mutually_exclusive[i].L2 == L2) {
            l("AddMutualExclusion: " $ locations[L1].name $ " and "$ locations[L2].name $ " are already mutually exclusive");
            return;
        }
    }
    l("AddMutualExclusion: " $ locations[L1].name $ " and "$ locations[L2].name $ " are mutually exclusive");
    mutually_exclusive[num_mututally_exclusives].L1 = L1;
    mutually_exclusive[num_mututally_exclusives].L2 = L2;
    num_mututally_exclusives++;
}

function AddMutualInclusion(int L1, int L2)
{// might be more generally useful with more arguments for allowances, make sure to call after adding all the goal locations
    local int i, k;
    local int G1, G2;

    G1 = locations[L1].bitMask & 0xFFFF;
    G2 = locations[L2].bitMask & 0xFFFF;

    l("AddMutualInclusion: " $ locations[L1].name $ " and " $ locations[L2].name);

    for(i=0; i<num_locations; i++) {
        if((locations[i].bitMask & G1) != G1) continue;
        for(k=0; k<num_locations; k++) {
            if(i == k) continue;
            if((locations[k].bitMask & G2) != G2) continue;
            if(i==L1 ^^ k==L2) AddMutualExclusion(i, k);
        }
    }
    l("AddMutualInclusion: end");
}

function MutualExcludeSameMap(int G1, int G2)
{
    local int i, k;

    l("MutualExcludeSameMap: " $ goals[G1].name $ " and " $ goals[G2].name);
    G1 = goals[G1].bitMask;
    G2 = goals[G2].bitMask;

    for(i=0; i<num_locations; i++) {
        if((locations[i].bitMask & G1) == 0) continue;
        for(k=0; k<num_locations; k++) {
            if(i == k) continue;
            if((locations[k].bitMask & G2) == 0) continue;
            if(locations[i].mapName != locations[k].mapName) continue;
            AddMutualExclusion(i, k);
        }
    }
    l("MutualExcludeSameMap: end");
}

function MutualExcludeMaps(int G1, string M1, int G2, string M2)
{
    local int i, k;

    l("MutualExcludeMaps: " $ goals[G1].name @ M1 $ " and " $ goals[G2].name @ M2);
    G1 = goals[G1].bitMask;
    G2 = goals[G2].bitMask;

    for(i=0; i<num_locations; i++) {
        if((locations[i].bitMask & G1) == 0) continue;
        if(locations[i].mapName != M1) continue;
        for(k=0; k<num_locations; k++) {
            if(i == k) continue;
            if((locations[k].bitMask & G2) == 0) continue;
            if(locations[k].mapName != M2) continue;
            AddMutualExclusion(i, k);
        }
    }
    l("MutualExcludeMaps: end");
}

function AddMutualExclusionLocMap(int L1, string map)
{
    local int i;

    l("AddMutualExclusionLocMap: " $ locations[L1].name $ " and " $ map);
    for(i=0; i<num_locations; i++) {
        if(i == L1) continue;
        if(locations[i].mapName != map) continue;
        AddMutualExclusion(L1, i);
    }
    l("AddMutualExclusionLocMap: end");
}
//#endregion

//#region init
function int InitGoalsByMod(int mission, string map)
{
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());
    l("InitGoalsByMod: Using Revision Maps? "$RevisionMaps);

    if (RevisionMaps){
        return InitGoalsRev(dxr.dxInfo.missionNumber, dxr.localURL);
    } else {
        return InitGoals(dxr.dxInfo.missionNumber, dxr.localURL);
    }
}

function PreFirstEntry()
{
    local int seed;

    Super.PreFirstEntry();

    if(dxr.flags.settings.startinglocations <= 0 && dxr.flags.settings.goals <= 0)
        return;

    seed = InitGoalsByMod(dxr.dxInfo.missionNumber, dxr.localURL);

    PreFirstEntryMapFixes();

    SetGlobalSeed( "DXRMissions" $ seed );
    ShuffleGoals();
    DignifyAllGoalActors();
    RandoMissionGoals = true;
}

function DignifyAllGoalActors()
{
    local int g,a;
    local bool bTextures;

    if(!#defined(vanilla) && !#defined(revision)) return;
    if(num_goals == 0 && num_locations == 0) return;

    bTextures = class'MenuChoice_GoalTextures'.static.IsEnabled();

    for(g=0;g<num_goals;g++){
        for(a=0;a<ArrayCount(goals[g].actors);a++){
            if( dxr.localURL != goals[g].mapName ) continue;
            //Make sure the cached actor reference is actually populated
            if (goals[g].actors[a].a==None && goals[g].actors[a].actorName!=''){
                GetActor(goals[g].actors[a]);
            }
            if (goals[g].actors[a].a!=None){
                DignifyGoalActor(goals[g], goals[g].actors[a].a, bTextures);
            }
        }
    }
}

// Generic textures we want to apply consistently across all goal actors
// subclasses can override this to set newTex based on g.name
function DignifyGoalActor(Goal g, Actor a, bool enableTextures, optional Texture newTex)
{
    local bool changed;

    if (ComputerSecurity(a)!=None){
        #ifdef revision
        ComputerSecurity(a).Facelift(false);
        #endif
        if(newTex != None) a.Skin = newTex;
        else a.Skin = Texture'GoalSecurityComputerGreen';
        changed=True;
    } else if (ComputerPersonal(a)!=None){
        #ifdef revision
        ComputerPersonal(a).Facelift(false);
        #endif
        if(newTex != None) a.Skin = newTex;
        else a.Skin=Texture'GoalComputerPersonalYellow';
        changed=True;
    }
#ifdef injections
    else if (DataLinkTrigger(a)!=None) {
        DataLinkTrigger(a).bImportant = true;
    }
#endif

    if (!enableTextures && changed){
        a.Skin=a.Default.Skin;
#ifdef revision
        //For now, everything being dignified is a decoration, but maybe not in the future?
        #var(DeusExPrefix)Decoration(a).Facelift(true);
#endif
    }
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

    GenerateLocationMarkers();
}

function GenerateLocationMarkers()
{
    local int i, mask;
    local DXRLocationMarker marker;

    foreach AllActors(class'DXRLocationMarker', marker) {
        marker.Destroy();
    }

    for(i=0; i<num_locations; i++) {
        if(dxr.localURL != locations[i].mapName) continue;
        mask = locations[i].bitMask;
        if((mask & (START_LOCATION | VANILLA_START)) == mask) continue; // this is just a start location
        marker = DXRLocationMarker(Spawnm(class'DXRLocationMarker',,, locations[i].positions[0].pos));
        marker.BindName = locations[i].name $ "?";
    }
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
                warning("Failed to move "$a.Name$" out");
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
    local bool success;

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
        success = p.SetLocation(loc);
        if(!success) {
            err("Failed to move player to " $ locations[g].name @ loc @ rotate);
        }
        p.SetRotation(rotate);
        p.ViewRotation = rotate;
        p.PutCarriedDecorationInHand();
        rando_start_loc = p.Location;
        b_rando_start = true;
        AfterMovePlayerToStartLocation(locations[g]);
    }

    if( dxr.flags.settings.goals > 0 ) {
        for(g=0; g<num_goals; g++) {
            MoveGoalToLocation(goals[g], locations[goalsToLocations[g]]);
        }
    }
}

function bool _ChooseGoalLocations(out int goalsToLocations[32])
{
    local int i, a, g, g1, g2, r, loc, _num_locs, _num_starts, _num_goal_locs;
    local int availLocs[64], goalsOrder[32], goalLocs[64];

    // build list of availLocs based on flags, also count _num_starts
    _num_locs = 0;
    _num_starts = 0;
    goalsToLocations[num_goals] = -1;
    for(i=0; i<num_locations; i++) {
        // exclude the vanilla start locations if randomized starting locations are disabled
        if( dxr.flags.settings.startinglocations <= 0 && (VANILLA_START & locations[i].bitMask) != 0 ) {
            goalsToLocations[num_goals] = i; // write this as the start location so mutual exclusions work
            continue;
        }
        // exclude the vanilla goal locations if randomized goal locations are disabled
        if( dxr.flags.settings.goals <= 0 && (VANILLA_GOAL & locations[i].bitMask) != 0 )
            continue;

        if(locations[i].weight < 100 && !chance_single(locations[i].weight))
            continue;

        if( (START_LOCATION & locations[i].bitMask) != 0) {
            goalLocs[_num_starts++] = _num_locs;// build temporary goalLocs
        }
        availLocs[_num_locs++] = i;
    }

    // choose a starting location
    if(_num_starts > 0 && goalsToLocations[num_goals] == -1) {
        _num_goal_locs = _num_starts;
        r = rng(_num_goal_locs);
        a = goalLocs[r];
        loc = availLocs[a];

        goalsToLocations[num_goals] = loc;
        _num_locs--;
        availLocs[a] = availLocs[_num_locs];

        // remove locations that are no longer valid
        for(a=0; a<_num_locs; a++) {
            if(!IsComboAllowed(loc, availLocs[a])) {
                _num_locs--;
                availLocs[a] = availLocs[_num_locs];
                a--;
            }
        }
    }

    if(num_goals == 0) return true;
    if(dxr.flags.settings.goals <= 0) return true;

    // do the goals in a random order
    for(i=0; i<num_goals; i++) {
        goalsOrder[i] = i;
    }
    for(i=num_goals-1; i>=0; i--) {
        r = rng(i+1);
        g1 = goalsOrder[i];
        goalsOrder[i] = goalsOrder[r];
        goalsOrder[r] = g1;
    }

    // choose the goal locations
    for(g1=0; g1<num_goals; g1++) {
        g = goalsOrder[g1];

        // build temporary goalLocs
        _num_goal_locs = 0;
        for(a=0; a<_num_locs; a++) {
            loc = availLocs[a];
            if( (goals[g].bitMask & locations[loc].bitMask) != 0) {
                goalLocs[_num_goal_locs++] = a;
            }
        }

        if(_num_goal_locs==0) return false;

        r = rng(_num_goal_locs);
        a = goalLocs[r];
        loc = availLocs[a];
        goalsToLocations[g] = loc;

        spoilers[g].goalName=goals[g].name;
        spoilers[g].goalLocation=locations[loc].name;
        spoilers[g].locationMapName=locations[loc].mapName;
        spoilers[g].locationId=loc;

        _num_locs--;
        availLocs[a] = availLocs[_num_locs];

        // remove locations that are no longer valid
        for(a=0; a<_num_locs; a++) {
            if(!IsComboAllowed(loc, availLocs[a])) {
                _num_locs--;
                availLocs[a] = availLocs[_num_locs];
                a--;
            }
        }
    }

    return true;
}

function bool IsComboAllowed(int loc1, int loc2)
{
    local int i;

    for(i=0; i<num_mututally_exclusives; i++) {
        if( mutually_exclusive[i].L1 == loc1 && mutually_exclusive[i].L2 == loc2 )
            return false;
        if( mutually_exclusive[i].L2 == loc1 && mutually_exclusive[i].L1 == loc2 )
            return false;
    }
    return true;
}

function bool IsLayoutAllowed(int goalsToLocations[32])
{
    return true;
}

function ChooseGoalLocations(out int goalsToLocations[32])
{
    local int attempts;
    for(attempts=0; attempts<1000; attempts++) {
        if(_ChooseGoalLocations(goalsToLocations)) {
            if(!IsLayoutAllowed(goalsToLocations)) continue;
            if(attempts > 100) {
                warning("ChooseGoalLocations took " $ (attempts+1) $ " attempts!");
            }
            return;
        }
    }
    err("ChooseGoalLocations took too many attempts!");
}

function Actor GetActor(out GoalActor ga)
{
    local Actor a;
    local DXRReplacedActors replace;

    if( ga.actorName == '' ) return None;

    foreach AllActors(class'Actor', a) {
#ifdef hx
        if( (HXMover(a) != None && a.Name == ga.actorName)
            || a.GetPropertyText("PrecessorName") == string(ga.actorName))
#else
        if(a.name == ga.actorName)
#endif
        {
            ga.a = a;
            return a;
        }
    }

    //Didn't find an actor with the given name - maybe it was replaced?
    foreach AllActors(class'DXRReplacedActors',replace){break;} //(This will only exist in non-vanilla, where DXRReplaceActors runs)
    if (replace==None) return None; //No replaced actors, ignore this logic

    a=replace.FindReplacement(ga.actorName);
    ga.a = a;

    return a;
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
    CheckShowMarkers();
    if(num_goals != 0 || num_locations != 0) return;// we don't need to re-InitGoals if we already have them

    seed = InitGoalsByMod(dxr.dxInfo.missionNumber, dxr.localURL);

    SetGlobalSeed( "DXRMissions" $ seed );
    ChooseGoalLocations(goalsToLocations);
}

function CheckShowMarkers()
{
    local ActorDisplayWindow actorDisplay;
    if(dxr.flags.settings.goals == 101) {
        actorDisplay = DeusExRootWindow(player().rootWindow).actorDisplay;
        actorDisplay.SetViewClass(class'DXRLocationMarker');
        actorDisplay.ShowLOS(false);
        actorDisplay.ShowPos(false);
        if(!#defined(injections))
            actorDisplay.ShowBindName(true);
    } else if(dxr.flags.settings.goals == 102) {
        actorDisplay = DeusExRootWindow(player().rootWindow).actorDisplay;
        actorDisplay.SetViewClass(class'DXRGoalMarker');
        actorDisplay.ShowLOS(false);
        actorDisplay.ShowPos(false);
        if(!#defined(injections))
            actorDisplay.ShowBindName(true);
    }
}

function Timer()
{
    Super.Timer();
    if( dxr == None ) return;
    MissionTimer();
    if (RandoMissionGoals && !dxr.flagbase.GetBool('PlayerTraveling')){
        //Secondary objectives get cleared if added in pre/postFirstEntry due to the MissionScript, the MissionsScript also clears the PlayerTraveling flag
        if(!dxr.flags.IsReducedRando()) {
            AddMissionGoals();
        }
        RandoMissionGoals=false;
    }
}

function UpdateGoalWithRandoInfo(name goalName, string text, optional bool always)
{
    local ConEventAddGoal ceag;

    if (player(true) == None) return; // don't spam HX logs
    if (!always && dxr.flags.settings.goals == 0) return; // don't add rando notes if goal randomization is turned off

    foreach AllObjects(class'ConEventAddGoal', ceag) {
        if (ceag != None && ceag.goalName == goalName && InStr(ceag.goalText, "Rando: ") == -1) {
            ceag.goalText = ceag.goalText $ "|nRando: " $ text;
        }
    }
}

function int _UpdateLocation(Actor a, string goalName)
{
    local int g, loc;

    l("_UpdateLocation " $ a @ goalName);

    // make sure locations have been chosen
    AnyEntry();

    for(g=0; g < num_goals; g++) {
        if(spoilers[g].goalName != goalName) continue;
        break;
    }
    if(g>=num_goals) return -1;
    for(loc=0; loc < num_locations; loc++) {
        if(spoilers[g].goalLocation != locations[loc].name) continue;
        if( (goals[g].bitMask & locations[loc].bitMask) == 0) continue;
        break;
    }
    if(loc>=num_locations) return -1;

    l("_UpdateLocation " $ a @ goalName @ g @ loc);
    goals[g].actors[0].a = a;
    MoveGoalToLocation(goals[g], locations[loc]);
    return g;
}

function DeleteGoal(Goal g, GoalLocation Loc)
{
    local int i;
    local Actor a;
    // delete from map
    for(i=0; i<ArrayCount(g.actors); i++) {
        a = g.actors[i].a;
        if(a == None) continue;
        a.Event = '';
        a.Destroy();
    }
}

function MoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local int i;
    local Actor a;
    local #var(prefix)ScriptedPawn sp;
    local string result;
    local DXRGoalMarker marker;
    local #var(DeusExPrefix)Mover dxm;

    result = g.name $ " to " $ Loc.name;
    info("Moving " $ result $ " (" $ Loc.mapName @ Loc.positions[0].pos $")");

    if(g.mapName == dxr.localURL && Loc.mapName != dxr.localURL) {
        DeleteGoal(g, Loc);
        return;
    }
    else if(Loc.mapName == dxr.localURL &&
            (g.mapName != dxr.localURL || (g.bitMask & ALWAYS_CREATE)!=0)) {
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

        //If actor was a mover, make it have dynamic lighting so it looks right
        dxm = #var(DeusExPrefix)Mover(a);
        if (dxm!=None){
            dxm.bDynamicLightMover=False;//very quickly disable
            dxm.bDynamicLightMover=True; //Make lighting apply properly
        }

        //If actor is a scriptedpawn and has the magic Start HomeTag, update their HomeBase
        //'Start' means their HomeBase will be set to their initial location
        sp = #var(prefix)ScriptedPawn(a);
        if (sp!=None && sp.HomeTag=='Start'){
            //I don't really understand why, but this commented out logic doesn't actually work
            //sp.SetHomeBase(Loc.positions[i].pos,Loc.positions[i].rot);
            //sp.HomeTag='Start';  //Make sure to reset it afterwards, in case you want to shuffle them again

            //This code (in SetPawnLocAsHome), which seems to be functionally equivalent (except the pawn has to be at the location) works
            SetPawnLocAsHome(sp);
        }

        //If the actor has inventory, make sure it moves to the new location and is based on the thing
        RebaseInventory(a);
    }

    if( (Loc.bitMask & SITTING_GOAL) != 0) {
        sp = #var(prefix)ScriptedPawn(g.actors[0].a);
        if(sp != None)
            sp.SetOrders('Sitting');
    }

    if(Loc.mapName == dxr.localURL) {
        marker = DXRGoalMarker(Spawnm(class'DXRGoalMarker',,, Loc.positions[0].pos));
        marker.BindName = g.name $ " (" $ Loc.name $ ")";
        AfterMoveGoalToLocation(g, Loc);
    } else {
        AfterMoveGoalToOtherMap(g, Loc);
    }
}

function bool MoveActor(Actor a, vector loc, rotator rotation, EPhysics p)
{
    local #var(prefix)ScriptedPawn sp;
    local Mover m;
    local bool success, oldbCollideWorld, oldbCollideActors, oldbBlockActors, oldbBlockPlayers;
    local #var(prefix)Vehicles v;
    local int offset;

    loc = vectm(loc.X, loc.Y, loc.Z);
    if(Brush(a) == None) {// brushes/movers get negative scaling, so their rotation doesn't need to be adjusted
        offset = GetRotationOffset(a.class);
        rotation = rotm(rotation.pitch, rotation.yaw, rotation.roll, offset);
    }

    l("moving " $ a $ " from (" $ a.location $ ") to (" $ loc $ ")" );
    oldbCollideWorld = a.bCollideWorld;
    oldbCollideActors = a.bCollideActors;
    oldbBlockActors = a.bBlockActors;
    oldbBlockPlayers = a.bBlockPlayers;

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

    //Physics changes can sometimes change collision as a side effect (If a base gets set as a result), reset collision to what it was before the move
    a.SetCollision(oldbCollideActors, oldbBlockActors, oldbBlockPlayers);

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

//HX runs InitializePawn sooner than vanilla - this function is to accomodate making sure
//pawns created by CreateGoal end up in or out of world appropriately with HX
function HXScriptedPawnPostInitWorldState(#var(prefix)ScriptedPawn sp)
{
    if (!#defined(hx)) return;

    if (!sp.bInWorld)
    {
        // tricky
        sp.bInWorld = true;
        sp.LeaveWorld();
    }
}

function PartialInWorld(Actor a, vector offset, bool onlyIfOutOfWorld)
{
    #ifndef hx
    local ScriptedPawn p;
    local #var(prefix)Vehicles v;

    p = ScriptedPawn(a);
    v = #var(prefix)Vehicles(a);

    if(p!=None) {
        warning("PartialInWorld for ScriptedPawns is not implemented yet! " $ a);
    }
    else if(v!=None) {
        if(v.bInWorld && onlyIfOutOfWorld) return;
        if(v.bInWorld) v.WorldPosition = v.Location;
        v.bInWorld = false;
        v.bHidden = false;
        v.bDetectable = false;
        v.SetCollision(false, false, false);
        v.bCollideWorld = false;
        v.SetPhysics(PHYS_None);
        v.SetLocation(v.WorldPosition + offset);  // move it partially out of the way
    }
    else {
        warning("PartialInWorld idk what to do with " $ a);
    }
    #endif
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
        switch(dxr.localURL) {
            case "05_NYC_UNATCOMJ12lab":
            case "06_HongKong_Helibase":
            case "14_Vandenberg_Sub":
                too_close = 120 * 16;// worst cases are 05 jail and 06 helibase? for larger maps this doesn't matter much anyways
                break;
            default:
                too_close = 50 * 16;
        }
        foreach dxr.RadiusActors(class'PlayerStart', ps, too_close, loc) {
            dist = VSize(loc-ps.location);
            if( dist < too_close ) return true;
        }
    }

    too_close = 50 * 16;
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

    i = NORMAL_GOAL | VANILLA_START;
    testint(i, -2147483647, "NORMAL_GOAL | VANILLA_START");
    testint(i & SITTING_GOAL, 0, "Leo dock not sitting goal");
}
