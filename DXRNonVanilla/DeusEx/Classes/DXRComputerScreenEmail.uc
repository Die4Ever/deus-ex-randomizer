class DXRComputerScreenEmail extends ComputerScreenEmail;

var DXRPasswords passwords;

function ProcessDeusExText(Name textName, optional TextWindow winText)
{
    local DXREvents e;
    foreach player.AllActors(class'DXREvents', e) {
        e.ReadText(textName);
    }
    foreach player.AllActors(class'DXRPasswords', passwords) { break; }

    Super.ProcessDeusExText(textName, winText);
}

function ProcessDeusExTextTag(DeusExTextParser parser, optional TextWindow winText)
{
    local String text;
    local byte tag;

    tag  = parser.GetTag();

    switch(tag)
    {
        case 0:				// TT_Text:
        case 9:				// TT_PlayerName:
        case 10:			// TT_PlayerFirstName:
            text = parser.GetText();
            if(passwords != None) passwords.ProcessString(text);

            // Add the text
            if (winText != None)
                winText.AppendText(text);

            break;

        default:
            Super.ProcessDeusExTextTag(parser, winText);
            break;
    }
}

