class DXRPlayer injects Human;
//class DXRPlayer shims DeusExPlayer;

#exec OBJ LOAD FILE=NYCStreets2_Music

var DXRando dxr;
var DXRLoadouts loadout;
var bool bOnLadder;
var transient string nextMap;

var Music LevelSong;
var byte LevelSongSection;
var byte CombatSection;// used for NYCStreets2_Music

var Rotator ShakeRotator;

function ClientMessage(coerce string msg, optional Name type, optional bool bBeep)
{
    // 2 spaces because destroyed item pickups do ClientMessage( Item.PickupMessage @ Item.itemArticle @ Item.ItemName, 'Pickup' );
    if( msg == "  " ) return;

    Super.ClientMessage(msg, type, bBeep);
    class'DXRTelemetry'.static.SendLog(GetDXR(), self, "INFO", msg);

    if(bBeep) {
        // we don't want to override more important log sounds like Sound'LogSkillPoints'
        if(DeusExRootWindow(rootWindow).hud.msgLog.logSoundToPlay == None)
            DeusExRootWindow(rootWindow).hud.msgLog.PlayLogSound(Sound'Menu_Focus');
    }
}

function PlayerMove( float DeltaTime )
{
    log("ERROR: "$Self$".PlayerMove("$DeltaTime$"), state: "$GetStateName());
    ClientMessage("ERROR: "$Self$".PlayerMove("$DeltaTime$"), state: "$GetStateName());
    GotoState('PlayerWalking');
}

event ClientTravel( string URL, ETravelType TravelType, bool bItems )
{
    nextMap = URL;
    Super.ClientTravel(URL, TravelType, bItems);
}

function ResetGoals()
{
	local DeusExGoal goal;
	local DeusExGoal goalNext;
    local bool isOldGoal;

    GetDXR();



	goal = FirstGoal;

	while( goal != None )
	{
		goalNext = goal.next;
        isOldGoal = (goal.goalMission < (dxr.dxInfo.missionNumber-1));

		// Delete:
		// 1) Completed Primary Goals
        // 2) Any Primary Goals two or more missions old
		// 3) ALL Secondary Goals

		if ((!goal.IsPrimaryGoal()) || (goal.IsPrimaryGoal() && (goal.IsCompleted() || isOldGoal)))
			DeleteGoal(goal);

		goal = goalNext;
	}
}

function DXRando GetDXR()
{
    if( dxr == None ) foreach AllActors(class'DXRando', dxr) { break; }
    return dxr;
}

function DXRBase DXRFindModule(class<DXRBase> class)
{
    local DXRBase m;
    if( dxr == None ) GetDXR();
    if( dxr != None ) m = dxr.FindModule(class);
    return m;
}

function PostIntro()
{
    if( flagbase.GetInt('Rando_newgameplus_loops') > 0 ) {
        bStartNewGameAfterIntro = true;
    }
    Super.PostIntro();
}

// just wrap some stuff in an if statement for flag Rando_newgameplus_loops
exec function StartNewGame(String startMap)
{
    if (DeusExRootWindow(rootWindow) != None)
        DeusExRootWindow(rootWindow).ClearWindowStack();

    // Set a flag designating that we're traveling,
    // so MissionScript can check and not call FirstFrame() for this map.
    flagBase.SetBool('PlayerTraveling', True, True, 0);

    GetDXR();
    dxr.DXRInit();
    dxr.info( Self$" StartNewGame("$startMap$") found "$dxr$", dxr.flagbase: "$dxr.flagbase$", dxr.flags.newgameplus_loops: "$dxr.flags.newgameplus_loops);
    if( dxr.flags.newgameplus_loops == 0 ) {
        SaveSkillPoints();
        ResetPlayer();
    }
    DeleteSaveGameFiles();

    bStartingNewGame = True;

    // Send the player to the specified map!
    if (startMap == "")
        Level.Game.SendPlayer(Self, "01_NYC_UNATCOIsland");		// TODO: Must be stored somewhere!
    else
        Level.Game.SendPlayer(Self, startMap);
}

