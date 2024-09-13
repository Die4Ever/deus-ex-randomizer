class DXRMenuMain injects MenuMain;

var float countdown;
var int nameLen, firstSpace, secondSpace;
var MenuUIMenuButtonWindow randoSettingsButton;
var string NoSavingTitle;

var DXRNews news;

#ifdef injections
function UpdateButtonStatus()
{
    local bool allowSave;
    allowSave = class'DXRAutosave'.static.CanSaveDuringInfolinks(player);

    Super.UpdateButtonStatus();

    //We will leave the save button active in game modes
    //that restrict saving so that we can show a message
    //when you hit the button explaining why.  Only make
    //the button clickable if an infolink is playing and
    //you have the choice allowing save during infolinks
    //since the infolink will only skip when opening the
    //save screen itself.
    if (player.dataLinkPlay!=None && allowSave){
        winButtons[1].SetSensitivity(True);
    }
}
#endif

function SetTitle(String newTitle)
{
    bTickEnabled = true;
#ifdef gmdx
    title = "GMDX RANDOMIZER " $ class'DXRVersion'.static.VersionString();
    nameLen = 14;
    firstSpace = 4;
    secondSpace = 999;
#elseif revision
    title = "REVISION RANDOMIZER " $ class'DXRVersion'.static.VersionString();
    nameLen = 18;
    firstSpace = 8;
    secondSpace = 999;
#elseif vmd
    title = "VMD RANDOMIZER " $ class'DXRVersion'.static.VersionString();
    nameLen = 13;
    firstSpace = 3;
    secondSpace = 999;
#else
    title = "DEUS EX RANDOMIZER " $ class'DXRVersion'.static.VersionString();
    nameLen = 16;
    firstSpace = 4;
    secondSpace = 7;
#endif
    winTitle.SetTitle( title );
    countdown = 0.5;
}

function Tick(float DeltaTime)
{
    local int i;
    local string l, r, letter;

    countdown -= DeltaTime;
    if( countdown > 0 ) return;

    countdown = Float(Rand(500)) / 2000.0 + 0.1;

    i = Rand(nameLen);
    if(i >= firstSpace) i++;//skip the space after DEUS
    if(i >= secondSpace) i++;//skip the space after EX

    l = Left(title, i);
    r = Mid(title, i+1);
    letter = Chr( Rand(26) + 65 );

    title = l $ letter $ r;

    winTitle.SetTitle( title );
}

function CreateMenuButtons()
{
    local int newsWidth;

    ButtonNames[4] = "Rando Training";
    Super.CreateMenuButtons();

    winButtons[3].SetWidth((buttonWidth/2)+3); //Make settings half-width
    winButtons[3].SetButtonText(" "$ButtonNames[3]); //Need an extra space to make the text fit right

    randoSettingsButton = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
    randoSettingsButton.SetButtonText("Rando");
    randoSettingsButton.SetPos(buttonXPos+(buttonWidth/2), buttonDefaults[3].y); //Put it next to the settings button
    randoSettingsButton.SetWidth(buttonWidth/2);

    // news
    newsWidth = 400;
    news = DXRNews(winClient.NewChild(class'DXRNews'));
    news.CreateNews(player, ClientWidth, 0, newsWidth, ClientHeight - 16);
    if(news.HasNews()) {
        ClientWidth += newsWidth;
        winClient.SetWidth(ClientWidth);
    }
}

function bool ButtonActivated( Window buttonPressed )
{
    local bool bHandled;
    bHandled = Super.ButtonActivated( buttonPressed);

    if (!bHandled){
        if (buttonPressed == randoSettingsButton){
            // Check to see if there's somewhere to go
            ProcessMenuAction(MA_MenuScreen, Class'MenuScreenRandoOptChoices');
            bHandled = True;
        }
    }

    return bHandled;
}

function ProcessCustomMenuButton(string key)
{
    local string reason;

    switch(key)
    {
        case "SAVEGAME":
            #ifdef injections
            reason = class'DXRAutosave'.static.GetSaveFailReason(player);
            #endif

            if (reason==""){
                #ifdef injections
                class'DXRAutosave'.static.SkipInfolinksForSave(player);
                #endif
                root.InvokeMenuScreen(Class'MenuScreenSaveGame');
            } else {
                root.MessageBox(NoSavingTitle, reason, 1, False, Self);
            }
            break;
    }
}

//"button" can actually be the message box itself
event bool BoxOptionSelected(Window button, int buttonNumber)
{
    local string s;

    if (MenuUIMessageBoxWindow(button)!=None){
        s = MenuUIMessageBoxWindow(button).winTitle.titleText;
    }

    if (s==NoSavingTitle){
        root.PopWindow();
        return true;
    } else {
        return Super.BoxOptionSelected(button,buttonNumber);
    }
}

defaultproperties
{
    AskToTrainTitle="Rando Training Mission"
    AskToTrainMessage="Before starting DX Randomizer for the first time, we suggest running through the Rando Training Mission.  Would you like to do this now?"
    buttonDefaults(1)=(Y=49,Action=MA_Custom,Key="SAVEGAME")
    NoSavingTitle="Can't Save!"
}
