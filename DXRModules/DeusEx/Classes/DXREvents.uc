class DXREvents extends DXRActorsBase;

var bool died;
var name watchflags[32];
var int num_watchflags;
var int bingo_win_countdown;
var name rewatchflags[8];
var int num_rewatchflags;
var float PoolBallHeight;

struct BingoOption {
    var string event, desc;
    var int max;
    var int missions;// bit masks
};
var BingoOption bingo_options[250];

struct MutualExclusion {
    var string e1, e2;
};
var MutualExclusion mutually_exclusive[32];

function PreFirstEntry()
{
    Super.PreFirstEntry();

    switch(dxr.dxInfo.missionNumber) {
        case 99:
            Ending_FirstEntry();
            break;

        default:
            // if any mission has a lot of flags then it can get its own case and function
            SetWatchFlags();
            break;
    }
}

function PostFirstEntry()
{
    Super.PostFirstEntry();

     //Done here so that items you are carrying over between levels don't get hit by LogPickup
    InitStatLogShim();
}

function InitStatLogShim()
{
    //I think both LocalLog and WorldLog will always be None in DeusEx, but if this makes it
    //to another game, might need to actually see if there's a possibility of overlap here.
    if (!((Level.Game.LocalLog!=None && Level.Game.LocalLog.IsA('DXRStatLog')) ||
          (Level.Game.WorldLog!=None && Level.Game.WorldLog.IsA('DXRStatLog')))){
        if (Level.Game.LocalLog==None){
            Level.Game.LocalLog=spawn(class'DXRStatLog');
        } else if (Level.Game.WorldLog==None){
            Level.Game.WorldLog=spawn(class'DXRStatLog');
        }
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
    local #var(prefix)Greasel g;
    local #var(prefix)DamageTrigger dt;
    local #var(prefix)Poolball ball;
    local int i;

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
        bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1551.508301,-820.408875,-39.901726),95,40);

        bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vectm(240.180969,-385.104431,280.098511),80,40);
        bt.MakeClassProximityTrigger(class'#var(prefix)FlagPole');


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


        break;
    case "02_NYC_HOTEL":
        WatchFlag('M02HostagesRescued');// for the hotel, set by Mission02.uc
        bt = class'BingoTrigger'.static.Create(self,'TonThirdFloor',vectm(-630,-1955,424),150,40);

        break;
    case "02_NYC_UNDERGROUND":
        WatchFlag('FordSchickRescued');
        break;
    case "02_NYC_BAR":
        WatchFlag('JockSecondStory');
        WatchFlag('LeoToTheBar');
        WatchFlag('PlayPool');
        SetPoolBallHeight();
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
        bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1551.508301,-820.408875,-39.901726),95,40);
        bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vectm(240.180969,-385.104431,280.098511),80,40);
        bt.MakeClassProximityTrigger(class'#var(prefix)FlagPole');
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
        break;
    case "03_NYC_HANGAR":
        RewatchFlag('747Ambrosia');
        break;
    case "03_NYC_747":
        RewatchFlag('747Ambrosia');
        WatchFlag('JuanLebedev_Unconscious');
        WatchFlag('PlayerKilledLebedev');
        WatchFlag('AnnaKilledLebedev');
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
        SetPoolBallHeight();
        break;
    case "04_NYC_HOTEL":
        WatchFlag('GaveRentonGun');
        bt = class'BingoTrigger'.static.Create(self,'TonThirdFloor',vectm(-630,-1955,424),150,40);
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
        bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1551.508301,-820.408875,-39.901726),95,40);
        bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vectm(240.180969,-385.104431,280.098511),80,40);
        bt.MakeClassProximityTrigger(class'#var(prefix)FlagPole');
        break;
    case "04_NYC_UNATCOISLAND":
        bt = class'BingoTrigger'.static.Create(self,'CommsPit',vectm(-6385.640625,1441.881470,-247.901276),40,40);
        break;
    case "05_NYC_UNATCOMJ12LAB":
        CheckPaul();
        bt = class'BingoTrigger'.static.Create(self,'nanocage',vectm(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'botorders2',vectm(0,0,0));
        break;
    case "05_NYC_UNATCOHQ":
        WatchFlag('KnowsAnnasKillphrase1');
        WatchFlag('KnowsAnnasKillphrase2');

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

        bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vectm(1551.508301,-820.408875,-39.901726),95,40);

        bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vectm(240.180969,-385.104431,280.098511),80,40);
        bt.MakeClassProximityTrigger(class'#var(prefix)FlagPole');

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

        foreach AllActors(class'#var(prefix)Hooker1', h) {
            if(h.BindName == "ClubMercedes")
                h.bImportant = true;
        }
        foreach AllActors(class'#var(prefix)LowerClassFemale', lcf) {
            if(lcf.BindName == "ClubTessa")
                lcf.bImportant = true;
        }

        bt = class'BingoTrigger'.static.Create(self,'EnterQuickStop',vectm(0,438,-267),200,40);
        bt = class'BingoTrigger'.static.Create(self,'EnterQuickStop',vectm(220,438,-267),200,40);
        bt = class'BingoTrigger'.static.Create(self,'EnterQuickStop',vectm(448,438,-267),200,40);

        bt = class'BingoTrigger'.static.Create(self,'LuckyMoneyFreezer',vectm(-1615,-2960,-343),200,40);

        foreach AllActors(class'#var(prefix)Poolball',ball){
            if (ball.Region.Zone.ZoneGroundFriction>1){
                ball.Destroy(); //There's at least one ball outside of the table.  Just destroy it for simplicity
            }
        }

        SetPoolBallHeight();

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
        bt = class'BingoTrigger'.static.Create(self,'WanChaiStores',vectm(910,-643,40),150,40);  //News Stand
        bt.Tag='WanChaiNews';
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'WanChaiStores',vectm(632,-532,40),130,40);  //Flower Shop
        bt.Tag='WanChaiFlowers';
        bt.bDestroyOthers=False;


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

        foreach AllActors(class'#var(prefix)Greasel',g){
            g.bImportant = True;
            g.BindName="JerryTheVentGreasel";
            g.FamiliarName = "Jerry the Vent Greasel";
            g.UnfamiliarName = "Jerry the Vent Greasel";
        }
        WatchFlag('JerryTheVentGreasel_Dead');

        WatchFlag('FlowersForTheLab');
        break;

    case "06_HONGKONG_STORAGE":
        WatchFlag('FlowersForTheLab');
        break;

    case "08_NYC_STREET":
        bt = class'BingoTrigger'.static.Create(self,GetKnicksTag(),vectm(0,0,0));
        bt.bingoEvent="MadeBasket";
        WatchFlag('StantonAmbushDefeated');
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
        SetPoolBallHeight();
        break;
    case "08_NYC_HOTEL":
        bt = class'BingoTrigger'.static.Create(self,'TonThirdFloor',vectm(-630,-1955,424),150,40);
        break;
    case "09_NYC_DOCKYARD":
        ReportMissingFlag('M08WarnedSmuggler', "SmugglerDied");
        break;
    case "09_NYC_SHIP":
        bt = class'BingoTrigger'.static.Create(self,'CraneControls',vectm(3264,-1211,1222));
        bt.Tag = 'Crane';

        bt = class'BingoTrigger'.static.Create(self,'CraneTop',vectm(1937,0,1438),100,40);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'CraneTop',vectm(-1791,1082,1423),100,40);
        bt.bDestroyOthers=False;

        bt = class'BingoTrigger'.static.Create(self,'CaptainBed',vectm(2887,58,960),30,40);


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

        break;
    case "09_NYC_GRAVEYARD":
        WatchFlag('GaveDowdAmbrosia');
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

        bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(-2983.597168,774.217407,312.100128),70,40);
        bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
        bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(-2984.404785,662.764954,312.100128),70,40);
        bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');

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
        break;
    case "11_PARIS_CATHEDRAL":
        WatchFlag('GuntherKillswitch');
        bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(2019,-2256,-704),20,15);
        bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
        bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(2076.885254,-3248.189941,-704.369995),20,15);
        bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
        bt = class'BingoTrigger'.static.Create(self,'Cremation',vectm(1578,-2286,-647),50,40);
        bt.MakeClassProximityTrigger(class'#var(prefix)ChefCarcass');
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
        bt = class'BingoTrigger'.static.Create(self,'SiloWaterTower',vectm(-1212,-3427,1992),200,40);
        break;
    case "14_OCEANLAB_LAB":
        WatchFlag('DL_Flooded_Played');
        bt = class'BingoTrigger'.static.Create(self,'OceanLabCrewChamber',vectm(1932.035522,3334.331787,-2247.888184),60,40);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'OceanLabCrewChamber',vectm(1932.035522,3334.331787,-2507.888184),60,40);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'OceanLabCrewChamber',vectm(1928.762573,3721.919189,-2507.888184),60,40);
        bt.bDestroyOthers=False;
        bt = class'BingoTrigger'.static.Create(self,'OceanLabCrewChamber',vectm(1928.762573,3721.919189,-2247.888184),60,40);
        bt.bDestroyOthers=False;

        bt = class'BingoTrigger'.static.Create(self,'OceanLabGreenBeacon',vectm(1543,3522,-1847),200,200);

        break;
    case "14_OCEANLAB_UC":
        WatchFlag('LeoToTheBar');
        WatchFlag('PageTaunt_Played');
        break;
    case "15_AREA51_BUNKER":
        WatchFlag('JockBlewUp');
        WatchFlag('blast_door_open');

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
        break;
    case "15_AREA51_ENTRANCE":
        WatchFlag('PlayPool');
        SetPoolBallHeight();
        break;
    case "15_AREA51_FINAL":
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

