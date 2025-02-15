class MenuChoice_BalanceEtc extends MenuChoice_AccordingToGameMode;

event InitWindow()
{
    Super.InitWindow();

    if(!class'DXRInfo'.static.OnTitleScreen()) {
        SetSensitivity(false);
        btnInfo.SetSensitivity(false);
        btnAction.SetSensitivity(false);
    }
}

defaultproperties
{
    HelpText="Miscellaneous balance changes."
    actionText="Other Balance Changes"
    enumText(0)="Disabled"
    enumText(2)="Enabled"
}
