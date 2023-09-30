class DXREvents extends DXREventsBase;


function WatchActors()
{
    local #var(prefix)Lamp lamp;
    local #var(prefix)BoneFemur femur;
    local #var(prefix)BoneSkull skull;
    local #var(prefix)Trophy trophy;
    local #var(prefix)PoolTableLight poolLight;
    local #var(prefix)HKMarketLight hangingLight;
    local #var(prefix)ShopLight shopLight;
    local #var(prefix)SignFloor signFloor;
    local #var(prefix)WaterCooler cooler;
    local #var(prefix)WaterFountain fountain;
    local #var(prefix)Chandelier chandelier;
    local #var(prefix)HangingChicken chicken;
    local #var(prefix)HKHangingPig pig;
    local #var(prefix)BarrelVirus virus;
    local #var(prefix)Mailbox mail;
    local #var(prefix)CigaretteMachine cigVending;

    foreach AllActors(class'#var(prefix)Lamp',lamp){
        AddWatchedActor(lamp,"LightVandalism");
    }
    foreach AllActors(class'#var(prefix)PoolTableLight',poolLight){
        AddWatchedActor(poolLight,"LightVandalism");
    }
    foreach AllActors(class'#var(prefix)HKMarketLight',hangingLight){
        AddWatchedActor(hangingLight,"LightVandalism");
    }
    foreach AllActors(class'#var(prefix)ShopLight',shopLight){
        AddWatchedActor(shopLight,"LightVandalism");
    }
    foreach AllActors(class'#var(prefix)Chandelier',chandelier){
        AddWatchedActor(chandelier,"LightVandalism");
    }
    foreach AllActors(class'#var(prefix)BoneFemur',femur){
        AddWatchedActor(femur,"FightSkeletons");
    }
    foreach AllActors(class'#var(prefix)BoneSkull',skull){
        AddWatchedActor(skull,"FightSkeletons");
    }
    foreach AllActors(class'#var(prefix)Trophy',trophy){
        AddWatchedActor(trophy,"TrophyHunter");
    }
    foreach AllActors(class'#var(prefix)SignFloor',signFloor){
        AddWatchedActor(signFloor,"SlippingHazard");
    }
    foreach AllActors(class'#var(prefix)WaterCooler',cooler){
        AddWatchedActor(cooler,"Dehydrated");
    }
    foreach AllActors(class'#var(prefix)WaterFountain',fountain){
        AddWatchedActor(fountain,"Dehydrated");
    }
    foreach AllActors(class'#var(prefix)HangingChicken',chicken){
        AddWatchedActor(chicken,"BeatTheMeat");
    }
    foreach AllActors(class'#var(prefix)HKHangingPig',pig){
        AddWatchedActor(pig,"BeatTheMeat");
    }
    foreach AllActors(class'#var(prefix)BarrelVirus',virus){
        AddWatchedActor(virus,"WhyContainIt");
    }
    foreach AllActors(class'#var(prefix)Mailbox',mail){
        AddWatchedActor(mail,"MailModels");
    }
    foreach AllActors(class'#var(prefix)CigaretteMachine',cigVending){
        AddWatchedActor(cigVending,"SmokingKills");
    }

}

