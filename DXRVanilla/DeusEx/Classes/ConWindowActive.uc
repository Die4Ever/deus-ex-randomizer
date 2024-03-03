class DXRConWindowActive merges ConWindowActive;
// merges because Kentie's Launcher does this https://github.com/Die4Ever/deus-ex-randomizer/issues/453

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
    local int selectedOption;

    selectedOption=0;
    switch(key){
        case IK_1:
        case IK_NumPad1:
            selectedOption=1;
            break;
        case IK_2:
        case IK_NumPad2:
            selectedOption=2;
            break;
        case IK_3:
        case IK_NumPad3:
            selectedOption=3;
            break;
        case IK_4:
        case IK_NumPad4:
            selectedOption=4;
            break;
        case IK_5:
        case IK_NumPad5:
            selectedOption=5;
            break;
        default:
            selectedOption=0;
            break;
    }

    if ( numChoices != 0 ){
        if (selectedOption!=0){
            if (selectedOption<=numChoices){
                ButtonActivated(conChoices[selectedOption-1]);
                return True;
            }
        }
    } else {
        if (selectedOption!=0){
            conPlay.PlayNextEvent();
            return True;
        }
    }

    return _VirtualKeyPressed(key,bRepeat);
}

function AddButton( ConChoiceWindow newButton )
{
    _AddButton(newButton);

    newButton.SetText("("$numChoices$") "$ Mid(newButton.GetText(),2)); // (#) Dialog option
}
