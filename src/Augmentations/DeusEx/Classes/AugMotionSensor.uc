#compileif injections
class AugMotionSensor extends AugVision;

// AugDisplayWindow detects the class type to set motion sensor

// level value is feet*16, 112 is MaxFrobDistance (7 feet)
defaultproperties
{
    Icon=Texture'AugIconMotionSensor'
    smallIcon=Texture'AugIconMotionSensor_Small'
    LevelValues(0)=320
    maxLevel=0
    energyRate=10
    AugmentationName="Motion Sensor"
    Description="Motion Sensor allows an agent to see moving things through walls."
}