function WatchFlag(name flag, optional bool disallow_immediate) {
    // disallow_immediate means it will still be added to the watch list, but won't be checked in the first tick
    // this is good for flag names that get reused and need to be cleared by the MissionScript, like MS_DL_Played
    if( (!disallow_immediate) && dxr.flagbase.GetBool(flag) ) {
        SendFlagEvent(flag, true);
        return;
    }
    watchflags[num_watchflags++] = flag;
    if(num_watchflags > ArrayCount(watchflags))
        err("WatchFlag num_watchflags > ArrayCount(watchflags)");
}

//Only actually add the flag to the list if it isn't already set
function RewatchFlag(name flag, optional bool disallow_immediate){
    if (!dxr.flagbase.GetBool(flag)) {
        WatchFlag(flag,disallow_immediate);
        // rewatchflags will get checked in AnyEntry so they can be removed
        rewatchflags[num_rewatchflags++] = flag;
    } else {
        l("RewatchFlag "$flag$" is already set!");
    }
}

function ReportMissingFlag(name flag, string eventname) {
    if( ! dxr.flagbase.GetBool(flag) ) {
        SendFlagEvent(eventname, true);
    }
}

function Ending_FirstEntry()
{
    local int ending;

    ending = 0;

    switch(dxr.localURL)
    {
        //Make sure we actually are only running on the endgame levels
        //Just in case we hit a custom level with mission 99 or something
        case "ENDGAME1": //Tong
            ending = 1;
            break;
        case "ENDGAME2": //Helios
            ending = 2;
            break;
        case "ENDGAME3": //Everett
            ending = 3;
            break;
        case "ENDGAME4": //Dance party
            ending = 4;
            break;
        default:
            //In case rando runs some player level or something with mission 99
            break;
    }

    if (ending!=0){
        //Notify of game completion with correct ending number
        BeatGame(dxr,ending);
    }
}

simulated function AnyEntry()
{
    local int r, w;
    Super.AnyEntry();
    SetTimer(1, true);

    for(w=0; w<ArrayCount(watchflags); w++) {
        if(watchflags[w]!='')
            l("AnyEntry watchflags["$w$"]: "$watchflags[w]);
    }

    // any rewatch flags that were set outside of this map need to be cleared from the watch list
    for(r=0; r<ArrayCount(rewatchflags); r++) {
        if(rewatchflags[r] == '') continue;
        l("AnyEntry rewatchflags["$r$"]: "$rewatchflags[r]);
        if (dxr.flagbase.GetBool(rewatchflags[r])) {
            l("AnyEntry rewatchflags["$r$"]: "$rewatchflags[r]$" is set!");
            for(w=0; w<num_watchflags; w++) {
                if(watchflags[w] != rewatchflags[r]) continue;

                num_watchflags--;
                watchflags[w] = watchflags[num_watchflags];
                watchflags[num_watchflags]='';
                w--;
            }
        }
    }
}

simulated function bool ClassInLevel(class<Actor> className)
{
    local Actor a;

    foreach AllActors(className,a){
        return True;
    };
    return False;
}

