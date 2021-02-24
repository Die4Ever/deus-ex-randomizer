class DXRPasswords extends DXRActorsBase;

var transient DeusExNote lastCheckedNote;

var travel string oldpasswords[64];
var travel string newpasswords[64];
var travel int passStart;
var travel int passEnd;
var config float min_hack_adjust, max_hack_adjust;
var transient int updated;

function CheckConfig()
{
    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,8) ) {
        min_hack_adjust = 0.5;
        max_hack_adjust = 1.5;
    }
    Super.CheckConfig();
}

function Timer()
{
    local DeusExGoal goal;
    local DeusExNote note;
    local int i;

    Super.Timer();
    if( dxr == None ) return;

    goal = dxr.Player.FirstGoal;
    while( goal != None ) {
        for (i=0; i<ArrayCount(oldpasswords); i++)
        {
            if( oldpasswords[i] == "6282" )
                UpdateGoal(goal, oldpasswords[i], newpasswords[i]);
        }
        goal = goal.next;
    }

    note = dxr.Player.FirstNote;
    while( note != lastCheckedNote && note != None )
    {
        for (i=0; i<ArrayCount(oldpasswords); i++)
        {
            UpdateNote(note, oldpasswords[i], newpasswords[i]);
        }
        note = note.next;
    }
    lastCheckedNote = dxr.Player.FirstNote;
    NotifyPlayerNotesUpdated();
}

function ProcessString(out string str, optional out string updated_passwords[16])
{
    local int i, j;
    for(j=0; j<ArrayCount(updated_passwords); j++) {
        if( updated_passwords[j] == "" ) break;
    }
    for (i=0; i<ArrayCount(oldpasswords); i++)
    {
        if( UpdateString(str, oldpasswords[i], newpasswords[i]) ) {
            if( j >= ArrayCount(updated_passwords) ) {
                warning("ProcessString "$oldpasswords[i]$" to "$newpasswords[i]$", j >= ArrayCount(updated_passwords)");
                j=0;
            }
            updated_passwords[j++] = newpasswords[i];
        }
    }
}

function bool UpdateString(out string str, string oldpassword, string newpassword)
{
    if( oldpassword == "" ) return false;
    if( str == "") return false;
    if( WordInStr( Caps(str), Caps(oldpassword), Len(oldpassword), true ) == -1 ) return false;

    info("found string with password " $ oldpassword $ ", replacing with newpassword " $ newpassword);

    str = ReplaceText( str, oldpassword, " " $ newpassword $ " ", true );//spaces around the password make it so you can double click to highlight it then copy it easily
    return true;
}

function FirstEntry()
{
    Super.FirstEntry();

    lastCheckedNote = None;
    RandoPasswords(dxr.flags.passwordsrandomized);
    RandoInfoDevs(dxr.flags.infodevices);
    RandoHacks();
    MakeAllHackable(dxr.flags.deviceshackable);
}

function AnyEntry()
{
    Super.AnyEntry();

    lastCheckedNote = None;
    LogAll();
    SetTimer(1.0, True);
}

function RandoHacks()
{
    local HackableDevices h;

    SetSeed( "RandoHacks" );

    foreach AllActors(class'HackableDevices', h) {
        _RandoHackable(h);
    }
}

function _RandoHackable(HackableDevices h)
{
    if( h.bHackable ) {
        h.hackStrength = FClamp(rngrange(h.hackStrength, min_hack_adjust, max_hack_adjust), 0, 1);
    }
}

static function RandoHackable(DXRando dxr, HackableDevices h)
{
    local DXRPasswords m;
    m = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
    if( m != None ) {
        m._RandoHackable(h);
    }
}

