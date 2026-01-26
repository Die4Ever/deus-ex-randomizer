class DXRComputerScreenEmail extends #var(prefix)ComputerScreenEmail;

var DXRPasswords passwords;
var bool addNote;
var string updated_passwords[16];

function ProcessDeusExText(Name textName, optional TextWindow winText)
{
    local DXREvents e;
    local #var(prefix)PlayerPawn pp;
    local int i;

#ifdef hx
    pp = PlayerPawn;
#else
    pp = player;
#endif

    addNote = True;
    for(i=0; i<ArrayCount(updated_passwords); i++) {
        updated_passwords[i] = "";
    }

    foreach pp.AllActors(class'DXREvents', e) {
        e.ReadText(textName);
    }
    foreach pp.AllActors(class'DXRPasswords', passwords) { break; }

    Super.ProcessDeusExText(textName, winText);

    if (addNote){
        TryAddingNote(winText.GetText(),textName);
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

function ProcessEmail(DeusExTextParser parser)
{
    local int oldIdx;

    oldIdx = emailIndex;
    Super.ProcessEmail(parser);

    if (oldIdx != emailIndex){
        //Replace passwords in email subject lines (Alex's closet code...)
        if(passwords != None) passwords.ProcessString(emailInfo[emailIndex].emailSubject, updated_passwords);
    }
}

function TryAddingNote(string text, optional name texttag)
{
    local string mapname, textPackage;
    local Name finalTextTag;
    local DeusExNote note;
    local DeusExRootWindow rootWindow;
    local #var(PlayerPawn) pp;

    if(Len(text)==0) return;


#ifdef hx
    pp = PlayerPawn;
#else
    pp = #var(PlayerPawn)(player);
#endif

    rootWindow = DeusExRootWindow(pp.rootWindow);
    if (texttag==''){
        mapname = GetMapNameStripped();
        finalTextTag = rootWindow.StringToName(mapname$"-"$ DxrCrc(text));
    } else {
        textPackage = "DeusExText";
        if (CompOwner!=None && CompOwner.IsA('#var(prefix)Computers')){
        #ifndef hx
            textPackage = #var(prefix)Computers(CompOwner).TextPackage;
        #else
            textPackage = CompOwner.TextPackage;
        #endif
        }
        finalTextTag = rootWindow.StringToName(textPackage$"-"$texttag);
    }

#ifdef revision
    note = pp.GetNote(finalTextTag, "");
#else
    note = pp.GetNote(finalTextTag);
#endif
    if (note == None)
    {
        note = pp.AddNote(text,, True);
        SetTextTag(note, finalTextTag);
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
#ifdef hx
    mapname = Caps(PlayerPawn.GetLevelInfo().mapName);
#else
    mapname = Caps(player.GetLevelInfo().mapName);
#endif
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

    dxr = class'DXRando'.default.dxr;
    if (dxr!=None) {
        return dxr.Crc(plaintext);
    }
    return 0;
}
