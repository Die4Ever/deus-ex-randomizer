class DXRMissions2 extends DXRActorsBase;

struct RemoveActor {
    var string map_name;
    var name actor_name;
};
var config RemoveActor remove_actors[32];

const NORMAL_GOAL = 1;
const GOAL_TYPE1 = 2;
const GOAL_TYPE2 = 4;
const GOAL_TYPE3 = 8;
const GOAL_TYPE4 = 16;
const VANILLA_GOAL = 536870912;
const START_LOCATION = 1073741824;
const PLAYER_LOCATION = 7; // keep in sync with length of GoalLocation.positions array

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
    var int G1, L1, G2, L2;
};

var Goal goals[32];
var GoalLocation locations[64];
var MutualExclusion mutually_exclusive[20];
var int num_goals, num_locations, num_mututally_exclusives;

var config bool allow_vanilla;

var vector rando_start_loc;
var bool b_rando_start;

function CheckConfig()
{
    local class<Actor> a;
    local int i;
    local string map;

    if( ConfigOlderThan(2,0,3,7) ) {
        allow_vanilla = false;

        for(i=0; i<ArrayCount(remove_actors); i++) {
            remove_actors[i].map_name = "";
            remove_actors[i].actor_name = '';
        }

#ifndef revision
        vanilla_remove_actors();
#endif
    }

    for(i=0; i<ArrayCount(remove_actors); i++) {
        remove_actors[i].map_name = Caps(remove_actors[i].map_name);
    }

    Super.CheckConfig();
}

function vanilla_remove_actors()
{
    // TODO: actor names aren't stable
    local int i;
    remove_actors[i].map_name = "01_NYC_unatcoisland";
    remove_actors[i].actor_name = 'OrdersTrigger2';//the order that makes Paul run to you
    i++;

    remove_actors[i].map_name = "01_NYC_unatcoisland";
    remove_actors[i].actor_name = 'DataLinkTrigger0';//find Paul
    i++;

    remove_actors[i].map_name = "01_NYC_unatcoisland";
    remove_actors[i].actor_name = 'DataLinkTrigger8';//the "don't leave without talking to Paul" datalink
    i++;

    remove_actors[i].map_name = "01_NYC_unatcoisland";
    remove_actors[i].actor_name = 'DataLinkTrigger10';//DL_MissedHermann
    i++;

    remove_actors[i].map_name = "01_NYC_unatcoisland";
    remove_actors[i].actor_name = 'DataLinkTrigger5';//DL_NearTop
    i++;

    remove_actors[i].map_name = "01_NYC_unatcoisland";
    remove_actors[i].actor_name = 'DataLinkTrigger12';//DL_Top
    i++;

    remove_actors[i].map_name = "09_NYC_GRAVEYARD";
    remove_actors[i].actor_name = 'Barrel0';//barrel next to the transmitter thing, idk what it does but it explodes when I move it
    i++;
}

function AddGoalActor(int goalID, int index, name actorName, EPhysics physics)
{
    goals[goalID].actors[index].actorName = actorName;
    goals[goalID].actors[index].physics = physics;
}

function int AddGoal(string mapName, string goalName, int bitMask, name actorName, EPhysics physics)
{
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
    locations[num_locations].mapName = mapName;
    locations[num_locations].name = name;
    locations[num_locations].bitMask = bitMask;
    for(i=0; i<ArrayCount(locations[num_locations].positions); i++) {
        AddActorLocation(num_locations, i, loc, r);
    }

    if(name == "" && mapName == dxr.localURL) {
        a = Lightbulb(_AddActor(self, class'Lightbulb', loc, r));
        a.bInvincible = true;
        DebugMarkKeyPosition(a, num_locations @ loc);
    }
    return num_locations++;
}

function AddMutualExclusion(int L1, int L2)
{
    mutually_exclusive[num_mututally_exclusives].L1 = L1;
    mutually_exclusive[num_mututally_exclusives].L2 = L2;
    num_mututally_exclusives++;
}

