class WaltonWareCrate extends DXRInfiniteCrate;

var travel int NumSkillPoints;

function Destroyed()
{
    local DeusExPlayer player;

    if (DeusExPlayer(Instigator) != None) {
        player = DeusExPlayer(Instigator);
    } else {
        player = DeusExPlayer(GetPlayerPawn());
    }

    if (player != None) {
        player.SkillPointsAdd(NumSkillPoints);
    }

    Super.Destroyed();
}

defaultproperties
{
     ItemName="Walton's Care Package"
     Skin=Texture'WaltonWareCrate'
}