function RandoPasswords(int mode)
{
    local Computers c;
    local Keypad k;
    local ATM a;
    local int i;

    if( mode == 0 ) return;

    foreach AllActors(class'Computers', c)
    {
        for (i=0; i<ArrayCount(c.userList); i++)
        {
            if (c.userList[i].password == "")
                continue;

            ChangeComputerPassword(c, i);
        }
    }

    foreach AllActors(class'Keypad', k)
    {
        ChangeKeypadPasscode(k);
    }

    foreach AllActors(class'ATM', a)
    {
        for (i=0; i<ArrayCount(a.userList); i++)
        {
            if(a.userList[i].PIN == "")
                continue;

            ChangeATMPIN(a, i);
        }
    }

    FixCodes();
}

function FixCodes()
{
    local string newpassword;
    if( dxr.localURL == "02_NYC_HOTEL" ) {
        newpassword = GeneratePasscode("4321");
        ReplacePassword("count back from 4", newpassword);
    }
    if( dxr.localURL == "15_AREA51_PAGE" ) {
        newpassword = GeneratePasscode("7243");
        ReplacePassword("724", Left(newpassword, 3) );
    }
}

function RandoInfoDevs(int percent)
{
    local InformationDevices id;
    local Inventory inv;
    local int i, num, slot;
    local int hasPass[64];
    local DeusExTextParser parser;

    //l("RandoInfoDevs percent == "$percent);
    if(percent == 0) return;

    foreach AllActors(class'InformationDevices', id)
    {
        if( rng(100) > percent ) continue;
        
        for(i=0; i<ArrayCount(hasPass); i++)
            hasPass[i]=0;
        
        if ( id.textTag != '' ) {
            parser = new(None) Class'DeusExTextParser';
            if( parser.OpenText(id.textTag, id.TextPackage) ) {
                ProcessText(parser, hasPass);
                parser.CloseText();
            }
            CriticalDelete(parser);
        }
        i=0;
        num=0;
        foreach AllActors(class'Inventory', inv)
        {
            if( SkipActor(inv, 'Inventory') ) continue;
            if( InfoPositionGood(id, inv.Location, hasPass) == False ) continue;
            num++;
        }

        l("datacube "$id$" got num "$num);
        slot=rng(num+1);//+1 for the vanilla location
        if(slot==0) {
            l("not swapping infodevice "$ActorToString(id));
            continue;
        }
        slot--;
        i=0;
        foreach AllActors(class'Inventory', inv)
        {
            if( SkipActor(inv, 'Inventory') ) continue;
            if( InfoPositionGood(id, inv.Location, hasPass) == False ) continue;

            if(i==slot) {
                l("swapping infodevice "$ActorToString(id)$" with "$inv);
                Swap(id, inv);
                break;
            }
            i++;
        }
    }
}

function MakeAllHackable(int deviceshackable)
{
    local HackableDevices h;

    if( deviceshackable <= 0 ) return;

    SetSeed( "MakeAllHackable" );

    foreach AllActors(class'HackableDevices', h)
    {
        if( h.bHackable == false && chance_single(deviceshackable) ) {
            l("found unhackable device: " $ ActorToString(h) $ ", tag: " $ h.Tag $ " in " $ dxr.localURL);
            h.bHackable = true;
            h.hackStrength = 1;
            h.initialhackStrength = 1;
        }
    }
}

function ChangeComputerPassword(Computers c, int i)
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

    //if( Len(oldpassword) <3 ) return;
    newpassword = GeneratePassword(dxr, oldpassword);
    c.userList[i].password = newpassword;
    ReplacePassword(oldpassword, newpassword);
}

function ChangeKeypadPasscode(Keypad k)
{
    local string oldpassword;
    local string newpassword;
    local int j;

    oldpassword = k.validCode;

    for (j=0; j<ArrayCount(oldpasswords); j++)
    {
        if( oldpassword == oldpasswords[j] ) {
            k.validCode = newpasswords[j];
            return;
        }
    }

    //if( Len(oldpassword) <3 ) return;
    newpassword = GeneratePasscode(oldpassword);
    k.validCode = newpassword;
    ReplacePassword(oldpassword, newpassword);
}

