class EnergyDrinkCan extends #var(DeusExPrefix)Pickup; // can't subclass Sodacan because Super doesn't work well in states

state Activated
{
    function Activate()
    {
        // can't turn it off
    }

    function BeginState()
    {
        local #var(PlayerPawn) player;
        local float f;
        local int i;
        local string message;

        Super.BeginState();

        player = #var(PlayerPawn)(Owner);

        if(player == None) return;

    #ifdef injections
        i = player._HealPlayer(2, false, false);
        message = "Healed "$ i $" point";
        if(i != 1)
            message = message $ "s";
    #else
        if (player != None)
            player.HealPlayer(2, False);
    #endif

        f = FMin(5, player.EnergyMax - player.Energy);
        if( f > 0 ) {
            if( Len(message) > 0 )
                message = message $ ", recharged ";
            else
                message = "Recharged ";

            player.Energy += f;
            message = message $ int(f) $ " point";
            if( int(f) != 1 )
                message = message $"s";
        }

        if( Len(message) > 0 )
            player.ClientMessage(message);

        PlaySound(sound'MaleBurp');
        UseOnce();
    }
Begin:
}

defaultproperties
{
    ItemName="Energy Drink"
    ItemArticle="an"
    Description="The can is blank except for the phrase 'PRODUCT PLACEMENT HERE.' It is unclear whether this is a name or an invitation."
    beltDescription="ENRG"
    Mesh=LodMesh'DeusExItems.Sodacan'
    Skin=Texture'DeusExItems.Skins.SodacanTex2'
    maxCopies=10
    bCanHaveMultipleCopies=True
    bActivatable=True
    PlayerViewOffset=(X=30.000000,Z=-12.000000)
    PlayerViewMesh=LodMesh'DeusExItems.Sodacan'
    PickupViewMesh=LodMesh'DeusExItems.Sodacan'
    ThirdPersonMesh=LodMesh'DeusExItems.Sodacan'
    LandSound=Sound'DeusExSounds.Generic.MetalHit1'
    Icon=Texture'DeusExUI.Icons.BeltIconSodaCan'
    largeIcon=Texture'DeusExUI.Icons.LargeIconSodaCan'
    largeIconWidth=24
    largeIconHeight=45
    Mesh=LodMesh'DeusExItems.Sodacan'
    CollisionRadius=3.000000
    CollisionHeight=4.500000
    Mass=5.000000
    Buoyancy=3.000000
}

