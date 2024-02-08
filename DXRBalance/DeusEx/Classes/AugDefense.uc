class DXRAugDefense injects AugDefense;

simulated function DeusExProjectile FindNearestProjectile()
{
    local DeusExProjectile proj;
    local float dist;

    proj = Super.FindNearestProjectile();
    if(proj != None) {
        dist = VSize(Player.Location - proj.Location);
        if (dist < LevelValues[CurrentLevel]) {
            TickUse();
        }
    }
    return proj;
}

defaultproperties
{
    bAutomatic=true
}
