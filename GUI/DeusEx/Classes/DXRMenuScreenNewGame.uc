#ifdef revision
class DXRMenuScreenNewGame extends RevMenuScreenNewGame;
#else
class DXRMenuScreenNewGame extends MenuScreenNewGame;
#endif

var DXRando dxr;
var DXRFlags flags;
var config string last_player_name;
var bool hasCheckedLDDP;
#ifndef injections
var bool bFemaleEnabled;
#endif

static function bool HasLDDPInstalled()
{
    local DeusExTextParser parser;
    local bool opened;

    if(!#defined(injections)) return false;// just to be safe if you have a lot of mods installed in the same folder

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

    Super(MenuUIScreenWindow).InitWindow();

    bFemaleEnabled = HasLDDPInstalled();

    if (bFemaleEnabled)
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
    if(flags.IsSpeedrunMode())
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

    player.SkillPointsAvail = player.Default.SkillPointsAvail;
    player.SkillPointsTotal = player.Default.SkillPointsTotal;

    portraitIndex = 0;
    btnPortrait.SetBackground(texPortraits[portraitIndex]);

    // if skills_disable_downgrades is enabled then we don't want to allow the player to ResetToDefaults as a workaround
    // SetDxr will still init the skills
    if( flags != None && flags.settings.skills_disable_downgrades == 0 ) {
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

    Super.CopySkills();

    for(i=0; i<ArrayCount(localSkills); i++) {
        if( SkillWeaponPistol(localSkills[i]) != None ) {
            localSkills[i].DecLevel();
        }
    }

    for(i=1; i<ArrayCount(localSkills); i++) {
        if( localSkills[i-1] == None ) break;
        localSkills[i-1].next = localSkills[i];
    }

    if(dxr!=None)
        dxrs = DXRSkills(dxr.FindModule(class'DXRSkills'));
    if( dxrs != None )
        dxrs.RandoSkills(localSkills[0]);
}

function SaveSettings()
{
    local Inventory i;

    foreach player.AllActors(class'Inventory', i) {
        i.Destroy();
    }
    player.Inventory = None;
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
    SaveConfig();
}

function String BuildSkillString( Skill aSkill )
{
    local String skillString;
    local String levelCost;

    if ( aSkill.GetCurrentLevel() == 3 )
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
            AddTimer(0.1, false, 0, 'Timer');// timer to wait for items to be destroyed (issue #426)
        }
    }
    else
        Super.ProcessAction(actionKey);
}

function Timer(int timerID, int invocations, int clientData)
{
    player.ShowIntro(True);
}

function CreateActionButtons()
{
    Super.CreateActionButtons();
    actionButtons[3].btn.Hide();
}

defaultproperties
{
    actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel)
    actionButtons(3)=(Align=HALIGN_Left,Action=AB_Other,Text="|&New Seed",Key="NEWSEED")
}
