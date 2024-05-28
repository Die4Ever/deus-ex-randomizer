class DXRFixupM02 extends DXRFixup;

function PreFirstEntryMapFixes()
{
    local BarrelAmbrosia ambrosia;
    local Trigger t;
    local NYPoliceBoat b;
    local DeusExMover d;
    local #var(prefix)NanoKey k;
    local CrateExplosiveSmall c;
    local Terrorist nsf;
    local #var(prefix)BoxSmall bs;
    local #var(prefix)Keypad2 kp;
    local #var(prefix)TAD tad;
    local #var(prefix)FishGenerator fg;
    local #var(prefix)PigeonGenerator pg;
    local #var(prefix)Trigger trig;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
    local DXRHoverHint hoverHint;
    local DXRButtonHoverHint buttonHint;
    local #var(prefix)Button1 button;
    local OnceOnlyTrigger oot;
    local bool RevisionMaps;
    local bool VanillaMaps;
    local #var(prefix)CrateUnbreakableSmall crateSmall;
    local #var(prefix)CrateUnbreakableMed crateMedium;
    local Vector loc;

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
    case "02_NYC_BATTERYPARK":
        if (VanillaMaps){
            foreach AllActors(class'BarrelAmbrosia', ambrosia) {
                foreach RadiusActors(class'Trigger', t, 16, ambrosia.Location) {
                    if(t.CollisionRadius < 100)
                        t.SetCollisionSize(t.CollisionRadius*2, t.CollisionHeight*2);
                }
            }
            foreach AllActors(class'#var(prefix)MapExit',exit,'Boat_Exit'){break;}
            foreach AllActors(class'NYPoliceBoat',b) {
                b.BindName = "NYPoliceBoat";
                b.ConBindEvents();
                class'DXRTeleporterHoverHint'.static.Create(self, "", b.Location, b.CollisionRadius+5, b.CollisionHeight+5, exit);
            }
            foreach AllActors(class'DeusExMover', d) {
                if( d.Name == 'DeusExMover19' ) {
                    d.KeyIDNeeded = 'ControlRoomDoor';
                }
            }
            foreach AllActors(class'Terrorist',nsf,'ShantyTerrorist'){
                nsf.Tag = 'ShantyTerrorists';  //Restores voice lines when NSF still alive (still hard to have happen though)
            }
            if(!dxr.flags.IsZeroRando()) {
                k = Spawn(class'#var(prefix)NanoKey',,, vectm(1574.209839, -238.380142, 339.215179));
                k.KeyID = 'ControlRoomDoor';
                k.Description = "Control Room Door Key";
                if(dxr.flags.settings.keysrando > 0)
                    GlowUp(k);
            }

            fg=Spawn(class'#var(prefix)FishGenerator',,, vectm(-1274,-3892,177));//Near Boat dock
            fg.ActiveArea=2000;
        }

        break;
    case "02_NYC_WAREHOUSE":
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

            npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(1700.929810,-519.988037,57.729870),rotm(0,0,0,0),'02_Newspaper06'); //Joe Greene article, table in room next to break room (near bathrooms)
            npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(-1727.644775,2479.614990,1745.724976),rotm(0,0,0,0),'02_Newspaper06'); //Next to apartment(?) door on rooftops, near elevator

            //Remove the small boxes in the sewers near the ladder so that bigger boxes don't shuffle into those spots
            foreach AllActors(class'DeusExMover',d,'DrainGrate'){break;}
            foreach d.RadiusActors(class'#var(prefix)BoxSmall',bs,800){bs.Destroy();}

            //A switch in the sewer swimming path to allow backtracking
            AddSwitch( vect(-1518.989136,278.541260,-439.973816), rot(0, 2768, 0), 'DrainGrate');

            //A keypad in the sewer walking path to allow backtracking
            kp = #var(prefix)Keypad2(Spawnm(class'#var(prefix)Keypad2',,,vect(-622.685,497.4295,-60.437), rot(0,-49192,0)));
            kp.validCode="2577";
            kp.bToggleLock=False;
            kp.Event='DoorToWarehouse';

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
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit);
            hoverHint.SetBaseActor(jock);

            foreach AllActors(class'#var(prefix)MapExit',exit,'ToStreet'){break;}
            foreach AllActors(class'#var(prefix)Button1',button){
                if (button.Event=='ToStreet'){
                    break;
                }
            }

            buttonHint = DXRButtonHoverHint(class'DXRButtonHoverHint'.static.Create(self, "", button.Location, button.CollisionRadius+5, button.CollisionHeight+5, exit));
            buttonHint.SetBaseActor(button);

            // fix collision with the fence https://github.com/Die4Ever/deus-ex-randomizer/issues/665
            foreach AllActors(class'DeusExMover', d) {
                if(d.Event == 'BlewFence') break;
            }
            class'FillCollisionHole'.static.CreateLine(self, vectm(-2184, 1266.793335, 79.291428), vectm(-2050, 1266.793335, 79.291428), 10, 80, d);

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
        }
        break;
    case "02_NYC_HOTEL":
        if (VanillaMaps){
            Spawn(class'#var(prefix)Binoculars',,, vectm(-610.374573,-3221.998779,94.160065)); //Paul's bedside table

            //Restore answering machine message, but in mission 2 (conversation is in mission 3);
            //tad=Spawn(class'#var(prefix)TAD',,, vectm(-290,-2380,115),rotm(0,0,0));
            //tad.BindName="AnsweringMachine";
            //CreateAnsweringMachineConversation(tad);
            //tad.ConBindEvents();


            Spawn(class'PlaceholderItem',,, vectm(-732,-2628,75)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(-732,-2712,75)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(-129,-3038,127)); //Bathroom counter
            Spawn(class'PlaceholderItem',,, vectm(15,-2972,123)); //Kitchen counter
            Spawn(class'PlaceholderItem',,, vectm(-853,-3148,75)); //Crack next to Paul's bed

            SetAllLampsState(false, true, true); // the lamp in Paul's apartment
        }
        break;

    case "02_NYC_STREET":
        if (RevisionMaps){
            foreach AllActors(class'CrateExplosiveSmall', c) {
                l("hiding " $ c @ c.Tag @ c.Event);
                c.bHidden = true;// hide it so DXRSwapItems doesn't move it, this is supposed to be inside the plane that flies overhead
            }
        }
        foreach AllActors(class'DeusExMover', d, 'AugStore') {
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
        Spawn(class'SmugglerElevatorTracker',, 'elevatorbutton');

        break;
    case "02_NYC_BAR":
        Spawnm(class'BarDancer',,,vect(-1475,-580,48),rot(0,25000,0));
        break;

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
    case "02_NYC_SMUG":
        foreach AllActors(class'DeusExMover', d,'botordertrigger') {
            d.tag = 'botordertriggerDoor';
        }

        oot = Spawn(class'OnceOnlyTrigger');
        oot.Event='botordertriggerDoor';
        oot.Tag='botordertrigger';

        SetAllLampsState(false, true, true); // smuggler has one table lamp, upstairs where no one is
        Spawn(class'SmugglerElevatorTracker',, 'elevatorbutton');

        break;

    case "02_NYC_FREECLINIC":
        SetAllLampsState(true, true, false); // the free clinic has one desk lamp, at a desk no one is using
        break;
    }
}

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

