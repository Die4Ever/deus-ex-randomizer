//=============================================================================
// MenuScreenRandoOptionsBase
//=============================================================================

class MenuScreenRandoOptionsBase expands MenuUIScreenWindow abstract;

var MenuUIScrollAreaWindow winScroll;
var Window controlsParent;

function CreateChoices();

event InitWindow()
{
    local int scrollHeight;

    Super(MenuUIWindow).InitWindow();

    controlsParent = winClient;
    CreateScrollWindow();

    CreateChoices();
    LoadSettings();

    scrollHeight = choiceStartY + (choiceCount * choiceVerticalGap);
    controlsParent.SetSize(clientWidth, scrollHeight);

    ClientHeight = Min(scrollHeight + 36, default.ClientHeight);
    winClient.SetSize(clientWidth, ClientHeight);

    helpPosY = ClientHeight - 36;
    winScroll.SetSize(ClientWidth, helpPosY);
}

function CreateScrollWindow()
{
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
     Title="Base Menu"
     ClientWidth=500
     ClientHeight=400
     helpPosY=364//helpPosY = ClientHeight - 36
     choiceStartY=12
}
