class OATMenuAugsSelectorDXRando extends OATMenuAugsSelector;

function CreateControls()
{
    local int i;

    Super.CreateControls();

    for (i=0; i<ArrayCount(PageLabels); i++)
    {
        if (PageLabels[i]!=None){
            PageLabels[i].SetFont(Font'DXRFontMenuHeaders_DS'); //Better font
        }
    }
}

function bool BuildAugList()
{
	local Augmentation TAug, AllAugs[32];
    local int total, i, j, num;

	if (Player == None) return false;

    // fill temporary array of player's augs
    for(TAug = Player.AugmentationSystem.FirstAug; TAug != None; TAug = TAug.Next)
	{
        if ((TAug.bHasIt) && (!TAug.bAlwaysActive) && (TAug.HotkeyNum > 2) && (TAug.HotkeyNum < 13))
        {
            // priority augs
            switch(TAug.class) {
            case class'AugSpeed':
            case class'AugStealth':
            case class'AugOnlySpeed':
            case class'AugJump':
            case class'AugNinja':
                Augs[num++] = TAug;
                break;

            default:
                AllAugs[total++] = TAug;
                break;
            }
        }
    }

    // manual augs
    for(i=0; i<total; i++) {
        if(AllAugs[i] == None) continue;
        if(!AllAugs[i].bAutomatic) {
            Augs[num++] = AllAugs[i];
            AllAugs[i] = None;
        }
    }

    // auto augs
    for(i=0; i<total; i++) {
        if(AllAugs[i] == None) continue;
        Augs[num++] = AllAugs[i];
        AllAugs[i] = None;
    }

    return num>0;
}