function AddPhoneTriggers(bool isRevision)
{
    local #var(prefix)Phone p;
    local BingoTrigger bt;
    local int i;

    //Spawn invisible phones for the payphones
    switch(dxr.localURL) {
    case "02_NYC_STREET":
    case "04_NYC_STREET":
    case "08_NYC_STREET":
        if (!isRevision){
            p = Spawn(class'PayPhone',,,vectm(1117,1969,-430)); //Near Osgoode and Son's
            p = Spawn(class'PayPhone',,,vectm(-1314,944,-430)); //Near Free Clinic
        }
        break;
    case "02_NYC_BAR":
    case "04_NYC_BAR":
    case "08_NYC_BAR":
        if (!isRevision){
            p = Spawn(class'PayPhone',,,vectm(-2624,624,72)); //Near the bathroom
        }
        break;
    case "02_NYC_FREECLINIC":
    case "08_NYC_FREECLINIC":
        if (!isRevision){
            p = Spawn(class'PayPhone',,,vectm(-215,752,-254));  //In the front lobby
        }
        break;
    case "03_NYC_BROOKLYNBRIDGESTATION":
        if (!isRevision){
            p = Spawn(class'PayPhone',,,vectm(-660,-1854,435));  //Upper floor, near El Rey
            p = Spawn(class'PayPhone',,,vectm(-660,-1806,435));
        }
        break;
    case "09_NYC_DOCKYARD":
        if (!isRevision){
            p=Spawn(class'#var(prefix)Phone',,,vectm(2333,2153,53),rotm(0,5688,0));
        }
        break;
    }
    i=0;
    foreach AllActors(class'#var(prefix)Phone',p){
        bt = class'BingoTrigger'.static.Create(self,'PhoneCall',vectm(0,0,0));
        bt.bDestroyOthers=False;
        bt.tag=StringToName("PhoneCall"$i);
        p.event=StringToName("PhoneCall"$i);
        i++;
    }

}

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
    local int i;

    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    //General checks
    WatchActors();
    AddPhoneTriggers(RevisionMaps);

    switch(dxr.localURL) {
    case "00_TrainingFinal":
        WatchFlag('m00meetpage_Played');
        break;

    case "01_NYC_UNATCOISLAND":
        WatchFlag('GuntherFreed');
        WatchFlag('GuntherRespectsPlayer');

        foreach AllActors(class'#var(prefix)SkillAwardTrigger',skillAward) {
            if(skillAward.awardMessage=="Exploration Bonus" && skillAward.skillPointsAdded==50 && skillAward.Region.Zone.bWaterZone){
                skillAward.Event='SunkenShip';
                break;
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'SunkenShip',skillAward.Location);

        bt = class'BingoTrigger'.static.Create(self,'BackOfStatue',vectm(2503.605469,354.826355,2072.113037),40,40);
        bt = class'BingoTrigger'.static.Create(self,'BackOfStatue',vectm(2507.357178,-83.523094,2072.113037),40,40);

        bt = class'BingoTrigger'.static.Create(self,'CommsPit',vectm(-6385.640625,1441.881470,-247.901276),40,40);

        bt = class'BingoTrigger'.static.Create(self,'StatueHead',vectm(6250,109,504),800,40);

        break;
    case "01_NYC_UNATCOHQ":
        WatchFlag('BathroomBarks_Played');
        WatchFlag('ManBathroomBarks_Played');
        WatchFlag('Shannon_Dead');
        if(RevisionMaps){
            bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1725,-1062,-40),95,40);
            bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vectm(1130,-150,310),80,40);
        } else {
            bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1551.508301,-820.408875,-39.901726),95,40);
            bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vectm(240.180969,-385.104431,280.098511),80,40);
        }
        bt.MakeClassProximityTrigger(class'#var(prefix)FlagPole');

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
    case "02_NYC_HOTEL":
        WatchFlag('M02HostagesRescued');// for the hotel, set by Mission02.uc
        bt = class'BingoTrigger'.static.Create(self,'TonThirdFloor',vectm(-630,-1955,424),150,40);

        break;
    case "02_NYC_UNDERGROUND":
        WatchFlag('FordSchickRescued');

        bt = class'BingoTrigger'.static.Create(self,'SewerSurfin',vectm(-50,-125,-1000),750,40);
        bt.MakeClassProximityTrigger(class'#var(prefix)JoeGreeneCarcass');
        break;
    case "02_NYC_BAR":
        WatchFlag('JockSecondStory');
        WatchFlag('LeoToTheBar');
        WatchFlag('PlayPool');
        InitPoolBalls();
        break;
    case "02_NYC_FREECLINIC":
        WatchFlag('BoughtClinicPlan');
        break;
    case "02_NYC_SMUG":
        WatchFlag('MetSmuggler');
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
        break;
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
        bt = class'BingoTrigger'.static.Create(self,'MolePeopleWater',vectm(0,-528,48),60,40);
        break;
    case "03_NYC_UNATCOISLAND":
        WatchFlag('DXREvents_LeftOnBoat');
        bt = class'BingoTrigger'.static.Create(self,'CommsPit',vectm(-6385.640625,1441.881470,-247.901276),40,40);
        break;
    case "03_NYC_UNATCOHQ":
        WatchFlag('SimonsAssassination');
        WatchFlag('Shannon_Dead');
        WatchFlag('MeetWalton_Played');
        if(RevisionMaps){
            bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1725,-1062,-40),95,40);
            bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vectm(1130,-150,310),80,40);
        } else {
            bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1551.508301,-820.408875,-39.901726),95,40);
            bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vectm(240.180969,-385.104431,280.098511),80,40);
        }
        bt.MakeClassProximityTrigger(class'#var(prefix)FlagPole');

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
        InitPoolBalls();
        break;
    case "03_NYC_HANGAR":
        RewatchFlag('747Ambrosia');
        break;
    case "03_NYC_747":
        RewatchFlag('747Ambrosia');
        WatchFlag('JuanLebedev_Unconscious');
        WatchFlag('PlayerKilledLebedev');
        WatchFlag('AnnaKilledLebedev');

        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'field001'){
            dxm.Event='SuspensionCrate';
        }
        bt = class'BingoTrigger'.static.Create(self,'SuspensionCrate',vectm(0,0,0));

        break;
    case "03_NYC_BROOKLYNBRIDGESTATION":
        WatchFlag('FreshWaterOpened');
        break;
    case "03_NYC_HANGAR":
        WatchFlag('NiceTerrorist_Dead');// only tweet it once, not like normal PawnDeaths

        foreach AllActors(class'#var(prefix)Mechanic', mechanic) {
            if(mechanic.BindName == "Harold")
                mechanic.bImportant = true;
        }
        break;
    case "04_NYC_BAR":
        WatchFlag('LeoToTheBar');
        WatchFlag('PlayPool');
        InitPoolBalls();
        break;
    case "04_NYC_HOTEL":
        WatchFlag('GaveRentonGun');
        WatchFlag('FamilySquabbleWrapUpGilbertDead_Played');
        bt = class'BingoTrigger'.static.Create(self,'TonThirdFloor',vectm(-630,-1955,424),150,40);
        break;
    case "04_NYC_UNDERGROUND":
        bt = class'BingoTrigger'.static.Create(self,'SewerSurfin',vectm(-50,-125,-1000),750,40);
        bt.MakeClassProximityTrigger(class'#var(prefix)JoeGreeneCarcass');
        break;
    case "05_NYC_UNATCOISLAND":
        bt = class'BingoTrigger'.static.Create(self,'nsfwander',vectm(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'CommsPit',vectm(-6385.640625,1441.881470,-247.901276),40,40);

        break;
    case "02_NYC_STREET":
        WatchFlag('AlleyBumRescued');
        bt = class'BingoTrigger'.static.Create(self,GetKnicksTag(),vectm(0,0,0));
        bt.bingoEvent="MadeBasket";
        break;
    case "04_NYC_STREET":
        bt = class'BingoTrigger'.static.Create(self,GetKnicksTag(),vectm(0,0,0));
        bt.bingoEvent="MadeBasket";
        break;
    case "04_NYC_BATTERYPARK":
        bt = class'BingoTrigger'.static.Create(self,'MadeItToBP',vectm(0,0,0));
        break;
    case "04_NYC_SMUG":
        RewatchFlag('MetSmuggler');
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
        WatchFlag('Shannon_Dead');
        WatchFlag('M04MeetWalton_Played');
        if(RevisionMaps){
            bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1725,-1062,-40),95,40);
            bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vectm(1130,-150,310),80,40);
            bt.MakeClassProximityTrigger(class'#var(prefix)FlagPole');
            bt = class'BingoTrigger'.static.Create(self,'PresentForManderley',vectm(960,234,297),350,60);
            bt.MakeClassProximityTrigger(class'#var(prefix)JuanLebedevCarcass');
        } else {
            bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1551.508301,-820.408875,-39.901726),95,40);
            bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vectm(240.180969,-385.104431,280.098511),80,40);
            bt.MakeClassProximityTrigger(class'#var(prefix)FlagPole');
            bt = class'BingoTrigger'.static.Create(self,'PresentForManderley',vectm(220,4,280),300,40);
            bt.MakeClassProximityTrigger(class'#var(prefix)JuanLebedevCarcass');
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
        bt = class'BingoTrigger'.static.Create(self,'CommsPit',vectm(-6385.640625,1441.881470,-247.901276),40,40);
        break;
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
        WatchFlag('Shannon_Dead');
        WatchFlag('M05WaltonAlone_Played');
        WatchFlag('M05MeetManderley_Played');

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
            bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1725,-1062,-40),95,40);
            bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vectm(1130,-150,310),80,40);
        } else {
            bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1551.508301,-820.408875,-39.901726),95,40);
            bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vectm(240.180969,-385.104431,280.098511),80,40);
        }
        bt.MakeClassProximityTrigger(class'#var(prefix)FlagPole');

        foreach AllActors(class'#var(prefix)Female2',f) {
            if(f.BindName == "Shannon"){
                f.bImportant = true;
                f.bInvincible = false;
            }
        }

        bt = class'BingoTrigger'.static.Create(self,'ManderleyMail',vectm(0,0,0));
        bt.Tag = 'holoswitch';

        break;
    case "06_HONGKONG_WANCHAI_CANAL":
        WatchFlag('FoundScientistBody');
        WatchFlag('M06BoughtVersaLife');

        foreach AllActors(class'#var(prefix)FlagTrigger',fTrigger,'FoundScientist') {
            // so you don't have to go right into the corner, default is 96, and 40 height
            fTrigger.SetCollisionSize(500, 160);
        }

        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'SecretHold'){
            break;
        }
        skillAward = #var(prefix)SkillAwardTrigger(findNearestToActor(class'#var(prefix)SkillAwardTrigger',dxm));
        skillAward.Event='BoatEngineRoom';
        bt = class'BingoTrigger'.static.Create(self,'BoatEngineRoom',skillAward.Location);

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


        break;
    case "06_HONGKONG_WANCHAI_UNDERWORLD":
        WatchFlag('ClubMercedesConvo1_Done');
        WatchFlag('M07ChenSecondGive_Played');
        WatchFlag('LDDPRussPaid');
        WatchFlag('LeoToTheBar');
        WatchFlag('PlayPool');
        WatchFlag('M06JCHasDate');

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

        foreach AllActors(class'#var(prefix)Poolball',ball){
            if (ball.Region.Zone.ZoneGroundFriction>1){
                ball.Destroy(); //There's at least one ball outside of the table.  Just destroy it for simplicity
            }
        }

        InitPoolBalls();

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

        bt = class'BingoTrigger'.static.Create(self,'TonnochiBillboard',vectm(0,550,870),300,40);

        bt = class'BingoTrigger'.static.Create(self,'MaggieCanFly',vectm(-30,-1950,1400),600,40);
        bt.MakeClassProximityTrigger(class'#var(prefix)MaggieChowCarcass');

        break;
    case "06_HONGKONG_WANCHAI_MARKET":
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
        bt = class'BingoTrigger'.static.Create(self,'TongTargets',vectm(-596.3,1826,40),40,100);
        bt.MakeShootingTarget();

        bt = class'BingoTrigger'.static.Create(self,'TongTargets',vectm(-466.5,1826,40),40,100);
        bt.MakeShootingTarget();

        bt = class'BingoTrigger'.static.Create(self,'TongTargets',vectm(-337.2,1826,40),40,100);
        bt.MakeShootingTarget();

        break;
    case "06_HONGKONG_HELIBASE":
        bt = class'BingoTrigger'.static.Create(self,'purge',vectm(0,0,0));

        foreach AllActors(class'#var(prefix)Trigger',trig){
            if (trig.classProximityType==class'Basketball'){
                break;
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'HongKongBBall',trig.Location,14,3);
        bt.MakeClassProximityTrigger(class'#var(prefix)Basketball');

        break;
    case "06_HONGKONG_MJ12LAB":
        foreach AllActors(class'ZoneInfo',zone){
            if (zone.bFogZone){
                zone.ZonePlayerEvent = 'HongKongGrays';
                break;
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'HongKongGrays',zone.Location);

        WatchFlag('JerryTheVentGreasel_Dead');

        WatchFlag('FlowersForTheLab');
        break;

    case "06_HONGKONG_STORAGE":
        WatchFlag('FlowersForTheLab');
        break;

    case "06_HONGKONG_VERSALIFE":
        WatchFlag('Supervisor_Paid');
        break;

    case "08_NYC_STREET":
        bt = class'BingoTrigger'.static.Create(self,GetKnicksTag(),vectm(0,0,0));
        bt.bingoEvent="MadeBasket";
        WatchFlag('StantonAmbushDefeated');
        WatchFlag('GreenKnowsAboutDowd');
        break;
    case "08_NYC_SMUG":
        WatchFlag('M08WarnedSmuggler');
        RewatchFlag('MetSmuggler');
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
        break;
    case "08_NYC_HOTEL":
        bt = class'BingoTrigger'.static.Create(self,'TonThirdFloor',vectm(-630,-1955,424),150,40);
        WatchFlag('GreenKnowsAboutDowd');
        break;
    case "08_NYC_UNDERGROUND":
        WatchFlag('GreenKnowsAboutDowd');
        bt = class'BingoTrigger'.static.Create(self,'SewerSurfin',vectm(-50,-125,-1000),750,40);
        bt.MakeClassProximityTrigger(class'#var(prefix)JoeGreeneCarcass');
        break;
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
    case "10_PARIS_CATACOMBS":
        WatchFlag('IcarusCalls_Played');
        foreach AllActors(class'#var(prefix)JunkieFemale', jf) {
            if(jf.BindName == "aimee")
                jf.bImportant = true;
        }

        bt = class'BingoTrigger'.static.Create(self,'WarehouseEntered',vectm(-580.607361,-2248.497803,-551.895874),200,160);

        break;
    case "10_PARIS_CATACOMBS_TUNNELS":
        foreach AllActors(class'#var(prefix)WIB',wib){
            if(wib.BindName=="Hela")
                wib.bImportant = true;
        }
        WatchFlag('SilhouetteHostagesAllRescued');
        break;
    case "10_PARIS_METRO":
        WatchFlag('M10EnteredBakery');
        WatchFlag('AlleyCopSeesPlayer_Played');
        WatchFlag('assassinapartment');
        RewatchFlag('KnowsGuntherKillphrase');

        foreach AllActors(class'#var(prefix)Mutt', starr) {
            starr.bImportant = true;// you're important to me
            starr.BindName = "Starr";
        }
        if(RevisionMaps){
            bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(217,-5306,328),50,40);
            bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
        } else {
            bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(-2983.597168,774.217407,312.100128),70,40);
            bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
            bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(-2984.404785,662.764954,312.100128),70,40);
            bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
        }
        break;
    case "10_PARIS_CLUB":
        WatchFlag('CamilleConvosDone');
        WatchFlag('LDDPAchilleDone');
        WatchFlag('LeoToTheBar');
        WatchFlag('LouisBerates');
        RewatchFlag('KnowsGuntherKillphrase');

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

#ifdef vanilla
        bt = class'BingoTrigger'.static.Create(self,'BethsPainting',vectm(0,0,0));
        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm){
            if (dxm.Name=='DeusExMover8'){
                dxm.Event='BethsPainting';
            }
        }
