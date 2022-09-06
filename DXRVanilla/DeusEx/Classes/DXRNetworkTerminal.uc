class DXRNetworkTerminal injects NetworkTerminal;

var ComputerScreenKnownAccounts winKnownAccounts;
var ShadowWindow                winKnownShadow;

function ShowScreen(Class<ComputerUIWindow> newScreen)
{
    switch(newScreen) {
        case class'ComputerScreenSpecialOptions':
            newScreen = class'DXRComputerScreenSpecialOptions';
            break;
    }
    Super.ShowScreen(newScreen);
}

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

function LogInAs(String user, String pass)
{
    local ComputerScreenLogin login;
    local ComputerScreenATM atm;
    if (winComputer.IsA('ComputerScreenLogin'))
    {
        login = ComputerScreenLogin(winComputer);
        login.editUserName.SetText(user);
        login.editPassword.SetText(pass);
        if(pass != "")
            login.ProcessLogin();
        else
            login.SetFocusWindow(login.editPassword);
    }
    else if (winComputer.IsA('ComputerScreenATM'))
    {
        atm = ComputerScreenAtm(winComputer);
        atm.editAccount.SetText(user);
        atm.editPIN.SetText(pass);
        if(pass != "")
            atm.ProcessLogin();
        else
            atm.SetFocusWindow(atm.editPIN);
    }

    userName = user;
}

function CloseScreen(String action)
{
    if ((action == "LOGIN") && (winKnownAccounts != None))
    {
        CloseKnownAccountsWindow();
    }

    Super.CloseScreen(action);
}

function CreateKnownAccountsWindow()
{
    local int codes_mode;
    codes_mode = int(player.ConsoleCommand("get #var(package).MenuChoice_PasswordAutofill codes_mode"));
    if( codes_mode < 1 ) return;

    winKnownShadow = ShadowWindow(NewChild(Class'ShadowWindow'));

    winKnownAccounts = ComputerScreenKnownAccounts(NewChild(Class'ComputerScreenKnownAccounts'));
    if( codes_mode == 2 )
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
