class DXRNetworkTerminalPersonal extends #var(prefix)NetworkTerminalPersonal;

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

function LogInAs(String user, String pass)
{
    local #var(prefix)ComputerScreenLogin login;

    if (winComputer.IsA('ComputerScreenLogin'))
    {
        login = #var(prefix)ComputerScreenLogin(winComputer);
        login.editUserName.SetText(user);
        login.editPassword.SetText(pass);
        if(pass != "")
            login.ProcessLogin();
        else
            login.SetFocusWindow(login.editPassword);
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