#endif

        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'field002'){
            dxm.Event='SuspensionCrate';
        }
        bt = class'BingoTrigger'.static.Create(self,'SuspensionCrate',vectm(0,0,0));

        break;
    case "11_PARIS_CATHEDRAL":
        WatchFlag('GuntherKillswitch');
        WatchFlag('DL_gold_found_Played');
        WatchFlag('M11WaltonHolo_Played');

        if (RevisionMaps){
            bt = class'BingoTrigger'.static.Create(self,'CathedralUnderwater',vectm(2614,-2103,-120),500,180);
            bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(3811,-3200,-64),20,15);
            bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
            bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(3869,-4256,-64),20,15);
            bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
            bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(3387,-3233,-7.9),50,40);
            bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
            bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(4100,-3469,-6.9),50,40);
            bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
        } else {
            bt = class'BingoTrigger'.static.Create(self,'CathedralUnderwater',vectm(771,-808,-706),500,180);
            bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(2019,-2256,-704),20,15);
            bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
            bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(2076.885254,-3248.189941,-704.369995),20,15);
            bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
            bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(1578,-2286,-647),50,40);
            bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
        }
        bt = class'BingoTrigger'.static.Create(self,'secretdoor01',vectm(0,0,0));

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
    case "12_VANDENBERG_GAS":
        bt = class'BingoTrigger'.static.Create(self,'support1',vectm(0,0,0)); //This gets hit when you blow up the gas pumps
        if (RevisionMaps){
            bt = class'BingoTrigger'.static.Create(self,'GasStationCeiling',vectm(1222,1078,-700),150,10);
        } else {
            bt = class'BingoTrigger'.static.Create(self,'GasStationCeiling',vectm(984,528,-700),150,10);
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

        bt = class'BingoTrigger'.static.Create(self,'CliffSacrifice',vectm(1915,2795,-3900),10000,40);
        bt.MakeClassProximityTrigger(class'#var(DeusExPrefix)Carcass');

        bt = class'BingoTrigger'.static.Create(self,'CliffSacrifice',vectm(-190,-1350,-2760),8000,40);
        bt.MakeClassProximityTrigger(class'#var(DeusExPrefix)Carcass');

        bt = class'BingoTrigger'.static.Create(self,'VandenbergShaft',vectm(1442.694580,1303.784180,-1755),110,10);


        break;
    case "12_VANDENBERG_TUNNELS":
        bt = class'BingoTrigger'.static.Create(self,'VandenbergReactorRoom',vectm(-1427,3287,-2985),500,100);
        break;
    case "12_VANDENBERG_COMPUTER":
        bt = class'BingoTrigger'.static.Create(self,'VandenbergServerRoom',vectm(940,2635,-1320),200,40);
        break;
    case "14_OCEANLAB_SILO":
        WatchFlag('MeetDrBernard_Played');
        foreach AllActors(class'#var(prefix)ScientistMale', sm) {
            if (sm.BindName=="drbernard"){
                sm.bImportant = true;
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'SiloSlide',vectm(25,-4350,165),40,40);
        bt = class'BingoTrigger'.static.Create(self,'SiloWaterTower',vectm(-1212,-3427,1992),240,40);
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

        break;
    case "14_OCEANLAB_UC":
        WatchFlag('LeoToTheBar');
        WatchFlag('PageTaunt_Played');
        RewatchFlag('WaltonShowdown_Played');
        break;
    case "14_VANDENBERG_SUB":
        RewatchFlag('WaltonShowdown_Played');

        //Same location in Revision and Vanilla
        bt = class'BingoTrigger'.static.Create(self,'OceanLabShed',vectm(618.923523,4063.243896,-391.901031),160,40);

        break;
    case "15_AREA51_BUNKER":
        WatchFlag('JockBlewUp');
        WatchFlag('blast_door_open');
        RewatchFlag('WaltonBadass_Played');

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

        bt = class'BingoTrigger'.static.Create(self,'power_dispatcher',vectm(0,0,0));
        bt.bingoEvent = "Area51ElevatorPower";

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

//If there are any situational changes (Eg. Male/Female), adjust the description here
simulated function string tweakBingoDescription(string event, string desc)
{
    local DXRando dxr;

    foreach AllActors(class'DXRando', dxr) {break;}

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

function ReadText(name textTag)
{
    local string eventname;
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

    case '06_Datacube05':// Maggie Chow's bday
        eventname = "July 18th"; // don't break, fallthrough
    default:
        // HACK: because names normally can't have hyphens? convert to string and use that instead
        switch(string(textTag)){
            case "09_NYC_DOCKYARD--796967769":
                eventname = "8675309";
                break;
            case "15_AREA51_PAGE--32904306":
            case "15_AREA51_PAGE--1066683761":
            case "15_AREA51_PAGE--1790818418":
            case "15_AREA51_PAGE--26631873":
                eventname="CloneCubes";
                break;
        }
        if(eventname != "") {
            pws = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
            if(pws != None)
                pws.ProcessString(eventname);
            SendFlagEvent(textTag, false, eventname);
        } else {
            // it's simple for a bingo event that requires reading just 1 thing
            _MarkBingo(textTag);
            return;
        }
    }

    data = class'PlayerDataItem'.static.GiveItem(player());

    if(data.MarkRead(textTag)) {
        _MarkBingo(eventname);
    }
}

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
            return "MedicalBot_ClassDead";
        case "DXRRepairBot_ClassDead":
            return "RepairBot_ClassDead";
        case "FrenchGray_ClassDead":
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
        case "TechSergeantKaplan_Dead":
        case "Mole_Dead":
        case "JordanShea_Dead":
        case "Doctor1_Dead":
        case "Doctor2_Dead":
        case "Veteran_Dead":
        case "jughead_Dead":
        case "drugdealer_Dead":
        case "Harold_Dead":
        case "Shannon_Dead":
        case "Sven_Dead":
        case "supervisor01_Dead":
        case "Canal_Pilot_Dead":
        case "Canal_Bartender_Dead":
        case "MarketBum1_Dead":
        case "ClubDoorGirl_Dead":
        case "Mamasan_Dead":
        case "ClubBartender_Dead":
        case "bums_Dead":
        case "Camille_Dead":
        case "Jean_Dead":
        case "Michelle_Dead":
        case "Antoine_Dead":
        case "Jocques_Dead":
        case "Kristi_Dead":
        case "HotelBartender_Dead":
        case "MetroTechnician_Dead":
        case "lemerchant_Dead":
        case "DXRNPCs1_Dead":
        case "MarketWaiter_Dead":
        case "Sally_Dead":
        case "Pimp_Dead":
        case "Bum_M_Dead":
        case "Renault_Dead":
        case "Louis_Dead":
        case "Defoe_Dead":
        case "Cassandra_Dead":
        case "ClubBouncer_Dead":
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
        default:
            return eventname;
    }
    return eventname;

}

