class WaltonWareCrate extends DXRInfiniteCrate;

var int NumSkillPoints;

function Destroyed()
{
    if (class'DXRando'.default.dxr != None && class'DXRando'.default.dxr.player != None) {
        class'DXRando'.default.dxr.player.SkillPointsAdd(NumSkillPoints);
    }

    Super.Destroyed();
}

defaultproperties
{
     ItemName="Walton's Care Package"
     Skin=Texture'WaltonWareCrate'
}
