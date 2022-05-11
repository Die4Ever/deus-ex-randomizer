#ifdef injections
class NewGamePlusCreditsWindow injects CreditsWindow;
#else
class NewGamePlusCreditsWindow extends CreditsWindow;
#endif

event DestroyWindow()
{
    DoNewGamePlus();
    Super.DestroyWindow();
}

function DoNewGamePlus()
{
    local DXRFlags f;

    if (!bLoadIntro) return;

    foreach player.AllActors(class'DXRFlags', f) {
        f.NewGamePlus();
        bLoadIntro=false;
        break;
    }
}

function AddDXRCreditsGeneral()
{
#ifdef gmdx
    PrintHeader("Deus Ex GMDX Randomizer");
#elseif vmd
    PrintHeader("Deus Ex Vanilla? Madder. Randomizer");
#elseif revision
    PrintHeader("Deus Ex: Revision Randomizer");
#elseif hx
    PrintHeader("Deus Ex HX Randomizer");
#else
    PrintHeader("Deus Ex Randomizer");
#endif
    PrintText("Version"@class'DXRVersion'.static.VersionString());
    PrintLn();
    PrintHeader("Contributors");
    PrintText("Die4Ever");
    PrintText("TheAstropath");

    PrintLn();
    PrintHeader("Home Page");
    PrintText("https://github.com/Die4Ever/deus-ex-randomizer");

    PrintLn();
    PrintHeader("Discord Community");
    PrintText("https://discord.gg/daQVyAp2ds");

    PrintLn();
    PrintLn();
}

function AddDXRandoCredits()
{
    local DXRBase mod;
    local DataStorage ds;

    AddDXRCreditsGeneral();

    foreach player.AllActors(class'DXRBase', mod) {
        mod.AddDXRCredits(Self);
    }

    PrintHeader("Original Developers");
    PrintLn();

    ds = class'DataStorage'.static.GetObjFromPlayer(player);
    if( ds != None ) ds.EndPlaythrough();
}

function ProcessText()
{
    PrintPicture(CreditsBannerTextures, 2, 1, 505, 75);
    PrintLn();
    AddDXRandoCredits();
    Super.ProcessText();
}
