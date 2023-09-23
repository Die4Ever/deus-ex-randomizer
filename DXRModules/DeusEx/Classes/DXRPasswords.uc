class DXRPasswords extends DXRDatacubes;

function CheckConfig()
{
    local int i;
    if( ConfigOlderThan(2,3,4,3) ) {
        i=0;
        not_passwords[i++] = "dragon head";
        not_passwords[i++] = "security restriction";
        not_passwords[i++] = "security office";
        not_passwords[i++] = "security system";
        not_passwords[i++] = " of security";// TODO: reduce these, we can probably just blacklist the word security and then whitelist the actual passwords
        not_passwords[i++] = "SECURITY PERSON";
        not_passwords[i++] = "AUTHORIZED SECURITY";
        not_passwords[i++] = "SECURITY SHOULD";
        not_passwords[i++] = "SECURITY MEASURE";
        not_passwords[i++] = "SECURITY OFFICE";
        not_passwords[i++] = "SECURITY AGEN";
        not_passwords[i++] = "SECURITY CODE";
        not_passwords[i++] = "SECURITY PROTOCOL";
        not_passwords[i++] = "SECURITY VULN";
        not_passwords[i++] = "SECURITY GRID";
        not_passwords[i++] = "SECURITY LIAB";
        not_passwords[i++] = "SECURITY CONSOLE";
        not_passwords[i++] = "SECURITY UPGRADE";
        not_passwords[i++] = "network security";
        not_passwords[i++] = "security computer";
        not_passwords[i++] = "security keypad";
        not_passwords[i++] = "the security";
        not_passwords[i++] = "bypass security";
        not_passwords[i++] = "catacombs security";
        not_passwords[i++] = "security clearances";
        not_passwords[i++] = "security authorization";
        not_passwords[i++] = "security bulletin";
        not_passwords[i++] = "called security";
        not_passwords[i++] = "that security was";
        not_passwords[i++] = "most security";
        not_passwords[i++] = "automated security";
        not_passwords[i++] = "attention nightshift";
        not_passwords[i++] = "research wing";
        not_passwords[i++] = "nanotech research";
        not_passwords[i++] = "research team";
        not_passwords[i++] = "weapons research";
        not_passwords[i++] = "captain james";
        not_passwords[i++] = "captain keene";
        not_passwords[i++] = "captain Kang";
        not_passwords[i++] = "captain Zhao";
        not_passwords[i++] = "the captain";
        not_passwords[i++] = "Brooklyn Naval Shipyard";
        not_passwords[i++] = "Simons is no better";
        not_passwords[i++] = "Simons, FEMA";
        not_passwords[i++] = "Walton Simons";
        not_passwords[i++] = "SIMONS WENT";
        not_passwords[i++] = "REPORT TO SIMONS";
        not_passwords[i++] = "Bob Page";
        not_passwords[i++] = "MJ12 COMPROMISED INDIVIDUALS";
        not_passwords[i++] = "MJ12 tool";
        not_passwords[i++] = "MJ12 has the";
        not_passwords[i++] = "MJ12 network";
        not_passwords[i++] = "the MJ12";
        not_passwords[i++] = "Majestic 12";
        not_passwords[i++] = "12 hours";
        not_passwords[i++] = ":12";
        not_passwords[i++] = "4/12";
        not_passwords[i++] = "Chapter 12";
        not_passwords[i++] = "the Illuminati";
        not_passwords[i++] = "raptor-chickens";
        not_passwords[i++] = "of Illuminati";
        not_passwords[i++] = "Tiffany";// and then manually allow "password Tiffany" inside FixCodes()

        for(i=i;i<ArrayCount(not_passwords);i++) {
            not_passwords[i] = "";
        }

        i=0;
        yes_passwords[i].map = "12_VANDENBERG_COMPUTER";
        yes_passwords[i].password = "Tiffany";
        yes_passwords[i].search_for = "password Tiffany";
        i++;

        yes_passwords[i].map = "12_VANDENBERG_COMPUTER";
        yes_passwords[i].password = "Tiffany";
        yes_passwords[i].search_for = "password: Tiffany";
        i++;

        yes_passwords[i].map = "09_NYC_DOCKYARD";
        yes_passwords[i].password = "SIMONS";
        yes_passwords[i].search_for = "PASSWORD: SIMONS";
        i++;

        yes_passwords[i].map = "06_HONGKONG_WANCHAI_STREET";
        yes_passwords[i].password = "SECURITY";
        yes_passwords[i].search_for = "PASSWORD SECURITY";
        i++;

        yes_passwords[i].map = "06_HONGKONG_MJ12LAB";
        yes_passwords[i].password = "SECURITY";
        yes_passwords[i].search_for = "PASSWORD HAS BEEN RESET TO THE DEFAULT MJ12 AND SECURITY";
        i++;

        for(i=i;i<ArrayCount(yes_passwords);i++) {
            yes_passwords[i].map = "";
        }
    }
    num_not_passwords=0;
    for(i=0; i<ArrayCount(not_passwords); i++) {
        if(not_passwords[i] != "")
            not_passwords[num_not_passwords++] = Caps(not_passwords[i]);
    }
    for(i=num_not_passwords; i<ArrayCount(not_passwords); i++) {
        not_passwords[i] = "";
    }
    for(i=0; i<ArrayCount(yes_passwords); i++) {
        yes_passwords[i].map = Caps(yes_passwords[i].map);
    }
    Super.CheckConfig();

    // can't put escaped quotes inside config, so we need to add it after saving the config
    not_passwords[num_not_passwords++] = Caps("the \"Oceanguard\" login");

    for(i=0; i<ArrayCount(yes_passwords); i++) {
        if( yes_passwords[i].map != "" ) continue;
        yes_passwords[i].map = "09_NYC_DOCKYARD";
        yes_passwords[i].password = "SECURITY";
        yes_passwords[i].search_for = "PASSWORD IS \"SECURITY\"";
        break;
    }
}

