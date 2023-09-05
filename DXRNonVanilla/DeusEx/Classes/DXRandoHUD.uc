#ifdef revision
class DXRandoHUD extends RevHUD;
#else
class DXRandoHUD extends DeusExHUD;
#endif

var HUDSpeedrunSplits splits;

event InitWindow()
{
	Super.InitWindow();

#ifndef vmd
    frobDisplay.Destroy();
    frobDisplay = FrobDisplayWindow(NewChild(Class'DXRFrobDisplayWindow'));
    frobDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
#endif

    splits = HUDSpeedrunSplits(NewChild(Class'HUDSpeedrunSplits'));
}

event DescendantRemoved(Window descendant)
{
    Super.DescendantRemoved(descendant);

    if (descendant == splits){
        splits = None;
    }
}

function ConfigurationChanged()
{
    local float splitsWidth, splitsHeight;
    local float width, beltWidth, beltHeight;

    Super.ConfigurationChanged();

    //Put the speedrun splits in the bottom left corner
    if (splits != None)
    {
        splits.QueryPreferredSize(splitsWidth, splitsHeight);
        if (belt != None) belt.QueryPreferredSize(beltWidth, beltHeight);

        splits.ConfigureChild(0, height - beltHeight - splitsHeight - 8, splitsWidth, splitsHeight);
    }
}