exec function QuickSave()
{
    if( class'DXRAutosave'.static.AllowManualSaves(self) ) Super.QuickSave();
    else ClientMessage("Manual saving is not allowed in this game mode! Good Luck!",, true);
}

function bool AddInventory( inventory NewItem )
{
    if( loadout == None ) loadout = DXRLoadouts(DXRFindModule(class'DXRLoadouts'));
    if ( loadout != None && loadout.ban(self, NewItem) ) {
        NewItem.Destroy();
        return true;
    }

    return Super.AddInventory(NewItem);
}

// copied a lot from DeusExPlayer DeleteInventory
function bool HideInventory(inventory item)
{
    local DeusExRootWindow root;
    local PersonaScreenInventory winInv;

    item.bDisplayableInv = false;

    // If the item was inHand, clear the inHand
    if (inHand == item)
    {
        SetInHand(None);
        SetInHandPending(None);
    }

    // Make sure the item is removed from the inventory grid
    RemoveItemFromSlot(item);

    root = DeusExRootWindow(rootWindow);

    if (root != None)
    {
        // If the inventory screen is active, we need to send notification
        // that the item is being removed
        winInv = PersonaScreenInventory(root.GetTopWindow());
        if (winInv != None)
            winInv.InventoryDeleted(item);

        // Remove the item from the object belt
        if (root != None)
            root.DeleteInventory(item);
      else //In multiplayer, we often don't have a root window when creating corpse, so hand delete
      {
         item.bInObjectBelt = false;
         item.beltPos = -1;
      }
    }
}

#ifdef transcended
function DeusExNote AddNote( optional String strNote, optional Bool bUserNote, optional bool bShowInLog, optional String strSource)
#else
function DeusExNote AddNote( optional String strNote, optional Bool bUserNote, optional bool bShowInLog )
#endif
{
    local DeusExLevelInfo info;
    local DeusExNote newNote;
#ifdef transcended
    newNote = Super.AddNote(strNote, bUserNote, bShowInLog, strSource);
#else
    newNote = Super.AddNote(strNote, bUserNote, bShowInLog);

    info = GetLevelInfo();
    if (info != None) {
        newNote.mission = info.MissionNumber;
        newNote.level_name = Caps(info.mapName);
        log("AddNote: new note mission: "$newNote.mission$", level name: "$newNote.level_name);
    }
#endif

    return newNote;
}

function float GetCurrentGroundSpeed()
{
    local float augValue, speed;

    // Remove this later and find who's causing this to Access None MB
    if ( AugmentationSystem == None )
        return 0;

    augValue = AugmentationSystem.GetAugLevelValue(class'AugSpeed');
    if (augValue == -1.0)
        augValue = AugmentationSystem.GetAugLevelValue(class'AugNinja');

    if (augValue == -1.0)
        augValue = 1.0;

    if ( Level.NetMode != NM_Standalone )
        speed = Self.mpGroundSpeed * augValue;
    else
        speed = Default.GroundSpeed * augValue;

    return speed;
}

