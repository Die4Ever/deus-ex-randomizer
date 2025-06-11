class DXRMissionsM08 extends DXRMissions;

    var vector assaultLocations[20];
    var int numAssaultLocations;


function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2, bar1, bar2;
    local bool bMemes;

    bMemes = class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags);

    AddGoal("08_NYC_Bar", "Harley Filben", GOAL_TYPE1, 'HarleyFilben0', PHYS_Falling);
    goal = AddGoal("08_NYC_Bar", "Vinny", GOAL_TYPE1, 'NathanMadison0', PHYS_Falling);
    //AddGoalActor(goal, 1, 'SandraRenton0', PHYS_Falling); TODO: move Sandra with Vinny?
    //AddGoalActor(goal, 2, 'CoffeeTable0', PHYS_Falling);
    AddGoal("08_NYC_FreeClinic", "Joe Greene", GOAL_TYPE1, 'JoeGreene0', PHYS_Falling);

    AddGoalLocation("08_NYC_Street", "Hotel Roof", START_LOCATION | VANILLA_START | GOAL_TYPE1, vect(-354.250427, 795.071594, 594.411743), rot(0, -18600, 0));
    bar1 = AddGoalLocation("08_NYC_Bar", "Bar Table", GOAL_TYPE1 | VANILLA_GOAL | SITTING_GOAL, vect(-1689.125122, 337.159912, 63.599533), rot(0,-10144,0));
    bar2 = AddGoalLocation("08_NYC_Bar", "Bar", GOAL_TYPE1 | VANILLA_GOAL, vect(-931.038086, -488.537109, 47.600464), rot(0,9536,0));
    AddMutualExclusion(bar1, bar2);
    AddGoalLocation("08_NYC_FreeClinic", "Clinic", GOAL_TYPE1 | VANILLA_GOAL, vect(-115, -270, -272.399506), rot(0,31640,0));
    AddGoalLocation("08_NYC_Underground", "Sewers", GOAL_TYPE1, vect(591.048462, -152.517639, -560.397888), rot(0,32768,0));
    AddGoalLocation("08_NYC_Hotel", "Hotel", GOAL_TYPE1 | SITTING_GOAL, vect(-108.541245, -2709.490479, 111.600838), rot(0,20000,0));
    AddGoalLocation("08_NYC_Street", "Basketball Court", GOAL_TYPE1 | START_LOCATION, vect(2694.934082, -2792.844971, -448.396637), rot(0,32768,0));

    AddGoal("08_NYC_Street", "Jock", GOAL_TYPE2, 'BlackHelicopter0', PHYS_None);
    AddGoalLocation("08_NYC_Street", "Hotel Roof", GOAL_TYPE2 | VANILLA_GOAL, vect(75,965,755), rot(0, 22824, 0));
    AddGoalLocation("08_NYC_Street", "Bar Entrance", GOAL_TYPE2, vect(-180,-1675,-325), rot(0, 0, 0));
    if(bMemes) {
        AddGoalLocation("08_NYC_Street", "Smuggler Back Entrance", GOAL_TYPE2, vect(3010,-4285,-470), rot(0, 23416, 0));
        AddGoalLocation("08_NYC_Street", "Alley", GOAL_TYPE2, vect(-2222,-770,-390), rot(0, 0, 0));
    }

    //The MJ12 assault squads now get randomized as two squads of 5 (as they were split in non-GOTY)
    AddGoal("08_NYC_Street", "MJ12 Assault Squad 1", GOAL_TYPE3 | ALWAYS_CREATE, 'Van0', PHYS_None);
    AddGoal("08_NYC_Street", "MJ12 Assault Squad 2", GOAL_TYPE3 | ALWAYS_CREATE, 'Van1', PHYS_None);
    AddGoalLocation("08_NYC_Street", "Alley", GOAL_TYPE3 | VANILLA_GOAL, vect(-1893.816406,-614.223816,-445.429260), rot(0, -32616, 0));
    AddGoalLocation("08_NYC_Street", "Road to NSF HQ", GOAL_TYPE3 | VANILLA_GOAL, vect(-1758.505249,-1704.474976,-445.434998), rot(0, 32832, 0));
    AddGoalLocation("08_NYC_Street", "Basketball Court", GOAL_TYPE3, vect(2914,-3000,-429), rot(0, 7200, 0));
    AddGoalLocation("08_NYC_Street", "Smuggler Front Door", GOAL_TYPE3, vect(2292.625977,-1448.627441,-445.429016), rot(0, 0, 0));
    AddGoalLocation("08_NYC_Street", "Hotel", GOAL_TYPE3, vect(1005.300781,201.109436,-445.432312), rot(0, -16240, 0));

    if (dxr.flags.settings.starting_map >= 81) //Mission 8 Smuggler
    {
        skip_rando_start = True;
    }

    return 81;
}

