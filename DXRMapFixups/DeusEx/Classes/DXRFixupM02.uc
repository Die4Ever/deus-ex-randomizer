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
#ifdef injections
    local #var(prefix)Newspaper np;
    local class<#var(prefix)Newspaper> npClass;
    npClass = class'#var(prefix)Newspaper';
#else
    local DXRInformationDevices np;
    local class<DXRInformationDevices> npClass;
    npClass = class'DXRInformationDevices';
#endif

    switch (dxr.localURL)
    {
#ifdef vanillamaps
    case "02_NYC_BATTERYPARK":
        foreach AllActors(class'BarrelAmbrosia', ambrosia) {
            foreach RadiusActors(class'Trigger', t, 16, ambrosia.Location) {
                if(t.CollisionRadius < 100)
                    t.SetCollisionSize(t.CollisionRadius*2, t.CollisionHeight*2);
            }
        }
        foreach AllActors(class'NYPoliceBoat',b) {
            b.BindName = "NYPoliceBoat";
            b.ConBindEvents();
        }
        foreach AllActors(class'DeusExMover', d) {
            if( d.Name == 'DeusExMover19' ) {
                d.KeyIDNeeded = 'ControlRoomDoor';
            }
        }
        foreach AllActors(class'Terrorist',nsf,'ShantyTerrorist'){
            nsf.Tag = 'ShantyTerrorists';  //Restores voice lines when NSF still alive (still hard to have happen though)
        }
        k = Spawn(class'#var(prefix)NanoKey',,, vectm(1574.209839, -238.380142, 339.215179));
        k.KeyID = 'ControlRoomDoor';
        k.Description = "Control Room Door Key";
        if(dxr.flags.settings.keysrando > 0)
            GlowUp(k);
        break;
    case "02_NYC_WAREHOUSE":
        npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(1700.929810,-519.988037,57.729870),rotm(0,0,0),'02_Newspaper06'); //Joe Greene article, table in room next to break room (near bathrooms)
        npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(-1727.644775,2479.614990,1745.724976),rotm(0,0,0),'02_Newspaper06'); //Next to apartment(?) door on rooftops, near elevator

        //Remove the small boxes in the sewers near the ladder so that bigger boxes don't shuffle into those spots
        foreach AllActors(class'DeusExMover',d,'DrainGrate'){break;}
        foreach d.RadiusActors(class'#var(prefix)BoxSmall',bs,800){bs.Destroy();}

        //A switch in the sewer swimming path to allow backtracking
        AddSwitch( vect(-1518.989136,278.541260,-439.973816), rot(0, 2768, 0), 'DrainGrate');

       //A keypad in the sewer walking path to allow backtracking
        kp = Spawn(class'Keypad2',,,vectm(-622.685,497.4295,-60.437), rotm(0,-49192,0));
        kp.validCode="2577";
        kp.bToggleLock=False;
        kp.Event='DoorToWarehouse';

        class'PlaceholderEnemy'.static.Create(self,vectm(782,-1452,48));
        class'PlaceholderEnemy'.static.Create(self,vectm(1508,-1373,256));
        class'PlaceholderEnemy'.static.Create(self,vectm(1814,-1842,48));
        class'PlaceholderEnemy'.static.Create(self,vectm(-31,-1485,48));
        class'PlaceholderEnemy'.static.Create(self,vectm(1121,-1095,-144));
        class'PlaceholderEnemy'.static.Create(self,vectm(467,-214,-144));
        break;
    case "02_NYC_HOTEL":
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
        break;
#endif

    case "02_NYC_STREET":
#ifdef revision
        foreach AllActors(class'CrateExplosiveSmall', c) {
            l("hiding " $ c @ c.Tag @ c.Event);
            c.bHidden = true;// hide it so DXRSwapItems doesn't move it, this is supposed to be inside the plane that flies overhead
        }
#endif
        foreach AllActors(class'DeusExMover', d, 'AugStore') {
            d.bFrobbable = true;
        }
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
    switch(dxr.localURL) {
    case "02_NYC_WAREHOUSE":
        if(!#defined(revision)) {
            AddBox(class'#var(prefix)CrateUnbreakableSmall', vectm(183.993530, 926.125000, 1162.103271));// apartment
            AddBox(class'#var(prefix)CrateUnbreakableMed', vectm(-389.361969, 744.039978, 1088.083618));// ladder
            AddBox(class'#var(prefix)CrateUnbreakableSmall', vectm(-328.287048, 767.875000, 1072.113770));
        }

        // this map is too hard
        Spawn(class'#var(prefix)AdaptiveArmor',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)AdaptiveArmor',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)BallisticArmor',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)BallisticArmor',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)FireExtinguisher',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)FireExtinguisher',,, GetRandomPositionFine());

        break;
    }
}
