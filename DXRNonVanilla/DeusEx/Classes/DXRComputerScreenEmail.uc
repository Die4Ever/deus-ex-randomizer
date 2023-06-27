class DXRComputerScreenEmail extends ComputerScreenEmail;

var DXRPasswords passwords;
var bool addNote;

function ProcessDeusExText(Name textName, optional TextWindow winText)
{
    local DXREvents e;

    addNote = True;

    foreach player.AllActors(class'DXREvents', e) {
        e.ReadText(textName);
    }
    foreach player.AllActors(class'DXRPasswords', passwords) { break; }

    Super.ProcessDeusExText(textName, winText);

    if (addNote){
        TryAddingNote(winText.GetText());
    }
}

function ProcessDeusExTextTag(DeusExTextParser parser, optional TextWindow winText)
{
    local String text;
    local byte tag;
    local string updated_passwords[16];
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

            for(i=0; i<ArrayCount(updated_passwords); i++) {
                if( updated_passwords[i] != "" ) {
                    addNote = True;
                    passwords.MarkPasswordKnown(updated_passwords[i]);
                }
            }
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

    if(Len(text)==0) return;

    rootWindow = DeusExRootWindow(player.rootWindow);

    mapname = GetMapNameStripped();
    plaintextTag = rootWindow.StringToName(mapname$"-"$ DxrCrc(text));

#ifdef revision
    note = player.GetNote(plaintextTag, "");
#else
    note = player.GetNote(plaintextTag);
#endif
    if (note == None)
    {
        note = player.AddNote(text,, True);
        SetTextTag(note, plaintextTag);
    }
}

function SetTextTag(DeusExNote note, Name textTag)
{
#ifdef revision
    note.SetTextTag(textTag, "");
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
