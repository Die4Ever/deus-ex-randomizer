class DXRMissionsM01 extends DXRMissions;

function int InitGoals(int mission, string map)
{
    local int leo, unatco, pauldock, harleydock, electric, hut, jail, top, topofbase;
    local int boat_pauldock, boat_harleydock, boat_top, boat_hut;
    local bool bMemes;

    bMemes = class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags);

    leo = AddGoal("01_NYC_UNATCOISLAND", "Terrorist Commander", NORMAL_GOAL, 'TerroristCommander0', PHYS_Falling);
    AddGoalActor(leo, 1, 'DataLinkTrigger12', PHYS_None);
    AddGoalActor(leo, 2, 'SkillAwardTrigger6', PHYS_None);

    AddGoal("01_NYC_UNATCOISLAND", "Police Boat", GOAL_TYPE1, 'NYPoliceBoat0', PHYS_None);

    unatco = AddGoalLocation("01_NYC_UNATCOISLAND", "UNATCO HQ", START_LOCATION, vect(-6348.445313, 1912.637207, -111.428482), rot(0, 0, 0));
    hut = AddGoalLocation("01_NYC_UNATCOISLAND", "Hut", NORMAL_GOAL, vect(-2407.206787, 205.915558, -128.899979), rot(0, 30472, 0));
    electric = AddGoalLocation("01_NYC_UNATCOISLAND", "Electric Bunker", NORMAL_GOAL | START_LOCATION, vect(6552.227539, -3246.095703, -447.438049), rot(0, 0, 0));

    if(bMemes) {
        pauldock = AddGoalLocation("01_NYC_UNATCOISLAND", "South Dock", NORMAL_GOAL | VANILLA_START, vect(-4760.569824, 10430.811523, -280.674988), rot(0, -7040, 0));
        jail = AddGoalLocation("01_NYC_UNATCOISLAND", "Jail", NORMAL_GOAL | START_LOCATION, vect(2127.692139, -1774.869141, -149.140366), rot(0, -16159, 0));
    } else {
        pauldock = AddGoalLocation("01_NYC_UNATCOISLAND", "South Dock", VANILLA_START, vect(-4760.569824, 10430.811523, -280.674988), rot(0, -7040, 0));
        jail = AddGoalLocation("01_NYC_UNATCOISLAND", "Jail", START_LOCATION, vect(2127.692139, -1774.869141, -149.140366), rot(0, -16159, 0));
    }
    topofbase = AddGoalLocation("01_NYC_UNATCOISLAND", "Top of the Base", NORMAL_GOAL, vect(2980.058105, -669.242554, 1056.577271), rot(0, 0, 0));
    top = AddGoalLocation("01_nyc_unatcoisland", "Top of the Statue", NORMAL_GOAL | VANILLA_GOAL | START_LOCATION, vect(2931.230957, 27.495235, 2527.800049), rot(0, 14832, 0));
    harleydock = AddGoalLocation("01_NYC_UNATCOISLAND", "North Dock", NORMAL_GOAL | START_LOCATION, vect(4018,-10308,-256), rot(0, 22520, 0));
        AddActorLocation(harleydock, PLAYER_LOCATION, vect(1297.173096, -10257.972656, -287.428131), rot(0, 0, 0));

    //Boat locations
    boat_pauldock = AddGoalLocation("01_nyc_unatcoisland", "South Dock", GOAL_TYPE1 | VANILLA_GOAL , vect(-5122.414551, 10138.813477, -269.806213), rot(0, 0, 0));
    boat_harleydock = AddGoalLocation("01_nyc_unatcoisland", "North Dock", GOAL_TYPE1 , vect(4535.585938, -10046.186523, -269.806213), rot(0, 0, 0));
    if(bMemes) {
        boat_hut = AddGoalLocation("01_nyc_unatcoisland", "Behind UNATCO", GOAL_TYPE1 , vect(-4578.414551, 267.813477, 24.193787), rot(0, 0, 0));
        boat_top = AddGoalLocation("01_nyc_unatcoisland", "Top of the Statue", GOAL_TYPE1 , vect(3682.585449, 326, 2108.193848), rot(0, 0, 0));
    }

    // Leo vs start location mutual exclusions
    AddMutualExclusion(unatco, pauldock);
    AddMutualExclusion(unatco, hut);
    AddMutualExclusion(harleydock, electric);
    AddMutualExclusion(jail, topofbase);
    AddMutualExclusion(jail, hut);
    AddMutualExclusion(topofbase, top);

    // Leo vs boat mutual exclusions
    AddMutualExclusion(boat_pauldock, pauldock);
    AddMutualExclusion(boat_pauldock, unatco);
    AddMutualExclusion(boat_harleydock, harleydock);
    AddMutualExclusion(boat_harleydock, electric);
    if(bMemes) {
        AddMutualExclusion(boat_hut, hut);
        AddMutualExclusion(boat_hut, unatco);
        AddMutualExclusion(boat_hut, jail);
        AddMutualExclusion(boat_top, top);
        AddMutualExclusion(boat_top, topofbase);
    }

    if(bMemes) {
        AddMapMarker(class'Image01_LibertyIsland',156,364,"L","Terrorist Commander", pauldock,"Leo Gold, the terrorist commander, can be located on the South dock.  This is the location you would normally start the game.");
        AddMapMarker(class'Image01_LibertyIsland',235,147,"L","Terrorist Commander", jail,"Leo Gold, the terrorist commander, can be located inside the jail cell where Gunther is locked up.");
    }
    AddMapMarker(class'Image01_LibertyIsland',156,199,"L","Terrorist Commander", hut,"Leo Gold, the terrorist commander, can be located in the small hut in front of the statue.");
    AddMapMarker(class'Image01_LibertyIsland',318,140,"L","Terrorist Commander",electric,"Leo Gold, the terrorist commander, can be located in the back of the small bunker next to the statue.  He would be behind the malfunctioning electrical box.");
    AddMapMarker(class'Image01_LibertyIsland',239,15,"L","Terrorist Commander",harleydock,"Leo Gold, the terrorist commander, can be located on the North dock on the opposite side from the hut.");
    AddMapMarker(class'Image01_LibertyIsland',257,159,"L","Terrorist Commander",topofbase,"Leo Gold, the terrorist commander, can be located on the highest outside level of the base of the statue.");
    AddMapMarker(class'Image01_LibertyIsland',260,184,"L","Terrorist Commander",top,"Leo Gold, the terrorist commander, can be located in the command post at the top of the statue.  This is his vanilla location.");

    AddMapMarker(class'Image01_LibertyIsland',130,371,"B","Police Boat",boat_pauldock,"The police boat can be located at the South dock, where you normally start the game.  This is the vanilla location.");
    AddMapMarker(class'Image01_LibertyIsland',250,16,"B","Police Boat",boat_harleydock,"The police boat can be located at the North dock, near where Harley Filben is located.");
    if(bMemes) {
        AddMapMarker(class'Image01_LibertyIsland',281,179,"B","Police Boat",boat_top,"The police boat can be located floating off the side of an upper level of the statue.");
        AddMapMarker(class'Image01_LibertyIsland',121,200,"B","Police Boat",boat_hut,"The police boat can be located floating behind UNATCO HQ, near the small hut in front of the statue.");
    }

    return mission;
}

