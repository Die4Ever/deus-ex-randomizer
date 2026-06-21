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
            FixNoRoomForSmuggler();
        }

        if (dxr.flagbase.getBool('SmugglerDoorDone')) {
            dxr.flagbase.setBool('MetSmuggler', true,, -1);
        }
        break;
    case "08_NYC_BAR":
        if (!#defined(gmdx) && !#defined(vmd) && !(#defined(revision)&&!VanillaMaps)){
            //This is fixed in:
            // - ConFix (used by GMDX)
            // - Revision conversations (which I guess only get used on Revision Maps)
            // - Vanilla? Madder!
            AddNoRoomToJordanSheaConvo();
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
    local ConEventMoveCamera cemc;
    local ConEventSpeech ces, noRoom, normalSpeech;
    local SpawnItemTrigger sit;

    FixConversationGiveItem(GetConversation('M08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister'); //Make sure he tries to transfer the right class

    //Find an instance of JC saying "no room"
    noRoom = GetSpeechEvent(GetConversation('M08SmugglerConvos').eventList,"I don't have enough room to carry that.");

    //Make sure there's handling for a full inventory
    c = GetConversation('M08MeetFordSchick');

    ce = c.eventList;
    prev=None;
    while (ce!=None){
        if (ce.eventType==ET_End){
            cee = ConEventEnd(ce);
        } else if (ce.eventType==ET_TransferObject){
            ceto = ConEventTransferObject(ce);
        } else if (ce.eventType==ET_MoveCamera){
            cemc = ConEventMoveCamera(ce); //We want to find the last one, which is a Head Shot, Mid
            if (cemc.cameraPosition!=CP_HeadShotMid){
                cemc=None;
            }
        } else if (ce.eventType==ET_Speech && normalSpeech==None){
            //find a case where JC is talking to Ford, for reference
            normalSpeech = ConEventSpeech(ce);
            if (normalSpeech.speakerName!="JCDenton"){
                normalSpeech=None;
            }
        }
        prev=ce;
        ce = ce.nextEvent;
    }

    if(cee!=None && ceto!=None && noRoom!=None && normalSpeech!=None){
        //Found all the relevant conversation pieces we need

        //After the regular conversation end, add a Trigger event and a new End event.
        //If the item transfer fails, it will jump to the new Trigger event, which will
        //spawn the aug can on the table instead.

        if (ceto.failLabel!=""){
            //Quick failsafe, don't make any changes if there's already a failLabel set from something else
            return;
        }

        ceto.failLabel = "AugUpgradeTransferFailed";

        //Trigger a SpawnItemTrigger to spawn the upgrade can on the table
        cet = NewConEventTrigger(c,cee,'SpawnOverflowAugUpgrade'); //Trigger goes after the regular end
        cet.label = "AugUpgradeTransferFailed";

        //Stitch a "No room!" line onto the end of the conversation for more clarity
        ces = NewConEventSpeech(c,cet,noRoom.conSpeech.speech,noRoom.conSpeech.soundID);
        ces.speaker = normalSpeech.speaker;
        ces.speakerName = normalSpeech.speakerName;
        ces.speakingTo = normalSpeech.speakingTo;
        ces.speakingToName = normalSpeech.speakingToName;
        ces.bBold = noRoom.bBold;
        ces.speechFont = noRoom.speechFont;

        //End the conversation
        cee2 = ConEventEnd(NewConEvent(c,ces,class'ConEventEnd')); //End goes after the voice line

        //Tweak the final camera angle, to hopefully give vision on the spawning aug can when it fails
        //No promises though, because the camera positions are more like suggestions
        if (cemc!=None){
            cemc.cameraPosition = CP_ShoulderRight;
        }
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

function FixNoRoomForSmuggler(){
    local Conversation c;
    local ConEvent ce, prev, addCreds,transfer;
    local ConEventTransferObject ceto;

    c = GetConversation('M08SmugglerConvos');

    //BuyShotgun, BuySabot, and BuyGEP all take your money before trying to transfer the object
    //We want to swap those back around.  They also don't have a "No Room" fail path assigned.
    ce = c.eventList;
    while (ce!=None){
        switch(ce.label)
        {
            case "BuyShotgun": //It is criminal that he is asking 7500 for an assault shotgun
            case "BuySabot":
            case "BuyGEP":
                if (ce.eventType==ET_AddCredits &&
                    ce.nextEvent!=None &&
                    ce.nextEvent.eventType==ET_TransferObject)
                {
                    //We need to swap these events around so the transfer is first
                    addCreds = ce;
                    transfer = ce.nextEvent;

                    prev.nextEvent = transfer;
                    addCreds.nextEvent = transfer.nextEvent;
                    transfer.nextEvent = addCreds;

                    transfer.label = addCreds.label;
                    addCreds.label = "";

                    ce = transfer;
                }

                break;

            default:
                break;
        }
        if (ce.eventType==ET_TransferObject){
            ceto = ConEventTransferObject(ce);
            if (ceto!=None && ceto.failLabel == ""){
                //There are a few transfers that don't fail if you don't have room
                ceto.failLabel = "NoRoom";
            }
        }
        prev = ce;
        ce = ce.nextEvent;
    }

}

function AddNoRoomToJordanSheaConvo(){
    //When you buy from Jordan in this mission, they got lazy and didn't have a failure path
    //for when you don't have room to accept the candy or booze you buy.  Luckily, there's a
    //line that's good enough that we can yoink from the conversation with Smuggler.
    local ConEventSpeech origNoRoom, newNoRoom, normalSpeech;
    local Conversation c;
    local ConEvent ce,ceeNext;
    local ConEventTransferObject ceto;
    local ConEventEnd cee,cee2;

    //First, find the "No Room" line from the Smuggler convo
    origNoRoom = GetSpeechEvent(GetConversation('M08SmugglerConvos').eventList,"I don't have enough room to carry that.");

    //Now we need to make a new branch in Jordan's conversation and adjust the transfer item events to point to it
    c = GetConversation('M08JordanSheaConvos');
    ce = c.eventList;
    while (ce!=None){
        if (ce.eventType==ET_End){
            //Keep track of these end events.  We're going to add our new bit after the last end
            cee = ConEventEnd(ce);
        } else if (ce.eventType==ET_Speech && normalSpeech==None){
            //find a case where JC is talking to Jordan, for reference
            normalSpeech = ConEventSpeech(ce);
            if (normalSpeech.speakerName!="JCDenton"){
                normalSpeech=None;
            }
        }
        ce = ce.nextEvent;
    }

    if (cee == None) return; //We're hosed if this doesn't exist.
    ceeNext = cee.nextEvent;

    newNoRoom = NewConEventSpeech(c,cee,origNoRoom.conSpeech.speech,origNoRoom.conSpeech.soundID);
    newNoRoom.speaker = normalSpeech.speaker;
    newNoRoom.speakerName = normalSpeech.speakerName;
    newNoRoom.speakingTo = normalSpeech.speakingTo;
    newNoRoom.speakingToName = normalSpeech.speakingToName;
    newNoRoom.bBold = origNoRoom.bBold;
    newNoRoom.speechFont = origNoRoom.speechFont;
    newNoRoom.label = "DXRandoNoRoom";

    //End the conversation
    cee2 = ConEventEnd(NewConEvent(c,newNoRoom,class'ConEventEnd')); //New ending goes after the "No Room" speech
    cee2.nextEvent=ceeNext;//New ending will point to what the old ending pointed to (presumably None)

    //Now point all the Transfer Object events to the "No Room" branch if they fail
    ce = c.eventList;
    while (ce!=None){
        if (ce.eventType==ET_TransferObject){
            ceto = ConEventTransferObject(ce);
            if (ceto!=None && ceto.failLabel==""){
                ceto.failLabel = "DXRandoNoRoom";
            }
        }
        ce = ce.nextEvent;
    }

}

//#region Adjust Infolinks
function RearrangeJockExitDialog()
{
    local Conversation c;
    local ConEvent ce,prev;
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

        if (#defined(gmdxnotae)){
            GMDXUnatcoTroopTimerChecks();
        }

        break;
    }
}
//#endregion

//A dupe of the vanilla spawning logic, which is commented out
//in the GMDX Mission08 mission script.
//Brings in both original troops and any clones
function GMDXUnatcoTroopTimerChecks()
{
    local RiotCop cop;
    local UNATCOTroop troop;
    local #var(prefix)ScriptedPawn sp;
    local int count;

    // spawn reinforcements as cops are killed
    if (!dxr.flagbase.GetBool('MS_UnhideTroop1'))
    {
        count = 0;
        foreach AllActors(class'RiotCop', cop, 'Cop1')
            count++;

        if (count == 0)
        {
            //foreach AllActors(class'UNATCOTroop', troop, 'troop1')
            //    troop.EnterWorld();
            foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
                switch(sp.Tag){
                    case 'troop1':
                    case 'troop1_clone':
                        sp.EnterWorld();
                        break;
                }
            }

            dxr.flagbase.SetBool('MS_UnhideTroop1', True,, 9);
        }
    }
    if (!dxr.flagbase.GetBool('MS_UnhideTroop2'))
    {
        count = 0;
        foreach AllActors(class'RiotCop', cop, 'Cop2')
            count++;

        if (count == 0)
        {
            //foreach AllActors(class'UNATCOTroop', troop, 'troop2')
            //    troop.EnterWorld();
            foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
                switch(sp.Tag){
                    case 'troop2':
                    case 'troop2_clone':
                        sp.EnterWorld();
                        break;
                }
            }

            dxr.flagbase.SetBool('MS_UnhideTroop2', True,, 9);
        }
    }
    if (!dxr.flagbase.GetBool('MS_UnhideTroop3'))
    {
        count = 0;
        foreach AllActors(class'RiotCop', cop, 'Cop3')
            count++;

        if (count == 0)
        {
            //foreach AllActors(class'UNATCOTroop', troop, 'troop3')
            //    troop.EnterWorld();
            foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
                switch(sp.Tag){
                    case 'troop3':
                    case 'troop3_clone':
                        sp.EnterWorld();
                        break;
                }
            }

            dxr.flagbase.SetBool('MS_UnhideTroop3', True,, 9);
        }
    }
    if (!dxr.flagbase.GetBool('MS_UnhideTroop4'))
    {
        count = 0;
        foreach AllActors(class'RiotCop', cop, 'Cop4')
            count++;

        if (count == 0)
        {
            //foreach AllActors(class'UNATCOTroop', troop, 'troop4')
            //    troop.EnterWorld();
            foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
                switch(sp.Tag){
                    case 'troop4':
                    case 'troop4_clone':
                        sp.EnterWorld();
                        break;
                }
            }

            dxr.flagbase.SetBool('MS_UnhideTroop4', True,, 9);
        }
    }
    if (!dxr.flagbase.GetBool('MS_UnhideTroop5'))
    {
        count = 0;
        foreach AllActors(class'RiotCop', cop, 'Cop5')
            count++;

        if (count == 0)
        {
            //foreach AllActors(class'UNATCOTroop', troop, 'troop5')
            //    troop.EnterWorld();
            foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
                switch(sp.Tag){
                    case 'troop5':
                    case 'troop5_clone':
                        sp.EnterWorld();
                        break;
                }
            }

            dxr.flagbase.SetBool('MS_UnhideTroop5', True,, 9);
        }
    }
    if (!dxr.flagbase.GetBool('MS_UnhideTroop6'))
    {
        count = 0;
        foreach AllActors(class'RiotCop', cop, 'Cop6')
            count++;

        if (count == 0)
        {
            //foreach AllActors(class'UNATCOTroop', troop, 'troop6')
            //    troop.EnterWorld();
            foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
                switch(sp.Tag){
                    case 'troop6':
                    case 'troop6_clone':
                        sp.EnterWorld();
                        break;
                }
            }

            dxr.flagbase.SetBool('MS_UnhideTroop6', True,, 9);
        }
    }
}

