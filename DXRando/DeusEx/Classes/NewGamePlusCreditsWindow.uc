class NewGamePlusCreditsWindow injects CreditsWindow;

event DestroyWindow()
{
    local DXRFlags f;
    // Check to see if we need to load the intro
    if (bLoadIntro)
    {
        foreach player.AllActors(class'DXRFlags', f) {
            f.NewGamePlus();
            bLoadIntro=false;
        }
    }

    Super.DestroyWindow();
}
