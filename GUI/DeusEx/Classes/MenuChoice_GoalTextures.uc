class MenuChoice_GoalTextures extends DXRMenuUIChoiceInt;

function SaveSetting()
{
    local DXRMissions dxrm;

    Super.SaveSetting();

    foreach player.AllActors(class'DXRMissions', dxrm) {
        dxrm.ApplyGoalTexturesToAllActors();
    }
}

//This will be called from the barrels themselves, who won't have ready access to a DXRFlags
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