//GMDXv9 just sticks all the UNATCO guys into a pile near the
//basketball court, which sucks for that as a random start location.
//Move them back to where they were in vanilla and throw them out of
//world, so that they spawn in as you kill riot cops, like vanilla.
function GMDXInitUnatcoTroopLocations()
{
    local int troopGroup[5];
    local UNATCOTroop troop;
    local int i;
    local vector groupLoc[2];

    foreach AllActors(class'UNATCOTroop',troop){
        i=-1;
        switch (troop.Tag){
            case 'troop1':
                groupLoc[0]=vectm(-2189.358643,-121.666634,-439.463501);
                groupLoc[1]=vectm(-2166.745850,-184.898239,-439.463593);
                i = 0;
                break;
            case 'troop2':
                groupLoc[0]=vectm(1250.246338,-2782.366943,-439.463593);
                groupLoc[1]=vectm(1314.120728,-2762.695801,-439.463593);
                i = 1;
                break;
            case 'troop3':
                groupLoc[0]=vectm(-968.075439,-2133.654053,-439.463593);
                groupLoc[1]=vectm(-1059.733398,-2128.914307,-439.463593);
                i = 2;
                break;
            case 'troop4':
                groupLoc[0]=vectm(2134.842041,955.861084,-439.463593);
                groupLoc[1]=vectm(2129.507080,872.361023,-439.463593);
                i = 3;
                break;
            case 'troop5':
                groupLoc[0]=vectm(-2641.368896,1566.562012,-454.205292);
                groupLoc[1]=vectm(-2643.181885,1649.113647,-451.688416);
                i = 4;
                break;
        }

        if (i!=-1){
            troop.SetLocation(groupLoc[troopGroup[i]]);

            if (troopGroup[i]==0){
                troopGroup[i]=1;
            }
        }
    }
}

