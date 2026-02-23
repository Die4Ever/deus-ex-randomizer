class MenuChoice_TextureSmoothing extends DXRMenuUIChoiceInt;

function SaveSetting()
{
    local DXRFixup f;
    Super.SaveSetting();

    foreach player.AllActors(class'DXRFixup', f) {
        f.AdjustTextureSmoothing();
    }
}

static function bool NoSmoothTextures()
{
    return default.value==1 || default.value==3;
}

static function bool NoSmoothActors()
{
    return default.value==2 || default.value==3;
}

defaultproperties
{
    value=0
    defaultvalue=0
    enumText(0)="All Smoothed"
    enumText(1)="Object Textures Smoothed" //World textures unsmoothed
    enumText(2)="World Textures Smoothed" //Object textures unsmoothed
    enumText(3)="None Smoothed"
    HelpText="Choose where texture smoothing should be applied."
    actionText="Texture Smoothing"
}
