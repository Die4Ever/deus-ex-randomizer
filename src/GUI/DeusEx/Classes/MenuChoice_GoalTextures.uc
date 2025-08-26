class MenuChoice_GoalTextures extends DXRMenuUIChoiceInt;

function SaveSetting()
{
    local DXRMissions dxrm;
    local DXRFixup dxrfu;

    Super.SaveSetting();

    foreach player.AllActors(class'DXRMissions', dxrm) {
        dxrm.DignifyAllGoalActors();
    }

    foreach player.AllActors(class'DXRFixup',dxrfu){
        dxrfu.AdjustBookColours();
        break;
    }
}

static function bool IsEnabled()
{
    return default.value==1;
}

static function bool BookColoursShouldChange()
{
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    if (dxr==None) return false;

    if(!#defined(vanilla)) return false; //Have to think about Facelift before allowing in other mods
    if(dxr.flags.IsZeroRandoPure()) return false; //Don't change the textures for pure Zero Rando

    return IsEnabled();
}

defaultproperties
{
    value=1
    defaultvalue=1
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Give randomized goal objects distinctly coloured textures?"
    actionText="Goal Textures"
    enumText(0)="Original Textures"
    enumText(1)="New Textures"
}
