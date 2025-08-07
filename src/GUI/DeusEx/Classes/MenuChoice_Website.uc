//=============================================================================
// MenuChoice_Website
//=============================================================================

class MenuChoice_Website extends MenuChoice_OpenUrl;

event InitWindow()
{
    open_url = "https://mods4ever.com/?utm_source=game&utm_medium=menubutton&utm_version="$ class'DXRVersion'.static.VersionNumber();
    Super.InitWindow();
}

defaultproperties
{
    HelpText="Open the Mods4Ever.com website for info, downloads, our social links, and other mods from us."
    actionText="Go to Mods4Ever.com website"
    open_url="https://mods4ever.com/?utm_source=game&utm_medium=menubutton"
}
