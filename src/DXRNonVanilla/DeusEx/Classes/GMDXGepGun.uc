class GMDXGepGun extends WeaponGEPGun;
// fix for https://github.com/Die4Ever/deus-ex-randomizer/issues/227

simulated function Tick(float deltaTime)
{
    local bool oldbCanTrack;
    oldbCanTrack = bCanTrack;
    if(DeusExPlayer(Owner) == None)
        bCanTrack = false;
    Super.Tick(deltaTime);
    bCanTrack = oldbCanTrack;
}
