class DXRMissionsM02 extends DXRMissions;


function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2, jock_holy_smokes, jock_sewer, generator_sewer, generator_alley;

    switch(map) {
    case "02_NYC_BATTERYPARK":
        goal = AddGoal("02_NYC_BATTERYPARK", "Ambrosia", NORMAL_GOAL, 'BarrelAmbrosia0', PHYS_Falling);
        AddGoalActor(goal, 1, 'SkillAwardTrigger0', PHYS_None);
        AddGoalActor(goal, 2, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 3, 'FlagTrigger1', PHYS_None); //Sets AmbrosiaTagged
        AddGoalActor(goal, 4, 'DataLinkTrigger1', PHYS_None);

        AddGoalLocation("02_NYC_BATTERYPARK", "Dock", START_LOCATION | VANILLA_START, vect(-619.571289, -3679.116455, 255.099762), rot(0, 29856, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Behind the Castle", START_LOCATION, vect(2364.934326, -2026.725952, 363.899994), rot(0, 159109, 0));

        AddGoalLocation("02_NYC_BATTERYPARK", "In the command room", NORMAL_GOAL | START_LOCATION, vect(650.060547, -989.234863, -160.095200), rot(0, 16718, 0));

        AddGoalLocation("02_NYC_BATTERYPARK", "Ambrosia Vanilla", NORMAL_GOAL | VANILLA_GOAL, vect(507.282898, -1066.344604, -403.132751), rot(0, 16536, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Shanty Town", NORMAL_GOAL, vect(-2970,1840,348), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Behind the cargo", NORMAL_GOAL, vect(58.725319, -446.887207, -405.899323), rot(0, 32768, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "By the desk", NORMAL_GOAL, vect(-615.152161, -665.281738, -397.581146), rot(0, -24786, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Walkway by the water", NORMAL_GOAL, vect(-420.000000, -2222.000000, -400), rot(0, 16436, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Subway stairs", NORMAL_GOAL, vect(-5106.205078, 1813.453003, -82.239639), rot(0, -16412, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Subway", NORMAL_GOAL, vect(-4727.703613, 3116.336670, -321.900604), rot(0, -49276, 0));

        if (dxr.flags.settings.starting_map > 20)
        {
            skip_rando_start = True;
        }

        return 21;

    case "02_NYC_WAREHOUSE":
        // NORMAL_GOAL is Jock, GOAL_TYPE1 is the generator, GOAL_TYPE2 is the computers
        AddGoal("02_NYC_WAREHOUSE", "Jock", NORMAL_GOAL, 'BlackHelicopter1', PHYS_None);
        AddGoalLocation("02_NYC_WAREHOUSE", "Vanilla Jock", NORMAL_GOAL | VANILLA_GOAL, vect(-222.402451,-294.757233,1132.798828), rot(0,-24128,0));
        jock_holy_smokes = AddGoalLocation("02_NYC_WAREHOUSE", "Holy Smokes", NORMAL_GOAL, vect(-566.249695, 305.599731, 1207.798462), rot(0, -32800, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Back Door", NORMAL_GOAL, vect(1656.467041, -1658.624268, 357.798462), rot(0, -32800, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Dumpster", NORMAL_GOAL, vect(1665.240112, 91.544250, 126.798462), rot(0, 0, 0));
        jock_sewer = AddGoalLocation("02_NYC_WAREHOUSE", "Sewer", NORMAL_GOAL, vect(-1508.833008, 360, -216.201538), rot(0, 16400, 0));

        goal = AddGoal("02_NYC_WAREHOUSE", "Generator", GOAL_TYPE1, 'BreakableWall2', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'CrateExplosiveSmall0', PHYS_None);
        AddGoalActor(goal, 2, 'CrateExplosiveSmall6', PHYS_None);
        AddGoalActor(goal, 3, 'AmbientSoundTriggered0', PHYS_None);
        AddGoalActor(goal, 4, 'AmbientSoundTriggered1', PHYS_None);

        AddGoalLocation("02_NYC_WAREHOUSE", "Warehouse", GOAL_TYPE1 | VANILLA_GOAL, vect(575,-608,122), rot(32768, -16384, 0));
        generator_alley = AddGoalLocation("02_NYC_WAREHOUSE", "Alley", GOAL_TYPE1, vect(-550, 1700, 110), rot(0,32768,-16384));
        AddMutualExclusion(generator_alley, jock_sewer);// too easy
        AddMutualExclusion(generator_alley, jock_holy_smokes);
        loc = AddGoalLocation("02_NYC_WAREHOUSE", "Apartment", GOAL_TYPE1, vect(460,1130,1000), rot(0,32768,-16384));
        AddMutualExclusion(loc, jock_holy_smokes);
        AddGoalLocation("02_NYC_WAREHOUSE", "Basement", GOAL_TYPE1, vect(300,-480,-125), rot(0,-16384,-16384));
        generator_sewer = AddGoalLocation("02_NYC_WAREHOUSE", "Sewer", GOAL_TYPE1, vect(-1695,784,-210), rot(32768,-32768,0));
        AddMutualExclusion(generator_sewer, jock_sewer);// can't put Jock and the generator both in the sewers
        AddMutualExclusion(generator_sewer, jock_holy_smokes);
        AddGoalLocation("02_NYC_WAREHOUSE", "3rd Floor", GOAL_TYPE1, vect(1340, -700, 575), rot(32768, 0, 32768)); //Near the ramp
        AddGoalLocation("02_NYC_WAREHOUSE", "4th Floor", GOAL_TYPE1, vect(390,-660,832), rot(32768,0,0)); //Among the boxes

        goal = AddGoal("02_NYC_WAREHOUSE", "Generator Computer", GOAL_TYPE2 | GOAL_TYPE3, 'ComputerPersonal5', PHYS_Falling);
        AddGoalActor(goal, 1, 'AmbientSoundTriggered3', PHYS_None);
        AddGoal("02_NYC_WAREHOUSE", "Email Computer", GOAL_TYPE2 | GOAL_TYPE4, 'ComputerPersonal0', PHYS_Falling);
        AddGoalLocation("02_NYC_WAREHOUSE", "Warehouse Computer Room", GOAL_TYPE2 | VANILLA_GOAL, vect(1277.341797, -864.810913, 311.500397), rot(0, 16712, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Basement", GOAL_TYPE2 | VANILLA_GOAL, vect(1002.848999, -897.071167, -136.499573), rot(0, -17064, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Break room", GOAL_TYPE2, vect(1484.731934, -917.463257, 73.499916), rot(0,-16384,0));

        loc = AddGoalLocation("02_NYC_WAREHOUSE", "Apartment", GOAL_TYPE3, vect(-239.501144, 1441.699951, 1151.502930), rot(0,0,0));
        loc2 = AddGoalLocation("02_NYC_WAREHOUSE", "Apartment", GOAL_TYPE4, vect(-239.501144, 1441.699951, 1151.502930), rot(0,0,0));
        AddMutualExclusion(loc, loc2);
        AddMutualExclusion(loc, jock_holy_smokes);

        loc = AddGoalLocation("02_NYC_WAREHOUSE", "Holy Smokes", GOAL_TYPE3, vect(-846.480957, 919.700012, 1475.486938), rot(0,32768,0));
        loc2 = AddGoalLocation("02_NYC_WAREHOUSE", "Holy Smokes", GOAL_TYPE4, vect(-846.480957, 919.700012, 1475.486938), rot(0,32768,0));
        AddMutualExclusion(loc, loc2);
        AddMutualExclusion(loc, jock_holy_smokes);

        return 22;
    }

    return mission+1000;
}

function int InitGoalsRev(int mission, string map)
{
    local int goal, loc, loc2, jock_holy_smokes, jock_sewer, generator_sewer, generator_alley;

    switch(map) {
    case "02_NYC_BATTERYPARK":
        goal = AddGoal("02_NYC_BATTERYPARK", "Ambrosia", NORMAL_GOAL, 'BarrelAmbrosia0', PHYS_Falling);
        AddGoalActor(goal, 1, 'SkillAwardTrigger0', PHYS_None);
        AddGoalActor(goal, 2, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 3, 'FlagTrigger1', PHYS_None); //Sets AmbrosiaTagged
        AddGoalActor(goal, 4, 'DataLinkTrigger15', PHYS_None);

        AddGoalLocation("02_NYC_BATTERYPARK", "Dock", START_LOCATION | VANILLA_START, vect(-619.571289, -3679.116455, 255.099762), rot(0, 29856, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Behind the Castle", START_LOCATION, vect(2364.934326, -2026.725952, 363.899994), rot(0, 159109, 0)); //TODO: Check location

        AddGoalLocation("02_NYC_BATTERYPARK", "In the command room", NORMAL_GOAL | START_LOCATION, vect(650.060547, -989.234863, -160.095200), rot(0, 16718, 0));

        loc = AddGoalLocation("02_NYC_BATTERYPARK", "Ambrosia Vanilla", NORMAL_GOAL | VANILLA_GOAL, vect(507.282898, -1066.344604, -403.132751), rot(0, 16536, 0));
        AddActorLocation(loc, PLAYER_LOCATION, vect(81.434570, -1123.060547, -384.397644), rot(0, 8000, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Shanty Town", NORMAL_GOAL, vect(-2970,1840,348), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Behind the cargo", NORMAL_GOAL, vect(185,-30,-405), rot(0, 32768, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "By the desk", NORMAL_GOAL, vect(-615.152161, -665.281738, -397.581146), rot(0, -24786, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Walkway by the water", NORMAL_GOAL, vect(-420.000000, -2222.000000, -400), rot(0, 16436, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Subway stairs", NORMAL_GOAL, vect(-5106.205078, 1813.453003, -82.239639), rot(0, -16412, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Subway", NORMAL_GOAL, vect(-4727.703613, 3116.336670, -321.900604), rot(0, -49276, 0));

        if (dxr.flags.settings.starting_map > 20)
        {
            skip_rando_start = True;
        }

        return 21;

    case "02_NYC_WAREHOUSE":
        // NORMAL_GOAL is Jock, GOAL_TYPE1 is the generator, GOAL_TYPE2 is the computers
        AddGoal("02_NYC_WAREHOUSE", "Jock", NORMAL_GOAL, 'JockHelicopter0', PHYS_None);
        AddGoalLocation("02_NYC_WAREHOUSE", "Vanilla Jock", NORMAL_GOAL | VANILLA_GOAL, vect(-222.402451,-294.757233,1132.798828), rot(0,-24128,0));
        jock_holy_smokes = AddGoalLocation("02_NYC_WAREHOUSE", "Holy Smokes", NORMAL_GOAL, vect(-566.249695, 305.599731, 1207.798462), rot(0, -32800, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Back Door", NORMAL_GOAL, vect(1656.467041, -1658.624268, 357.798462), rot(0, -32800, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Dumpster", NORMAL_GOAL, vect(1665.240112, 91.544250, 126.798462), rot(0, 0, 0));
        jock_sewer = AddGoalLocation("02_NYC_WAREHOUSE", "Sewer", NORMAL_GOAL, vect(-1508.833008, 360, -216.201538), rot(0, 16400, 0));

        goal = AddGoal("02_NYC_WAREHOUSE", "Generator", GOAL_TYPE1, 'BreakableWall2', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'CrateExplosiveSmall0', PHYS_None);
        AddGoalActor(goal, 2, 'CrateExplosiveSmall6', PHYS_None);
        AddGoalActor(goal, 3, 'AmbientSoundTriggered0', PHYS_None);
        AddGoalActor(goal, 4, 'AmbientSoundTriggered1', PHYS_None);

        AddGoalLocation("02_NYC_WAREHOUSE", "Warehouse", GOAL_TYPE1 | VANILLA_GOAL, vect(575,-608,122), rot(32768, -16384, 0));
        generator_alley = AddGoalLocation("02_NYC_WAREHOUSE", "Alley", GOAL_TYPE1, vect(-550, 1700, 110), rot(0,32768,-16384));
        AddMutualExclusion(generator_alley, jock_sewer);// too easy
        AddMutualExclusion(generator_alley, jock_holy_smokes);
        loc = AddGoalLocation("02_NYC_WAREHOUSE", "Apartment", GOAL_TYPE1, vect(460,1130,1000), rot(0,32768,-16384));
        AddMutualExclusion(loc, jock_holy_smokes);
        AddGoalLocation("02_NYC_WAREHOUSE", "Basement", GOAL_TYPE1, vect(300,-480,-125), rot(0,-16384,-16384));
        generator_sewer = AddGoalLocation("02_NYC_WAREHOUSE", "Sewer", GOAL_TYPE1, vect(-1695,784,-210), rot(32768,-32768,0));
        AddMutualExclusion(generator_sewer, jock_sewer);// can't put Jock and the generator both in the sewers
        AddMutualExclusion(generator_sewer, jock_holy_smokes);
        AddGoalLocation("02_NYC_WAREHOUSE", "3rd Floor", GOAL_TYPE1, vect(1340, -700, 575), rot(32768, 0, 32768));
        AddGoalLocation("02_NYC_WAREHOUSE", "4th Floor", GOAL_TYPE1, vect(390,-660,832), rot(32768,0,0)); //Among the boxes

        goal=AddGoal("02_NYC_WAREHOUSE", "Generator Computer", GOAL_TYPE2 | GOAL_TYPE3, 'ComputerPersonal5', PHYS_Falling);
        AddGoalActor(goal, 1, 'AmbientSoundTriggered3', PHYS_None);
        AddGoal("02_NYC_WAREHOUSE", "Email Computer", GOAL_TYPE2 | GOAL_TYPE4, 'ComputerPersonal0', PHYS_Falling);
        AddGoalLocation("02_NYC_WAREHOUSE", "Warehouse Computer Room", GOAL_TYPE2 | VANILLA_GOAL, vect(1277.341797, -864.810913, 311.500397), rot(0, 16712, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Basement", GOAL_TYPE2 | VANILLA_GOAL, vect(1002.848999, -897.071167, -136.499573), rot(0, -17064, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Break room", GOAL_TYPE2, vect(1484.731934, -917.463257, 73.499916), rot(0,-16384,0));

        loc = AddGoalLocation("02_NYC_WAREHOUSE", "Apartment", GOAL_TYPE3, vect(-239.501144, 1441.699951, 1151.502930), rot(0,0,0));
        loc2 = AddGoalLocation("02_NYC_WAREHOUSE", "Apartment", GOAL_TYPE4, vect(-239.501144, 1441.699951, 1151.502930), rot(0,0,0));
        AddMutualExclusion(loc, loc2);
        AddMutualExclusion(loc, jock_holy_smokes);

        loc = AddGoalLocation("02_NYC_WAREHOUSE", "Holy Smokes", GOAL_TYPE3, vect(-846.480957, 919.700012, 1475.486938), rot(0,32768,0));
        loc2 = AddGoalLocation("02_NYC_WAREHOUSE", "Holy Smokes", GOAL_TYPE4, vect(-846.480957, 919.700012, 1475.486938), rot(0,32768,0));
        AddMutualExclusion(loc, loc2);
        AddMutualExclusion(loc, jock_holy_smokes);

        return 22;

    }

    return mission+1000;
}

function ReplaceBatteryParkSubwayTNT()
{
    local CrateExplosiveSmall tnt;
    local #var(prefix)Barrel1 barrel;
    local class<#var(prefix)Barrel1> barrelclass;
    local bool destroyTNT;
    local int choice;

#ifdef injections
    barrelclass = class'Barrel1';
#else
    barrelclass = class'DXRBarrel1';
#endif

    //The front crates have their tag set to ExplosiveCrate.
    //Since we're changing their types, they should all be set off
    choice = rng(8);
    foreach AllActors(class'CrateExplosiveSmall',tnt){
        destroyTNT = True;
        barrel = None;
        switch(choice){
            case 0:
            case 1:
                //Keep TNT crate - 300 explosion damage
                destroyTNT=False;
                tnt.bIsSecretGoal=True;
                tnt.Tag='ExplosiveCrate';
                break;
            case 2:
                //Explosive barrel - 400 explosion damage
                barrel = Spawn(barrelclass,,,tnt.Location);
                barrel.SkinColor=SC_Explosive;
                break;
            case 3:
                //Flammable Solid barrel - 200 explosion damage
                barrel = Spawn(barrelclass,,,tnt.Location);
                barrel.SkinColor=SC_FlammableSolid;
                break;
            case 4:
            case 5:
                //Poison Barrel
                barrel = Spawn(barrelclass,,,tnt.Location);
                barrel.SkinColor=SC_Poison;
                break;
            case 6:
            case 7:
                //Biohazard Barrel
                barrel = Spawn(barrelclass,,,tnt.Location);
                barrel.SkinColor=SC_Biohazard;
                break;
        }

        if (barrel!=None){
            barrel.bIsSecretGoal=True;
            barrel.BeginPlay();
            barrel.Tag='ExplosiveCrate';
        }

        if(destroyTNT){
            tnt.destroy();
        }
    }
}

function PreFirstEntryMapFixes()
{
    local #var(prefix)AnnaNavarre anna;
    local #var(prefix)InterpolateTrigger it;
    local #var(DeusExPrefix)Mover dxm;
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    if( dxr.localURL == "02_NYC_BATTERYPARK" ) {
        foreach AllActors(class'#var(prefix)AnnaNavarre', anna) {
            anna.SetOrders('Standing');
            anna.SetLocation( vectm(1082.845703, 1807.538818, 335.101776) );
            anna.SetRotation( rotm(0, -16608, 0, 16384) );
            anna.HomeLoc = anna.Location;
            anna.HomeRot = vector(anna.Rotation);
        }
        ReplaceBatteryParkSubwayTNT();
    }

    if (RevisionMaps && dxr.localURL=="02_NYC_WAREHOUSE"){
        foreach AllActors(class'#var(prefix)InterpolateTrigger',it,'FlyInTrigger'){
            it.Destroy();
        }
    }
    if(dxr.localURL=="02_NYC_WAREHOUSE") {
        ConsoleCommand("set #var(prefix)AmbientSoundTriggered bstatic false");// HACK? maybe better than creating a new subclass for DynamicSoundTriggered and then doing replacements

        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'Generator'){
            dxm.SetCollision(false,false,false);
            RemoveMoverPrePivot(dxm);
            dxm.PrePivot=vect(-80,0,-50); //This is intentionally not a vectm
            dxm.BasePos=dxm.BasePos+dxm.PrePivot;
            dxm.SetLocation(dxm.BasePos);
            dxm.SetCollision(true,true,true);
        }
    }
}

function AnyEntry()
{
    Super.AnyEntry();

    switch(dxr.localURL) {
    case "02_NYC_BATTERYPARK":
        UpdateGoalWithRandoInfo('FindAmbrosia', "The Ambrosia could be anywhere in Battery Park.");
        break;
    case "02_NYC_STREET":
        UpdateGoalWithRandoInfo('DestroyGenerator', "The generator could be anywhere in the warehouse district.  It looks like a large yellow cylinder.");
        break;
    }
}

function AfterMoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local Actor a;
    local #var(DeusExPrefix)Mover m;
    local #var(prefix)ComputerPersonal cp;
    local DXRPasswords passwords;
    local int i,rad,height;
    local AmbientSoundTriggered ast1,ast2;

    if (g.name=="Generator"){
        if (Loc.Name=="Warehouse" || Loc.Name=="Sewer" || Loc.Name=="3rd Floor" || Loc.Name=="4th Floor"){ //These ones lie horizontal
            rad=175;
            height=100;
        } else { //The rest stand upright
            rad=120;
            height=131;
        }
        class'DXRHoverHint'.static.Create(self, "NSF Generator", g.actors[0].a.Location, rad, height, g.actors[0].a);
        a = Spawn(class'DynamicBlockMonsters',,, g.actors[0].a.Location);
        a.SetBase(g.actors[0].a);
        a.SetCollisionSize(rad, height);

        for(i=0; i<ArrayCount(g.actors); i++) {
            if( AmbientSoundTriggered(g.actors[i].a) != None) {
                AmbientSoundTriggered(g.actors[i].a).SoundRadius = 1600;
            }
        }

        //Find the original alarm sound
        foreach AllActors(class'AmbientSoundTriggered',ast1,'WarningSound'){ break; }

        //Spawn an alarm sound at the generator as well (the original one goes with the computer)
        ast2 = Spawn(class'AmbientSoundTriggered',,'WarningSound', g.actors[0].a.Location);
        ast2.savedSound=ast1.savedSound; //Revision didn't like referencing the sound by name, so just copy it from the original
        ast2.bTriggerOnceOnly=True;
        ast2.bActive=False;

    }

    if(g.name == "Generator" && Loc.name != "Warehouse") {
        a = AddBox(class'#var(prefix)CrateUnbreakableLarge', vectm(505.710449, -605, 162.091278), rotm(16384,0,0, GetRotationOffset(class'#var(prefix)CrateUnbreakableLarge')));
        a.SetCollisionSize(a.CollisionRadius * 4, a.CollisionHeight * 4);
        a.bMovable = false;
        a.DrawScale = 4;
        class'DXRHoverHint'.static.Create(self, "This is not the generator", a.Location, a.CollisionRadius+5, a.CollisionHeight+5);
        a = AddBox(class'#var(prefix)CrateUnbreakableLarge', vectm(677.174988, -809.484558, 114.097824), rotm(0,0,0, GetRotationOffset(class'#var(prefix)CrateUnbreakableLarge')));
        a.SetCollisionSize(a.CollisionRadius * 2, a.CollisionHeight * 2);
        a.bMovable = false;
        a.DrawScale = 2;

        foreach AllActors(class'#var(DeusExPrefix)Mover', m, 'Debris') {
            m.Tag = '';
            m.Event = '';
        }

        passwords = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
        if(passwords != None && Loc.name != "UC") {
            passwords.ReplacePassword("defend the generator in the Warehouse,", "defend the generator in the "$Loc.name$",");
        }
    }
    else if(g.name == "Generator Computer" && Loc.name != "Warehouse Computer Room") {
        passwords = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
        if(passwords != None && Loc.name != "UC") {
            passwords.ReplacePassword("generator's computer in the Warehouse Computer Room.", "generator's computer in the "$Loc.name$".");
        }
    }
    else if(dxr.localURL=="02_NYC_WAREHOUSE" && g.name=="Email Computer") {
        cp = #var(prefix)ComputerPersonal(g.actors[0].a);
        cp.TextPackage = "#var(package)";
    }
}
