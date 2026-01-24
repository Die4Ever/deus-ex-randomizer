class MenuChoice_ConsoleFontSize extends DXRMenuUIChoiceInt;

static function Font GetConsoleFont()
{
    switch (default.value){
        case 0:
            return Font'DXRMedFont';
        case 1:
            return Font'DXRFontMenuTitle';
        case 2:
            return Font'DXRFontConversationLargeBold';
        case 3:
            return Font'DXRFontMenuExtraLarge';
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
    value=3
    defaultvalue=3
    HelpText="How big should the console font be?"
    actionText="Console Font Size"
    enumText(0)="Tiny"
    enumText(1)="Small"
    enumText(2)="Medium"
    enumText(3)="Large"
}
