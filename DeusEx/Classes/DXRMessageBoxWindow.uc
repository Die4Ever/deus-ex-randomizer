//=============================================================================
// DXRMessageBoxWindow
//=============================================================================

class DXRMessageBoxWindow extends MenuUIMessageBoxWindow;

const CustomMode = 2;

var DXRBase callbackModule;
var int     callbackId;

const maxButtons = 3;
var MenuUIActionButtonWindow customBtn[3];

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
    local int i;

	bHandled = Super.ButtonActivated(buttonPressed);
    
    if (!bHandled) {
        if (mbMode == CustomMode) {
            for (i=0;i<numButtons;i++) {
                if (buttonPressed == customBtn[i]) {
                    if ((bDeferredKeyPress) && (IsKeyDown(IK_Enter) || IsKeyDown(IK_Space) || IsKeyDown(IK_Y)))
                        bKeyPressed = True;
                    else
                        PostResult(i);

                    bHandled = True;
                    break;                
                }
            }
        
        } else {
            //I don't know what mode we're in
            bHandled = False;
        }
    }
    
    return bHandled;

}

function SetCustomMode( int numBtns, String labels[3] )
{
	local int i;
    mbMode = CustomMode; //For now, we'll treat mode 2 as "custom" mode
	
	// Now create buttons appropriately
    for (i = 0;i<numBtns;i++) {
        customBtn[i]  = winButtonBar.AddButton(labels[i], HALIGN_Right);
    }
    numButtons = numBtns;
    SetFocusWindow(customBtn[0]);


	// Tell the shadow which bitmap to use
	if (winShadow != None)
		MenuUIMessageBoxShadowWindow(winShadow).SetButtonCount(numButtons);
}


function SetCallback( DXRBase module, int id )
{
	callbackModule = module;
    callbackId = id;
}

function PostResult( int buttonNumber )
{
	if ( callbackModule != None )
		callbackModule.MessageBoxClicked(buttonNumber,callbackId);
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	local bool bHandled;

    bHandled = Super.VirtualKeyPressed(key,bRepeat);
    
    if (!bHandled) {
        if (mbMode == CustomMode) {
            switch(key) {
                case IK_Enter:	
                case IK_Space:
                case IK_Escape:
                    if (bDeferredKeyPress) {
                        bKeyPressed = True;
                    } else {
                        PostResult(0);
                    }
                    bHandled = True;
                    break;
                    
                default:
                    //
                    break;

            }
        }
    }
    
    return bHandled;

}