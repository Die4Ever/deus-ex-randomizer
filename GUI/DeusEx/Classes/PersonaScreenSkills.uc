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

    if(#defined(vmd)) return; // VMD has different calculations

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
    local int levelBefore;
    local DXRando dxr;

    if (selectedSkill!=None){
        levelBefore=selectedSkill.CurrentLevel;
    }

    Super.UpgradeSkill();
    UpdateSwimSpeed();
    UpdateSkillBanned(selectedSkillButton);

    if (selectedSkill!=None){
        if (selectedSkill.CurrentLevel!=levelBefore){
            //Skill upgraded
            foreach player.AllActors(class'DXRando',dxr){break;}
            class'DXREvents'.static.MarkBingo(dxr,"SkillUpgraded"); //General "Upgrade x skills" kind of situation
            class'DXREvents'.static.MarkBingo(dxr,selectedSkill.Class.Name$"Upgraded"); //Skill-specific upgrade goals
            class'DXREvents'.static.MarkBingo(dxr,"SkillLevel"$(selectedSkill.CurrentLevel+1)); //"Get X skills to level Y" type goals
        }
    }
}
