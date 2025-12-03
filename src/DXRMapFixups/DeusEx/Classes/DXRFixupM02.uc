class DXRFixupM02 extends DXRFixup;

//#region Pre First Entry
function PreFirstEntryMapFixes()
{
    local #var(prefix)BarrelAmbrosia ambrosia;
    local Trigger t;
    local NYPoliceBoat b;
    local #var(DeusExPrefix)Mover d;
    local #var(prefix)NanoKey k;
    local CrateExplosiveSmall c;
    local #var(prefix)Terrorist nsf;
    local #var(prefix)BoxSmall bs;
    local #var(prefix)Keypad2 kp;
    local #var(prefix)TAD tad;
    local #var(prefix)FishGenerator fg;
    local #var(prefix)PigeonGenerator pg;
    local #var(prefix)Trigger trig;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
    local #var(prefix)Jock actualJock;
    local #var(prefix)OrdersTrigger ot;
    local #var(prefix)SkillAwardTrigger sat;
    local #var(prefix)FordSchick ford;
    local #var(prefix)MJ12Troop troop;
    local #var(prefix)AllianceTrigger at;
    local #var(prefix)PickupDistributor pd;
    local DXRHoverHint hoverHint;
    local DXRButtonHoverHint buttonHint;
    local #var(prefix)Button1 button;
    local OnceOnlyTrigger oot;
    local bool RevisionMaps;
    local bool VanillaMaps;
    local #var(prefix)CrateUnbreakableSmall crateSmall;
    local #var(prefix)CrateUnbreakableMed crateMedium;
    local Vector loc;
    local Teleporter tel;
    local DynamicTeleporter dtel;
    local DynamicLight light;
    local DeusExDecoration s;
    local Smuggler smug;
    local HomeBase hb;
    local DXRReinforcementPoint reinforce;
    local #var(prefix)Poolball pb;
    local int i;
#ifdef revision
    local JockHelicopter jockheli;
#endif

#ifdef injections
    local #var(prefix)Newspaper np;
    local class<#var(prefix)Newspaper> npClass;
    local #var(prefix)Datacube dc;
    npClass = class'#var(prefix)Newspaper';
#else
    local DXRInformationDevices np;
    local class<DXRInformationDevices> npClass;
    local DXRInformationDevices dc;
    npClass = class'DXRInformationDevices';
#endif

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());
    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch (dxr.localURL)
    {
    //#region Battery Park
    case "02_NYC_BATTERYPARK":

        foreach AllActors(class'#var(DeusExPrefix)Mover', d) {
            if( d.Name == 'DeusExMover19' ) {
                d.Tag = 'ControlRoomDoor';
                if(class'MenuChoice_BalanceMaps'.static.MajorEnabled()) d.KeyIDNeeded = 'ControlRoomDoor'; // if we aren't spawning the key, don't make it show the "Key Unacquired" text
            }
        }

        if(class'MenuChoice_BalanceMaps'.static.MajorEnabled()) {
            k = Spawn(class'#var(prefix)NanoKey',,, vectm(1574.209839, -238.380142, 342));
            k.KeyID = 'ControlRoomDoor';
            k.Description = "Control Room Door Key";
            if(dxr.flags.settings.keysrando > 0)
                GlowUp(k);

            //Make the ambrosia worth more so that there's more incentive to actually do your job?
            foreach AllActors(class'#var(prefix)SkillAwardTrigger', sat, 'AmbrosiaTagged'){
                sat.skillPointsAdded=300; //Default is 150
            }
        }

        if(dxr.flags.settings.goals>0 || class'MenuChoice_BalanceMaps'.static.MajorEnabled()) {
            k = Spawn(class'#var(prefix)NanoKey',,, vectm(636.035339, -1050.083496, -135.789780));
            k.KeyID = 'KioskDoors';
            k.Description = "Kiosk door key";
            k.bIsSecretGoal = true;

            AddSwitch(vect(794.640015, -841.168518, -158.871399), rot(0, 32768, 0), 'ControlRoomDoor');
        }

        //Prevent TNT crates in subway from being shuffled (in case Goal Rando is disabled)
        foreach AllActors(class'CrateExplosiveSmall', c) {
            c.bIsSecretGoal = true;
        }

        PreventShufflingAmbrosia();

        if (VanillaMaps){
            foreach AllActors(class'#var(prefix)BarrelAmbrosia', ambrosia) {
                foreach RadiusActors(class'Trigger', t, 16, ambrosia.Location) {
                    if(t.CollisionRadius < 100)
                        t.SetCollisionSize(t.CollisionRadius*2, t.CollisionHeight*2);
                }
            }
            foreach AllActors(class'#var(prefix)Terrorist',nsf,'ShantyTerrorist'){
                nsf.Tag = 'ShantyTerrorists';  //Restores voice lines when NSF still alive (still hard to have happen though)
            }

            fg=Spawn(class'#var(prefix)FishGenerator',,, vectm(-1274,-3892,177));//Near Boat dock
            fg.ActiveArea=2000;
        } else {
            //Revision maps
            s = AddSwitch( vect(480,-809,-350), rot(0, -16384, 0), 'AmbrosiaGate');  //Switch to open the gate near the vanilla ambrosia location from inside
            d = #var(DeusExPrefix)Mover(findNearestToActor(class'#var(DeusExPrefix)Mover',s));
            d.Tag='AmbrosiaGate';

            //The Revision map doesn't have the boat MapExit
            //This will happen before DXREvents, which changes the tag on this MapExit
            exit = Spawn(class'DynamicMapExit',,'Boat_Exit',vect(-420,-3827,278));
            exit.SetCollision(false,false,false);
            exit.DestMap="03_NYC_UNATCOIsland";
        }

        foreach AllActors(class'#var(prefix)MapExit',exit,'Boat_Exit'){break;}
        foreach AllActors(class'NYPoliceBoat',b) {
            b.BindName = "NYPoliceBoat";
            b.ConBindEvents();
            class'DXRTeleporterHoverHint'.static.Create(self, "", b.Location, b.CollisionRadius+5, b.CollisionHeight+5, exit,, true);
        }

        break;
    //#endregion

    //#region Warehouse
    case "02_NYC_WAREHOUSE":
        //Warehouse is basically the same between Vanilla and Revision (Just some extra hallways and paths)
        if (VanillaMaps){
            // crates for climbing out of the sewer water
            foreach RadiusActors(class'#var(prefix)CrateUnbreakableSmall', crateSmall, 8.0, vectm(-1658.93, 664.61, -358.68)) {
                crateSmall.bIsSecretGoal = true;
                loc = crateSmall.Location - vectm(0, 123.0, 0);
                crateSmall.SetLocation(loc);
                break;
            }
            foreach RadiusActors(class'#var(prefix)CrateUnbreakableMed', crateMedium, 20.0, vectm(-1606.68, 640.60, -435.55)) {
                crateMedium.bIsSecretGoal = true;
                loc = crateMedium.Location - vectm(0, 123.0, 0);
                crateMedium.SetLocation(loc);
            }

            //Detach the trigger that opens the basement door when you get near it from inside
            //Add a button instead
            foreach AllActors(class'#var(prefix)Trigger',trig){
                if (trig.Event=='SecurityDoor'){
                    trig.Event='';
                    trig.Destroy();
                    break;
                }
            }
            AddSwitch( vect(915.534,-1046.767,-117.347), rot(0, 16368, 0), 'SecurityDoor');

            //Add teleporter hint text to Jock
            foreach AllActors(class'#var(prefix)MapExit',exit){break;}
            foreach AllActors(class'#var(prefix)BlackHelicopter',jock){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit,, true);
            hoverHint.SetBaseActor(jock);

            //add a small light to the lower floor of the apartment.
            //This helps to just put a little bit of light on the generator location
            //in the case of 0 brightness boost
            light = Spawn(class'DynamicLight',,, vectm(500,900,1050));
            light.LightType=LT_Steady;
            light.LightBrightness=16;
            light.LightRadius=10;

            //add a small spotlight from the lamp in the alley.
            //This helps to just put a little bit of light on the generator location
            //in the case of 0 brightness boost
            light = DynamicLight(Spawnm(class'DynamicLight',,, vect(-645,1760,310),rot(-10000,-16384,0)));
            light.LightType=LT_Steady;
            light.LightEffect=LE_Spotlight;
            light.LightBrightness=32;
            light.LightRadius=64;

            // fix collision with the fence https://github.com/Die4Ever/deus-ex-randomizer/issues/665
            foreach AllActors(class'#var(DeusExPrefix)Mover', d) {
                if(d.Event == 'BlewFence') break;
            }
            class'FillCollisionHole'.static.CreateLine(self, vectm(-2184, 1266.793335, 79.291428), vectm(-2050, 1266.793335, 79.291428), 10, 80, d);
        } else {
            //Revision

            //Add teleporter hint text to Jock
            #ifdef revision
            foreach AllActors(class'#var(prefix)MapExit',exit){break;}
            foreach AllActors(class'JockHelicopter',jockheli){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jockheli.Location, jockheli.CollisionRadius+5, jockheli.CollisionHeight+5, exit,, true);
            hoverHint.SetBaseActor(jockheli);
            #endif

        }

        //Both vanilla and Revision:

        //Remove the small boxes in the sewers near the ladder so that bigger boxes don't shuffle into those spots
        foreach AllActors(class'#var(DeusExPrefix)Mover',d,'DrainGrate'){break;}
        foreach d.RadiusActors(class'#var(prefix)BoxSmall',bs,800){bs.Destroy();}

        //A switch in the sewer swimming path to allow backtracking
        AddSwitch( vect(-1518.989136,278.541260,-439.973816), rot(0, 2768, 0), 'DrainGrate');

        //A keypad in the sewer walking path to allow backtracking
        kp = #var(prefix)Keypad2(Spawnm(class'#var(prefix)Keypad2',,,vect(-622.685,497.4295,-60.437), rot(0,-49192,0)));
        kp.validCode="2577";
        kp.bToggleLock=False;
        kp.Event='DoorToWarehouse';

        npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(1700.929810,-519.988037,57.729870),rotm(0,0,0,0),'02_Newspaper06'); //Joe Greene article, table in room next to break room (near bathrooms)
        npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(-1727.644775,2479.614990,1745.724976),rotm(0,0,0,0),'02_Newspaper06'); //Next to apartment(?) door on rooftops, near elevator

        foreach AllActors(class'#var(prefix)MapExit',exit,'ToStreet'){break;}
        foreach AllActors(class'#var(prefix)Button1',button){
            if (button.Event=='ToStreet'){
                break;
            }
        }
        buttonHint = DXRButtonHoverHint(class'DXRButtonHoverHint'.static.Create(self, "", button.Location, button.CollisionRadius+5, button.CollisionHeight+5, exit));
        buttonHint.SetBaseActor(button);

        foreach RadiusActors(class'#var(DeusExPrefix)Mover', d,10,vectm(1552,-1136,384)){break;}
        class'FakeMirrorInfo'.static.Create(self,vectm(1553,-1130,380),vectm(1645,-1135,260),d); //Mirror door in computer room.  This doesn't actually rotate with the door yet...

        class'PlaceholderEnemy'.static.Create(self,vectm(782,-1452,48));
        class'PlaceholderEnemy'.static.Create(self,vectm(1508,-1373,256));
        class'PlaceholderEnemy'.static.Create(self,vectm(1814,-1842,48));
        class'PlaceholderEnemy'.static.Create(self,vectm(-31,-1485,48));
        class'PlaceholderEnemy'.static.Create(self,vectm(1121,-1095,-144));
        class'PlaceholderEnemy'.static.Create(self,vectm(467,-214,-144));
        class'PlaceholderEnemy'.static.Create(self,vectm(-1570,493,1183)); //rooftop
        class'PlaceholderEnemy'.static.Create(self,vectm(681,1359,1424)); //rooftop window
        class'PlaceholderEnemy'.static.Create(self,vectm(-1820,1248,1616)); //rooftop tower
        class'PlaceholderEnemy'.static.Create(self,vectm(-635,1983,1768)); //rooftop chimneys
        class'PlaceholderEnemy'.static.Create(self,vectm(-1847,1940,1800)); //rooftop building near elevator
        class'PlaceholderEnemy'.static.Create(self,vectm(-972,765,1184)); //rooftop
        class'PlaceholderEnemy'.static.Create(self,vectm(110,530,784)); //lower rooftop
        class'PlaceholderEnemy'.static.Create(self,vectm(423,565,624)); //even lower rooftop
        class'PlaceholderEnemy'.static.Create(self,vectm(875,712,464)); //lowest rooftop
        class'PlaceholderEnemy'.static.Create(self,vectm(-5,1415,1192)); //apartment
        class'PlaceholderEnemy'.static.Create(self,vectm(-2080,812,48)); //alley
        class'PlaceholderEnemy'.static.Create(self,vectm(13,-718,-96)); //Warehouse sewer entrance
        class'PlaceholderEnemy'.static.Create(self,vectm(-1555,2756,1584)); //Rooftops near elevator
        class'PlaceholderEnemy'.static.Create(self,vectm(-1717,2177,2008)); //roof of rooftop building near elevator
        class'PlaceholderEnemy'.static.Create(self,vectm(843,75,480)); //Warehouse garage roof
        class'PlaceholderEnemy'.static.Create(self,vectm(1649,-1393,64),,'Shitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(1676,-1535,64),,'Shitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(1334,-1404,64),,'Shitting');

        if(class'MenuChoice_BalanceMaps'.static.MajorEnabled()) {
            // this map is too hard
            SpawnItemInContainer(self,class'#var(prefix)AdaptiveArmor',vectm(-1890,1840,1775)); //Rooftop apartment hall
            SpawnItemInContainer(self,class'#var(prefix)AdaptiveArmor',vectm(700,850,1175)); //Apartment top floor
            SpawnItemInContainer(self,class'#var(prefix)BallisticArmor',vectm(-1220,1770,15)); //Next to electrical box
            SpawnItemInContainer(self,class'#var(prefix)BallisticArmor',vectm(-2150,595,-240)); //Pipe next to sewer ladder
            SpawnItemInContainer(self,class'#var(prefix)FireExtinguisher',vectm(-2190,2230,315)); //Fire Escape near ground entrance
            SpawnItemInContainer(self,class'#var(prefix)FireExtinguisher',vectm(-650,1030,15)); //Final ground hall to warehouse (without grenades)
        }

        break;
    //#endregion

    //#region Hotel
    case "02_NYC_HOTEL":
        if (class'MenuChoice_BalanceMaps'.static.ModerateEnabled()){
            //Make sure the alliance triggers have unique tags
            foreach AllActors(class'#var(prefix)AllianceTrigger',at){
                if (at.Event=='SecondFloorTerrorist'){
                    at.Tag='SecondFloorHostageAlliance';
                    at.SetCollision(False,False,False);
                }
                if (at.Event=='GilbertTerrorist'){
                    at.Tag='GilbertHostageAlliance';
                    at.SetCollision(False,False,False);
                    at.Alliance='NSF';
                    for(i=0;i<ArrayCount(at.Alliances);i++){
                        if (at.Alliances[i].allianceName=='Hostages'){
                            at.Alliances[i].allianceLevel=-1; //These triggers normally only set the alliance to 0...
                            break;
                        }
                    }
                }
            }

            //The terrorists on the upper floor will now go hostile to the hostages
            //if either of them emits distress or hears weaponfire, or if the player makes a loud noise, creates a carcass, or fires a weapon
            //Triggers need to be above the terrorists so that the WeaponFire event from the prod isn't caught
            foreach AllActors(class'#var(prefix)Terrorist', nsf, 'SecondFloorTerrorist'){
                class'ListenAIEventTrigger'.static.Create(self,nsf.Location+vect(0,0,100),'SecondFloorHostageAlliance',true,false,'SecondFloorTerrorist',,,,true,,,,true,); //WeaponFire, Distress
                class'ListenAIEventTrigger'.static.Create(self,nsf.Location+vect(0,0,100),'SecondFloorHostageAlliance',false,true,'',,,,true,true,true,,,); //WeaponFire, Carcass, and LoudNoise
            }

            //The terrorist watching Gilbert will now go hostile
            //if he emits distress or hears weaponfire, or if the player makes a loud noise, creates a carcass, or fires a weapon
            //Triggers need to be above the terrorists so that the WeaponFire event from the prod isn't caught
            //Also keep him from being named "Terrorist"
            foreach AllActors(class'#var(prefix)Terrorist', nsf, 'GilbertTerrorist'){
                class'ListenAIEventTrigger'.static.Create(self,nsf.Location+vect(0,0,100),'GilbertHostageAlliance',true,false,'GilbertTerrorist',,,,true,,,,true,); //WeaponFire, Distress
                class'ListenAIEventTrigger'.static.Create(self,nsf.Location+vect(0,0,100),'GilbertHostageAlliance',false,true,'',,,,true,true,true,,,); //WeaponFire, Carcass, and LoudNoise
                if (class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) {
                    class'DXRNames'.static.GiveRandomName(dxr, nsf, true);
                }
            }

            //The terrorist guarding Gilbert will no longer be ordered to attack the player
            //There is already an AllianceTrigger ready to swap his alliances, and he is always
            //facing the right way anyway.  Just delete the OrdersTrigger
            foreach AllActors(class'#var(prefix)OrdersTrigger',ot){
                if (ot.Event!='GilbertTerrorist' && ot.Orders!='Attacking') continue;
                ot.Destroy();
                break;
            }
        }


        if (VanillaMaps){
            if(class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) {
                Spawn(class'#var(prefix)Binoculars',,, vectm(-610.374573,-3221.998779,94.160065)); //Paul's bedside table
            }

            //Restore answering machine message, but in mission 2 (conversation is in mission 3);
            //tad=Spawn(class'#var(prefix)TAD',,, vectm(-290,-2380,115),rotm(0,0,0));
            //tad.BindName="AnsweringMachine";
            //CreateAnsweringMachineConversation(tad);
            //tad.ConBindEvents();

            foreach RadiusActors(class'#var(DeusExPrefix)Mover', d, 1.0, vectm(-304.0, -3000.0, 64.0)) {
                // interpolate Paul's bathroom door to its starting position so it doesn't close instantaneously when frobbed
                d.InterpolateTo(1, 0.0);
                break;
            }

            Spawn(class'PlaceholderItem',,, vectm(-732,-2628,75)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(-732,-2712,75)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(-129,-3038,127)); //Bathroom counter
            Spawn(class'PlaceholderItem',,, vectm(15,-2972,123)); //Kitchen counter
            Spawn(class'PlaceholderItem',,, vectm(-853,-3148,75)); //Crack next to Paul's bed

            SetAllLampsState(false, true, true); // the lamp in Paul's apartment
        } else {
            if(class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) {
                Spawn(class'#var(prefix)Binoculars',,, vectm(-90,-3958,95)); //Paul's bedside table
            }

            Spawn(class'PlaceholderItem',,, vectm(-180,-3365,70)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(-180,-3450,70)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(480,-3775,125)); //Bathroom counter
            Spawn(class'PlaceholderItem',,, vectm(550,-3700,120)); //Kitchen counter
            Spawn(class'PlaceholderItem',,, vectm(-310,-3900,75)); //Crack next to Paul's bed
        }
        break;
    //#endregion

    //#region Street
    case "02_NYC_STREET":
        if (RevisionMaps){
            foreach AllActors(class'CrateExplosiveSmall', c) {
                l("hiding " $ c @ c.Tag @ c.Event);
                c.bHidden = true;// hide it so DXRSwapItems doesn't move it, this is supposed to be inside the plane that flies overhead
            }

            //Another store room with the same key as AugStore in the RevisionMaps
            foreach AllActors(class'#var(DeusExPrefix)Mover', d, 'SwankyStore') {
                d.bFrobbable = true;
            }
        }
        foreach AllActors(class'#var(DeusExPrefix)Mover', d, 'AugStore') {
            d.bFrobbable = true;
        }

        pg=Spawn(class'#var(prefix)PigeonGenerator',,, vectm(2404,-1318,-487));//Near Smuggler
        pg.MaxCount=3;

        foreach AllActors(class'#var(prefix)MapExit',exit,'ToWarehouse'){break;}
        foreach AllActors(class'#var(prefix)Button1',button){
            if (button.Event=='ToWarehouse'){
                break;
            }
        }
        buttonHint = DXRButtonHoverHint(class'DXRButtonHoverHint'.static.Create(self, "", button.Location, button.CollisionRadius+5, button.CollisionHeight+5, exit));
        buttonHint.SetBaseActor(button);

        SetAllLampsState(false, true, true); // the lamp in Paul's apartment, seen through the window
        if (#defined(vanilla)) {
            class'MoverToggleTrigger'.static.CreateMTT(self, 'DXRSmugglerElevatorUsed', 'elevatorbutton', 0, 1, 0.0, 3);
            foreach AllActors(class'Teleporter', tel) {
                if (tel.URL == "02_NYC_Smug#ToSmugFrontDoor") {
                    dtel = class'DynamicTeleporter'.static.ReplaceTeleporter(tel);
                    dtel.SetDestination("02_NYC_Smug", 'PathNode83',, 16384);
                    class'DXREntranceRando'.static.AdjustTeleporterStatic(dxr, dtel);
                    break;
                }
            }
        }

        break;
    //#endregion

    //#region Bar
    case "02_NYC_BAR":
        class'PoolTableManager'.static.CreatePoolTableManagers(self);
        if (RevisionMaps){
            AddActor(class'PoolTableResetButton',vect(-1970,-565.3,145),rot(0,16384,0));
        } else {
            AddActor(class'PoolTableResetButton',vect(-1700,-389.3,50),rot(0,16384,0));
        }

        if (class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)){
            Spawnm(class'BarDancer',,,vect(-1475,-580,48),rot(0,25000,0));
        } else {
            Spawnm(class'BarDancerBoring',,,vect(-1475,-580,48),rot(0,25000,0));
        }

        foreach AllActors(class'#var(prefix)Jock', actualJock) {
            actualJock.BarkBindName = "Jock";
            break;
        }
        break;
    //#endregion

    //#region Underground (Sewers)
    case "02_NYC_UNDERGROUND":
