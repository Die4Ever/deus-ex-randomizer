class DXRFixupM08 extends DXRFixup;

//#region Any Entry
function AnyEntryMapFixes()
{
    local StantonDowd s;
    local bool VanillaMaps;
    local ConEventAddGoal ceag;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    Super.AnyEntryMapFixes();

    switch(dxr.localURL) {
    case "08_NYC_STREET":
        SetTimer(1.0, True);

        foreach AllActors(class'StantonDowd', s) {
            RemoveReactions(s);
        }

        RearrangeMJ12ConvergingInfolink();
        RearrangeJockExitDialog();

        ceag = GetGoalConEvent('ScuttleShip', 'StantonDowd');
        if (ceag != None) {
            ceag.goalText = ReplaceText(ceag.goalText, "PCS", "PRCS");
        }

        break;

    case "08_NYC_SMUG":
        if (!#defined(gmdx) && !#defined(vmd) && !(#defined(revision)&&!VanillaMaps)){
            //This is fixed in:
            // - ConFix (used by GMDX)
            // - Revision conversations (which I guess only get used on Revision Maps)
            // - Vanilla? Madder!
            FixFordSchickConvo();
        }

        if (dxr.flagbase.getBool('SmugglerDoorDone')) {
            dxr.flagbase.setBool('MetSmuggler', true,, -1);
        }
        break;
    }
}
//#endregion