function int InitGoalsRev(int mission, string map)
{
    local int goal, loc, loc2, bar1, bar2;
    local bool bMemes;

    bMemes = class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags);

    AddGoal("08_NYC_Bar", "Harley Filben", NORMAL_GOAL, 'HarleyFilben0', PHYS_Falling);
    goal = AddGoal("08_NYC_Bar", "Vinny", NORMAL_GOAL, 'NathanMadison0', PHYS_Falling);
    //AddGoalActor(goal, 1, 'SandraRenton0', PHYS_Falling); TODO: move Sandra with Vinny?
    //AddGoalActor(goal, 2, 'CoffeeTable0', PHYS_Falling);
    AddGoal("08_NYC_FreeClinic", "Joe Greene", NORMAL_GOAL, 'JoeGreene0', PHYS_Falling);

    AddGoalLocation("08_NYC_Street", "Hotel Roof", START_LOCATION | VANILLA_START | NORMAL_GOAL, vect(-462.25,856,634.4), rot(0, -18600, 0));
    bar1 = AddGoalLocation("08_NYC_Bar", "Bar Table", NORMAL_GOAL | VANILLA_GOAL | SITTING_GOAL, vect(-1394.78,727.7,95.6), rot(0,-10144,0));
    bar2 = AddGoalLocation("08_NYC_Bar", "Bar", NORMAL_GOAL | VANILLA_GOAL, vect(-556.6,-403.86,49.6), rot(0,41832,0));
    AddMutualExclusion(bar1, bar2);
    AddGoalLocation("08_NYC_FreeClinic", "Clinic", NORMAL_GOAL | VANILLA_GOAL, vect(1293.991211,-1226.047852,-239.399506), rot(0,31640,0));
    AddGoalLocation("08_NYC_Underground", "Sewers", NORMAL_GOAL, vect(591.048462, -152.517639, -560.397888), rot(0,32768,0));
    AddGoalLocation("08_NYC_Hotel", "Hotel", NORMAL_GOAL | SITTING_GOAL, vect(316,-3439,111), rot(0,0,0));
    loc = AddGoalLocation("08_NYC_Street", "Basketball Court", NORMAL_GOAL | START_LOCATION, vect(2683.1,-1977.77,-448), rot(0,-16390,0));
    loc2 = AddGoalLocation("08_NYC_Street", "Apartment Over Basketball Court", NORMAL_GOAL , vect(2690,-1750,50), rot(0,-16390,0)); //Revision Only
    AddGoalLocation("08_NYC_Street", "Garage Roof", NORMAL_GOAL , vect(750,-2875,-250), rot(0,32768,0)); //Revision Only
    AddGoalLocation("08_NYC_Street", "Smuggler's Front Entrance", NORMAL_GOAL , vect(4780,-3475,-380), rot(0,16384,0)); //Revision Only
    AddMutualExclusion(loc, loc2); //Can't use both the basketball court and apartment over the court

    AddGoal("08_NYC_Street", "Jock", GOAL_TYPE2, 'JockHelicopter0', PHYS_None);
    AddGoalLocation("08_NYC_Street", "Hotel Roof", GOAL_TYPE2 | VANILLA_GOAL, vect(75,965,755), rot(0, 22824, 0));
    AddGoalLocation("08_NYC_Street", "Bar Entrance", GOAL_TYPE2, vect(-400,-1675,-325), rot(0, 0, 0));
    if(bMemes) {
        AddGoalLocation("08_NYC_Street", "Smuggler Back Entrance", GOAL_TYPE2, vect(4775,580,-330), rot(0, 0, 0));
        AddGoalLocation("08_NYC_Street", "Garage Back Lot", GOAL_TYPE2, vect(1940,-3020,-350), rot(0, 8000, 0));
    }

    //The MJ12 assault squads now get randomized as a squad of 8 and a squad of 7
    AddGoal("08_NYC_Street", "MJ12 Assault Squad 1", GOAL_TYPE3 | ALWAYS_CREATE, 'Van90', PHYS_None);
    AddGoal("08_NYC_Street", "MJ12 Assault Squad 2", GOAL_TYPE3 | ALWAYS_CREATE, 'Van91', PHYS_None);
    AddGoalLocation("08_NYC_Street", "Alley", GOAL_TYPE3 | VANILLA_GOAL, vect(-910,-1230,-445), rot(0, 0, 0));
    AddGoalLocation("08_NYC_Street", "Road to NSF HQ", GOAL_TYPE3 | VANILLA_GOAL, vect(-744,-3530,-445), rot(0, -8016, 0));
    AddGoalLocation("08_NYC_Street", "Basketball Court", GOAL_TYPE3, vect(2855,-1965,-430), rot(0, 16325, 0));
    AddGoalLocation("08_NYC_Street", "Smuggler Front Door", GOAL_TYPE3, vect(4200,-3450,-437), rot(0, 32768, 0));
    AddGoalLocation("08_NYC_Street", "Hotel", GOAL_TYPE3, vect(1200,420,-445), rot(0, 0, 0));

    if (dxr.flags.settings.starting_map >= 81) //Mission 8 Smuggler
    {
        skip_rando_start = True;
    }

    return 81;
}

