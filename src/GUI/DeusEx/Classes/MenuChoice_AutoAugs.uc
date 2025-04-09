class MenuChoice_AutoAugs extends MenuChoice_AccordingToGameMode;

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
    HelpText="Some augmentations will only use energy while in effect."
    actionText="Semi-Automatic Augs"
    enumText(0)="Manual Augs"
    enumText(2)="Semi-Automatic Augs"
}
