#ifdef injections
class DXRHUDMedBotHealthScreen injects HUDMedBotHealthScreen;
#elseif hx
class DXRHUDMedBotHealthScreen extends HXPersonaScreenHealthMedBot;
#else
class DXRHUDMedBotHealthScreen extends HUDMedBotHealthScreen;
#endif

function UpdateMedBotDisplay()
{
    local float barPercent;
    local String infoText;
    local float secondsRemaining;
    local String barLabel;

#ifdef injections
    local MedicalBot dxrbot;
    dxrbot = medBot;
#else
    local DXRMedicalBot dxrbot;
    dxrbot = DXRMedicalBot(medBot);
#endif

    if (medBot != None)
    {
        infoText = Sprintf(HealthInfoTextLabel, medBot.healAmount);

        // Update the bar
        if (medBot.CanHeal())
        {
            winHealthBar.SetCurrentValue(100);
            if (dxrbot != None && dxrbot.HasLimitedUses()) {
                barLabel = ReadyLabel $ dxrbot.GetRemainingUsesStr();
            } else {
                barLabel = ReadyLabel;
            }
            winHealthBarText.SetText(barLabel);

            if (IsPlayerDamaged())
                infoText = infoText $ MedBotReadyLabel;
            else
                infoText = infoText $ MedBotYouAreHealed;
        }
        else
        {
            secondsRemaining = medBot.GetRefreshTimeRemaining();

            barPercent = 100 * (1.0 - (secondsRemaining / Float(medBot.healRefreshTime)));

            winHealthBar.SetCurrentValue(barPercent);

            if (dxrbot != None && dxrbot.HasLimitedUses() && !dxrbot.HealsRemaining())
                winHealthBarText.SetText("No Heals Left");
            else if (secondsRemaining == 1)
                winHealthBarText.SetText(Sprintf(SecondsSingularLabel, Int(secondsRemaining)));
            else
                winHealthBarText.SetText(Sprintf(SecondsPluralLabel, Int(secondsRemaining)));

            if (dxrbot != None && dxrbot.HasLimitedUses() && !dxrbot.HealsRemaining())
                infoText = infoText $ "|nNo heals remaining";
            else if (IsPlayerDamaged())
                infoText = infoText $ MedBotRechargingLabel;
            else
                infoText = infoText $ MedBotYouAreHealed;
        }

        winHealthInfoText.SetText(infoText);
    }

    EnableButtons();
}

function Tick(float deltaTime)
{
    UpdateMedBotDisplay();
    UpdateRegionWindows();
}
