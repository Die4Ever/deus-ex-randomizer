class MenuScreenRandoOptChoices expands MenuUIMenuWindow;

defaultproperties
{
     ButtonNames(0)="Randomizer"
     ButtonNames(1)="Visuals"
     ButtonNames(2)="Audio"
     ButtonNames(3)="Gameplay"
     ButtonNames(4)="?????"
     ButtonNames(5)="?????"
     ButtonNames(6)="Previous Menu"
     buttonXPos=7
     buttonWidth=282
     buttonDefaults(0)=(Y=13,Action=MA_MenuScreen,Invoke=Class'#var(package).MenuScreenRandoOptionsRandomizer')
     buttonDefaults(1)=(Y=49,Action=MA_MenuScreen,Invoke=Class'#var(package).MenuScreenRandoOptionsVisuals')
     buttonDefaults(2)=(Y=85,Action=MA_MenuScreen,Invoke=Class'#var(package).MenuScreenRandoOptionsAudio')
     buttonDefaults(3)=(Y=121,Action=MA_MenuScreen,Invoke=Class'#var(package).MenuScreenRandoOptionsGameplay')
     buttonDefaults(4)=(Y=157,Action=MA_MenuScreen,Invoke=Class'#var(package).MenuScreenRandoOptions')
     buttonDefaults(5)=(Y=193,Action=MA_MenuScreen,Invoke=Class'#var(package).MenuScreenRandoOptions')
     buttonDefaults(6)=(Y=266,Action=MA_Previous)
     Title="Rando Settings"
     ClientWidth=294
     ClientHeight=308
     clientTextures(0)=Texture'DeusExUI.UserInterface.MenuOptionsBackground_1'
     clientTextures(1)=Texture'DeusExUI.UserInterface.MenuOptionsBackground_2'
     clientTextures(2)=Texture'DeusExUI.UserInterface.MenuOptionsBackground_3'
     clientTextures(3)=Texture'DeusExUI.UserInterface.MenuOptionsBackground_4'
     textureCols=2
}
