//=============================================================================
// MenuScreenRandoOptionsAudio
//=============================================================================

class MenuScreenRandoOptionsAudio expands MenuScreenRandoOptionsBase;

function CreateChoices()
{
    local bool useDXRMusicPlayer;

    useDXRMusicPlayer = true;

    #ifdef revision
    if (class'RevJCDentonMale'.Default.bUseRevisionSoundtrack){
            useDXRMusicPlayer=False;
    }
    #endif

    if(useDXRMusicPlayer) {
        CreateChoice(class'MenuChoice_ContinuousMusic');
        CreateChoice(class'MenuChoice_RandomMusic');
        CreateChoice(class'MenuChoice_ChangeSong');
        //TODO: CreateChoice(class'MenuChoice_AutoChangeSong'); on a timer
        CreateChoice(class'MenuChoice_DisableSong');
        CreateChoice(class'MenuChoice_UTMusic');
        CreateChoice(class'MenuChoice_UnrealMusic');
        CreateChoice(class'MenuChoice_DXMusic');
    } else {
    #ifdef revision
        //Show the Revision soundtrack choice option if non-vanilla is chosen
        CreateChoice(class'RevMenuChoice_Soundtrack');
    #endif
    }
    if(#defined(injections)){
        CreateChoice(class'MenuChoice_ChargeTimer');
    }
}

defaultproperties
{
    Title="Randomizer Audio"
}