function DoJump( optional float F )
{
    local DeusExWeapon w;
    local float scaleFactor, augLevel;

    if ((CarriedDecoration != None) && (CarriedDecoration.Mass > 20))
        return;
    else if (bForceDuck || IsLeaning())
        return;

    if (Physics == PHYS_Walking)
    {
        if ( Role == ROLE_Authority )
            PlaySound(JumpSound, SLOT_None, 1.5, true, 1200, 1.0 - 0.2*FRand() );
        if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
            MakeNoise(0.1 * Level.Game.Difficulty);
        PlayInAir();

        Velocity.Z = JumpZ;

        if ( Level.NetMode != NM_Standalone )
        {
         if (AugmentationSystem == None)
            augLevel = -1.0;
         else
            augLevel = AugmentationSystem.GetAugLevelValue(class'AugSpeed');
            if( augLevel == -1.0 )
                augLevel = AugmentationSystem.GetAugLevelValue(class'AugNinja');
            w = DeusExWeapon(InHand);
            if ((augLevel != -1.0) && ( w != None ) && ( w.Mass > 30.0))
            {
                scaleFactor = 1.0 - FClamp( ((w.Mass - 30.0)/55.0), 0.0, 0.5 );
                Velocity.Z *= scaleFactor;
            }
        }

        // reduce the jump velocity if you are crouching
//		if (bIsCrouching)
//			Velocity.Z *= 0.9;

        if ( Base != Level )
            Velocity.Z += Base.Velocity.Z;
        SetPhysics(PHYS_Falling);
        if ( bCountJumps && (Role == ROLE_Authority) )
            Inventory.OwnerJumped();

        class'DXRStats'.static.AddJump(self);
    }
}

function Landed(vector HitNormal)
{
    local vector legLocation;
    local int augLevel;
    local float augReduce, dmg;

    //Note - physics changes type to PHYS_Walking by default for landed pawns
    PlayLanded(Velocity.Z);
    if (Velocity.Z < -1.4 * JumpZ)
    {
        MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
        if ((Velocity.Z < -700) && (ReducedDamageType != 'All'))
            if ( Role == ROLE_Authority )
            {
                // check our jump augmentation and reduce falling damage if we have it
                // jump augmentation doesn't exist anymore - use Speed instaed
                // reduce an absolute amount of damage instead of a relative amount
                augReduce = 0;
                if (AugmentationSystem != None)
                {
                    augLevel = AugmentationSystem.GetClassLevel(class'AugSpeed');
                    if( augLevel == -1.0 )
                        augLevel = AugmentationSystem.GetClassLevel(class'AugNinja');
                    if (augLevel >= 0)
                        augReduce = 15 * (augLevel+1);
                }

                dmg = Max((-0.16 * (Velocity.Z + 700)) - augReduce, 0);
                legLocation = Location + vect(-1,0,-1);			// damage left leg
                TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');

                legLocation = Location + vect(1,0,-1);			// damage right leg
                TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');

                dmg = Max((-0.06 * (Velocity.Z + 700)) - augReduce, 0);
                legLocation = Location + vect(0,0,1);			// damage torso
                TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');
            }
    }
    else if ( (Level.Game != None) && (Level.Game.Difficulty > 1) && (Velocity.Z > 0.5 * JumpZ) )
        MakeNoise(0.1 * Level.Game.Difficulty);
    bJustLanded = true;
}

function bool CanInstantLeftClick(DeusExPickup item)
{
    if (inHand!=None) return false;

    if (item==None) return false;
    if (item.bActivatable==False) return false;
    if (item.GetStateName()=='Activated') return false;

    if (Binoculars(item)!=None) return false; //Unzooming requires left clicking the binocs again
    return true;
}

exec function ParseLeftClick()
{
    local DeusExPickup item;
    Super.ParseLeftClick();
    item = DeusExPickup(FrobTarget);
    if (item != None && CanInstantLeftClick(item))
    {
        // So that any effects get applied to you
        item.SetOwner(self);
        // add to the player's inventory, so ChargedPickups travel across maps
        item.BecomeItem();
        item.bDisplayableInv = false;
        item.Inventory = Inventory;
        Inventory = item;
        item.Activate();
    }
}

event WalkTexture( Texture Texture, vector StepLocation, vector StepNormal )
{
    if ( Texture!=None && Texture.Outer!=None && Texture.Outer.Name=='Ladder' ) {
        bOnLadder = True;
    }
    else
        bOnLadder = False;
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
    class'DXREvents'.static.AddPlayerDeath(GetDXR(), self, Killer, damageType, HitLocation);
    Super.Died(Killer,damageType,HitLocation);
}

