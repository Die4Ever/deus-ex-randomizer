class MenuChoice_BarrelTextures extends DXRMenuUIChoiceInt;

function SaveSetting()
{
    local #var(injectsprefix)Barrel1 b;

    Super.SaveSetting();

    foreach player.AllActors(class'#var(injectsprefix)Barrel1', b) {
        b.UpdateBarrelTexture();
    }
}

//This will be called from the barrels themselves, who won't have ready access to a DXRFlags
static function bool IsEnabled(Actor a)
{
    local DXRFlags f;

    if (default.value==2) { return True; }
    if (default.value==0) { return False; }

    foreach a.AllActors(class'DXRFlags',f){break;}
    if (f==None){return False;}

    return (default.value==2) || (default.value==1 && f.IsSpeedrunMode());
}

defaultproperties
{
    value=1
    defaultvalue=1
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Use new barrel textures with coloured markings?  This is automatically enabled in Speedrun Mode."
    actionText="Barrel Textures"
    enumText(0)="Original Textures"
    enumText(1)="According to Game Mode"
    enumText(2)="New Textures"
}
