class DXRPasswords extends DXRActorsBase;

var transient DeusExNote lastCheckedNote;

var travel string oldpasswords[128];
var travel string newpasswords[128];
var travel int passStart;
var travel int passEnd;

function FirstEntry()
{
    Super.FirstEntry();

    RandoPasswords(dxr.flags.passwordsrandomized);
    MakeAllHackable(dxr.flags.deviceshackable);
}

function AnyEntry()
{
    Super.AnyEntry();

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

    if( Len(oldpassword) <3 ) return;
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

    if( Len(oldpassword) <3 ) return;
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

    if( Len(oldpassword) <3 ) return;
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
        if( InStr( Caps(note.text), Caps(oldpassword) ) != -1 )
        {
            UpdateNote(note, oldpassword, newpassword);
        }
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
    if( InStr( Caps(note.text), Caps(oldpassword) ) == -1 ) return;

    dxr.Player.ClientMessage("Note updated");
    l("found note with password " $ oldpassword $ ", replacing with newpassword " $ newpassword);

    note.text = ReplaceText( note.text, oldpassword, newpassword );
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

static final function string ReplaceText(coerce string Text, coerce string Replace, coerce string With)
{
    local int i;
    local string Output, capsReplace;

    capsReplace = Caps(Replace);
    
    i = InStr( Caps(Text), capsReplace );
    while (i != -1) {
        Output = Output $ Left(Text, i) $ With;
        Text = Mid(Text, i + Len(Replace)); 
        i = InStr( Caps(Text), capsReplace);
    }
    Output = Output $ Text;
    return Output;
}

function LogAll()
{
    local Computers c;
    local Keypad k;
    local int i;

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
