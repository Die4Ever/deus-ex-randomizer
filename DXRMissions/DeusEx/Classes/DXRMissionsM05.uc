class DXRMissionsM05 extends DXRMissions;


function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2;

    switch(map) {
    case "05_NYC_UNATCOMJ12LAB":
        goal = AddGoal("05_NYC_UNATCOMJ12LAB", "Paul", NORMAL_GOAL, 'PaulDenton0', PHYS_Falling);
        AddGoalActor(goal, 1, 'PaulDentonCarcass0', PHYS_Falling);
        AddGoalActor(goal, 2, 'DataLinkTrigger6', PHYS_None);

        AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Armory", NORMAL_GOAL, vect(-8548.773438, 1074.370850, -20.860909), rot(0, 0, 0));
        loc = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Surgery Ward", NORMAL_GOAL | VANILLA_GOAL, vect(2281.708008, -617.352478, -224.400238), rot(0,35984,0));
        AddActorLocation(loc, 1, vect(2177.405273, -552.487671, -200.899811), rot(0, 16944, 0));
        AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Greasel Pit", NORMAL_GOAL, vect(375,3860,-604), rot(0, 8048, 0));
        AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Robotics Bay Office", NORMAL_GOAL, vect(-4297,1083,210), rot(0, 16392, 0));

        return 51;

    case "05_NYC_UNATCOHQ":
        AddGoal("05_NYC_UNATCOHQ", "Alex Jacobson", NORMAL_GOAL, 'AlexJacobson0', PHYS_Falling);
        AddGoal("05_NYC_UNATCOHQ", "Jaime Reyes", NORMAL_GOAL, 'JaimeReyes0', PHYS_Falling);

        AddGoalLocation("05_NYC_UNATCOHQ", "Jail", NORMAL_GOAL, vect(-2478.156738, -1123.645874, -16.399887), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Bathroom", NORMAL_GOAL, vect(121.921074, 287.711243, 39.599487), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Manderley's Bathroom", NORMAL_GOAL, vect(261.019775, -403.939575, 287.600586), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Break Room", NORMAL_GOAL, vect(718.820068, 1411.137451, 287.598999), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "West Office", NORMAL_GOAL, vect(-666.268066, -460.813965, 463.598083), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Computer Ops", NORMAL_GOAL | VANILLA_GOAL, vect(2001.611206,-801.088379,-16.225000), rot(0,23776,0));

        // could've left the actor name blank, but this will make them easier to find with legend
        AddGoal("05_NYC_UNATCOHQ", "Anna's Killphrase 1", GOAL_TYPE1, 'FlagTrigger0', PHYS_Falling);
        AddGoal("05_NYC_UNATCOHQ", "Anna's Killphrase 2", GOAL_TYPE1, 'FlagTrigger1', PHYS_Falling);

        AddGoalLocation("05_NYC_UNATCOHQ", "Manderley's Computer", GOAL_TYPE1 | VANILLA_GOAL, vect(285.293274, -97.416443, 306.213837), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Gunther's Computer", GOAL_TYPE1 | VANILLA_GOAL, vect(-361.564636, -1105.282837, 0.215084), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Sam's Computer", GOAL_TYPE1, vect(923.469177, -819.359863, 9.367111), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Alex's Computer", GOAL_TYPE1, vect(1058.635620, -629.008118, -10.500217), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Jaime's Computer", GOAL_TYPE1, vect(988.246399, 1035.369507, 0.215073), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Janice's Computer", GOAL_TYPE1, vect(118.116867, 399.636597, 307.363861), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "JC's Computer", GOAL_TYPE1, vect(-189.312790, 1268.172729, 314.458160), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Jail Computer", GOAL_TYPE1, vect(-1491.076782, -1207.629028, -2.499634), rot(0, 25000, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Conference Room Computer", GOAL_TYPE1, vect(79.009933, 863.868042, 296.502075), rot(0, 0, 0));
        return 52;
    }

    return mission+1000;
}

function AfterShuffleGoals(int goalsToLocations[32])
{
    local int g;
    local string dctext;

    //Only do this on mission 5 UNATCO HQ
    if (dxr.localURL != "05_NYC_UNATCOHQ"){
        return;
    }

    // put a datacube on Manderley's desk, this is for 2 different goals at once so it can't be done in MoveGoalToLocation
    dctext = "I've hidden Anna's killphrase like you asked.";

    for(g=0; g<num_goals; g++) {
        if(goals[g].name == "Anna's Killphrase 1") {
            dctext = dctext $ "|n|nPart 1 is on "$ locations[goalsToLocations[g]].name;
            break;
        }
    }
    for(g=0; g<num_goals; g++) {
        if(goals[g].name == "Anna's Killphrase 2") {
            dctext = dctext $ "|nPart 2 is on "$ locations[goalsToLocations[g]].name;
            break;
        }
    }

    dctext = dctext $ "|n|nBoth using the DEMIURGE username. JC will never find them!";

    SpawnDatacube(vect(243.288742, -104.183029, 289.368256), rot(0,0,0), dctext, true);
}

