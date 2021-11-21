class DXRPasswords extends DXRActorsBase;

var transient DeusExNote lastCheckedNote;
var config safe_rule datacubes_rules[32];

var int num_not_passwords;
var config string not_passwords[64];

struct YesPassword {
    var string map;
    var string password;
    var string search_for;
};
var config YesPassword yes_passwords[32];

var travel string oldpasswords[64];
var travel string newpasswords[64];
var travel int passStart;
var travel int passEnd;
var config float min_hack_adjust, max_hack_adjust;
var transient int updated;

replication
{
    reliable if( Role==ROLE_Authority )
        num_not_passwords, not_passwords, yes_passwords, oldpasswords, newpasswords, passStart, passEnd;
}

function CheckConfig()
{
    local int i;
    if( ConfigOlderThan(1,4,8,0) ) {
        min_hack_adjust = 0.5;
        max_hack_adjust = 1.5;
    }
    if( ConfigOlderThan(1,5,8,0) ) {
#ifndef revision
        i=0;

        // satcom password
        datacubes_rules[i].map = "01_NYC_UNATCOISLAND";
        datacubes_rules[i].item_name = '01_Datacube06';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // armory 0451 code
        datacubes_rules[i].map = "01_NYC_UNATCOISLAND";
        datacubes_rules[i].item_name = '01_Datacube03';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        // nsf001 smashthestate
        datacubes_rules[i].map = "01_NYC_UNATCOISLAND";
        datacubes_rules[i].item_name = '01_Datacube04';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].map = "04_NYC_NSFHQ";
        datacubes_rules[i].item_name = '04_Datacube01';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i] = datacubes_rules[i-1];
        datacubes_rules[i].item_name = '04_Datacube02';
        i++;

        datacubes_rules[i] = datacubes_rules[i-1];
        datacubes_rules[i].item_name = '04_Datacube02';
        i++;

        datacubes_rules[i].map = "05_NYC_UNATCOMJ12LAB";
        datacubes_rules[i].item_name = '05_Datacube01';// don't allow this in the locked cabinet
        datacubes_rules[i].min_pos = vect(-2235.248291, 1414.674072, -159.039658)-vect(8,8,8);
        datacubes_rules[i].max_pos = vect(-2235.248291, 1414.674072, -159.039658)+vect(8,8,8);
        datacubes_rules[i].allow = false;
        i++;

        // make sure you can get to the book without needing to jump down
        datacubes_rules[i].map = "10_PARIS_CATACOMBS";
        datacubes_rules[i].item_name = '10_Book09';
        datacubes_rules[i].min_pos = vect(-99999, -99999, 1956.809082); //top floor
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].map = "10_PARIS_CATACOMBS";
        datacubes_rules[i].item_name = '10_Book09';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999); //top floor
        datacubes_rules[i].max_pos = vect(99999, 99999, 1956.809082);
        datacubes_rules[i].allow = false;
        i++;

        // DataCube0 and 2
        datacubes_rules[i].map = "11_PARIS_CATHEDRAL";
        datacubes_rules[i].item_name = '11_Datacube03';
        datacubes_rules[i].min_pos = vect(-99999, -99999, 1956.809082); //top floor
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;

        datacubes_rules[i].map = "11_PARIS_CATHEDRAL";
        datacubes_rules[i].item_name = '11_Datacube03';// DataCube0 and 2 have the same textTag
        datacubes_rules[i].min_pos = vect(3587, -812, -487); //before gunther room
        datacubes_rules[i].max_pos = vect(4322, -124, 74);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].map = "11_PARIS_CATHEDRAL";
        datacubes_rules[i].item_name = '11_Datacube03';// 0 and 2
        datacubes_rules[i].min_pos = vect(3146, -1715, -85); //above before gunther room
        datacubes_rules[i].max_pos = vect(3907, -1224, 434);
        datacubes_rules[i].allow = false;
        i++;

        datacubes_rules[i].map = "11_PARIS_CATHEDRAL";
        datacubes_rules[i].item_name = '11_Datacube03';
        datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
        datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
        datacubes_rules[i].allow = true;
        i++;