simulated function bool AllPoolBallsSunk()
{
    local #var(prefix)Poolball ball;

    foreach AllActors(class'#var(prefix)Poolball',ball){
        if (ball.Location.Z > PoolBallHeight){
            return False;
        }
    }
    return True;
}

simulated function SetPoolBallHeight()
{
    local #var(prefix)Poolball ball;
    PoolBallHeight = 9999;

    foreach AllActors(class'#var(prefix)Poolball',ball){
        if (ball.Location.Z < PoolBallHeight){
            PoolBallHeight = ball.Location.Z;
        }
    }

    PoolBallHeight -= 1;
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

simulated function Timer()
{
    local int i;

    if( dxr == None || dxr.flagbase == None ) {
        return;
    }

    for(i=0; i<num_watchflags; i++) {
        if(watchflags[i] == '') break;

        if( watchflags[i] == 'MS_DL_Played' && dxr.flagbase.GetBool('PlayerTraveling') ) {
            continue;
        }

        if( watchflags[i] == 'LeoToTheBar' ) {
            if (ClassInLevel(class'#var(prefix)TerroristCommanderCarcass')){
                SendFlagEvent(watchflags[i]);
                num_watchflags--;
                watchflags[i] = watchflags[num_watchflags];
                watchflags[num_watchflags]='';
                i--;
                continue;
            }
        } else if( watchflags[i] == 'GuntherKillswitch' ) {
            if (WatchGuntherKillSwitch()){
                SendFlagEvent(watchflags[i]);
                num_watchflags--;
                watchflags[i] = watchflags[num_watchflags];
                watchflags[num_watchflags]='';
                i--;
                _MarkBingo("GuntherHermann_Dead");
                continue;
            }
        } else if( watchflags[i] == 'PlayPool' ) {
            if (AllPoolBallsSunk()){
                SendFlagEvent(watchflags[i]);
                num_watchflags--;
                watchflags[i] = watchflags[num_watchflags];
                watchflags[num_watchflags]='';
                i--;
                continue;
            }
        } else if( watchflags[i] == 'FlowersForTheLab' ) {
            if (ClassInLevel(class'#var(prefix)Flowers')){
                SendFlagEvent(watchflags[i]);
                num_watchflags--;
                watchflags[i] = watchflags[num_watchflags];
                watchflags[num_watchflags]='';
                i--;
                continue;
            }
        }

        if( dxr.flagbase.GetBool(watchflags[i]) ) {
            SendFlagEvent(watchflags[i]);
            num_watchflags--;
            watchflags[i] = watchflags[num_watchflags];
            watchflags[num_watchflags]='';
            i--;
        }
    }
    // for nonvanilla, because GameInfo.Died is called before the player's Dying state calls root.ClearWindowStack();
    if(died) {
        class'DXRHints'.static.AddDeath(dxr, player());
        died = false;
    }

    if (bingo_win_countdown>=0){
        HandleBingoWinCountdown();
    }
}

function PreTravel()
{
    Super.PreTravel();
    SetTimer(0, false);
}

function HandleBingoWinCountdown()
{
    //Blocked in HX for now (Blocked at the check, but here for safety as well)
    if(#defined(hx)) return;

    if (bingo_win_countdown > 0) {
        //Show win message
        class'DXRBigMessage'.static.CreateBigMessage(dxr.player,None,"Congratulations!  You finished your bingo!","Game ending in "$bingo_win_countdown$" seconds");
        if (bingo_win_countdown == 2 && !#defined(vanilla)) {
            //Give it 2 seconds to send the tweet
            //This is still needed outside of vanilla
            BeatGame(dxr,4);
        }
        bingo_win_countdown--;
    } else if (bingo_win_countdown == 0) {
        //Go to bingo win ending
        Level.Game.SendPlayer(dxr.player,"99_EndGame4");
    }
}

function bool SpecialTriggerHandling(Actor Other, Pawn Instigator)
{
    local #var(prefix)MapExit m;
    if (tag == 'Boat_Exit'){
        dxr.flagbase.SetBool('DXREvents_LeftOnBoat', true,, 999);

        foreach AllActors(class'#var(prefix)MapExit',m,'Boat_Exit2'){
            m.Trigger(Other,Instigator);
        }
        return true;
    }

    return false;
}

function Trigger(Actor Other, Pawn Instigator)
{
    local string j;
    local class<Json> js;
    local name useTag;

    js = class'Json';

    //Leave this variable for now, in case we need to massage tags
    //again at some point in the future
    useTag = tag;

    Super.Trigger(Other, Instigator);
    l("Trigger("$Other$", "$instigator$")");

    if (!SpecialTriggerHandling(Other,Instigator)){
        j = js.static.Start("Trigger");
        js.static.Add(j, "instigator", GetActorName(Instigator));
        js.static.Add(j, "tag", useTag);
        js.static.add(j, "other", GetActorName(other));
        GeneralEventData(dxr, j);
        js.static.End(j);

        class'DXRTelemetry'.static.SendEvent(dxr, Instigator, j);
        _MarkBingo(useTag);
    }
}

function SendFlagEvent(coerce string eventname, optional bool immediate, optional string extra)
{
    local string j;
    local class<Json> js;
    js = class'Json';

    l("SendFlagEvent " $ eventname @ immediate @ extra);

    if(eventname ~= "M02HostagesRescued") {// for the hotel, set by Mission02.uc
        M02HotelHostagesRescued();
        return;
    }
    else if(eventname ~= "MS_DL_Played") {// this is a generic flag name used in a few of the mission scripts
        if(dxr.localURL ~= "02_NYC_BATTERYPARK") {
            BatteryParkHostages();
        }
        return;
    }

    j = js.static.Start("Flag");
    js.static.Add(j, "flag", eventname);
    js.static.Add(j, "immediate", immediate);
    js.static.Add(j, "location", vectclean(dxr.player.location));
    if(extra != "")
        js.static.Add(j, "extra", extra);
    GeneralEventData(dxr, j);
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, dxr.player, j);
    _MarkBingo(eventname);
}

function M02HotelHostagesRescued()
{
    local bool MaleHostage_Dead, FemaleHostage_Dead, GilbertRenton_Dead;
    MaleHostage_Dead = dxr.flagbase.GetBool('MaleHostage_Dead');
    FemaleHostage_Dead = dxr.flagbase.GetBool('FemaleHostage_Dead');
    GilbertRenton_Dead = dxr.flagbase.GetBool('GilbertRenton_Dead');
    if( !MaleHostage_Dead && !FemaleHostage_Dead && !GilbertRenton_Dead) {
        SendFlagEvent("HotelHostagesSaved");
    }
}

function BatteryParkHostages()
{
    local bool SubTerroristsDead, EscapeSuccessful, SubHostageMale_Dead, SubHostageFemale_Dead;
    SubTerroristsDead = dxr.flagbase.GetBool('SubTerroristsDead');
    EscapeSuccessful = dxr.flagbase.GetBool('EscapeSuccessful');
    SubHostageMale_Dead = dxr.flagbase.GetBool('SubHostageMale_Dead');
    SubHostageFemale_Dead = dxr.flagbase.GetBool('SubHostageFemale_Dead');

    l("BatteryParkHostages() " $ SubTerroristsDead @ EscapeSuccessful @ SubHostageMale_Dead @ SubHostageFemale_Dead);
    if( (SubTerroristsDead || EscapeSuccessful) && !SubHostageMale_Dead && !SubHostageFemale_Dead ) {
        SendFlagEvent("SubwayHostagesSaved");
    }
}

static function _DeathEvent(DXRando dxr, Actor victim, Actor Killer, coerce string damageType, vector HitLocation, string type)
{
    local string j;
    local class<Json> js;
    local bool unconcious;
    js = class'Json';

    j = js.static.Start(type);
    js.static.Add(j, "victim", GetActorName(victim));
    js.static.Add(j, "victimBindName", victim.BindName);
    js.static.Add(j, "victimRandomizedName", GetRandomizedName(victim));
    if(#var(prefix)ScriptedPawn(victim) != None) {
        unconcious = #var(prefix)ScriptedPawn(victim).bStunned;
        js.static.Add(j, "victimUnconcious", unconcious);
    }

    if(Killer != None) {
        js.static.Add(j, "killerclass", Killer.Class.Name);
        js.static.Add(j, "killer", GetActorName(Killer));
        js.static.Add(j, "killerRandomizedName", GetRandomizedName(Killer));
    }
    js.static.Add(j, "dmgtype", damageType);
    GeneralEventData(dxr, j);
    js.static.Add(j, "location", dxr.flags.vectclean(victim.Location));
    js.static.End(j);
    class'DXRTelemetry'.static.SendEvent(dxr, victim, j);
}

static function string GetRandomizedName(Actor a)
{
    local ScriptedPawn sp;
    sp = ScriptedPawn(a);
    if(sp == None || sp.bImportant) return "";
    return sp.FamiliarName;
}

static function AddPlayerDeath(DXRando dxr, #var(PlayerPawn) player, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    local DXREvents ev;
    class'DXRStats'.static.AddDeath(player);

    if(#defined(injections))
        class'DXRHints'.static.AddDeath(dxr, player);
    else {
        // for nonvanilla, because GameInfo.Died is called before the player's Dying state calls root.ClearWindowStack();
        ev = DXREvents(dxr.FindModule(class'DXREvents'));
        if(ev != None)
            ev.died = true;
    }

    if(Killer == None) {
        if(player.myProjKiller != None)
            Killer = player.myProjKiller;
        if(player.myTurretKiller != None)
            Killer = player.myTurretKiller;
        if(player.myPoisoner != None)
            Killer = player.myPoisoner;
        if(player.myBurner != None)
            Killer = player.myBurner;
        // myKiller is only set in multiplayer
        if(player.myKiller != None)
            Killer = player.myKiller;
    }

    if(damageType == "shot") {
        if( !IsHuman(Killer.class) && Robot(Killer) == None ) {
            // only humans and robots can shoot? karkians deal shot damage
            damageType = "";
        }
    }

    _DeathEvent(dxr, player, Killer, damageType, HitLocation, "DEATH");
}

static function AddPawnDeath(ScriptedPawn victim, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    local DXRando dxr;
    local DXREvents e;
    foreach victim.AllActors(class'DXRando', dxr) break;

    if(dxr != None)
        e = DXREvents(dxr.FindModule(class'DXREvents'));
    log(e$".AddPawnDeath "$dxr$", "$victim);
    if(e != None)
        e._AddPawnDeath(victim, Killer, damageType, HitLocation);
}

function bool checkInitialAlliance(ScriptedPawn p,name allianceName, float allianceLevel)
{
    local int i;

    for (i=0;i<8;i++){
        if (p.InitialAlliances[i].AllianceName==allianceName &&
            p.InitialAlliances[i].AllianceLevel~=allianceLevel){
            return True;
        }
    }
    return False;
}

function bool isInitialPlayerAlly(ScriptedPawn p)
{
    return checkInitialAlliance(p,'Player',1.0);
}

function _AddPawnDeath(ScriptedPawn victim, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    local string classname;

    _MarkBingo(victim.BindName$"_Dead");
    _MarkBingo(victim.BindName$"_DeadM" $ dxr.dxInfo.missionNumber);
    if( Killer == None || #var(PlayerPawn)(Killer) != None ) {
        classname = string(victim.class.name);
        if(#defined(hx) && InStr(classname, "HX")==0) {
            classname = Mid(classname, 2);
        }

        if (IsHuman(victim.class) && ((damageType == "Stunned") ||
                                (damageType == "KnockedOut") ||
                                (damageType == "Poison") ||
                                (damageType == "PoisonEffect"))){
            _MarkBingo(classname$"_ClassUnconscious");
            _MarkBingo(classname$"_ClassUnconsciousM" $ dxr.dxInfo.missionNumber);
        } else {
            _MarkBingo(classname$"_ClassDead");
            _MarkBingo(classname$"_ClassDeadM" $ dxr.dxInfo.missionNumber);

            //Were they an ally?  Skip on NSF HQ, because that's kind of a bait
            if (isInitialPlayerAlly(victim) &&   //Must have initially been an ally
                 (dxr.localURL!="04_NYC_NSFHQ" || (dxr.localURL=="04_NYC_NSFHQ" && dxr.flagbase.GetBool('DL_SimonsPissed_Played')==False)) //Not on the NSF HQ map, or if it is, before you send the signal (kludgy)
                 ){
                _MarkBingo("AlliesKilled");
            }

        }
        if (damageType=="stomped" && IsHuman(victim.class)){ //If you stomp a human to death...
            _MarkBingo("HumanStompDeath");
        }
    }

    if(!victim.bImportant)
        return;

    if(victim.BindName == "PaulDenton")
        dxr.flagbase.SetBool('DXREvents_PaulDead', true,, 999);
    else if(victim.BindName == "AnnaNavarre" && dxr.flagbase.GetBool('annadies')) {
        _MarkBingo("AnnaKillswitch");
        Killer = player();
    }

    _DeathEvent(dxr, victim, Killer, damageType, HitLocation, "PawnDeath");
}

static function AddDeath(Pawn victim, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    local DXRando dxr;
    local #var(PlayerPawn) player;
    local #var(prefix)ScriptedPawn sp;
    player = #var(PlayerPawn)(victim);
    sp = #var(prefix)ScriptedPawn(victim);
    if(player != None) {
        foreach victim.AllActors(class'DXRando', dxr) break;
        AddPlayerDeath(dxr, player, Killer, damageType, HitLocation);
    }
    else if(sp != None)
        AddPawnDeath(sp, Killer, damageType, HitLocation);
}

static function PaulDied(DXRando dxr)
{
    local string j;
    local class<Json> js;
    js = class'Json';

    j = js.static.Start("PawnDeath");
    js.static.Add(j, "victim", "Paul Denton");
    js.static.Add(j, "victimBindName", "PaulDenton");
    js.static.Add(j, "dmgtype", "");
    GeneralEventData(dxr, j);
    js.static.Add(j, "location", dxr.flags.vectclean(dxr.player.location));
    js.static.End(j);
    dxr.flagbase.SetBool('DXREvents_PaulDead', true,, 999);
    class'DXRTelemetry'.static.SendEvent(dxr, dxr.player, j);
    MarkBingo(dxr, "PaulDenton_Dead");
}

static function SavedPaul(DXRando dxr, #var(PlayerPawn) player, optional int health)
{
    local string j;
    local class<Json> js;
    js = class'Json';

    j = js.static.Start("SavedPaul");
    if(health > 0)
        js.static.Add(j, "PaulHealth", health);
    GeneralEventData(dxr, j);
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, dxr.player, j);
    MarkBingo(dxr, "SavedPaul");
}

static function BeatGame(DXRando dxr, int ending)
{
    local PlayerDataItem data;
    local DXRStats stats;
    local string j;
    local class<Json> js;
    js = class'Json';

    stats = DXRStats(dxr.FindModule(class'DXRStats'));

    j = js.static.Start("BeatGame");
    js.static.Add(j, "ending", ending);
    js.static.Add(j, "SaveCount", dxr.player.saveCount);
    js.static.Add(j, "Autosaves", stats.GetDataStorageStat(dxr, "DXRStats_autosaves"));
    js.static.Add(j, "deaths", stats.GetDataStorageStat(dxr, "DXRStats_deaths"));
    js.static.Add(j, "LoadCount", stats.GetDataStorageStat(dxr, "DXRStats_loads"));
    js.static.Add(j, "maxrando", dxr.flags.maxrando);
    js.static.Add(j, "bSetSeed", dxr.flags.bSetSeed);
    data = class'PlayerDataItem'.static.GiveItem(dxr.player);
    js.static.Add(j, "initial_version", data.initial_version);
    js.static.Add(j, "combat_difficulty", dxr.player.CombatDifficulty);
    js.static.Add(j, "rando_difficulty", dxr.flags.difficulty);
    js.static.Add(j, "cheats", dxr.player.FlagBase.GetInt('DXRStats_cheats'));

    if (dxr.player.carriedDecoration!=None){
        js.static.Add(j, "carriedItem", dxr.player.carriedDecoration.Class);
    }
    else if(dxr.player.inHand.IsA('POVCorpse')){
        js.static.Add(j, "carriedItem", POVCorpse(dxr.player.inHand).carcClassString);
    }

    GeneralEventData(dxr, j);
    BingoEventData(dxr, j);
    AugmentationData(dxr, j);
    GameTimeEventData(dxr, j);

    js.static.Add(j, "score", stats.ScoreRun());
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, dxr.player, j);
}

static function ExtinguishFire(DXRando dxr, string extinguisher, DeusExPlayer player)
{
    local string j;
    local class<Json> js;
    js = class'Json';

    j = js.static.Start("ExtinguishFire");
    js.static.Add(j, "extinguisher", extinguisher);
    js.static.Add(j, "location", dxr.flags.vectclean(player.Location));
    GeneralEventData(dxr, j);
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, player, j);
    MarkBingo(dxr, "ExtinguishFire");
}

