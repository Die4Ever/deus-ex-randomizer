class DXRHUDKeypadWindow injects HUDKeypadWindow;

// instantly interrupt the DENIED message
function PressButton(int num)
{
    if (inputCode == keypadOwner.validCode) return;

    if(bWait) {
        KeypadDelay(0,0,0);
        bWait = false;
    }

    Super.PressButton(num);
}

function KeypadDelay(int timerID, int invocations, int clientData)
{
    if(!bWait) return;
    Super.KeypadDelay(timerID, invocations, clientData);
}

// fix alt+tab issue
event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
    local bool bKeyHandled;

    bKeyHandled = True;

    if (!bRepeat)
    {
        switch(key)
        {
            case IK_0:
            case IK_NUMPAD0:	btnKeys[10].PressButton(); break;
            case IK_1:
            case IK_NUMPAD1:	btnKeys[0].PressButton(); break;
            case IK_2:
            case IK_NUMPAD2:	btnKeys[1].PressButton(); break;
            case IK_3:
            case IK_NUMPAD3:	btnKeys[2].PressButton(); break;
            case IK_4:
            case IK_NUMPAD4:	btnKeys[3].PressButton(); break;
            case IK_5:
            case IK_NUMPAD5:	btnKeys[4].PressButton(); break;
            case IK_6:
            case IK_NUMPAD6:	btnKeys[5].PressButton(); break;
            case IK_7:
            case IK_NUMPAD7:	btnKeys[6].PressButton(); break;
            case IK_8:
            case IK_NUMPAD8:	btnKeys[7].PressButton(); break;
            case IK_9:
            case IK_NUMPAD9:	btnKeys[8].PressButton(); break;

            default:
                bKeyHandled = False;
        }
    }

    if (!bKeyHandled)
        return Super(DeusExBaseWindow).VirtualKeyPressed(key, bRepeat);
    else
        return bKeyHandled;
}
