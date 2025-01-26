class DXRFixupVandenberg extends DXRFixup;

var bool M14GaryNotDone;
var bool M12GaryHostageBriefing;
var int storedBotCount;// MJ12 bots in CMD

function CheckConfig()
{
    local int i;

    add_datacubes[i].map = "12_VANDENBERG_GAS";
    add_datacubes[i].imageClass = class'Image12_Tiffany_HostagePic';
    add_datacubes[i].location = vect(-107.1, 901.3, -939.4);
    i++;

    Super.CheckConfig();
}

function PreFirstEntryMapFixes()
{
    local ElevatorMover e;
    local ComputerSecurity comp;
    local KarkianBaby kb;
    local DataLinkTrigger dlt;
    local FlagTrigger ft;
    local #var(prefix)HowardStrong hs;
    local #var(prefix)WaltonSimons ws;
    local #var(DeusExPrefix)Mover door;
    local DXREnemies dxre;
    local #var(prefix)TracerTong tt;
    local SequenceTrigger st;
    local #var(prefix)ShopLight sl;
    local #var(prefix)RatGenerator rg;
    local #var(prefix)OrdersTrigger ot;
    local #var(prefix)NanoKey key;
    local #var(prefix)DamageTrigger dt;
    local #var(prefix)BeamTrigger bt;
    local #var(prefix)LaserTrigger lt;
    local OnceOnlyTrigger oot;
    local Actor a;
    local #var(prefix)PigeonGenerator pg;
    local #var(prefix)FishGenerator fg;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
#ifdef revision
    local JockHelicopter jockheli;
#endif
    local DXRHoverHint hoverHint;
    local ScriptedPawn pawn;
    local #var(prefix)ScriptedPawn sp;
    local #var(prefix)Robot bot;
    local #var(prefix)TiffanySavage tiffany;
    local #var(prefix)SecurityCamera sc;
    local Dispatcher d;
    local string botName;
    local int securityBotNum, militaryBotNum;
    local #var(prefix)DataCube dc;
    local #var(prefix)Teleporter t;
    local #var(prefix)Fan1 fan;
    local #var(prefix)Fan2 fan2;
    local DynamicTeleporter dynt;
    local CrateUnbreakableSmall cus;

    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL)
    {
    case "12_VANDENBERG_CMD":
        // add goals and keypad code
        // you've definitely met Jock at Everett's helipad
        player().GoalCompleted('MeetJock');

        foreach AllActors(class'#var(prefix)TracerTong', tt) {
            RemoveReactions(tt);// he looks pretty sick
        }

        class'PlaceholderEnemy'.static.Create(self,vectm(-2467,866,-2000));
        class'PlaceholderEnemy'.static.Create(self,vectm(-2689,4765,-2143));
        class'PlaceholderEnemy'.static.Create(self,vectm(-163,7797,-2143));
        class'PlaceholderEnemy'.static.Create(self,vectm(2512,6140,-2162));
        class'PlaceholderEnemy'.static.Create(self,vectm(2267,643,-2000));

        class'PlaceholderEnemy'.static.Create(self,vectm(-1702,1839,-2000),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(-1623,1826,-2000),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(-1456,1806,-2000),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(-1354,1813,-2000),,'Sitting');

        // some extra platforming!
        sl = #var(prefix)ShopLight(AddActor(class'#var(prefix)ShopLight', vect(1.125000, 938.399963, -1025), rot(0, 16384, 0)));
        sl.bInvincible = true;
        sl.bCanBeBase = true;

        rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(-1975,227,-2191));//Near generator
        rg.MaxCount=1;
        rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(6578,8227,-3101));//Near guardhouse
        rg.MaxCount=1;

        //Clear out items in inaccessible containers far below the earth
        foreach RadiusActors(class'Actor', a, 250, vectm(-4350,3000,-5850)) {
            a.Destroy();
        }

        foreach AllActors(class'#var(prefix)DamageTrigger',dt){
            if (dt.DamageType=='Shocked'){
                dt.Tag='lab_water';
            }
        }

        pg=Spawn(class'#var(prefix)PigeonGenerator',,, vectm(2065,2785,-871));//CMD Rooftop
        pg.MaxCount=3;

        foreach AllActors(class'#var(DeusExPrefix)Mover',door){
            if(door.name=='DeusExMover15'){
                door.Tag='CmdBackDoor';
            }
        }
        AddSwitch( vect(-278.854828,657.390503,-1977.144531), rot(0, 16384, 0), 'CmdBackDoor');

        if (VanillaMaps){
            //Patch holes in the wall in the vanilla map
            class'FillCollisionHole'.static.CreateLine(self, vectm(3081.067383, 1640, -2031.417969), vectm(3081.067383, 6584, -2031.417969), 40, 300);

            VandenbergCmdFixTimsDoor();
            FixCmdElevator();
            UnleashingBotsOpenCommsDoor();
        } else {
            VandenbergCmdRevisionFixWatchtowerDoor();
        }

        //Add teleporter hint text to Jock
        foreach AllActors(class'#var(prefix)MapExit',exit,'mission_done'){break;}
        if (VanillaMaps){
            foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'Helicopter'){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit);
            hoverHint.SetBaseActor(jock);
        } else {
        #ifdef revision
            foreach AllActors(class'JockHelicopter',jockheli){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jockheli.Location, jockheli.CollisionRadius+5, jockheli.CollisionHeight+5, exit,, true);
            hoverHint.SetBaseActor(jockheli);
        #endif
        }

        foreach AllActors(class'#var(prefix)Robot',bot,'enemy_bot') {
            if (#var(prefix)SecurityBot2(bot) != None) {
                botName = "MJ12 Security Bot " $ ++securityBotNum;
            } else if (#var(prefix)MilitaryBot(bot) != None) {
                botName = "MJ12 Military Bot " $ ++militaryBotNum;
            } else {
                botName = "MJ12 Bot";
            }

            hoverHint = class'DXRHoverHint'.static.Create(self, botName, bot.Location, bot.CollisionRadius*1.11, bot.CollisionHeight*1.11, bot);
            hoverHint.SetBaseActor(bot);
            hoverHint.VisibleDistance = 15000;
        }

        //There are 3 cameras in CMD that have 20 memoryTime instead of the default 5
        //These are the only ones with non-default in the whole game.  Revert them.
        foreach AllActors(class'#var(prefix)SecurityCamera',sc){
            sc.memoryTime = sc.Default.memoryTime;
        }

        break;

    case "12_VANDENBERG_TUNNELS":

        foreach AllActors(class'ElevatorMover', e, 'Security_door3') {
            e.BumpType = BT_PlayerBump;
            e.BumpEvent = 'SC_Door3_opened';
        }
        //Duplicate the dispatcher for both ends of the radioactive room that sets off the alarms and explosion
        d = Spawn(class'Dispatcher',, 'SC_Door3_opened' );
        d.OutEvents[0]='Warning';
        d.OutDelays[0]=0;
        d.OutEvents[1]='tnt';
        d.OutDelays[1]=3;
        d.OutEvents[2]='Warning';
        d.OutDelays[2]=2;

        if (VanillaMaps){
            //Backtracking button next to security door 3
            AddSwitch( vect(-396.634888, 2295, -2542.310547), rot(0, -16384, 0), 'SC_Door3_opened').bCollideWorld = false;

            //Swap the beam triggers that set off this turret to LaserTrigger for clarity
            foreach AllActors(class'#var(prefix)BeamTrigger',bt){
                if (bt.Tag=='Turret_beam'){
                    lt = #var(prefix)LaserTrigger(SpawnReplacement(bt,class'#var(prefix)LaserTrigger'));
                    lt.TriggerType=bt.TriggerType;
                    lt.bTriggerOnceOnly = bt.bTriggerOnceOnly;
                    lt.bDynamicLight = bt.bDynamicLight;
                    lt.bIsOn = bt.bIsOn;
                    bt.Destroy();
                }
            }

            Spawn(class'PlaceholderItem',,, vectm(-3227,3679,-2599)); //floor near stairwell down to flooded area
            Spawn(class'PlaceholderItem',,, vectm(-1590,2796,-2599)); //airlock after spiderbot trap
        } else {
            //Backtracking button next to security door 3 (Different X location in Revision)
            AddSwitch( vect(2710, 2295, -2542), rot(0, -16384, 0), 'SC_Door3_opened').bCollideWorld = false;

            //Backtracking button on backside of end-of-tunnels forklift
            AddSwitch( vect(2778,1371,-2550), rot(0, -10904, 0), 'waataaa');

            Spawn(class'PlaceholderItem',,, vectm(-3227,3679,-2520)); //boxes near stairwell down to flooded area
            Spawn(class'PlaceholderItem',,, vectm(-1640,2796,-2599)); //airlock after spiderbot trap
        }

        Spawn(class'PlaceholderItem',,, vectm(-2227,4220,-2519)); //on top of generator
        Spawn(class'PlaceholderItem',,, vectm(-1421,5119,-2534)); //on top of boxes near start
        Spawn(class'PlaceholderItem',,, vectm(-1205,5271,-2534)); //on top of boxes near start
        Spawn(class'PlaceholderItem',,, vectm(-2676,3649,-2599)); //stairwell down to flooded area

        Spawn(class'PlaceholderContainer',,, vectm(-2250,4586,-2577)); //across from generator
        Spawn(class'PlaceholderContainer',,, vectm(-2414,4329,-2577)); //near generator
        Spawn(class'PlaceholderContainer',,, vectm(-3175,3194,-2577)); //near stairwell to flooded area
        Spawn(class'PlaceholderContainer',,, vectm(-1399,4950,-2565)); //near boxes near start
        Spawn(class'PlaceholderContainer',,, vectm(-3083,2798,-2577)); //near corner near spiderbot trap
        Spawn(class'PlaceholderContainer',,, vectm(-325,1386,-2577)); //after the pit

        if (!#defined(vanilla)){
            //Disable collision on the MapExit's before shuffling so that the moving items don't trigger them
            //For Vanilla, this is fixed in DXRBacktracking, but nothing else uses that module (yet)
            foreach AllActors(class'#var(prefix)MapExit',exit){
                exit.Tag='';
                exit.SetCollision(False,False,False);
            }

            dynt = Spawn(class'DynamicTeleporter',,,vectm(-1625,5743,-2364)); //Start
            dynt.SetCollisionSize(30,15);
            dynt.SetDestination("12_vandenberg_cmd",,"commstat");

            if (VanillaMaps){
                dynt = Spawn(class'DynamicTeleporter',,,vectm(398,1164,-2356)); //End
            } else {
                dynt = Spawn(class'DynamicTeleporter',,,vectm(3366,1164,-2356)); //End
            }
            dynt.SetCollisionSize(30,15);
            dynt.SetDestination("12_vandenberg_cmd",,"storage");
        }
        break;

    case "14_VANDENBERG_SUB":
        //Door into base from shore (inside)
        AddSwitch( vect(2279.640137,3638.638184,-398.255676), rot(0, -16384, 0), 'door_base');

        foreach AllActors(class'#var(DeusExPrefix)Mover',door){
            if(door.KeyIDNeeded=='shed'){
                door.Tag='ShedDoor';
            }
            if (door.Tag=='Elevator1'){
                door.MoverEncroachType=ME_CrushWhenEncroach;
            }
            if(door.Tag=='sub_doors'){
                door.bLocked = true;
                door.bHighlight = true;
                door.bFrobbable = true;
                door.bPickable = false;// make sure DXRDoors sees this as an undefeatable door, also in vanilla this door is obviously not pickable due to not being frobbable

                //Fix prepivot, since the upper door was set way off to the side.  Just adjust both in the same way
                //so that they are centered roughly in the middle of the door
                RemoveMoverPrePivot(door);
            }
        }

        if (VanillaMaps){
            //Elevator down to lower level
            AddSwitch( vect(3790.639893, -488.639587, -369.964142), rot(0, 32768, 0), 'Elevator1');
            AddSwitch( vect(3799.953613, -446.640015, -1689.817993), rot(0, 16384, 0), 'Elevator1');

            foreach AllActors(class'KarkianBaby',kb) {
                if(kb.BindName == "tankkarkian"){
                    kb.BindName = "TankKharkian";
                }
            }
            rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(737,4193,-426));//In shoreside shed
            rg.MaxCount=1;

            Spawn(class'PlaceholderItem',,, vectm(755,4183,-421)); //Shed
            Spawn(class'PlaceholderItem',,, vectm(755,4101,-421)); //Shed
            Spawn(class'PlaceholderItem',,, vectm(462,4042,-421)); //Shed
            Spawn(class'PlaceholderItem',,, vectm(462,3986,-421)); //Shed
            Spawn(class'PlaceholderItem',,, vectm(462,3939,-421)); //Shed

            AddSwitch( vect(654.545,3889.5397,-367.262), rot(0, 16384, 0), 'ShedDoor');

            fg=Spawn(class'#var(prefix)FishGenerator',,, vectm(5657,-1847,-1377));//Near tunnel to sub bay
            fg.ActiveArea=20000; //Long line of sight on this one...  Want it to trigger early

            //Add teleporter hint text to Jock
            foreach AllActors(class'#var(prefix)MapExit',exit,'ChopperExit'){break;}
            foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'BlackHelicopter'){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit);
            hoverHint.SetBaseActor(jock);
        } else {
            AddSwitch( vect(540,3890,-370), rot(0, 16384, 0), 'ShedDoor');

            //Add teleporter hint text to Jock
            #ifdef revision
            foreach AllActors(class'#var(prefix)MapExit',exit,'ChopperExit'){break;}
            foreach AllActors(class'JockHelicopter',jockheli,'BlackHelicopter'){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jockheli.Location, jockheli.CollisionRadius+5, jockheli.CollisionHeight+5, exit,, true);
            hoverHint.SetBaseActor(jockheli);
            #endif

            Spawn(class'PlaceholderItem',,, vectm(718,3913,-355)); //Shed
            Spawn(class'PlaceholderItem',,, vectm(723,3972,-355)); //Shed
            Spawn(class'PlaceholderItem',,, vectm(726,4050,-365)); //Shed
            Spawn(class'PlaceholderItem',,, vectm(740,4203,-420)); //Shed
            Spawn(class'PlaceholderItem',,, vectm(555,4207,-420)); //Shed
        }
        break;

    case "14_OCEANLAB_LAB":

        // backtracking button for crew module
        AddSwitch( vect(4888.692871, 3537.360107, -1753.115845), rot(0, 16384, 0), 'crewkey').bCollideWorld = false;
        // backtracking button for greasel lab
        AddSwitch( vect(1889.5, 491.932892, -1535.522339), rot(0, 0, 0), 'Glab');

        foreach AllActors(class'#var(DeusExPrefix)Mover',door){
            if(door.KeyIDNeeded=='crewkey'){
                door.Tag = 'crewkey';
            }
            if(door.KeyIDNeeded=='Glab'){
                door.Tag = 'Glab';
            }
        }

        if (VanillaMaps){
            if(!#defined(vmd))// button to open the door heading towards the ladder in the water
                AddSwitch( vect(3077.360107, 497.609467, -1738.858521), rot(0, 0, 0), 'Access');

            foreach AllActors(class'ComputerSecurity', comp) {
                if( comp.UserList[0].userName == "Kraken" && comp.UserList[0].Password == "Oceanguard" ) {
                    comp.UserList[0].userName = "Oceanguard";
                    comp.UserList[0].Password = "Kraken";
                }
            }

            //There is an invisible wall that makes this location hard to reach on the mirrored map.
            //just nudge the datacube over a bit
            foreach AllActors(class'#var(prefix)DataCube',dc){
                if(dc.TextTag=='14_Datacube06'){
                    dc.SetLocation(vectm(4169,407,-1540));
                    break;
                }
            }

            foreach AllActors(class'#var(prefix)Teleporter',t){
                if (t.URL=="14_OceanLab_UC.dx #UC"){
                    t.SetCollisionSize(t.CollisionRadius,150); //Taller so you can't jump over
                }
            }

            foreach AllActors(class'#var(prefix)WaltonSimons',ws){
                ws.MaxProvocations = 0;
                ws.AgitationSustainTime = 3600;
                ws.AgitationDecayRate = 0;
            }

            Spawn(class'PlaceholderItem',,, vectm(37.5,531.4,-1569)); //Secretary desk
            Spawn(class'PlaceholderItem',,, vectm(2722,226.5,-1481)); //Greasel Lab desk
            Spawn(class'PlaceholderItem',,, vectm(4097.8,395.4,-1533)); //Desk with zappy electricity near construction zone
            Spawn(class'PlaceholderItem',,, vectm(4636.1,1579.3,-1741)); //Electrical box in construction zone
            Spawn(class'PlaceholderItem',,, vectm(5359.5,3122.3,-1761)); //Construction vehicle tread
            Spawn(class'PlaceholderItem',,, vectm(3114.3,3711.2,-2549)); //Storage room in crew capsule

            Spawn(class'PlaceholderContainer',,, vectm(-71,775,-1599)); //Secretary desk corner
            Spawn(class'PlaceholderContainer',,, vectm(1740,156,-1599)); //Open storage room
            Spawn(class'PlaceholderContainer',,, vectm(2999,482,-1503)); //Greasel lab
            Spawn(class'PlaceholderContainer',,, vectm(1780,3725,-2483)); //Crew module bed
            Spawn(class'PlaceholderContainer',,, vectm(1733,3848,-4223)); //Corner in hall to UC
        } else {
            Spawn(class'PlaceholderItem',,, vectm(217,750,-1570)); //Secretary desk
            Spawn(class'PlaceholderItem',,, vectm(2722,226.5,-1481)); //Greasel Lab desk
            Spawn(class'PlaceholderItem',,, vectm(4097.8,395.4,-1533)); //Desk with zappy electricity near construction zone
            Spawn(class'PlaceholderItem',,, vectm(4202,2552,-1740)); //Electrical box in construction zone
            Spawn(class'PlaceholderItem',,, vectm(5359.5,3122.3,-1761)); //Construction vehicle tread
            Spawn(class'PlaceholderItem',,, vectm(3114,3687,-2530)); //Storage room in crew capsule

            Spawn(class'PlaceholderItem',,, vectm(-163,732,-2190));
            Spawn(class'PlaceholderItem',,, vectm(470,678,-1955));
            Spawn(class'PlaceholderItem',,, vectm(5,815,-1760));
            Spawn(class'PlaceholderItem',,, vectm(-72,-523,-1570));
            Spawn(class'PlaceholderItem',,, vectm(258,-539,-1580));
            Spawn(class'PlaceholderItem',,, vectm(432,-359,-1570));

            Spawn(class'PlaceholderContainer',,, vectm(-165,509,-1590)); //Secretary desk corner
            Spawn(class'PlaceholderContainer',,, vectm(1740,156,-1599)); //Open storage room
            Spawn(class'PlaceholderContainer',,, vectm(3000,-108,-1500)); //Greasel lab
            Spawn(class'PlaceholderContainer',,, vectm(1780,3725,-2483)); //Crew module bed
            Spawn(class'PlaceholderContainer',,, vectm(1733,3848,-4223)); //Corner in hall to UC
        }
        break;
    case "14_OCEANLAB_UC":
        if (VanillaMaps){
            //This door can get stuck if a spiderbot gets jammed into the little bot-bay
            foreach AllActors(class'#var(DeusExPrefix)Mover', door, 'Releasebots') {
                door.MoverEncroachType=ME_IgnoreWhenEncroach;
            }

            foreach AllActors(class'#var(prefix)BeamTrigger',bt,'Lasertrip'){
                bt.Event='ReleasebotsOnce';
            }

            oot=Spawn(class'OnceOnlyTrigger');
            oot.Event='Releasebots';
            oot.Tag='ReleasebotsOnce';

            Spawn(class'PlaceholderItem',,, vectm(1020.93,8203.4,-2864)); //Over security computer
            Spawn(class'PlaceholderItem',,, vectm(348.9,8484.63,-2913)); //Turret room
            Spawn(class'PlaceholderItem',,, vectm(1280.84,8534.17,-2913)); //Turret room
            Spawn(class'PlaceholderItem',,, vectm(1892,8754.5,-2901)); //Turret room, opposite from bait computer
        } else {
            //This door can get stuck if a spiderbot gets jammed into the little bot-bay
            foreach AllActors(class'#var(DeusExPrefix)Mover', door, 'ALARMS') {
                door.MoverEncroachType=ME_IgnoreWhenEncroach;
                door.Tag='AlarmsOnce';
            }

            oot=Spawn(class'OnceOnlyTrigger');
            oot.Event='AlarmsOnce';
            oot.Tag='ALARMS';

            Spawn(class'PlaceholderItem',,, vectm(1084,8200,-2860)); //Over security computer
            Spawn(class'PlaceholderItem',,, vectm(1780,8587,-2790)); //Turret room
            Spawn(class'PlaceholderItem',,, vectm(423,8547,-2900)); //Turret room
            Spawn(class'PlaceholderItem',,, vectm(73,9110,-2910)); //Turret room, opposite from bait computer
        }

        //Make the datalink immediately trigger when you download the schematics, regardless of where the computer is
        foreach AllActors(class'FlagTrigger',ft,'schematic'){
            ft.bTrigger = True;
            ft.event = 'schematic2';
        }
        foreach AllActors(class'DataLinkTrigger',dlt){
            if (dlt.datalinkTag=='dl_downloaded'){
                dlt.Tag = 'schematic2';
            }
        }

        foreach AllActors(class'#var(prefix)Fan1',fan){
            fan.bHighlight=True;
        }

        break;

    case "14_Oceanlab_silo":
        if (VanillaMaps){
            if(!dxr.flags.IsReducedRando()) {
                foreach AllActors(class'#var(prefix)HowardStrong', hs) {
                    hs.ChangeAlly('', 1, true);
                    hs.ChangeAlly('mj12', 1, true);
                    hs.ChangeAlly('spider', 1, true);
                    RemoveFears(hs);
                    hs.MinHealth = 0;
                    hs.BaseAccuracy *= 0.1;

                    GiveItem(hs, class'#var(prefix)BallisticArmor');
                    dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
                    if(dxre != None) {
                        dxre.GiveRandomWeapon(hs, false, 2);
                        dxre.GiveRandomMeleeWeapon(hs);
                    }
                    hs.FamiliarName = "Howard Stronger";
                    hs.UnfamiliarName = "Howard Stronger";

                    if(!#defined(vmd)) {// vmd allows AI to equip armor, so maybe he doesn't need the health boost?
                        SetPawnHealth(hs, 200);
                    }

                    hs.LeaveWorld();
                }
            }

            class'FrictionTrigger'.static.CreateIce(self, vectm(28.63,-5129.48,-231.285), 1190, 650);

            // one of the small crates inside the bathroom jail. can otherwise be impossible to get out of it without speed aug
            foreach RadiusActors(class'CrateUnbreakableSmall', cus, 0.1, vectm(288.01, -1402.41, 488.10)) {
                cus.bIsSecretGoal = true;
                break;
            }

            class'PlaceholderEnemy'.static.Create(self,vectm(270,-6601,1500)); //This one is locked inside a fence in Revision, so only use it in Vanilla
        }

        //Add teleporter hint text to Jock
        foreach AllActors(class'#var(prefix)MapExit',exit,'ExitPath'){break;}
        foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'BlackHelicopter'){break;}
        hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit,, true);
        hoverHint.SetBaseActor(jock);

        //The door closing behind you when the ambush starts sucks if you came in via the silo.
        //Just make it not close.
        foreach AllActors(class'SequenceTrigger', st, 'doorclose') {
            if (st.Event=='blast_door4' && st.Tag=='doorclose'){
                st.Event = '';
                st.Tag = 'doorclosejk';
                break;
            }
        }

        class'PlaceholderEnemy'.static.Create(self,vectm(-264,-6991,-553));
        class'PlaceholderEnemy'.static.Create(self,vectm(-312,-6886,327));
        class'PlaceholderEnemy'.static.Create(self,vectm(-1257,-3472,1468));
        class'PlaceholderEnemy'.static.Create(self,vectm(1021,-3323,1476));


        dxr.flagbase.SetBool('MS_UnhideHelicopter', True,, 15);
        foreach AllActors(class'DataLinkTrigger', dlt, 'klax') {
            dlt.Destroy();
            break;
        }

        break;
    case "12_VANDENBERG_COMPUTER":
        foreach AllActors(class'#var(prefix)OrdersTrigger',ot,'GaryWalksToPosition'){
            ot.Orders='RunningTo';
            ot.ordersTag='gary_patrol1';
        }

        //Show the strength of the fan grill
        foreach AllActors(class'#var(DeusExPrefix)Mover',door,'BreakableWall'){
            door.bHighlight = true;
            door.bLocked=true;
            door.bPickable=false;
        }

        foreach AllActors(class'#var(prefix)Fan2',fan2){
            fan2.bHighlight=True;
        }

        Spawn(class'PlaceholderItem',,, vectm(579,2884,-1629)); //Table near entrance
        Spawn(class'PlaceholderItem',,, vectm(1057,2685.25,-1637)); //Table overlooking computer room
        Spawn(class'PlaceholderItem',,, vectm(1970,2883.43,-1941)); //In first floor computer room

        break;

    case "12_VANDENBERG_GAS":
        //Make Tiffany actually move like a useful human being
        foreach AllActors(class'#var(prefix)TiffanySavage',tiffany){
            tiffany.GroundSpeed = 180;
            tiffany.walkAnimMult = 1;
        }

        foreach AllActors(class'#var(prefix)ScriptedPawn',sp,'guard2'){
            SetOutsideGuyReactions(sp);
        }
        foreach AllActors(class'#var(prefix)ScriptedPawn',sp,'mib_garage'){
            SetOutsideGuyReactions(sp);
        }

        ot = Spawn(class'OrdersTrigger',, 'TiffanyLeaving');
        ot.Orders = 'Leaving';
        ot.Event = '#var(prefix)TiffanySavage';
        ot.SetCollision(false, false, false);

        if (VanillaMaps){
            class'PlaceholderEnemy'.static.Create(self,vectm(635,488,-930));
            class'PlaceholderEnemy'.static.Create(self,vectm(1351,582,-930),,'Shitting');
            rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(1000,745,-972));//Gas Station back room
            rg.MaxCount=1;
            rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(-2375,-644,-993));//Under trailer near Jock
            rg.MaxCount=1;

            //Add teleporter hint text to Jock
            foreach AllActors(class'#var(prefix)MapExit',exit,'UN_BlackHeli'){break;}
            foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'Heli'){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit,, true);
            hoverHint.SetBaseActor(jock);


            Spawn(class'PlaceholderItem',,, vectm(-366,-2276,-1553)); //Under collapsed bridge
            Spawn(class'PlaceholderItem',,, vectm(-394,-1645,-1565)); //Near bridge pillar
            Spawn(class'PlaceholderItem',,, vectm(-88,-2087,-1553)); //Collapsed bridge road surface
            Spawn(class'PlaceholderItem',,, vectm(909,-2474,-1551)); //Wrecked car
            Spawn(class'PlaceholderItem',,, vectm(-3152,-2780,-1364)); //Ledge near original key
        } else {
            //Add teleporter hint text to Jock
            #ifdef revision
            foreach AllActors(class'#var(prefix)MapExit',exit,'exit'){break;}
            foreach AllActors(class'JockHelicopter',jockheli,'Heli'){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jockheli.Location, jockheli.CollisionRadius+5, jockheli.CollisionHeight+5, exit,, true);
            hoverHint.SetBaseActor(jockheli);
            #endif

            class'PlaceholderEnemy'.static.Create(self,vectm(886,1044,-930));

            Spawn(class'PlaceholderItem',,, vectm(-366,-2276,-1553)); //Under collapsed bridge
            Spawn(class'PlaceholderItem',,, vectm(-394,-1645,-1565)); //Near bridge pillar
            Spawn(class'PlaceholderItem',,, vectm(-88,-2087,-1553)); //Collapsed bridge road surface
            Spawn(class'PlaceholderItem',,, vectm(909,-2474,-1551)); //Wrecked car
            Spawn(class'PlaceholderItem',,, vectm(-2864,-2618,-1490)); //Ledge near original key
        }
        break;
    }
}