function FixFordSchickConvo()
{
    local Conversation c;
    local ConEvent ce,prev;
    local ConEventEnd cee,cee2;
    local ConEventTrigger cet;
    local ConEventTransferObject ceto;
    local SpawnItemTrigger sit;

    FixConversationGiveItem(GetConversation('M08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister'); //Make sure he tries to transfer the right class

    //Make sure there's handling for a full inventory
    c = GetConversation('M08MeetFordSchick');

    ce = c.eventList;
    prev=None;
    while (ce!=None){
        if (ce.eventType==ET_End){
            cee = ConEventEnd(ce);
        } else if (ce.eventType==ET_TransferObject){
            ceto = ConEventTransferObject(ce);
        }
        prev=ce;
        ce = ce.nextEvent;
    }

    if(cee!=None && ceto!=None){
        //Found the end of the conversation and the transfer

        //After the regular conversation end, add a Trigger event and a new End event.
        //If the item transfer fails, it will jump to the new Trigger event, which will
        //spawn the aug can on the table instead.

        if (ceto.failLabel!=""){
            //Quick failsafe, don't make any changes if there's already a failLabel set from something else
            return;
        }

        ceto.failLabel = "AugUpgradeTransferFailed";

        cet = new(c) class'ConEventTrigger';
        cet.eventType=ET_Trigger;
        cet.label = "AugUpgradeTransferFailed";
        cet.triggerTag = 'SpawnOverflowAugUpgrade';
        cet.conversation=c;

        cee.nextEvent = cet; //Stick this after the regular end

        cee2 = new(c) class'ConEventEnd';
        cee2.eventType=ET_End;
        cee2.conversation = c;
        cet.nextEvent=cee2;
    }

    foreach AllActors(class'SpawnItemTrigger',sit,'SpawnOverflowAugUpgrade'){break;}
    if (sit==None){
        //Make sure the actual trigger that the conversation now hits
        //actually exists (this only needs to happen once, unlike the
        //conversation tweaks)
        sit = Spawn(class'SpawnItemTrigger',,'SpawnOverflowAugUpgrade');
        sit.spawnClass=class'#var(prefix)AugmentationUpgradeCannister';
        sit.spawnLoc = vectm(-462,1385,248);
    }

}

//#region Adjust Infolinks
function RearrangeJockExitDialog()
{
    local Conversation c;
    local ConEvent ce,prev;
    local ConEventSpeech ces;
    local ConEventAddSkillPoints ceasp;
    local ConEventAddGoal ceag,goalComplete;

    c = GetConversation('M08JockExit');

    ce = c.eventList;
    prev=None;
    while (ce!=None){
        if (ce.eventType==ET_AddGoal){
            ceag = ConEventAddGoal(ce);
            if (ceag.goalName=='GetBackToRoof'){
                //Pull this goal out of the list
                goalComplete = ceag;
                prev.nextEvent = goalComplete.nextEvent;
            }
        } else if (ce.eventType==ET_AddSkillPoints){
            ceasp = ConEventAddSkillPoints(ce);
        }
        prev=ce;
        ce = ce.nextEvent;
    }

    if (ceasp!=None && goalComplete!=None){
        //The "GetBackToRoof" goal normally only gets marked as complete if you have a LAM
        //Move it to get completed when you head out with Jock
        goalComplete.nextEvent = ceasp.nextEvent;
        ceasp.nextEvent = goalComplete;
    }


}

function RearrangeMJ12ConvergingInfolink()
{
    local Conversation c;
    local ConEvent ce;
    local ConEventSpeech ces;
    local ConEventSetFlag cesf;

    c = GetConversation('DL_Exit');

    ce = c.eventList;
    while (ce!=None){
        if (ce.eventType==ET_Speech){
            ces = ConEventSpeech(ce);
        } else if (ce.eventType==ET_SetFlag){
            cesf = ConEventSetFlag(ce);
        }
        ce = ce.nextEvent;
    }

    if (ces!=None && cesf!=None && ces.nextEvent==cesf){
        //The conversation is typically:
        //Speech -> SetFlag -> End
        //but I want it to be
        //SetFlag -> Speech -> End

        ces.nextEvent = cesf.nextEvent;
        cesf.nextEvent = ces;
        c.eventList = cesf;
    }

}

//#endregion

function Name FindCorrespondingCopTag(Name unatcoTag)
{
    switch(unatcoTag){
        case 'troop1':
        case 'troop1_clone':
            return 'Cop1';
        case 'troop2':
        case 'troop2_clone':
            return 'Cop2';
        case 'troop3':
        case 'troop3_clone':
            return 'Cop3';
        case 'troop4':
        case 'troop4_clone':
            return 'Cop4';
        case 'troop5':
        case 'troop5_clone':
            return 'Cop5';
        case 'troop6':
        case 'troop6_clone':
            return 'Cop6';
        default:
            return '';
    }
}

function Name FindReinforcementPointTag(Name copTag)
{
    //Intentionally don't apply these to the clone tags, since the mission script only checks non-clones
    switch(copTag){
        case 'Cop1':
            return 'Cop1Reinforcements';
        case 'Cop2':
            return 'Cop2Reinforcements';
        case 'Cop3':
            return 'Cop3Reinforcements';
        case 'Cop4':
            return 'Cop4Reinforcements';
        case 'Cop5':
            return 'Cop5Reinforcements';
        case 'Cop6':
            return 'Cop6Reinforcements';
        default:
            return '';
    }
}

function SetUNATCOTargetOrders(#var(prefix)ScriptedPawn troop)
{
    local name reinforceTag;

    reinforceTag = FindReinforcementPointTag(FindCorrespondingCopTag(troop.Tag));

    if (reinforceTag=='') return;

    troop.bKeepWeaponDrawn=True;
    troop.SetOrders('RunningTo',reinforceTag,True);
}


//#region Timer
function TimerMapFixes()
{
    local BlackHelicopter chopper;
    local bool VanillaMaps;
    local DeusExGoal newGoal;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL)
    {
    case "08_NYC_STREET":
        if (VanillaMaps && dxr.flagbase.GetBool('StantonDowd_Played') )
        {
            foreach AllActors(class'BlackHelicopter', chopper, 'CopterExit')
                chopper.EnterWorld();
            dxr.flagbase.SetBool('MS_Helicopter_Unhidden', True,, 9);
        }

        if (dxr.flagbase.GetBool('MS_Helicopter_Unhidden') && player().FindGoal('GetBackToRoof')==None){
            newGoal=player().AddGoal('GetBackToRoof',True);
            if(dxr.flags.settings.goals > 0) {
                newGoal.SetText("Find Jock and take the helicopter to Brooklyn Naval Shipyard.|nRando: Jock could be anywhere in the streets.");
            } else {
                newGoal.SetText("Find Jock and take the helicopter to Brooklyn Naval Shipyard.");
            }
        }

        break;
    }
}
//#endregion

//#region Pre First Entry
function PreFirstEntryMapFixes()
{
    local #var(prefix)DataLinkTrigger dlt;
    local #var(prefix)NanoKey k;
    local #var(prefix)PigeonGenerator pg;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
#ifdef revision
    local JockHelicopter jockheli;
#endif
    local OnceOnlyTrigger oot;
    local #var(DeusExPrefix)Mover d;
    local DXRHoverHint hoverHint;
    local bool VanillaMaps;
    local ScriptedPawn pawn;
    local #var(prefix)LaserTrigger lt;
    local Teleporter tel;
    local DynamicTeleporter dtel;
    local RiotCop rc;
    local Smuggler smug;
    local #var(prefix)OrdersTrigger ot;
    local DXRReinforcementPoint reinforce;
    local #var(prefix)BarrelFire bf;

#ifdef injections
    local #var(prefix)Newspaper np;
    local class<#var(prefix)Newspaper> npClass;
    npClass = class'#var(prefix)Newspaper';
#else
    local DXRInformationDevices np;
    local class<DXRInformationDevices> npClass;
    npClass = class'DXRInformationDevices';
#endif

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL)
    {
        //#region Street
        case "08_NYC_STREET":

            //Reinforcements for the sixth cop
            if (class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) {
                pawn=#var(prefix)UNATCOTroop(Spawnm(class'#var(prefix)UNATCOTroop',,'troop6', vect(-85,80,-460)));
                pawn.SetAlliance('UNATCO');
                ChangeInitialAlliance(pawn,'Player',-1,true);
                pawn.bInWorld=false;
                pawn.InitializePawn();

                pawn=#var(prefix)UNATCOTroop(Spawnm(class'#var(prefix)UNATCOTroop',,'troop6', vect(-150,80,-460)));
                pawn.SetAlliance('UNATCO');
                ChangeInitialAlliance(pawn,'Player',-1,true);
                pawn.bInWorld=false;
                pawn.InitializePawn();
            }

            // fix alliances
            foreach AllActors(class'ScriptedPawn', pawn) {
                switch(pawn.Alliance) {
                case 'UNATCO':
                case 'RiotCop':
                case 'Robot':
                case 'MJ12':
                case 'ShadyGuy':
                    // make their alliances permananet
                    pawn.ChangeAlly('RiotCop', 1, true);
                    pawn.ChangeAlly('Robot', 1, true);
                    pawn.ChangeAlly('UNATCO', 1, true);
                    pawn.ChangeAlly('MJ12', 1, true);
                    pawn.ChangeAlly('ShadyGuy', 1, true);

                    //InitialAlliances also need to be changed so that clones get the correct alliances
                    ChangeInitialAlliance(pawn, 'RiotCop', 1, true);
                    ChangeInitialAlliance(pawn, 'Robot', 1, true);
                    ChangeInitialAlliance(pawn, 'UNATCO', 1, true);
                    ChangeInitialAlliance(pawn, 'MJ12', 1, true);
                    ChangeInitialAlliance(pawn, 'ShadyGuy', 1, true);
                    break;
                }
            }
            //Since we always spawn the helicopter on the roof immediately after the conversation,
            //the ambush should also always happen immediately after the conversation (instead of
            //after getting explosives)
            foreach AllActors(class'#var(prefix)DataLinkTrigger',dlt)
            {
                if (dlt.CheckFlag=='PlayerHasExplosives'){
                    dlt.CheckFlag='StantonDowd_Played';
                    if(VanillaMaps) {
                        dlt.SetCollisionSize(516, 1000);
                        dlt = spawn(class'#var(prefix)DataLinkTrigger',,, vectm(990.951843, 1799.208252, -455.899506));
                        dlt.SetCollisionSize(516, 1000);
                        dlt.CheckFlag='StantonDowd_Played';
                        dlt.datalinkTag = 'DL_Exit';
                        break;
                    }
                }
            }

            pg=Spawn(class'#var(prefix)PigeonGenerator',,, vectm(-2102,1942,-503));//In park
            pg.MaxCount=3;

            //Add teleporter hint text to Jock
            foreach AllActors(class'#var(prefix)MapExit',exit){break;}
            if (VanillaMaps){
                foreach AllActors(class'#var(prefix)BlackHelicopter',jock){break;}
                hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit,, true);
                hoverHint.SetBaseActor(jock);
            } else {
            #ifdef revision
                foreach AllActors(class'JockHelicopter',jockheli){break;}
                hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jockheli.Location, jockheli.CollisionRadius+5, jockheli.CollisionHeight+5, exit,, true);
                hoverHint.SetBaseActor(jockheli);
            #endif
            }

            if (#defined(vanilla)) {
                class'MoverToggleTrigger'.static.CreateMTT(self, 'DXRSmugglerElevatorUsed', 'elevatorbutton', 0, 1, 0.0, 9);
                foreach AllActors(class'Teleporter', tel) {
                    if (tel.URL == "08_NYC_Smug#ToSmugFrontDoor") {
                        dtel = class'DynamicTeleporter'.static.ReplaceTeleporter(tel);
                        dtel.SetDestination("08_NYC_Smug", 'PathNode83',, 16384);
                        class'DXREntranceRando'.static.AdjustTeleporterStatic(dxr, dtel);
                        break;
                    }
                }
            }

            if (VanillaMaps){
                foreach AllActors(class'#var(prefix)BarrelFire', bf) {
                    if(bf.name=='BarrelFire0') {
                        bf.bIsSecretGoal = true; // the flaming barrel near Dowd is good for visibility
                        break;
                    }
                }
            } else {
                foreach AllActors(class'#var(prefix)BarrelFire', bf) {
                    if(bf.name=='BarrelFire40' || bf.name=='BarrelFire41') {
                        bf.bIsSecretGoal = true; // the flaming barrel near Dowd is good for visibility
                    }
                }
            }

            break;
    //#endregion

    //#region Hotel
        case "08_NYC_HOTEL":
            if (VanillaMaps){
                if(class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) {
                    Spawn(class'#var(prefix)Binoculars',,, vectm(-610.374573,-3221.998779,94.160065)); //Paul's bedside table
                    SpawnDatacubeTextTag(vectm(-840,-2920,85), rotm(0,0,0,0), '02_Datacube07',False); //Paul's stash code, in bottom of closet

                    k = Spawn(class'#var(prefix)NanoKey',,, vectm(-967,-1240,-74)); //In a mail nook
                    k.KeyID = 'CrackRoom';
                    k.Description = "'Ton Hotel, North Room Key";
                    if(dxr.flags.settings.keysrando > 0)
                        GlowUp(k);

                    k = Spawn(class'#var(prefix)NanoKey',,, vectm(-845,-2920,180)); //Top shelf of Paul's closet
                    k.KeyID = 'Apartment';
                    k.Description = "Apartment key";
                    if(dxr.flags.settings.keysrando > 0)
                        GlowUp(k);
                }

                foreach AllActors(class'RiotCop', rc) {
                    if (rc.bindname == "RiotCop") {
                        rc.bindname = "Cop";
                    }
                }

                foreach RadiusActors(class'#var(DeusExPrefix)Mover', d, 1.0, vectm(-304.0, -3000.0, 64.0)) {
                    // interpolate Paul's bathroom door to its starting position so it doesn't close instantaneously when frobbed
                    d.InterpolateTo(1, 0.0);
                    break;
                }

                Spawn(class'PlaceholderItem',,, vectm(-732,-2628,75)); //Actual closet
                Spawn(class'PlaceholderItem',,, vectm(-732,-2712,75)); //Actual closet
                Spawn(class'PlaceholderItem',,, vectm(-129,-3038,127)); //Bathroom counter
                Spawn(class'PlaceholderItem',,, vectm(15,-2972,123)); //Kitchen counter
                Spawn(class'PlaceholderItem',,, vectm(-853,-3148,75)); //Crack next to Paul's bed
            } else {
                if(class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) {
                    Spawn(class'#var(prefix)Binoculars',,, vectm(-90,-3958,95)); //Paul's bedside table
                    k = Spawn(class'#var(prefix)NanoKey',,, vectm(-900,-1385,-74)); //In a mail nook
                    k.KeyID = 'Hotelroom1';
                    k.Description = "'Ton Hotel, South Room Key";
                    if(dxr.flags.settings.keysrando > 0)
                        GlowUp(k);

                    k = Spawn(class'#var(prefix)NanoKey',,, vectm(-300,-3630,180)); //Top shelf of Paul's closet
                    k.KeyID = 'Apartment';
                    k.Description = "Apartment key";
                    if(dxr.flags.settings.keysrando > 0)
                        GlowUp(k);

                    SpawnDatacubeTextTag(vectm(-295,-3655,85), rotm(0,0,0,0), '02_Datacube07',False); //Paul's stash code, in bottom of closet
                }


                Spawn(class'PlaceholderItem',,, vectm(-180,-3365,70)); //Actual closet
                Spawn(class'PlaceholderItem',,, vectm(-180,-3450,70)); //Actual closet
                Spawn(class'PlaceholderItem',,, vectm(480,-3775,125)); //Bathroom counter
                Spawn(class'PlaceholderItem',,, vectm(550,-3700,120)); //Kitchen counter
                Spawn(class'PlaceholderItem',,, vectm(-310,-3900,75)); //Crack next to Paul's bed
            }
            break;
    //#endregion

    //#region Bar
        case "08_NYC_BAR":
            FixHarleyFilben();
            class'PoolTableManager'.static.CreatePoolTableManagers(self);
            if (!VanillaMaps){
                AddActor(class'PoolTableResetButton',vect(-1970,-565.3,145),rot(0,16384,0));
            } else {
                AddActor(class'PoolTableResetButton',vect(-1700,-389.3,50),rot(0,16384,0));
            }

            npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(-1171.976440,250.575806,53.729687),rotm(0,0,0,0),'08_Newspaper01'); //Joe Greene article, table near where Harley is in Vanilla
            if (class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)){
                Spawn(class'BarDancer',,,vectm(-2150,-500,48),rotm(0,0,0,0));
            } else {
                Spawn(class'BarDancerBoring',,,vectm(-2150,-500,48),rotm(0,0,0,0));
            }

            break;
    //#endregion

    //#region Smuggler
        case "08_NYC_SMUG":
            foreach AllActors(class'#var(DeusExPrefix)Mover', d,'botordertrigger') {
                d.tag = 'botordertriggerDoor';
            }
            oot = Spawn(class'OnceOnlyTrigger');
            oot.Event='botordertriggerDoor';
            oot.Tag='botordertrigger';

            if (class'MenuChoice_BalanceMaps'.static.ModerateEnabled()){
                //The bot will no longer directly be ordered to attack the player
                //This prevents him from breaking stealth
                //There is already an AllianceTrigger and he will move to where his home base is outside the door
                foreach AllActors(class'#var(prefix)OrdersTrigger',ot,'InitiateOrder'){
                    ot.Destroy();

                    ot = #var(prefix)OrdersTrigger(Spawnm(class'#var(prefix)OrdersTrigger',,'InitiateOrder'));
                    ot.Event='smugglerbots';
                    ot.SetCollision(false,false,false);
                    ot.Orders='GoingTo';
                    ot.ordersTag='SmugBotDest';

                    break;
                }

                reinforce=Spawn(class'DXRReinforcementPoint',,'SmugBotDest',vectm(0,-400,-10));
                reinforce.SetCollisionSize(16,32);
                reinforce.SetAsHomeBase(false);
            }

            foreach AllActors(class'Smuggler', smug) {
                smug.bImportant = true;
                break;
            }

            if (!dxr.flagbase.GetBool('FordSchickRescued')) {
                SetAllLampsState(false, true, true); // smuggler has one table lamp, upstairs where no one is unless Ford was rescued
            }

            class'MoverToggleTrigger'.static.CreateMTT(self, 'DXRSmugglerElevatorUsed', 'elevatorbutton', 1, 0, 0.0, 9);

            //Verified in both vanilla and Revision
            foreach AllActors(class'#var(DeusExPrefix)Mover', d,'mirrordoor'){break;}
            class'FakeMirrorInfo'.static.Create(self,vectm(-527,1660,348),vectm(-627,1655,220),d); //Mirror in front of Smuggler's Stash

            break;
    //#endregion

    //#region Free Clinic
        case "08_NYC_FREECLINIC":
            SetAllLampsState(true, true, false); // the free clinic has one desk lamp, at a desk no one is using
            break;
    //#endregion

    //#region Underground (Sewers)
        case "08_NYC_UNDERGROUND":
            if(class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) {
                foreach AllActors(class'#var(prefix)LaserTrigger',lt){
                    if (lt.Location.Z < -574 && lt.Location.Z > -575){
                        lt.SetLocation(lt.Location+vect(0,0,11)); //Move them slightly higher up to match their location in mission 2, so you can crouch under
                    }
                }
            }
            break;
    //#endregion
    }
}
//#endregion

