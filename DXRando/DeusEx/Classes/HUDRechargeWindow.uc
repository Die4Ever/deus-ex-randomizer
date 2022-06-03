#ifdef injections
class DXRHUDRechargeWindow injects HUDRechargeWindow;
#else
class DXRHUDRechargeWindow extends #var(prefix)HUDRechargeWindow;
#endif

function UpdateRepairBotWindows()
{
    local float barPercent;
    local String infoText;
    local float secondsRemaining;
    local String barLabel;

#ifdef injections
    local RepairBot dxrbot;
    dxrbot = repairBot;
#else
    local DXRRepairBot dxrbot;
    dxrbot = DXRRepairBot(repairBot);
#endif

    if (repairBot != None)
    {
        // Update the bar
        if (repairBot.CanCharge())
        {
            winRepairBotBar.SetCurrentValue(100);
            if (dxrbot != None && dxrbot.HasLimitedUses()){
                barLabel = ReadyLabel $ dxrbot.GetRemainingUsesStr();
            } else {
                barLabel = ReadyLabel;
            }
            winRepairBotBarText.SetText(barLabel);
        }
        else
        {
            secondsRemaining = repairBot.GetRefreshTimeRemaining();

            barPercent = 100 * (1.0 - (secondsRemaining / Float(repairBot.chargeRefreshTime)));

            winRepairBotBar.SetCurrentValue(barPercent);

            if (dxrbot != None && dxrbot.HasLimitedUses() && !dxrbot.ChargesRemaining())
                winRepairBotBarText.SetText("No Charges Remaining");
            else if (secondsRemaining == 1)
                winRepairBotBarText.SetText(Sprintf(SecondsSingularLabel, Int(secondsRemaining)));
            else
                winRepairBotBarText.SetText(Sprintf(SecondsPluralLabel, Int(secondsRemaining)));
        }

        winRepairBotInfoText.SetText(RepairBotStatusLabel);
    }
}

function UpdateInfoText()
{
    local String infoText;

#ifdef injections
    local RepairBot dxrbot;
    dxrbot = repairBot;
#else
    local DXRRepairBot dxrbot;
    dxrbot = DXRRepairBot(repairBot);
#endif

    if (repairBot != None)
    {
        infoText = Sprintf(RepairBotInfoText, repairBot.chargeAmount, repairBot.chargeRefreshTime);

        if (dxrbot != None && dxrbot.HasLimitedUses() && !dxrbot.ChargesRemaining())
            infoText = infoText $ "|nNo charges remaining";
        else if (player.Energy >= player.EnergyMax)
            infoText = infoText $ RepairBotYouAreHealed;
        else if (repairBot.CanCharge())
            infoText = infoText $ RepairBotReadyLabel;
        else
            infoText = infoText $ RepairBotRechargingLabel;

        winInfo.SetText(infoText);
    }
}

event Tick(float deltaSeconds)
{
    if (lastRefresh >= refreshInterval)
    {
        lastRefresh = 0.0;
        UpdateRepairBotWindows();
        UpdateInfoText();
        UpdateBioWindows();
        EnableButtons();
    }
    else
    {
        lastRefresh += deltaSeconds;
    }
}
