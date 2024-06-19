class DXRMissionsM03 extends DXRMissions;


function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2;

    switch(map) {
    case "03_NYC_BATTERYPARK":
        AddGoal("03_NYC_BATTERYPARK", "Harley Filben", NORMAL_GOAL, 'HarleyFilben0', PHYS_Falling);
        goal = AddGoal("03_NYC_BATTERYPARK", "Curly", NORMAL_GOAL, 'BumMale4', PHYS_Falling);
        AddGoalActor(goal, 1, 'BumFemale2', PHYS_Falling);

        AddGoalLocation("03_NYC_BATTERYPARK", "Jock", START_LOCATION | VANILLA_START, vect(-1226.699951, 2215.864258, 400.663818), rot(0, -25672, 0));

        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Castle Clinton Entrance", NORMAL_GOAL | START_LOCATION, vect(1082.374023, 1458.807617, 334.248260), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(1161.899657, 1559.100464, 331.741821), rot(0,0,0));

        AddGoalLocation("03_NYC_BATTERYPARK", "Ventilation System", START_LOCATION, vect(-4340.930664, 2332.365234, 244.506165), rot(0, 0, 0));
        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Eagle Statue", NORMAL_GOAL | START_LOCATION, vect(-2968.101563, -1407.404419, 334.242554), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-2888.101563, -1307.404419, 332.242554), rot(0,0,0));

        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Dock", NORMAL_GOAL | START_LOCATION, vect(-1079.890625, -3412.052002, 270.581390), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-999.890625, -3312.052002, 268), rot(0,0,0));

        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Hut", NORMAL_GOAL | VANILLA_GOAL, vect(-2763.231689,1370.594604,373.603882), rot(0,7272,0));
        AddActorLocation(loc, 1, vect(-2683.231689, 1470.594604, 371), rot(0,0,0));

        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Subway", NORMAL_GOAL | VANILLA_GOAL | START_LOCATION, vect(-4819.345215,3478.138916,-304.225006), rot(0,0,0));
        AddActorLocation(loc, 1, vect(-4739.345215, 3578.138916, -306), rot(0,0,0));

        if (dxr.flags.settings.starting_map > 32)
        {
            skip_rando_start = True;
        }

        return 31;

    case "03_NYC_BROOKLYNBRIDGESTATION":
        // GOAL_TYPE1 is only for people that can safely go up into the Rooks territory
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Rock (Drug Dealer)", NORMAL_GOAL, 'ThugMale13', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Lenny (Junkie)", NORMAL_GOAL | GOAL_TYPE1, 'JunkieMale1', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Charlie", NORMAL_GOAL | GOAL_TYPE1, 'BumMale2', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "El Rey", NORMAL_GOAL | GOAL_TYPE1, 'ThugMale3', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Ex-Mole Person", NORMAL_GOAL | GOAL_TYPE1, 'BumMale3', PHYS_Falling);
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Water pipes", NORMAL_GOAL, vect(2893.466064, -4513.004395, 104.099274), rot(0, 0, 0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Rooks East Side", GOAL_TYPE1, vect(1755.025391, -847.637695, 382.144287), rot(0, 0, 0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Men's Restroom", NORMAL_GOAL | VANILLA_GOAL, vect(-1248.503662,-2870.117432,109.675003), rot(0,-21080,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Rooks West Side", GOAL_TYPE1 | VANILLA_GOAL, vect(-2978.629639,-2281.836670,415.774994), rot(0,0,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "SE Corner", NORMAL_GOAL | VANILLA_GOAL, vect(975.220337,1208.224854,111.775002), rot(0,-22408,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "NE Corner", NORMAL_GOAL | VANILLA_GOAL, vect(1003.048767,-2519.280762,111.775002), rot(0,13576,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "NW Corner", NORMAL_GOAL | VANILLA_GOAL, vect(-988.025696,-3381.119385,111.775002), rot(0,-22608,0));
        return 32;

    case "03_NYC_AIRFIELD":
        AddGoal("03_NYC_AIRFIELD", "Terrorist with the East Gate key", NORMAL_GOAL, 'Terrorist13', PHYS_Falling);
        loc=AddGoalLocation("03_NYC_AIRFIELD", "South Gate", NORMAL_GOAL, vect(223.719452, 3689.905273, 15.100115), rot(0, 0, 0));
        AddMapMarker(class'Image03_NYC_Airfield',324,270,"K","East Gate Key", loc,"The terrorist with the key to the East Gate can be located at the South Gate in the airfield.");
        loc=AddGoalLocation("03_NYC_AIRFIELD", "SW Security Tower", NORMAL_GOAL, vect(-2103.891113, 3689.706299, 15.091076), rot(0, 0, 0));
        AddMapMarker(class'Image03_NYC_Airfield',303,361,"K","East Gate Key", loc,"The terrorist with the key to the East Gate can be located outside the South West Security Tower in the airfield.");
        loc=AddGoalLocation("03_NYC_AIRFIELD", "West Security Tower", NORMAL_GOAL, vect(-2060.626465, -2013.138672, 15.090023), rot(0, 0, 0));
        AddMapMarker(class'Image03_NYC_Airfield',100,290,"K","East Gate Key", loc,"The terrorist with the key to the East Gate can be located outside the West Security Tower in the airfield.");
        loc=AddGoalLocation("03_NYC_AIRFIELD", "NW Security Tower", NORMAL_GOAL, vect(729.454651, -4151.924805, 15.079981), rot(0, 0, 0));
        AddMapMarker(class'Image03_NYC_Airfield',79,162,"K","East Gate Key", loc,"The terrorist with the key to the East Gate can be located outside the North West Security Tower in the airfield.");
        loc=AddGoalLocation("03_NYC_AIRFIELD", "NE Security Tower", NORMAL_GOAL, vect(5215.076660, -4134.674316, 15.090023), rot(0, 0, 0));
        AddMapMarker(class'Image03_NYC_Airfield',128,49,"K","East Gate Key", loc,"The terrorist with the key to the East Gate can be located outside the North East Security Tower in the airfield.");
        loc=AddGoalLocation("03_NYC_AIRFIELD", "Hangar Door", NORMAL_GOAL, vect(941.941895, 283.418152, 15.090023), rot(0, 0, 0));
        AddMapMarker(class'Image03_NYC_Airfield',232,213,"K","East Gate Key", loc,"The terrorist with the key to the East Gate can be located outside the hangar doors in the airfield.");
        loc=AddGoalLocation("03_NYC_AIRFIELD", "Dock", NORMAL_GOAL | VANILLA_GOAL, vect(-2687.128662,2320.010986,63.774998), rot(0,0,0));
        AddMapMarker(class'Image03_NYC_Airfield',257,354,"K","East Gate Key", loc,"The terrorist with the key to the East Gate can be located on the docks at the airfield.  This is the vanilla location.");

        goal = AddGoal("03_NYC_AIRFIELD", "Ambrosia", GOAL_TYPE1, 'BarrelAmbrosia0', PHYS_Falling);
        AddGoalActor(goal,1,'FlagTrigger0',PHYS_None); //Reduced radius, sets BoatDocksAmbrosia
        loc=AddGoalLocation("03_NYC_AIRFIELD", "Docks", GOAL_TYPE1 | VANILLA_GOAL, vect(-2482.986816,1924.479126,44.869865), rot(0,0,0));
        AddMapMarker(class'Image03_NYC_Airfield',241,354,"A","Ambrosia", loc,"A barrel of Ambrosia can be located on the docks in the airfield.  This is a vanilla location.");
        loc=AddGoalLocation("03_NYC_AIRFIELD", "Hangar Door", GOAL_TYPE1, vect(1069,289,45), rot(0,16328,0));
        AddMapMarker(class'Image03_NYC_Airfield',213,204,"A","Ambrosia", loc,"A barrel of Ambrosia can be located in the airfield in front of the main hangar doors.");
        loc=AddGoalLocation("03_NYC_AIRFIELD", "Near Electrical", GOAL_TYPE1, vect(5317,-2405,45), rot(0,16328,0));
        AddMapMarker(class'Image03_NYC_Airfield',172,55,"A","Ambrosia", loc,"A barrel of Ambrosia can be located near the electrical area in the airfield.");
        loc=AddGoalLocation("03_NYC_AIRFIELD", "Near Satellite", GOAL_TYPE1, vect(5317,3189,45), rot(0,16328,0));
        AddMapMarker(class'Image03_NYC_Airfield',339,106,"A","Ambrosia", loc,"A barrel of Ambrosia can be located near the satellite dish in the airfield, outside the barracks.");
        loc=AddGoalLocation("03_NYC_AIRFIELD", "Cargo Container", GOAL_TYPE1, vect(-220,3012,373), rot(0,25344,0));
        AddMapMarker(class'Image03_NYC_Airfield',298,280,"A","Ambrosia", loc,"A barrel of Ambrosia can be located inside a cargo container in the airfield.");

        return 33;

    case "03_NYC_AIRFIELDHELIBASE":
        goal = AddGoal("03_NYC_AIRFIELDHELIBASE", "Ambrosia", NORMAL_GOAL, 'BarrelAmbrosia1', PHYS_Falling);
        AddGoalActor(goal,1,'FlagTrigger0',PHYS_None); //Reduced radius, sets HelicopterBaseAmbrosia

        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Main Entrance", NORMAL_GOAL | VANILLA_GOAL, vect(47.421066,1102.545044,40.869644), rot(0,0,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Womens Bathroom", NORMAL_GOAL, vect(1362,677,41), rot(0,32872,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Office", NORMAL_GOAL, vect(-1403,215,41), rot(0,49152,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Secret Room", NORMAL_GOAL, vect(-1149,626,215), rot(0,81896,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Helipad", NORMAL_GOAL, vect(508,-399,192), rot(0,71560,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Catwalk", NORMAL_GOAL, vect(1394,-1221,800), rot(0,71560,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Break Room", NORMAL_GOAL, vect(895,1257,206), rot(0,32856,0));

        return 34;

    case "03_NYC_747":
    case "03_NYC_HANGAR":
        goal = AddGoal("03_NYC_747", "747 Ambrosia", NORMAL_GOAL, 'BarrelAmbrosia1', PHYS_Falling);
        AddGoalActor(goal,1,'FlagTrigger1',PHYS_None); //Reduced radius, sets 747Ambrosia

        loc=AddGoalLocation("03_NYC_747", "Cargo", NORMAL_GOAL | VANILLA_GOAL, vect(-147.147064,-511.348846,158.870544), rot(0,15760,0));
        AddMapMarker(class'Image03_747Diagram',34,66,"A","Ambrosia", loc,"A barrel of Ambrosia can be located in the cargo hold of the 747.  This is one of the vanilla Ambrosia locations.");
        loc=AddGoalLocation("03_NYC_747", "Office", NORMAL_GOAL, vect(6,-736,339), rot(0,-32,0));
        AddMapMarker(class'Image03_747Diagram',89,163,"A","Ambrosia", loc,"A barrel of Ambrosia can be located in the office on board the 747.");
        loc=AddGoalLocation("03_NYC_747", "Flight Deck", NORMAL_GOAL, vect(1339,-513,484), rot(0,16480,0));
        AddMapMarker(class'Image03_747Diagram',298,321,"A","Ambrosia", loc,"A barrel of Ambrosia can be located on the flight deck of the 747.");
        loc=AddGoalLocation("03_NYC_747", "Bedroom", NORMAL_GOAL, vect(1594,-710,368), rot(0,0,0));
        AddMapMarker(class'Image03_747Diagram',355,169,"A","Ambrosia", loc,"A barrel of Ambrosia can be located in the bedroom of the 747.");
        loc=AddGoalLocation("03_NYC_HANGAR", "Near Trailers", NORMAL_GOAL, vect(1867,-1318,29), rot(0,0,0));
        AddMapMarker(class'Image03_NYC_Airfield',230,155,"A","Ambrosia", loc,"A barrel of Ambrosia can be located near some trailers inside the hangar.");
        loc=AddGoalLocation("03_NYC_HANGAR", "Near Engine", NORMAL_GOAL, vect(4140,-1554,29), rot(0,32776,0));
        AddMapMarker(class'Image03_NYC_Airfield',225,76,"A","Ambrosia", loc,"A barrel of Ambrosia can be located near the engine of the 747 inside the hangar.");

        return 35;
    }

    return mission+1000;
}

function int InitGoalsRev(int mission, string map)
{
    local int goal, loc, loc2;

    switch(map) {
    case "03_NYC_BATTERYPARK":
        AddGoal("03_NYC_BATTERYPARK", "Harley Filben", NORMAL_GOAL, 'HarleyFilben0', PHYS_Falling);
        goal = AddGoal("03_NYC_BATTERYPARK", "Curly", NORMAL_GOAL, 'BumMale4', PHYS_Falling);
        AddGoalActor(goal, 1, 'BumFemale2', PHYS_Falling);

        AddGoalLocation("03_NYC_BATTERYPARK", "Jock", START_LOCATION | VANILLA_START, vect(942,2675,387), rot(0, -25672, 0));

        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Castle Clinton Entrance", NORMAL_GOAL | START_LOCATION, vect(1082.374023, 1458.807617, 334.248260), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(1161.899657, 1559.100464, 331.741821), rot(0,0,0));

        AddGoalLocation("03_NYC_BATTERYPARK", "Ventilation System", START_LOCATION, vect(-4340.930664, 2332.365234, 244.506165), rot(0, 0, 0));
        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Eagle Statue", NORMAL_GOAL | START_LOCATION, vect(-2968.101563, -1407.404419, 334.242554), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-2888.101563, -1307.404419, 332.242554), rot(0,0,0));

        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Dock", NORMAL_GOAL | START_LOCATION, vect(-1079.890625, -3412.052002, 270.581390), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-999.890625, -3312.052002, 268), rot(0,0,0));

        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Hut", NORMAL_GOAL | VANILLA_GOAL, vect(-2763.231689,1370.594604,373.603882), rot(0,7272,0));
        AddActorLocation(loc, 1, vect(-2683.231689, 1470.594604, 371), rot(0,0,0));

        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Subway", NORMAL_GOAL | VANILLA_GOAL | START_LOCATION, vect(-4819.345215,3478.138916,-304.225006), rot(0,0,0));
        AddActorLocation(loc, 1, vect(-4739.345215, 3578.138916, -306), rot(0,0,0));

        if (dxr.flags.settings.starting_map > 32)
        {
            skip_rando_start = True;
        }

        return 31;

    case "03_NYC_BROOKLYNBRIDGESTATION":
        // GOAL_TYPE1 is only for people that can safely go up into the Rooks territory
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Rock (Drug Dealer)", NORMAL_GOAL, 'ThugMale13', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Lenny (Junkie)", NORMAL_GOAL | GOAL_TYPE1, 'JunkieMale1', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Charlie", NORMAL_GOAL | GOAL_TYPE1, 'BumMale2', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "El Rey", NORMAL_GOAL | GOAL_TYPE1, 'ThugMale3', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Ex-Mole Person", NORMAL_GOAL | GOAL_TYPE1, 'BumMale3', PHYS_Falling);
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Water pipes", NORMAL_GOAL, vect(2893.466064, -4513.004395, 104.099274), rot(0, 0, 0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Rooks East Side", GOAL_TYPE1, vect(1755.025391, -847.637695, 382.144287), rot(0, 0, 0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Men's Restroom", NORMAL_GOAL | VANILLA_GOAL, vect(-1248.503662,-2870.117432,109.675003), rot(0,-21080,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Rooks West Side", GOAL_TYPE1 | VANILLA_GOAL, vect(-2978.629639,-2281.836670,415.774994), rot(0,0,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "SE Corner", NORMAL_GOAL | VANILLA_GOAL, vect(975.220337,1208.224854,111.775002), rot(0,-22408,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "NE Corner", NORMAL_GOAL | VANILLA_GOAL, vect(1003.048767,-2519.280762,111.775002), rot(0,13576,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "NW Corner", NORMAL_GOAL | VANILLA_GOAL, vect(-988.025696,-3381.119385,111.775002), rot(0,-22608,0));
        return 32;

    case "03_NYC_AIRFIELD":
        AddGoal("03_NYC_AIRFIELD", "Terrorist with the East Gate key", NORMAL_GOAL, 'Terrorist13', PHYS_Falling);
        AddGoalLocation("03_NYC_AIRFIELD", "South Gate", NORMAL_GOAL, vect(223.719452, 3689.905273, 15.100115), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "SW Security Tower", NORMAL_GOAL, vect(-2103.891113, 3689.706299, 15.091076), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "West Security Tower", NORMAL_GOAL, vect(-2060.626465, -2013.138672, 15.090023), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "NW Security Tower", NORMAL_GOAL, vect(729.454651, -4151.924805, 15.079981), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "NE Security Tower", NORMAL_GOAL, vect(5215.076660, -4134.674316, 15.090023), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "Hangar Door", NORMAL_GOAL, vect(941.941895, 283.418152, 15.090023), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "Dock", NORMAL_GOAL | VANILLA_GOAL, vect(-2687.128662,2320.010986,63.774998), rot(0,0,0));

        goal = AddGoal("03_NYC_AIRFIELD", "Ambrosia", GOAL_TYPE1, 'BarrelAmbrosia0', PHYS_Falling);
        AddGoalActor(goal,1,'FlagTrigger0',PHYS_None); //Reduced radius, sets BoatDocksAmbrosia
        AddGoalLocation("03_NYC_AIRFIELD", "Docks", GOAL_TYPE1 | VANILLA_GOAL, vect(-2482.986816,1924.479126,44.869865), rot(0,0,0));
        AddGoalLocation("03_NYC_AIRFIELD", "Hangar Door", GOAL_TYPE1, vect(1069,289,45), rot(0,16328,0));
        AddGoalLocation("03_NYC_AIRFIELD", "Near Electrical", GOAL_TYPE1, vect(5317,-2405,45), rot(0,16328,0));
        AddGoalLocation("03_NYC_AIRFIELD", "Near Satellite", GOAL_TYPE1, vect(5317,3189,45), rot(0,16328,0));
        AddGoalLocation("03_NYC_AIRFIELD", "Cargo Container", GOAL_TYPE1, vect(-220,3012,373), rot(0,25344,0));

        return 33;

    case "03_NYC_AIRFIELDHELIBASE":
        goal = AddGoal("03_NYC_AIRFIELDHELIBASE", "Ambrosia", NORMAL_GOAL, 'BarrelAmbrosia1', PHYS_Falling);
        AddGoalActor(goal,1,'FlagTrigger0',PHYS_None); //Reduced radius, sets HelicopterBaseAmbrosia

        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Main Entrance", NORMAL_GOAL | VANILLA_GOAL, vect(47.421066,1102.545044,40.869644), rot(0,0,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Womens Bathroom", NORMAL_GOAL, vect(1362,677,41), rot(0,32872,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Office", NORMAL_GOAL, vect(-1403,215,41), rot(0,49152,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Secret Room", NORMAL_GOAL, vect(-1149,626,215), rot(0,81896,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Helipad", NORMAL_GOAL, vect(508,-399,192), rot(0,71560,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Catwalk", NORMAL_GOAL, vect(1394,-1221,800), rot(0,71560,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Break Room", NORMAL_GOAL, vect(895,1257,206), rot(0,32856,0));

        return 34;

    case "03_NYC_747":
    case "03_NYC_HANGAR":
        goal = AddGoal("03_NYC_747", "747 Ambrosia", NORMAL_GOAL, 'BarrelAmbrosia1', PHYS_Falling);
        AddGoalActor(goal,1,'FlagTrigger1',PHYS_None); //Reduced radius, sets 747Ambrosia

        AddGoalLocation("03_NYC_747", "Cargo", NORMAL_GOAL | VANILLA_GOAL, vect(-147.147064,-511.348846,158.870544), rot(0,15760,0));
        AddGoalLocation("03_NYC_747", "Office", NORMAL_GOAL, vect(6,-736,339), rot(0,-32,0));
        AddGoalLocation("03_NYC_747", "Flight Deck", NORMAL_GOAL, vect(1339,-513,484), rot(0,16480,0));
        AddGoalLocation("03_NYC_747", "Bedroom", NORMAL_GOAL, vect(1594,-710,368), rot(0,0,0));
        AddGoalLocation("03_NYC_HANGAR", "Near Trailers", NORMAL_GOAL, vect(1867,-1318,29), rot(0,0,0));
        AddGoalLocation("03_NYC_HANGAR", "Near Engine", NORMAL_GOAL, vect(4140,-1554,29), rot(0,32776,0));

        return 35;
    }

    return mission+1000;
}

function AnyEntry()
{
    Super.AnyEntry();

    switch(dxr.localURL) {
    case "03_NYC_BATTERYPARK":
        Player().StartDataLinkTransmission("dl_batterypark");
        break;
    }
}

function PreFirstEntryMapFixes()
{
    local FlagTrigger ft;
    local #var(prefix)Terrorist t;

    switch(dxr.localURL) {
    case "03_NYC_MOLEPEOPLE":
        Spawn(class'ExtinguishFireTrigger',,, vectm(0.0, -528.0, 18.0)).SetCollisionSize(60.0, 10.0); // mole people water
        break;

    case "03_NYC_AIRFIELDHELIBASE":
        foreach AllActors(class'FlagTrigger',ft){// probably ambrosia
            if (ft.Name=='FlagTrigger0'){
                ft.SetCollisionSize(150, ft.CollisionHeight);
            }
        }
        break;

    case "03_NYC_AIRFIELD":
        foreach AllActors(class'FlagTrigger',ft){// probably ambrosia
            if (ft.Name=='FlagTrigger0'){
                ft.SetCollisionSize(150, ft.CollisionHeight);
            }
        }
        foreach AllActors(class'#var(prefix)Terrorist', t, 'boatguard') {
            // don't swap this guy, he has the east gate key
            t.bVisionImportant = true;
            t.bIsSecretGoal = true;
        }
        break;

    case "03_NYC_747":
        foreach AllActors(class'FlagTrigger',ft){// probably ambrosia
            if (ft.Name=='FlagTrigger1'){
                ft.SetCollisionSize(100, ft.CollisionHeight);
            }
        }
        break;
    }
}

function MissionTimer()
{
    local FlagBase f;
    local int count;

    f = dxr.flagbase;

    switch(dxr.localURL) {
    case "03_NYC_HANGAR":
        // copied from Mission03.uc, check for Ambrosia Barrels being tagged
        if (!f.GetBool('Barrel3Checked'))
        {
            if (f.GetBool('747Ambrosia'))
            {
                count = 1;
                if (f.GetBool('HelicopterBaseAmbrosia'))
                    count++;
                if (f.GetBool('BoatDocksAmbrosia'))
                    count++;

                if (count == 1)
                    Player().StartDataLinkTransmission("DL_TaggedOne");
                else if (count == 2)
                    Player().StartDataLinkTransmission("DL_TaggedTwo");
                else if (count == 3)
                    Player().StartDataLinkTransmission("DL_TaggedThree");

                f.SetBool('Barrel3Checked', True,, 4);
            }
        }
        break;
    case "03_NYC_AIRFIELDHELIBASE":
        UpdateGoalWithRandoInfo('FindAmbrosiaBarrels', "The Ambrosia could be anywhere in the helibase or airfield.");
        break;
    case "03_NYC_AIRFIELD":
        UpdateGoalWithRandoInfo('LastBarrel747', "The last barrel of Ambrosia could be in the hangar or somewhere on the 747.");
        break;
    case "03_NYC_BROOKLYNBRIDGESTATION":
        UpdateGoalWithRandoInfo('TalkToCharlie', "Charlie could be anywhere in the station");
        UpdateGoalWithRandoInfo('KillDealer', "Rock could be anywhere in the station");
        break;
    }
}

function CreateGoal(out Goal g, GoalLocation Loc)
{
    local BarrelAmbrosia ambrosia;
    local FlagTrigger ft;
    local SkillAwardTrigger st;

    switch(g.name) {
    case "747 Ambrosia":
        ambrosia = BarrelAmbrosia(Spawnm(class'BarrelAmbrosia',, 'DXRMissions', Loc.positions[0].pos));
        ft = FlagTrigger(Spawnm(class'FlagTrigger',, '747BarrelUsed', Loc.positions[1].pos));
        st = SkillAwardTrigger(Spawnm(class'SkillAwardTrigger',, 'skills', Loc.positions[2].pos));
        g.actors[0].a = ambrosia;
        g.actors[1].a = ft;
        g.actors[2].a = st;

        //Nothing particularly special about the barrel, all the magic is in the FlagTrigger
        ambrosia.bPushable = False;

        ft.SetCollisionSize(100,40);
        ft.Event = 'skills';
        ft.bInitiallyActive = True;
        ft.bTriggerOnceOnly = True;
        ft.bSetFlag = True;
        ft.bTrigger = True;
        ft.flagExpiration = 999;
        ft.FlagName = '747Ambrosia';
        ft.flagValue = True;

        st.SetCollision(False,False,False);
        st.awardMessage="Goal Accomplishment Bonus";
        st.skillPointsAdded = 100;
        break;
    }
}
