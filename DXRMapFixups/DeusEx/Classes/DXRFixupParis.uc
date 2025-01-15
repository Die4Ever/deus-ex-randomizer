class DXRFixupParis extends DXRFixup;

function PreFirstEntryMapFixes()
{
    local GuntherHermann g;
    local DeusExMover m;
    local Trigger t;
    local Dispatcher d;
    local ScriptedPawn sp;
    local #var(prefix)TobyAtanwe toby;
    local #var(prefix)JaimeReyes j;
    local #var(prefix)DamageTrigger dt;
    local #var(prefix)DataLinkTrigger dlt;
    local #var(prefix)ComputerSecurity cs;
    local #var(prefix)AutoTurret at;
    local #var(prefix)WIB wib;
    local #var(prefix)MorganEverett everett;
    local #var(prefix)Chad chad;
    local DXRMapVariants mapvariants;
    local DXRHoverHint hoverHint;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
    local bool VanillaMaps;
    local FlagTrigger ft;
    local #var(prefix)Teleporter tele;
    local Businesswoman1 bw;
    local #var(prefix)NicoletteDuclare nico;
    local #var(prefix)NanoKey k;
    local DXRMoverSequenceTrigger elevatortrig;
    local Actor a;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL)
    {
    case "10_PARIS_CATACOMBS":
        FixConversationAddNote(GetConversation('MeetAimee'), "Stupid, stupid, stupid password.");
        SetAllLampsState(true, false, true); // lamps in the building next to the metro station

        AddSwitch(vect(-3615.780029, 3953.899902, 2121.5), rot(0, 16384, 0), 'roof_elevator_call');
        elevatortrig = Spawn(class'DXRMoverSequenceTrigger',, 'roof_elevator_call');
        elevatortrig.Event = 'roof_elevator';

        if(!VanillaMaps){
            //Revision, entrance to closed Metro station (split to a separate map)
            foreach AllActors(class'#var(prefix)MapExit',exit,'change_map'){break;}
            foreach AllActors(class'DeusExMover', m) {
                if (m.Event=='change_map'){
                    hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", GetMoverCenter(m), 40, 75,exit);
                }
            }
        }

        break;

    case "10_PARIS_CATACOMBS_METRO": //Revision-only map, the little underground mall area
        foreach AllActors(class'#var(prefix)MapExit',exit,'change_map'){break;}
        foreach AllActors(class'DeusExMover', m) {
            if (m.Event=='change_map'){
                hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", GetMoverCenter(m), 40, 75,exit);
            }
        }

        break;
    case "10_PARIS_CATACOMBS_TUNNELS":
        if (VanillaMaps){
            foreach AllActors(class'Trigger', t)
                if( t.Event == 'MJ12CommandoSpecial' )
                    t.Touch(player());// make this guy patrol instead of t-pose

            foreach AllActors(class'#var(prefix)WIB',wib){
                wib.UnfamiliarName="Agent Hela";
            }
            AddSwitch( vect(-2190.893799, 1203.199097, -6.663990), rot(0,0,0), 'catacombs_blastdoorB' );

            if(!dxr.flags.IsReducedRando()) {
                foreach AllActors(class'ScriptedPawn',sp){
                    if(sp.BindName=="bums"){
                        sp.bImportant=True;
                        sp.UnfamiliarName="Dr. Kit";
                        sp.FamiliarName="Dr. Mehdi Kit";
                        break;
                    }
                }
            }

            class'PlaceholderEnemy'.static.Create(self,vectm(-362,-3444,-32));
            class'PlaceholderEnemy'.static.Create(self,vectm(-743,677,-256));
        } else {
            AddSwitch( vect(-2174.426758,1208.133789,-6.660000), rot(0,0,0), 'catacombs_blastdoorB' );

            foreach AllActors(class'#var(prefix)Chad', chad){
                chad.bInvincible=False;
            }

            class'PlaceholderEnemy'.static.Create(self,vectm(-76,-3450,-280));
            class'PlaceholderEnemy'.static.Create(self,vectm(-748,601,-256));
        }
        AddSwitch( vect(897.238892, -120.852928, -9.965580), rot(0,0,0), 'catacombs_blastdoor02' );

        foreach AllActors(class'ScriptedPawn', sp, 'hostage_female') {
            sp.GroundSpeed = 200.0; // same speed as the male hostage
            sp.walkAnimMult = 1.11;
            break;
        }

        class'PlaceholderEnemy'.static.Create(self,vectm(-1573,-113,-64));
        class'PlaceholderEnemy'.static.Create(self,vectm(781,1156,-32));

        break;

    case "10_PARIS_CHATEAU":
        if (VanillaMaps){
            foreach AllActors(class'DeusExMover', m, 'everettsignal')
                m.Tag = 'everettsignaldoor';
            d = Spawn(class'Dispatcher',, 'everettsignal', vectm(176.275253, 4298.747559, -148.500031) );
            d.OutEvents[0] = 'everettsignaldoor';
            AddSwitch( vect(-769.359985, -4417.855469, -96.485504), rot(0, 32768, 0), 'everettsignaldoor' );

            SetAllLampsState(false, false, false); // surely Nicolette didn't leave all the lights on when she moved out

            foreach AllActors(class'FlagTrigger', ft) {
                if (ft.FlagName == 'ChateauInCellar') {
                    ft.Destroy();
                    break;
                }
            }

            ft = Spawn(class'FlagTrigger',,, vectm(1364.082031, 2048.021240, -311.900421));
            ft.SetCollisionSize(250.0, 40.0);
            ft.bWhileStandingOnly = true;
            ft.bTriggerOnceOnly = false;
            ft.FlagName = 'ChateauInCellar';

            ft = Spawn(class'FlagTrigger',,, vectm(979.147034, 2428.054932, -392.494201));
            ft.SetCollisionSize(300.0, 40.0);
            ft.bWhileStandingOnly = true;
            ft.bTriggerOnceOnly = false;
            ft.FlagName = 'ChateauInCellar';

            ft = Spawn(class'FlagTrigger',,, vectm(1798.484375, 2425.229736, -392.494201));
            ft.SetCollisionSize(300.0, 40.0);
            ft.bWhileStandingOnly = true;
            ft.bTriggerOnceOnly = false;
            ft.FlagName = 'ChateauInCellar';
        }

        //speed up the secret door...
        foreach AllActors(class'Dispatcher', d, 'cellar_doordispatcher') {
            d.OutDelays[1] = 0;
            d.OutDelays[2] = 0;
            d.OutDelays[3] = 0;
            d.OutEvents[2] = '';
            d.OutEvents[3] = '';
        }
        foreach AllActors(class'DeusExMover', m, 'secret_candle') {
            m.MoveTime = 0.5;
        }
        foreach AllActors(class'DeusExMover', m, 'cellar_door') {
            m.MoveTime = 1;
        }

        break;
    case "10_PARIS_METRO":
        if (VanillaMaps){
            //Add a key for the media store
            if(!dxr.flags.IsZeroRando()) {
                //On the table in the cafe
                k = Spawn(class'#var(prefix)NanoKey',,, vectm(-2020,1115,340));
                k.KeyID = 'mediastore_door';
                k.Description = "Media Store Door Key";
                if(dxr.flags.settings.keysrando > 0)
                    GlowUp(k);

                //The media store datalinkTrigger is basically inside the door we want
                foreach AllActors (class'#var(prefix)DataLinkTrigger',dlt){
                    if (dlt.datalinkTag=='DL_mediastore') break;
                }
                m = DeusExMover(findNearestToActor(class'DeusExMover',dlt));
                m.KeyIDNeeded='mediastore_door';
            }



            // make the apartment stairs less hidden, not safe to have stairs without a light!
            CandleabraLight(vect(1825.758057, 1481.900024, 576.077698), rot(0, 16384, 0));
            CandleabraLight(vect(1162.240112, 1481.900024, 879.068848), rot(0, 16384, 0));
        }

        //Add teleporter hint text to Jock
        foreach AllActors(class'#var(prefix)MapExit',exit,'ChopperExit'){break;}
        foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'BlackHelicopter'){break;}
        hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit);
        hoverHint.SetBaseActor(jock);

        //If neither flag is set, JC never talked to Jaime, so he just didn't bother
        if (!dxr.flagbase.GetBool('JaimeRecruited') && !dxr.flagbase.GetBool('JaimeLeftBehind')){
            //Need to pretend he *was* recruited, so that he doesn't spawn
            dxr.flagbase.SetBool('JaimeRecruited',True);
        }
        foreach AllActors(class'#var(prefix)JaimeReyes', j) {
            RemoveFears(j);
        }

        break;

    case "10_PARIS_CLUB":
        foreach AllActors(class'ScriptedPawn',sp){
            if (sp.BindName=="LDDPAchille" || sp.BindName=="Camille"){
                sp.bImportant=True;
            }
        }
        foreach AllActors(class'Businesswoman1', bw) {
            if (bw.UnfamiliarName == "woman") { // don't fix it if it's already been changed somewhere else
                bw.UnfamiliarName = "Woman";
            }
        }

        foreach AllActors(class'#var(prefix)NicoletteDuclare',nico){
            RemoveReactions(nico);
        }

        SetAllLampsState(true, true, false, vect(-1821.85, -351.37, -207.11), 200.0); // the two Lamp3s on the desks near the back exit, but not the one where the accountant is

        Spawn(class'PlaceholderItem',,, vectm(-607.8,-1003.2,59)); //Table near Nicolette Vanilla
        if (VanillaMaps) {
            Spawn(class'PlaceholderItem',,, vectm(-239.927216,499.098633,43)); //Ledge near club owner
            Spawn(class'PlaceholderItem',,, vectm(-1164.5,1207.85,-133)); //Table near biocell guy
            Spawn(class'PlaceholderItem',,, vectm(-2093.7,-293,-161)); //Club back room
        } else {
            Spawn(class'PlaceholderItem',,, vectm(-500,570,0)); //Ledge near club owner
            Spawn(class'PlaceholderItem',,, vectm(-895,1475,-135)); //Table near biocell guy
            Spawn(class'PlaceholderItem',,, vectm(-1745,-570,-160)); //Club back room
        }
        Spawn(class'PlaceholderItem',,, vectm(-1046,-1393,-145)); //Bathroom counter 1
        Spawn(class'PlaceholderItem',,, vectm(-1545.5,-1016.7,-145)); //Bathroom counter 2
        Spawn(class'PlaceholderItem',,, vectm(-1464,-1649.6,-197)); //Bathroom stall 1
        Spawn(class'PlaceholderItem',,, vectm(-1096.7,-847,-197)); //Bathroom stall 2

        break;
    case "11_PARIS_UNDERGROUND":
        foreach AllActors(class'DXRMapVariants', mapvariants) { break; }
        foreach AllActors(class'#var(prefix)TobyAtanwe', toby) {
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, class'DXRMapInfo'.static.GetTeleporterName(mapvariants.VaryMap("11_PARIS_EVERETT"),"Entrance"), toby.Location, toby.CollisionRadius+5, toby.CollisionHeight+5);
            hoverHint.SetBaseActor(toby);
        }
        if (VanillaMaps){
            Spawn(class'PlaceholderItem',,, vectm(2268.5,-563.7,-101)); //Near ATM
            Spawn(class'PlaceholderItem',,, vectm(408.3,768.7,-37)); //Near Mechanic
            Spawn(class'PlaceholderItem',,, vectm(-729,809.5,-1061)); //Bench at subway
            Spawn(class'PlaceholderItem',,, vectm(-733,-251,-1061)); //Bench at subway
            Spawn(class'PlaceholderItem',,, vectm(300.7,491,-1061)); //Opposite side of tracks
        } else {
            //Revision, metro station exit to Cathedral
            foreach AllActors(class'#var(prefix)MapExit',exit,'change_map'){break;}
            foreach AllActors(class'DeusExMover', m) {
                if (m.Event=='change_map'){
                    hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", GetMoverCenter(m), 40, 75,exit);
                }
            }

            Spawn(class'PlaceholderItem',,, vectm(-1135,3000,-125)); //Near ATM
            Spawn(class'PlaceholderItem',,, vectm(-855,2260,-150)); //Benches near ATM
            Spawn(class'PlaceholderItem',,, vectm(1155,1150,-320)); //Bench at subway
            Spawn(class'PlaceholderItem',,, vectm(1150,430,-320)); //Bench at subway
            Spawn(class'PlaceholderItem',,, vectm(1145,1370,-365)); //Plants near subway
        }
        break;
    case "11_PARIS_CATHEDRAL":
        foreach AllActors(class'GuntherHermann', g) {
            g.ChangeAlly('mj12', 1, true);
            g.MaxProvocations = 0;
            g.AgitationSustainTime = 3600;
            g.AgitationDecayRate = 0;
        }
        foreach AllActors(class'#var(prefix)DamageTrigger',dt){
            //There should only be two damage triggers in the map,
            //but check the damage type anyway for safety
            //This will make the fireplaces actually set you on fire
            if(dt.DamageType=='Burned'){
                dt.DamageType='Flamed';
            }
        }

        if (VanillaMaps){
            foreach AllActors(class'#var(prefix)Teleporter',tele){
                if (tele.URL=="11_Paris_Underground#Paris_Underground"){
                    tele.SetCollisionSize(tele.CollisionRadius,120); //Twice as tall, so you can't crouch under
                }

            }
        } else {
            //Items in an unopenable shop window (Nutella store)
            foreach RadiusActors(class'Actor',a,100,vectm(-4635,-4110,280)){
                if (Inventory(a)!=None || #var(DeusExPrefix)Decoration(a)!=None){
                    a.bIsSecretGoal=true;
                }
            }
            foreach RadiusActors(class'Actor',a,100,vectm(-5625,-3610,350)){
                if (Inventory(a)!=None || #var(DeusExPrefix)Decoration(a)!=None){
                    a.bIsSecretGoal=true;
                }
            }

            //Revision, entrance to Metro station
            foreach AllActors(class'#var(prefix)MapExit',exit,'change_map'){break;}
            foreach AllActors(class'DeusExMover', m) {
                if (m.Event=='change_map'){
                    hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", GetMoverCenter(m), 40, 75,exit);
                }
            }

        }
        break;
    case "11_PARIS_EVERETT":
        foreach AllActors(class'#var(prefix)ComputerSecurity',cs){
            if (cs.specialOptions[1].Text=="Nanotech Containment Field 002"){
                //This option isn't actually hooked up to anything.  The fields are on the normal security screen.
                cs.specialOptions[0].Text="";
                cs.specialOptions[0].TriggerEvent='';
                cs.specialOptions[0].TriggerText="";
                cs.specialOptions[1].Text="";
                cs.specialOptions[1].TriggerEvent='';
                cs.specialOptions[1].TriggerText="";
            }
        }

        MakeTurretsNonHostile(); //Revision has a turret that is in "attack everything" mode

        foreach AllActors(class'#var(prefix)MorganEverett', everett) {
            // Everett's vanilla BarkBindName is "Man"
            everett.BarkBindName = "MorganEverett";
            break;
        }

        //Add teleporter hint text to Jock
        foreach AllActors(class'#var(prefix)MapExit',exit,'CalledByDispatcher'){break;}
        foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'BlackHelicopter'){break;}
        hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit,, true);
        hoverHint.SetBaseActor(jock);

        SetAllLampsState(true, false, true); // Everett's bedroom

        break;
    }
}