function PostFirstEntryMapFixes()
{
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    switch(dxr.localURL) {
    case "02_NYC_WAREHOUSE":
        if(!RevisionMaps) {
            AddBox(class'#var(prefix)CrateUnbreakableSmall', vectm(183.993530, 926.125000, 1162.103271));// apartment
            AddBox(class'#var(prefix)CrateUnbreakableMed', vectm(-389.361969, 744.039978, 1088.083618));// ladder
            AddBox(class'#var(prefix)CrateUnbreakableSmall', vectm(-328.287048, 767.875000, 1072.113770));
        }

        if(!dxr.flags.IsZeroRando()) {
            // this map is too hard
            Spawn(class'#var(prefix)AdaptiveArmor',,, GetRandomPositionFine());
            Spawn(class'#var(prefix)AdaptiveArmor',,, GetRandomPositionFine());
            Spawn(class'#var(prefix)BallisticArmor',,, GetRandomPositionFine());
            Spawn(class'#var(prefix)BallisticArmor',,, GetRandomPositionFine());
            Spawn(class'#var(prefix)FireExtinguisher',,, GetRandomPositionFine());
            Spawn(class'#var(prefix)FireExtinguisher',,, GetRandomPositionFine());
        }

        break;
    }
}

function AnyEntryMapFixes()
{
    local Jock j;

    switch (dxr.localURL) {
    case "02_NYC_BAR":
        if (dxr.flagbase.getBool('GeneratorBlown')) {
            foreach AllActors(class'Jock', j) {
                j.LeaveWorld();
                break;
            }
        }
        break;

    case "02_NYC_STREET":
        MoveSmugglerElevator();
        break;

    case "02_NYC_SMUG":
        if (dxr.flagbase.getBool('SmugglerDoorDone')) {
            dxr.flagbase.setBool('MetSmuggler', true,, -1);
        }
        MoveSmugglerElevator();
        break;
    }
}