function CreateGoal(out Goal g, GoalLocation Loc)
{
    local #var(prefix)ScriptedPawn sp;
    local #var(prefix)Van van;

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

    case "MJ12 Assault Squad 1":
    case "MJ12 Assault Squad 2":
        van = #var(prefix)Van(Spawnm(class'#var(prefix)Van',, 'DXRMissions', Loc.positions[0].pos,Loc.positions[0].rot));
        g.actors[0].a = van;
        van.FamiliarName=PickSurveillanceVanName();
        van.UnfamiliarName=van.FamiliarName;
        van.bIsSecretGoal=True;
        break;
    }
}

function String PickSurveillanceVanName()
{
    switch(Rand(8)){
        case 0:
            return "Flower Delivery Van";
        case 1:
            return "Ice Cream Truck";
        case 2:
            return "Pest Control Van";
        case 3:
            return "Phone Company Van";
        case 4:
            return "The Cleaners";
        case 5:
            return "Milk Delivery Truck";
        case 6:
            return "Ordinary Van";
        case 7:
            return "Black Van Pizza";
    }
}

function AnyEntry()
{
    Super.AnyEntry();

    switch(dxr.localURL)
    {
    case "08_NYC_STREET":
        UpdateGoalWithRandoInfo('FindHarleyFilben', "Harley could be anywhere in Hell's Kitchen");
        break;
    }

    UpdateGoalWithRandoInfo('KillGreene', "Joe Greene could be anywhere.");
}

function AfterMoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    if (g.name=="Jock") {
        if((!RevisionMaps && Loc.name=="Smuggler Back Entrance") || Loc.name=="Alley") {
            g.actors[0].a.DrawScale = 0.5;
            g.actors[0].a.SetCollisionSize(200, 50);
        } else {
            g.actors[0].a.DrawScale = 1;
            g.actors[0].a.SetCollisionSize(320, 87);
        }
        g.actors[0].a.SoundRadius = 255;// this is a byte, FLOAT WorldSoundRadius() const {return 25.0 * ((int)SoundRadius+1);}
    }
}

function AfterMovePlayerToStartLocation(GoalLocation Loc)
{
    local #var(prefix)InterpolateTrigger it;

    if (Loc.name!="Hotel Roof") {
        foreach AllActors(class'#var(prefix)InterpolateTrigger', it) {
            if(it.Event=='EntranceCopter') it.Trigger(self, None);
        }
    }
}

function AfterShuffleGoals(int goalsToLocations[32])
{
    local int g, numGuys,perSquad;

    if (dxr.localURL == "08_NYC_STREET"){
        numGuys=GetTotalNumAssaultSquadTroops();
        perSquad = Ceil(float(numGuys)/2.0);

        l("Need to get locations for "$numGuys$" guys, "$perSquad$" in each squad");

        numAssaultLocations=0;
        for(g=0; g<num_goals; g++) {
            if((goals[g].name == "MJ12 Assault Squad 1") || (goals[g].name == "MJ12 Assault Squad 2")) {
                AddAssaultSquadLocations(locations[goalsToLocations[g]].name, perSquad);
            }
        }
        MoveAssaultSquads();
    }
}

