#compileif gmdxae
class DXRMenuScreenGMDXOptionsGameplayGMDXAE extends MenuScreenGMDXOptionsGameplay;

function BuildModifierList()
{
    //We control real-time UI based on game modes as well, under our advanced settings.
    //Our setting will twiddle the bRealUI setting itself.
    RemoveItem("bRealUI");

    Super.BuildModifierList();
}
