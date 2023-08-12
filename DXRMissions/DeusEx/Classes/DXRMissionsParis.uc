class DXRMissionsParis extends DXRMissions;


function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2;

    switch(map) {
    case "10_PARIS_METRO":
    case "10_PARIS_CLUB":
        AddGoal("10_PARIS_METRO", "Jaime", NORMAL_GOAL, 'JaimeReyes1', PHYS_Falling);
        AddGoal("10_PARIS_CLUB", "Nicolette", NORMAL_GOAL, 'NicoletteDuClare0', PHYS_Falling);
        AddGoalLocation("10_PARIS_CLUB", "Club", NORMAL_GOAL | VANILLA_GOAL | SITTING_GOAL, vect(-673.488708, -1385.685059, 43.097466), rot(0, 17368, 0));
        AddGoalLocation("10_PARIS_CLUB", "Back Room TV", NORMAL_GOAL, vect(-1939.340942, -478.474091, -180.899628), rot(0, -16384, 0));
        AddGoalLocation("10_PARIS_METRO", "Apartment Balcony", NORMAL_GOAL, vect(2405, 957.270508, 863.598877), rot(0, 0, 0));
        AddGoalLocation("10_PARIS_METRO", "Hostel", NORMAL_GOAL, vect(2315.102295, 2511.724365, 651.103638), rot(0, 0, 0));
        AddGoalLocation("10_PARIS_METRO", "Bakery", NORMAL_GOAL, vect(922.178833, 2382.884521, 187.105133), rot(0, 16384, 0));
        AddGoalLocation("10_PARIS_METRO", "Stairs", NORMAL_GOAL, vect(-802.443115, 2434.175781, -132.900146), rot(0, 35000, 0));
        AddGoalLocation("10_PARIS_METRO", "Pillars", NORMAL_GOAL, vect(-3614.988525, 2406.175293, 235.101135), rot(0, -16384, 0));
        AddGoalLocation("10_PARIS_METRO", "Media Store", NORMAL_GOAL, vect(1006.833252, 1768.635620, 187.101196), rot(0, 0, 0));
        AddGoalLocation("10_PARIS_METRO", "Alcove Behind Pillar", NORMAL_GOAL, vect(1924.965210, -1234.666016, 187.101776), rot(0, 0, 0));
        AddGoalLocation("10_PARIS_METRO", "Cafe", NORMAL_GOAL | VANILLA_GOAL | SITTING_GOAL, vect(-2300.492920, 1459.889160, 333.215088), rot(0, 0, 0));
        return 101;

    case "11_PARIS_CATHEDRAL":
        goal = AddGoal("11_PARIS_CATHEDRAL", "Templar Computer", NORMAL_GOAL, 'ComputerPersonal0', PHYS_Falling);
        AddGoalActor(goal, 1, 'GuntherHermann0', PHYS_Falling);
        AddGoalActor(goal, 2, 'OrdersTrigger0', PHYS_None);
        AddGoalActor(goal, 3, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 4, 'SkillAwardTrigger3', PHYS_None);
        AddGoalActor(goal, 5, 'FlagTrigger2', PHYS_None);
        AddGoalActor(goal, 6, 'DataLinkTrigger8', PHYS_None);

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
/*
    case "11_PARIS_CATHEDRAL":
        goal = AddGoal("11_PARIS_CATHEDRAL", "Templar Computer", NORMAL_GOAL, 'ComputerPersonal0', PHYS_Falling);
        AddGoalActor(goal, 1, 'GuntherHermann0', PHYS_Falling);
        AddGoalActor(goal, 2, 'OrdersTrigger0', PHYS_None);
        AddGoalActor(goal, 3, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 4, 'SkillAwardTrigger3', PHYS_None);
        AddGoalActor(goal, 5, 'FlagTrigger2', PHYS_None);
        AddGoalActor(goal, 6, 'DataLinkTrigger8', PHYS_None);

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
*/
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
        if(dxr.flags.settings.goals > 0)
            UpdateGoalWithRandoInfo('MeetJaime', "Jaime could be anywhere in Paris.");
        UpdateGoalWithRandoInfo('GetCrack', "The zyme can be anywhere.");// not actually depedent on goals rando

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
        if(dxr.flags.settings.goals > 0)
            UpdateGoalWithRandoInfo('FindNicolette', "Nicolette could be anywhere in the city");
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
