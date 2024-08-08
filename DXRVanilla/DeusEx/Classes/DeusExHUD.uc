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
    local float width, hitHeight, compassHeight;

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

function PartialShow(bool bShow)
{
    if(!bShow) { // UpdateSettings should take care of most of the showing again
        if(belt!=None) belt.Show(bShow);
        if(receivedItems!=None) receivedItems.Show(bShow);
        if(msgLog!=None) msgLog.Show(bShow);
        if(infolink!=None) infolink.Show(bShow);
        if(startDisplay!=None) startDisplay.Show(bShow);
    }
}
