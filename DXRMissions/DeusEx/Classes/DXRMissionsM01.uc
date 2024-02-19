class DXRMissionsM01 extends DXRMissions;

function int InitGoals(int mission, string map)
{
    local int goal, goal2, loc, loc2;

    goal = AddGoal("01_NYC_UNATCOISLAND", "Terrorist Commander", NORMAL_GOAL, 'TerroristCommander0', PHYS_Falling);
    AddGoalActor(goal, 1, 'DataLinkTrigger12', PHYS_None);
    goal2 = AddGoal("01_NYC_UNATCOISLAND", "Police Boat", GOAL_TYPE1, 'NYPoliceBoat0', PHYS_None);

    loc = AddGoalLocation("01_NYC_UNATCOISLAND", "UNATCO HQ", START_LOCATION, vect(-6348.445313, 1912.637207, -111.428482), rot(0, 0, 0));
    loc2 = AddGoalLocation("01_NYC_UNATCOISLAND", "Dock", NORMAL_GOAL | VANILLA_START, vect(-4760.569824, 10430.811523, -280.674988), rot(0, -7040, 0));
    AddMutualExclusion(loc, loc2);
    AddMapMarker(class'Image01_LibertyIsland',156,364,"L","Terrorist Commander", loc2,"Leo Gold, the terrorist commander, can be located on the south dock.  This is the location you would normally start the game.");

    loc2 = AddGoalLocation("01_NYC_UNATCOISLAND", "Hut", NORMAL_GOAL, vect(-2407.206787, 205.915558, -128.899979), rot(0, 30472, 0));
    AddMutualExclusion(loc, loc2);
    AddMapMarker(class'Image01_LibertyIsland',156,199,"L","Terrorist Commander", loc2,"Leo Gold, the terrorist commander, can be located in the small hut in front of the statue.");

    loc = AddGoalLocation("01_NYC_UNATCOISLAND", "Harley Filben Dock", START_LOCATION, vect(1297.173096, -10257.972656, -287.428131), rot(0, 0, 0));
    loc2 = AddGoalLocation("01_NYC_UNATCOISLAND", "Electric Bunker", NORMAL_GOAL | START_LOCATION, vect(6552.227539, -3246.095703, -447.438049), rot(0, 0, 0));
    AddMutualExclusion(loc, loc2);
    AddMapMarker(class'Image01_LibertyIsland',318,140,"L","Terrorist Commander",loc2,"Leo Gold, the terrorist commander, can be located in the back of the small bunker next to the statue.  He would be behind the malfunctioning electrical box.");

    loc=AddGoalLocation("01_NYC_UNATCOISLAND", "Jail", NORMAL_GOAL | START_LOCATION, vect(2127.692139, -1774.869141, -149.140366), rot(0, 0, 0));
    AddMapMarker(class'Image01_LibertyIsland',235,147,"L","Terrorist Commander", loc,"Leo Gold, the terrorist commander, can be located inside the jail cell where Gunther is locked up.");

    loc = AddGoalLocation("01_NYC_UNATCOISLAND", "Top of the Base", NORMAL_GOAL, vect(2980.058105, -669.242554, 1056.577271), rot(0, 0, 0));
    AddMapMarker(class'Image01_LibertyIsland',257,159,"L","Terrorist Commander",loc,"Leo Gold, the terrorist commander, can be located on the highest outside level of the base of the statue.");
    loc2 = AddGoalLocation("01_nyc_unatcoisland", "Top of the Statue", NORMAL_GOAL | VANILLA_GOAL | START_LOCATION, vect(2931.230957, 27.495235, 2527.800049), rot(0, 14832, 0));
    AddMapMarker(class'Image01_LibertyIsland',260,184,"L","Terrorist Commander",loc2,"Leo Gold, the terrorist commander, can be located in the command post at the top of the statue.  This is his vanilla location.");
    AddMutualExclusion(loc, loc2);

    //Boat locations
    loc=AddGoalLocation("01_nyc_unatcoisland", "South Dock", GOAL_TYPE1 | VANILLA_GOAL , vect(-5122.414551, 10138.813477, -269.806213), rot(0, 0, 0));
    AddMapMarker(class'Image01_LibertyIsland',130,371,"B","Police Boat",loc,"The police boat can be located at the South dock, where you normally start the game.  This is the vanilla location.");
    loc=AddGoalLocation("01_nyc_unatcoisland", "North Dock", GOAL_TYPE1 , vect(4535.585938, -10046.186523, -269.806213), rot(0, 0, 0));
    AddMapMarker(class'Image01_LibertyIsland',250,16,"B","Police Boat",loc,"The police boat can be located at the North dock, near where Harley Filben is located.");
    loc=AddGoalLocation("01_nyc_unatcoisland", "Top of the Statue", GOAL_TYPE1 , vect(3682.585449, 231.813477, 2108.193848), rot(0, 0, 0));
    AddMapMarker(class'Image01_LibertyIsland',281,179,"B","Police Boat",loc,"The police boat can be located floating off the side of an upper level of the statue.");
    loc=AddGoalLocation("01_nyc_unatcoisland", "Behind UNATCO", GOAL_TYPE1 , vect(-4578.414551, 267.813477, 24.193787), rot(0, 0, 0));
    AddMapMarker(class'Image01_LibertyIsland',121,200,"B","Police Boat",loc,"The police boat can be located floating behind UNATCO HQ, near the small hut in front of the statue.");
    return mission;
}