#ifdef injections
        foreach AllActors(class'#var(prefix)Datacube',dc){
#else
        foreach AllActors(class'DXRInformationDevices',dc){
#endif
            if (dc.texttag=='02_Datacube03'){ //Move datacube from underwater...
                dc.SetLocation(vectm(2026.021118,-572.896851,-506.561584)); //On top of keypad lockbox
                break;
            }
        }

        if(class'MenuChoice_BalanceMaps'.static.MinorEnabled()) {
            //Ford Schick has no alliance set
            foreach AllActors(class'#var(prefix)FordSchick',ford){
                ford.SetAlliance('FordSchick');
            }

            //The troops (for the most part) start hostile to Ford - keep them friendly to him initially
            foreach AllActors(class'#var(prefix)MJ12Troop',troop){
                ChangeInitialAlliance(troop,'FordSchick',1,false);
                troop.ChangeAlly('FordSchick',1,false);
            }

            //AllianceTriggers to make MJ12 Troops hostile to Ford when he escapes
            //These go off when you tell him to make a break for it
            MakeFordHateTrigger('MJ12Troop');
            MakeFordHateTrigger('FordsGuard');
            MakeFordHateTrigger('AlarmTroop');
        }

        if (RevisionMaps){
            //Delete the extra cue ball on the ping-pong table
            foreach AllActors(class'#var(prefix)Poolball',pb){
                if (pb.Name=='Poolball16'){
                    pb.Destroy();
                }
            }
            class'PoolTableManager'.static.CreatePoolTableManagers(self); //There's a pool table here in Revision (and it's nicely racked)
            AddActor(class'PoolTableResetButton',vect(-4925,1136.772827,-973),rot(0,16384,0));
        }

        Spawn(class'PlaceholderItem',,, vectm(2644,-630,-405)); //Weird little ledge near pipe and bodies
        Spawn(class'PlaceholderItem',,, vectm(2678.5,-340.3,-413)); //On pipe near bodies
        Spawn(class'PlaceholderItem',,, vectm(-1534,119,-821)); //Path to Schick, 1
        Spawn(class'PlaceholderItem',,, vectm(-2192,122,-821)); //Path to Schick, 2
        Spawn(class'PlaceholderItem',,, vectm(-3399,1471,-948)); //Schick Lab shelf
        Spawn(class'PlaceholderItem',,, vectm(-3593,1620,-961)); //Schick Fume Hood
        Spawn(class'PlaceholderItem',,, vectm(-4264,982,-981)); //Barracks bed
        Spawn(class'PlaceholderItem',,, vectm(-173,850,-322)); //Guard Room Table

        class'PlaceholderEnemy'.static.Create(self,vectm(-4219,1236,-976),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(-4059,976,-976),,'Sitting');

        break;
    //#endregion

    //#region Smuggler
    case "02_NYC_SMUG":
        foreach AllActors(class'#var(DeusExPrefix)Mover', d,'botordertrigger') {
            d.tag = 'botordertriggerDoor';
        }

        oot = Spawn(class'OnceOnlyTrigger');
        oot.Event='botordertriggerDoor';
        oot.Tag='botordertrigger';

        if (class'MenuChoice_BalanceMaps'.static.ModerateEnabled()){
            //The bot will no longer directly be ordered to attack the player
            //This prevents him from breaking stealth
            //There is already an AllianceTrigger and he will move to where his home base is outside the door
            foreach AllActors(class'#var(prefix)OrdersTrigger',ot,'InitiateOrder'){
                ot.Destroy();

                ot = #var(prefix)OrdersTrigger(Spawnm(class'#var(prefix)OrdersTrigger',,'InitiateOrder'));
                ot.Event='smugglerbots';
                ot.SetCollision(false,false,false);
                ot.Orders='GoingTo';
                ot.ordersTag='SmugBotDest';

                break;
            }

            reinforce=Spawn(class'DXRReinforcementPoint',,'SmugBotDest',vectm(0,-400,-10));
            reinforce.SetCollisionSize(16,32);
            reinforce.SetAsHomeBase(false);
        }

        foreach AllActors(class'Smuggler', smug) {
            smug.bImportant = true;
            break;
        }

        SetAllLampsState(false, true, true); // smuggler has one table lamp, upstairs where no one is
        if (#defined(vanilla)) {
            class'MoverToggleTrigger'.static.CreateMTT(self, 'DXRSmugglerElevatorUsed', 'elevatorbutton', 1, 0, 0.0, 3);
        }

        //Verified in both vanilla and Revision
        foreach AllActors(class'#var(DeusExPrefix)Mover', d,'mirrordoor'){break;}
        class'FakeMirrorInfo'.static.Create(self,vectm(-527,1660,348),vectm(-627,1655,220),d); //Mirror in front of Smuggler's Stash

        break;
    //#endregion

    //#region Free Clinic
    case "02_NYC_FREECLINIC":
        SetAllLampsState(true, true, false); // the free clinic has one desk lamp, at a desk no one is using

        // the free clinic shares a KeyID with the MJ12 facility beneath unatco
        foreach AllActors(class'#var(prefix)NanoKey', k) {
            if (k.KeyID == 'Cabinet' || k.KeyID == 'fccabinet') {
                k.KeyID = 'MedCabDoor';
            }
        }
        foreach AllActors(class'#var(DeusExPrefix)Mover', d, 'MedCabDoor') {
            d.KeyIDNeeded = 'MedCabDoor';
        }

        //Just to be safe - I don't think we ever get through here before the pickup
        //distributors do their thing, but it doesn't hurt to try
        foreach AllActors(class'#var(prefix)PickupDistributor',pd) {
            for (i=0;i<ArrayCount(pd.NanoKeyData);i++)
            {
                if (pd.NanoKeyData[i].KeyID=='Cabinet' || pd.NanoKeyData[i].KeyID=='fccabinet'){
                    pd.NanoKeyData[i].KeyID='MedCabDoor';
                }
            }
        }

        break;
    //#endregion
    }
}
//#endregion

