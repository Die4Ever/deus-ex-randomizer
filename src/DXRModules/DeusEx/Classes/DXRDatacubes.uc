class DXRDatacubes extends DXRPasswordsBase abstract;

var safe_rule datacubes_rules[16];
var float min_hack_adjust, max_hack_adjust;

function CheckConfig()
{
    local int i;
    min_hack_adjust = 0.4;
    max_hack_adjust = 1.5;

    if(class'DXRMapVariants'.static.IsRevisionMaps(player()))
        revision_datacubes_rules();
    else
        vanilla_datacubes_rules();

    for(i=0;i<ArrayCount(datacubes_rules);i++) {
        datacubes_rules[i] = FixSafeRule(datacubes_rules[i]);
        datacubes_rules[i] = ApplyDefaultTextPackage(datacubes_rules[i]);
    }

    Super.CheckConfig();
}

function vanilla_datacubes_rules()
{
    local int i;

    switch(dxr.localURL) {
    case "01_NYC_UNATCOISLAND":
        // satcom password
        datacubes_rules[i].item_name = '01_Datacube06';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // armory 0451 code
        datacubes_rules[i].item_name = '01_Datacube03';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // nsf001 smashthestate
        datacubes_rules[i].item_name = '01_Datacube04';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "01_NYC_UNATCOHQ":
        // Manderley's password
        datacubes_rules[i].item_name = '01_Datacube01';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "02_NYC_BATTERYPARK":
        // Castle Clinton underground access code - needs to be above ground
        datacubes_rules[i].item_name = '02_Datacube15';
        datacubes_rules[i].min_pos = vect(-99999, -99999, 320);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "02_NYC_UNDERGROUND":
        // East Hatch Code
        datacubes_rules[i].item_name = '02_Datacube03';
        datacubes_rules[i].min_pos = vect(1960, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //Other door code
        datacubes_rules[i].item_name = '02_Datacube06';
        datacubes_rules[i].min_pos = vect(1960, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //Security Code that lets you rotate the bridge
        datacubes_rules[i].item_name = '02_Datacube11';
        datacubes_rules[i].min_pos = vect(-1350, -99999, -670);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //Computer login
        datacubes_rules[i].item_name = '02_Datacube02';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(-1350, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "02_NYC_HOTEL":
        // The code to Paul's bookshelf stash
        datacubes_rules[i].item_name = '02_Datacube07';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, -2540, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //Paul's computer password
        datacubes_rules[i].item_name = '02_Datacube05';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, -2300, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "02_NYC_WAREHOUSE":
        // ramp code
        datacubes_rules[i].item_name = '02_Datacube09';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // NSF righteous
        datacubes_rules[i].item_name = '02_Datacube14';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // TFRASE ValleyForge
        datacubes_rules[i].item_name = '02_Datacube18';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "03_NYC_UNATCOHQ":
        datacubes_rules[i].item_name = 'JCCompPassword';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "03_NYC_BatteryPark":
        // Curly's Journal
        datacubes_rules[i].item_name = '03_Book06';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "03_NYC_BrooklynBridgeStation":
        datacubes_rules[i].item_name = '03_Datacube14';
        datacubes_rules[i].min_pos = vect(-999999, -999999, -999999);
        datacubes_rules[i].max_pos = vect(999999, 999999, 999999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "03_NYC_Airfield":
        // datacube for hanger keypad
        // disallow in security tower
        datacubes_rules[i].item_name = '03_Datacube10';
        datacubes_rules[i].min_pos = vect(5100, 3600, -999999);
        datacubes_rules[i].max_pos = vect(999999, 999999, 999999);
        datacubes_rules[i].allow = false;
        i++;

        // disallow below ground level, like the sewers or water area
        datacubes_rules[i].item_name = '03_Datacube10';
        datacubes_rules[i].min_pos = vect(-999999, -999999, -999999);
        datacubes_rules[i].max_pos = vect(999999, 999999, -55);
        datacubes_rules[i].allow = false;
        i++;

        // allow anywhere else past the gate
        datacubes_rules[i].item_name = '03_Datacube10';
        datacubes_rules[i].min_pos = vect(1700, 2400, -999999);
        datacubes_rules[i].max_pos = vect(5000, 3600, 999999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "03_NYC_AIRFIELDHELIBASE":
        //etodd computer password
        datacubes_rules[i].item_name = '03_Datacube12';
        datacubes_rules[i].min_pos = vect(-999999, -999999, -999999);
        datacubes_rules[i].max_pos = vect(999999, 999999, 999999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "03_NYC_747":
        //Suspension crate code

        //Don't allow in the suspension crate itself
        datacubes_rules[i].item_name = '03_Datacube13';
        datacubes_rules[i].min_pos = vect(-410,-700,130);
        datacubes_rules[i].max_pos = vect(-395,-680,150);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = '03_Datacube13';
        datacubes_rules[i].min_pos = vect(-999999, -999999, -999999);
        datacubes_rules[i].max_pos = vect(999999, 999999, 999999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "04_NYC_UNATCOHQ":
        datacubes_rules[i].item_name = 'JCCompPassword';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "04_NYC_HOTEL":
        //Paul's computer password
        datacubes_rules[i].item_name = '02_Datacube05';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, -2300, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // The code to Paul's bookshelf stash
        datacubes_rules[i].item_name = '02_Datacube07';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, -2540, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "04_NYC_NSFHQ":
        // don't allow either datacube in the room with the vanilla transmitter computer
        // datacube with the password for sending the signal, allowed almost anywhere
        datacubes_rules[i].item_name = '04_Datacube01';
        datacubes_rules[i].min_pos = vect(100, 329, 1010);
        datacubes_rules[i].max_pos = vect(116, 345, 1050);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = '04_Datacube01';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // datacube with the security password, don't allow it to go in the basement, you might need it to open the weird door things
        datacubes_rules[i].item_name = '04_Datacube02';
        datacubes_rules[i].min_pos = vect(100, 329, 1010);
        datacubes_rules[i].max_pos = vect(116, 345, 1050);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = '04_Datacube02';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 0);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = '04_Datacube02';
        datacubes_rules[i].min_pos = vect(-99999, -99999, 0);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "05_NYC_UNATCOMJ12LAB":
        // jail cell codes
        datacubes_rules[i].item_name = '05_Datacube01';// don't allow this in the locked cabinet
        datacubes_rules[i].min_pos = vect(-2235.248291, 1414.674072, -159.039658)-vect(8,8,8);
        datacubes_rules[i].max_pos = vect(-2235.248291, 1414.674072, -159.039658)+vect(8,8,8);
        datacubes_rules[i].allow = false;
        i++;

        // As requested, the patient has been moved to the Surgery Ward for immediate salvage of his datavault.  If you wish to observe the progress of the operation in person, the door code for surgery is 0199; or, if you wish to view the operation remotely, you may use the temporary account we've created for you: login "psherman" and password "Raven".  Please let me know if myself or my staff can provide you with any further assistance.
        /*datacubes_rules[i].map = "05_NYC_UNATCOMJ12LAB";
        datacubes_rules[i].item_name = '05_Datacube03';
        datacubes_rules[i].min_pos = vect(1214.396851, -1006.870361, -99999);
        datacubes_rules[i].max_pos = vect(2404.169922, -254.634888, 99999);
        datacubes_rules[i].allow = false;
        i++;*/

        datacubes_rules[i].item_name = '05_Datacube03';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;// actually just don't randomize this one since we mention it in the wiki
        i++;

        // Wednesday, 4/15: IS promises that LabNet accounts will be restored by Friday; new login is "dmoreau" with password "raptor".
        datacubes_rules[i].item_name = '05_Book01';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // We are in the process of ghosting all network security resources to provide additional protection against possible intrusion or denial of service attacks.  Until this process is complete, all security computers will be utilizing a temporary system.
        // Login: MJ12  Password: INVADER
        datacubes_rules[i].item_name = '05_Datacube02';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "05_NYC_UNATCOHQ":
        datacubes_rules[i].item_name = 'JCCompPassword';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "06_HONGKONG_HELIBASE":
        //Security login
        datacubes_rules[i].item_name = '06_Datacube18';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "06_HONGKONG_WANCHAI_MARKET":
        datacubes_rules[i].item_name = '06_Datacube22';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = 'MarketATMPassword';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "06_HONGKONG_WANCHAI_STREET":
        //"Insurgent"
        datacubes_rules[i].item_name = '06_Book16';
        datacubes_rules[i].min_pos = vect(-1336,-1910,1950);
        datacubes_rules[i].max_pos = vect(-116,-447,2311);
        datacubes_rules[i].allow = true;
        i++;

        //Tai-Fun and Insurgent
        datacubes_rules[i].item_name = '06_Datacube21';
        datacubes_rules[i].min_pos = vect(-1336,-1910,1950);
        datacubes_rules[i].max_pos = vect(-116,-447,2311);
        datacubes_rules[i].allow = true;
        i++;

        //Police Vault entry code (in apartment, nowhere else)
        datacubes_rules[i].item_name = 'PoliceVaultPassword';
        datacubes_rules[i].min_pos = vect(-1336,-1910,1950);
        datacubes_rules[i].max_pos = vect(-116,-447,2311);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = 'PoliceVaultPassword';
        datacubes_rules[i].min_pos = vect(-99999,-99999,-99999);
        datacubes_rules[i].max_pos = vect(99999,99999,99999);
        datacubes_rules[i].allow = false;
        i++;


        datacubes_rules[i].item_name = 'QuickStopATMPassword';
        datacubes_rules[i].min_pos = vect(-99999,-99999,-99999);
        datacubes_rules[i].max_pos = vect(99999,99999,99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "06_HONGKONG_WANCHAI_UNDERWORLD":
        //Added datacube with security computer login/password (LUCKYMONEY/REDARROW)

        //Don't allow in the Quickstop
        datacubes_rules[i].item_name = 'LuckyMoneyPassword';
        datacubes_rules[i].min_pos = vect(-169,254,-305);
        datacubes_rules[i].max_pos = vect(443,650,-170);
        datacubes_rules[i].allow = false;
        i++;

        //Don't allow in the Freezer
        datacubes_rules[i].item_name = 'LuckyMoneyPassword';
        datacubes_rules[i].min_pos = vect(-1841,-3203,-360);
        datacubes_rules[i].max_pos = vect(-1393,-2420,-163);
        datacubes_rules[i].allow = false;
        i++;

        //Don't allow in the safe
        datacubes_rules[i].item_name = 'LuckyMoneyPassword';
        datacubes_rules[i].min_pos = vect(-1235, 125, -325);
        datacubes_rules[i].max_pos = vect(-1200, 155, -290);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = 'LuckyMoneyPassword';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "06_HONGKONG_VERSALIFE":
        datacubes_rules[i].item_name = 'VersalifeMainElevatorCode';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "06_HONGKONG_STORAGE":
        //Anywhere below the exit pipe
        datacubes_rules[i].item_name = 'VersalifeNanotechCode';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 1345); //1345 is the top of the pipe
        datacubes_rules[i].allow = true;
        i++;

        //The datacube with the code for the door lock
        //Don't allow in that alcove between the doors
        datacubes_rules[i].item_name = '06_Datacube30';
        datacubes_rules[i].min_pos = vect(50, -1700, 875);
        datacubes_rules[i].max_pos = vect(100, -1800, 925);
        datacubes_rules[i].allow = false;
        i++;

        //Don't allow at the bottom of the stairs
        datacubes_rules[i].item_name = '06_Datacube30';
        datacubes_rules[i].min_pos = vect(300, -2050, 450);
        datacubes_rules[i].max_pos = vect(400, -2150, 550);
        datacubes_rules[i].allow = false;
        i++;

        //Before the doors!
        datacubes_rules[i].item_name = '06_Datacube30';
        datacubes_rules[i].min_pos = vect(-99999, -900, 800); //The items in the alcove in the lower hallway
        datacubes_rules[i].max_pos = vect(99999, 99999, 1345); //1345 is the top of the pipe
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "08_NYC_HOTEL":
        // The code to Paul's bookshelf stash
        datacubes_rules[i].item_name = '02_Datacube07';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, -2540, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "09_NYC_DOCKYARD":
        //Walton Simons login
        datacubes_rules[i].item_name = '09_Datacube11';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //USFEMA login
        datacubes_rules[i].item_name = '09_Datacube12';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //Jenny's Number can be anywhere
        datacubes_rules[i].item_name = 'JennysNumber';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "09_NYC_SHIP":
        //Ramp Code
        datacubes_rules[i].item_name = '09_Datacube14';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "09_NYC_GRAVEYARD":
        //Generator code datacube

        //Behind bookshelf
        datacubes_rules[i].item_name = 'EMGeneratorHintCube';
        datacubes_rules[i].min_pos = vect(990, 700, 0);
        datacubes_rules[i].max_pos = vect(1130, 850, 200);
        datacubes_rules[i].allow = false;
        i++;

        //Dowd's Safe
        datacubes_rules[i].item_name = 'EMGeneratorHintCube';
        datacubes_rules[i].min_pos = vect(-1400,70,-300);
        datacubes_rules[i].max_pos = vect(-1375,90,-250);
        datacubes_rules[i].allow = false;
        i++;

        //Allowed everywhere else
        datacubes_rules[i].item_name = 'EMGeneratorHintCube';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "10_PARIS_CATACOMBS":
        // make sure you can get to the book without needing to jump down
        datacubes_rules[i].item_name = '10_Book09';
        datacubes_rules[i].min_pos = vect(-99999, -99999, 1956.809082); //top floor
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '10_Book09';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999); //top floor
        datacubes_rules[i].max_pos = vect(99999, 99999, 1956.809082);
        datacubes_rules[i].allow = false;
        i++;

        //Login for the security system in the bunker warehouse
        datacubes_rules[i].item_name = '10_Datacube12';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "10_PARIS_CLUB":
        // Storage room code - main area of the club
        datacubes_rules[i].item_name = '10_Datacube07';
        datacubes_rules[i].min_pos = vect(-1350, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //back office
        datacubes_rules[i].item_name = '10_Datacube07';
        datacubes_rules[i].min_pos = vect(-2100,-1290,-99999);
        datacubes_rules[i].max_pos = vect(-1652,-820,99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "11_PARIS_EVERETT":
        // Lucius DeBeers login
        datacubes_rules[i].item_name = '11_Datacube01';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "11_PARIS_CATHEDRAL":
        // DataCube0 and 2
        datacubes_rules[i].item_name = '11_Datacube03';
        datacubes_rules[i].min_pos = vect(-99999, -99999, 1956.809082); //top floor
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '11_Datacube03';// DataCube0 and 2 have the same textTag
        datacubes_rules[i].min_pos = vect(3587, -812, -487); //before gunther room
        datacubes_rules[i].max_pos = vect(4322, -124, 74);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = '11_Datacube03';// 0 and 2
        datacubes_rules[i].min_pos = vect(3146, -1715, -85); //above before gunther room
        datacubes_rules[i].max_pos = vect(3907, -1224, 434);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = '11_Datacube03';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "14_VANDENBERG_SUB":
        //Code for URV Bay doors - anywhere offshore
        datacubes_rules[i].item_name = '14_Datacube01';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 2000, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //Upper area onshore
        datacubes_rules[i].item_name = '14_Datacube01';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -150);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "14_OCEANLAB_SILO":
        //Code for missile launch controls - anywhere above ground
        datacubes_rules[i].item_name = '14_Datacube05';
        datacubes_rules[i].min_pos = vect(-99999, -99999, 1415);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //underground, outside of the actual silo
        datacubes_rules[i].item_name = '14_Datacube05';
        datacubes_rules[i].min_pos = vect(-99999, -3610, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 1415);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "14_OCEANLAB_LAB":
        //OCEANGUARD code to open sub bay doors.  This is SUPER IMPORTANT.  This needs to not fuck up.
        //Intent is for it to be able to spawn anywhere from the sub bay up to and including the storage room, but not the locked one

        //Exclude Locked storage room
        datacubes_rules[i].item_name = '14_Datacube06';
        datacubes_rules[i].min_pos = vect(598,-178,-1635);
        datacubes_rules[i].max_pos = vect(976,322,-1457);
        datacubes_rules[i].allow = false;
        i++;

        //Between Sub Bay and door to Greasel Lab, top floor
        datacubes_rules[i].item_name = '14_Datacube06';
        datacubes_rules[i].min_pos = vect(-260, -240, -1637);
        datacubes_rules[i].max_pos = vect(1879, 960, -1457);
        datacubes_rules[i].allow = true;
        i++;

        //All floors of that main central building with the sub bay
        datacubes_rules[i].item_name = '14_Datacube06';
        datacubes_rules[i].min_pos = vect(-230,-221,-2535);
        datacubes_rules[i].max_pos = vect(464,1431,-1448);
        datacubes_rules[i].allow = true;
        i++;

        //Explicitly exclude EVERYTHING else for safety
        datacubes_rules[i].item_name = '14_Datacube06';
        datacubes_rules[i].min_pos = vect(-99999,-99999,-99999);
        datacubes_rules[i].max_pos = vect(99999,99999,99999);
        datacubes_rules[i].allow = false;
        i++;
        break;

    case "14_OCEANLAB_UC":
        //Code for walkway security computer - could go anywhere except for across the bridge (which has no loose items)
        datacubes_rules[i].item_name = '14_Datacube03';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "15_AREA51_BUNKER":
        //Both of these have to be above ground
        datacubes_rules[i].item_name = 'A51VentComputerCode';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -645);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = 'A51VentElevatorCode';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -645);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "15_AREA51_ENTRANCE":
        // allow between barracks and sector 3 access door
        datacubes_rules[i].item_name = 'SleepPodCode1';
        datacubes_rules[i].min_pos = vect(-580, -99999, -99999);
        datacubes_rules[i].max_pos = vect(4280, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        datacubes_rules[i].item_name = 'SleepPodCode1';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = 'SleepPodCode2';
        datacubes_rules[i].min_pos = vect(-580, -99999, -99999);
        datacubes_rules[i].max_pos = vect(4280, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        datacubes_rules[i].item_name = 'SleepPodCode2';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = 'SleepPodCode3';
        datacubes_rules[i].min_pos = vect(-580, -99999, -99999);
        datacubes_rules[i].max_pos = vect(4280, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        datacubes_rules[i].item_name = 'SleepPodCode3';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;
        break;

    case "15_AREA51_PAGE":
        datacubes_rules[i].item_name = '15_Datacube18';// LAB 12 / graytest
        datacubes_rules[i].min_pos = vect(4774.132813, -10507.679688, -5294.627441);
        datacubes_rules[i].max_pos = vect(6394.192383, -9250.182617, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '15_Datacube18';// LAB 12 / graytest
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        //Aquinas Substation and Router Control Room code
        datacubes_rules[i].item_name = '15_Datacube11';
        datacubes_rules[i].min_pos = vect(7158, -6119, -6115);
        datacubes_rules[i].max_pos = vect(4620, -8039, -5371);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '15_Datacube11';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        //UC Control Room password can be anywhere
        datacubes_rules[i].item_name = 'UCControlRoomPassword';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "15_AREA51_FINAL":
        //Code for stairwell blastdoor
        //Not in the reactor lab
        datacubes_rules[i].item_name = '15_Datacube08';
        datacubes_rules[i].min_pos = vect(-3868,-5302,-2096);
        datacubes_rules[i].max_pos = vect(-2435,-3906,-1442);
        datacubes_rules[i].allow = false;
        i++;

        //Not in the aug upgrade can container
        datacubes_rules[i].item_name = '15_Datacube08';
        datacubes_rules[i].min_pos = vect(-5035, -3065, -700);
        datacubes_rules[i].max_pos = vect(-4985, -3145, -650);
        datacubes_rules[i].allow = false;
        i++;

        //anywhere before the stairwell blastdoor
        datacubes_rules[i].item_name = '15_Datacube08';
        datacubes_rules[i].min_pos = vect(-5655, -5190, -1700);
        datacubes_rules[i].max_pos = vect(-2376, -2527, -534);
        datacubes_rules[i].allow = true;
        i++;

        //Code for Reactor lab
        //Not in the reactor lab
        datacubes_rules[i].item_name = '15_Datacube19';
        datacubes_rules[i].min_pos = vect(-3868,-5302,-2096);
        datacubes_rules[i].max_pos = vect(-2435,-3906,-1442);
        datacubes_rules[i].allow = false;
        i++;

        //Not in the aug upgrade can container
        datacubes_rules[i].item_name = '15_Datacube19';
        datacubes_rules[i].min_pos = vect(-5035, -3065, -700);
        datacubes_rules[i].max_pos = vect(-4985, -3145, -650);
        datacubes_rules[i].allow = false;
        i++;

        //anywhere before the stairwell blastdoor
        datacubes_rules[i].item_name = '15_Datacube19';
        datacubes_rules[i].min_pos = vect(-5655, -5190, -1700);
        datacubes_rules[i].max_pos = vect(-2376, -2527, -534);
        datacubes_rules[i].allow = true;
        i++;
        break;
    }
}

function revision_datacubes_rules()
{
    local int i;

    switch(dxr.localURL) {
    case "01_NYC_UNATCOISLAND":
        // satcom password
        datacubes_rules[i].item_name = '01_Datacube06';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // armory 0451 code
        datacubes_rules[i].item_name = '01_Datacube03';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // nsf001 smashthestate
        datacubes_rules[i].item_name = '01_Datacube04';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "01_NYC_UNATCOHQ":
        // Manderley's password
        datacubes_rules[i].item_name = '01_Datacube01';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "02_NYC_BATTERYPARK":
        // Castle Clinton underground access code - needs to be above ground
        datacubes_rules[i].item_name = '02_Datacube15';
        datacubes_rules[i].min_pos = vect(-99999, -99999, 320);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "02_NYC_UNDERGROUND":

        // East Hatch Code - This actually doesn't exist in Revision, but we'll leave it here too
        datacubes_rules[i].item_name = '02_Datacube03';
        datacubes_rules[i].min_pos = vect(1960, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //Other door code (Both the east hatch and the door inside it)
        datacubes_rules[i].item_name = '02_Datacube06';
        datacubes_rules[i].min_pos = vect(1960, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //Security Code that lets you rotate the bridge
        datacubes_rules[i].item_name = '02_Datacube11';
        datacubes_rules[i].min_pos = vect(-1350, -99999, -670);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //Computer login
        datacubes_rules[i].item_name = '02_Datacube02';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(-1350, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "02_NYC_HOTEL":

        // The code to Paul's bookshelf stash (Anywhere in Paul's Apartment except the stash)
        datacubes_rules[i].item_name = '02_Datacube07';
        datacubes_rules[i].min_pos = vect(-310, -4000, -99999);
        datacubes_rules[i].max_pos = vect(580, -3284, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '02_Datacube07';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        //Paul's computer password (Anywhere in Paul's Apartment)
        datacubes_rules[i].item_name = '02_Datacube05';
        datacubes_rules[i].min_pos = vect(-310, -4000, -99999);
        datacubes_rules[i].max_pos = vect(580, -2870, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '02_Datacube05';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        break;

    case "02_NYC_WAREHOUSE":
        // ramp code
        datacubes_rules[i].item_name = '02_Datacube09';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // NSF righteous
        datacubes_rules[i].item_name = '02_Datacube14';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // TFRASE ValleyForge
        datacubes_rules[i].item_name = '02_Datacube18';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "03_NYC_UNATCOHQ":
        datacubes_rules[i].item_name = 'JCCompPassword';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "03_NYC_BatteryPark":
        // Curly's Journal
        datacubes_rules[i].item_name = '03_Book06';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "03_NYC_BrooklynBridgeStation":
        datacubes_rules[i].item_name = '03_Datacube14';
        datacubes_rules[i].min_pos = vect(-999999, -999999, -999999);
        datacubes_rules[i].max_pos = vect(999999, 999999, 999999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "03_NYC_Airfield":
        // datacube for hanger keypad
        // disallow in security tower
        datacubes_rules[i].item_name = '03_Datacube10';
        datacubes_rules[i].min_pos = vect(5100, 3600, -999999);
        datacubes_rules[i].max_pos = vect(999999, 999999, 999999);
        datacubes_rules[i].allow = false;
        i++;

        // disallow below ground level, like the sewers or water area
        datacubes_rules[i].item_name = '03_Datacube10';
        datacubes_rules[i].min_pos = vect(-999999, -999999, -999999);
        datacubes_rules[i].max_pos = vect(999999, 999999, -55);
        datacubes_rules[i].allow = false;
        i++;

        // allow anywhere else past the gate
        datacubes_rules[i].item_name = '03_Datacube10';
        datacubes_rules[i].min_pos = vect(1700, 2400, -999999);
        datacubes_rules[i].max_pos = vect(5000, 3600, 999999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "03_NYC_AIRFIELDHELIBASE":
        //etodd computer password
        datacubes_rules[i].item_name = '03_Datacube12';
        datacubes_rules[i].min_pos = vect(-999999, -999999, -999999);
        datacubes_rules[i].max_pos = vect(999999, 999999, 999999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "03_NYC_747":
        //Suspension crate code

        //Don't allow in the suspension crate itself
        datacubes_rules[i].item_name = '03_Datacube13';
        datacubes_rules[i].min_pos = vect(-410,-700,130);
        datacubes_rules[i].max_pos = vect(-395,-680,150);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = '03_Datacube13';
        datacubes_rules[i].min_pos = vect(-999999, -999999, -999999);
        datacubes_rules[i].max_pos = vect(999999, 999999, 999999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "04_NYC_UNATCOHQ":
        datacubes_rules[i].item_name = 'JCCompPassword';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "04_NYC_HOTEL":
        // The code to Paul's bookshelf stash (Anywhere in Paul's Apartment except the stash)
        datacubes_rules[i].item_name = '02_Datacube07';
        datacubes_rules[i].min_pos = vect(-310, -4000, -99999);
        datacubes_rules[i].max_pos = vect(580, -3284, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '02_Datacube07';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        //Paul's computer password (Anywhere in Paul's Apartment)
        datacubes_rules[i].item_name = '02_Datacube05';
        datacubes_rules[i].min_pos = vect(-310, -4000, -99999);
        datacubes_rules[i].max_pos = vect(580, -2870, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '02_Datacube05';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        break;

    case "04_NYC_NSFHQ":
        // don't allow either datacube in the room with the vanilla transmitter computer
        // datacube with the password for sending the signal, allowed almost anywhere (in the HQ)
        datacubes_rules[i].item_name = '04_Datacube01';
        datacubes_rules[i].min_pos = vect(100, 329, 1010);
        datacubes_rules[i].max_pos = vect(116, 345, 1050);
        datacubes_rules[i].allow = false;
        i++;

        //Exclude the small apartment near the HQ
        datacubes_rules[i].item_name = '04_Datacube01';
        datacubes_rules[i].min_pos = vect(-632,1406,216);
        datacubes_rules[i].max_pos = vect(-264,1709,394);
        datacubes_rules[i].allow = false;
        i++;

        //Just the NSF HQ area itself
        datacubes_rules[i].item_name = '04_Datacube01';
        datacubes_rules[i].min_pos = vect(-515, -2600, -99999);
        datacubes_rules[i].max_pos = vect(1451, 1722, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //exclude the rest of the map
        datacubes_rules[i].item_name = '04_Datacube01';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        // datacube with the security password, don't allow it to go in the basement, you might need it to open the weird door things
        // Otherwise, anywhere in the HQ region
        datacubes_rules[i].item_name = '04_Datacube02';
        datacubes_rules[i].min_pos = vect(100, 329, 1010);
        datacubes_rules[i].max_pos = vect(116, 345, 1050);
        datacubes_rules[i].allow = false;
        i++;

        //Exclude the small apartment near the HQ
        datacubes_rules[i].item_name = '04_Datacube02';
        datacubes_rules[i].min_pos = vect(-632,1406,216);
        datacubes_rules[i].max_pos = vect(-264,1709,394);
        datacubes_rules[i].allow = false;
        i++;

        //Just the NSF HQ area itself
        datacubes_rules[i].item_name = '04_Datacube02';
        datacubes_rules[i].min_pos = vect(-515,-2600, 0);
        datacubes_rules[i].max_pos = vect(1451, 1722, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '04_Datacube02';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        break;

    case "05_NYC_UNATCOMJ12LAB":
        // jail cell codes
        datacubes_rules[i].item_name = '05_Datacube01';// don't allow this in the locked cabinet
        datacubes_rules[i].min_pos = vect(-2355,1414,-158)-vect(8,8,8);
        datacubes_rules[i].max_pos = vect(-2355,1414,-158)+vect(8,8,8);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = '05_Datacube01';// A spot up to the offices over mech bays
        datacubes_rules[i].min_pos = vect(-4093,652,-111)-vect(8,8,8);
        datacubes_rules[i].max_pos = vect(-4093,652,-111)+vect(8,8,8);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = '05_Datacube01';// Exclude the area in the main command centre too
        datacubes_rules[i].min_pos = vect(-1578,37,-171);
        datacubes_rules[i].max_pos = vect(-1507,210,-79);
        datacubes_rules[i].allow = false;
        i++;

        // As requested, the patient has been moved to the Surgery Ward for immediate salvage of his datavault.  If you wish to observe the progress of the operation in person, the door code for surgery is 0199; or, if you wish to view the operation remotely, you may use the temporary account we've created for you: login "psherman" and password "Raven".  Please let me know if myself or my staff can provide you with any further assistance.
        /*datacubes_rules[i].map = "05_NYC_UNATCOMJ12LAB";
        datacubes_rules[i].item_name = '05_Datacube03';
        datacubes_rules[i].min_pos = vect(1214.396851, -1006.870361, -99999);
        datacubes_rules[i].max_pos = vect(2404.169922, -254.634888, 99999);
        datacubes_rules[i].allow = false;
        i++;*/

        datacubes_rules[i].item_name = '05_Datacube03';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;// actually just don't randomize this one since we mention it in the wiki
        i++;


        // Wednesday, 4/15: IS promises that LabNet accounts will be restored by Friday; new login is "dmoreau" with password "raptor".
        datacubes_rules[i].item_name = '05_Book01';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // We are in the process of ghosting all network security resources to provide additional protection against possible intrusion or denial of service attacks.  Until this process is complete, all security computers will be utilizing a temporary system.
        // Login: MJ12  Password: INVADER
        datacubes_rules[i].item_name = '05_Datacube02';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;


        // Datacube with code to get into armoury area (keypad locked door at exit of robotics bay)

        //RATS datacube with password to armoury can be in armoury or robotics bay (original location is armoury desk)
        datacubes_rules[i].item_name = '05_Datacube03';
        datacubes_rules[i].package_name = "RevisionText";
        datacubes_rules[i].min_pos = vect(-9453, 180, -99999); //Allow in the armoury
        datacubes_rules[i].max_pos = vect(-7367,2273, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '05_Datacube03';
        datacubes_rules[i].package_name = "RevisionText";
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(-933, 99999, 99999);  //Allow anywhere on the robotics bay side of the map
        datacubes_rules[i].allow = true;
        i++;

        //Datacube with armoury door code - allow only in the robotics bay
        datacubes_rules[i].item_name = '05_Datacube04';
        datacubes_rules[i].package_name = "RevisionText";
        datacubes_rules[i].min_pos = vect(-9453, 180, -99999); //Keep out of the armoury
        datacubes_rules[i].max_pos = vect(-7367,2273, 99999);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = '05_Datacube04';
        datacubes_rules[i].package_name = "RevisionText";
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(-933, 99999, 99999);  //Allow anywhere on the robotics bay side of the map
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '05_Datacube04';
        datacubes_rules[i].package_name = "RevisionText";
        datacubes_rules[i].min_pos = vect(-933, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);  //Disallow anywhere on the medlab side of the map
        datacubes_rules[i].allow = false;
        i++;

        // Datacube with code to get into medical wing (Locked door at the command centre)
        datacubes_rules[i].item_name = '05_Datacube01';
        datacubes_rules[i].package_name = "RevisionText";
        datacubes_rules[i].min_pos = vect(-9453, 180, -99999); //Keep out of the armoury
        datacubes_rules[i].max_pos = vect(-7367,2273, 99999);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = '05_Datacube01';
        datacubes_rules[i].package_name = "RevisionText";
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(-933, 99999, 99999);  //Allow anywhere on the robotics bay side of the map
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "05_NYC_UNATCOHQ":
        datacubes_rules[i].item_name = 'JCCompPassword';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "06_HONGKONG_HELIBASE":
        //Security login
        datacubes_rules[i].item_name = '06_Datacube18';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "06_HONGKONG_WANCHAI_MARKET":
        datacubes_rules[i].item_name = '06_Datacube22';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = 'MarketATMPassword';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "06_HONGKONG_WANCHAI_STREET":
        //"Insurgent"
        datacubes_rules[i].item_name = '06_Book16';
        datacubes_rules[i].min_pos = vect(-1336,-1910,1950);
        datacubes_rules[i].max_pos = vect(-116,-447,2311);
        datacubes_rules[i].allow = true;
        i++;

        //Tai-Fun and Insurgent
        datacubes_rules[i].item_name = '06_Datacube21';
        datacubes_rules[i].min_pos = vect(-1336,-1910,1950);
        datacubes_rules[i].max_pos = vect(-116,-447,2311);
        datacubes_rules[i].allow = true;
        i++;

        //Police Vault entry code (in apartment, nowhere else)
        datacubes_rules[i].item_name = 'PoliceVaultPassword';
        datacubes_rules[i].min_pos = vect(-1336,-1910,1950);
        datacubes_rules[i].max_pos = vect(-116,-447,2311);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = 'PoliceVaultPassword';
        datacubes_rules[i].min_pos = vect(-99999,-99999,-99999);
        datacubes_rules[i].max_pos = vect(99999,99999,99999);
        datacubes_rules[i].allow = false;
        i++;


        datacubes_rules[i].item_name = 'QuickStopATMPassword';
        datacubes_rules[i].min_pos = vect(-99999,-99999,-99999);
        datacubes_rules[i].max_pos = vect(99999,99999,99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "06_HONGKONG_WANCHAI_UNDERWORLD":
        //Added datacube with security computer login/password (LUCKYMONEY/REDARROW)

        //Don't allow in the Quickstop
        datacubes_rules[i].item_name = 'LuckyMoneyPassword';
        datacubes_rules[i].min_pos = vect(-169,254,-305);
        datacubes_rules[i].max_pos = vect(443,650,-170);
        datacubes_rules[i].allow = false;
        i++;

        //Don't allow in the Freezer
        datacubes_rules[i].item_name = 'LuckyMoneyPassword';
        datacubes_rules[i].min_pos = vect(-1841,-3203,-360);
        datacubes_rules[i].max_pos = vect(-1393,-2420,-163);
        datacubes_rules[i].allow = false;
        i++;

        //Don't allow in the safe
        datacubes_rules[i].item_name = 'LuckyMoneyPassword';
        datacubes_rules[i].min_pos = vect(-1235, 125, -325);
        datacubes_rules[i].max_pos = vect(-1200, 155, -290);
        datacubes_rules[i].allow = false;
        i++;

        //Don't allow in the locked police room
        datacubes_rules[i].item_name = 'LuckyMoneyPassword';
        datacubes_rules[i].min_pos = vect(526,-393,-295);
        datacubes_rules[i].max_pos = vect(968,-189,-196);
        datacubes_rules[i].allow = false;
        i++;

        //Don't allow in the locked restaurant
        datacubes_rules[i].item_name = 'LuckyMoneyPassword';
        datacubes_rules[i].min_pos = vect(1332,-1334,-99999);
        datacubes_rules[i].max_pos = vect(2870,-315,99999);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = 'LuckyMoneyPassword';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "06_HONGKONG_VERSALIFE":
        datacubes_rules[i].item_name = 'VersalifeMainElevatorCode';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "06_HONGKONG_STORAGE":
        //Anywhere below the exit pipe
        datacubes_rules[i].item_name = 'VersalifeNanotechCode';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 1345); //1345 is the top of the pipe
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "08_NYC_HOTEL":
        // The code to Paul's bookshelf stash (Anywhere in Paul's Apartment except the stash)
        datacubes_rules[i].item_name = '02_Datacube07';
        datacubes_rules[i].min_pos = vect(-310, -4000, -99999);
        datacubes_rules[i].max_pos = vect(580, -3284, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '02_Datacube07';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        //Paul's computer password (Anywhere in Paul's Apartment)
        datacubes_rules[i].item_name = '02_Datacube05';
        datacubes_rules[i].min_pos = vect(-310, -4000, -99999);
        datacubes_rules[i].max_pos = vect(580, -2870, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '02_Datacube05';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        break;

    case "09_NYC_DOCKYARD":
        //Walton Simons login
        datacubes_rules[i].item_name = '09_Datacube11';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //USFEMA login
        datacubes_rules[i].item_name = '09_Datacube12';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //Jenny's Number can be anywhere
        datacubes_rules[i].item_name = 'JennysNumber';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "09_NYC_SHIP":
        //Ramp Code
        datacubes_rules[i].item_name = '09_Datacube14';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "09_NYC_GRAVEYARD":
        //Generator code datacube

        //Behind bookshelf
        datacubes_rules[i].item_name = 'EMGeneratorHintCube';
        datacubes_rules[i].min_pos = vect(990, 700, 0);
        datacubes_rules[i].max_pos = vect(1130, 850, 200);
        datacubes_rules[i].allow = false;
        i++;

        //Dowd's Safe
        datacubes_rules[i].item_name = 'EMGeneratorHintCube';
        datacubes_rules[i].min_pos = vect(-1400,-2025,-300);
        datacubes_rules[i].max_pos = vect(-1350,-2000,-250);
        datacubes_rules[i].allow = false;
        i++;

        //Don't allow in the underground catacombs or whatever
        datacubes_rules[i].item_name = 'EMGeneratorHintCube';
        datacubes_rules[i].min_pos = vect(-99999,-99999,-99999);
        datacubes_rules[i].max_pos = vect(99999,99999,-1050);
        datacubes_rules[i].allow = false;
        i++;

        //Allowed everywhere else
        datacubes_rules[i].item_name = 'EMGeneratorHintCube';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -1050);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "10_PARIS_ENTRANCE": //The level where you start on the roof
        // make sure you can get to the book without needing to jump down
        datacubes_rules[i].item_name = '10_Book09';
        datacubes_rules[i].min_pos = vect(-99999, -99999, 1956.809082); //top floor
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '10_Book09';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999); //top floor
        datacubes_rules[i].max_pos = vect(99999, 99999, 1956.809082);
        datacubes_rules[i].allow = false;
        i++;
        break;

    case "10_PARIS_CATACOMBS":
        //Login for the security system in the bunker warehouse
        datacubes_rules[i].item_name = '10_Datacube12';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "10_PARIS_CLUB":

        // Storage room code - main area of the club
        datacubes_rules[i].item_name = '10_Datacube07';
        datacubes_rules[i].min_pos = vect(-1584, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //back office
        datacubes_rules[i].item_name = '10_Datacube07';
        datacubes_rules[i].min_pos = vect(-2366,-303,-99999);
        datacubes_rules[i].max_pos = vect(-1832,383,99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "11_PARIS_EVERETT":
        // Lucius DeBeers login
        datacubes_rules[i].item_name = '11_Datacube01';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "11_PARIS_CATHEDRAL":
        // DataCube0 and 2 (The one with the 3 codes, 2 copies in the level)
        datacubes_rules[i].item_name = '11_Datacube03';
        datacubes_rules[i].min_pos = vect(-99999, -99999, 1956.809082); //top floor
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '11_Datacube03';// DataCube0 and 2 have the same textTag
        datacubes_rules[i].min_pos = vect(5442,-2553,-231); //gunther room
        datacubes_rules[i].max_pos = vect(7179,-1534,-4);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = '11_Datacube03';// 0 and 2
        datacubes_rules[i].min_pos = vect(5048,-2605,289); //before gunther room
        datacubes_rules[i].max_pos = vect(6075,-1800,766);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].item_name = '11_Datacube03';// 0 and 2
        datacubes_rules[i].min_pos = vect(5044,-5242,-139); //in the vault
        datacubes_rules[i].max_pos = vect(6059,-3717,92);
        datacubes_rules[i].allow = false;
        i++;

        //Anywhere on the cathedral grounds otherwise
        datacubes_rules[i].item_name = '11_Datacube03';
        datacubes_rules[i].min_pos = vect(2597,-4860, -99999);
        datacubes_rules[i].max_pos = vect(7902,1079, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '11_Datacube03';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        break;

    case "14_VANDENBERG_SUB":
        //Code for URV Bay doors

        // Roof of offshore module
        datacubes_rules[i].item_name = '14_Datacube01';
        datacubes_rules[i].min_pos = vect(1280,52,-170)-vect(32,32,32);
        datacubes_rules[i].max_pos = vect(1280,52,-170)+vect(32,32,32);
        datacubes_rules[i].allow = false;
        i++;

        //anywhere offshore
        datacubes_rules[i].item_name = '14_Datacube01';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(6200, 2000, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //Upper area onshore
        datacubes_rules[i].item_name = '14_Datacube01';
        datacubes_rules[i].min_pos = vect(800, -99999, -150);
        datacubes_rules[i].max_pos = vect(6200, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '14_Datacube01';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        break;

    case "14_OCEANLAB_SILO":
        //Code for missile launch controls - anywhere above ground
        datacubes_rules[i].item_name = '14_Datacube05';
        datacubes_rules[i].min_pos = vect(-99999, -99999, 1415);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //underground, outside of the actual silo
        datacubes_rules[i].item_name = '14_Datacube05';
        datacubes_rules[i].min_pos = vect(-99999, -3610, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 1415);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "14_OCEANLAB_LAB":
        //OCEANGUARD code to open sub bay doors.  This is SUPER IMPORTANT.  This needs to not fuck up.
        //Intent is for it to be able to spawn anywhere from the sub bay up to and including the command centre.
        //Revision has a locked door into the storage room hall which uses that login to access it

        //All floors of that main central building with the sub bay
        datacubes_rules[i].item_name = '14_Datacube06';
        datacubes_rules[i].min_pos = vect(-204,-550,-99999);
        datacubes_rules[i].max_pos = vect(491,817,99999);
        datacubes_rules[i].allow = true;
        i++;

        //Explicitly exclude EVERYTHING else for safety
        datacubes_rules[i].item_name = '14_Datacube06';
        datacubes_rules[i].min_pos = vect(-99999,-99999,-99999);
        datacubes_rules[i].max_pos = vect(99999,99999,99999);
        datacubes_rules[i].allow = false;
        i++;
        break;

    case "14_OCEANLAB_UC":
        //Code for walkway security computer - could go anywhere except for across the bridge (which has no loose items)

        // Stupid spot under the walkway
        datacubes_rules[i].item_name = '14_Datacube03';
        datacubes_rules[i].min_pos = vect(876,8206,-3179)-vect(8,8,8);
        datacubes_rules[i].max_pos = vect(876,8206,-3179)+vect(8,8,8);
        datacubes_rules[i].allow = false;
        i++;

        //Anywhere else
        datacubes_rules[i].item_name = '14_Datacube03';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "15_AREA51_BUNKER":
        //Both of these have to be above ground
        datacubes_rules[i].item_name = 'A51VentComputerCode';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -645);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = 'A51VentElevatorCode';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -645);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "15_AREA51_ENTRANCE":
        datacubes_rules[i].item_name = 'SleepPodCode1';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = 'SleepPodCode2';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = 'SleepPodCode3';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
        break;

    case "15_AREA51_FINAL":
        //Code for stairwell blastdoor
        //Not in the reactor lab
        datacubes_rules[i].item_name = '15_Datacube08';
        datacubes_rules[i].min_pos = vect(-3781,-6090,-99999);
        datacubes_rules[i].max_pos = vect(-2965,-4909,99999);
        datacubes_rules[i].allow = false;
        i++;

        //Not in the aug upgrade can container
        datacubes_rules[i].item_name = '15_Datacube08';
        datacubes_rules[i].min_pos = vect(-5005, -3035, -620);
        datacubes_rules[i].max_pos = vect(-4953, -3117, -680);
        datacubes_rules[i].allow = false;
        i++;

        //anywhere before the stairwell blastdoor
        datacubes_rules[i].item_name = '15_Datacube08';
        datacubes_rules[i].min_pos = vect(-5655, -5190, -1700);
        datacubes_rules[i].max_pos = vect(-2376, -2527, -534);
        datacubes_rules[i].allow = true;
        i++;

        //Code for Reactor lab
        //Not in the reactor lab
        datacubes_rules[i].item_name = '15_Datacube19';
        datacubes_rules[i].min_pos = vect(-3781,-6090,-99999);
        datacubes_rules[i].max_pos = vect(-2965,-4909,99999);
        datacubes_rules[i].allow = false;
        i++;

        //Not in the aug upgrade can container
        datacubes_rules[i].item_name = '15_Datacube19';
        datacubes_rules[i].min_pos = vect(-5005, -3035, -620);
        datacubes_rules[i].max_pos = vect(-4953, -3117, -680);
        datacubes_rules[i].allow = false;
        i++;

        //anywhere before the stairwell blastdoor
        datacubes_rules[i].item_name = '15_Datacube19';
        datacubes_rules[i].min_pos = vect(-5655, -5190, -1700);
        datacubes_rules[i].max_pos = vect(-2376, -2527, -534);
        datacubes_rules[i].allow = true;
        i++;

        break;

    case "15_AREA51_PAGE":
        // LAB12/graytest datacube (note that the text tag is different from vanilla)
        //Main clone area
        datacubes_rules[i].item_name = '15_Datacube02';// LAB 12 / graytest
        datacubes_rules[i].min_pos = vect(-1066,-1579, -99999);
        datacubes_rules[i].max_pos = vect(590,291, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //Side Medical Area
        datacubes_rules[i].item_name = '15_Datacube02';// LAB 12 / graytest
        datacubes_rules[i].min_pos = vect(-2403,-648, -99999);
        datacubes_rules[i].max_pos = vect(-1564,102, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '15_Datacube02';// LAB 12 / graytest
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;

        //UC Control Room password can be anywhere
        datacubes_rules[i].item_name = 'UCControlRoomPassword';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        //Aquinas Substation and Router Control Room code
        datacubes_rules[i].item_name = '15_Datacube11';
        datacubes_rules[i].min_pos = vect(-1546,1643,0);
        datacubes_rules[i].max_pos = vect(967,3487,-762);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].item_name = '15_Datacube11';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = false;
        i++;


        break;

    }
}

//I don't want to add the default text package to all the rules manually
function safe_rule ApplyDefaultTextPackage(safe_rule r)
{
    if (r.item_name!='' && r.package_name==""){
        r.package_name="DeusExText"; //Default text package name
    }

    return r;
}


function FirstEntry()
{
    Super.FirstEntry();

    RandoInfoDevs(dxr.flags.settings.infodevices);
    RandoHacks();
    MakeAllHackable(dxr.flags.settings.deviceshackable);
}

function RandoHacks()
{
    local #var(prefix)HackableDevices h;

    if(dxr.flags.settings.deviceshackable <=0 && dxr.flags.IsZeroRando()) return;
    SetSeed( "RandoHacks" );

    foreach AllActors(class'#var(prefix)HackableDevices', h) {
        _RandoHackable(h);
    }
}

function _RandoHackable(#var(prefix)HackableDevices h)
{
    if( h.bHackable && h.hackStrength>0 ) {
        h.hackStrength = rngrange(h.hackStrength, min_hack_adjust, max_hack_adjust);
        h.hackStrength = Clamp(h.hackStrength*100, 1, 100)/100.0;
        h.initialhackStrength = h.hackStrength;
    }
}

static function RandoHackable(DXRando dxr, #var(prefix)HackableDevices h)
{
    local DXRPasswords m;
    m = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
    if( m != None ) {
        m._RandoHackable(h);
    }
}

function RandoInfoDevs(int percent)
{
    local #var(prefix)InformationDevices id;
    local bool totallyEmpty;
#ifndef injections
    local #var(injectsprefix)InformationDevices dxrid;
#endif

    foreach AllActors(class'#var(prefix)InformationDevices', id)
    {
        if(!id.bHidden && percent>0 && id.Mesh == class'#var(prefix)DataCube'.default.Mesh)
            GlowUp(id);
        if( id.bIsSecretGoal || !chance_single(percent) ) {
            if( ! id.bAddToVault ) { // Zero Rando books should add to vault too
                InfoDevsHasPass(id);
            }
            continue;
        }
        if (id.textTag=='' && id.imageClass==None){
            //Don't shuffle completely empty information devices
            //This isn't an issue (afaik) in vanilla, but mods sometimes
            //put empty datacubes/newspapers in inaccessible areas as decoration
            totallyEmpty=True;
#ifdef injections
            if (id.plaintext!="") totallyEmpty=False;
#else
            dxrid = #var(injectsprefix)InformationDevices(id);
            if (dxrid!=None){
                if (dxrid.plaintext!="") totallyEmpty=False;
            }
#endif
            if (totallyEmpty) continue;
        }
        _RandoInfoDev(id, dxr.flags.settings.infodevices_containers > 0);
    }
}

function _RandoInfoDev(#var(prefix)InformationDevices id, bool containers)
{
    local Inventory inv;
    local Containers c;
    local Actor temp[1024];
    local int num, slot, numHasPass, bads, tries;
    local int hasPass[64];
    local Vector newloc;
    local String TextTag;

    InfoDevsHasPass(id, hasPass, numHasPass);

    TextTag = class'#var(injectsprefix)InformationDevices'.static.GetTextTag(id);

    num=0;
    foreach AllActors(class'Inventory', inv)
    {
        if( SkipActor(inv) ) continue;
        if( InfoPositionGood(id, inv.Location, hasPass, numHasPass) == False ) {
            bads++;
            continue;
        }
#ifdef locdebug
        if(TextTag ~= "#var(locdebug)" && ("#var(locpackage)"==id.TextPackage || "#var(locpackage)"~="None" || "#var(locpackage)"=="" )){
            DebugMarkKeyPosition(inv.Location, TextTag);
        }
#endif
        temp[num++] = inv;
    }

    if(containers) {
        foreach AllActors(class'Containers', c)
        {
            if( SkipActor(c) ) continue;
            if( InfoPositionGood(id, c.Location, hasPass, numHasPass) == False ) {
                bads++;
                continue;
            }
            if( HasBased(c) ) continue;
#ifdef locdebug
            if(TextTag ~= "#var(locdebug)" && ("#var(locpackage)"==id.TextPackage || "#var(locpackage)"~="None" || "#var(locpackage)"=="" )){
                DebugMarkKeyPosition(c.Location, TextTag);
            }
#endif
            temp[num++] = c;
        }
    }

    l("DatacubePositionCheck datacube "$id$" ("$TextTag$") got num "$num$" with "$bads$" unsafe positions in map "$dxr.localurl);
    for(tries=0; tries<5; tries++) {
        slot=rng(num+1);//+1 for the vanilla location, since we're not in the list
        if(slot==0) {
            l("not swapping infodevice "$ActorToString(id));
            return;
        }
        slot--;
        l("swapping infodevice "$ActorToString(id)$" with "$temp[slot] $" ("$temp[slot].Location$")");

        if(PlaceholderItem(temp[slot]) != None) {
            newloc = temp[slot].Location;
            newloc.Z -= temp[slot].CollisionHeight - id.CollisionHeight;
            temp[slot].SetCollisionSize(id.CollisionRadius, id.CollisionHeight);
            temp[slot].SetLocation(newloc);
        }
        // Swap argument A is more lenient with collision than argument B
        if(Swap(temp[slot], id)) break;
    }
}

function MakeAllHackable(int deviceshackable)
{
    local #var(prefix)HackableDevices h;

    SetSeed( "MakeAllHackable" );

    foreach AllActors(class'#var(prefix)HackableDevices', h)
    {
        if( h.bHackable == false && chance_single(deviceshackable) ) {
            h.bHackable = true;
            h.hackStrength = rngrange(0.8, min_hack_adjust, max_hack_adjust);
            h.hackStrength = Clamp(h.hackStrength*100, 1, 100) / 100.0;
            h.initialhackStrength = h.hackStrength;
            l("found unhackable device: " $ ActorToString(h) $ ", tag: " $ h.Tag $ " in " $ dxr.localURL $ ", now: " $ h.hackStrength);
        }

        // make Helios ending slightly harder?
        if(h.Event == 'door_helios_room') {
            h.bHackable = false;
            h.hackStrength = 1;
            h.initialhackStrength = h.hackStrength;
        }
    }
}

simulated function bool InfoDevsHasPass(#var(prefix)InformationDevices id, optional out int hasPass[64], optional out int numHasPass)
{
    local DeusExTextParser parser;
    local int i;
    local #var(injectsprefix)InformationDevices injectID;

    numHasPass=0;
    for(i=0; i<ArrayCount(hasPass); i++)
        hasPass[i]=0;

    if ( id.textTag != '' ) {
        parser = new(None) Class'DeusExTextParser';
        if( parser.OpenText(id.textTag, id.TextPackage) ) {
            l("infodev test password "$id$" textTag: " $ id.textTag);
            ProcessText(parser, hasPass, numHasPass);
            parser.CloseText();
        }
        CriticalDelete(parser);
    }

    #ifdef injections
        injectID=id;
    #else
        injectID=#var(injectsprefix)InformationDevices(id);
    #endif

    if( injectID!=None && injectID.plaintext != "" ) {
        ProcessStringHasPass(injectID.plaintext, hasPass, numHasPass);
    }

    if( numHasPass > 0 )
        id.bAddToVault = true;

    return numHasPass > 0;
}

simulated function ProcessText(DeusExTextParser parser, out int hasPass[64], out int numHasPass)
{
    local string text;
    local int i;
    local byte tag;

    while(parser.ProcessText()) {
        tag = parser.GetTag();
        if( tag != 0 ) continue;

        text = parser.GetText();
        l(text);
        text = Caps(text);
        if( Len(text) == 0 ) continue;

        ProcessStringHasPass( text, hasPass, numHasPass );
    }
}

simulated function ProcessStringHasPass(string text, out int hasPass[64], out int numHasPass)
{
    local int i;
    text = Caps(text);
    for(i=0; i<passEnd; i++) {
        if( Len(oldpasswords[i]) == 0 ) continue;
        if( PassInStr( text, oldpasswords[i] ) != -1 ) {
            /*l("found password "$oldpasswords[i]);
            l(text);
            l("---");*/
            hasPass[i] = 1;
            numHasPass++;
        }
    }
}

function bool CheckComputerPosition(#var(prefix)InformationDevices id, #var(prefix)Computers c, vector newpos, int hasPass[64])
{
    local int a, i;

    if( PositionIsSafe(id.Location, c, newpos) ) return True;// don't even need to check the passwords

    for (i=0; i<ArrayCount(c.userList); i++)
    {
        if (c.userList[i].password == "")
            continue;

        for (a=0; a<passEnd; a++) {
            if( hasPass[a]==1 && c.userList[i].password == newpasswords[a] ) {
                return False;
            }
        }
    }
    return True;
}

function bool CheckKeypadPosition(#var(prefix)InformationDevices id, #var(prefix)Keypad k, vector newpos, int hasPass[64])
{
    local int i;

    if( PositionIsSafe(id.Location, k, newpos) ) return True;// don't even need to check the passwords
    if ( k.validCode == "" ) return True;

    for (i=0; i<passEnd; i++) {
        if( hasPass[i]==1 && k.validCode == newpasswords[i] ) {
            return False;
        }
    }
    return True;
}

function bool InfoPositionGood(#var(prefix)InformationDevices id, vector newpos, int hasPass[64], int numHasPass)
{
    local #var(prefix)Computers c;
    local #var(prefix)Keypad k;
    local #var(injectsprefix)InformationDevices injectID;
    local String TextTag;
    local String mapname;
    local int i;

    TextTag = class'#var(injectsprefix)InformationDevices'.static.GetTextTag(id);

    i = GetSafeRule( datacubes_rules, TextTag, id.TextPackage, newpos);
    if( i != -1 ) return datacubes_rules[i].allow;

    if( VSize( id.Location - newpos ) > 5000 ) return False;

    if ( TextTag == "" ) {
        //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning True, no textTag");
        return True;
    }

    if( numHasPass==0 ) {
        //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning True, hasPass is empty");
        return True;
    }// else l("InfoPositionGood("$ActorToString(id)$", "$newpos$") found hasPass "$a);

    foreach AllActors(class'#var(prefix)Computers', c)
    {
        if( CheckComputerPosition(id, c, newpos, hasPass) == False ) {
            //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning False, found computer "$ActorToString(c));
            return False;
        }
    }
    foreach AllActors(class'#var(prefix)Keypad', k)
    {
        if( CheckKeypadPosition(id, k, newpos, hasPass) == False ) {
            //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning False, found keypad "$ActorToString(k));
            return False;
        }
    }
    //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning True");
    return True;
}


static function string GetHumanTextTagName(string texttag, string textpackage)
{

    local string prefix,fullTag,s1;
    local int i;

    fullTag = textpackage$"."$texttag;
    //Exact matches should check both package and tag, since Revision has some tag overlap
    switch(fullTag){
        case "DeusExText.00_Book01":
            return "UNATCO Training Manual";
        case "DeusExText.00_Datacube01":
            return "First Door Code";
        case "DeusExText.00_Datacube02":
            return "Final Bridge Code";
        case "DeusExText.00_Datacube03":
            return "Note from Jaime";
        case "DeusExText.00_Datacube04":
            return "UNATCO Stealth Guidelines";

        case "DeusExText.01_Book09":
        case "RevisionText.01_Book09_Biomod":
        case "RevisionText.01_Book09_Rev":
            return "Nano-Augmentation Guidelines";
        case "RevisionText.01_Datacube01":
            return "Note to Paul"; //To Paul from Janice, telling him his account is now active (no details)
        case "RevisionText.01_Datacube02":
            return "Detention Wing Door Code";
        case "DeusExText.01_Datacube01":
            return "Manderley Login";
        case "DeusExText.01_Datacube03":
            return "Comm Van Code";
        case "DeusExText.01_Datacube04":
            return "NSF001 Login";
        case "DeusExText.01_Datacube05":
            return "Gunther Login";
        case "DeusExText.01_Datacube06":
            return "SATCOM Login";
        case "DeusExText.01_Datacube10":
            return "Mnemosyne Sojourn Project";
        case "DeusExText.01_Newspaper01":
            return "Mead Bucks Congress";
        case "DeusExText.01_Newspaper02":
            return "Bootcamp for Betty";
        case "DeusExText.01_Newspaper03":
            return "A Lesson for Our President";
        case "DeusExText.01_Newspaper05":
            return "French Connection Found in Rubble";
        case "DeusExText.01_Newspaper07":
            return "Mass Grave in Brooklyn";

        case "DeusExText.02_Datacube01":
            return "Note for Commander Frase";
        case "DeusExText.02_Datacube02":
            return "JSteward Login";
        case "DeusExText.02_Datacube03":
            return "Sewer Hatch Code";
        case "DeusExText.02_Datacube05":
            return "Paul Login";
        case "DeusExText.02_Datacube06":
            return "Sewer Hatch Code";
        case "DeusExText.02_Datacube07":
            return "Paul's Painting Code";
        case "DeusExText.02_Datacube09":
            return "Warehouse Basement Ramp Code";
        case "DeusExText.02_Datacube10":
            return "Warehouse Office Code";
        case "DeusExText.02_Datacube11":
            return "Sewer Security Login";
        case "DeusExText.02_Datacube14":
            return "Warehouse Generator Computer Login";
        case "DeusExText.02_Datacube15":
            return "Castle Clinton Kiosk Code";
        case "DeusExText.02_Datacube16":
            return "Note for Commander Grimaldi";
        case "DeusExText.02_Datacube17":
            return "Note for Commander Frase";
        case "DeusExText.02_Datacube18":
            return "Warehouse Email Computer Login";
        case "DeusExText.02_Newspaper01":
            return "Bellevue Reports Increase in Admittance";
        case "DeusExText.02_Newspaper02":
            return "Grayve Times Ad";
        case "DeusExText.02_Newspaper04":
            return "Court Upholds NY Grid Law";
        case "DeusExText.02_Newspaper05":
            return "NetChurch of God Ad";
        case "RevisionText.02_Book01":
            return "Dangerous Days: Chapter 2";
        case "RevisionText.02_Book02":
            return "Diary";
        case "RevisionText.02_Book03":
            return "Gray Wolf";
        case "RevisionText.02_Datacube01":
            return "Note to YT";
        case "RevisionText.02_Datacube02":
            return "Bar Freezer Door Code";

        case "DeusExText.03_Book01":
            return "Art of War";
        case "DeusExText.03_Book02":
            return "Medical Management of Biological Casualties Handbook";
        case "DeusExText.03_Book03":
            return "Righteous Angels: Perspectives on UNATCO";
        case "DeusExText.03_Book06":
            return "Curly's Journal"; //Should this mention that it's the phonebooth code too?
        case "DeusExText.03_Datacube03":
            return "Note for Jonny"; //Note to Jonny from Erin Young
        case "DeusExText.03_Datacube05":
            return "Note for Erin"; //Note to Erin (Young) from Juan Lebedev
        case "DeusExText.03_Datacube06":
            return "Note for Young"; //Note to (Erin) Young from Decker
        case "DeusExText.03_Datacube08":
            return "Phonebooth Code"; //UNUSED
        case "DeusExText.03_Datacube10":
            return "Hangar Door Code";
        case "DeusExText.03_Datacube12":
            return "ETodd Login";
        case "DeusExText.03_Datacube13":
            return "Suspension Crate Code";
        case "DeusExText.03_Datacube14":
            return "Brooklyn Bridge Station Bathroom Code";
        case "DeusExText.03_Newspaper03":
            return "Seasonal Flooding Minimal";
        case "DeusExText.747Diagram":
            return "747 Diagram";
        case "DeusExText.MilleniumMagazine":
            return "Millenium Magazine";
        case "RevisionText.03_Datacube01":
            return "Server Room Door Code";
        case "RevisionText.03_Datacube10":  //For leaving a good soda in Gunther's office
        case "RevisionText.03_Datacube11":  //For leaving a bad soda in Gunther's office
        case "RevisionText.03_Datacube12":  //For leaving a good and bad soda in Gunther's office
            return "Note from Gunther";

        case "DeusExText.04_Datacube01":
            return "Dish Alignment Login";
        case "DeusExText.04_Datacube02":
            return "TJefferson Login"; //The login for the computer in the halon room that opens the basement (How to phrase that in a concise way though?)
        case "DeusExText.04_Datacube04":
            return "Halon Gas Warning";
        case "DeusExText.04_Datacube05":
            return "Paul's Evidence";
        case "DeusExText.04_Newspaper01":
            return "Ten Dead in Gang Slaying";
        case "DeusExText.04_Newspaper02":
            return "UNATCO Nabs Terrorists in Hell's Kitchen Raid";
        case "RevisionText.04_Datacube01":
            return "Storage Locker Door Code";
        case "RevisionText.04_Datacube02":
            return "Warehouse Storage Deposit Door Code";
        case "RevisionText.04_Datacube10":
        case "RevisionText.04_Datacube11":
        case "RevisionText.04_Datacube12":
        case "RevisionText.04_Datacube13":
        case "RevisionText.04_Datacube14":
        case "RevisionText.04_Datacube15":
        case "RevisionText.04_Datacube16":
        case "RevisionText.04_Datacube17":
        case "RevisionText.04_Datacube18":
        case "RevisionText.04_Datacube19":
        case "RevisionText.04_Datacube20":
        case "RevisionText.04_Datacube21":
            return "Note from Gunther";  //More notes for leaving Gunther drinks.  I ain't writing descriptions for all of these

        case "DeusExText.05_Book01":
            return "DMoreau Login";
        case "DeusExText.05_Datacube01":
            return "Detention Block Codes";
        case "DeusExText.05_Datacube02":
            return "MJ12 Lab Security Login";
        case "DeusExText.05_Datacube03":
            return "Surgery Ward Door Code and PSherman Login";
        case "DeusExText.05_Datacube04":
            return "Armory Door Code";
        case "DeusExText.05_Datacube05":
            return "Greasel Dissection Chart";
        case "DeusExText.05_Datacube06":
            return "Acoustic Sound Sensors";
        case "DeusExText.05_Datacube07":
            return "Surgical Pre-Evaluation: Paul Denton";
        case "DeusExText.05_Datacube08":
        case "RevisionText.05_Datacube05":
            return "UNATCO Logins";
        case "DeusExText.05_Datacube10":
            return "Prospectus: Series P Agents";
        case "DeusExText.WaltonSimons":
            return "Walton Simons";
        case "RevisionText.05_Datacube01":
            return "Medical Wing Door Code";
        case "RevisionText.05_Datacube02":
            return "Note to Marty";
        case "RevisionText.05_Datacube03":
            return "Armory Upstairs Door Code";
        case "RevisionText.05_Datacube04":
            return "Armory Area Door Code";

        case "DeusExText.06_Book01":
        case "RevisionText.06_Book01_Biomod":
        case "RevisionText.06_Book01_Rev":
            return "MJ12 Nano-Augmentation Experiment Series 3-C";
        case "DeusExText.06_Book05":
            return "Journal of Hung Kwan Gordon Quick";
        case "DeusExText.06_Book07":
            return "Karkian Scientist Final Note";
        case "DeusExText.06_Book10":
            return "The True Way";
        case "DeusExText.06_Book15":
            return "Tai-Fun";
        case "DeusExText.06_Book16":
            return "Insurgent";
        case "DeusExText.06_Book17":
            return "The Most Holy Annals of the Luminous Path";
        case "DeusExText.06_Datacube01":
            return "Acoustic Gunfire Sensors";
        case "DeusExText.06_Datacube02":
            return "Helibase Elevator Code";
        case "DeusExText.06_Datacube03":
            return "Note to Officer Tam"; //Note from Central Police Command to Tam about the triad conflicts
        case "DeusExText.06_Datacube04":
            return "Surveillance Note"; //Luminous Path spotted the helicopter coming in
        case "DeusExText.06_Datacube05":
            return "Maggie's Birthday";
        case "DeusExText.06_Datacube06":
            return "Yuen Interrogation Recording";
        case "DeusExText.06_Datacube07":
            return "Versalife Security Records";
        case "DeusExText.06_Datacube08":
            return "Versalife Sign-Ins";
        case "DeusExText.06_Datacube09":
            return "Nervous Notes";
        case "DeusExText.06_Datacube10": //Mentions that Lundquist has Root, and MChow should be granted access, but no passwords
            return "Note to Harrison"; //From Dr Lundquist to Harrison
        case "DeusExText.06_Datacube11":
            return "MJ12 Security Login";
        case "DeusExText.06_Datacube12":
            return "Weapons Research Team Login";
        case "DeusExText.06_Datacube13":
            return "Police Station Door Code";
        case "DeusExText.06_Datacube14":
            return "Report on Dr. Feng"; //Just lore, Maggie reported a doctor who was talking about the Gray Death too much
        case "DeusExText.06_Datacube15":
            return "Note to Mr. Hundley";  //Tai-Fun is compromised, report use of it!
        case "DeusExText.06_Datacube16":
            return "Helibase Gas Purge Code";
        case "DeusExText.06_Datacube17":
            return "Ship's Captain Log";
        case "DeusExText.06_Datacube18":
            return "Helibase Security Login";
        case "DeusExText.06_Datacube19":
            return "Officer Tam Login";
        case "DeusExText.06_Datacube20":
            return "Queen's Tower Login and Code";
        case "DeusExText.06_Datacube21":
            return "Maggie Chow's Favorite Books";
        case "DeusExText.06_Datacube22":
            return "Police Report";
        case "DeusExText.06_Datacube23":
            return "Jock's Login";
        case "DeusExText.06_Datacube24":
            return "Superfreighter Refitting";
        case "DeusExText.06_Datacube25":
            return "UC Shutdown Code";
        case "DeusExText.06_Datacube27":
            return "Versalife Floorplans"; //UNUSED
        case "DeusExText.06_Datacube28":
            return "Wan Chai Market Map";
        case "DeusExText.06_Datacube29":
            return "Magnetic Testing Chamber Code";
        case "DeusExText.06_Datacube30":
            return "Versalife Level 2 Door Seal Code";
        case "DeusExText.06_Datacube31":
            return "Versalife Data Entry Login";
        case "DeusExText.06_Datacube32":
            return "Deck One Flight Control Note";
        case "DeusExText.06_Newspaper01":
            return "UNATCO Responds to Terrorist Attack";
        case "DeusExText.06_Newspaper03":
            return "Gray Death Cases Misdiagnosed";
        case "DeusExText.06_Newspaper04":
            return "Canal Road Tunnel Collapse";
        case "DeusExText.GrayDisection":
            return "Gray Dissection";
        case "RevisionText.06_Book01":  //Note that this is a *different* 06_Book01 from above
            return "Van Problems";
        case "RevisionText.06_Book02":
            return "Chan's Diary";
        case "RevisionText.06_Datacube01":
            return "Zhanshan Temple Closed";
        case "RevisionText.06_Datacube03":
            return "Note to Tessa";
        case "RevisionText.06_Datacube04":
            return "Pipe Checks";
        case "RevisionText.06_Datacube05":
            return "Private Office Door Code";
        case "RevisionText.06_Newspaper01":
            return "Furnitures for Sale!";
        case "RevisionText.06_Newspaper02":
            return "VERY CHEAP FOOD!";
        case "RevisionText.06_Newspaper03":
            return "Mall News";
        case "RevisionText.06_Newspaper04":
            return "Shots Fired";

        case "DeusExText.08_Datacube01":
            return "Free Clinic Login";
        case "DeusExText.08_Newspaper02":
            return "Terrorist Bombing Kills 35";
        case "DeusExText.08_Newspaper03":
            return "SOCIETY: Party Against Tomorrow";
        case "DeusExText.08_Newspaper04":
            return "Beth DuClare Awarded Legion of Honor";
        case "RevisionText.08_Datacube01":
            return "Zyme Addict's Note";
        case "RevisionText.08_Datacube02":
            return "Note to Cassy";

        case "DeusExText.09_Book01":
            return "Naval Yard Sign-Ins";
        case "DeusExText.09_Datacube01":
            return "Note to Captain Keene"; //Talk to the dock foreman for the ramp code
        case "DeusExText.09_Datacube02":
            return "Ship Armory Code";
        case "DeusExText.09_Datacube03":
            return "Captain's Quarters Code";
        case "DeusExText.09_Datacube04":
            return "Ship Ops Code";
        case "DeusExText.09_Datacube05":
            return "Superfreighter Status Update";
        case "DeusExText.09_Datacube06":
            return "Ship Hangar Code";
        case "DeusExText.09_Datacube07":
            return "Ship Engine Room Bridge Code";
        case "DeusExText.09_Datacube08":
            return "East Warehouse Security Office Code";
        case "DeusExText.09_Datacube09":
            return "Submarine Facility Door Code";
        case "DeusExText.09_Datacube10":
            return "Root Login";
        case "DeusExText.09_Datacube11":
            return "Walton Simons Login";
        case "DeusExText.09_Datacube12":
            return "USFEMA Login";
        case "DeusExText.09_Datacube13":
            return "KZhao Login";
        case "DeusExText.09_Datacube14":
        case "RevisionText.09_Datacube14":
            return "Ship Ramp Code";
        case "DeusExText.09_Newspaper01":
            return "Search for Terrorist Leader Intensifies";
        case "DeusExText.09_Newspaper02":
            return "Page Unveils 'Aquinas'";
        case "DeusExText.09_Newspaper03":
            return "Family Discovers New Species";
        case "RevisionText.09_Book01":
            return "Sandoval 25:18";
        case "RevisionText.09_Book02":
            return "The Definitive Anthology of Children's Very Short Stories";
        case "RevisionText.09_Datacube01":
            return "Reconnaissance";
        case "RevisionText.09_Datacube02":
            return "Gatehouse Security Login";
        case "RevisionText.09_Datacube03":
            return "Out of Coffee!";
        case "RevisionText.09_Datacube04":
            return "Jazz Computer Login";
        case "RevisionText.09_Datacube05":
            return "VODKA";
        case "RevisionText.09_Datacube06":
            return "Lower Decks Door Code";
        case "RevisionText.09_Datacube07":
            return "Weld Point Security Door Codes";  //For those boxes around the two in the main engine room
        case "RevisionText.09_Datacube08":
            return "Lower Decks Security Login";
        case "RevisionText.09_Datacube09":
            return "Break Room Security Login";
        case "RevisionText.09_Datacube15":
            return "Fan Safety";
        case "RevisionText.09_Newspaper01":
            return "Accident At Versalife Sets Back Ambrosia Production";

        case "DeusExText.10_Book01":
            return "Richard III: Act I, Scene IV";
        case "DeusExText.10_Book04":
            return "Common Sense";
        case "DeusExText.10_Book05":
            return "The Eye of Argon";
        case "DeusExText.10_Book07":
            return "Petals of Twilight";
        case "DeusExText.10_Book09":
            return "Maintenance Lift Code";
        case "DeusExText.10_Datacube01":
            return "Agent Hela's Orders";
        case "DeusExText.10_Datacube02":
            return "Beth's Computer Login";
        case "DeusExText.10_Datacube07":
            return "Club Storeroom Code";
        case "DeusExText.10_Datacube09":
            return "Paris Street Map";
        case "DeusExText.10_Datacube10":
            return "Note to Chad";  //A guy reporting to Chad about MJ12 in the catacombs
        case "DeusExText.10_Datacube11":
            return "Agent Hela Login";
        case "DeusExText.10_Datacube12":
            return "RZelazny Login";
        case "DeusExText.10_Datacube13":
            return "Chateau Suspension Vault Code";
        case "DeusExText.10_Newspaper01":
            return "Catacombs Closed to Public";
        case "DeusExText.10_Newspaper02":
            return "Police Raid Catacombs";
        case "DeusExText.10_Newspaper03":
            return "Exclusive: Bob Page Interview";
        case "DeusExText.10_Newspaper04":
            return "Bot Kills Three in Accidental Shooting";
        case "DeusExText.10_Newspaper05":
            return "Somnolente Ile Scandal Resurfaces";
        case "RevisionText.10_Book01":
            return "Henry Leighton's Journal";
        case "RevisionText.10_Book02":
            return "Reyn's Table: Chapter 1";
        case "RevisionText.10_Datacube01":
            return "Metro Station Security Login";
        case "RevisionText.10_Newspaper01":
            return "The Atlantic Standard (International Edition)";

        case "DeusExText.11_Book01":
            return "MJ12 Compromised Individuals List";
        case "DeusExText.11_Book02":
            return "The Doctrine of the Mighty";
        case "DeusExText.11_Book08":
            return "Testament of Adept 34501";
        case "DeusExText.11_Book09":
            return "Project Morpheus: Notebook 8-B";
        case "DeusExText.11_Book10":
            return "MJ12 Troop Journal";
        case "DeusExText.11_Datacube01":
            return "Everett's Security Login";
        case "DeusExText.11_Datacube02":
            return "Morpheus Door Code";
        case "DeusExText.11_Datacube03":
        case "RevisionText.11_Datacube03":
            return "Adept 34501 Cathedral Codes";
        case "DeusExText.11_Newspaper01":
            return "United States Institutes Martial Law";
        case "RevisionText.11_Datacube01":
            return "Interpol Wanted: J.C. Denton";
        case "RevisionText.11_Datacube02":
            return "Cathedral Security Login";

        case "DeusExText.12_Datacube01":
            return "Tunnel Security Login";
        case "DeusExText.12_Datacube02":
            return "Vandenberg Guardhouse Note";

        case "DeusExText.14_Book01":
            return "Thomas Mann: Last Will and Testament";
        case "DeusExText.14_Book02":
            return "Universal Constructor: Theory, Principles, and Practice";
        case "DeusExText.14_Book03":
            return "Silo Scientist List";
        case "DeusExText.14_Datacube01":
        case "RevisionText.14_Datacube01":
            return "URV Bay Security Login";
        case "DeusExText.14_Datacube02":
        case "RevisionText.14_Datacube05":
            return "OceanLab Tunnel Code";
        case "DeusExText.14_Datacube03":
            return "OceanLab UC Security Login";
        case "DeusExText.14_Datacube04"://Warning about spiders and stuff in UC
            return "Final Note";
        case "DeusExText.14_Datacube05":
            return "Silo Launch Computer Login";
        case "DeusExText.14_Datacube06":
            return "OceanGuard Login";
        case "DeusExText.14_Datacube07": //Yushio heading down to UC
            return "Note to Mary Beth";
        case "DeusExText.14_Newspaper01":
            return "U.S. Situation Worsens";
        case "RevisionText.14_Book01":
            return "Everything You Ever Wanted To Know About..."; //...Tidal Influence on Undersea Communications Arrays (But Were Too Afraid To Ask Because You Were Worried It Would Make You Look Incompetent)
        case "RevisionText.14_Book02":
            return "Dangerous Days: Chapter 14";
        case "RevisionText.14_Datacube02":
            return "Note from Dr. Michael Roth";
        case "RevisionText.14_Datacube03":
            return "Employee Evaluation";
        case "RevisionText.14_Datacube04":
            return "Operations Room Door Code";

        case "DeusExText.15_Datacube06":
            return "Problem Recommendation Report 87-X";
        case "DeusExText.15_Datacube07":
        case "DeusExText.A51BlastDoorComputerHintCube":  //This cube replaces the text tag above
            return "Bunker Door Security Login";
        case "DeusExText.15_Datacube08":
            return "Maintenance Log: Purvis, J.";
        case "DeusExText.15_Datacube09":
            return "Coolant Room Door Code";
        case "DeusExText.15_Datacube10":
            return "Last Words";  //Recording of a dude dying
        case "DeusExText.15_Datacube11":
            return "Aquinas Router Door Code";
        case "DeusExText.15_Datacube12":
            return "Explosives Locker Door Code";
        case "DeusExText.15_Datacube13":
            return "JShears Login";
        case "DeusExText.15_Datacube14":
            return "Technical Report 12-Y";
        case "DeusExText.15_Datacube15":
            return "A new god, crafted in our likeness";  //"Page is God", "All Praise the UC"
        case "DeusExText.15_Datacube17":
            return "Lab B13 Login";
        case "DeusExText.15_Datacube18":
        case "RevisionText.15_Datacube02":
            return "Gray Lab Login";
        case "DeusExText.15_Datacube19":
            return "Reactor Room Door Code";
        case "DeusExText.15_Datacube20":
            return "Hiding in the Reactor Lab";
        case "DeusExText.15_Datacube21":
            return "Page Security Login";
        case "DeusExText.Area51Sector4":
            return "Area 51 Sector 4 Map";
        case "RevisionText.15_Datacube01":
            return "Note to Rose";

/////////////////////////
//   Added datacubes   //
/////////////////////////

        case "DeusExText.LeoHintCube":
            return "Note from Leo";

        case "DeusExText.FixedSaveReminder":
            return "Save Reminder";

        case "DeusExText.ManderleyKillphraseHint":
            return "Anna's Killphrase Note";

        case "DeusExText.DTSHintCube":
            return "Dragon Tooth Sword Note";

        case "DeusExText.EMGeneratorHintCube":
            return "EM Generator Installation Note";

        case "DeusExText.JCCompPassword":
            return "JC's Computer Login";

        case "DeusExText.KillphrasePassword":
            return "Anna's Killphrase Login";

        case "DeusExText.VersalifeMainElevatorCode":
            return "Versalife Market Elevator Code";

        case "DeusExText.VersalifeNanotechCode":
            return "Versalife Level 2 Lab Code";

        case "DeusExText.PoliceVaultPassword":
            return "Police Vault Code";

        case "DeusExText.LuckyMoneyPassword":
            return "Lucky Money Security Login";

        case "DeusExText.JennysNumber":
            return "Jenny's Number";

        case "DeusExText.A51VentComputerCode":
            return "Area 51 Ventilation Security Login";

        case "DeusExText.A51VentElevatorCode":
            return "Area 51 Ventilation Elevator Code";

        case "DeusExText.UCControlRoomPassword":
            return "UC Control Room Code";

        case "#var(package).RepairbotNearby":
            return "Repair Bot Nearby";

        case "#var(package).MedbotNearby":
            return "Medical Bot Nearby";

        case "#var(package).AugbotNearby":
            return "Augmentation Bot Nearby";

///////////////////////////////
//   GROUPS OF TEXT THINGS   //
///////////////////////////////


        case "DeusExText.01_Book01":
        case "DeusExText.01_Book02":
        case "DeusExText.01_Book03":
        case "DeusExText.01_Book04":
        case "DeusExText.01_Book05":
        case "DeusExText.01_Book06":
        case "DeusExText.01_Book07":
        case "DeusExText.01_Book08":
            return "UNATCO Handbook";

        case "DeusExText.01_Newspaper04":
            return "Midnight Sun: Ryan Allan";
        case "DeusExText.01_Newspaper06":
        case "DeusExText.01_Newspaper08":
        case "RevisionText.01_Newspaper08": //Corrects a few typos in original
        case "DeusExText.02_Newspaper06":
        case "DeusExText.03_Newspaper02":
        case "DeusExText.08_Newspaper01":
            return "Midnight Sun: Joe Greene";

        case "DeusExText.01_Datacube09":
            return "Janine's Bots: Medical Bot";
        case "DeusExText.03_Datacube11":
            return "Janine's Bots: Repair Bot";
        case "DeusExText.05_Datacube09":
            return "Janine's Bots: Peacebringer";
        case "DeusExText.06_Datacube26":  //Unused
            return "Janine's Bots: Spider Bot";

        case "DeusExText.01_Book10":
            return "Project Dibbuk: Overview";
        case "DeusExText.05_Book06":
        case "DeusExText.06_Book02":
            return "Project Dibbuk: Specifications and Operation";
        case "DeusExText.06_Book06":
            return "Project Dibbuk: Thoughts and Meditations";

        case "DeusExText.02_Newspaper03":
            return "Chinese Lunar Mine Operational"; //Lunar Mining
        case "DeusExText.03_Newspaper01":
            return "McMoran Slings Chinese Ore"; //Lunar Mining
        case "DeusExText.06_Newspaper02":
            return "Mass Driver Accident Kills Over 2,000"; //Lunar Mining

        case "DeusExText.02_Book10":
        case "DeusExText.04_Book10":  //Unused
            return "Chlorine and Water Treatment Report";

        case "DeusExText.02_Book06":
        case "DeusExText.04_Book06":
            return "Basic Firearm Safety Rules";

        case "DeusExText.02_Book09":
        case "DeusExText.04_Book09":  //Unused
            return "Nanotechnology for Stupid People";

        case "DeusExText.02_Book04":
        case "DeusExText.04_Book04":
            return "CIA Factbook 2050: Hong Kong";

        case "DeusExText.02_Book08":
        case "DeusExText.04_Book08":
            return "The Modern Terrorist's Handbook";

        case "DeusExText.02_Book07":
        case "DeusExText.04_Book07":
            return "The Reluctant Dictators";

        case "DeusExText.02_Book01":
        case "DeusExText.04_Book01":
            return "Vishnu's Fall";

        case "DeusExText.02_Book02":
        case "DeusExText.04_Book02":
            return "Hotel Register";

        case "DeusExText.06_Book04":
            return "Chinese Silver Loaves Recipe"; //Joy of Cooking
        case "DeusExText.10_Book06":
            return "Coq au Vin Recipe"; //Joy of Cooking

        case "DeusExText.11_Book04":
            return "The Red Cross: A History of the Knights Templar, Volume One";
        case "DeusExText.11_Book05":
            return "The Red Cross: A History of the Knights Templar, Volume Two";
        case "DeusExText.11_Book06":
            return "The Red Cross: A History of the Knights Templar, Volume Three";
        case "DeusExText.11_Book07":
            return "The Red Cross: A History of the Knights Templar, Volume Four";

        case "DeusExText.02_Book03":
        case "DeusExText.04_Book03":
            return "Jacob's Shadow: Chapter 12";
        case "DeusExText.03_Book04":
            return "Jacob's Shadow: Chapter 15";
        case "DeusExText.06_Book03":
            return "Jacob's Shadow: Chapter 20";
        case "DeusExText.09_Book02":
            return "Jacob's Shadow: Chapter 23";
        case "DeusExText.10_Book02":
            return "Jacob's Shadow: Chapter 27";
        case "DeusExText.12_Book01":
            return "Jacob's Shadow: Chapter 32";
        case "DeusExText.15_Book01":
            return "Jacob's Shadow: Chapter 34";

        case "DeusExText.02_Book05":
        case "DeusExText.03_Book05":
        case "DeusExText.04_Book05":
        case "DeusExText.10_Book03":
        case "DeusExText.12_Book02":
        case "DeusExText.14_Book04":
        case "DeusExText.15_Book02":
            return "The Man Who Was Thursday";

        case "DeusExText.15_Datacube01": //Entrance Sleep Pod Code
        case "DeusExText.SleepPodCode1":
        case "DeusExText.SleepPodCode2":
        case "DeusExText.SleepPodCode3":
            return "Sleeping Pod Code";

        case "DeusExText.15_Datacube02":
        case "DeusExText.15_Datacube03":
        case "DeusExText.15_Datacube04":
        case "DeusExText.15_Datacube05":
        case "DeusExText.CloneCube1":
        case "DeusExText.CloneCube2":
        case "DeusExText.CloneCube3":
        case "DeusExText.CloneCube4":
            return "Clone Data";

        case "DeusExText.01_Datacube07":
        case "DeusExText.02_Datacube08":
        case "DeusExText.02_Datacube13":
        case "DeusExText.04_Datacube03":
        case "#var(package).04_Datacube03":  //Modified version of above
        case "DeusExText.10_Datacube03":
        case "DeusExText.10_Datacube04":
        case "DeusExText.10_Datacube05":
        case "DeusExText.10_Datacube06":
        case "DeusExText.10_Datacube08":
        case "DeusExText.11_Book03":
        case "DeusExText.MarketATMPassword":
        case "DeusExText.QuickStopATMPassword":
        case "RevisionText.06_Datacube02":
            return "ATM Login";
    }

    //Prefix matches - These are probably all generated by us, so we don't need to worry about the text package
    i = InStr(texttag,"_");
    if (i!=-1){
        prefix = Left(texttag,i);
        switch(prefix){
            case "DXRMachinesRandoTurret": //Datacubes for added turrets (with a security computer)
                i = FindLast(texttag,"_");
                s1 = Mid(texttag,i+1); //Grab everything after the last _ (should be the computer name)
                return s1 $" Login";
            case "CrowdControlSpamCubes": //Spam datacubes from Crowd Control
                //These are meant to distract and fill up your notes, so don't hint they're anything...
                return "Note";
        }
    }

    //Didn't match anything!
    if (class'DXRVersion'.static.VersionIsStable()) {
        return "";
    } else {
        //Show the text package + text tag for non-stable versions
        return fullTag;
    }
}