function int InitGoalsRev(int mission, string map)
{
    local int goal, loc, loc2;

    goal = AddGoal("01_NYC_UNATCOISLAND", "Terrorist Commander", NORMAL_GOAL, 'TerroristCommander0', PHYS_Falling);
    AddGoalActor(goal, 1, 'DataLinkTrigger12', PHYS_None);
    AddGoal("01_NYC_UNATCOISLAND", "Police Boat", GOAL_TYPE1, 'NYPoliceBoat0', PHYS_None);

    loc = AddGoalLocation("01_NYC_UNATCOISLAND", "UNATCO HQ", START_LOCATION, vect(-6146.002930, 1748.501709, -87.000000), rot(0, 0, 0));
    loc2 = AddGoalLocation("01_NYC_UNATCOISLAND", "Dock", NORMAL_GOAL | VANILLA_START, vect(-4728.569824, 9358.811523, -280.674988), rot(0, -7040, 0));
    AddMutualExclusion(loc, loc2);
    loc2 = AddGoalLocation("01_NYC_UNATCOISLAND", "Hut", NORMAL_GOAL, vect(-2404,177,-83), rot(0, 30472, 0));
    AddMutualExclusion(loc, loc2);

    loc = AddGoalLocation("01_NYC_UNATCOISLAND", "Harley Filben Dock", START_LOCATION, vect(1297.173096, -10257.972656, -287.428131), rot(0, 0, 0));
    loc2 = AddGoalLocation("01_NYC_UNATCOISLAND", "Electric Bunker", NORMAL_GOAL | START_LOCATION, vect(6552.227539, -3246.095703, -447.438049), rot(0, 0, 0));
    AddMutualExclusion(loc, loc2);

    AddGoalLocation("01_NYC_UNATCOISLAND", "Jail", NORMAL_GOAL | START_LOCATION, vect(2127.692139, -1774.869141, -149.140366), rot(0, 0, 0));

    loc = AddGoalLocation("01_NYC_UNATCOISLAND", "Top of the Base", NORMAL_GOAL, vect(2980.058105, -669.242554, 1056.577271), rot(0, 0, 0));
    loc2 = AddGoalLocation("01_NYC_UNATCOISLAND", "Top of the Statue", NORMAL_GOAL | VANILLA_GOAL | START_LOCATION, vect(2931.230957, 27.495235, 2527.800049), rot(0, 14832, 0));
    AddMutualExclusion(loc, loc2);

    //Boat locations
    AddGoalLocation("01_nyc_unatcoisland", "South Dock", GOAL_TYPE1 | VANILLA_GOAL , vect(-5023.598145,9131.867188,-269.806213), rot(0, 16192, 0));
    AddGoalLocation("01_nyc_unatcoisland", "North Dock", GOAL_TYPE1 , vect(4471, -10046.186523, -269.806213), rot(0, 16192, 0));
    AddGoalLocation("01_nyc_unatcoisland", "Top of the Statue", GOAL_TYPE1 , vect(3682.585449, 231.813477, 2108.193848), rot(0, 16192, 0));
    AddGoalLocation("01_nyc_unatcoisland", "Behind UNATCO", GOAL_TYPE1 , vect(-4571,135,24), rot(0, 16192, 0));

    return mission;
}

