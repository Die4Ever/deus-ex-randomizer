class DXRButton1 injects #var(prefix)Button1;

enum ERandoButtonType
{
    RBT_Vanilla,
    RBT_OpenDoors
};

var() ERandoButtonType RandoButtonType;

function SetSkin(EButtonType type, bool lit)
{
    switch(RandoButtonType){
        case RBT_OpenDoors:
            if (lit){
                Skin = Texture'OpenDoorButtonLit';
                ScaleGlow = 3.0;
            } else {
                Skin = Texture'OpenDoorButtonUnlit';
                ScaleGlow = Default.ScaleGlow;
            }
            break;
        case RBT_Vanilla:
        Default:
            Super.SetSkin(type,lit);
            break;
    }
}

defaultproperties
{
    RandoButtonType=RBT_Vanilla
}
