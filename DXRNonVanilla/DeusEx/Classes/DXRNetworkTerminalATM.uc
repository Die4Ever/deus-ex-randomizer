#ifdef hx
class DXRNetworkTerminalATM extends HXNetworkTerminalATM;
#else
class DXRNetworkTerminalATM extends #var(prefix)ATMWindow;
#endif

var ComputerScreenKnownAccounts winKnownAccounts;
var ShadowWindow                winKnownShadow;

function ConfigurationChanged()
{
    local float hackAccountsWidth, hackAccountsHeight;
    local float hackWidth, hackHeight;

    Super.ConfigurationChanged();

    if (winHack != None)
    {
        winHack.QueryPreferredSize(hackWidth, hackHeight);
    }

    if (winKnownAccounts != None)
    {
        winKnownAccounts.QueryPreferredSize(hackAccountsWidth, hackAccountsHeight);
        winKnownAccounts.ConfigureChild(
            width - hackAccountsWidth, hackHeight + 20,
            hackAccountsWidth, hackAccountsHeight);

        // Place shadow
        winKnownShadow.ConfigureChild(
            width - hackAccountsWidth + winKnownAccounts.backgroundPosX - shadowOffsetX,
            hackHeight + 20 + winKnownAccounts.backgroundPosY - shadowOffsetY,
            winKnownAccounts.backgroundWidth + (shadowOffsetX * 2),
            winKnownAccounts.backgroundHeight + (shadowOffsetY * 2));
    }

}

function CreateKnownAccountsWindow()
{
    if( class'MenuChoice_PasswordAutofill'.static.GetSetting() < 1 ) return;

    winKnownShadow = ShadowWindow(NewChild(Class'ShadowWindow'));

    winKnownAccounts = ComputerScreenKnownAccounts(NewChild(Class'ComputerScreenKnownAccounts'));
    if( class'MenuChoice_PasswordAutofill'.static.GetSetting() == 2 )
        winKnownAccounts.bShowPasswords = true;
    winKnownAccounts.SetNetworkTerminal(Self);
    winKnownAccounts.SetCompOwner(compOwner);
    winKnownAccounts.AskParentForReconfigure();
}

function CloseKnownAccountsWindow()
{
    if (winKnownAccounts != None)
    {
        winKnownAccounts.Destroy();
        winKnownAccounts = None;

        winKnownShadow.Destroy();
        winKnownShadow = None;
    }
}

function CreateHackWindow()
{
    local Float hackTime;
    local Float skillLevelValue;

    //Revision-only for now, until other mods get a bit more love
    //to make sure passwords are accessible, etc
    if (!#defined(revision)){
        Super.CreateHackWindow();
        return;
    }

    skillLevelValue = player.SkillSystem.GetSkillLevelValue(class'SkillComputer');
    skillLevel      = player.SkillSystem.GetSkillLevel(class'SkillComputer');

    // Check to see if the player is skilled in Hacking before
    // creating the window
    if ((skillLevel > 0) && (bUsesHackWindow))
    {
        // Base the detection and hack time on the skill level
        hackTime       = detectionTime / (skillLevelValue * 1.5);
        detectionTime *= skillLevelValue;

        // First create the shadow window
        winHackShadow = ShadowWindow(NewChild(Class'ShadowWindow'));

        winHack = #var(injectsprefix)ComputerScreenHack(NewChild(Class'#var(injectsprefix)ComputerScreenHack'));
        winHack.SetNetworkTerminal(Self);
        winHack.SetDetectionTime(detectionTime, hackTime);
    }
}

function LogInAs(String user, String pass)
{
    local #var(prefix)ComputerScreenATM atm;

    if (winComputer.IsA('#var(prefix)ComputerScreenATM'))
    {
        atm = #var(prefix)ComputerScreenAtm(winComputer);
        atm.editAccount.SetText(user);
        atm.editPIN.SetText(pass);
        if(pass != "")
            atm.ProcessLogin();
        else
            atm.SetFocusWindow(atm.editPIN);
    }

    userName = user;
}


function ShowScreen(Class<#var(prefix)ComputerUIWindow> newScreen)
{
    newScreen = class'DXRNetworkTerminal'.static.ShowScreen(newScreen);

    Super.ShowScreen(newScreen);
}

event InitWindow()
{
    Super.InitWindow();
#ifndef hx
    class'DXRNetworkTerminal'.static.InitWindow(self);
#endif
}