static simulated function string GetBingoGoalHelpText(string event,int mission)
{
    local string msg;
    switch(event){
        case "Free Space":
            return "Don't worry about it!  This one's free!";
        case "TerroristCommander_Dead":
            return "Kill Leo Gold, the terrorist commander on Liberty Island";
        case "TiffanySavage_Dead":
            return "Let Tiffany Savage die (or kill her yourself).  She is being held hostage at the gas station";
        case "PaulDenton_Dead":
            return "Let Paul Denton die (or kill him yourself) during the ambush on the hotel";
        case "JordanShea_Dead":
            return "Kill Jordan Shea, the bartender at the Underworld bar in New York";
        case "SandraRenton_Dead":
            msg = "Kill Sandra Renton (or let her die).  ";
            if (mission<=2){
                msg=msg$"  She can be found in an alley next to the Underworld bar in New York";
            } else if (mission<=4){
                msg=msg$"  She can be found inside the hotel";
            } else if (mission<=8){
                msg=msg$"  She can be found in the Underworld bar";
            } else if (mission<=12){
                msg=msg$"  She can be found outside the gas station";
            }
            return msg;
        case "GilbertRenton_Dead":
            return "Kill Gilbert Renton.  He can be found behind the front desk in the 'Ton hotel";
        case "AnnaNavarre_Dead":
            return "Kill Anna Navarre.  ";
            if (mission<=3){
                msg=msg$"She can be found on the 747";
            } else if (mission<=4){
                msg=msg$"She can be found somewhere in New York after sending the NSF signal";
            } else if (mission<=5){
                msg=msg$"She can be found at the exit of UNATCO HQ";
            }
        case "WarehouseEntered":
            return "Enter the underground warehouse in Paris.  This warehouse is located in the building across the street from the entrance to the Catacombs.";
        case "GuntherHermann_Dead":
            return "Kill Gunther.  He can be found guarding a computer somewhere in the cathedral in Paris.";
        case "JoJoFine_Dead":
            return "Kill Jojo Fine (or let him get killed).  He can be found in the 'Ton hotel before the ambush";
        case "TobyAtanwe_Dead":
            return "Kill Toby Atanwe, who is Morgan Everett's assistant.  He can be killed once you arrive at Everett's house";
        case "Antoine_Dead":
            return "Kill Antoine in the Paris club.  He can be found at a table in a back corner of the club selling bioelectric cells";
        case "Chad_Dead":
            return "Kill Chad Dumier.  He can be found in the Silhouette hideout in the Paris catacombs";
        case "paris_hostage_Dead":
            return "Let both of the hostages in the Paris catacombs die (whether you do it yourself or not).  They can be found locked in the centre of the catacombs bunker occupied by MJ12.";
        case "Hela_Dead":
            return "Kill Hela, the woman in black leading the MJ12 force in the Paris catacombs";
        case "Renault_Dead":
            return "Kill Renault in the Paris hostel.  He is the man who asks you to steal zyme and will buy it from you";
        case "Labrat_Bum_Dead":
            return "Kill the bum locked up in the Hong Kong MJ12 lab, or let him be killed.";
        case "DXRNPCs1_Dead":
            return "Kill The Merchant.  He will randomly spawn in levels according to your chosen game settings.  Keep in mind that once you kill him, he will no longer appear for the rest of your run!";
        case "lemerchant_Dead":
            return "Kill Le Merchant.  He spawns near where you first land in Paris.  He's a different guy!";
        case "Harold_Dead":
            return "Kill Harold the mechanic.  He can be found working underneath the 747 in the LaGuardia hangar.";
        case "aimee_Dead":
            return "Kill Aimee, the woman worrying about her cats in Paris.  She can be found near where you first land in Paris.";
        case "WaltonSimons_Dead":
            msg="Kill Walton Simons.  ";
            if (mission<=14){
                msg=msg$"He can be found hunting you down somewhere in or around the Ocean Lab.";
            } else if (mission==15){
                msg=msg$"He can be found hunting you down somewhere in Area 51.";
            }
            return msg;
        case "JoeGreene_Dead":
            msg= "Kill Joe Greene, the reporter poking around in New York.  ";
            if (mission<=2){
                msg=msg$"He can be found in the Underworld bar.";
            }else if (mission<=8){
                msg=msg$"He can be found somewhere in New York after you return from Hong Kong.";
            }
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
            return "Rescue Ford Schick from the MJ12 lab in the sewers under New York on your first visit to Hell's Kitchen.  The key to the sewers can be gotten from Smuggler";
        case "NiceTerrorist_Dead":
            return "Kill a friendly NSF trooper in the LaGuardia hangar.";
        case "M10EnteredBakery":
            return "Enter the bakery in the streets of Paris.  The bakery can be found across the street from the Metro.";
        case "FreshWaterOpened":
            return "Fix the fresh water supply in Brooklyn Bridge Station.  The water valves are behind some collapsed rubble.";
        case "assassinapartment":
            return "Visit the apartment in Paris that has Starr the dog inside.  This apartment is over top of the media store, but is accessed from the opposite side of the building near where Jock picks you up.";
        case "GaveRentonGun":
            return "Give Gilbert Renton a gun when he is trying to protect his daughter from JoJo Fine, before the ambush.";
        case "DXREvents_LeftOnBoat":
            return "After destroying the NSF generator, return to Battery Park and take the boat back to UNATCO.";
        case "AlleyBumRescued":
            return "On your first visit to Battery Park, rescue the bum being mugged on the basketball court.  The court can be found behind the subway station.";
        case "FoundScientistBody":
            return "Enter the collapsed tunnel under the canals and find the scientist body.  The tunnel can be accessed through the vents in the freezer of the Old China Hand.";
        case "ClubEntryPaid":
            return "Give Mercedes and Tessa (the two women waiting outside the Lucky Money) money to get into the club.";
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
            return "Buy two beers from Jordan Shea and give them to Jock in the Underworld bar.";
        case "M07ChenSecondGive_Played":
            return "After the triad meeting in the temple, meet the leaders in the Lucky Money and receive all the gifted bottles of wine from each Dragon Head.";
        case "DeBeersDead":
            return "Kill Lucius DeBeers in Everett's House.  You can do so either by destroying him or shutting off his bio support with the computer next to him";
        case "StantonAmbushDefeated":
            return "Defend Stanton Dowd from the MJ12 ambush after talking to him.";
        case "SmugglerDied":
            return "Let Smuggler die by not warning him of the UNATCO raid.  This can be done either by not talking to him at all, or not warning him of the raid if you talk to him after talking to Dowd.";
        case "GaveDowdAmbrosia":
            return "Find a vial of ambrosia on the upper decks of the superfreighter and bring to to Stanton Dowd in the graveyard.";
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
            return "Kill Manderley while escaping from UNATCO.";
        case "MadeItToBP":
            return "After the raid on the 'Ton hotel, escape to Gunther's roadblock in Battery Park.";
        case "MetSmuggler":
            return "Talk to Smuggler in his Hell's Kitchen hideout.";
        case "SickMan_Dead":
            return "Kill the junkie in Battery Park who asks for someone to kill him.  He is typically found near the East Coast Memorial (the eagle statue and large plaques)";
        case "M06PaidJunkie":
            return "Visit the junkie living on the floor under construction below Maggie Chow's apartment.  Give her money.";
        case "M06BoughtVersaLife":
            return "Buy the maps of Versalife from the guy in the Old China Hand bar, by the canal";
        case "FlushToilet":
            return "Find and flush enough different toilets.  Note that toilets in places that you revisit (like UNATCO HQ) will count again on each visit";
        case "FlushUrinal":
            return "Find and flush enough different urinals.  Note that urinals in places that you revisit (like UNATCO HQ) will count again on each visit";
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
            return "Enter the ship that has sunk off the North Dock of Liberty Island (Near Harley Filben)";
        case "SpinShipsWheel":
            msg="Spin enough ships wheels.  ";
            if (mission<=1){
                msg=msg$"There is a ships wheel on the wall of the hut Harley Filben is in.";
            }else if (mission<=6){
                msg=msg$"There is a ships wheel on the smuggler's ship in the Wan Chai canals, as well as on the wall of the Boat Persons house (off the side of the canal)";
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
            return "Kill enough greasels.  You must kill the greasels yourself.";
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
            return "Destroy enough military bots.  You must destroy them yourself.  Disabling them with EMP grenades does not count.";
        case "VandenbergToilet":
            return "Use the one toilet in Vandenberg.  It is located inside the Comm building outside.";
        case "BoatEngineRoom":
            return "Enter the small room at the back of the smuggler's boat in the Hong Kong canals.  The room can be accessed by using one of the hanging lanterns near the back of the boat.";
        case "SecurityBot2_ClassDead":
            return "Destroy enough of the two legged walking security bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "SecurityBotSmall_ClassDead":
            return "Destroy enough of the smaller, treaded security bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "SpiderBot_ClassDead":
            return "Destroy enough spider bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "HumanStompDeath":
            return "Jump on enough humans heads until they die.  Note that people will not take stomp damage unless they are hostile to you, so you may need to hit them first to make them angry.";
        case "Rat_ClassDead":
            return "Kill enough rats.";
        case "UNATCOTroop_ClassUnconscious":
            return "Knock out enough UNATCO Troopers.  You can knock them out with things like the baton, prod, or tranq darts.";
        case "Terrorist_ClassUnconscious":
            return "Knock out enough NSF Troops.  You can knock them out with things like the baton, prod, or tranq darts.";
        case "MJ12Troop_ClassUnconscious":
            return "Knock out enough MJ12 Troopers.  You can knock them out with things like the baton, prod, or tranq darts.";
        case "MJ12Commando_ClassUnconscious":
            return "Knock out enough MJ12 Commandos.  You can knock them out with things like the baton, prod, or tranq darts.";
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
            return "Read enough 'Know Your Enemy' articles on the public computer in the UNATCO break room.";
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
            } else if (mission<=9){
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
            return "Open the main blast doors of the Area 51 bunker by finding the security computer somewhere on the surface.";
        case "SpinningRoom":
            return "Pass through the center of the spinning room in the ventilation system of the Brooklyn Naval Yards.";
        case "MolePeopleSlaughtered":
            return "Kill most of the friendly mole people in the tunnels leading to Lebedev's private terminal at LaGuardia.";
        case "surrender":
            return "Find the leader of the NSF in the mole people tunnels and let him surrender.";
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
            return "Knock Lebedev out instead of killing him.";
        case "BrowserHistoryCleared":
            return "While escaping UNATCO, log into the computer in your office and clear your browser history.";
        case "AnnaKillswitch":
            return "After finding the pieces of Anna's killphrase, actually use it against her.";
        case "AnnaNavarre_DeadM3":
            return "Kill Anna Navarre on the 747.";
        case "AnnaNavarre_DeadM4":
            return "Kill Anna Navarre after sending the signal for the NSF but before being captured by UNATCO.";
        case "AnnaNavarre_DeadM5":
            return "Kill Anna Navarre in UNATCO HQ.";
        case "SimonsAssassination":
            return "Watch Walton Simons' full interrogation of the captured NSF soldiers.";
        case "AlliesKilled":
            return "Kill enough people who do not actively hate you (This should be most people who show as green on the crosshairs)";
        case "MaySung_Dead":
            return "Kill May Sung, Maggie Chow's maid.";
        case "MostWarehouseTroopsDead":
            return "Kill most of the UNATCO Troops securing the NSF HQ.  This can be done before sending the signal for the NSF or after.";
        case "CleanerBot_ClassDead":
            return "Destroy enough cleaner bots.  Disabling them with EMP does not count.";
        case "MedicalBot_ClassDead":
            return "Destroy enough medical bots.  Disabling them with EMP does not count.";
        case "RepairBot_ClassDead":
            return "Destroy enough repair bots.  Disabling them with EMP does not count.";
        case "DrugDealer_Dead":
            return "Kill Rock, the drug dealer who lives in Brooklyn Bridge station.";
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
            return "Enter the pit outside of UNATCO HQ enough times.";
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
            return "Visit enough of the stores in the Wan Chai market by walking up to them.";
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
            return "Find the pool of water in the Mole People tunnels and jump into it.";
        case "botorders2":
            return "Use the security computer in the upper floor of the MJ12 Robot Maintenance facility to alter the AI of the security bots.";
        case "BathroomFlags":
            return "Place a flag in Manderley's bathroom enough times.  This can only be done once per visit. I'm sure this is how you get to the secret ending!";
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
            return "Kill the greasel in the vents over the main hall of the MJ12 Lab in Hong Kong.  His name is Jerry and he is a good boy.";
        case "BiggestFan":
            return "Destroy the large fan in the ventilation ducts of the Brooklyn Naval Yards.";
        case "Sodacan_Activated":
            return "Chug enough cans of soda.";
        case "BallisticArmor_Activated":
            return "Equip enough ballistic armour.";
        case "Flare_Activated":
            return "Light enough flares.";
        case "VialAmbrosia_Activated":
            return "After finding the vial of ambrosia somewhere on the upper decks of the superfreighter, drink it instead of saving it for Stanton Dowd.";
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
            return "Kill Ford Schick.  Note that you can do this after rescuing him.";
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
                msg=msg$"There is a machine in the Underworld bar in Hell's Kitchen.";
            } else if (mission<=3){
                msg=msg$"There is a machine in Alex's office and the break room of UNATCO HQ, two machines in the LaGuardia helibase break room, and one in the Airfield barracks.";
            } else if (mission<=4){
                msg=msg$"There is a machine in Alex's office and the break room of UNATCO HQ, as well as one in the Underworld bar in Hell's Kitchen.";
            } else if (mission<=5){
                msg=msg$"There is a machine in Alex's office and the break room of UNATCO HQ.";
            } else if (mission<=6){
                msg=msg$"There is a machine in the MJ12 Helibase, one in the MJ12 Lab barracks, one in the Old China Hand, and one in the Lucky Money.";
            } else if (mission<=8){
                msg=msg$"There is a machine in the Underworld bar in Hell's Kitchen.";
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
            return "Watch NSF Troops through binoculars for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "UNATCOTroop_peeptime":
            return "Watch UNATCO Troopers through binoculars for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "MJ12Troop_peeptime":
            return "Watch MJ12 Troopers through binoculars for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "MJ12Commando_peeptime":
            return "Watch MJ12 Commandos through binoculars for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "PawnState_Dancing":
            return "Watch someone dance through a pair of binoculars.  There should be someone vibing in a bar or club.";
        case "BirdWatching":
            return "Watch birds through binoculars for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "NYEagleStatue_peeped":
            return "Look at the bronze eagle statue in Battery Park through a pair of binoculars.";
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
            return "Find and view enough tourist pictures of places.  This includes images of the entrance to the cathedral, images of the catacombs, and the image of the NSF headquarters.";
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
            return "Find enough different keys around Chateau DuClare.  Keys include the key to Beths Room, Nicolettes Room, and to the Basement";
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
            return "Kill enough of the sailors on the top floor of the Lucky Money club.";
        case "Shannon_Dead":
            return "Kill Shannon in UNATCO HQ as retribution for her thieving ways.";
        case "DestroyCapitalism":
            msg = "Kill enough people willing to sell you goods in exchange for money.|nThe Merchant may be elusive, but he must be eliminated when spotted.|n|n";
            if (mission<=1){
                msg=msg$"Tech Sergeant Kaplan and the woman in the hut on the North Dock both absolutely deserve it.";
            } else if (mission<=2){
                msg=msg$"Jordan Shea and Sally in the bar, the doctors in the Free Clinic, and the pimp in the alleys deserve it.";
            } else if (mission<=3){
                msg=msg$"There is a veteran in Battery Park, El Rey and Rock in Brooklyn Bridge Station, and Harold in the hangar.  They all deserve it.";
            } else if (mission<=4){
                msg=msg$"Jordan Shea deserves it.";
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
            return msg;
        case "Canal_Cop_Dead":
            return "Kill one of the Chinese Military in the Hong Kong canals standing near the entrance to Tonnochi Road.";
        case "LightVandalism":
            return "Destroy enough lamps throughout the game.  This might be chandeliers, desk lamps, hanging lights, pool table lights, standing lamps, or table lamps";
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
                msg=msg$"There are many trophies in Hong Kong.  One can be found in the Helibase, another one around the canals, and one on Tonnochi Road";
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
            return "Talk to Sandra Renton after Gilbert and JoJo both die.  He was a good man...  What a rotten way to die.";
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
            return "Scientists think they're so much smarter than you.  Show them how smart your weapons are and kill enough of those nerds.";
        case "Chef_ClassDead":
            return "Do what needs to be done and kill a chef.";
        case "un_PrezMeadPic_peepedtex":
            return "Look closely at a picture of President Mead using a pair of binoculars.  This can be found in UNATCO HQ (both above and below ground).";
        case "un_bboard_peepedtex":
            return "Look at the bulletin board in the UNATCO HQ break room through a pair of binoculars.";
        case "DrtyPriceSign_A_peepedtex":
            return "Check the gas prices through a pair of binoculars at the abandoned Vandenberg Gas Station.";
        case "GS_MedKit_01_peepedtex":
            return "Use a pair of binoculars to find a representation of the Red Cross (A red cross on a white background) in the Vandenberg Gas Station.  Improper use of the emblem is a violation of the Geneva Conventions.";
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
            return "Kill enough SCUBA divers in and around the Ocean Lab.";
        case "ShipRamp":
            return "Raise the ramp to get on board the superfreighter.";
        case "SuperfreighterProp":
            return "Dive to the propeller at the back of the superfreighter.";
        case "ShipNamePlate":
            return "Use binoculars to check the name marked on the side of the superfreighter";
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
            if (mission<=1){
                msg=msg$"|n|nThere is a desk phone on Janice's desk in UNATCO HQ.";
            } else if (mission <=2){
                msg=msg$"|n|nThere is a desk phone and a pay phone in the Free Clinic.  There are two payphones in the streets.  There is a payphone in the back of the bar.";
            } else if (mission <=3){
                msg=msg$"|n|nThere is a desk phone on Janice's desk in UNATCO HQ.  There are two desk phones in offices in the LaGuardia Helibase.";
            } else if (mission <=4){
                msg=msg$"|n|nThere is a desk phone on Janice's desk in UNATCO HQ.  There are two payphones in the streets.  There is a payphone in the back of the bar.";
            } else if (mission <=5){
                msg=msg$"|n|nThere is a desk phone on Janice's desk in UNATCO HQ.";
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
            return "Deactivate enough of the laser grids in the sewers underneath the dockyards";
        case "A51CommBuildingBasement":
            return "Go into the hatch in the Command 24 building in Area 51 and enter the basement.";
        case "FreighterHelipad":
            return "Walk up onto the helipad in the lower decks of the superfreighter.";
        default:
            return "Unable to find help text for event '"$event$"'|nReport this to the developers!";
    }
}

function ExtendedTests()
{
    local string helpText;
    local int i;

    //Make sure all bingo goals have help text
    for (i=0;i<ArrayCount(bingo_options);i++){
        if (bingo_options[i].event!=""){
            helpText = GetBingoGoalHelpText(bingo_options[i].event,0);
            test( InStr(helpText, "Unable to find help text for event") == -1, "Bingo Goal "$bingo_options[i].event$" does not have help text!");
        }
    }
}

// calculate missions masks with https://jsfiddle.net/2sh7xej0/1/
defaultproperties
{
    bingo_options(0)=(event="TerroristCommander_Dead",desc="Kill the Terrorist Commander",max=1,missions=2)
	bingo_options(1)=(event="TiffanySavage_Dead",desc="Kill Tiffany Savage",max=1,missions=4096)
	bingo_options(2)=(event="PaulDenton_Dead",desc="Let Paul die",max=1,missions=16)
	bingo_options(3)=(event="JordanShea_Dead",desc="Kill Jordan Shea",max=1,missions=276)
	bingo_options(4)=(event="SandraRenton_Dead",desc="Kill Sandra Renton",max=1,missions=4372)
	bingo_options(5)=(event="GilbertRenton_Dead",desc="Kill Gilbert Renton",max=1,missions=20)
	//bingo_options()=(event="AnnaNavarre_Dead",desc="Kill Anna Navarre",max=1,missions=56)
    bingo_options(6)=(event="WarehouseEntered",desc="Enter the underground warehouse in Paris",max=1,missions=1024)
	bingo_options(7)=(event="GuntherHermann_Dead",desc="Kill Gunther Hermann",max=1,missions=3072)
	bingo_options(8)=(event="JoJoFine_Dead",desc="Kill JoJo",max=1,missions=16)
	bingo_options(9)=(event="TobyAtanwe_Dead",desc="Kill Toby Atanwe",max=1,missions=2048)
	bingo_options(10)=(event="Antoine_Dead",desc="Kill Antoine",max=1,missions=1024)
	bingo_options(11)=(event="Chad_Dead",desc="Kill Chad",max=1,missions=1024)
	bingo_options(12)=(event="paris_hostage_Dead",desc="Kill both the hostages in the catacombs",max=2,missions=1024)
	//bingo_options()=(event="hostage_female_Dead",desc="Kill hostage Anna",max=1)
	bingo_options(13)=(event="Hela_Dead",desc="Kill Hela",max=1,missions=1024)
	bingo_options(14)=(event="Renault_Dead",desc="Kill Renault",max=1,missions=1024)
	bingo_options(15)=(event="Labrat_Bum_Dead",desc="Kill Labrat Bum",max=1,missions=64)
	bingo_options(16)=(event="DXRNPCs1_Dead",desc="Kill The Merchant",max=1)
	bingo_options(17)=(event="lemerchant_Dead",desc="Kill Le Merchant",max=1,missions=1024)
	bingo_options(18)=(event="Harold_Dead",desc="Kill Harold the mechanic in the hangar",max=1,missions=8)
	//bingo_options()=(event="Josh_Dead",desc="Kill Josh",max=1)
	//bingo_options()=(event="Billy_Dead",desc="Kill Billy",max=1)
	//bingo_options()=(event="MarketKid_Dead",desc="Kill Louis Pan",max=1)
	bingo_options(19)=(event="aimee_Dead",desc="Kill Aimee",max=1,missions=1024)
	bingo_options(20)=(event="WaltonSimons_Dead",desc="Kill Walton Simons",max=1,missions=49152)
	bingo_options(21)=(event="JoeGreene_Dead",desc="Kill Joe Greene",max=1,missions=276)
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
    bingo_options(31)=(event="assassinapartment",desc="Visit Starr in Paris",max=1,missions=1024)
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
    bingo_options(57)=(event="JosephManderley_Dead",desc="Kill Joseph Manderley",max=1,missions=32)
    bingo_options(58)=(event="MadeItToBP",desc="Escape to Battery Park",max=1,missions=16)
    bingo_options(59)=(event="MetSmuggler",desc="Meet Smuggler",max=1,missions=276)
    bingo_options(60)=(event="SickMan_Dead",desc="Kill the sick man who wants to die",max=1,missions=12)
    bingo_options(61)=(event="M06PaidJunkie",desc="Help the junkie on Tonnochi Road",max=1,missions=64)
    bingo_options(62)=(event="M06BoughtVersaLife",desc="Get maps of the VersaLife building",max=1,missions=64)
    bingo_options(63)=(event="FlushToilet",desc="Use %s toilets",max=30,missions=8062)
    bingo_options(64)=(event="FlushUrinal",desc="Use %s urinals",max=20,missions=22398)
    bingo_options(65)=(event="MeetTimBaker_Played",desc="Free Tim from the Vandenberg storage room",max=1,missions=4096)
    bingo_options(66)=(event="MeetDrBernard_Played",desc="Find the man locked in the bathroom",max=1,missions=16384)
    bingo_options(67)=(event="KnowsGuntherKillphrase",desc="Learn Gunther's Killphrase",max=1,missions=1056)
    bingo_options(68)=(event="KnowsAnnasKillphrase",desc="Learn both parts of Anna's Killphrase",max=2,missions=32)
    bingo_options(69)=(event="Area51FanShaft",desc="Jump!  You can make it!",max=1,missions=32768)
    bingo_options(70)=(event="PoliceVaultBingo",desc="Visit the Hong Kong police vault",max=1,missions=64)
    bingo_options(71)=(event="SunkenShip",desc="Enter the sunken ship at Liberty Island",max=1,missions=2)
    bingo_options(72)=(event="SpinShipsWheel",desc="Spin %s ships wheels",max=3,missions=578)
    bingo_options(73)=(event="ActivateVandenbergBots",desc="Activate both of the bots at Vandenberg",max=2,missions=4096)
    bingo_options(74)=(event="TongsHotTub",desc="Take a dip in Tracer Tong's hot tub",max=1,missions=64)
    bingo_options(75)=(event="JocksToilet",desc="Use Jock's toilet",max=1,missions=64)
    bingo_options(76)=(event="Greasel_ClassDead",desc="Kill %s Greasels",max=5,missions=50272)
    bingo_options(77)=(event="support1",desc="Blow up a gas station",max=1,missions=4096)
    bingo_options(78)=(event="UNATCOTroop_ClassDead",desc="Kill %s UNATCO Troopers",max=15,missions=318)
    bingo_options(79)=(event="Terrorist_ClassDead",desc="Kill %s NSF Terrorists",max=15,missions=62)
    bingo_options(80)=(event="MJ12Troop_ClassDead",desc="Kill %s MJ12 Troopers",max=25,missions=57204)
    bingo_options(81)=(event="MJ12Commando_ClassDead",desc="Kill %s MJ12 Commandos",max=10,missions=56384)
    bingo_options(82)=(event="Karkian_ClassDead",desc="Kill %s Karkians",max=5,missions=49248)
    bingo_options(83)=(event="MilitaryBot_ClassDead",desc="Destroy %s Military Bots",max=5,missions=24176)
    bingo_options(84)=(event="VandenbergToilet",desc="Use the only toilet in Vandenberg",max=1,missions=4096)
    bingo_options(85)=(event="BoatEngineRoom",desc="Access the engine room on the boat in the Hong Kong canals",max=1,missions=64)
    bingo_options(86)=(event="SecurityBot2_ClassDead",desc="Destroy %s Walking Security Bots",max=5,missions=57202)
    bingo_options(87)=(event="SecurityBotSmall_ClassDead",desc="Destroy %s commercial grade Security Bots",max=10,missions=35102)
    bingo_options(88)=(event="SpiderBot_ClassDead",desc="Destroy %s Spider Bots",max=15,missions=53824)
    bingo_options(89)=(event="HumanStompDeath",desc="Stomp %s humans to death",max=3)
    bingo_options(90)=(event="Rat_ClassDead",desc="Kill %s rats",max=30,missions=53118)
    bingo_options(91)=(event="UNATCOTroop_ClassUnconscious",desc="Knock out %s UNATCO Troopers",max=15,missions=318)
    bingo_options(92)=(event="Terrorist_ClassUnconscious",desc="Knock out %s NSF Terrorists",max=15,missions=62)
    bingo_options(93)=(event="MJ12Troop_ClassUnconscious",desc="Knock out %s MJ12 Troopers",max=25,missions=57204)
    bingo_options(94)=(event="MJ12Commando_ClassUnconscious",desc="Knock out %s MJ12 Commandos",max=2,missions=56384)
    bingo_options(95)=(event="purge",desc="Release the gas in the MJ12 Helibase",max=1,missions=64)
    bingo_options(96)=(event="ChugWater",desc="Chug water %s times",max=30,mission=40830)
#ifndef vmd
    bingo_options(97)=(event="ChangeClothes",desc="Change clothes at %s different clothes racks",max=3,missions=852)
#endif
    bingo_options(98)=(event="arctrigger",desc="Shut off the electricity at the airfield",max=1,missions=8)
#ifndef hx
    bingo_options(99)=(event="LeoToTheBar",desc="Bring the terrorist commander to the bar",max=1,missions=17686)
#endif
    bingo_options(100)=(event="KnowYourEnemy",desc="Read %s Know Your Enemy bulletins",max=6,missions=10)
    bingo_options(101)=(event="09_NYC_DOCKYARD--796967769",desc="Learn Jenny's phone number",max=1,missions=512)
    bingo_options(102)=(event="JacobsShadow",desc="Read %s parts of Jacob's Shadow",max=4,missions=38492)
    bingo_options(103)=(event="ManWhoWasThursday",desc="Read %s parts of The Man Who Was Thursday",max=4,missions=54300)
    bingo_options(104)=(event="GreeneArticles",desc="Read %s newspaper articles by Joe Greene",max=4,missions=270)
    bingo_options(105)=(event="MoonBaseNews",desc="Read news about the Lunar Mining Complex",max=1,missions=76)
    bingo_options(106)=(event="06_Datacube05",desc="Learn Maggie Chow's Birthday",max=1,missions=64)
    bingo_options(107)=(event="Gray_ClassDead",desc="Kill %s Grays",max=5,missions=32832)
    bingo_options(108)=(event="CloneCubes",desc="Read about %s clones in Area 51",max=4,missions=32768)
    bingo_options(109)=(event="blast_door_open",desc="Open the blast doors at Area 51",max=1,missions=32768)
    bingo_options(110)=(event="SpinningRoom",desc="Pass through the spinning room",max=1,missions=512)
    bingo_options(111)=(event="MolePeopleSlaughtered",desc="Slaughter the Mole People",max=1,missions=8)
    bingo_options(112)=(event="surrender",desc="Make the NSF surrender in the Mole People tunnels",max=1,missions=8)
    bingo_options(113)=(event="nanocage",desc="Open the cages in the UNATCO MJ12 Lab",max=1,missions=32)
#ifdef vanilla
    bingo_options(114)=(event="unbirth",desc="Return to the tube that spawned you",max=1,missions=32768)
#endif
    bingo_options(115)=(event="StolenAmbrosia",desc="Find %s stolen barrels of Ambrosia",max=3,missions=12)
    bingo_options(116)=(event="AnnaKilledLebedev",desc="Let Anna kill Lebedev",max=1,missions=8)
    bingo_options(117)=(event="PlayerKilledLebedev",desc="Kill Lebedev yourself",max=1,missions=8)
    bingo_options(118)=(event="JuanLebedev_Unconscious",desc="Knock out Lebedev",max=1,missions=8)
    bingo_options(119)=(event="BrowserHistoryCleared",desc="Clear your browser history before quitting",max=1,missions=32)
    bingo_options(120)=(event="AnnaKillswitch",desc="Use Anna's Killphrase",max=1,missions=32)
    bingo_options(121)=(event="AnnaNavarre_DeadM3",desc="Kill Anna Navarre in Mission 3",max=1,missions=8)
    bingo_options(122)=(event="AnnaNavarre_DeadM4",desc="Kill Anna Navarre in Mission 4",max=1,missions=16)
    bingo_options(123)=(event="AnnaNavarre_DeadM5",desc="Kill Anna Navarre in Mission 5",max=1,missions=32)
    bingo_options(124)=(event="SimonsAssassination",desc="Let Walton lose his patience",max=1,missions=8)
    bingo_options(125)=(event="AlliesKilled",desc="Kill %s innocents",max=15)
    bingo_options(126)=(event="MaySung_Dead",desc="Kill Maggie Chows maid",max=1,missions=64)
    bingo_options(127)=(event="MostWarehouseTroopsDead",desc="Eliminate the UNATCO troops defending NSF HQ",max=1,missions=16)
    bingo_options(128)=(event="CleanerBot_ClassDead",desc="Destroy %s Cleaner Bots",max=5,missions=286)
    bingo_options(129)=(event="MedicalBot_ClassDead",desc="Destroy %s Medical Bots",max=3)
    bingo_options(130)=(event="RepairBot_ClassDead",desc="Destroy %s Repair Bots",max=3)
    bingo_options(131)=(event="DrugDealer_Dead",desc="Kill the Drug Dealer in Brooklyn Bridge Station",max=1,missions=8)
    bingo_options(132)=(event="botordertrigger",desc="The Smuggler is whacked-out paranoid",max=1,missions=276)
#ifdef injections
    bingo_options(133)=(event="IgnitedPawn",desc="Set %s people on fire",max=15)
    bingo_options(134)=(event="GibbedPawn",desc="Blow up %s people",max=15)
#endif
    bingo_options(135)=(event="IcarusCalls_Played",desc="Take a phone call from Icarus in Paris",max=1,missions=1024)
    bingo_options(136)=(event="AlexCloset",desc="Go into Alex's closet",max=1,missions=58)
    bingo_options(137)=(event="BackOfStatue",desc="Climb to the balcony on the back of the statue",max=1,missions=2)
    bingo_options(138)=(event="CommsPit",desc="Check the SATCOM wiring %s times",max=3,missions=58)
    bingo_options(139)=(event="StatueHead",desc="Visit the head of the Statue of Liberty",max=1,missions=2)
    bingo_options(140)=(event="CraneControls",desc="Use the dockside crane controls",max=1,missions=512)
    bingo_options(141)=(event="CraneTop",desc="Visit the end of both cranes on the freighter",max=2,missions=512)
    bingo_options(142)=(event="CaptainBed",desc="Jump on the freighter captains bed",max=1,missions=512)
    bingo_options(143)=(event="FanTop",desc="Get blown to the top of the freighter ventilation shaft",max=1,missions=512)
    bingo_options(144)=(event="LouisBerates",desc="Sneak behind the Porte De L'Enfer door man",max=1,missions=1024)
    bingo_options(145)=(event="EverettAquarium",desc="Go for a swim in Everett's aquarium",max=1,missions=2048)
    bingo_options(146)=(event="TrainTracks",desc="Jump on to the train tracks in Paris",max=1,missions=2048)
    bingo_options(147)=(event="OceanLabCrewChamber",desc="Visit %s crew chambers in the Ocean Lab",max=4,missions=16384)
    bingo_options(148)=(event="HeliosControlArms",desc="Jump down the control arms in Helios' chamber",max=1,missions=32768)
    bingo_options(149)=(event="TongTargets",desc="Use the shooting range in Tong's base",max=1,missions=64)
    bingo_options(150)=(event="WanChaiStores",desc="Visit %s stores in the Wan Chai market",max=4,missions=64)
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
    bingo_options(161)=(event="BathroomFlags",desc="Place a flag in Manderley's bathroom %s times",max=3,missions=58)
    bingo_options(162)=(event="SiloSlide",desc="Take the silo slide",max=1,missions=16384)
    bingo_options(163)=(event="SiloWaterTower",desc="Climb the water tower at the silo",max=1,missions=16384)
    bingo_options(164)=(event="TonThirdFloor",desc="Go to the third floor of the 'Ton",max=1,missions=276)
    bingo_options(165)=(event="Set_flag_helios",desc="Engage the Aquinas primary router",max=1,missions=32768)
    bingo_options(166)=(event="coolant_switch",desc="Flush the reactor coolant",max=1,missions=32768)
    bingo_options(167)=(event="BlueFusionReactors",desc="Deactivate %s blue fusion reactors",max=4,missions=32768)
    bingo_options(168)=(event="A51UCBlocked",desc="Close the doors to %s UCs in Area 51",max=3,missions=32768)
    bingo_options(169)=(event="VandenbergReactorRoom",desc="Enter the reactor room in the Vandenberg tunnels",max=1,missions=4096)
    bingo_options(170)=(event="VandenbergServerRoom",desc="Enter the server room in the Vandenberg control center",max=1,missions=4096)
    bingo_options(171)=(event="VandenbergWaterTower",desc="Climb the water tower in Vandenberg",max=1,missions=4096)
#ifndef hx
    bingo_options(172)=(event="Cremation",desc="Cook the cook",max=1,missions=2048)
#endif
    bingo_options(173)=(event="OceanLabGreenBeacon",desc="Swim to the green beacon",max=1,missions=16384)
    bingo_options(174)=(event="PageTaunt_Played",desc="Let Bob Page taunt you in the Ocean Lab",max=1,missions=16384)
    //bingo_options()=(event="M11WaltonHolo_Played",desc="Talk to Walton Simons after defeating Gunther",max=1,missions=2048)
    bingo_options(175)=(event="JerryTheVentGreasel_Dead",desc="Kill Jerry the Vent Greasel",max=1,missions=64)
    bingo_options(176)=(event="BiggestFan",desc="Destroy your biggest fan",max=1,missions=512)
    bingo_options(177)=(event="Sodacan_Activated",desc="Drink %s cans of soda",max=75)
    bingo_options(178)=(event="BallisticArmor_Activated",desc="Use %s Ballistic Armors",max=3,missions=57212)
    bingo_options(179)=(event="Flare_Activated",desc="Light %s flares",max=15)
    bingo_options(180)=(event="VialAmbrosia_Activated",desc="Take a sip of Ambrosia",max=1,missions=56832)
    bingo_options(181)=(event="Binoculars_Activated",desc="Take a peek through binoculars",max=1)
    bingo_options(182)=(event="HazMatSuit_Activated",desc="Use %s HazMat Suits",max=3,missions=54866)
    bingo_options(183)=(event="AdaptiveArmor_Activated",desc="Use %s Thermoptic Camos",max=3,missions=55132)
    bingo_options(184)=(event="DrinkAlcohol",desc="Drink %s bottles of alcohol",max=75)
    bingo_options(185)=(event="ToxicShip",desc="Enter the toxic ship",max=1,missions=64)
#ifdef injections
    bingo_options(186)=(event="ComputerHacked",desc="Hack %s computers",max=10)
#endif
    bingo_options(187)=(event="TechGoggles_Activated",desc="Use %s tech goggles",max=3,missions=54346)
    bingo_options(188)=(event="Rebreather_Activated",desc="Use %s rebreathers",max=3,missions=55400)
    bingo_options(189)=(event="PerformBurder",desc="Hunt %s birds",max=10,missions=19806)
    bingo_options(190)=(event="GoneFishing",desc="Kill %s fish",max=10,missions=18506)
    bingo_options(191)=(event="FordSchick_Dead",desc="Kill Ford Schick",max=1,missions=276)
    bingo_options(192)=(event="ChateauInComputerRoom",desc="Find Beth's secret routing station",max=1,missions=1024)
    bingo_options(193)=(event="DuClareBedrooms",desc="Visit both bedrooms in the DuClare Chateau",max=2,missions=1024)
    bingo_options(194)=(event="PlayPool",desc="Sink all the pool balls %s times",max=3,missions=33116)
    bingo_options(195)=(event="FireExtinguisher_Activated",desc="Use %s fire extinguishers",max=10)
    bingo_options(196)=(event="PianoSongPlayed",desc="Play %s different songs on the piano",max=5,missions=64)
    bingo_options(197)=(event="PianoSong0Played",desc="Play the theme song on the piano",max=1,missions=64)
    bingo_options(198)=(event="PianoSong7Played",desc="Stauf Says...",max=1,missions=64)
    bingo_options(199)=(event="PinballWizard",desc="Play %s different pinball machines",max=10,missions=37246)
    bingo_options(200)=(event="FlowersForTheLab",desc="Bring some flowers to brighten up the lab",max=1,missions=64)
    bingo_options(201)=(event="BurnTrash",desc="Burn %s bags of trash",max=25,missions=57182)
    bingo_options(202)=(event="M07MeetJaime_Played",desc="Meet Jaime in Hong Kong",max=1,missions=96)
    bingo_options(203)=(event="Terrorist_peeptime",desc="Watch Terrorists for %s seconds",max=30,missions=62)
    bingo_options(204)=(event="UNATCOTroop_peeptime",desc="Watch UNATCO Troopers for %s seconds",max=30,missions=318)
    bingo_options(205)=(event="MJ12Troop_peeptime",desc="Watch MJ12 Troopers for %s seconds",max=30,missions=57204)
    bingo_options(206)=(event="MJ12Commando_peeptime",desc="Watch MJ12 Commandos for %s seconds",max=15,missions=56384)
    bingo_options(207)=(event="PawnState_Dancing",desc="You can dance if you want to",max=1,missions=1364)
    bingo_options(208)=(event="BirdWatching",desc="Watch birds for %s seconds",max=30,missions=19806)
    bingo_options(209)=(event="NYEagleStatue_peeped",desc="Look at a bronze eagle statue",max=1,missions=28)
    bingo_options(210)=(event="BrokenPianoPlayed",desc="Play a broken piano",max=1,missions=64)
    bingo_options(211)=(event="Supervisor_Paid",desc="Pay for access to the VersaLife labs",max=1,missions=64)
    bingo_options(212)=(event="ImageOpened_WaltonSimons",desc="Look at Walton Simons' nudes",max=1,missions=544)
#ifdef vanilla
    bingo_options(213)=(event="BethsPainting",desc="Admire Beth DuClare's favourite painting",max=1,missions=1024)
#endif
    bingo_options(214)=(event="ViewPortraits",desc="Look at %s portraits",max=2,missions=4890)
    bingo_options(215)=(event="ViewSchematics",desc="Inspect a schematic",max=1,missions=49152)
    bingo_options(216)=(event="ViewMaps",desc="View %s maps",max=6,missions=56686)
    bingo_options(217)=(event="ViewDissection",desc="Have a look at a dissection report",max=1,missions=96)
    bingo_options(218)=(event="ViewTouristPics",desc="Look at a tourist picture",max=1,missions=2576)
    bingo_options(219)=(event="CathedralUnderwater",desc="Swim through the underwater tunnel at the cathedral",max=1,missions=2048)
    bingo_options(220)=(event="DL_gold_found_Played",desc="Recover the Templar gold",max=1,missions=2048)
    bingo_options(221)=(event="12_Email04",desc="Read a motivational email from Gary",max=1,missions=4096)
    bingo_options(222)=(event="ReadJCEmail",desc="Check your email %s times",max=3,missions=122)
    bingo_options(223)=(event="02_Email05",desc="Paul's Classic Movies",max=1,missions=4)
    bingo_options(224)=(event="11_Book08",desc="Read Adept 34501's diary",max=1,missions=2048)
    bingo_options(225)=(event="GasStationCeiling",desc="Access the ceiling of a gas station",max=1,missions=4096)
    bingo_options(226)=(event="NicoletteHouseTour",desc="Tour %s parts of Chateau DuClare with Nicolette",max=5,missions=1024)
    bingo_options(227)=(event="nico_fireplace",desc="Access Nicolette's secret stash",max=1,missions=1024)
    bingo_options(228)=(event="dumbwaiter",desc="Not so dumb now!",max=1,missions=1024)
    bingo_options(229)=(event="secretdoor01",desc="Open the secret door in the cathedral",max=1,missions=2048)
    bingo_options(230)=(event="CathedralLibrary",desc="Worth its weight in gold",max=1,missions=2048)
    bingo_options(231)=(event="DuClareKeys",desc="Collect %s different keys around Chateau DuClare",max=3,missions=1024)
    bingo_options(232)=(event="ShipLockerKeys",desc="Collect %s locker keys inside the superfreighter",max=2,missions=512)
    bingo_options(233)=(event="VendingMachineEmpty",desc="All Sold Out! (%s)",max=18,missions=36734)
    bingo_options(234)=(event="VendingMachineEmpty_Drink",desc="I Wanted Orange! (%s)",max=12,missions=36734)
    bingo_options(235)=(event="VendingMachineDispense_Candy",desc="Ooh, a piece of candy! (%s)",max=100,missions=36478)
    bingo_options(236)=(event="M06JCHasDate",desc="Pay for some company",max=1,missions=64)
    bingo_options(237)=(event="Sailor_ClassDeadM6",desc="I SPILL %s DRINKS!",max=5,missions=64)
    bingo_options(238)=(event="Shannon_Dead",desc="Kill the thief in UNATCO",max=1,missions=58)
    bingo_options(239)=(event="DestroyCapitalism",desc="MUST. CRUSH. %s CAPITALISTS.",max=10,missions=7550)
    bingo_options(240)=(event="Canal_Cop_Dead",desc="Not advisable to visit the canals at night",max=1,missions=64)
    bingo_options(241)=(event="LightVandalism",desc="Perform %s acts of light vandalism",max=40,missions=57214)
    bingo_options(242)=(event="FightSkeletons",desc="Destroy %s skeleton parts",max=10,missions=19536)
    bingo_options(243)=(event="TrophyHunter",desc="Trophy Hunter (%s)",max=10,missions=1146)
    bingo_options(244)=(event="SlippingHazard",desc="Create %s potential slipping hazards",max=5,missions=894)
    bingo_options(245)=(event="Dehydrated",desc="Stay dehydrated %s times",max=15,missions=40830)
#ifndef vmd
    bingo_options(246)=(event="PresentForManderley",desc="Bring a present to Manderley",max=1,missions=24)
#endif
    bingo_options(247)=(event="WaltonConvos",desc="Have %s conversations with Walton Simons",max=3,missions=51256)
    bingo_options(248)=(event="OceanLabShed",desc="Enter the shed on shore at the Ocean Lab",max=1,missions=16384)
    bingo_options(249)=(event="DockBlastDoors",desc="Open %s bunker blast doors in the dockyard",max=3,missions=512)
    bingo_options(250)=(event="ShipsBridge",desc="Enter the bridge of the superfreighter",max=1,missions=512)
    bingo_options(251)=(event="BeatTheMeat",desc="Beat the meat %s times",max=15,missions=2624)
    bingo_options(252)=(event="FamilySquabbleWrapUpGilbertDead_Played",desc="What a shame",max=1,missions=16)
    bingo_options(253)=(event="CrackSafe",desc="Crack %s safes",max=3,missions=516)
    bingo_options(254)=(event="CliffSacrifice",desc="Sacrifice a body off of a cliff",max=1,missions=4096)
    bingo_options(255)=(event="MaggieCanFly",desc="Teach Maggie Chow how to fly",max=1,missions=64)
    bingo_options(256)=(event="VandenbergShaft",desc="Jump down the Vandenberg shaft",max=1,missions=4096)
    bingo_options(257)=(event="ScienceIsForNerds",desc="Science is for nerds (%s)",max=10,missions=20576)
    bingo_options(258)=(event="Chef_ClassDead",desc="My Name Chef",max=1,missions=3072)
    bingo_options(259)=(event="un_PrezMeadPic_peepedtex",desc="Have a look at the anime president",max=1,missions=58)
    bingo_options(260)=(event="un_bboard_peepedtex",desc="Check the bulletin board at UNATCO HQ",max=1,missions=58)
    bingo_options(261)=(event="DrtyPriceSign_A_peepedtex",desc="Check the gas prices in Vandenberg",max=1,missions=4096)
    bingo_options(262)=(event="GS_MedKit_01_peepedtex",desc="Spot a war crime",max=1,missions=4096)
    bingo_options(263)=(event="WatchKeys_cabinet",desc="Find the keys to the MIB filing cabinet",max=1,missions=32)
    bingo_options(264)=(event="MiguelLeaving",desc="Miguel can make it on his own",max=1,missions=32)
    bingo_options(265)=(event="KarkianDoorsBingo",desc="Open the Karkian cage in the MJ12 Lab",max=1,missions=32)
    bingo_options(266)=(event="SuspensionCrate",desc="Open %s Suspension Crates",max=3,missions=3112)
    bingo_options(267)=(event="ScubaDiver_ClassDead",desc="Kill %s SCUBA Divers",max=3,missions=16384)
    bingo_options(268)=(event="ShipRamp",desc="Raise the ramp to the super freighter",max=1,missions=512)
    bingo_options(269)=(event="SuperfreighterProp",desc="Props to you",max=1,missions=512)
    bingo_options(270)=(event="ShipNamePlate",desc="Check the name on the super freighter",max=1,missions=512)
    bingo_options(271)=(event="DL_SecondDoors_Played",desc="The sub-bay doors are closed",max=1,missions=16384)
    bingo_options(272)=(event="WhyContainIt",desc="Why contain it?",max=1,missions=20480)
    bingo_options(273)=(event="MailModels",desc="But why mail models? (%s)",max=3,missions=276)
    bingo_options(274)=(event="UNATCOHandbook",desc="Rules and Regulations (%s)",max=4,missions=26)
    bingo_options(275)=(event="02_Book06",desc="Learn basic firearm safety",max=1,missions=276)
    bingo_options(276)=(event="15_Email02",desc="The truth is out there",max=1,missions=32768)
    bingo_options(277)=(event="ManderleyMail",desc="Check Manderley's holomail %s times",max=2,missions=58)
    bingo_options(278)=(event="LetMeIn",desc="Let me in!",max=1,missions=26)
    bingo_options(279)=(event="08_Bulletin02",desc="Most Wanted",max=1,missions=256)
    bingo_options(280)=(event="SnitchDowd",desc="Snitches get stitches",max=1,missions=256)
    bingo_options(281)=(event="SewerSurfin",desc="Sewer Surfin'",max=1,missions=276)
    bingo_options(282)=(event="SmokingKills",desc="Smoking Kills (%s)",max=5,missions=3420)
    bingo_options(283)=(event="PhoneCall",desc="Make %s phone calls",max=5,missions=1918)
    bingo_options(284)=(event="Area51ElevatorPower",desc="Power the elevator in Area 51",max=1,missions=32768)
    bingo_options(285)=(event="Area51SleepingPod",desc="Open %s sleeping pods in Area 51",max=4,missions=32768)
    bingo_options(286)=(event="Area51SteamValve",desc="Close %s steam valves in Area 51",max=2,missions=32768)
    bingo_options(287)=(event="DockyardLaser",desc="Deactivate %s laser grids under the dockyard",max=3,missions=512)
    bingo_options(288)=(event="A51CommBuildingBasement",desc="Enter the basement of the Area 51 Command building",max=1,missions=32768)
    bingo_options(289)=(event="FreighterHelipad",desc="Walk on the helipad inside the superfreighter",max=1,missions=512)





    mutually_exclusive(0)=(e1="PaulDenton_Dead",e2="SavedPaul")
    mutually_exclusive(1)=(e1="JockBlewUp",e2="GotHelicopterInfo")
    mutually_exclusive(2)=(e1="SmugglerDied",e2="M08WarnedSmuggler")
    mutually_exclusive(3)=(e1="SilhouetteHostagesAllRescued",e2="paris_hostage_Dead")
    mutually_exclusive(4)=(e1="UNATCOTroop_ClassUnconscious",e2="UNATCOTroop_ClassDead")
    mutually_exclusive(5)=(e1="Terrorist_ClassUnconscious",e2="Terrorist_ClassDead")
    mutually_exclusive(6)=(e1="MJ12Troop_ClassUnconscious",e2="MJ12Troop_ClassDead")
    mutually_exclusive(7)=(e1="MJ12Commando_ClassUnconscious",e2="MJ12Commando_ClassDead")
    mutually_exclusive(8)=(e1="AnnaKilledLebedev",e2="PlayerKilledLebedev")
    mutually_exclusive(9)=(e1="AnnaKilledLebedev",e2="JuanLebedev_Unconscious")
    mutually_exclusive(10)=(e1="PlayerKilledLebedev",e2="JuanLebedev_Unconscious")
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
    mutually_exclusive(38)=(e1="Binoculars_Activated",e2="PawnState_Dancing")
    mutually_exclusive(39)=(e1="Supervisor_Paid",e2="M06BoughtVersaLife")
    mutually_exclusive(40)=(e1="VendingMachineEmpty",e2="VendingMachineEmpty_Drink")
    mutually_exclusive(41)=(e1="VendingMachineEmpty",e2="VendingMachineDispense_Candy")
    mutually_exclusive(42)=(e1="VendingMachineEmpty_Drink",e2="VendingMachineDispense_Candy")
    mutually_exclusive(43)=(e1="ShipsBridge",e2="SpinShipsWheel")
    mutually_exclusive(44)=(e1="FamilySquabbleWrapUpGilbertDead_Played",e2="GilbertRenton_Dead")
    mutually_exclusive(45)=(e1="FamilySquabbleWrapUpGilbertDead_Played",e2="JoJoFine_Dead")
    mutually_exclusive(46)=(e1="Cremation",e2="Chef_ClassDead")
    mutually_exclusive(47)=(e1="nsfwander",e2="MiguelLeaving")
}
