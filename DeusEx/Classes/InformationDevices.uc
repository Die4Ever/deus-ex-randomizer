class InformationDevices injects InformationDevices abstract;

var DXRPasswords passwords;
var string plaintext;

// ----------------------------------------------------------------------
// CreateInfoWindow()
// ----------------------------------------------------------------------

function CreateInfoWindow()
{
    local DeusExNote note;
    local DeusExRootWindow rootWindow;

    foreach AllActors(class'DXRPasswords', passwords) { break; }

    Super.CreateInfoWindow();
    if ( textTag != '' ) {
        return;
    }
    if( plaintext != "" ) {
        rootWindow = DeusExRootWindow(aReader.rootWindow);
        infoWindow = rootWindow.hud.ShowInfoWindow();
        infoWindow.ClearTextWindows();

        vaultString = "";
        if (winText == None)
            winText = infoWindow.AddTextWindow();
        vaultString = plaintext;
        if(passwords != None) passwords.ProcessString(vaultString);
        winText.SetText(vaultString);
        if (bAddToVault)
        {
            note = aReader.GetNote(Name);
            if (note == None)
            {
                note = aReader.AddNote(vaultString,, True);
                note.SetTextTag(Name);
            }
        }
        vaultString = "";
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

            if(passwords != None) passwords.ProcessString(text);

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
