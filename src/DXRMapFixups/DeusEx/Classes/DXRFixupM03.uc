class DXRFixupM03 extends DXRFixup;

function CheckConfig()
{
    local int i;

    add_datacubes[i].map = "03_NYC_UNATCOHQ";
    add_datacubes[i].text = "Note to self:|nUsername: JCD|nPassword: bionicman ";
    add_datacubes[i].Location = vect(-210,1290,290); //JC's Desk
    add_datacubes[i].plaintextTag = "JCCompPassword";
    i++;

    Super.CheckConfig();
}

//#region Post First Entry
function PostFirstEntryMapFixes()
{
    local Actor a;
    local bool RevisionMaps;
    local #var(prefix)NanoKey key;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    switch(dxr.localURL) {
    case "03_NYC_UNATCOHQ":
        FixUNATCORetinalScanner();
        PreventUNATCOZombieDanger();
        break;
    case "03_NYC_BatteryPark":
        player().StartDataLinkTransmission("dl_batterypark");
        break;
    case "03_NYC_BrooklynBridgeStation":
        if (!RevisionMaps){
            a = AddActor(class'Barrel1', vect(-27.953907, -3493.229980, 45.101418));
            Barrel1(a).SkinColor = SC_Explosive;
            a.BeginPlay();
        }
        break;

    case "03_NYC_AirfieldHeliBase":
        if (!RevisionMaps){
            //crates to get back over the beginning of the level
            AddActor(class'#var(prefix)CrateUnbreakableSmall', vect(-9463.387695, 3377.530029, 60));
            AddActor(class'#var(prefix)CrateUnbreakableMed', vect(-9461.959961, 3320.718750, 75));
        }
        SetAllLampsState(true, true, false); // this map has one desk lamp, in an office no one is in
        break;

    case "03_NYC_AIRFIELD":
        foreach AllActors(class'#var(prefix)NanoKey', key) {
            if(key.KeyID == 'securitytower' && key.Owner == None) {
                key.Destroy();
            }
        }
        break;
    }
}
//#endregion

//#region Timer
function TimerMapFixes()
{
    switch(dxr.localURL)
    {
    case "03_NYC_747":
        FixAnnaAmbush();
        break;
    }
}
//#endregion

