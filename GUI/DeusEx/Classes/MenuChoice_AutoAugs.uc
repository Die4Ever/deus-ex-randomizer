class MenuChoice_AutoAugs extends DXRMenuUIChoiceBool;

#ifdef injections
function SaveSetting()
{
    local Augmentation aug;
    Super.SaveSetting();

    foreach player.AllActors(class'Augmentation', aug) {
        aug.SetAutomatic();
    }
}
#endif

defaultproperties
{
    enabled=True
    defaultvalue=True
    HelpText="Some augmentations will only use energy while in effect."
    actionText="Semi-Automatic Augs"
    enumText(0)="Manual Augs"
    enumText(1)="Semi-Automatic Augs"
}