function int InitGoalsRev(int mission, string map)
{
    local int leo, unatco, pauldock, harleydock, electric, hut, jail, top, topofbase;
    local int boat_pauldock, boat_harleydock, boat_top, boat_hut;
    local bool bMemes;

    bMemes = class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags);

    leo = AddGoal("01_NYC_UNATCOISLAND", "Terrorist Commander", NORMAL_GOAL, 'TerroristCommander0', PHYS_Falling);
    AddGoalActor(leo, 1, 'DataLinkTrigger12', PHYS_None);
    AddGoalActor(leo, 2, 'SkillAwardTrigger6', PHYS_None);

    AddGoal("01_NYC_UNATCOISLAND", "Police Boat", GOAL_TYPE1, 'NYPoliceBoat0', PHYS_None);

    unatco = AddGoalLocation("01_NYC_UNATCOISLAND", "UNATCO HQ", START_LOCATION, vect(-6146.002930, 1748.501709, -87.000000), rot(0, 0, 0));
    if(bMemes) {
        pauldock = AddGoalLocation("01_NYC_UNATCOISLAND", "South Dock", NORMAL_GOAL | VANILLA_START, vect(-4728.569824, 9358.811523, -280.674988), rot(0, -7040, 0));
        jail = AddGoalLocation("01_NYC_UNATCOISLAND", "Jail", NORMAL_GOAL | START_LOCATION, vect(2127.692139, -1774.869141, -149.140366), rot(0, -16159, 0));
    } else {
        pauldock = AddGoalLocation("01_NYC_UNATCOISLAND", "South Dock", VANILLA_START, vect(-4728.569824, 9358.811523, -280.674988), rot(0, -7040, 0));
        jail = AddGoalLocation("01_NYC_UNATCOISLAND", "Jail", START_LOCATION, vect(2127.692139, -1774.869141, -149.140366), rot(0, -16159, 0));
    }
    hut = AddGoalLocation("01_NYC_UNATCOISLAND", "Hut", NORMAL_GOAL, vect(-2404,177,-83), rot(0, 30472, 0));
    electric = AddGoalLocation("01_NYC_UNATCOISLAND", "Electric Bunker", NORMAL_GOAL | START_LOCATION, vect(6552.227539, -3246.095703, -447.438049), rot(0, 0, 0));
    topofbase = AddGoalLocation("01_NYC_UNATCOISLAND", "Top of the Base", NORMAL_GOAL, vect(2980.058105, -669.242554, 1056.577271), rot(0, 0, 0));
    top = AddGoalLocation("01_NYC_UNATCOISLAND", "Top of the Statue", NORMAL_GOAL | VANILLA_GOAL | START_LOCATION, vect(2931.230957, 27.495235, 2527.800049), rot(0, 14832, 0));
    harleydock = AddGoalLocation("01_NYC_UNATCOISLAND", "North Dock", NORMAL_GOAL | START_LOCATION, vect(4205,-9811,-279), rot(0, 0, 0));
        AddActorLocation(harleydock, PLAYER_LOCATION, vect(1297.173096, -10257.972656, -287.428131), rot(0, 0, 0));

    //Boat locations
    boat_pauldock = AddGoalLocation("01_nyc_unatcoisland", "South Dock", GOAL_TYPE1 | VANILLA_GOAL, vect(-5023.598145,9131.867188,-269.806213), rot(0, 16192, 0));
    boat_harleydock = AddGoalLocation("01_nyc_unatcoisland", "North Dock", GOAL_TYPE1, vect(4471, -10046.186523, -269.806213), rot(0, 16192, 0));
    if(bMemes) {
        boat_top = AddGoalLocation("01_nyc_unatcoisland", "Top of the Statue", GOAL_TYPE1, vect(3682.585449, 231.813477, 2108.193848), rot(0, 16192, 0));
        boat_hut = AddGoalLocation("01_nyc_unatcoisland", "Behind UNATCO", GOAL_TYPE1, vect(-4571,135,24), rot(0, 16192, 0));
    }


    // Leo vs start location mutual exclusions
    AddMutualExclusion(unatco, pauldock);
    AddMutualExclusion(unatco, hut);
    AddMutualExclusion(harleydock, electric);
    AddMutualExclusion(jail, topofbase);
    AddMutualExclusion(jail, hut);
    AddMutualExclusion(topofbase, top);

    // Leo vs boat mutual exclusions
    AddMutualExclusion(boat_pauldock, pauldock);
    AddMutualExclusion(boat_pauldock, unatco);
    AddMutualExclusion(boat_harleydock, harleydock);
    AddMutualExclusion(boat_harleydock, electric);
    if(bMemes) {
        AddMutualExclusion(boat_hut, hut);
        AddMutualExclusion(boat_hut, unatco);
        AddMutualExclusion(boat_hut, jail);
        AddMutualExclusion(boat_top, top);
        AddMutualExclusion(boat_top, topofbase);
    }

    return mission;
}

