class DXRComputerScreenSpecialOptions extends #var(prefix)ComputerScreenSpecialOptions;

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
#ifdef hx
        if (!compOwner.specialOptions[specialIndex].bAlreadyTriggered)
#else
        if (!Computers(compOwner).specialOptions[specialIndex].bAlreadyTriggered)
#endif
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
    local #var(prefix)PlayerPawn pp;
#ifdef hx
    pp = PlayerPawn;
#else
    pp = player;
#endif

    foreach pp.AllActors(class'DXRPasswords', passwords) { break; }
    if(passwords == None) {
        return;
    }

#ifdef hx
        text = compOwner.specialOptions[specialIndex].TriggerText;
#else
        text = Computers(compOwner).specialOptions[specialIndex].TriggerText;
#endif

    passwords.ProcessString(text, new_passwords);

#ifdef hx
    compOwner.specialOptions[specialIndex].TriggerText = text;
    note = pp.AddNote(text,, True);
#else
    Computers(compOwner).specialOptions[specialIndex].TriggerText = text;
    note = DeusExPlayer(pp).AddNote(text,, True);

#endif


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
