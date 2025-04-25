class DXRComputerScreenSecurity injects ComputerScreenSecurity;

function CreatePanSlider()
{
    Super.CreatePanSlider();
    //Default to half pan speed instead of whatever the bottom is
    winPanSlider.winSlider.SetTickPosition(winPanSlider.winSlider.GetNumTicks()/2);
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
    switch(key)
    {
        //This already works with the number row, but not numpad
        case IK_NumPad1:
            winCameras[0].btnCamera.PressButton();
            return true;
        case IK_NumPad2:
            winCameras[1].btnCamera.PressButton();
            return true;
        case IK_NumPad3:
            winCameras[2].btnCamera.PressButton();
            return true;
    }

    return Super.VirtualKeyPressed(key, bRepeat);
}