function VandenbergCmdFixTimsDoor()
{
    local #var(DeusExPrefix)Mover door;
    local #var(prefix)NanoKey key;

    if(!dxr.flags.IsZeroRando()) {
        //Add a key to Tim's closet
        foreach AllActors(class'#var(DeusExPrefix)Mover',door){
            if (door.Name=='DeusExMover28'){
                door.KeyIDNeeded='TimsClosetKey';
                door.Tag = 'TimsDoor';
                AddSwitch( vect(-1782.48,1597.85,-1969), rot(0, 0, 0), 'TimsDoor');
            }
        }

        key = Spawn(class'#var(prefix)NanoKey',,,vectm(-1502.665771,2130.560791,-1996.783691)); //Windowsill in Hazard Lab
        key.KeyID='TimsClosetKey';
        key.Description="Tim's Closet Key";
        key.SkinColor=SC_Level3;
        key.MultiSkins[0] = Texture'NanoKeyTex3';
    }
}

function VandenbergCmdRevisionFixWatchtowerDoor()
{
    local #var(DeusExPrefix)Mover door;
    local #var(prefix)NanoKey key;

    if(!dxr.flags.IsZeroRando()) {
        //Add a key to the watch tower
        foreach AllActors(class'#var(DeusExPrefix)Mover',door){
            if (door.Name=='DeusExMover42'){
                door.KeyIDNeeded='watchtowerkey';
                door.Tag = 'WatchTowerDoor';
            }
        }

        key = Spawn(class'#var(prefix)NanoKey',,,vectm(-2100,5325,-2150)); //Barracks bed
        key.KeyID='watchtowerkey';
        key.Description="Watch Tower Key";
        key.SkinColor=SC_Level3;
        key.MultiSkins[0] = Texture'NanoKeyTex3';
    }

}

