class HXRandoGameInfo extends HXGameInfo config;

var DXRando dxr;

replication
{
    reliable if( Role==ROLE_Authority )
        dxr;
}

function DXRando GetDXR()
{
    if( dxr != None ) return dxr;
    foreach AllActors(class'DXRando', dxr) return dxr;
    if( DeusExLevelInfo == None ) return None;

    dxr = Spawn(class'DXRando');
    dxr.SetdxInfo(DeusExLevelInfo);
    log("GetDXR(), dxr: "$dxr, self.name);
    return dxr;
}

event InitGame( String Options, out String Error )
{
    Super.InitGame(Options, Error);

    log("InitGame", self.name);
    GetDXR();
}

event PostLogin(playerpawn NewPlayer)
{
    local DeusExNote note;
    local #var(PlayerPawn) p;

    Super.PostLogin(NewPlayer);
    if( Role != ROLE_Authority ) return;

    p = #var(PlayerPawn)(NewPlayer);

    GetDXR();
    log("PostLogin("$NewPlayer$") server, dxr: "$dxr, self.name);
    dxr.PlayerLogin( p );

    for( note = FirstNote; note != None; note = note.next )
    {
        log(p$".ClientAddNote( "$note.text$", "$note.bUserNote$", "$note.textTag$" );");
        p.ClientAddNote( note.text, note.bUserNote, note.textTag );
    }
}

//
// Examine the passed player's inventory, and accept or discard each item.
// AcceptInventory needs to gracefully handle the case of some inventory
// being accepted but other inventory not being accepted (such as the default
// weapon).  There are several things that can go wrong: A weapon's
// AmmoType not being accepted but the weapon being accepted -- the weapon
// should be killed off. Or the player's selected inventory item, active
// weapon, etc. not being accepted, leaving the player weaponless or leaving
// the HUD inventory rendering messed up (AcceptInventory should pick another
// applicable weapon/item as current).
//
event AcceptInventory(pawn PlayerPawn)
{
    local HXPlayerPawn Human;
    local HXNanoKeyInfo aKey;
    local int PointsSpent;
    local class<HXMissionScript> HXScript;
    local Inventory Inv;

    // First remark all inventory spaces as occupied,
    // skip sanity checks for now
    for ( Inv = HXPlayerPawn(PlayerPawn).Inventory; Inv != None; Inv = Inv.Inventory )
        if ( Inv.bDisplayableInv )
            HXPlayerPawn(PlayerPawn).MarkSpace( Inv.invPosX, Inv.invPosY, Inv.invSlotsX, Inv.invSlotsY, Inv );

    //default accept all inventory except default weapon (spawned explicitly)
    //local inventory inv;
    // Initialize the inventory.
    //AddDefaultInventory( PlayerPawn );
    //log( "All inventory from" @ PlayerPawn.PlayerReplicationInfo.PlayerName @ "is accepted" );

    Human = HXPlayerPawn(PlayerPawn);

    if ( Human == None )
        return;

    if ( Human.HXKeyRing != None )
    {
        Log( "KeyRing found! Not adding default equipment for" $ PlayerPawn, 'DevInventory' );

        if ( MissionScript!=None && DeusExLevelInfo!=None )
            MissionScript.AcceptInventory( HXPlayerPawn(PlayerPawn), Steve.Portal, Caps(DeusExLevelInfo.MapName) );

        Human.InitializeSubSystems();
    }
    else
    {
        Log( "KeyRing not found! Adding default equipment for " $ PlayerPawn, 'DevInventory' );

        // Other defaults
        Human.Credits = Human.Default.Credits;
        Human.Energy  = Human.Default.Energy;

        Human.SetInHandPending(None);
        Human.SetInHand(None);

        Human.bInHandTransition = False;

        Human.RestoreAllHealth();

        // Reinitialize all subsystems we've just nuked
        Human.InitializeSubSystems();

        // Give starting inventory.
        //if (Level.Netmode != NM_Standalone)
        //{
            //NintendoImmunityEffect( True );
            Human.GiveInitialInventory();
        //}

        Human.SkillPointsTotal = Steve.SkillPointsTotal;
        Human.SkillPointsAvail = Steve.SkillPointsTotal;
    }
}

function ProcessServerTravel( string URL, bool bItems )
{
    local int i;
    local DeusExNote note;
    local DataStorage ds;
    log(Self$".ProcessServerTravel PreTravel dxr: "$dxr);

    ds = class'DataStorage'.static.GetObj(dxr);
    for( note = FirstNote; note != None; note = note.next ) {
        log(self$".ProcessServerTravel, note: "$note);
        ds.AddNote( note.textTag, note.bUserNote, note.text );
    }
    ds.PreTravel();

    dxr.PreTravel();

    Super.ProcessServerTravel( URL, bItems );
}

function bool RestartPlayer( Pawn PlayerToRestart )
{
    local #var(PlayerPawn) p;
    local bool ret;
    ret = Super.RestartPlayer(PlayerToRestart);
    p = #var(PlayerPawn)(PlayerToRestart);
    if( p != None )
        dxr.PlayerRespawn( p );

    return ret;
}

function Killed( pawn Killer, pawn Other, name damageType )
{
    Super.Killed(Killer, Other, damageType);
    class'DXREvents'.static.AddDeath(Other, Killer, damageType);
}
