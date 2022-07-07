class DXRSwapItems extends DXRActorsBase;

var config string swap_actors[16];

function CheckConfig()
{
    local int i;
    if( ConfigOlderThan(1,5,9,8) ) {
        for(i=0; i < ArrayCount(swap_actors); i++) {
            swap_actors[i] = "";
        }
        i=0;
        swap_actors[i++] = "Engine.Inventory";
#ifdef hx
        swap_actors[i++] = "HX.HXContainers";
#else
        swap_actors[i++] = "Containers";
#endif
    }
    Super.CheckConfig();
}

function FirstEntry()
{
    local int i;
    local float chance;
    local string c;
    Super.FirstEntry();

    for(i=0; i < ArrayCount(swap_actors); i++) {
        if( swap_actors[i] == "" ) continue;

        c = swap_actors[i];
        chance = 100;
        if( c == "Engine.Inventory" )
            chance = dxr.flags.settings.swapitems;
#ifdef hx
        else if( c == "HX.HXContainers" )
            chance = dxr.flags.settings.swapcontainers;
#else
        else if( c == "Containers" )
            chance = dxr.flags.settings.swapcontainers;
#endif
        l("swapping swap_actors["$i$"]: "$c$", chance: "$chance);
        SwapAll(c, chance);
        l("done swapping swap_actors["$i$"]: "$c);
    }
}
