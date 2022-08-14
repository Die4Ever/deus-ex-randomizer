class ComputerUIWindow injects ComputerUIWindow abstract;

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
    local string updated_passwords[16];
    local int j;
    local bool addNote;

    tag  = parser.GetTag();

    switch(tag)
    {
        case 0:				// TT_Text:
        case 9:				// TT_PlayerName:
        case 10:			// TT_PlayerFirstName:
            text = parser.GetText();
            if(passwords != None) passwords.ProcessString(text,updated_passwords);

            // Add the text
            if (winText != None)
                winText.AppendText(text);

            for(j=0; j<ArrayCount(updated_passwords); j++) {
                if( updated_passwords[j] != "" ) {
                    addNote = True;
                    if(passwords != None) passwords.MarkPasswordKnown(updated_passwords[j]);
                }
            }

            if (addNote) player.AddNote(text,False,True);

            break;

        default:
            Super.ProcessDeusExTextTag(parser, winText);
            break;
    }
}
