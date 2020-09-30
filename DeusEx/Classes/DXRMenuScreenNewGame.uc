class DXRMenuScreenNewGame extends MenuScreenNewGame;

var DXRando dxr;
var DXRFlags flags;

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
	editName.SetText(player.TruePlayerName);

	player.SkillPointsAvail = player.Default.SkillPointsAvail;
	player.SkillPointsTotal = player.Default.SkillPointsTotal;

	portraitIndex = 0;
	btnPortrait.SetBackground(texPortraits[portraitIndex]);

    if( flags.skills_disable_downgrades == 0 ) {
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

    //if( flags.disable_skill_downgrades )
        //btnDowngrade.SetSensitivity( False );

	if ( selectedSkill != None )
        level = selectedSkill.GetCurrentLevel();

    allow_downgrade = level > 0;
    allow_downgrade = allow_downgrade && level > flags.skills_disable_downgrades;
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
    local Skill aSkill;
    local int skillIndex;
    
    if(dxr!=None) {
        dxrs = DXRSkills(dxr.FindModule(class'DXRSkills'));
        if( dxrs != None )
            dxrs.RandoSkills();
    }

    skillIndex = 0;

    aSkill = player.SkillSystem.FirstSkill;
    while(aSkill != None)
    {
        localSkills[skillIndex] = player.Spawn(aSkill.Class);
        localSkills[skillIndex].Cost[0] = aSkill.Cost[0];
        localSkills[skillIndex].Cost[1] = aSkill.Cost[1];
        localSkills[skillIndex].Cost[2] = aSkill.Cost[2];

        skillIndex++;
        aSkill = aSkill.next;
    }
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
}

defaultproperties
{
}
