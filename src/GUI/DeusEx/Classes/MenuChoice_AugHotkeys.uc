class MenuChoice_AugHotkeys extends DXRMenuUIChoiceInt;

static function bool ShouldHide()
{
    return default.value==0;
}

static function bool ShowSmall()
{
    return default.value==1;
}

static function bool ShowLarge()
{
    return default.value==2;
}

defaultproperties
{
    value=2
    defaultvalue=2
    HelpText="How should the aug hotkeys be displayed in game?"
    actionText="Aug Hotkeys"
    enumText(0)="Disabled"
    enumText(1)="Small"
    enumText(2)="Large"
}
