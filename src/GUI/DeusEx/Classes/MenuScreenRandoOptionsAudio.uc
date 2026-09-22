//=============================================================================
// MenuScreenRandoOptionsAudio
//=============================================================================

class MenuScreenRandoOptionsAudio expands MenuScreenRandoOptionsBase;

function CreateChoices()
{
    local bool useTracker;

    if(#defined(gmdxae)){
        //Randomized music is currently disabled in AE, due to interaction
        //conflicts with the changes to music handling in AE
        return;
    }

    useTracker = !class'DXRActorsBase'.static.IsUsingOggMusic(#var(PlayerPawn)(player));

    if (useTracker){
        CreateChoice(class'MenuChoice_ContinuousMusic');
    }

    CreateChoice(class'MenuChoice_RandomMusic');
    CreateChoice(class'MenuChoice_ChangeSong');
    CreateChoice(class'MenuChoice_DisableSong');

    if(useTracker) {
        //TODO: CreateChoice(class'MenuChoice_AutoChangeSong'); on a timer
        CreateChoice(class'MenuChoice_UTMusic');
        CreateChoice(class'MenuChoice_UnrealMusic');
        CreateChoice(class'MenuChoice_DXMusic');
    } else {
        CreateChoice(class'MenuChoice_RevMusic');
        CreateChoice(class'MenuChoice_RevPS2Music');
    }
    if(#defined(injections)){
        CreateChoice(class'MenuChoice_ChargeTimer');
    }
}

defaultproperties
{
    Title="Randomizer Audio"
}
