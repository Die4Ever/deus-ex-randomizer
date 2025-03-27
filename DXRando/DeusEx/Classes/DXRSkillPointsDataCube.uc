class DXRSkillPointsDataCube extends DataCube;

var int NumSkillPoints;
var string Hint;
var bool bFrobbed;

function Frob(Actor other, Inventory frobWith)
{
    local string hint, details;

    if (DeusExPlayer(other) != None) {
        if (!bFrobbed) {
            DXRHints(class'DXRHints'.static.Find()).GetHint(false, hint, details);
            self.Hint = hint @ details;
            plaintext = self.Hint $ "|n|n" $ NumSkillPoints $ " skill points awarded";
            DeusExPlayer(other).SkillPointsAdd(NumSkillPoints);
            bFrobbed = true;
        } else {
            plaintext = self.Hint;
            bAddToVault = false;
        }
    }

    Super.Frob(other, frobWith);
}
