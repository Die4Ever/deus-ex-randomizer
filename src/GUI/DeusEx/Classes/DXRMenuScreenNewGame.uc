#ifdef revision
class DXRMenuScreenNewGame extends RevMenuScreenNewGame;
#else
class DXRMenuScreenNewGame extends MenuScreenNewGame;
#endif

var DXRando dxr;
var DXRFlags flags;
var config string last_player_name;
var config int last_portrait;
var bool hasCheckedLDDP;
var MenuUIActionButtonWindow btnRandomPortrait;
#ifndef injections
var bool bFemaleEnabled;
#endif

static function bool HasLDDPInstalled()
{
    local DeusExTextParser parser;
    local bool opened;

    if(#defined(revision)) return true; //Revision always has LDDP available

    if(!#defined(injections)) return false;// just to be safe if you have a lot of mods installed in the same folder, Revision and VMD still allow selecting FemJC

    if(default.hasCheckedLDDP) {
        return default.bFemaleEnabled;
    }

    //LDDP, 10/26/21: Attempt a load. If succesful, we have LDDP installed. Thus, we can flick on all the female functionality.
    // DXRando check for a text file instead of a texture, so we can install in pieces
    parser = new(None) Class'DeusExTextParser';
    opened = parser.OpenText('FemJC02_Email01', "DeusExText");
    if(opened)
        parser.CloseText();
    CriticalDelete(parser);

    default.bFemaleEnabled = opened;
    default.hasCheckedLDDP = true;
    return opened;
}

event InitWindow()
{
    local int i;

    bFemaleEnabled = HasLDDPInstalled();

    Super(MenuUIScreenWindow).InitWindow();

    if (bFemaleEnabled && !#defined(revision)) //Revision has all male, then all female ordering instead of interleaved
    {
        TexPortraits[0] = Texture(DynamicLoadObject("FemJC.MenuPlayerSetupJCDentonMale_1", class'Texture', false));
        TexPortraits[1] = Texture(DynamicLoadObject("FemJC.MenuPlayerSetupJCDentonFemale_1", class'Texture', false));
        TexPortraits[2] = Texture(DynamicLoadObject("FemJC.MenuPlayerSetupJCDentonMale_2", class'Texture', false));
        TexPortraits[3] = Texture(DynamicLoadObject("FemJC.MenuPlayerSetupJCDentonFemale_2", class'Texture', false));
        TexPortraits[4] = Texture(DynamicLoadObject("FemJC.MenuPlayerSetupJCDentonMale_3", class'Texture', false));
        TexPortraits[5] = Texture(DynamicLoadObject("FemJC.MenuPlayerSetupJCDentonFemale_3", class'Texture', false));
        TexPortraits[6] = Texture(DynamicLoadObject("FemJC.MenuPlayerSetupJCDentonMale_4", class'Texture', false));
        TexPortraits[7] = Texture(DynamicLoadObject("FemJC.MenuPlayerSetupJCDentonFemale_4", class'Texture', false));
        TexPortraits[8] = Texture(DynamicLoadObject("FemJC.MenuPlayerSetupJCDentonMale_5", class'Texture', false));
        TexPortraits[9] = Texture(DynamicLoadObject("FemJC.MenuPlayerSetupJCDentonFemale_5", class'Texture', false));
    }

    SaveSkillPoints();
    ResetToDefaults();

    //Pick a random portrait
    if (class'MenuChoice_JCGenderSkin'.static.IsRandom()){
        SelectRandomPortrait(false); //Randomly select one of the portraits
    } else if (class'MenuChoice_JCGenderSkin'.static.IsRemember()) {
        SelectPortrait(last_portrait); //Select the last portrait used
    }

    // Need to do this because of the edit control used for
    // saving games.
    SetMouseFocusMode(MFOCUS_Click);

    Show();
    SetFocusWindow(editName);
    editName.SetSelectedArea(0, Len(editName.GetText()));
    combatDifficulty = player.Default.CombatDifficulty;

    StyleChanged();
}

function SetDxr(DXRando d)
{
    dxr=d;
    flags = DXRFlags(dxr.FindModule(class'DXRFlags'));

    if(class'MenuChoice_ShowNewSeed'.static.ShowNewSeed(dxr))
        actionButtons[3].btn.Show();
    else
        actionButtons[3].btn.Hide();

    player.SkillPointsAvail = player.Default.SkillPointsAvail;
    player.SkillPointsTotal = player.Default.SkillPointsTotal;
    CopySkills();
    PopulateSkillsList();
    UpdateSkillPoints();
    EnableButtons();
}

function ResetToDefaults()
{
    // force the player to type in a name, it makes Death Markers more fun!
    editName.SetText(last_player_name);

    portraitIndex = 0;
    btnPortrait.SetBackground(texPortraits[portraitIndex]);

    // if skills_disable_downgrades is enabled then we don't want to allow the player to ResetToDefaults as a workaround
    // SetDxr will still init the skills
    if( flags != None && flags.settings.skills_disable_downgrades == 0 ) {
        player.SkillPointsAvail = player.Default.SkillPointsAvail;
        player.SkillPointsTotal = player.Default.SkillPointsTotal;

        CopySkills();
        PopulateSkillsList();
        UpdateSkillPoints();
    }
    EnableButtons();
}

function EnableButtons()
{
    local bool allow_downgrade;
    local int level;
    Super.EnableButtons();

    if ( selectedSkill != None )
        level = selectedSkill.GetCurrentLevel();

    allow_downgrade = level > 0;
    allow_downgrade = allow_downgrade && level > flags.settings.skills_disable_downgrades;
    btnDowngrade.EnableWindow(allow_downgrade);

    EnableActionButton(AB_Other, True, "START");
}

// ----------------------------------------------------------------------
// CopySkills()
//
// Makes a local copy of the skills so we can manipulate them without
// actually making changes to the ones attached to the player.
// ----------------------------------------------------------------------

function CopySkills()
{
    local DXRSkills dxrs;
    local int i;
    local bool bOldZRP;

    // HACK for skill descriptions, which run in a static function
    bOldZRP = class'DXRFlags'.default.bZeroRandoPure;
    class'DXRFlags'.default.bZeroRandoPure = flags.IsZeroRandoPure();

    Super.CopySkills();

    for(i=1; i<ArrayCount(localSkills); i++) {
        if( localSkills[i-1] == None ) break;
        localSkills[i-1].next = localSkills[i];

        if(SkillWeaponPistol(localSkills[i]) != None && localSkills[i].CanAffordToUpgrade(player.SkillPointsAvail)
            && flags != None && flags.IsZeroRando())
        {
            localSkills[i].IncLevel(player);
        }
    }

    if(dxr!=None)
        dxrs = DXRSkills(dxr.FindModule(class'DXRSkills'));
    if( dxrs != None ) {
        dxrs.RandoSkills(localSkills[0]);
    }
    class'DXRFlags'.default.bZeroRandoPure = bOldZRP;
}

function SaveSettings()
{
    local Inventory i;

    foreach player.AllActors(class'Inventory', i) {
        i.Destroy();
    }
    player.Inventory = None;
    dxr.flags.ClearInHand(#var(PlayerPawn)(player));
    player.RestoreAllHealth();
    if (DeusExRootWindow(player.rootWindow) != None)
        DeusExRootWindow(player.rootWindow).ResetFlags();

    Super.SaveSettings();

    dxr.flags.SaveFlags();
    dxr.Destroy();
    foreach player.AllActors(class'DXRando', dxr)
        dxr.Destroy();
    player.ServerSetSloMo(1);//reset game speed to prevent crashes
    last_player_name = player.TruePlayerName;
    last_portrait = portraitIndex;
    SaveConfig();
}

function String BuildSkillString( Skill aSkill )
{
    local String skillString;
    local String levelCost;

    if ( aSkill.GetCurrentLevel() == ArrayCount(aSkill.Cost) )
        levelCost = "--";
    else if( aSkill.GetCost() >= 99999 )
        levelCost = "BANNED";
    else
        levelCost = String(aSkill.GetCost());

    skillString = aSkill.skillName $ ";" $
                  aSkill.GetCurrentLevelString()
                  // space for padding
                  $ "; " $ levelCost;

    return skillString;
}

function CreateSkillsListWindow()
{
    Super.CreateSkillsListWindow();
    lstSkills.SetColumnAlignment(2, HALIGN_Left);
}


function ProcessAction(String actionKey)
{
    local DeusExPlayer		localPlayer;
    local String			localStartMap;
    local String            playerName;

    localPlayer   = player;
//	localStartMap = strStartMap;

    if (actionKey == "NEWSEED")
    {
        flags.RollSeed();
        SetDxr(dxr);
    }
    else if (actionKey == "START")
    {
        // Make sure the name isn't blank
        playerName = TrimSpaceS(editName.GetText());

        if (playerName == "")
        {
            root.MessageBox(NameBlankTitle, NameBlankPrompt, 1, False, Self);
        }
        else
        {
            SaveSettings();
            AddTimer(0.11, false, 0, 'Timer');// timer to wait for items to be destroyed (issue #426), deletes happen every 100ms? probably don't need this anymore with our new ClearInHand() function
        }
    }
    else
        Super.ProcessAction(actionKey);
}

function Timer(int timerID, int invocations, int clientData)
{
    class'DXRFlags'.default.bZeroRandoPure = flags.IsZeroRandoPure(); // make sure the player and augs created use proper defaults
    player.ShowIntro(True);
}

function CreateActionButtons()
{
    Super.CreateActionButtons();
    actionButtons[3].btn.Hide();

    btnRandomPortrait = MenuUIActionButtonWindow(winClient.NewChild(Class'MenuUIActionButtonWindow'));
    btnRandomPortrait.SetButtonText("Random");
    btnRandomPortrait.SetPos(20,316);
    btnRandomPortrait.SetWidth(65);
}

function bool ButtonActivated( Window buttonPressed )
{
    if (buttonPressed==btnRandomPortrait){
        SelectRandomPortrait(true);
        return true;
    }
    return Super.ButtonActivated(buttonPressed);
}

function SelectPortrait(int portraitNum)
{
    portraitIndex=portraitNum;
    btnPortrait.SetBackground(texPortraits[portraitIndex]);
}

function SelectRandomPortrait(bool noRepeat)
{
    local int numPortraits;

    //We could use the size of the array, but Revision has a whole bunch
    //of other options available that I don't think we really want to
    //include in the random pool.
    if (bFemaleEnabled){
        numPortraits=10;
    } else {
        numPortraits=5;
    }

    if (noRepeat){
        //This shouldn't ever pick the same portrait twice in a row,
        //since it can't roll *all* the way around
        portraitIndex=(portraitIndex+Rand(numPortraits-1)+1) % numPortraits;
    } else {
        portraitIndex=(portraitIndex+Rand(numPortraits)) % numPortraits;
    }
    btnPortrait.SetBackground(texPortraits[portraitIndex]);
}

function GiveTip()
{
    // DXRando: disable this because we think it's more confusing than helpful?
    /*if ((Human(Player) == None) || (!Human(Player).bGaveNewGameTips))
    {
        root.MessageBox(CheckboxTipHeader, CheckboxTipText, 1, False, Self);
    }*/
}


defaultproperties
{
    btnLabelResetToDefaults="Restore Defaults"
    actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel)
    actionButtons(3)=(Align=HALIGN_Left,Action=AB_Other,Text="|&New Seed",Key="NEWSEED")
}
