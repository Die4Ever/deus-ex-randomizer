class DXRMenuMain injects MenuMain;

var float countdown;
var int nameLen, firstSpace, secondSpace;
var MenuUIMenuButtonWindow randoSettingsButton;

var DXRNews news;

#ifdef injections
function UpdateButtonStatus()
{
    Super.UpdateButtonStatus();
    if( ! class'DXRAutosave'.static.AllowManualSaves(player) ) winButtons[1].SetSensitivity(False);
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
            ProcessMenuAction(MA_MenuScreen, Class'MenuScreenRandoOptions');
            bHandled = True;
        }
    }

    return bHandled;
}
