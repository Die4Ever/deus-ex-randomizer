class DXRComputerScreenSpecialOptions extends ComputerScreenSpecialOptions;

function ActivateSpecialOption(MenuUIChoiceButton buttonPressed)
{
    local int buttonIndex;
    local int specialIndex;

    specialIndex = -1;

    // Loop through the buttons and find a Match!
    for(buttonIndex=0; buttonIndex<arrayCount(optionButtons); buttonIndex++)
    {
        if (optionButtons[buttonIndex].btnSpecial == buttonPressed)
        {
            specialIndex = optionButtons[buttonIndex].specialIndex;

            // Disable this button so the user can't activate this
            // choice again
            optionButtons[buttonIndex].btnSpecial.SetSensitivity(False);

            break;
        }
    }

    // If we found the matching button, activate the option!
    if (specialIndex != -1)
    {
        // Make sure this option wasn't already triggered
        if (!Computers(compOwner).specialOptions[specialIndex].bAlreadyTriggered)
        {
            // adjust passwords, add note
            SpecialOptionTriggerAdjustPassword(specialIndex);
        }
    }

    Super.ActivateSpecialOption(buttonPressed);
}

function SpecialOptionTriggerAdjustPassword(int specialIndex)
{
    local DeusExNote note;
    local DXRPasswords passwords;
    local string new_passwords[16];
    local string text;
    local int i;

    foreach player.AllActors(class'DXRPasswords', passwords) { break; }
    if(passwords == None) {
        return;
    }

    text = Computers(compOwner).specialOptions[specialIndex].TriggerText;
    passwords.ProcessString(text, new_passwords);
    Computers(compOwner).specialOptions[specialIndex].TriggerText = text;

    note = player.AddNote(text,, True);

#ifdef injections
    for(i=0; i < ArrayCount(new_passwords) && i < ArrayCount(note.new_passwords); i++) {
        note.new_passwords[i] = new_passwords[i];
        new_passwords[i] = "";
        if (note.new_passwords[i]!="") {
            passwords.MarkPasswordKnown(note.new_passwords[i]);
        }
    }
#endif
}