function int InitGoals(int mission, string map)
{
    local int goal, loc;
    // return a salt for the seed, the default return at the end is fine if you only have 1 set of goals in the whole mission
    num_goals = 0;
    num_locations = 0;
    num_mututally_exclusives = 0;
    switch(map) {
    case "01_NYC_UNATCOISLAND":
        // need to add vanilla start locations
        AddGoal("01_NYC_UNATCOISLAND", "Terrorist Commander", NORMAL_GOAL, 'TerroristCommander0', PHYS_Falling);
        AddGoalLocation("01_NYC_UNATCOISLAND", "UNATCO HQ", START_LOCATION, vect(-6348.445313, 1912.637207, -111.428482), rot(0, 0, 0));
        AddGoalLocation("01_NYC_UNATCOISLAND", "Dock", START_LOCATION | VANILLA_GOAL, vect(-4760.569824, 10430.811523, -280.674988), rot(0, -7040, 0));
        AddGoalLocation("01_NYC_UNATCOISLAND", "Harley Filben Dock", START_LOCATION, vect(1297.173096, -10257.972656, -287.428131), rot(0, 0, 0));
        AddGoalLocation("01_NYC_UNATCOISLAND", "Electric Bunker", NORMAL_GOAL | START_LOCATION, vect(6552.227539, -3246.095703, -447.438049), rot(0, 0, 0));
        AddGoalLocation("01_NYC_UNATCOISLAND", "Jail", NORMAL_GOAL | START_LOCATION, vect(2127.692139, -1774.869141, -149.140366), rot(0, 0, 0));
        AddGoalLocation("01_NYC_UNATCOISLAND", "Hut", NORMAL_GOAL, vect(-2407.206787, 205.915558, -128.899979), rot(0, 30472, 0));
        AddGoalLocation("01_NYC_UNATCOISLAND", "Top of the Base", NORMAL_GOAL, vect(2980.058105, -669.242554, 1056.577271), rot(0, 0, 0));
        if( dxr.flags.settings.goals > 0 )
            AddGoalLocation("01_nyc_unatcoisland", "Top of the Statue", NORMAL_GOAL | VANILLA_GOAL | START_LOCATION, vect(2931.230957, 27.495235, 2527.800049), rot(0, 14832, 0));
        break;

    case "02_NYC_BATTERYPARK":
        goal = AddGoal("02_NYC_BATTERYPARK", "Ambrosia", NORMAL_GOAL, 'BarrelAmbrosia0', PHYS_Falling);
        AddGoalActor(goal, 1, 'SkillAwardTrigger0', PHYS_None);
        AddGoalActor(goal, 2, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 3, 'FlagTrigger1', PHYS_None);
        AddGoalActor(goal, 4, 'DataLinkTrigger1', PHYS_None);

        AddGoalLocation("02_NYC_BATTERYPARK", "Dock", START_LOCATION | VANILLA_GOAL, vect(-619.571289, -3679.116455, 255.099762), rot(0, 29856, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Ventilation system", NORMAL_GOAL | START_LOCATION, vect(-4310.507813, 2237.952637, 189.843536), rot(0, 0, 0));
        if(dxr.flags.settings.goals > 0) {
            loc = AddGoalLocation("02_NYC_BATTERYPARK", "Ambrosia Vanilla", NORMAL_GOAL | VANILLA_GOAL | START_LOCATION, vect(507.282898, -1066.344604, -403.132751), rot(0, 16536, 0));
            AddActorLocation(loc, PLAYER_LOCATION, vect(81.434570, -1123.060547, -384.397644), rot(0, 8000, 0));
        }
        AddGoalLocation("02_NYC_BATTERYPARK", "In the command room", NORMAL_GOAL, vect(650.060547, -989.234863, -178.095200), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Behind the cargo", NORMAL_GOAL, vect(58.725319, -446.887207, -416.899323), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "On the desk", NORMAL_GOAL, vect(-644.152161, -676.281738, -379.581146), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Walkway by the water", NORMAL_GOAL, vect(-420.000000, -2222.000000, -420.899750), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Subway stairs", NORMAL_GOAL, vect(-4993.205078, 1919.453003, -73.239639), rot(0, 16384, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Subway", NORMAL_GOAL, vect(-4727.703613, 3116.336670, -336.900604), rot(0, 0, 0));
        return 21;

    case "02_NYC_WAREHOUSE":
        AddGoal("02_NYC_WAREHOUSE", "Jock", NORMAL_GOAL, 'BlackHelicopter1', PHYS_Falling);
        AddGoalLocation("02_NYC_WAREHOUSE", "", NORMAL_GOAL, vect(-222.402451, -294.757233, 1132.798462), rot(0, -24128, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "", NORMAL_GOAL, vect(-566.249695, 305.599731, 1207.798462), rot(0, -32800, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "", NORMAL_GOAL, vect(1656.467041, -1658.624268, 357.798462), rot(0, -32800, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "", NORMAL_GOAL, vect(1665.240112, 91.544250, 126.798462), rot(0, 0, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "", NORMAL_GOAL, vect(-1508.833008, 321.208252, -216.201538), rot(0, 16400, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "", NORMAL_GOAL | VANILLA_GOAL, vect(-222.402451,-294.757233,21132.798828), rot(0,-24128,0));
        return 22;

    case "03_NYC_BATTERYPARK":
        AddGoal("03_NYC_BATTERYPARK", "Harley Filben", NORMAL_GOAL, 'HarleyFilben0', PHYS_Falling);
        goal = AddGoal("03_NYC_BATTERYPARK", "Curly", NORMAL_GOAL, 'BumMale4', PHYS_Falling);
        AddGoalActor(goal, 1, 'BumFemale2', PHYS_Falling);
        AddGoalLocation("03_NYC_BATTERYPARK", "Jock", START_LOCATION | VANILLA_GOAL, vect(-1226.699951, 2215.864258, 400.663818), rot(0, -25672, 0));
        AddGoalLocation("03_NYC_BATTERYPARK", "", NORMAL_GOAL | START_LOCATION, vect(-4857.345215, 3452.138916, -301.399628), rot(0, 0, 0));
        AddGoalLocation("03_NYC_BATTERYPARK", "", NORMAL_GOAL | START_LOCATION, vect(-2771.231689, 1412.594604, 373.603882), rot(0, 7272, 0));
        AddGoalLocation("03_NYC_BATTERYPARK", "", NORMAL_GOAL | START_LOCATION, vect(1082.374023, 1458.807617, 334.248260), rot(0, 0, 0));
        AddGoalLocation("03_NYC_BATTERYPARK", "", START_LOCATION, vect(-4340.930664, 2332.365234, 244.506165), rot(0, 0, 0));
        AddGoalLocation("03_NYC_BATTERYPARK", "", NORMAL_GOAL | START_LOCATION, vect(-2968.101563, -1407.404419, 334.242554), rot(0, 0, 0));
        AddGoalLocation("03_NYC_BATTERYPARK", "", NORMAL_GOAL | START_LOCATION, vect(-1079.890625, -3412.052002, 270.581390), rot(0, 0, 0));
        AddGoalLocation("03_NYC_BATTERYPARK", "", NORMAL_GOAL | VANILLA_GOAL, vect(-2763.231689,1370.594604,369.799988), rot(0,7272,0));
        AddGoalLocation("03_NYC_BATTERYPARK", "", NORMAL_GOAL | VANILLA_GOAL, vect(-4819.345215,3478.138916,-304.225006), rot(0,0,0));
        return 31;

    case "03_NYC_BROOKLYNBRIDGESTATION":
        // GOAL_TYPE1 is only for people that can safely go up into the Rooks territory
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Rock (Drug Dealer)", NORMAL_GOAL, 'ThugMale13', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Lenny (Junkie)", NORMAL_GOAL | GOAL_TYPE1, 'JunkieMale1', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Charlie", NORMAL_GOAL | GOAL_TYPE1, 'BumMale2', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "El Rey", NORMAL_GOAL | GOAL_TYPE1, 'ThugMale3', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Ex-Mole Person", NORMAL_GOAL | GOAL_TYPE1, 'BumMale3', PHYS_Falling);
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Water pipes", NORMAL_GOAL, vect(2893.466064, -4513.004395, 104.099274), rot(0, 0, 0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Rooks East Side", GOAL_TYPE1, vect(1755.025391, -847.637695, 382.144287), rot(0, 0, 0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Men's Restroom", NORMAL_GOAL | VANILLA_GOAL, vect(-1248.503662,-2870.117432,109.675003), rot(0,-21080,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Rooks West Side", GOAL_TYPE1 | VANILLA_GOAL, vect(-2978.629639,-2281.836670,415.774994), rot(0,0,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "SE Corner", NORMAL_GOAL | VANILLA_GOAL, vect(975.220337,1208.224854,111.775002), rot(0,-22408,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "NE Corner", NORMAL_GOAL | VANILLA_GOAL, vect(1003.048767,-2519.280762,111.775002), rot(0,13576,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "NW Corner", NORMAL_GOAL | VANILLA_GOAL, vect(-988.025696,-3381.119385,111.775002), rot(0,-22608,0));
        return 32;

    case "03_NYC_AIRFIELD":
        AddGoal("03_NYC_AIRFIELD", "Terrorist with the East Gate key", NORMAL_GOAL, 'Terrorist13', PHYS_Falling);
        AddGoalLocation("03_NYC_AIRFIELD", "", NORMAL_GOAL, vect(223.719452, 3689.905273, 15.100115), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "", NORMAL_GOAL, vect(-2103.891113, 3689.706299, 15.091076), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "", NORMAL_GOAL, vect(-2060.626465, -2013.138672, 15.090023), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "", NORMAL_GOAL, vect(729.454651, -4151.924805, 15.079981), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "", NORMAL_GOAL, vect(5215.076660, -4134.674316, 15.090023), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "", NORMAL_GOAL, vect(941.941895, 283.418152, 15.090023), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "", NORMAL_GOAL | VANILLA_GOAL, vect(-2687.128662,2320.010986,63.774998), rot(0,0,0));
        return 33;

    case "04_NYC_NSFHQ":
        AddGoal("04_NYC_NSFHQ", "Computer", NORMAL_GOAL, 'ComputerPersonal3', PHYS_Falling);
        AddGoalLocation("04_NYC_NSFHQ", "", NORMAL_GOAL, vect(-460.091187, 1011.083496, 551.367859), rot(0, 16672, 0));
        AddGoalLocation("04_NYC_NSFHQ", "", NORMAL_GOAL, vect(206.654617, 1340.000000, 311.652832), rot(0, 0, 0));
        AddGoalLocation("04_NYC_NSFHQ", "", NORMAL_GOAL, vect(381.117371, -696.875671, 63.615902), rot(0, 32768, 0));
        AddGoalLocation("04_NYC_NSFHQ", "", NORMAL_GOAL, vect(42.340145, 1104.667480, 73.610352), rot(0, 0, 0));
        AddGoalLocation("04_NYC_NSFHQ", "", NORMAL_GOAL, vect(1290.299927, 1385.000000, -185.000000), rot(0, 16384, 0));
        AddGoalLocation("04_NYC_NSFHQ", "", NORMAL_GOAL, vect(-617.888855, 141.699875, -208.000000), rot(0, 16384, 0));
        AddGoalLocation("04_NYC_NSFHQ", "", NORMAL_GOAL | VANILLA_GOAL, vect(187.265259,315.583862,1032.054199), rot(0,16672,0));
        break;

    case "05_NYC_UNATCOMJ12LAB":
        goal = AddGoal("05_NYC_UNATCOMJ12LAB", "Paul", NORMAL_GOAL, 'PaulDenton0', PHYS_Falling);
        AddGoalActor(goal, 1, 'PaulDentonCarcass0', PHYS_Falling);
        AddGoalActor(goal, 2, 'DataLinkTrigger6', PHYS_None);
        AddGoalLocation("05_NYC_UNATCOMJ12LAB", "", NORMAL_GOAL, vect(-8548.773438, 1074.370850, -20.860909), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOMJ12LAB", "", NORMAL_GOAL | VANILLA_GOAL, vect(2177.405273,-552.487671,-213.375015), rot(0,16944,0));
        AddGoalLocation("05_NYC_UNATCOMJ12LAB", "", NORMAL_GOAL | VANILLA_GOAL, vect(2281.708008,-617.352478,-224.224991), rot(0,35984,0));
        AddGoalLocation("05_NYC_UNATCOMJ12LAB", "", NORMAL_GOAL | VANILLA_GOAL, vect(2179.028076,-562.791992,-178.900085), rot(0,0,0));
        return 51;

    case "05_NYC_UNATCOHQ":
        AddGoal("05_NYC_UNATCOHQ", "Alex Jacobson", NORMAL_GOAL, 'AlexJacobson0', PHYS_Falling);
        AddGoalLocation("05_NYC_UNATCOHQ", "", NORMAL_GOAL, vect(-2478.156738, -1123.645874, -16.399887), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "", NORMAL_GOAL, vect(121.921074, 287.711243, 39.599487), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "", NORMAL_GOAL, vect(261.019775, -403.939575, 287.600586), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "", NORMAL_GOAL, vect(718.820068, 1411.137451, 287.598999), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "", NORMAL_GOAL, vect(-666.268066, -460.813965, 463.598083), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "", NORMAL_GOAL | VANILLA_GOAL, vect(2001.611206,-801.088379,-16.225000), rot(0,23776,0));
        return 52;

    case "06_HONGKONG_MJ12LAB":
        goal = AddGoal("06_HONGKONG_MJ12LAB", "Nanotech Blade ROM", NORMAL_GOAL, 'ComputerPersonal0', PHYS_Falling);
        /*AddGoalActor(goal, 1, 'DataLinkTrigger0', PHYS_None);// I doubt these all need to be moved
        AddGoalActor(goal, 1, 'DataLinkTrigger3', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger4', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger5', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger6', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger8', PHYS_None);
        AddGoalActor(goal, 1, 'FlagTrigger0', PHYS_None);
        AddGoalActor(goal, 1, 'FlagTrigger1', PHYS_None);
        AddGoalActor(goal, 1, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 1, 'SkillAwardTrigger10', PHYS_None);*/
        AddGoal("06_HONGKONG_MJ12LAB", "Radiation Controls", NORMAL_GOAL, 'ComputerPersonal1', PHYS_Falling);
        AddGoalLocation("06_HONGKONG_MJ12LAB", "", NORMAL_GOAL, vect(-140.163544, 1705.130127, -583.495483), rot(0, 0, 0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "", NORMAL_GOAL, vect(-1273.699951, 803.588745, -792.499512), rot(0, 16384, 0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "", NORMAL_GOAL, vect(-1712.699951, -809.700012, -744.500610), rot(0, 16384, 0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "", NORMAL_GOAL | VANILLA_GOAL, vect(-0.995101,-260.668579,-311.088989), rot(0,32824,0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "", NORMAL_GOAL | VANILLA_GOAL, vect(-723.018677,591.498901,-743.972717), rot(0,49160,0));
        break;

    case "08_NYC_Bar":
    case "08_NYC_FreeClinic":
    case "08_NYC_Hotel":
    case "08_NYC_Smug":
    case "08_NYC_Street":
    case "08_NYC_Underground":
        // filben? dowd? greene?
        break;

    case "09_NYC_GRAVEYARD":
        goal = AddGoal("09_NYC_GRAVEYARD", "Jammer", NORMAL_GOAL, 'BreakableWall1', PHYS_Falling);
        AddGoalActor(goal, 1, 'SkillAwardTrigger2', PHYS_None);
        AddGoalActor(goal, 2, 'FlagTrigger0', PHYS_None);
        AddGoalActor(goal, 3, 'TriggerLight0', PHYS_None);
        AddGoalActor(goal, 4, 'TriggerLight1', PHYS_None);
        AddGoalActor(goal, 5, 'TriggerLight2', PHYS_None);
        AddGoalActor(goal, 6, 'AmbientSoundTriggered0', PHYS_None);
        AddGoalLocation("09_NYC_GRAVEYARD", "", NORMAL_GOAL, vect(-283.503448, -787.867920, -184.000000), rot(0, 0, -32768));
        AddGoalLocation("09_NYC_GRAVEYARD", "", NORMAL_GOAL, vect(-766.879333, 501.505676, -88.109619), rot(0, 0, -32768));
        AddGoalLocation("09_NYC_GRAVEYARD", "", NORMAL_GOAL, vect(-1530.000000, 845.000000, -107.000000), rot(0, 0, -32768));
        AddGoalLocation("09_NYC_GRAVEYARD", "", NORMAL_GOAL | VANILLA_GOAL, vect(1103.000000,728.000000,48.000000), rot(0,0,-32768));
        return 91;

    case "09_NYC_SHIPBELOW":
        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point", NORMAL_GOAL, 'DeusExMover40', PHYS_None);
        AddGoalActor(goal, 1, 'ParticleGenerator10', PHYS_None);
        AddGoal("09_NYC_SHIPBELOW", "Weld Point", NORMAL_GOAL, 'DeusExMover16', PHYS_None);
        AddGoalActor(goal, 1, 'ParticleGenerator4', PHYS_None);
        AddGoal("09_NYC_SHIPBELOW", "Weld Point", NORMAL_GOAL, 'DeusExMover33', PHYS_None);
        AddGoalActor(goal, 1, 'ParticleGenerator7', PHYS_None);
        AddGoal("09_NYC_SHIPBELOW", "Weld Point", NORMAL_GOAL, 'DeusExMover31', PHYS_None);
        AddGoalActor(goal, 1, 'ParticleGenerator5', PHYS_None);
        AddGoal("09_NYC_SHIPBELOW", "Weld Point", NORMAL_GOAL, 'DeusExMover32', PHYS_None);
        AddGoalActor(goal, 1, 'ParticleGenerator6', PHYS_None);
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL, vect(-384.000000, 1024.000000, -272.000000), rot(0, 49152, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL, vect(-3296.000000, -1664.000000, -112.000000), rot(0, 81920, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL, vect(-2480.000000, -448.000000, -144.000000), rot(0, 32768, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL, vect(-3952.000000, 768.000000, -416.000000), rot(0, 0, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL, vect(-5664.000000, -928.000000, -432.000000), rot(0, 16384, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL, vect(-4080.000000, -816.000000, -128.000000), rot(0, 32768, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL, vect(-4720.000000, 1536.000000, -144.000000), rot(0, -16384, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL, vect(-3200.000000, -48.000000, -96.000000), rot(0, 0, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL, vect(-288.000000, -432.000000, 112.000000), rot(-16384, 16384, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL | VANILLA_GOAL, vect(832.000000,1024.000000,-432.000000), rot(0,49152,0));
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL | VANILLA_GOAL, vect(-3680.000000,1647.000000,-416.000000), rot(0,49152,0));
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL | VANILLA_GOAL, vect(-6528.000000,200.000000,-448.000000), rot(0,65536,0));
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL | VANILLA_GOAL, vect(-3296.000000,-1664.000000,-416.000000), rot(0,81920,0));
        AddGoalLocation("09_NYC_SHIPBELOW", "", NORMAL_GOAL | VANILLA_GOAL, vect(832.000000,-1024.000000,-416.000000), rot(0,16384,0));
        return 92;

    case "10_PARIS_METRO":
    case "10_PARIS_CLUB":
        // nicolette
        break;

    case "11_PARIS_CATHEDRAL":
        goal = AddGoal("11_PARIS_CATHEDRAL", "Templar Computer", NORMAL_GOAL, 'ComputerPersonal0', PHYS_Falling);
        AddGoalActor(goal, 1, 'GuntherHermann0', PHYS_Falling);
        AddGoalActor(goal, 2, 'OrdersTrigger0', PHYS_None);
        AddGoalActor(goal, 3, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 4, 'SkillAwardTrigger3', PHYS_None);
        AddGoalActor(goal, 5, 'FlagTrigger2', PHYS_None);
        AddGoalActor(goal, 6, 'DataLinkTrigger8', PHYS_None);
        AddGoalLocation("11_PARIS_CATHEDRAL", "", NORMAL_GOAL, vect(2990.853516, 30.971684, -392.498993), rot(0, 16384, 0));
        AddGoalLocation("11_PARIS_CATHEDRAL", "", NORMAL_GOAL, vect(1860.275635, -9.666374, -371.286804), rot(0, 16384, 0));
        AddGoalLocation("11_PARIS_CATHEDRAL", "", NORMAL_GOAL, vect(1511.325317, -3204.465088, -680.498413), rot(0, 32768, 0));
        AddGoalLocation("11_PARIS_CATHEDRAL", "", NORMAL_GOAL, vect(3480.141602, -3180.397949, -704.496704), rot(0, 0, 0));
        AddGoalLocation("11_PARIS_CATHEDRAL", "", NORMAL_GOAL, vect(3458.506592, -2423.655029, -104.499863), rot(0, -16384, 0));
        AddGoalLocation("11_PARIS_CATHEDRAL", "", NORMAL_GOAL, vect(2659.672852, -1515.583862, 393.494843), rot(0, 10720, 0));
        AddGoalLocation("11_PARIS_CATHEDRAL", "", NORMAL_GOAL | VANILLA_GOAL, vect(5193.660645,-1007.544922,-838.674988), rot(0,-17088,0));
        break;

    case "12_VANDENBERG_CMD":
        AddGoal("12_VANDENBERG_CMD", "Control Station", NORMAL_GOAL, 'Keypad0', PHYS_None);
        AddGoal("12_VANDENBERG_CMD", "Control Station", NORMAL_GOAL, 'Keypad1', PHYS_None);
        AddGoalLocation("12_VANDENBERG_CMD", "Jock", START_LOCATION | VANILLA_GOAL, vect(657.233215, 2501.673096, -908.798096), rot(0, -16384, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "", NORMAL_GOAL, vect(1895.174561, 1405.394287, -1656.404175), rot(0, 32768, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "", NORMAL_GOAL, vect(444.509338, 1503.229126, -1415.007568), rot(0, -16384, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "", NORMAL_GOAL, vect(-288.769806, 1103.257813, -1984.334717), rot(0, -16384, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "", NORMAL_GOAL, vect(-1276.664063, 1168.599854, -1685.868042), rot(0, 16384, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "", START_LOCATION, vect(657.233215, 2501.673096, -908.798096), rot(0, -16384, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "", START_LOCATION, vect(6750.350586, 7763.461426, -3092.699951), rot(0, 0, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "", START_LOCATION, vect(-214.927200, 888.034485, -2043.409302), rot(0, 0, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "", START_LOCATION, vect(-1879.828003, 1820.156006, -1777.113892), rot(0, 0, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "", NORMAL_GOAL | VANILLA_GOAL, vect(-2371.028564,-96.179214,-2070.390625), rot(0,-32768,0));
        AddGoalLocation("12_VANDENBERG_CMD", "", NORMAL_GOAL | VANILLA_GOAL, vect(1628.947754,1319.745483,-2014.406982), rot(0,-65536,0));
        break;

    case "14_OCEANLAB_SILO":
        AddGoal("14_OCEANLAB_SILO", "Howard Strong", NORMAL_GOAL, 'HowardStrong0', PHYS_Falling);
        AddGoalLocation("14_OCEANLAB_SILO", "", NORMAL_GOAL, vect(-220.000000, -6829.463379, 55.600639), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "", NORMAL_GOAL, vect(-259.846710, -6848.406250, 326.598969), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "", NORMAL_GOAL, vect(-271.341187, -6832.150391, 535.596741), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "", NORMAL_GOAL, vect(-266.569397, -6868.054199, 775.592590), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "", NORMAL_GOAL | VANILLA_GOAL, vect(-52.397560,-6767.679199,-320.225006), rot(0,-7512,0));
        break;

    case "15_AREA51_BUNKER":
        AddGoalLocation("15_AREA51_BUNKER", "Jock", START_LOCATION | VANILLA_GOAL, vect(-1778.574707, 1741.028320, -213.732849), rot(0, -12416, 0));
        AddGoalLocation("15_AREA51_BUNKER", "", START_LOCATION, vect(-1778.574707, 1741.028320, -213.732849), rot(0, -12416, 0));
        AddGoalLocation("15_AREA51_BUNKER", "", START_LOCATION, vect(-493.825836, 3099.697510, -512.897827), rot(0, 0, 0));
        break;
    }

    return mission+1000;
}

function PreFirstEntry()
{
    local #var(prefix)AnnaNavarre anna;
    local int goalsToLocations[32];
    local int seed;

    Super.PreFirstEntry();
#ifndef revision
    seed = InitGoals(dxr.dxInfo.missionNumber, dxr.localURL);
#endif

    if( dxr.localURL == "01_NYC_UNATCOISLAND" ) {
        dxr.flags.f.SetBool('MeetPaul_Played', true,, 2);
        dxr.flags.f.SetBool('FemJCMeetPaul_Played', true,, 2);
        dxr.flags.f.SetBool('PaulGaveWeapon', true,, 2);
#ifdef revision
        dxr.flags.f.SetBool('PaulGiveWeapon_Played', true,, 2);
        dxr.flags.f.SetBool('FemJCPaulGiveWeapon_Played', true,, 2);
        dxr.flags.f.SetBool('GotFreeWeapon', true,, 2);
#endif
    }
    else if( dxr.localURL == "02_NYC_BATTERYPARK" ) {
        foreach AllActors(class'#var(prefix)AnnaNavarre', anna) {
            anna.SetOrders('Standing');
            anna.SetLocation( vect(1082.845703, 1807.538818, 335.101776) );
            anna.SetRotation( rot(0, -16608, 0) );
            anna.HomeLoc = anna.Location;
            anna.HomeRot = vector(anna.Rotation);
        }
    }

    SetGlobalSeed( "DXRMissions" $ seed );

    if( ArrayCount(goalsToLocations) != ArrayCount(goals) ) err("ArrayCount(goalsToLocations) != ArrayCount(goals)");

    if(num_goals == 0) return;

    MoveActorsOut();
    ChooseGoalLocations(goalsToLocations);
    MoveActorsIn(goalsToLocations);
}

function MoveActorsOut()
{
    local int g, i;
    local Actor a;

    for(g=0; g<num_goals; g++) {
        if( dxr.localURL != goals[g].mapName ) continue;

        for(i=0; i<ArrayCount(goals[g].actors); i++) {
            a = GetActor(goals[g].actors[i]);
            if(a == None) continue;
            a.SetLocation(a.Location + vect(0,0,20000));
        }
    }
}

function MoveActorsIn(int goalsToLocations[32])
{
    local int g, i;
    local #var(PlayerPawn) p;

    if( dxr.flags.settings.goals > 0 ) {
        for(g=0; g<num_goals; g++) {
            MoveGoalToLocation(goals[g], locations[goalsToLocations[g]]);
        }
    }

    if( dxr.flags.settings.startinglocations > 0 ) {
        p = player();
        g = goalsToLocations[g];
        l("Moving player to " $ locations[g].name);
        i = PLAYER_LOCATION;
        p.SetLocation(locations[g].positions[i].pos);
        p.SetRotation(locations[g].positions[i].rot);
        rando_start_loc = p.Location;
        b_rando_start = true;
    }
}

function bool _ChooseGoalLocations(out int goalsToLocations[32])
{
    // TODO: check mutual_exclusions, maybe ensure things aren't too close together?
    local int i, r, _num_locs;
    local int availLocs[64];
    for(i=0; i<num_locations; i++) {
        availLocs[i] = i;
    }
    _num_locs = num_locations;

    // choose a starting location
    goalsToLocations[num_goals] = -1;
    for(i=0; i<10; i++) {
        r = rng(_num_locs);
        if( (START_LOCATION & locations[availLocs[r]].bitMask) == 0)
            continue;

        goalsToLocations[num_goals] = availLocs[r];
        _num_locs--;
        availLocs[r] = availLocs[_num_locs];
    }
    if(goalsToLocations[num_goals] == -1)
        return false;

    // choose the goal locations
    for(i=0; i<num_goals; i++) {
        r = rng(_num_locs);
        goalsToLocations[i] = availLocs[r];
        if( (goals[i].bitMask & locations[availLocs[r]].bitMask) == 0)
            return false;

        _num_locs--;
        availLocs[r] = availLocs[_num_locs];
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
        if(a.name == ga.actorName) {
            ga.a = a;
            return a;
        }
    }
    return None;
}

function bool MoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local int i;
    local Actor a;

    // TODO: need to handle GoalLocation with different map, need to destroy actors moving out of the map, and spawn them for moving in
    l("Moving " $ g.name $ " ("$ g.actors[0].a $") to " $ Loc.name $ " ("$ Loc.positions[0].pos $")");

    for(i=0; i<ArrayCount(g.actors); i++) {
        a = g.actors[i].a;
        if(a == None) continue;
        MoveActor(a, Loc.positions[i].pos, Loc.positions[i].rot, g.actors[i].physics);
    }
}

function bool MoveActor(Actor a, vector loc, rotator rotation, EPhysics p)
{
    local ScriptedPawn sp;
    local Mover m;
    local bool success, oldbCollideWorld;
    local Vehicles v;

    l("moving " $ a $ " from (" $ a.location $ ") to (" $ loc $ ")" );
    oldbCollideWorld = a.bCollideWorld;
    if(p == PHYS_None) a.bCollideWorld = false;
    success = a.SetLocation(loc);
    if( success == false ) {
        a.bCollideWorld = oldbCollideWorld;
        warning("failed to move "$a$" to "$loc);
        return false;
    }
    a.SetRotation(rotation);
    a.SetPhysics(p);
    if(p == PHYS_None) a.bCollideWorld = oldbCollideWorld;

    sp = ScriptedPawn(a);
    if( sp != None ) {
        if( sp.Orders == 'Patrolling' ) sp.SetOrders('Wandering');
        sp.HomeLoc = sp.Location;
        sp.HomeRot = vector(sp.Rotation);
        sp.DesiredRotation = rotation;
        if (!sp.bInWorld){
            sp.WorldPosition = sp.Location;
            sp.SetLocation(sp.Location+vect(0,0,20000));
        }
    }
    v = Vehicles(a);
    if ( v != None ) {
        if (!v.bInWorld){
            v.WorldPosition = v.Location;
            v.SetLocation(v.Location+vect(0,0,20000));
        }
    }

    m = Mover(a);
    if( m != None ) {
        m.BasePos = a.Location;
        m.BaseRot = a.Rotation;
    }

    return true;
}

function bool MoveGoalTo(name goalName, int locNumber)
{
    /*local Actor goalActor,a;
    local ImportantLocation targetLoc;
    local goal targetGoal;
    local int i,locNum;
    local bool foundGoal,foundLoc;

    //Find goal actor by name
     foreach AllActors(class'Actor', a) {
#ifdef hx
        if( a.GetPropertyText("PrecessorName") == string(goalName) )
#else
        if( a.name == goalName )
#endif
        {
            goalActor = a;
            break;
        }
    }

    if (goalActor == None) {
        //Couldn't find the actual goal actor
        return False;
    }
    locNum = 0;
    for(i=0; i<ArrayCount(important_locations); i++) {
        if( dxr.localURL != important_locations[i].map_name ) continue;
        if (locNum==locNumber){
            targetLoc = important_locations[i];
            foundLoc = true;
            break;
        }
        locNum++;
    }

    if (foundLoc == false){
        //Couldn't find the target location
        return False;
    }

    for(i=0; i<ArrayCount(goals); i++) {
        if( dxr.localURL != goals[i].map_name ) continue;
        if (goals[i].actor_name==goalName){
            targetGoal = goals[i];
            foundGoal = true;
            break;
        }
    }

    if (foundGoal == false){
        //Couldn't find a goal for the specified name
        return False;
    }

    MoveActor(goalActor, targetLoc.location, targetLoc.rotation, targetGoal.physics);

    return True;*/
}

static function bool IsCloseToStart(DXRando dxr, vector loc)
{
    local PlayerStart ps;
    local Teleporter t;
    local float too_close, dist;
    local DXRMissions m;

    too_close = 90*16;

    m = DXRMissions(dxr.FindModule(class'DXRMissions'));
    if( dxr.localURL == "12_VANDENBERG_GAS" ) {
        if ( VSize(vect(168.601334, 607.866882, -980.902832) - loc) < too_close ) return true;
    }
    if( m != None && m.b_rando_start ) {
        if ( VSize(m.rando_start_loc - loc) < too_close ) return true;
        else return false;
    }
    else {
        foreach dxr.RadiusActors(class'PlayerStart', ps, too_close, loc) {
            dist = VSize(loc-ps.location);
            if( dist < too_close ) return true;
        }
    }

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
