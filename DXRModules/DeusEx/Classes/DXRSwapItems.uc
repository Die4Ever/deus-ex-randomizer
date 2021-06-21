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
    local class<Actor> c;
    Super.FirstEntry();

    for(i=0; i < ArrayCount(swap_actors); i++) {
        if( swap_actors[i] == "" ) continue;

        c = GetClassFromString(swap_actors[i], class'Actor');
        chance = 100;
        if( c == class'Inventory' )
            chance = dxr.flags.settings.swapitems;
#ifdef hx
        else if( c == class'HXContainers' )
            chance = dxr.flags.settings.swapcontainers;
#else
        else if( c == class'Containers' )
            chance = dxr.flags.settings.swapcontainers;
#endif
        l("swapping swap_actors["$i$"]: "$swap_actors[i]$", chance: "$chance);
        SwapAll(c.name, chance);
        l("done swapping swap_actors["$i$"]: "$swap_actors[i]);
    }
}
