class DXREvents extends DXREventsBase;


//#region WatchActors
function WatchActors()
{
    local #var(DeusExPrefix)Decoration d;

    foreach AllActors(class'#var(DeusExPrefix)Decoration', d) {
        if( #var(prefix)Lamp(d) != None
            || #var(prefix)PoolTableLight(d) != None
            || #var(prefix)HKMarketLight(d) != None
            || #var(prefix)ShopLight(d) != None
            || #var(prefix)HangingShopLight(d) != None
            || #var(prefix)Chandelier(d) != None
            || #var(prefix)Lightbulb(d) != None
            || #var(prefix)HKHangingLantern(d) != None
            || #var(prefix)HKHangingLantern2(d) != None)
        {
            AddWatchedActor(d,"LightVandalism");
        }
        else if(#var(prefix)Trophy(d) != None)
        {
            AddWatchedActor(d,"TrophyHunter");
        }
        else if(#var(prefix)SignFloor(d) != None)
        {
            AddWatchedActor(d,"SlippingHazard");
        }
        else if(#var(prefix)HangingChicken(d) != None
            || #var(prefix)HKHangingPig(d) != None)
        {
            AddWatchedActor(d,"BeatTheMeat");
        }
        else if(#var(prefix)BarrelVirus(d) != None)
        {
            AddWatchedActor(d,"WhyContainIt");
        }
        else if(#var(prefix)Mailbox(d) != None)
        {
            AddWatchedActor(d,"MailModels");
        }
        else if(#var(prefix)CigaretteMachine(d) != None)
        {
            AddWatchedActor(d,"SmokingKills");
        }
        else if(#var(prefix)Buoy(d) != None)
        {
            AddWatchedActor(d,"BuoyOhBuoy");
        }
        else if(#var(prefix)Flask(d) != None)
        {
            AddWatchedActor(d,"ASingleFlask");
        }
    }
}
//#endregion

//#region Phone Triggers
function AddPhoneTriggers(bool isRevision)
{
    local #var(prefix)Phone p;
    local #var(prefix)WHPhone wp;
#ifdef revision
    local RevPhone rp;
#endif
    local int i;

    //Spawn invisible phones for the payphones
    switch(dxr.localURL) {
    case "01_NYC_UNATCOISLAND":
        if (isRevision){
            p = Spawn(class'PayPhone',,,vectm(-3999.9, 9039,-222)); //South Dock
            p = Spawn(class'PayPhone',,,vectm(-3839.9, 9039, -222)); //South Dock
        }
        break;
    case "02_NYC_STREET":
        if (isRevision){
            p = Spawn(class'PayPhone',,,vectm(-1219.22, 776.7, -431.58)); //Outside Free Clinic
            p = Spawn(class'PayPhone',,,vectm(-1216.45, 1014.59, -431.58)); //Outside Free Clinic
            p = Spawn(class'PayPhone',,,vectm(3523, -3280.4, -431)); //Outside Nutella Store
            p = Spawn(class'PayPhone',,,vectm(3523, -3424.59, -431)); //Outside Nutella Store
            p = Spawn(class'PayPhone',,,vectm(3651, -1583.93, -435.40)); //Near bus stop
            p = Spawn(class'PayPhone',,,vectm(3651, -1763.33, -430.23)); //Near bus stop (Tipped over)
            p = Spawn(class'PayPhone',,,vectm(1952.04, 2508.99, -432.5)); //Near Osgoode and Son's
            p = Spawn(class'PayPhone',,,vectm(1599.67, 2508.99, -432.5)); //Near Osgoode and Son's
            //break;
        } else {
            p = Spawn(class'PayPhone',,,vectm(1117,1969,-430)); //Near Osgoode and Son's
            p = Spawn(class'PayPhone',,,vectm(-1314,944,-430)); //Near Free Clinic
        }
        break;
    case "04_NYC_STREET":
        if (isRevision){
            p = Spawn(class'PayPhone',,,vectm(-1219.22, 776.7, -431.58)); //Outside Free Clinic
            p = Spawn(class'PayPhone',,,vectm(-1216.45, 1014.59, -431.58)); //Outside Free Clinic
            p = Spawn(class'PayPhone',,,vectm(3523, -3280.4, -431)); //Outside Nutella Store
            p = Spawn(class'PayPhone',,,vectm(3523, -3424.59, -431)); //Outside Nutella Store
            p = Spawn(class'PayPhone',,,vectm(3676.9, -1577.22, -490.4)); //Near bus stop (Tipped Over)
            p = Spawn(class'PayPhone',,,vectm(3650, -1764.06, -430)); //Near bus stop (Tipped Over)
            p = Spawn(class'PayPhone',,,vectm(1949.62, 2509, -431)); //Near Osgoode and Son's
            p = Spawn(class'PayPhone',,,vectm(1597.67, 2509, -431)); //Near Osgoode and Son's
        } else {
            p = Spawn(class'PayPhone',,,vectm(1117,1969,-430)); //Near Osgoode and Son's
            p = Spawn(class'PayPhone',,,vectm(-1314,944,-430)); //Near Free Clinic
        }
        break;
    case "08_NYC_STREET":
        if (isRevision){
            p = Spawn(class'PayPhone',,,vectm(-1219.22, 776.7, -431.58)); //Outside Free Clinic
            p = Spawn(class'PayPhone',,,vectm(-1216.45, 1014.59, -431.58)); //Outside Free Clinic
            p = Spawn(class'PayPhone',,,vectm(3522, -3280, -431)); //Outside Nutella Store
            p = Spawn(class'PayPhone',,,vectm(3522, -3424.4, -431)); //Outside Nutella Store
            p = Spawn(class'PayPhone',,,vectm(3676.9, -1577.22, -490.4)); //Near bus stop (Tipped Over)
            p = Spawn(class'PayPhone',,,vectm(3650, -1764.06, -430)); //Near bus stop (Tipped Over)
            p = Spawn(class'PayPhone',,,vectm(1899.19, 2513.20, -486.25)); //Near Osgoode and Son's (Tipped over)
            p = Spawn(class'PayPhone',,,vectm(1592.46, 2495.74, -433.14)); //Near Osgoode and Son's (Tipped over)
        } else {
            p = Spawn(class'PayPhone',,,vectm(1117,1969,-430)); //Near Osgoode and Son's
            p = Spawn(class'PayPhone',,,vectm(-1314,944,-430)); //Near Free Clinic
        }
        break;
    case "02_NYC_BAR":
        if (isRevision){
            p = Spawn(class'PayPhone',,,vectm(-2667.1, 15.8, 75)); //Near the bathroom
            p = Spawn(class'PayPhone',,,vectm(-2667.1, -96.4, 75)); //Near the bathroom
        } else{
            p = Spawn(class'PayPhone',,,vectm(-2624,624,72)); //Near the bathroom
        }
        break;
    case "04_NYC_BAR":
        if (isRevision){
            p = Spawn(class'PayPhone',,,vectm(-2667.1, 15.8, 75)); //Near the bathroom
            p = Spawn(class'PayPhone',,,vectm(-2667.1, -96.4, 75)); //Near the bathroom
            p = Spawn(class'PayPhone',,,vectm(-2667.1, -40.4, 75)); //Near the bathroom
        } else{
            p = Spawn(class'PayPhone',,,vectm(-2624,624,72)); //Near the bathroom
        }
        break;
    case "08_NYC_BAR":
        if (isRevision){
            p = Spawn(class'PayPhone',,,vectm(-2667.1, 15.1, 74)); //Near the bathroom
            p = Spawn(class'PayPhone',,,vectm(-2667.1, -40.83, 74)); //Near the bathroom
            p = Spawn(class'PayPhone',,,vectm(-2667.1, -96.66, 74)); //Near the bathroom
        } else{
            p = Spawn(class'PayPhone',,,vectm(-2624,624,72)); //Near the bathroom
        }
        break;

    case "02_NYC_FREECLINIC":
    case "08_NYC_FREECLINIC":
        if (!isRevision){
            p = Spawn(class'PayPhone',,,vectm(-215,752,-254));  //In the front lobby
        } else {
            p = Spawn(class'PayPhone',,,vectm(-203.12, 752.87,-251.78));  //In the front lobby
        }
        break;

    case "02_NYC_BATTERYPARK":
        if (isRevision){
            p = Spawn(class'PayPhone',,,vectm(-2707.23, -171, 400)); //Near Shanty town
            p = Spawn(class'PayPhone',,,vectm(-3108.31, -171, 400)); //Near Shanty town
            p = Spawn(class'PayPhone',,,vectm(-3584.65, -171, 400)); //Near Shanty town
            p = Spawn(class'PayPhone',,,vectm(883, 639, 417.47)); //In Castle Clinton
            p = Spawn(class'PayPhone',,,vectm(882.97, 520, 415.65)); //In Castle Clinton
        }
        break;
    case "03_NYC_BATTERYPARK":
        if (isRevision){
            p = Spawn(class'PayPhone',,,vectm(-2708.68, -171, 400)); //Near Shanty town
            p = Spawn(class'PayPhone',,,vectm(-3108.13, -171, 400)); //Near Shanty town
        }
        break;
    case "04_NYC_BATTERYPARK":
        if (isRevision){
            p = Spawn(class'PayPhone',,,vectm(-2709.1, -171, 400)); //Near Shanty town
            p = Spawn(class'PayPhone',,,vectm(-3108.44, -171, 400)); //Near Shanty town
        }
        break;
    case "03_NYC_BROOKLYNBRIDGESTATION":
        if (!isRevision){
            p = Spawn(class'PayPhone',,,vectm(-660,-1854,435));  //Upper floor, near El Rey
            p = Spawn(class'PayPhone',,,vectm(-660,-1806,435));
        } else {
            p = Spawn(class'PayPhone',,,vectm(-669, -1855.67, 433.5));  //Upper floor, near El Rey
            p = Spawn(class'PayPhone',,,vectm(-669, -1807.72, 433.5));
        }
        break;
    case "04_NYC_NSFHQ":
        if (isRevision){
            p = Spawn(class'PayPhone',,,vectm(-1641.06, -4912.54, 80));  //Near Checkpoint
            p = Spawn(class'PayPhone',,,vectm(-1641.06, -5041.04, 80));
        }
        break;

    case "06_HONGKONG_WANCHAI_COMPOUND":
        if (isRevision){ //This map only exists in revision, but might as well check
            p = Spawn(class'PayPhone',,,vectm(-671.12, 2528.5, 84));  //Near Entrance
            p = Spawn(class'PayPhone',,,vectm(561.36, 2421, 84));  //Near Entrance
            p = Spawn(class'PayPhone',,,vectm(656.89, 2421, 84));  //Near Entrance
            p = Spawn(class'PayPhone',,,vectm(-465.27, 5266.2, 66.5));  //Covered Area
            p = Spawn(class'PayPhone',,,vectm(-465.27, 5218.72, 66.5));  //Covered Area
            p = Spawn(class'PayPhone',,,vectm(-1147, 4295.44, 66));  //Between Buildings
            p = Spawn(class'PayPhone',,,vectm(-1147, 4215.07, 66));  //Between Buildings
        }
        break;
    case "09_NYC_DOCKYARD":
        if (!isRevision){
            p=#var(prefix)Phone(Spawnm(class'#var(prefix)Phone',,,vect(2333,2153,53),rot(0,5688,0)));
        }
        break;

    case "10_PARIS_CATACOMBS_METRO":
        if (isRevision){ //Another Revision-only map
            p = Spawn(class'PayPhone',,,vectm(974.99, -2581.45, -555));  //In the ATM+ area
            p = Spawn(class'PayPhone',,,vectm(974.99, -2504.94, -553));
            //There might be two missing here, but I couldn't find them
        }
    case "11_PARIS_UNDERGROUND":
        if (isRevision){
            p = Spawn(class'PayPhone',,,vectm(620.99, 304.67, 15.75));
            p = Spawn(class'PayPhone',,,vectm(617, 464.96, 15.75));
        }
    }
    i=0;

    foreach AllActors(class'#var(prefix)Phone',p){
        switch(p.BindName){
            case "AI_phonecall_paris01":
                break; //Covered by the Icarus call flag - IcarusCalls_Played
            default:
                CreatePhoneTrigger(p,i);
                i++;
                break;
        }
    }
    foreach AllActors(class'#var(prefix)WHPhone',wp){
        switch(wp.BindName){
            case "AI_phonecall_paris01":
                break; //Covered by the Icarus call flag - IcarusCalls_Played
            default:
                CreatePhoneTrigger(wp,i);
                i++;
                break;
        }
    }
#ifdef revision
    foreach AllActors(class'RevPhone',rp){
        switch(rp.BindName){
            case "AI_phonecall_paris01":
                break; //Covered by the Icarus call flag - IcarusCalls_Played
            default:
                CreatePhoneTrigger(rp,i);
                i++;
                break;
        }
    }
#endif
}

function CreatePhoneTrigger(Actor phone, int num)
{
    local BingoTrigger bt;

    bt = class'BingoTrigger'.static.Create(self,'PhoneCall',phone.Location);
    bt.bDestroyOthers=False;
    bt.tag=StringToName("PhoneCall"$num);
    phone.event=StringToName("PhoneCall"$num);
}
//#endregion

//#region SetWatchFlags
function SetWatchFlags() {
    local #var(prefix)MapExit m;
    local #var(prefix)ChildMale child;
    local #var(prefix)Mechanic mechanic;
    local #var(prefix)JunkieFemale jf;
    local #var(prefix)GuntherHermann gunther;
    local #var(prefix)Mutt starr;// arms smuggler's dog in Paris
    local #var(prefix)Hooker1 h;  //Mercedes
    local #var(prefix)LowerClassFemale lcf; //Tessa
    local #var(prefix)JunkieMale jm;
    local #var(prefix)ScientistMale sm;
    local ZoneInfo zone;
    local #var(prefix)SkillAwardTrigger skillAward;
    local #var(DeusExPrefix)Mover dxm;
    local #var(prefix)LogicTrigger lTrigger;
    local WaterZone water;
    local #var(prefix)Toilet closestToilet;
    local #var(prefix)BookOpen book;
    local #var(prefix)FlagTrigger fTrigger;
    local #var(prefix)WIB wib;
    local #var(prefix)ComputerPersonal cp;
    local #var(prefix)Maid maid;
    local #var(prefix)Trigger trig;
    local BingoTrigger bt;
    local #var(prefix)LowerClassMale lcm;
    local #var(prefix)DamageTrigger dt;
    local #var(prefix)Poolball ball;
    local #var(prefix)DataLinkTrigger dlt;
    local #var(prefix)Female2 f;
    local #var(prefix)Fan1 fan1;
    local #var(prefix)Button1 button;
    local #var(prefix)VialCrack zyme;
    local #var(prefix)ControlPanel conPanel;
    local #var(prefix)SatelliteDish satDish;
    local Dispatcher disp;
    local int i;
    local DXRRaceTimerStart raceStart;
    local DXRRaceCheckPoint checkPoint;
    local OnceOnlyTrigger oot;

    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    //For debugging purposes - can probably remove later
    l("SetWatchFlags: Setting flag watches and bingo locations based on Revision maps? "$RevisionMaps);

    //General checks
    WatchActors();
    AddPhoneTriggers(RevisionMaps);

    switch(dxr.localURL) {
    //#region Training
    case "00_Training":
        raceStart = Spawn(class'DXRRaceTimerStart',,,vectm(-60,830,-40));
        raceStart.SetCollisionSize(150,100);
        raceStart.raceName="Training Section 1";
        raceStart.targetTime=120; //2:00

        checkPoint = Spawn(class'DXRRaceCheckPoint',,,vectm(4800,-4680,30));
        checkPoint.SetCollisionSize(100,100);
        raceStart.RegisterCheckpoint(checkPoint);
        break;
    case "00_TrainingCombat":
        raceStart = Spawn(class'DXRRaceTimerStart',,,vectm(-110,0,-50));
        raceStart.SetCollisionSize(100,100);
        raceStart.raceName="Training Section 2 (Combat)";
        raceStart.targetTime=150; //2:30

        checkPoint = Spawn(class'DXRRaceCheckPoint',,,vectm(4950,-250,-20));
        checkPoint.SetCollisionSize(100,100);
        raceStart.RegisterCheckpoint(checkPoint);
        break;
    case "00_TrainingFinal":
        WatchFlag('m00meetpage_Played');

        raceStart = Spawn(class'DXRRaceTimerStart',,,vectm(-200,-500,-50));
        raceStart.SetCollisionSize(100,100);
        raceStart.raceName="Training Section 3 (Final)";
        raceStart.targetTime=90; //1:30

        checkPoint = Spawn(class'DXRRaceCheckPoint',,,vectm(6575,-5700,100));
        checkPoint.SetCollisionSize(100,100);
        raceStart.RegisterCheckpoint(checkPoint);

        break;
    //#endregion

    //#region Mission 1
    case "01_NYC_UNATCOISLAND":
        WatchFlag('GuntherFreed');
        WatchFlag('GuntherRespectsPlayer');
        WatchFlag('StatueMissionComplete');

        foreach AllActors(class'#var(prefix)SkillAwardTrigger',skillAward) {
            if(skillAward.awardMessage=="Exploration Bonus" && skillAward.skillPointsAdded==50 && skillAward.Region.Zone.bWaterZone){
                skillAward.Event='SunkenShip';
                break;
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'SunkenShip',skillAward.Location);

        bt = class'BingoTrigger'.static.Create(self,'BackOfStatue',vectm(2503.605469,354.826355,2072.113037),40,40);
        bt = class'BingoTrigger'.static.Create(self,'BackOfStatue',vectm(2507.357178,-83.523094,2072.113037),40,40);

        class'BingoFrobber'.static.Create(self,"SATCOM Wiring",'CommsPit',vectm(-6467.026855,1464.081787,-208.328873),22,30,"You checked the SATCOM wiring");

        bt = class'BingoTrigger'.static.Create(self,'StatueHead',vectm(6250,109,504),800,40);

        //Triangle points
        bt = class'BingoTrigger'.static.Create(self,'LibertyPoints',vectm(7400,120,570),500,100);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'LibertyPoints',vectm(4100,-3650,570),500,100);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'LibertyPoints',vectm(1850,-3650,570),500,100);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'LibertyPoints',vectm(-920,-1135,570),500,100);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'LibertyPoints',vectm(-920,1390,570),500,100);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'LibertyPoints',vectm(1850,3900,570),500,100);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'LibertyPoints',vectm(4100,3900,570),500,100);
        bt.bDestroyOthers=False;
        //Square corners
        bt = class'BingoTrigger'.static.Create(self,'LibertyPoints',vectm(275,-2380,570),500,100);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'LibertyPoints',vectm(5670,-2380,570),500,100);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'LibertyPoints',vectm(5670,2640,570),500,100);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'LibertyPoints',vectm(275,2640,570),500,100);
        bt.bDestroyOthers=False;

        bt = class'BingoTrigger'.static.Create(self,'fork',vectm(0,0,0));
        bt.bingoEvent="ForkliftCertified";

        break;
    case "01_NYC_UNATCOHQ":
        WatchFlag('BathroomBarks_Played');
        WatchFlag('ManBathroomBarks_Played');
        if(RevisionMaps){
            bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1725,-1062,-40),95,40);
            class'BingoTrigger'.static.ProxCreate(self,'BathroomFlags',vectm(1130,-150,310),80,40,class'#var(prefix)FlagPole');
            class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-1032,447,588),20,10);
        } else {
            bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1551.508301,-820.408875,-39.901726),95,40);
            class'BingoTrigger'.static.ProxCreate(self,'BathroomFlags',vectm(240.180969,-385.104431,280.098511),80,40,class'#var(prefix)FlagPole');

            class'BingoTrigger'.static.PeepCreate(self,'un_bboard_peepedtex',vectm(497,1660,317.7),80,40);
            class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-945,343,568),20,10);
        }

        foreach AllActors(class'#var(prefix)Female2',f) {
            if(f.BindName == "Shannon"){
                f.bImportant = true;
                f.bInvincible = false;
            }
        }

        bt = class'BingoTrigger'.static.Create(self,'ManderleyMail',vectm(0,0,0));
        bt.Tag = 'holoswitch';

        bt = class'BingoTrigger'.static.Create(self,'LetMeIn',vectm(0,0,0));
        bt.Tag = 'retinal_msg_trigger';

        break;
    //#endregion

    //#region Mission 2
    case "02_NYC_BATTERYPARK":
        WatchFlag('JoshFed');
        WatchFlag('M02BillyDone');
        WatchFlag('AmbrosiaTagged');
        WatchFlag('MS_DL_Played', true);// this is the datalink played after dealing with the hostage situation, from Mission02.uc

        foreach AllActors(class'#var(prefix)ChildMale', child) {
            if(child.BindName == "Josh" || child.BindName == "Billy")
                child.bImportant = true;
        }

        foreach AllActors(class'#var(prefix)JunkieMale',jm) {
            if(jm.BindName == "SickMan"){
                jm.bImportant = true;
            }
        }

        foreach AllActors(class'#var(prefix)MapExit',m,'Boat_Exit'){
            m.Tag = 'Boat_Exit2';
        }
        Tag = 'Boat_Exit';  //this is a special case, since we do extra handling here

        foreach AllActors(class'#var(DeusExPrefix)Mover', dxm) {
            if (dxm.KeyIDNeeded=='CCSafe'){
                dxm.Event='CrackSafe';
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'CrackSafe',vectm(0,0,0));

        break;
    case "02_NYC_STREET":
        WatchFlag('AlleyBumRescued');
        WatchFlag('M02SallyDone');
        WatchFlag('MeetSandraRenton_Played');
        bt = class'BingoTrigger'.static.Create(self,GetKnicksTag(),vectm(0,0,0));
        bt.bingoEvent="MadeBasket";
        break;
    case "02_NYC_HOTEL":
        WatchFlag('M02HostagesRescued');// for the hotel, set by Mission02.uc
        WatchFlag('MaleHostageRescued_Played');
        bt = class'BingoTrigger'.static.Create(self,'TonThirdFloor',vectm(-630,-1955,424),150,40);

        break;
    case "02_NYC_UNDERGROUND":
        WatchFlag('FordSchickRescued');
        class'BingoTrigger'.static.ProxCreate(self,'SewerSurfin',vectm(-50,-125,-1000),750,40,class'#var(prefix)JoeGreeneCarcass');
        break;
    case "02_NYC_BAR":
        WatchFlag('JockSecondStory');
        WatchFlag('LeoToTheBar');
        WatchFlag('PlayPool');
        InitPoolBalls();
        WatchFlag('JordanSheaConvos_Played');
        WatchFlag('WorkerGivesInfo_Played');
        if (RevisionMaps) {
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(112,-2,242),40,20);  //Only one in Revision
        } else {
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(257,0,240),40,20);  //Front Door
            bt.bDestroyOthers = false;
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-2431,-258,240),40,20);  //Back Door
            bt.bDestroyOthers = false;
        }
        break;
    case "02_NYC_FREECLINIC":
        WatchFlag('BoughtClinicPlan');
        WatchFlag('MeetClinicOlderBum_Played');
        WatchFlag('MeetWindowBum_Played');
        break;
    case "02_NYC_SMUG":
        WatchFlag('MeetSmuggler_Played');
        bt = class'BingoTrigger'.static.Create(self,'botordertrigger',vectm(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'mirrordoor',vectm(0,0,0));
        bt.Tag = 'mirrordoorout';
        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'mirrordoor'){
            dxm.Event='mirrordoorout';
        }

        break;
    case "02_NYC_WAREHOUSE":
        foreach AllActors(class'#var(DeusExPrefix)Mover', dxm) {
            if (dxm.Name=='DeusExMover25'){
                dxm.Event='CrackSafe';
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'CrackSafe',vectm(0,0,0));

        // 3 triggers in a chain, like checkpoints to make sure you swim all the way through
        bt = class'BingoTrigger'.static.Create(self,'WarehouseSewerTunnel',vectm(-1348.603027, 211.117294, -459.900452),80,60);
        bt.bDestroyOthers = false;
        bt = class'BingoTrigger'.static.Create(self,'WarehouseSewerTunnel',vectm(-836.882141, -160.352020, -425.417816),60,60);
        bt.bDestroyOthers = false;
        bt = class'BingoTrigger'.static.Create(self,'WarehouseSewerTunnel',vectm(-19.620102, -866.462830, -403.896912),60,40);
        bt.bDestroyOthers = false;
        if (RevisionMaps) {
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(2048,1111,680),30,10);  //Only one in Revision
        }
        break;
    //#endregion

    //#region Mission 3
    case "03_NYC_BATTERYPARK":
        foreach AllActors(class'#var(prefix)JunkieMale',jm) {
            if(jm.BindName == "SickMan"){
                jm.bImportant = true;
            }
        }
        break;
    case "03_NYC_MOLEPEOPLE":
        WatchFlag('MolePeopleSlaughtered');
        bt = class'BingoTrigger'.static.Create(self,'surrender',vectm(0,0,0));
        bt = class'BingoTrigger'.static.CrouchCreate(self,'MolePeopleWater',vectm(0,-528,48),60,40);
        break;
    case "03_NYC_UNATCOISLAND":
        WatchFlag('DXREvents_LeftOnBoat');
        class'BingoFrobber'.static.Create(self,"SATCOM Wiring",'CommsPit',vectm(-6467.026855,1464.081787,-208.328873),22,30,"You checked the SATCOM wiring");

        break;
    case "03_NYC_UNATCOHQ":
        WatchFlag('SimonsAssassination');
        WatchFlag('MeetWalton_Played');
        WatchFlag('MeetInjuredTrooper2_Played');
        if(RevisionMaps){
            bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1725,-1062,-40),95,40);
            class'BingoTrigger'.static.ProxCreate(self,'BathroomFlags',vectm(1130,-150,310),80,40,class'#var(prefix)FlagPole');
            class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-1032,447,588),20,10);
        } else {
            bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1551.508301,-820.408875,-39.901726),95,40);
            class'BingoTrigger'.static.ProxCreate(self,'BathroomFlags',vectm(240.180969,-385.104431,280.098511),80,40,class'#var(prefix)FlagPole');

            class'BingoTrigger'.static.PeepCreate(self,'un_bboard_peepedtex',vectm(497,1660,317.7),80,40);
            class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-945,343,568),20,10);
        }

        foreach AllActors(class'#var(prefix)Female2',f) {
            if(f.BindName == "Shannon"){
                f.bImportant = true;
                f.bInvincible = false;
            }
        }

        bt = class'BingoTrigger'.static.Create(self,'ManderleyMail',vectm(0,0,0));
        bt.Tag = 'holoswitch';

        bt = class'BingoTrigger'.static.Create(self,'LetMeIn',vectm(0,0,0));
        bt.Tag = 'retinal_msg_trigger';

        break;
    case "03_NYC_AIRFIELD":
        WatchFlag('BoatDocksAmbrosia');
        bt = class'BingoTrigger'.static.Create(self,'arctrigger',vectm(0,0,0));

        bt = class'BingoTrigger'.static.Create(self,'AirfieldGuardTowers',vectm(5347.652344,-4286.462402,328),100,40);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'AirfieldGuardTowers',vectm(584.657654,-4306.718750,328),100,40);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'AirfieldGuardTowers',vectm(-2228.463379,-2148.080078,328),100,40);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'AirfieldGuardTowers',vectm(-2225.839600,3800.267578,328),100,40);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'AirfieldGuardTowers',vectm(5339.792969,3815.784912,328),100,40);
        bt.bDestroyOthers=False;

        break;
    case "03_NYC_AIRFIELDHELIBASE":
        WatchFlag('HelicopterBaseAmbrosia');
        WatchFlag('PlayPool');
        WatchFlag('OverhearLebedev_Played');
        InitPoolBalls();
        bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(1432,-177,136),20,10);

        break;
    case "03_NYC_HANGAR":
        RewatchFlag('747Ambrosia');
        if (RevisionMaps){
            bt = class'BingoTrigger'.static.CrouchCreate(self,'CherryPickerSeat',vectm(5300,815,140),20,20);
        }
        break;
    case "03_NYC_747":
        RewatchFlag('747Ambrosia');
        WatchFlag('MeetLebedev_Played');
        WatchFlag('PlayerKilledLebedev');
        WatchFlag('AnnaKilledLebedev');

        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'field001'){
            dxm.Event='SuspensionCrate';
        }
        bt = class'BingoTrigger'.static.Create(self,'SuspensionCrate',vectm(0,0,0));

        break;
    case "03_NYC_BROOKLYNBRIDGESTATION":
        WatchFlag('FreshWaterOpened');
        WatchFlag('ThugGang_AllianceDead');
        WatchFlag('DonDone');
        WatchFlag('LennyDone');
        if(RevisionMaps){
            WatchFlag('PlayPool');
            InitPoolBalls();
        }
        break;
    case "03_NYC_HANGAR":
        WatchFlag('NiceTerrorist_Dead');// only tweet it once, not like normal PawnDeaths

        foreach AllActors(class'#var(prefix)Mechanic', mechanic) {
            if(mechanic.BindName == "Harold")
                mechanic.bImportant = true;
        }
        break;
    //#endregion

    //#region Mission 4
    case "04_NYC_BAR":
        WatchFlag('LeoToTheBar');
        WatchFlag('PlayPool');
        InitPoolBalls();
        if (RevisionMaps) {
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(112,-2,242),40,20);  //Only one in Revision
        } else {
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(257,0,240),40,20);  //Front Door
            bt.bDestroyOthers = false;
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-2431,-258,240),40,20);  //Back Door
            bt.bDestroyOthers = false;
        }
        break;
    case "04_NYC_HOTEL":
        WatchFlag('GaveRentonGun');
        WatchFlag('FamilySquabbleWrapUpGilbertDead_Played');
        WatchFlag('M04PlayerLikesUNATCO_Played');
        bt = class'BingoTrigger'.static.Create(self,'TonThirdFloor',vectm(-630,-1955,424),150,40);
        break;
    case "04_NYC_UNDERGROUND":
        class'BingoTrigger'.static.ProxCreate(self,'SewerSurfin',vectm(-50,-125,-1000),750,40,class'#var(prefix)JoeGreeneCarcass');
        break;
    case "04_NYC_STREET":
        bt = class'BingoTrigger'.static.Create(self,GetKnicksTag(),vectm(0,0,0));
        bt.bingoEvent="MadeBasket";
        break;
    case "04_NYC_BATTERYPARK":
        bt = class'BingoTrigger'.static.Create(self,'MadeItToBP',vectm(0,0,0));
        break;
    case "04_NYC_SMUG":
        WatchFlag('M04MeetSmuggler_Played');
        bt = class'BingoTrigger'.static.Create(self,'botordertrigger',vectm(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'mirrordoor',vectm(0,0,0));
        bt.Tag = 'mirrordoorout';
        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'mirrordoor'){
            dxm.Event='mirrordoorout';
        }
        break;
    case "04_NYC_NSFHQ":
        WatchFlag('MostWarehouseTroopsDead');
        break;
    case "04_NYC_UNATCOHQ":
        WatchFlag('M04MeetWalton_Played');
        if(RevisionMaps){
            class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1725,-1062,-40),95,40);
            class'BingoTrigger'.static.ProxCreate(self,'BathroomFlags',vectm(1130,-150,310),80,40,class'#var(prefix)FlagPole');
            class'BingoTrigger'.static.ProxCreate(self,'PresentForManderley',vectm(960,234,297),350,60,class'#var(prefix)JuanLebedevCarcass');
            class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-1032,447,588),20,10);
        } else {
            class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1551.508301,-820.408875,-39.901726),95,40);
            class'BingoTrigger'.static.ProxCreate(self,'BathroomFlags',vectm(240.180969,-385.104431,280.098511),80,40,class'#var(prefix)FlagPole');
            class'BingoTrigger'.static.ProxCreate(self,'PresentForManderley',vectm(220,4,280),300,40,class'#var(prefix)JuanLebedevCarcass');

            class'BingoTrigger'.static.PeepCreate(self,'un_bboard_peepedtex',vectm(497,1660,317.7),80,40);
            class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-945,343,568),20,10);
        }

        foreach AllActors(class'#var(prefix)Female2',f) {
            if(f.BindName == "Shannon"){
                f.bImportant = true;
                f.bInvincible = false;
            }
        }

        bt = class'BingoTrigger'.static.Create(self,'ManderleyMail',vectm(0,0,0));
        bt.Tag = 'NoMessage';

        bt = class'BingoTrigger'.static.Create(self,'LetMeIn',vectm(0,0,0));
        bt.Tag = 'retinal_msg_trigger';

        break;
    case "04_NYC_UNATCOISLAND":
        WatchFlag('AnnaKilledLebedev'); //Fixup will set this if you get back to HQ without killing Anna or Juan
        class'BingoFrobber'.static.Create(self,"SATCOM Wiring",'CommsPit',vectm(-6467.026855,1464.081787,-208.328873),22,30,"You checked the SATCOM wiring");


        if (dxr.flagbase.GetBool('M03PlayerKilledAnna') && !dxr.flagbase.GetBool('JuanLebedev_Dead')) {
            MarkBingo("LebedevLived");
        }
        break;
    //#endregion

    //#region Mission 5
    case "05_NYC_UNATCOMJ12LAB":
        CheckPaul();
        WatchFlag('WatchKeys_cabinet');
        WatchFlag('MiguelLeaving');
        bt = class'BingoTrigger'.static.Create(self,'nanocage',vectm(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'botorders2',vectm(0,0,0));

        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'Beastdoor'){
            dxm.Event='KarkianDoorsBingo';
        }
        bt = class'BingoTrigger'.static.Create(self,'KarkianDoorsBingo',vectm(0,0,0));

        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'field002'){
            dxm.Event='SuspensionCrate';
        }
        bt = class'BingoTrigger'.static.Create(self,'SuspensionCrate',vectm(0,0,0));

        break;
    case "05_NYC_UNATCOHQ":
        WatchFlag('KnowsAnnasKillphrase1');
        WatchFlag('KnowsAnnasKillphrase2');
        WatchFlag('M05WaltonAlone_Played');
        WatchFlag('M05MeetManderley_Played');
        WatchFlag('M05MeetJaime_Played');

        foreach AllActors(class'#var(prefix)ComputerPersonal',cp){
            if (cp.Name=='ComputerPersonal7'){  //JC's computer
                for (i=0;i<4 && cp.specialOptions[i].Text!="";i++){}
                if (i<4){
                    cp.specialOptions[i].Text="Clear Browser History";
                    cp.specialOptions[i].TriggerText="Browser History Cleared!";
                    cp.specialOptions[i].bTriggerOnceOnly=True;
                    cp.specialOptions[i].TriggerEvent='BrowserHistoryCleared';
                    cp.specialOptions[i].UserName="JCD";
                }
                break;
            }
        }

        bt = class'BingoTrigger'.static.Create(self,'BrowserHistoryCleared',cp.Location);

        if(RevisionMaps){
            class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1725,-1062,-40),95,40);
            class'BingoTrigger'.static.ProxCreate(self,'BathroomFlags',vectm(1130,-150,310),80,40,class'#var(prefix)FlagPole');
            class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-1032,447,588),20,10);
        } else {
            class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1551.508301,-820.408875,-39.901726),95,40);
            class'BingoTrigger'.static.ProxCreate(self,'BathroomFlags',vectm(240.180969,-385.104431,280.098511),80,40,class'#var(prefix)FlagPole');

            class'BingoTrigger'.static.PeepCreate(self,'un_bboard_peepedtex',vectm(497,1660,317.7),80,40);
            class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-945,343,568),20,10);
        }

        foreach AllActors(class'#var(prefix)Female2',f) {
            if(f.BindName == "Shannon"){
                f.bImportant = true;
                f.bInvincible = false;
            }
        }

        bt = class'BingoTrigger'.static.Create(self,'ManderleyMail',vectm(0,0,0));
        bt.Tag = 'holoswitch';

        break;
    case "05_NYC_UNATCOISLAND":
        bt = class'BingoTrigger'.static.Create(self,'nsfwander',vectm(0,0,0));
        bt.Tag='SavedMiguel';

        class'BingoFrobber'.static.Create(self,"SATCOM Wiring",'CommsPit',vectm(-6467.026855,1464.081787,-208.328873),22,30,"You checked the SATCOM wiring");

        break;
    //#endregion

    //#region Mission 6
    case "06_HONGKONG_WANCHAI_CANAL":
        WatchFlag('FoundScientistBody');
        WatchFlag('M06BoughtVersaLife');
        WatchFlag('Canal_Bartender_Question4');

        foreach AllActors(class'#var(prefix)FlagTrigger',fTrigger,'FoundScientist') {
            // so you don't have to go right into the corner, default is 96, and 40 height
            fTrigger.SetCollisionSize(500, 160);
        }

        class'BingoFrobber'.static.Create(self,"Boat Equipment",'BoatEngineRoom',vectm(2304.4,3154.4,-365),30,35,"You checked the power levels");

        foreach AllActors(class'#var(prefix)LowerClassMale',lcm,'CanalDrugDealer'){
            break;
        }
        bt = class'BingoTrigger'.static.Create(self,'CanalDrugDeal',lcm.Location,200,40);

        foreach AllActors(class'#var(prefix)DamageTrigger',dt){
            if (dt.DamageType=='PoisonGas'){
                dt.Region.Zone.ZonePlayerEvent='ToxicShip';
                break;
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'ToxicShip',vectm(0,0,0));

        bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-1856,2060,-305),20,10); //Front Door
        bt.bDestroyOthers=false;
        bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-1856,2553,-305),20,10); //Kitchen Door
        bt.bDestroyOthers=false;


        break;
    case "06_HONGKONG_WANCHAI_UNDERWORLD":
        WatchFlag('ClubMercedesConvo1_Done');
        WatchFlag('M07ChenSecondGive_Played');
        WatchFlag('LDDPRussPaid');
        WatchFlag('LeoToTheBar');
        WatchFlag('PlayPool');
        WatchFlag('M06JCHasDate');
        WatchFlag('M06BartenderQuestion3');
        WatchFlag('Raid_Underway');

        foreach AllActors(class'#var(prefix)Hooker1', h) {
            if(h.BindName == "ClubMercedes")
                h.bImportant = true;
        }
        foreach AllActors(class'#var(prefix)LowerClassFemale', lcf) {
            if(lcf.BindName == "ClubTessa")
                lcf.bImportant = true;
        }

        bt = class'BingoTrigger'.static.Create(self,'EnterQuickStop',vectm(0,438,-267),180,40);
        bt = class'BingoTrigger'.static.Create(self,'EnterQuickStop',vectm(220,438,-267),180,40);
        bt = class'BingoTrigger'.static.Create(self,'EnterQuickStop',vectm(448,438,-267),180,40);

        bt = class'BingoTrigger'.static.Create(self,'LuckyMoneyFreezer',vectm(-1615,-2960,-343),200,40);
        bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-1024,-790,-231),20,10);

        foreach AllActors(class'#var(prefix)Poolball',ball){
            if (ball.Region.Zone.ZoneGroundFriction>1){
                ball.Destroy(); //There's at least one ball outside of the table.  Just destroy it for simplicity
            }
        }

        InitPoolBalls();
        BallsPerTable=14; //This table is missing some balls

        break;
    case "06_HONGKONG_WANCHAI_STREET":
        WatchFlag('M06PaidJunkie');

        //Find Jock's apartment door
        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm){
            if (dxm.KeyIDNeeded=='JocksKey'){
                break;
            }
        }

        //Find the nearest toilet
        closestToilet = #var(prefix)Toilet(findNearestToActor(class'#var(prefix)Toilet',dxm));

        closestToilet.Event='JocksToilet';
        bt = class'BingoTrigger'.static.Create(self,'JocksToilet',closestToilet.Location);

        foreach AllActors(class'#var(prefix)Maid',maid){
            maid.bImportant = True;
            maid.BarkBindName = "MaySung";
        }

        class'BingoTrigger'.static.Create(self,'TonnochiBillboard',vectm(0,550,870),300,40);

        class'BingoTrigger'.static.ProxCreate(self,'MaggieCanFly',vectm(-30,-1950,1400),600,40,class'#var(prefix)MaggieChowCarcass');
        bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-100,-1215,147),20,10); //Main Floor
        bt.bDestroyOthers=false;
        bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-1084,-1235,1832),20,10); //Under Construction Floor
        bt.bDestroyOthers=false;
        bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(927,-958,1295),20,10); //Over Jock's elevator
        bt.bDestroyOthers=false;
        bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(830,-1020,1270),20,10); //Next to Jock's elevator
        bt.bDestroyOthers=false;


        break;
    case "06_HONGKONG_WANCHAI_MARKET":
        WatchFlag('BeenToCops');

        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'station_door_05'){
            break;
        }

        skillAward = #var(prefix)SkillAwardTrigger(findNearestToActor(class'#var(prefix)SkillAwardTrigger',dxm));
        skillAward.Event='PoliceVaultBingo';
        bt = class'BingoTrigger'.static.Create(self,'PoliceVaultBingo',skillAward.Location);

        bt = class'BingoTrigger'.static.Create(self,'WanChaiStores',vectm(445,-1032,24),80,40);  //Pottery Store
        bt.Tag='WanChaiPottery';
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'WanChaiStores',vectm(640,-1093,200),100,40);  //Tea House
        bt.Tag='WanChaiTea';
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'WanChaiStores',vectm(-6,-1416,40),250,40);  //Butcher (Louis Pan works for him too)
        bt.Tag='WanChaiButcher';
        bt.bDestroyOthers=False;
        if (RevisionMaps){
            bt = class'BingoTrigger'.static.Create(self,'WanChaiStores',vectm(1040,-266,40),100,40);  //Souvenir Shop
            bt.Tag='WanChaiSouvenir';
            bt.bDestroyOthers=False;
        } else {
            bt = class'BingoTrigger'.static.Create(self,'WanChaiStores',vectm(910,-643,40),150,40);  //News Stand
            bt.Tag='WanChaiNews';
            bt.bDestroyOthers=False;
            bt = class'BingoTrigger'.static.Create(self,'WanChaiStores',vectm(632,-532,40),130,40);  //Flower Shop
            bt.Tag='WanChaiFlowers';
            bt.bDestroyOthers=False;
        }

        break;
    case "06_HONGKONG_TONGBASE":
        WatchFlag('M07MeetJaime_Played');
        foreach AllActors(class'WaterZone', water) {
            water.ZonePlayerEvent = 'TongsHotTub';
            break;
        }
        bt = class'BingoTrigger'.static.Create(self,'TongsHotTub',water.Location);

        //Need to make sure these are slightly out of the wall so that explosions hit them
        class'BingoTrigger'.static.ShootCreate(self,'TongTargets',vectm(-596.3,1826,40),40,100);
        class'BingoTrigger'.static.ShootCreate(self,'TongTargets',vectm(-466.5,1826,40),40,100);
        class'BingoTrigger'.static.ShootCreate(self,'TongTargets',vectm(-337.2,1826,40),40,100);

        WatchFlag('PaulToTong');

        break;
    case "06_HONGKONG_HELIBASE":
        bt = class'BingoTrigger'.static.Create(self,'purge',vectm(0,0,0));

        foreach AllActors(class'#var(prefix)Trigger',trig){
            if (trig.classProximityType==class'Basketball'){
                break;
            }
        }
        class'BingoTrigger'.static.ProxCreate(self,'HongKongBBall',trig.Location,14,3,class'#var(prefix)Basketball');
        bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-1832,-81,536),20,10);

        foreach AllActors(class'#var(DeusExPrefix)Mover', dxm, 'DeusExMover') {
            switch(dxm.Name) {
            case 'DeusExMover26':
                dxm.Event = 'M06HeliSafe1';
                bt = class'BingoTrigger'.static.Create(self,'M06HeliSafe1',dxm.Location);
                bt.bingoEvent = "M06HeliSafe";
                bt.bDestroyOthers = false;
                break;
            case 'DeusExMover31':
                dxm.Event = 'M06HeliSafe2';
                bt = class'BingoTrigger'.static.Create(self,'M06HeliSafe2',dxm.Location);
                bt.bingoEvent = "M06HeliSafe";
                bt.bDestroyOthers = false;
                break;
            }
        }

        break;
    case "06_HONGKONG_MJ12LAB":
        foreach AllActors(class'ZoneInfo',zone){
            if (class'DXRStoredZoneInfo'.static.IsFogZone(zone)){
                zone.ZonePlayerEvent = 'HongKongGrays';
                break;
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'HongKongGrays',zone.Location);

        WatchFlag('FlowersForTheLab');
        break;

    case "06_HONGKONG_STORAGE":
        WatchFlag('FlowersForTheLab');
        break;

    case "06_HONGKONG_VERSALIFE":
        WatchFlag('Supervisor_Paid');
        bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(207,575,-15),20,10);
        break;
    case "06_HONGKONG_WANCHAI_GARAGE":
        if (RevisionMaps){
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-572,-463,-23),20,10);
        } else {
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-572,-335,-23),20,10);
        }
        break;
    //#endregion

    //#region Mission 8
    case "08_NYC_STREET":
        bt = class'BingoTrigger'.static.Create(self,GetKnicksTag(),vectm(0,0,0));
        bt.bingoEvent="MadeBasket";
        WatchFlag('StantonAmbushDefeated');
        WatchFlag('GreenKnowsAboutDowd');
        MarkBingo("MaggieLived", true);
        break;
    case "08_NYC_SMUG":
        WatchFlag('M08WarnedSmuggler');
        WatchFlag('M08SmugglerConvos_Played');
        bt = class'BingoTrigger'.static.Create(self,'botordertrigger',vectm(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'mirrordoor',vectm(0,0,0));
        bt.Tag = 'mirrordoorout';
        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'mirrordoor'){
            dxm.Event='mirrordoorout';
        }
        break;
    case "08_NYC_BAR":
        WatchFlag('LeoToTheBar');
        WatchFlag('PlayPool');
        WatchFlag('GreenKnowsAboutDowd');
        WatchFlag('SheaKnowsAboutDowd');
        InitPoolBalls();
        if (RevisionMaps) {
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(112,-2,242),40,20);  //Only one in Revision
        } else {
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(257,0,240),40,20);  //Front Door
            bt.bDestroyOthers = false;
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-2431,-258,240),40,20);  //Back Door
            bt.bDestroyOthers = false;
        }

        break;
    case "08_NYC_HOTEL":
        class'BingoTrigger'.static.Create(self,'TonThirdFloor',vectm(-630,-1955,424),150,40);
        WatchFlag('GreenKnowsAboutDowd');
        break;
    case "08_NYC_UNDERGROUND":
        WatchFlag('GreenKnowsAboutDowd');
        class'BingoTrigger'.static.ProxCreate(self,'SewerSurfin',vectm(-50,-125,-1000),750,40,class'#var(prefix)JoeGreeneCarcass');
        break;
    case "08_NYC_FREECLINIC":
        WatchFlag('GreenKnowsAboutDowd');
        break;
    //#endregion

    //#region Mission 9
    case "09_NYC_DOCKYARD":
        ReportMissingFlag('M08WarnedSmuggler', "SmugglerDied");

        bt = class'BingoTrigger'.static.Create(self,'DockBlastDoors',vectm(0,0,0));
        bt.Tag = 'BlastDoor1';
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'DockBlastDoors',vectm(0,0,0));
        bt.Tag = 'BlastDoor2';
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'DockBlastDoors',vectm(0,0,0));
        bt.Tag = 'BlastDoor3';
        bt.bDestroyOthers=False;

        foreach AllActors(class'#var(DeusExPrefix)Mover', dxm) {
            if (dxm.Name=='DeusExMover25'){
                dxm.Event='CrackSafe';
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'CrackSafe',vectm(0,0,0));

        bt = class'BingoTrigger'.static.Create(self,'DockyardLaser',vectm(0,0,0));
        bt.Tag = 'TunnelTrigger';
        bt.bDestroyOthers=False;
        bt.bUntrigger=True;

        bt = class'BingoTrigger'.static.Create(self,'DockyardLaser',vectm(0,0,0));
        bt.Tag = 'WarehouseTunnel';
        bt.bDestroyOthers=False;
        bt.bUntrigger=True;

        bt = class'BingoTrigger'.static.Create(self,'DockyardLaser',vectm(0,0,0));
        bt.Tag = 'AmmoTunnel';
        bt.bDestroyOthers=False;
        bt.bUntrigger=True;

        bt = class'BingoTrigger'.static.Create(self,'DockyardTrailer',vectm(-733,1760,125),55,40);
        bt = class'BingoTrigger'.static.Create(self,'DockyardTrailer',vectm(-733,1970,125),55,40);
        bt = class'BingoTrigger'.static.Create(self,'DockyardTrailer',vectm(545,2920,63),55,40);

        break;
    case "09_NYC_SHIP":
        bt = class'BingoTrigger'.static.Create(self,'CraneControls',vectm(3264,-1211,1222));
        bt.Tag = 'Crane';

        bt = class'BingoTrigger'.static.Create(self,'CraneTop',vectm(1937,0,1438),100,40);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'CraneTop',vectm(-1791,1082,1423),100,40);
        bt.bDestroyOthers=False;

        bt = class'BingoTrigger'.static.Create(self,'CaptainBed',vectm(2887,58,960),30,40);

        bt = class'BingoTrigger'.static.Create(self,'ShipsBridge',vectm(1892,120,936),200,40);

        foreach AllActors(class'#var(DeusExPrefix)Mover', dxm) {
            if (dxm.Name=='DeusExMover25'){
                dxm.Event='CrackSafe';
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'CrackSafe',vectm(0,0,0));

        bt = class'BingoTrigger'.static.Create(self,'ShipRamp',vectm(0,0,0));

        bt = class'BingoTrigger'.static.Create(self,'SuperfreighterProp',vectm(2969,78,-1120),225,225);

        bt = class'BingoTrigger'.static.Create(self,'Titanic',vectm(-3555,110,360),100,40);

        break;
    case "09_NYC_SHIPFAN":
        bt = class'BingoTrigger'.static.Create(self,'SpinningRoom',vectm(0,0,0));
        foreach AllActors(class'ZoneInfo', zone) {
            if (zone.DamageType=='Burned'){
                zone.ZonePlayerEvent = 'SpinningRoom';
            }
        }

        bt = class'BingoTrigger'.static.Create(self,'BiggestFan',vectm(0,0,0));
        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm){
            if (dxm.RotationRate.Yaw!=0){
                dxm.Event='BiggestFan';
                break;
            }
        }

        break;
    case "09_NYC_SHIPBELOW":
        WatchFlag('ShipPowerCut');// sparks of electricity come off that thing like lightning!
        bt = class'BingoTrigger'.static.Create(self,'FanTop',vectm(-2935,50,840),200,50);

        WatchFlag('WatchKeys_Locker1');
        WatchFlag('WatchKeys_Locker2');

        bt = class'BingoTrigger'.static.Create(self,'FreighterHelipad',vectm(-5516,142,-180),500,40);
        bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-993,-60,-80),40,20);
        break;

        break;
    case "09_NYC_GRAVEYARD":
        WatchFlag('GaveDowdAmbrosia');

        foreach AllActors(class'#var(DeusExPrefix)Mover', dxm) {
            if (dxm.Name=='DeusExMover25'){
                dxm.Event='CrackSafe';
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'CrackSafe',vectm(0,0,0));

        break;
    //#endregion

    //#region Mission 10
    case "10_PARIS_ENTRANCE": //A Revision-only map that covers where you start in Paris and ends after the radioactive room (and the underground section right after it)
        foreach AllActors(class'#var(prefix)JunkieFemale', jf) {
            if(jf.BindName == "aimee")
                jf.bImportant = true;
        }

        bt = class'BingoTrigger'.static.Create(self,'roof_elevator',vect(0,0,0));

        break;
    case "10_PARIS_CATACOMBS":
        WatchFlag('IcarusCalls_Played');
        foreach AllActors(class'#var(prefix)JunkieFemale', jf) {
            if(jf.BindName == "aimee")
                jf.bImportant = true;
        }

        bt = class'BingoTrigger'.static.Create(self,'WarehouseEntered',vectm(-580.607361,-2248.497803,-551.895874),200,160);
        bt = class'BingoTrigger'.static.Create(self,'roof_elevator',vect(0,0,0));
        break;
    case "10_PARIS_CATACOMBS_TUNNELS":
        foreach AllActors(class'#var(prefix)WIB',wib){
            if(wib.BindName=="Hela")
                wib.bImportant = true;
        }
        WatchFlag('SilhouetteHostagesAllRescued');
        MarkBingo("AimeeLeMerchantLived", true);

        //Regular forwards direction catacombs timing
        if (RevisionMaps){
            raceStart = Spawn(class'DXRRaceTimerStart',,,vectm(-3287,-2270,555));
        } else {
            raceStart = Spawn(class'DXRRaceTimerStart',,,vectm(-2580,-2250,100));
        }
        raceStart.raceName="Catacombs";
        raceStart.SetCollisionSize(60,80);
        raceStart.targetTime=90; //Under 1 minute (around 55ish seconds) is possible if you really blast it

        checkPoint = Spawn(class'DXRRaceCheckPoint',,,vectm(2775,-3785,-450)); //Lines up for both
        checkPoint.SetCollisionSize(100,80);
        raceStart.RegisterCheckpoint(checkPoint);

        //Going backwards through catacombs
        raceStart = Spawn(class'DXRRaceTimerStart',,,vectm(2775,-3785,-450));
        raceStart.raceName="Reverse Catacombs";
        raceStart.SetCollisionSize(100,80);
        raceStart.targetTime=60; //Under 1 minute (around 55ish seconds) is possible forwards if you really blast it

        if (RevisionMaps){
            checkPoint = Spawn(class'DXRRaceCheckPoint',,,vectm(-3287,-2270,555));
        } else {
            checkPoint = Spawn(class'DXRRaceCheckPoint',,,vectm(-2580,-2250,100));
        }
        checkPoint.SetCollisionSize(60,80);
        raceStart.RegisterCheckpoint(checkPoint);

        break;
    case "10_PARIS_METRO":
        WatchFlag('M10EnteredBakery');
        WatchFlag('AlleyCopSeesPlayer_Played');
        WatchFlag('assassinapartment');
        WatchFlag('MeetRenault_Played');
        WatchFlag('JoshuaInterrupted_Played');
        RewatchFlag('KnowsGuntherKillphrase');

        foreach AllActors(class'#var(prefix)Mutt', starr) {
            starr.bImportant = true;// you're important to me
            starr.BindName = "Starr";
        }
        if(RevisionMaps){
            class'BingoTrigger'.static.ProxCreate(self,'Cremation',vectm(217,-5306,328),50,40,class'#var(prefix)ChefCarcass');
        } else {
            class'BingoTrigger'.static.ProxCreate(self,'Cremation',vectm(-2983.597168,774.217407,312.100128),70,40,class'#var(prefix)ChefCarcass');
            class'BingoTrigger'.static.ProxCreate(self,'Cremation',vectm(-2984.404785,662.764954,312.100128),70,40,class'#var(prefix)ChefCarcass');
        }

        // SoldRenaultZyme
        bt = class'BingoTrigger'.static.Create(self,'SoldRenaultZyme', vectm(1953,2195,159));
        bt.bTriggerOnceOnly = false;
        bt.SetFinishedFlag('RenaultPaid', 6);
        foreach AllActors(class'#var(prefix)VialCrack', zyme) {
            if(zyme.name == 'VialCrack1' || zyme.name == 'VialCrack3') {
                zyme.bIsSecretGoal = true;
            }
        }
        break;
    case "10_PARIS_CLUB":
        WatchFlag('CamilleConvosDone');

        //Achille only counts if you're female
        if (dxr.flagbase.GetBool('LDDPJCIsFemale')) {
            WatchFlag('LDDPAchilleDone');
        }
        WatchFlag('LeoToTheBar');
        WatchFlag('LouisBerates');
        RewatchFlag('KnowsGuntherKillphrase');
        if (RevisionMaps){
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(2016,785,144),40,20);  //Actual Front Door
            bt.bDestroyOthers = false;
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(255,-305,80),40,10);  //Front Door
            bt.bDestroyOthers = false;
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-2140,-528,-56),20,10);  //Back Door
            bt.bDestroyOthers = false;

        } else {
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(2064,595,144),40,20);  //Actual Front Door
            bt.bDestroyOthers = false;
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(290,-32,128),40,20);  //Front Door
            bt.bDestroyOthers = false;
            bt=class'BingoTrigger'.static.PeepCreate(self,'EmergencyExit',vectm(-2140,-528,-72),20,10);  //Back Door
            bt.bDestroyOthers = false;
        }

        break;
    case "10_PARIS_CHATEAU":
        WatchFlag('ChateauInComputerRoom');
        WatchFlag('ChateauInBethsRoom');
        WatchFlag('ChateauInNicolettesRoom');

        //Nicolette's House Tour
        WatchFlag('NicoletteInUnderground_Played');
        WatchFlag('NicoletteInUnderground2_Played');
        WatchFlag('NicoletteInStudy_Played');
        WatchFlag('NicoletteInLivingRoom_Played');
        WatchFlag('NicoletteInKeyRoom_Played');
        WatchFlag('NicoletteInGarden_Played');
        WatchFlag('NicoletteInGarden2_Played');
        WatchFlag('NicoletteInBethsRoom_Played');

        //NanoKeys
        WatchFlag('WatchKeys_beth_room');
        WatchFlag('WatchKeys_nico_room');
        WatchFlag('WatchKeys_duclare_chateau');

        bt = class'BingoTrigger'.static.Create(self,'nico_fireplace',vectm(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'dumbwaiter',vectm(0,0,0));

        bt = class'BingoTrigger'.static.Create(self,'BethsPainting',vectm(0,0,0));
        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm){
            if (dxm.Name=='DeusExMover8'){
                dxm.Event='BethsPainting';
            }
        }

        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'field002'){
            dxm.Event='SuspensionCrate';
        }
        bt = class'BingoTrigger'.static.Create(self,'SuspensionCrate',vectm(0,0,0));

        raceStart = Spawn(class'DXRRaceTimerStart',,'ChateauKeyRaceStart');
        raceStart.raceName="the Chateau DuClare key hunt";

        oot = Spawn(class'OnceOnlyTrigger',, 'ChateauKeyRaceStartOnce');
        oot.Event = 'ChateauKeyRaceStart';

        trig = Spawn(class'#var(prefix)Trigger',,,vectm(15,60,150)); //Front Door
        trig.Event='ChateauKeyRaceStartOnce';

        trig = Spawn(class'#var(prefix)Trigger',,,vectm(175,60,150)); //Front Door
        trig.Event='ChateauKeyRaceStartOnce';

        trig = Spawn(class'#var(prefix)Trigger',,,vectm(-560,-1280,120)); //Back Door
        trig.Event='ChateauKeyRaceStartOnce';

        checkPoint = Spawn(class'DXRRaceCheckPoint',,,vectm(1375,1200,-200));
        checkPoint.SetCollisionSize(80,80);
        raceStart.RegisterCheckpoint(checkPoint);

        break;
    //#endregion

    //#region Mission 11
    case "11_PARIS_CATHEDRAL":
        WatchFlag('GuntherKillswitch');
        WatchFlag('DL_gold_found_Played');
        WatchFlag('M11WaltonHolo_Played');

        if (RevisionMaps){
            class'BingoTrigger'.static.Create(self,'CathedralUnderwater',vectm(2614,-2103,-120),500,180);
            class'BingoTrigger'.static.ProxCreate(self,'Cremation',vectm(3811,-3200,-64),20,15,class'#var(prefix)ChefCarcass');
            class'BingoTrigger'.static.ProxCreate(self,'Cremation',vectm(3869,-4256,-64),20,15,class'#var(prefix)ChefCarcass');
            class'BingoTrigger'.static.ProxCreate(self,'Cremation',vectm(3387,-3233,-7.9),50,40,class'#var(prefix)ChefCarcass');
            class'BingoTrigger'.static.ProxCreate(self,'Cremation',vectm(4100,-3469,-6.9),50,40,class'#var(prefix)ChefCarcass');

            class'BingoTrigger'.static.CrouchCreate(self,'IOnceKnelt',vectm(3650,-1090,265),450,40);
        } else {
            class'BingoTrigger'.static.Create(self,'CathedralUnderwater',vectm(771,-808,-706),500,180);
            class'BingoTrigger'.static.ProxCreate(self,'Cremation',vectm(2019,-2256,-704),20,15,class'#var(prefix)ChefCarcass');
            class'BingoTrigger'.static.ProxCreate(self,'Cremation',vectm(2076.885254,-3248.189941,-704.369995),20,15,class'#var(prefix)ChefCarcass');
            class'BingoTrigger'.static.ProxCreate(self,'Cremation',vectm(1578,-2286,-647),50,40,class'#var(prefix)ChefCarcass');

            class'BingoTrigger'.static.CrouchCreate(self,'IOnceKnelt',vectm(1830,-140,-375),450,40);
        }
        bt = class'BingoTrigger'.static.Create(self,'secretdoor01',vectm(0,0,0));

        bt = class'BingoTrigger'.static.Create(self,'CathedralDisplayCase',vectm(-6335,305,-565),40,40);
        bt = class'BingoTrigger'.static.Create(self,'CathedralDisplayCase',vectm(-6428,305,-565),40,40);


        foreach AllActors(class'#var(prefix)DataLinkTrigger',dlt){
            if (dlt.datalinkTag=='DL_knightslibrary'){
                bt = class'BingoTrigger'.static.Create(self,'CathedralLibrary',dlt.Location,dlt.CollisionRadius,dlt.CollisionHeight);
            }
        }

        break;
    case "11_PARIS_EVERETT":
        WatchFlag('GotHelicopterInfo');
        WatchFlag('MeetAI4_Played');
        WatchFlag('DeBeersDead');

        foreach AllActors(class'WaterZone',water){
            water.ZonePlayerEvent = 'EverettAquarium';
            break;
        }
        bt = class'BingoTrigger'.static.Create(self,'EverettAquarium',water.Location);

        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'field001'){
            dxm.Event='SuspensionCrate';
        }
        bt = class'BingoTrigger'.static.Create(self,'SuspensionCrate',vectm(0,0,0));
        bt.bDestroyOthers=False;

        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'field002'){
            dxm.Event='SuspensionCrate';
        }
        bt = class'BingoTrigger'.static.Create(self,'SuspensionCrate',vectm(0,0,0));
        bt.bDestroyOthers=False;

        break;
    case "11_PARIS_UNDERGROUND":
        foreach AllActors(class'ZoneInfo',zone){
            if (zone.bPainZone && zone.DamageType=='Shocked'){
                //zone.ZonePlayerEvent = 'TrainTracks';
                //The ZonePlayerEvent only gets triggered here if you crouch, since I guess
                //it's based on your Location, rather than collision?  We'll use the location of the
                //ZoneInfo for our new BingoTrigger still though.
                break;
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'TrainTracks',zone.Location,3000,1);
        break;
    //#endregion

    //#region Mission 12
    case "12_VANDENBERG_GAS":
        WatchFlag('TiffanyHeli');
        bt = class'BingoTrigger'.static.Create(self,'support1',vectm(0,0,0)); //This gets hit when you blow up the gas pumps
        if (RevisionMaps){
            bt = class'BingoTrigger'.static.Create(self,'GasStationCeiling',vectm(1222,1078,-700),150,10);
            class'BingoFrobber'.static.Create(self,"Cash Register",'GasCashRegister',vectm(992.049377,922.186157,-905.889954),18,16,"You checked the cash register");
        } else {
            bt = class'BingoTrigger'.static.Create(self,'GasStationCeiling',vectm(984,528,-700),150,10);
            class'BingoFrobber'.static.Create(self,"Cash Register",'GasCashRegister',vectm(751.841187,370.094513,-903.900024),18,16,"You checked the cash register");
        }
        break;
    case "12_VANDENBERG_CMD":
        WatchFlag('MeetTimBaker_Played');
        foreach AllActors(class'#var(prefix)ScientistMale', sm) {
            if (sm.BindName=="TimBaker"){
                sm.bImportant = true;
            }
        }

        bt = class'BingoTrigger'.static.Create(self,'bunker_door1',vectm(0,0,0));
        bt.bingoEvent = "ActivateVandenbergBots";
        bt = class'BingoTrigger'.static.Create(self,'bunker_door2',vectm(50,0,0));
        bt.bingoEvent = "ActivateVandenbergBots";

        foreach AllActors(class'#var(prefix)Toilet',closestToilet){
            closestToilet.Event='VandenbergToilet';
        }
        bt = class'BingoTrigger'.static.Create(self,'VandenbergToilet',vectm(150,0,0));

        bt = class'BingoTrigger'.static.Create(self,'VandenbergWaterTower',vectm(-1030,80,-1600),350,40);

        class'BingoTrigger'.static.ProxCreate(self,'CliffSacrifice',vectm(1915,2795,-3900),10000,40,class'#var(DeusExPrefix)Carcass');

        class'BingoTrigger'.static.ProxCreate(self,'CliffSacrifice',vectm(-190,-1350,-2760),8000,40,class'#var(DeusExPrefix)Carcass');

        bt = class'BingoTrigger'.static.Create(self,'VandenbergShaft',vectm(1442.694580,1303.784180,-1755),110,10);

        class'BingoTrigger'.static.ShootCreate(self,'VandenbergAntenna',vectm(1800,2590,395),40,40);

        bt = class'BingoTrigger'.static.Create(self,'VandenbergHazLab',vectm(0,0,0));
        bt.bUntrigger=True;
        bt.Tag='lab_water';

        foreach AllActors(class'WaterZone', water) {
            if (RevisionMaps && water.Name=='WaterZone2'){
                water.ZonePlayerEvent = 'VandenbergGasSwim';
            } else if (!RevisionMaps && water.Name=='WaterZone0'){
                water.ZonePlayerEvent = 'VandenbergGasSwim';
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'VandenbergGasSwim',vectm(0,0,0));


        break;
    case "12_VANDENBERG_TUNNELS":
        WatchFlag('WatchKeys_maintenancekey');
        bt = class'BingoTrigger'.static.Create(self,'VandenbergReactorRoom',vectm(-1427,3287,-2985),500,100);

        if(RevisionMaps){
            bt = class'BingoTrigger'.static.Create(self,'waataaa',vectm(0,0,0));
            bt.bingoEvent="ForkliftCertified";
        }
        break;
    case "12_VANDENBERG_COMPUTER":
        bt = class'BingoTrigger'.static.Create(self,'VandenbergServerRoom',vectm(940,2635,-1320),200,40);

        bt = class'BingoTrigger'.static.Create(self,'EnterUC',vectm(1135,2360,-2138),40,40);

        foreach AllActors(class'#var(prefix)ControlPanel',conPanel){
            bt = class'BingoTrigger'.static.Create(self,'VandenbergComputerElec',conPanel.Location);
            bt.Tag=conPanel.name;
            bt.bDestroyOthers=False;
            conPanel.event=conPanel.name;
        }

        break;
    //#endregion

    //#region Mission 14
    case "14_OCEANLAB_SILO":
        WatchFlag('MeetDrBernard_Played');
        foreach AllActors(class'#var(prefix)ScientistMale', sm) {
            if (sm.BindName=="drbernard"){
                sm.bImportant = true;
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'SiloWaterTower',vectm(-1212,-3427,1992),240,40);
        bt = class'BingoTrigger'.static.Create(self,'SiloAttic',vectm(-2060,-6270,1825),200,40);

        bt = class'BingoTrigger'.static.CrouchCreate(self,'CherryPickerSeat',vectm(-17,-6461,-500),20,20);

        raceStart = Spawn(class'DXRRaceTimerStart',,,vectm(23,-4072,390));
        raceStart.raceName="The Silo's Secret Slide";
        raceStart.targetTime=5; //6.1ish seconds if you run through with full leg health, 5 is "impressive"
        raceStart.finishBingoGoal="SiloSlide";
        raceStart.SetCollisionSize(raceStart.CollisionRadius,10);

        checkPoint = Spawn(class'DXRRaceCheckPoint',,,vectm(25,-6316,-768));
        checkPoint.SetCollisionSize(checkPoint.CollisionRadius,80);
        raceStart.RegisterCheckpoint(checkPoint);

        break;
    case "14_OCEANLAB_LAB":
        WatchFlag('DL_Flooded_Played');
        RewatchFlag('WaltonShowdown_Played');
        WatchFlag('DL_SecondDoors_Played');

        bt = class'BingoTrigger'.static.Create(self,'OceanLabCrewChamber',vectm(1932.035522,3334.331787,-2247.888184),60,40);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'OceanLabCrewChamber',vectm(1932.035522,3334.331787,-2507.888184),60,40);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'OceanLabCrewChamber',vectm(1928.762573,3721.919189,-2507.888184),60,40);
        bt.bDestroyOthers=False;
        if (RevisionMaps){
            bt = class'BingoTrigger'.static.Create(self,'OceanLabCrewChamber',vectm(2056,3825,-2212),75,80);
            bt.bDestroyOthers=False;
        } else {
            bt = class'BingoTrigger'.static.Create(self,'OceanLabCrewChamber',vectm(1928.762573,3721.919189,-2247.888184),60,40);
            bt.bDestroyOthers=False;
        }
        bt = class'BingoTrigger'.static.Create(self,'OceanLabGreenBeacon',vectm(1543,3522,-1847),200,200);

        bt = class'BingoTrigger'.static.Create(self,'OceanLabFloodedStoreRoom',vectm(-540,360,-1745),150,40);

        bt = class'BingoTrigger'.static.Create(self,'OceanLabMedBay',vectm(2395,425,-1745),225,80);



        break;
    case "14_OCEANLAB_UC":
        WatchFlag('LeoToTheBar');
        WatchFlag('PageTaunt_Played');
        RewatchFlag('WaltonShowdown_Played');
        bt = class'BingoTrigger'.static.Create(self,'EnterUC',vectm(860,6758,-3175),40,40);

        foreach AllActors(class'#var(prefix)Fan1',fan1){
            AddWatchedActor(fan1,"UCVentilation");
        }
        break;
    case "14_VANDENBERG_SUB":
        RewatchFlag('WaltonShowdown_Played');

        //Same location in Revision and Vanilla
        bt = class'BingoTrigger'.static.Create(self,'OceanLabShed',vectm(618.923523,4063.243896,-391.901031),160,40);

        //Put a shootable bingo trigger on every satellite dish in the level.  In Revision, this includes an extra tower with dishes
        foreach AllActors(class'#var(prefix)SatelliteDish', satDish) {
            class'BingoTrigger'.static.ShootCreate(self,'SubBaseSatellite',satDish.Location,satDish.CollisionRadius+5,satDish.CollisionHeight+5);
        }
        break;
    //#endregion

    //#region Mission 15
    case "15_AREA51_BUNKER":
        WatchFlag('JockBlewUp');
        WatchFlag('blast_door_open');
        RewatchFlag('WaltonBadass_Played');
        WatchFlag('MeetScaredSoldier_Played');

        foreach AllActors(class'ZoneInfo', zone) {
            if (zone.Tag=='fan'){
                zone.ZonePlayerEvent = 'Area51FanShaft';
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'Area51FanShaft',vectm(0,0,0));

        //This flag trigger actually doesn't trigger because a security computer can only trigger DeusExMovers
        foreach AllActors(class'#var(prefix)FlagTrigger',fTrigger,'blast_door'){
            fTrigger.Tag = 'blast_door_flag';
        }
        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'blast_door'){
            dxm.Event = 'blast_door_flag';
        }

        //Need to make sure this only triggers if you hit the button to actually power on the elevator
        //(and not if hit by the new trigger added in DXRFixupM15 at the bottom of the elevator for backtracking)
        disp = Spawn(class'Dispatcher',,'power_dispatcher_middle');
        disp.OutEvents[0]='power_dispatcher';
        disp.OutDelays[0]=0;
        disp.OutEvents[1]='power_dispatcher_bingo';
        disp.OutDelays[1]=0;

        //call 'power_dispatcher' and 'power_dispatcher_bingo'
        bt = class'BingoTrigger'.static.Create(self,'power_dispatcher_bingo',vectm(0,0,0));
        bt.bingoEvent = "Area51ElevatorPower";

        foreach AllActors(class'#var(prefix)Button1',button){
            if (button.Event=='power_dispatcher'){
                button.Event = 'power_dispatcher_middle';
                break;
            }
        }

        bt = class'BingoTrigger'.static.Create(self,'A51CommBuildingBasement',vectm(984,2788,-750),100,40);

        break;
    case "15_AREA51_ENTRANCE":
        WatchFlag('PlayPool');
        RewatchFlag('WaltonBadass_Played');
        InitPoolBalls();

        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm){
            if (dxm.tag=='chamber1'){
                dxm.event='sleeppod1';
            } else if (dxm.tag=='chamber3'){
                dxm.event='sleeppod2';
            } else if (dxm.tag=='chamber4'){
                dxm.event='sleeppod3';
            } else if (dxm.tag=='chamber5'){
                dxm.event='sleeppod4';
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'sleeppod1',vectm(0,0,0));
        bt.bingoEvent = "Area51SleepingPod";
        bt.bDestroyOthers=False;

        bt = class'BingoTrigger'.static.Create(self,'sleeppod2',vectm(0,0,0));
        bt.bingoEvent = "Area51SleepingPod";
        bt.bDestroyOthers=False;

        bt = class'BingoTrigger'.static.Create(self,'sleeppod3',vectm(0,0,0));
        bt.bingoEvent = "Area51SleepingPod";
        bt.bDestroyOthers=False;

        bt = class'BingoTrigger'.static.Create(self,'sleeppod4',vectm(0,0,0));
        bt.bingoEvent = "Area51SleepingPod";
        bt.bDestroyOthers=False;


        bt = class'BingoTrigger'.static.Create(self,'steam1',vectm(0,0,0));
        bt.bingoEvent = "Area51SteamValve";
        bt.bDestroyOthers=False;

        bt = class'BingoTrigger'.static.Create(self,'Steam2',vectm(0,0,0));
        bt.bingoEvent = "Area51SteamValve";
        bt.bDestroyOthers=False;

        if (RevisionMaps){
            bt = class'BingoTrigger'.static.CrouchCreate(self,'CherryPickerSeat',vectm(-625,15,-135),20,20);
        } else {
            bt = class'BingoTrigger'.static.CrouchCreate(self,'CherryPickerSeat',vectm(-72,1392,-123),20,20);
        }

        break;
    case "15_AREA51_FINAL":
        RewatchFlag('WaltonBadass_Played');
        foreach AllActors(class'#var(prefix)BookOpen', book) {
            if (book.textTag == '15_Book01'){ //This copy of Jacob's Shadow is also in _BUNKER and _ENTRANCE
                book.textTag = '15_Book02';  //Put that good Thursday man back where he (probably) belongs
            }
        }

        bt = class'BingoTrigger'.static.Create(self,'HeliosControlArms',vectm(-3995,2458,128),250,40);
        bt = class'BingoTrigger'.static.Create(self,'HeliosControlArms',vectm(-3995,2458,-123),250,40);
        bt = class'BingoTrigger'.static.Create(self,'HeliosControlArms',vectm(-3995,2458,-392),250,40);
        bt = class'BingoTrigger'.static.Create(self,'HeliosControlArms',vectm(-3995,2458,-902),250,40);
        bt = class'BingoTrigger'.static.Create(self,'HeliosControlArms',vectm(-3995,2458,-1152),250,40);
        bt = class'BingoTrigger'.static.Create(self,'HeliosControlArms',vectm(-3995,2458,-1413),250,40);

        bt = class'BingoTrigger'.static.Create(self,'A51ExplosiveLocker',vectm(-5845,-385,-1485),150,40);

        foreach AllActors(class'WaterZone', water) {
            if (RevisionMaps && water.Name=='WaterZone3'){ //Revision has a second tank
                water.ZonePlayerEvent = 'A51SeparationSwim';
            } else if (water.Name=='WaterZone2'){
                water.ZonePlayerEvent = 'A51SeparationSwim';
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'A51SeparationSwim',vectm(0,0,0));

        bt = class'BingoTrigger'.static.Create(self,'forks',vectm(0,0,0));
        bt.bingoEvent="ForkliftCertified";

        break;
    case "15_AREA51_PAGE":
#ifdef vanilla
        foreach AllActors(class'WaterZone', water) {
            if (water.Name=='WaterZone5'){// in GMDX v10 and Revision it's WaterZone0
                water.ZonePlayerEvent = 'unbirth';
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'unbirth',vectm(0,0,0));
#endif
        bt = class'BingoTrigger'.static.Create(self,'Set_flag_helios',vectm(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'coolant_switch',vectm(0,0,0));

        bt = class'BingoTrigger'.static.Create(self,'BlueFusionReactors',vectm(0,0,0));
        bt.Tag='node1';
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'BlueFusionReactors',vectm(0,0,0));
        bt.Tag='node2';
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'BlueFusionReactors',vectm(0,0,0));
        bt.Tag='node3';
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'BlueFusionReactors',vectm(0,0,0));
        bt.Tag='node4';
        bt.bDestroyOthers=False;

        bt = class'BingoTrigger'.static.Create(self,'A51UCBlocked',vectm(0,0,0));
        bt.Tag='UC_shutdoor1';
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'A51UCBlocked',vectm(0,0,0));
        bt.Tag='UC_shutdoor2';
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'A51UCBlocked',vectm(0,0,0));
        bt.Tag='UC_shutdoor3';
        bt.bDestroyOthers=False;

        bt = class'BingoTrigger'.static.Create(self,'EnterUC',vectm(5743,-9272,-5578),40,40);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'EnterUC',vectm(8628,-7267,-5970),40,40);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'EnterUC',vectm(7235,-8823,-5134),40,40);
        bt.bDestroyOthers=False;

        break;
    //#endregion
    }
}