#elseif revision
        i=0;
        // TODO: datacubes_rules for Revision
#endif

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
        not_passwords[i++] = "the Illuminati";
        not_passwords[i++] = "raptor-chickens";
        not_passwords[i++] = "of Illuminati";
        not_passwords[i++] = "Tiffany";// and then manually allow "password Tiffany" inside FixCodes()

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
    }
    for(i=0; i<ArrayCount(datacubes_rules); i++) {
        datacubes_rules[i].map = Caps(datacubes_rules[i].map);
    }
    num_not_passwords=0;
    for(i=0; i<ArrayCount(not_passwords); i++) {
        not_passwords[num_not_passwords++] = Caps(not_passwords[i]);
    }
    Super.CheckConfig();

    for(i=0; i<ArrayCount(yes_passwords); i++) {
        if( yes_passwords[i].map != "" ) continue;
        // can't put escaped quotes inside config, so we need to add it after saving the config
        yes_passwords[i].map = "09_NYC_DOCKYARD";
        yes_passwords[i].password = "SECURITY";
        yes_passwords[i].search_for = "PASSWORD IS \"SECURITY\"";
        break;
    }
}

simulated function Timer()
{
#ifdef hx
    if( Role == ROLE_Authority )
        UpdateGoalsAndNotes( HXGameInfo(Level.Game).Steve.FirstGoal, HXGameInfo(Level.Game).FirstNote );
    
    if( player(true) != None )
        UpdateGoalsAndNotes( None, player().FirstNote );
#else
    if( player(true) != None )
        UpdateGoalsAndNotes( player().FirstGoal, player().FirstNote );
#endif
}

#ifdef hx
simulated function UpdateGoalsAndNotes(HXGoal first_goal, DeusExNote first_note)
#else
simulated function UpdateGoalsAndNotes(DeusExGoal first_goal, DeusExNote first_note)
#endif
{
#ifdef hx
    local HXGoal goal, tgoal;
#else
    local DeusExGoal goal, tgoal;
#endif
    local DeusExNote note, tnote;
    local int i;

    goal = first_goal;
    while( goal != None ) {
        tgoal = goal.next;
        for (i=0; i<ArrayCount(oldpasswords); i++)
        {
            switch(oldpasswords[i]) {
                case "6282":
                case "archon":
                    UpdateGoal(goal, oldpasswords[i], newpasswords[i]);
            }
        }
        goal = tgoal;
    }

    note = first_note;
    while( note != lastCheckedNote && note != None )
    {
        tnote = note.next;
        for (i=0; i<ArrayCount(oldpasswords); i++)
        {
            UpdateNote(note, oldpasswords[i], newpasswords[i]);
        }
        note = tnote;
    }
    lastCheckedNote = first_note;
#ifndef hx
    NotifyPlayerNotesUpdated(player());
#endif
}


simulated function ProcessString(out string str, optional out string updated_passwords[16], optional bool conversation)
{
    local int i, j;
    for(j=0; j<ArrayCount(updated_passwords); j++) {
        if( updated_passwords[j] == "" ) break;
    }
    for (i=0; i<ArrayCount(oldpasswords); i++)
    {
        if( conversation && ( oldpasswords[i] == "SECURITY" || oldpasswords[i] == "TARGET" || oldpasswords[i] == "RESEARCH") ) {// HACK
            continue;
        }
        if( UpdateString(str, oldpasswords[i], newpasswords[i]) ) {
            if( j >= ArrayCount(updated_passwords) ) {
                warning("ProcessString "$oldpasswords[i]$" to "$newpasswords[i]$", j >= ArrayCount(updated_passwords)");
                j=0;
            }
            updated_passwords[j++] = newpasswords[i];
        }
    }
}