function CreateAnsweringMachineConversation(Actor tad)
{
    local Conversation con;
    local ConEvent ce;
    local ConEventSpeech ces;
    local ConItem conItem;
    local ConversationList list;

    con = new(level) class'Conversation';
    con.conName='AnsweringMachineMessage';
    con.CreatedBy="AnsweringMachineMessage";
    con.conOwnerName="AnsweringMachine";
    con.bGenerateAudioNames=false;
    con.bInvokeFrob=true;
    con.bFirstPerson=true;
    con.bNonInteractive=true;
    con.audioPackageName="Mission03";

    ces = new(con) class'ConEventSpeech';
    con.eventList = ces;
    ces.eventType=ET_Speech;
    ces.conversation=con;
    ces.speaker=tad;
    ces.speakerName="";
    ces.speakingTo=tad;
    ces.speechFont=SF_Normal;
    ces.conSpeech = new(con) class'ConSpeech';
    ces.conSpeech.speech="Paul, I know you said no phone messages, but South Street's going up in smoke.  We'll have to meet at the subway station.";
    ces.conSpeech.soundID=69; //Yes, really

    player().ClientMessage("Speech audio: "$con.GetSpeechAudio(69));

    ce = new(con) class'ConEventEnd';
    ce.eventType=ET_End;
    ces.nextEvent=ce;
    ce.conversation=con;

    conItem = new(Level) class'ConItem';
    conItem.conObject = con;

    foreach AllObjects(class'ConversationList', list) {
        if( list.conversations != None ) {
            conItem.next = list.conversations;
            list.conversations = conItem;
            break;
        }
    }

}

