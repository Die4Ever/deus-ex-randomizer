class DXRMenuScreenNewGame extends MenuScreenNewGame;

var DXRando dxr;
var DXRFlags flags;
var config string last_player_name;

function SetDxr(DXRando d)
{
    dxr=d;
    flags = DXRFlags(dxr.FindModule(class'DXRFlags'));
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

defaultproperties
{
    actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel)
}
