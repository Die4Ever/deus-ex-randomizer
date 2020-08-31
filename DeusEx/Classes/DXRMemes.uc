class DXRMemes extends DXRActorsBase;

var Actor rotating;

function AnyEntry()
{
    local DXLogo logo;
    local IonStormLogo islogo;
    local EidosLogo elogo;
    local ElectricityEmitter elec;
    local Actor a;
    local Rotator r;
    local Vector v;
    local Class<Actor> newActorClass;
    Super.AnyEntry();

    switch(dxr.localURL)
    {
        case "DXONLY":
        case "DX":
            l("Memeing up "$ dxr.localURL);
            foreach AllActors(class'DXLogo', logo)
            {                
                newActorClass = GetRandomActorClass();
                l("DXLogo replaced with "$newActorClass);
                a = ReplaceActor(logo, newActorClass );
                
                //Get it spinning just right
                rotating = a;
                a.SetPhysics(PHYS_None);
                a.bFixedRotationDir = True;
                a.bRotateToDesired = False;
                r.Pitch = 2500;
                r.Yaw = 5000;
                r.Roll = 0;
                a.RotationRate = r;
                
                //Get rid of any ambient sounds it may make
                a.AmbientSound = None;
                
                GotoState('RotatingState');
            }

            foreach AllActors(class'IonStormLogo', islogo)
            {
                newActorClass = GetRandomActorClass();
                l("IonStormLogo replaced with "$newActorClass);
                a = ReplaceActor(islogo, newActorClass );
                a.SetPhysics(PHYS_None);
                a.DrawScale *= 2.0;
            }

            foreach AllActors(class'EidosLogo', elogo)
            {
                newActorClass = GetRandomActorClass();
                l("EidosLogo replaced with "$newActorClass);
                a = ReplaceActor(elogo, newActorClass );
                a.SetPhysics(PHYS_None);
                a.DrawScale *= 2.0;
            }
            
            foreach AllActors(class'ElectricityEmitter', elec)
            {
                v.Z = 70;
                elec.move(v);
            }
            break;

        case "INTRO":
        case "ENDGAME1":
        case "ENDGAME2":
        case "ENDGAME3":
        case "ENDGAME4":
        case "00_TRAINING":
            // extra randomization in the intro for the lolz, ENDGAME4 doesn't have a DeusExLevelInfo object though, so it doesn't get randomized :(
            l("Memeing up "$ dxr.localURL);
            RandomizeIntro();
            break;
    }
}

state() RotatingState {
    event Tick(float deltaTime)
    {
        local Rotator r;
        r = rotating.Rotation;
        r.Pitch += float(rotating.RotationRate.Pitch) * deltaTime;
        r.Yaw += float(rotating.RotationRate.Yaw) * deltaTime;
        r.Roll += float(rotating.RotationRate.Roll) * deltaTime;
        rotating.SetRotation(r);
    }
}

function RandomizeIntro()
{
    local Tree t;
    local DeusExMover m;
    local BreakableGlass g;
    local Actor a;
    //local CameraPoint c;

    SetSeed("RandomizeIntro");
    
    foreach AllActors(class'Tree', t)
    { // exclude 90% of trees from the SwapAll by temporarily hiding them
        if( rng(100) < 90 ) t.bHidden = true;
    }
    foreach AllActors(class'DeusExMover', m)
    {
        m.bHidden = true;
    }
    foreach AllActors(class'BreakableGlass', g)
    {
        g.bHidden = true;
    }
    dxr.Player.bHidden = true;
    SwapAll('Actor');
    dxr.Player.bHidden = false;
    foreach AllActors(class'Actor', a)
    {
        if( a.bHidden ) continue;
        SetActorScale(a, float(rng(1500))/1000 + 0.3);
        a.Fatness = rng(50) + 105;
    }

    foreach AllActors(class'Tree', t)
    {
        t.bHidden = false;
    }
    foreach AllActors(class'DeusExMover', m)
    {
        m.bHidden = false;
    }
    foreach AllActors(class'BreakableGlass', g)
    {
        g.bHidden = false;
    }

    /*foreach AllActors(class'CameraPoint', c)
    {
        c.bHidden = false;
    }
    SwapAll('CameraPoint');
    foreach AllActors(class'CameraPoint', c)
    {
        c.bHidden = true;
    }*/
}

function bool is_valid(string s, class<Object> o)
{// determines if a class is worthy of replacing the logo in the menu
    local class<Actor> a;
    a = class<Actor>(o);
    if ( a == None ) return false;
    if ( a.default.bHidden ) return false;
    if ( a.default.Mesh == None ) return false;
    if ( a.default.DrawType != DT_Mesh ) return false;
    if ( a.default.Style != STY_Normal ) return false;

    log( "if ( r == i++ ) return class'" $ s $ "';" );
    //i++;//was a global variable in my code that outputted code...
    return true;
}