function UnleashingBotsOpenCommsDoor()
{
    local DXRSimpleTrigger t;
    local #var(prefix)LogicTrigger logic;
    local #var(prefix)DataLinkTrigger dt;
    local #var(prefix)FlagTrigger ft;

    if(dxr.flags.IsZeroRandoPure()) return;

    // releasing the bots should be enough to get into the comms building, especially for Stick With the Prod players

    foreach AllActors(class'#var(prefix)DataLinkTrigger', dt) {
        if(dt.datalinkTag == 'DL_command_bots_destroyed') {
            dt.Tag = 'bots_released';
            break;
        }
    }

    logic = spawn(class'#var(prefix)LogicTrigger',, 'bunker_doors');
    logic.inGroup1 = 'bunker_door1';
    logic.inGroup2 = 'bunker_door2';
    logic.Op = GATE_AND;
    logic.Event = 'bots_released';
#ifdef hx
    logic.bOneShot = true;
#else
    logic.OneShot = true;
#endif

    t = spawn(class'DXRSimpleTrigger',, 'bunker_door1');
    t.Group = 'bunker_door1';
    t.Event = 'bunker_doors';
    t = spawn(class'DXRSimpleTrigger',, 'bunker_door2');
    t.Group = 'bunker_door2';
    t.Event = 'bunker_doors';

    ft = spawn(class'#var(prefix)FlagTrigger',, 'bots_released');
    ft.flagName = 'MS_DL_Played';
    ft.SetCollision(false,false,false);
}

