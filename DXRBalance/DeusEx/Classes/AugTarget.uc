class DXRAugTarget injects AugTarget;

simulated function TickUse()
{
    if(DeusExRootWindow(Player.rootWindow).winCount > 0)
        return; // don't tick while reading item descriptions
    Super.TickUse();
}

defaultproperties
{
    bAutomatic=true
}
