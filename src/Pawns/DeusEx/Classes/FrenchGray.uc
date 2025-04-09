//=============================================================================
// FrenchGray.
//=============================================================================
class FrenchGray extends #var(prefix)Gray;

function bool Facelift(bool bOn)
{
    return false;
}

defaultproperties
{
    FamiliarName="Gris"
    UnfamiliarName="Gris"
    Skin=Texture'#var(package).DXRandoPawns.GrayTexFrench'
    CarcassType=Class'DeusEx.FrenchGrayCarcass'
}