function bool IsHighlighted(actor A)
{
    local bool wasBehind,highlight;

    wasBehind = bBehindView;
    bBehindView = False;
    highlight = Super.IsHighlighted(A);
    bBehindView = wasBehind;
    return highlight;
}

exec function CrowdControlAnon()
{
    local DXRCrowdControl cc;
    local DXRFlags f;

    foreach AllActors(class'DXRCrowdControl',cc)
    {
        cc.link.anon = True;
    }
    foreach AllActors(class'DXRFlags',f)
    {
        f.crowdcontrol = 2;
        f.f.SetInt('Rando_crowdcontrol',2,,999);
    }

    ClientMessage("Now hiding Crowd Control names");

}

exec function CrowdControlNames()
{
    local DXRCrowdControl cc;
    local DXRFlags f;

    foreach AllActors(class'DXRCrowdControl',cc)
    {
        cc.link.anon = False;
    }
    foreach AllActors(class'DXRFlags',f)
    {
        f.crowdcontrol = 1;
        f.f.SetInt('Rando_crowdcontrol',1,,999);
    }
    ClientMessage("Now showing Crowd Control names");
}

exec function CheatsOn()
{
    bCheatsEnabled = true;
    ClientMessage("Cheats Enabled");
}

exec function CheatsOff()
{
    bCheatsEnabled = false;
    ClientMessage("Cheats Disabled");

}

//Just a copy of PlayersOnly, but doesn't need cheats and faster to type (In case of lockups after a save)
exec function po()
{
    if ( Level.Netmode != NM_Standalone )
        return;

    Level.bPlayersOnly = !Level.bPlayersOnly;
}

exec function FixAugHotkeys()
{
    local AugmentationManager am;
    local int hotkeynums[7], loc;
    local Augmentation a;

    am = AugmentationSystem;
    for(loc=0; loc<ArrayCount(am.AugLocs); loc++) {
        hotkeynums[loc] = am.AugLocs[loc].KeyBase + 1;
    }
    for( a = am.FirstAug; a != None; a = a.next ) {
        if( !a.bHasIt ) continue;
        loc = a.AugmentationLocation;
        if( a.AugmentationLocation == LOC_Default ) continue;
        ClientMessage(a.AugmentationName$" will bind to F"$hotkeynums[loc]);
        a.HotKeyNum = hotkeynums[loc]++;
    }

    am.RefreshAugDisplay();
}

exec function ShuffleGoals()
{
    local DXRMissions missions;

    foreach AllActors(class'DXRMissions',missions)
    {
        missions.SetGlobalSeed(FRand());
        missions.ShuffleGoals();
    }
}

exec function MoveGoalLocation( int locNumber, coerce string goalName)
{
    local DXRMissions missions;

    foreach AllActors(class'DXRMissions',missions)
    {
        if (missions.MoveGoalTo(goalName,locNumber)==true){
            ClientMessage("Successfully moved goal");
        } else {
            ClientMessage("Failed to move goal");
        }
    }
}

exec function AllPasswords()
{
    local Computers c;
    local Keypad k;
    local ATM a;
    local int i;

    foreach AllActors(class'Computers',c){
        for (i=0;i<ArrayCount(c.knownAccount);i++){
            c.SetAccountKnown(i);
        }
    }

    foreach AllActors(class'Keypad',k){
        k.bCodeKnown = True;
    }

    foreach AllActors(class'ATM',a){
        for (i=0;i<ArrayCount(a.knownAccount);i++){
            a.SetAccountKnown(i);
        }
    }
    ClientMessage("Set all account passwords to known");
}

//========= MUSIC STUFF
function _ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
    Super.ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);
}

// only called by GameInfo::PostLogin()
function ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
    local DXRContinuousMusic cm;
    GetDXR();
    cm = DXRContinuousMusic(dxr.LoadModule(class'DXRContinuousMusic'));
    cm.ClientSetMusic(self, NewSong, NewSection, NewCdTrack, NewTransition);
}

