//=============================================================================
// DXRMessageBoxWindow
//=============================================================================

class DXRMessageBoxWindow extends MenuUIMessageBoxWindow;

var DXRBase callbackModule;
var int     callbackId;

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