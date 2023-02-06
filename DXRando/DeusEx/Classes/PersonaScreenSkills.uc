class DXRPersonaScreenSkills injects #var(prefix)PersonaScreenSkills;

function UpdateSkillBanned(PersonaSkillButtonWindow b)
{
    local Skill s;
    if( b == None || b.skill == None )
        return;
    s = b.skill;
    b.winPointsNeeded.SetPos(260, 0);
    b.winPointsNeeded.SetSize(38, 27);
    b.winPointsNeeded.SetTextAlignments(HALIGN_Left, VALIGN_Center);
    if( s.GetCost() >= 98999 ) {// VMD adjusts skill costs so we need to be more lenient
        //b.winPointsNeeded.SetText(b.NotAvailableLabel);
        b.winPointsNeeded.SetText("BANNED");
    }
}

function CreateSkillsList()
{
    local int i;

    Super.CreateSkillsList();

    for(i=0; i<ArrayCount(skillButtons); i++) {
        UpdateSkillBanned(skillButtons[i]);
    }
}

function UpdateSwimSpeed()
{
    local float mult,augLevel;

    if (!selectedSkill.isA('SkillSwimming')){
        return;
    }

    if (!player.HeadRegion.Zone.bWaterZone){
        return;
    }

    //Calculation from DeusExPlayer HeadZoneChange
    mult = selectedSkill.LevelValues[selectedSkill.CurrentLevel];
    if ( player.Level.NetMode == NM_Standalone )
	{
        player.WaterSpeed = player.Default.WaterSpeed * mult;
    } else {
        if (player.AugmentationSystem!=None){
            augLevel = player.AugmentationSystem.GetAugLevelValue(class'AugAqualung');
            if (augLevel==-1.0){
                player.WaterSpeed = Human(player).Default.mpWaterSpeed * mult;
            } else {
                player.WaterSpeed = Human(player).Default.mpWaterSpeed * 2.0 * mult;
            }
        }
    }
}

function UpgradeSkill()
{
    Super.UpgradeSkill();
    UpdateSwimSpeed();
    UpdateSkillBanned(selectedSkillButton);
}
