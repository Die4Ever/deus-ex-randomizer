class DXRBacktracking extends DXRActorsBase;

function FirstEntry()
{
    local Teleporter t;
    local DynamicTeleporter dt;
    local BlockPlayer bp;
    Super.FirstEntry();

    switch(dxr.localURL) {
        case "10_PARIS_METRO":
            foreach AllActors(class'BlockPlayer', bp) {
                if( bp.Name == 'BlockPlayer0' ) {
                    bp.bBlockPlayers=false;
                }
            }
            dt = Spawn(class'DynamicTeleporter',,'sewers_backtrack',vect(1599.971558, -4694.342773, 13.399302));
            dt.URL = "10_PARIS_CATACOMBS_TUNNELS#?toname=AmbientSound10";
            dt.Radius = 160;
            class'DXRFixup'.static._AddSwitch(Self, vect(1602.826904, -4318.841309, -250.365067), rot(0, 16384, 0), 'sewers_backtrack');
            break;
        case "15_AREA51_ENTRANCE":
            dt = Spawn(class'DynamicTeleporter',,,vect(4384.407715, -2483.292236, -41.900017));
            dt.URL = "15_area51_bunker#?toname=Light188";
            dt.Radius = 160;
            break;
        case "15_AREA51_FINAL":
            dt = Spawn(class'DynamicTeleporter',,,vect(-5714.406250, -1977.827881, -1358.711304));
            dt.URL = "15_area51_entrance#?toname=Light73";
            dt.Radius = 160;
            break;
    }
}

function AnyEntry()
{
    local string tonamestring;
    local name toname;
    local Actor a;
    Super.AnyEntry();

    //need to make sure this doesn't happen when loading a save
    if (! dxr.flags.f.GetBool('PlayerTraveling')) return;

    tonamestring = Level.game.ParseOption( "?" $ Level.GetLocalURL(), "toname" );
    if( InStr(tonamestring, "#") >=0 ) {
        tonamestring = Left(tonamestring,InStr(tonamestring,"#"));
    }
    if( tonamestring != "" ) {
        toname = dxr.Player.rootWindow.StringToName(tonamestring);
        foreach AllActors(class'Actor', a) {
            if( a.Name == toname ) {
                dxr.Player.SetLocation(a.Location);
                dxr.Player.UpdateURL("toname", "", false);
                break;
            }
        }
    }
}
