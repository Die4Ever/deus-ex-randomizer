class DXRMissionsParis extends DXRMissions;


function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2;

    switch(map) {
    case "10_PARIS_CATACOMBS_TUNNELS":
        AddGoal("10_PARIS_CATACOMBS_TUNNELS", "Agent Hela", NORMAL_GOAL, 'WIB0', PHYS_Falling);
        loc=AddGoalLocation("10_PARIS_CATACOMBS_TUNNELS", "Back of Bunker", NORMAL_GOAL | VANILLA_GOAL, vect(705.735596,-3802.420410,-281.812622), rot(0, 16384, 0));
        AddActorLocation(loc, 1, vect(802,-3736,-284), rot(0,0,0));
        AddMapMarker(class'Image10_Paris_CatacombsTunnels',59,155,"H","Agent Hela", loc,"Agent Hela can be located in her nest at the back of the MJ12 bunker.  She will have a copy of the sewer key with her.  This is her vanilla location.");
        loc=AddGoalLocation("10_PARIS_CATACOMBS_TUNNELS", "Back of Bunker Upper Level Ladder Side", NORMAL_GOAL, vect(923,-2907,-32), rot(0, 31936, 0));
        AddActorLocation(loc, 1, vect(880,-2980,-44), rot(0,0,0));
        AddMapMarker(class'Image10_Paris_CatacombsTunnels',97,137,"H","Agent Hela", loc,"Agent Hela can be located on the upper level at back of the MJ12 bunker, on the side with the ladder.  She will have a copy of the sewer key with her.");
        loc=AddGoalLocation("10_PARIS_CATACOMBS_TUNNELS", "Back of Bunker Upper Level Stair Side", NORMAL_GOAL, vect(-290,-2475,-32), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-240,-2420,-44), rot(0,0,0));
        AddMapMarker(class'Image10_Paris_CatacombsTunnels',97,195,"H","Agent Hela", loc,"Agent Hela can be located on the upper level at back of the MJ12 bunker, on the side with the stairs.  She will have a copy of the sewer key with her.");
        loc=AddGoalLocation("10_PARIS_CATACOMBS_TUNNELS", "Front of Bunker Side", NORMAL_GOAL, vect(-637,745,-256), rot(0, -16640, 0));
        AddActorLocation(loc, 1, vect(-440,730,-300), rot(0,0,0));
        AddMapMarker(class'Image10_Paris_CatacombsTunnels',248,205,"H","Agent Hela", loc,"Agent Hela can be located in the room off to the side at the front of the MJ12 bunker.  She will have a copy of the sewer key with her.");
        loc=AddGoalLocation("10_PARIS_CATACOMBS_TUNNELS", "Front of Bunker Upper Level", NORMAL_GOAL, vect(-1635,-82,-64), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-1640,-257,-82), rot(0,0,0));
        AddMapMarker(class'Image10_Paris_CatacombsTunnels',211,244,"H","Agent Hela", loc,"Agent Hela can be located in the room up the ramp at the front of the MJ12 bunker.  She will have a copy of the sewer key with her.");
        return 102;
    case "10_PARIS_METRO":
    case "10_PARIS_CLUB":
        AddGoal("10_PARIS_METRO", "Jaime", NORMAL_GOAL, 'JaimeReyes1', PHYS_Falling);
        AddGoal("10_PARIS_CLUB", "Nicolette", NORMAL_GOAL, 'NicoletteDuClare0', PHYS_Falling);
        loc=AddGoalLocation("10_PARIS_CLUB", "Club", NORMAL_GOAL | VANILLA_GOAL | SITTING_GOAL, vect(-673.488708, -1385.685059, 43.097466), rot(0, 17368, 0));
        AddMapMarker(class'Image10_Paris_Metro',250,256,"P","Nicolette/Jaime", loc,"Nicolette or Jaime can be located upstairs in the club.  This is Nicolette's vanilla location.");
        loc=AddGoalLocation("10_PARIS_CLUB", "Back Room TV", NORMAL_GOAL, vect(-1939.340942, -478.474091, -180.899628), rot(0, -16384, 0));
        AddMapMarker(class'Image10_Paris_Metro',264,238,"P","Nicolette/Jaime", loc,"Nicolette or Jaime can be located in the back room of the club, watching TV.");
        loc=AddGoalLocation("10_PARIS_METRO", "Apartment Balcony", NORMAL_GOAL, vect(2405, 957.270508, 863.598877), rot(0, 0, 0));
        AddMapMarker(class'Image10_Paris_Metro',278,263,"P","Nicolette/Jaime", loc,"Nicolette or Jaime can be located on the balcony of apartment #12.");
        loc=AddGoalLocation("10_PARIS_METRO", "Hostel", NORMAL_GOAL, vect(2315.102295, 2511.724365, 651.103638), rot(0, 0, 0));
        AddMapMarker(class'Image10_Paris_Metro',284,309,"P","Nicolette/Jaime", loc,"Nicolette or Jaime can be located in the locked room of the hostel.");
        loc=AddGoalLocation("10_PARIS_METRO", "Bakery", NORMAL_GOAL, vect(922.178833, 2382.884521, 187.105133), rot(0, 16384, 0));
        AddMapMarker(class'Image10_Paris_Metro',234,315,"P","Nicolette/Jaime", loc,"Nicolette or Jaime can be located behind the counter of the bakery.");
        loc=AddGoalLocation("10_PARIS_METRO", "Stairs", NORMAL_GOAL, vect(-802.443115, 2434.175781, -132.900146), rot(0, 35000, 0));
        AddMapMarker(class'Image10_Paris_Metro',167,310,"P","Nicolette/Jaime", loc,"Nicolette or Jaime can be located on the stairs leading down to the Metro.");
        loc=AddGoalLocation("10_PARIS_METRO", "Pillars", NORMAL_GOAL, vect(-3614.988525, 2406.175293, 235.101135), rot(0, -16384, 0));
        AddMapMarker(class'Image10_Paris_Metro',60,313,"P","Nicolette/Jaime", loc,"Nicolette or Jaime can be located between the arches of the Pillars of Freedom.");
        loc=AddGoalLocation("10_PARIS_METRO", "Media Store", NORMAL_GOAL, vect(1006.833252, 1768.635620, 187.101196), rot(0, 0, 0));
        AddMapMarker(class'Image10_Paris_Metro',223,291,"P","Nicolette/Jaime", loc,"Nicolette or Jaime can be located inside the media store.");
        loc=AddGoalLocation("10_PARIS_METRO", "Alcove Behind Pillar", NORMAL_GOAL, vect(1924.965210, -1234.666016, 187.101776), rot(0, 0, 0));
        AddMapMarker(class'Image10_Paris_Metro',255,146,"P","Nicolette/Jaime", loc,"Nicolette or Jaime can be located in a corner of the streets, behind a single large pillar.");
        loc=AddGoalLocation("10_PARIS_METRO", "Cafe", NORMAL_GOAL | VANILLA_GOAL | SITTING_GOAL, vect(-2300.492920, 1459.889160, 333.215088), rot(0, 0, 0));
        AddMapMarker(class'Image10_Paris_Metro',124,269,"P","Nicolette/Jaime", loc,"Nicolette or Jaime can be located in the cafe across from the club.  This is Jaime's vanilla location.");
        return 101;

    case "11_PARIS_CATHEDRAL":
        goal = AddGoal("11_PARIS_CATHEDRAL", "Templar Computer", NORMAL_GOAL, 'ComputerPersonal0', PHYS_Falling);
        AddGoalActor(goal, 1, 'GuntherHermann0', PHYS_Falling);
        //AddGoalActor(goal, 2, 'OrdersTrigger0', PHYS_None); Tag=CathedralGuntherAttacks
        //AddGoalActor(goal, 3, 'GoalCompleteTrigger0', PHYS_None); Tag=templar_upload
        AddGoalActor(goal, 2, 'SkillAwardTrigger3', PHYS_None);
        //AddGoalActor(goal, 5, 'FlagTrigger2', PHYS_None); Tag=templar_upload
        AddGoalActor(goal, 3, 'DataLinkTrigger8', PHYS_None); // DL_morgan_uplink "I'm getting what I need.  Good work."
        AddGoalActor(goal, 4, 'DataLinkTrigger14', PHYS_None); // DL_gunthernearcomp
        AddGoalActor(goal, 5, 'DataLinkTrigger10', PHYS_None); // DL_gunthernearcomp

        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Barracks", NORMAL_GOAL, vect(2990.853516, 30.971684, -392.498993), rot(0, 16384, 0));
        AddActorLocation(loc, 1, vect(2971.853516, 144.971680, -392.498993), rot(0,-8000,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Chapel", NORMAL_GOAL, vect(1860.275635, -9.666374, -371.286804), rot(0, 16384, 0));
        AddActorLocation(loc, 1, vect(2127, -143.666382, -350), rot(0, 32768, 0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Kitchen", NORMAL_GOAL, vect(1511.325317, -3204.465088, -680.498413), rot(0, 32768, 0));
        AddActorLocation(loc, 1, vect(1511.325317, -3123.465088, -680.498413), rot(0,65536,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Gold Vault", NORMAL_GOAL, vect(3480.141602, -3180.397949, -704.496704), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(3879.141602, -2890.397949, -704.496704), rot(0,32768,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "WiB Bedroom", NORMAL_GOAL, vect(3458.506592, -2423.655029, -104.499863), rot(0, -16384, 0));
        AddActorLocation(loc, 1, vect(3433.506592, -2536.655029, -104.499863), rot(0,16384,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Bridge", NORMAL_GOAL, vect(2591.672852, -1314.583862, 365.494843), rot(0, -18000, 0));
        AddActorLocation(loc, 1, vect(2632.672852, -1579.583862, 431.494843), rot(0,12000,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Basement", NORMAL_GOAL | VANILLA_GOAL, vect(5193.660645,-1007.544922,-838.674988), rot(0,-17088,0));
        AddActorLocation(loc, 1, vect(4926.411133, -627.878662, -845.294189), rot(0,45728,0));
        return 111;
    }

    return mission+1000;
}

function int InitGoalsRev(int mission, string map)
{
    local int goal, loc, loc2;

    switch(map) {
    case "10_PARIS_CATACOMBS_TUNNELS":
        AddGoal("10_PARIS_CATACOMBS_TUNNELS", "Agent Hela", NORMAL_GOAL, 'AgentHela0', PHYS_Falling);
        loc=AddGoalLocation("10_PARIS_CATACOMBS_TUNNELS", "Back of Bunker", NORMAL_GOAL | VANILLA_GOAL, vect(705.049500,-3805.679932,-278.812622), rot(0, 16384, 0));
        AddActorLocation(loc, 1, vect(795,-3725,-284), rot(0,0,0));
        loc=AddGoalLocation("10_PARIS_CATACOMBS_TUNNELS", "Back of Bunker Upper Level Ladder Side", NORMAL_GOAL, vect(-245,-2881,-32), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-227,-2481,-28), rot(0,0,0));
        loc=AddGoalLocation("10_PARIS_CATACOMBS_TUNNELS", "Back of Bunker Side Room", NORMAL_GOAL, vect(1102,-3028,-288), rot(0, -35404, 0));
        AddActorLocation(loc, 1, vect(955,-2630,-330), rot(0,0,0));
        loc=AddGoalLocation("10_PARIS_CATACOMBS_TUNNELS", "Front of Bunker Side", NORMAL_GOAL, vect(-500,600,-264), rot(0, -25956, 0));
        AddActorLocation(loc, 1, vect(-775,675,-300), rot(0,0,0));
        loc=AddGoalLocation("10_PARIS_CATACOMBS_TUNNELS", "Front of Bunker Upper Level", NORMAL_GOAL, vect(-1480,-90,-64), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-1668,65,-108), rot(0,0,0));
        return 102;
    case "10_PARIS_METRO":
    case "10_PARIS_CLUB":
        AddGoal("10_PARIS_METRO", "Jaime", NORMAL_GOAL, 'JaimeReyes1', PHYS_Falling);
        AddGoal("10_PARIS_CLUB", "Nicolette", NORMAL_GOAL, 'NicoletteDuClare0', PHYS_Falling);
        AddGoalLocation("10_PARIS_CLUB", "Club", NORMAL_GOAL | VANILLA_GOAL | SITTING_GOAL, vect(58.34,-1774.21,106.09), rot(0, 17368, 0));
        AddGoalLocation("10_PARIS_CLUB", "Back Room TV", NORMAL_GOAL, vect(-1865,-478,-180), rot(0, -16384, 0));
        AddGoalLocation("10_PARIS_METRO", "Apartment Balcony", NORMAL_GOAL, vect(2314.5,-78.6,655.6), rot(0, 0, 0));
        AddGoalLocation("10_PARIS_METRO", "Hostel", NORMAL_GOAL, vect(1304.6,3258.6,687.6), rot(0, 0, 0));
        AddGoalLocation("10_PARIS_METRO", "Bakery", NORMAL_GOAL, vect(1148.7,173.4,240), rot(0, 16384, 0));
        AddGoalLocation("10_PARIS_METRO", "Stairs", NORMAL_GOAL, vect(3106.6,-4551,-121), rot(0, 32768, 0));
        AddGoalLocation("10_PARIS_METRO", "Arches", NORMAL_GOAL, vect(1671,1166,223.6), rot(0, -16384, 0));
        AddGoalLocation("10_PARIS_METRO", "Media Store", NORMAL_GOAL, vect(1445,-5378,223), rot(0, -16328, 0));
        AddGoalLocation("10_PARIS_METRO", "Corner Near Pillar", NORMAL_GOAL, vect(2061.8,-993,223.6), rot(0, -8000, 0));
        AddGoalLocation("10_PARIS_METRO", "Cafe", NORMAL_GOAL | VANILLA_GOAL | SITTING_GOAL, vect(998,-5229.4,295.21), rot(0, 0, 0));
        return 101;

    case "11_PARIS_CATHEDRAL":
        goal = AddGoal("11_PARIS_CATHEDRAL", "Templar Computer", NORMAL_GOAL, 'ComputerPersonal0', PHYS_Falling);
        AddGoalActor(goal, 1, 'GuntherHermann0', PHYS_Falling);
        AddGoalActor(goal, 2, 'OrdersTrigger0', PHYS_None);
        AddGoalActor(goal, 3, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 4, 'SkillAwardTrigger3', PHYS_None);
        AddGoalActor(goal, 5, 'FlagTrigger2', PHYS_None);
        AddGoalActor(goal, 6, 'DataLinkTrigger8', PHYS_None);

        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Barracks", NORMAL_GOAL, vect(4738.159668,-882.423401,247.500351), rot(0, 32768, 0));
        AddActorLocation(loc, 1, vect(4789.892578,-801.263672,241.979095), rot(0,-16392,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Chapel", NORMAL_GOAL, vect(3652.271240,-945.115540,268.747803), rot(0, 16384, 0));
        AddActorLocation(loc, 1, vect(3724,-1341,278), rot(0, -16384, 0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Kitchen", NORMAL_GOAL, vect(3630,-4502,-40), rot(0, 32768, 0));
        AddActorLocation(loc, 1, vect(3516,-4530,-52), rot(0,65536,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Gold Vault", NORMAL_GOAL, vect(5263,-4120,-64), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(5175,-4216,-100), rot(0,16392,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "WiB Bedroom", NORMAL_GOAL, vect(5262.339844,-3395.224121,535.498474), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(5243.958984,-3493.718506,539.100281), rot(0,16384,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Bridge", NORMAL_GOAL, vect(4463.660645,-2195.544922,1034.499390), rot(0, -16392, 0));
        AddActorLocation(loc, 1, vect(4240.411133,-1804.878662,1061.705811), rot(0,-16392,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Basement", NORMAL_GOAL | VANILLA_GOAL, vect(7101.660645,-2043.54492,-198.500610), rot(0,-17088,0));
        AddActorLocation(loc, 1, vect(6718.411,-1571.88,-205.294), rot(0,45728,0));
        return 111;
    }

    return mission+1000;
}

function MissionTimer()
{
    local #var(prefix)NicoletteDuClare nico;
    local #var(prefix)BlackHelicopter chopper;
    local #var(prefix)ParticleGenerator gen;
    local FlagBase f;

    f = dxr.flagbase;

    switch(dxr.localURL) {
    case "10_PARIS_METRO":
        UpdateGoalWithRandoInfo('MeetJaime', "Jaime could be anywhere in Paris.");
        if(dxr.flags.settings.swapitems > 0) {
            UpdateGoalWithRandoInfo('GetCrack', "The zyme can be anywhere.",True);// dependent on swap items, not on goals rando
        }
        if (f.GetBool('MeetNicolette_Played') &&
            !f.GetBool('NicoletteLeftClub'))
        {
            f.SetBool('NicoletteLeftClub', True,, 11);

            foreach AllActors(class'#var(prefix)NicoletteDuClare', nico, 'DXRMissions') {
                nico.Event = '';
                nico.Destroy();
                player().ClientFlash(1,vect(2000,2000,2000));
                gen = Spawn(class'#var(prefix)ParticleGenerator',,, nico.Location);
                gen.SetCollision(false, false, false);
                gen.SetLocation(nico.Location);
                gen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
                gen.LifeSpan = 2;
                gen.particleDrawScale = 5;
                gen.riseRate = 1;
                player().PlaySound(Sound'DeusExSounds.Weapons.GasGrenadeExplode');
            }

            foreach AllActors(class'#var(prefix)NicoletteDuClare', nico)
                nico.EnterWorld();

            foreach AllActors(class'#var(prefix)BlackHelicopter', chopper, 'BlackHelicopter')
                chopper.EnterWorld();
        }
        break;

    case "10_PARIS_CATACOMBS_TUNNELS":
        UpdateGoalWithRandoInfo('FindNicolette', "Nicolette could be anywhere in the city.");
        break;
    case "10_PARIS_CHATEAU":
        UpdateGoalWithRandoInfo('AccessTemplarComputer', "The computer could be anywhere in the cathedral.");
        break;
    case "10_PARIS_CATACOMBS":
        UpdateGoalWithRandoInfo('KillGreasels', "The greasels could be anywhere in the area.");
        break;
    }
}

function CreateGoal(out Goal g, GoalLocation Loc)
{
    local #var(prefix)ScriptedPawn sp;

    switch(g.name) {
    case "Nicolette":
        sp = #var(prefix)ScriptedPawn(Spawnm(class'#var(prefix)NicoletteDuClare',, 'DXRMissions', Loc.positions[0].pos));
        g.actors[0].a = sp;
        RemoveReactions(sp);
        sp.BindName = "NicoletteDuClare";
        sp.FamiliarName = "Young Woman";
        sp.UnfamiliarName = "Young Woman";
        sp.bInvincible = true;
        sp.SetOrders('Dancing');
        sp.ConBindEvents();
        sp.RaiseAlarm = RAISEALARM_Never;
        break;

    case "Jaime":
        if(dxr.flagbase.GetBool('JaimeLeftBehind')) {
            sp = #var(prefix)ScriptedPawn(Spawnm(class'#var(prefix)JaimeReyes',, 'DXRMissions', Loc.positions[0].pos));
            g.actors[0].a = sp;
            RemoveReactions(sp);
            sp.SetOrders('Standing');
            sp.RaiseAlarm = RAISEALARM_Never;
        }
        break;
    }
}

function PreFirstEntryMapFixes()
{
    local #var(prefix)WIB hela;
    local #var(prefix)NanoKey key;
    local #var(DeusExPrefix)Mover m;
    local #var(prefix)ComputerPublic cp;
    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL) {
    case "10_PARIS_CATACOMBS_TUNNELS":
        foreach AllActors(class'#var(prefix)WIB', hela) {
            key = #var(prefix)NanoKey(GiveItem(hela,class'#var(prefix)NanoKey'));
            key.Description="Catacombs Sewer Entry Key";
            key.keyId='catacombs_blastdoor02';
            break;
        }
        break;

    case "10_PARIS_METRO":
        if(VanillaMaps) {
            key = Spawn(class'#var(prefix)NanoKey',,, vectm(-1733,-2480,168));
            key.KeyID = 'apartment12';
            key.Description = "Key to Apartment #12";
            if(dxr.flags.settings.keysrando > 0)
                GlowUp(key);

            foreach AllActors(class'#var(DeusExPrefix)Mover', m){
                if (m.Name=='DeusExMover10') {
                    m.KeyIDNeeded='apartment12';
                    break;
                }
            }

            foreach AllActors(class'#var(prefix)ComputerPublic',cp){
                //The two public computers in the lobby of the hostel become guest registries
                if (cp.Name=='ComputerPublic2' || cp.Name=='ComputerPublic3'){
                    cp.TextPackage = "#var(package)";
                    cp.bulletinTag='10_HostelBulletinMenu';
                    cp.FamiliarName="Guest Registry";
                    cp.UnfamiliarName=cp.FamiliarName;
                }
            }
        }
        break;
    }
}

function AfterMoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local DXREnemiesPatrols patrol;
    local DXRPasswords passwords;
    local #var(prefix)NanoKey key;
    local string guestName;
    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    if (g.name=="Agent Hela"){
        if (Loc.Name=="Back of Bunker" ||   //Vanilla
            Loc.Name=="Front of Bunker Side" ||   //Vanilla
            Loc.Name=="Front of Bunker Upper Level"|| //Vanilla
            Loc.Name=="Back of Bunker Side Room"){ //Revision

            foreach AllActors(class'DXREnemiesPatrols',patrol){break;}
            patrol.GivePatrol(#var(prefix)ScriptedPawn(g.actors[0].a));
        } else {
            #var(prefix)ScriptedPawn(g.actors[0].a).SetOrders('Standing');
        }

        //Create the sneakable bonus key near Hela
        key=#var(prefix)NanoKey(Spawnm(class'#var(prefix)NanoKey',,,Loc.positions[1].pos));
        key.Description="Catacombs Sewer Entry Key";
        key.keyId='catacombs_blastdoor02';
        key.bIsSecretGoal=true;
        if(dxr.flags.settings.keysrando > 0)
            GlowUp(key);

    }

    if (Loc.name=="Hostel"){
        if (g.name=="Jaime" && dxr.flagbase.GetBool('JaimeLeftBehind')){
            guestName="Jaime Reyes";
        } else if (g.name=="Nicolette"){
            guestName="Nicolette DuClare";
        }

        passwords = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
        if(passwords != None && guestName != "") {
            passwords.ReplacePassword("   Room 1 is currently unoccupied", "  Guest: "$guestName);
        }
    }

    if (g.name=="Templar Computer" && VanillaMaps) { // TODO: make this work in Revision too
        g.actors[2].a.SetCollisionSize(160,64);
        g.actors[4].a.SetCollisionSize(1600,200);
    }
}
