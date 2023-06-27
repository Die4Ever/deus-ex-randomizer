class ComputerUIWindow injects ComputerUIWindow abstract;

var DXRPasswords passwords;
var bool addNote;
var string updated_passwords[16];

function ProcessDeusExText(Name textName, optional TextWindow winText)
{
    local DXREvents e;
    local int i;

    addNote = True;
    for(i=0; i<ArrayCount(updated_passwords); i++) {
        updated_passwords[i] = "";
    }

    foreach player.AllActors(class'DXREvents', e) {
        e.ReadText(textName);
    }
    foreach player.AllActors(class'DXRPasswords', passwords) { break; }

    Super.ProcessDeusExText(textName, winText);

    for(i=0; i<ArrayCount(updated_passwords); i++) {
        if( updated_passwords[i] != "" ) {
            addNote = True;
            passwords.MarkPasswordKnown(updated_passwords[i]);
        }
    }
    if (addNote){
        TryAddingNote(winText.GetText());
    }
}

function ProcessDeusExTextTag(DeusExTextParser parser, optional TextWindow winText)
{
    local String text;
    local byte tag;
    local int i;

    tag  = parser.GetTag();

    switch(tag)
    {
        case 0:				// TT_Text:
        case 9:				// TT_PlayerName:
        case 10:			// TT_PlayerFirstName:
            text = parser.GetText();
            if(passwords != None) passwords.ProcessString(text, updated_passwords);

            // Add the text
            if (winText != None)
                winText.AppendText(text);
            break;

        default:
            Super.ProcessDeusExTextTag(parser, winText);
            break;
    }
}

function TryAddingNote(string text)
{
    local string mapname;
    local Name plaintextTag;
    local DeusExNote note;
    local DeusExRootWindow rootWindow;
    local int i;

    if(Len(text)==0) return;

    rootWindow = DeusExRootWindow(player.rootWindow);

    mapname = GetMapNameStripped();
    plaintextTag = rootWindow.StringToName(mapname$"-"$ DxrCrc(text));

    note = player.GetNote(plaintextTag);
    if (note == None)
    {
        note = player.AddNote(text,, True);
        SetTextTag(note, plaintextTag);
    }

    for(i=0; i<ArrayCount(updated_passwords); i++) {
        note.SetNewPassword(updated_passwords[i]);
    }
}

function SetTextTag(DeusExNote note, Name textTag)
{
#ifdef revision
    note.SetTextTag(textTag, TextPackage);
#elseif hx
    // do nothing
#else
    note.SetTextTag(textTag);
#endif
}

function string GetMapNameStripped()
{
    local string mapname;
    local int i;
    mapname = Caps(player.GetLevelInfo().mapName);
    while( true ) {
        i = InStr(mapname, "\\");
        if( i == -1 ) break;
        mapname = Mid(mapname, i+1);
    }
    while( true ) {
        i = InStr(mapname, ".");
        if( i == -1 ) break;
        mapname = Left(mapname, i) $ "-" $ Mid(mapname, i+1);
    }
    return mapname;
}

function int DxrCrc(string plaintext)
{
    local DXRando dxr;

    foreach player.AllActors(class'DXRando', dxr) {
        return dxr.Crc(plaintext);
    }
    return 0;
}
