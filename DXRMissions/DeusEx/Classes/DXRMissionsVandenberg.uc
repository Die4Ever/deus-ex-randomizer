class DXRMissionsVandenberg extends DXRMissions;

var bool WaltonAppeared;

function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2;

    switch(map) {
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

function MissionTimer()
{
    local #var(prefix)WaltonSimons Walton;
    local FlagBase f;

    f = dxr.flagbase;

    switch(dxr.localURL) {
    case "14_VANDENBERG_SUB":
    case "14_OCEANLAB_UC":
        if (!WaltonAppeared && f.GetBool('DL_downloaded_Played'))
        {
            foreach AllActors(class'#var(prefix)WaltonSimons', Walton){
                Walton.EnterWorld();
            }
            WaltonAppeared=True;

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
        sp = Spawn(class'#var(prefix)WaltonSimons',, 'DXRMissions', Loc.positions[0].pos);
        ot = Spawn(class'OrdersTrigger',,'simonsattacks',Loc.positions[0].pos);
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
    local #var(prefix)ComputerPersonal cp;
    local DXRPasswords passwords;

    if (g.name=="Jock Escape") {
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
