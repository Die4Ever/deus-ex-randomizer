class DXRVialCrack injects VialCrack;

state Activated
{
    function BeginState()
    {
        local DeusExPlayer player;

        Super(DeusExPickup).BeginState();

        player = DeusExPlayer(Owner);
        if (player != None)
        {
            player.drugEffectTimer += 60.0;
            player.TakeDamage(10, player, player.Location, vect(0,0,0), 'PoisonGas'); // `player.HealPlayer(-10, False)` does nothing
        }

        UseOnce();
    }
}
