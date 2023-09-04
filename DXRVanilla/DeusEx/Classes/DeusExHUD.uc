class DXRandoHUD merges DeusExHUD;

var HUDEnergyDisplay  energy;
var HUDSpeedrunSplits splits;

event InitWindow()
{
    _InitWindow();

    energy = HUDEnergyDisplay(NewChild(Class'HUDEnergyDisplay'));
    splits = HUDSpeedrunSplits(NewChild(Class'HUDSpeedrunSplits'));
}

event DescendantRemoved(Window descendant)
{
    _DescendantRemoved(descendant);

    if (descendant == energy){
        energy = None;
    } else if (descendant == splits){
        splits = None;
    }
}

function ConfigurationChanged()
{
    local float energyWidth, energyHeight, splitsWidth, splitsHeight;
    local float width, hitHeight, compassHeight, beltWidth, beltHeight;

    _ConfigurationChanged();

    //Put the energy display right under the compass
    if (energy != None)
    {
        energy.QueryPreferredSize(energyWidth, energyHeight);

        if (compass!=None){compass.QueryPreferredSize(width,compassHeight);}
        if (hit!=None){hit.QueryPreferredSize(width,hitHeight);}

        energy.ConfigureChild(0, hitHeight + compassHeight + 8, energyWidth, energyHeight);
    }

    //Put the speedrun splits in the bottom left corner
    if (splits != None)
    {
        splits.QueryPreferredSize(splitsWidth, splitsHeight);
        if (belt != None) belt.QueryPreferredSize(beltWidth, beltHeight);

        splits.ConfigureChild(0, height - beltHeight - splitsHeight - 8, splitsWidth, splitsHeight);
    }
}
