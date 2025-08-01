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

static function bool IsEnabled(Actor a)
{
    return default.value==1;
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
