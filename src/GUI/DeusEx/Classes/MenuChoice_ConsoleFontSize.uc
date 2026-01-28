class MenuChoice_ConsoleFontSize extends DXRMenuUIChoiceInt;

static function Font GetConsoleFont()
{
    switch (default.value){
        case 0:
            return Font'DXRMedFont';
        case 1:
            return Font'DXRMedFont_x2';
        case 2:
            return Font'DXRMedFont_x3';
    }
    return Font'DXRMedFont';
}

static function UpdateConsoleFont()
{
    local Canvas c;
    local Font newFont;
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    if (dxr==None) return;

    newFont = GetConsoleFont();

    foreach dxr.AllObjects(class'Canvas',c){
        c.MedFont = newFont;
    }
}

function SaveSetting()
{
    Super.SaveSetting();

    UpdateConsoleFont();
}

defaultproperties
{
    value=2
    defaultvalue=2
    HelpText="How big should the console font be?"
    actionText="Console Font Size"
    enumText(0)="Small"
    enumText(1)="Medium"
    enumText(2)="Large"
}