function MakeFordHateTrigger(name pawnEvent)
{
    local #var(prefix)AllianceTrigger at;

    at = Spawn(class'#var(prefix)AllianceTrigger');
    at.Tag='FordExit';
    at.Event=pawnEvent;
    at.SetCollision(False,False,False);
    at.Alliance='MJ12';
    at.Alliances[0].AllianceLevel=-1;
    at.Alliances[0].AllianceName='FordSchick';
    at.Alliances[0].bPermanent=True;
}

//#region Post First Entry
function PostFirstEntryMapFixes()
{
    local bool RevisionMaps;
    local Female2 female;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    switch(dxr.localURL) {
    case "02_NYC_WAREHOUSE":
        if(!RevisionMaps) {
            AddBox(class'#var(prefix)CrateUnbreakableSmall', vectm(183.993530, 926.125000, 1162.103271));// apartment
            AddBox(class'#var(prefix)CrateUnbreakableMed', vectm(-389.361969, 744.039978, 1088.083618));// ladder
            AddBox(class'#var(prefix)CrateUnbreakableSmall', vectm(-328.287048, 767.875000, 1072.113770));
        }

        break;
    case "02_NYC_BAR":
        foreach AllActors(class'Female2', female, 'Female2') {
            if (female.bindName == "BarWoman1") {
                female.FamiliarName = "Meg";
                break;
            }
        }
        break;
    }
}
//#endregion

//#region Any Entry
function AnyEntryMapFixes()
{
    local ConEventSpeech ces;
    local Jock j;

    switch (dxr.localURL) {
    case "02_NYC_STREET":
        ces = GetSpeechEvent(GetConversation('SmugglerDoorBellConvo').eventList, "... too sick");
        if (ces != None)
            ces.conSpeech.speech = "... too sick.  Come back later."; // add a missing period after "sick"
        break;

    case "02_NYC_BAR":
        if (dxr.flagbase.getBool('GeneratorBlown')) {
            foreach AllActors(class'Jock', j) {
                j.LeaveWorld();
                break;
            }
        }
        break;

    case "02_NYC_SMUG":
        if (dxr.flagbase.getBool('SmugglerDoorDone')) {
            dxr.flagbase.setBool('MetSmuggler', true,, -1);
        }
        break;
    }
}
//#endregion
