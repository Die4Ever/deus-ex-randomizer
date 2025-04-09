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
    if( s.CurrentLevel < ArrayCount(s.Cost) && s.GetCost() >= 98999 ) {// VMD adjusts skill costs so we need to be more lenient
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

static function UpdateSwimSpeed(Skill s, #var(prefix)Human p)
{
    local float mult,augLevel;

    if (!s.isA('#var(prefix)SkillSwimming')){
        return;
    }

    if (!p.HeadRegion.Zone.bWaterZone){
        return;
    }

    if(#defined(vmd)) return; // VMD has different calculations

    //Calculation from DeusExPlayer HeadZoneChange
    mult = s.LevelValues[s.CurrentLevel];
    if ( p.Level.NetMode == NM_Standalone || #defined(hx))
	{
        p.WaterSpeed = p.Default.WaterSpeed * mult;
    } else {
#ifndef hx
        if (p.AugmentationSystem!=None){
            augLevel = p.AugmentationSystem.GetAugLevelValue(class'AugAqualung');
            if (augLevel==-1.0){
                p.WaterSpeed = p.Default.mpWaterSpeed * mult;
            } else {
                p.WaterSpeed = p.Default.mpWaterSpeed * 2.0 * mult;
            }
        }
#endif
    }
}

function UpgradeSkill()
{
    local int levelBefore;

    if (selectedSkill!=None){
        levelBefore=selectedSkill.CurrentLevel;
    }

    Super.UpgradeSkill();
    UpdateSwimSpeed(selectedSkill,#var(prefix)Human(player));
    UpdateSkillBanned(selectedSkillButton);

    if (selectedSkill!=None){
        if (selectedSkill.CurrentLevel!=levelBefore){
            //Skill upgraded
            class'DXREvents'.static.MarkBingo("SkillUpgraded"); //General "Upgrade x skills" kind of situation
            class'DXREvents'.static.MarkBingo(selectedSkill.Class.Name$"Upgraded"); //Skill-specific upgrade goals
            class'DXREvents'.static.MarkBingo("SkillLevel"$(selectedSkill.CurrentLevel+1)); //"Get X skills to level Y" type goals
        }
    }
}