function PreFirstEntryMapFixes()
{
    local #var(prefix)ComputerPersonal cp;

    if( dxr.localURL ~= "05_NYC_UNATCOHQ" ) {
        // jail computer
        cp = Spawn(class'#var(prefix)ComputerPersonal',, 'DXRMissions', vect(-1491.076782, -1207.629028, -2.499634), rot(0, 25000, 0));
        cp.UserList[0].userName = "KLloyd";
        cp.UserList[0].Password = "squishy";

        // conference room computer
        cp = Spawn(class'#var(prefix)ComputerPersonal',, 'DXRMissions', vect(79.009933, 863.868042, 296.502075), rot(0,0,0));
        cp.UserList[0].userName = "KLloyd";
        cp.UserList[0].Password = "squishy";

        foreach AllActors(class'#var(prefix)ComputerPersonal', cp) {
            // remove demiurge, and also user and guest because they're useless anyways
            RemoveComputerUser(cp, "demiurge");
            RemoveComputerUser(cp, "USER");
            RemoveComputerUser(cp, "GUEST");
            RemoveComputerSpecialOption(cp, 'know1');
            RemoveComputerSpecialOption(cp, 'know2');
            // keep the button for Gunther's killphrase on Manderley's computer
            if(cp.specialOptions[0].userName ~= "demiurge")
                cp.specialOptions[0].userName = "";
        }
    }
}

function AddMissionGoals()
{
    local #var(prefix)DataLinkTrigger dlt;
    local Inventory item;
    local DeusExGoal newGoal;

    if(dxr.localURL != "05_NYC_UNATCOMJ12LAB") return;

    foreach AllActors(class'#var(prefix)DataLinkTrigger', dlt) {
        if(dlt.datalinkTag == 'DL_Choice') {
            dlt.Event='';
            dlt.Destroy();
        }
    }
    newGoal=player().AddGoal('FindPaul', true);
    if(dxr.flagbase.GetBool('PaulDenton_Dead'))
        newGoal.SetText("Get the datavault from your brother's body.  Tracer Tong will need it to defeat the killswitch.");
    else
        newGoal.SetText("Find your brother and access information in his datavault that Tracer Tong will need to defeat the killswitch.");

    newGoal=player().AddGoal('FindEquipment', false);
    l("added goal "$newGoal);
    newGoal.SetText("Find the equipment taken from you when you were captured by UNATCO.");

    item = Spawn(class'Image05_NYC_MJ12Lab');
    item.Frob(player(), None);
}

function AfterMoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local int i;
    local #var(prefix)ComputerPersonal cp;
    local DXRPasswords passwords;

    if (g.name=="Anna's Killphrase 1" || g.name=="Anna's Killphrase 2") {
        // insert the demiurge/archon account and add the special options
        cp = #var(prefix)ComputerPersonal(findNearestToActor(class'#var(prefix)ComputerPersonal', g.actors[0].a));

        AddComputerUserAt(cp, "DEMIURGE", "archon", 0);

        for(i=0; i<ArrayCount(cp.specialOptions); i++) {
            if(cp.specialOptions[i].TriggerEvent != '')
                continue;
            if (g.name=="Anna's Killphrase 1") {
                cp.specialOptions[i].TriggerEvent = 'know1';
                cp.specialOptions[i].TriggerText = "Killphrase Part 1 of 2 Decrypted : 'Flatlander'";
            } else {
                cp.specialOptions[i].TriggerEvent = 'know2';
                cp.specialOptions[i].TriggerText = "Killphrase Part 2 of 2 Decrypted : 'Woman'";
            }
            cp.specialOptions[i].Text = "Decrypt Agent ANavarre Killphrase";
            cp.specialOptions[i].bTriggerOnceOnly = true;
            cp.specialOptions[i].userName = "DEMIURGE";
            break;
        }
    }
    else if (g.name=="Paul" && Loc.name!="Surgery Ward") {
        passwords = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
        if(passwords != None) {// 05_Datacube03.txt
            passwords.ReplacePassword("the patient has been moved to the Surgery Ward", "the patient has been moved to the "$Loc.name);
        }
    }
}
