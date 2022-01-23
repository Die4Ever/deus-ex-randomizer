class DXRHUDRechargeWindow injects HUDRechargeWindow;

function UpdateRepairBotWindows()
{
	local float barPercent;
	local String infoText;
	local float secondsRemaining;
    local String barLabel;

	if (repairBot != None)
	{
		// Update the bar
		if (repairBot.CanCharge())
		{		
			winRepairBotBar.SetCurrentValue(100);
            if (repairBot.HasLimitedUses()){
                barLabel = ReadyLabel $ repairBot.GetRemainingUsesStr();
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

			if (repairBot.HasLimitedUses() && !repairBot.ChargesRemaining())
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

	if (repairBot != None)
	{
		infoText = Sprintf(RepairBotInfoText, repairBot.chargeAmount, repairBot.chargeRefreshTime);

		if (repairBot.HasLimitedUses() && !repairBot.ChargesRemaining())
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