function FirstEntry()
{
    if(dxr.flags.settings.passwordsrandomized != 0)
        FixCodes();// run this first so our manual logic takes precedence
    Super.FirstEntry();
}

function FixCodes()
{
    local string newpassword, replacement;
    local int i;

    for(i=0; i<ArrayCount(yes_passwords); i++) {
        if( yes_passwords[i].map != dxr.localURL ) continue;
        newpassword = GeneratePassword(dxr, yes_passwords[i].password);
        //replacement = ReplaceText(yes_passwords[i].search_for, yes_passwords[i].password, newpassword, false);
        ReplacePassword(yes_passwords[i].search_for, newpassword );
    }

    switch(dxr.localURL) {
        case "02_NYC_HOTEL":
        case "04_NYC_HOTEL":
        case "08_NYC_HOTEL":
            newpassword = GeneratePasscode("4321");
            ReplacePassword("count back from 4", newpassword);
            break;

        case "03_NYC_AIRFIELDHELIBASE":
            // 747 suspension crate
            newpassword = GeneratePasscode("9905");
            ReplacePassword("9905", newpassword);
            break;

        case "09_NYC_DOCKYARD":
            // Jenny
            newpassword = GeneratePasscode("867") $ GeneratePasscode("530") $ "9";
            ReplacePassword("8675309", newpassword);
            break;

        case "11_PARIS_UNDERGROUND":
            newpassword = GeneratePasscode("wyrdred08");
            ReplacePassword("wyrdred0", Left(newpassword, 8) );
            break;

        case "15_AREA51_PAGE":
            newpassword = GeneratePasscode("7243");
            ReplacePassword("724", Left(newpassword, 3) );
            break;
    }
}

function ChangeKeypadPasscode(#var(prefix)Keypad k, bool rando)
{
    if( k.validCode == "718" && rando ) {
        FixMaggieChowBday(k);
        return;
    }
    else
        Super.ChangeKeypadPasscode(k, rando);
}

function FixMaggieChowBday(#var(prefix)Keypad k)
{
    local string oldpassword, newpassword;
    local int month, day, i, oldseed;
    local string months[12];

    oldpassword = k.validCode;

    i=0;
    months[i++] = "January";
    months[i++] = "February";
    months[i++] = "March";
    months[i++] = "April";
    months[i++] = "May";
    months[i++] = "June";
    months[i++] = "July";
    months[i++] = "August";
    months[i++] = "September";
    months[i++] = "October";
    months[i++] = "November";
    months[i++] = "December";

    oldseed = SetGlobalSeed(oldpassword);//manually set the seed to avoid using the level name in the seed
    month = rng(12)+1;
    day = rng(28)+1;// HACK: too lazy to do the right number of days in each month
    dxr.SetSeed(oldseed);

    newpassword = string(month);
    if(day<10) newpassword = newpassword $ "0" $ day;
    else newpassword = newpassword $ day;
    ReplacePassword(oldpassword, newpassword);
    k.validCode = newpassword;

    newpassword = months[month-1] @ day;
    ReplacePassword("July 18th", newpassword);
}

function ExtendedTests()
{
    local bool bHasPass;
    local int oldPassStart, oldPassEnd;
    local string prevOldPassword, prevNewPassword;
#ifdef vanilla
    local DataCube d;
    d = spawn(class'DataCube',,, vect(-1549.046997, 5708.364746, -2569.889648));
#else
    local DXRInformationDevices d;
    d = spawn(class'DXRInformationDevices',,, vect(-1549.046997, 5708.364746, -2569.889648));
#endif

    Super.ExtendedTests();

    oldPassStart = passStart;
    oldPassEnd = passEnd;
    passStart = 0;
    passEnd = 1;
    prevOldPassword = oldpasswords[passStart];
    prevNewPassword = newpasswords[passStart];

    oldpasswords[passStart] = "DXRando";
    newpasswords[passStart] = "RANDOM";

    test(d != None, "spawned DataCube " $ d );
    d.TextTag = '12_DXRandoTest01';
    d.TextPackage = "#var(package)";

    bHasPass = InfoDevsHasPass(d);
    testbool(bHasPass, true, d $ " has password DXRando");

    oldpasswords[passStart] = "UNKNOWN";
    newpasswords[passStart] = "RANDOM";

    bHasPass = InfoDevsHasPass(d);
    testbool(bHasPass, false, d $ " doesn't have password UNKNOWN");

    oldpasswords[passStart] = prevOldPassword;
    newpasswords[passStart] = prevNewPassword;
    passStart = oldPassStart;
    passEnd = oldPassEnd;
}
