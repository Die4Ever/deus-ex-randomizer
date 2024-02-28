class DXRTeleporterHoverHint extends DXRHoverHint;

function AttachTarget(name targetName)
{
    Super.AttachTarget(targetName);

    if (target!=None && Teleporter(target)==None && MapExit(target)==None){
        log("Attached to target that was not a teleporter or map exit ("$target$","$targetName$")");
        target=None;
    }
}

function string formatMapName(string mapName)
{
    local string mapNameOnly,teleName;
    local int hashPos;

    hashPos = InStr(mapName,"#");

    if (hashPos+1 == Len(mapName)) {
        // # is the last character, leave it out
        return class'DXRMapInfo'.static.GetTeleporterName(Left(mapName, Len(mapName)-1),"");
    }
    if (hashPos==-1){
        //No # in map name, so it's probably just the map name?
        return class'DXRMapInfo'.static.GetTeleporterName(mapName, "");
    }

    mapNameOnly = Left(mapName, hashPos);

    teleName = Mid(mapName,hashPos+1);

    return class'DXRMapInfo'.static.GetTeleporterName(mapNameOnly,teleName);
}

function String GetHintText()
{
    local DynamicTeleporter dynTele;
    local string teleDest;

    if (target==None){
        return HintText;
    }

    if (#var(prefix)Teleporter(target)!=None){
        teleDest = #var(prefix)Teleporter(target).URL;
        dynTele = DynamicTeleporter(target);
        if (dynTele!=None && dynTele.destName != ''){
            if (InStr(teleDest,"#")==-1){
                teleDest = teleDest $ "#";
            }
            teleDest = teleDest $ dynTele.destName;

        }
    } else if (#var(prefix)MapExit(target)!=None){
        teleDest = #var(prefix)MapExit(target).DestMap;
#ifdef injections
        if (#var(prefix)MapExit(target).destName!=''){
            teleDest = teleDest$#var(prefix)MapExit(target).destName;
        }
#endif
    }
    return "To: "$formatMapName(teleDest);
}

function bool ShouldDisplay(float dist)
{
    if (Super.ShouldDisplay(dist)==False){
        return False;
    }

    return (class'MenuChoice_ShowTeleporters'.default.show_teleporters > 1);
}
