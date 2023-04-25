class DXRMissionsM09 extends DXRMissions;


function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2;

    switch(map) {
    case "09_NYC_GRAVEYARD":
        goal = AddGoal("09_NYC_GRAVEYARD", "Jammer", NORMAL_GOAL, 'BreakableWall1', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'SkillAwardTrigger2', PHYS_None);
        AddGoalActor(goal, 2, 'FlagTrigger0', PHYS_None);
        AddGoalActor(goal, 3, 'TriggerLight0', PHYS_None);
        AddGoalActor(goal, 4, 'TriggerLight1', PHYS_None);
        AddGoalActor(goal, 5, 'TriggerLight2', PHYS_None);
        AddGoalActor(goal, 6, 'AmbientSoundTriggered0', PHYS_None);
        AddGoalLocation("09_NYC_GRAVEYARD", "Main Tunnel", NORMAL_GOAL, vect(-283.503448, -787.867920, -184.000000), rot(0, 0, -32768));
        AddGoalLocation("09_NYC_GRAVEYARD", "Open Grave", NORMAL_GOAL, vect(-766.879333, 501.505676, -88.109619), rot(0, 0, -32768));
        AddGoalLocation("09_NYC_GRAVEYARD", "Tunnel Ledge", NORMAL_GOAL, vect(-1530.000000, 845.000000, -107.000000), rot(0, 0, -32768));
        AddGoalLocation("09_NYC_GRAVEYARD", "Behind Bookshelf", NORMAL_GOAL | VANILLA_GOAL, vect(1103.000000,728.000000,48.000000), rot(0,0,-32768));
        return 91;

    case "09_NYC_SHIPBELOW":
        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 1", NORMAL_GOAL, 'DeusExMover40', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator10', PHYS_None);
        AddGoalActor(goal, 2, 'CrateExplosiveSmall1', PHYS_None);
        AddGoalActor(goal, 3, 'DataLinkTrigger8', PHYS_None);
        //AddGoalActor(goal, 3, 'AmbientSoundTriggered5', PHYS_None);
        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 2", NORMAL_GOAL, 'DeusExMover16', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator4', PHYS_None);
        AddGoalActor(goal, 2, 'CrateExplosiveSmall0', PHYS_None);
        AddGoalActor(goal, 3, 'DataLinkTrigger0', PHYS_None);
        //AddGoalActor(goal, 3, 'AmbientSoundTriggered0', PHYS_None);
        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 3", NORMAL_GOAL, 'DeusExMover33', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator7', PHYS_None);
        AddGoalActor(goal, 2, 'CrateExplosiveSmall2', PHYS_None);
        AddGoalActor(goal, 3, 'DataLinkTrigger3', PHYS_None);
        //AddGoalActor(goal, 3, 'AmbientSoundTriggered3', PHYS_None);
        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 4", NORMAL_GOAL, 'DeusExMover31', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator5', PHYS_None);
        AddGoalActor(goal, 2, 'CrateExplosiveSmall4', PHYS_None);
        AddGoalActor(goal, 3, 'DataLinkTrigger1', PHYS_None);
        //AddGoalActor(goal, 3, 'AmbientSoundTriggered1', PHYS_None);
        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 5", NORMAL_GOAL, 'DeusExMover32', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator6', PHYS_None);
        AddGoalActor(goal, 2, 'CrateExplosiveSmall3', PHYS_None);
        AddGoalActor(goal, 3, 'DataLinkTrigger2', PHYS_None);
        //AddGoalActor(goal, 3, 'AmbientSoundTriggered2', PHYS_None);

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "North Engine Room", NORMAL_GOAL, vect(-384.000000, 1024.000000, -272.000000), rot(0, 49152, 0));
        AddActorLocation(loc, 2, vect(-378, 978, -272), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps Balcony", NORMAL_GOAL, vect(-3296.000000, -1664.000000, -112.000000), rot(0, 81920, 0));
        AddActorLocation(loc, 2, vect(-3300, -1619, -112), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps Hallway", NORMAL_GOAL, vect(-2480.000000, -448.000000, -144.000000), rot(0, 32768, 0));
        AddActorLocation(loc, 2, vect(-2522, -464, -144), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "SE Electrical Room", NORMAL_GOAL, vect(-3952.000000, 768.000000, -416.000000), rot(0, 0, 0));
        AddActorLocation(loc, 2, vect(-3908, 766, -416), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "South Helipad", NORMAL_GOAL, vect(-5664.000000, -928.000000, -432.000000), rot(0, 16384, 0));
        AddActorLocation(loc, 2, vect(-5664, -889, -432), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Helipad Storage Room", NORMAL_GOAL, vect(-4080.000000, -816.000000, -128.000000), rot(0, 32768, 0));
        AddActorLocation(loc, 2, vect(-4120, -816, -128), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Helipad Air Control", NORMAL_GOAL, vect(-4720.000000, 1536.000000, -144.000000), rot(0, -16384, 0));
        AddActorLocation(loc, 2, vect(-4717, 1501, -144), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Fan Room", NORMAL_GOAL, vect(-3200.000000, -48.000000, -96.000000), rot(0, 0, 0));
        AddActorLocation(loc, 2, vect(-3157, -48, -96), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Engine Control Room", NORMAL_GOAL, vect(-288.000000, -432.000000, 112.000000), rot(-16384, 16384, 0));
        AddActorLocation(loc, 2, vect(-288, -426, 62), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "NW Engine Room", NORMAL_GOAL | VANILLA_GOAL, vect(832.000000,1024.000000,-432.000000), rot(0,49152,0));
        AddActorLocation(loc, 2, vect(833.449036, 993.195618, -490.899567), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "NE Electical Room", NORMAL_GOAL | VANILLA_GOAL, vect(-3680.000000,1647.000000,-416.000000), rot(0,49152,0));
        AddActorLocation(loc, 2, vect(-3680.022217, 1616.057861, -490.899567), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "East Helipad", NORMAL_GOAL | VANILLA_GOAL, vect(-6528.000000,200.000000,-448.000000), rot(0,65536,0));
        AddActorLocation(loc, 2, vect(-6499.218750, 200.039917, -490.899567), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps", NORMAL_GOAL | VANILLA_GOAL, vect(-3296.000000,-1662.000000,-416.000000), rot(0,81920,0));
        AddActorLocation(loc, 2, vect(-3296.133789, -1632.118652, -490.899567), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "SW Engine Room", NORMAL_GOAL | VANILLA_GOAL, vect(832.000000,-1024.000000,-416.000000), rot(0,16384,0));
        AddActorLocation(loc, 2, vect(831.944641, -996.442627, -490.899567), rot(0,0,0));

        return 92;
    }

    return mission+1000;
}

function PreFirstEntryMapFixes()
{
    local #var(prefix)Barrel1 barrel;

    if( dxr.localURL == "09_NYC_GRAVEYARD" ) {
        // //barrel next to the transmitter thing, it explodes when I move it
        foreach AllActors(class'#var(prefix)Barrel1', barrel, 'BarrelOFun') {
            barrel.bExplosive = false;
            barrel.Destroy();
        }
    }
}
