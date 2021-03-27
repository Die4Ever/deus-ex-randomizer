class InformationDevices injects InformationDevices abstract;

var DXRPasswords passwords;
var string plaintext;
var string new_passwords[16];

function string _GetMapName()
{
    local DeusExLevelInfo dxinfo;
    foreach AllActors(class'DeusExLevelInfo', dxinfo) {
        return Caps(dxinfo.mapName);
    }
    log("WARNING: "$self$" failed to find DeusExLevelInfo!");
    return Caps(GetURLMap());
}

function string GetMapNameStripped()
{
    local string mapname;
    local int i;
    mapname = _GetMapName();
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

// ----------------------------------------------------------------------
// CreateInfoWindow()
// ----------------------------------------------------------------------

function CreateInfoWindow()
{
    local DeusExNote note;
    local DeusExRootWindow rootWindow;
    local int i;
    local Name plaintextTag;
    local string mapname;

    foreach AllActors(class'DXRPasswords', passwords) { break; }

    if( plaintext != "" ) {
        rootWindow = DeusExRootWindow(aReader.rootWindow);
        infoWindow = rootWindow.hud.ShowInfoWindow();
        infoWindow.ClearTextWindows();

        vaultString = "";
        if (winText == None)
            winText = infoWindow.AddTextWindow();
        vaultString = plaintext;
        if(passwords != None) passwords.ProcessString(vaultString, new_passwords);
        winText.SetText(vaultString);
        if (bAddToVault)
        {
            mapname = GetMapNameStripped();
            plaintextTag = rootWindow.StringToName(mapname$"-"$Name);
            log(Self$": plaintextTag: "$plaintextTag);
            note = aReader.GetNote(plaintextTag);
            if (note == None)
            {
                note = aReader.AddNote(vaultString,, True);
                note.SetTextTag(plaintextTag);
                for(i=0; i < ArrayCount(new_passwords) && i < ArrayCount(note.new_passwords); i++) {
                    note.new_passwords[i] = new_passwords[i];
                    new_passwords[i] = "";
                }
            }
        }
        vaultString = "";
        return;
    }

    if (bAddToVault) note = aReader.GetNote(Name);
    Super.CreateInfoWindow();
    if ( bAddToVault && note == None && aReader.FirstNote.textTag == Name && textTag != '' )
    {
        note = aReader.FirstNote;
        for(i=0; i < ArrayCount(new_passwords) && i < ArrayCount(note.new_passwords); i++) {
            note.new_passwords[i] = new_passwords[i];
            new_passwords[i] = "";
        }
    }
}

// ----------------------------------------------------------------------
// ProcessTag()
// ----------------------------------------------------------------------

function ProcessTag(DeusExTextParser parser)
{
    local String text;
    local byte tag;
    local Name fontName;

    tag  = parser.GetTag();

    // Make sure we have a text window to operate on.
    if (winText == None)
    {
        winText = infoWindow.AddTextWindow();
        bSetText = True;
    }

    switch(tag)
    {
        // If a winText window doesn't yet exist, create one.
        // Then add the text
        case 0:				// TT_Text:
        case 9:				// TT_PlayerName:
        case 10:			// TT_PlayerFirstName:
            text = parser.GetText();

            if(passwords != None) passwords.ProcessString(text, new_passwords);

            // Add the text
            if (bSetText)
                winText.SetText(text);
            else
                winText.AppendText(text);

            vaultString = vaultString $ text;
            bSetText = False;
            break;

        default:
            Super.ProcessTag(parser);
            break;
    }
}
