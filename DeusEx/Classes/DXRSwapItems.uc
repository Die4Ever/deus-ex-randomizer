class DXRSwapItems extends DXRActorsBase;

var config class<Actor> swap_actors[16];

function CheckConfig()
{
    local int i;
    if( config_version == 0 ) {
        for(i=0; i < ArrayCount(swap_actors); i++) {
            swap_actors[i] = None;
        }
        i=0;
        swap_actors[i++] = class'Inventory';
        swap_actors[i++] = class'Containers';
    }
    Super.CheckConfig();
}

function FirstEntry()
{
    local int i;
    Super.FirstEntry();

    for(i=0; i < ArrayCount(swap_actors); i++) {
        if( swap_actors[i] != None )
            SwapAll(swap_actors[i].name);
    }
}
