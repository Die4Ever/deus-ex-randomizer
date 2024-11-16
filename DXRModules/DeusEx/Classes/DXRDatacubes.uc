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

        datacubes_rules[i].item_name = '15_AREA51_BUNKER';
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
        //Intent is for it to be able to spawn anywhere from the sub bay up to and including the storage room, but not the locked one

        //Exclude Locked storage room
        datacubes_rules[i].item_name = '14_Datacube06';
        datacubes_rules[i].min_pos = vect(595,-170,-1627);
        datacubes_rules[i].max_pos = vect(970,333,-1467);
        datacubes_rules[i].allow = false;
        i++;

        //Between Sub Bay and door to Greasel Lab, top floor
        datacubes_rules[i].item_name = '14_Datacube06';
        datacubes_rules[i].min_pos = vect(491,-170,-1627);
        datacubes_rules[i].max_pos = vect(1786,814,-1468);
        datacubes_rules[i].allow = true;
        i++;

        //All floors of that main central building with the sub bay
        datacubes_rules[i].item_name = '14_Datacube06';
        datacubes_rules[i].min_pos = vect(-204,-218,-99999);
        datacubes_rules[i].max_pos = vect(491,814,99999);
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

        break;

    }
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

    foreach AllActors(class'#var(prefix)InformationDevices', id)
    {
        if(!id.bHidden && id.Mesh == class'#var(prefix)DataCube'.default.Mesh)
            GlowUp(id);
        if( id.bIsSecretGoal || !chance_single(percent) ) {
            if( ! id.bAddToVault ) { // Zero Rando books should add to vault too
                InfoDevsHasPass(id);
            }
            continue;
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
        if(TextTag ~= "#var(locdebug)") DebugMarkKeyPosition(inv.Location, id.textTag);
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
            if(TextTag ~= "#var(locdebug)") DebugMarkKeyPosition(c.Location, id.textTag);
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
            l("found unhackable device: " $ ActorToString(h) $ ", tag: " $ h.Tag $ " in " $ dxr.localURL);
            h.bHackable = true;
            h.hackStrength = rngrange(1, min_hack_adjust, max_hack_adjust);
            h.hackStrength = Clamp(h.hackStrength*100, 1, 100) / 100.0;
            h.initialhackStrength = h.hackStrength;
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

    i = GetSafeRule( datacubes_rules, TextTag, newpos);
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