//#region Post First Entry
function PostFirstEntryMapFixes()
{
    local #var(prefix)ScriptedPawn sp;
    local name rpTag;
    local DXRReinforcementPoint reinforce;

    DXRStartDataLinkTransmission("DL_Entry"); // play on any start
    switch(dxr.localURL)
    {
        case "08_NYC_STREET":

            if (class'MenuChoice_BalanceMaps'.static.ModerateEnabled()){
                //Place reinforcement points on the cops
                foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
                    rpTag = FindReinforcementPointTag(sp.Tag);
                    if (rpTag!=''){
                        reinforce = sp.Spawn(class'DXRReinforcementPoint',,rpTag,sp.Location);
                        reinforce.Init(sp);
                    }
                }

                //Make sure the troopers are running to the reinforcement points
                foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
                    SetUNATCOTargetOrders(sp);
                }

                //A point for the MJ12 Attack Force to run to (the stairs of Osgoode & Sons)
                //This location works for both Vanilla maps and Revision
                reinforce = Spawn(class'DXRReinforcementPoint',,'MJ12AttackForceTarget',vectm(530,1900,-450));
                reinforce.SetCollisionSize(200,100); //Make it bigger than the other reinforcement points

                //Make the Attack Force run to the reinforcement point instead of directly attacking the player
                foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
                    if (sp.Tag!='MJ12AttackForce' && sp.Tag!='MJ12AttackForce_clone') continue;

                    sp.bKeepWeaponDrawn=True;
                    sp.SetOrders('RunningTo','MJ12AttackForceTarget',True);
                }
            }

            break;
    }
}
//#endregion
