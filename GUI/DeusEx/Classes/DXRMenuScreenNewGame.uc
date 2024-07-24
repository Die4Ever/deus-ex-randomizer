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

const SkillsColWidth = 140;
const SkillLevelColWidth = 70;
const SkillValueColWidth = 34;
const SkillCostColWidth = 51;
const SkillCostLeftPad = 10;

static function bool HasLDDPInstalled()
{
    local DeusExTextParser parser;
    local bool opened;

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
    if(flags.moresettings.splits_overlay > 0)
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
                  aSkill.GetCurrentLevelString() $ ";" $
                  BuildSkillStrengthString( aSkill, 0) $ ";" $
                  BuildSkillStrengthString( aSkill, 1) $ ";" $
                  BuildSkillStrengthString( aSkill, 2) $ ";" $
                  BuildSkillStrengthString( aSkill, 3) $ ";" $
                  levelCost;

    return skillString;
}

function String BuildSkillStrengthString( Skill aSkill, int i )
{
    local DXRSkills dxrs;
    local String prefix;
    local float val;

    if( dxr!=None )
    {
        dxrs = DXRSkills(dxr.FindModule(class'DXRSkills'));
    }

    // This helps visually indicate which skill strength the player possess
    // at their current skill training.
    if ( aSkill.GetCurrentLevel()==i )
    {
        prefix = ">";
    }
    else
    {
        prefix = " ";
    }

    val = aSkill.levelValues[i];
    return prefix $ dxrs.DescriptionLevelShort(aSkill, i, val);
}

function CreateTextHeaders()
{
    local MenuUILabelWindow winLabel;
    local int x;
    local int y;

    CreateMenuLabel(21, 17, HeaderCodeNameLabel, winClient);
    CreateMenuLabel(21, 73, HeaderNameLabel, winClient);
    CreateMenuLabel(21, 133, HeaderAppearanceLabel, winClient);
    CreateMenuLabel(409, 344, HeaderSkillPointsLabel,  winClient);

    // ...Skill Table Headers Start Here...
    x = 172;
    y = 18;

    // Col 0
    // Because this column's header and cell contents have different font sizes,
    // the header needs some adjustment to visually align with the cell
    // contents.
    winLabel = CreateMenuLabel(x + 3, y - 1, HeaderSkillsLabel, winClient);

    // I'm not sure quite sure why, but nudging the other headers by a small
    // amount makes them look more aligned with their cell contents.
    x = x + 2;

    // Col 1
    x = x + SkillsColWidth;
    winLabel = CreateMenuLabel(x, y, HeaderSkillLevelLabel, winClient);
    winLabel.SetFont(Font'FontMenuSmall');

    // Col 2-6
    x = x + SkillLevelColWidth;
    winLabel = CreateMenuLabel(x, y, "Skill Strength", winClient);
    winLabel.SetFont(Font'FontMenuSmall');

    // Col 7
    x = x + SkillValueColWidth * 4 + SkillCostLeftPad;
    winLabel = CreateMenuLabel(x, y, "Cost", winClient);
    winLabel.SetFont(Font'FontMenuSmall');
}

function CreateSkillsListWindow()
{
    local int i;

    // The size of the skill list is (397, 150).
    // The position of the table is (172, 41).
    // So, the widths should sum up to 397.
    Super.CreateSkillsListWindow();

    lstSkills.SetNumColumns(7);
    lstSkills.SetColumnWidth(0, SkillsColWidth);
    lstSkills.SetColumnWidth(1, SkillLevelColWidth);
    lstSkills.SetColumnWidth(2, SkillValueColWidth);
    lstSkills.SetColumnWidth(3, SkillValueColWidth);
    lstSkills.SetColumnWidth(4, SkillValueColWidth);
    lstSkills.SetColumnWidth(5, SkillValueColWidth + SkillCostLeftPad);
    lstSkills.SetColumnWidth(6, SkillCostColWidth - SkillCostLeftPad);
    
    for( i=0; i<7; i++ )
    {
        lstSkills.SetColumnAlignment(i, HALIGN_Left);
    }
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
    player.ShowIntro(True);
}

function CreateActionButtons()
{
    Super.CreateActionButtons();
    actionButtons[3].btn.Hide();
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
