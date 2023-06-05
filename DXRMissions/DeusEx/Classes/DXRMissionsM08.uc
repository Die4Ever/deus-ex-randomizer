class DXRMissionsM08 extends DXRMissions;


function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2;

    AddGoal("08_NYC_Bar", "Harley Filben", NORMAL_GOAL, 'HarleyFilben0', PHYS_Falling);
    goal = AddGoal("08_NYC_Bar", "Vinny", NORMAL_GOAL, 'NathanMadison0', PHYS_Falling);
    //AddGoalActor(goal, 1, 'SandraRenton0', PHYS_Falling); TODO: move Sandra with Vinny?
    //AddGoalActor(goal, 2, 'CoffeeTable0', PHYS_Falling);
    AddGoal("08_NYC_FreeClinic", "Joe Greene", NORMAL_GOAL, 'JoeGreene0', PHYS_Falling);

    AddGoalLocation("08_NYC_Street", "Hotel Roof", START_LOCATION | VANILLA_START | NORMAL_GOAL, vect(-354.250427, 795.071594, 594.411743), rot(0, -18600, 0));
    AddGoalLocation("08_NYC_Bar", "Bar Table", NORMAL_GOAL | VANILLA_GOAL | SITTING_GOAL, vect(-1689.125122, 337.159912, 63.599533), rot(0,-10144,0));
    AddGoalLocation("08_NYC_Bar", "Bar", NORMAL_GOAL | VANILLA_GOAL, vect(-931.038086, -488.537109, 47.600464), rot(0,9536,0));
    AddGoalLocation("08_NYC_FreeClinic", "Clinic", NORMAL_GOAL | VANILLA_GOAL, vect(904.356262, -1229.045166, -272.399506), rot(0,31640,0));
    AddGoalLocation("08_NYC_Underground", "Sewers", NORMAL_GOAL, vect(591.048462, -152.517639, -560.397888), rot(0,32768,0));
    AddGoalLocation("08_NYC_Hotel", "Hotel", NORMAL_GOAL | SITTING_GOAL, vect(-108.541245, -2709.490479, 111.600838), rot(0,20000,0));
    AddGoalLocation("08_NYC_Street", "Basketball Court", NORMAL_GOAL | START_LOCATION, vect(2694.934082, -2792.844971, -448.396637), rot(0,32768,0));
    return 81;
}

function CreateGoal(out Goal g, GoalLocation Loc)
{
    local #var(prefix)ScriptedPawn sp;

    switch(g.name) {
    case "Harley Filben":
        sp = #var(prefix)ScriptedPawn(Spawnm(class'#var(prefix)HarleyFilben',, 'DXRMissions', Loc.positions[0].pos));
        g.actors[0].a = sp;
        sp.UnfamiliarName = "Harley Filben";
        sp.bInvincible = true;
        sp.bImportant = true;
        sp.SetOrders('Standing');
        RemoveReactions(sp);
        break;

    case "Vinny":
        sp = #var(prefix)ScriptedPawn(Spawnm(class'#var(prefix)NathanMadison',, 'DXRMissions', Loc.positions[0].pos));
        g.actors[0].a = sp;
        sp.BindName = "Sailor";
        sp.FamiliarName = "Vinny";
        sp.UnfamiliarName = "Soldier";
        sp.SetOrders('Standing');
        sp.ConBindEvents();
        RemoveReactions(sp);
        break;

    case "Joe Greene":
        sp = #var(prefix)ScriptedPawn(Spawnm(class'#var(prefix)JoeGreene',, 'DXRMissions', Loc.positions[0].pos));
        g.actors[0].a = sp;
        sp.BarkBindName = "Male";
        sp.SetOrders('Standing');
        sp.ConBindEvents();
        break;
    }
}

function MissionTimer()
{
    switch(dxr.localURL)
    {
    case "08_NYC_STREET":
        if(dxr.flags.settings.goals > 0)
            UpdateGoalWithRandoInfo('FindHarleyFilben', "Harley could be anywhere in Hell's Kitchen");
        break;
    }

    if(dxr.flags.settings.goals > 0)
        UpdateGoalWithRandoInfo('KillGreene', "Joe Greene could be anywhere.");
}