function PreFirstEntryMapFixes()
{
    local #var(prefix)DataLinkTrigger dlt;
    local #var(prefix)OrdersTrigger ot;

    if( dxr.localURL == "01_NYC_UNATCOISLAND" ) {
        dxr.flags.f.SetBool('PaulGaveWeapon', true,, 2);
#ifdef revision
        dxr.flags.f.SetBool('PaulGiveWeapon_Played', true,, 2);
        dxr.flags.f.SetBool('FemJCPaulGiveWeapon_Played', true,, 2);
        dxr.flags.f.SetBool('GotFreeWeapon', true,, 2);
#endif
        foreach AllActors(class'#var(prefix)OrdersTrigger', ot, 'PaulRunningToPlayer') {
            ot.Event = '';
            ot.Destroy();
        }
        foreach AllActors(class'#var(prefix)DataLinkTrigger', dlt) {
            switch(dlt.dataLinkTag) {
            case 'DL_StartGame':
            case 'DL_MissedPaul':
            case 'DL_MissedHermann':
            case 'DL_NearTop':
            case 'DL_MissedPaul':
                dlt.Event = '';
                dlt.Destroy();
            }
        }
    }
}

function MissionTimer()
{
    switch(dxr.localURL) {
    case "01_NYC_UNATCOHQ":
        if(dxr.flags.settings.goals > 0)
            UpdateGoalWithRandoInfo('GetToDock', "The boat could be anywhere.");
    }
}

function AddMissionGoals()
{
    local DeusExGoal newGoal;
    if(dxr.localURL != "01_NYC_UNATCOISLAND") return;

    //The MeetPaul conversation would normally give you several goals.
    //Give them manually instead of via that conversation.
    newGoal=player().AddGoal('DefeatNSFCommandCenter',True);
    newGoal.SetText("The NSF seem to be directing the attack from somewhere on the island.  Find the commander.");

    newGoal=player().AddGoal('RescueAgent',False);
    newGoal.SetText("One of UNATCO's top agents is being held inside the Statue.  Break him out, and he'll back you up against the NSF.");

    newGoal=player().AddGoal('MeetFilben',False);
    newGoal.SetText("Meet UNATCO informant Harley Filben at the North Docks.  He has a key to the Statue doors.");
}

function AfterMoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local string text;

    if(g.name == "Terrorist Commander") {
        // DataLinkTrigger 15ft wide, 4ft tall
        if(g.actors[1].a != None)
            g.actors[1].a.SetCollisionSize(240, 64);
        if(Loc.name != "Top of the Statue") {
            text = "I'm gonna go for a walk to clear my head."
                $ "|n|nI might be anywhere, like the hut in front of the statue, hanging out with Gunther in jail, or maybe I'll even sneak past UNATCO to hang out on the dock.";
        } else {
            text = "I was thinking about going for a walk but I got lazy."
                $ "|n|nI could've been anywhere, like the hut in front of the statue, hanging out with Gunther in jail, or maybe even snuck past UNATCO to hang out on the dock.";
        }
        text = text $ "|n-- Leo"
            $ "|n|nPS: You can see all my possible locations by clicking the Goal Locations button on your Goals screen."
            $ "|nIf you get really stuck then click on Show Spoilers, Show Nanokeys, or Show Datacubes.";

        SpawnDatacubePlaintext(vectm(2801.546387, 171.028091, 2545.382813), rotm(0,0,0), text, true);
    }
}
