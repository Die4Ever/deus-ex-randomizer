class DXROrdersTrigger injects #var(prefix)OrdersTrigger;

#ifdef hx
function StartPatrolling()
#else
function bool StartPatrolling()
#endif
{
    local ScriptedPawn P;
    local name newTag;

#ifdef hx
    if(Event == '') return;
#else
    if(Event == '') return True;
#endif

    newtag = StringToName(Event $ "_clone");

    // find the target NPC to start on the patrol route
    foreach AllActors (class'ScriptedPawn', P) {
        if( P.Tag != Event && P.Tag != newtag ) continue;

        if(Orders=='Idle' && Robot(P)==None) {
            P.HealthTorso = 0;
            P.Health = 0;
            P.TakeDamage(1, P, P.Location, vect(0,0,0), 'Shot');
        }
        else
            P.SetOrders(Orders, ordersTag, True);
    }

#ifndef hx
    return True;
#endif
}

#ifndef hx
function Name StringToName(string s)
{
    local DeusExPlayer player;
    player = DeusExPlayer(GetPlayerPawn());
    return player.rootWindow.StringToName(s);
}
#endif
