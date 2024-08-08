class DXRandoRootWindow merges DeusExRootWindow;
// merges because DeusExRootWindow depends on int entries

var HUDSpeedrunSplits splits;

var localized String LoadLatestTitle;
var localized String LoadLatestMessage;

event InitWindow()
{
    _InitWindow();

    splits = HUDSpeedrunSplits(NewChild(Class'HUDSpeedrunSplits'));
    splits.SetWindowAlignments(HALIGN_Full, VALIGN_Full, 0, 0);
}

event DescendantRemoved(Window descendant)
{
    _DescendantRemoved(descendant);
    if ( descendant == splits )
        splits = None;
}

function bool GetNoPause(bool bNoPause) {
    local DXRFlags flags;

    foreach parentPawn.AllActors(class'DXRFlags', flags) {
        if(!bNoPause && flags.settings.menus_pause == 0) {
            bNoPause = true;
            PartialHideHud();
        }
    }

    return bNoPause;
}

function DeusExBaseWindow PopWindow(optional Bool bNoUnpause)
{
    local float f;
    local DeusExMover m;
    local HackableDevices h;
    local SkilledTool tool;
    local bool bFixGlitches;

    bFixGlitches = class'MenuChoice_FixGlitches'.default.enabled;

    // check for super jumps
    f = DeusExPlayer(parentPawn).AugmentationSystem.GetAugLevelValue(class'AugSpeed');
    if(bFixGlitches && f > 0 && parentPawn.JumpZ > parentPawn.default.JumpZ * f) {
        parentPawn.JumpZ = parentPawn.default.JumpZ * f;
    }
    else if(f > 0 && parentPawn.JumpZ > parentPawn.default.JumpZ * f*1.3) {
        class'DXRStats'.static.AddCheatOffense(DeusExPlayer(parentPawn));
    }

    if(bFixGlitches && !bNoUnPause) {
        foreach parentPawn.AllActors(class'DeusExMover', m) {
            if(!m.bPicking) continue;
            m.LastTickTime = m.Level.TimeSeconds;
        }
        foreach parentPawn.AllActors(class'HackableDevices', h) {
            if(!h.bHacking) continue;
            h.LastTickTime = h.Level.TimeSeconds;
        }
    }
    else if(!bFixGlitches && !bNoUnPause) {
        // check for using tools during paused menus, the issue is in DeusExMover::Timer and HackableDevices::Timer
        foreach parentPawn.AllActors(class'SkilledTool', tool) {
            if(!tool.IsInState('UseIt')) continue;
            if(NanoKeyRing(tool) != None) continue;
            class'DXRStats'.static.AddCheatOffense(DeusExPlayer(parentPawn));
            break;
        }
    }

    _PopWindow(bNoUnpause);
}

function DeusExBaseWindow InvokeMenuScreen(Class<DeusExBaseWindow> newScreen, optional bool bNoPause)
{
    log("DXRandoRootWindow InvokeMenuScreen "$newScreen);
    return _InvokeMenuScreen(newScreen, GetNoPause(bNoPause));
}

function InvokeMenu(Class<DeusExBaseWindow> newMenu)
{
    log("DXRandoRootWindow InvokeMenu "$newMenu);
    _InvokeMenu(newMenu);
}

function DeusExBaseWindow InvokeUIScreen(Class<DeusExBaseWindow> newScreen, optional Bool bNoPause)
{
    log("DXRandoRootWindow InvokeUIScreen "$newScreen);
    return _InvokeUIScreen(newScreen, GetNoPause(bNoPause));
}

function ConfirmLoadLatest()
{
    local MenuUIMessageBoxWindow msgBox;

    msgBox = MessageBox(LoadLatestTitle, LoadLatestMessage, 0, False, Self);
    msgBox.SetDeferredKeyPress(True);
}

function ShowHud(bool bShow)
{
    if(splits!= None && bShow) splits.UpdateVisibility();
    else if(splits!= None) splits.Hide();

    if (hud != None)
    {
        if (bShow)
        {
            hud.UpdateSettings(DeusExPlayer(parentPawn));
            hud.Show();
            hud.PartialShow(true);// DXRando
            scopeView.ShowView();
        }
        else
        {
            hud.Hide();
            scopeView.HideView();
        }
    }
}

function PartialHideHud()
{
    if(hud != None) {
        hud.PartialShow(false);
    }
    if(splits!= None) splits.Show(false);
}

// ----------------------------------------------------------------------
// BoxOptionSelected()
// ----------------------------------------------------------------------

event bool BoxOptionSelected(Window messagebox, int buttonNumber)
{
    local string s;

    s = MenuUIMessageBoxWindow(messagebox).winText.GetText();
    // Destroy the msgbox!
    PopWindow();

    if (buttonNumber == 0 && s == QuickLoadMessage) {
        DeusExPlayer(parentPawn).QuickLoadConfirmed();
    }
    else if(buttonNumber == 0 && s == LoadLatestMessage) {
        Human(parentPawn).LoadLatestConfirmed();
    }

    return true;
}

// maybe fix some alt+tab issues

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
    local bool bKeyHandled;
    local DeusExPlayer Player;
    local bool accelKey;

    Player = DeusExPlayer(parentPawn);

    bKeyHandled = True;

    Super.VirtualKeyPressed(key, bRepeat);// we are merges, so this calls DeusExRootWindow's Super

    // Check for Ctrl-F9, which is a hard-coded key to take a screenshot
    if ( IsKeyDown( IK_Ctrl ) && ( key == IK_F9 ))
    {
        parentPawn.ConsoleCommand("SHOT");
        return True;
    }

    // DXRando: escape takes priority over alt, due to alt+tab issues
    accelKey = key >= IK_A && key <= IK_Z;
    if ( accelKey && (IsKeyDown( IK_Alt ) || IsKeyDown( IK_Shift ) || IsKeyDown( IK_Ctrl )))
        return False;

    // When player dies in multiplayer...
    if ((Player != None) && (Player.Health <= 0) && (Player.Level.NetMode != NM_Standalone))
    {
        if (( MultiplayerMessageWin(GetTopWindow()) != None ) && ( key == IK_Escape ))
        {
            PopWindow();
            Player.ShowMainMenu();
        }
        return True;
    }

    // Check if this is a DataVault key
    if (!ProcessDataVaultSelection(key))
    {
        switch( key )
        {
            // Hide the screen if the Escape key is pressed
            // Temp: Also if the Return key is pressed
            case IK_Escape:
                PopWindow();
                break;

            // We want Print Screen to work in UI screens
            case IK_PrintScrn:
                parentPawn.ConsoleCommand("SHOT");
                break;

    //		case IK_GreyMinus:
    //			PushWindow(Class'MenuScreenRGB');
    //			break;

            default:
                bKeyHandled = False;
        }
    }

    return bKeyHandled;
}


defaultproperties
{
    LoadLatestTitle="Load Latest Save?"
    LoadLatestMessage="You will lose your current game in progress, are you sure you wish to Load?"
}