static function GeneralEventData(DXRando dxr, out string j)
{
    local string loadout,lang;
    local class<Json> js;
    js = class'Json';

    js.static.Add(j, "PlayerName", GetActorName(dxr.player));
    js.static.Add(j, "map", dxr.localURL);
    js.static.Add(j, "mapname", dxr.dxInfo.MissionLocation);
    js.static.Add(j, "mission", dxr.dxInfo.missionNumber);
    js.static.Add(j, "TrueNorth", dxr.dxInfo.TrueNorth);
    js.static.Add(j, "PlayerIsFemale", dxr.flagbase.GetBool('LDDPJCIsFemale'));
    js.static.Add(j, "GameMode", dxr.flags.GameModeName(dxr.flags.gamemode));
    js.static.Add(j, "newgameplus_loops", dxr.flags.newgameplus_loops);

    loadout = GetLoadoutName(dxr);
    if(loadout != "")
        js.static.Add(j, "loadout", loadout);

    lang = GetConfig("Engine.Engine", "Language");
    if(lang != "")
        js.static.Add(j, "language", lang);
}

static function AugmentationData(DXRando dxr, out string j)
{
    local Augmentation anAug;
    local string augId,augName,augInfo;
    local int level;

    anAug = dxr.player.AugmentationSystem.FirstAug;
    while(anAug != None)
    {
        if (anAug.HotKeyNum <= 0){ //I think if you uninstall an aug it becomes -1?
            anAug = anAug.next;
            continue;
        }
        augId = "Aug-"$anAug.HotKeyNum;
        augName = ""$anAug.Class.Name;
        level = anAug.CurrentLevel;
        if (anAug.bBoosted){
            level = level-1;
        }

        augInfo = "{\"name\":\"" $ augName $"\",\"level\":"$level$"}";

        j = j $",\"" $ augId $ "\":" $ augInfo;


        anAug = anAug.next;
    }

}

