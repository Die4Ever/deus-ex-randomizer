class DXRMissionsM06 extends DXRMissions;

var bool M08Briefing;


function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2;

    switch(map) {
    case "06_HONGKONG_VERSALIFE":
        AddGoal("06_HONGKONG_VERSALIFE", "Gary Burkett", NORMAL_GOAL | SITTING_GOAL, 'Male2', PHYS_Falling);
        AddGoal("06_HONGKONG_VERSALIFE", "Data Entry Worker", NORMAL_GOAL | SITTING_GOAL, 'Male0', PHYS_Falling);
        AddGoal("06_HONGKONG_VERSALIFE", "John Smith", NORMAL_GOAL | SITTING_GOAL, 'Male9', PHYS_Falling);
        AddGoal("06_HONGKONG_VERSALIFE", "Mr. Hundley", NORMAL_GOAL, 'Businessman0', PHYS_Falling);
        AddGoalLocation("06_HONGKONG_VERSALIFE", "2nd Floor Break room", NORMAL_GOAL | VANILLA_GOAL, vect(-952.069763, 246.924271, 207.600281), rot(0, -25708, 0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "3rd Floor Break room", NORMAL_GOAL | VANILLA_GOAL, vect(-971.477234, 352.951782, 463.600586), rot(0,0,0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "3rd Floor Cubicle", SITTING_GOAL | VANILLA_GOAL, vect(209.333740, 1395.673584, 466.101288), rot(0,18572,0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "3rd Floor Corner", NORMAL_GOAL | VANILLA_GOAL, vect(-68.717262, 2165.082031, 465.039124), rot(0,15816,0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "1st Floor Cubicle", SITTING_GOAL, vect(13.584339, 1903.127441, -48.399910), rot(0, 16384, 0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "1st Floor Water Cooler", NORMAL_GOAL, vect(846.994751, 1754.889526, -48.398872), rot(0, 30000, 0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "2nd Floor Cubicle", SITTING_GOAL, vect(16.111176, 1888.993774, 207.596893), rot(0,16384,0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "2nd Floor Water Cooler", NORMAL_GOAL, vect(858.500061, 1747.315918, 207.601013), rot(0, 30000, 0));
        return 61;

    case "06_HONGKONG_MJ12LAB":
        goal = AddGoal("06_HONGKONG_MJ12LAB", "Nanotech Blade ROM", NORMAL_GOAL, 'ComputerPersonal0', PHYS_Falling);
        AddGoalActor(goal, 1, 'DataLinkTrigger0', PHYS_None);// DL_Tong_07: I have uploaded the component the Triads need to complete the sword.
        AddGoalActor(goal, 2, 'DataLinkTrigger3', PHYS_None);// DL_Tong_07 but with Tag TongHasTheROM
        AddGoalActor(goal, 3, 'DataLinkTrigger8', PHYS_None);// DL_Tong_08: The ROM-encoding should be in this wing of the laboratory.
        AddGoalActor(goal, 4, 'FlagTrigger0', PHYS_None);
        AddGoalActor(goal, 5, 'FlagTrigger1', PHYS_None);
        AddGoalActor(goal, 6, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 7, 'SkillAwardTrigger10', PHYS_None);

        /*AddGoalActor(goal, 1, 'DataLinkTrigger4', PHYS_None);// DL_Tong_07
        AddGoalActor(goal, 1, 'DataLinkTrigger5', PHYS_None);// DL_Tong_07
        AddGoalActor(goal, 1, 'DataLinkTrigger6', PHYS_None);// DL_Tong_07*/

        AddGoal("06_HONGKONG_MJ12LAB", "Radiation Controls", NORMAL_GOAL, 'ComputerPersonal1', PHYS_Falling);
        AddGoalLocation("06_HONGKONG_MJ12LAB", "Barracks", NORMAL_GOAL, vect(-140.163544, 1705.130127, -583.495483), rot(0, 0, 0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "Radioactive Chamber", NORMAL_GOAL, vect(-1273.699951, 803.588745, -792.499512), rot(0, 16384, 0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "Lab", NORMAL_GOAL, vect(-1712.699951, -809.700012, -744.500610), rot(0, 16384, 0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "ROM Encoding Room", NORMAL_GOAL | VANILLA_GOAL, vect(-0.995101,-260.668579,-311.088989), rot(0,32824,0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "Radioactive Lab", NORMAL_GOAL | VANILLA_GOAL, vect(-723.018677,591.498901,-743.972717), rot(0,49160,0));
        loc = AddGoalLocation("06_HONGKONG_MJ12LAB", "Overlook Office", NORMAL_GOAL, vect(3, 886, 820), rot(0, 32768, 0));
        AddActorLocation(loc, 1, vect(3, 886, 789.101990), rot(0,0,0));// MAHOGANY desk
        return 62;

    case "06_HONGKONG_WANCHAI_STREET":
    case "06_HONGKONG_WANCHAI_CANAL":
    case "06_HONGKONG_WANCHAI_MARKET":
    case "06_HONGKONG_WANCHAI_UNDERWORLD":
        goal = AddGoal("06_HONGKONG_WANCHAI_STREET", "Dragon's Tooth Sword", NORMAL_GOAL, 'WeaponNanoSword0', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger0', PHYS_None);// DL_Tong_00: Now bring the sword to Max Chen at the Lucky Money Club

        AddGoalLocation("06_HONGKONG_WANCHAI_STREET", "Sword Case", NORMAL_GOAL | VANILLA_GOAL, vect(-1857.841064, -158.911865, 2051.345459), rot(0, 0, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_STREET", "in Maggie's shower", NORMAL_GOAL, vect(-1294.841064, -1861.911865, 2190.345459), rot(0, 0, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_STREET", "on Jock's bed", NORMAL_GOAL, vect(342.584808, -1802.576172, 1713.509521), rot(0, 0, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_STREET", "in the sniper nest", NORMAL_GOAL, vect(204.923828, -195.652588, 1795), rot(0, 40000, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_CANAL", "in the hold of the boat", NORMAL_GOAL, vect(2293, 2728, -598), rot(0, 10808, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_CANAL", "with the boatperson", NORMAL_GOAL, vect(1775, 2065, -317), rot(0, 0, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_CANAL", "in the Old China Hand kitchen", NORMAL_GOAL, vect(-1623, 3164, -393), rot(0, -49592, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD", "in the Lucky Money freezer", NORMAL_GOAL, vect(-1780, -2750, -333), rot(0, 27104, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_MARKET", "in the police vault", NORMAL_GOAL, vect(-480, -720, -107), rot(0, -5564, 0));

        goal = AddGoal("06_HONGKONG_WANCHAI_UNDERWORLD","Max Chen",GOAL_TYPE1,'MaxChen0',PHYS_FALLING);
        AddGoalActor(goal, 1, 'TriadRedArrow5', PHYS_Falling); //Maybe I should actually find these guys by bindname?  They're "RightHandMan"
        AddGoalActor(goal, 2, 'TriadRedArrow6', PHYS_Falling);

        loc=AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD","Office",GOAL_TYPE1 | SITTING_GOAL | VANILLA_GOAL,vect(426.022644,-2469.105957,-336.399414),rot(0,0,0));
        AddActorLocation(loc, 1, vect(488.291809, -2581.964355, -336.402618), rot(0,32620,0));
        AddActorLocation(loc, 2, vect(484.913330,-2345.247559,-336.401306), rot(0,32620,0));

        if (IsAprilFools()){
            loc=AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD","Bathroom",GOAL_TYPE1 | SITTING_GOAL,vect(-1561,-671,-339),rot(0,16368,0));
        } else {
            loc=AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD","Bathroom",GOAL_TYPE1,vect(-1725.911133,-565.364746,-339),rot(0,16368,0));
        }
        AddActorLocation(loc, 1, vect(-1794.911133,-572.364746,-339), rot(0,16368,0));
        AddActorLocation(loc, 2, vect(-1658.911133,-568.364746,-339), rot(0,16368,0));

        loc=AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD","Bar",GOAL_TYPE1,vect(-772,-2220,-144),rot(0,-16352,0));
        AddActorLocation(loc, 1, vect(-755,-2326,-136), rot(0,16508,0));
        AddActorLocation(loc, 2, vect(-617,-2280,-136), rot(0,32620,0));

        loc=AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD","Sailors",GOAL_TYPE1,vect(-1392,-2539,18),rot(0,-6414,0));
        AddActorLocation(loc, 1, vect(-1161,-2550,21), rot(0,39348,0));
        AddActorLocation(loc, 2, vect(-1204,-2758,21), rot(0,23892,0));

        return 63;
    }

    return mission+1000;
}

function int InitGoalsRev(int mission, string map)
{
    local int goal, loc, loc2;

    switch(map) {
    case "06_HONGKONG_VERSALIFE":
        AddGoal("06_HONGKONG_VERSALIFE", "Gary Burkett", NORMAL_GOAL | SITTING_GOAL, 'Male2', PHYS_Falling);
        AddGoal("06_HONGKONG_VERSALIFE", "Data Entry Worker", NORMAL_GOAL | SITTING_GOAL, 'Male0', PHYS_Falling);
        AddGoal("06_HONGKONG_VERSALIFE", "John Smith", NORMAL_GOAL | SITTING_GOAL, 'Male9', PHYS_Falling);
        AddGoal("06_HONGKONG_VERSALIFE", "Mr. Hundley", NORMAL_GOAL, 'Businessman0', PHYS_Falling);
        AddGoalLocation("06_HONGKONG_VERSALIFE", "2nd Floor Break room", NORMAL_GOAL | VANILLA_GOAL, vect(-952.069763, 246.924271, 207.600281), rot(0, -25708, 0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "3rd Floor Break room", NORMAL_GOAL | VANILLA_GOAL, vect(-971.477234, 352.951782, 463.600586), rot(0,0,0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "3rd Floor Cubicle", SITTING_GOAL | VANILLA_GOAL, vect(209.333740, 1395.673584, 466.101288), rot(0,18572,0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "3rd Floor Corner", NORMAL_GOAL | VANILLA_GOAL, vect(-68.717262, 2165.082031, 465.039124), rot(0,15816,0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "1st Floor Cubicle", SITTING_GOAL, vect(13.584339, 1903.127441, -48.399910), rot(0, 16384, 0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "1st Floor Water Cooler", NORMAL_GOAL, vect(846.994751, 1754.889526, -48.398872), rot(0, 30000, 0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "2nd Floor Cubicle", SITTING_GOAL, vect(16.111176, 1888.993774, 207.596893), rot(0,16384,0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "2nd Floor Water Cooler", NORMAL_GOAL, vect(858.500061, 1747.315918, 207.601013), rot(0, 30000, 0));
        return 61;

    case "06_HONGKONG_MJ12LAB":
        goal = AddGoal("06_HONGKONG_MJ12LAB", "Nanotech Blade ROM", NORMAL_GOAL, 'ComputerPersonal0', PHYS_Falling);
        AddGoalActor(goal, 1, 'DataLinkTrigger0', PHYS_None);// DL_Tong_07: I have uploaded the component the Triads need to complete the sword.
        AddGoalActor(goal, 2, 'DataLinkTrigger3', PHYS_None);// DL_Tong_07 but with Tag TongHasTheROM
        AddGoalActor(goal, 3, 'DataLinkTrigger8', PHYS_None);// DL_Tong_08: The ROM-encoding should be in this wing of the laboratory.
        AddGoalActor(goal, 4, 'FlagTrigger0', PHYS_None);
        AddGoalActor(goal, 5, 'FlagTrigger1', PHYS_None);
        AddGoalActor(goal, 6, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 7, 'SkillAwardTrigger10', PHYS_None);

        //AddGoalActor(goal, 1, 'DataLinkTrigger4', PHYS_None);// DL_Tong_07
        //AddGoalActor(goal, 1, 'DataLinkTrigger5', PHYS_None);// DL_Tong_07
        //AddGoalActor(goal, 1, 'DataLinkTrigger6', PHYS_None);// DL_Tong_07

        AddGoal("06_HONGKONG_MJ12LAB", "Radiation Controls", NORMAL_GOAL, 'ComputerPersonal1', PHYS_Falling);
        AddGoalLocation("06_HONGKONG_MJ12LAB", "Barracks", NORMAL_GOAL, vect(-140.163544, 1705.130127, -583.495483), rot(0, 0, 0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "Radioactive Chamber", NORMAL_GOAL, vect(-1273.699951, 803.588745, -792.499512), rot(0, 16384, 0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "Lab", NORMAL_GOAL, vect(-1712.699951, -809.700012, -744.500610), rot(0, 16384, 0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "ROM Encoding Room", NORMAL_GOAL | VANILLA_GOAL, vect(-0.995101,-260.668579,-311.088989), rot(0,32824,0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "Radioactive Lab", NORMAL_GOAL | VANILLA_GOAL, vect(-592.426758,329.524597,-743.972717), rot(0,49160,0));
        return 62;

    case "06_HONGKONG_WANCHAI_STREET":
    case "06_HONGKONG_WANCHAI_CANAL":
    case "06_HONGKONG_WANCHAI_MARKET":
    case "06_HONGKONG_WANCHAI_UNDERWORLD":
        goal = AddGoal("06_HONGKONG_WANCHAI_STREET", "Dragon's Tooth Sword", NORMAL_GOAL, 'WeaponNanoSword0', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger0', PHYS_None);// DL_Tong_00: Now bring the sword to Max Chen at the Lucky Money Club

        AddGoalLocation("06_HONGKONG_WANCHAI_STREET", "Sword Case", NORMAL_GOAL | VANILLA_GOAL, vect(-1857.841064, -158.911865, 2051.345459), rot(0, 0, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_STREET", "in Maggie's shower", NORMAL_GOAL, vect(-1294.841064, -1861.911865, 2190.345459), rot(0, 0, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_STREET", "on Jock's bed", NORMAL_GOAL, vect(342.584808, -1802.576172, 1713.509521), rot(0, 0, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_STREET", "in the sniper nest", NORMAL_GOAL, vect(204.923828, -195.652588, 1795), rot(0, 40000, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_CANAL", "in the hold of the boat", NORMAL_GOAL, vect(2293, 2728, -598), rot(0, 10808, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_CANAL", "with the boatperson", NORMAL_GOAL, vect(1775, 2065, -317), rot(0, 0, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_CANAL", "in the Old China Hand kitchen", NORMAL_GOAL, vect(-1623, 3164, -393), rot(0, -49592, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD", "in the Lucky Money freezer", NORMAL_GOAL, vect(-1780, -2750, -333), rot(0, 27104, 0));
        AddGoalLocation("06_HONGKONG_WANCHAI_MARKET", "in the police vault", NORMAL_GOAL, vect(-480, -720, -107), rot(0, -5564, 0));

        goal = AddGoal("06_HONGKONG_WANCHAI_UNDERWORLD","Max Chen",GOAL_TYPE1,'MaxChen0',PHYS_FALLING);
        AddGoalActor(goal, 1, 'TriadRedArrow5', PHYS_Falling); //Maybe I should actually find these guys by bindname?  They're "RightHandMan"
        AddGoalActor(goal, 2, 'TriadRedArrow6', PHYS_Falling);

        loc=AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD","Office",GOAL_TYPE1 | SITTING_GOAL | VANILLA_GOAL,vect(426.022644,-2469.105957,-336.399414),rot(0,0,0));
        AddActorLocation(loc, 1, vect(488.291809, -2581.964355, -336.402618), rot(0,32620,0));
        AddActorLocation(loc, 2, vect(484.913330,-2345.247559,-336.401306), rot(0,32620,0));

        loc=AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD","Bathroom",GOAL_TYPE1,vect(-1725.911133,-565.364746,-339),rot(0,16368,0));
        AddActorLocation(loc, 1, vect(-1794.911133,-572.364746,-339), rot(0,16368,0));
        AddActorLocation(loc, 2, vect(-1658.911133,-568.364746,-339), rot(0,16368,0));

        loc=AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD","Bar",GOAL_TYPE1,vect(-772,-2220,-144),rot(0,-16352,0));
        AddActorLocation(loc, 1, vect(-755,-2326,-136), rot(0,16508,0));
        AddActorLocation(loc, 2, vect(-617,-2280,-136), rot(0,32620,0));

        loc=AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD","Sailors",GOAL_TYPE1,vect(-1392,-2539,18),rot(0,-6414,0));
        AddActorLocation(loc, 1, vect(-1161,-2550,21), rot(0,39348,0));
        AddActorLocation(loc, 2, vect(-1204,-2758,21), rot(0,23892,0));

        return 63;

    }

    return mission+1000;
}

function MissionTimer()
{
    local #var(prefix)TracerTong tong;
    local bool ready_for_m08;

    switch(dxr.localURL) {
    case "06_HONGKONG_WANCHAI_MARKET":
        UpdateGoalWithRandoInfo('InvestigateMaggieChow', "The sword may not be in Maggie's apartment, instead there will be a Datacube with a hint.");
        break;
    case "06_HONGKONG_TONGBASE":
        UpdateGoalWithRandoInfo('GetROM', "The computer with the ROM-encoding could be anywhere in the lab.");

        //Immediately start M08Briefing after M07Briefing, if possible
        ready_for_m08 = !M08Briefing && dxr.flagbase.GetBool('M07Briefing_played') && !dxr.flagbase.GetBool('M08Briefing_played');
        ready_for_m08 = ready_for_m08 && dxr.flagbase.GetBool('TriadCeremony_Played') && dxr.flagbase.GetBool('VL_UC_Destroyed') && dxr.flagbase.GetBool('VL_Got_Schematic');
        if (ready_for_m08){
            if (player().conPlay==None){
                foreach AllActors(class'#var(prefix)TracerTong',tong){ break;}

                //Ensure we have line of sight and are reasonably close, otherwise this looks really dumb
                //(Particularly if you did this the expected way with multiple visits)
                if (VSize(tong.Location-player().Location) <= 180 && FastTrace(tong.Location,player().Location)){
                    if (dxr.FlagBase.GetBool('LDDPJCIsFemale')){
                        M08Briefing = (player().StartConversationByName('FemJCM08Briefing',tong));
                    } else {
                        M08Briefing = (player().StartConversationByName('M08Briefing',tong));
                    }
                }
            }
        }
        break;
    }

    //Rando can give you this goal in a bunch of maps (Tonnochi Road, Canal, Market, Lucky Money)
    //just update it whenever
    UpdateGoalWithRandoInfo('ConvinceRedArrow', "Max Chen could be anywhere in the Lucky Money.");
}

function DeleteGoal(Goal g, GoalLocation Loc)
{
    if (g.name=="Dragon's Tooth Sword"){
        GenerateDTSHintCube(g, Loc);
    }
}

function GenerateDTSHintCube(Goal g, GoalLocation Loc)
{
    local #var(prefix)DataLinkTrigger dt;
    foreach AllActors(class'#var(prefix)DataLinkTrigger', dt) {
        if(dt.datalinkTag=='DL_Tong_00B') { // Greetings, JC Denton; this adds the goal for retrieving the sword, and if that happens after completing the goal then the goal is stuck
            dt.Destroy();
        }
    }
    SpawnDatacubePlaintext(vectm(-1857.841064, -158.911865, 2051.345459), rotm(0,0,0,0),
        "I borrowed the sword but forgot it somewhere...  Maybe "$Loc.name$"?", true);
}

function CreateGoal(out Goal g, GoalLocation Loc)
{
    local WeaponNanoSword dts;
    local DataLinkTrigger dlt;

    switch(g.name) {
    case "Dragon's Tooth Sword":
        dts = WeaponNanoSword(Spawnm(class'WeaponNanoSword',,,Loc.positions[0].pos,Loc.positions[0].rot));
        dlt = DataLinkTrigger(Spawnm(class'DataLinkTrigger',,,Loc.positions[0].pos));

        g.actors[0].a=dts;
        g.actors[1].a=dlt;

        dlt.SetCollision(True,False,False);
        dlt.Tag='';
        dlt.datalinkTag='DL_Tong_00';
        dlt.SetCollisionSize(100,20);
        break;
    }
}

function AfterMoveGoalToLocation(Goal g, GoalLocation Loc)
{
    if (g.name=="Dragon's Tooth Sword" && Loc.name!="Sword Case") {
        if(g.actors[1].a != None) {
            g.actors[1].a.Tag=''; //Change the tag so it doesn't get hit if the case opens

            //Make the datalink trigger actually bumpable
            g.actors[1].a.SetCollision(True,False,False);
            g.actors[1].a.SetCollisionSize(100,20);
        }

        if ( dxr.localURL == "06_HONGKONG_WANCHAI_STREET" ){
            GenerateDTSHintCube(g,Loc);
        }
    }
    if (g.name=="Nanotech Blade ROM" && Loc.name!="ROM Encoding Room") {
        g.actors[3].a.SetCollisionSize(400, 100);// DL_Tong_08: The ROM-encoding should be in this wing of the laboratory.
    }

    if (Loc.name == "Overlook Office") {
        // spawn the MAHOGANY desk (CreateGoal only gets called for different maps)
        g.actors[1].a = Spawnm(class'MahoganyDesk',,,Loc.positions[1].pos, Loc.positions[1].rot);
    }
}

function PreFirstEntryMapFixes()
{
    if (dxr.localURL == "06_HONGKONG_HELIBASE") {
        FailIfCorpseNotHeld("TerroristCommander");
    }
}