// ----------------------------------------------------------------------
// UpdateDynamicMusic() copied from DeusExPlayer, but Level.Song was changed to LevelSong, and Level.SongSection changed to LevelSongSection
//
// Pattern definitions:
//   0 - Ambient 1
//   1 - Dying
//   2 - Ambient 2 (optional)
//   3 - Combat
//   4 - Conversation
//   5 - Outro
// ----------------------------------------------------------------------

function UpdateDynamicMusic(float deltaTime)
{
    local bool bCombat;
    local ScriptedPawn npc;
    local Pawn CurPawn;
    local DeusExLevelInfo info;

    if (LevelSong == None)
        return;

    // DEUS_EX AMSD In singleplayer, do the old thing.
    // In multiplayer, we can come out of dying.
    if (!PlayerIsClient())
    {
        if ((musicMode == MUS_Dying) || (musicMode == MUS_Outro))
            return;
    }
    else
    {
        if (musicMode == MUS_Outro)
            return;
    }

    musicCheckTimer += deltaTime;
    musicChangeTimer += deltaTime;

    if (IsInState('Interpolating'))
    {
        // don't mess with the music on any of the intro maps
        info = GetLevelInfo();
        if ((info != None) && (info.MissionNumber < 0))
        {
            musicMode = MUS_Outro;
            return;
        }

        if (musicMode != MUS_Outro)
        {
            _ClientSetMusic(LevelSong, 5, 255, MTRAN_FastFade);
            musicMode = MUS_Outro;
        }
    }
    else if (IsInState('Conversation'))
    {
        if (musicMode != MUS_Conversation)
        {
            // save our place in the ambient track
            if (musicMode == MUS_Ambient)
                savedSection = SongSection;
            else
                savedSection = 255;

            _ClientSetMusic(LevelSong, 4, 255, MTRAN_Fade);
            musicMode = MUS_Conversation;
        }
    }
    else if (IsInState('Dying'))
    {
        if (musicMode != MUS_Dying)
        {
            _ClientSetMusic(LevelSong, 1, 255, MTRAN_Fade);
            musicMode = MUS_Dying;
        }
    }
    else
    {
        // only check for combat music every second
        if (musicCheckTimer >= 1.0)
        {
            musicCheckTimer = 0.0;
            bCombat = False;

            // check a 100 foot radius around me for combat
            // XXXDEUS_EX AMSD Slow Pawn Iterator
            //foreach RadiusActors(class'ScriptedPawn', npc, 1600)
            for (CurPawn = Level.PawnList; CurPawn != None; CurPawn = CurPawn.NextPawn)
            {
                npc = ScriptedPawn(CurPawn);
                if ((npc != None) && (VSize(npc.Location - Location) < (1600 + npc.CollisionRadius)))
                {
                    if ((npc.GetStateName() == 'Attacking') && (npc.Enemy == Self))
                    {
                        bCombat = True;
                        break;
                    }
                }
            }

            if (bCombat)
            {
                musicChangeTimer = 0.0;

                if (musicMode != MUS_Combat)
                {
                    // save our place in the ambient track
                    if (musicMode == MUS_Ambient)
                        savedSection = SongSection;
                    else
                        savedSection = 255;

                    _ClientSetMusic(LevelSong, CombatSection, 255, MTRAN_FastFade);
                    musicMode = MUS_Combat;
                }
            }
            else if (musicMode != MUS_Ambient)
            {
                // wait until we've been out of combat for 5 seconds before switching music
                if (musicChangeTimer >= 5.0)
                {
                    // use the default ambient section for this map
                    if (savedSection == 255)
                        savedSection = LevelSongSection;

                    // fade slower for combat transitions
                    if (musicMode == MUS_Combat)
                        _ClientSetMusic(LevelSong, savedSection, 255, MTRAN_SlowFade);
                    else
                        _ClientSetMusic(LevelSong, savedSection, 255, MTRAN_Fade);

                    savedSection = 255;
                    musicMode = MUS_Ambient;
                    musicChangeTimer = 0.0;
                }
            }
        }
    }
}