function class<Actor> GetRandomActorClass()
{
    local int r, i;

    r = rng(519);

    if ( r == i++ ) return class'AcousticSensor';
    if ( r == i++ ) return class'AdaptiveArmor';
    if ( r == i++ ) return class'AIPrototype';
    if ( r == i++ ) return class'AlarmLight';
    if ( r == i++ ) return class'AlarmUnit';
    if ( r == i++ ) return class'AlexJacobson';
    if ( r == i++ ) return class'AlexJacobsonCarcass';
    if ( r == i++ ) return class'Ammo10mm';
    if ( r == i++ ) return class'Ammo20mm';
    if ( r == i++ ) return class'Ammo3006';
    if ( r == i++ ) return class'Ammo762mm';
    if ( r == i++ ) return class'AmmoBattery';
    if ( r == i++ ) return class'ammocrate';
    if ( r == i++ ) return class'AmmoDart';
    if ( r == i++ ) return class'AmmoDartFlare';
    if ( r == i++ ) return class'AmmoDartPoison';
    if ( r == i++ ) return class'AmmoEMPGrenade';
    //if ( r == i++ ) return class'AmmoGasGrenade';
    //if ( r == i++ ) return class'AmmoGraySpit';
    //if ( r == i++ ) return class'AmmoGreaselSpit';
    //if ( r == i++ ) return class'AmmoLAM';
    //if ( r == i++ ) return class'AmmoNanoVirusGrenade';
    if ( r == i++ ) return class'AmmoNapalm';
    //if ( r == i++ ) return class'AmmoNone';
    if ( r == i++ ) return class'AmmoPepper';
    if ( r == i++ ) return class'AmmoPlasma';
    if ( r == i++ ) return class'AmmoRocket';
    if ( r == i++ ) return class'AmmoRocketMini';
    //if ( r == i++ ) return class'AmmoRocketRobot';
    if ( r == i++ ) return class'AmmoRocketWP';
    if ( r == i++ ) return class'AmmoSabot';
    if ( r == i++ ) return class'AmmoShell';
    if ( r == i++ ) return class'AmmoShuriken';
    if ( r == i++ ) return class'AnnaNavarre';
    if ( r == i++ ) return class'AnnaNavarreCarcass';
    if ( r == i++ ) return class'ATM';
    if ( r == i++ ) return class'AttackHelicopter';
    if ( r == i++ ) return class'AugmentationCannister';
    if ( r == i++ ) return class'AugmentationUpgradeCannister';
    if ( r == i++ ) return class'AutoTurret';
    if ( r == i++ ) return class'AutoTurretGun';
    if ( r == i++ ) return class'AutoTurretGunSmall';
    if ( r == i++ ) return class'AutoTurretSmall';
    if ( r == i++ ) return class'BallisticArmor';
    if ( r == i++ ) return class'Barrel1';
    if ( r == i++ ) return class'BarrelAmbrosia';
    if ( r == i++ ) return class'BarrelFire';
    if ( r == i++ ) return class'BarrelVirus';
    if ( r == i++ ) return class'Bartender';
    if ( r == i++ ) return class'BartenderCarcass';
    if ( r == i++ ) return class'Basket';
    if ( r == i++ ) return class'Basketball';
    if ( r == i++ ) return class'BeamTrigger';
    if ( r == i++ ) return class'Binoculars';
    if ( r == i++ ) return class'BioelectricCell';
    if ( r == i++ ) return class'BlackHelicopter';
    if ( r == i++ ) return class'BoatPerson';
    if ( r == i++ ) return class'BoatPersonCarcass';
    if ( r == i++ ) return class'BobPage';
    if ( r == i++ ) return class'BobPageAugmented';
    if ( r == i++ ) return class'BobPageCarcass';
    if ( r == i++ ) return class'BoneFemur';
    if ( r == i++ ) return class'BoneSkull';
    if ( r == i++ ) return class'BookClosed';
    if ( r == i++ ) return class'BookOpen';
    if ( r == i++ ) return class'BoxLarge';
    if ( r == i++ ) return class'BoxMedium';
    if ( r == i++ ) return class'BoxSmall';
    if ( r == i++ ) return class'BumFemale';
    if ( r == i++ ) return class'BumFemaleCarcass';
    if ( r == i++ ) return class'BumMale';
    if ( r == i++ ) return class'BumMale2';
    if ( r == i++ ) return class'BumMale2Carcass';
    if ( r == i++ ) return class'BumMale3';
    if ( r == i++ ) return class'BumMale3Carcass';
    if ( r == i++ ) return class'BumMaleCarcass';
    if ( r == i++ ) return class'Buoy';
    if ( r == i++ ) return class'Bushes1';
    if ( r == i++ ) return class'Bushes2';
    if ( r == i++ ) return class'Bushes3';
    if ( r == i++ ) return class'Businessman1';
    if ( r == i++ ) return class'Businessman1Carcass';
    if ( r == i++ ) return class'Businessman2';
    if ( r == i++ ) return class'Businessman2Carcass';
    if ( r == i++ ) return class'Businessman3';
    if ( r == i++ ) return class'Businessman3Carcass';
    if ( r == i++ ) return class'Businesswoman1';
    if ( r == i++ ) return class'Businesswoman1Carcass';
    if ( r == i++ ) return class'Butler';
    if ( r == i++ ) return class'ButlerCarcass';
    if ( r == i++ ) return class'Button1';
    if ( r == i++ ) return class'Cactus1';
    if ( r == i++ ) return class'Cactus2';
    if ( r == i++ ) return class'CageLight';
    if ( r == i++ ) return class'Candybar';
    if ( r == i++ ) return class'CarBurned';
    if ( r == i++ ) return class'CarStripped';
    if ( r == i++ ) return class'Cart';
    if ( r == i++ ) return class'CarWrecked';
    if ( r == i++ ) return class'Cat';
    if ( r == i++ ) return class'CatCarcass';
    if ( r == i++ ) return class'CeilingFan';
    if ( r == i++ ) return class'CeilingFanMotor';
    if ( r == i++ ) return class'Chad';
    if ( r == i++ ) return class'ChadCarcass';
    if ( r == i++ ) return class'Chair1';
    if ( r == i++ ) return class'ChairLeather';
    if ( r == i++ ) return class'Chandelier';
    if ( r == i++ ) return class'Chef';
    if ( r == i++ ) return class'ChefCarcass';
    if ( r == i++ ) return class'ChildMale';
    if ( r == i++ ) return class'ChildMale2';
    if ( r == i++ ) return class'ChildMale2Carcass';
    if ( r == i++ ) return class'ChildMaleCarcass';
    if ( r == i++ ) return class'CigaretteMachine';
    if ( r == i++ ) return class'Cigarettes';
    if ( r == i++ ) return class'CleanerBot';
    if ( r == i++ ) return class'ClothesRack';
    if ( r == i++ ) return class'CoffeeTable';
    if ( r == i++ ) return class'ComputerPersonal';
    if ( r == i++ ) return class'ComputerPublic';
    if ( r == i++ ) return class'ComputerSecurity';
    if ( r == i++ ) return class'ControlPanel';
    if ( r == i++ ) return class'Cop';
    if ( r == i++ ) return class'CopCarcass';
    if ( r == i++ ) return class'CouchLeather';
    if ( r == i++ ) return class'CrateBreakableMedCombat';
    if ( r == i++ ) return class'CrateBreakableMedGeneral';
    if ( r == i++ ) return class'CrateBreakableMedMedical';
    if ( r == i++ ) return class'CrateExplosiveSmall';
    if ( r == i++ ) return class'CrateUnbreakableLarge';
    if ( r == i++ ) return class'CrateUnbreakableMed';
    if ( r == i++ ) return class'CrateUnbreakableSmall';
    if ( r == i++ ) return class'Credits';
    if ( r == i++ ) return class'Cushion';
    if ( r == i++ ) return class'Dart';
    if ( r == i++ ) return class'DartFlare';
    if ( r == i++ ) return class'DartPoison';
    if ( r == i++ ) return class'DataCube';
    //if ( r == i++ ) return class'DataVaultImage';
    if ( r == i++ ) return class'DentonClone';
    if ( r == i++ ) return class'Doberman';
    if ( r == i++ ) return class'DobermanCarcass';
    if ( r == i++ ) return class'Doctor';
    if ( r == i++ ) return class'DoctorCarcass';
    if ( r == i++ ) return class'DXLogo';
    if ( r == i++ ) return class'DXText';
    if ( r == i++ ) return class'Earth';
    if ( r == i++ ) return class'EidosLogo';
    if ( r == i++ ) return class'EMPGrenade';
    if ( r == i++ ) return class'Fan1';
    if ( r == i++ ) return class'Fan1Vertical';
    if ( r == i++ ) return class'Fan2';
    if ( r == i++ ) return class'Faucet';
    if ( r == i++ ) return class'Female1';
    if ( r == i++ ) return class'Female1Carcass';
    if ( r == i++ ) return class'Female2';
    if ( r == i++ ) return class'Female2Carcass';
    if ( r == i++ ) return class'Female3';
    if ( r == i++ ) return class'Female3Carcass';
    if ( r == i++ ) return class'Female4';
    if ( r == i++ ) return class'Female4Carcass';
    if ( r == i++ ) return class'FireExtinguisher';
    if ( r == i++ ) return class'FirePlug';
    if ( r == i++ ) return class'Fish';
    if ( r == i++ ) return class'Fish2';
    if ( r == i++ ) return class'Fishes';
    if ( r == i++ ) return class'FlagPole';
    if ( r == i++ ) return class'Flare';
    if ( r == i++ ) return class'Flask';
    //if ( r == i++ ) return class'FleshFragment';
    if ( r == i++ ) return class'Flowers';
    if ( r == i++ ) return class'Fly';
    if ( r == i++ ) return class'FordSchick';
    if ( r == i++ ) return class'FordSchickCarcass';
    if ( r == i++ ) return class'GarySavage';
    if ( r == i++ ) return class'GarySavageCarcass';
    if ( r == i++ ) return class'GasGrenade';
    if ( r == i++ ) return class'GilbertRenton';
    if ( r == i++ ) return class'GilbertRentonCarcass';
    //if ( r == i++ ) return class'GlassFragment';
    if ( r == i++ ) return class'GordonQuick';
    if ( r == i++ ) return class'GordonQuickCarcass';
    if ( r == i++ ) return class'Gray';
    if ( r == i++ ) return class'GrayCarcass';
    if ( r == i++ ) return class'Greasel';
    if ( r == i++ ) return class'GreaselCarcass';
    if ( r == i++ ) return class'GuntherHermann';
    if ( r == i++ ) return class'GuntherHermannCarcass';
    if ( r == i++ ) return class'HangingChicken';
    if ( r == i++ ) return class'HangingShopLight';
    if ( r == i++ ) return class'HarleyFilben';
    if ( r == i++ ) return class'HarleyFilbenCarcass';
    if ( r == i++ ) return class'HazMatSuit';
    //if ( r == i++ ) return class'HECannister20mm';
    if ( r == i++ ) return class'HKBirdcage';
    if ( r == i++ ) return class'HKBuddha';
    if ( r == i++ ) return class'HKChair';
    if ( r == i++ ) return class'HKCouch';
    if ( r == i++ ) return class'HKHangingLantern';
    if ( r == i++ ) return class'HKHangingLantern2';
    if ( r == i++ ) return class'HKHangingPig';
    if ( r == i++ ) return class'HKIncenseBurner';
    if ( r == i++ ) return class'HKMarketLight';
    if ( r == i++ ) return class'HKMarketTable';
    if ( r == i++ ) return class'HKMarketTarp';
    if ( r == i++ ) return class'HKMilitary';
    if ( r == i++ ) return class'HKMilitaryCarcass';
    if ( r == i++ ) return class'HKTable';
    if ( r == i++ ) return class'HKTukTuk';
    if ( r == i++ ) return class'Hooker1';
    if ( r == i++ ) return class'Hooker1Carcass';
    if ( r == i++ ) return class'Hooker2';
    if ( r == i++ ) return class'Hooker2Carcass';
    if ( r == i++ ) return class'HowardStrong';
    if ( r == i++ ) return class'HowardStrongCarcass';
    //if ( r == i++ ) return class'Image01_GunFireSensor';
    //if ( r == i++ ) return class'Image01_LibertyIsland';
    //if ( r == i++ ) return class'Image01_TerroristCommander';
    //if ( r == i++ ) return class'Image02_Ambrosia_Flyer';
    //if ( r == i++ ) return class'Image02_BobPage_ManOfYear';
    //if ( r == i++ ) return class'Image02_NYC_Warehouse';
    //if ( r == i++ ) return class'Image03_747Diagram';
    //if ( r == i++ ) return class'Image03_NYC_Airfield';
    //if ( r == i++ ) return class'Image03_WaltonSimons';
    //if ( r == i++ ) return class'Image04_NSFHeadquarters';
    //if ( r == i++ ) return class'Image04_UNATCONotice';
    //if ( r == i++ ) return class'Image05_GreaselDisection';
    //if ( r == i++ ) return class'Image05_NYC_MJ12Lab';
    //if ( r == i++ ) return class'Image06_HK_Market';
    //if ( r == i++ ) return class'Image06_HK_MJ12Helipad';
    //if ( r == i++ ) return class'Image06_HK_MJ12Lab';
    //if ( r == i++ ) return class'Image06_HK_Versalife';
    //if ( r == i++ ) return class'Image06_HK_WanChai';
    //if ( r == i++ ) return class'Image08_JoeGreenMIBMJ12';
    //if ( r == i++ ) return class'Image09_NYC_Ship_Bottom';
    //if ( r == i++ ) return class'Image09_NYC_Ship_Top';
    //if ( r == i++ ) return class'Image10_Paris_Catacombs';
    //if ( r == i++ ) return class'Image10_Paris_CatacombsTunnels';
    //if ( r == i++ ) return class'Image10_Paris_Metro';
    //if ( r == i++ ) return class'Image11_Paris_Cathedral';
    //if ( r == i++ ) return class'Image11_Paris_CathedralEntrance';
    //if ( r == i++ ) return class'Image12_Tiffany_HostagePic';
    //if ( r == i++ ) return class'Image12_Vandenberg_Command';
    //if ( r == i++ ) return class'Image12_Vandenberg_Sub';
    //if ( r == i++ ) return class'Image14_OceanLab';
    //if ( r == i++ ) return class'Image14_Schematic';
    //if ( r == i++ ) return class'Image15_Area51Bunker';
    //if ( r == i++ ) return class'Image15_Area51_Sector3';
    //if ( r == i++ ) return class'Image15_Area51_Sector4';
    //if ( r == i++ ) return class'Image15_BlueFusionDevice';
    //if ( r == i++ ) return class'Image15_GrayDisection';
    if ( r == i++ ) return class'IonStormLogo';
    if ( r == i++ ) return class'JaimeReyes';
    if ( r == i++ ) return class'JaimeReyesCarcass';
    if ( r == i++ ) return class'Janitor';
    if ( r == i++ ) return class'JanitorCarcass';
    if ( r == i++ ) return class'JCDentonMale';
    if ( r == i++ ) return class'JCDentonMaleCarcass';
    if ( r == i++ ) return class'JCDouble';
    if ( r == i++ ) return class'Jock';
    if ( r == i++ ) return class'JockCarcass';
    if ( r == i++ ) return class'JoeGreene';
    if ( r == i++ ) return class'JoeGreeneCarcass';
    if ( r == i++ ) return class'JoJoFine';
    if ( r == i++ ) return class'JoJoFineCarcass';
    if ( r == i++ ) return class'JordanShea';
    if ( r == i++ ) return class'JordanSheaCarcass';
    if ( r == i++ ) return class'JosephManderley';
    if ( r == i++ ) return class'JosephManderleyCarcass';
    if ( r == i++ ) return class'JuanLebedev';
    if ( r == i++ ) return class'JuanLebedevCarcass';
    if ( r == i++ ) return class'JunkieFemale';
    if ( r == i++ ) return class'JunkieFemaleCarcass';
    if ( r == i++ ) return class'JunkieMale';
    if ( r == i++ ) return class'JunkieMaleCarcass';
    if ( r == i++ ) return class'Karkian';
    if ( r == i++ ) return class'KarkianBaby';
    if ( r == i++ ) return class'KarkianBabyCarcass';
    if ( r == i++ ) return class'KarkianCarcass';
    if ( r == i++ ) return class'Keypad1';
    if ( r == i++ ) return class'Keypad2';
    if ( r == i++ ) return class'Keypad3';
    //if ( r == i++ ) return class'LAM';
    if ( r == i++ ) return class'Lamp1';
    if ( r == i++ ) return class'Lamp2';
    if ( r == i++ ) return class'Lamp3';
    if ( r == i++ ) return class'LaserTrigger';
    if ( r == i++ ) return class'LifeSupportBase';
    if ( r == i++ ) return class'Lightbulb';
    if ( r == i++ ) return class'LightSwitch';
    if ( r == i++ ) return class'Liquor40oz';
    if ( r == i++ ) return class'LiquorBottle';
    if ( r == i++ ) return class'Lockpick';
    if ( r == i++ ) return class'LowerClassFemale';
    if ( r == i++ ) return class'LowerClassFemaleCarcass';
    if ( r == i++ ) return class'LowerClassMale';
    if ( r == i++ ) return class'LowerClassMale2';
    if ( r == i++ ) return class'LowerClassMale2Carcass';
    if ( r == i++ ) return class'LowerClassMaleCarcass';
    if ( r == i++ ) return class'LuciusDeBeers';
    if ( r == i++ ) return class'MaggieChow';
    if ( r == i++ ) return class'MaggieChowCarcass';
    if ( r == i++ ) return class'Maid';
    if ( r == i++ ) return class'MaidCarcass';
    if ( r == i++ ) return class'Mailbox';
    if ( r == i++ ) return class'Male1';
    if ( r == i++ ) return class'Male1Carcass';
    if ( r == i++ ) return class'Male2';
    if ( r == i++ ) return class'Male2Carcass';
    if ( r == i++ ) return class'Male3';
    if ( r == i++ ) return class'Male3Carcass';
    if ( r == i++ ) return class'Male4';
    if ( r == i++ ) return class'Male4Carcass';
    if ( r == i++ ) return class'MargaretWilliams';
    if ( r == i++ ) return class'MargaretWilliamsCarcass';
    if ( r == i++ ) return class'MaxChen';
    if ( r == i++ ) return class'MaxChenCarcass';
    if ( r == i++ ) return class'Mechanic';
    if ( r == i++ ) return class'MechanicCarcass';
    if ( r == i++ ) return class'MedicalBot';
    if ( r == i++ ) return class'MedKit';
    //if ( r == i++ ) return class'MetalFragment';
    if ( r == i++ ) return class'MIB';
    if ( r == i++ ) return class'MIBCarcass';
    if ( r == i++ ) return class'MichaelHamner';
    if ( r == i++ ) return class'MichaelHamnerCarcass';
    if ( r == i++ ) return class'Microscope';
    if ( r == i++ ) return class'MilitaryBot';
    if ( r == i++ ) return class'MiniSub';
    if ( r == i++ ) return class'MJ12Commando';
    if ( r == i++ ) return class'MJ12CommandoCarcass';
    if ( r == i++ ) return class'MJ12Troop';
    if ( r == i++ ) return class'MJ12TroopCarcass';
    if ( r == i++ ) return class'Moon';
    if ( r == i++ ) return class'MorganEverett';
    if ( r == i++ ) return class'MorganEverettCarcass';
    //if ( r == i++ ) return class'mpmj12';
    //if ( r == i++ ) return class'mpnsf';
    //if ( r == i++ ) return class'Mpunatco';
    if ( r == i++ ) return class'Multitool';
    if ( r == i++ ) return class'Mutt';
    if ( r == i++ ) return class'MuttCarcass';
    if ( r == i++ ) return class'NanoKey';
    if ( r == i++ ) return class'NanoVirusGrenade';
    if ( r == i++ ) return class'NathanMadison';
    if ( r == i++ ) return class'NathanMadisonCarcass';
    if ( r == i++ ) return class'Newspaper';
    if ( r == i++ ) return class'NewspaperOpen';
    if ( r == i++ ) return class'NicoletteDuClare';
    if ( r == i++ ) return class'NicoletteDuClareCarcass';
    if ( r == i++ ) return class'Nurse';
    if ( r == i++ ) return class'NurseCarcass';
    if ( r == i++ ) return class'NYEagleStatue';
    if ( r == i++ ) return class'NYLiberty';
    if ( r == i++ ) return class'NYLibertyTop';
    if ( r == i++ ) return class'NYLibertyTorch';
    if ( r == i++ ) return class'NYPoliceBoat';
    if ( r == i++ ) return class'OfficeChair';
    if ( r == i++ ) return class'Pan1';
    if ( r == i++ ) return class'Pan2';
    if ( r == i++ ) return class'Pan3';
    if ( r == i++ ) return class'Pan4';
    //if ( r == i++ ) return class'PaperFragment';
    if ( r == i++ ) return class'PaulDenton';
    if ( r == i++ ) return class'PaulDentonCarcass';
    if ( r == i++ ) return class'PhilipMead';
    if ( r == i++ ) return class'PhilipMeadCarcass';
    if ( r == i++ ) return class'Phone';
    if ( r == i++ ) return class'Pigeon';
    if ( r == i++ ) return class'PigeonCarcass';
    if ( r == i++ ) return class'Pillow';
    if ( r == i++ ) return class'Pinball';
    if ( r == i++ ) return class'Plant1';
    if ( r == i++ ) return class'Plant2';
    if ( r == i++ ) return class'Plant3';
    if ( r == i++ ) return class'PlasmaBolt';
    //if ( r == i++ ) return class'PlasticFragment';
    if ( r == i++ ) return class'Poolball';
    if ( r == i++ ) return class'PoolTableLight';
    if ( r == i++ ) return class'Pot1';
    if ( r == i++ ) return class'Pot2';
    //if ( r == i++ ) return class'POVCorpse';
    if ( r == i++ ) return class'RachelMead';
    if ( r == i++ ) return class'RachelMeadCarcass';
    if ( r == i++ ) return class'Rat';
    if ( r == i++ ) return class'RatCarcass';
    if ( r == i++ ) return class'Rebreather';
    if ( r == i++ ) return class'RepairBot';
    if ( r == i++ ) return class'RetinalScanner';
    if ( r == i++ ) return class'RiotCop';
    if ( r == i++ ) return class'RiotCopCarcass';
    if ( r == i++ ) return class'RoadBlock';
    if ( r == i++ ) return class'Rockchip';
    if ( r == i++ ) return class'Rocket';
    if ( r == i++ ) return class'RocketLAW';
    if ( r == i++ ) return class'RocketMini';
    if ( r == i++ ) return class'RocketRobot';
    if ( r == i++ ) return class'RocketWP';
    if ( r == i++ ) return class'Sailor';
    if ( r == i++ ) return class'SailorCarcass';
    if ( r == i++ ) return class'SamCarter';
    if ( r == i++ ) return class'SamCarterCarcass';
    if ( r == i++ ) return class'SandraRenton';
    if ( r == i++ ) return class'SandraRentonCarcass';
    if ( r == i++ ) return class'SarahMead';
    if ( r == i++ ) return class'SarahMeadCarcass';
    if ( r == i++ ) return class'SatelliteDish';
    if ( r == i++ ) return class'ScientistFemale';
    if ( r == i++ ) return class'ScientistFemaleCarcass';
    if ( r == i++ ) return class'ScientistMale';
    if ( r == i++ ) return class'ScientistMaleCarcass';
    if ( r == i++ ) return class'ScubaDiver';
    if ( r == i++ ) return class'ScubaDiverCarcass';
    if ( r == i++ ) return class'Seagull';
    if ( r == i++ ) return class'SeagullCarcass';
    if ( r == i++ ) return class'Secretary';
    if ( r == i++ ) return class'SecretaryCarcass';
    if ( r == i++ ) return class'SecretService';
    if ( r == i++ ) return class'SecretServiceCarcass';
    if ( r == i++ ) return class'SecurityBot2';
    if ( r == i++ ) return class'SecurityBot3';
    if ( r == i++ ) return class'SecurityBot4';
    if ( r == i++ ) return class'SecurityCamera';
    if ( r == i++ ) return class'ShellCasing';
    if ( r == i++ ) return class'ShellCasing2';
    if ( r == i++ ) return class'ShellCasingSilent';
    if ( r == i++ ) return class'ShipsWheel';
    if ( r == i++ ) return class'ShopLight';
    if ( r == i++ ) return class'ShowerFaucet';
    if ( r == i++ ) return class'ShowerHead';
    if ( r == i++ ) return class'Shuriken';
    if ( r == i++ ) return class'SignFloor';
    if ( r == i++ ) return class'Smuggler';
    if ( r == i++ ) return class'SmugglerCarcass';
    //if ( r == i++ ) return class'snipertracer';
    if ( r == i++ ) return class'Sodacan';
    if ( r == i++ ) return class'Soldier';
    if ( r == i++ ) return class'SoldierCarcass';
    if ( r == i++ ) return class'SoyFood';
    if ( r == i++ ) return class'SpiderBot';
    if ( r == i++ ) return class'SpiderBot2';
    if ( r == i++ ) return class'SpyDrone';
    if ( r == i++ ) return class'StantonDowd';
    if ( r == i++ ) return class'StantonDowdCarcass';
    if ( r == i++ ) return class'StatueLion';
    if ( r == i++ ) return class'SubwayControlPanel';
    if ( r == i++ ) return class'Switch1';
    if ( r == i++ ) return class'Switch2';
    if ( r == i++ ) return class'TAD';
    if ( r == i++ ) return class'TechGoggles';
    if ( r == i++ ) return class'Terrorist';
    if ( r == i++ ) return class'TerroristCarcass';
    if ( r == i++ ) return class'TerroristCommander';
    if ( r == i++ ) return class'TerroristCommanderCarcass';
    if ( r == i++ ) return class'ThugMale';
    if ( r == i++ ) return class'ThugMale2';
    if ( r == i++ ) return class'ThugMale2Carcass';
    if ( r == i++ ) return class'ThugMale3';
    if ( r == i++ ) return class'ThugMale3Carcass';
    if ( r == i++ ) return class'ThugMaleCarcass';
    if ( r == i++ ) return class'TiffanySavage';
    if ( r == i++ ) return class'TiffanySavageCarcass';
    if ( r == i++ ) return class'TobyAtanwe';
    if ( r == i++ ) return class'TobyAtanweCarcass';
    if ( r == i++ ) return class'Toilet';
    if ( r == i++ ) return class'Toilet2';
    //if ( r == i++ ) return class'Tracer';
    if ( r == i++ ) return class'TracerTong';
    if ( r == i++ ) return class'TracerTongCarcass';
    if ( r == i++ ) return class'TrafficLight';
    if ( r == i++ ) return class'Trashbag';
    if ( r == i++ ) return class'Trashbag2';
    if ( r == i++ ) return class'TrashCan1';
    if ( r == i++ ) return class'Trashcan2';
    if ( r == i++ ) return class'TrashCan3';
    if ( r == i++ ) return class'TrashCan4';
    if ( r == i++ ) return class'TrashPaper';
    if ( r == i++ ) return class'Tree1';
    if ( r == i++ ) return class'Tree2';
    if ( r == i++ ) return class'Tree3';
    if ( r == i++ ) return class'Tree4';
    if ( r == i++ ) return class'TriadLumPath';
    if ( r == i++ ) return class'TriadLumPath2';
    if ( r == i++ ) return class'TriadLumPath2Carcass';
    if ( r == i++ ) return class'TriadLumPathCarcass';
    if ( r == i++ ) return class'TriadRedArrow';
    if ( r == i++ ) return class'TriadRedArrowCarcass';
    if ( r == i++ ) return class'Trophy';
    if ( r == i++ ) return class'Tumbleweed';
    if ( r == i++ ) return class'UNATCOTroop';
    if ( r == i++ ) return class'UNATCOTroopCarcass';
    if ( r == i++ ) return class'Valve';
    if ( r == i++ ) return class'Van';
    if ( r == i++ ) return class'Vase1';
    if ( r == i++ ) return class'Vase2';
    if ( r == i++ ) return class'VendingMachine';
    if ( r == i++ ) return class'VialAmbrosia';
    if ( r == i++ ) return class'VialCrack';
    if ( r == i++ ) return class'WaltonSimons';
    if ( r == i++ ) return class'WaltonSimonsCarcass';
    if ( r == i++ ) return class'WaterCooler';
    if ( r == i++ ) return class'WaterFountain';
    if ( r == i++ ) return class'WeaponAssaultGun';
    if ( r == i++ ) return class'WeaponAssaultShotgun';
    if ( r == i++ ) return class'WeaponBaton';
    if ( r == i++ ) return class'WeaponCatScratch';
    if ( r == i++ ) return class'WeaponCombatKnife';
    if ( r == i++ ) return class'WeaponCrowbar';
    if ( r == i++ ) return class'WeaponDogBite';
    if ( r == i++ ) return class'WeaponEMPGrenade';
    if ( r == i++ ) return class'WeaponFlamethrower';
    if ( r == i++ ) return class'WeaponGasGrenade';
    if ( r == i++ ) return class'WeaponGEPGun';
    if ( r == i++ ) return class'WeaponGraySpit';
    if ( r == i++ ) return class'WeaponGraySwipe';
    if ( r == i++ ) return class'WeaponGreaselSpit';
    if ( r == i++ ) return class'WeaponHideAGun';
    if ( r == i++ ) return class'WeaponKarkianBite';
    if ( r == i++ ) return class'WeaponKarkianBump';
    if ( r == i++ ) return class'WeaponLAM';
    if ( r == i++ ) return class'WeaponLAW';
    if ( r == i++ ) return class'WeaponMiniCrossbow';
    if ( r == i++ ) return class'WeaponMJ12Commando';
    if ( r == i++ ) return class'WeaponMJ12Rocket';
    if ( r == i++ ) return class'WeaponMod';
    if ( r == i++ ) return class'WeaponModAccuracy';
    if ( r == i++ ) return class'WeaponModClip';
    if ( r == i++ ) return class'WeaponModLaser';
    if ( r == i++ ) return class'WeaponModRange';
    if ( r == i++ ) return class'WeaponModRecoil';
    if ( r == i++ ) return class'WeaponModReload';
    if ( r == i++ ) return class'WeaponModScope';
    if ( r == i++ ) return class'WeaponModSilencer';
    if ( r == i++ ) return class'WeaponNanoSword';
    if ( r == i++ ) return class'WeaponNanoVirusGrenade';
    if ( r == i++ ) return class'WeaponNPCMelee';
    if ( r == i++ ) return class'WeaponNPCRanged';
    if ( r == i++ ) return class'WeaponPepperGun';
    if ( r == i++ ) return class'WeaponPistol';
    if ( r == i++ ) return class'WeaponPlasmaRifle';
    if ( r == i++ ) return class'WeaponProd';
    if ( r == i++ ) return class'WeaponRatBite';
    if ( r == i++ ) return class'WeaponRifle';
    if ( r == i++ ) return class'WeaponRobotMachinegun';
    if ( r == i++ ) return class'WeaponRobotRocket';
    if ( r == i++ ) return class'WeaponSawedOffShotgun';
    if ( r == i++ ) return class'WeaponShuriken';
    if ( r == i++ ) return class'WeaponSpiderBot';
    if ( r == i++ ) return class'WeaponSpiderBot2';
    if ( r == i++ ) return class'WeaponStealthPistol';
    if ( r == i++ ) return class'WeaponSword';
    if ( r == i++ ) return class'WHBenchEast';
    if ( r == i++ ) return class'WHBenchLibrary';
    if ( r == i++ ) return class'WHBookstandLibrary';
    if ( r == i++ ) return class'WHCabinet';
    if ( r == i++ ) return class'WHChairDining';
    if ( r == i++ ) return class'WHChairOvalOffice';
    if ( r == i++ ) return class'WHChairPink';
    if ( r == i++ ) return class'WHDeskLibrarySmall';
    if ( r == i++ ) return class'WHDeskOvalOffice';
    if ( r == i++ ) return class'WHEndtableLibrary';
    if ( r == i++ ) return class'WHFireplaceGrill';
    if ( r == i++ ) return class'WHFireplaceLog';
    if ( r == i++ ) return class'WHPhone';
    if ( r == i++ ) return class'WHPiano';
    if ( r == i++ ) return class'WHRedCandleabra';
    if ( r == i++ ) return class'WHRedCouch';
    if ( r == i++ ) return class'WHRedEagleTable';
    if ( r == i++ ) return class'WHRedLampTable';
    if ( r == i++ ) return class'WHRedOvalTable';
    if ( r == i++ ) return class'WHRedVase';
    if ( r == i++ ) return class'WHTableBlue';
    if ( r == i++ ) return class'WIB';
    if ( r == i++ ) return class'WIBCarcass';
    if ( r == i++ ) return class'WineBottle';
    //if ( r == i++ ) return class'WoodFragment';
}

defaultproperties
{
}
