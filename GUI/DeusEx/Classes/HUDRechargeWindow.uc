class DXRHUDRechargeWindow injects #var(prefix)HUDRechargeWindow;

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

    if(#defined(gmdx) || #defined(vmd)) {
        Super.UpdateRepairBotWindows();
        return;
    }

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
            log("repairbot barLabel: "$barLabel);
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

    if(#defined(gmdx) || #defined(vmd)) {
        Super.UpdateInfoText();
        return;
    }

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

function UpdateBioWindows()
{
    local float energyPercent;

    if (repairBot==None || player==None){
        log("Player or RepairBot doesn't exist while updating RepairBot energy bar - probably dead?");
        return;
    }

    energyPercent = 100.0 * (player.Energy / player.EnergyMax);
    winBioBar.SetCurrentValue(energyPercent);

    winBioBarText.SetText(Int(player.Energy)$"/"$Int(player.EnergyMax)$" Energy");

    winBioInfoText.SetText(BioStatusLabel);
}

event Tick(float deltaSeconds)
{
    if(#defined(gmdx) || #defined(vmd)) {
        Super.Tick(deltaSeconds);
        return;
    }

    if(repairBot == None || repairBot.bDeleteMe || player == None || player.bDeleteMe) {
        player = None;
        repairBot = None;
        DestroyWindow();
        root.PopWindow();
        return;
    }

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
