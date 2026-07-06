class MenuChoice_DeathCam extends DXRMenuUIChoiceInt;

static function bool IsKillCam()
{
    return default.value==3;
}

static function bool IsDefaultCam()
{
    return default.value==0;
}

static function bool IsOverheadCam()
{
    return default.value==0 || default.value==1 || default.value==2;
}

static function float CameraSpinRotationMult()
{
    switch(default.value){
        case 0: //"Spinning Camera (Original)"
            return 8192.0; //Default value
        case 1: //"Slower Spinning Camera"
            return 2048.0;
        case 2: //"Overhead Camera (No Spin)"
            return 0.0;
        case 3: //"Show Killer (Kill Cam)"
            return 2048.0; //Kill Cam reverts to the spin if the killer dies (or isn't valid)
    }

    return 8192.0; //Default value
}

defaultproperties
{
    value=0
    defaultvalue=0
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="What would you like the camera to do when you're dead?"
    actionText="Death Cam"
    enumText(0)="Spinning Camera (Original)"
    enumText(1)="Spinning Camera (Slowed)"
    enumText(2)="Overhead Camera (No Spin)"
    enumText(3)="Show Killer (Kill Cam)"
}
