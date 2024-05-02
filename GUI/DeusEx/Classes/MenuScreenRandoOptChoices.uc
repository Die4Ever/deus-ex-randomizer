class MenuScreenRandoOptChoices expands MenuUIMenuWindow;

defaultproperties
{
     ButtonNames(0)="Randomizer"
     ButtonNames(1)="Visuals"
     ButtonNames(2)="Audio"
     ButtonNames(3)="Gameplay"
     ButtonNames(4)="Previous Menu" //Four Choice menu
     //ButtonNames(4)="?????" //five Choice menu
     //ButtonNames(5)="Previous Menu" //five Choice menu
     buttonXPos=7
     buttonWidth=282
     buttonDefaults(0)=(Y=13,Action=MA_MenuScreen,Invoke=Class'#var(package).MenuScreenRandoOptionsRandomizer')
     buttonDefaults(1)=(Y=49,Action=MA_MenuScreen,Invoke=Class'#var(package).MenuScreenRandoOptionsVisuals')
     buttonDefaults(2)=(Y=85,Action=MA_MenuScreen,Invoke=Class'#var(package).MenuScreenRandoOptionsAudio')
     buttonDefaults(3)=(Y=121,Action=MA_MenuScreen,Invoke=Class'#var(package).MenuScreenRandoOptionsGameplay')
     buttonDefaults(4)=(Y=198,Action=MA_Previous) //Four choice menu coord
     //buttonDefaults(4)=(Y=157,Action=MA_MenuScreen,Invoke=Class'#var(package).MenuScreenRandoOptionsGameplay') //five choice menu coord
     //buttonDefaults(5)=(Y=213,Action=MA_Previous) //five choice menu coord
     Title="Rando Settings"
     ClientWidth=294
     ClientHeight=240 //Four choice menu
     //ClientHeight=255 //Five choice menu
     clientTextures(0)=Texture'MenuRandoOptionsFourChoice_1'
     clientTextures(1)=Texture'MenuRandoOptionsFourChoice_2'
     //clientTextures(0)=Texture'MenuRandoOptionsFiveChoice_1'
     //clientTextures(1)=Texture'MenuRandoOptionsFiveChoice_2'
     textureCols=2
}