static function BingoEventData(DXRando dxr, out string j)
{
    local PlayerDataItem data;
    local string event, desc;
    local int x, y, progress, max;
    local class<Json> js;
    js = class'Json';

    data = class'PlayerDataItem'.static.GiveItem(dxr.player);
    js.static.Add(j, "NumberOfBingos", data.NumberOfBingos());

    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            data.GetBingoSpot(x, y, event, desc, progress, max);
            j = j $ ",\"bingo-"$x$"-"$y $ "\":"
                $ "{\"event\":\"" $ event $ "\",\"desc\":\"" $ desc $ "\",\"progress\":" $ progress $ ",\"max\":" $ max $ "}";
        }
    }
}

static function GameTimeEventData(DXRando dxr, out string j)
{
    local int time, realtime, time_without_menus, i, t;
    local DXRStats stats;
    local class<Json> js;
    js = class'Json';

    stats = DXRStats(dxr.FindModule(class'DXRStats'));
    if(stats == None) return;

    for (i=1;i<=15;i++) {
        t = stats.GetMissionTime(i);
        js.static.Add(j, "mission-" $ i $ "-time", t);
        time += t;
        t = stats.GetCompleteMissionTime(i);
        js.static.Add(j, "mission-" $ i $ "-realtime", t);
        realtime += t;
        time_without_menus += t;
        t = stats.GetCompleteMissionMenuTime(i);
        js.static.Add(j, "mission-" $ i $ "-menutime", t);
        realtime += t;
    }
    js.static.Add(j, "time", time);
    js.static.Add(j, "timewithoutmenus", time_without_menus);
    js.static.Add(j, "realtime", realtime);
}

