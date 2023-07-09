class DXRPasswordsBase extends DXRActorsBase abstract;

var transient DeusExNote lastCheckedNote;

var int num_not_passwords;
var config string not_passwords[100];

struct YesPassword {
    var string map;
    var string password;
    var string search_for;
};
var config YesPassword yes_passwords[64];

var travel string oldpasswords[100];
var travel string newpasswords[100];
var travel int passStart;
var travel int passEnd;
var transient int updated;

replication
{
    reliable if( Role==ROLE_Authority )
        num_not_passwords, not_passwords, yes_passwords, oldpasswords, newpasswords, passStart, passEnd;
}

simulated function Timer()
{
    if(dxr == None)
        return;
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

    if(oldpassword == newpassword)
        return false;

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

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    local ConSpeech c;
    local ConEventAddNote cn;
    Super.PlayerAnyEntry(p);

    if( p == player() )
        lastCheckedNote = None;
    SetTimer(1.0, true);

    foreach AllObjects(class'ConSpeech', c) {
        ProcessString(c.speech,, true);
    }
    // TODO: this doesn't work right cause then the password doesn't get replaced when it gets added which means it never gets marked as "known" for the autofill
    /*foreach AllObjects(class'ConEventAddNote', cn) {
        ProcessString(cn.noteText,, true);
    }*/
}

function RandoPasswords(int mode)
{
    local #var(prefix)Computers c;
    local #var(prefix)Keypad k;
    local #var(prefix)ATM a;
    local int i;
    local bool rando;

    if( mode == 0 ) rando = false;
    else rando = true;

    foreach AllActors(class'#var(prefix)Computers', c)
    {
        for (i=0; i<ArrayCount(c.userList); i++)
        {
            ChangeComputerPassword(c, i, rando);
        }
    }

    foreach AllActors(class'#var(prefix)Keypad', k)
    {
        ChangeKeypadPasscode(k, rando);
    }

    foreach AllActors(class'#var(prefix)ATM', a)
    {
#ifdef hx
        for (i=0; i<ArrayCount(a.ATMUserList); i++)
#else
        for (i=0; i<ArrayCount(a.userList); i++)
#endif
        {
            ChangeATMPIN(a, i, rando);
        }
    }
}