function bool FailIfCorpseNotHeld(class<#var(DeusExPrefix)Carcass> carcClass, string goal)
{
    local #var(PlayerPawn) p;

    p = player();
    if (POVCorpse(p.inHand) == None || string(carcClass) != POVCorpse(p.inHand).carcClassString) {
        MarkBingoAsFailed(goal);
        return true;
    }
    return false;
}

//#region Special Bingo Failures
function MarkBingoFailedSpecial()
{
    local int progress, maxProgress;
    local PlayerDataItem data;

    if (dxr.flags.IsEntranceRando()) return; // TODO: a couple here would be marked correctly in Entrance Rando modes

    data = class'PlayerDataItem'.static.GiveItem(player());

    switch (dxr.localURL) {
    case "02_NYC_BATTERYPARK":
    case "03_NYC_UNATCOISLAND":
    case "03_NYC_BATTERYPARK":
        FailIfCorpseNotHeld(class'#var(prefix)TerroristCommanderCarcass', "LeoToTheBar");
        break;
    case "04_NYC_UNATCOISLAND":
        FailIfCorpseNotHeld(class'#var(prefix)TerroristCommanderCarcass', "LeoToTheBar");
        // the last Terrorist left is Miguel
        progress = data.GetBingoProgress("Terrorist_ClassDead", maxProgress);
        if (maxProgress - progress > 1) {
            MarkBingoAsFailed("Terrorist_ClassDead");
        }
        progress = data.GetBingoProgress("Terrorist_ClassUnconscious", maxProgress);
        if (maxProgress - progress > 1) {
            MarkBingoAsFailed("Terrorist_ClassUnconscious");
        }

        break;
    case "04_NYC_STREET":
    case "05_NYC_UNATCOMJ12Lab":
        FailIfCorpseNotHeld(class'#var(prefix)TerroristCommanderCarcass', "LeoToTheBar");
        break;
    case "06_HONGKONG_HELIBASE":
        FailIfCorpseNotHeld(class'#var(prefix)TerroristCommanderCarcass', "LeoToTheBar");
        FailIfCorpseNotHeld(class'#var(prefix)PaulDentonCarcass', "PaulToTong");
        break;
    case "08_NYC_STREET":
    case "09_NYC_DOCKYARD":
        FailIfCorpseNotHeld(class'#var(prefix)TerroristCommanderCarcass', "LeoToTheBar");
        break;
    case "09_NYC_GRAVEYARD":
        FailIfCorpseNotHeld(class'#var(prefix)TerroristCommanderCarcass', "LeoToTheBar");
        if (! HasItem(player(), class'VialAmbrosia')) {
            MarkBingoAsFailed("GaveDowdAmbrosia");
        }
        MarkBingoAsFailed("ChangeClothes");
        break;
    case "11_PARIS_EVERETT":
        if(dxr.flags.IsReducedRando()) {
            FailIfCorpseNotHeld(class'#var(prefix)TerroristCommanderCarcass', "LeoToTheBar");
        }
        break;
    case "10_PARIS_CATACOMBS":
    case "12_VANDENBERG_CMD":
        FailIfCorpseNotHeld(class'#var(prefix)TerroristCommanderCarcass', "LeoToTheBar");
        break;
    }

    switch (dxr.dxInfo.missionNumber) {
    case 6:
        if (dxr.flagbase.GetBool('Have_ROM')) {
            MarkBingoAsFailed("MarketKid_PlayerDead");
            MarkBingoAsFailed("MarketKid_PlayerUnconscious");
        }
        break;
    }
}
//#endregion

simulated function AnyEntry()
{
    local Conversation conv;
    local ConEvent ce;
    local ConChoice choice;

    Super.AnyEntry();

    switch(dxr.localURL) {
    case "10_PARIS_METRO":
        // SoldRenaultZyme bingo goal issue #705
        conv = GetConversation('RenaultPays');
        // add trigger for BingoTrigger event SoldRenaultZyme (Paying 50)
        ce = conv.GetEventFromLabel("SellRepeat");
        ce = NewConEvent(conv, ce, class'ConEventTrigger');
        ce.eventType = ET_Trigger;// no clean way to pass enums from other classes
        ConEventTrigger(ce).triggerTag = 'SoldRenaultZyme';
        // add trigger for BingoTrigger event SoldRenaultZyme (Paying 65)
        ce = conv.GetEventFromLabel("MoreMoney3");
        ce = NewConEvent(conv, ce, class'ConEventTrigger');
        ce.eventType = ET_Trigger;// no clean way to pass enums from other classes
        ConEventTrigger(ce).triggerTag = 'SoldRenaultZyme';
        // remove the event with label Sell which checks for the RenaultPaid flag
        RemoveConvEventByLabel(conv, "Sell");

        // remove the flag checks for entering the bakery, since you can get zyme from other places
        ce = conv.GetEventFromLabel("ActualChoice");
        for(choice = ConEventChoice(ce).ChoiceList; choice != None; choice = choice.nextChoice) {
            DeleteChoiceFlag(choice, 'M10EnteredBakery', true);
        }
        break;
    case "05_NYC_UNATCOISLAND":
        //Add a trigger event to hit the SavedMiguel bingo trigger
        conv = GetConversation('MiguelHack');
        ce = conv.GetEventFromLabel("Hop");
        ce = NewConEvent(conv, ce, class'ConEventTrigger');
        ce.eventType = ET_Trigger;
        ConEventTrigger(ce).triggerTag = 'SavedMiguel';
        break;
    }
}

function name GetKnicksTag() {
    local #var(prefix)FlagTrigger ft;

    foreach AllActors(class'#var(prefix)FlagTrigger',ft) {
        if (ft.Event=='MadeBasketM' || ft.Event=='MadeBasketF') {
            if (dxr.flagbase.GetBool('LDDPJCIsFemale')) {
                return 'MadeBasketF';
            } else {
                return 'MadeBasketM';
            }
        }
    }
    return 'MadeBasket';
}

function CheckPaul() {
    if( dxr.flagbase.GetBool('PaulDenton_Dead') ) {
        if( ! dxr.flagbase.GetBool('DXREvents_PaulDead'))
            PaulDied(dxr);
    } else if( ! #defined(vanilla)) {
        SavedPaul(dxr, dxr.player);
    }
}

simulated function bool WatchGuntherKillSwitch()
{
    local GuntherHermann gunther;

    foreach AllActors(class'GuntherHermann',gunther){
        if (gunther.GetStateName()=='KillswitchActivated'){
            return True;
        }
    };
    return False;
}

//#region TweakBingoDescription
//If there are any situational changes (Eg. Male/Female), adjust the description here
simulated function string tweakBingoDescription(string event, string desc)
{
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    switch(event){
        //FemJC gets a male character instead.  Russ normally, Noah in Revision
        case "ClubEntryPaid":
           if (dxr.flagbase.GetBool('LDDPJCIsFemale')) {
#ifdef revision
               return "Let Noah help";
#else
               return "Let Russ help";
#endif
           } else {
               return desc;
           }

            break;
        case "CamilleConvosDone":
            if (dxr.flagbase.GetBool('LDDPJCIsFemale')) {
                return "Get info from Achille";
            } else {
                return desc;
            }
        default:
            return desc;
            break;
    }
}
//#endregion

//#region ReadText
function ReadText(name textTag)
{
    local string eventname;
    local string flagEvent;
    local PlayerDataItem data;
    local DXRPasswords pws;

    l("ReadText "$textTag);

    switch(textTag) {
    // groups of textTags, we need separate tracking for which have been read and which haven't, before incrementing the bingo progress
    case '01_Bulletin05':
    case '01_Bulletin06':
    case '01_Bulletin07':
    case '01_Bulletin08':
    case '03_Bulletin01':
    case '03_Bulletin02':
        eventname = "KnowYourEnemy";
        break;

    case '02_Book03':
    case '03_Book04':
    case '04_Book03':
    case '06_Book03':
    case '09_Book02':
    case '10_Book02':
    case '12_Book01':
    case '15_Book01':
        eventname = "JacobsShadow";
        break;

    case '02_Book05':
    case '03_Book05':
    case '04_Book05':
    case '10_Book03':
    case '12_Book02':
    case '14_Book04':
    case '15_Book02':
        eventname = "ManWhoWasThursday";
        break;

    case '01_Newspaper06':
    case '01_Newspaper08':
    case '02_Newspaper06':
    case '03_Newspaper02':
    case '08_Newspaper01':
        eventname = "GreeneArticles";
        break;

    case '02_Newspaper03':
    case '03_Newspaper01':
    case '06_Newspaper02':
        eventname="MoonBaseNews";
        break;

    case '15_Datacube02':
    case '15_Datacube03':
    case '15_Datacube04':
    case '15_Datacube05':
    case 'CloneCube1':
    case 'CloneCube2':
    case 'CloneCube3':
    case 'CloneCube4':
        eventname="CloneCubes";
        break;

    case '01_Book01':
    case '01_Book02':
    case '01_Book03':
    case '01_Book04':
    case '01_Book05':
    case '01_Book06':
    case '01_Book07':
    case '01_Book08':
        eventname="UNATCOHandbook";
        break;

    case '06_Book04':
    case '10_Book06':
        eventname="JoyOfCooking";
        break;

    case 'JennysNumber':
        eventname = "8675309";
        flagEvent="09_NYC_DOCKYARD--796967769"; //So the web side doesn't need adjustment (yet)
        break;


    case '06_Datacube05':// Maggie Chow's bday
        eventname = "July 18th";
        flagEvent="06_Datacube05";
        break;

    default:
        // HACK: because names normally can't have hyphens? convert to string and use that instead
        switch(string(textTag)){
            case "09_NYC_DOCKYARD--796967769":
            case "JennysNumber":
                eventname = "8675309";
                flagEvent="09_NYC_DOCKYARD--796967769";
                break;
            case "15_AREA51_PAGE--32904306":
            case "15_AREA51_PAGE--1066683761":
            case "15_AREA51_PAGE--1790818418":
            case "15_AREA51_PAGE--26631873":
                eventname="CloneCubes";
                break;
        }
        if(eventname == "") {
            // it's simple for a bingo event that requires reading just 1 thing
            _MarkBingo(textTag);
            return;
        }
    }

    if(flagEvent!="" && eventname != "") {
        pws = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
        if(pws != None)
            pws.ProcessString(eventname);
        SendFlagEvent(flagEvent, false, eventname);
    }

    data = class'PlayerDataItem'.static.GiveItem(player());

    if(data.MarkRead(textTag)) {
        _MarkBingo(eventname);
    }
}
//#endregion

//#region ban goals by flags
simulated function _CreateBingoBoard(PlayerDataItem data, int starting_map, int bingo_duration, optional bool bTest)
{
    local int starting_mission, end_mission, real_duration;
    local float loge_duration, medbots, repairbots, merchants;

    starting_mission = class'DXRStartMap'.static.GetStartMapMission(starting_map);
    end_mission = class'DXRStartMap'.static.GetEndMission(starting_map, bingo_duration);
    real_duration = class'DXRStartMap'.static.SquishMission(end_mission) - class'DXRStartMap'.static.SquishMission(starting_mission) + 1;

    loge_duration = Loge(real_duration + 1.71828); // real_duration of 1 means 1 loge_duration, full game is 2.689090 loge_duration
    medbots = dxr.flags.settings.medbots;
    if(medbots <= -1) medbots = 30;
    medbots *= loge_duration;

    repairbots = dxr.flags.settings.repairbots;
    if(repairbots <= -1) repairbots = 30;
    repairbots *= loge_duration;

    // https://github.com/Die4Ever/deus-ex-randomizer/issues/1095
    if(medbots < 20 || repairbots < 20) {
        data.BanGoal("MedicalBot_ClassDead", 1);
        data.BanGoal("RepairBot_ClassDead", 1);
    } else {
        data.BanGoal("UtilityBot_ClassDead", 1);
    }

    merchants = dxr.flags.settings.merchants * loge_duration;
    if(merchants < 20) data.BanGoal("DXRNPCs1_PlayerDead", 1);

    if (medbots < 20 ||
#ifndef hx
        dxr.flags.settings.CombatDifficulty > 6 ||
#endif
        dxr.flags.settings.medkits < 50 ||
        dxr.flags.settings.health < 75) {
        data.BanGoal("JustAFleshWound", 1);
        data.BanGoal("LostLimbs", 1);
    }

#ifndef hx
    if (dxr.flags.settings.CombatDifficulty > 6) {
        data.BanGoal("ExtinguishFire",1);
    }
#endif

    Super._CreateBingoBoard(data, starting_map, bingo_duration, bTest);
}
//#endregion

//#region RemapBingoEvent
function string RemapBingoEvent(string eventname)
{
    ///////////////////////////////////////////////////////
    ////  MAKE SURE YOU DON'T FALL THROUGH YOUR CASE!  ////
    ///////////////////////////////////////////////////////

    switch(eventname) {
        case "ManBathroomBarks_Played":
            return "BathroomBarks_Played";// LDDP
        case "hostage_female_Dead":
        case "hostage_Dead":
            return "paris_hostage_Dead";
        case "KnowsAnnasKillphrase1":
        case "KnowsAnnasKillphrase2":
            return "KnowsAnnasKillphrase";
        case "SecurityBot3_ClassDead":
        case "SecurityBot4_ClassDead":
        case "DXRSecurityBot4_ClassDead":
            return "SecurityBotSmall_ClassDead";
        case "SpiderBot2_ClassDead":
            return "SpiderBot_ClassDead";
        case "LDDPRussPaid":
        case "ClubMercedesConvo1_Done":
            return "ClubEntryPaid";
        case "LDDPAchilleDone":
            return "CamilleConvosDone";
        case "KarkianBaby_ClassDead":
            return "Karkian_ClassDead";
        case "AmbrosiaTagged":
        case "BoatDocksAmbrosia":
        case "HelicopterBaseAmbrosia":
        case "747Ambrosia":
            return "StolenAmbrosia";
        case "PlayerKilledLebedev":
            //Check to make sure he wasn't knocked out
            if (dxr.flagbase.GetBool('JuanLebedev_Unconscious')) {
                return ""; //Don't mark this event if knocked out
            }
            return "PlayerKilledLebedev";
        case "UNATCOClone1_ClassDead":
        case "UNATCOClone2_ClassDead":
        case "UNATCOClone3_ClassDead":
        case "UNATCOClone4_ClassDead":
        case "UNATCOCloneAugTough1_ClassDead":
        case "UNATCOCloneAugStealth1_ClassDead":
        case "UNATCOCloneAugShield1_ClassDead":
            return "UNATCOTroop_ClassDead";
        case "NSFClone1_ClassDead":
        case "NSFClone2_ClassDead":
        case "NSFClone3_ClassDead":
        case "NSFClone4_ClassDead":
        case "NSFCloneAugTough1_ClassDead":
        case "NSFCloneAugStealth1_ClassDead":
        case "NSFCloneAugShield1_ClassDead":
            return "Terrorist_ClassDead";
        case "MJ12Clone1_ClassDead":
        case "MJ12Clone2_ClassDead":
        case "MJ12Clone3_ClassDead":
        case "MJ12Clone4_ClassDead":
        case "MJ12CloneAugTough1_ClassDead":
        case "MJ12CloneAugStealth1_ClassDead":
        case "MJ12CloneAugShield1_ClassDead":
            return "MJ12Troop_ClassDead";
        case "UNATCOClone1_ClassUnconscious":
        case "UNATCOClone2_ClassUnconscious":
        case "UNATCOClone3_ClassUnconscious":
        case "UNATCOClone4_ClassUnconscious":
        case "UNATCOCloneAugTough1_ClassUnconscious":
        case "UNATCOCloneAugStealth1_ClassUnconscious":
        case "UNATCOCloneAugShield1_ClassUnconscious":
            return "UNATCOTroop_ClassUnconscious";
        case "NSFClone1_ClassUnconscious":
        case "NSFClone2_ClassUnconscious":
        case "NSFClone3_ClassUnconscious":
        case "NSFClone4_ClassUnconscious":
        case "NSFCloneAugTough1_ClassUnconscious":
        case "NSFCloneAugStealth1_ClassUnconscious":
        case "NSFCloneAugShield1_ClassUnconscious":
            return "Terrorist_ClassUnconscious";
        case "MJ12Clone1_ClassUnconscious":
        case "MJ12Clone2_ClassUnconscious":
        case "MJ12Clone3_ClassUnconscious":
        case "MJ12Clone4_ClassUnconscious":
        case "MJ12CloneAugTough1_ClassUnconscious":
        case "MJ12CloneAugStealth1_ClassUnconscious":
        case "MJ12CloneAugShield1_ClassUnconscious":
            return "MJ12Troop_ClassUnconscious";
        case "DXRMedicalBot_ClassDead":
        case "MedicalBot_ClassDead":
            _MarkBingo("UtilityBot_ClassDead"); //Split into another event, but still return this one as-is
            return "MedicalBot_ClassDead";
        case "DXRRepairBot_ClassDead":
        case "RepairBot_ClassDead":
            _MarkBingo("UtilityBot_ClassDead"); //Split into another event, but still return this one as-is
            return "RepairBot_ClassDead";
        case "FrenchGray_ClassDead":
        case "GrayBaby_ClassDead":
            return "Gray_ClassDead";
        case "LiquorBottle_Activated":
        case "Liquor40oz_Activated":
        case "WineBottle_Activated":
            return "DrinkAlcohol";
        case "Pigeon_ClassDead":
        case "Seagull_ClassDead":
            return "PerformBurder";
        case "Fish_ClassDead":
        case "Fish2_ClassDead":
            return "GoneFishing";
        case "ChateauInBethsRoom":
        case "ChateauInNicolettesRoom":
            return "DuClareBedrooms";
        case "NSFClone1_peeptime":
        case "NSFClone2_peeptime":
        case "NSFClone3_peeptime":
        case "NSFClone4_peeptime":
        case "NSFCloneAugTough1_peeptime":
        case "NSFCloneAugStealth1_peeptime":
        case "NSFCloneAugShield1_peeptime":
            return "Terrorist_peeptime";
        case "UNATCOClone1_peeptime":
        case "UNATCOClone2_peeptime":
        case "UNATCOClone3_peeptime":
        case "UNATCOClone4_peeptime":
        case "UNATCOCloneAugTough1_peeptime":
        case "UNATCOCloneAugStealth1_peeptime":
        case "UNATCOCloneAugShield1_peeptime":
            return "UNATCOTroop_peeptime";
        case "MJ12Clone1_peeptime":
        case "MJ12Clone2_peeptime":
        case "MJ12Clone3_peeptime":
        case "MJ12Clone4_peeptime":
        case "MJ12CloneAugTough1_peeptime":
        case "MJ12CloneAugStealth1_peeptime":
        case "MJ12CloneAugShield1_peeptime":
            return "MJ12Troop_peeptime";
        case "Pigeon_peeptime":
        case "Seagull_peeptime":
            return "BirdWatching";
        case "ImageOpened_TiffanyHostagePicture":
        case "ImageOpened_JoeGreeneMIBMJ12":
        case "ImageOpened_TerroristCommander":
        case "ImageOpened_MilleniumMagazine":
            return "ViewPortraits";
        case "ImageOpened_BlueFusionDevice":
        case "ImageOpened_UniversalConstructorComponent":
            return "ViewSchematics";
        case "ImageOpened_Area51Sector4":
        case "ImageOpened_Area51Sector3":
        case "ImageOpened_Area51Bunker":
        case "ImageOpened_OceanLab":
        case "ImageOpened_VandenbergSub":
        case "ImageOpened_VandenbergCommandComplex":
        case "ImageOpened_ParisCathedral":
        case "ImageOpened_ParisMetroMap":
        case "ImageOpened_ParisCatacombsTunnels":
        case "ImageOpened_PCRSWallCloudUpperDecks":
        case "ImageOpened_PCRSWallCloudLowerDecks":
        case "ImageOpened_HongKongWanChaiDistrict":
        case "ImageOpened_VersalifeBuilding":
        case "ImageOpened_MJ12HelipadFacility":
        case "ImageOpened_HongKongMarket":
        case "ImageOpened_MJ12LabFacility":
        case "ImageOpened_HongKongMJ12LabFacility":
        case "ImageOpened_NYCAirfield":
        case "ImageOpened_747Diagram":
        case "ImageOpened_NYCWarehouse":
        case "ImageOpened_LibertyIslandSatellitePhoto":
            return "ViewMaps";
        case "ImageOpened_GrayDisection":
        case "ImageOpened_GreaselDisection":
            return "ViewDissection";
        case "ImageOpened_CathedralEntrance":
        case "ImageOpened_ParisCatacombs":
        case "ImageOpened_NSFHeadquarters":
            return "ViewTouristPics";
        case "01_EmailMenu_JCD":
        case "03_EmailMenu_JCD":
        case "04_EmailMenu_JCD":
        case "05_EmailMenu_JCD":
        case "06_EmailMenu_JCDenton":
            return "ReadJCEmail";
        case "NicoletteInUnderground_Played":
        case "NicoletteInUnderground2_Played":
        case "NicoletteInStudy_Played":
        case "NicoletteInLivingRoom_Played":
        case "NicoletteInKeyRoom_Played":
        case "NicoletteInGarden_Played":
        case "NicoletteInGarden2_Played":
        case "NicoletteInBethsRoom_Played":
            return "NicoletteHouseTour";
        case "WatchKeys_beth_room":
        case "WatchKeys_nico_room":
        case "WatchKeys_duclare_chateau":
            return "DuClareKeys";
        case "WatchKeys_Locker1":
        case "WatchKeys_Locker2":
            return "ShipLockerKeys";
        case "TechSergeantKaplan_PlayerDead":
        case "Mole_PlayerDead":
        case "JordanShea_PlayerDead":
        case "Doctor1_PlayerDead":
        case "Doctor2_PlayerDead":
        case "Veteran_PlayerDead":
        case "jughead_PlayerDead":
        case "drugdealer_PlayerDead":
        case "Harold_PlayerDead":
        case "Shannon_PlayerDead":
        case "Sven_PlayerDead":
        case "supervisor01_PlayerDead":
        case "Canal_Pilot_PlayerDead":
        case "Canal_Bartender_PlayerDead":
        case "MarketBum1_PlayerDead":
        case "ClubDoorGirl_PlayerDead":
        case "Mamasan_PlayerDead":
        case "ClubBartender_PlayerDead":
        case "bums_PlayerDead":
        case "Camille_PlayerDead":
        case "Jean_PlayerDead":
        case "Michelle_PlayerDead":
        case "Antoine_PlayerDead":
        case "Jocques_PlayerDead":
        case "Kristi_PlayerDead":
        case "HotelBartender_PlayerDead":
        case "MetroTechnician_PlayerDead":
        case "lemerchant_PlayerDead":
        case "DXRNPCs1_PlayerDead":
        case "MarketWaiter_PlayerDead":
        case "Sally_PlayerDead":
        case "Pimp_PlayerDead":
        case "Bum_M_PlayerDead":
        case "Renault_PlayerDead":
        case "Louis_PlayerDead":
        case "Defoe_PlayerDead":
        case "Cassandra_PlayerDead":
        case "ClubBouncer_PlayerDead":
            _MarkBingo("DestroyCapitalism"); //Split into another event, but still return this one as-is
            return eventname;
        case "MeetWalton_Played":
        case "M04MeetWalton_Played":
        case "M05WaltonAlone_Played":
        case "M05MeetManderley_Played":
        case "M11WaltonHolo_Played":
        case "WaltonShowdown_Played":
        case "WaltonBadass_Played":
            return "WaltonConvos";
        case "ScientistMale_ClassDead":
        case "ScientistFemale_ClassDead":
            return "ScienceIsForNerds";
        case "ShipNamePlate_B_peepedtex":
        case "ShipNamePlate_C_peepedtex":
        case "ShipNamePlate_D_peepedtex":
            return "ShipNamePlate";
        case "UNATCOHQ_BulletinBoard_Cork_peepedtex":
            return "un_bboard_peepedtex";
        case "SheaKnowsAboutDowd":
        case "GreenKnowsAboutDowd":
            return "SnitchDowd";
        case "IcarusCalls_Played":
            _MarkBingo("PhoneCall"); //It's a phone call!
            return eventname;
        case "Doberman_peeptime":
        case "Mutt_peeptime":
            return "WatchDogs";
        case "DonDone":
        case "LennyDone":
            return "GiveZyme";
        case "PetAnimal_Karkian":
        case "PetAnimal_KarkianBaby":
            return "PetKarkians";
        case "PetAnimal_Doberman":
        case "PetAnimal_Mutt":
            return "PetDogs";
        case "PetAnimal_Fish":
        case "PetAnimal_Fish2":
            return "PetFish";
        case "PetAnimal_Pigeon":
        case "PetAnimal_Seagull":
            return "PetBirds";
        case "PetAnimal_Rat":
        case "PetAnimal_NastyRat":
            return "PetRats";
        case "PianoSong9Played":
        case "PianoSong32Played":
        case "PianoSong33Played":
        case "PianoSong45Played":
        case "PianoSong62Played":
        case "PianoSong73Played":
        case "PianoSong74Played":
        case "PianoSong75Played":
        case "PianoSong76Played":
        case "PianoSong77Played":
        case "PianoSong78Played":
        case "PianoSong79Played":
        case "PianoSong80Played":
        case "PianoSong81Played":
        case "PianoSong82Played":
        case "PianoSong83Played":
        case "PianoSong84Played":
        case "PianoSong85Played":
            return "SeasonalPianoPlayed";
        case "MeetClinicOlderBum_Played":
        case "MeetWindowBum_Played":
        case "JordanSheaConvos_Played":
        case "WorkerGivesInfo_Played":
        case "MaleHostageRescued_Played":
        case "M02SallyDone":
            return "InterviewLocals";
        case "MeetSandraRenton_Played":
            _MarkBingo("InterviewLocals"); //Split into another event, but still return this one as-is
            return eventname;
        case "BlackCat_peeptime":
            return "Cat_peeptime";
        case "PetAnimal_BlackCat":
            return "PetAnimal_Cat";
        case "MeetSmuggler_Played":
        case "M04MeetSmuggler_Played":
        case "M08SmugglerConvos_Played":
            return "MeetSmuggler";
        case "Ray_Dead":
        case "Ray_Unconscious":
            return "GotHelicopterInfo";
        case "CarlaBrown_PlayerDead":
        case "StacyWebber_PlayerDead":
        case "TimBaker_PlayerDead":
        case "StephanieMaxwell_PlayerDead":
        case "TonyMares_PlayerDead":
        case "Savage_assistant_M_PlayerDead":
        case "Savage_assistant_F_PlayerDead":
        case "LDDPVanSci_PlayerDead":
            return "Ex51";
        case "BodyPartLoss_LeftLeg":
        case "BodyPartLoss_RightLeg":
        case "BodyPartLoss_LeftArm":
        case "BodyPartLoss_RightArm":
            _MarkBingo("LostLimbs"); //Split into another event, but still return this one as-is
            return eventname;
        default:
            return eventname;
    }
    return eventname;
}
//#endregion

//#region Bingo Failure
static function int GetBingoFailedEvents(string eventname, out string failed[7])
{
    local int num_failed;
    local DXRando dxr;
    dxr = class'DXRando'.default.dxr;

    if (Right(eventname, 12) == "_Unconscious") {
        failed[num_failed++] = Left(eventname, Len(eventname) - 11) $ "Dead";
        failed[num_failed++] = Left(eventname, Len(eventname) - 11) $ "PlayerDead";
    } else if (Right(eventname, 5) == "_Dead") {
        failed[num_failed++] = Left(eventname, Len(eventname) - 4) $ "Unconscious";
        failed[num_failed++] = Left(eventname, Len(eventname) - 4) $ "PlayerUnconscious";
    }

    // keep in mind that a goal can only be marked as failed if it isn't already marked as completed
    switch (eventname) {

        case "SubHostageFemale_Dead":
        case "SubHostageMale_Unconscious":
        case "SubHostageFemale_Dead":
        case "SubHostageMale_Unconscious":
            failed[num_failed++] = "SubwayHostagesSaved";
            return num_failed;
        case "AlleyBum_Dead":
        case "AlleyBum_Unconscious":
            failed[num_failed++] = "AlleyBumRescued";
            return num_failed;
        case "FordSchick_Dead":
        case "FordSchick_Unconscious":
            failed[num_failed++] = "FordSchickRescued";
            return num_failed;
        case "GeneratorBlown":
            failed[num_failed++] = "JockSecondStory";
            return num_failed;
        case "SandraRenton_Dead":
        case "SandraRenton_Unconscious":
            failed[num_failed++] = "FamilySquabbleWrapUpGilbertDead_Played";
            failed[num_failed++] = "MeetSandraRenton_Played";
            return num_failed;
        case "GilbertRenton_Dead":
        case "GilbertRenton_Unconscious":
            if (class'DXRando'.default.dxr.localURL != "04_NYC_HOTEL") {
                failed[num_failed++] = "FamilySquabbleWrapUpGilbertDead_Played";
            }
            failed[num_failed++] = "GaveRentonGun";
        // fallthrough
        case "FemaleHostage_Dead":
        case "FemaleHostage_Unconscious":
        case "MaleHostage_Dead":
        case "MaleHostage_Unconscious":
            failed[num_failed++] = "HotelHostagesSaved";
            return num_failed;
        case "Josh_Dead":
        case "Josh_Unconscious":
            failed[num_failed++] = "JoshFed";
            return num_failed;
        case "Billy_Dead":
        case "Billy_Unconscious":
            failed[num_failed++] = "M02BillyDone";
            return num_failed;
        case "Don_Dead":
        case "Don_Unconscious":
        case "Lenny_Dead":
        case "Lenny_Unconscious":
            failed[num_failed++] = "GiveZyme";
            return num_failed;
        case "MeetLebedev_Played":
            failed[num_failed++] = "OverhearLebedev_Played";
            return num_failed;
        case "JuanLebedev_Dead":
        case "JuanLebedev_Unconscious":
            failed[num_failed++] = "LebedevLived";
            return num_failed;
        case "JoJoFine_Dead":
        case "JoJoFine_Unconscious":
            failed[num_failed++] = "GaveRentonGun";
            return num_failed;
        case "NSFSignalSent":
            failed[num_failed++] = "M04PlayerLikesUNATCO_Played";
            return num_failed;
        case "Miguel_Dead":
        case "Miguel_Unconscious":
            failed[num_failed++] = "Terrorist_peeptime";
            failed[num_failed++] = "Terrorist_ClassDead";
            failed[num_failed++] = "Terrorist_ClassUnconscious";
            failed[num_failed++] = "nsfwander";
            failed[num_failed++] = "MiguelLeaving";
            return num_failed;
        case "JaimeLeftBehind":
            failed[num_failed++] = "M07MeetJaime_Played";
            // fallthrough
        case "JaimeRecruited":
            failed[num_failed++] = "KnowsGuntherKillphrase";
            return num_failed;
        case "M06Junkie_Dead":
        case "M06Junkie_Unconscious":
            failed[num_failed++] = "M06PaidJunkie";
            return num_failed;
        case "MarketBum1_Dead": // the guy who sells you the Versalife map and camo, isn't in the market, and looks nothing like a bum
        case "MarketBum1_Unconscious":
            failed[num_failed++] = "M06BoughtVersaLife";
            return num_failed;
        case "Canal_Bartender_Dead":
        case "Canal_Bartender_Unconscious":
            failed[num_failed++] = "Canal_Bartender_Question4";
            return num_failed;
        case "ClubBartender_Dead":
        case "ClubBartender_Unconscious":
            failed[num_failed++] = "M06BartenderQuestion3";
            return num_failed;
        case "MaggieChow_Dead":
        case "MaggieChow_Unconscious":
            failed[num_failed++] = "MaggieLived";
            return num_failed;
        case "Mamasan_Dead":
        case "Mamasan_Unconscious":
        case "Date1_Dead":
        case "Date1_Unconscious":
            failed[num_failed++] = "M06JCHasDate";
            return num_failed;
        case "Raid_Underway": //Raid started
            failed[num_failed++] = "M06JCHasDate";
            failed[num_failed++] = "ClubEntryPaid";
            return num_failed;
        case "ClubMercedes_Dead":
        case "ClubMercedes_Unconscious":
        case "ClubTessa_Dead":
        case "ClubTessa_Unconscious":
            if (!dxr.flagbase.GetBool('LDDPJCIsFemale')) {
                failed[num_failed++] = "ClubEntryPaid";
            }
            return num_failed;
        case "LDDPRuss_Dead":
        case "LDDPRuss_Unconscious":
            if (dxr.flagbase.GetBool('LDDPJCIsFemale')) {
                failed[num_failed++] = "ClubEntryPaid";
            }
            return num_failed;
        case "Supervisor01_Dead":
        case "Supervisor01_Unconscious":
            failed[num_failed++] = "Supervisor_Paid";
            return num_failed;
        case "Aimee_Dead":
        case "Aimee_Unconscious":
        case "LeMerchant_Dead":
        case "LeMerchant_Unconscious":
            failed[num_failed++] = "AimeeLeMerchantLived";
            return num_failed;
        case "hostage_female_Dead":
        case "hostage_female_Unconscious":
        case "hostage_Dead":
        case "hostage_Unconscious":
            failed[num_failed++] = "SilhouetteHostagesAllRescued";
            return num_failed;
        case "Renault_Dead":
        case "Renault_Unconscious":
            failed[num_failed++] = "SoldRenaultZyme";
            failed[num_failed++] = "MeetRenault_Played";
            return num_failed;
        case "Joshua_Dead":
        case "Joshua_Unconscious":
            failed[num_failed++] = "JoshuaInterrupted_Played";
            return num_failed;
        case "Camille_Dead":
        case "Camille_Unconscious":
            failed[num_failed++] = "CamilleConvosDone";
            return num_failed;
        case "drbernard_Dead":
        case "drbernard_Unconscious":
            failed[num_failed++] = "MeetDrBernard_Played";
            return num_failed;
        case "TimBaker_Dead":
        case "TimBaker_Unconscious":
            failed[num_failed++] = "MeetTimBaker_Played";
            return num_failed;
        case "TiffanySavage_Dead":
        case "TiffanySavage_Unconscious":
            failed[num_failed++] = "TiffanyHeli";
            return num_failed;
        case "AnnaNavarre_DeadM3":
            failed[num_failed++] = "AnnaNavarre_DeadM4";
            failed[num_failed++] = "AnnaNavarre_DeadM5";
            return num_failed;
        case "AnnaNavarre_DeadM4":
            failed[num_failed++] = "AnnaNavarre_DeadM5";
            return num_failed;
        case "SavedPaul":
            failed[num_failed++] = "PaulToTong";
            return num_failed;
        case "StatueMissionComplete":
            failed[num_failed++] = "GuntherFreed";
            return num_failed;
    }

    return num_failed;
}
//#endregion

//#region Bingo Help Text
static simulated function string GetBingoGoalHelpText(string event,int mission, bool FemJC)
{
    local string msg;
    switch(event){
        case "Free Space":
            return "Don't worry about it!  This one's free!";
        case "TerroristCommander_Dead":
        case "TerroristCommander_PlayerDead":
            return "Kill Leo Gold, the terrorist commander on Liberty Island.  You must kill him yourself.";
        case "TiffanySavage_Dead":
        case "TiffanySavage_PlayerDead":
            return "Kill Tiffany Savage.  She is being held hostage at the gas station.  You must kill her yourself.";
        case "PaulDenton_Dead":
            return "Let Paul Denton die (or kill him yourself) during the ambush on the hotel.";
        case "JordanShea_Dead":
        case "JordanShea_PlayerDead":
            return "Kill Jordan Shea, the bartender at the Underworld Tavern in New York.  You must kill her yourself.";
        case "SandraRenton_Dead":
        case "SandraRenton_PlayerDead":
            msg = "Kill Sandra Renton.  ";
            if (mission<=2){
                msg=msg$"She can be found in an alley next to the Underworld Tavern in New York";
            } else if (mission<=4){
                msg=msg$"She can be found inside the hotel";
            } else if (mission<=8){
                msg=msg$"She can be found in the Underworld Tavern";
            } else if (mission<=12){
                msg=msg$"She can be found outside the gas station";
            }
            msg = msg $ ".  You must kill her yourself.";
            return msg;
        case "GilbertRenton_Dead":
        case "GilbertRenton_PlayerDead":
            return "Kill Gilbert Renton.  He can be found behind the front desk in the 'Ton hotel.  You must kill him yourself.";
        case "WarehouseEntered":
            return "Enter the underground warehouse in Paris.  This warehouse is located in the building across the street from the entrance to the Catacombs.";
        case "GuntherHermann_Dead":
            return "Kill Gunther.  He can be found guarding a computer somewhere in the cathedral in Paris.";
        case "JoJoFine_Dead":
        case "JoJoFine_PlayerDead":
            return "Kill Jojo Fine.  He can be found in the 'Ton hotel before the ambush.  You must kill him yourself.";
        case "TobyAtanwe_Dead":
        case "TobyAtanwe_PlayerDead":
            return "Kill Toby Atanwe, who is Morgan Everett's assistant.  He can be killed once you arrive at Everett's house.  You must kill him yourself.";
        case "Antoine_Dead":
        case "Antoine_PlayerDead":
            return "Kill Antoine in the Paris club.  He can be found at a table in a back corner of the club selling bioelectric cells.  You must kill him yourself.";
        case "Chad_Dead":
        case "Chad_PlayerDead":
            return "Kill Chad Dumier.  He can be found in the Silhouette hideout in the Paris catacombs.  You must kill him yourself.";
        case "paris_hostage_Dead":
            return "Let both of the hostages in the Paris catacombs die (whether you do it yourself or not).  They can be found locked in the centre of the catacombs bunker occupied by MJ12.";
        case "Hela_Dead":
        case "Hela_PlayerDead":
            return "Kill Hela, the woman in black leading the MJ12 force in the Paris catacombs.  You must kill her yourself.";
        case "Renault_Dead":
        case "Renault_PlayerDead":
            return "Kill Renault in the Paris hostel.  He is the man who asks you to steal zyme and will buy it from you.  You must kill him yourself.";
        case "Labrat_Bum_Dead":
        case "Labrat_Bum_PlayerDead":
            return "Kill the bum locked up in the Hong Kong MJ12 lab.  You must kill him yourself.";
        case "DXRNPCs1_Dead":
        case "DXRNPCs1_PlayerDead":
            return "Kill The Merchant.  He will randomly spawn in levels according to your chosen game settings.  You must kill him yourself.  Keep in mind that once you kill him, he will no longer appear for the rest of your run!";
        case "lemerchant_Dead":
        case "lemerchant_PlayerDead":
            return "Kill Le Merchant.  He spawns near where you first land in Paris.  He's a different guy!  You must kill him yourself.";
        case "Harold_Dead":
        case "Harold_PlayerDead":
            return "Kill Harold the mechanic.  He can be found working underneath the 747 in the LaGuardia hangar.  You must kill him yourself.";
        case "aimee_Dead":
        case "aimee_PlayerDead":
            return "Kill Aimee, the woman worrying about her cats in Paris.  She can be found near where you first land in Paris.  You must kill her yourself.";
        case "WaltonSimons_Dead":
            msg="Kill Walton Simons.  ";
            if (mission<=14){
                msg=msg$"He can be found hunting you down somewhere in or around the Ocean Lab";
            } else if (mission==15){
                msg=msg$"He can be found hunting you down somewhere in Area 51";
            }
            msg=msg$".  You must kill him yourself.";
            return msg;
        case "JoeGreene_Dead":
        case "JoeGreene_PlayerDead":
            msg= "Kill Joe Greene, the reporter poking around in New York.  ";
            if (mission<=4){
                msg=msg$"He can be found in the Underworld Tavern";
            }else if (mission<=8){
                msg=msg$"He can be found somewhere in New York after you return from Hong Kong";
            }
            msg=msg$".  You must kill him yourself.";
            return msg;
        case "GuntherFreed":
            return "Free Gunther from the makeshift jail on Liberty Island.  The jail is just inside the base of the statue.";
        case "BathroomBarks_Played":
            return "Enter the wrong bathroom in UNATCO HQ on your first visit.";
        case "GotHelicopterInfo":
            return "Help Jock locate the bomb planted in his helicopter by killing the fake mechanic.";
        case "JoshFed":
            return "Give Josh some soy food or a candy bar.  Josh is a kid located on the docks of Battery Park.";
        case "M02BillyDone":
            return "Give Billy some soy food or a candy bar.  Billy is a kid located in the kiosk of Castle Clinton.";
        case "FordSchickRescued":
            return "Rescue Ford Schick from the MJ12 lab in the sewers under New York on your first visit to Hell's Kitchen.  The key to the sewers can be gotten from Smuggler.";
        case "NiceTerrorist_Dead":
            return "Kill a friendly NSF trooper in the LaGuardia hangar.";
        case "M10EnteredBakery":
            return "Enter the bakery in the streets of Paris.  The bakery can be found across the street from the Metro.";
        case "FreshWaterOpened":
            return "Fix the fresh water supply in Brooklyn Bridge Station.  The water valves are behind some collapsed rubble.";
        case "assassinapartment":
            return "Visit the apartment in Paris that has Starr the dog inside.  This apartment is over top of the media store, but is accessed from the opposite side of the building near where Jock picks you up.";
        case "PetAnimal_BindName_Starr":
            return "Visit the apartment in Paris and pet Starr, the dog inside.  This apartment is over top of the media store, but is accessed from the opposite side of the building near where Jock picks you up.";
        case "GaveRentonGun":
            return "Give Gilbert Renton a gun when he is trying to protect his daughter from JoJo Fine, before the ambush.";
        case "DXREvents_LeftOnBoat":
            return "After destroying the NSF generator, return to Battery Park and take the boat back to UNATCO.";
        case "AlleyBumRescued":
            return "On your first visit to Battery Park, rescue the bum being mugged on the basketball court.  The court can be found behind the subway station.";
        case "FoundScientistBody":
            return "Enter the collapsed tunnel under the canals and find the scientist body.  The tunnel can be accessed through the vents in the freezer of the Old China Hand.";
        case "ClubEntryPaid":
           if (FemJC) {
#ifdef revision
               return "Let Noah, the man waiting outside the Lucky Money, pay to get you into the club.";
#else
               return "Let Russ, the man waiting outside the Lucky Money, pay to get you into the club.";
#endif
           } else {
               return "Give Mercedes and Tessa (the two women waiting outside the Lucky Money) money to get into the club.";
           }
        case "M08WarnedSmuggler":
            return "After talking to Stanton Dowd, talk to Smuggler and warn him of the impending UNATCO raid.";
        case "ShipPowerCut":
            return "Help the electrician on the superfreighter by disabling the electrical panels under the electrical room.";
        case "CamilleConvosDone":
            return "Talk to Camille the Paris cage dancer and get all the information you can.";
        case "MeetAI4_Played":
            return "Talk to Morpheus, the prototype AI locked away in Everett's house.";
        case "DL_Flooded_Played":
            return "Swim outside of the Ocean Lab on the ocean floor and enter the flooded section through the hole blasted in the underside of the structure.  There is a flickering light above the hole you need to enter.";
        case "JockSecondStory":
            return "Buy two beers from Jordan Shea and give them to Jock in the Underworld Tavern.";
        case "M07ChenSecondGive_Played":
            return "After the triad meeting in the temple, meet the leaders in the Lucky Money and receive all the gifted bottles of wine from each Dragon Head.";
        case "DeBeersDead":
            return "Kill Lucius DeBeers in Everett's House.  You can do so either by destroying him or shutting off his bio support with the computer next to him.";
        case "StantonAmbushDefeated":
            return "Defend Stanton Dowd from the MJ12 ambush after talking to him.";
        case "SmugglerDied":
            return "Let Smuggler die by not warning him of the UNATCO raid.  This can be done either by not talking to him at all, or not warning him of the raid if you talk to him after talking to Dowd.";
        case "GaveDowdAmbrosia":
            return "Find a vial of ambrosia on the upper decks of the superfreighter and bring it to Stanton Dowd in the graveyard.";
        case "JockBlewUp":
            return "Don't kill the fake mechanic at Everett's house so that Jock dies when you arrive in Area 51.";
        case "SavedPaul":
            return "Save Paul during the ambush on the 'Ton hotel.";
        case "nsfwander":
            return "Escort Miguel, the captured NSF troop, out of the MJ12 base underneath UNATCO HQ.";
        case "MadeBasket":
            return "Throw the basketball into the net in Hell's Kitchen.";
        case "BoughtClinicPlan":
            return "On your first visit to Hell's Kitchen, go to the free clinic and buy the full treatment plan from the doctors.";
        case "ExtinguishFire":
            return "Put yourself out by using a shower, sink, toilet, or urinal while on fire.  You can light yourself on fire with WP Rockets or by jumping onto a burning barrel.";
        case "SubwayHostagesSaved":
            return "Ensure both hostages in the Battery Park subway station escape on the train.";
        case "HotelHostagesSaved":
            return "Rescue the hostages on the top floor of the 'Ton as well as Gilbert Renton.";
        case "SilhouetteHostagesAllRescued":
            return "Save both hostages in the Paris catacombs and escort them to safety in the Silhouette hideout.";
        case "JosephManderley_Dead":
        case "JosephManderley_PlayerDead":
            return "Kill Manderley while escaping from UNATCO.  You must kill him yourself.";
        case "MadeItToBP":
            return "After the raid on the 'Ton hotel, escape to Gunther's roadblock in Battery Park.";
        case "MeetSmuggler":
            return "Talk to Smuggler in his Hell's Kitchen hideout.";
        case "SickMan_Dead":
        case "SickMan_PlayerDead":
            return "Kill the junkie in Battery Park who asks for someone to kill him.  He is typically found near the East Coast Memorial (the eagle statue and large plaques).  You must kill him yourself.";
        case "M06PaidJunkie":
            return "Visit the junkie living on the floor under construction below Maggie Chow's apartment.  Give her money.";
        case "M06BoughtVersaLife":
            return "Buy the maps of Versalife from the guy in the Old China Hand bar, by the canal.";
        case "FlushToilet":
            return "Find and flush enough different toilets.  Note that toilets in places that you revisit (like UNATCO HQ) will count again on each visit.";
        case "FlushUrinal":
            return "Find and flush enough different urinals.  Note that urinals in places that you revisit (like UNATCO HQ) will count again on each visit.";
        case "MeetTimBaker_Played":
            return "Enter the storage room in Vandenberg near the Hazard Lab and talk to Tim Baker.";
        case "MeetDrBernard_Played":
            return "Find Dr. Bernard, the scientist locked in the bathroom at the silo.";
        case "KnowsGuntherKillphrase":
            return "Learn Gunther's killphrase from Jaime in Paris.  Note that he will only meet you in Paris if you ask him to stay with UNATCO while you escape from the MJ12 base.";
        case "KnowsAnnasKillphrase":
            return "Learn both parts of Anna's killphrase in UNATCO HQ after escaping from the MJ12 lab.  The killphrase is split across two computers in HQ.  There will be a datacube on Manderley's desk with hints to the location of the parts of the killphrase.";
        case "Area51FanShaft":
            return "In Area 51, jump down the ventilation shaft inside the hangar.";
        case "PoliceVaultBingo":
            return "Enter the police vault in the Wan Chai Market.";
        case "SunkenShip":
            return "Enter the ship that has sunk off the North Dock of Liberty Island (Near Harley Filben).";
        case "SpinShipsWheel":
            msg="Spin enough ships wheels.  ";
            if (mission<=1){
                msg=msg$"There is a ships wheel on the wall of the hut Harley Filben is in.";
            }else if (mission<=6){
                msg=msg$"There is a ships wheel on the smuggler's ship in the Wan Chai canals, as well as on the wall of the Boat Persons house (off the side of the canal).";
            }else if (mission<=9){
                msg=msg$"There is a ships wheel on the bridge of the Superfreighter.";
            }
            return msg;
        case "ActivateVandenbergBots":
            return "Activate both military bots in Vandenberg.  The two generator keypads must be activated before you can enter the building that the milbots are inside.";
        case "TongsHotTub":
            return "Jump into the tub of water in Tracer Tong's hideout.";
        case "JocksToilet":
            return "Use the toilet in Jock's Tonnochi Road apartment.  The bathroom is behind a sliding door next to the kitchen.";
        case "Greasel_ClassDead":
            return "Kill enough greasels.  You must kill them yourself.";
        case "support1":
            return "Blow up the gas station.";
        case "UNATCOTroop_ClassDead":
            return "Kill enough UNATCO Troopers.  You must kill them yourself.";
        case "Terrorist_ClassDead":
            return "Kill enough NSF Troops.  You must kill them yourself.";
        case "MJ12Troop_ClassDead":
            return "Kill enough MJ12 Troopers.  You must kill them yourself.";
        case "MJ12Commando_ClassDead":
            return "Kill enough MJ12 Commandos.  You must kill them yourself.";
        case "Karkian_ClassDead":
            return "Kill enough karkians.  You must kill them yourself.";
        case "MilitaryBot_ClassDead":
            return "Destroy enough military bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "VandenbergToilet":
            return "Use the one toilet in Vandenberg.  It is located inside the Comm building outside.";
        case "BoatEngineRoom":
            return "Enter the small room at the back of the smuggler's boat in the Hong Kong canals and check the power levels on the equipment inside.  The room can be accessed by using one of the hanging lanterns near the back of the boat.";
        case "SecurityBot2_ClassDead":
            return "Destroy enough of the two legged walking security bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "SecurityBotSmall_ClassDead":
            return "Destroy enough of the smaller, treaded security bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "SpiderBot_ClassDead":
            return "Destroy enough spider bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "HumanStompDeath":
            return "Jump on enough humans heads until they die.  Note that people will not take stomp damage unless they are hostile to you, so you may need to hit them first to make them angry.";
        case "Rat_ClassDead":
            return "Kill enough rats.  You must kill them yourself.";
        case "UNATCOTroop_ClassUnconscious":
            return "Knock out enough UNATCO Troopers.  You can knock them out with things like the baton, prod, or tranq darts.  You must knock them out yourself.";
        case "Terrorist_ClassUnconscious":
            return "Knock out enough NSF Troops.  You can knock them out with things like the baton, prod, or tranq darts.  You must knock them out yourself.";
        case "MJ12Troop_ClassUnconscious":
            return "Knock out enough MJ12 Troopers.  You can knock them out with things like the baton, prod, or tranq darts.  You must knock them out yourself.";
        case "MJ12Commando_ClassUnconscious":
            return "Knock out enough MJ12 Commandos.  You can knock them out with things like the baton, prod, or tranq darts.  You must knock them out yourself.";
        case "purge":
            return "Use the keypad in the vents of the Hong Kong MJ12 Helibase to release poison gas into the barracks.";
        case "ChugWater":
            return "Drink the entire contents of a water fountain or water cooler as quickly as possible.";
        case "ChangeClothes":
            return "Use hanging clothes to change your appearance!";
        case "arctrigger":
            return "Disable the arcing electricity in the corner of the LaGuardia airfield.";
        case "LeoToTheBar":
            return "Bring the body of Leo Gold (The terrorist commander from Liberty Island) to any bar in the game (New York, Hong Kong, Paris) and set him down.  You can also bring him to the bottom of the Ocean Lab, since it is under many BARs of pressure.";
        case "KnowYourEnemy":
            return "Read enough \"Know Your Enemy\" bulletins on the public computer in the UNATCO break room.";
        case "09_NYC_DOCKYARD--796967769":
            return "Find Jenny's number (867-5309) somewhere in the outer area of the Brooklyn Naval Yards on a datacube.";
        case "JacobsShadow":
            msg="Read enough chapters of Jacob's Shadow.  ";
            if (mission<=2){
                msg=msg$"There is a chapter in the MJ12 sewer base in Hell's Kitchen.";
            } else if (mission<=3){
                msg=msg$"There is a chapter in the LaGuardia Helibase.";
            } else if (mission<=4){
                msg=msg$"There is a chapter in the 'Ton hotel.";
            } else if (mission<=6){
                msg=msg$"There is a chapter in the Wan Chai Market.";
            } else if (mission<=9 && class'DXRando'.default.dxr.localURL!="09_NYC_GRAVEYARD"){
                msg=msg$"There is a chapter in the lower decks of the Superfreighter.";
            } else if (mission<=10){
                msg=msg$"There is a chapter in the DuClare Chateau.";
            } else if (mission<=12){
                msg=msg$"There is a chapter in Vandenberg Command and the Computer area.";
            } else if (mission<=15){
                msg=msg$"There is a chapter in Area 51 on the surface, in Sector 2, and in Sector 3.";
            }
            return msg;
        case "ManWhoWasThursday":
            msg="Read enough chapters of The Man Who Was Thursday.  ";
            if (mission<=2){
                msg=msg$"There is a chapter inside the 'Ton hotel and in the sewers.";
            } else if (mission<=3){
                msg=msg$"There is a chapter in the LaGuardia helibase.";
            } else if (mission<=4){
                msg=msg$"There is a chapter inside the 'Ton hotel.";
            } else if (mission<=10){
                msg=msg$"There is a chapter in Denfert-Rochereau square, the streets and buildings before entering the Paris catacombs.";
            } else if (mission<=12){
                msg=msg$"There is a chapter in Vandenberg Command.";
            } else if (mission<=14){
                msg=msg$"There is a chapter in the Ocean Lab.";
            } else if (mission<=15){
                msg=msg$"There is a chapter in Sector 3 of Area 51.";
            }
            return msg;
        case "GreeneArticles":
            msg="Read enough news articles written by Joe Greene of the Midnight Sun.  ";
            if (mission<=1){
                msg=msg$"There's one on Liberty Island, and one in UNATCO HQ.";
            } else if (mission<=2){
                msg=msg$"There is an article somewhere around the NSF warehouse.";
            } else if (mission<=3){
                msg=msg$"There are 3 copies of the same article: in Brooklyn Bridge Station, in the helibase, and in the 747.";
            } else if (mission<=8){
                msg=msg$"There is an article in the streets of Hell's Kitchen and in the bar.";
            }
            return msg;
        case "MoonBaseNews":
            msg="Read an article talking about the mining complex located on the moon.  ";
            if (mission<=2){
                msg=msg$"There is an article in the streets of Hell's Kitchen.";
            } else if (mission<=3){
                msg=msg$"There is an article in the LaGuardia Helibase.";
            } else if (mission<=6){
                msg=msg$"There is an article in the Wan Chai Market as well as the Lucky Money.";
            }
            return msg;
        case "06_Datacube05":
            return "Find the datacube on Tonnochi Road from Louis Pan reminding Maggie that he will never forget her birthday again.";
        case "Gray_ClassDead":
            return "Kill enough Grays.  You must kill them yourself.";
        case "CloneCubes":
            return "Read enough datacubes regarding the cloning projects at Area 51.  There are 8 datacubes scattered through Sector 4 of Area 51.";
        case "blast_door_open":
            return "Open the main blast doors of the Area 51 bunker by finding the security computer somewhere on the surface or by opening them from inside.";
        case "SpinningRoom":
            return "Pass through the center of the spinning room in the ventilation system of the Brooklyn Naval Yards.";
        case "MolePeopleSlaughtered":
            return "Kill most of the friendly mole people in the tunnels leading to Lebedev's private terminal at LaGuardia.";
        case "surrender":
            return "Find the leader of the NSF in the hidden room of the mole people tunnels and let him surrender.";
        case "nanocage":
            return "Open the greasel cages in the MJ12 lab underneath UNATCO HQ.";
        case "unbirth":
            return "Find the cloning tank in Sector 4 of Area 51 that does not have a lid and go swimming in it.";
        case "StolenAmbrosia":
            msg="Find enough stolen barrels of ambrosia.  ";
            if (mission<=2){
                msg=msg$"There is a barrel of ambrosia somewhere in Battery Park.";
            } else if (mission<=3){
                msg=msg$"There are three barrels of ambrosia.  One is in the LaGuardia helibase.  One is in the airfield.  One is either in the hangar or on the 747.";
            }
            return msg;
        case "AnnaKilledLebedev":
            return "Let Anna kill Lebedev by walking away without killing him yourself.";
        case "PlayerKilledLebedev":
            return "Murder Juan Lebedev on the 747 of your own volition.";
        case "JuanLebedev_Unconscious":
        case "JuanLebedev_PlayerUnconscious":
            return "Knock Lebedev out instead of killing him.  You must knock him out yourself.";
        case "BrowserHistoryCleared":
            return "While escaping UNATCO, log into the computer in your office and clear your browser history.";
        case "AnnaKillswitch":
            return "After finding the pieces of Anna's killphrase, actually use it against her.";
        case "AnnaNavarre_DeadM3":
            return "Kill Anna Navarre on the 747.  You must kill her yourself.";
        case "AnnaNavarre_DeadM4":
            return "Kill Anna Navarre after sending the signal for the NSF but before being captured by UNATCO.  You must kill her yourself.";
        case "AnnaNavarre_DeadM5":
            return "Kill Anna Navarre in UNATCO HQ.  You must kill her yourself.";
        case "SimonsAssassination":
            return "Watch Walton Simons' full interrogation of the captured NSF soldiers.";
        case "AlliesKilled":
            return "Kill enough people who do not actively hate you.  (This should be most people who show as green on the crosshairs)";
        case "MaySung_Dead":
        case "MaySung_PlayerDead":
            return "Kill May Sung, Maggie Chow's maid.  You must kill her yourself.";
        case "MostWarehouseTroopsDead":
            return "Kill or knock out most of the UNATCO Troops securing the NSF HQ.  This can be done before sending the signal for the NSF or after.";
        case "CleanerBot_ClassDead":
            return "Destroy enough cleaner bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "MedicalBot_ClassDead":
            return "Destroy enough medical bots or aug bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "RepairBot_ClassDead":
            return "Destroy enough repair bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "UtilityBot_ClassDead":
            return "Destroy enough utility bots (medical bots, aug bots, or repair bots).  You must destroy them yourself and disabling them with EMP does not count.";
        case "DrugDealer_Dead":
        case "DrugDealer_PlayerDead":
            return "Kill Rock, the drug dealer who lives in Brooklyn Bridge Station.  You must kill him yourself.";
        case "botordertrigger":
            return "Set off the laser tripwires in Smuggler's hideout.";
        case "IgnitedPawn":
            return "Set enough people on fire.";
        case "GibbedPawn":
            return "Blow up enough people.  If they turn into chunks of meat, it counts.";
        case "IcarusCalls_Played":
            return "Answer the phone in the building across from the entrance to the catacombs in Paris.";
        case "AlexCloset":
            return "Enter Alex Jacobson's storage closet in UNATCO HQ.  The code to the door can be found in his email during the first mission.";
        case "BackOfStatue":
            return "Climb out along the balcony ledges of the Statue of Liberty and go around to the side facing UNATCO HQ.";
        case "CommsPit":
            return "Inspect the wiring in the pit outside of UNATCO HQ enough times.";
        case "StatueHead":
            return "Walk up to where the head of the Statue of Liberty is being displayed.";
        case "CraneControls":
            return "Move the crane next to the Superfreighter (inside the dock) by going up the elevator on the dockside and hitting the button at the top.";
        case "CraneTop":
            return "Walk to the ends of the two cranes that are on the deck of the Superfreighter itself.";
        case "CaptainBed":
            return "Enter the captain's quarters on the Superfreighter and jump on his bed.";
        case "FanTop":
            return "Enter the ventilation shaft in the lower decks of the Superfreighter and let yourself get blown to the top of the shaft.";
        case "LouisBerates":
            return "Sneak behind the doorman of the Porte De L'Enfer, the club in Paris.";
        case "EverettAquarium":
            return "Enter the aquarium in Morgan Everett's house.";
        case "TrainTracks":
            return "Jump onto the train tracks in Paris.";
        case "OceanLabCrewChamber":
            return "Visit enough of the crew chambers in the Ocean Lab.";
        case "HeliosControlArms":
            return "Jump down onto the arms sticking out of the wall below where you talk to Helios in Area 51.";
        case "TongTargets":
            return "Shoot at the targets in the shooting range in Tracer Tong's hideout.";
        case "WanChaiStores":
            return "Visit all of the stores in the Wan Chai market by walking up to them.";
        case "HongKongBBall":
            return "Throw the basketball into the net on the rooftop of the MJ12 helibase in Hong Kong.";
        case "CanalDrugDeal":
            return "Find the two people making a drug deal in the Hong Kong canals and listen in.";
        case "HongKongGrays":
            return "Enter the enclosure in the Hong Kong MJ12 Lab containing the grays.";
        case "EnterQuickStop":
            return "Enter the Quick Stop convenience store outside of the Lucky Money in Hong Kong.";
        case "LuckyMoneyFreezer":
            return "Enter the freezer in the back of the Lucky Money club in Hong Kong.";
        case "TonnochiBillboard":
            return "Jump onto the 'Big Top Cigarettes' billboard hanging above the entrance in Tonnochi Road.  This sign has a big picture of a clown on it, and says 'NO JOKE' at the top.";
        case "AirfieldGuardTowers":
            return "Enter the top floor of enough of the guard towers in the corners of the LaGuardia airfield.";
        case "mirrordoor":
            return "Open (or destroy) the mirror acting as the door to the secret stash in Smuggler's hideout.";
        case "MolePeopleWater":
            return "Find the pool of water in the Mole People tunnels and jump into it.  You need to crouch to get yourself fully immersed.";
        case "botorders2":
            return "Use the security computer in the upper floor of the MJ12 Robot Maintenance facility to alter the AI of the security bots.";
        case "BathroomFlags":
            return "Place a flag in Manderley's bathroom enough times.  This can only be done once per visit.  I'm sure this is how you get to the secret ending!";
        case "SiloSlide":
            return "When entering the missile silo, open the vent in the floor and go down the slide that drops you into the water underneath the missile.";
        case "SiloWaterTower":
            return "Go to the top of the water tower at the missile silo.";
        case "TonThirdFloor":
            return "Climb up the elevator shaft in the 'Ton hotel to the third floor.";
        case "Set_flag_helios":
            return "Enter the Aquinas Control Room in sector 4 of Area 51 and engage the primary router by pressing the buttons on each side of the room and using the computer.";
        case "coolant_switch":
            return "Flush the reactor coolant in the coolant area on the bottom floor of Sector 4 of Area 51.";
        case "BlueFusionReactors":
            return "Deactivate blue fusion reactors in Sector 4 of Area 51.  Alex will give you three of the four digits of the code and you have to guess the last one.";
        case "A51UCBlocked":
            return "Close the doors to enough of the UCs in Sector 4 of Area 51.";
        case "VandenbergReactorRoom":
            return "Enter the flooded reactor room in the tunnels underneath Vandenberg.";
        case "VandenbergServerRoom":
            return "Enter the locked server room in the computer section of Vandenberg.";
        case "VandenbergWaterTower":
            return "Climb to the top of the water tower at the back of Vandenberg.";
        case "Cremation":
            return "Kill (or knock out) a chef in Paris, then throw his body either into a fireplace or onto a stovetop.";
        case "OceanLabGreenBeacon":
            return "Swim to the green beacon on top of the Ocean Lab crew module.  The green beacon can be seen out the window of the sub bay on the ocean floor.";
        case "PageTaunt_Played":
            return "After recovering the schematics for the Universal Constructor below the Ocean Lab, talk to Bob Page on the communicator before leaving.";
        case "JerryTheVentGreasel_Dead":
        case "JerryTheVentGreasel_PlayerDead":
            return "Kill the greasel in the vents over the main hall of the MJ12 Lab in Hong Kong.  His name is Jerry and he is a good boy.  You must kill him yourself.";
        case "BiggestFan":
            return "Destroy the large fan in the ventilation ducts of the Brooklyn Naval Yards.";
        case "Sodacan_Activated":
            return "Chug enough cans of soda.";
        case "BallisticArmor_Activated":
            return "Equip enough ballistic armour.";
        case "Flare_Activated":
            return "Light enough flares.";
        case "VialAmbrosia_Activated":
            return "After finding the vial of ambrosia somewhere on the upper decks of the superfreighter, drink it instead of saving it for Stanton Dowd.|n|nThere is also a vial of ambrosia in a small box in the Ocean Lab.";
        case "Binoculars_Activated":
            return "Find and use a pair of binoculars.";
        case "HazMatSuit_Activated":
            return "Use enough hazmat suits.";
        case "AdaptiveArmor_Activated":
            return "Wear enough thermoptic camo.";
        case "DrinkAlcohol":
            return "Get absolutely tanked and drink enough alcohol.  This can be liquor, a forty, or wine.";
        case "ToxicShip":
            return "Find and enter the low, flat boat in the Hong Kong canals.  Note that the interior of the boat is filled with toxic gas.";
        case "ComputerHacked":
            return "Use your computer skills to hack enough computers.";
        case "TechGoggles_Activated":
            return "Wear enough pairs of tech goggles.";
        case "Rebreather_Activated":
            return "Equip enough rebreathers.";
        case "PerformBurder":
            return "Kill enough birds.  These can be either pigeons or seagulls.";
        case "GoneFishing":
            return "Kill enough fish.";
        case "FordSchick_Dead":
        case "FordSchick_PlayerDead":
            return "Kill Ford Schick.  Note that you can do this after rescuing him.  You must kill him yourself.";
        case "ChateauInComputerRoom":
            return "Make your way down to Beth DuClare's computer station in the basement of the DuClare chateau.";
        case "DuClareBedrooms":
            return "Enter both Beth and Nicolette's bedrooms in the DuClare chateau.";
        case "PlayPool":
            return "Sink all 16 balls on enough different pool tables.";
        case "FireExtinguisher_Activated":
            return "Use enough fire extinguishers.";
        case "PianoSongPlayed":
            return "Play enough different songs on a piano.";
        case "PianoSong0Played":
            return "Play the Deus Ex theme song on a piano.  The song needs to be played correctly and all the way through.";
        case "PianoSong7Played":
            return "Play 'The Game' from The 7th Guest on a piano.   The song needs to be played correctly and all the way through.";
        case "PinballWizard":
            msg="Play enough different pinball machines.  ";
            if (mission<=1){
                msg=msg$"There is a machine in Alex's office as well as the break room.";
            } else if (mission<=2){
                msg=msg$"There is a machine in the Underworld Tavern in Hell's Kitchen.";
            } else if (mission<=3){
                msg=msg$"There is a machine in Alex's office and the break room of UNATCO HQ, two machines in the LaGuardia helibase break room, and one in the Airfield barracks.";
            } else if (mission<=4){
                msg=msg$"There is a machine in Alex's office and the break room of UNATCO HQ, as well as one in the Underworld Tavern in Hell's Kitchen.";
            } else if (mission<=5){
                msg=msg$"There is a machine in Alex's office and the break room of UNATCO HQ.";
            } else if (mission<=6){
                msg=msg$"There is a machine in the MJ12 Helibase, one in the MJ12 Lab barracks, one in the Old China Hand, and one in the Lucky Money.";
            } else if (mission<=8){
                msg=msg$"There is a machine in the Underworld Tavern in Hell's Kitchen.";
            } else if (mission<=12){
                msg=msg$"There is a machine in the Comms building in Vandenberg.";
            } else if (mission<=15){
                msg=msg$"There is a machine in the Comm building on the surface, and another one in the break room of Area 51.";
            }
            return msg;
        case "FlowersForTheLab":
            return "Bring some flowers into either level of the Hong Kong MJ12 lab and set them down.";
        case "BurnTrash":
            return "Set enough bags of trash on fire and let them burn until they are destroyed.";
        case "M07MeetJaime_Played":
            return "Meet Jaime in Tracer Tong's hideout in Hong Kong.  Note that he will only meet you in Hong Kong if you ask him to meet you there while you escape from the MJ12 base under UNATCO.";
        case "Terrorist_peeptime":
            return "Watch NSF Troops through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "UNATCOTroop_peeptime":
            return "Watch UNATCO Troopers through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "MJ12Troop_peeptime":
            return "Watch MJ12 Troopers through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "MJ12Commando_peeptime":
            return "Watch MJ12 Commandos through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "PawnAnim_Dance":
            return "Watch someone dance through a pair of binoculars or a scope.  There should be someone vibing in a bar or club.";
        case "BirdWatching":
            return "Watch birds through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "NYEagleStatue_peeped":
            return "Look at the bronze eagle statue in Battery Park through a pair of binoculars or a scope.";
        case "BrokenPianoPlayed":
            return "Damage a piano enough that it will no longer work, then try to play it.";
        case "Supervisor_Paid":
            return "Pay Mr. Hundley for access to the MJ12 Lab in Hong Kong.";
        case "ImageOpened_WaltonSimons":
            return "Find and look at the image displaying Walton Simons' augmentations.";
        case "BethsPainting":
            return "Open (or destroy) the painting in Beth DuClare's bedroom in the DuClare chateau.";
        case "ViewPortraits":
            return "Find and view enough portraits.  These include the picture of Leo Gold (the terrorist commander), the magazine cover showing Bob Page, the image of Joe Greene, and the image of Tiffany Savage.";
        case "ViewSchematics":
            return "Find and view enough schematics.  These include the schematic of the Universal Contructor and the schematic of the blue fusion reactors.";
        case "ViewMaps":
            msg = "Find and view enough maps of different areas.";

            if (mission<=1){
                msg = msg $ "|n|nPaul has a map of Liberty Island available for you before you find the terrorist commander.";
            }

            return msg;
        case "ViewDissection":
            return "Find and view enough images of dissections.  This includes the images of a greasel and a gray being dissected.";
        case "ViewTouristPics":
            return "Find and view enough tourist photos of places.  This includes images of the entrance to the cathedral, images of the catacombs, and the image of the NSF headquarters.";
        case "CathedralUnderwater":
            return "Swim through the underwater tunnel that leads to the Paris cathedral.";
        case "DL_gold_found_Played":
            return "Find the templar gold in the basement of the Paris cathedral.";
        case "12_Email04":
            return "Read the email from Gary Savage with the subject line 'We Must Stand'.  This can be found on the computer in the reception area of the main Vandenberg building, as well as inside the computer area of Vandenberg.";
        case "ReadJCEmail":
            return "Check your email enough times.  This can be done either in UNATCO HQ or in Tracer Tong's hideout.";
        case "02_Email05":
            return "Read Paul's emails and find out what classic movies he has ordered.";
        case "11_Book08":
            return "Read the diary of Adept 34501, the Woman in Black living in the Paris cathedral.";
        case "GasStationCeiling":
            return "Enter the ceiling of the gas station from the roof.";
        case "NicoletteHouseTour":
            return "Escort Nicolette around the Chateau and let her tell you about it.  Potential points of interest include the study, the living room, the upper hallway, Beth's room, the basement, near the back door, and by the maze.";
        case "nico_fireplace":
            return "Access the secret stash behind the fireplace in Nicolette's bedroom in the Chateau.";
        case "dumbwaiter":
            return "Use the DuClare dumbwaiter between the kitchen and Beth's room.";
        case "secretdoor01":
            return "Twist the pulsating light in the Cathedral and open the secret door.";
        case "CathedralLibrary":
            return "Enter the library in the Cathedral.";
        case "DuClareKeys":
            return "Find enough different keys around Chateau DuClare.  Keys include the key to Beths Room, Nicolettes Room, and to the Basement.";
        case "ShipLockerKeys":
            return "Find keys to the lockers on the lower decks of the superfreighter.  The lockers are inside the building underneath the helipad.";
        case "VendingMachineEmpty":
            return "Empty enough vending machines of any type.";
        case "VendingMachineEmpty_Drink":
            return "Empty enough soda vending machines.";
        case "VendingMachineDispense_Candy":
            return "Dispense enough candy bars from vending machines.";
        case "M06JCHasDate":
            return "Rent a companion for the night from the Mamasan in the Lucky Money club.";
        case "Sailor_ClassDeadM6":
            return "Kill enough of the sailors on the top floor of the Lucky Money club.  You must kill them yourself.";
        case "Shannon_Dead":
        case "Shannon_PlayerDead":
            return "Kill Shannon in UNATCO HQ as retribution for her thieving ways.  You must kill her yourself.";
        case "DestroyCapitalism":
            msg = "Kill enough people willing to sell you goods in exchange for money.  You must kill them yourself.|nThe Merchant may be elusive, but he must be eliminated when spotted.|n|n";
            if (mission<=1){
                msg=msg$"Tech Sergeant Kaplan and the woman in the hut on the North Dock both absolutely deserve it.  Shannon is also acting suspicious.";
            } else if (mission<=2){
                msg=msg$"Jordan Shea and Sally in the bar, the doctors in the Free Clinic, and the pimp in the alleys deserve it.";
            } else if (mission<=3){
                msg=msg$"There is a veteran in Battery Park, El Rey and Rock in Brooklyn Bridge Station, and Harold in the hangar.  They all deserve it.  Shannon seems like she might be up to something too.";
            } else if (mission<=4){
                msg=msg$"Jordan Shea and Shannon deserve it.";
            } else if (mission<=5){
                msg=msg$"Sven the mechanic and Shannon both deserve it.";
            } else if (mission<=6){
                msg=msg$"Hong Kong is overflowing with capitalist pigs:|n";
                msg=msg$" - The tea house waiter in the market needs to go.|n";
                msg=msg$" - In the VersaLife offices, you can eliminate Mr. Hundley.|n";
                msg=msg$" - In the canals, you must end the life of the Old China Hand bartender, the man selling maps there, and the smuggler on the boat.|n";
                msg=msg$" - In the Lucky Money, you must eliminate the bartender, the bouncer, the mamasan selling escorts, and the doorgirl.";
            } else if (mission<=8){
                msg=msg$"Jordan Shea needs to go.";
            } else if (mission<=10){
                msg=msg$"Paris is filled with filthy capitalists:|n";
                msg=msg$" - Before the catacombs, you must eliminate Le Merchant and Defoe the arms dealer.|n";
                msg=msg$" - In the catacombs, the man in Vault 2 needs to go.|n";
                msg=msg$" - In the Champs D'Elysees streets, you must end the hostel bartender, Renault the drug dealer, and Kristi in the cafe.|n";
                msg=msg$" - In the club, you can annihilate Camille the dancer, Jean the male bartender, Michelle the female bartender, Antoine the biocell seller, Louis the doorman, Cassandra the woman offering to sell information, and Jocques the worker in the back room.  ";
            } else if (mission<=11){
                msg=msg$"The technician in the metro station needs to be stopped.";
            } else if (mission<=12){
                msg=msg$"The bum living at the Vandenberg gas station deserves it.";
            }
            msg = msg$"|n|n(It's a Simpsons reference)";
            return msg;
        case "Canal_Cop_Dead":
        case "Canal_Cop_PlayerDead":
            return "Kill one of the Chinese Military in the Hong Kong canals standing near the entrance to Tonnochi Road.  You must kill him yourself.";
        case "LightVandalism":
            return "Destroy enough lamps throughout the game.  This might be chandeliers, desk lamps, hanging lights, pool table lights, standing lamps, or table lamps.";
        case "FightSkeletons":
            msg = "Destroy enough femurs or skulls.  Don't let the skeletons rise up!  ";
            if (mission<=4){
                msg=msg$"A skull can be found in the NSF HQ.";
            } else if (mission<=6){
                msg=msg$"A skull can be found in the Hong Kong VersaLife level 1 labs, as well as in Tracer Tong's hideout and in the Wan Chai Market.";
            } else if (mission<=10){
                msg=msg$"The Paris catacombs are just completely loaded with skulls and femurs.";
            } else if (mission<=11){
                msg=msg$"A skull can be found underwater at the Cathedral.";
            } else if (mission<=14){
                msg=msg$"Several skulls and femurs can be found in the OceanLab on the ocean floor.";
            }
            return msg;
        case "TrophyHunter":
            msg = "Destroy enough trophies.  ";
            if (mission<=1){
                msg=msg$"Multiple trophies can be found in UNATCO HQ (in the offices and above ground).";
            } else if (mission<=3){
                msg=msg$"Multiple trophies can be found in UNATCO HQ (in the offices and above ground).  Several can also be found in the LaGuardia Helibase.";
            } else if (mission<=5){ //Mission 4 and 5 both only have trophies at HQ
                msg=msg$"Multiple trophies can be found in UNATCO HQ (in the offices and above ground).";
            } else if (mission<=6){
                msg=msg$"There are many trophies in Hong Kong.  One can be found in the Helibase, another one around the canals, and one on Tonnochi Road.";
            } else if (mission<=10){
                msg=msg$"There is a trophy in Chateau DuClare.";
            }
            return msg;
        case "SlippingHazard":
            msg = "Destroy enough 'Wet Floor' signs, leaving the area unmarked and dangerous.";
            if (mission<=1){
                msg = msg$"  There are signs in UNATCO HQ.";
            } else if (mission<=2){
                msg = msg$"  There is a sign in the hotel.";
            } else if (mission<=3){
                msg = msg$"  There are signs in UNATCO HQ.";
            } else if (mission<=4){
                msg = msg$"  There are signs in UNATCO HQ, and another one in the hotel.";
            } else if (mission<=5){
                msg = msg$"  There are signs in UNATCO HQ.";
            } else if (mission<=6){
                msg = msg$"  There is a sign in the MJ12 Helibase and on Tonnochi road.";
            } else if (mission<=8){
                msg = msg$"  There is a sign in the hotel.";
            } else if (mission<=9){
                msg = msg$"  There are signs on the lower decks of the superfreighter.";
            }
            return msg;
        case "Dehydrated":
            return "Destroy enough water coolers or water fountains.";
        case "PresentForManderley":
            return "Bring Juan Lebedev back to Manderley's office.";
        case "WaltonConvos":
            msg="Have enough conversations with Walton Simons.  ";
            if (mission<=3){
                msg=msg$"He can be found in Manderley's office after destroying the generator.";
            } else if (mission<=4){
                msg=msg$"He can be found in the UNATCO break room talking with Jaime Reyes.";
            } else if (mission<=5){
                msg=msg$"He can be found talking with Manderley via hologram.";
            } else if (mission<=11){
                msg=msg$"He can be found as a hologram in the basement of the cathedral after killing Gunther.";
            } else if (mission<=14){
                msg=msg$"He can be found somewhere around the Ocean Lab after retrieving the Universal Constructor schematics.";
            } else if (mission<=15){
                msg=msg$"He can be found somewhere around Area 51.";
            }
            return msg;
        case "OceanLabShed":
            return "Enter the small square storage building on shore, near the main pedestal leading up to the Ocean Lab sub base.";
        case "DockBlastDoors":
            return "Open enough of the blast doors inside the ammunition storage warehouse in the dockyard.";
        case "ShipsBridge":
            return "Enter the bridge on the top deck of the superfreighter.";
        case "BeatTheMeat":
            return "Destroy enough hanging slaughtered chickens or pigs.";
        case "FamilySquabbleWrapUpGilbertDead_Played":
            return "Talk to Sandra Renton after Gilbert and JoJo both die in Mission 4.  He was a good man...  What a rotten way to die.";
        case "CrackSafe":
            msg="Open enough safes throughout the game.  ";
            if (mission<=2){
                msg=msg$"There is a safe in the control room under Castle Clinton, and another one in the basement office of the NSF Warehouse.";
            } else if (mission<=9){
                msg=msg$"There is a safe in the office in the dockyard, one on the upper decks of the superfreighter, and one in Dowd's mausoleum.";
            }
            return msg;
        case "CliffSacrifice":
            return "Throw a corpse off of the cliffs in Vandenberg.";
        case "MaggieCanFly":
            return "Throw Maggie Chow out of her apartment window.";
        case "VandenbergShaft":
            return "Jump down the shaft leading from the third floor to the first floor, down to near the indoor generator.";
        case "ScienceIsForNerds":
            return "Scientists think they're so much smarter than you.  Show them how smart your weapons are and kill enough of those nerds in lab coats.";
        case "Chef_ClassDead":
            return "Do what needs to be done and kill a chef.  You must kill him yourself.";
        case "un_PrezMeadPic_peepedtex":
            return "Look closely at a picture of President Mead using a pair of binoculars or a scope.  This can be found in UNATCO HQ (both above and below ground).";
        case "un_bboard_peepedtex":
            return "Look at the bulletin board in the UNATCO HQ break room through a pair of binoculars or a scope.";
        case "DrtyPriceSign_A_peepedtex":
            return "Check the gas prices through a pair of binoculars or a scope at the abandoned Vandenberg Gas Station.";
        case "GS_MedKit_01_peepedtex":
            return "Use a pair of binoculars or a scope to find a representation of the Red Cross (A red cross on a white background) in the Vandenberg Gas Station.  Improper use of the emblem is a violation of the Geneva Conventions.";
        case "WatchKeys_cabinet":
            return "Find the key that opens the filing cabinets in the back of the greasel lab in the MJ12 base underneath UNATCO.  This is typically held by whoever is sitting at the desk in the back part of that lab.";
        case "MiguelLeaving":
            return "Tell Miguel that he can slip out on his own.  He definitely can't, but he doesn't know that.";
        case "KarkianDoorsBingo":
            return "Open the doors to the karkian cage near the surgery ward in the MJ12 base underneath UNATCO.";
        case "SuspensionCrate":
            msg = "Open enough suspension crates.  These are the square containers with force fields sealing them.|n|n";
            if (mission<=3){
                msg = msg $ "There is a suspension crate on Lebedev's plane.";
            } else if (mission<=5){
                msg = msg $ "There is a suspension crate in the back of the greasel lab at the MJ12 base under UNATCO.";
            } else if (mission<=10){
                msg = msg $ "There is a suspension crate in the basement of Chateau DuClare.";
            } else if (mission<=11){
                msg = msg $ "There are two suspension crates in Everett's lab.";
            }
            return msg;
        case "ScubaDiver_ClassDead":
            return "Kill enough SCUBA divers in and around the Ocean Lab.  You must kill them yourself.";
        case "ShipRamp":
            return "Raise the ramp to get on board the superfreighter from the docks.  There is a keypad on a box next to the ramp that raises it.";
        case "SuperfreighterProp":
            return "Dive to the propeller at the back of the superfreighter.";
        case "ShipNamePlate":
            return "Use binoculars or a scope to check the name marked on the side of the superfreighter.";
        case "DL_SecondDoors_Played":
            return "You need to open them.|n|nTry to leave the Ocean Lab while the sub-bay doors are closed.";
        case "WhyContainIt":
            return "Destroy a barrel of the gray death virus.  Barrels can be found around the Vandenberg command building, in the Sub Base, and around the Universal Constructor under the Ocean Lab.";
        case "MailModels":
            return "Destroy enough mailboxes.  They can be found in the streets of New York.";
        case "UNATCOHandbook":
            return "Find and read enough UNATCO Handbooks scattered around HQ.";
        case "02_Book06":
            return "Read a guide to basic firearm safety.  Smuggler likes to keep a copy of this lying around somewhere.";
        case "15_Email02":
            return "Read an email discussing the true origin of the Grays.  This can be found on a computer in Sector 3 of Area 51.";
        case "ManderleyMail":
            return "Check Manderley's holomail messages enough times on different visits.";
        case "LetMeIn":
            return "Try to enter the door below the UNATCO Medical office without authorization.";
        case "08_Bulletin02":
            return "Read your wanted poster on a public news terminal when returning to New York.";
        case "SnitchDowd":
            return "Ask Joe Greene or Jordan Shea about Stanton Dowd.";
        case "SewerSurfin":
            return "Throw Joe Greene's body into the water in the New York sewers, like the rat he is.";
        case "SmokingKills":
            return "Destroy enough cigarette vending machines.  Smoking kills!";
        case "PhoneCall":
            msg = "Make phone calls on enough different phones (Either desk phones or pay phones).";
            if (mission <=2){
                msg=msg$"|n|nThere is a desk phone and a pay phone in the Free Clinic.  There are two payphones in the streets.  There is a payphone in the back of the bar.";
            } else if (mission <=3){
                msg=msg$"|n|nThere is a desk phone on Janice's desk in UNATCO HQ.  There are two desk phones in offices in the LaGuardia Helibase.";
            } else if (mission <=4){
                msg=msg$"|n|nThere is a desk phone on Janice's desk in UNATCO HQ.  There are two payphones in the streets.  There is a payphone in the back of the bar.";
            } else if (mission <=5){
                msg=msg$"|n|nThere is a desk phone on Sam's desk in UNATCO HQ.";
            } else if (mission <=6){
                msg=msg$"|n|nThere is a desk phone in the Luminous Path Compound in the Wan Chai Market.";
                msg=msg$"|nThere is a desk phone at the front desk of Queen's Tower on Tonnochi Road.";
                msg=msg$"|nThere is a desk phone on the conference table in the Lucky Money.";
                msg=msg$"|nThere is a desk phone in the conference room on the first level of the MJ12 Lab under VersaLife.";
            } else if (mission <=8){
                msg=msg$"|n|nThere is a desk phone and a pay phone in the Free Clinic.  There are two payphones in the streets.  There is a payphone in the back of the bar.";
            } else if (mission <=9){
                msg=msg$"|n|nThere is a desk phone in an office in the dockyard.";
            } else if (mission<=10){
                msg=msg$"|n|nThere is a desk phone in the office across the street from the entrance to the catacombs in Denfert-Rochereau.";
            }
            return msg;
        case "Area51ElevatorPower":
            return "Enter the main blast doors of the Area 51 bunker and turn on the power to the elevator.";
        case "Area51SleepingPod":
            return "Open enough of the sleeping pods in the entrance to the Area 51 bunker.";
        case "Area51SteamValve":
            return "Close the steam valves in the maintenance tunnels under the floors of the entrance to the Area 51 bunker.";
        case "DockyardLaser":
            return "Deactivate enough of the laser grids in the sewers underneath the dockyards.";
        case "A51CommBuildingBasement":
            return "Go into the hatch in the Command 24 building in Area 51 and enter the basement.";
        case "FreighterHelipad":
            return "Walk up onto the helipad in the lower decks of the superfreighter.";
        case "11_Bulletin01":
            return "Read about the cathedral on a public computer.  These can be found on the streets near the metro, as well as inside the metro.";
        case "A51ExplosiveLocker":
            return "Enter the explosives locker in Area 51.  This is the locked room on the staircase leading down from Helios towards Sector 4.";
        case "A51SeparationSwim":
            return "Go swimming in the tall cylindrical separation tank in Sector 3 of Area 51.";
        case "09_Email08":
            return "Read an email from Captain Zhao's daughter on his computer on the superfreighter.";
        case "Titanic":
            return "Stand on the rail at the front of the superfreighter and hold your arms out...  It feels like you're flying!";
        case "MeetScaredSoldier_Played":
            return "Talk to Xander, the sole surviving soldier hiding out in the building inside the hangar in Area 51.";
        case "DockyardTrailer":
            return "Enter one of the trailers parked in the dockyards.  There is a key to open the trailers somewhere in the dockyards.";
        case "CathedralDisplayCase":
            return "Enter the store display case in the street leading up to the cathedral.";
        case "WIB_ClassDeadM11":
            return "Kill Adept 34501, the Woman in Black living in the cathedral.  You must kill her yourself.";
        case "VandenbergAntenna":
            return "Shoot the tip of the antenna on top of the command center at the Vandenberg Air Force Base.";
        case "VandenbergHazLab":
            return "Enter the Hazard Lab in Vandenberg and disable the electricity that is making the water hazardous.";
        case "WatchKeys_maintenancekey":
            return "Find the maintenance key in the tunnels underneath Vandenberg.";
        case "EnterUC":
            return "Step into enough Universal Constructors throughout the game.  There are five available:|n - One in the computer section of Vandenberg|n - One in the bottom of the Ocean Lab|n - Three in the very bottom of Area 51";
        case "VandenbergComputerElec":
            return "Disable both electrical panels in the computer room of Vandenberg.  There's very little risk!";
        case "VandenbergGasSwim":
            return "Go swimming in the water around the base of the two gas tanks outside of the Vandenberg command center.";
        case "SiloAttic":
            return "Enter the attic in the building outside the fence at the silo.";
        case "SubBaseSatellite":
            return "Shoot one of the satellite dishes on the tower on top of the sub base on shore in California.";
        case "UCVentilation":
            return "Destroy enough ventilation fans near the Universal Contructor under the Ocean Lab.";
        case "OceanLabFloodedStoreRoom":
            return "Swim along the ocean floor to the locked and flooded storage room from in the Ocean Lab.";
        case "OceanLabMedBay":
            return "Enter the med bay in the Ocean Lab.  This room is flooded and off the side of the Karkian Lab.";
        case "WatchDogs":
            return "Watch dogs through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "Cat_peeptime":
            return "Watch cats through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "Binoculars_peeptime":
            return "Watch binoculars through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "roof_elevator":
            return "Use the roof elevator in Denfert-Rochereau right at the start.  There will be a book nearby with the code for the keypad.";
        case "MeetRenault_Played":
            return "Talk to Renault, in the Paris hostel.  He is the man who asks you to steal zyme and will buy it from you.";
        case "SoldRenaultZyme":
            return "Sell at least 5 vials of Zyme to Renault in the Paris hostel.";
        case "WarehouseSewerTunnel":
            return "Swim through the underwater tunnel in the Warehouse District.";
        case "PaulToTong":
            return "Take Paul's corpse from the MJ12 facility under UNATCO to Tracer Tong.";
        case "M04PlayerLikesUNATCO_Played":
            return "Tell Paul you won't send the distress signal after going to the NSF base.";
        case "Canal_Bartender_Question4":
            return "Learn about Olaf Stapledon's \"Last and First Men\" from the Old China Hand bartender.";
        case "M06BartenderQuestion3":
            return "Hear the Lucky Money bartender's ideas about good government.";
        case "M05MeetJaime_Played":
            return "Talk to Jaime while escaping UNATCO and tell him to stay or to join you in Hong Kong.";
        case "jughead_Dead":
        case "jughead_PlayerDead":
            return "Kill El Rey, the leader of the Rooks in the Brooklyn Bridge Station.  You must kill him yourself.";
        case "JoshuaInterrupted_Played":
            return "Learn the login for the computer in the MJ12 guard shack from a trooper's father in a Paris cafe.";
        case "LebedevLived":
            return "Leave the airfield for UNATCO with Juan Lebedev still alive and Anna Navarre dead.";
        case "AimeeLeMerchantLived":
            return "Leave Denfert-Rochereau with Aimee and Le Merchant still alive and conscious.  This is a very difficult goal.";
        case "OverhearLebedev_Played":
            return "Listen to a phone conversation in the airfield helibase between Juan Lebedev and Tracer Tong.  It can be heard in one of the offices.";
        case "ThugGang_AllianceDead":
            return "Slaughter most of the Rooks in the Brooklyn Bridge Station.  You must kill them yourself.";
        case "GiveZyme":
            return "Give zyme to the two junkies in the Brooklyn Bridge Station.";
        case "MarketKid_Unconscious":
        case "MarketKid_PlayerUnconscious":
            return "Knock out Louis Pan, the kid running a protection racket for the Luminous Path in the Wan Chai Market.  You must knock him out yourself.  Crime (sometimes) doesn't pay.";
        case "MaggieLived":
            return "Leave Hong Kong for New York with Maggie Chow still alive and conscious.";
        case "PetKarkians":
            return "Hear me out - Karkians are basically just big puppies...  Give enough of them the head rubs they deserve!  Make sure your hands are empty, or you won't be able to pet anything!";
        case "PetDogs":
            return "That's right, you can pet the dog!  Give enough dogs some petting time.  Make sure your hands are empty, or you won't be able to pet anything!";
        case "PetFish":
            return "Trust me, fish like getting pet.  Max Chen has some fish in his office who would really appreciate it.  Make sure your hands are empty, or you won't be able to pet anything!";
        case "PetBirds":
            return "Ok, maybe you shouldn't pet the birds, but can you help yourself?  Give enough birds a pet!  Make sure your hands are empty, or you won't be able to pet anything!";
        case "PetAnimal_Cat":
            return "Ohhhh, that cat really wants to get pet!  Give enough cats a pet!  Make sure your hands are empty, or you won't be able to pet anything!";
        case "PetAnimal_Greasel":
            return "They might look a bit greasy and very mean, but they sure love head pats!  Give those greasels some pets!  Make sure your hands are empty, or you won't be able to pet anything!";
        case "PetRats":
            return "Get down there and pet enough rats!  Make sure your hands are empty, or you won't be able to pet anything!";
        case "NotABigFan":
            return "Turn off enough ceiling fans through the game.";
        case "MeetInjuredTrooper2_Played":
            return "Talk to the injured trooper in the UNATCO HQ Medical Lab.";
        case "InterviewLocals":
            return "Interview some of the locals around Hell's Kitchen to find out more information about the NSF generator.";
        case "MeetSandraRenton_Played":
            return "Rescue Sandra Renton from Johnny, the pimp who has her cornered in the alley beside the Underworld Tavern.";
        case "TiffanyHeli":
            return "Rescue Tiffany Savage at the abandoned gas station.";
        case "AlarmUnitHacked":
            return "Hack enough Alarm Sounder Panels.  These are the big red wall buttons that set off alarms.";
        case "BuoyOhBuoy":
            return "Destroy enough buoys through the game.";
        case "PlayerPeeped":
            return "Observe yourself in a mirror through binoculars or a scope.";
        case "DangUnstabCond_peepedtex":
            return "Carefully inspect the wording on the Area Condemned signs near the top of the Statue of Liberty using binoculars or a scope.";
        case "pa_TrainSign_D_peepedtex":
            return "Take a close look at the map of the Paris metro lines using binoculars or a scope.";
        case "IOnceKnelt":
            return "Yeah, I can do that too, buddy.  Crouch inside the chapel at the Paris Cathedral.";
        case "GasCashRegister":
            return "Find the cash register in the gas station and check if there's anything left behind.";
        case "LibertyPoints":
            return "Walk around on the foundation of the statue and visit each of the 11 points.";
        case "CherryPickerSeat":
            return "Take a knee in the seat of a cherry picker.";
        case "ForkliftCertified":
            return "Demonstrate your certification and operate a functional forklift.";
        case "ASingleFlask":
            return "Destroy enough flasks through the game.";
        case "FC_EyeTest_peepedtex":
            return "Look at a Snellen Chart (One of those eye exams with the differently sized letters) in the Free Clinic through binoculars or a scope.  Make sure to stand further back so it isn't cheating!";
        case "EmergencyExit":
            return "Know your exit in case of an emergency!  Locate enough emergency exit signs through the game by looking at them through binoculars or a scope.";
        case "Ex51":
            return "Kill enough of the named X51 scientists in Vandenberg.|n|n - Carla Brown on the roof|n - Stacy Webber in front of the hazard lab|n - Tim Baker in the closet near the hazard lab|n"$" - Stephanie Maxwell near the command room doors|n - Tony Mares in the comms building|n - Ben Roper in the command room|n"$" - Latasha Taylor in the command room|n - Stacey Marshall in the command room (with LDDP installed)";
        case "JoyOfCooking":
            return "Read a recipe from a book and experience the joy of cooking!|n|nThere is a recipe for Chinese Silver Loaves in the Wan Chai Market, and a recipe for Coq au Vin in the streets of Paris.";
        case "DolphinJump": // keep height number in sync with DolphinJumpTrigger CreateDolphin
            msg = TrimTrailingZeros(FloatToString(GetRealDistance(160), 1)) @ GetDistanceUnitLong();
            return "Jump " $ msg $ " out of the water.|n|nHow high in the sky can you fly?";
        case "M06HeliSafe":
            return "Open both safes in the Hong Kong Helibase.|n|nThere's one in each Flight Control Deck room.";
        case "JustAFleshWound":
            return "Reduce JC to just a torso and head by losing both arms and both legs.";
        case "LostLimbs":
            return "Every night, I can feel my leg...  and my arm...  even my fingers.|n|nLose enough limbs through the game.";
        default:
            return "Unable to find help text for event '"$event$"'|nReport this to the developers!";
    }
}
//#endregion

static function bool BingoGoalCanFail(string event)
{
    switch(event) {
        case "Sodacan_Activated":
        case "BallisticArmor_Activated":
        case "HazMatSuit_Activated":
        case "AdaptiveArmor_Activated":
        case "DrinkAlcohol":
        case "TechGoggles_Activated":
        case "Rebreather_Activated":
        case "FireExtinguisher_Activated":
        case "ViewPortraits":
        case "ViewSchematics":
        case "ViewMaps":
        case "ImageOpened_WaltonSimons":
        case "ViewDissection":
        case "ViewTouristPics":
            return false;
        default:
            return true;
    }
}

function ExtendedTests()
{
    local string helpText;
    local int i;

    Super.ExtendedTests();

    //Make sure all bingo goals have help text
    for (i=0;i<ArrayCount(bingo_options);i++){
        if (bingo_options[i].event!=""){
            helpText = GetBingoGoalHelpText(bingo_options[i].event,0,False);
            test( InStr(helpText, "Unable to find help text for event") == -1, "Bingo Goal "$bingo_options[i].event$" does not have male JC help text!");
            helpText = GetBingoGoalHelpText(bingo_options[i].event,0,True);
            test( InStr(helpText, "Unable to find help text for event") == -1, "Bingo Goal "$bingo_options[i].event$" does not have female JC help text!");
        }
    }
}

// calculate missions masks with https://jsfiddle.net/2sh7xej0/1/
defaultproperties
{
//#region Bingo Options
    bingo_options(0)=(event="TerroristCommander_PlayerDead",desc="Kill the Terrorist Commander",max=1,missions=2)
	bingo_options(1)=(event="TiffanySavage_PlayerDead",desc="Give it your best shot",max=1,missions=4096)
	bingo_options(2)=(event="PaulDenton_Dead",desc="Let Paul die",max=1,missions=16)
	bingo_options(3)=(event="JordanShea_PlayerDead",desc="Kill Jordan Shea",max=1,missions=276)
	bingo_options(4)=(event="SandraRenton_PlayerDead",desc="Kill Sandra Renton",max=1,missions=4372)
	bingo_options(5)=(event="GilbertRenton_PlayerDead",desc="Kill Gilbert Renton",max=1,missions=20)
	//bingo_options()=(event="AnnaNavarre_Dead",desc="Kill Anna Navarre",max=1,missions=56)
    bingo_options(6)=(event="WarehouseEntered",desc="Enter the underground warehouse in Paris",max=1,missions=1024)
	bingo_options(7)=(event="GuntherHermann_Dead",desc="Kill Gunther Hermann",max=1,missions=2048)
	bingo_options(8)=(event="JoJoFine_PlayerDead",desc="Kill JoJo",max=1,missions=16)
	bingo_options(9)=(event="TobyAtanwe_PlayerDead",desc="Kill Toby Atanwe",max=1,missions=2048)
	bingo_options(10)=(event="Antoine_PlayerDead",desc="Kill Antoine",max=1,missions=1024)
	bingo_options(11)=(event="Chad_PlayerDead",desc="Kill Chad",max=1,missions=1024)
	bingo_options(12)=(event="paris_hostage_Dead",desc="Kill both the hostages in the catacombs",max=2,missions=1024,do_not_scale=true)
	//bingo_options()=(event="hostage_female_PlayerDead",desc="Kill hostage Anna",max=1)
	bingo_options(13)=(event="Hela_PlayerDead",desc="Kill Hela",max=1,missions=1024)
	bingo_options(14)=(event="Renault_PlayerDead",desc="Kill Renault",max=1,missions=1024)
	bingo_options(15)=(event="Labrat_Bum_PlayerDead",desc="Kill Labrat Bum",max=1,missions=64)
	bingo_options(16)=(event="DXRNPCs1_PlayerDead",desc="Kill The Merchant",max=1)
	bingo_options(17)=(event="lemerchant_PlayerDead",desc="Kill Le Merchant",max=1,missions=1024)
	bingo_options(18)=(event="Harold_PlayerDead",desc="Kill Harold the mechanic in the hangar",max=1,missions=8)
	//bingo_options()=(event="Josh_PlayerDead",desc="Kill Josh",max=1)
	//bingo_options()=(event="Billy_PlayerDead",desc="Kill Billy",max=1)
	//bingo_options()=(event="MarketKid_PlayerDead",desc="Kill Louis Pan",max=1)
	bingo_options(19)=(event="aimee_PlayerDead",desc="Kill Aimee",max=1,missions=1024)
	bingo_options(20)=(event="WaltonSimons_Dead",desc="Kill Walton Simons",max=1,missions=49152)
	bingo_options(21)=(event="JoeGreene_PlayerDead",desc="Kill Joe Greene",max=1,missions=276)
    bingo_options(22)=(event="GuntherFreed",desc="Free Gunther from jail",max=1,missions=2)
    bingo_options(23)=(event="BathroomBarks_Played",desc="Embarrass UNATCO",max=1,missions=2)
    //bingo_options()=(event="ManBathroomBarks_Played",desc="Embarass UNATCO",max=1)
    bingo_options(24)=(event="GotHelicopterInfo",desc="A bomb!",max=1,missions=2048)
    bingo_options(25)=(event="JoshFed",desc="Give Josh some food",max=1,missions=4)
    bingo_options(26)=(event="M02BillyDone",desc="Give Billy some food",max=1,missions=4)
    bingo_options(27)=(event="FordSchickRescued",desc="Rescue Ford Schick",max=1,missions=4)
    bingo_options(28)=(event="NiceTerrorist_Dead",desc="Ignore Paul in the 747 Hangar",max=1,missions=8)
    bingo_options(29)=(event="M10EnteredBakery",desc="Enter the bakery",max=1,missions=1024)
    //bingo_options()=(event="AlleyCopSeesPlayer_Played",desc="",max=1)
    bingo_options(30)=(event="FreshWaterOpened",desc="Fix the water",max=1,missions=8)
    #ifdef injections
    bingo_options(31)=(event="PetAnimal_BindName_Starr",desc="Pet Starr in Paris",max=1,missions=1024)
    #else
    bingo_options(31)=(event="assassinapartment",desc="Visit Starr in Paris",max=1,missions=1024)
    #endif
    bingo_options(32)=(event="GaveRentonGun",desc="Give Gilbert a weapon",max=1,missions=16)
    bingo_options(33)=(event="DXREvents_LeftOnBoat",desc="Take the boat out of Battery Park",max=1,missions=4)
    bingo_options(34)=(event="AlleyBumRescued",desc="Rescue the bum on the basketball court",max=1,missions=4)
    bingo_options(35)=(event="FoundScientistBody",desc="Search the canal",max=1,missions=64)
    bingo_options(36)=(event="ClubEntryPaid",desc="Help Mercedes and Tessa",max=1,missions=64)
    bingo_options(37)=(event="M08WarnedSmuggler",desc="Warn Smuggler",max=1,missions=256)
    bingo_options(38)=(event="ShipPowerCut",desc="Help the electrician",max=1,missions=512)
    bingo_options(39)=(event="CamilleConvosDone",desc="Get info from Camille",max=1,missions=1024)
    bingo_options(40)=(event="MeetAI4_Played",desc="Talk to Morpheus",max=1,missions=2048)
    bingo_options(41)=(event="DL_Flooded_Played",desc="Check flooded zone in the ocean lab",max=1,missions=16384)
    bingo_options(42)=(event="JockSecondStory",desc="Get Jock buzzed",max=1,missions=4)
    bingo_options(43)=(event="M07ChenSecondGive_Played",desc="Party with the Triads",max=1,missions=64)
    bingo_options(44)=(event="DeBeersDead",desc="Put Lucius out of his misery",max=1,missions=2048)
    bingo_options(45)=(event="StantonAmbushDefeated",desc="Defend Dowd from the ambush",max=1,missions=256)
    bingo_options(46)=(event="SmugglerDied",desc="Let Smuggler die",max=1,missions=256)
    bingo_options(47)=(event="GaveDowdAmbrosia",desc="Give Dowd Ambrosia",max=1,missions=512)
    bingo_options(48)=(event="JockBlewUp",desc="Let Jock die",max=1,missions=2048)
    bingo_options(49)=(event="SavedPaul",desc="Save Paul",max=1,missions=16)
    bingo_options(50)=(event="nsfwander",desc="Save Miguel",max=1,missions=32)
    bingo_options(51)=(event="MadeBasket",desc="Sign up for the Knicks",max=1,missions=276)
    bingo_options(52)=(event="BoughtClinicPlan",desc="Buy the full treatment plan in the clinic",max=1,missions=4)
    bingo_options(53)=(event="ExtinguishFire",desc="Extinguish yourself with running water",max=1,missions=22398)
    bingo_options(54)=(event="SubwayHostagesSaved",desc="Save both hostages in the subway",max=1,missions=4)
    bingo_options(55)=(event="HotelHostagesSaved",desc="Save all hostages in the hotel",max=1,missions=4)
    bingo_options(56)=(event="SilhouetteHostagesAllRescued",desc="Save both hostages in the catacombs",max=1,missions=1024)
    bingo_options(57)=(event="JosephManderley_PlayerDead",desc="Kill Joseph Manderley",max=1,missions=32)
    bingo_options(58)=(event="MadeItToBP",desc="Escape to Battery Park",max=1,missions=16)
    bingo_options(59)=(event="MeetSmuggler",desc="Meet Smuggler",max=1,missions=276)
    bingo_options(60)=(event="SickMan_PlayerDead",desc="Kill the sick man who wants to die",max=1,missions=12)
    bingo_options(61)=(event="M06PaidJunkie",desc="Help the junkie on Tonnochi Road",max=1,missions=64)
    bingo_options(62)=(event="M06BoughtVersaLife",desc="Get maps of the VersaLife building",max=1,missions=64)
    bingo_options(63)=(event="FlushToilet",desc="Use %s toilets",desc_singular="Use a toilet",max=30,missions=8062)
    bingo_options(64)=(event="FlushUrinal",desc="Use %s urinals",desc_singular="Use a urinal",max=20,missions=22398)
    bingo_options(65)=(event="MeetTimBaker_Played",desc="Free Tim from the Vandenberg storage room",max=1,missions=4096)
    bingo_options(66)=(event="MeetDrBernard_Played",desc="Find the man locked in the bathroom",max=1,missions=16384)
    bingo_options(67)=(event="KnowsGuntherKillphrase",desc="Learn Gunther's Killphrase",max=1,missions=1056)
    bingo_options(68)=(event="KnowsAnnasKillphrase",desc="Learn both parts of Anna's Killphrase",max=2,missions=32,do_not_scale=true)
    bingo_options(69)=(event="Area51FanShaft",desc="Jump!  You can make it!",max=1,missions=32768)
    bingo_options(70)=(event="PoliceVaultBingo",desc="Visit the Hong Kong police vault",max=1,missions=64)
    bingo_options(71)=(event="SunkenShip",desc="Enter the sunken ship at Liberty Island",max=1,missions=2)
    bingo_options(72)=(event="SpinShipsWheel",desc="Spin %s ship's wheels",desc_singular="Spin a ship's wheel",max=3,missions=578)
    bingo_options(73)=(event="ActivateVandenbergBots",desc="Activate both of the bots at Vandenberg",max=2,missions=4096,do_not_scale=true)
    bingo_options(74)=(event="TongsHotTub",desc="Take a dip in Tracer Tong's hot tub",max=1,missions=64)
    bingo_options(75)=(event="JocksToilet",desc="Use Jock's toilet",max=1,missions=64)
    bingo_options(76)=(event="Greasel_ClassDead",desc="Kill %s Greasels",desc_singular="Kill a Greasel",max=5,missions=50272)
    bingo_options(77)=(event="support1",desc="Blow up a gas station",max=1,missions=4096)
    bingo_options(78)=(event="UNATCOTroop_ClassDead",desc="Kill %s UNATCO Troopers",desc_singular="Kill a UNATCO Trooper",max=15,missions=318)
    bingo_options(79)=(event="Terrorist_ClassDead",desc="Kill %s NSF Terrorists",desc_singular="Kill an NSF Terrorist",max=15,missions=46)
    bingo_options(80)=(event="MJ12Troop_ClassDead",desc="Kill %s MJ12 Troopers",desc_singular="Kill an MJ12 Trooper",max=25,missions=57188)
    bingo_options(81)=(event="MJ12Commando_ClassDead",desc="Kill %s MJ12 Commandos",desc_singular="Kill an MJ12 Commando",max=10,missions=56384)
    bingo_options(82)=(event="Karkian_ClassDead",desc="Kill %s Karkians",desc_singular="Kill a Karkian",max=5,missions=49248)
    bingo_options(83)=(event="MilitaryBot_ClassDead",desc="Destroy %s Military Bots",desc_singular="Destroy a Military Bot",max=5,missions=24176)
    bingo_options(84)=(event="VandenbergToilet",desc="Use the only toilet in Vandenberg",max=1,missions=4096)
    bingo_options(85)=(event="BoatEngineRoom",desc="Check the power levels on the canal boat",max=1,missions=64)
    bingo_options(86)=(event="SecurityBot2_ClassDead",desc="Destroy %s Walking Security Bots",desc_singular="Destroy a Walking Security Bot",max=5,missions=57202)
    bingo_options(87)=(event="SecurityBotSmall_ClassDead",desc="Destroy %s commercial grade Security Bots",desc_singular="Destroy a commercial grade Security Bot",max=10,missions=35102)
    bingo_options(88)=(event="SpiderBot_ClassDead",desc="Destroy %s Spider Bots",desc_singular="Destroy a Spider Bot",max=15,missions=53824)
    bingo_options(89)=(event="HumanStompDeath",desc="Stomp %s humans to death",desc_singular="Stomp a human to death",max=3)
    bingo_options(90)=(event="Rat_ClassDead",desc="Kill %s rats",desc_singular="Kill a rat",max=30,missions=53118)
    bingo_options(91)=(event="UNATCOTroop_ClassUnconscious",desc="Knock out %s UNATCO Troopers",desc_singular="Knock out a UNATCO Trooper",max=15,missions=318)
    bingo_options(92)=(event="Terrorist_ClassUnconscious",desc="Knock out %s NSF Terrorists",desc_singular="Knock out an NSF Terrorist",max=15,missions=46)
    bingo_options(93)=(event="MJ12Troop_ClassUnconscious",desc="Knock out %s MJ12 Troopers",desc_singular="Knock out an MJ12 Trooper",max=25,missions=57188)
    bingo_options(94)=(event="MJ12Commando_ClassUnconscious",desc="Knock out %s MJ12 Commandos",desc_singular="Knock out an MJ12 Commando",max=2,missions=56384)
    bingo_options(95)=(event="purge",desc="Release the gas in the MJ12 Helibase",max=1,missions=64)
    bingo_options(96)=(event="ChugWater",desc="Chug water %s times",desc_singular="Chug water",max=30,mission=40830)
#ifndef vmd
    bingo_options(97)=(event="ChangeClothes",desc="Change clothes at %s different clothes racks",desc_singular="Change clothes at a clothes rack",max=3,missions=852)
#endif
    bingo_options(98)=(event="arctrigger",desc="Shut off the electricity at the airfield",max=1,missions=8)
#ifndef hx
    bingo_options(99)=(event="LeoToTheBar",desc="Bring the terrorist commander to a bar",max=1,missions=17686)
#endif
    bingo_options(100)=(event="KnowYourEnemy",desc="Read %s Know Your Enemy bulletins",desc_singular="Read a Know Your Enemy bulletin",max=6,missions=26)
    bingo_options(101)=(event="09_NYC_DOCKYARD--796967769",desc="Learn Jenny's phone number",max=1,missions=512)
    bingo_options(102)=(event="JacobsShadow",desc="Read %s parts of Jacob's Shadow",desc_singular="Read one part of Jacob's Shadow",max=4,missions=38492)
    bingo_options(103)=(event="ManWhoWasThursday",desc="Read %s parts of The Man Who Was Thursday",desc_singular="Read one part of The Man Who Was Thursday",max=4,missions=54300)
    bingo_options(104)=(event="GreeneArticles",desc="Read %s newspaper articles by Joe Greene",desc_singular="Read a newspaper article by Joe Greene",max=4,missions=270)
    bingo_options(105)=(event="MoonBaseNews",desc="Read news about the Lunar Mining Complex",max=1,missions=76)
    bingo_options(106)=(event="06_Datacube05",desc="Learn Maggie Chow's Birthday",max=1,missions=64)
    bingo_options(107)=(event="Gray_ClassDead",desc="Kill %s Grays",desc_singular="Kill a Gray",max=5,missions=32832)
    bingo_options(108)=(event="CloneCubes",desc="Read about %s clones in Area 51",desc_singular="Read about a clone in Area 51",max=4,missions=32768)
    bingo_options(109)=(event="blast_door_open",desc="Open the blast doors at Area 51",max=1,missions=32768)
    bingo_options(110)=(event="SpinningRoom",desc="Pass through the spinning room",max=1,missions=512)
    bingo_options(111)=(event="MolePeopleSlaughtered",desc="Slaughter the Mole People",max=1,missions=8)
    bingo_options(112)=(event="surrender",desc="Make the NSF surrender in the tunnels",max=1,missions=8)
    bingo_options(113)=(event="nanocage",desc="Open the cages in the UNATCO MJ12 Lab",max=1,missions=32)
#ifdef vanilla
    bingo_options(114)=(event="unbirth",desc="Return to the tube that spawned you",max=1,missions=32768)
#endif
    bingo_options(115)=(event="StolenAmbrosia",desc="Find %s stolen barrels of Ambrosia",desc_singular="Find a stolen barrel of Ambrosia",max=3,missions=12)
    bingo_options(116)=(event="AnnaKilledLebedev",desc="Let Anna kill Lebedev",max=1,missions=8)
    bingo_options(117)=(event="PlayerKilledLebedev",desc="Kill Lebedev yourself",max=1,missions=8)
    bingo_options(118)=(event="JuanLebedev_PlayerUnconscious",desc="Knock out Lebedev",max=1,missions=8)
    bingo_options(119)=(event="BrowserHistoryCleared",desc="Clear your browser history before quitting",max=1,missions=32)
    bingo_options(120)=(event="AnnaKillswitch",desc="Use Anna's Killphrase",max=1,missions=32)
    bingo_options(121)=(event="AnnaNavarre_DeadM3",desc="Kill Anna Navarre in Mission 3",max=1,missions=8)
    bingo_options(122)=(event="AnnaNavarre_DeadM4",desc="Kill Anna Navarre in Mission 4",max=1,missions=16)
    bingo_options(123)=(event="AnnaNavarre_DeadM5",desc="Kill Anna Navarre in Mission 5",max=1,missions=32)
    bingo_options(124)=(event="SimonsAssassination",desc="Let Walton lose his patience",max=1,missions=8)
    bingo_options(125)=(event="AlliesKilled",desc="Kill %s innocents",desc_singular="Kill an innocent",max=15)
    bingo_options(126)=(event="MaySung_PlayerDead",desc="Kill Maggie Chow's maid",max=1,missions=64)
    bingo_options(127)=(event="MostWarehouseTroopsDead",desc="Eliminate the UNATCO troops defending NSF HQ",max=1,missions=16)
    bingo_options(128)=(event="CleanerBot_ClassDead",desc="Destroy %s Cleaner Bots",desc_singular="Destroy a Cleaner Bot",max=5,missions=286)
    bingo_options(129)=(event="MedicalBot_ClassDead",desc="Destroy %s Medical Bots",desc_singular="Destroy a Medical Bot",max=3)
    bingo_options(130)=(event="RepairBot_ClassDead",desc="Destroy %s Repair Bots",desc_singular="Destroy a Repair Bot",max=3)
    bingo_options(131)=(event="DrugDealer_PlayerDead",desc="Kill the Drug Dealer in Brooklyn Bridge Station",max=1,missions=8)
    bingo_options(132)=(event="botordertrigger",desc="The Smuggler is whacked-out paranoid",max=1,missions=276)
#ifdef injections
    bingo_options(133)=(event="IgnitedPawn",desc="Set %s people on fire",desc_singular="Set someone on fire",max=15)
    bingo_options(134)=(event="GibbedPawn",desc="Blow up %s people",desc_singular="Blow someone up",max=15)
#endif
    bingo_options(135)=(event="IcarusCalls_Played",desc="Take a phone call from Icarus in Paris",max=1,missions=1024)
    bingo_options(136)=(event="AlexCloset",desc="Go into Alex's closet",max=1,missions=58)
    bingo_options(137)=(event="BackOfStatue",desc="Climb to the balcony on the back of the statue",max=1,missions=2)
    bingo_options(138)=(event="CommsPit",desc="Check the SATCOM wiring %s times",desc_singular="Check the SATCOM wiring",max=3,missions=58)
    bingo_options(139)=(event="StatueHead",desc="Visit the head of the Statue of Liberty",max=1,missions=2)
    bingo_options(140)=(event="CraneControls",desc="Use the dockside crane controls",max=1,missions=512)
    bingo_options(141)=(event="CraneTop",desc="Visit the end of both cranes on the freighter",max=2,missions=512)
    bingo_options(142)=(event="CaptainBed",desc="Jump on the freighter captains bed",max=1,missions=512)
    bingo_options(143)=(event="FanTop",desc="Get blown to the top of the freighter ventilation shaft",max=1,missions=512)
    bingo_options(144)=(event="LouisBerates",desc="Sneak behind the Porte De L'Enfer door man",max=1,missions=1024)
    bingo_options(145)=(event="EverettAquarium",desc="Go for a swim in Everett's aquarium",max=1,missions=2048)
    bingo_options(146)=(event="TrainTracks",desc="Jump on to the train tracks in Paris",max=1,missions=2048)
    bingo_options(147)=(event="OceanLabCrewChamber",desc="Visit %s crew chambers in the Ocean Lab",desc_singular="Visit a crew chamber in the Ocean Lab",max=4,missions=16384)
    bingo_options(148)=(event="HeliosControlArms",desc="Jump down the control arms in Helios' chamber",max=1,missions=32768)
    bingo_options(149)=(event="TongTargets",desc="Use the shooting range in Tong's base",max=1,missions=64)
    bingo_options(150)=(event="WanChaiStores",desc="Visit all of the stores in the Wan Chai market",max=5,missions=64,do_not_scale=true)
    bingo_options(151)=(event="HongKongBBall",desc="Shoot some hoops in Hong Kong",max=1,missions=64)
    bingo_options(152)=(event="CanalDrugDeal",desc="Walk in on a drug deal in progress",max=1,missions=64)
    bingo_options(153)=(event="HongKongGrays",desc="Enter the Hong Kong Gray enclosure",max=1,missions=64)
    bingo_options(154)=(event="EnterQuickStop",desc="Enter the Quick Stop in Hong Kong",max=1,missions=64)
    bingo_options(155)=(event="LuckyMoneyFreezer",desc="Enter the Lucky Money freezer",max=1,missions=64)
    bingo_options(156)=(event="TonnochiBillboard",desc="Get onto the billboard over Tonnochi road",max=1,missions=64)
    bingo_options(157)=(event="AirfieldGuardTowers",desc="Visit %s of the Airfield guard towers",max=3,missions=8)
    bingo_options(158)=(event="mirrordoor",desc="Access Smuggler's secret stash",max=1,missions=276)
    bingo_options(159)=(event="MolePeopleWater",desc="Bathe in the Mole People water supply",max=1,missions=8)
    bingo_options(160)=(event="botorders2",desc="Alter the bot AI in the MJ12 base under UNATCO",max=1,missions=32)
    bingo_options(161)=(event="BathroomFlags",desc="Put a flag in Manderley's bathroom %s times",desc_singular="Put a flag in Manderley's bathroom",max=3,missions=58)
    bingo_options(162)=(event="SiloSlide",desc="Take the silo slide",max=1,missions=16384)
    bingo_options(163)=(event="SiloWaterTower",desc="Climb the water tower at the silo",max=1,missions=16384)
    bingo_options(164)=(event="TonThirdFloor",desc="Go to the third floor of the 'Ton",max=1,missions=276)
    bingo_options(165)=(event="Set_flag_helios",desc="Engage the Aquinas primary router",max=1,missions=32768)
    bingo_options(166)=(event="coolant_switch",desc="Flush the reactor coolant",max=1,missions=32768)
    bingo_options(167)=(event="BlueFusionReactors",desc="Deactivate %s blue fusion reactors",desc_singular="Deactivate a blue fusion reactor",max=4,missions=32768)
    bingo_options(168)=(event="A51UCBlocked",desc="Close the doors to %s UCs in Area 51",desc_singular="Close the door to a UC in Area 51",max=3,missions=32768)
    bingo_options(169)=(event="VandenbergReactorRoom",desc="Enter the reactor room in the Vandenberg tunnels",max=1,missions=4096)
    bingo_options(170)=(event="VandenbergServerRoom",desc="Enter the server room in the Vandenberg control center",max=1,missions=4096)
    bingo_options(171)=(event="VandenbergWaterTower",desc="Climb the water tower in Vandenberg",max=1,missions=4096)
#ifndef hx
    bingo_options(172)=(event="Cremation",desc="Cook the cook",max=1,missions=2048)
#endif
    bingo_options(173)=(event="OceanLabGreenBeacon",desc="Swim to the green beacon",max=1,missions=16384)
    bingo_options(174)=(event="PageTaunt_Played",desc="Let Bob Page taunt you in the Ocean Lab",max=1,missions=16384)
    //bingo_options()=(event="M11WaltonHolo_Played",desc="Talk to Walton Simons after defeating Gunther",max=1,missions=2048)
    bingo_options(175)=(event="JerryTheVentGreasel_PlayerDead",desc="Kill Jerry the Vent Greasel",max=1,missions=64)
    bingo_options(176)=(event="BiggestFan",desc="Destroy your biggest fan",max=1,missions=512)
    bingo_options(177)=(event="Sodacan_Activated",desc="Drink %s cans of soda",desc_singular="Drink a can of soda",max=75)
    bingo_options(178)=(event="BallisticArmor_Activated",desc="Use %s ballistic armors",desc_singular="Use ballistic armor",max=3,missions=57212)
    bingo_options(179)=(event="Flare_Activated",desc="Light %s flares",desc_singular="Light a flare",max=15)
    bingo_options(180)=(event="VialAmbrosia_Activated",desc="Take a sip of Ambrosia",max=1,missions=16896)
    bingo_options(181)=(event="Binoculars_Activated",desc="Take a peek through binoculars",max=1)
    bingo_options(182)=(event="HazMatSuit_Activated",desc="Use %s hazmat suits",desc_singular="Use a hazmat suit",max=3,missions=54866)
    bingo_options(183)=(event="AdaptiveArmor_Activated",desc="Use %s thermoptic mamos",desc_singular="Use thermoptic camo",max=3,missions=55132)
    bingo_options(184)=(event="DrinkAlcohol",desc="Drink %s bottles of alcohol",desc_singular="Drink a bottle of alcohol",max=75)
    bingo_options(185)=(event="ToxicShip",desc="Enter the toxic ship",max=1,missions=64)
    bingo_options(186)=(event="ComputerHacked",desc="Hack %s computers",desc_singular="Hack a computer",max=10)
    bingo_options(187)=(event="TechGoggles_Activated",desc="Use %s tech goggles",desc_singular="Use tech goggles",max=3,missions=54346)
    bingo_options(188)=(event="Rebreather_Activated",desc="Use %s rebreathers",desc_singular="Use a rebreather",max=3,missions=55400)
    bingo_options(189)=(event="PerformBurder",desc="Hunt %s birds",desc_singular="Hunt a bird",max=10,missions=24446)
    bingo_options(190)=(event="GoneFishing",desc="Kill %s fish",max=10,missions=18510)
    bingo_options(191)=(event="FordSchick_PlayerDead",desc="Kill Ford Schick",max=1,missions=276)
    bingo_options(192)=(event="ChateauInComputerRoom",desc="Find Beth's secret routing station",max=1,missions=1024)
    bingo_options(193)=(event="DuClareBedrooms",desc="Visit both bedrooms in the DuClare Chateau",max=2,missions=1024,do_not_scale=true)
    bingo_options(194)=(event="PlayPool",desc="Sink all the pool balls %s times",desc_singular="Sink all the pool balls",max=3,missions=33116)
    bingo_options(195)=(event="FireExtinguisher_Activated",desc="Use %s fire extinguishers",desc_singular="Use a fire extinguisher",max=10)
    bingo_options(196)=(event="PianoSongPlayed",desc="Play %s different songs on the piano",desc_singular="Play a song on the piano",max=5,missions=64)
    bingo_options(197)=(event="PianoSong0Played",desc="Play the theme song on the piano",max=1,missions=64)
    bingo_options(198)=(event="PianoSong7Played",desc="Stauf Says...",max=1,missions=64)
    bingo_options(199)=(event="PinballWizard",desc="Play %s different pinball machines",desc_singular="Play a pinball machine",max=10,missions=37246)
    bingo_options(200)=(event="FlowersForTheLab",desc="Bring some flowers to brighten up the lab",max=1,missions=64)
    bingo_options(201)=(event="BurnTrash",desc="Burn %s bags of trash",desc_singular="Burn a bag of trash",max=25,missions=57182)
    bingo_options(202)=(event="M07MeetJaime_Played",desc="Meet Jaime in Hong Kong",max=1,missions=96)
    bingo_options(203)=(event="Terrorist_peeptime",desc="Watch Terrorists for %s seconds",desc_singular="Watch Terrorists for 1 second",max=30,missions=46)
    bingo_options(204)=(event="UNATCOTroop_peeptime",desc="Watch UNATCO Troopers for %s seconds",desc_singular="Watch UNATCO Troopers for 1 second",max=30,missions=318)
    bingo_options(205)=(event="MJ12Troop_peeptime",desc="Watch MJ12 Troopers for %s seconds",desc_singular="Watch MJ12 Troopers for 1 second",max=30,missions=57188)
    bingo_options(206)=(event="MJ12Commando_peeptime",desc="Watch MJ12 Commandos for %s seconds",desc_singular="Watch MJ12 Commandos for 1 second",max=15,missions=56384)
    bingo_options(207)=(event="PawnAnim_Dance",desc="You can dance if you want to",max=1,missions=1364)
    bingo_options(208)=(event="BirdWatching",desc="Watch birds for %s seconds",desc_singular="Watch birds for 1 second",max=30,missions=24446)
    bingo_options(209)=(event="NYEagleStatue_peeped",desc="Look at a bronze eagle statue",max=1,missions=28)
    bingo_options(210)=(event="BrokenPianoPlayed",desc="Play a broken piano",max=1,missions=64)
    bingo_options(211)=(event="Supervisor_Paid",desc="Pay for access to the VersaLife labs",max=1,missions=64)
    bingo_options(212)=(event="ImageOpened_WaltonSimons",desc="Look at Walton Simons' nudes",max=1,missions=544)
    bingo_options(213)=(event="BethsPainting",desc="Admire Beth DuClare's favourite painting",max=1,missions=1024)
#ifndef hx
    bingo_options(214)=(event="ViewPortraits",desc="Look at %s portraits",desc_singular="Look at a portrait",max=2,missions=4890)
    bingo_options(215)=(event="ViewSchematics",desc="Inspect a schematic",max=1,missions=49152)
    bingo_options(216)=(event="ViewMaps",desc="View %s maps",desc_singular="View a map",max=6,missions=56686)
    bingo_options(217)=(event="ViewDissection",desc="Have a look at a dissection report",max=1,missions=96)
    bingo_options(218)=(event="ViewTouristPics",desc="Look at a tourist photo",max=1,missions=2576)
#endif
    bingo_options(219)=(event="CathedralUnderwater",desc="Swim through the underwater tunnel at the cathedral",max=1,missions=2048)
    bingo_options(220)=(event="DL_gold_found_Played",desc="Recover the Templar gold",max=1,missions=2048)
    bingo_options(221)=(event="12_Email04",desc="Read a motivational email from Gary",max=1,missions=4096)
    bingo_options(222)=(event="ReadJCEmail",desc="Check your email %s times",desc_singular="Check your email",max=3,missions=122)
    bingo_options(223)=(event="02_Email05",desc="Paul's Classic Movies",max=1,missions=4)
    bingo_options(224)=(event="11_Book08",desc="Read Adept 34501's diary",max=1,missions=2048)
    bingo_options(225)=(event="GasStationCeiling",desc="Access the ceiling of a gas station",max=1,missions=4096)
    bingo_options(226)=(event="NicoletteHouseTour",desc="Tour 5 parts of Chateau DuClare with Nicolette",max=5,missions=1024,do_not_scale=true)
    bingo_options(227)=(event="nico_fireplace",desc="Access Nicolette's secret stash",max=1,missions=1024)
    bingo_options(228)=(event="dumbwaiter",desc="Not so dumb now!",max=1,missions=1024)
    bingo_options(229)=(event="secretdoor01",desc="Open the secret door in the cathedral",max=1,missions=2048)
    bingo_options(230)=(event="CathedralLibrary",desc="Worth its weight in gold",max=1,missions=2048)
    bingo_options(231)=(event="DuClareKeys",desc="Get 3 unique keys around Chateau DuClare",max=3,missions=1024,do_not_scale=true)
    bingo_options(232)=(event="ShipLockerKeys",desc="Collect %s locker keys inside the super freighter",desc_singular="Collect a locker key inside the super freighter",max=2,missions=512)
    bingo_options(233)=(event="VendingMachineEmpty",desc="All Sold Out!",max=18,missions=40830)
    bingo_options(234)=(event="VendingMachineEmpty_Drink",desc="I Wanted Orange!",max=12,missions=38782)
    bingo_options(235)=(event="VendingMachineDispense_Candy",desc="Ooh, a piece of candy!",max=100,missions=36478)
    bingo_options(236)=(event="M06JCHasDate",desc="Pay for some company",max=1,missions=64)
    bingo_options(237)=(event="Sailor_ClassDeadM6",desc="I SPILL %s DRINKS!",desc_singular="I SPILL MY DRINK!",max=5,missions=64)
    bingo_options(238)=(event="Shannon_PlayerDead",desc="Kill the thief in UNATCO",max=1,missions=58)
    bingo_options(239)=(event="DestroyCapitalism",desc="MUST.  CRUSH.  %s CAPITALISTS.",desc_singular="MUST.  CRUSH.  CAPITALIST.",max=10,missions=7550)
    bingo_options(240)=(event="Canal_Cop_PlayerDead",desc="Not advisable to visit the canals at night",max=1,missions=64)
    bingo_options(241)=(event="LightVandalism",desc="Perform %s acts of light vandalism",desc_singular="Perform 1 act of light vandalism",max=40,missions=57214)
    bingo_options(242)=(event="FightSkeletons",desc="Destroy %s skeleton parts",desc_singular="Destroy 1 skeleton part",max=10,missions=19536)
    bingo_options(243)=(event="TrophyHunter",desc="Trophy Hunter",max=10,missions=1146)
    bingo_options(244)=(event="SlippingHazard",desc="Create %s potential slipping hazards",desc_singular="Create 1 potential slipping hazard",max=5,missions=894)
    bingo_options(245)=(event="Dehydrated",desc="Stay dehydrated %s times",desc_singular="Stay dehydrated 1 time",max=15,missions=40830)
#ifndef vmd
    bingo_options(246)=(event="PresentForManderley",desc="Bring a present to Manderley",max=1,missions=24)
#endif
    bingo_options(247)=(event="WaltonConvos",desc="Have %s conversations with Walton Simons",desc_singular="Have a conversation with Walton Simons",max=3,missions=51256)
    bingo_options(248)=(event="OceanLabShed",desc="Enter the shed on shore at the Ocean Lab",max=1,missions=16384)
    bingo_options(249)=(event="DockBlastDoors",desc="Open %s bunker blast doors in the dockyard",desc_singular="Open a bunker blast door in the dockyard",max=3,missions=512)
    bingo_options(250)=(event="ShipsBridge",desc="Enter the bridge of the super freighter",max=1,missions=512)
    bingo_options(251)=(event="BeatTheMeat",desc="Beat the meat %s times",desc_singular="Beat the meat",max=15,missions=2624)
    bingo_options(252)=(event="FamilySquabbleWrapUpGilbertDead_Played",desc="What a shame",max=1,missions=16)
    bingo_options(253)=(event="CrackSafe",desc="Crack %s safes",desc_singular="Crack a safe",max=3,missions=516)
    bingo_options(254)=(event="CliffSacrifice",desc="Sacrifice a body off of a cliff",max=1,missions=4096)
    bingo_options(255)=(event="MaggieCanFly",desc="Teach Maggie Chow how to fly",max=1,missions=64)
    bingo_options(256)=(event="VandenbergShaft",desc="Jump down the Vandenberg shaft",max=1,missions=4096)
    bingo_options(257)=(event="ScienceIsForNerds",desc="Science is for nerds",max=10,missions=20576)
    bingo_options(258)=(event="Chef_ClassDead",desc="My Name Chef",max=1,missions=3072)
    bingo_options(259)=(event="un_PrezMeadPic_peepedtex",desc="Have a look at the anime president",max=1,missions=58)
    bingo_options(260)=(event="un_bboard_peepedtex",desc="Check the bulletin board at UNATCO HQ",max=1,missions=58)
    bingo_options(261)=(event="DrtyPriceSign_A_peepedtex",desc="Check the gas prices in Vandenberg",max=1,missions=4096)
    bingo_options(262)=(event="GS_MedKit_01_peepedtex",desc="Spot a war crime",max=1,missions=4096)
    bingo_options(263)=(event="WatchKeys_cabinet",desc="Find the keys to the MIB filing cabinet",max=1,missions=32)
    bingo_options(264)=(event="MiguelLeaving",desc="Miguel can make it on his own",max=1,missions=32)
    bingo_options(265)=(event="KarkianDoorsBingo",desc="Open the Karkian cage in the MJ12 Lab",max=1,missions=32)
    bingo_options(266)=(event="SuspensionCrate",desc="Open %s Suspension Crates",desc_singular="Open a Suspension Crate",max=3,missions=3112)
    bingo_options(267)=(event="ScubaDiver_ClassDead",desc="Kill %s SCUBA Divers",desc_singular="Kill a SCUBA Diver",max=3,missions=16384)
    bingo_options(268)=(event="ShipRamp",desc="Raise the ramp to the super freighter",max=1,missions=512)
    bingo_options(269)=(event="SuperfreighterProp",desc="Props to you",max=1,missions=512)
    bingo_options(270)=(event="ShipNamePlate",desc="Check the name on the super freighter",max=1,missions=512)
    bingo_options(271)=(event="DL_SecondDoors_Played",desc="The sub-bay doors are closed",max=1,missions=16384)
    bingo_options(272)=(event="WhyContainIt",desc="Why contain it?",max=1,missions=20480)
    bingo_options(273)=(event="MailModels",desc="But why mail models?",max=3,missions=276)
    bingo_options(274)=(event="UNATCOHandbook",desc="Rules and Regulations",max=4,missions=26)
    bingo_options(275)=(event="02_Book06",desc="Learn basic firearm safety",max=1,missions=276)
    bingo_options(276)=(event="15_Email02",desc="The truth is out there",max=1,missions=32768)
    bingo_options(277)=(event="ManderleyMail",desc="Check Manderley's holomail %s times",desc_singular="Check Manderley's holomail",max=2,missions=58)
#ifndef revision
    bingo_options(278)=(event="LetMeIn",desc="Let me in!",max=1,missions=26)
#endif
    bingo_options(279)=(event="08_Bulletin02",desc="Most Wanted",max=1,missions=256)
    bingo_options(280)=(event="SnitchDowd",desc="Snitches get stitches",max=1,missions=256)
    bingo_options(281)=(event="SewerSurfin",desc="Sewer Surfin'",max=1,missions=276)
    bingo_options(282)=(event="SmokingKills",desc="Smoking Kills",max=5,missions=3420)
    bingo_options(283)=(event="PhoneCall",desc="Make %s phone calls",desc_singular="Make a phone call",max=5,missions=1916)
    bingo_options(284)=(event="Area51ElevatorPower",desc="Power the elevator in Area 51",max=1,missions=32768)
    bingo_options(285)=(event="Area51SleepingPod",desc="Open %s sleeping pods in Area 51",desc_singular="Open a sleeping pod in Area 51",max=4,missions=32768)
    bingo_options(286)=(event="Area51SteamValve",desc="Close the steam valves in Area 51",max=2,missions=32768,do_not_scale=true)
    bingo_options(287)=(event="DockyardLaser",desc="Deactivate %s laser grids under the dockyard",desc_singular="Deactivate a laser grid under the dockyard",max=3,missions=512)
    bingo_options(288)=(event="A51CommBuildingBasement",desc="Enter the basement of the Area 51 Command building",max=1,missions=32768)
    bingo_options(289)=(event="FreighterHelipad",desc="Walk on the helipad inside the super freighter",max=1,missions=512)
    bingo_options(290)=(event="11_Bulletin01",desc="Learn about the Cathedral",max=1,missions=2048)
    bingo_options(291)=(event="A51ExplosiveLocker",desc="Enter the explosives locker in Area 51",max=1,missions=32768)
    bingo_options(292)=(event="A51SeparationSwim",desc="Swim in the Area 51 separation tank",max=1,missions=32768)
    bingo_options(293)=(event="09_Email08",desc="Daddy Zhao",max=1,missions=512)
    bingo_options(294)=(event="Titanic",desc="I'm flying, Jack!",max=1,missions=512)
    bingo_options(295)=(event="MeetScaredSoldier_Played",desc="Talk to the surviving Area 51 soldier",max=1,missions=32768)
    bingo_options(296)=(event="DockyardTrailer",desc="Enter a trailer in the dockyards",max=1,missions=512)
    bingo_options(297)=(event="CathedralDisplayCase",desc="Enter the display case outside the cathedral",max=1,missions=2048)
    bingo_options(298)=(event="WIB_ClassDeadM11",desc="Kill Adept 34501",max=1,missions=2048)
    bingo_options(299)=(event="VandenbergAntenna",desc="Shoot the tip of the antenna in Vandenberg",max=1,missions=4096)
    bingo_options(300)=(event="VandenbergHazLab",desc="Shut off the electricity in the Hazard Lab",max=1,missions=4096)
    bingo_options(301)=(event="WatchKeys_maintenancekey",desc="Find the Vandenberg tunnel maintenance key",max=1,missions=4096)
    bingo_options(302)=(event="EnterUC",desc="Enter %s Universal Constructors",desc_singular="Enter a Universal Constructor",max=3,missions=53248)
    bingo_options(303)=(event="VandenbergComputerElec",desc="There's very little risk",max=2,missions=4096, do_not_scale=true)
    bingo_options(304)=(event="VandenbergGasSwim",desc="Swim around the Vandenberg gas tanks",max=1,missions=4096)
    bingo_options(305)=(event="SiloAttic",desc="Enter the attic at the Silo",max=1,missions=16384)
    bingo_options(306)=(event="SubBaseSatellite",desc="Shoot a satellite dish at the sub base",max=1,missions=16384)
    bingo_options(307)=(event="UCVentilation",desc="Destroy %s ventilation fans in the Ocean Lab",desc_singular="Destroy a ventilation fan in the Ocean Lab",max=6,missions=16384)
    bingo_options(308)=(event="OceanLabFloodedStoreRoom",desc="Swim to the locked store room in the Ocean Lab",max=1,missions=16384)
    bingo_options(309)=(event="OceanLabMedBay",desc="Enter the flooded med bay in the Ocean Lab",max=1,missions=16384)
    bingo_options(310)=(event="WatchDogs",desc="Watch Dogs (%s seconds)",desc_singular="Watch Dogs (1 second)",max=15,missions=21604)
    bingo_options(311)=(event="Cat_peeptime",desc="Look at that kitty! (%s seconds)",desc_singular="Look at that kitty! (1 second)",max=15,missions=7256)
    bingo_options(312)=(event="Binoculars_peeptime",desc="Who Watches the Watchers? (%s seconds)",desc_singular="Who Watches the Watchers? (1 second)",max=5)
    bingo_options(313)=(event="roof_elevator",desc="Use the roof elevator in Denfert - Rochereau",max=1,missions=1024)
    bingo_options(314)=(event="MeetRenault_Played",desc="Ever tried rat piss?",max=1,missions=1024)
    bingo_options(315)=(event="WarehouseSewerTunnel",desc="Take the sewers to the Warehouse",max=3,missions=4,do_not_scale=true)
    bingo_options(316)=(event="PaulToTong",desc="Help Tong get a closer inspection",max=1,missions=96)
    bingo_options(317)=(event="M04PlayerLikesUNATCO_Played",desc="You're not a terrorist",max=1,missions=16)
    bingo_options(318)=(event="Canal_Bartender_Question4",desc="Not big into books",max=1,missions=64)
    bingo_options(319)=(event="M06BartenderQuestion3",desc="The mark of the educated man",max=1,missions=64)
    bingo_options(320)=(event="M05MeetJaime_Played",desc="Talk to Jaime during the escape",max=1,missions=32)
    bingo_options(321)=(event="jughead_PlayerDead",desc="Kill El Rey",max=1,missions=8)
    bingo_options(322)=(event="JoshuaInterrupted_Played",desc="He was the one who wanted to be a soldier",max=1,missions=1024)
    bingo_options(323)=(event="LebedevLived",desc="Keep Lebedev alive",max=1,missions=8)
    bingo_options(324)=(event="AimeeLeMerchantLived",desc="Let Aimee and Le Merchant live",max=1,missions=1024)
    bingo_options(325)=(event="OverhearLebedev_Played",desc="This socket is being monitored",max=1,missions=8)
    bingo_options(326)=(event="ThugGang_AllianceDead",desc="Slaughter the Rooks",max=10,missions=8,do_not_scale=true) // there are ordinarily 11 Rooks
    bingo_options(327)=(event="GiveZyme",desc="Who needs Rock?",max=2,missions=8,do_not_scale=true) // Huh?  Not me.  He could just die.  Take his fifty-cut zyme and blow.
    // bingo_options()=(event="MarketKid_PlayerUnconscious",desc="Crime doesn't pay",max=1,missions=64)
    bingo_options(328)=(event="MaggieLived",desc="Let Maggie Live",max=1,missions=64)
    bingo_options(329)=(event="SoldRenaultZyme",desc="Sell Zyme to Renault",max=5,missions=1024,do_not_scale=true)
#ifdef vanilla
    bingo_options(330)=(event="PetKarkians",desc="Karkians are just big leather dogs",max=3,missions=49248)
    bingo_options(331)=(event="PetDogs",desc="You can pet the dog",max=5,missions=21604)
    bingo_options(332)=(event="PetFish",desc="They feel kind of slimy",max=5,missions=64)
    bingo_options(333)=(event="PetBirds",desc="Feel the hollow bones",max=3,missions=24446)
    bingo_options(334)=(event="PetAnimal_Cat",desc="Here kitty, kitty, kitty!",max=3,missions=7256)
    bingo_options(335)=(event="PetAnimal_Greasel",desc="Green, Greasy, and very pettable",max=5,missions=50272)
    bingo_options(336)=(event="PetRats",desc="Pat dat rat",max=25,missions=53118)
#endif
    bingo_options(337)=(event="NotABigFan",desc="Not a big fan",max=20,missions=17244)
    bingo_options(338)=(event="MeetInjuredTrooper2_Played",desc="Cheer up an injured trooper",max=1,missions=8)
    bingo_options(339)=(event="InterviewLocals",desc="Interview locals about a generator",max=3,missions=4,do_not_scale=true)
    bingo_options(340)=(event="MeetSandraRenton_Played",desc="Rescue Sandra Renton",max=1,missions=4)
    bingo_options(341)=(event="TiffanyHeli",desc="Rescue Tiffany Savage",max=1,missions=4096)
    bingo_options(342)=(event="AlarmUnitHacked",desc="Hack %s Alarm Sounder Panels",desc_singular="Hack an Alarm Sounder Panel",max=10)
    bingo_options(343)=(event="BuoyOhBuoy",desc="Buoy Oh Buoy",max=10,missions=94)
    bingo_options(344)=(event="PlayerPeeped",desc="Despite everything, it's still you",max=1,missions=24446)
    bingo_options(345)=(event="DangUnstabCond_peepedtex",desc="Condemned!",max=1,missions=2)
    bingo_options(346)=(event="pa_TrainSign_D_peepedtex",desc="Closely inspect the Paris metro map",max=1,missions=2048)
    bingo_options(347)=(event="IOnceKnelt",desc="I once knelt in this chapel",max=1,missions=2048)
    bingo_options(348)=(event="GasCashRegister",desc="Check the cash register at the gas station",max=1,missions=4096)
    bingo_options(349)=(event="LibertyPoints",desc="Visit the 11 points of the statue foundation",max=11,missions=2,do_not_scale=true)
    bingo_options(350)=(event="CherryPickerSeat",desc="Sit in the seat of a cherry picker",max=1,missions=49152)
    bingo_options(351)=(event="ForkliftCertified",desc="Forklift Certified",max=1,missions=32770)
    bingo_options(352)=(event="ASingleFlask",desc="Do you have a single flask to back that up?",max=10,missions=24190)
    bingo_options(353)=(event="FC_EyeTest_peepedtex",desc="Take an eye exam",max=1,missions=260)
    bingo_options(354)=(event="EmergencyExit",desc="Locate %s emergency exits",desc_singular="Locate an emergency exit",max=8,missions=1918)
    bingo_options(355)=(event="Ex51",desc="Ex-51",desc_singular="Ex-51",max=6,missions=4096)
    bingo_options(356)=(event="JoyOfCooking",desc="The Joy of Cooking",max=1,missions=1088)
#ifdef injections || revision
    bingo_options(357)=(event="DolphinJump",desc="The marks on your head look like stars in the sky",max=1,missions=56910)
#endif
    bingo_options(358)=(event="UtilityBot_ClassDead",desc="Destroy %s Utility Bots",desc_singular="Destroy a Utility Bot",max=3)
    bingo_options(359)=(event="M06HeliSafe",desc="HeliSafe",max=2,missions=64,do_not_scale=true)
#ifdef injections || revision
    bingo_options(360)=(event="JustAFleshWound",desc="Just a flesh wound",max=1)
    bingo_options(361)=(event="LostLimbs",desc="Why are we here?  Just to suffer?",desc_singular="Why are we here?  Just to suffer?",max=10)
#endif
    //Current bingo_options array size is 400.  Keep this at the bottom of the list as a reminder!
//#endregion



//#region Mutual Exclusions
    mutually_exclusive(0)=(e1="PaulDenton_Dead",e2="SavedPaul")
    mutually_exclusive(1)=(e1="JockBlewUp",e2="GotHelicopterInfo")
    mutually_exclusive(2)=(e1="SmugglerDied",e2="M08WarnedSmuggler")
    mutually_exclusive(3)=(e1="SilhouetteHostagesAllRescued",e2="paris_hostage_Dead")
    mutually_exclusive(4)=(e1="UNATCOTroop_ClassUnconscious",e2="UNATCOTroop_ClassDead")
    mutually_exclusive(5)=(e1="Terrorist_ClassUnconscious",e2="Terrorist_ClassDead")
    mutually_exclusive(6)=(e1="MJ12Troop_ClassUnconscious",e2="MJ12Troop_ClassDead")
    mutually_exclusive(7)=(e1="MJ12Commando_ClassUnconscious",e2="MJ12Commando_ClassDead")
    mutually_exclusive(8)=(e1="AnnaKilledLebedev",e2="PlayerKilledLebedev")
    mutually_exclusive(9)=(e1="AnnaKilledLebedev",e2="JuanLebedev_PlayerUnconscious")
    mutually_exclusive(10)=(e1="PlayerKilledLebedev",e2="JuanLebedev_PlayerUnconscious")
    mutually_exclusive(11)=(e1="AnnaKillswitch",e2="AnnaNavarre_DeadM3")
    mutually_exclusive(12)=(e1="AnnaKillswitch",e2="AnnaNavarre_DeadM4")
    mutually_exclusive(13)=(e1="AnnaKillswitch",e2="AnnaNavarre_DeadM5")
    mutually_exclusive(14)=(e1="AnnaNavarre_DeadM3",e2="AnnaNavarre_DeadM4")
    mutually_exclusive(15)=(e1="AnnaNavarre_DeadM3",e2="AnnaNavarre_DeadM5")
    mutually_exclusive(16)=(e1="AnnaNavarre_DeadM4",e2="AnnaNavarre_DeadM3")
    mutually_exclusive(17)=(e1="AnnaNavarre_DeadM4",e2="AnnaNavarre_DeadM5")
    mutually_exclusive(18)=(e1="AnnaNavarre_DeadM5",e2="AnnaNavarre_DeadM3")
    mutually_exclusive(19)=(e1="AnnaNavarre_DeadM5",e2="AnnaNavarre_DeadM4")
    mutually_exclusive(20)=(e1="VialAmbrosia_Activated",e2="GaveDowdAmbrosia")
    mutually_exclusive(21)=(e1="PianoSongPlayed",e2="PianoSong0Played")
    mutually_exclusive(22)=(e1="PianoSongPlayed",e2="PianoSong7Played")
    mutually_exclusive(23)=(e1="PianoSong0Played",e2="PianoSong7Played")
    mutually_exclusive(24)=(e1="UNATCOTroop_peeptime",e2="Terrorist_peeptime")
    mutually_exclusive(25)=(e1="MJ12Troop_peeptime",e2="UNATCOTroop_peeptime")
    mutually_exclusive(26)=(e1="MJ12Troop_peeptime",e2="Terrorist_peeptime")
    mutually_exclusive(27)=(e1="MJ12Troop_peeptime",e2="MJ12Commando_peeptime")
    mutually_exclusive(28)=(e1="BrokenPianoPlayed",e2="PianoSongPlayed")
    mutually_exclusive(29)=(e1="BrokenPianoPlayed",e2="PianoSong0Played")
    mutually_exclusive(30)=(e1="BrokenPianoPlayed",e2="PianoSong7Played")
    mutually_exclusive(31)=(e1="M07MeetJaime_Played",e2="KnowsGuntherKillphrase")
    mutually_exclusive(32)=(e1="Binoculars_Activated",e2="Terrorist_peeptime")
    mutually_exclusive(33)=(e1="Binoculars_Activated",e2="UNATCOTroop_peeptime")
    mutually_exclusive(34)=(e1="MJ12Troop_peeptime",e2="Binoculars_Activated")
    mutually_exclusive(35)=(e1="Binoculars_Activated",e2="MJ12Commando_peeptime")
    mutually_exclusive(36)=(e1="Binoculars_Activated",e2="NYEagleStatue_peeped")
    mutually_exclusive(37)=(e1="Binoculars_Activated",e2="BirdWatching")
    mutually_exclusive(38)=(e1="Binoculars_Activated",e2="PawnAnim_Dance")
    mutually_exclusive(39)=(e1="Supervisor_Paid",e2="M06BoughtVersaLife")
    mutually_exclusive(40)=(e1="VendingMachineEmpty",e2="VendingMachineEmpty_Drink")
    mutually_exclusive(41)=(e1="VendingMachineEmpty",e2="VendingMachineDispense_Candy")
    mutually_exclusive(42)=(e1="VendingMachineEmpty_Drink",e2="VendingMachineDispense_Candy")
    mutually_exclusive(43)=(e1="ShipsBridge",e2="SpinShipsWheel")
    mutually_exclusive(44)=(e1="FamilySquabbleWrapUpGilbertDead_Played",e2="GilbertRenton_PlayerDead")
    mutually_exclusive(45)=(e1="FamilySquabbleWrapUpGilbertDead_Played",e2="JoJoFine_PlayerDead")
    mutually_exclusive(46)=(e1="Cremation",e2="Chef_ClassDead")
    mutually_exclusive(47)=(e1="nsfwander",e2="MiguelLeaving")
    mutually_exclusive(48)=(e1="PaulToTong",e2="SavedPaul")
    mutually_exclusive(49)=(e1="LebedevLived",e2="AnnaKilledLebedev")
    mutually_exclusive(50)=(e1="LebedevLived",e2="PlayerKilledLebedev")
    mutually_exclusive(51)=(e1="AimeeLeMerchantLived",e2="lemerchant_PlayerDead")
    mutually_exclusive(52)=(e1="AimeeLeMerchantLived",e2="aimee_PlayerDead")
    mutually_exclusive(52)=(e1="MaggieLived",e2="MaggieCanFly")
    mutually_exclusive(53)=(e1="GoneFishing",e2="PetFish")
    mutually_exclusive(54)=(e1="BirdWatching",e2="PetBirds")
    mutually_exclusive(55)=(e1="Cat_peeptime",e2="PetAnimal_Cat")
    mutually_exclusive(56)=(e1="Greasel_ClassDead",e2="PetAnimal_Greasel")
    mutually_exclusive(57)=(e1="Rat_ClassDead",e2="PetRats")
    mutually_exclusive(58)=(e1="Karkian_ClassDead",e2="PetKarkians")
    mutually_exclusive(59)=(e1="PerformBurder",e2="PetBirds")
    mutually_exclusive(60)=(e1="PetRats",e2="PetBirds")
    mutually_exclusive(61)=(e1="TiffanySavage_PlayerDead",e2="TiffanyHeli")
    mutually_exclusive(62)=(e1="LebedevLived",e2="AnnaNavarre_DeadM3")
    mutually_exclusive(63)=(e1="LebedevLived",e2="AnnaNavarre_DeadM4")
    mutually_exclusive(64)=(e1="LebedevLived",e2="AnnaNavarre_DeadM5")
    mutually_exclusive(65)=(e1="LebedevLived",e2="AnnaKillswitch")
    mutually_exclusive(66)=(e1="LebedevLived",e2="JuanLebedev_PlayerUnconscious")
    mutually_exclusive(67)=(e1="Ex51",e2="ScienceIsForNerds")
    mutually_exclusive(68)=(e1="PetAnimal_BindName_Starr",e2="PetDogs")
    mutually_exclusive(69)=(e1="JustAFleshWound",e2="LostLimbs")
//#endregion
}