function AddSingleLocation(Vector loc, out int numAdded, int totalNum)
{
    if (numAdded>=totalNum) return;

    if (numAssaultLocations>=ArrayCount(assaultLocations)){
        l("Trying to add more assault squad locations than available in the array!");
        return;
    }

    assaultLocations[numAssaultLocations++]=loc;
    numAdded++;

    l("Added Assault Squad Location "$loc);

    return;
}

function AddAssaultSquadLocations(string locName, int numLocs)
{
    local bool RevisionMaps;
    local int numAdded;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    numAdded=0;

    if (!RevisionMaps){
        switch(locName){
            case "Alley": //Non-GOTY Squad 1 vanilla location
                AddSingleLocation(vectm(-2086,-706,-426),numAdded,numLocs);
                AddSingleLocation(vectm(-2041,-761,-426),numAdded,numLocs);
                AddSingleLocation(vectm(-1886,-719,-426),numAdded,numLocs);
                AddSingleLocation(vectm(-1849,-779,-426),numAdded,numLocs);
                AddSingleLocation(vectm(-1692,-695,-426),numAdded,numLocs);
                break;
            case "Road to NSF HQ": //Non-GOTY Squad 2 vanilla location
                AddSingleLocation(vectm(-1907,-1534,-434),numAdded,numLocs);
                AddSingleLocation(vectm(-1856,-1584,-434),numAdded,numLocs);
                AddSingleLocation(vectm(-1817,-1497,-441),numAdded,numLocs);
                AddSingleLocation(vectm(-1693,-1494,-452),numAdded,numLocs);
                AddSingleLocation(vectm(-1577,-1585,-438),numAdded,numLocs);
                break;
            case "Basketball Court":
                AddSingleLocation(vectm(2450, -2400, -448),numAdded,numLocs);
                AddSingleLocation(vectm(2550, -2400, -448),numAdded,numLocs);
                AddSingleLocation(vectm(2650, -2400, -448),numAdded,numLocs);
                AddSingleLocation(vectm(2490, -2500, -448),numAdded,numLocs);
                AddSingleLocation(vectm(2600, -2500, -448),numAdded,numLocs);
                break;
            case "Smuggler Front Door":
                AddSingleLocation(vectm(2552,-1108,-464),numAdded,numLocs);
                AddSingleLocation(vectm(2536,-1038,-464),numAdded,numLocs);
                AddSingleLocation(vectm(2483,-1129,-464),numAdded,numLocs);
                AddSingleLocation(vectm(2491,-1043,-464),numAdded,numLocs);
                AddSingleLocation(vectm(2444,-1094,-464),numAdded,numLocs);
                break;
            case "Hotel":
                AddSingleLocation(vectm(1246,453,-464),numAdded,numLocs);
                AddSingleLocation(vectm(1170,398,-464),numAdded,numLocs);
                AddSingleLocation(vectm(1238,340,-464),numAdded,numLocs);
                AddSingleLocation(vectm(1177,289,-464),numAdded,numLocs);
                AddSingleLocation(vectm(1234,229,-464),numAdded,numLocs);
                break;
        }
    } else { //Revision Maps
        //Revision has 15 guys total, but the number depends on the difficulty
        //Currently still splitting them into two groups
        //Difficulty 0: 4 guys
        //Difficulty 1: 6 guys
        //Difficulty 2: 11 guys
        //Difficulty 3: 15 guys
        switch(locName){
            case "Alley":
                AddSingleLocation(vectm(-1650,-650,-450),numAdded,numLocs);
                AddSingleLocation(vectm(-1650,-700,-450),numAdded,numLocs);
                AddSingleLocation(vectm(-1650,-750,-450),numAdded,numLocs);
                AddSingleLocation(vectm(-1650,-800,-450),numAdded,numLocs);
                AddSingleLocation(vectm(-1600,-750,-450),numAdded,numLocs);
                AddSingleLocation(vectm(-1600,-800,-450),numAdded,numLocs);
                AddSingleLocation(vectm(-1550,-750,-450),numAdded,numLocs);
                AddSingleLocation(vectm(-1550,-800,-450),numAdded,numLocs);
                break;
            case "Road to NSF HQ":
                AddSingleLocation(vectm(-1250,-2750,-460),numAdded,numLocs);
                AddSingleLocation(vectm(-1250,-2800,-460),numAdded,numLocs);
                AddSingleLocation(vectm(-1250,-2850,-460),numAdded,numLocs);
                AddSingleLocation(vectm(-1250,-2900,-460),numAdded,numLocs);
                AddSingleLocation(vectm(-1250,-2950,-460),numAdded,numLocs);
                AddSingleLocation(vectm(-1250,-3000,-460),numAdded,numLocs);
                AddSingleLocation(vectm(-1250,-3050,-460),numAdded,numLocs);
                AddSingleLocation(vectm(-1250,-3100,-460),numAdded,numLocs);
                break;
            case "Basketball Court":
                AddSingleLocation(vectm(2900,-2350,-460),numAdded,numLocs);
                AddSingleLocation(vectm(2850,-2350,-460),numAdded,numLocs);
                AddSingleLocation(vectm(2800,-2350,-460),numAdded,numLocs);
                AddSingleLocation(vectm(2750,-2350,-460),numAdded,numLocs);
                AddSingleLocation(vectm(2700,-2350,-460),numAdded,numLocs);
                AddSingleLocation(vectm(2650,-2350,-460),numAdded,numLocs);
                AddSingleLocation(vectm(2600,-2350,-460),numAdded,numLocs);
                AddSingleLocation(vectm(2550,-2350,-460),numAdded,numLocs);
                break;
            case "Smuggler Front Door":
                AddSingleLocation(vectm(4300,-3000,-460),numAdded,numLocs);
                AddSingleLocation(vectm(4300,-2950,-460),numAdded,numLocs);
                AddSingleLocation(vectm(4300,-2900,-460),numAdded,numLocs);
                AddSingleLocation(vectm(4300,-2850,-460),numAdded,numLocs);
                AddSingleLocation(vectm(4300,-2800,-460),numAdded,numLocs);
                AddSingleLocation(vectm(4200,-2800,-460),numAdded,numLocs);
                AddSingleLocation(vectm(4200,-2850,-460),numAdded,numLocs);
                AddSingleLocation(vectm(4200,-2900,-460),numAdded,numLocs);
                break;
            case "Hotel":
                AddSingleLocation(vectm(1400,500,-460),numAdded,numLocs);
                AddSingleLocation(vectm(1400,450,-460),numAdded,numLocs);
                AddSingleLocation(vectm(1400,400,-460),numAdded,numLocs);
                AddSingleLocation(vectm(1400,350,-460),numAdded,numLocs);
                AddSingleLocation(vectm(1400,300,-460),numAdded,numLocs);
                AddSingleLocation(vectm(1400,250,-460),numAdded,numLocs);
                AddSingleLocation(vectm(1400,200,-460),numAdded,numLocs);
                AddSingleLocation(vectm(1400,150,-460),numAdded,numLocs);
                break;
        }
    }
}

function MoveAssaultSquads()
{
    local int i;
    local MJ12Troop t;

    i=0;
    foreach AllActors(class'MJ12Troop',t,'MJ12AttackForce'){
        t.WorldPosition = assaultLocations[i];
        t.SetLocation(assaultLocations[i++]+vectm(0,0,20000));
    }
}

function int GetTotalNumAssaultSquadTroops()
{
    local int i;
    local MJ12Troop t;

    i=0;
    foreach AllActors(class'MJ12Troop',t,'MJ12AttackForce'){ i++; }

    return i;
}


function PreFirstEntryMapFixes()
{
    local #var(prefix)InterpolateTrigger it;
    local #var(prefix)Van v;
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    if (RevisionMaps && dxr.localURL=="08_NYC_STREET"){
        foreach AllActors(class'#var(prefix)InterpolateTrigger',it,'FlyInTrigger'){
            it.Destroy();
        }

        //Get rid of the existing vans,
        //we'll spawn new ones to mark the assault squad spawn points
        foreach AllActors(class'#var(prefix)Van', v){
            v.Destroy();
        }
    }
}
