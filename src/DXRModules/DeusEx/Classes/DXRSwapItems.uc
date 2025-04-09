class DXRSwapItems extends DXRActorsBase transient;

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
    local Trigger lasers[128];
    local BeamTrigger bt;
    local LaserTrigger lt;
    local int num_lasers;

    Super.FirstEntry();

    foreach AllActors(class'BeamTrigger', bt) {
        if(bt.bAlreadyTriggered) continue;
        bt.bAlreadyTriggered = true;
        lasers[num_lasers++] = bt;
    }
    foreach AllActors(class'LaserTrigger', lt) {
        if(lt.bNoAlarm) continue;
        lt.bNoAlarm = true;
        lasers[num_lasers++] = lt;
    }

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

    for(i=0; i<num_lasers; i++) {
        bt = BeamTrigger(lasers[i]);
        lt = LaserTrigger(lasers[i]);
        if(bt != None) {
            bt.emitter.CalcTrace(0);
            bt.Tick(0);
            bt.bAlreadyTriggered = false;
        }
        else if(lt != None) {
            lt.emitter.CalcTrace(0);
            lt.Tick(0);
            lt.bNoAlarm = false;
        }
    }
}
