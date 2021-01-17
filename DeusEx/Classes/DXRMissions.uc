class DXRMissions extends DXRBase;

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
var config ImportantLocation important_locations[64];

struct Goal {
    var string map_name;
    var name actor_name;
    var float group_radius;
    //var bool move_with_previous;//for chaining things together?
    //var bool is_movable_actor;
};
var config Goal goals[50];

var config bool allow_vanilla;

function CheckConfig()
{
    local int i;
    local string map;

    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,8) ) {
        allow_vanilla = false;

        i=0;
        remove_actors[i].map_name = "01_NYC_unatcoisland";
        remove_actors[i].actor_name = 'PaulDenton0';//because he gives you EZ mode weapons
        i++;

        remove_actors[i].map_name = "01_NYC_unatcoisland";
        remove_actors[i].actor_name = 'DataLinkTrigger8';//the "don't leave without talking to Paul" datalink
        i++;

        remove_actors[i].map_name = "02_nyc_batterypark";
        remove_actors[i].actor_name = 'AnnaNavarre0';//because she chases you down
        i++;

        for(i=0; i<ArrayCount(goals); i++) {
            goals[i].map_name = "";
            goals[i].group_radius = 0;
        }
        for(i=0; i<ArrayCount(important_locations); i++) {
            important_locations[i].is_player_start = false;
            important_locations[i].is_goal_position = true;
            important_locations[i].rotation = rot(0,0,0);
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
        i++;

        map = "03_nyc_batterypark";
        goals[i].map_name = map;
        goals[i].actor_name = 'HarleyFilben0';
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'BumMale4';
        goals[i].group_radius = 200;//bring BumFemale2 with him?
        i++;

        /*map = "03_nyc_airfield";
        goals[i].map_name = map;
        goals[i].actor_name = 'Terrorist13';//need to make sure to get rid of his patrol orders
        i++;*/

        map = "03_NYC_BrooklynBridgeStation";
        goals[i].map_name = map;
        goals[i].actor_name = 'ThugMale13';
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'JunkieMale1';
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'BumMale2';
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'ThugMale3';
        i++;

        goals[i].map_name = map;
        goals[i].actor_name = 'BumMale3';
        i++;

        /*goals[i].map_name = "04_NYC_NSFHQ";
        goals[i].actor_name = 'ComputerPersonal3';
        goals[i].group_radius = 16;
        i++;*/

        /*goals[i].map_name = "04_NYC_NSFHQ";
        goals[i].actor_name = 'ComputerPersonal4';//or maybe keep it behind the door that ComputerPersonal3 opens?
        goals[i].group_radius = 16;
        i++;*/

        /*goals[i].map_name = "";
        goals[i].actor_name = '';
        goals[i].group_radius = 0;
        i++;*/
        //mission 5 I can move Paul, Jaime, Alex
        //mission 6 I can move the computer that stores the rom encoding, and opens the UC?
        //mission 8 stanton dowd, harley filben, joe greene
        //mission 9 I can kinda move the weld points lol
        //11 gunther with the computer
        //12 tiffany?
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
        important_locations[i].location = vect(-2687.128662,2320.010986,63.774998);//'Terrorist13'
        i++;

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

        important_locations[i].map_name = "04_NYC_NSFHQ";
        important_locations[i].location = vect(187.265259,315.583862,1032.054199);//'ComputerPersonal3' computer to align dishes and open the door
        important_locations[i].rotation = rot(0,16672,0);
        i++;

        /*important_locations[i].map_name = "04_NYC_NSFHQ";
        important_locations[i].location = vect(116.650787,400.400024,1032.054199);//'ComputerPersonal4' computer that sends the signal, probably can't risk putting 'ComputerPersonal3' back here
        important_locations[i].rotation = rot(0,49384,0);
        i++;*/
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

    Super.CheckConfig();
}

function FirstEntry()
{
    local Actor a;
    local int i, k, start, slot, tries, num_ma, num_ps, num_gl;
    local vector diff;
    local Actor movable_actors[32];
    local float movable_actors_radius[32];
    local ImportantLocation player_starts[32];
    local ImportantLocation goal_locations[32];

    Super.FirstEntry();
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

    foreach AllActors(class'Actor', a) {
        for(i=0; i<ArrayCount(remove_actors); i++) {
            if( dxr.localURL != remove_actors[i].map_name ) continue;

            if( a.name == remove_actors[i].actor_name ) {
                a.Destroy();
                break;
            }
        }

        for(i=0; i<ArrayCount(goals); i++) {
            if( dxr.localURL != goals[i].map_name ) continue;

            if( a.name == goals[i].actor_name ) {
                movable_actors[num_ma] = a;
                movable_actors_radius[num_ma] = goals[i].group_radius;
                num_ma++;
            }
        }
    }

    if( allow_vanilla == true && num_ps > 0 ) {
        player_starts[num_ps].location = dxr.Player.location;
        player_starts[num_ps].rotation = dxr.Player.rotation;
        num_ps++;
    }

    if( num_ps > 0 ) {
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

    for(i=0; i<num_ma && num_gl>0; i++) {
        slot = rng(num_gl);
        diff = goal_locations[slot].location - movable_actors[i].location;
        if( allow_vanilla == false && num_gl > 1 && VSize(diff) < 16 && tries<100 ) {
            tries++;
            l(movable_actors[i] $ ", vanilla not allowed, num_gl==" $ num_gl $ ", tries=="$tries);
            i--;
            continue;
        }
        if( movable_actors_radius[i] >= 0.1 ) {
            foreach RadiusActors(class'Actor', a, movable_actors_radius[i], movable_actors[i].location) {
                if( NavigationPoint(a) != None ) continue;
                if( Light(a) != None ) continue;
                a.SetLocation( a.location + diff );
                a.SetPhysics(PHYS_Falling);
            }
        }
        //if current orders are patrolling, set orders to standing?
        movable_actors[i].SetLocation(goal_locations[slot].location);
        movable_actors[i].SetRotation(goal_locations[slot].rotation);
        movable_actors[i].SetPhysics(PHYS_Falling);
        goal_locations[slot] = goal_locations[num_gl-1];
        num_gl--;
    }

}

function AnyEntry()
{
    Super.AnyEntry();
}

//tests to ensure that there are more goal locations than movable actors
