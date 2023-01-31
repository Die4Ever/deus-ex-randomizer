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
#elseif revision
// ----------------------------------------------------------------------
// PostLogin()
// ----------------------------------------------------------------------
event _PostLogin(playerpawn NewPlayer)
{
	local RevJCDentonMale player;
	local RevMenuUICommandMessageBoxWindow msgBox;
	local bool NeedsReboot;
	local bool DidUpdate;
	local RevMapList MapList;

	Super_PostLogin(NewPlayer);

	player = RevJCDentonMale(NewPlayer);

	if (player != None)
	{
		//Set up Revision music (no music for dedicated servers since they don't need it and it crashes the server).
		if (Level.NetMode != NM_DedicatedServer)
			SetupMusic(player);

		player.GetDateandTime();
		ApplyGamemode(player);
		ApplySeasons(player);

		//Do config upgrades.
		if (player.CurrentUpgradeVersionMajor < player.REVISION_VERSION_MAJOR ||
			player.CurrentUpgradeVersionMinor < player.REVISION_VERSION_MINOR ||
			player.CurrentUpgradeVersionBuild < player.REVISION_VERSION_BUILD ||
			player.CurrentUpgradeVersionRevision < player.REVISION_VERSION_REVISION)
		{
			//Do the 1.1 update.
			if (player.CurrentUpgradeVersionMajor <= 1 && player.CurrentUpgradeVersionMinor < 1)
			{
				player.bUseRevisionFootsteps = True;
				player.ConsoleCommand("set ini:Engine.Engine.ViewportManager UseDirectDraw False");
				NeedsReboot = True;
				DidUpdate = True;
			}

			//Do the 1.1.0.1 update.
			if (player.CurrentUpgradeVersionMajor <= 1 && player.CurrentUpgradeVersionMinor <= 1 && player.CurrentUpgradeVersionBuild <= 0 && player.CurrentUpgradeVersionRevision < 1)
			{
				//If we won't load this now the "if check" below will fail due to it not being initialized yet.
				DynamicLoadObject("RGalaxy.GalaxyAudioSubsystem", class'Class');

				if (int(player.ConsoleCommand("get ini:Engine.Engine.AudioDevice EffectsChannels")) > 28)
				{
					//Assume GalaxyAudioSubsystem if true.
					if (int(player.ConsoleCommand("MaxEffectsChannels")) <= 0)
					{
						player.ConsoleCommand("set ini:Engine.Engine.AudioDevice EffectsChannels 28");
						DidUpdate = True;
					}
				}
			}

			//Do the 1.4.2 update.
			if (player.CurrentUpgradeVersionMajor <= 1 && player.CurrentUpgradeVersionMinor <= 4 && player.CurrentUpgradeVersionBuild < 2)
			{
				DynamicLoadObject("D3D10Drv.D3D10RenderDevice", class'Class');
				player.ConsoleCommand("set D3D10Drv.D3D10RenderDevice AlphaToCoverage False");
				player.ConsoleCommand("set D3D10Drv.D3D10RenderDevice AutoFOV False");
				player.ConsoleCommand("set D3D10Drv.D3D10RenderDevice ClassicLighting True");
				player.ConsoleCommand("set D3D10Drv.D3D10RenderDevice FPSLimit 0");
				player.ConsoleCommand("set D3D10Drv.D3D10RenderDevice LODBias 0");

				DynamicLoadObject("D3D9Drv.D3D9RenderDevice", class'Class');
				player.ConsoleCommand("set D3D9Drv.D3D9RenderDevice MaxLogTextureSize 12");

				DynamicLoadObject("Editor.EditorEngine", class'Class');
				player.ConsoleCommand("set Editor.EditorEngine CacheSizeMegs 4");

				player.ConsoleCommand("set Revision.RevConsole bLoadscreenHints True");
				player.ConsoleCommand("set DeusEx.DeusExGameEngine CacheSizeMegs 4");
				player.ConsoleCommand("set DeusEx.MenuScreenJoinGame MasterServerAddress master.333networks.com");

				MapList = player.Spawn(class'RevMapList');
				MapList.Maps[5]="97_Survival_Cathedral";
				MapList.Maps[6]="97_Survival_Bar";
				MapList.Maps[7]="97_Survival_Dockyard";
				MapList.Maps[8]="97_Survival_UC";
				MapList.Maps[9]="97_Survival_Nanotech";
				MapList.MapSizes[5]="(1-16)";
				MapList.MapSizes[6]="(1-8)";
				MapList.MapSizes[7]="(1-4)";
				MapList.MapSizes[8]="(1-8)";
				MapList.MapSizes[9]="(2-16)";
				MapList.SaveConfig();

				DidUpdate = True;
			}

			player.CurrentUpgradeVersionMajor = player.REVISION_VERSION_MAJOR;
			player.CurrentUpgradeVersionMinor = player.REVISION_VERSION_MINOR;
			player.CurrentUpgradeVersionBuild = player.REVISION_VERSION_BUILD;
			player.CurrentUpgradeVersionRevision = player.REVISION_VERSION_REVISION;
			player.SaveConfig();

			if (DidUpdate)
			{
				if (NeedsReboot)
				{
					msgBox = RevMenuUICommandMessageBoxWindow(RevRootWindow(player.rootWindow).CustomMessageBox(Class'RevMenuUICommandMessageBoxWindow', player.RevisionNotice, UpdateRebootMessage, 1, False, None, True));
					msgBox.ConsoleCommands[0] = "RELAUNCH -NEWWINDOW";
				}
				else
					msgBox = RevMenuUICommandMessageBoxWindow(RevRootWindow(player.rootWindow).CustomMessageBox(Class'RevMenuUICommandMessageBoxWindow', player.RevisionNotice, UpdateMessage, 1, False, None, True));

				msgBox.SetNotifyWindow(msgBox);
			}
		}
	}

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
    local DXRContinuousMusic cm;
    // Start player's music.
    cm = DXRContinuousMusic(GetDXR().LoadModule(class'DXRContinuousMusic'));
    if(cm!=None)
        cm.ClientSetMusic( NewPlayer, Level.Song, Level.SongSection, Level.CdTrack, MTRAN_Fade );
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