static function string GetLoadoutName(DXRando dxr)
{
    local DXRLoadouts loadout;
    loadout = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
    if( loadout == None )
        return "";
    return loadout.GetName(loadout.loadout);
}

// BINGO STUFF
simulated function PlayerAnyEntry(#var(PlayerPawn) player)
{
    local PlayerDataItem data;
    local string event, desc;
    local int progress, max;

    data = class'PlayerDataItem'.static.GiveItem(player);

    //Update the exported bingo info in case this was a reload
    data.ExportBingoState();

    // don't overwrite existing bingo
    data.GetBingoSpot(0, 0, event, desc, progress, max);
    if( event != "" ) {
        //Make sure bingo didn't get completed just before leaving a level
        CheckBingoWin(dxr,data.NumberOfBingos());
    } else {
        SetGlobalSeed("bingo"$dxr.flags.bingoBoardRoll);
        _CreateBingoBoard(data);
    }
}

simulated function CreateBingoBoard()
{
    local PlayerDataItem data;
    dxr.flags.bingoBoardRoll++;
    dxr.flags.SaveFlags();
    SetGlobalSeed("bingo"$dxr.flags.bingoBoardRoll);
    data = class'PlayerDataItem'.static.GiveItem(player());
    _CreateBingoBoard(data);
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

simulated function _CreateBingoBoard(PlayerDataItem data)
{
    local int x, y, i;
    local string event, desc;
    local int progress, max, missions, starting_mission_mask, starting_mission, end_mission_mask, end_mission, masked_missions;
    local int options[ArrayCount(bingo_options)], num_options, slot, free_spaces;
    local float f;

    starting_mission = class'DXRStartMap'.static.GetStartMapMission(dxr.flags.settings.starting_map);
    starting_mission_mask = class'DXRStartMap'.static.GetStartingMissionMask(dxr.flags.settings.starting_map);
    if (dxr.flags.bingo_duration!=0){
        end_mission = starting_mission+dxr.flags.bingo_duration-1; //The same mission is the first mission

        //Missions 7 and 13 don't exist, so don't count them
        if (starting_mission<7 && end_mission>=7){
            end_mission+=1;
        }
        if (starting_mission<13 && end_mission>=13){
            end_mission+=1;
        }
    } else {
        end_mission = 15;
    }
    end_mission_mask = class'DXRStartMap'.static.GetEndMissionMask(end_mission);

    num_options = 0;
    for(x=0; x<ArrayCount(bingo_options); x++) {
        if(bingo_options[x].event == "") continue;
        masked_missions = bingo_options[x].missions & starting_mission_mask & end_mission_mask;
        if(bingo_options[x].missions!=0 && masked_missions == 0) continue;
        if(class'DXRStartMap'.static.BingoGoalImpossible(bingo_options[x].event,dxr.flags.settings.starting_map)) continue;
        options[num_options++] = x;
    }

    for(x=0; x<ArrayCount(mutually_exclusive); x++) {
        if(mutually_exclusive[x].e1 == "") continue;

        slot = HandleMutualExclusion(mutually_exclusive[x], options, num_options);
        if( slot >= 0 ) {
            num_options--;
            options[slot] = options[num_options];
        }
    }

    //Clear out the board so it is ready to be repopulated
    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            data.SetBingoSpot(x, y, "", "", 0, 0, 0);
        }
    }

    free_spaces = dxr.flags.settings.bingo_freespaces;
    free_spaces = self.Max(free_spaces, (25+3) - num_options);// +3 to ensure some variety of goal selection
    free_spaces = Min(free_spaces, 5); // max of 5 free spaces?

    //Prepopulate the board with free spaces
    switch(free_spaces) {
    case 5:// all fall through
        data.SetBingoSpot(1, 4, "Free Space", "Free Space", 1, 1, 0);// column
    case 4:
        data.SetBingoSpot(4, 1, "Free Space", "Free Space", 1, 1, 0);// row
    case 3:
        data.SetBingoSpot(3, 0, "Free Space", "Free Space", 1, 1, 0);// column
    case 2:
        data.SetBingoSpot(0, 3, "Free Space", "Free Space", 1, 1, 0);// row
    case 1:
        data.SetBingoSpot(2, 2, "Free Space", "Free Space", 1, 1, 0);// center
    case 0:
        break;
    }

    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            data.GetBingoSpot(x,y,event,desc,progress,max);
            if(max > 0) { //Skip spaces that are already filled with something
                continue;
            }

            slot = rng(num_options);
            i = options[slot];
            event = bingo_options[i].event;
            desc = bingo_options[i].desc;
            desc = tweakBingoDescription(event,desc);
            missions = bingo_options[i].missions;
            masked_missions = missions & end_mission_mask; //Pre-mask the bingo endpoint
            max = bingo_options[i].max;
            // dynamic scaling based on starting mission (not current mission due to leaderboard exploits)
            if(max > 1 && InStr(desc, "%s") != -1) {
                f = float(dxr.flags.bingo_scale)/100.0;
                f = rngrange(f, 0.8, 1);// 80% to 100%
                f *= MissionsMaskAvailability(starting_mission, masked_missions) ** 1.5;
                max = Ceil(float(max) * f);
                max = self.Max(max, 1);
                desc = sprintf(desc, max);
            }

            num_options--;
            options[slot] = options[num_options];
            data.SetBingoSpot(x, y, event, desc, 0, max, missions);
        }
    }

    // TODO: we could handle bingo_freespaces>1 by randomly putting free spaces on the board, but this probably won't be a desired feature
    data.ExportBingoState();
}

