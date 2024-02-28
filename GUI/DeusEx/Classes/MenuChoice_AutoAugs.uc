class MenuChoice_AutoAugs extends DXRMenuUIChoiceBool;

function SaveSetting()
{
    local Augmentation aug;
    Super.SaveSetting();

    foreach player.AllActors(class'Augmentation', aug) {
        aug.SetAutomatic();
    }
}

defaultproperties
{
    enabled=True
    HelpText="Some augmentations will only use energy while in effect."
    actionText="Semi-Automatic Augs"
    enumText(0)="Manual Augs"
    enumText(1)="Semi-Automatic Augs"
}
