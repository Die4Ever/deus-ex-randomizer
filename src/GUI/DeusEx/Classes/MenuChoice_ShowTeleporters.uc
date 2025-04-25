class MenuChoice_ShowTeleporters extends DXRMenuUIChoiceInt;

function SaveSetting()
{
    local DXRFixup f;
    Super.SaveSetting();

    foreach player.AllActors(class'DXRFixup', f) {
        f.ShowTeleporters();
    }
}

static function bool ShowTeleporters()
{
    local bool bReducedRando;
    if(class'DXRando'.default.dxr == None || class'DXRando'.default.dxr.flags == None) {
        return false;
    }
    bReducedRando = class'DXRando'.default.dxr.flags.IsReducedRando();
    return default.value==1 || default.value==2 || (!bReducedRando && default.value==3);
}

static function bool ShowDescriptions()
{
    local bool bReducedRando;
    if(class'DXRando'.default.dxr == None || class'DXRando'.default.dxr.flags == None) {
        return false;
    }
    bReducedRando = class'DXRando'.default.dxr.flags.IsReducedRando();
    return default.value==2 || (!bReducedRando && default.value==3);
}

defaultproperties
{
    value=3
    defaultvalue=3
    enumText(0)="Hidden"
    enumText(1)="Visible without descriptions"
    enumText(2)="Visible with descriptions"
    enumText(3)="According to Game Mode"
    HelpText="Visible icons for teleporters with text descriptions."
    actionText="Teleporter Icons"
}
