class DXRPasswords extends DXRDatacubes;

function CheckConfig()
{
    local int i;

    i=0;
    not_passwords[i++] = "dragon head";
    not_passwords[i++] = "security";// To reduce these, we can just blacklist the word security and then whitelist the actual passwords
    not_passwords[i++] = "attention nightshift";
    not_passwords[i++] = "research wing";
    not_passwords[i++] = "nanotech research";
    not_passwords[i++] = "research team";
    not_passwords[i++] = "weapons research";
    not_passwords[i++] = "research goals";
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
    not_passwords[i++] = "Simons has";
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
    not_passwords[i++] = "12%";
    not_passwords[i++] = ".12";
    not_passwords[i++] = "REPORT 12-Y";
    not_passwords[i++] = "LAB 12";
    not_passwords[i++] = "MChow//HKNET.974.12.8723";
    not_passwords[i++] = "login: MJ12";
    not_passwords[i++] = "MJ12 Cyberinformation";
    not_passwords[i++] = "MJ12 Chemical";
    not_passwords[i++] = "entity token \"MJ12\"";
    not_passwords[i++] = "MJ12 operations";
    not_passwords[i++] = "MJ12 Nano-Augmentation";
    not_passwords[i++] = "of MJ12";
    not_passwords[i++] = "default MJ12";
    not_passwords[i++] = "MJ12 PERSONNEL";
    not_passwords[i++] = "MJ12 H.K. HELIBASE";
    not_passwords[i++] = "MJ12 presence";
    not_passwords[i++] = "MJ12 helibase";
    not_passwords[i++] = "for \"MJ12\"";
    not_passwords[i++] = "and MJ12";
    not_passwords[i++] = "the Illuminati";
    not_passwords[i++] = "raptor-chickens";
    not_passwords[i++] = "of Illuminati";
    not_passwords[i++] = "Tiffany";// and then manually allow "password Tiffany" inside FixCodes()
    not_passwords[i++] = "little .22 pistol";
    not_passwords[i++] = "the MJ12-COL";
    not_passwords[i++] = "questions to MJ12 Simulations";
    not_passwords[i++] = "human target-practis";
    not_passwords[i++] = "research campus";
    not_passwords[i++] = "But tell Simons";
    not_passwords[i++] = "entity token \"MJ12\"";
    not_passwords[i++] = "Captain Hernandez";
    not_passwords[i++] = "information linking Simons";
    not_passwords[i++] = "Which Simons has a";
    not_passwords[i++] = "Brooklyn Bridge Station access is through";
    not_passwords[i++] = "Manhattan and Brooklyn";
    not_passwords[i++] = "Brooklyn Naval Yards";
    not_passwords[i++] = "Brooklyn Bridge Station";
    not_passwords[i++] = "from the Illuminati to the";
    not_passwords[i++] = "entity token \"Illuminati\"";
    not_passwords[i++] = "connected to the Illuminati";
    not_passwords[i++] = "the \"Oceanguard\" login";
    not_passwords[i++] = "UNATCO.4352.768"; //768 is the Level 2 Labs door seal code
    not_passwords[i++] = "USER NAME";
    not_passwords[i++] = "user permissions";
    not_passwords[i++] = "user access";


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

    //Fixups will cover these password replacements if balance changes are enabled
    //These ones are funny because we change the passwords to unique ones.
    if( !(class'MenuChoice_BalanceMaps'.static.ModerateEnabled() || class'MenuChoice_PasswordAutofill'.static.ShowKnownAccounts()) ){
        //QUEENSTOWER security computer password is updated with balance changes
        yes_passwords[i].map = "06_HONGKONG_WANCHAI_STREET";
        yes_passwords[i].search_for = "PASSWORD SECURITY";
        yes_passwords[i].password = "SECURITY";
        i++;

        //MJ12 security computer password is updated with balance changes
        yes_passwords[i].map = "06_HONGKONG_MJ12LAB";
        yes_passwords[i].search_for = "PASSWORD HAS BEEN RESET TO THE DEFAULT MJ12 AND SECURITY";
        yes_passwords[i].password = "SECURITY";
        i++;

        //USFEMA security computer password is updated with balance changes
        yes_passwords[i].map = "09_NYC_DOCKYARD";
        yes_passwords[i].search_for =  "PASSWORD IS \"SECURITY\"";
        yes_passwords[i].password = "SECURITY";
        i++;
    }

    for(i=i;i<ArrayCount(yes_passwords);i++) {
        yes_passwords[i].map = "";
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
}

function FirstEntry()
{
    if(dxr.flags.settings.passwordsrandomized != 0)
        FixCodes(dxr.flags.settings.passwordsrandomized);// run this first so our manual logic takes precedence
    Super.FirstEntry();
}

//Convert a word into the numbers you'd use on a phone to type that word out (a "Phoneword")
function string CalcPhoneWordNumbers(string phoneWord)
{
    local string phoneNumber;
    local int i;

    phoneWord = Caps(phoneWord); //Just to be safe

    for(i=0;i<Len(phoneWord);i++){
        switch(Mid(phoneWord,i,1)){
            case "A":
            case "B":
            case "C":
                phoneNumber = phoneNumber $ "2";
                break;
            case "D":
            case "E":
            case "F":
                phoneNumber = phoneNumber $ "3";
                break;
            case "G":
            case "H":
            case "I":
                phoneNumber = phoneNumber $ "4";
                break;
            case "J":
            case "K":
            case "L":
                phoneNumber = phoneNumber $ "5";
                break;
            case "M":
            case "N":
            case "O":
                phoneNumber = phoneNumber $ "6";
                break;
            case "P":
            case "Q":
            case "R":
            case "S":
                phoneNumber = phoneNumber $ "7";
                break;
            case "T":
            case "U":
            case "V":
                phoneNumber = phoneNumber $ "8";
                break;
            case "W":
            case "X":
            case "Y":
            case "Z":
                phoneNumber = phoneNumber $ "9";
                break;
        }
    }

    return phoneNumber;
}

//Add dashes between the letters of a word to make it look like it's being spelled out
function string SpellOutWord(string word)
{
    local string spelledWord;
    local int i;

    word = Caps(word); //Just to be safe

    for(i=0;i<Len(word);i++){
        spelledWord = spelledWord $ Mid(word,i,1);
        if ((i+1)<Len(word)){
            spelledWord = spelledWord $ "-";
        }
    }

    return spelledWord;
}

// Mole people phone booth Code: MOLE/6653
function FixMolePeoplePhoneboothCode()
{
    local string newpassword, newWord;
    local int numWords,oldseed;

    oldseed = SetGlobalSeed("MolePeoplePhoneBooth");//manually set the seed to avoid using the level name in the seed
    numWords = class'DXRRandomWordLists'.static.GetShortWordListLength();
    newWord = Caps(class'DXRRandomWordLists'.static.GetRandomShortWord(rng(numWords)));
    ReapplySeed(oldseed);

    newpassword = CalcPhoneWordNumbers(newWord);
    ReplacePassword("MOLE/6653",newWord$"/"$newpassword); //Don't want to replace any *other* uses of the word "MOLE"
    ReplacePassword("6653", newpassword);
    ReplacePassword("M-O-L-E",SpellOutWord(newWord));
}

function FixCodes(int mode)
{
    local string newpassword, replacement;
    local int i;

    for(i=0; i<ArrayCount(yes_passwords); i++) {
        if( yes_passwords[i].map != dxr.localURL ) continue;
        newpassword = GeneratePassword(yes_passwords[i].password,mode);
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

        case "03_NYC_BATTERYPARK":
            // Mole people phone booth Code: MOLE/6653
            FixMolePeoplePhoneboothCode();
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
            FixArea51BlueFusionReactorCodes();
            break;
    }
}

function FixArea51BlueFusionReactorCodes()
{
    local #var(injectsprefix)Keypad kp;

    foreach AllActors(class'#var(injectsprefix)Keypad', kp) {
        if(kp.validCode == "7243") {
            kp.Group = 'BFRKeypads';
            kp.bGrouped = true;
        }
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
    ReapplySeed(oldseed);

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
