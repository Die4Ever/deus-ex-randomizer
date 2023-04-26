class DXRMissionsM04 extends DXRMissions;


function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2;

    // GOAL_TYPE1 for the computer, 2 for Anna
    AddGoal("04_NYC_NSFHQ", "Computer", GOAL_TYPE1, 'ComputerPersonal3', PHYS_Falling);
    AddGoalLocation("04_NYC_NSFHQ", "Third Floor", GOAL_TYPE1, vect(-460.091187, 1011.083496, 551.367859), rot(0, 16672, 0));
    AddGoalLocation("04_NYC_NSFHQ", "Second Floor", GOAL_TYPE1, vect(206.654617, 1340.000000, 311.652832), rot(0, 0, 0));
    AddGoalLocation("04_NYC_NSFHQ", "Garage", GOAL_TYPE1, vect(381.117371, -696.875671, 63.615902), rot(0, 32768, 0));
    AddGoalLocation("04_NYC_NSFHQ", "Break Room", GOAL_TYPE1, vect(42.340145, 1104.667480, 73.610352), rot(0, 0, 0));
    AddGoalLocation("04_NYC_NSFHQ", "Basement Exit", GOAL_TYPE1, vect(1290.299927, 1385.000000, -185.000000), rot(0, 16384, 0));
    AddGoalLocation("04_NYC_NSFHQ", "Basement Entrance", GOAL_TYPE1, vect(-617.888855, 141.699875, -208.000000), rot(0, 16384, 0));
    AddGoalLocation("04_NYC_NSFHQ", "Rooftop", GOAL_TYPE1 | VANILLA_GOAL, vect(187.265259,315.583862,1032.054199), rot(0,16672,0));

    goal = AddGoal("04_NYC_BatteryPark", "Anna Navarre", GOAL_TYPE2, 'AnnaNavarre0', PHYS_Falling);
    AddGoalActor(goal, 1, 'AllianceTrigger11', PHYS_None); //AnnaAttacksJC
    AddGoalLocation("04_NYC_BatteryPark", "Battery Park Subway", GOAL_TYPE2 | VANILLA_GOAL, vect(-4981.514648,2416.581787,-304.599060), rot(0,-49328,0));
    AddGoalLocation("04_NYC_Street", "Street Barricade", GOAL_TYPE2, vect(-6353.232422,899.716797,-480.599030), rot(0,25000,0));
    AddGoalLocation("04_NYC_Street", "Hell's Kitchen Subway", GOAL_TYPE2, vect(1370.337646,-1819.429688,-464.602142), rot(0,32768,0));
    AddGoalLocation("04_NYC_Street", "Outside Free Clinic", GOAL_TYPE2, vect(-1500.715332,891.878662,-464.603424), rot(0,0,0));
    AddGoalLocation("04_NYC_Hotel", "Hotel", GOAL_TYPE2, vect(30.716736,-65.753799,-16.600384), rot(0,40000,0));
    return mission;
}

function CreateGoal(out Goal g, GoalLocation Loc)
{
    local #var(prefix)ScriptedPawn sp;
    local #var(prefix)AllianceTrigger at;
    local FlagBase f;

    f = dxr.flagbase;

    switch(g.name) {
    case "Anna Navarre":
        if (f.GetBool('AnnaNavarre_Dead')){
            l("Anna Navarre dead, not spawning");
            return;
        }
        sp = Spawn(class'#var(prefix)AnnaNavarre',, 'AnnaNavarre', Loc.positions[0].pos);
        g.actors[0].a = sp;
        sp.SetAlliance('UNATCO');
        sp.bInvincible = false;
        sp.SetOrders('WaitingFor');
        at = Spawn(class'#var(prefix)AllianceTrigger',, 'AnnaAttacksJC', Loc.positions[0].pos);
        at.Event = 'AnnaNavarre';
        at.Alliance = 'UNATCO';
        at.Alliances[0].AllianceName = 'Player';
        at.Alliances[0].AllianceLevel = -1;
        at.Alliances[0].bPermanent = true;
        at.Alliances[1].AllianceName = 'UNATCO';
        at.Alliances[1].AllianceLevel = 1;
        at.Alliances[1].bPermanent = true;
        at.SetCollision(False,False,False);
        g.actors[1].a = at;
        sp.ConBindEvents();
        if(!f.GetBool('NSFSignalSent'))
            sp.bInWorld = false;
        break;
    }
}
