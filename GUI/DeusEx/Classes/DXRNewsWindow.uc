class DXRNewsWindow extends MenuUIScreenWindow;

var DXRNews news;
var DXRBase callbackModule;

function CreateControls()
{
    Super.CreateControls();

    news = DXRNews(winClient.NewChild(class'DXRNews'));
    news.CreateNews(player, 0, 0, ClientWidth, ClientHeight);
}

function ProcessAction(String actionKey)
{
    log(self@"ProcessAction"@actionKey);
    if(callbackModule==None) return;

    switch(actionKey) {
    case "OPEN":
        callbackModule.MessageBoxClicked(0, 0);
        break;

    case "CANCEL":
        callbackModule.MessageBoxClicked(1, 0);
        break;
    }
}


event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
    if ( IsKeyDown( IK_Alt ) || IsKeyDown( IK_Shift ) )
        return False;

    switch( key )
    {
        case IK_Escape:
            player.PlaySound(Sound'DeusExSounds.Generic.Buzz1');
            return True;
            break;
    }
}

function Set(DXRTelemetry tel, string newtitle)
{
    callbackModule = tel;
    SetTitle(newtitle);
    news.Set(tel);
}

defaultproperties
{
    actionButtons(0)=(Align=HALIGN_Right,Action=AB_Other,Text="Keep Using Old Version",Key="CANCEL")
    actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Open In Browser",Key="OPEN")
    Title="News"
    ClientWidth=400
    ClientHeight=400
}
