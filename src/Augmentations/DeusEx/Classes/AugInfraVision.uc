#compileif injections
class AugInfraVision extends AugVision;

// AugDisplayWindow detects the class type to set infravision

// level value is feet*16, 112 is MaxFrobDistance (7 feet)
defaultproperties
{
    Icon=Texture'AugIconInfraVision'
    smallIcon=Texture'AugIconInfraVision_Small'
    LevelValues(0)=240
    maxLevel=0
    energyRate=0
    AugmentationName="Infravision"
    Description="Infravision allows an agent to see people, robots, and computers through walls."
}
