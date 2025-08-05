class MenuChoice_AutoAugsInstall extends DXRMenuUIChoiceInt;

static function bool bEnableAug(Augmentation aug)
{
    if(default.value == 0) return false;
    if(!aug.bAutomatic) return false;
    if(default.value == 1) return true;
    // protection/defensive/damage resistance augs
    switch(aug.class) {
    case class'AugDefense':
        return default.value == 2; // protection aug, but not damage resistance
    case class'AugBallistic':
    case class'AugEMP':
    case class'AugEnviro':
    case class'AugShield':
        return default.value == 2 || default.value == 3;
    }
    return false;
}

defaultproperties
{
    value=3
    defaultvalue=3
    HelpText="When using a MedBot to install an auto aug, automatically enable the aug."
    actionText="Auto Augs Installation"
    enumText(0)="Manually Enable Auto Augs"
    enumText(1)="Enable Auto Augs On Installation"
    enumText(2)="Protection Augs"
    enumText(3)="Damage Resistance Augs"
}