//=========== END OF MUSIC STUFF

function UpdateRotation(float DeltaTime, float maxPitch)
{
    local DataStorage datastorage;
    local int rollAmount;
    datastorage = class'DataStorage'.static.GetObjFromPlayer(self);
    rollAmount = int(datastorage.GetConfigKey('cc_cameraRoll'));

    if(rollAmount == 0) {
        Super.UpdateRotation(DeltaTime,maxPitch);
        return;
    }

    //Track and handle shake rotation as though we are always right-ways up
    ViewRotation = ShakeRotator;
    Super.UpdateRotation(DeltaTime,maxPitch);
    ShakeRotator = ViewRotation;

    //Apply any roll after figuring out (and storing) the current shake state
    ViewRotation.Roll += rollAmount;
}

// LDDP: for Lay D Denton compatibility
simulated function PreBeginPlay()
{
    Super.PreBeginPlay();
}
function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
    Super.PlayTakeHitSound(Damage, damageType, Mult);
}
function TweenToRunning(float tweentime)
{
    Super.TweenToRunning(tweentime);
}
function PlayWalking()
{
    local float newhumanAnimRate;

    newhumanAnimRate = humanAnimRate;

    // UnPhysic.cpp walk speed changed by proportion 0.7/0.3 (2.33), but that looks too goofy (fast as hell), so we'll try something a little slower
    if ( Level.NetMode != NM_Standalone )
        newhumanAnimRate = humanAnimRate * 1.75;

    //	ClientMessage("PlayWalking()");
    if(!HasAnim('CrouchWalk'))
        LoopAnim('Walk', newhumanAnimRate);
    else if (bForceDuck || bCrouchOn)
        LoopAnim('CrouchWalk', newhumanAnimRate);
    else
    {
        if (HasTwoHandedWeapon())
            LoopAnim('Walk2H', newhumanAnimRate);
        else
            LoopAnim('Walk', newhumanAnimRate);
    }
}
function TweenToWalking(float tweentime)
{
    if(!HasAnim('CrouchWalk'))
        TweenAnim('Walk', tweentime);
    else
        Super.TweenToWalking(tweentime);
}
function PlayFiring()
{
    Super.PlayFiring();
}
function TweenToWaiting(float tweentime)
{
    //	ClientMessage("TweenToWaiting()");
    if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
    {
        if (IsFiring())
            LoopAnim('TreadShoot');
        else
            LoopAnim('Tread');
    }
    else if (HasAnim('CrouchWalk') && (IsLeaning() || bForceDuck))
        TweenAnim('CrouchWalk', tweentime);
    else if (((AnimSequence == 'Pickup') && bAnimFinished) || ((AnimSequence != 'Pickup') && !IsFiring()))
    {
        if (HasTwoHandedWeapon())
            TweenAnim('BreatheLight2H', tweentime);
        else
            TweenAnim('BreatheLight', tweentime);
    }
}
function UpdateAnimRate( float augValue )
{
    Super.UpdateAnimRate(augValue);
}
function PlayDying(name damageType, vector hitLoc)
{
    Super.PlayDying(damageType, hitLoc);
}
function TweenToSwimming(float tweentime)
{
    Super.TweenToSwimming(tweentime);
}
function PlayDyingSound()
{
    Super.PlayDyingSound();
}
function Gasp()
{
    Super.Gasp();
}
function float RandomPitch()
{
    return Super.RandomPitch();
}
function PlayWeaponSwitch(Weapon newWeapon)
{
    Super.PlayWeaponSwitch(newWeapon);
}
function PlayCrawling()
{
    //	ClientMessage("PlayCrawling()");
    if (IsFiring())
        LoopAnim('CrouchShoot');
    else if(HasAnim('CrouchWalk'))
        LoopAnim('CrouchWalk');
}
function PlayRising()
{
    Super.PlayRising();
}
function PlayDuck()
{
    //	ClientMessage("PlayDuck()");
    if ((AnimSequence != 'Crouch') && (AnimSequence != 'CrouchWalk'))
    {
        if (IsFiring())
            PlayAnim('CrouchShoot',,0.1);
        else
            PlayAnim('Crouch',,0.1);
    }
    else if(HasAnim('CrouchWalk'))
        TweenAnim('CrouchWalk', 0.1);
}
function PlayLanded(float impactVel)
{
    Super.PlayLanded(impactVel);
}
function PlayInAir()
{
    Super.PlayInAir();
}
function PlaySwimming()
{
    Super.PlaySwimming();
}
function PlayWaiting()
{
//	ClientMessage("PlayWaiting()");
    if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
    {
        if (IsFiring())
            LoopAnim('TreadShoot');
        else
            LoopAnim('Tread');
    }
    else if (HasAnim('CrouchWalk') && (IsLeaning() || bForceDuck))
        TweenAnim('CrouchWalk', 0.1);
    else if (!IsFiring())
    {
        if (HasTwoHandedWeapon())
            LoopAnim('BreatheLight2H');
        else
            LoopAnim('BreatheLight');
    }
}
function PlayRunning()
{
    Super.PlayRunning();
}
function PlayTurning()
{
    if(!HasAnim('CrouchWalk'))
        TweenAnim('Walk', 0.1);
    else
        Super.PlayTurning();
}
function Bool HasTwoHandedWeapon()
{
    return Super.HasTwoHandedWeapon();
}
function Bool IsFiring()
{
    return Super.IsFiring();
}

