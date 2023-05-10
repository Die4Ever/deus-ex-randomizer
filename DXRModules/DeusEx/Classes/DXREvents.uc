class DXREvents extends DXRActorsBase;

var bool died;
var name watchflags[32];
var int num_watchflags;
var int bingo_win_countdown;
var name rewatchflags[8];
var int num_rewatchflags;

struct BingoOption {
    var string event, desc;
    var int max;
    var int missions;// bit masks
};
var BingoOption bingo_options[200];

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


function SetWatchFlags() {
    local MapExit m;
    local ChildMale child;
    local Mechanic mechanic;
    local JunkieFemale jf;
    local GuntherHermann gunther;
    local Mutt starr;// arms smuggler's dog in Paris
    local Hooker1 h;  //Mercedes
    local LowerClassFemale lcf; //Tessa
    local JunkieMale jm;
    local ScientistMale sm;
    local ZoneInfo zone;
    local SkillAwardTrigger skillAward;
    local #var(DeusExPrefix)Mover dxm;
    local LogicTrigger lTrigger;
    local WaterZone water;
    local Toilet closestToilet;
    local BookOpen book;
    local FlagTrigger fTrigger;
    local WIB wib;
    local ComputerPersonal cp;
    local #var(prefix)Maid maid;
    local Trigger trig;
    local BingoTrigger bt;
    local LowerClassMale lcm;
    local Greasel g;
    local int i;

    switch(dxr.localURL) {
    case "00_TrainingFinal":
        WatchFlag('m00meetpage_Played');
        break;

    case "01_NYC_UNATCOISLAND":
        WatchFlag('GuntherFreed');
        WatchFlag('GuntherRespectsPlayer');

        foreach AllActors(class'SkillAwardTrigger',skillAward) {
            if(skillAward.awardMessage=="Exploration Bonus" && skillAward.skillPointsAdded==50 && skillAward.Region.Zone.bWaterZone){
                skillAward.Event='SunkenShip';
                break;
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'SunkenShip',skillAward.Location);

        bt = class'BingoTrigger'.static.Create(self,'BackOfStatue',vect(2503.605469,354.826355,2072.113037),40,40);
        bt = class'BingoTrigger'.static.Create(self,'BackOfStatue',vect(2507.357178,-83.523094,2072.113037),40,40);

        bt = class'BingoTrigger'.static.Create(self,'CommsPit',vect(-6385.640625,1441.881470,-247.901276),40,40);

        bt = class'BingoTrigger'.static.Create(self,'StatueHead',vect(6250,109,504),800,40);

        break;
    case "01_NYC_UNATCOHQ":
        WatchFlag('BathroomBarks_Played');
        WatchFlag('ManBathroomBarks_Played');
        bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vect(1551.508301,-820.408875,-39.901726),95,40);

        bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vect(240.180969,-385.104431,280.098511),80,40);
        bt.MakeClassProximityTrigger(class'FlagPole');


        break;
    case "02_NYC_BATTERYPARK":
        WatchFlag('JoshFed');
        WatchFlag('M02BillyDone');
        WatchFlag('AmbrosiaTagged');
        WatchFlag('MS_DL_Played', true);// this is the datalink played after dealing with the hostage situation, from Mission02.uc

        foreach AllActors(class'ChildMale', child) {
            if(child.BindName == "Josh" || child.BindName == "Billy")
                child.bImportant = true;
        }

        foreach AllActors(class'JunkieMale',jm) {
            if(jm.BindName == "SickMan"){
                jm.bImportant = true;
            }
        }

        foreach AllActors(class'MapExit',m,'Boat_Exit'){
            m.Tag = 'Boat_Exit2';
        }
        Tag = 'Boat_Exit';  //this is a special case, since we do extra handling here


        break;
    case "02_NYC_HOTEL":
        WatchFlag('M02HostagesRescued');// for the hotel, set by Mission02.uc
        bt = class'BingoTrigger'.static.Create(self,'TonThirdFloor',vect(-630,-1955,424),150,40);

        break;
    case "02_NYC_UNDERGROUND":
        WatchFlag('FordSchickRescued');
        break;
    case "02_NYC_BAR":
        WatchFlag('JockSecondStory');
        WatchFlag('LeoToTheBar');
        break;
    case "02_NYC_FREECLINIC":
        WatchFlag('BoughtClinicPlan');
        break;
    case "02_NYC_SMUG":
        WatchFlag('MetSmuggler');
        bt = class'BingoTrigger'.static.Create(self,'botordertrigger',vect(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'mirrordoor',vect(0,0,0));

        break;
    case "03_NYC_BATTERYPARK":
        foreach AllActors(class'JunkieMale',jm) {
            if(jm.BindName == "SickMan"){
                jm.bImportant = true;
            }
        }
        break;
    case "03_NYC_MOLEPEOPLE":
        WatchFlag('MolePeopleSlaughtered');
        bt = class'BingoTrigger'.static.Create(self,'surrender',vect(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'MolePeopleWater',vect(0,-528,48),60,40);
        break;
    case "03_NYC_UNATCOISLAND":
        WatchFlag('DXREvents_LeftOnBoat');
        bt = class'BingoTrigger'.static.Create(self,'CommsPit',vect(-6385.640625,1441.881470,-247.901276),40,40);
        break;
    case "03_NYC_UNATCOHQ":
        WatchFlag('SimonsAssassination');
        bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vect(1551.508301,-820.408875,-39.901726),95,40);
        bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vect(240.180969,-385.104431,280.098511),80,40);
        bt.MakeClassProximityTrigger(class'FlagPole');
        break;
    case "03_NYC_AIRFIELD":
        WatchFlag('BoatDocksAmbrosia');
        bt = class'BingoTrigger'.static.Create(self,'arctrigger',vect(0,0,0));

        bt = class'BingoTrigger'.static.Create(self,'AirfieldGuardTowers',vect(5347.652344,-4286.462402,328),100,40);
        bt = class'BingoTrigger'.static.Create(self,'AirfieldGuardTowers',vect(584.657654,-4306.718750,328),100,40);
        bt = class'BingoTrigger'.static.Create(self,'AirfieldGuardTowers',vect(-2228.463379,-2148.080078,328),100,40);
        bt = class'BingoTrigger'.static.Create(self,'AirfieldGuardTowers',vect(-2225.839600,3800.267578,328),100,40);
        bt = class'BingoTrigger'.static.Create(self,'AirfieldGuardTowers',vect(5339.792969,3815.784912,328),100,40);

        break;
    case "03_NYC_AIRFIELDHELIBASE":
        WatchFlag('HelicopterBaseAmbrosia');
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

        foreach AllActors(class'Mechanic', mechanic) {
            if(mechanic.BindName == "Harold")
                mechanic.bImportant = true;
        }
        break;
    case "04_NYC_BAR":
        WatchFlag('LeoToTheBar');
        break;
    case "04_NYC_HOTEL":
        WatchFlag('GaveRentonGun');
        bt = class'BingoTrigger'.static.Create(self,'TonThirdFloor',vect(-630,-1955,424),150,40);
        break;
    case "05_NYC_UNATCOISLAND":
        bt = class'BingoTrigger'.static.Create(self,'nsfwander',vect(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'CommsPit',vect(-6385.640625,1441.881470,-247.901276),40,40);

        break;
    case "02_NYC_STREET":
        WatchFlag('AlleyBumRescued');
        bt = class'BingoTrigger'.static.Create(self,GetKnicksTag(),vect(0,0,0));
        bt.bingoEvent="MadeBasket";
        break;
    case "04_NYC_STREET":
        bt = class'BingoTrigger'.static.Create(self,GetKnicksTag(),vect(0,0,0));
        bt.bingoEvent="MadeBasket";
        break;
    case "04_NYC_BATTERYPARK":
        bt = class'BingoTrigger'.static.Create(self,'MadeItToBP',vect(0,0,0));
        break;
    case "04_NYC_SMUG":
        RewatchFlag('MetSmuggler');
        bt = class'BingoTrigger'.static.Create(self,'botordertrigger',vect(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'mirrordoor',vect(0,0,0));
        break;
    case "04_NYC_NSFHQ":
        WatchFlag('MostWarehouseTroopsDead');
        break;
    case "04_NYC_UNATCOHQ":
        bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vect(1551.508301,-820.408875,-39.901726),95,40);
        bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vect(240.180969,-385.104431,280.098511),80,40);
        bt.MakeClassProximityTrigger(class'FlagPole');
        break;
    case "04_NYC_UNATCOISLAND":
        bt = class'BingoTrigger'.static.Create(self,'CommsPit',vect(-6385.640625,1441.881470,-247.901276),40,40);
        break;
    case "05_NYC_UNATCOMJ12LAB":
        CheckPaul();
        bt = class'BingoTrigger'.static.Create(self,'nanocage',vect(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'botorders2',vect(0,0,0));
        break;
    case "05_NYC_UNATCOHQ":
        WatchFlag('KnowsAnnasKillphrase1');
        WatchFlag('KnowsAnnasKillphrase2');

        foreach AllActors(class'ComputerPersonal',cp){
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

        bt = class'BingoTrigger'.static.Create(self,'AlexCloset',vect(1551.508301,-820.408875,-39.901726),95,40);

        bt = class'BingoTrigger'.static.Create(self,'BathroomFlags',vect(240.180969,-385.104431,280.098511),80,40);
        bt.MakeClassProximityTrigger(class'FlagPole');

        break;
    case "06_HONGKONG_WANCHAI_CANAL":
        WatchFlag('FoundScientistBody');
        WatchFlag('M06BoughtVersaLife');

        foreach AllActors(class'FlagTrigger',fTrigger,'FoundScientist') {
            // so you don't have to go right into the corner, default is 96, and 40 height
            fTrigger.SetCollisionSize(500, 160);
        }

        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'SecretHold'){
            break;
        }
        skillAward = SkillAwardTrigger(findNearestToActor(class'SkillAwardTrigger',dxm));
        skillAward.Event='BoatEngineRoom';
        bt = class'BingoTrigger'.static.Create(self,'BoatEngineRoom',skillAward.Location);

        foreach AllActors(class'LowerClassMale',lcm,'CanalDrugDealer'){
            break;
        }
        bt = class'BingoTrigger'.static.Create(self,'CanalDrugDeal',lcm.Location,200,40);

        break;
    case "06_HONGKONG_WANCHAI_UNDERWORLD":
        WatchFlag('ClubMercedesConvo1_Done');
        WatchFlag('M07ChenSecondGive_Played');
        WatchFlag('LDDPRussPaid');
        WatchFlag('LeoToTheBar');

        foreach AllActors(class'Hooker1', h) {
            if(h.BindName == "ClubMercedes")
                h.bImportant = true;
        }
        foreach AllActors(class'LowerClassFemale', lcf) {
            if(lcf.BindName == "ClubTessa")
                lcf.bImportant = true;
        }

        bt = class'BingoTrigger'.static.Create(self,'EnterQuickStop',vect(0,438,-267),200,40);
        bt = class'BingoTrigger'.static.Create(self,'EnterQuickStop',vect(220,438,-267),200,40);
        bt = class'BingoTrigger'.static.Create(self,'EnterQuickStop',vect(448,438,-267),200,40);

        bt = class'BingoTrigger'.static.Create(self,'LuckyMoneyFreezer',vect(-1615,-2960,-343),200,40);

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
        closestToilet = Toilet(findNearestToActor(class'Toilet',dxm));

        closestToilet.Event='JocksToilet';
        bt = class'BingoTrigger'.static.Create(self,'JocksToilet',closestToilet.Location);

        foreach AllActors(class'#var(prefix)Maid',maid){
            maid.bImportant = True;
            maid.BarkBindName = "MaySung";
        }

        bt = class'BingoTrigger'.static.Create(self,'TonnochiBillboard',vect(0,550,870),300,40);



        break;
    case "06_HONGKONG_WANCHAI_MARKET":
        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'station_door_05'){
            break;
        }

        skillAward = SkillAwardTrigger(findNearestToActor(class'SkillAwardTrigger',dxm));
        skillAward.Event='PoliceVaultBingo';
        bt = class'BingoTrigger'.static.Create(self,'PoliceVaultBingo',skillAward.Location);

        bt = class'BingoTrigger'.static.Create(self,'WanChaiStores',vect(445,-1032,24),80,40);  //Pottery Store
        bt.Tag='WanChaiPottery';
        bt = class'BingoTrigger'.static.Create(self,'WanChaiStores',vect(640,-1093,200),100,40);  //Tea House
        bt.Tag='WanChaiTea';
        bt = class'BingoTrigger'.static.Create(self,'WanChaiStores',vect(-6,-1416,40),250,40);  //Butcher (Louis Pan works for him too)
        bt.Tag='WanChaiButcher';
        bt = class'BingoTrigger'.static.Create(self,'WanChaiStores',vect(910,-643,40),150,40);  //News Stand
        bt.Tag='WanChaiNews';
        bt = class'BingoTrigger'.static.Create(self,'WanChaiStores',vect(632,-532,40),130,40);  //Flower Shop
        bt.Tag='WanChaiFlowers';


        break;
    case "06_HONGKONG_TONGBASE":
        foreach AllActors(class'WaterZone', water) {
            water.ZonePlayerEvent = 'TongsHotTub';
            break;
        }
        bt = class'BingoTrigger'.static.Create(self,'TongsHotTub',water.Location);

        //Need to make sure these are slightly out of the wall so that explosions hit them
        bt = class'BingoTrigger'.static.Create(self,'TongTargets',vect(-596.3,1826,40),40,100);
        bt.MakeShootingTarget();

        bt = class'BingoTrigger'.static.Create(self,'TongTargets',vect(-466.5,1826,40),40,100);
        bt.MakeShootingTarget();

        bt = class'BingoTrigger'.static.Create(self,'TongTargets',vect(-337.2,1826,40),40,100);
        bt.MakeShootingTarget();

        break;
    case "06_HONGKONG_HELIBASE":
        bt = class'BingoTrigger'.static.Create(self,'purge',vect(0,0,0));

        foreach AllActors(class'Trigger',trig){
            if (trig.classProximityType==class'Basketball'){
                break;
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'HongKongBBall',trig.Location,14,3);
        bt.MakeClassProximityTrigger(class'Basketball');

        break;
    case "06_HONGKONG_MJ12LAB":
        foreach AllActors(class'ZoneInfo',zone){
            if (zone.bFogZone){
                zone.ZonePlayerEvent = 'HongKongGrays';
                break;
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'HongKongGrays',zone.Location);

        foreach AllActors(class'Greasel',g){
            g.bImportant = True;
            g.BindName="JerryTheVentGreasel";
            g.FamiliarName = "Jerry the Vent Greasel";
            g.UnfamiliarName = "Jerry the Vent Greasel";
        }
        WatchFlag('JerryTheVentGreasel_Dead');

        break;
    case "08_NYC_STREET":
        bt = class'BingoTrigger'.static.Create(self,GetKnicksTag(),vect(0,0,0));
        bt.bingoEvent="MadeBasket";
        WatchFlag('StantonAmbushDefeated');
        break;
    case "08_NYC_SMUG":
        WatchFlag('M08WarnedSmuggler');
        RewatchFlag('MetSmuggler');
        bt = class'BingoTrigger'.static.Create(self,'botordertrigger',vect(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'mirrordoor',vect(0,0,0));
        break;
    case "08_NYC_BAR":
        WatchFlag('LeoToTheBar');
        break;
    case "08_NYC_HOTEL":
        bt = class'BingoTrigger'.static.Create(self,'TonThirdFloor',vect(-630,-1955,424),150,40);
        break;
    case "09_NYC_SHIP":
        ReportMissingFlag('M08WarnedSmuggler', "SmugglerDied");

        bt = class'BingoTrigger'.static.Create(self,'CraneControls',vect(3264,-1211,1222));
        bt.Tag = 'Crane';

        bt = class'BingoTrigger'.static.Create(self,'CraneTop',vect(1937,0,1438),100,40);
        bt = class'BingoTrigger'.static.Create(self,'CraneTop',vect(-1791,1082,1423),100,40);

        bt = class'BingoTrigger'.static.Create(self,'CaptainBed',vect(2887,58,960),30,40);


        break;
    case "09_NYC_SHIPFAN":
        bt = class'BingoTrigger'.static.Create(self,'SpinningRoom',vect(0,0,0));
        foreach AllActors(class'ZoneInfo', zone) {
            if (zone.DamageType=='Burned'){
                zone.ZonePlayerEvent = 'SpinningRoom';
            }
        }

        break;
    case "09_NYC_SHIPBELOW":
        WatchFlag('ShipPowerCut');// sparks of electricity come off that thing like lightning!
        bt = class'BingoTrigger'.static.Create(self,'FanTop',vect(-2935,50,840),200,50);

        break;
    case "09_NYC_GRAVEYARD":
        WatchFlag('GaveDowdAmbrosia');
        break;
    case "10_PARIS_CATACOMBS":
        WatchFlag('IcarusCalls_Played');
        foreach AllActors(class'JunkieFemale', jf) {
            if(jf.BindName == "aimee")
                jf.bImportant = true;
        }

        bt = class'BingoTrigger'.static.Create(self,'WarehouseEntered',vect(-580.607361,-2248.497803,-551.895874),200,160);

        break;
    case "10_PARIS_CATACOMBS_TUNNELS":
        foreach AllActors(class'WIB',wib){
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

        foreach AllActors(class'GuntherHermann', gunther) {
            gunther.bInvincible = false;
        }
        foreach AllActors(class'Mutt', starr) {
            starr.bImportant = true;// you're important to me
            starr.BindName = "Starr";
        }

        bt = class'BingoTrigger'.static.Create(self,'Cremation',vect(-2983.597168,774.217407,312.100128),70,40);
        bt.MakeClassProximityTrigger(class'ChefCarcass');
        bt = class'BingoTrigger'.static.Create(self,'Cremation',vect(-2984.404785,662.764954,312.100128),70,40);
        bt.MakeClassProximityTrigger(class'ChefCarcass');

        break;
    case "10_PARIS_CLUB":
        WatchFlag('CamilleConvosDone');
        WatchFlag('LDDPAchilleDone');
        WatchFlag('LeoToTheBar');
        WatchFlag('LouisBerates');
        RewatchFlag('KnowsGuntherKillphrase');

        break;
    case "11_PARIS_CATHEDRAL":
        WatchFlag('GuntherKillswitch');
        bt = class'BingoTrigger'.static.Create(self,'Cremation',vect(2019,-2256,-704),20,15);
        bt.MakeClassProximityTrigger(class'ChefCarcass');
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
        bt = class'BingoTrigger'.static.Create(self,'support1',vect(0,0,0)); //This gets hit when you blow up the gas pumps
        break;
    case "12_VANDENBERG_CMD":
        WatchFlag('MeetTimBaker_Played');
        foreach AllActors(class'ScientistMale', sm) {
            if (sm.BindName=="TimBaker"){
                sm.bImportant = true;
            }
        }

        bt = class'BingoTrigger'.static.Create(self,'bunker_door1',vect(0,0,0));
        bt.bingoEvent = "ActivateVandenbergBots";
        bt = class'BingoTrigger'.static.Create(self,'bunker_door2',vect(50,0,0));
        bt.bingoEvent = "ActivateVandenbergBots";

        foreach AllActors(class'Toilet',closestToilet){
            closestToilet.Event='VandenbergToilet';
        }
        bt = class'BingoTrigger'.static.Create(self,'VandenbergToilet',vect(150,0,0));

        bt = class'BingoTrigger'.static.Create(self,'VandenbergWaterTower',vect(-1030,80,-1600),350,40);

        break;
    case "12_VANDENBERG_TUNNELS":
        bt = class'BingoTrigger'.static.Create(self,'VandenbergReactorRoom',vect(-1427,3287,-2985),500,100);
        break;
    case "12_VANDENBERG_COMPUTER":
        bt = class'BingoTrigger'.static.Create(self,'VandenbergServerRoom',vect(940,2635,-1320),200,40);
        break;
    case "14_OCEANLAB_SILO":
        WatchFlag('MeetDrBernard_Played');
        foreach AllActors(class'ScientistMale', sm) {
            if (sm.BindName=="drbernard"){
                sm.bImportant = true;
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'SiloSlide',vect(25,-4350,165),40,40);
        bt = class'BingoTrigger'.static.Create(self,'SiloWaterTower',vect(-1212,-3427,1992),200,40);
        break;
    case "14_OCEANLAB_LAB":
        WatchFlag('DL_Flooded_Played');
        bt = class'BingoTrigger'.static.Create(self,'OceanLabCrewChamber',vect(1932.035522,3334.331787,-2247.888184),60,40);
        bt = class'BingoTrigger'.static.Create(self,'OceanLabCrewChamber',vect(1932.035522,3334.331787,-2507.888184),60,40);
        bt = class'BingoTrigger'.static.Create(self,'OceanLabCrewChamber',vect(1928.762573,3721.919189,-2507.888184),60,40);
        bt = class'BingoTrigger'.static.Create(self,'OceanLabCrewChamber',vect(1928.762573,3721.919189,-2247.888184),60,40);

        bt = class'BingoTrigger'.static.Create(self,'OceanLabGreenBeacon',vect(1543,3522,-1847),200,200);

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
        bt = class'BingoTrigger'.static.Create(self,'Area51FanShaft',vect(0,0,0));

        //This flag trigger actually doesn't trigger because a security computer can only trigger DeusExMovers
        foreach AllActors(class'FlagTrigger',fTrigger,'blast_door'){
            fTrigger.Tag = 'blast_door_flag';
        }
        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'blast_door'){
            dxm.Event = 'blast_door_flag';
        }
        break;
    case "15_AREA51_FINAL":
        foreach AllActors(class'BookOpen', book) {
            if (book.textTag == '15_Book01'){ //This copy of Jacob's Shadow is also in _BUNKER and _ENTRANCE
                book.textTag = '15_Book02';  //Put that good Thursday man back where he (probably) belongs
            }
        }

        bt = class'BingoTrigger'.static.Create(self,'HeliosControlArms',vect(-3995,2458,128),250,40);
        bt = class'BingoTrigger'.static.Create(self,'HeliosControlArms',vect(-3995,2458,-123),250,40);
        bt = class'BingoTrigger'.static.Create(self,'HeliosControlArms',vect(-3995,2458,-392),250,40);
        bt = class'BingoTrigger'.static.Create(self,'HeliosControlArms',vect(-3995,2458,-902),250,40);
        bt = class'BingoTrigger'.static.Create(self,'HeliosControlArms',vect(-3995,2458,-1152),250,40);
        bt = class'BingoTrigger'.static.Create(self,'HeliosControlArms',vect(-3995,2458,-1413),250,40);
        break;
    case "15_AREA51_PAGE":
#ifdef vanilla
        foreach AllActors(class'WaterZone', water) {
            if (water.Name=='WaterZone5'){// in GMDX v10 and Revision it's WaterZone0
                water.ZonePlayerEvent = 'unbirth';
            }
        }
        bt = class'BingoTrigger'.static.Create(self,'unbirth',vect(0,0,0));
#endif
        bt = class'BingoTrigger'.static.Create(self,'Set_flag_helios',vect(0,0,0));
        bt = class'BingoTrigger'.static.Create(self,'coolant_switch',vect(0,0,0));

        bt = class'BingoTrigger'.static.Create(self,'BlueFusionReactors',vect(0,0,0));
        bt.Tag='node1';
        bt = class'BingoTrigger'.static.Create(self,'BlueFusionReactors',vect(0,0,0));
        bt.Tag='node2';
        bt = class'BingoTrigger'.static.Create(self,'BlueFusionReactors',vect(0,0,0));
        bt.Tag='node3';
        bt = class'BingoTrigger'.static.Create(self,'BlueFusionReactors',vect(0,0,0));
        bt.Tag='node4';

        bt = class'BingoTrigger'.static.Create(self,'A51UCBlocked',vect(0,0,0));
        bt.Tag='UC_shutdoor1';
        bt = class'BingoTrigger'.static.Create(self,'A51UCBlocked',vect(0,0,0));
        bt.Tag='UC_shutdoor2';
        bt = class'BingoTrigger'.static.Create(self,'A51UCBlocked',vect(0,0,0));
        bt.Tag='UC_shutdoor3';

        break;
    }
}

function name GetKnicksTag() {
    local FlagTrigger ft;

    foreach AllActors(class'FlagTrigger',ft) {
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

simulated function bool LeoToTheBar()
{
    local TerroristCommanderCarcass leoBody;
    //player().ClientMessage("Looking for Leo");

    foreach AllActors(class'TerroristCommanderCarcass',leoBody){
        return True;
    };
    return False;
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
            if (LeoToTheBar()){
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
    local MapExit m;
    if (tag == 'Boat_Exit'){
        dxr.flagbase.SetBool('DXREvents_LeftOnBoat', true,, 999);

        foreach AllActors(class'MapExit',m,'Boat_Exit2'){
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
    js.static.Add(j, "location", dxr.player.location);
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
    js.static.Add(j, "location", victim.Location);
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
    _MarkBingo(victim.BindName$"_Dead");
    _MarkBingo(victim.BindName$"_DeadM" $ dxr.dxInfo.missionNumber);
    if( Killer == None || #var(PlayerPawn)(Killer) != None ) {
        if (IsHuman(victim.class) && ((damageType == "Stunned") ||
                                (damageType == "KnockedOut") ||
	                            (damageType == "Poison") ||
                                (damageType == "PoisonEffect"))){
            _MarkBingo(victim.class.name$"_ClassUnconscious");
            _MarkBingo(victim.BindName$"_ClassUnconsciousM" $ dxr.dxInfo.missionNumber);
        } else {
            _MarkBingo(victim.class.name$"_ClassDead");
            _MarkBingo(victim.BindName$"_ClassDeadM" $ dxr.dxInfo.missionNumber);

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
    js.static.Add(j, "location", dxr.player.location);
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
    js.static.Add(j, "location", player.Location);
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
        SetGlobalSeed("bingo");
        _CreateBingoBoard(data);
    }
}

simulated function CreateBingoBoard()
{
    local PlayerDataItem data;
    SetGlobalSeed("bingo"$FRand());
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
    local int progress, max, missions;
    local int options[200], num_options, slot;

    num_options = 0;
    for(x=0; x<ArrayCount(bingo_options); x++) {
        if(bingo_options[x].event == "") continue;
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

    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            if(num_options == 0 || (x==2 && y==2 && dxr.flags.settings.bingo_freespaces>0)) {
                data.SetBingoSpot(x, y, "Free Space", "Free Space", 1, 1, 0);
                continue;
            }

            slot = rng(num_options);
            i = options[slot];
            event = bingo_options[i].event;
            desc = bingo_options[i].desc;
            desc = tweakBingoDescription(event,desc);
            max = bingo_options[i].max;
            missions = bingo_options[i].missions;
            num_options--;
            options[slot] = options[num_options];
            data.SetBingoSpot(x, y, event, desc, 0, max, missions);
        }
    }

    // TODO: we could handle bingo_freespaces>1 by randomly putting free spaces on the board, but this probably won't be a desired feature
    data.ExportBingoState();
}

simulated function int HandleMutualExclusion(MutualExclusion m, int options[200], int num_options) {
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

function CheckBingoWin(DXRando dxr, int numBingos)
{
    //Block this in HX for now
    if(#defined(hx)) return;

    if (dxr.flags.settings.bingo_win > 0){
        if (numBingos >= dxr.flags.settings.bingo_win && dxr.LocalURL!="ENDGAME4"){
            info("Number of bingos: "$numBingos$" has exceeded the bingo win threshold! "$dxr.flags.settings.bingo_win);
            bingo_win_countdown = 5;
        }
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

function _MarkBingo(coerce string eventname)
{
    local int previousbingos, nowbingos, time;
    local PlayerDataItem data;
    local string j;
    local class<Json> js;
    js = class'Json';

    // combine some events
    switch(eventname) {
        case "ManBathroomBarks_Played":
            eventname = "BathroomBarks_Played";// LDDP
            break;
        case "hostage_female_Dead":
        case "hostage_Dead":
            eventname = "paris_hostage_Dead";
            break;
        case "KnowsAnnasKillphrase1":
        case "KnowsAnnasKillphrase2":
            eventname = "KnowsAnnasKillphrase";
            break;
        case "SecurityBot3_ClassDead":
        case "SecurityBot4_ClassDead":
            eventname = "SecurityBotSmall_ClassDead";
            break;
        case "SpiderBot2_ClassDead":
            eventname="SpiderBot_ClassDead";
            break;
        case "LDDPRussPaid":
        case "ClubMercedesConvo1_Done":
            eventname="ClubEntryPaid";
            break;
        case "LDDPAchilleDone":
            eventname="CamilleConvosDone";
            break;
        case "KarkianBaby_ClassDead":
            eventname="Karkian_ClassDead";
            break;
        case "AmbrosiaTagged":
        case "BoatDocksAmbrosia":
        case "HelicopterBaseAmbrosia":
        case "747Ambrosia":
            eventname="StolenAmbrosia";
            break;
        case "PlayerKilledLebedev":
            //Check to make sure he wasn't knocked out
            if (dxr.flagbase.GetBool('JuanLebedev_Unconscious')) {
                return; //Don't mark this event if knocked out
            }
            break;
        case "UNATCOClone1_ClassDead":
        case "UNATCOClone2_ClassDead":
        case "UNATCOClone3_ClassDead":
        case "UNATCOClone4_ClassDead":
            eventname="UNATCOTroop_ClassDead";
            break;
        case "NSFClone1_ClassDead":
        case "NSFClone2_ClassDead":
        case "NSFClone3_ClassDead":
        case "NSFClone4_ClassDead":
            eventname="Terrorist_ClassDead";
            break;
        case "MJ12Clone1_ClassDead":
        case "MJ12Clone2_ClassDead":
        case "MJ12Clone3_ClassDead":
        case "MJ12Clone4_ClassDead":
            eventname="MJ12Troop_ClassDead";
            break;
        case "DXRMedicalBot_ClassDead":
            eventname="MedicalBot_ClassDead";
            break;
        case "DXRRepairBot_ClassDead":
            eventname="RepairBot_ClassDead";
            break;
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
        js.static.Add(j, "location", player().Location);
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
    if(missionAnded > 0) return 2;// 2==true
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
    if(missionAnded > 0) return 2;// 2==true
#endif

    if(missionsMask < (1<<minMission)) {
        return -1;// impossible in future missions
    }

    return 0;// 0==false
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
    bingo_options(53)=(event="ExtinguishFire",desc="Extinguish yourself with running water",max=1)
    bingo_options(54)=(event="SubwayHostagesSaved",desc="Save both hostages in the subway",max=1,missions=4)
    bingo_options(55)=(event="HotelHostagesSaved",desc="Save all hostages in the hotel",max=1,missions=4)
    bingo_options(56)=(event="SilhouetteHostagesAllRescued",desc="Save both hostages in the catacombs",max=1,missions=1024)
    bingo_options(57)=(event="JosephManderley_Dead",desc="Kill Joseph Manderley",max=1,missions=32)
    bingo_options(58)=(event="MadeItToBP",desc="Escape to Battery Park",max=1,missions=16)
    bingo_options(59)=(event="MetSmuggler",desc="Meet Smuggler",max=1,missions=276)
    bingo_options(60)=(event="SickMan_Dead",desc="Kill the sick man who wants to die",max=1,missions=12)
    bingo_options(61)=(event="M06PaidJunkie",desc="Help the junkie on Tonnochi Road",max=1,missions=64)
    bingo_options(62)=(event="M06BoughtVersaLife",desc="Get maps of the VersaLife building",max=1,missions=64)
    bingo_options(63)=(event="FlushToilet",desc="Use 30 toilets",max=30)
    bingo_options(64)=(event="FlushUrinal",desc="Use 20 urinals",max=20)
    bingo_options(65)=(event="MeetTimBaker_Played",desc="Free Tim from the Vandenberg storage room",max=1,missions=4096)
    bingo_options(66)=(event="MeetDrBernard_Played",desc="Find the man locked in the bathroom",max=1,missions=16384)
    bingo_options(67)=(event="KnowsGuntherKillphrase",desc="Learn Gunther's Killphrase",max=1,missions=1056)
    bingo_options(68)=(event="KnowsAnnasKillphrase",desc="Learn both parts of Anna's Killphrase",max=2,missions=32)
    bingo_options(69)=(event="Area51FanShaft",desc="Jump!  You can make it!",max=1,missions=32768)
    bingo_options(70)=(event="PoliceVaultBingo",desc="Visit the Hong Kong police vault",max=1,missions=64)
    bingo_options(71)=(event="SunkenShip",desc="Enter the sunken ship at Liberty Island",max=1,missions=2)
    bingo_options(72)=(event="SpinShipsWheel",desc="Spin 3 ships wheels",max=3)
    bingo_options(73)=(event="ActivateVandenbergBots",desc="Activate both of the bots at Vandenberg",max=2,missions=4096)
    bingo_options(74)=(event="TongsHotTub",desc="Take a dip in Tracer Tong's hot tub",max=1,missions=64)
    bingo_options(75)=(event="JocksToilet",desc="Use Jock's toilet",max=1,missions=64)
    bingo_options(76)=(event="Greasel_ClassDead",desc="Kill 5 Greasels",max=5)
    bingo_options(77)=(event="support1",desc="Blow up a gas station",max=1,missions=4096)
    bingo_options(78)=(event="UNATCOTroop_ClassDead",desc="Kill 15 UNATCO Troopers",max=15)
    bingo_options(79)=(event="Terrorist_ClassDead",desc="Kill 15 NSF Terrorists",max=15)
    bingo_options(80)=(event="MJ12Troop_ClassDead",desc="Kill 25 MJ12 Troopers",max=25)
    bingo_options(81)=(event="MJ12Commando_ClassDead",desc="Kill 10 MJ12 Commandos",max=10)
    bingo_options(82)=(event="Karkian_ClassDead",desc="Kill 5 Karkians",max=5)
    bingo_options(83)=(event="MilitaryBot_ClassDead",desc="Destroy 5 Military Bots",max=5)
    bingo_options(84)=(event="VandenbergToilet",desc="Use the only toilet in Vandenberg",max=1,missions=4096)
    bingo_options(85)=(event="BoatEngineRoom",desc="Access the engine room on the boat in the Hong Kong canals",max=1,missions=64)
    bingo_options(86)=(event="SecurityBot2_ClassDead",desc="Destroy 5 Walking Security Bots",max=5)
    bingo_options(87)=(event="SecurityBotSmall_ClassDead",desc="Destroy 15 commercial grade Security Bots",max=15)
    bingo_options(88)=(event="SpiderBot_ClassDead",desc="Destroy 15 Spider Bots",max=15)
    bingo_options(89)=(event="HumanStompDeath",desc="Stomp 3 humans to death",max=3)
    bingo_options(90)=(event="Rat_ClassDead",desc="Kill 40 rats",max=40)
    bingo_options(91)=(event="UNATCOTroop_ClassUnconscious",desc="Knock out 15 UNATCO Troopers",max=15)
    bingo_options(92)=(event="Terrorist_ClassUnconscious",desc="Knock out 15 NSF Terrorists",max=15)
    bingo_options(93)=(event="MJ12Troop_ClassUnconscious",desc="Knock out 25 MJ12 Troopers",max=25)
    bingo_options(94)=(event="MJ12Commando_ClassUnconscious",desc="Knock out 2 MJ12 Commandos",max=2)
    bingo_options(95)=(event="purge",desc="Release the gas in the MJ12 Helibase",max=1,missions=64)
    bingo_options(96)=(event="ChugWater",desc="Chug water 30 times",max=30)
#ifndef vmd
    bingo_options(97)=(event="ChangeClothes",desc="Change clothes at 3 different clothes racks",max=3)
#endif
    bingo_options(98)=(event="arctrigger",desc="Shut off the electricity at the airfield",max=1,missions=8)
    bingo_options(99)=(event="LeoToTheBar",desc="Bring the terrorist commander to the bar",max=1,missions=17686)
    bingo_options(100)=(event="KnowYourEnemy",desc="Read all 6 Know Your Enemy bulletins",max=6,missions=10)
    bingo_options(101)=(event="09_NYC_DOCKYARD--796967769",desc="Learn Jenny's phone number",max=1,missions=512)
    bingo_options(102)=(event="JacobsShadow",desc="Read 4 parts of Jacob's Shadow",max=4,missions=38492)
    bingo_options(103)=(event="ManWhoWasThursday",desc="Read 4 parts of The Man Who Was Thursday",max=4,missions=54300)
    bingo_options(104)=(event="GreeneArticles",desc="Read 4 newspaper articles by Joe Greene",max=4,missions=270)
    bingo_options(105)=(event="MoonBaseNews",desc="Read news about the Lunar Mining Complex",max=1,missions=76)
    bingo_options(106)=(event="06_Datacube05",desc="Learn Maggie Chow's Birthday",max=1,missions=64)
    bingo_options(107)=(event="Gray_ClassDead",desc="Kill 5 Grays",max=5)
    bingo_options(108)=(event="CloneCubes",desc="Read about the four clones in Area 51",max=4,missions=32768)
    bingo_options(109)=(event="blast_door_open",desc="Open the blast doors at Area 51",max=1,missions=32768)
    bingo_options(110)=(event="SpinningRoom",desc="Pass through the spinning room",max=1,missions=512)
    bingo_options(111)=(event="MolePeopleSlaughtered",desc="Slaughter the Mole People",max=1,missions=8)
    bingo_options(112)=(event="surrender",desc="Make the NSF surrender in the Mole People tunnels",max=1,missions=8)
    bingo_options(113)=(event="nanocage",desc="Open the cages in the UNATCO MJ12 Lab",max=1,missions=32)
#ifdef vanilla
    bingo_options(114)=(event="unbirth",desc="Return to the tube that spawned you",max=1,missions=32768)
#endif
    bingo_options(115)=(event="StolenAmbrosia",desc="Find 3 stolen barrels of Ambrosia",max=3,missions=12)
    bingo_options(116)=(event="AnnaKilledLebedev",desc="Let Anna kill Lebedev",max=1,missions=8)
    bingo_options(117)=(event="PlayerKilledLebedev",desc="Kill Lebedev yourself",max=1,missions=8)
    bingo_options(118)=(event="JuanLebedev_Unconscious",desc="Knock out Lebedev",max=1,missions=8)
    bingo_options(119)=(event="BrowserHistoryCleared",desc="Clear your browser history before quitting",max=1,missions=32)
    bingo_options(120)=(event="AnnaKillswitch",desc="Use Anna's Killphrase",max=1,missions=32)
    bingo_options(121)=(event="AnnaNavarre_DeadM3",desc="Kill Anna Navarre in Mission 3",max=1,missions=8)
    bingo_options(122)=(event="AnnaNavarre_DeadM4",desc="Kill Anna Navarre in Mission 4",max=1,missions=16)
    bingo_options(123)=(event="AnnaNavarre_DeadM5",desc="Kill Anna Navarre in Mission 5",max=1,missions=32)
    bingo_options(124)=(event="SimonsAssassination",desc="Let Walton lose his patience",max=1,missions=8)
    bingo_options(125)=(event="AlliesKilled",desc="Kill 15 allies",max=15)
    bingo_options(126)=(event="MaySung_Dead",desc="Kill Maggie Chows maid",max=1,missions=64)
    bingo_options(127)=(event="MostWarehouseTroopsDead",desc="Eliminate the UNATCO troops defending NSF HQ",max=1,missions=16)
    bingo_options(128)=(event="CleanerBot_ClassDead",desc="Destroy 5 Cleaner Bots",max=5)
    bingo_options(129)=(event="MedicalBot_ClassDead",desc="Destroy 3 Medical Bots",max=3)
    bingo_options(130)=(event="RepairBot_ClassDead",desc="Destroy 3 Repair Bots",max=3)
    bingo_options(131)=(event="DrugDealer_Dead",desc="Kill the Drug Dealer in Brooklyn Bridge Station",max=1,missions=8)
    bingo_options(132)=(event="botordertrigger",desc="The Smuggler is whacked-out paranoid",max=1,missions=276)
    bingo_options(133)=(event="IgnitedPawn",desc="Set 15 people on fire",max=15)
    bingo_options(134)=(event="GibbedPawn",desc="Blow up 15 people",max=15)
    bingo_options(135)=(event="IcarusCalls_Played",desc="Take a phone call from Icarus in Paris",max=1,missions=1024)
    bingo_options(136)=(event="AlexCloset",desc="Go into Alex's closet",max=1,missions=58)
    bingo_options(137)=(event="BackOfStatue",desc="Climb to the balcony on the back of the statue",max=1,missions=2)
    bingo_options(138)=(event="CommsPit",desc="Check the SATCOM wiring 3 times",max=3,missions=58)
    bingo_options(139)=(event="StatueHead",desc="Visit the head of the Statue of Liberty",max=1,missions=2)
    bingo_options(140)=(event="CraneControls",desc="Use the dockside crane controls",max=1,missions=512)
    bingo_options(141)=(event="CraneTop",desc="Visit the end of both cranes onboard the superfreighter",max=2,missions=512)
    bingo_options(142)=(event="CaptainBed",desc="Jump on the superfreighter captains bed",max=1,missions=512)
    bingo_options(143)=(event="FanTop",desc="Get blown to the top of the superfreighter ventilation shaft",max=1,missions=512)
    bingo_options(144)=(event="LouisBerates",desc="Sneak behind the Porte De L'Enfer door man",max=1,missions=1024)
    bingo_options(145)=(event="EverettAquarium",desc="Go for a swim in Everett's aquarium",max=1,missions=2048)
    bingo_options(146)=(event="TrainTracks",desc="Jump on to the train tracks in Paris",max=1,missions=2048)
    bingo_options(147)=(event="OceanLabCrewChamber",desc="Visit all 4 crew chambers in the Ocean Lab",max=4,missions=16384)
    bingo_options(148)=(event="HeliosControlArms",desc="Jump down the control arms in Helios' chamber",max=1,missions=32768)
    bingo_options(149)=(event="TongTargets",desc="Use the shooting range in Tong's base",max=1,missions=64)
    bingo_options(150)=(event="WanChaiStores",desc="Visit 4 stores in the Wan Chai market",max=4,missions=64)
    bingo_options(151)=(event="HongKongBBall",desc="Shoot some hoops in Hong Kong",max=1,missions=64)
    bingo_options(152)=(event="CanalDrugDeal",desc="Walk in on a drug deal in progress",max=1,missions=64)
    bingo_options(153)=(event="HongKongGrays",desc="Enter the Hong Kong Gray enclosure",max=1,missions=64)
    bingo_options(154)=(event="EnterQuickStop",desc="Enter the Quick Stop in Hong Kong",max=1,missions=64)
    bingo_options(155)=(event="LuckyMoneyFreezer",desc="Enter the Lucky Money freezer",max=1,missions=64)
    bingo_options(156)=(event="TonnochiBillboard",desc="Get onto the billboard over Tonnochi road",max=1,missions=64)
    bingo_options(157)=(event="AirfieldGuardTowers",desc="Visit 3 of the Airfield guard towers",max=3,missions=8)
    bingo_options(158)=(event="mirrordoor",desc="Access Smuggler's secret stash",max=1,missions=276)
    bingo_options(159)=(event="MolePeopleWater",desc="Bathe in the Mole People water supply",max=1,missions=8)
    bingo_options(160)=(event="botorders2",desc="Alter the bot AI in the MJ12 base under UNATCO",max=1,missions=32)
    bingo_options(161)=(event="BathroomFlags",desc="Place a flag in Manderley's bathroom 3 times",max=3,missions=58)
    bingo_options(162)=(event="SiloSlide",desc="Take the silo slide",max=1,missions=16384)
    bingo_options(163)=(event="SiloWaterTower",desc="Climb the water tower at the silo",max=1,missions=16384)
    bingo_options(164)=(event="TonThirdFloor",desc="Go to the third floor of the 'Ton",max=1,missions=276)
    bingo_options(165)=(event="Set_flag_helios",desc="Engage the Aquinas primary router",max=1,missions=32768)
    bingo_options(166)=(event="coolant_switch",desc="Flush the reactor coolant",max=1,missions=32768)
    bingo_options(167)=(event="BlueFusionReactors",desc="Deactivate the four blue fusion reactors",max=4,missions=32768)
    bingo_options(168)=(event="A51UCBlocked",desc="Close the doors to 3 UCs in Area 51",max=3,missions=32768)
    bingo_options(169)=(event="VandenbergReactorRoom",desc="Enter the reactor room in the Vandenberg tunnels",max=1,missions=4096)
    bingo_options(170)=(event="VandenbergServerRoom",desc="Enter the server room in the Vandenberg control center",max=1,missions=4096)
    bingo_options(171)=(event="VandenbergWaterTower",desc="Climb the water tower in Vandenberg",max=1,missions=4096)
    bingo_options(172)=(event="Cremation",desc="Cook the cook",max=1,missions=2048)
    bingo_options(173)=(event="OceanLabGreenBeacon",desc="Swim to the green beacon",max=1,missions=16384)
    bingo_options(174)=(event="PageTaunt_Played",desc="Let Bob Page taunt you in the Ocean Lab",max=1,missions=16384)
    //bingo_options()=(event="M11WaltonHolo_Played",desc="Talk to Walton Simons after defeating Gunther",max=1,missions=2048)
    bingo_options(175)=(event="JerryTheVentGreasel_Dead",desc="Kill Jerry the Vent Greasel",max=1,missions=64)


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

    bingo_win_countdown=-1
}
