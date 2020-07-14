class DXREnemies extends DXRActorsBase;

function FirstEntry()
{
    Super.FirstEntry();
    RandoEnemies(dxr.flags.enemiesrandomized);
}

function RandoEnemies(int percent)
{
    local int num, i;
    local ScriptedPawn p;

    l("RandoEnemies "$percent);

    SetSeed( "RandoEnemies" );

    foreach AllActors(class'ScriptedPawn', p)
    {
        if( SkipActor(p, 'ScriptedPawn') ) continue;
        if( p.bImportant || p.bInvincible ) continue;
        if( IsInitialEnemy(p) == False ) continue;
        if( rng(100) >= percent ) continue;
        //num++;
        CloneScriptedPawn(p);
    }
}

function bool IsInitialEnemy(ScriptedPawn p)
{
    local int i;

    return p.GetPawnAllianceType(dxr.Player) == ALLIANCE_Hostile;

    /*for(i=0; i<ArrayCount(p.InitialAlliances); i++)
    {
        if( p.InitialAlliances[i].AllianceName == 'Player' ) {
            if( p.InitialAlliances[i].AllianceLevel < 0 ) return True;
            else return False;
        }
    }

    return False;*/
}

function ScriptedPawn CloneScriptedPawn(ScriptedPawn p, optional class<ScriptedPawn> newclass)
{
    local int i;
    local ScriptedPawn n;
    local float radius;
    local vector loc;

    if( p == None ) {
        l("p == None?");
        return None;
    }
    if( newclass == None ) newclass = p.class;
    radius = p.CollisionRadius;
    loc = p.Location + (radius*vect(3, 1, 0));
    n = Spawn(newclass,,, loc );
    if( n == None ) {
        l("failed to clone "$ActorToString(p)$" into class "$newclass$" into "$loc);
        return None;
    }

    l("cloning "$ActorToString(p)$" into class "$newclass$" got "$ActorToString(n));

    n.Alliance = p.Alliance;
    for(i=0; i<ArrayCount(n.InitialAlliances); i++ )
    {
        n.InitialAlliances[i] = p.InitialAlliances[i];
    }
    for(i=0; i<ArrayCount(n.InitialInventory); i++ )
    {
        n.InitialInventory[i] = p.InitialInventory[i];
    }
    //Orders = 'Patrolling', Engine.PatrolPoint with Nextpatrol?
    //bReactAlarm, bReactCarcass, bReactDistress, bReactFutz, bReactLoudNoise, bReactPresence, bReactProjectiles, bReactShot
    //bFearAlarm, bFearCarcass, bFearDistress, bFearHacking, bFearIndirectInjury, bFearInjury, bFearProjectiles, bFearShot, bFearWeapon
    return n;
}