simulated function int HandleMutualExclusion(MutualExclusion m, int options[ArrayCount(bingo_options)], int num_options) {
    local int a, b, overwrite;

    for(a=0; a<num_options; a++) {
        if( bingo_options[options[a]].event == m.e1 ) break;
    }
    if( a >= num_options ) return -1;

    for(b=0; b<num_options; b++) {
        if( bingo_options[options[b]].event == m.e2 ) break;
    }
    if( b >= num_options ) return -1;

    if(rngb()) {
        return a;
    } else {
        return b;
    }
}

function bool CheckBingoWin(DXRando dxr, int numBingos)
{
    //Block this in HX for now
    if(#defined(hx)) return false;

    if (dxr.flags.settings.bingo_win > 0){
        if (numBingos >= dxr.flags.settings.bingo_win && dxr.LocalURL!="ENDGAME4"){
            info("Number of bingos: "$numBingos$" has exceeded the bingo win threshold! "$dxr.flags.settings.bingo_win);
            bingo_win_countdown = 5;
            return true;
        }
    }
    return false;
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

    case '06_Datacube05':// Maggie Chow's bday
        eventname = "July 18th"; // don't break, fallthrough
    default:
        // HACK: because names normally can't have hyphens? convert to string and use that instead
        if(string(textTag) == "09_NYC_DOCKYARD--796967769")
            eventname = "8675309";
        if(eventname != "") {
            pws = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
            if(pws != None)
                pws.ProcessString(eventname);
            SendFlagEvent(textTag, false, eventname);
        } else {
            // it's simple for a bingo event that requires reading just 1 thing
            _MarkBingo(textTag);
        }
        return;
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
        default:
            return eventname;
    }
    return eventname;

}

function _MarkBingo(coerce string eventname)
{
    local int previousbingos, nowbingos, time;
    local PlayerDataItem data;
    local string j;
    local class<Json> js;
    js = class'Json';

    // combine some events
    eventname=RemapBingoEvent(eventname);

    //Remapping can also block an event from being marked
    if (eventname==""){
        return;
    }

    data = class'PlayerDataItem'.static.GiveItem(player());
    previousbingos = data.NumberOfBingos();
    l(self$"._MarkBingo("$eventname$") data: "$data$", previousbingos: "$previousbingos);

    if( ! data.IncrementBingoProgress(eventname)) return;

    nowbingos = data.NumberOfBingos();
    l(self$"._MarkBingo("$eventname$") previousbingos: "$previousbingos$", nowbingos: "$nowbingos);

    if( nowbingos > previousbingos ) {
        time = class'DXRStats'.static.GetTotalTime(dxr);
        player().ClientMessage("That's a bingo! Game time: " $ class'DXRStats'.static.fmtTimeToString(time),, true);

        j = js.static.Start("Bingo");
        js.static.Add(j, "newevent", eventname);
        js.static.Add(j, "location", vectclean(player().Location));
        GeneralEventData(dxr, j);
        BingoEventData(dxr, j);
        GameTimeEventData(dxr, j);
        js.static.End(j);

        class'DXRTelemetry'.static.SendEvent(dxr, player(), j);

        CheckBingoWin(dxr,nowbingos);
    } else {
        player().ClientMessage("Completed bingo goal: " $ data.GetBingoDescription(eventname));
    }
}

static function MarkBingo(DXRando dxr, coerce string eventname)
{
    local DXREvents e;
    e = DXREvents(dxr.FindModule(class'DXREvents'));
    log(e$".MarkBingo "$dxr$", "$eventname);
    if(e != None) {
        e._MarkBingo(eventname);
    }
}

function AddBingoScreen(CreditsWindow cw)
{
    local CreditsBingoWindow cbw;
    cbw = CreditsBingoWindow(cw.winScroll.NewChild(Class'CreditsBingoWindow'));
    cbw.FillBingoWindow(player());
}

function AddDXRCredits(CreditsWindow cw)
{
    cw.PrintLn();
    cw.PrintHeader("Bingo");
    AddBingoScreen(cw);
    cw.PrintLn();
}

static function int BingoActiveMission(int currentMission, int missionsMask)
{
    local int missionAnded, minMission;
    if(missionsMask == 0) return 1;// 1==maybe
    missionAnded = (1 << currentMission) & missionsMask;
    if(missionAnded != 0) return 2;// 2==true
    minMission = currentMission;

#ifdef backtracking
    // check conjoined backtracking missions
    switch(currentMission) {
    case 10:
        currentMission=11;
        break;
    case 11:
        currentMission=10;
        minMission=10;
        break;
    case 12:
        currentMission=14;
        break;
    case 14:
        currentMission=12;
        minMission=12;
        break;
    }
    missionAnded = (1 << currentMission) & missionsMask;
    if(missionAnded != 0) return 2;// 2==true
#endif

    if(missionsMask < (1<<minMission)) {
        return -1;// impossible in future missions
    }

    return 0;// 0==false
}

static function float MissionsMaskAvailability(int currentMission, int missionsMask)
{
    local int num, expired, i, t;

    if(missionsMask == 0) return 1.0 - float(currentMission-1) / 15.0;

    for(i=1; i<currentMission; i++) {
        t = (1<<i) & missionsMask;
        expired += int( t != 0 );
    }
    for(i=currentMission; i<15; i++) {
        t = (1<<i) & missionsMask;
        num += int( t != 0 );
    }

    return float(num)/float(expired+num);
}