simulated function bool UpdateString(out string str, string oldpassword, string newpassword)
{
    if( oldpassword == "" ) return false;
    if( str == "") return false;
    if( PassInStr( str, oldpassword ) == -1 ) return false;

    info("found string with password " $ oldpassword $ ", replacing with newpassword " $ newpassword);
    //l(str);
    //l("---");

    str = ReplaceText( str, oldpassword, " " $ newpassword $ " ", true );//spaces around the password make it so you can double click to highlight it then copy it easily
        
    return true;
}

function FirstEntry()
{
    Super.FirstEntry();

    lastCheckedNote = None;
    RandoPasswords(dxr.flags.settings.passwordsrandomized);
    RandoInfoDevs(dxr.flags.settings.infodevices);
    RandoHacks();
    MakeAllHackable(dxr.flags.settings.deviceshackable);
}

function AnyEntry()
{
    local DataStorage ds;
    local ConSpeech c;
    Super.AnyEntry();

    LogAll();
#ifdef hx
    ds = class'DataStorage'.static.GetObj(dxr);
    ds.HXLoadNotes();
#endif
}

simulated function PlayerAnyEntry(#var PlayerPawn  p)
{
    local ConSpeech c;
    Super.PlayerAnyEntry(p);

    if( p == player() )
        lastCheckedNote = None;
    SetTimer(1.0, true);

    foreach AllObjects(class'ConSpeech', c) {
        ProcessString(c.speech,, true);
    }
}

function RandoHacks()
{
    local #var prefix HackableDevices h;

    SetSeed( "RandoHacks" );

    foreach AllActors(class'#var prefix HackableDevices', h) {
        _RandoHackable(h);
    }
}

function _RandoHackable(#var prefix HackableDevices h)
{
    if( h.bHackable ) {
        h.hackStrength = FClamp(rngrange(h.hackStrength, min_hack_adjust, max_hack_adjust), 0, 1);
        h.hackStrength = int(h.hackStrength*100)/100.0;
        h.initialhackStrength = h.hackStrength;
    }
}

static function RandoHackable(DXRando dxr, #var prefix HackableDevices h)
{
    local DXRPasswords m;
    m = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
    if( m != None ) {
        m._RandoHackable(h);
    }
}

function RandoPasswords(int mode)
{
    local #var prefix Computers c;
    local #var prefix Keypad k;
    local #var prefix ATM a;
    local int i;

    if( mode == 0 ) return;

    foreach AllActors(class'#var prefix Computers', c)
    {
        for (i=0; i<ArrayCount(c.userList); i++)
        {
            if (c.userList[i].password == "")
                continue;

            ChangeComputerPassword(c, i);
        }
    }

    foreach AllActors(class'#var prefix Keypad', k)
    {
        ChangeKeypadPasscode(k);
    }

    foreach AllActors(class'#var prefix ATM', a)
    {
#ifdef hx
        for (i=0; i<ArrayCount(a.ATMUserList); i++)
        {
            if(a.ATMUserList[i].PIN == "")
                continue;

            ChangeATMPIN(a, i);
        }
#else
        for (i=0; i<ArrayCount(a.userList); i++)
        {
            if(a.userList[i].PIN == "")
                continue;

            ChangeATMPIN(a, i);
        }
#endif
    }

    FixCodes();
}

function FixCodes()
{
    local string newpassword, replacement;
    local int i;

    for(i=0; i<ArrayCount(yes_passwords); i++) {
        if( yes_passwords[i].map != dxr.localURL ) continue;
        newpassword = GeneratePassword(dxr, yes_passwords[i].password);
        replacement = ReplaceText(yes_passwords[i].search_for, yes_passwords[i].password, newpassword, true);
        ReplacePassword(yes_passwords[i].search_for, replacement );
    }

    switch(dxr.localURL) {
        case "02_NYC_HOTEL":
            newpassword = GeneratePasscode("4321");
            ReplacePassword("count back from 4", newpassword);
            break;
        
        case "15_AREA51_PAGE":
            newpassword = GeneratePasscode("7243");
            ReplacePassword("724", Left(newpassword, 3) );
            break;
    }
}

function FixMaggieChowBday(#var prefix Keypad k)
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

    oldseed = dxr.SetSeed( dxr.seed + dxr.Crc(oldpassword) );//manually set the seed to avoid using the level name in the seed
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

simulated function bool InfoDevsHasPass(#var prefix InformationDevices id, optional out int hasPass[64], optional out int numHasPass)
{
    local DeusExTextParser parser;
    local int i;

    numHasPass=0;
    for(i=0; i<ArrayCount(hasPass); i++)
        hasPass[i]=0;
    
    if ( id.textTag != '' ) {
        parser = new(None) Class'DeusExTextParser';
        if( parser.OpenText(id.textTag, id.TextPackage) ) {
            ProcessText(parser, hasPass, numHasPass);
            parser.CloseText();
        }
        CriticalDelete(parser);
    }

#ifdef injections
    if( id.plaintext != "" ) {
        ProcessStringHasPass(id.plaintext, hasPass, numHasPass);
    }
#endif

    if( numHasPass > 0 )
        id.bAddToVault = true;
    
    return numHasPass > 0;
}

function RandoInfoDevs(int percent)
{
    local #var prefix InformationDevices id;
    local Inventory inv;
    local Actor temp[1024];
    local int num, slot, numHasPass;
    local int hasPass[64];

    if(percent == 0) return;

    foreach AllActors(class'#var prefix InformationDevices', id)
    {
        if( rng(100) > percent ) continue;

        InfoDevsHasPass(id, hasPass, numHasPass);

        num=0;
        foreach AllActors(class'Inventory', inv)
        {
            if( SkipActor(inv, 'Inventory') ) continue;
            if( InfoPositionGood(id, inv.Location, hasPass, numHasPass) == False ) continue;
            temp[num++] = inv;
        }
        /*foreach AllActors(class'Containers', c)
        {
            if( SkipActor(c, 'Containers') ) continue;
            if( InfoPositionGood(id, c.Location, hasPass) == False ) continue;
            temp[num++] = c;
        }*/

        l("datacube "$id$" got num "$num);
        slot=rng(num+1);//+1 for the vanilla location
        if(slot==0) {
            l("not swapping infodevice "$ActorToString(id));
            continue;
        }
        slot--;
        l("swapping infodevice "$ActorToString(id)$" with "$temp[slot]);
        // Swap argument A is more lenient with collision than argument B
        Swap(temp[slot], id);
    }
}

function MakeAllHackable(int deviceshackable)
{
    local #var prefix HackableDevices h;

    if( deviceshackable <= 0 ) return;

    SetSeed( "MakeAllHackable" );

    foreach AllActors(class'#var prefix HackableDevices', h)
    {
        if( h.bHackable == false && chance_single(deviceshackable) ) {
            l("found unhackable device: " $ ActorToString(h) $ ", tag: " $ h.Tag $ " in " $ dxr.localURL);
            h.bHackable = true;
            h.hackStrength = FClamp(rngrange(1, min_hack_adjust, max_hack_adjust), 0, 1);
            h.hackStrength = int(h.hackStrength*100)/100.0;
            h.initialhackStrength = h.hackStrength;
        }
    }
}

function ChangeComputerPassword(#var prefix Computers c, int i)
{
    local string oldpassword;
    local string newpassword;
    local int j;

    oldpassword = c.userList[i].password;

    for (j=0; j<ArrayCount(oldpasswords); j++)
    {
        if( oldpassword == oldpasswords[j] ) {
            c.userList[i].password = newpasswords[j];
            return;
        }
    }

    if( Len(oldpassword) < 2 ) return;
    newpassword = GeneratePassword(dxr, oldpassword);
    c.userList[i].password = newpassword;
    ReplacePassword(oldpassword, newpassword);
}

function ChangeKeypadPasscode(#var prefix Keypad k)
{
    local string oldpassword;
    local string newpassword;
    local int j;

    if( k.validCode == "718" ) {
        FixMaggieChowBday(k);
        return;
    }

    oldpassword = k.validCode;

    for (j=0; j<ArrayCount(oldpasswords); j++)
    {
        if( oldpassword == oldpasswords[j] ) {
            k.validCode = newpasswords[j];
            return;
        }
    }

    if( Len(oldpassword) < 2 ) return;
    newpassword = GeneratePasscode(oldpassword);
    k.validCode = newpassword;
    ReplacePassword(oldpassword, newpassword);
}

function ChangeATMPIN(#var prefix ATM a, int i)
{
    local string oldpassword;
    local string newpassword;
    local int j;

#ifdef hx
    oldpassword = a.ATMUserList[i].PIN;
#else
    oldpassword = a.userList[i].PIN;
#endif

    for (j=0; j<ArrayCount(oldpasswords); j++)
    {
        if( oldpassword == oldpasswords[j] ) {
#ifdef hx
            a.ATMUserList[i].PIN = newpasswords[j];
#else
            a.userList[i].PIN = newpasswords[j];
#endif
            return;
        }
    }

    if( Len(oldpassword) < 2 ) return;
    newpassword = GeneratePasscode(oldpassword);
#ifdef hx
    a.ATMUserList[i].PIN = newpassword;
#else
    a.userList[i].PIN = newpassword;
#endif
    ReplacePassword(oldpassword, newpassword);
}

function ReplacePassword(string oldpassword, string newpassword)
{ // do I even need passStart?
#ifndef hx
    local #var PlayerPawn  p;
#endif

    oldpasswords[passEnd] = oldpassword;
    newpasswords[passEnd] = newpassword;
    passEnd = (passEnd+1) % ArrayCount(oldpasswords);
    if(passEnd == passStart) passStart = (passStart+1) % ArrayCount(oldpasswords);
    info("replaced password " $ oldpassword $ " with " $ newpassword $ ", passEnd is " $ passEnd $", passStart is " $ passStart);

    if( oldpassword == "6282" ) {
        // we only update the code 6282 because it's rare for passwords to be in goals
#ifdef hx
        UpdateAllGoals(HXGameInfo(Level.Game).Steve.FirstGoal, oldpassword, newpassword);
#else
        foreach AllActors(class'#var PlayerPawn ', p) {
            UpdateAllGoals(p.FirstGoal, oldpassword, newpassword);
        }
#endif
    }

#ifdef hx
    UpdateAllNotes(HXGameInfo(Level.Game).FirstNote, oldpassword, newpassword);
#else
    foreach AllActors(class'#var PlayerPawn ', p) {
        UpdateAllNotes(p.FirstNote, oldpassword, newpassword);
    }
#endif
}

simulated function NotifyPlayerNotesUpdated(#var PlayerPawn  p)
{
    if( updated == 1 ) {
        p.ClientMessage("Note updated with randomized password");
        DeusExRootWindow(p.rootWindow).hud.msgLog.PlayLogSound(Sound'LogNoteAdded');
    }
    else if( updated > 1 ) {
        p.ClientMessage("Notes updated with randomized passwords");
        DeusExRootWindow(p.rootWindow).hud.msgLog.PlayLogSound(Sound'LogNoteAdded');
    }
    updated = 0;
}

function MarkPasswordKnown(string password)
{
#ifdef injections
    local #var prefix Keypad k;
    local #var prefix Computers c;
    local #var prefix ATM a;
       
    //Check computer logins
    foreach AllActors(class '#var prefix Computers',c)
    {
        c.SetAccountKnownByPassword(password);
    }

    foreach AllActors(class '#var prefix ATM',a)
    {
        a.SetAccountKnownByPassword(password);
    } 
 
    //Check keypad logins
    foreach AllActors(class '#var prefix Keypad',k)
    {
        if (password == k.validCode) {
            k.bCodeKnown = True;
        }
    }
#endif
}

#ifdef hx
simulated function bool UpdateAllGoals(HXGoal goal, string oldpassword, string newpassword)
{
    local HXGoal tgoal;
#else
simulated function bool UpdateAllGoals(DeusExGoal goal, string oldpassword, string newpassword)
{
    local DeusExGoal tgoal;
#endif
    while( goal != None ) {
        tgoal = goal.next;
        UpdateGoal(goal, oldpassword, newpassword);
        goal = tgoal;
    }
}

#ifdef hx
simulated function bool UpdateGoal(HXGoal goal, string oldpassword, string newpassword)
{
    local HXPlayerPawn p;
#else
simulated function bool UpdateGoal(DeusExGoal goal, string oldpassword, string newpassword)
{
#endif
    if( oldpassword == "" ) return false;
    if( goal.text == "") return false;
    if( goal.bCompleted ) return false;
    if( PassInStr( goal.text, oldpassword ) == -1 ) return false;

#ifndef hx
    player().ClientMessage("Goal updated with randomized password");
    DeusExRootWindow(player().rootWindow).hud.msgLog.PlayLogSound(Sound'LogGoalAdded');
#endif
    
    info("found goal with password " $ oldpassword $ ", replacing with newpassword " $ newpassword);
    
    goal.text = ReplaceText( goal.text, oldpassword, " " $ newpassword $ " ", true );//spaces around the password make it so you can double click to highlight it then copy it easily
    
#ifdef hx
    HXGameInfo(Level.Game).AddNote(goal.text, false, true, '');
#endif

    MarkPasswordKnown(newpassword);
    
    return true;
}

simulated function bool UpdateAllNotes(DeusExNote note, string oldpassword, string newpassword)
{
    local DeusExNote tnote;
    while( note != None )
    {
        tnote = note.next;
        UpdateNote(note, oldpassword, newpassword);
        note = tnote;
    }
}

simulated function bool UpdateNote(DeusExNote note, string oldpassword, string newpassword)
{
#ifdef hx
    local HXPlayerPawn p;
#endif

    if( oldpassword == "" ) return false;
    if( note.bUserNote && player().CombatDifficulty > 0 ) return false;
    if( note.text == "") return false;

#ifdef injections
    if( note.HasPassword(newpassword))
    {
        MarkPasswordKnown(newpassword);
    }

    if( note.HasEitherPassword(oldpassword, newpassword) ) return false;
#endif
    if( PassInStr( note.text, oldpassword ) == -1 ) return false;
    
    updated++;
    info("found note with password " $ oldpassword $ ", replacing with newpassword " $ newpassword);

    note.text = ReplaceText( note.text, oldpassword, " " $ newpassword $ " ", true );//spaces around the password make it so you can double click to highlight it then copy it easily
#ifdef injections
    note.SetNewPassword(newpassword);
#endif
#ifdef hx
    HXUpdateNote(note.textTag, note.text, "");
#endif
    
    MarkPasswordKnown(newpassword);
    
    return true;
}

simulated function HXUpdateNote(Name textTag, string newText, string TextPackage)
{
    local DeusExNote note;
    l("HXUpdateNote, player(): "$player()$", textTag: "$textTag$", newText: "$newText$", TextPackage: "$TextPackage);
#ifdef hx
    note = HXGameInfo(Level.Game).GetNote(textTag);
    if( note == None ) {
        HXGameInfo(Level.Game).AddNote(newText, false, true, textTag);
    }
    else
        note.text = newText;
#endif
    // I don't think Revision needs this function at all
#ifdef revision
    note = player().GetNote(textTag, TextPackage);
#else
    note = player().GetNote(textTag);
#endif
    if( note != None )
        note.text = newText;
}

static function string GeneratePassword(DXRando dxr, string oldpassword)
{
    local string out;
    local int i;
    local int c;
    local int oldseed;
    oldseed = dxr.SetSeed( dxr.seed + dxr.Crc(oldpassword) );
    for(i=0; i<5; i++) {
        // 0-9 is 48-57, 97-122 is a-z
        c = staticrng(dxr, 36) + 48;
        if ( c > 57 ) c += 39;
        out = out $ Chr(c);
    }
    dxr.SetSeed(oldseed);
    return out;
}

function string GeneratePasscode(string oldpasscode)
{
    local string newpasscode;
    local int maximum;
    local int oldpasslength;
    local int i;
    local int oldseed;

    oldpasslength = Len(oldpasscode);
    maximum = 1;
    //rng does a modulo based on the maximum, so it needs to be one larger than what we actually want
    //10 for single digit gives 1-9, 100 for double gives 1-99, etc...
    for(i=0;i<oldpasslength;i++) {
        maximum = maximum * 10;
    }    
    
    oldseed = dxr.SetSeed( dxr.seed + dxr.Crc(oldpasscode) );//manually set the seed to avoid using the level name in the seed
    newpasscode = rng(maximum) $ "";
    dxr.SetSeed(oldseed);

    //If the new passcode is shorter than the old one, we need to add some leading zeroes until it matches
    while (Len(newpasscode) < oldpasslength) {
        newpasscode = "0" $ newpasscode;
    }
    return newpasscode;
}

simulated final function int PassInStr(string text, string oldpassword)
{
    local string capsPass, capsText, capsNot;
    local int lenPass, i, n, k, offset;
    local bool found;

    capsText = Caps(text);
    capsPass = Caps(oldpassword);
    lenPass = Len(oldpassword);

    i = WordInStr( capsText, capsPass, lenPass, true );
    while (i != -1) {
        found = false;
        for(n=0; n<num_not_passwords; n++) {
            capsNot = Caps(not_passwords[n]);
            offset = InStr(capsNot, capsPass);
            if( offset == -1 ) continue;

            k = InStr(capsText, capsNot);
            if( k == i-offset ) {
                found = true;
                break;
            }
        }
        if( !found ) return i;
        capsText = Mid(capsText, i + lenPass); 
        i = WordInStr( capsText, capsPass, lenPass, true );
    }

    return -1;
}

simulated static final function string ReplaceText(coerce string Text, coerce string Replace, coerce string With, optional bool word)
{
    local int i, replace_len;
    local string Output, capsReplace;

    replace_len = Len(Replace);
    capsReplace = Caps(Replace);
    
    i = WordInStr( Caps(Text), capsReplace, replace_len, word );
    while (i != -1) {
        Output = Output $ Left(Text, i) $ With;
        Text = Mid(Text, i + replace_len); 
        i = WordInStr( Caps(Text), capsReplace, replace_len, word);
    }
    Output = Output $ Text;
    return Output;
}

simulated static final function int WordInStr(coerce string Text, coerce string Replace, int replace_len, optional bool word)
{
    local int i, e;
    i = InStr(Text, Replace);
    if(word==false || i==-1) return i;

    if(i>0) {
        if( IsWordChar(Text, i-1) ) {
            e = WordInStr(Mid(Text, i+1), Replace, replace_len, word);
            if( e <= 0 ) return -1;
            return i+1+e;
        }
    }
    e = i + replace_len;
    if( e < Len(Text) ) {
        if( IsWordChar(Text, e) ) {
            e = WordInStr(Mid(Text, i+1), Replace, replace_len, word);
            if( e <= 0 ) return -1;
            return i+1+e;
        }
    }
    return i;
}

simulated static final function bool IsWordChar(coerce string Text, int index)
{
    local int c;
    c = Asc(Mid(Text, index, 1));
    if( c>=48 && c<=57) // 0-9
        return true;
    if( c>=65 && c<=90) // A-Z
        return true;
    if( c>=97 && c<=122) // a-z
        return true;
    if( c == 39 ) // apostrophe
        return true;
    return false;
}

simulated function LogAll()
{
    local #var prefix Computers c;
    local #var prefix Keypad k;
    local #var prefix ATM a;
    local int i;

    l("passEnd is " $ passEnd $", passStart is " $ passStart);

    foreach AllActors(class'#var prefix Keypad', k)
    {
        l("found "$k$" with code: " $ k.validCode );
    }

    foreach AllActors(class'#var prefix Computers', c)
    {
        for (i=0; i<ArrayCount(c.userList); i++)
        {
            if (c.userList[i].password == "")
                continue;

            l("found "$c$" username: "$c.userList[i].username$", password: " $ c.userList[i].password);
        }
    }

    foreach AllActors(class'#var prefix ATM', a)
    {
#ifdef hx
        for( i=0; i<ArrayCount(a.ATMUserList); i++) {
            if (a.ATMUserList[i].PIN == "")
                continue;
            
            l("found "$a$" PIN: "$a.ATMUserList[i].PIN);
        }
    }
#else
        for( i=0; i<ArrayCount(a.userList); i++) {
            if (a.userList[i].PIN == "")
                continue;
            
            l("found "$a$" PIN: "$a.userList[i].PIN);
        }
    }
#endif
}

simulated function ProcessText(DeusExTextParser parser, out int hasPass[64], out int numHasPass)
{
    local string text;
    local int i;
    local byte tag;

    while(parser.ProcessText()) {
        tag = parser.GetTag();
        if( tag != 0 ) continue;

        text = Caps(parser.GetText());
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

function bool CheckComputerPosition(#var prefix InformationDevices id, #var prefix Computers c, vector newpos, int hasPass[64])
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

function bool CheckKeypadPosition(#var prefix InformationDevices id, #var prefix Keypad k, vector newpos, int hasPass[64])
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

function bool InfoPositionGood(#var prefix InformationDevices id, vector newpos, int hasPass[64], int numHasPass)
{
    local #var prefix Computers c;
    local #var prefix Keypad k;
    local int i;

    i = GetSafeRule( datacubes_rules, id.textTag, newpos);
    if( i != -1 ) return datacubes_rules[i].allow;

    if( VSize( id.Location - newpos ) > 5000 ) return False;

    if ( id.textTag == '' ) {
        //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning True, no textTag");
        return True;
    }

    if( numHasPass==0 ) {
        //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning True, hasPass is empty");
        return True;
    }// else l("InfoPositionGood("$ActorToString(id)$", "$newpos$") found hasPass "$a);

    foreach AllActors(class'#var prefix Computers', c)
    {
        if( CheckComputerPosition(id, c, newpos, hasPass) == False ) {
            //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning False, found computer "$ActorToString(c));
            return False;
        }
    }
    foreach AllActors(class'#var prefix Keypad', k)
    {
        if( CheckKeypadPosition(id, k, newpos, hasPass) == False ) {
            //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning False, found keypad "$ActorToString(k));
            return False;
        }
    }
    //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning True");
    return True;
}

function RunTests()
{
    local int old_num_not_passwords;
    local string oldnot;
    Super.RunTests();

    testint( WordInStr("THIS IS A TEST", "IS", 2 ), 2, "WordInStr match" );
    testint( WordInStr("THIS IS A TEST", "IS", 2, true ), 5, "WordInStr 2nd match" );
    testint( WordInStr("THISIS A TEST", "IS", 2, true ), -1, "WordInStr 2nd match not word" );
    testint( WordInStr("MJ12", "12", 2, true ), -1, "WordInStr not word" );
    testint( WordInStr("MJ 12", "12", 2, true ), 3, "WordInStr match at end" );

    teststring( ReplaceText("MJ12 12 12345", "12", "12345", true), "MJ12 12345 12345", "ReplaceText 1" );
    teststring( ReplaceText("MJ12 12 12345", "45", "12345", true), "MJ12 12 12345", "ReplaceText 2" );
    teststring( ReplaceText("dragon's dragon", "dragon", "test", true), "dragon's test", "ReplaceText 3 apostrophe" );

    oldnot = not_passwords[0];
    not_passwords[0] = "CAPTAIN ZHAO";
    old_num_not_passwords = num_not_passwords;
    num_not_passwords = 1;

    testint( PassInStr("hello captain zhao", "captain"), -1, "not password 1");
    testint( PassInStr("hello captain zhao", "zhao"), -1, "not password 2");
    testint( PassInStr("hello captain zhao", "hello"), 0, "yes password 1");
    testint( PassInStr("password is captain", "captain"), 12, "yes password 2");

    not_passwords[0] = oldnot;
    num_not_passwords = old_num_not_passwords;
}