//#region Pre First Entry
function PreFirstEntryMapFixes()
{
    local Mover m;
    local Actor a;
    local Trigger t;
    local Teleporter tele;
    local DynamicTeleporter dt;
    local #var(prefix)NanoKey k;
    local #var(prefix)InformationDevices i;
    local #var(prefix)UNATCOTroop unatco;
    local #var(prefix)WeaponModRecoil wmr;
    local #var(prefix)Terrorist terror;
    local #var(prefix)FishGenerator fg;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
    local DXRHoverHint hoverHint;
    local #var(prefix)HumanCivilian hc;
    local #var(prefix)OrdersTrigger ot;
    local #var(prefix)AllianceTrigger at;
    local #var(prefix)WeaponShuriken tk;
    local #var(prefix)JuanLebedev juan;
    local #var(prefix)ScriptedPawn sp;
    local AlarmUnit au;
    local vector loc;
    local #var(prefix)ComputerPublic compublic;
    local #var(DeusExPrefix)Mover dxm;
    local DXRSimpleTrigger st;
    local bool VanillaMaps;
    local #var(PlayerPawn) p;

    p = player();
    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(p);

    switch (dxr.localURL)
    {
    //#region Battery Park
    case "03_NYC_BATTERYPARK":
        FixHarleyFilben();

        foreach AllActors(class'#var(prefix)NanoKey', k) {
            // unnamed key normally unreachable
            if( k.KeyID == '' || k.KeyID == 'KioskDoors' ) {
                k.Destroy();
            }
        }

        if(VanillaMaps) {
            //Revision already has a switch to call the phonebooth down
            AddSwitch(vect(-4621.640137, 2902.651123, -650.285461), rot(0,0,0), 'ElevatorPhone');
        }

        fg=Spawn(class'#var(prefix)FishGenerator',,, vectm(-1274,-3892,177));//Near Boat dock
        fg.ActiveArea=2000;

        if(dxr.flags.IsEntranceRando()) {
            //rebreather because of #TOOCEAN connection
            SpawnItemInContainer(self,class'#var(prefix)Rebreather',vectm(-485,-3525,265)); //Dock near picnic table
        }

        GoalCompletedSilent(p, 'SeeCarter');

        //Add some junk around the park so that there are some item locations outside of the shanty town
        AddActor(class'Liquor40oz', vect(933.56,-3554.86,279.04));
        AddActor(class'Sodacan', vect(2203.28,-3558.84,279.04));
        AddActor(class'Liquor40oz', vect(-980.83,-3368.42,286.24));
        AddActor(class'Cigarettes', vect(-682.67,-3771.20,282.24));
        AddActor(class'Liquor40oz', vect(-2165.67,-3546.039,285.30));
        AddActor(class'Sodacan', vect(-2170.83,-3094.94,330.24));
        AddActor(class'Liquor40oz', vect(-3180.75,-3546.79,281.43));
        AddActor(class'Liquor40oz', vect(-2619.56,-2540.80,330.25));
        AddActor(class'Cigarettes', vect(-3289.43,-919.07,360.80));
        AddActor(class'Liquor40oz', vect(-2799.94,-922.68,361.86));
        AddActor(class'Sodacan', vect(800.76,1247.99,330.25));
        AddActor(class'Liquor40oz', vect(1352.29,2432.98,361.58));
        AddActor(class'Cigarettes', vect(788.50,2359.26,360.63));
        AddActor(class'Liquor40oz', vect(3153.26,-310.73,326.25));
        AddActor(class'Sodacan', vect(-2132.21,1838.89,326.25));

        break;
    //#endregion

    //#region Airfield Heli Base
    case "03_NYC_AirfieldHeliBase":
        // call the elevator at the end of the level when you open the appropriate door
        // Revision uses an ElevatorTrigger with more logic, maybe we can look at it later if needed
        if (VanillaMaps){
            //Bottom button hits Event BasementDoorOpen, which then should trigger Event BasementFloor
            st = spawn(class'DXRSimpleTrigger',, 'BasementDoorOpen');
            st.bTriggerOnceOnly=false;
            st.Event = 'BasementFloor';

            //Top button hits Event GroundDoorOpen, which then should trigger Event GroundLevel
            st = spawn(class'DXRSimpleTrigger',, 'GroundDoorOpen');
            st.bTriggerOnceOnly=false;
            st.Event = 'GroundLevel';
        }

        foreach AllActors(class'Mover',m) {
            // sewer door backtracking so we can make a switch for this
            if ( DeusExMover(m) != None && DeusExMover(m).KeyIDNeeded == 'Sewerdoor')
            {
                m.Tag = 'Sewerdoor';
            }
        }

        if(class'MenuChoice_BalanceMaps'.static.MajorEnabled() &&
           class'DXRBacktracking'.static.bSillyChoppers()) {
            //Only stop the platforms from falling if you're in a game mode that requires backtracking
            foreach AllActors(class'Trigger', t) {
                //disable the platforms that fall when you step on them
                if( t.Event == 'firstplatform' || t.Event == 'platform2' ) {
                    t.Event = '';
                }
            }
        }
        foreach AllActors(class'#var(prefix)UNATCOTroop', unatco) {
            unatco.bHateCarcass = false;
            unatco.bHateDistress = false;
        }

        // Sewerdoor backtracking
        AddSwitch( vect(-6878.640137, 3623.358398, 150.903931), rot(0,0,0), 'Sewerdoor');

        //stepping stone valves out of the water, I could make the collision radius a little wider even if it isn't realistic?
        AddActor(class'Valve', vect(-3105,-385,-210), rot(0,0,16384));
        a = AddActor(class'DynamicBlockPlayer', vect(-3105,-385,-210));
        SetActorScale(a, 1.3);

        AddActor(class'Valve', vect(-3080,-395,-170), rot(0,0,16384));
        a = AddActor(class'DynamicBlockPlayer', vect(-3080,-395,-170));
        SetActorScale(a, 1.3);

        AddActor(class'Valve', vect(-3065,-405,-130), rot(0,0,16384));
        a = AddActor(class'DynamicBlockPlayer', vect(-3065,-405,-130));
        SetActorScale(a, 1.3);

        if(dxr.flags.IsEntranceRando()) {
            //rebreather because of #TOOCEAN connection
            SpawnItemInContainer(self,class'#var(prefix)Rebreather',vectm(1020,1015,215)); //Near pool tables
        }

        //Button to extend sewer platform from the other side
        AddSwitch( vect(-5233.946289,3601.383545,161.851822), rot(0, 16384, 0), 'MoveableBridge');

        class'PlaceholderEnemy'.static.Create(self,vectm(1273,809,48),,'Shitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(1384,805,48),,'Shitting');

        class'PlaceholderEnemy'.static.Create(self,vectm(-326,1494,48),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(-422,1393,48),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(352,1510,48),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(451,1397,48),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(1154,170,224),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(1044,94,224),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(928,546,224),,'Sitting');

        break;
    //#endregion

    //#region Airfield
    case "03_NYC_AIRFIELD":
        if(dxr.flags.IsEntranceRando()) {
            //rebreather because of #TOOCEAN connection
            SpawnItemInContainer(self,class'#var(prefix)Rebreather',vectm(-2030,995,100)); //Truck near docks
        }

        foreach AllActors(class'#var(prefix)Terrorist', terror,'boatguard'){
            terror.bIsSecretGoal=true;
        }

        //Add teleporter hint text to Jock
        foreach AllActors(class'#var(prefix)MapExit',exit){break;}
        foreach AllActors(class'#var(prefix)BlackHelicopter',jock){break;}
        hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit,, true);
        hoverHint.SetBaseActor(jock);

        // fix collision with the static crates https://github.com/Die4Ever/deus-ex-randomizer/issues/665
        class'FillCollisionHole'.static.CreateLine(self, vectm(792.113403, -1343.670166, 69), vectm(675, -1343.670166, 69), 32, 90);
        class'FillCollisionHole'.static.CreateLine(self, vectm(675, -1300, 69), vectm(675, -1093.477783, 69), 32, 90);
        class'FillCollisionHole'.static.CreateLine(self, vectm(718, -1093.477783, 69), vectm(779.922424, -1093.477783, 69), 32, 80);

        class'FillCollisionHole'.static.CreateLine(self, vectm(-1300, 130, 69), vectm(-1030, 130, 69), 32, 80);
        class'FillCollisionHole'.static.CreateLine(self, vectm(-1030, 160, 69), vectm(-1030, 231, 69), 32, 80);

        class'FillCollisionHole'.static.CreateLine(self, vectm(4726, -2685, 69), vectm(4835, -2685, 69), 32, 80);
        class'FillCollisionHole'.static.CreateLine(self, vectm(4830, -2650, 69), vectm(4830, -2430, 69), 32, 80);
        class'FillCollisionHole'.static.CreateLine(self, vectm(4800, -2430, 69), vectm(4727, -2430, 69), 32, 80);

        class'FillCollisionHole'.static.CreateLine(self, vectm(-545, 585, 69), vectm(-545, 485, 69), 32, 80);
        class'FillCollisionHole'.static.CreateLine(self, vectm(-580, 485, 69), vectm(-805, 485, 69), 32, 80);
        class'FillCollisionHole'.static.CreateLine(self, vectm(-805, 510, 69), vectm(-805, 574, 69), 32, 80);

        class'FillCollisionHole'.static.CreateLine(self, vectm(-325, 1275, 69), vectm(-325, 1385, 69), 32, 80);
        class'FillCollisionHole'.static.CreateLine(self, vectm(-565, 1271, 69), vectm(-565, 1385, 69), 32, 80);

        class'FillCollisionHole'.static.CreateLine(self, vectm(585, 3395, 69), vectm(485, 3395, 69), 32, 80);
        class'FillCollisionHole'.static.CreateLine(self, vectm(485, 3360, 69), vectm(485, 3127, 69), 32, 80);

        class'FillCollisionHole'.static.CreateLine(self, vectm(485, 2805, 69), vectm(485, 2920, 69), 32, 80);

        class'FillCollisionHole'.static.CreateLine(self, vectm(1471, 3440, 69), vectm(1565, 3424, 69), 32, 80);
        class'FillCollisionHole'.static.CreateLine(self, vectm(1565, 3460, 69), vectm(1565, 3675, 69), 32, 80);
        class'FillCollisionHole'.static.CreateLine(self, vectm(1520, 3675, 69), vectm(1464, 3675, 69), 32, 80);

        // extra spots for datacube
        Spawn(class'PlaceholderItem',,, vectm(5113,3615,6.3));        //In front of guard tower
        Spawn(class'PlaceholderItem',,, vectm(3111,3218,275));        //Bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(3225,3193,275));        //Different Bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(2850,3448,219));        //Bathroom stall
        Spawn(class'PlaceholderItem',,, vectm(2929,2810,91));         //Dining table
        Spawn(class'PlaceholderItem',,, vectm(2860,3335,99));         //Kitchen Counter
        Spawn(class'PlaceholderItem',,, vectm(3055,3300,99));         //Kitchen island
        Spawn(class'PlaceholderItem',,, vectm(3036,3474,99));         //Next to stove
        Spawn(class'PlaceholderItem',,, vectm(4441,3112,51));         //Base of satellite
        Spawn(class'PlaceholderItem',,, vectm(1915,2800.6,79));       //Gate support (inside gate)
        Spawn(class'PlaceholderItem',,, vectm(3641.339,2623.73,27));  //Steps outside barracks
        if(VanillaMaps) {
            foreach AllActors(class'Teleporter', tele) {
                if(tele.Event == 'HangarEnt') {
                    tele.SetCollisionSize(tele.CollisionRadius, tele.CollisionHeight + 10);
                }
            }

            foreach AllActors(class'Teleporter', tele) {
                if (tele.event != 'BHElevatorEnt') continue;

                tele.event = '';
                tele.SetCollision(false, false, false);
                break;
            }
            dt = Spawn(class'DynamicTeleporter',,, vectm(2048.0, -2827.0, 56.1));
            dt.SetCollisionSize(50.0, 40.0);
            dt.SetDestination("03_NYC_AirfieldHeliBase",, "BHElevatorEnt");

            class'PlaceholderEnemy'.static.Create(self,vectm(2994,3406,256),,'Shitting');
            class'PlaceholderEnemy'.static.Create(self,vectm(2887,3410,256),,'Shitting');

            foreach RadiusActors(class'AlarmUnit', au, 1.0, vectm(-1967.865112, 1858.142822, 101.505104)) {
                // alarm inside the boat house is too high up for enemies to reach
                loc = au.Location;
                loc.z = 80.225643; // halfway between the one inside the boat house and the one outside
                au.SetLocation(loc);
                break;
            }
        }
        break;
    //#endregion

    //#region Brooklyn Bridge Station
    case "03_NYC_BROOKLYNBRIDGESTATION":

        if (class'MenuChoice_BalanceMaps'.static.ModerateEnabled()){
            //El Rey will no longer directly be ordered to attack the player, he will just go hostile and face them
            //This prevents him from breaking stealth
            foreach AllActors(class'#var(prefix)OrdersTrigger',ot,'elreyattacks'){
                class'FacePlayerTrigger'.static.Create(self,'elreyattacks','Elrey',ot.Location);
                class'DrawWeaponTrigger'.static.Create(self,'elreyattacks','Elrey',ot.Location,true);

                at = Spawn(class'#var(injectsprefix)AllianceTrigger',,'elreyattacks',ot.Location);
                at.SetCollision(False,False,False);
                at.Event='Elrey';
                at.Alliance='ThugGang';
                at.Alliances[0].allianceName='Player';
                at.Alliances[0].allianceLevel=-1.0;
                at.Alliances[0].bPermanent=true;

                ot.Destroy();
                break;
            }

            //Give HomeTag's to important people so they return to their original location if spooked
            //Charlie, El Rey, and the Ex-Mole Person already have a Start HomeTag set.
            foreach AllActors(class'#var(prefix)ScriptedPawn', sp){
                switch(sp.BindName){
                    case "DrugDealer": //Rock
                    case "Lenny": //Lenny
                        SetPawnLocAsHome(sp);
                        break;
                }
            }
        }

        if (VanillaMaps){
            //Put a button behind the hidden bathroom door
            //Mostly for entrance rando, but just in case
            //Revision already has a switch here (although it's small and hard to see)
            AddSwitch( vect(-1673, -1319.913574, 130.813538), rot(0, 32767, 0), 'MoleHideoutOpened' );

            class'FakeMirrorInfo'.static.Create(self,vectm(-1344,-1645,186),vectm(-1256,-1660,130)); //Women's Bathroom Mirror
            class'FakeMirrorInfo'.static.Create(self,vectm(-1456,-1645,186),vectm(-1368,-1660,130)); //Women's Bathroom Mirror
            class'FakeMirrorInfo'.static.Create(self,vectm(-1343,-2935,186),vectm(-1256,-2950,130)); //Men's Bathroom Mirror
            class'FakeMirrorInfo'.static.Create(self,vectm(-1455,-2935,186),vectm(-1367,-2950,130)); //Men's Bathroom Mirror
        } else {
            //These mirrors actually work in Revision, so no FakeMirrorInfo required
        }
        break;
    //#endregion

    //#region Mole People
    case "03_NYC_MOLEPEOPLE":
        foreach AllActors(class'#var(DeusExPrefix)Mover', dxm, 'DeusExMover') {
            if( dxm.KeyIDNeeded == 'MoleRestroomKey' ) dxm.Tag = 'BathroomDoor';
        }

        //The Leader can go hostile so easily... just make that not possible
        foreach AllActors(class'#var(prefix)Terrorist',terror,'MoleTerroristLeader'){
            terror.ChangeAlly('Player',0,True);//Permanently neutral
            break;
        }

        if (VanillaMaps){
            AddSwitch( vect(3745, -2593.711914, 140.335358), rot(0, 0, 0), 'BathroomDoor' );

            foreach AllActors(class'Mover', m, 'WaterChanges') {
                if(m.Name == 'DeusExMover0') {
                    // lower the mole people broken water
                    m.SetLocation(m.Location + vectm(0,0, -16));
                    m.MoveTime = 0.1;
                    // put the flag trigger here instead of the "start" of the map, for entrance rando
                    foreach AllActors(class'Trigger', t, 'FlagTrigger') {
                        if(t.Event == 'WaterChanges') {
                            t.SetLocation(m.Location);
                            t.SetCollisionSize(1280, 1280);
                        }
                    }
                } else if(m.Name == 'DeusExMover1') {
                    // mole people running water can extinuish fire, great for bingo
                    a = Spawn(class'ExtinguishFireTrigger',,, m.Location + vectm(0, 0, -14));
                    a.SetCollisionSize(60.0, 10.0);
                    a.SetBase(m);
                    m.MoveTime = 0.1;
                }
            }

            class'PlaceholderEnemy'.static.Create(self,vectm(4030,-2958,112),,'Shitting');

            class'FakeMirrorInfo'.static.Create(self,vectm(3895,-2730,186),vectm(3808,-2710,130)); //Women's Bathroom Mirror
            class'FakeMirrorInfo'.static.Create(self,vectm(4007,-2730,186),vectm(3920,-2710,130)); //Women's Bathroom Mirror
            class'FakeMirrorInfo'.static.Create(self,vectm(3895,-2395,186),vectm(3808,-2375,130)); //Men's Bathroom Mirror
            class'FakeMirrorInfo'.static.Create(self,vectm(4007,-2395,186),vectm(3920,-2375,130)); //Men's Bathroom Mirror

        } else {
            //Revision
            AddSwitch( vect(3745,-2592,140), rot(0, 0, 0), 'BathroomDoor' );
            //These mirrors actually work in Revision, so no FakeMirrorInfo required
        }

        // change "MolePerson" (un)familiarNames to "Mole Person". he's in the wood shack near the Terrorist Leader
        foreach AllActors(class'#var(prefix)HumanCivilian', hc) {
            if (hc.UnfamiliarName == "MolePerson") {
                hc.UnfamiliarName = "Mole Person";
            }
            if (hc.FamiliarName == "MolePerson") {
                hc.FamiliarName = "Mole Person";
            }
        }

        Spawn(class'PlaceholderItem',,, vectm(-73,-497.98,42.3)); //Water supply
        Spawn(class'PlaceholderItem',,, vectm(-486,206,26)); //Under ramps
        Spawn(class'PlaceholderItem',,, vectm(461,206,26)); //Under Ramp 2
        Spawn(class'PlaceholderItem',,, vectm(395,830,74)); //Around Pillars
        Spawn(class'PlaceholderItem',,, vectm(-2,633,74));//More pillars
        Spawn(class'PlaceholderItem',,, vectm(-465,562,74));//Even more pillars
        Spawn(class'PlaceholderItem',,, vectm(-659,990,107)); //Pillar stairs
        Spawn(class'PlaceholderItem',,, vectm(661,1000,107)); //other side pillar stairs
        Spawn(class'PlaceholderItem',,, vectm(-919,-94,11)); //Other side ramp
        Spawn(class'PlaceholderItem',,, vectm(1222,88,11)); //Near start, but bad side


        break;
    //#endregion

    //#region 747
    case "03_NYC_747":
        // fix Jock's conversation state so he doesn't play the dialog for unatco->battery park but now plays dialog for airfield->unatco
        // DL_Airfield is "You're entering a helibase terminal below a private section of LaGuardia."
        dxr.flagbase.SetBool('DL_Airfield_Played', true,, 4);
        if(VanillaMaps) {
            foreach AllActors(class'#var(prefix)InformationDevices', i) {
                if(i.imageClass == Class'Image03_747Diagram') {
                    // move the out of bounds datacabe onto the bed of the empty room
                    i.SetLocation(vectm(1554.862549, -741.237427, 363.370605));
                }
            }
        }

        //This makes it so Juan will at least attempt to return back to his original location after being spooked
        //It still fails sometimes (maybe when the player is blocking the path back?) and leaves him standing there,
        //but it's at least a sometimes improvement?
        if(class'MenuChoice_BalanceMaps'.static.ModerateEnabled()){
            foreach AllActors(class'#var(prefix)JuanLebedev',juan){
                SetPawnLocAsHome(juan);
            }
        }

        Spawn(class'PlaceholderItem',,, vectm(1702,-359.8,373)); //Bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(1624.15,-740.12,373)); //Guest bed headboard
        Spawn(class'PlaceholderItem',,, vectm(1412.5,-297.7,406.32)); //Closet shelf
        Spawn(class'PlaceholderItem',,, vectm(1445.97,-294.6,316.31)); //Closet floor
        Spawn(class'PlaceholderItem',,, vectm(733.2,-462.57,342.5)); //Middle seat row
        Spawn(class'PlaceholderItem',,, vectm(617.1,-511.35,342.51)); //Back row seat
        Spawn(class'PlaceholderItem',,, vectm(327.4,-524.8,342.5)); //Weird solo seating row
        Spawn(class'PlaceholderItem',,, vectm(342.4,-730.14,196.3)); //Shelf in cargo area
        Spawn(class'PlaceholderItem',,, vectm(495.4,-733.96,196.3)); //Shelf in cargo area
        break;
    //#endregion

    //#region UNATCO Island
    case "03_NYC_UNATCOISLAND":
        if(class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) {
            foreach AllActors(class'#var(prefix)UNATCOTroop', unatco) {
                if(unatco.BindName != "PrivateLloyd") continue;
                unatco.FamiliarName = "Corporal Lloyd";
                unatco.UnfamiliarName = "Corporal Lloyd";
            }
        }
        //Add teleporter hint text to Jock
        foreach AllActors(class'#var(prefix)MapExit',exit){break;}
        foreach AllActors(class'#var(prefix)BlackHelicopter',jock){break;}
        hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit);
        hoverHint.SetBaseActor(jock);

        if (VanillaMaps){
            //Fix a hole in the wall
            class'FillCollisionHole'.static.CreateLine(self, vectm(-4400,3165,-20), vectm(-3480,3165,-20), 32, 100);
        }

        SetAllLampsState(,, false, vect(-5724.620605, 1435.543213, -79.614632), 0.01);

        break;
    //#endregion

    //#region UNATCO HQ
    case "03_NYC_UNATCOHQ":
        FixUNATCOCarterCloset();
        FixAlexsEmail();
        MakeTurretsNonHostile(); //Revision has hostile turrets near jail
        SpeedUpUNATCOFurnaceVent();

        if(class'MenuChoice_BalanceMaps'.static.MajorEnabled()) {
            k = Spawn(class'#var(prefix)NanoKey',,, vectm(965,900,-28));
            k.KeyID = 'JaimeClosetKey';
            k.Description = "MedLab Closet Key Code";
            if(dxr.flags.settings.keysrando > 0)
                GlowUp(k);
        }

        foreach AllActors(class'#var(prefix)OrdersTrigger',ot){
            if (ot.ordersTag=='CarterAtWindow'){
                ot.Orders='RunningTo';
                break;
            }
        }

        if (VanillaMaps) {
            //Move weapon mod out of Manderley's secret (inaccessible) safe
            foreach AllActors(class'#var(prefix)WeaponModRecoil',wmr){
                if (wmr.Name=='WeaponModRecoil0'){
                    wmr.SetLocation(vectm(420.843567,175.866135,261.520447));
                }
            }

            foreach AllActors(class'#var(prefix)ComputerPublic', compublic) {
                compublic.bCollideWorld = false;
                compublic.SetLocation(vectm(741.36, 1609.34, 298.0));
                compublic.SetRotation(rotm(0, -16384, 0, GetRotationOffset(class'#var(prefix)ComputerPublic')));
                compublic.TextPackage = "#var(package)";
                compublic.BulletinTag = '03_BulletinMenu';
                break;
            }
            class'FakeMirrorInfo'.static.Create(self,vectm(2430,1872,-80),vectm(2450,2060,-16)); //Mirror window at level 4 entrance
        } else {
            foreach AllActors(class'#var(prefix)WeaponShuriken',tk){
                tk.bIsSecretGoal=true; //Keep the throwing knives in Anna's mannequin
            }
            class'FakeMirrorInfo'.static.Create(self,vectm(2475,1872,-80),vectm(2450,2064,-16)); //Mirror window at level 4 entrance
        }

        SetAllLampsState(true, false, true); // alex isn't in his office

        //Spawn some placeholders for new item locations
        Spawn(class'PlaceholderItem',,, vectm(363.284149, 344.847, 50.32)); //Womens bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(211.227, 348.46, 50.32)); //Mens bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(982.255,1096.76,-7)); //Jaime's desk
        Spawn(class'PlaceholderItem',,, vectm(-307.8,-1122,-7)); //Anna's Desk
        Spawn(class'PlaceholderItem',,, vectm(-138.5,-790.1,-1.65)); //Anna's bookshelf
        if (VanillaMaps){
            Spawn(class'PlaceholderItem',,, vectm(-27,1651.5,291)); //Breakroom table
            Spawn(class'PlaceholderItem',,, vectm(602,1215.7,295)); //Kitchen Counter

            Spawn(class'PlaceholderItem',,, vectm(2033.8,1979.9,-85)); //Near MJ12 Door
            Spawn(class'PlaceholderItem',,, vectm(2148,2249,-85)); //Near MJ12 Door
            Spawn(class'PlaceholderItem',,, vectm(2433,1384,-85)); //Near MJ12 Door
            Spawn(class'PlaceholderContainer',,, vectm(2384,1669,-95)); //MJ12 Door

        } else {
            //Revision Kitchen/Breakroom is in a different location
            Spawn(class'PlaceholderItem',,, vectm(295,1385,485)); //Breakroom table
            Spawn(class'PlaceholderItem',,, vectm(765,1500,440)); //Kitchen Counter

            //Level 4/MJ12 Lab area is blocked off in Revision, these are alternate locations for those placeholders
            Spawn(class'PlaceholderItem',,, vectm(110,-1050,-20)); //Desk at entrance to jail area
            Spawn(class'PlaceholderItem',,, vectm(1280,-180,-55)); //Next to couch/plant outside medical
            Spawn(class'PlaceholderItem',,, vectm(1335,300,-35)); //Under desk near medical beds
            Spawn(class'PlaceholderContainer',,, vectm(1490,975,-20)); //Near blocked door down to level 4

        }
        Spawn(class'PlaceholderItem',,, vectm(-672.8,1261,473)); //Upper Left Office desk
        Spawn(class'PlaceholderItem',,, vectm(-433.128601,736.819763,314.310211)); //Weird electrical thing in closet
        Spawn(class'PlaceholderContainer',,, vectm(-1187,-1154,-31)); //Behind Jail Desk
        Spawn(class'PlaceholderContainer',,, vectm(-383.6,1376,273)); //JC's Office

        break;
    //#endregion
    }
}
//#endregion