function bool IsThemeAdded(Class<ColorTheme> themeClass)
{
	local ColorTheme curTheme;
	local ColorTheme prevTheme;
	local Bool bDeleted;

	bDeleted    = False;
	curTheme = ThemeManager.FirstColorTheme;

	while(curTheme != None)
	{
		if ((curTheme.GetThemeName() == themeClass.default.themeName) && (curTheme.IsSystemTheme() == themeClass.default.bSystemTheme) && curTheme.themeType == themeClass.default.themeType)
		{
			return True;
		}

		curTheme = curTheme.next;
	}
    return False;

}

function AddColorTheme(Class<ColorTheme> themeClass)
{
    if(IsThemeAdded(themeClass)==False){
        ThemeManager.AddTheme(themeClass);
    }
}

function CreateColorThemeManager()
{
    local ColorTheme theme;
    Super.CreateColorThemeManager();

    AddColorTheme(Class'ColorThemeHUD_HotDogStand');
    AddColorTheme(Class'ColorThemeMenu_HotDogStand');
    AddColorTheme(Class'ColorThemeHUD_Black');
    AddColorTheme(Class'ColorThemeMenu_Black');
    AddColorTheme(Class'ColorThemeHUD_Rando');
    AddColorTheme(Class'ColorThemeMenu_Rando');
    AddColorTheme(Class'ColorThemeHUD_Swirl');
    AddColorTheme(Class'ColorThemeMenu_Swirl');

}

// ----------------------------------------------------------------------
// RemoveItemDuringConversation()
// The only difference here is that we no longer remove the item from the inventory grid
// ----------------------------------------------------------------------

function RemoveItemDuringConversation(Inventory item)
{
	if (item != None)
	{
		// take it out of our hand
		if (item == inHand)
			PutInHand(None);

		// Make sure it's removed from the inventory grid
		//RemoveItemFromSlot(item);  //RANDO: How about we actually don't

		// Make sure the item is deactivated!
		if (item.IsA('DeusExWeapon'))
		{
			DeusExWeapon(item).ScopeOff();
			DeusExWeapon(item).LaserOff();
		}
		else if (item.IsA('DeusExPickup'))
		{
			// turn it off if it is on
			if (DeusExPickup(item).bActive)
				DeusExPickup(item).Activate();
		}

		if (conPlay != None)
			conPlay.SetInHand(None);
	}
}
// ---
