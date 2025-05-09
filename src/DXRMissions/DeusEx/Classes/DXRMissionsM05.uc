class DXRMissionsM05 extends DXRMissions;


function int InitGoals(int mission, string map)
{
    local int goal, loc, pArm,pSurg,pPit,pRobot,  eArm,eSurg;

    switch(map) {
    case "05_NYC_UNATCOMJ12LAB":
        goal = AddGoal("05_NYC_UNATCOMJ12LAB", "Paul", NORMAL_GOAL, 'PaulDenton0', PHYS_Falling);
        AddGoalActor(goal, 1, 'PaulDentonCarcass0', PHYS_Falling);
        AddGoalActor(goal, 2, 'DataLinkTrigger6', PHYS_None);
        AddGoalActor(goal, 3, 'SecurityCamera0', PHYS_None);

        pArm = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Armory", NORMAL_GOAL, vect(-8548.773438, 1074.370850, -20.860909), rot(0, 0, 0));
        AddActorLocation(pArm, 3, vect(-8162.683594, 1194.161621, 276.902924), rot(-6000, 36000, 0));
        AddMapMarker(class'Image05_NYC_MJ12Lab',33,289,"P","Paul", pArm,"Paul can be located on the second floor of the armory.  If Paul is in this location, your equipment will be located in the surgery ward.");

        pSurg = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Surgery Ward", NORMAL_GOAL | VANILLA_GOAL, vect(2281.708008, -617.352478, -224.400238), rot(0,35984,0));
        AddActorLocation(pSurg, 1, vect(2177.405273, -552.487671, -200.899811), rot(0, 16944, 0));
        AddActorLocation(pSurg, 2, vect(2177.405273, -552.487671, -200.899811), rot(0, 16944, 0)); //DataLinkTrigger should be centered on his carcass rather than his living location
        AddActorLocation(pSurg, 3, vect(1891.301514, -289.854248, -64.997406), rot(-3000, 58200, 0));
        AddMapMarker(class'Image05_NYC_MJ12Lab',379,96,"P","Paul", pSurg,"Paul can be located in the surgery ward.  This is the vanilla location.  If Paul is in this location, your equipment will be located in the armory.");

        pPit = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Greasel Pit", NORMAL_GOAL, vect(456,3947,-604), rot(0, 8048, 0));
        AddActorLocation(pPit, 3, vect(745.180481, 4150.960449, -477.601196), rot(-3100, 39700, 0));
        AddMapMarker(class'Image05_NYC_MJ12Lab',325,226,"P","Paul", pPit,"Paul can be located in the greasel pit accessed through the vent on the back wall of the nanotech lab.  If Paul is in this location, your equipment will be located in the armory.");

        pRobot = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Robotics Bay Office", NORMAL_GOAL, vect(-4297,1083,210), rot(0, 16392, 0));
        AddActorLocation(pRobot, 3, vect(-4289.660645, 1397.180054, 307.937073), rot(-2000, -16384, 0));
        AddMapMarker(class'Image05_NYC_MJ12Lab',171,286,"P","Paul", pRobot,"Paul can be located in the office on the third floor of the robotics bay.  If Paul is in this location, your equipment will be located in the surgery ward.");

        //This is just the concept of the location of your equipment.  BalanceJailbreak in DXRFixup will actually place the items
        AddGoal("05_NYC_UNATCOMJ12LAB", "Equipment", GOAL_TYPE2, '', PHYS_None);

        eArm = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Armory", GOAL_TYPE2 | VANILLA_GOAL, vect(-8477.731445,1244.474854,-199.900879), rot(0, 0, 0));
        AddMapMarker(class'Image05_NYC_MJ12Lab',46,299,"E","Equipment", eArm,"Your equipment can be located in the armory.  This is the vanilla location.  If your equipment is in this location, Paul is in either the surgery ward or the greasel pit.");

        eSurg = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Surgery Ward", GOAL_TYPE2, vect(1670.443237,-702.527649,-179.660095), rot(0,0,0));
        AddMapMarker(class'Image05_NYC_MJ12Lab',362,95,"E","Equipment", eSurg,"Your equipment can be located in the surgery ward.  If your equipment is in this location, Paul is in either the armory or the robotics bay office.");

        AddMutualExclusion(eArm, pArm);
        AddMutualExclusion(eArm, pRobot);
        AddMutualExclusion(eSurg, pSurg);
        AddMutualExclusion(eSurg, pPit);

        AddGoal("05_NYC_UNATCOMJ12LAB", "Paul Security Monitor", GOAL_TYPE4, 'ComputerSecurity4', PHYS_None); //Making this a goal actor so it gets dignified, but it will always be in the original location
        loc = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Command Center", GOAL_TYPE4, vect(-1072.5594,20.1928,-101.3019), rot(0, 16312, 0));
        AddMapMarker(class'Image05_NYC_MJ12Lab',282,124,"C","Paul Security Monitor", loc,"The Paul Security Monitor is located in the Command Center. Use this computer to see where Paul is on the camera.");
        return 51;

    case "05_NYC_UNATCOHQ":
        AddGoal("05_NYC_UNATCOHQ", "Alex Jacobson", NORMAL_GOAL, 'AlexJacobson0', PHYS_Falling);
        AddGoal("05_NYC_UNATCOHQ", "Jaime Reyes", NORMAL_GOAL, 'JaimeReyes0', PHYS_Falling);

        AddGoalLocation("05_NYC_UNATCOHQ", "Jail", NORMAL_GOAL, vect(-2478.156738, -1123.645874, -16.399887), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Bathroom", NORMAL_GOAL, vect(110, 335, 40), rot(0, 32768, 0));
        if (IsAprilFools()){
            AddGoalLocation("05_NYC_UNATCOHQ", "Manderley's Bathroom", NORMAL_GOAL | SITTING_GOAL, vect(261.019775, -403.939575, 287.600586), rot(0, 0, 0));
        } else {
            AddGoalLocation("05_NYC_UNATCOHQ", "Manderley's Bathroom", NORMAL_GOAL, vect(261.019775, -403.939575, 287.600586), rot(0, 0, 0));
        }
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

function int InitGoalsRev(int mission, string map)
{
    local int goal, loc, pArm,pSurg,pPit,pRobot,  eArm,eSurg;

    switch(map) {
    case "05_NYC_UNATCOMJ12LAB":
        goal = AddGoal("05_NYC_UNATCOMJ12LAB", "Paul", NORMAL_GOAL, 'PaulDenton0', PHYS_Falling);
        AddGoalActor(goal, 1, 'PaulDentonCarcass0', PHYS_Falling);
        AddGoalActor(goal, 2, 'DataLinkTrigger6', PHYS_None);
        AddGoalActor(goal, 3, 'SecurityCamera0', PHYS_None);

        pArm = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Armory", NORMAL_GOAL, vect(-8548.773438, 1074.370850, -20.860909), rot(0, 0, 0));
        AddActorLocation(pArm, 3, vect(-8162.683594, 1194.161621, 276.902924), rot(-6000, 36000, 0));

        pSurg = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Surgery Ward", NORMAL_GOAL | VANILLA_GOAL, vect(2281.708008, -617.352478, -224.400238), rot(0,35984,0));
        AddActorLocation(pSurg, 1, vect(2177.405273, -552.487671, -200.899811), rot(0, 16944, 0));
        AddActorLocation(pSurg, 2, vect(2177.405273, -552.487671, -200.899811), rot(0, 16944, 0)); //DataLinkTrigger should be centered on his carcass rather than his living location
        AddActorLocation(pSurg, 3, vect(1891.301514, -289.854248, -64.997406), rot(-3000, 58200, 0));

        pPit = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Greasel Pit", NORMAL_GOAL, vect(456,3947,-604), rot(0, 8048, 0));
        AddActorLocation(pPit, 3, vect(745.180481, 4150.960449, -477.601196), rot(-3100, 39700, 0));

        pRobot = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Robotics Bay Office", NORMAL_GOAL, vect(-4297,1083,210), rot(0, 16392, 0));
        AddActorLocation(pRobot, 3, vect(-4289.660645, 1397.180054, 307.937073), rot(-2000, -16384, 0));

        //This is just the concept of the location of your equipment.  BalanceJailbreak in DXRFixup will actually place the items
        AddGoal("05_NYC_UNATCOMJ12LAB", "Equipment", GOAL_TYPE2, '', PHYS_None);
        eArm = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Armory", GOAL_TYPE2 | VANILLA_GOAL, vect(-8477.731445,1244.474854,-199.900879), rot(0, 0, 0));
        eSurg = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Surgery Ward", GOAL_TYPE2, vect(1670.443237,-702.527649,-179.660095), rot(0,0,0));

        AddMutualExclusion(eArm, pArm);
        AddMutualExclusion(eArm, pRobot);
        AddMutualExclusion(eSurg, pSurg);
        AddMutualExclusion(eSurg, pPit);

        AddGoal("05_NYC_UNATCOMJ12LAB", "Paul Security Monitor", GOAL_TYPE4, 'ComputerSecurity4', PHYS_None); //Making this a goal actor so it gets dignified, but it will always be in the original location
        loc = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Command Center", GOAL_TYPE4, vect(-1044.9645,529.963,46.6981), rot(0, 65520, 0));
        return 51;

    case "05_NYC_UNATCOHQ":
        AddGoal("05_NYC_UNATCOHQ", "Alex Jacobson", NORMAL_GOAL, 'AlexJacobson0', PHYS_Falling);
        AddGoal("05_NYC_UNATCOHQ", "Jaime Reyes", NORMAL_GOAL, 'JaimeReyes0', PHYS_Falling);

        AddGoalLocation("05_NYC_UNATCOHQ", "Jail", NORMAL_GOAL, vect(-2198,-971,-16), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Bathroom", NORMAL_GOAL, vect(110, 335, 40), rot(0, 32768, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Manderley's Bathroom", NORMAL_GOAL, vect(1156,-123,314), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Break Room", NORMAL_GOAL, vect(592,1411,428), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "West Office", NORMAL_GOAL, vect(-666.268066, -460.813965, 463.598083), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Computer Ops", NORMAL_GOAL | VANILLA_GOAL, vect(2001.611206,-801.088379,-16.225000), rot(0,23776,0));

        // could've left the actor name blank, but this will make them easier to find with legend
        AddGoal("05_NYC_UNATCOHQ", "Anna's Killphrase 1", GOAL_TYPE1, 'FlagTrigger0', PHYS_Falling);
        AddGoal("05_NYC_UNATCOHQ", "Anna's Killphrase 2", GOAL_TYPE1, 'FlagTrigger1', PHYS_Falling);

        AddGoalLocation("05_NYC_UNATCOHQ", "Manderley's Computer", GOAL_TYPE1 | VANILLA_GOAL, vect(1151.788208,145.233704,327.445404), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Anna's Computer", GOAL_TYPE1 | VANILLA_GOAL, vect(-640.761169,1259.560181,291.215088), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Gunther's Computer", GOAL_TYPE1 | VANILLA_GOAL, vect(-659.200012,754.311157,291.444000), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Sam's Computer", GOAL_TYPE1, vect(924.204590,-1000.484375,-9.348007), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Alex's Computer", GOAL_TYPE1, vect(2365.178711,-747.500488,-84.667282), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Jaime's Computer", GOAL_TYPE1, vect(1000.666504,1033.376709,-10.500046), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Janice's Computer", GOAL_TYPE1, vect(102.770264,395.777710,296.648743), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "JC's Computer", GOAL_TYPE1, vect(-190.257980,1295.428711,291.458160), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Jail Computer", GOAL_TYPE1, vect(-1179.331055,-1115.923462,-11.673233), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Conference Room Computer", GOAL_TYPE1, vect(32.709930,878.123413,291.501068), rot(0, 0, 0));

        return 52;

    }

    return mission+1000;
}

function AfterShuffleGoals(int goalsToLocations[32])
{
    local int g;
    local string dctext;
    local PaulDentonCarcass paulbody;
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    //Only do this on mission 5 UNATCO HQ
    if (dxr.localURL == "05_NYC_UNATCOHQ"){
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

        if (RevisionMaps){
            SpawnDatacubePlaintext(vectm(1130.502441,195.451401,321.369446), rotm(0,0,0,0), dctext, "ManderleyKillphraseHint", true);
        } else {
            SpawnDatacubePlaintext(vectm(243.288742, -104.183029, 289.368256), rotm(0,0,0,0), dctext, "ManderleyKillphraseHint", true);
        }

    } else if (dxr.localURL == "05_NYC_UNATCOMJ12LAB" && #defined(revision)){
        //For some reason shuffling Paul's body stops it from being destroyed by the mission script
        if (!player().flagbase.GetBool('PaulDenton_Dead')){
            foreach AllActors(class'PaulDentonCarcass',paulbody){
                paulbody.Destroy();
            }
        }
    }
}

function PreFirstEntryMapFixes()
{
    local #var(prefix)ComputerPersonal cp;
    local #var(prefix)ComputerSecurity cs;
    local #var(prefix)DataLinkTrigger  dlt;
    local int i, compRotOffset;
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());
    compRotOffset = GetRotationOffset(class'#var(prefix)ComputerPersonal');

    if( dxr.localURL ~= "05_NYC_UNATCOHQ" ) {
        // jail computer
        if (!RevisionMaps){
            cp = Spawn(class'#var(prefix)ComputerPersonal',, 'DXRMissions', vectm(-1491.076782, -1207.629028, -2.499634), rotm(0, 25000, 0, compRotOffset));
            cp.UserList[0].userName = "KLloyd";
            cp.UserList[0].Password = "squishy";
        }

        // conference room computer
        if (RevisionMaps){
            cp = Spawn(class'#var(prefix)ComputerPersonal',, 'DXRMissions', vectm(32.709930,878.123413,291.501068), rotm(0,0,0, compRotOffset));
        } else {
            cp = Spawn(class'#var(prefix)ComputerPersonal',, 'DXRMissions', vectm(79.009933, 863.868042, 296.502075), rotm(0,0,0, compRotOffset));
        }
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
    if( dxr.localURL ~= "05_NYC_UNATCOMJ12Lab") {
        foreach AllActors(class'#var(prefix)ComputerSecurity', cs) {
            if(cs.name != 'ComputerSecurity4') continue;
            for(i=0; i<ArrayCount(cs.Views); i++) {
                if(cs.Views[i].CameraTag == 'medcam') {
                    cs.Views[i].titleString = "Paul Denton";
                }
            }
        }

        foreach AllActors(class'#var(prefix)DataLinkTrigger', dlt) {
            if (dlt.Name=='DataLinkTrigger6'){
                dlt.SetCollisionSize(200,100);
                break;
            }
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

    if(dxr.flagbase.GetBool('PaulDenton_Dead'))
        AddGoalFromConv(player(), 'FindPaul', 'DL_Choice', 1);
    else
        AddGoalFromConv(player(), 'FindPaul', 'DL_Choice');
    AddGoalFromConv(player(), 'FindEquipment', 'DL_Choice');

    GiveImage(player(), class'Image05_NYC_MJ12Lab');
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
        DignifyGoalActor(g, cp,class'MenuChoice_GoalTextures'.static.IsEnabled(self)); //Should the killphrase computers actually be visually distinct?
    }
    else if (g.name=="Paul" && Loc.name!="Surgery Ward") {
        passwords = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
        if(passwords != None) {// 05_Datacube03.txt
            passwords.ReplacePassword("the patient has been moved to the Surgery Ward", "the patient has been moved to the "$Loc.name);
        }
    }
}

function AnyEntry()
{
    Super.AnyEntry();

    switch(dxr.localURL) {
    case "05_NYC_UNATCOMJ12LAB":
        UpdateGoalWithRandoInfo('FindPaul', "Paul could be located anywhere in the lab.  A security computer in the command center will be connected to a camera monitoring him.");
        UpdateGoalWithRandoInfo('FindEquipment', "Your equipment could be in either the armory or the surgery bay.");
        break;
    }
}
