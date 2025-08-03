class MenuChoice_ScopeBlackout extends DXRMenuUIChoiceInt;

static function bool IsEnabled(Actor a)
{
    local DXRFlags f;

    if (default.value==2) { return True; }
    if (default.value==0) { return False; }

    if (a==None){return False;}
    foreach a.AllActors(class'DXRFlags',f){break;}
    if (f==None){return False;}

    return (default.value==2) || (default.value==1 && f.IsZeroRandoPure());
}

defaultproperties
{
    value=1
    defaultvalue=1
    HelpText="Should the screen be blacked out around scopes when zoomed in?"
    actionText="Scope Blackout"
    enumText(0)="Disabled"
    enumText(1)="According to Game Mode"
    enumText(2)="Enabled"
}
