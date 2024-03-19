class DXRAugTarget injects AugTarget;

simulated function TickUse()
{
    if(DeusExRootWindow(Player.rootWindow).winCount > 0)
        return; // don't tick while reading item descriptions
    if (Player.inHand!=None && DeusExWeapon(Player.inHand)!=None && DeusExWeapon(Player.inHand).bHandToHand && (DeusExWeapon(Player.inHand).ProjectileClass == None)){
        return; // don't tick for melee
    }
    Super.TickUse();
}

defaultproperties
{
    bAutomatic=true
}
