class DXRMissionsM15 extends DXRMissions;


function int InitGoals(int mission, string map)
{
    local int goal, loc;

    switch(map) {
    case "15_AREA51_BUNKER":
        AddGoalLocation("15_AREA51_BUNKER", "Jock", START_LOCATION | VANILLA_START, vect(-1778.574707, 1741.028320, -213.732849), rot(0, -12416, 0));
        AddGoalLocation("15_AREA51_BUNKER", "Tower", START_LOCATION, vect(-1319.494751, 168.401230, 102.800003), rot(0, -38180, 0));
        AddGoalLocation("15_AREA51_BUNKER", "Behind the Van", START_LOCATION, vect(-493.825836, 3099.697510, -512.897827), rot(0, 0, 0));

        goal = AddGoal("15_AREA51_BUNKER", "Walton Simons", NORMAL_GOAL, 'WaltonSimons0', PHYS_Falling);
        AddGoalActor(goal, 1, 'Trigger0', PHYS_None); //Triggers WaltonTalks
        AddGoalActor(goal, 2, 'OrdersTrigger1', PHYS_None); //WaltonTalks -> Conversation triggers WaltonAttacks
        AddGoalActor(goal, 3, 'AllianceTrigger0', PHYS_None); //WaltonAttacks

        loc = AddGoalLocation("15_AREA51_BUNKER", "Command 24", NORMAL_GOAL | VANILLA_GOAL, vect(1125.623779,3076.459961,-462.398041), rot(0, -33064, 0));
        AddActorLocation(loc, 1, vect(471.648193, 2674.075439, -487.900055), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_BUNKER", "Behind Supply Shed", NORMAL_GOAL, vect(-1563,3579,-198), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-1358,2887,-160), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_BUNKER", "Behind Tower", NORMAL_GOAL, vect(-1136,-137,-181), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-1344,740,-160), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_BUNKER", "Hangar", NORMAL_GOAL, vect(1182,-1140,-478), rot(0, -33064, 0));
        AddActorLocation(loc, 1, vect(781,-235,-487), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_BUNKER", "Bunker Entrance", NORMAL_GOAL, vect(3680,1875,-848), rot(0, -18224, 0));
        AddActorLocation(loc, 1, vect(3470,1212,-800), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_ENTRANCE", "Sector 3 Access", NORMAL_GOAL, vect(-456,124,-16), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-20,80,-180), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_FINAL", "Heliowalton", NORMAL_GOAL, vect(-4400,750,-1475), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-3720,730,-1105), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_FINAL", "Reactor Lab", NORMAL_GOAL, vect(-3960,-3266,-1552), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-3455,-3261,-1560), rot(0,0,0));

        AddGoal("15_AREA51_BUNKER", "Area 51 Blast Door Computer", GOAL_TYPE1, 'ComputerSecurity0', PHYS_None);
        loc = AddGoalLocation("15_AREA51_BUNKER", "the tower", GOAL_TYPE1 | VANILLA_GOAL, vect(-1248.804321,137.393707,442.793121), rot(0, 0, 0));
        AddMapMarker(class'Image15_Area51Bunker',29,220,"C","Blast Door Computer", loc,"The Blast Door Computer can sometimes be found at the top of the Tower.");
        loc = AddGoalLocation("15_AREA51_BUNKER", "Command 24", GOAL_TYPE1, vect(1125.200562,2887.646484,-432.319794), rot(0, 0, 0));
        AddMapMarker(class'Image15_Area51Bunker',151,277,"C","Blast Door Computer", loc,"The Blast Door Computer can sometimes be found in the Command 24 building.");
        loc = AddGoalLocation("15_AREA51_BUNKER", "the hangar", GOAL_TYPE1, vect(1062.942261,-2496.865723,-443.252533), rot(0, 16384, 0));
        AddMapMarker(class'Image15_Area51Bunker',95,134,"C","Blast Door Computer", loc,"The Blast Door Computer can sometimes be found on the outside of the building inside the Hangar.");
        loc = AddGoalLocation("15_AREA51_BUNKER", "the supply shed", GOAL_TYPE1, vect(-1527.608521,3280.824219,-158.588562), rot(0, -16384, 0));
        AddMapMarker(class'Image15_Area51Bunker',63,316,"C","Blast Door Computer", loc,"The Blast Door Computer can sometimes be found in the Supply Shed (Which is not visible on this map image).");

        if (dxr.flags.GetStartingMap() > 150)
        {
            skip_rando_start = True;
        }

        return 151;

        break;

    case "15_AREA51_PAGE":
        // GOAL_TYPE1 is for the goals that can be in easy locations, aka everything except Aquinas Substation Computer
        goal = AddGoal("15_AREA51_PAGE", "Aquinas Substation Computer", NORMAL_GOAL, 'ComputerSecurity0', PHYS_None);
        loc = AddGoalLocation("15_AREA51_PAGE", "Aquinas Substation", NORMAL_GOAL | VANILLA_GOAL, vect(7676.954590, -5536.813965, -5952.371094), rot(0, -32824, 0));
        AddMapMarker(class'Image15_Area51_Sector4',316,199,"E","Ending", loc,"One of the end game goals can be located on the wall of the Aquinas Substation.");

        goal = AddGoal("15_AREA51_PAGE", "Coolant Deactivation Button", GOAL_TYPE1 | NORMAL_GOAL, 'Switch0', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger2', PHYS_None); // shutting down the coolant, DL_tong3: Good.  Now go to the reactor lab.
        AddGoalActor(goal, 2, 'DataLinkTrigger12', PHYS_None); // same
        AddGoalActor(goal, 3, 'DataLinkTrigger37', PHYS_None); // DL_ButtonWarning: You will stay away from the coolant controls.  I will be destroyed if the reactors become unstable, and without me there will be chaos.
        loc = AddGoalLocation("15_AREA51_PAGE", "Coolant B13", NORMAL_GOAL | VANILLA_GOAL, vect(7530.221191,-10824.041992, -5968.846680), rot(11200, -16088, 0));
        AddMapMarker(class'Image15_Area51_Sector4',78,208,"E","Ending", loc,"One of the end game goals can be located on the control panel in the Coolant B13 room.");

        goal = AddGoal("15_AREA51_PAGE", "Blue Fusion Reactor 3 Control", GOAL_TYPE1 | NORMAL_GOAL, 'Keypad5', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger17', PHYS_None); // DL_Blue_Fusion: That's one of the blue-fusion reactors.  You need to shut down all four.
        loc = AddGoalLocation("15_AREA51_PAGE", "Ground Floor", NORMAL_GOAL | VANILLA_GOAL, vect(6360.212402, -6899.757324, -5988.736328), rot(0, -45056, 0));
        AddMapMarker(class'Image15_Area51_Sector4',256,254,"E","Ending", loc,"One of the end game goals can be located on the base of the ground floor Blue Fusion Reactor.");

        goal = AddGoal("15_AREA51_PAGE", "Blue Fusion Reactor 4 Control", GOAL_TYPE1 | NORMAL_GOAL, 'Keypad6', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger19', PHYS_None); // DL_Blue_Fusion
        loc = AddGoalLocation("15_AREA51_PAGE", "Radioactive Room", NORMAL_GOAL | VANILLA_GOAL, vect(4764.696289, -6270.016113, -5596.736328), rot(0, -61760, 0));
        AddMapMarker(class'Image15_Area51_Sector4',155,376,"E","Ending", loc,"One of the end game goals can be located on the base of the Blue Fusion Reactor in the radioactive room.");

        goal = AddGoal("15_AREA51_PAGE", "Blue Fusion Reactor 2 Control", GOAL_TYPE1 | NORMAL_GOAL, 'Keypad1', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger18', PHYS_None); // DL_Blue_Fusion
        loc = AddGoalLocation("15_AREA51_PAGE", "Under Page", NORMAL_GOAL | VANILLA_GOAL, vect(6153.652832, -7133.199219, -5596.736328), rot(0, -61568, 0));
        AddMapMarker(class'Image15_Area51_Sector4',115,314,"E","Ending", loc,"One of the end game goals can be located on the base of the Blue Fusion Reactor on the middle floor underneath Bob Page.");

        goal = AddGoal("15_AREA51_PAGE", "Blue Fusion Reactor 1 Control", GOAL_TYPE1 | NORMAL_GOAL, 'Keypad0', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger21', PHYS_None); // DL_Blue_Fusion
        loc = AddGoalLocation("15_AREA51_PAGE", "Observation Deck", NORMAL_GOAL | VANILLA_GOAL, vect(6029.028809, -8301.839844, -5148.736328), rot(0, -36944, 0));
        AddMapMarker(class'Image15_Area51_Sector4',192,77,"E","Ending", loc,"One of the end game goals can be located on the base of the Blue Fusion Reactor in the top floor Observation Deck overlooking Bob Page.");

        if (#bool(shuffleucswitches)){
            //Shuffle the UC switches themselves
            goal = AddGoal("15_AREA51_PAGE", "Upper UC Shutdown", GOAL_TYPE1 | NORMAL_GOAL, 'DeusExMover72', PHYS_MovingBrush);
            loc = AddGoalLocation("15_AREA51_PAGE", "Upper UC Control Room", GOAL_TYPE1 | VANILLA_GOAL, vect(7873,-7548,-5096), rot(0, 16384, 0));

            goal = AddGoal("15_AREA51_PAGE", "Middle UC Shutdown", GOAL_TYPE1| NORMAL_GOAL, 'DeusExMover51', PHYS_MovingBrush);
            loc = AddGoalLocation("15_AREA51_PAGE", "Middle UC Control Room", NORMAL_GOAL | VANILLA_GOAL, vect(5518,-8644,-5540), rot(0, 16384, 0));

            goal = AddGoal("15_AREA51_PAGE", "Bottom UC Shutdown", GOAL_TYPE1 | NORMAL_GOAL, 'DeusExMover49', PHYS_MovingBrush);
            loc = AddGoalLocation("15_AREA51_PAGE", "Bottom UC Control Room", NORMAL_GOAL | VANILLA_GOAL, vect(7956,-7495,-5931), rot(0, 32768, 0));
        } else {
            //Only use the rooms as extra locations
            loc = AddGoalLocation("15_AREA51_PAGE", "Upper UC Control Room", GOAL_TYPE1, vect(7991,-7395,-5096), rot(0, 32768, 0));
            AddMapMarker(class'Image15_Area51_Sector4',237,11,"E","Ending", loc,"One of the end game goals can be located on the wall of the Control Room for the upper UC (UC-03).");

            loc = AddGoalLocation("15_AREA51_PAGE", "Middle UC Control Room", NORMAL_GOAL, vect(5382,-8556,-5540), rot(0, 0, 0));
            AddMapMarker(class'Image15_Area51_Sector4',53,348,"E","Ending", loc,"One of the end game goals can be located on the wall of the Control Room for the middle UC (UC-01).");

            loc = AddGoalLocation("15_AREA51_PAGE", "Bottom UC Control Room", NORMAL_GOAL, vect(7868,-7631,-5931), rot(0, 16384, 0));
            AddMapMarker(class'Image15_Area51_Sector4',224,187,"E","Ending", loc,"One of the end game goals can be located on the wall of the Control Room for the bottom UC (UC-02).");
        }

        return 154;

        break;
    }


    return mission+1000;
}

function int InitGoalsRev(int mission, string map)
{
    local int goal, loc;

    switch(map) {
    case "15_AREA51_BUNKER":
        AddGoalLocation("15_AREA51_BUNKER", "Jock", START_LOCATION | VANILLA_START, vect(-6066,618.8,-46.73), rot(0, 199216, 0)); //This rotation matches the PlayerStart, it's not a typo
        AddGoalLocation("15_AREA51_BUNKER", "Tower", START_LOCATION, vect(-4960,2300,110), rot(0, -16000, 0));
        AddGoalLocation("15_AREA51_BUNKER", "Behind the Van", START_LOCATION, vect(-979.896423,3249.618408,-472.401825), rot(0, 0, 0));


        goal = AddGoal("15_AREA51_BUNKER", "Walton Simons", NORMAL_GOAL, 'WaltonSimons1', PHYS_Falling);
        AddGoalActor(goal, 1, 'Trigger4', PHYS_None); //Triggers WaltonTalks
        AddGoalActor(goal, 2, 'OrdersTrigger3', PHYS_None); //WaltonTalks -> Conversation triggers WaltonAttacks
        AddGoalActor(goal, 3, 'AllianceTrigger1', PHYS_None); //WaltonAttacks

        loc = AddGoalLocation("15_AREA51_BUNKER", "Command 24", NORMAL_GOAL | VANILLA_GOAL, vect(1390,2640,-264), rot(0, -33064, 0));
        AddActorLocation(loc, 1, vect(353,2344,-494), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_BUNKER", "Behind Supply Shed", NORMAL_GOAL, vect(-782,208,-192), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-1772,210,-178), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_BUNKER", "Behind Tower", NORMAL_GOAL, vect(-914,2050,-192), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-1598,2045,-178), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_BUNKER", "Hangar", NORMAL_GOAL, vect(1717,-1750,-480), rot(0, -33064, 0));
        AddActorLocation(loc, 1, vect(1147,-1129,-494), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_BUNKER", "Bunker Entrance", NORMAL_GOAL, vect(3802,2388,-848), rot(0, -18224, 0));
        AddActorLocation(loc, 1, vect(3079,1214,-826), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_ENTRANCE", "Sector 3 Elevator", NORMAL_GOAL, vect(-3969.244385,703.847961,-2168.792725), rot(0, -16568, 0));
        //AddActorLocation(loc, 1, vect(-20,80,-180), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_FINAL", "Heliowalton", NORMAL_GOAL, vect(-4400,750,-1475), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-3720,730,-1105), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_FINAL", "Reactor Lab", NORMAL_GOAL, vect(-4358,-3393,-1527), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-3455,-3261,-1560), rot(0,0,0));


        AddGoal("15_AREA51_BUNKER", "Area 51 Blast Door Computer", GOAL_TYPE1, 'ComputerSecurity4', PHYS_None);
        AddGoalLocation("15_AREA51_BUNKER", "the tower", GOAL_TYPE1 | VANILLA_GOAL, vect(-1108.649414,2037.512451,302.793121), rot(0, 65536, 0));
        AddGoalLocation("15_AREA51_BUNKER", "Command 24", GOAL_TYPE1, vect(1363.689941,2460.441895,-235.503601), rot(0, 0, 0));
        AddGoalLocation("15_AREA51_BUNKER", "the hangar", GOAL_TYPE1, vect(1397.388672,-2498.310059,-441.741699), rot(0, 16384, 0));
        AddGoalLocation("15_AREA51_BUNKER", "the supply shed", GOAL_TYPE1, vect(-1860.243530,2902.310059,-151.812180), rot(0, -16384, 0));

        if (dxr.flags.GetStartingMap() > 150)
        {
            skip_rando_start = True;
        }

        return 151;

        break;

    case "15_AREA51_PAGE":
        // GOAL_TYPE1 is for the goals that can be in easy locations, aka everything except Aquinas Substation Computer
        goal = AddGoal("15_AREA51_PAGE", "Aquinas Substation Computer", NORMAL_GOAL, 'ComputerSecurity0', PHYS_None);
        loc = AddGoalLocation("15_AREA51_PAGE", "Aquinas Substation", NORMAL_GOAL | VANILLA_GOAL, vect(1510.912109,4078.936279,-577.371094), rot(0, -32824, 0));

        goal = AddGoal("15_AREA51_PAGE", "Coolant Deactivation Button", GOAL_TYPE1 | NORMAL_GOAL, 'Switch0', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger2', PHYS_None); // shutting down the coolant, DL_tong3: Good.  Now go to the reactor lab.
        AddGoalActor(goal, 2, 'DataLinkTrigger12', PHYS_None); // same
        AddGoalActor(goal, 3, 'DataLinkTrigger37', PHYS_None); // DL_ButtonWarning: You will stay away from the coolant controls.  I will be destroyed if the reactors become unstable, and without me there will be chaos.
        loc = AddGoalLocation("15_AREA51_PAGE", "Coolant B13", NORMAL_GOAL | VANILLA_GOAL, vect(1362.221191,-1212.041992,-596.846680), rot(11200, -16088, 0));

        goal = AddGoal("15_AREA51_PAGE", "Blue Fusion Reactor 3 Control", GOAL_TYPE1 | NORMAL_GOAL, 'Keypad5', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger17', PHYS_None); // DL_Blue_Fusion: That's one of the blue-fusion reactors.  You need to shut down all four.
        loc = AddGoalLocation("15_AREA51_PAGE", "Ground Floor", NORMAL_GOAL | VANILLA_GOAL, vect(192.212402,2712.242676,-616.736328), rot(0, -45056, 0));

        goal = AddGoal("15_AREA51_PAGE", "Blue Fusion Reactor 4 Control", GOAL_TYPE1 | NORMAL_GOAL, 'Keypad6', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger19', PHYS_None); // DL_Blue_Fusion
        loc = AddGoalLocation("15_AREA51_PAGE", "Radioactive Room", NORMAL_GOAL | VANILLA_GOAL, vect(-1403.303711,3341.983887,-224.736328), rot(0, -61760, 0));

        goal = AddGoal("15_AREA51_PAGE", "Blue Fusion Reactor 2 Control", GOAL_TYPE1 | NORMAL_GOAL, 'Keypad1', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger18', PHYS_None); // DL_Blue_Fusion
        loc = AddGoalLocation("15_AREA51_PAGE", "Under Page", NORMAL_GOAL | VANILLA_GOAL, vect(-14.347168,2478.800781,-224.736328), rot(0, -61568, 0));

        goal = AddGoal("15_AREA51_PAGE", "Blue Fusion Reactor 1 Control", GOAL_TYPE1 | NORMAL_GOAL, 'Keypad0', PHYS_None);
        AddGoalActor(goal, 1, 'DataLinkTrigger21', PHYS_None); // DL_Blue_Fusion
        loc = AddGoalLocation("15_AREA51_PAGE", "Observation Deck", NORMAL_GOAL | VANILLA_GOAL, vect(-138.971191,1310.160156,223.263672), rot(0, -36944, 0));

        if (#bool(shuffleucswitches)){
            //Shuffle the UC switches themselves
            goal = AddGoal("15_AREA51_PAGE", "Upper UC Shutdown", GOAL_TYPE1 | NORMAL_GOAL, 'DeusExMover72', PHYS_MovingBrush);
            loc = AddGoalLocation("15_AREA51_PAGE", "Upper UC Control Room", GOAL_TYPE1 | VANILLA_GOAL, vect(1705,2064,276), rot(0, 16384, 0));

            goal = AddGoal("15_AREA51_PAGE", "Middle UC Shutdown", GOAL_TYPE1| NORMAL_GOAL, 'DeusExMover51', PHYS_MovingBrush);
            loc = AddGoalLocation("15_AREA51_PAGE", "Middle UC Control Room", NORMAL_GOAL | VANILLA_GOAL, vect(-650,968,-168), rot(0, 16384, 0));

            goal = AddGoal("15_AREA51_PAGE", "Bottom UC Shutdown", GOAL_TYPE1 | NORMAL_GOAL, 'DeusExMover49', PHYS_MovingBrush);
            loc = AddGoalLocation("15_AREA51_PAGE", "Bottom UC Control Room", NORMAL_GOAL | VANILLA_GOAL, vect(1788,2117,-559), rot(0, 32768, 0));
        } else {
            //Only use the rooms as extra locations
            loc = AddGoalLocation("15_AREA51_PAGE", "Upper UC Control Room", GOAL_TYPE1, vect(1820,2210,290), rot(0, 32768, 0));
            loc = AddGoalLocation("15_AREA51_PAGE", "Middle UC Control Room", NORMAL_GOAL, vect(-784,1056,-165), rot(0, 0, 0));
            loc = AddGoalLocation("15_AREA51_PAGE", "Bottom UC Control Room", NORMAL_GOAL, vect(1700,1983,-555), rot(0, 16384, 0));
        }

        return 154;

        break;
    }

    return mission+1000;
}

function PreFirstEntryMapFixes()
{
    local Trigger t;
    local FlagTrigger ft;
    local #var(DeusExPrefix)Mover dxm;
    local vector v;
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    if ( dxr.localURL == "15_AREA51_BUNKER" ) {
        foreach AllActors(class'Trigger',t){
            if (t.Name=='Trigger1' || t.Name=='Trigger2'){
                t.Destroy(); //Just rely on one trigger for Walton
            }
        }
    } else if (dxr.localURL=="15_AREA51_FINAL" && RevisionMaps){
        //Revision has a trigger in Final that makes Walton chase you down from the elevator.
        //This moves him again, so he ends up unrandomized
        foreach AllActors(class'FlagTrigger',ft){
            if (ft.Event=='SimonsSequence'){
                ft.Event='';
                ft.Destroy();
            }
        }
    } else if (dxr.localURL=="15_AREA51_PAGE" && !RevisionMaps) {
        //Remove the insane prepivot on the UC door closers (but not in HX, because it doesn't like that)
        if (!#defined(hx)){
            foreach AllActors(class'#var(DeusExPrefix)Mover',dxm){
                if (dxm.Event=='UC_shutdoor1' ||
                    dxm.Event=='UC_shutdoor2' ||
                    dxm.Event=='UC_shutdoor3'){

                    v=vectm(0,0,dxm.PrePivot.Z);

                    RemoveMoverPrePivot(dxm);

                    //Return the Z component of the prepivot so the switches rotate on center
                    dxm.PrePivot=v;
                    dxm.BasePos=dxm.BasePos+v;
                    dxm.SetLocation(dxm.BasePos);
                }
            }
        }
    }
}

function CreateGoal(out Goal g, GoalLocation Loc)
{
    local #var(prefix)ScriptedPawn sp;
    local #var(prefix)OrdersTrigger ot;
    local #var(prefix)AllianceTrigger at;
    local #var(prefix)Trigger t;
    local FlagBase f;

    f = dxr.flagbase;

    switch(g.name) {
    case "Walton Simons": //Much the same as above, but he could be dead already
        if (f.GetBool('WaltonSimons_Dead')){
            l("Walton Simons dead, not spawning");
            return;
        }

        sp = #var(prefix)ScriptedPawn(Spawnm(class'#var(prefix)WaltonSimons',, 'DXRMissions', Loc.positions[0].pos));
        ot = #var(prefix)OrdersTrigger(Spawnm(class'#var(prefix)OrdersTrigger',,'WaltonTalks',Loc.positions[0].pos));
        at = #var(prefix)AllianceTrigger(Spawnm(class'#var(prefix)AllianceTrigger',,'WaltonAttacks',Loc.positions[0].pos));
        t = #var(prefix)Trigger(Spawnm(class'#var(prefix)Trigger',,,Loc.positions[1].pos));
        g.actors[0].a = sp;
        g.actors[1].a = ot;
        g.actors[2].a = at;
        g.actors[3].a = t;

        sp.BarkBindName = "WaltonSimons";
        sp.Tag='WaltonSimons';
        sp.SetOrders('WaitingFor');
        sp.bInvincible=False;
        sp.MaxProvocations = 0;
        sp.AgitationSustainTime = 3600;
        sp.AgitationDecayRate = 0;

        sp.SetAlliance('mj12');

        GiveItem(sp,class'WeaponPlasmaRifle',100);
        GiveItem(sp,class'WeaponNanoSword');
        GiveItem(sp,class'WeaponLAM',3); //A bomb!

        sp.ConBindEvents();

        ot.Event='WaltonSimons';
        ot.Orders='RunningTo';
        ot.SetCollision(False,False,False);

        at.Event='WaltonSimons';
        at.Alliances[0].AllianceLevel=-1;
        at.Alliances[0].AllianceName='Player';
        at.Alliances[0].bPermanent=True;
        at.SetCollision(False,False,False);

        t.Event='WaltonTalks';
        t.SetCollisionSize(1024,300);

        break;
    }
}

function AfterMoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local #var(prefix)DataCube dc1;
    local #var(prefix)InformationDevices dc2;
    local #var(prefix)FlagTrigger ft;
    local #var(prefix)Switch1 button;
    local Dispatcher disp;
    local rotator r;
    local string dctext;

    if (g.name=="Area 51 Blast Door Computer" && Loc.name != "the tower") {
        foreach AllActors(class'#var(prefix)DataCube',dc1){
            if(dc1.TextTag!='15_Datacube07') continue;

            dctext = "Yusef:|n|nThey've jammed all communications, even narrow band microcasts, so this is the only way I could pass a message to you.  ";
            dctext = dctext $ "I don't know who these guys are -- they're not ours, not any of ours I've ever seen at least -- but they're slaughtering us.  ";
            dctext = dctext $ "I managed to hack the first layer of the Dreamland systems, but the best I could do was lock the bunker doors and reroute control to the security console in "$Loc.name$".  ";
            dctext = dctext $ "Should take them awhile to figure that one out, and the moment they do I'll nail the first bastard that sticks his head out of the hole.  If something happens to me, the login is ";
            dctext = dctext $ "\"a51\" and the password is \"xx15yz\".|n|n";
            dctext = dctext $ "BTW, be careful -- a squad made it out before I managed to lock the doors: they headed for the warehouse and then I lost contact with them.|n|n--Hawkins";

            dc2 = SpawnDatacubePlaintext(dc1.Location, dc1.Rotation, dctext, "A51BlastDoorComputerHintCube");
            if( dc2 != None ){
                l("DXRMissions spawned "$ dc2 @ dctext @ dc2.Location);
                dc1.Destroy();
            }
            else warning("failed to spawn tower datacube at "$dc1.Location);
        }
    }
    else if (g.name=="Coolant Deactivation Button") {
        // make the FlagTrigger directly hit the DataLinkTrigger
        foreach AllActors(class'#var(prefix)FlagTrigger', ft, 'coolant') {
            ft.Event = 'coolant_dlt';
            ft.bTrigger = true;
        }
        if(g.actors[2].a != None) {
            g.actors[2].a.Destroy();
            g.actors[2].a = None;
        }
        g.actors[1].a.Tag = 'coolant_dlt';
        g.actors[1].a.SetCollision(false,false,false);

        // give this Switch1 the defaults of Switch2
        button = #var(prefix)Switch1(g.actors[0].a);
        button.Skin=Texture'DeusExDeco.Skins.Switch1Tex2';
        button.DrawScale=2;
        button.SetCollisionSize(5.260000, 5.940000);
    }
    else if (g.name=="Aquinas Substation Computer") {
        g.actors[0].a.Event = 'AquinasDoorComputer';
    }
    else if (g.name=="Upper UC Shutdown" || g.name=="Middle UC Shutdown" || g.name=="Bottom UC Shutdown"){
        r = g.actors[0].a.rotation;
        r.Yaw = r.Yaw - 32768;
        if (r.Pitch!=0){ //Adjust the pitch for the coolant control panel location
            r.Pitch = -r.Pitch;
        }
        g.actors[0].a.SetRotation(r);
        #var(DeusExPrefix)Mover(g.actors[0].a).BaseRot=r;

        class'DXRHoverHint'.static.Create(self, g.name, g.actors[0].a.Location, 15, 10, g.actors[0].a);
    }

    if(Loc.name=="Observation Deck") {// for releasing the bots behind you
        foreach AllActors(class'Dispatcher', disp, 'node1') {
            disp.Tag = g.actors[0].a.Event;
        }
    }
}

function AfterShuffleGoals(int goalsToLocations[32])
{
    local int g;
    local WaltonSimons walt;
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    //Revision can put Walt in the elevator down to Sector 3.  We need to despawn him if we don't pick that location
    if (RevisionMaps && dxr.localURL == "15_AREA51_ENTRANCE"){
        for(g=0; g<num_goals; g++) {
            if(goals[g].name == "Walton Simons" && locations[goalsToLocations[g]].name!="Sector 3 Elevator") {
                foreach AllActors(class'WaltonSimons',walt){
                    walt.Destroy();
                }
            }
        }
    }
}