function ChangeATMPIN(ATM a, int i)
{
    local string oldpassword;
    local string newpassword;
    local int j;

    oldpassword = a.userList[i].PIN;

    for (j=0; j<ArrayCount(oldpasswords); j++)
    {
        if( oldpassword == oldpasswords[j] ) {
            a.userList[i].PIN = newpasswords[j];
            return;
        }
    }

    //if( Len(oldpassword) <3 ) return;
    newpassword = GeneratePasscode(oldpassword);
    a.userList[i].PIN = newpassword;
    ReplacePassword(oldpassword, newpassword);
}

function ReplacePassword(string oldpassword, string newpassword)
{ // do I even need passStart?
    local DeusExGoal goal;
    local DeusExNote note;

    oldpasswords[passEnd] = oldpassword;
    newpasswords[passEnd] = newpassword;
    passEnd = (passEnd+1) % ArrayCount(oldpasswords);
    if(passEnd == passStart) passStart = (passStart+1) % ArrayCount(oldpasswords);
    info("replaced password " $ oldpassword $ " with " $ newpassword $ ", passEnd is " $ passEnd $", passStart is " $ passStart);

    if( oldpassword == "6282" ) {
        goal = dxr.Player.FirstGoal;
        while( goal != None ) {
            UpdateGoal(goal, oldpassword, newpassword);
            goal = goal.next;
        }
    }

    note = dxr.Player.FirstNote;
    while( note != None )
    {
        UpdateNote(note, oldpassword, newpassword);
        note = note.next;
    }

    //NotifyPlayerNotesUpdated();
}

function NotifyPlayerNotesUpdated()
{
    if( updated == 1 )
        dxr.Player.ClientMessage("Note updated");
    else if( updated > 1 )
        dxr.Player.ClientMessage("Notes updated");
    updated = 0;
}

function bool UpdateGoal(DeusExGoal goal, string oldpassword, string newpassword)
{
    if( oldpassword == "" ) return false;
    if( goal.text == "") return false;
    if( goal.bCompleted ) return false;
    if( WordInStr( Caps(goal.text), Caps(oldpassword), Len(oldpassword), true ) == -1 ) return false;

    dxr.Player.ClientMessage("Goal updated");
    info("found goal with password " $ oldpassword $ ", replacing with newpassword " $ newpassword);

    goal.text = ReplaceText( goal.text, oldpassword, " " $ newpassword $ " ", true );//spaces around the password make it so you can double click to highlight it then copy it easily
    return true;
}