function SpawnLeMerchant(vector loc, rotator rot)
{
    local DXRNPCs npcs;
    local DXREnemies dxre;
    local ScriptedPawn sp;
    local Merchant m;

    if(dxr.flags.settings.swapitems > 0) {
        // spawn Le Merchant with a hazmat suit because there's no guarantee of one before the highly radioactive area
        // we need to do this in AnyEntry because we need to recreate the conversation objects since they're transient
        npcs = DXRNPCs(dxr.FindModule(class'DXRNPCs'));
        if(npcs != None) {
            sp = npcs.CreateForcedMerchant("Le Merchant", 'lemerchant', class'LeMerchant', loc, rot, class'#var(prefix)HazMatSuit');
        }
        // give him weapons to defend himself
        dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
        if(dxre != None && sp != None) {
            sp.bKeepWeaponDrawn = true;
            GiveItem(sp, class'#var(prefix)WineBottle');
            dxre.RandomizeSP(sp, 100);
            RemoveFears(sp);
            sp.ChangeAlly('Player', 0.0, false);
            sp.MaxProvocations = 0;
            sp.AgitationSustainTime = 3600;
            sp.AgitationDecayRate = 0;
        }
    }

}

function AnyEntryMapFixes()
{
    local TobyAtanwe toby;
    local Conversation c;
    local ConEvent ce, cePrev;
    local ConEventSpeech ces;
    local ConEventSetFlag cesf;
    local ConEventAddSkillPoints ceasp;
    local ConEventTransferObject ceto;
    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL)
    {
    case "10_PARIS_CATACOMBS":
        if (VanillaMaps){
            SpawnLeMerchant(vectm(-3209.483154, 5190.826172,1199.610352), rotm(0, -10000, 0, 16384));
        }
        break;
    case "10_PARIS_ENTRANCE": //Revision splits Paris into a few more maps.  This is the first one
        if (!VanillaMaps){
            SpawnLeMerchant(vectm(-2222,3500,1240), rotm(0, -10000, 0, 16384));
        }
        break;
    case "10_PARIS_CATACOMBS_TUNNELS":
        SetTimer(1.0, True); //To update the Nicolette goal description
        break;
    case "10_PARIS_CLUB":
        FixConversationAddNote(GetConversation('MeetCassandra'),"with a keypad back where the offices are");
        GetConversation('AnnetteInterrupted').AddFlagRef('Chad_Dead', false);
        GetConversation('CharlotteInterrupted').AddFlagRef('Chad_Dead', false);
        break;
    case "10_PARIS_CHATEAU":
        FixConversationAddNote(GetConversation('NicoletteInStudy'),"I used to use that computer whenever I was at home");
        FixConversationFlag(GetConversation('NicoletteInCellar'), 'ChateauInCeller', true, 'ChateauInCellar', true);
        break;
    case "10_PARIS_METRO":
        //Tong gives you a map of the streets when you enter via the sewer
        c = GetConversation('DL_metrosewer');
        ce = c.eventList;
        cePrev=ce;
        while(ce!=None){
            if (ce.eventType==ET_Speech && ce.nextEvent.eventType==ET_End){
                ceto = new(c) class'ConEventTransferObject';
                ceto.eventType=ET_TransferObject;
                ceto.label="TransferMetroMap";
                ceto.objectName="Image10_Paris_Metro";
                ceto.giveObject=class'Image10_Paris_Metro';
                ceto.toName="JCDenton";
                ceto.fromName="TracerTong";
                ceto.transferCount=1;
                ceto.nextEvent=ce.nextEvent;
                ce.nextEvent=ceto;
            }
            ce=ce.nextEvent;
        }

        // fix the night manager sometimes trying to talk to you while you're flying away https://www.youtube.com/watch?v=PeLbKPSHSOU&t=6332s
        c = GetConversation('MeetNightManager');
        if(c!=None) {
            c.bInvokeBump = false;
            c.bInvokeSight = false;
            c.bInvokeRadius = false;
        }
        break;
    case "11_PARIS_UNDERGROUND":
        //Add a flag change to Toby's conversation so it sets MS_PlayerTeleported to false if you choose the "take me with you" option
        //This will let you choose to stay or go.
        foreach AllActors(class'TobyAtanwe', toby) {
            //Rebind his events to make sure his conversation is loaded if
            //you travelled from mission 10 to 11 Underground directly.
            //This would really only happen in Entrance Rando.
            toby.ConBindEvents();
        }
        c = GetConversation('MeetTobyAtanwe');
        if (c==None){
            player().ClientMessage("Failed to find conversation for Toby Atanwe!  Report this to the devs!");
        } else {
            ce = c.eventList;
            cePrev=ce;
            while(ce!=None){
                if (ce.eventType==ET_Speech){
                    ces = ConEventSpeech(ce);
                    if (InStr(ces.conSpeech.speech,"Step a little closer")!=-1){
                        //Spawn a ConEventSetFlag to set "MS_LetTobyTakeYou_Rando", insert it between this and it's next event
                        cesf = new(c) class'ConEventSetFlag';
                        cesf.eventType=ET_SetFlag;
                        cesf.label="LetTobyTakeYou";
                        cesf.flagRef = new(c) class'ConFlagRef';
                        cesf.flagRef.flagName='MS_LetTobyTakeYou_Rando';
                        cesf.flagRef.value=True;
                        cesf.flagRef.expiration=12;
                        cesf.nextEvent = ces.nextEvent;
                        ces.nextEvent = cesf;
                    }
                } else if (ce.eventType==ET_AddSkillPoints){
                    ceasp = ConEventAddSkillPoints(ce);
                    cePrev.nextEvent = ce.nextEvent; //Remove the event from its current position
                    ce.nextEvent=None;
                    ce=cePrev;
                }

                cePrev=ce;
                ce=ce.nextEvent;
            }
        }

        //Assuming we found both the "correct" conversation ending and the skill point trigger,
        //insert the skill point trigger after setting the "actually take me" flag
        if (cesf!=None && ceasp!=None){
            ceasp.nextEvent = cesf.nextEvent;
            cesf.nextEvent = ceasp;
        }

        break;
    case "11_PARIS_EVERETT":
        foreach AllActors(class'TobyAtanwe', toby) {
            toby.bInvincible = false;
        }
        break;
    }
}

function PostFirstEntryMapFixes()
{
    local #var(prefix)WIB wib;
    local #var(prefix)NanoKey k;
    local #var(PlayerPawn) p;

    p = player();

    switch(dxr.localURL) {
    case "10_PARIS_METRO":
        k = None;
        if (class'DXRMapVariants'.static.IsVanillaMaps(p)) {
            k = Spawn(class'#var(prefix)NanoKey',,, vectm(2513.0, 2439.0, 458.0));
        } else if (class'DXRMapVariants'.static.IsRevisionMaps(p)) {
            k = Spawn(class'#var(prefix)NanoKey',,, vectm(1225.0, 3005.0, 495.0));
        }
        if (k != None) {
            k.Description = "Hotel key";
            k.KeyID = 'hotel_roomdoor';
        }

        break;
    case "11_PARIS_CATHEDRAL":
        AddBox(class'#var(prefix)CrateUnbreakableSmall', vectm(-3570.950684, 2238.034668, -783.901367));// right at the start

        //We don't need her to be unshuffled or special, but we want her name to be set
        foreach AllActors(class'#var(prefix)WIB',wib){
            wib.UnfamiliarName="Adept 34501";
            wib.FamiliarName="Adept 34501";
        }

        break;
    }
}
