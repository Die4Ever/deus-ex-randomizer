class MenuChoice_TextureAnims extends DXRMenuUIChoiceInt;

function SaveSetting()
{
    local DXRFixup f;
    Super.SaveSetting();

    foreach player.AllActors(class'DXRFixup', f) {
        f.AdjustTextureAnimRates();
    }
}

static function bool IsEnabled()
{
    return default.value==1;
}

defaultproperties
{
    value=1
    defaultvalue=1
    enumText(0)="Default"
    enumText(1)="Rate Limited" //Animated textures capped at reasonable speeds
    HelpText="Choose whether to rate limit certain animated textures (like water) or not.  Rate limiting is recommended for better visuals."
    actionText="Animated Textures"
}