function bool UpdateNote(DeusExNote note, string oldpassword, string newpassword)
{
    if( oldpassword == "" ) return false;
    if( note.text == "") return false;
    if( WordInStr( Caps(note.text), Caps(oldpassword), Len(oldpassword), true ) == -1 ) return false;
    if( note.HasEitherPassword(oldpassword, newpassword) ) return false;

    updated++;
    info("found note with password " $ oldpassword $ ", replacing with newpassword " $ newpassword);

    note.text = ReplaceText( note.text, oldpassword, " " $ newpassword $ " ", true );//spaces around the password make it so you can double click to highlight it then copy it easily
    note.SetNewPassword(newpassword);
    return true;
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

static final function string ReplaceText(coerce string Text, coerce string Replace, coerce string With, optional bool word)
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

static final function int WordInStr(coerce string Text, coerce string Replace, int replace_len, optional bool word)
{
    local int i, e;
    i = InStr(Text, Replace);
    if(word==false || i==-1) return i;

    if(i>0) {
        if( IsAlphaNumeric(Text, i-1) ) {
            e = WordInStr(Mid(Text, i+1), Replace, replace_len, word);
            if( e <= 0 ) return -1;
            return i+1+e;
        }
    }
    e = i + replace_len;
    if( e < Len(Text) ) {
        if( IsAlphaNumeric(Text, e) ) {
            e = WordInStr(Mid(Text, i+1), Replace, replace_len, word);
            if( e <= 0 ) return -1;
            return i+1+e;
        }
    }
    return i;
}

static final function bool IsAlphaNumeric(coerce string Text, int index)
{
    local int c;
    c = Asc(Mid(Text, index, 1));
    if( c>=48 && c<=57) // 0-9
        return true;
    if( c>=65 && c<=90) // A-Z
        return true;
    if( c>=97 && c<=122) // a-z
        return true;
    return false;
}

function LogAll()
{
    local Computers c;
    local Keypad k;
    local ATM a;
    local int i;

    l("passEnd is " $ passEnd $", passStart is " $ passStart);

    foreach AllActors(class'Keypad', k)
    {
        l("found "$k$" with code: " $ k.validCode );
    }

    foreach AllActors(class'Computers', c)
    {
        for (i=0; i<ArrayCount(c.userList); i++)
        {
            if (c.userList[i].password == "")
                continue;

            l("found "$c$" username: "$c.userList[i].username$", password: " $ c.userList[i].password);
        }
    }

    foreach AllActors(class'ATM', a)
    {
        for( i=0; i<ArrayCount(a.userList); i++) {
            if (a.userList[i].PIN == "")
                continue;
            
            l("found "$a$" PIN: "$a.userList[i].PIN);
        }
    }
}

function ProcessText(DeusExTextParser parser, out int hasPass[64])
{
    local string text;
    local int i;
    local byte tag;

    while(parser.ProcessText()) {
        tag = parser.GetTag();
        if( tag != 0 ) continue;

        text = Caps(parser.GetText());
        if( Len(text) == 0 ) continue;

        for(i=0; i<passEnd; i++) {
            if( Len(oldpasswords[i]) == 0 ) continue;
            if( WordInStr( text, Caps(oldpasswords[i]), Len(oldpasswords[i]), true ) != -1 ) {
                hasPass[i] = 1;
                //l("hasPass["$i$"] = 1;");
            }
        }
    }
}

function bool CheckComputerPosition(InformationDevices id, Computers c, vector newpos, int hasPass[64])
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

function bool CheckKeypadPosition(InformationDevices id, Keypad k, vector newpos, int hasPass[64])
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

function bool InfoPositionGood(InformationDevices id, vector newpos, int hasPass[64])
{
    local Computers c;
    local Keypad k;
    local int a, i;

    if( VSize( id.Location - newpos ) > 5000 ) return False;

    if ( id.textTag == '' ) {
        //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning True, no textTag");
        return True;
    }

    a=0;
    for(i=0; i<passEnd; i++) {
        a+=hasPass[i];
    }
    if( a==0 ) {
        //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning True, hasPass is empty");
        return True;
    }// else l("InfoPositionGood("$ActorToString(id)$", "$newpos$") found hasPass "$a);

    foreach AllActors(class'Computers', c)
    {
        if( CheckComputerPosition(id, c, newpos, hasPass) == False ) {
            //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning False, found computer "$ActorToString(c));
            return False;
        }
    }
    foreach AllActors(class'Keypad', k)
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
    Super.RunTests();

    testint( WordInStr("THIS IS A TEST", "IS", 2 ), 2, "WordInStr match" );
    testint( WordInStr("THIS IS A TEST", "IS", 2, true ), 5, "WordInStr 2nd match" );
    testint( WordInStr("THISIS A TEST", "IS", 2, true ), -1, "WordInStr 2nd match not word" );
    testint( WordInStr("MJ12", "12", 2, true ), -1, "WordInStr not word" );
    testint( WordInStr("MJ 12", "12", 2, true ), 3, "WordInStr match at end" );

    teststring( ReplaceText("MJ12 12 12345", "12", "12345", true), "MJ12 12345 12345", "ReplaceText 1" );
    teststring( ReplaceText("MJ12 12 12345", "45", "12345", true), "MJ12 12 12345", "ReplaceText 2" );
}
