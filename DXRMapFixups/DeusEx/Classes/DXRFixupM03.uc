class DXRFixupM03 extends DXRFixup;

function CheckConfig()
{
    local int i;

    add_datacubes[i].map = "03_NYC_UNATCOHQ";
    add_datacubes[i].text = "Note to self:|nUsername: JCD|nPassword: bionicman ";
    i++;

    Super.CheckConfig();
}

function PostFirstEntryMapFixes()
{
    local Actor a;
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    FixUNATCORetinalScanner();

    switch(dxr.localURL) {
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
        break;
    }
}

function TimerMapFixes()
{
    switch(dxr.localURL)
    {
    case "03_NYC_747":
        FixAnnaAmbush();
        break;
    }
}

function PreFirstEntryMapFixes()
{
    local Mover m;
    local Actor a;
    local Trigger t;
    local Teleporter tele;
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

    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch (dxr.localURL)
    {
    case "03_NYC_BATTERYPARK":
        foreach AllActors(class'#var(prefix)NanoKey', k) {
            // unnamed key normally unreachable
            if( k.KeyID == '' || k.KeyID == 'KioskDoors' ) {
                k.Destroy();
            }
        }
        foreach AllActors(class'#var(prefix)InformationDevices', i) {
            if( i.textTag == '03_Book06' ) {
                i.bAddToVault = true;
            }
        }

        if(VanillaMaps) {
            AddSwitch(vect(-4621.640137, 2902.651123, -650.285461), rot(0,0,0), 'ElevatorPhone');
        }

        fg=Spawn(class'#var(prefix)FishGenerator',,, vectm(-1274,-3892,177));//Near Boat dock
        fg.ActiveArea=2000;

        //rebreather because of #TOOCEAN connection
        AddActor(class'Rebreather', vect(-936.151245, -3464.031006, 293.710968));

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

    case "03_NYC_AirfieldHeliBase":
        if (VanillaMaps){
            foreach AllActors(class'Mover',m) {
                // call the elevator at the end of the level when you open the appropriate door
                if (m.Tag == 'BasementDoorOpen')
                {
                    m.Event = 'BasementFloor';
                }
                else if (m.Tag == 'GroundDoorOpen')
                {
                    m.Event = 'GroundLevel';
                }
                // sewer door backtracking so we can make a switch for this
                else if ( DeusExMover(m) != None && DeusExMover(m).KeyIDNeeded == 'Sewerdoor')
                {
                    m.Tag = 'Sewerdoor';
                }
            }
            foreach AllActors(class'Trigger', t) {
                //disable the platforms that fall when you step on them
                if( t.Name == 'Trigger0' || t.Name == 'Trigger1' ) {
                    t.Event = '';
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

            //rebreather because of #TOOCEAN connection
            Spawn(class'Rebreather',,, vectm(1411.798950, 546.628845, 247.708572));

            //Button to extend sewer platform from the other side
            AddSwitch( vect(-5233.946289,3601.383545,161.851822), rot(0, 16384, 0), 'MoveableBridge');
        }
        break;

    case "03_NYC_AIRFIELD":
        //rebreather because of #TOOCEAN connection
        Spawn(class'Rebreather',,, vectm(-2031.959473, 995.781067, 75.709816));
        // extra spots for datacube
        Spawn(class'PlaceholderItem',,, vectm(5113,3615,1.3));        //In front of guard tower
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
            //Add teleporter hint text to Jock
            foreach AllActors(class'#var(prefix)MapExit',exit){break;}
            foreach AllActors(class'#var(prefix)BlackHelicopter',jock){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit.Name);
            hoverHint.SetBaseActor(jock);
        }
        break;

    case "03_NYC_BROOKLYNBRIDGESTATION":
        if (VanillaMaps){
            //Put a button behind the hidden bathroom door
            //Mostly for entrance rando, but just in case
            AddSwitch( vect(-1673, -1319.913574, 130.813538), rot(0, 32767, 0), 'MoleHideoutOpened' );
        }
        break;

    case "03_NYC_MOLEPEOPLE":
        if (VanillaMaps){
            foreach AllActors(class'Mover', m, 'DeusExMover') {
                if( m.Name == 'DeusExMover65' ) m.Tag = 'BathroomDoor';
            }
            AddSwitch( vect(3745, -2593.711914, 140.335358), rot(0, 0, 0), 'BathroomDoor' );

            //The Leader can go hostile so easily... just make that not possible
            foreach AllActors(class'#var(prefix)Terrorist',terror){
                if (terror.BindName=="TerroristLeader"){
                    terror.ChangeAlly('Player',0,True);//Permanently neutral
                    break;
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
        }
        break;

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

    case "03_NYC_UNATCOISLAND":
        if(!dxr.flags.IsReducedRando()) {
            foreach AllActors(class'#var(prefix)UNATCOTroop', unatco) {
                if(unatco.BindName != "PrivateLloyd") continue;
                unatco.FamiliarName = "Corporal Lloyd";
                unatco.UnfamiliarName = "Corporal Lloyd";
            }
        }
        //Add teleporter hint text to Jock
        foreach AllActors(class'#var(prefix)MapExit',exit){break;}
        foreach AllActors(class'#var(prefix)BlackHelicopter',jock){break;}
        hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit.Name);
        hoverHint.SetBaseActor(jock);

        break;
    case "03_NYC_UNATCOHQ":
        FixUNATCOCarterCloset();
        FixAlexsEmail();

        //Move weapon mod out of Manderley's secret (inaccessible) safe
        foreach AllActors(class'#var(prefix)WeaponModRecoil',wmr){
            if (wmr.Name=='WeaponModRecoil0'){
                wmr.SetLocation(vectm(420.843567,175.866135,261.520447));
            }
        }

        k = Spawn(class'#var(prefix)NanoKey',,, vectm(965,900,-28));
        k.KeyID = 'JaimeClosetKey';
        k.Description = "MedLab Closet Key Code";
        if(dxr.flags.settings.keysrando > 0)
            GlowUp(k);

        //Spawn some placeholders for new item locations
        Spawn(class'PlaceholderItem',,, vectm(363.284149, 344.847, 50.32)); //Womens bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(211.227, 348.46, 50.32)); //Mens bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(982.255,1096.76,-7)); //Jaime's desk
        Spawn(class'PlaceholderItem',,, vectm(2033.8,1979.9,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vectm(2148,2249,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vectm(2433,1384,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vectm(-307.8,-1122,-7)); //Anna's Desk
        Spawn(class'PlaceholderItem',,, vectm(-138.5,-790.1,-1.65)); //Anna's bookshelf
        Spawn(class'PlaceholderItem',,, vectm(-27,1651.5,291)); //Breakroom table
        Spawn(class'PlaceholderItem',,, vectm(602,1215.7,295)); //Kitchen Counter
        Spawn(class'PlaceholderItem',,, vectm(-672.8,1261,473)); //Upper Left Office desk
        Spawn(class'PlaceholderItem',,, vectm(-433.128601,736.819763,314.310211)); //Weird electrical thing in closet
        Spawn(class'PlaceholderContainer',,, vectm(-1187,-1154,-31)); //Behind Jail Desk
        Spawn(class'PlaceholderContainer',,, vectm(2384,1669,-95)); //MJ12 Door
        Spawn(class'PlaceholderContainer',,, vectm(-383.6,1376,273)); //JC's Office

        foreach AllActors(class'#var(prefix)HumanCivilian', hc, 'LDDPChet') {
            // Chet's name is Chet
            hc.bImportant = true;
        }

        break;
    }
}

function AnyEntryMapFixes()
{
    local #var(prefix)Phone phone;
    local Conversation c;
    local ConEvent ce;
    local ConEventSpeech ces;
    local bool RevisionMaps;

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
        break;
    }
}

function FixAnnaAmbush()
{
    local #var(prefix)AnnaNavarre anna;
    local #var(prefix)ThrownProjectile p;

    foreach AllActors(class'#var(prefix)AnnaNavarre', anna) {break;}

    // if she's angry then let her blow up
    if(anna != None && anna.GetAllianceType('player') == ALLIANCE_Hostile) anna = None;

    foreach AllActors(class'#var(prefix)ThrownProjectile', p) {
        if(!p.bProximityTriggered || !p.bStuck) continue;
        if(p.Owner==player() && anna != None) p.SetOwner(anna);
        if(anna == None && p.Owner!=player()) p.SetOwner(player());
    }
}