function PreFirstEntryMapFixes()
{
    local #var(prefix)DataLinkTrigger dlt;
    local #var(prefix)OrdersTrigger ot;
    local #var(prefix)SkillAwardTrigger sat;

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

        //Increase the radius of the 750 points for reaching the top of the statue
        //This gets moved with Leo and needs to be bigger than his conversation trigger
        //which has a 140 invocation radius.
        foreach AllActors(class'#var(prefix)SkillAwardTrigger',sat){
            if (sat.skillPointsAdded==750){ //Reward for reaching top of statue
                sat.SetCollisionSize(250,sat.CollisionHeight);
                break;
            }
        }
    }
}

function AnyEntry()
{
    Super.AnyEntry();

    switch(dxr.localURL) {
    case "01_NYC_UNATCOHQ":
        if(class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) {
            UpdateGoalWithRandoInfo('GetToDock', "The boat could be anywhere.");
        } else {
            UpdateGoalWithRandoInfo('GetToDock', "The boat could be at either dock.");
        }
        break;
    }
}

function AddMissionGoals()
{
    local #var(PlayerPawn) p;
    local DeusExGoal newGoal;

    if(dxr.localURL != "01_NYC_UNATCOISLAND") return;

    //The MeetPaul conversation would normally give you several goals.
    //Give them manually instead of via that conversation.
    //Leo is not necessarily in the statue, so that goal text cannot be retrieved directly from the conversation.
    p = player();
    newGoal=p.AddGoal('DefeatNSFCommandCenter',True);
    newGoal.SetText("The NSF seem to be directing the attack from somewhere on the island.  Find the commander.");
    GiveGoalFromConv(p, 'RescueAgent', 'MeetPaul');
    GiveGoalFromConv(p, 'MeetFilben', 'MeetPaul');
}

function AfterMoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local string text;
    local bool bMemes;

    if(g.name == "Terrorist Commander") {
        // DataLinkTrigger 15ft wide, 4ft tall
        if(g.actors[1].a != None)
            g.actors[1].a.SetCollisionSize(240, 64);

        bMemes = class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags);
        if(bMemes && Loc.name != "Top of the Statue") {
            text = "I'm gonna go for a walk to clear my head."
                $ "|n|nI might be anywhere, like the hut in front of the statue, hanging out with Gunther in jail, or maybe I'll even sneak past UNATCO to hang out on the dock.";
        } else if(bMemes) {
            text = "I was thinking about going for a walk but I got lazy."
                $ "|n|nI could've been anywhere, like the hut in front of the statue, hanging out with Gunther in jail, or maybe even snuck past UNATCO to hang out on the dock.";
        } else if(Loc.name != "Top of the Statue") {
            text = "I'm gonna go for a walk to clear my head."
                $ "|n|nI might be anywhere, like the hut in front of the statue, or on the dock with Filben.";
        } else {
            text = "I was thinking about going for a walk but I got lazy."
                $ "|n|nI could've been anywhere, like the hut in front of the statue, or on the dock with Filben.";
        }
        text = text $ "|n-- Leo"
            $ "|n|nPS: You can see all my possible locations by clicking the Goal Locations button on your Goals screen."
            $ "|nIf you get really stuck then click on Show Spoilers, Show Nanokeys, or Show Datacubes.";

        SpawnDatacubePlaintext(vectm(2801.546387, 171.028091, 2545.382813), rotm(0,0,0,0), text, "LeoHintCube", true);

        if(ScriptedPawn(g.actors[0].a) != None) {
            RemoveFears(ScriptedPawn(g.actors[0].a));
        }
    }
}