function RunTests()
{
    testint(NumBitsSet(0), 0, "NumBitsSet");
    testint(NumBitsSet(1), 1, "NumBitsSet");
    testint(NumBitsSet(2), 1, "NumBitsSet");
    testint(NumBitsSet(3), 2, "NumBitsSet");

    testint(NumBitsSet(1<<15), 1, "NumBitsSet");
    testint(NumBitsSet((1<<15)+(1<<8)), 2, "NumBitsSet");

    testfloat(MissionsMaskAvailability(1, (1<<3)), 1, "MissionsMaskAvailability");
    testfloat(MissionsMaskAvailability(5, (1<<5)), 1, "MissionsMaskAvailability");
    testfloat(MissionsMaskAvailability(5, (1<<8)), 1, "MissionsMaskAvailability");

    testfloat(MissionsMaskAvailability(5, (1<<3)+(1<<5)), 0.5, "MissionsMaskAvailability");
    testfloat(MissionsMaskAvailability(5, (1<<3)+(1<<7)), 0.5, "MissionsMaskAvailability");
    testfloat(MissionsMaskAvailability(5, (1<<3)+(1<<7)+(1<<10)), 2/3, "MissionsMaskAvailability");

    testfloat(MissionsMaskAvailability(1, 0), 1, "MissionsMaskAvailability");
    testfloat(MissionsMaskAvailability(6, 0), 10/15, "MissionsMaskAvailability");
    testfloat(MissionsMaskAvailability(15, 0), 1/15, "MissionsMaskAvailability");

    testint(BingoActiveMission(1, 0), 1, "BingoActiveMission maybe");
    testint(BingoActiveMission(1, (1<<1)), 2, "BingoActiveMission");
    testint(BingoActiveMission(2, (1<<1)), -1, "BingoActiveMission too late");
    testint(BingoActiveMission(15, (1<<15)), 2, "BingoActiveMission");
    testint(BingoActiveMission(3, (1<<15)), 0, "BingoActiveMission false");
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
    bingo_options(76)=(event="Greasel_ClassDead",desc="Kill %s Greasels",max=5)
    bingo_options(77)=(event="support1",desc="Blow up a gas station",max=1,missions=4096)
    bingo_options(78)=(event="UNATCOTroop_ClassDead",desc="Kill %s UNATCO Troopers",max=15,missions=318)
    bingo_options(79)=(event="Terrorist_ClassDead",desc="Kill %s NSF Terrorists",max=15,missions=62)
    bingo_options(80)=(event="MJ12Troop_ClassDead",desc="Kill %s MJ12 Troopers",max=25,missions=57204)
    bingo_options(81)=(event="MJ12Commando_ClassDead",desc="Kill %s MJ12 Commandos",max=10,missions=56384)
    bingo_options(82)=(event="Karkian_ClassDead",desc="Kill %s Karkians",max=5)
    bingo_options(83)=(event="MilitaryBot_ClassDead",desc="Destroy %s Military Bots",max=5)
    bingo_options(84)=(event="VandenbergToilet",desc="Use the only toilet in Vandenberg",max=1,missions=4096)
    bingo_options(85)=(event="BoatEngineRoom",desc="Access the engine room on the boat in the Hong Kong canals",max=1,missions=64)
    bingo_options(86)=(event="SecurityBot2_ClassDead",desc="Destroy %s Walking Security Bots",max=5)
    bingo_options(87)=(event="SecurityBotSmall_ClassDead",desc="Destroy %s commercial grade Security Bots",max=10)
    bingo_options(88)=(event="SpiderBot_ClassDead",desc="Destroy %s Spider Bots",max=15)
    bingo_options(89)=(event="HumanStompDeath",desc="Stomp %s humans to death",max=3)
    bingo_options(90)=(event="Rat_ClassDead",desc="Kill %s rats",max=30)
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
    bingo_options(107)=(event="Gray_ClassDead",desc="Kill %s Grays",max=5)
    bingo_options(108)=(event="CloneCubes",desc="Read about the four clones in Area 51",max=4,missions=32768)
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
    bingo_options(125)=(event="AlliesKilled",desc="Kill %s allies",max=15)
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
    bingo_options(167)=(event="BlueFusionReactors",desc="Deactivate the four blue fusion reactors",max=4,missions=32768)
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
    bingo_options(178)=(event="BallisticArmor_Activated",desc="Use %s Ballistic Armors",max=3)
    bingo_options(179)=(event="Flare_Activated",desc="Light %s flares",max=15)
    bingo_options(180)=(event="VialAmbrosia_Activated",desc="Take a sip of Ambrosia",max=1,missions=56832)
    bingo_options(181)=(event="Binoculars_Activated",desc="Take a peek through binoculars",max=1)
    bingo_options(182)=(event="HazMatSuit_Activated",desc="Use %s HazMat Suits",max=3)
    bingo_options(183)=(event="AdaptiveArmor_Activated",desc="Use %s Thermoptic Camos",max=3)
    bingo_options(184)=(event="DrinkAlcohol",desc="Drink %s bottles of alcohol",max=75)
    bingo_options(185)=(event="ToxicShip",desc="Enter the toxic ship",max=1,missions=64)
#ifdef injections
    bingo_options(186)=(event="ComputerHacked",desc="Hack %s computers",max=10)
#endif
    bingo_options(187)=(event="TechGoggles_Activated",desc="Use %s tech goggles",max=3)
    bingo_options(188)=(event="Rebreather_Activated",desc="Use %s rebreathers",max=3)
    bingo_options(189)=(event="PerformBurder",desc="Hunt %s birds",max=10)
    bingo_options(190)=(event="GoneFishing",desc="Kill %s fish",max=10)
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
    bingo_options(201)=(event="BurnTrash",desc="Burn %s bags of trash",max=25)
    bingo_options(202)=(event="M07MeetJaime_Played",desc="Meet Jaime in Hong Kong",max=1,missions=96)
    bingo_options(203)=(event="Terrorist_peeptime",desc="Watch Terrorists for %s seconds",max=30,missions=62)
    bingo_options(204)=(event="UNATCOTroop_peeptime",desc="Watch UNATCO Troopers for %s seconds",max=30,missions=318)
    bingo_options(205)=(event="MJ12Troop_peeptime",desc="Watch MJ12 Troopers for %s seconds",max=30,missions=57204)
    bingo_options(206)=(event="MJ12Commando_peeptime",desc="Watch MJ12 Commandos for %s seconds",max=15,missions=56384)
    bingo_options(207)=(event="PawnState_Dancing",desc="You can dance if you want to",max=1)
    bingo_options(208)=(event="BirdWatching",desc="Watch birds for %s seconds",max=30,missions=19838)
    bingo_options(209)=(event="NYEagleStatue_peeped",desc="Look at a bronze eagle statue",max=1,missions=28)
    bingo_options(210)=(event="BrokenPianoPlayed",desc="Play a broken piano",max=1,missions=64)

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

    bingo_win_countdown=-1
}
