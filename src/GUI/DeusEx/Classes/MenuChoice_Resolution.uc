class DXRMenuChoice_Resolution injects MenuChoice_Resolution;

function LoadSetting()
{
    local int choiceIndex;
    local int currentChoice;

    currentChoice = -1;

    for(choiceIndex=0; choiceIndex<arrayCount(enumText); choiceIndex++)
    {
        if (enumText[choiceIndex] == "")
            break;

        if (enumText[choiceIndex] == CurrentRes)
        {
            currentChoice = choiceIndex;
            break;
        }
    }

    if(currentChoice == -1) {
        currentChoice = choiceIndex;
        enumText[currentChoice] = CurrentRes;
    }

    SetValue(currentChoice);
}