//#region Any Entry
function AnyEntryMapFixes()
{
    local #var(prefix)Phone phone;
    local Conversation c;
    local ConEvent ce;
    local ConEventSpeech ces;
    local ConEventChoice cec;
    local ConChoice      cc;
    local bool RevisionMaps, knowPass, foundUnderground;
    local string textAdd;
    local #var(prefix)SecurityCamera cam;
    local #var(prefix)AutoTurret turret;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    switch(dxr.localURL) {
    case "03_NYC_747":
        SetTimer(1, true);
        break;

    case "03_NYC_AIRFIELDHELIBASE":
        if (!RevisionMaps){
            //Restore this cut phone conversation
            c = GetConversation('OverhearLebedev');
            c.conOwnerName="LebedevPhone";
            c.bInvokeRadius=True;
            c.radiusDistance=200;
            foreach AllActors(class'#var(prefix)Phone',phone){
                if (phone.name=='Phone1'){
                    phone.BindName="LebedevPhone";
                    break;
                }
            }

            ce = c.eventList;
            while (ce!=None){
                if (ce.eventType==ET_Speech){
                    ces = ConEventSpeech(ce);
                    ces.speaker=phone;
                    ces.speakingTo=phone;
                }
                ce = ce.nextEvent;
            }

            phone.ConBindEvents();
        }

        if (dxr.flagbase.GetBool('MeetLebedev_Played') || dxr.flagbase.GetBool('JuanLebedev_Dead')) {
            foreach AllActors(class'#var(prefix)SecurityCamera', cam) {
                cam.UnTrigger(None, None);
            }
            foreach AllActors(class'#var(prefix)AutoTurret', turret) {
                turret.UnTrigger(None, None);
            }
        }

        break;

    case "03_NYC_BROOKLYNBRIDGESTATION":
        // allow giving zyme to junkies even if you enter the maps out of order
        DeleteConversationFlag(GetConversation('MeetLenny'), 'FoundMoles', False);
        // Lenny's final barks seem to mistakenly be started by frobbing or bumping into him, causing them to take priority over `MeetLenny`
        c=GetConversation('LennyFinalBarks');
        c.bInvokeBump=False;
        c.bInvokeFrob=False;
        c=GetConversation('LennyFinalBarks2');
        c.bInvokeBump=False;
        c.bInvokeFrob=False;

        DeleteConversationFlag(GetConversation('MeetDon'), 'FoundMoles', False);
        c=GetConversation('DonFinalBarks');
        c.bInvokeBump=False;
        c.bInvokeFrob=False;
        c=GetConversation('DonFinalBarks2');
        c.bInvokeBump=False;
        c.bInvokeFrob=False;
        c=GetConversation('DonReturnBarks');
        c.bInvokeBump=False;
        c.bInvokeFrob=False;

        break;
    case "03_NYC_BATTERYPARK":
        knowPass = dxr.flagbase.GetBool('PlayerKnowsUnderworldPassword');
        foundUnderground = dxr.flagbase.GetBool('M03FoundUnderground');
        textAdd="";

        if (foundUnderground){
            textAdd=" (Already got underground)";
        } else if (knowPass) {
            textAdd=" (Already know the password to give to Curly)";
        }

        if (textAdd!="") {
            c=GetConversation('M03MeetFilben');
            ce = c.eventList;
            while (ce!=None){
                if (ce.eventType==ET_Choice){
                    cec = ConEventChoice(ce);
                    cc = cec.ChoiceList;
                    while (cc!=None){
                        if (InStr(cc.choiceText,"interested")!=-1){ //"I'm not interested."
                            cc.choiceText = cc.choiceText $ textAdd;
                        }
                        cc = cc.nextChoice;
                    }
                }
                ce = ce.nextEvent;
            }
        }
        break;
    }
}
//#endregion

//#region Fix Anna Ambush
function FixAnnaAmbush()
{
    local #var(prefix)AnnaNavarre anna;
    local #var(prefix)ThrownProjectile p;

    if(!class'MenuChoice_BalanceMaps'.static.MajorEnabled()) return;

    foreach AllActors(class'#var(prefix)AnnaNavarre', anna) {break;}

    anna.MaxProvocations = 0;

    // if she's angry then let her blow up
    if(anna != None && anna.GetAllianceType('player') == ALLIANCE_Hostile) anna = None;

    foreach AllActors(class'#var(prefix)ThrownProjectile', p) {
        if(!p.bProximityTriggered || !p.bStuck) continue;
        if(p.Owner==player() && anna != None) p.SetOwner(anna);
        if(anna == None && p.Owner!=player()) p.SetOwner(player());
    }
}
//#endregion
