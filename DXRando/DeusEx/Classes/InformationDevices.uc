#ifdef injections
class InformationDevices injects InformationDevices abstract;
#else
class DXRInformationDevices extends #var prefix InformationDevices;
#endif

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

function WritePasswordsToNote(DeusExNote note)
{
#ifdef injections
    local int i;

    for(i=0; i < ArrayCount(new_passwords) && i < ArrayCount(note.new_passwords); i++) {
        note.new_passwords[i] = new_passwords[i];
        new_passwords[i] = "";
        if (note.new_passwords[i]!="") {
            passwords.MarkPasswordKnown(note.new_passwords[i]);
        }
    }
#endif
}

function WritePasswordsToNoteByTag(DeusExRootWindow root, Name tag)
{
#ifndef hx
    local DeusExNote note;
    if(tag == '')
        return;

    note = GetNote(tag);
    if (note != None)
        WritePasswordsToNote(note);

    // LDDP compatibility
    tag = root.StringToName("FemJC"$tag);
    note = GetNote(tag);
    if (note != None)
        WritePasswordsToNote(note);
#endif
}

function DeusExNote GetNote(Name textTag)
{
#ifdef revision
    return aReader.GetNote(textTag, TextPackage);
#elseif hx
    return None;
#else
    return aReader.GetNote(textTag);
#endif
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

#ifdef hx
function AddToVault()
{
    local Name plaintextTag;
    local string vaultString, mapname;

    foreach AllActors(class'DXRPasswords', passwords) { break; }

    if( plaintext != "" ) {
        vaultString = plaintext;
        if(passwords != None) passwords.ProcessString(vaultString, new_passwords);
        mapname = GetMapNameStripped();
        plaintextTag = StringToName(mapname$"-"$Name);
        log(Self$": plaintextTag: "$plaintextTag);
        HXGameInfo(Level.Game).AddNote(vaultString, , True, textTag);
        return;
    }

    Super.AddToVault();
}


#else
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
            note = GetNote(plaintextTag);
            if (note == None)
            {
                note = aReader.AddNote(vaultString,, True);
                SetTextTag(note, plaintextTag);
                WritePasswordsToNote(note);
            }
        }
        vaultString = "";
        return;
    }

    Super.CreateInfoWindow();
    if(bAddToVault)
        WritePasswordsToNoteByTag(DeusExRootWindow(aReader.rootWindow), textTag);
}
#endif


#ifdef hx
// TODO: in HX this function is working, but we also need to override ProcessInformationDevicesWindowTag in HXPlayerPawn
/*function bool ProcessTag(DeusExTextParser parser, out string vaultString, bool bFirstParagraph )
{
    local String text;
    local byte tag;
    local Name fontName;

    tag  = parser.GetTag();

    switch(tag)
    {
        // If a winText window doesn't yet exist, create one.
        // Then add the text
        case 0:				// TT_Text:
        case 9:				// TT_PlayerName:
        case 10:			// TT_PlayerFirstName:
            text = parser.GetText();

            if(passwords != None) passwords.ProcessString(text, new_passwords);

            vaultString = vaultString $ text;
            break;

        default:
            bFirstParagraph = Super.ProcessTag(parser, vaultString, bFirstParagraph);
            break;
    }

    return bFirstParagraph;
}*/

#else
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
#endif

#ifdef gmdx
function bool Facelift(bool bOn)
{
    return false;
}

function postbeginplay()
{
}
#endif

defaultproperties
{
     bAddToVault=True
     bInvincible=True
     bCanBeBase=True
     ItemName="DataCube"
     Texture=Texture'DeusExItems.Skins.DataCubeTex2'
     Mesh=LodMesh'DeusExItems.DataCube'
     CollisionRadius=7.000000
     CollisionHeight=1.270000
     Mass=2.000000
     Buoyancy=3.000000
}
