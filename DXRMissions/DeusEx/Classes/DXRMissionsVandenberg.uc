class DXRMissionsVandenberg extends DXRMissions;

var bool WaltonAppeared;

function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2;

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

        AddGoalLocation("12_VANDENBERG_CMD", "Front Gate", START_LOCATION, vect(6750.350586, 7763.461426, -3092.699951), rot(0, 0, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "Outdoor Power Generator", NORMAL_GOAL | VANILLA_GOAL, vect(-2371.028564,-96.179214,-2070.390625), rot(0,-32768,0));
        AddGoalLocation("12_VANDENBERG_CMD", "Command Center Power Generator", NORMAL_GOAL | VANILLA_GOAL, vect(1628.947754,1319.745483,-2014.406982), rot(0,-65536,0));

        // complicated because of DXRBacktracking::VandCmdAnyEntry() to reuse the chopper
        goal = AddGoal("12_VANDENBERG_CMD", "Jock and Tong", GOAL_TYPE1, 'BlackHelicopter0', PHYS_None);
        AddGoalActor(goal, 1, 'TracerTong0', PHYS_Falling);

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Street Entrance", GOAL_TYPE1 | VANILLA_GOAL, vect(7014.185059, 7540.296875, -2984.704102), rot(0,-19840,0));
        AddActorLocation(loc, 1, vect(6436.471680, 7621.873535, -3061.458740), rot(0,-27976,0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Courtyard", GOAL_TYPE1, vect(-371.047180, 5046.039063, -2050.704102), rot(0,-19840,0));
        AddActorLocation(loc, 1, vect(-659.219116, 5350.891113, -2142.458740), rot(0,-27976,0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Comm 01 Roof", GOAL_TYPE1, vect(-1880.047119, 5382.039063, -1831.704102), rot(0,0,0));
        AddActorLocation(loc, 1, vect(-1553.219116, 5030.891113, -1876.458740), rot(0,-14000,0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Command Roof", GOAL_TYPE1, vect(-2209.047119, 2820.039063, -1410.704102), rot(0,-10000,0));
        AddActorLocation(loc, 1, vect(-1617.219116, 2778.891113, -1471.458740), rot(0,-10000,0));

        //loc = AddGoalLocation("12_VANDENBERG_CMD", "Command Hall", GOAL_TYPE1, vect(1799.313965, 1914.730225, -1934.704102), rot(0,32768,0));
        //AddActorLocation(loc, 1, vect(1412.059204, 1802.125000, -2023.458740), rot(0,-30000,0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Sniper Tower", GOAL_TYPE1, vect(-946.215820, 80.315643, -1359.704102), rot(0,32768,0));
        AddActorLocation(loc, 1, vect(-1033.543579, 265.367859, -1569.458740), rot(0,-30000,0));

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
        AddGoalLocation("14_OCEANLAB_UC", "UC Entry 2", GOAL_TYPE1, vect(945,5250,-4160), rot(0,0,0));

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
        AddGoal("14_OCEANLAB_SILO", "Howard Strong", NORMAL_GOAL, 'HowardStrong0', PHYS_Falling);

        AddGoalLocation("14_OCEANLAB_SILO", "Third Floor", NORMAL_GOAL, vect(-220.000000, -6829.463379, 55.600639), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Fourth Floor", NORMAL_GOAL, vect(-259.846710, -6848.406250, 326.598969), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Fifth Floor", NORMAL_GOAL, vect(-271.341187, -6832.150391, 535.596741), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Sixth Floor", NORMAL_GOAL, vect(-266.569397, -6868.054199, 775.592590), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Cherry Picker", NORMAL_GOAL | VANILLA_GOAL, vect(-52.397560,-6767.679199,-320.225006), rot(0,-7512,0));

        AddGoal("14_OCEANLAB_SILO", "Jock Escape", GOAL_TYPE1, 'BlackHelicopter0', PHYS_None);
        AddGoalLocation("14_OCEANLAB_SILO", "Vanilla Escape", GOAL_TYPE1 | VANILLA_GOAL, vect(-194.602554, -5680.964355, 1507.895020), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Sniper Tower", GOAL_TYPE1, vect(-842.344604, -3827.978027, 2039.993286), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Cherry Picker", GOAL_TYPE1, vect(-13.000000, -6790.000000, -542.000000), rot(0, 32768, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Computer Room", GOAL_TYPE1, vect(-100.721497, -1331.947754, 904.364380), rot(0, 32768, 0));
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
        if(dxr.flags.settings.goals > 0)
            UpdateGoalWithRandoInfo('FindJock', "Jock could be anywhere around the Command Center.");
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
        if(dxr.flags.settings.goals > 0)
            UpdateGoalWithRandoInfo('MeetJock', "Jock could be anywhere around the silo.");
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
}
