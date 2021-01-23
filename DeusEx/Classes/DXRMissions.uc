class DXRMissions extends DXRActorsBase;

//list of actors to remove
//list of starting positions
//list of goals to move, with a minimum distance from starting postion? and a radius of triggers to pull with it? list of positions they can be placed in?

struct RemoveActor {
    var string map_name;
    var name actor_name;
};
var config RemoveActor remove_actors[32];

struct ImportantLocation {
    var string map_name;
    var vector location;
    var rotator rotation;
    var bool is_player_start;
    var bool is_goal_position;
};
var config ImportantLocation important_locations[100];

struct Goal {
    var string map_name;
    var name actor_name;
    var float group_radius;
    var EPhysics physics;
    var bool move_with_previous;//for chaining things together?
    var bool allow_vanilla;
    //var bool is_movable_actor;
};
var config Goal goals[64];

var config bool allow_vanilla;

struct RandomItemStruct { var string type; var int chance; };
struct _RandomItemStruct { var class<Inventory> type; var int chance; };
var config RandomItemStruct randomitems[16];
var _RandomItemStruct _randomitems[16];

function CheckConfig()
{
    local class<Actor> a;
    local int i;
    local string map;

    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,9) ) {
        allow_vanilla = false;

        i=0;
        remove_actors[i].map_name = "01_NYC_unatcoisland";
        remove_actors[i].actor_name = 'PaulDenton0';//because he gives you EZ mode weapons
        i++;

        remove_actors[i].map_name = "01_NYC_unatcoisland";
        remove_actors[i].actor_name = 'DataLinkTrigger0';//find Paul
        i++;

        remove_actors[i].map_name = "01_NYC_unatcoisland";
        remove_actors[i].actor_name = 'DataLinkTrigger2';//nsf everywhere? doesn't trigger unless you talk to paul
        i++;

        remove_actors[i].map_name = "01_NYC_unatcoisland";
        remove_actors[i].actor_name = 'DataLinkTrigger8';//the "don't leave without talking to Paul" datalink
        i++;

        remove_actors[i].map_name = "02_nyc_batterypark";
        remove_actors[i].actor_name = 'AnnaNavarre0';//because she chases you down
        i++;

        /*remove_actors[i].map_name = "09_NYC_GRAVEYARD";
        remove_actors[i].actor_name = 'Barrel0';//barrel next to the transmitter thing, idk what it does but it explodes when I move it
        i++;*/

        for(i=0; i<ArrayCount(goals); i++) {
            goals[i].map_name = "";
            goals[i].group_radius = 0;
            goals[i].physics = PHYS_Falling;
            goals[i].move_with_previous = false;
            goals[i].allow_vanilla = false;
        }
        for(i=0; i<ArrayCount(important_locations); i++) {
            important_locations[i].is_player_start = false;
            important_locations[i].is_goal_position = true;
            important_locations[i].rotation = rot(0,0,0);
        }
        for(i=0; i < ArrayCount(randomitems); i++ ) {
            randomitems[i].type = "";
            randomitems[i].chance = 0;
        }

        i=0;

        map="01_nyc_unatcoisland";
        goals[i].map_name = map;
        goals[i].actor_name = 'TerroristCommander0';
        i++;

        map = "02_nyc_batterypark";
        goals[i].map_name = map;
        goals[i].actor_name = 'BarrelAmbrosia0';
        goals[i].group_radius = 160;
        goals[i].allow_vanilla = true;
        i++;

        map = "03_nyc_batterypark";
        goals[i].map_name = map;
        goals[i].actor_name = 'HarleyFilben0';
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'BumMale4';
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'BumFemale2';
        goals[i].move_with_previous = true;
        i++;

        map = "03_nyc_airfield";
        goals[i].map_name = map;
        goals[i].actor_name = 'Terrorist13';//need to make sure to get rid of his patrol orders
        goals[i].allow_vanilla = true;
        i++;

        map = "03_NYC_BrooklynBridgeStation";
        goals[i].map_name = map;
        goals[i].actor_name = 'ThugMale13';
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'JunkieMale1';
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'BumMale2';
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'ThugMale3';
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'BumMale3';
        goals[i].allow_vanilla = true;
        i++;

        map = "04_NYC_NSFHQ";
        goals[i].map_name = map;
        goals[i].actor_name = 'ComputerPersonal3';
        goals[i].allow_vanilla = true;
        goals[i].physics = PHYS_None;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'ComputerPersonal4';
        goals[i].allow_vanilla = true;
        goals[i].physics = PHYS_None;
        i++;

        map = "05_NYC_UnatcoMJ12Lab";
        goals[i].map_name = map;
        goals[i].actor_name = 'PaulDenton0';
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'PaulDentonCarcass0';
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'DataLinkTrigger6';
        goals[i].allow_vanilla = true;
        goals[i].move_with_previous = true;
        i++;

        map = "05_NYC_UnatcoHQ";
        goals[i].map_name = map;
        goals[i].actor_name = 'AlexJacobson0';
        goals[i].allow_vanilla = true;
        i++;

        map = "06_hongkong_mj12lab";
        goals[i].map_name = map;
        goals[i].actor_name = 'ComputerPersonal0';
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'DataLinkTrigger0';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'DataLinkTrigger3';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'DataLinkTrigger4';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'DataLinkTrigger5';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'DataLinkTrigger6';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'DataLinkTrigger8';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'FlagTrigger0';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'FlagTrigger1';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'GoalCompleteTrigger0';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'SkillAwardTrigger10';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'ComputerPersonal1';
        goals[i].allow_vanilla = true;
        i++;

        /*map = "08_nyc_street";
        goals[i].map_name = map;
        goals[i].actor_name = 'StantonDowd0';
        goals[i].allow_vanilla = true;
        i++;*/

        map = "09_nyc_graveyard";
        goals[i].map_name = map;
        goals[i].actor_name = 'BreakableWall1';
        goals[i].physics = PHYS_None;
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'SkillAwardTrigger2';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'FlagTrigger0';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'TriggerLight0';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'TriggerLight1';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'TriggerLight2';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'AmbientSoundTriggered0';
        goals[i].physics = PHYS_None;
        goals[i].move_with_previous = true;
        i++;

        map = "09_nyc_shipbelow";
        goals[i].map_name = map;
        goals[i].actor_name = 'DeusExMover40';//weld point
        goals[i].physics = PHYS_None;
        goals[i].group_radius = 80;
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'DeusExMover16';//weld point
        goals[i].physics = PHYS_None;
        goals[i].group_radius = 80;
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'DeusExMover33';//weld point
        goals[i].physics = PHYS_None;
        goals[i].group_radius = 80;
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'DeusExMover31';//weld point
        goals[i].physics = PHYS_None;
        goals[i].group_radius = 80;
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'DeusExMover32';//weld point
        goals[i].physics = PHYS_None;
        goals[i].group_radius = 80;
        goals[i].allow_vanilla = true;
        i++;

        map = "11_paris_cathedral";
        goals[i].map_name = map;
        goals[i].actor_name = 'ComputerPersonal0';//
        goals[i].allow_vanilla = true;
        goals[i].physics = PHYS_None;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'GuntherHermann0';//
        goals[i].move_with_previous = true;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'OrdersTrigger0';//
        goals[i].move_with_previous = true;
        goals[i].physics = PHYS_None;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'GoalCompleteTrigger0';//
        goals[i].move_with_previous = true;
        goals[i].physics = PHYS_None;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'SkillAwardTrigger3';//
        goals[i].move_with_previous = true;
        goals[i].physics = PHYS_None;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'FlagTrigger2';//
        goals[i].move_with_previous = true;
        goals[i].physics = PHYS_None;
        goals[i].group_radius = 1;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'DataLinkTrigger8';//
        goals[i].move_with_previous = true;
        goals[i].physics = PHYS_None;
        goals[i].group_radius = 1;
        i++;

        /*map = "11_paris_everett";
        goals[i].map_name = map;
        goals[i].actor_name = 'Mechanic0';//fake mechanic, Ray, talking to him early skips all the everett dialog
        goals[i].allow_vanilla = true;
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'OrdersTrigger3';//
        goals[i].move_with_previous = true;
        goals[i].physics = PHYS_None;
        i++;*/

        //mission 6 I can move the computer that opens the UC (nowhere good to put it though)?
        //11 everett? the fake mechanic near lucius, morpheus, aquarium
        //12 maybe the 2 keypads in vandenberg cmd? tiffany? in the bathroom or in the truck?
        //14 howard strong? 
        //15 ?

        i=0;

        map="01_nyc_unatcoisland";
        important_locations[i].map_name = map;
        important_locations[i].location = vect(-6348.445313,1912.637207,-111.428482);//'PathNode217' near unatco hq
        important_locations[i].is_player_start = true;
        important_locations[i].is_goal_position = false;
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(1297.173096,-10257.972656,-287.428131);//'PathNode274' near Harley Filben
        important_locations[i].is_player_start = true;
        important_locations[i].is_goal_position = false;
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(6552.227539,-3246.095703,-447.438049);//'PathNode851' bunker with electricity
        important_locations[i].is_player_start = true;
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(2321.717041,-2045.296753,-159.436096);//'PathNode23' in jail with Gunther
        important_locations[i].is_player_start = true;
        important_locations[i].is_goal_position = true;
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-2407.206787,205.915558,-128.899979);//'HidePoint6' little hut by nsf bot patrol
        important_locations[i].rotation = rot(0,30472,0);
        important_locations[i].is_player_start = true;
        important_locations[i].is_goal_position = true;
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(2931.230957,27.495235,2527.800049);//'TerroristCommander0'
        important_locations[i].rotation = rot(0,14832,0);
        important_locations[i].is_player_start = true;
        i++;

        map = "02_nyc_batterypark";
        important_locations[i].map_name = map;
        important_locations[i].location = vect(-4310.507813,2237.952637,189.843536);//'Light450' 
        important_locations[i].is_player_start = true;
        important_locations[i].is_goal_position = true;
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(507.282898,-1066.344604,-403.132751);//'BarrelAmbrosia0'
        important_locations[i].rotation = rot(0,16536,0);
        important_locations[i].is_player_start = true;
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(650.060547,-989.234863,-178.095200);//'PathNode17'
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(58.725319,-446.887207,-416.899323);//'PathNode167'
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-644.152161,-676.281738,-379.581146);//'Cigarettes0' on the table
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-444.113403,-2055.208252,-420.899750);//'PathNode192'
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-4993.205078,1919.453003,-73.239639);//'Light414'
        important_locations[i].rotation = rot(0,16384,0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-4727.703613,3116.336670,-336.900604);//'PathNode142'
        i++;

        map = "03_nyc_batterypark";
        important_locations[i].map_name = map;
        important_locations[i].location = vect(-4819.345215,3478.138916,-304.225006);//'HarleyFilben0'
        important_locations[i].is_player_start = true;
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-2763.231689,1370.594604,369.799988);//'BumMale4'
        important_locations[i].rotation = rot(0,7272,0);
        important_locations[i].is_player_start = true;
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(1082.374023, 1458.807617, 334.248260);//'PathNode68' outside of castle clinton
        important_locations[i].is_player_start = true;
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-4340.930664, 2332.365234, 244.506165);//'Light174' under the vent
        important_locations[i].is_player_start = true;
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-2968.101563, -1407.404419, 334.242554);//'PathNode0' in front of statue
        important_locations[i].is_player_start = true;
        i++;

        map = "03_nyc_airfield";
        important_locations[i].map_name = map;
        important_locations[i].location = vect(223.719452, 3689.905273, 15.100115);//'SpawnPoint9' by the gate to nowhere
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-2103.891113, 3689.706299, 15.091076);//'PathNode49' under security tower
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-2060.626465, -2013.138672, 15.090023);//'PathNode162' under security tower
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(729.454651, -4151.924805, 15.079981);//'PathNode118' under security tower
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(5215.076660, -4134.674316, 15.090023);//'PathNode188' under security tower
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(941.941895, 283.418152, 15.090023);//'PathNode81' big hanger door
        i++;

        /*important_locations[i].map_name = map;
        important_locations[i].location = vect(-2687.128662,2320.010986,63.774998);//'Terrorist13'
        i++;*/

        map = "03_NYC_BrooklynBridgeStation";
        important_locations[i].map_name = map;
        important_locations[i].location = vect(975.220337,1208.224854,111.775002);//'ThugMale13'
        important_locations[i].rotation = rot(0,43128,0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-1248.503662,-2870.117432,109.675003);//'JunkieMale1'
        important_locations[i].rotation = rot(0,44456,0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(1003.048767,-2519.280762,111.775002);//'BumMale2'
        important_locations[i].rotation = rot(0,13576,0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-2978.629639,-2281.836670,415.774994);//'ThugMale3'
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-988.025696, -3381.119385, 111.600235);//'BumMale3'
        important_locations[i].rotation = rot(0,-22608,0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(2893.466064, -4513.004395, 104.099274);//'SkillAwardTrigger0' near the pipes
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(1755.025391, -847.637695, 382.144287);//'PathNode20' upper level
        i++;

        map = "04_NYC_NSFHQ";
        important_locations[i].map_name = map;
        important_locations[i].location = vect(-460.091187, 1011.083496, 551.367859);//near the medbot
        important_locations[i].rotation = rot(0, 16672, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(206.654617, 1340, 311.652832);//locked room
        important_locations[i].rotation = rot(0, 0, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(381.117371, -696.875671, 63.615902);//next to repair bot
        important_locations[i].rotation = rot(0, 32768, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(42.340145, 1104.667480, 73.610352);//break room
        important_locations[i].rotation = rot(0, 0, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(1290.299927, 1385, -185);//basement counter
        important_locations[i].rotation = rot(0, 16384, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-617.888855, 141.699875, -208);//basement table
        important_locations[i].rotation = rot(0, 16384, 0);
        i++;

        map = "05_NYC_UnatcoMJ12Lab";
        /*important_locations[i].map_name = map;
        important_locations[i].location = vect(-4088.201172, 807.195679, -100.860603);//robot maintenance
        important_locations[i].rotation = rot(0, 0, 0);
        i++;*/

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-8548.773438, 1074.370850, -20.860909);//armory
        important_locations[i].rotation = rot(0, 0, 0);
        i++;

        map = "05_NYC_UnatcoHQ";
        important_locations[i].map_name = map;
        important_locations[i].location = vect(-2478.156738, -1123.645874, -16.399887);//jail
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(121.921074, 287.711243, 39.599487);//bathroom
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(261.019775, -403.939575, 287.600586);//manderley's bathroom
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(718.820068, 1411.137451, 287.598999);//vending machines
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-666.268066, -460.813965, 463.598083);//office
        i++;

        map = "06_hongkong_mj12lab";
        important_locations[i].map_name = map;
        important_locations[i].location = vect(-140.163544, 1705.130127, -583.495483);//barracks
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-1273.699951, 803.588745, -792.499512);//radioactive area
        important_locations[i].rotation = rot(0, 16384, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-1712.699951, -809.700012, -744.500610);//labs
        important_locations[i].rotation = rot(0, 16384, 0);
        i++;

        /*map = "08_nyc_street";
        important_locations[i].map_name = map;
        important_locations[i].location = vect(2850.863525, -873.754883, -720.404785);//smuggler front door
        important_locations[i].rotation = rot(0, 32768, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(2608.952881, -2765.534912, -448.403107);//basketball court
        important_locations[i].rotation = rot(0, 32768, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(3756.613525, -4264.618652, -528.401306);//smuggler back door
        important_locations[i].rotation = rot(0, 16384, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-2372.936035, -568.257813, -464.395020);//alley
        i++;*/

        map = "09_nyc_graveyard";
        important_locations[i].map_name = map;
        important_locations[i].location = vect(-283.503448, -787.867920, -184);//'PathNode108' in the tunnels
        important_locations[i].rotation = rot(0, 0, -32768);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-766.879333, 501.505676, -88.109619);//'BioelectricCell0' in the grave
        important_locations[i].rotation = rot(0, 0, -32768);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-1530, 845, -107);//'PathNode96' in the other tunnels
        important_locations[i].rotation = rot(0, 0, -32768);
        i++;

        map = "09_nyc_shipbelow";
        important_locations[i].map_name = map;
        important_locations[i].location = vect(-384.000000, 1024.000000, -272.000000);//first engine room
        important_locations[i].rotation = rot(0, 49152, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-3296.000000, -1664.000000, -112.000000);//above bilge pumps room
        important_locations[i].rotation = rot(0, 81920, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-2480.000000, -448.000000, -144.000000);//hallway above bilge pumps room
        important_locations[i].rotation = rot(0, 32768, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-3952.000000, 768.000000, -416.000000);//electrical room
        important_locations[i].rotation = rot(0, 0, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-5664.000000, -928.000000, -432.000000);//helipad room
        important_locations[i].rotation = rot(0, 16384, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-4336.000000, -150, -176.000000);//storage closet
        important_locations[i].rotation = rot(0, -16384, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-5152.000000, 1536.000000, -160.000000);//air control
        important_locations[i].rotation = rot(0, -16384, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-3072.000000, 64.000000, 816.000000);//big fan
        important_locations[i].rotation = rot(0, 0, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(-320.000000, -784.000000, 32.000000);//engine control room
        important_locations[i].rotation = rot(3800, 16384, 0);
        i++;

        map = "11_paris_cathedral";
        important_locations[i].map_name = map;
        important_locations[i].location = vect(2990.853516, 30.971684, -392.498993);//barracks
        important_locations[i].rotation = rot(0, 16384, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(1860.275635, -9.666374, -371.286804);//chapel
        important_locations[i].rotation = rot(0, 16384, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(1511.325317, -3204.465088, -680.498413);//kitchen
        important_locations[i].rotation = rot(0, 32768, 0);
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(3480.141602, -3180.397949, -704.496704);//vault
        i++;

        important_locations[i].map_name = map;
        important_locations[i].location = vect(3527.593750, -1992.829834, -100.499969);//WiB room
        important_locations[i].rotation = rot(0, -16384, 0);
        i++;

        i=0;

        randomitems[i].type = "Medkit";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "Lockpick";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "Multitool";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "Flare";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "FireExtinguisher";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "SoyFood";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "TechGoggles";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "Binoculars";
        randomitems[i].chance = 10;
        i++;

        randomitems[i].type = "BioelectricCell";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "BallisticArmor";
        randomitems[i].chance = 9;
        i++;

        randomitems[i].type = "WineBottle";
        randomitems[i].chance = 9;
        i++;
    }

    for(i=0; i<ArrayCount(remove_actors); i++) {
        remove_actors[i].map_name = Caps(remove_actors[i].map_name);
    }
    for(i=0; i<ArrayCount(goals); i++) {
        goals[i].map_name = Caps(goals[i].map_name);
    }
    for(i=0; i<ArrayCount(important_locations); i++) {
        important_locations[i].map_name = Caps(important_locations[i].map_name);
    }
    for(i=0; i < ArrayCount(randomitems); i++) {
        if( randomitems[i].type != "" ) {
            a = GetClassFromString(randomitems[i].type, class'Inventory');
            _randomitems[i].type = class<Inventory>(a);
            _randomitems[i].chance = randomitems[i].chance;
        }
    }

    Super.CheckConfig();
}

function FirstEntry()
{
    local Actor a;
    local int i, k, start, slot, tries, num_ma, num_ps, num_gl;
    local bool success;
    local vector loc, diff;
    local Actor movable_actors[32];
    local Goal local_goals[32];
    local ImportantLocation player_starts[32];
    local ImportantLocation goal_locations[32];

    Super.FirstEntry();

    if( dxr.localURL == "01_NYC_UNATCOISLAND" ) {
        RandoStartingEquipment(dxr.player);
    }

    SetSeed( "DXRMissions" );

    for(i=0; i<ArrayCount(important_locations); i++) {
        if( dxr.localURL != important_locations[i].map_name ) continue;

        if( important_locations[i].is_player_start ) {
            player_starts[num_ps] = important_locations[i];
            num_ps++;
        }
        if( important_locations[i].is_goal_position ) {
            goal_locations[num_gl] = important_locations[i];
            num_gl++;
        }
    }

    for(i=0; i<ArrayCount(goals); i++) {
        if( dxr.localURL != goals[i].map_name ) continue;
        local_goals[num_ma] = goals[i];
        num_ma++;
    }

    foreach AllActors(class'Actor', a) {
        for(i=0; i<ArrayCount(remove_actors); i++) {
            if( dxr.localURL != remove_actors[i].map_name ) continue;

            if( a.name == remove_actors[i].actor_name ) {
                a.Destroy();
                break;
            }
        }

        for(i=0; i<num_ma; i++) {
            if( a.name == local_goals[i].actor_name ) {
                movable_actors[i] = a;
            }
        }
    }

    if( allow_vanilla == true && num_ps > 0 ) {
        player_starts[num_ps].location = dxr.Player.location;
        player_starts[num_ps].rotation = dxr.Player.rotation;
        num_ps++;
    }

    if( dxr.flags.startinglocations > 0 && num_ps > 0 ) {
        l("randomizing starting location, num_ps == "$num_ps);
        start = rng(num_ps);
        dxr.Player.SetLocation(player_starts[start].location);
        dxr.Player.SetRotation(player_starts[start].rotation);

        for(i=0; i<num_gl; i++) {
            diff = player_starts[start].location - goal_locations[i].location;
            if( VSize(diff) < 160 ) {
                goal_locations[i] = goal_locations[num_gl-1];
                num_gl--;
                i--;
            }
        }
    }

    if( dxr.flags.goals == 0 ) return;

    l("randomizing goals, num_ma=="$num_ma$", num_gl=="$num_gl);

    for(i=0; i<num_ma && num_gl>0; i++) {
        if( local_goals[i].move_with_previous == true ) continue;

        if( allow_vanilla == true || local_goals[i].allow_vanilla == true ) {
            slot = rng(num_gl+1);
            if( slot == 0 ) continue;//don't do anything
            slot--;
        }
        else slot = rng(num_gl);
        l("moving goal: " $ movable_actors[i] );

        diff = goal_locations[slot].location - movable_actors[i].location;
        if( allow_vanilla == false && local_goals[i].allow_vanilla == false && num_gl > 1 && VSize(diff) < 16 && tries<100 ) {
            tries++;
            l(movable_actors[i] $ ", vanilla not allowed, num_gl==" $ num_gl $ ", tries=="$tries);
            i--;
            continue;
        }
        loc = GetCenter(movable_actors[i]);
        if( MoveActor(movable_actors[i], goal_locations[slot].location, goal_locations[slot].rotation, local_goals[i].physics) == false ) {
            continue;
        }
        if( local_goals[i].group_radius >= 0.1 ) {
            foreach RadiusActors(class'Actor', a, local_goals[i].group_radius, loc ) {
                if( NavigationPoint(a) != None ) continue;
                if( Light(a) != None ) continue;
                success = MoveActor(a, a.location + diff, a.rotation, local_goals[i].physics);
                if( success == false ) MoveActor(a, goal_locations[slot].location, a.rotation, local_goals[i].physics);
            }
        }

        for(k=i+1; k<num_ma; k++) {
            if( local_goals[k].move_with_previous == false ) break;
            success = false;
            if( local_goals[k].group_radius ~= 0.0 ) success = MoveActor(movable_actors[k], movable_actors[k].location + diff, goal_locations[slot].rotation, local_goals[k].physics);
            if( success == false ) MoveActor(movable_actors[k], goal_locations[slot].location, goal_locations[slot].rotation, local_goals[k].physics);
        }

        goal_locations[slot] = goal_locations[num_gl-1];
        num_gl--;
    }

}

function AnyEntry()
{
    Super.AnyEntry();
}

function bool MoveActor(Actor a, vector loc, rotator rotation, EPhysics p)
{
    local ScriptedPawn sp;
    local bool success, oldbCollideWorld;

    l("moving " $ a $ " from (" $ a.location $ ") to (" $ loc $ ")" );
    oldbCollideWorld = a.bCollideWorld;
    if(p == PHYS_None) a.bCollideWorld = false;
    success = a.SetLocation(loc);
    if( success == false ) {
        a.bCollideWorld = oldbCollideWorld;
        err("failed to move "$a$" to "$loc);
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
    }

    return true;
}

function RandoStartingEquipment(DeusExPlayer player)
{
    local Inventory item, anItem;
    local class<Inventory> iclass;
    local DXREnemies dxre;
    local DXRBannedItems dxrbanned;
    local int r, i;

    if( dxr.flags.equipment == 0 ) return;

    l("RandoStartingEquipment");
    dxr.SetSeed( dxr.Crc(dxr.seed $ " RandoStartingEquipment") );//independent of map/mission?

    dxr.player.energy = rng(75)+25;
    dxr.player.Credits = rng(200);

    dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));

    item = player.Inventory;
    while(item != None)
	{
		anItem = item;
        item = item.Inventory;
        if( NanoKeyRing(anItem) != None ) continue;
        if( dxre == None && DeusExWeapon(anItem) != None ) continue;
        if( dxre == None && Ammo(anItem) != None ) continue;
		player.DeleteInventory(anItem);
		anItem.Destroy();
	}

    dxrbanned = DXRBannedItems(dxr.FindModule(class'DXRBannedItems'));
    if( dxrbanned != None ) dxrbanned.AddStartingEquipment(player);

    for(i=0; i < dxr.flags.equipment; i++) {
        _RandoStartingEquipment(player, dxre);
    }
}

function _RandoStartingEquipment(DeusExPlayer player, DXREnemies dxre)
{
    local int i, r;
    local Inventory item;
    local class<Inventory> iclass;

    if(dxre != None) {
        dxre.GiveRandomWeapon(player);
        dxre.GiveRandomMeleeWeapon(player);
    }

    r = initchance();
    for(i=0; i < ArrayCount(_randomitems); i++ ) {
        if( _randomitems[i].type == None ) continue;
        if( chance( _randomitems[i].chance, r ) ) iclass = _randomitems[i].type;
    }

    item = Spawn(iclass);
    item.Frob(player, None);
}

//tests to ensure that there are more goal locations than movable actors for each map
function int RunTests()
{
    local int results, i, total;
    results = Super.RunTests();

    total=0;
    for(i=0; i < ArrayCount(randomitems); i++ ) {
        total += randomitems[i].chance;
    }
    results += test( total <= 100, "config randomitems chances, check total "$total);

    return results;
}
