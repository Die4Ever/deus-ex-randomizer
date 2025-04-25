class DXRMenuScreenNewGameExtended extends DXRMenuScreenNewGame;

#exec TEXTURE IMPORT FILE="Textures\MenuNewGameBackgroundExtended_1.pcx"	NAME="MenuNewGameBackgroundExtended_1"	GROUP="DXRandoUI" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\MenuNewGameBackgroundExtended_2.pcx"	NAME="MenuNewGameBackgroundExtended_2"	GROUP="DXRandoUI" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\MenuNewGameBackgroundExtended_3.pcx"	NAME="MenuNewGameBackgroundExtended_3"	GROUP="DXRandoUI" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\MenuNewGameBackgroundExtended_4.pcx"	NAME="MenuNewGameBackgroundExtended_4"	GROUP="DXRandoUI" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\MenuNewGameBackgroundExtended_5.pcx"	NAME="MenuNewGameBackgroundExtended_5"	GROUP="DXRandoUI" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\MenuNewGameBackgroundExtended_6.pcx"	NAME="MenuNewGameBackgroundExtended_6"	GROUP="DXRandoUI" MIPS=Off

const SkillsColWidth = 141;
const SkillLevelColWidth = 68;
const SkillValueColWidth = 34;
const SkillCostColWidth = 51;
const SkillCostLeftPad = 9;

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
    y = 19;

    // Col 0
    // Because this column's header and cell contents have different font sizes,
    // the header needs some adjustment to visually align with the cell
    // contents.
    winLabel = CreateMenuLabel(x + 3, y - 2, HeaderSkillsLabel, winClient);

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

defaultproperties
{
    clientTextures(0)=Texture'MenuNewGameBackgroundExtended_1'
    clientTextures(1)=Texture'MenuNewGameBackgroundExtended_2'
    clientTextures(2)=Texture'MenuNewGameBackgroundExtended_3'
    clientTextures(3)=Texture'MenuNewGameBackgroundExtended_4'
    clientTextures(4)=Texture'MenuNewGameBackgroundExtended_5'
    clientTextures(5)=Texture'MenuNewGameBackgroundExtended_6'
}
