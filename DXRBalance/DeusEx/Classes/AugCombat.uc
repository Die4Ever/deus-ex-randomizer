class DXRAugCombat injects AugCombat;

simulated function TickUse()
{
    local DeusExWeapon weapon;
    local DeusExDecoration deco;
    local DeusExMover mover;

    weapon = DeusExWeapon(Player.inHand);
    if(weapon == None || !weapon.bHandToHand)
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
}
