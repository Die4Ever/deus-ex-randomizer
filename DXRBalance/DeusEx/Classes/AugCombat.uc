class DXRAugCombat injects AugCombat;

simulated function TickUse()
{
    local DeusExWeapon weapon;
    local DeusExDecoration deco;
    local DeusExMover mover;

    weapon = DeusExWeapon(Player.inHand);
    if(weapon == None || !weapon.bHandToHand || weapon.ProjectileClass!=None)
        return;
    if(weapon.GetStateName() != 'NormalFire')
        return;

    deco = DeusExDecoration(Player.FrobTarget);
    if(deco != None && deco.minDamageThreshold <=1 && deco.HitPoints <= 10)
        return;

    mover = DeusExMover(Player.FrobTarget);
    if(mover != None && mover.minDamageThreshold <= 1 && mover.doorStrength < 0.1)
        return;

    Super.TickUse();
}

defaultproperties
{
    bAutomatic=true
    AutoLength=2.2// combat aug specifically makes sense to only use energy while active? a little extra so it doesn't fall in between ticks?
}
