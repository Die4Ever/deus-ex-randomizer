class DXRComputerScreenSecurity injects ComputerScreenSecurity;

function CreatePanSlider()
{
    Super.CreatePanSlider();
    //Default to half pan speed instead of whatever the bottom is
    winPanSlider.winSlider.SetTickPosition(winPanSlider.winSlider.GetNumTicks()/2);
}