//Add a new button in the elevator to open the doors
function FixCmdElevator()
{
    local #var(injectsprefix)Button1 doorButton;
    local #var(prefix)Button1 butt;
    local Dispatcher d;
    local Trigger t;
    local Vector loc;
    local Rotator rot;
    local Mover eleDoor;

    //Find the middle elevator button
    foreach AllActors(class'#var(prefix)Button1',butt){
        if (butt.Event=='delay_floor2'){
            break;
        }
    }

    rot = butt.Rotation;
    loc = butt.Location;
    loc.Z += 7; //Three buttons are 7 apart from each other on Y axis, so put this one equally above

    doorButton = Spawn(class'#var(injectsprefix)Button1',,,loc,rot);
    doorButton.moverTag = butt.moverTag;
    doorButton.RandoButtonType=RBT_OpenDoors;
    doorButton.ButtonType=BT_Blank;
    doorButton.Event='all_doors_button';
    doorButton.BeginPlay();

    //Doors are 'door1', 'door2', and 'door3'
    d = Spawn(class'Dispatcher',, 'all_doors_button' );
    d.OutEvents[0]='door1';
    d.OutDelays[0]=0;
    d.OutEvents[1]='door2';
    d.OutDelays[1]=0;
    d.OutEvents[2]='door3';
    d.OutDelays[2]=0;

    //Disable the proximity triggers on the doors
    foreach AllActors(class'Trigger',t){
        switch(t.Event){
            case 'door1':
            case 'door2':
            case 'door3':
                t.Event='';
                t.Destroy();
                break;
        }
    }

    foreach AllActors(class'Mover',eleDoor){
        switch(eleDoor.tag){
            case 'door1':
            case 'door2':
            case 'door3':
                eleDoor.MoverEncroachType=ME_IgnoreWhenEncroach;
                break;
        }
    }
}

