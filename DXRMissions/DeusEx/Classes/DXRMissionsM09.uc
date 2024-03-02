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
        AddGoalActor(goal, 7, 'Keypad99', PHYS_None); //this doesn't actually exist, but will get spawned afterwards

        loc=AddGoalLocation("09_NYC_GRAVEYARD", "Main Tunnel", NORMAL_GOAL, vect(-283.503448, -787.867920, -184.000000), rot(0, 0, -32768));
        AddActorLocation(loc, 7, vect(-347.961243,-736.953247,-163.610138), rot(0,-16416,0));

        loc=AddGoalLocation("09_NYC_GRAVEYARD", "Open Grave", NORMAL_GOAL, vect(-766.879333, 501.505676, -88.109619), rot(0, 0, -32768));
        AddActorLocation(loc, 7, vect(-801.517029,480.807953,-8.614368), rot(0,16392,0));

        loc=AddGoalLocation("09_NYC_GRAVEYARD", "Tunnel Ledge", NORMAL_GOAL, vect(-1530.000000, 845.000000, -107.000000), rot(0, 0, -32768));
        AddActorLocation(loc, 7, vect(-1568.019653,909.726563,-89.847336), rot(1700,0,0));

        loc=AddGoalLocation("09_NYC_GRAVEYARD", "Behind Bookshelf", NORMAL_GOAL | VANILLA_GOAL, vect(1103.000000,728.000000,48.000000), rot(0,0,-32768));
        AddActorLocation(loc, 7, vect(1127.001465,763.400208,69.272461), rot(0,-32760,0));
        return 91;

    case "09_NYC_SHIPBELOW":
        //NORMAL_GOAL for Weld Points, GOAL_TYPE1 for the bilge pump computer
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
        AddMapMarker(class'Image09_NYC_Ship_Bottom',320,343,"W","Weld Point", loc,"A weld point can be located at the North end of the engine room.");

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps Balcony", NORMAL_GOAL, vect(-3296.000000, -1664.000000, -112.000000), rot(0, 81920, 0));
        AddActorLocation(loc, 2, vect(-3300, -1619, -112), rot(0,0,0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',166,204,"W","Weld Point", loc,"A weld point can be located on the balcony of the bilge pump room.");

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps Hallway", NORMAL_GOAL, vect(-2480.000000, -448.000000, -144.000000), rot(0, 32768, 0));
        AddActorLocation(loc, 2, vect(-2522, -464, -144), rot(0,0,0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',212,269,"W","Weld Point", loc,"A weld point can be located in the upper hallway next to the bilge pump room.");

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "SE Electrical Room", NORMAL_GOAL, vect(-3950, 740, -352), rot(0, 0, 0));
        AddActorLocation(loc, 2, vect(-3908, 766, -416), rot(0,0,0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',135,135,"W","Weld Point", loc,"A weld point can be located on the South East side of the electrical room.");

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "South Helipad", NORMAL_GOAL, vect(-5664, -926, -418), rot(0, 16384, 0));
        AddActorLocation(loc, 2, vect(-5664, -889, -432), rot(0,0,0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',47,50,"W","Weld Point", loc,"A weld point can be located on the South side of the helipad.");

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Helipad Storage Room", NORMAL_GOAL, vect(-4082, -816, -128), rot(0, 32768, 0));
        AddActorLocation(loc, 2, vect(-4120, -816, -128), rot(0,0,0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',130,247,"W","Weld Point", loc,"A weld point can be located in the helipad storage room.");

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Helipad Air Control", NORMAL_GOAL, vect(-4752, 1536, -144), rot(0, -16384, 0));
        AddActorLocation(loc, 2, vect(-4717, 1501, -144), rot(0,0,0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',97,368,"W","Weld Point", loc,"A weld point can be located in the air control room of the helipad.");

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Fan Room", NORMAL_GOAL, vect(-3200.000000, -48.000000, -96.000000), rot(0, 0, 0));
        AddActorLocation(loc, 2, vect(-3157, -48, -96), rot(0,0,0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',175,286,"W","Weld Point", loc,"A weld point can be located inside the main ventilation fan shaft.");

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Engine Control Room", NORMAL_GOAL, vect(-288.000000, -432.000000, 112.000000), rot(-16384, 16384, 0));
        AddActorLocation(loc, 2, vect(-288, -426, 62), rot(0,0,0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',318,263,"W","Weld Point", loc,"A weld point can be located in the control tower in the engine room.");

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "NW Engine Room", NORMAL_GOAL | VANILLA_GOAL, vect(832, 1022, -430), rot(0,49152,0));
        AddActorLocation(loc, 2, vect(833.449036, 993.195618, -490.899567), rot(0,0,0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',381,148,"W","Weld Point", loc,"A weld point can be located on the North West side of the engine room.  This is a vanilla location.");

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "NE Electical Room", NORMAL_GOAL | VANILLA_GOAL, vect(-3680, 1647, -402), rot(0,49152,0));
        AddActorLocation(loc, 2, vect(-3680.022217, 1616.057861, -490.899567), rot(0,0,0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',152,180,"W","Weld Point", loc,"A weld point can be located on the North East side of the electical room.  This is a vanilla location.");

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "East Helipad", NORMAL_GOAL | VANILLA_GOAL, vect(-6526, 200, -418), rot(0,65536,0));
        AddActorLocation(loc, 2, vect(-6499.218750, 200.039917, -490.899567), rot(0,0,0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',5,109,"W","Weld Point", loc,"A weld point can be located on the East side of the helipad.  This is a vanilla location.");

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps", NORMAL_GOAL | VANILLA_GOAL, vect(-3296.000000,-1662.000000,-416.000000), rot(0,81920,0));
        AddActorLocation(loc, 2, vect(-3296.133789, -1632.118652, -490.899567), rot(0,0,0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',171,11,"W","Weld Point", loc,"A weld point can be located next to the bilge pumps.  This is a vanilla location.");

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "SW Engine Room", NORMAL_GOAL | VANILLA_GOAL, vect(832, -1024, -400), rot(0,16384,0));
        AddActorLocation(loc, 2, vect(831.944641, -996.442627, -490.899567), rot(0,0,0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',385,44,"W","Weld Point", loc,"A weld point can be located on the South West side of the engine room, behind a wall.  This is a vanilla location.");


        goal = AddGoal("09_NYC_SHIPBELOW", "Bilge Pump Computer", GOAL_TYPE1, 'ComputerPersonal0', PHYS_Falling);
        AddGoalActor(goal, 1, 'DataLinkTrigger4', PHYS_None);
        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pump Room", GOAL_TYPE1 | VANILLA_GOAL, vect(-2447.407959, -689.854431, -456.500488), rot(0, -15815, 0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',208,54,"C","Bilge Computer", loc,"The bilge pump computer can be located on a desk in the corner of the bilge pump room.  This is the vanilla location.");
        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Helibay Barracks", GOAL_TYPE1, vect(-5505, 175, -432), rot(0, 0, 0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',51,102,"C","Bilge Computer", loc,"The bilge pump computer can be located on a bed in the barracks underneath the helicopter in the helibay.");
        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Engine Room Tower", GOAL_TYPE1, vect(-133,-678,15), rot(0, -15815, 0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',328,256,"C","Bilge Computer", loc,"The bilge pump computer can be found in the control tower in the engine room.");
        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Helipad Air Control", GOAL_TYPE1, vect(-4987,1176,-205), rot(0, 32710, 0));
        AddMapMarker(class'Image09_NYC_Ship_Bottom',78,353,"C","Bilge Computer", loc,"The bilge pump computer can be found in the air control room of the helipad.");

        return 92;

    case "09_NYC_DOCKYARD":
        AddGoal("09_NYC_DOCKYARD", "Jock", NORMAL_GOAL, 'BlackHelicopter0', PHYS_None);
        AddGoalLocation("09_NYC_DOCKYARD", "Roof", NORMAL_GOAL | VANILLA_GOAL, vect(3324.307617, 6731.588379, 1459.857788), rot(0, -19856, 0));
        AddGoalLocation("09_NYC_DOCKYARD", "In Front of Ammo Storage", NORMAL_GOAL, vect(3226.842773, 2405.506348, 111.857788), rot(0, 10000, 0));
        AddGoalLocation("09_NYC_DOCKYARD", "Inside Warehouse", NORMAL_GOAL, vect(563.842773, 4372.506348, 111.857788), rot(0, 15000, 0));
        AddGoalLocation("09_NYC_DOCKYARD", "Sewer", NORMAL_GOAL, vect(2001.842773, 5715.506348, -164.142212), rot(0, 15000, 0));
        return 93;
    }

    return mission+1000;
}

function int InitGoalsRev(int mission, string map)
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
        AddGoalActor(goal, 7, 'Keypad99', PHYS_None); //this doesn't actually exist, but will get spawned afterwards

        loc=AddGoalLocation("09_NYC_GRAVEYARD", "Main Tunnel", NORMAL_GOAL, vect(-496,-896,-192), rot(0, 0, -32768));
        AddActorLocation(loc, 7, vect(-564.036,-977.077,-163.61), rot(0,-16416,0));

        loc=AddGoalLocation("09_NYC_GRAVEYARD", "Open Grave", NORMAL_GOAL, vect(-766.879333, 533, -88.109619), rot(0, 0, -32768));
        AddActorLocation(loc, 7, vect(-801.517029,480.807953,-8.614368), rot(0,16392,0));

        loc=AddGoalLocation("09_NYC_GRAVEYARD", "Tunnel Ledge", NORMAL_GOAL, vect(-2176,-2112,-128), rot(0, 0, -32768));
        AddActorLocation(loc, 7, vect(-2175,-2194,-88), rot(1700,16392,0));

        loc=AddGoalLocation("09_NYC_GRAVEYARD", "Behind Bookshelf", NORMAL_GOAL | VANILLA_GOAL, vect(1104.000000,736.000000,48.000000), rot(0,0,-32768));
        AddActorLocation(loc, 7, vect(1127.001465,763.400208,69.272461), rot(0,-32760,0));
        return 91;

    case "09_NYC_SHIPBELOW":
        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 1", NORMAL_GOAL, 'DeusExMover64', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator10', PHYS_None);
        AddGoalActor(goal, 2, 'DataLinkTrigger8', PHYS_None);

        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 2", NORMAL_GOAL, 'DeusExMover16', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator4', PHYS_None);
        AddGoalActor(goal, 2, 'DataLinkTrigger0', PHYS_None);

        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 3", NORMAL_GOAL, 'DeusExMover33', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator7', PHYS_None);
        AddGoalActor(goal, 2, 'DataLinkTrigger3', PHYS_None);

        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 4", NORMAL_GOAL, 'DeusExMover31', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator5', PHYS_None);
        AddGoalActor(goal, 2, 'DataLinkTrigger1', PHYS_None);

        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 5", NORMAL_GOAL, 'DeusExMover32', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator6', PHYS_None);
        AddGoalActor(goal, 2, 'DataLinkTrigger2', PHYS_None);

        //There's a door in Revision where this was in Vanilla
        //loc = AddGoalLocation("09_NYC_SHIPBELOW", "North Engine Room", NORMAL_GOAL, vect(-384.000000, 1024.000000, -272.000000), rot(0, 49152, 0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps Balcony", NORMAL_GOAL, vect(-3296.000000, -1664.000000, -112.000000), rot(0, 81920, 0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps Hallway", NORMAL_GOAL, vect(-2480.000000, -448.000000, -144.000000), rot(0, 32768, 0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "SE Electrical Room", NORMAL_GOAL, vect(-3952.000000, 768.000000, -416.000000), rot(0, 0, 0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "South Helipad", NORMAL_GOAL, vect(-5664.000000, -928.000000, -432.000000), rot(0, 16384, 0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Helipad Storage Room", NORMAL_GOAL, vect(-4080.000000, -816.000000, -128.000000), rot(0, 32768, 0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Helipad Air Control", NORMAL_GOAL, vect(-4720.000000, 1536.000000, -144.000000), rot(0, -16384, 0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Fan Room", NORMAL_GOAL, vect(-3200.000000, -48.000000, -96.000000), rot(0, 0, 0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Engine Control Room", NORMAL_GOAL, vect(-288.000000, -432.000000, 112.000000), rot(-16384, 16384, 0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "NW Engine Room", NORMAL_GOAL | VANILLA_GOAL, vect(848,1024,-416), rot(0,49152,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "NE Electical Room", NORMAL_GOAL | VANILLA_GOAL, vect(-3680.000000,1648.000000,-416.000000), rot(0,49152,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "East Helipad", NORMAL_GOAL | VANILLA_GOAL, vect(-6528.000000,192.000000,-448.000000), rot(0,65536,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps", NORMAL_GOAL | VANILLA_GOAL, vect(-3296.000000,-1664.000000,-416.000000), rot(0,81920,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "SW Engine Room", NORMAL_GOAL | VANILLA_GOAL, vect(816.000000,-1024.000000,-416.000000), rot(0,16384,0));

        return 92;

    case "09_NYC_DOCKYARD":
        AddGoal("09_NYC_DOCKYARD", "Jock", NORMAL_GOAL, 'BlackHelicopter0', PHYS_None);
        AddGoalLocation("09_NYC_DOCKYARD", "Roof", NORMAL_GOAL | VANILLA_GOAL, vect(3359.76,6789.344,1459), rot(0, -19856, 0));
        AddGoalLocation("09_NYC_DOCKYARD", "In Front of Ammo Storage", NORMAL_GOAL, vect(3371,2862,112), rot(0, 0, 0));
        AddGoalLocation("09_NYC_DOCKYARD", "Inside Warehouse", NORMAL_GOAL, vect(563.842773, 4372.506348, 111.857788), rot(0, 15000, 0));
        AddGoalLocation("09_NYC_DOCKYARD", "Sewer", NORMAL_GOAL, vect(2001.842773, 5715.506348, -164.142212), rot(0, 0, 0));
        return 93;

    }

    return mission+1000;
}

function PreFirstEntryMapFixes()
{
    local #var(prefix)Barrel1 barrel;
    local #var(prefix)DataLinkTrigger dlt;
    local DeusExMover dxm;
    local Actor a;
    local name barrelName;
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    if( dxr.localURL == "09_NYC_GRAVEYARD" ) {
        // //barrel next to the transmitter thing, it explodes when I move it
        if(RevisionMaps){
            barrelName='EMOff';
        } else {
            barrelName='BarrelOFun';
        }
        foreach AllActors(class'#var(prefix)Barrel1', barrel, barrelName) {
            barrel.bExplosive = false;
            barrel.Destroy();
        }

        SpawnDatacubePlaintext(vectm(1102.252563,821.384338,26.370010),rotm(0,0,0),"I installed that big device you asked for, but it's really blasting out a lot of EM interference...|n|nIf an FCC inspector comes around, you can turn it off by using the code 8854 ");
    } else if (dxr.localURL=="09_NYC_SHIPBELOW"){
        if(RevisionMaps){
            foreach AllActors(class'DeusExMover',dxm){
                if (dxm.Name=='DeusExMover64' ||
                    dxm.Name=='DeusExMover16' ||
                    dxm.Name=='DeusExMover33' ||
                    dxm.Name=='DeusExMover31' ||
                    dxm.Name=='DeusExMover32'){
                    //The two locations in the engine room are unbreakable until you open
                    //the doors to their magic boxes, presumably to get around movers
                    //taking explosion damage through walls.  Since we're shuffling everything,
                    //fuck that.  Also those ones were inexplicably stronger, so make them all
                    //the same strength.
                    dxm.bBreakable=True;
                    dxm.minDamageThreshold=60;
                }

                //Adjust the prepivots of all the movers to the values set in vanilla
                //They seem to be using the exact same brushes, so there's no good reason
                //to be different, as far as I can tell
                if (dxm.Name=='DeusExMover64'){
                    dxm.PrePivot=vect(-3,-2.5,7);
                }else if (dxm.Name=='DeusExMover16'){
                    dxm.PrePivot=vect(-2.999878,-5.500122,3);
                }else if (dxm.Name=='DeusExMover33'){
                    dxm.PrePivot=vect(-2.999756,-2.5,7);
                }else if (dxm.Name=='DeusExMover31'){
                    dxm.PrePivot=vect(-2,-2.5,7);
                }else if (dxm.Name=='DeusExMover32'){
                    dxm.PrePivot=vect(-3,-2.499756,-1);
                }

            }
        } else {
            foreach AllActors(class'DeusExMover',dxm){
                if (dxm.Name=='DeusExMover40' ||
                    dxm.Name=='DeusExMover16' ||
                    dxm.Name=='DeusExMover33' ||
                    dxm.Name=='DeusExMover31' ||
                    dxm.Name=='DeusExMover32'){
                    dxm.PrePivot=vect(-3,-2.5,5);
                }
            }
            a = Spawnm(class'DynamicBlockMonsters',,, vect(-3926.773438, 739.635742, -456.895294));
            a.SetCollisionSize(100, 64);
        }

        foreach AllActors(class'#var(prefix)DataLinkTrigger',dlt){
            if (dlt.datalinkTag=='DL_Bilge'){
                dlt.SetCollisionSize(dlt.CollisionRadius*2,dlt.CollisionHeight);
            }
        }
    }
}

function AfterMoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local #var(prefix)Keypad1 keypad;
    local SpecialEvent se;

    if (g.name=="Jammer") {
        //Add a keypad to disable the jammer
        keypad = #var(prefix)Keypad1(AddActor(class'#var(prefix)Keypad1',Loc.positions[7].pos,Loc.positions[7].rot));
        keypad.Event='EMOff';
        keypad.bHackable=True;
        keypad.hackStrength=0.05;
        keypad.validCode="8854";
        keypad.bToggleLock=False;

        se=Spawn(class'SpecialEvent',,,vectm(1527,782,0));
        se.Tag='EMOff';
        se.Message="EM Field Disabled";
        se.GoToState('DisplayMessage');
    }
}


function MissionTimer()
{
    switch(dxr.localURL)
    {
    case "09_NYC_GRAVEYARD":
        UpdateGoalWithRandoInfo('EliminateField', "The EM generator could be anywhere in the graveyard.");
        break;
    default:
        UpdateGoalWithRandoInfo('Escape', "Jock could be anywhere at the dockyard.");
        UpdateGoalWithRandoInfo('ScuttleShip', "Check the map in your Images section to see where the weld points can be.");
    }
}
