#ifdef revision
class DXRandoGameInfo extends RevGameInfo config;
#else
class DXRandoGameInfo extends DeusExGameInfo config;
#endif
// unused in vanilla since we just hook in DeusExLevelInfo instead
// HXRando has its own custom GameInfo

var DXRando dxr;

function DXRando GetDXR()
{
    local DeusExLevelInfo DeusExLevelInfo;

    if( dxr != None ) return dxr;
    foreach AllActors(class'DXRando', dxr) return dxr;

    foreach AllActors( Class'DeusExLevelInfo', DeusExLevelInfo )
        break;

    dxr = Spawn(class'DXRando');
    dxr.SetdxInfo(DeusExLevelInfo);
    log("GetDXR(), dxr: "$dxr, self.name);
    return dxr;
}

event InitGame( String Options, out String Error )
{
    Super.InitGame(Options, Error);

    log("InitGame DXR", self.name);
    GetDXR();
}

event PostLogin(playerpawn NewPlayer)
{
    local #var(PlayerPawn) p;

    _PostLogin(NewPlayer);

    if( Role != ROLE_Authority ) return;

    p = #var(PlayerPawn)(NewPlayer);

    GetDXR();
    log("PostLogin("$NewPlayer$") server, dxr: "$dxr, self.name);
    dxr.PlayerLogin( p );
}

function bool PickupQuery( Pawn Other, Inventory item )
{
    local DXRLoadouts loadouts;
    local #var(PlayerPawn) player;

    player = #var(PlayerPawn)(Other);
    if(player != None && item != None) {
        loadouts = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
        if( loadouts != None && loadouts.ban(player, item) ) {
            item.Destroy();
            return false;
        }
    }

    return Super.PickupQuery(Other, item);
}

function Killed( pawn Killer, pawn Other, name damageType )
{
    Super.Killed(Killer, Other, damageType);
    class'DXREvents'.static.AddDeath(Other, Killer, damageType);
}

#ifdef vmd
event _PostLogin(playerpawn NewPlayer)
{
    Super_PostLogin(NewPlayer);

    if (DeusExPlayer(NewPlayer) != None)
        ApplyGamemode(DeusExPlayer(NewPlayer));
}
#elseif gmdx
event _PostLogin(playerpawn NewPlayer)
{
    Super_PostLogin(NewPlayer);
}
#else
event _PostLogin(playerpawn NewPlayer)
{
    Super.PostLogin(NewPlayer);
}
#endif

//
// Called after a successful login. This is the first place
// it is safe to call replicated functions on the PlayerPawn.
//
// replace the vanilla one so we can do our continuous music magic
event Super_PostLogin( playerpawn NewPlayer )
{
    local Pawn P;
    local DXRMusicPlayer m;
    // Start player's music.
    m = DXRMusicPlayer(GetDXR().LoadModule(class'DXRMusicPlayer'));
    if(m!=None)
        m.ClientSetMusic( NewPlayer, Level.Song, Level.SongSection, Level.CdTrack, MTRAN_Fade );
    else
        NewPlayer.ClientSetMusic( Level.Song, Level.SongSection, Level.CdTrack, MTRAN_Fade );

    if ( Level.NetMode != NM_Standalone )
    {
        // replicate skins
        for ( P=Level.PawnList; P!=None; P=P.NextPawn )
            if ( P.bIsPlayer && (P != NewPlayer) )
            {
                if ( P.bIsMultiSkinned )
                    NewPlayer.ClientReplicateSkins(P.MultiSkins[0], P.MultiSkins[1], P.MultiSkins[2], P.MultiSkins[3]);
                else
                    NewPlayer.ClientReplicateSkins(P.Skin);

                if ( (P.PlayerReplicationInfo != None) && P.PlayerReplicationInfo.bWaitingPlayer && P.IsA('PlayerPawn') )
                {
                    if ( NewPlayer.bIsMultiSkinned )
                        PlayerPawn(P).ClientReplicateSkins(NewPlayer.MultiSkins[0], NewPlayer.MultiSkins[1], NewPlayer.MultiSkins[2], NewPlayer.MultiSkins[3]);
                    else
                        PlayerPawn(P).ClientReplicateSkins(NewPlayer.Skin);
                }
            }
    }
}