function SetGarageGuyReactions(#var(prefix)ScriptedPawn sp)
{
    sp.RaiseAlarm=RAISEALARM_BeforeAttacking;
    sp.bReactAlarm=True; //The various reactions on the normal garage guard
    sp.bReactCarcass=False;
    sp.bReactDistress=True;
    sp.bReactFutz=False;
    sp.bReactLoudNoise=True;
    sp.bReactPresence=True;
    sp.bReactProjectiles=True;
    sp.bReactShot=True;
    sp.bHateCarcass=False;
    sp.bHateDistress=True;
    sp.bHateHacking=False;
    sp.bHateIndirectInjury=False;
    sp.bHateInjury=True;
    sp.bHateShot=True;
    sp.bHateWeapon=True;
    sp.MaxProvocations=1;
    sp.ResetReactions();
}

function SetOutsideGuyReactions(#var(prefix)ScriptedPawn sp)
{
    sp.RaiseAlarm=RAISEALARM_BeforeFleeing;
    sp.bReactAlarm=True;
    sp.bReactCarcass=False;
    sp.bReactDistress=False;
    sp.bReactFutz=False;
    sp.bReactLoudNoise=False;
    sp.bReactPresence=True;
    sp.bReactProjectiles=True;
    sp.bReactShot=False;
    sp.bHateCarcass=False;
    sp.bHateDistress=False;
    sp.bHateHacking=False;
    sp.bHateIndirectInjury=False;
    sp.bHateInjury=True;
    sp.bHateShot=True;
    sp.bHateWeapon=False;
    sp.MaxProvocations=1;
    sp.ResetReactions();
}

function PostFirstEntryMapFixes()
{
    local #var(prefix)CrateUnbreakableLarge c;
    local Actor a;
    local #var(prefix)ScriptedPawn sp;
    local #var(prefix)AlarmUnit alarm;
    local #var(DeusExPrefix)Mover door;
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    switch(dxr.localURL) {
    case "12_VANDENBERG_CMD":
        if(!RevisionMaps){
            foreach RadiusActors(class'#var(prefix)CrateUnbreakableLarge', c, 16, vectm(570.835083, 1934.114014, -1646.114746)) {
                info("removing " $ c $ " dist: " $ VSize(c.Location - vectm(570.835083, 1934.114014, -1646.114746)) );
                c.Destroy();
            }
        }
        break;
    case "14_OCEANLAB_LAB":
        // ensure rebreather before greasel lab, in case the storage closet key is in the flooded area
        a = AddActor(class'#var(prefix)Rebreather', vect(1569, 24, -1628));
        a.SetPhysics(PHYS_None);
        l("PostFirstEntryMapFixes spawned "$ActorToString(a));
        break;
    case "12_VANDENBERG_GAS":
        foreach AllActors(class'#var(prefix)ScriptedPawn',sp,'guard2'){
            SetGarageGuyReactions(sp);
        }
        foreach AllActors(class'#var(prefix)ScriptedPawn',sp,'mib_garage'){
            SetGarageGuyReactions(sp);
            sp.Tag = 'guard2'; //
        }
        alarm = None;
        foreach AllActors(class'#var(prefix)ScriptedPawn',sp,'guard2'){
            if (#var(prefix)Animal(sp)!=None && alarm==None) {
                //player().ClientMessage("Spawning doggy alarm for "$sp);
                if (RevisionMaps){
                    alarm=#var(prefix)AlarmUnit(Spawnm(class'#var(prefix)AlarmUnit',,, vect(1381.687988,2581.708008,-960),rot(0,-16408,0))); //Dog Height Alarm
                } else {
                    alarm=#var(prefix)AlarmUnit(Spawnm(class'#var(prefix)AlarmUnit',,, vect(-7.312059,933.707886,-985),rot(0,-16408,0))); //Dog Height Alarm
                }
                alarm.Event='guardattack';
                alarm.Tag='alarm1'; //Same as the original alarm

                //a dog can't open a door, so trigger it from the alarm panel
                foreach RadiusActors(class'#var(DeusExPrefix)Mover',door,100,alarm.Location){
                    if (door.KeyIDNeeded=='pipe'){
                        door.Tag='guardattack';
                        break;
                    }
                }
            }
            if (#var(prefix)MJ12Commando(sp)!=None) {
                sp.DrawScale = 1;
                sp.SetCollisionSize(sp.default.CollisionRadius, sp.default.CollisionHeight);
            }
        }
        // if speedrun mode, put a TNT crate for assured death
        if(dxr.flags.IsSpeedrunMode()) {
            AddDelayEvent('guardattack', 'TiffanyTNT', 15);
            Spawnm(class'#var(prefix)CrateExplosiveSmall',, 'TiffanyTNT', vect(145.933289, 695, -1007.897644));
        }
        break;
    }
}

function AnyEntryMapFixes()
{
    local #var(prefix)ScriptedPawn sp;
    local NanoKey key;
    local #var(prefix)HowardStrong hs;
    local bool prevMapsDone;
    local Conversation con;
    local ConEvent ce;
    local ConEventTrigger cet;

    if(dxr.flagbase.GetBool('schematic_downloaded') && !dxr.flagbase.GetBool('DL_downloaded_Played')) {
        dxr.flagbase.SetBool('DL_downloaded_Played', true);
    }

    switch(dxr.localURL)
    {
    case "12_Vandenberg_gas":
        foreach AllActors(class'#var(prefix)ScriptedPawn', sp) {
            //We switch the tag for mib_garage to guard2 for safety purposes
            if (sp.Tag== 'mib_garage' || sp.Tag=='guard2'){
                key = NanoKey(sp.FindInventoryType(class'NanoKey'));
                if(key == None) continue;
                l(sp$" has key "$key$", "$key.KeyID$", "$key.Description);
                if(key.KeyID != '') continue;
                l("fixing "$key$" to garage_entrance");
                key.KeyID = 'garage_entrance';
                key.Description = "Garage Door";
                key.Timer();// make sure to fix the ItemName in vanilla
            }
        }

        con = GetConversation('M12JockFinal2');
        for (ce = con.eventList; ce != None; ce = ce.nextEvent) {
            if (ConEventCheckFlag(ce) != None && ConEventCheckFlag(ce).setLabel == "Dead") {
                cet = new(con) class'ConEventTrigger';
                cet.eventType = ET_Trigger;
                cet.triggerTag = 'TiffanyLeaving';
                cet.nextEvent = ce.nextEvent;
                ce.nextEvent = cet;
                break;
            }
        }

        break;

    case "14_VANDENBERG_SUB":
        FixSavageSkillPointsDupe();

        GetConversation('JockArea51').AddFlagRef('dummy', True); // 'JockArea51' can never play
        DeleteConversationFlag(GetConversation('JockBarks'), 'DL_Dead_Played', false); // 'JockBarks' can always play

        break;

    case "14_OCEANLAB_SILO":
        foreach AllActors(class'#var(prefix)HowardStrong', hs) {
            hs.ChangeAlly('', 1, true);
            hs.ChangeAlly('mj12', 1, true);
            hs.ChangeAlly('spider', 1, true);
            RemoveFears(hs);
            hs.MinHealth = 0;
        }

        Player().StartDataLinkTransmission("DL_FrontGate");

        prevMapsDone = dxr.flagbase.GetBool('Heliosborn') && //Finished Vandenberg, mission 12
            dxr.flagbase.GetBool('schematic_downloaded'); //Finished Ocean Lab, mission 14,
        prevMapsDone = prevMapsDone || !#defined(injections) || dxr.flags.settings.goals<=0;
        if(prevMapsDone && !dxr.flagbase.GetBool('MS_HowardStrongUnhidden')) {
            foreach AllActors(class'#var(prefix)HowardStrong', hs) {
                hs.EnterWorld();
                break;
            }
            dxr.flagbase.SetBool('MS_HowardStrongUnhidden', True,, 15);
        }

        SetTimer(1, true);

        break;
    case "12_VANDENBERG_COMPUTER":
        SetTimer(1, true);
        break;
    case "12_VANDENBERG_CMD":
        Player().StartDataLinkTransmission("DL_no_carla");

        // timer to count the MJ12 Bots
        SetTimer(1, True);

        break;

    case "14_OCEANLAB_LAB":
        GetConversation('DL_Simons1').AddFlagRef('WaltonSimons_Dead', false);
        GetConversation('DL_Simons2').AddFlagRef('WaltonSimons_Dead', false);
        break;
    }
}

function FixSavageSkillPointsDupe()
{
    local Conversation c;
    local ConEventAddSkillPoints sk;
    local ConEvent e, prev, next;

    c = GetConversation('GaryWaitingForSchematics');
    if(c==None) return;
    for(e = c.eventList; e != None; e=next) {
        next = e.nextEvent;// keep this when we delete e
        sk = ConEventAddSkillPoints(e);
        if(sk != None) {
            FixConversationDeleteEvent(sk, prev);
        }
        else {
            prev = e;
        }
    }

    if(!dxr.flagbase.GetBool('M14GaryDone')) {
        M14GaryNotDone = true;
        SetTimer(1, true);
    }
}

function TimerMapFixes()
{
    local #var(prefix)GarySavage gary;

    switch(dxr.localURL)
    {
    case "14_VANDENBERG_SUB":
        if(M14GaryNotDone && dxr.flagbase.GetBool('M14GaryDone')) {
            M14GaryNotDone = false;
            player().SkillPointsAdd(500);
        }
        break;
    case "12_VANDENBERG_COMPUTER":
        //Immediately start the conversation with Gary after the message from Page
        if (!M12GaryHostageBriefing && dxr.flagbase.GetBool('PageHostageBriefing_played') && !dxr.flagbase.GetBool('GaryHostageBriefing_played')){
            if (player().conPlay==None){
                foreach AllActors(class'#var(prefix)GarySavage',gary){ break;}
                if (dxr.FlagBase.GetBool('LDDPJCIsFemale')){
                    M12GaryHostageBriefing = (player().StartConversationByName('FemJCGaryHostageBriefing',gary));
                } else {
                    M12GaryHostageBriefing = (player().StartConversationByName('GaryHostageBriefing',gary));
                }
            }
        }
        break;
    case "12_VANDENBERG_CMD":
        CountMJ12Bots();
        break;

    case "14_Oceanlab_silo":
        _SiloGoalChecks();
        break;
    }
}

function private _SiloGoalChecks() {
    local BlackHelicopter chopper;

    // by design, no infolink plays after killing Howard Strong if the missile hasn't been redirected
    if (dxr.flagbase.GetBool('DXR_SiloEscapeHelicopterUnhidden') || !dxr.flagbase.GetBool('missile_launched')) {
        return;
    }

    // but we do things differently if you redirect the missile while Howard is (un?)dead
    if (dxr.flagbase.GetBool('HowardStrong_Dead')) {
        // both goals completed
        if (dxr.flagbase.GetBool('DL_Savage3_Played')) {
            // both goals completed in order, computer infolink already played, play vanilla infolink
            player().StartDataLinkTransmission("DL_Dead");
        } else {
            // goals completed out of order
            _SiloRedirectedMissileWithHowardDead();
        }

        foreach AllActors(class'BlackHelicopter', chopper, 'BlackHelicopter') {
            chopper.EnterWorld();
            break;
        }
        dxr.flagbase.SetBool('DXR_SiloEscapeHelicopterUnhidden', True,, 15);
    } else {
        // only computer goal completed, play vanilla infolink
        player().StartDataLinkTransmission("DL_Savage3");
    }
}

function private _SiloRedirectedMissileWithHowardDead() {
    // both goals completed out of order, computer infolink not played
    local ConEventSpeech cesInitiated, cesMinutes;

    cesInitiated = GetSpeechEvent(GetConversation('DL_Savage3').eventList, "Launch sequence initiated");
    cesMinutes = GetSpeechEvent(cesInitiated, "You've got about 10 minutes");

    cesInitiated.nextEvent = cesMinutes;
    cesMinutes.nextEvent = GetConversation('DL_Dead').eventList;
    dxr.flagbase.SetBool('DL_Dead_Played', True);

    player().StartDataLinkTransmission("DL_Savage3");
}

function CountMJ12Bots()
{
    local int newCount;
    local #var(prefix)Robot bot;

    newCount = 0;

    foreach AllActors(class'#var(prefix)Robot',bot,'enemy_bot') {
        if (bot.EMPHitPoints>0){
            newCount++;
        }
    }

    if (newCount!=storedBotCount){
        // A bot has been destroyed or disabled!
        if (UpdateBotGoal(newCount)==True){
            storedBotCount = newCount; //only update the stored count if the goal updated
            if(newCount==0){
                SetTimer(0, False);  // Disable the timer now that all bots are destroyed
            }
        }
    }
}

function bool UpdateBotGoal(int count)
{
    local string goalText;
    local DeusExGoal goal;
    local int bracketPos;
    goal = player().FindGoal('DestroyBots');

    if (goal!=None){
        goalText = goal.text;
        bracketPos = InStr(goalText,"[");

        if (bracketPos>0){ //If the extra text is already there, strip it.
            goalText = Mid(goalText,0,bracketPos-1);
        }

        goalText = goalText$" ["$count$" remaining]";

        goal.SetText(goalText);

        return True;
    }
    return False;
}