//This has to be done later than PreFirstEntry, otherwise the game locks up
function SendGMDXUNATCOTroopsOutOfWorld(#var(prefix)ScriptedPawn sp)
{
    switch(sp.Tag){
        case 'troop1':
        case 'troop1_clone':
        case 'troop2':
        case 'troop2_clone':
        case 'troop3':
        case 'troop3_clone':
        case 'troop4':
        case 'troop4_clone':
        case 'troop5':
        case 'troop5_clone':
        case 'troop6':
        case 'troop6_clone':
            sp.LeaveWorld();
            break;
    }
}

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
    local #var(prefix)Keypad2 kp;
    local #var(prefix)SecurityBot3 bot;
    local #var(prefix)Switch1 s1;

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

            if (#defined(gmdxnotae)){
                GMDXInitUnatcoTroopLocations();
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

                FixHotelPatrolPaths();

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
                Spawnm(class'BarDancer',,,vect(-2150,-500,48),rot(0,0,0));
            } else {
                Spawnm(class'BarDancerBoring',,,vect(-2150,-500,48),rot(0,0,0));
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

            if (class'DXRMapVariants'.static.IsGMDXMaps(player()) && class'MenuChoice_BalanceMaps'.static.ModerateEnabled()){
                FixGMDXSmugglerBots();
            }

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

            //The bot starts "standing" instead of "idle".
            //This makes it so he would still attack hostiles if present (and also makes him pettable)
            foreach AllActors(class'#var(prefix)SecurityBot3', bot, 'smugglerbots') {
                bot.SetOrders('Standing');
            }

            foreach AllActors(class'Smuggler', smug) {
                smug.bImportant = true;
                break;
            }

            if (!dxr.flagbase.GetBool('FordSchickRescued')) {
                SetAllLampsState(false, true, true); // smuggler has one table lamp, upstairs where no one is unless Ford was rescued
            }

            if (#bool(vanilla)) {
                class'MoverToggleTrigger'.static.CreateMTT(self, 'DXRSmugglerElevatorUsed', 'elevatorbutton', 1, 0, 0.0, 9);
            }
            if (VanillaMaps) {
                foreach RadiusActors(class'#var(prefix)Switch1', s1, 0.1, vectm(-59.050560, -1450.105591, 17.855021)) {
                    s1.moverTag = 'elevatorbutton';
                    s1.BeginPlay();
                    break;
                }
            }

            //Verified in both vanilla and Revision
            foreach AllActors(class'#var(DeusExPrefix)Mover', d,'mirrordoor'){break;}
            class'FakeMirrorInfo'.static.Create(self,vectm(-527,1660,348),vectm(-627,1655,220),d); //Mirror in front of Smuggler's Stash

            break;
    //#endregion

    //#region Free Clinic
        case "08_NYC_FREECLINIC":
            SetAllLampsState(true, true, false); // the free clinic has one desk lamp, at a desk no one is using

            if (VanillaMaps){
                //The keypad to surgery is backwards in GOTY.  Revert to non-GOTY rotation...
                //Of course, the door is broken open so it's not exactly necessary
                foreach AllActors(class'#var(prefix)Keypad2',kp){
                    if (kp.Event=='InSurgery'){
                        kp.SetRotation(rotm(0,-49176,0,GetRotationOffset(kp.Class)));
                        break;
                    }
                }
            }
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

//Smugglers bots in GMDX are always hostile to the player in M08, presumably a mistake?
function FixGMDXSmugglerBots()
{
    local SecurityBot3 bot;
    local DeusExMover  dxm;
    local Dispatcher   disp;
    local FlagTrigger  ft;

    //We will have already added a OnceOnlyTrigger to the lasers, expecting this door to be named this
    foreach AllActors(class'DeusExMover', dxm,'InitiateOrder')
    {
        dxm.tag = 'botordertriggerDoor';
    }

    //The bots start hostile instead of friendly
    foreach AllActors(class'SecurityBot3',bot)
    {
        ChangeInitialAlliance(bot,'Player',1.0,true); //Make sure the initial alliance is updated for clones
        bot.ChangeAlly('Player',1.0,true,false); //Make sure the bots are permanently friendly
    }

    //The flagtrigger has no tag or event
    foreach AllActors(class'FlagTrigger',ft)
    {
        if (ft.FlagName!='MetSmuggler') continue;
        ft.Tag = 'botordertrigger';
        ft.Event = 'InitiateOrder';
        ft.flagValue=False; //We want the bots to become hostile if the flag is false
    }

    //The dispatcher hits InitiateOrder directly, instead of botordertrigger
    foreach AllActors(class'Dispatcher',disp)
    {
        if (disp.OutEvents[1]!='InitiateOrder') continue;
        disp.OutEvents[1]='botordertrigger';
    }

}

function FixHotelPatrolPaths()
{
    local PatrolPoint pp;
    local #var(prefix)ScriptedPawn sp;

    //First, fix the tags on the patrol points (these tags align with the Transcended map fixes, so should be good regardless?)
    //Near front desk
    foreach RadiusActors(class'PatrolPoint',pp, 1, vectm(-379.099670,-1116.226318,-112.900032)){
        pp.Tag='HotelPatrol2A';
        pp.NextPatrol='HotelPatrol2B';
        break;
    }

    //Near upstairs far door
    foreach RadiusActors(class'PatrolPoint',pp, 1, vectm(670.092590,-859.416077,79.100044)){
        pp.Tag='HotelPatrol2B';
        pp.NextPatrol='HotelPatrol2C';
        pp.PauseTime=3.0;
        break;
    }

    //Near upstairs elevator
    foreach RadiusActors(class'PatrolPoint',pp, 1, vectm(-420.243744,-1938.531494,79.100182)){
        pp.Tag='HotelPatrol2C';
        pp.NextPatrol='HotelPatrol2A';
        pp.PauseTime=3.0;
        break;
    }

    //Now reinitialize all the patrol points
    foreach AllActors(class'PatrolPoint',pp){
        pp.PreBeginPlay();
    }

    //Now kick off the NPCs onto the right paths
    foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
        if (sp.Orders!='Patrolling') continue;
        sp.FollowOrders();
    }
}

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
                    if (#defined(gmdxnotae)){
                        SendGMDXUNATCOTroopsOutOfWorld(sp);
                    }
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
