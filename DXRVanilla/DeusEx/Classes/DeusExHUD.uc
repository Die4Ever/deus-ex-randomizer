class DXRandoHUD merges DeusExHUD;

var HUDEnergyDisplay  energy;

event InitWindow()
{
    _InitWindow();

    energy = HUDEnergyDisplay(NewChild(Class'HUDEnergyDisplay'));
}

event DescendantRemoved(Window descendant)
{
    _DescendantRemoved(descendant);

    if (descendant == energy){
        energy = None;
    }
}

function ConfigurationChanged()
{
	local float energyWidth, energyHeight;
    local float width,hitHeight,compassHeight;

    _ConfigurationChanged();

    //Put the energy display right under the compass
    if (energy != None)
    {
		energy.QueryPreferredSize(energyWidth, energyHeight);

        if (compass!=None){compass.QueryPreferredSize(width,compassHeight);}
        if (hit!=None){hit.QueryPreferredSize(width,hitHeight);}

		energy.ConfigureChild(0, hitHeight + compassHeight + 8, energyWidth, energyHeight);

    }
}
