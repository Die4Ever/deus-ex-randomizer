//=============================================================================
// MenuScreenRandoOptions
//=============================================================================

class MenuScreenRandoOptions expands MenuUIScreenWindow;

var MenuUIScrollAreaWindow winScroll;
var Window controlsParent;

function CreateChoices()
{
    controlsParent = winClient;
    CreateScrollWindow();

    CreateChoice(class'MenuChoice_Telemetry');
    CreateChoice(class'MenuChoice_JoinDiscord');
    CreateChoice(class'MenuChoice_ReleasePage');
    // TODO: button to open Mastodon?

    CreateChoice(class'MenuChoice_BrightnessBoost');
    CreateChoice(class'MenuChoice_ToggleMemes');

    if(!#defined(revision)) {
        CreateChoice(class'MenuChoice_ContinuousMusic');
        CreateChoice(class'MenuChoice_RandomMusic');
        CreateChoice(class'MenuChoice_ChangeSong');
        //TODO: CreateChoice(class'MenuChoice_AutoChangeSong');
        CreateChoice(class'MenuChoice_DisableSong');
        CreateChoice(class'MenuChoice_UTMusic');
        CreateChoice(class'MenuChoice_UnrealMusic');
        CreateChoice(class'MenuChoice_DXMusic');
    }

    CreateChoice(class'MenuChoice_ShowNews');

    if(#defined(vanilla)) {
        CreateChoice(class'MenuChoice_EnergyDisplay');
        CreateChoice(class'MenuChoice_ShowKeys');
        CreateChoice(class'MenuChoice_ThrowMelee');
    }

    CreateChoice(class'MenuChoice_PasswordAutofill');
    CreateChoice(class'MenuChoice_ConfirmNoteDelete');
    CreateChoice(class'MenuChoice_FixGlitches');

    controlsParent.SetSize(clientWidth, choiceStartY + (choiceCount * choiceVerticalGap));
}


function CreateScrollWindow()
{
    local MenuUIListWindow lstKeys;
    local DXRNews news;

    winScroll = CreateScrollAreaWindow(winClient);
    winScroll.vScale.SetThumbStep(20);
    winScroll.SetPos(0, 0);
    winScroll.SetSize(ClientWidth, helpPosY);
    winScroll.EnableScrolling(false,true);

    controlsParent = winScroll.clipWindow.NewChild(class'MenuUIClientWindow');
}

function CreateChoice(Class<MenuUIChoice> choice)
{
    local MenuUIChoice newChoice;

    if (choice == None) return;

    newChoice = MenuUIChoice(controlsParent.NewChild(choice));
    newChoice.SetPos(choiceStartX, choiceStartY + (choiceCount * choiceVerticalGap) - newChoice.buttonVerticalOffset);
    choiceCount++;
}

// ----------------------------------------------------------------------
// LoadSettings()
// ----------------------------------------------------------------------

function LoadSettings()
{
    local Window btnChoice;

    btnChoice = controlsParent.GetTopChild();
    while(btnChoice != None)
    {
        if (btnChoice.IsA('MenuUIChoice'))
            MenuUIChoice(btnChoice).LoadSetting();

        btnChoice = btnChoice.GetLowerSibling();
    }
}

// ----------------------------------------------------------------------
// SaveSettings()
// ----------------------------------------------------------------------

function SaveSettings()
{
    local Window btnChoice;

    btnChoice = controlsParent.GetTopChild();
    while(btnChoice != None)
    {
        if (btnChoice.IsA('MenuUIChoice'))
            MenuUIChoice(btnChoice).SaveSetting();

        btnChoice = btnChoice.GetLowerSibling();
    }

    Super.SaveSettings();
    player.SaveConfig();
}

// ----------------------------------------------------------------------
// CancelScreen()
// ----------------------------------------------------------------------

function CancelScreen()
{
    local Window btnChoice;

    btnChoice = controlsParent.GetTopChild();
    while(btnChoice != None)
    {
        if (btnChoice.IsA('MenuUIChoice'))
            MenuUIChoice(btnChoice).CancelSetting();

        btnChoice = btnChoice.GetLowerSibling();
    }

    Super.CancelScreen();
}

// ----------------------------------------------------------------------
// ResetToDefaults()
// ----------------------------------------------------------------------

function ResetToDefaults()
{
    local Window btnChoice;

    btnChoice = controlsParent.GetTopChild();
    while(btnChoice != None)
    {
        if (btnChoice.IsA('MenuUIChoice'))
            MenuUIChoice(btnChoice).ResetToDefault();

        btnChoice = btnChoice.GetLowerSibling();
    }
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_OK)
     actionButtons(2)=(Action=AB_Reset)
     Title="Randomizer Options"
     ClientWidth=500
     ClientHeight=400
     helpPosY=364//helpPosY = ClientHeight - 36
     choiceStartY=12
}
