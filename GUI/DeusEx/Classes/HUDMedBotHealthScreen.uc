class DXRHUDMedBotHealthScreen injects HUDMedBotHealthScreen;

function UpdateMedBotDisplay()
{
    local float barPercent;
    local String infoText;
    local float secondsRemaining;
    local String barLabel;

#ifdef injections
    local MedicalBot dxrbot;
    dxrbot = medBot;
#elseif hx
    local DXRMedicalBot dxrbot;
    dxrbot = None;// HACK: none of the GUI stuff works in HX anyways
#else
    local DXRMedicalBot dxrbot;
    dxrbot = DXRMedicalBot(medBot);
#endif

    if(#defined(gmdx) || #defined(vmd)) {
        Super.UpdateMedBotDisplay();
        return;
    }

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

function SetMedicalBot(MedicalBot newBot, optional bool bPlayAnim)
{
    local HUDMedBotAddAugsScreen augScreen;

    Super.SetMedicalBot(newBot, bPlayAnim);

    newBot = medBot; // just to be safe
    if (isAugsOnly(newBot)) {
        SkipAnimation(True);
        augScreen = HUDMedBotAddAugsScreen(root.InvokeUIScreen(Class'HUDMedBotAddAugsScreen', True));
        augScreen.SetMedicalBot(newBot);
    } else if(#var(injectsprefix)HUDMedBotNavBarWindow(winNavBar) != None) {
        #var(injectsprefix)HUDMedBotNavBarWindow(winNavBar).CreateAllButtons();
    }
}

static function bool isAugsOnly(MedicalBot bot)
{
#ifdef injections
    return bot != None && bot.augsOnly;
#elseif hx
    return false;
#else
    return #var(injectsprefix)MedicalBot(bot) != None && #var(injectsprefix)MedicalBot(bot).augsOnly;
#endif
}

function Tick(float deltaTime)
{
    if(#defined(gmdx) || #defined(vmd)) {
        Super.Tick(deltaTime);
        return;
    }

    if(medBot == None || medBot.bDeleteMe || player == None || player.bDeleteMe) {
        player = None;
        medBot = None;
        DestroyWindow();
        return;
    }

    UpdateMedBotDisplay();
    UpdateRegionWindows();
}