function ChangeComputerPassword(#var(prefix)Computers c, int i, bool rando)
{
    local string oldpassword;
    local string newpassword;
    local int j;

    oldpassword = c.userList[i].password;
    if(oldpassword == "") return;

    for (j=0; j<ArrayCount(oldpasswords); j++)
    {
        if( oldpassword == oldpasswords[j] ) {
            c.userList[i].password = newpasswords[j];
            return;
        }
    }

    if( Len(oldpassword) < 2 ) return;
    if(rando)
        newpassword = GeneratePassword(dxr, oldpassword);
    else
        newpassword = oldpassword;
    c.userList[i].password = newpassword;
    ReplacePassword(oldpassword, newpassword);
}

function ChangeKeypadPasscode(#var(prefix)Keypad k, bool rando)
{
    local string oldpassword;
    local string newpassword;
    local int j;

    oldpassword = k.validCode;
    if(oldpassword == "") return;

    for (j=0; j<ArrayCount(oldpasswords); j++)
    {
        if( oldpassword == oldpasswords[j] ) {
            k.validCode = newpasswords[j];
            return;
        }
    }

    if( Len(oldpassword) < 2 ) return;
    if(rando)
        newpassword = GeneratePasscode(oldpassword);
    else
        newpassword = oldpassword;
    k.validCode = newpassword;
    ReplacePassword(oldpassword, newpassword);
}

function ChangeATMPIN(#var(prefix)ATM a, int i, bool rando)
{
    local string oldpassword;
    local string newpassword;
    local int j;

#ifdef hx
    oldpassword = a.ATMUserList[i].PIN;
#else
    oldpassword = a.userList[i].PIN;
#endif

    if(oldpassword == "") return;

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
    if(rando)
        newpassword = GeneratePasscode(oldpassword);
    else
        newpassword = oldpassword;

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
    local #var(PlayerPawn) p;
#endif

    oldpasswords[passEnd] = oldpassword;
    newpasswords[passEnd] = newpassword;
    passEnd = (passEnd+1) % ArrayCount(oldpasswords);
    if(passEnd == passStart) passStart = (passStart+1) % ArrayCount(oldpasswords);
    info("replaced password \"" $ oldpassword $ "\" with \"" $ newpassword $ "\", passEnd is " $ passEnd $", passStart is " $ passStart);

    if( oldpassword == "6282" ) {
        // we only update the code 6282 because it's rare for passwords to be in goals
#ifdef hx
        UpdateAllGoals(HXGameInfo(Level.Game).Steve.FirstGoal, oldpassword, newpassword);
#else
        foreach AllActors(class'#var(PlayerPawn)', p) {
            UpdateAllGoals(p.FirstGoal, oldpassword, newpassword);
        }
#endif
    }

#ifdef hx
    UpdateAllNotes(HXGameInfo(Level.Game).FirstNote, oldpassword, newpassword);
#else
    foreach AllActors(class'#var(PlayerPawn)', p) {
        UpdateAllNotes(p.FirstNote, oldpassword, newpassword);
    }
#endif
}

simulated function NotifyPlayerNotesUpdated(#var(PlayerPawn) p)
{
    if( updated == 1 ) {
        p.ClientMessage("Note updated with randomized password",, true);
        DeusExRootWindow(p.rootWindow).hud.msgLog.PlayLogSound(Sound'LogNoteAdded');
    }
    else if( updated > 1 ) {
        p.ClientMessage("Notes updated with randomized passwords",, true);
        DeusExRootWindow(p.rootWindow).hud.msgLog.PlayLogSound(Sound'LogNoteAdded');
    }
    updated = 0;
}


function MarkPasswordKnown(string password)
{
#ifdef injections
    local #var(prefix)Keypad k;
    local #var(prefix)Computers c;
    local #var(prefix)ATM a;

    //Check computer logins
    foreach AllActors(class '#var(prefix)Computers',c)
    {
        c.SetAccountKnownByPassword(password);
    }

    foreach AllActors(class '#var(prefix)ATM',a)
    {
        a.SetAccountKnownByPassword(password);
    }
    //Check keypad logins
    foreach AllActors(class '#var(prefix)Keypad',k)
    {
        if (password == k.validCode) {
            k.bCodeKnown = True;
        }
    }
#else
    local DXRKeypad k;
    //Check keypad logins
    foreach AllActors(class 'DXRKeypad',k)
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

    MarkPasswordKnown(newpassword);
    if(oldpassword == newpassword)
        return false;

#ifndef hx
    player().ClientMessage("Goal updated with randomized password",, true);
    DeusExRootWindow(player().rootWindow).hud.msgLog.PlayLogSound(Sound'LogGoalAdded');
#endif

    info("found goal with password " $ oldpassword $ ", replacing with newpassword " $ newpassword);

    goal.text = ReplaceText( goal.text, oldpassword, " " $ newpassword $ " ", true );//spaces around the password make it so you can double click to highlight it then copy it easily

#ifdef hx
    HXGameInfo(Level.Game).AddNote(goal.text, false, true, '');
#endif

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
        return false;
    }

    // if the oldpassword is inside the note's new_passwords array, that means it's a coincidental collision
    if( note.HasEitherPassword(oldpassword, newpassword) ) return false;
#endif

    if( PassInStr( note.text, newpassword ) != -1 ) {
        MarkPasswordKnown(newpassword);
#ifdef injections
        note.SetNewPassword(newpassword);
#endif
        return false;
    }

    if( PassInStr( note.text, oldpassword ) == -1 ) return false;

    MarkPasswordKnown(newpassword);
    if(oldpassword == newpassword)
        return false;

    updated++;
    info("found note with password " $ oldpassword $ ", replacing with newpassword " $ newpassword);

    note.text = ReplaceText( note.text, oldpassword, " " $ newpassword $ " ", true );//spaces around the password make it so you can double click to highlight it then copy it easily
#ifdef injections
    note.SetNewPassword(newpassword);
#elseif hx
    HXUpdateNote(note.textTag, note.text, "");
#endif

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
    oldseed = dxr.SetSeed( dxr.seed + dxr.Crc(Caps(oldpassword)) );
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

    oldseed = SetGlobalSeed(oldpasscode);//manually set the seed to avoid using the level name in the seed
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
            capsNot = not_passwords[n];
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


simulated function LogAll()
{
    local #var(prefix)Computers c;
    local #var(prefix)Keypad k;
    local #var(prefix)ATM a;
    local int i;

    l("passEnd is " $ passEnd $", passStart is " $ passStart);

    foreach AllActors(class'#var(prefix)Keypad', k)
    {
        l("found "$k$" with code: " $ k.validCode );
    }

    foreach AllActors(class'#var(prefix)Computers', c)
    {
        for (i=0; i<ArrayCount(c.userList); i++)
        {
            if (c.userList[i].password == "")
                continue;

            l("found "$c$" username: "$c.userList[i].username$", password: " $ c.userList[i].password);
        }
    }

    foreach AllActors(class'#var(prefix)ATM', a)
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

function RunTests()
{
    local int old_num_not_passwords;
    local string oldnot;
    Super.RunTests();

    testint( WordInStr("THIS IS A TEST", "IS", 2 ), 2, "WordInStr match" );
    testint( WordInStr("THIS IS A TEST", "IS", 2, true ), 5, "WordInStr 2nd match" );
    testint( WordInStr("THISIS A TEST", "IS", 2, true ), -1, "WordInStr 2nd match not word" );
    testint( WordInStr("THIS .IS. A TEST", "IS", 2, true ), 6, "WordInStr periods" );
    testint( WordInStr("THIS \"IS\" A TEST", "IS", 2, true ), 6, "WordInStr quotes" );
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
    testint( PassInStr("password is captain.", "captain"), 12, "yes password period");
    testint( PassInStr("password is \"captain\"", "captain"), 13, "yes password quotes");

    teststring( GeneratePassword(dxr, "CAPTain"), GeneratePassword(dxr, "captain"), "GeneratePassword is case insensitive");

    not_passwords[0] = oldnot;
    num_not_passwords = old_num_not_passwords;
}
