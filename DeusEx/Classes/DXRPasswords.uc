class DXRPasswords extends DXRActorsBase;

var transient DeusExNote lastCheckedNote;

var travel string oldpasswords[64];
var travel string newpasswords[64];
var travel int passStart;
var travel int passEnd;

function FirstEntry()
{
    Super.FirstEntry();

    lastCheckedNote = None;
    RandoPasswords(dxr.flags.passwordsrandomized);
    MakeAllHackable(dxr.flags.deviceshackable);
}

function AnyEntry()
{
    Super.AnyEntry();

    lastCheckedNote = None;
    LogAll();
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
}

function MakeAllHackable(int deviceshackable)
{
    local HackableDevices h;

    foreach AllActors(class'HackableDevices', h)
    {
        if( h.bHackable == false && deviceshackable > 0 ) {
            l("found unhackable device class: " $ ActorToString(h) $ ", tag: " $ h.Tag $ " in " $ dxr.localURL);
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
    newpassword = GeneratePassword(oldpassword);
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
    local DeusExNote note;

    oldpasswords[passEnd] = oldpassword;
    newpasswords[passEnd] = newpassword;
    //l("replaced password " $ oldpassword $ " with " $ newpassword $ ", passEnd was " $ passEnd $", passStart was " $ passStart);
    passEnd = (passEnd+1) % ArrayCount(oldpasswords);
    if(passEnd == passStart) passStart = (passStart+1) % ArrayCount(oldpasswords);
    //Player.ClientMessage("replaced password " $ oldpassword $ " with " $ newpassword);
    l("replaced password " $ oldpassword $ " with " $ newpassword $ ", passEnd is " $ passEnd $", passStart is " $ passStart);

    note = dxr.Player.FirstNote;

	while( note != None )
	{
        UpdateNote(note, oldpassword, newpassword);
		note = note.next;
	}
}

function Timer()
{
    local DeusExNote note;
    local int i;

    Super.Timer();
	note = dxr.Player.FirstNote;

    //l("Timer(), passEnd is " $ passEnd $", passStart is " $ passStart);

	while( note != lastCheckedNote && note != None )
	{
        for (i=0; i<ArrayCount(oldpasswords); i++)
        {
            UpdateNote(note, oldpasswords[i], newpasswords[i]);
        }
		note = note.next;
	}
    lastCheckedNote = dxr.Player.FirstNote;
}

function UpdateNote(DeusExNote note, string oldpassword, string newpassword)
{
    if( oldpassword == "" ) return;
    if( note.text == "") return;
    if( WordInStr( Caps(note.text), Caps(oldpassword), Len(oldpassword), true ) == -1 ) return;

    dxr.Player.ClientMessage("Note updated");
    l("found note with password " $ oldpassword $ ", replacing with newpassword " $ newpassword);

    note.text = ReplaceText( note.text, oldpassword, newpassword, true );
}

function string GeneratePassword(string oldpassword)
{
    local string out;
    local int i;
    local int c;
    dxr.SetSeed( dxr.seed + dxr.Crc(oldpassword) );
    for(i=0; i<5; i++) {
        // 0-9 is 48-57, 97-122 is a-z
        c = rng(36) + 48;
        if ( c > 57 ) c += 39;
        out = out $ Chr(c);
    }
    return out;
}

function string GeneratePasscode(string oldpasscode)
{
    dxr.SetSeed( dxr.seed + dxr.Crc(oldpasscode) );
    // a number from 1000 to 9999, easily avoids leading 0s
    return (rng(8999) + 1000) $ "";
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
    local int i;

    l("passEnd is " $ passEnd $", passStart is " $ passStart);

    foreach AllActors(class'Keypad', k)
    {
        l("found Keypad with code: " $ k.validCode );
    }

    foreach AllActors(class'Computers', c)
    {
        for (i=0; i<ArrayCount(c.userList); i++)
        {
            if (c.userList[i].password == "")
                continue;

            l("found computer password: " $ c.userList[i].password);
        }
    }
}

function int RunTests()
{
    local int results;
    results = Super.RunTests();

    results += testint( WordInStr("THIS IS A TEST", "IS", 2 ), 2, "WordInStr match" );
    results += testint( WordInStr("THIS IS A TEST", "IS", 2, true ), 5, "WordInStr 2nd match" );
    results += testint( WordInStr("THISIS A TEST", "IS", 2, true ), -1, "WordInStr 2nd match not word" );
    results += testint( WordInStr("MJ12", "12", 2, true ), -1, "WordInStr not word" );
    results += testint( WordInStr("MJ 12", "12", 2, true ), 3, "WordInStr match at end" );

    results += teststring( ReplaceText("MJ12 12 12345", "12", "12345", true), "MJ12 12345 12345", "ReplaceText 1" );
    results += teststring( ReplaceText("MJ12 12 12345", "45", "12345", true), "MJ12 12 12345", "ReplaceText 2" );

    return results;
}
