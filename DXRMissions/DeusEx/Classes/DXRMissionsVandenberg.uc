class DXRMissionsVandenberg extends DXRMissions;

var bool WaltonAppeared;

function int InitGoals(int mission, string map)
{
    local int goal, loc;
    local int front_gate_start;
    local int howard_cherry, howard_meeting, howard_radio, howard_computer, howard_machine_shop;
    local int jock_vanilla, jock_cherry, jock_tower, jock_computer;
    local int computer_vanilla, computer_radio, computer_meeting, computer_machine_shop;

    switch(map) {
    case "12_VANDENBERG_CMD":
        AddGoal("12_VANDENBERG_CMD", "Backup Power Keypad", NORMAL_GOAL, 'Keypad0', PHYS_None);
        AddGoal("12_VANDENBERG_CMD", "Backup Power Keypad", NORMAL_GOAL, 'Keypad1', PHYS_None);
        AddGoalLocation("12_VANDENBERG_CMD", "Command Center Second Floor", NORMAL_GOAL, vect(1895.174561, 1405.394287, -1656.404175), rot(0, 32768, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "Third Floor Elevator", NORMAL_GOAL, vect(444.509338, 1503.229126, -1415.007568), rot(0, -16384, 0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Near Pipes", NORMAL_GOAL | START_LOCATION, vect(-288.769806, 1103.257813, -1984.334717), rot(0, -16384, 0));
        AddActorLocation(loc, PLAYER_LOCATION, vect(-214.927200, 888.034485, -2043.409302), rot(0, 0, 0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Globe Room", NORMAL_GOAL | START_LOCATION, vect(-1276.664063, 1168.599854, -1685.868042), rot(0, 16384, 0));
        AddActorLocation(loc, PLAYER_LOCATION, vect(-1879.828003, 1820.156006, -1777.113892), rot(0, 0, 0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Roof", NORMAL_GOAL | START_LOCATION | VANILLA_START, vect(927.361328, 2426.330811, -867.404114), rot(0, 32768, 0));
        AddActorLocation(loc, PLAYER_LOCATION, vect(657.233215, 2501.673096, -908.798096), rot(0, -16384, 0));

        front_gate_start = AddGoalLocation("12_VANDENBERG_CMD", "Front Gate", START_LOCATION, vect(6436.471680, 7621.873535, -3061.458740), rot(0, 0, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "Outdoor Power Generator", NORMAL_GOAL | VANILLA_GOAL, vect(-2371.028564,-96.179214,-2070.390625), rot(0,-32768,0));
        AddGoalLocation("12_VANDENBERG_CMD", "Command Center Power Generator", NORMAL_GOAL | VANILLA_GOAL, vect(1628.947754,1319.745483,-2014.406982), rot(0,-65536,0));

        // complicated because of DXRBacktracking::VandCmdAnyEntry() to reuse the chopper
        goal = AddGoal("12_VANDENBERG_CMD", "Jock and Tong", GOAL_TYPE1, 'BlackHelicopter0', PHYS_None);
        AddGoalActor(goal, 1, 'TracerTong0', PHYS_None);

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Front Gate", GOAL_TYPE1 | VANILLA_GOAL, vect(7014.185059, 7540.296875, -2984.704102), rot(0,-19840,0));
        AddActorLocation(loc, 1, vect(6436.471680, 7621.873535, -3061.458740), rot(0,-27976,0));
        AddMutualExclusion(front_gate_start, loc); // starting at the front gate and then exiting at the front gate is a LOT of walking

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Courtyard", GOAL_TYPE1, vect(-371.047180, 5046.039063, -2050.704102), rot(0,-19840,0));
        AddActorLocation(loc, 1, vect(-659.219116, 5350.891113, -2142.458740), rot(0,-27976,0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Comm 01 Roof", GOAL_TYPE1, vect(-1880.047119, 5443.039063, -1831.704102), rot(0,0,0));
        AddActorLocation(loc, 1, vect(-1581.219116, 5030.891113, -1910), rot(0,-14000,0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Command Roof", GOAL_TYPE1, vect(-2209.047119, 2820.039063, -1410.704102), rot(0,-10000,0));
        AddActorLocation(loc, 1, vect(-1617.219116, 2778.891113, -1471.458740), rot(0,-10000,0));

        //loc = AddGoalLocation("12_VANDENBERG_CMD", "Command Hall", GOAL_TYPE1, vect(1799.313965, 1914.730225, -1934.704102), rot(0,32768,0));
        //AddActorLocation(loc, 1, vect(1412.059204, 1802.125000, -2023.458740), rot(0,-30000,0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Sniper Tower", GOAL_TYPE1, vect(-946.215820, 80.315643, -1359.704102), rot(0,32768,0));
        AddActorLocation(loc, 1, vect(-1033.543579, 265.367859, -1569.458740), rot(0,-30000,0));

        if (dxr.flags.settings.starting_map > 120)
        {
            skip_rando_start = True;
        }

        return 121;

    case "14_VANDENBERG_SUB":
    case "14_OCEANLAB_LAB":
    case "14_OCEANLAB_UC":
        AddGoal("14_OCEANLAB_LAB", "Walton Simons", GOAL_TYPE1, 'WaltonSimons0', PHYS_Falling);
        AddGoalLocation("14_OCEANLAB_LAB", "Vanilla Digger", GOAL_TYPE1 | VANILLA_GOAL, vect(5294.391113,3422.380127,-1775.600830), rot(0,33056,0));
        AddGoalLocation("14_OCEANLAB_LAB", "Construction Sidepath", GOAL_TYPE1, vect(4158,2125,-1775), rot(0,0,0));
        AddGoalLocation("14_OCEANLAB_LAB", "Crew Module", GOAL_TYPE1, vect(2380,3532,-2233), rot(0,0,0));
        AddGoalLocation("14_OCEANLAB_LAB", "Greasel Lab", GOAL_TYPE1, vect(2920,454,-1486), rot(0,50000,0));
        AddGoalLocation("14_OCEANLAB_LAB", "Outside Karkian Lab", GOAL_TYPE1, vect(116,-61,-1967), rot(0,50000,0));
        AddGoalLocation("14_VANDENBERG_SUB", "Rooftop", GOAL_TYPE1, vect(2450,2880,776), rot(0,33080,0));
        AddGoalLocation("14_VANDENBERG_SUB", "Sub Bay", GOAL_TYPE1, vect(5372,-1626,-1424), rot(0,-16368,0));
        AddGoalLocation("14_OCEANLAB_UC", "UC Entry 1", GOAL_TYPE1, vect(945,6230,-4160), rot(0,0,0));
        AddGoalLocation("14_OCEANLAB_UC", "UC Entry 2", GOAL_TYPE1, vect(945,5189,-4160), rot(0,16384,0));

        goal = AddGoal("14_OCEANLAB_UC", "UC Computer", NORMAL_GOAL, 'ComputerPersonal0', PHYS_Falling);
        AddGoalActor(goal, 1, 'DataLinkTrigger1', PHYS_None);
        AddGoalActor(goal, 2, 'DataLinkTrigger2', PHYS_None);
        AddGoal("14_OCEANLAB_UC", "Email Computer", NORMAL_GOAL, 'ComputerPersonal1', PHYS_Falling);
        AddGoalLocation("14_OCEANLAB_UC", "UC", NORMAL_GOAL | VANILLA_GOAL, vect(264.363281, 6605.039551, -3173.865967), rot(0,32720,0));
        AddGoalLocation("14_OCEANLAB_UC", "Email Station", NORMAL_GOAL | VANILLA_GOAL, vect(-264.784027, 8735.982422, -2904.487549), rot(0,8816,0));
        AddGoalLocation("14_OCEANLAB_UC", "South Wing", NORMAL_GOAL | VANILLA_GOAL, vect(-1133.915039, 6690.755371, -3800.472168), rot(0,16384,0));// non-radioactive
        AddGoalLocation("14_OCEANLAB_UC", "North Wing", NORMAL_GOAL | VANILLA_GOAL, vect(1832.621338, 6919.640137, -3764.490234), rot(0,16384,0));// outside radioactive room
        return 141;

    case "14_OCEANLAB_SILO":
        // HOWARD
        AddGoal("14_OCEANLAB_SILO", "Howard Strong", NORMAL_GOAL, 'HowardStrong0', PHYS_Falling);
        howard_computer = AddGoalLocation("14_OCEANLAB_SILO", "Launch Command", NORMAL_GOAL, vect(38,-1306,832), rot(0, 28804, 0));
        //howard_computer = AddGoalLocation("14_OCEANLAB_SILO", "Launch Command", NORMAL_GOAL, vect(-100, -1331, 832), rot(0, 32768, 0));
        howard_meeting = AddGoalLocation("14_OCEANLAB_SILO", "Surface Meeting Room", NORMAL_GOAL, vect(-640,-3589,1472), rot(0, 34388, 0));
        howard_radio = AddGoalLocation("14_OCEANLAB_SILO", "Radio", NORMAL_GOAL, vect(-1794,-6147,1662), rot(0, 18000, 0));
        howard_machine_shop = AddGoalLocation("14_OCEANLAB_SILO", "Machine Shop", NORMAL_GOAL, vect(566,-4395,1474), rot(0, 21120, 0));
        //AddGoalLocation("14_OCEANLAB_SILO", "Third Floor", NORMAL_GOAL, vect(-220.000000, -6829.463379, 55.600639), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Fourth Floor", NORMAL_GOAL, vect(-259.846710, -6848.406250, 326.598969), rot(0, 0, 0));
        //AddGoalLocation("14_OCEANLAB_SILO", "Fifth Floor", NORMAL_GOAL, vect(-271.341187, -6832.150391, 535.596741), rot(0, 0, 0)); //this one sucks, since he runs away down the hall
        //howard_sixth = AddGoalLocation("14_OCEANLAB_SILO", "Sixth Floor", NORMAL_GOAL, vect(-266.569397, -6868.054199, 775.592590), rot(0, 0, 0));
        howard_cherry = AddGoalLocation("14_OCEANLAB_SILO", "Cherry Picker", NORMAL_GOAL | VANILLA_GOAL, vect(-52.397560,-6767.679199,-320.225006), rot(0,-7512,0));

        // JOCK
        AddGoal("14_OCEANLAB_SILO", "Jock Escape", GOAL_TYPE1, 'BlackHelicopter0', PHYS_None);
        jock_vanilla = AddGoalLocation("14_OCEANLAB_SILO", "Vanilla Escape", GOAL_TYPE1 | VANILLA_GOAL, vect(-194.602554, -5680.964355, 1507.895020), rot(0, 0, 0));
        jock_tower = AddGoalLocation("14_OCEANLAB_SILO", "Sniper Tower", GOAL_TYPE1, vect(-842.344604, -3827.978027, 2039.993286), rot(0, 0, 0));
        jock_cherry = AddGoalLocation("14_OCEANLAB_SILO", "Cherry Picker", GOAL_TYPE1, vect(-13.000000, -6790.000000, -542.000000), rot(0, 32768, 0));
        jock_computer = AddGoalLocation("14_OCEANLAB_SILO", "Launch Command", GOAL_TYPE1, vect(-100.721497, -1331.947754, 904.364380), rot(0, 32768, 0));

        // COMPUTER
        goal = AddGoal("14_OCEANLAB_SILO", "Launch Command Computer", GOAL_TYPE2, 'ComputerSecurity0', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger4', PHYS_None); // Launch sequence initiated.  It's gonna be a sunny day at Area 51...
        computer_vanilla = AddGoalLocation("14_OCEANLAB_SILO", "Launch Command", GOAL_TYPE2 | VANILLA_GOAL, vect(175.973724, -1612.441650, 853.105103), rot(0,16344,0));
        computer_radio = AddGoalLocation("14_OCEANLAB_SILO", "Radio", GOAL_TYPE2, vect(-1721.988770, -6533.606445, 1665), rot(16384,32768,0));
        computer_meeting = AddGoalLocation("14_OCEANLAB_SILO", "Surface Meeting Room", GOAL_TYPE2, vect(-691.854248, -3575.400391, 1475), rot(16384,0,0));
        computer_machine_shop = AddGoalLocation("14_OCEANLAB_SILO", "Machine Shop", GOAL_TYPE2, vect(234, -4439, 1475.204590), rot(16384,0,0));

        // MUTEXES
        AddMutualExclusion(howard_radio, computer_radio);
        AddMutualExclusion(howard_computer, computer_vanilla);
        AddMutualExclusion(howard_meeting, computer_meeting);
        AddMutualExclusion(howard_machine_shop, computer_machine_shop);

        AddMutualExclusion(howard_cherry, jock_cherry); //Cherry Picker and bottom of silo Jock
        AddMutualExclusion(howard_meeting, jock_tower); //Surface meeting room and sniper tower
        AddMutualExclusion(howard_radio, jock_vanilla); //Radio/Poker building and vanilla Jock
        AddMutualExclusion(howard_computer, jock_computer); // both in the same room

        AddMutualExclusion(computer_vanilla, jock_computer);

        return 142;
    }

    return mission+1000;
}

function int InitGoalsRev(int mission, string map)
{
    local int goal, loc, howard1, howard2, jock1, jock2;
    local int front_gate_start;

    switch(map) {
    case "12_VANDENBERG_CMD":
        AddGoal("12_VANDENBERG_CMD", "Backup Power Keypad", NORMAL_GOAL, 'Keypad2', PHYS_None);
        AddGoal("12_VANDENBERG_CMD", "Backup Power Keypad", NORMAL_GOAL, 'Keypad1', PHYS_None);
        AddGoalLocation("12_VANDENBERG_CMD", "Command Center Second Floor", NORMAL_GOAL, vect(1895.174561, 1405.394287, -1656.404175), rot(0, 32768, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "Third Floor Elevator", NORMAL_GOAL, vect(444.509338, 1503.229126, -1415.007568), rot(0, -16384, 0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Near Pipes", NORMAL_GOAL | START_LOCATION, vect(-288.769806, 1103.257813, -1984.334717), rot(0, -16384, 0));
        AddActorLocation(loc, PLAYER_LOCATION, vect(-214.927200, 888.034485, -2043.409302), rot(0, 0, 0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Globe Room", NORMAL_GOAL | START_LOCATION, vect(-1276.664063, 1168.599854, -1685.868042), rot(0, 16384, 0));
        AddActorLocation(loc, PLAYER_LOCATION, vect(-1879.828003, 1820.156006, -1777.113892), rot(0, 0, 0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Roof", NORMAL_GOAL | START_LOCATION | VANILLA_START, vect(927.361328, 2426.330811, -867.404114), rot(0, 32768, 0));
        AddActorLocation(loc, PLAYER_LOCATION, vect(657.233215, 2501.673096, -908.798096), rot(0, -16384, 0));

        front_gate_start = AddGoalLocation("12_VANDENBERG_CMD", "Front Gate", START_LOCATION, vect(6436.471680, 7621.873535, -3061.458740), rot(0, 0, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "Outdoor Power Generator", NORMAL_GOAL | VANILLA_GOAL, vect(-2371.028564,-96.179214,-2070.390625), rot(0,-32768,0));
        AddGoalLocation("12_VANDENBERG_CMD", "Command Center Power Generator", NORMAL_GOAL | VANILLA_GOAL, vect(1628.947754,1319.745483,-2014.406982), rot(0,-65536,0));

        // Will need handling if backtracking is implemented for Revision, since this uses a JockHelicopter
        goal = AddGoal("12_VANDENBERG_CMD", "Jock and Tong", GOAL_TYPE1, 'JockHelicopter2', PHYS_None);
        AddGoalActor(goal, 1, 'TracerTong0', PHYS_None);

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Front Gate", GOAL_TYPE1 | VANILLA_GOAL, vect(7040,7540,-2984), rot(0,-19840,0));
        AddActorLocation(loc, 1, vect(6436.471680, 7621.873535, -3061.458740), rot(0,-27976,0));
        AddMutualExclusion(front_gate_start, loc); // starting at the front gate and then exiting at the front gate is a LOT of walking

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Courtyard", GOAL_TYPE1, vect(-371.047180, 5564, -2050.704102), rot(0,-19840,0));
        AddActorLocation(loc, 1, vect(-659.219116, 5350.891113, -2142.458740), rot(0,-27976,0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Comm 01 Roof", GOAL_TYPE1, vect(-3099,8106,-1790), rot(0,-19840,0));
        AddActorLocation(loc, 1, vect(-2614,7817,-1922), rot(0,-14000,0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Command Roof", GOAL_TYPE1, vect(-2209.047119, 2820.039063, -1307), rot(0,-10000,0));
        AddActorLocation(loc, 1, vect(-1857,3077,-1471), rot(0,0,0));

        //loc = AddGoalLocation("12_VANDENBERG_CMD", "Command Hall", GOAL_TYPE1, vect(1799.313965, 1914.730225, -1934.704102), rot(0,32768,0));
        //AddActorLocation(loc, 1, vect(1412.059204, 1802.125000, -2023.458740), rot(0,-30000,0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Sniper Tower", GOAL_TYPE1, vect(-946.215820, 80.315643, -1359.704102), rot(0,32768,0));
        AddActorLocation(loc, 1, vect(-1033.543579, 265.367859, -1569.458740), rot(0,-30000,0));

        if (dxr.flags.settings.starting_map > 120)
        {
            skip_rando_start = True;
        }

        return 121;

    case "14_VANDENBERG_SUB":
    case "14_OCEANLAB_LAB":
    case "14_OCEANLAB_UC":
        AddGoal("14_OCEANLAB_LAB", "Walton Simons", GOAL_TYPE1, 'WaltonSimons0', PHYS_Falling);
        AddGoalLocation("14_OCEANLAB_LAB", "Digger", GOAL_TYPE1 | VANILLA_GOAL, vect(5294.391113,3422.380127,-1775.600830), rot(0,33056,0));
        AddGoalLocation("14_OCEANLAB_LAB", "Construction Sidepath", GOAL_TYPE1, vect(4158,2125,-1775), rot(0,0,0));
        AddGoalLocation("14_OCEANLAB_LAB", "Crew Module", GOAL_TYPE1, vect(2380,3532,-2233), rot(0,0,0));
        AddGoalLocation("14_OCEANLAB_LAB", "Greasel Lab", GOAL_TYPE1, vect(2920,454,-1486), rot(0,50000,0));
        AddGoalLocation("14_OCEANLAB_LAB", "Outside Karkian Lab", GOAL_TYPE1, vect(116,-61,-1967), rot(0,50000,0));
        AddGoalLocation("14_VANDENBERG_SUB", "Rooftop", GOAL_TYPE1, vect(2450,2880,776), rot(0,33080,0));
        AddGoalLocation("14_VANDENBERG_SUB", "Sub Bay", GOAL_TYPE1, vect(5372,-1626,-1424), rot(0,-16368,0));
        AddGoalLocation("14_OCEANLAB_UC", "UC Entry 1", GOAL_TYPE1, vect(945,6161,-4160), rot(0,16384,0));
        AddGoalLocation("14_OCEANLAB_UC", "UC Entry 2", GOAL_TYPE1, vect(945,5189,-4160), rot(0,16384,0));

        goal = AddGoal("14_OCEANLAB_UC", "UC Computer", NORMAL_GOAL, 'ComputerPersonal0', PHYS_Falling);
        AddGoalActor(goal, 1, 'DataLinkTrigger1', PHYS_None);
        AddGoalActor(goal, 2, 'DataLinkTrigger2', PHYS_None);
        AddGoal("14_OCEANLAB_UC", "Email Computer", NORMAL_GOAL, 'ComputerPersonal1', PHYS_Falling);
        AddGoalLocation("14_OCEANLAB_UC", "UC", NORMAL_GOAL | VANILLA_GOAL, vect(828.280029,4830.881348,-2911.599365), rot(0,32720,0));
        AddGoalLocation("14_OCEANLAB_UC", "Email Station", NORMAL_GOAL | VANILLA_GOAL, vect(74.924225,8542.011719,-2904.487549), rot(0,352,0));
        AddGoalLocation("14_OCEANLAB_UC", "South Wing", NORMAL_GOAL | VANILLA_GOAL, vect(-1068.248169,6907.536133,-3800.492920), rot(0,16384,0));// non-radioactive
        AddGoalLocation("14_OCEANLAB_UC", "North Wing", NORMAL_GOAL | VANILLA_GOAL, vect(2415.803467,7068.529785,-3740.642090), rot(0,-8000,0));// Medical room?
        return 141;


    case "14_OCEANLAB_SILO":
        AddGoal("14_OCEANLAB_SILO", "Howard Strong", NORMAL_GOAL, 'HowardStrong0', PHYS_Falling);

        AddGoalLocation("14_OCEANLAB_SILO", "Third Floor", NORMAL_GOAL, vect(-220.000000, -6829.463379, 55.600639), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Fourth Floor", NORMAL_GOAL, vect(-259.846710, -6848.406250, 326.598969), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Fifth Floor", NORMAL_GOAL, vect(-271.341187, -6832.150391, 535.596741), rot(0, 0, 0));
        howard1 = AddGoalLocation("14_OCEANLAB_SILO", "Sixth Floor", NORMAL_GOAL, vect(-266.569397, -6868.054199, 775.592590), rot(0, 0, 0));
        howard2 = AddGoalLocation("14_OCEANLAB_SILO", "Cherry Picker", NORMAL_GOAL | VANILLA_GOAL, vect(-52.397560,-6767.679199,-320.225006), rot(0,-7512,0));

        AddGoal("14_OCEANLAB_SILO", "Jock Escape", GOAL_TYPE1, 'BlackHelicopter0', PHYS_None);
        jock1 = AddGoalLocation("14_OCEANLAB_SILO", "Vanilla Escape", GOAL_TYPE1 | VANILLA_GOAL, vect(-194.602554,-5680.769043,1513.223389), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Sniper Tower", GOAL_TYPE1, vect(-842.344604, -3827.978027, 2039.993286), rot(0, 0, 0));
        jock2 = AddGoalLocation("14_OCEANLAB_SILO", "Cherry Picker", GOAL_TYPE1, vect(-13.000000, -6790.000000, -542.000000), rot(0, 32768, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Launch Command", GOAL_TYPE1, vect(-100.721497, -1331.947754, 904.364380), rot(0, 32768, 0));

        AddMutualExclusion(howard1, jock1);
        AddMutualExclusion(howard2, jock2);

        return 142;

    }

    return mission+1000;
}

function UpdateLocation(Actor a)
{
    _UpdateLocation(a, "Jock and Tong");
}

function MissionTimer()
{
    local #var(prefix)WaltonSimons Walton;
    local FlagBase f;

    f = dxr.flagbase;

    switch(dxr.localURL) {
    case "12_VANDENBERG_CMD":
        UpdateGoalWithRandoInfo('FindJock', "Jock could be anywhere around the Command Center.");
        UpdateGoalWithRandoInfo('ActivatePower', "The keypads can be anywhere around the Command Center.");
        break;

    case "14_VANDENBERG_SUB":
    case "14_OCEANLAB_UC":
        if (!WaltonAppeared && f.GetBool('schematic_downloaded'))
        {
            foreach AllActors(class'#var(prefix)WaltonSimons', Walton){
                Walton.EnterWorld();
            }
            WaltonAppeared=True;

        }
        break;

    case "14_OCEANLAB_SILO":
        UpdateGoalWithRandoInfo('MeetJock', "Jock could be anywhere around the silo.");
        UpdateGoalWithRandoInfo('AbortLaunch', "The computer to reprogram the missile could be anywhere around the silo.");

        if (!f.GetBool('schematic_downloaded') || !f.GetBool('Heliosborn')){
            UpdateGoalWithRandoInfo('PreventSabotage', "Howard Strong will only appear once the AIs have been merged in Vandenberg and the UC schematics have been retrieved from the Ocean Lab.");
        }

        break;
    }
}

function CreateGoal(out Goal g, GoalLocation Loc)
{
    local #var(prefix)ScriptedPawn sp;
    local OrdersTrigger ot;

    switch(g.name) {
    case "Walton Simons":
        sp = #var(prefix)ScriptedPawn(Spawnm(class'#var(prefix)WaltonSimons',, 'DXRMissions', Loc.positions[0].pos));
        ot = OrdersTrigger(Spawnm(class'OrdersTrigger',,'simonsattacks',Loc.positions[0].pos));
        g.actors[0].a = sp;
        g.actors[1].a = ot;

        sp.BarkBindName = "WaltonSimons";
        sp.Tag='WaltonSimons';
        sp.SetOrders('WaitingFor');
        sp.bInvincible=False;

        //scuba in the OceanLab, probably needs to be mj12 on shore, maybe something else if in UC area?
        if (Loc.mapName == "14_OCEANLAB_LAB"){
            sp.SetAlliance('scuba');
        } else if (Loc.mapName=="14_VANDENBERG_SUB"){
            sp.SetAlliance('mj12');
        } else if (Loc.mapName=="14_OCEANLAB_UC"){
            sp.SetAlliance('spider');
        }

        GiveItem(sp,class'WeaponPlasmaRifle',100);
        GiveItem(sp,class'WeaponNanoSword');

        sp.ConBindEvents();
        sp.bInWorld=False;

        ot.Event='WaltonSimons';
        ot.Orders='Attacking';
        ot.SetCollision(False,False,False);

        break;
    }
}

function AfterMoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local #var(prefix)OrdersTrigger ot;
    local #var(prefix)ComputerPersonal cp;
    local DXRPasswords passwords;
    local #var(prefix)DataLinkTrigger dt;
    local #var(prefix)Switch1 button;
    local #var(DeusExPrefix)Mover door;

    if (g.name=="Jock and Tong") {
        foreach AllActors(class'#var(prefix)OrdersTrigger', ot, 'TongGO') {
            ot.Orders = 'Wandering';
            ot.ordersTag = '';
        }
    }
    else if (g.name=="Jock Escape") {
        if(Loc.name=="Cherry Picker") {
            g.actors[0].a.DrawScale = 0.5;
            g.actors[0].a.SetCollisionSize(200, 50);
        } else {
            g.actors[0].a.DrawScale = 1;
            g.actors[0].a.SetCollisionSize(320, 87);
        }
        Vehicles(g.actors[0].a).FamiliarName="Jock Escape";
        Vehicles(g.actors[0].a).UnFamiliarName="Jock Escape";
    }
    else if (g.name=="UC Computer") {
        if(g.actors[1].a != None)
            g.actors[1].a.SetCollisionSize(640, 64);

        passwords = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
        if(passwords != None && Loc.name != "UC") {
            passwords.ReplacePassword("on the computer at the UC,", "on the computer at the "$Loc.name$",");
        }
    }
    else if (g.name=="Email Computer") {
        cp = #var(prefix)ComputerPersonal(g.actors[0].a);
        cp.UserList[0].UserName="MBHaggerty";
        cp.UserList[0].Password="Kraken";
        cp.TextPackage = "#var(package)";
    }
    else if (g.name=="Backup Power Keypad") {
        GlowUp(g.actors[0].a, 255);
    }
    else if (g.name=="Launch Command Computer" && Loc.name != "Launch Command") {
        foreach AllActors(class'#var(prefix)DataLinkTrigger', dt) {
            if(dt.name=='DataLinkTrigger1' || dt.name=='DataLinkTrigger6') {
                dt.Destroy();
            }
        }
        foreach AllActors(class'#var(prefix)Switch1', button) {
            if(button.name=='Switch4') {
                button.Destroy();
                break;
            }
        }
    }

    if (g.name=="Launch Command Computer") {
        g.actors[1].a.Tag = 'klax'; // trigger the DataLinkTrigger immediately
        foreach AllActors(class'#var(DeusExPrefix)Mover', door, 'computerdoors') {
            door.MoverEncroachType = ME_IgnoreWhenEncroach;
        }
    }
}

function PreFirstEntryMapFixes()
{
    local #var(prefix)ScriptedPawn sp;
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    if (dxr.localURL == "12_VANDENBERG_CMD") {
        if (RevisionMaps) {
            foreach AllActors(class'#var(prefix)ScriptedPawn',sp,'Helicopter'){
                //Jock starts in the Wandering state for some reason
                sp.SetOrders('Standing');
            }
        }
        FailIfCorpseNotHeld("TerroristCommander");
    }
}
