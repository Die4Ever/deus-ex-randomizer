class MenuChoice_ScopeScaling extends DXRMenuUIChoiceInt;

static function float GetScopeScale()
{
    switch (default.value){
        case 0:
            return 1.0;
        case 1:
            return 1.5;
        case 2:
            return 2.0;
        case 3:
            return 2.5;
        case 4:
            return 3.0;
        case 5:
            return -1.0; // Fit to Screen
        case 6:
            return -2.0; // Fit to Open Area
    }
    return 1.0;
}

defaultproperties
{
    value=5
    defaultvalue=5
    HelpText="How big should scopes show on screen?  Note that this does not change the amount you zoom, just the scope graphics."
    actionText="Scope Scaling"
    enumText(0)="1x"
    enumText(1)="1.5x"
    enumText(2)="2x"
    enumText(3)="2.5x"
    enumText(4)="3x"
    enumText(5)="Fit to Screen"
    enumText(6)="Fit to Open Area"
}
