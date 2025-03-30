class VendingMachineEnergy extends #var(injectsprefix)VendingMachine;

function class<Pickup> GetSpawnClass()
{
    return class'EnergyDrinkCan';
}

function DoSpawn(actor Frobber, Inventory frobWith)
{
    local DeusExPlayer player;
    local Vector loc;
    local Pickup product;

    Super(#var(prefix)ElectronicDevices).Frob(Frobber, frobWith);

    player = DeusExPlayer(Frobber);

    if (player != None)
    {
        if (numUses <= 0)
        {
            player.ClientMessage(msgEmpty);
            return;
        }

        if (player.Credits >= 5)
        {
            PlaySound(sound'VendingCoin', SLOT_None);
            loc = Vector(Rotation) * CollisionRadius * 0.8;
            loc.Z -= CollisionHeight * 0.7;
            loc += Location;

            product = Spawn(GetSpawnClass(), None,, loc);

            if (product != None)
            {
                if (product.IsA('Sodacan'))
                    PlaySound(sound'VendingCan', SLOT_None);
                else
                    PlaySound(sound'VendingSmokes', SLOT_None);

                product.Velocity = Vector(Rotation) * 100;
                product.bFixedRotationDir = True;
                product.RotationRate.Pitch = (32768 - Rand(65536)) * 4.0;
                product.RotationRate.Yaw = (32768 - Rand(65536)) * 4.0;
            }

            player.Credits -= 5;
            player.ClientMessage(msgDispensed);
            numUses--;
        }
        else
            player.ClientMessage(msgNoCredits);
    }
}

defaultproperties
{
    msgDispensed="5 credits deducted from your account"
    msgNoCredits="Costs 5 credits..."
    numUses=5
}
