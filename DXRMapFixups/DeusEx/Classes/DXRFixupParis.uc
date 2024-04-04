class DXRFixupParis extends DXRFixup;

function PreFirstEntryMapFixes()
{
    local GuntherHermann g;
    local DeusExMover m;
    local Trigger t;
    local Dispatcher d;
    local ScriptedPawn sp;
    local Conversation c;
    local #var(prefix)TobyAtanwe toby;
    local #var(prefix)JaimeReyes j;
    local #var(prefix)DamageTrigger dt;
    local #var(prefix)ComputerSecurity cs;
    local #var(prefix)AutoTurret at;
    local #var(prefix)WIB wib;
    local DXRMapVariants mapvariants;
    local DXRHoverHint hoverHint;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
    local #var(prefix)NanoKey k;
    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL)
    {
    case "10_PARIS_CATACOMBS":
        FixConversationAddNote(GetConversation('MeetAimee'), "Stupid, stupid, stupid password.");
        break;

    case "10_PARIS_CATACOMBS_TUNNELS":
        if (VanillaMaps){
            foreach AllActors(class'Trigger', t)
                if( t.Event == 'MJ12CommandoSpecial' )
                    t.Touch(player());// make this guy patrol instead of t-pose

            foreach AllActors(class'#var(prefix)WIB',wib){
                wib.UnfamiliarName="Agent Hela";
            }
            AddSwitch( vect(897.238892, -120.852928, -9.965580), rot(0,0,0), 'catacombs_blastdoor02' );
            AddSwitch( vect(-2190.893799, 1203.199097, -6.663990), rot(0,0,0), 'catacombs_blastdoorB' );

            foreach AllActors(class'ScriptedPawn',sp){
                if(sp.BindName=="bums"){
                    sp.bImportant=True;
                    sp.UnfamiliarName="Dr. Kit";
                    sp.FamiliarName="Dr. Mehdi Kit";
                    break;
                }
            }


            class'PlaceholderEnemy'.static.Create(self,vectm(-362,-3444,-32));
            class'PlaceholderEnemy'.static.Create(self,vectm(-743,677,-256));
            class'PlaceholderEnemy'.static.Create(self,vectm(-1573,-113,-64));
            class'PlaceholderEnemy'.static.Create(self,vectm(781,1156,-32));
        }
        break;

    case "10_PARIS_CHATEAU":
        if (VanillaMaps){
            foreach AllActors(class'DeusExMover', m, 'everettsignal')
                m.Tag = 'everettsignaldoor';
            d = Spawn(class'Dispatcher',, 'everettsignal', vectm(176.275253, 4298.747559, -148.500031) );
            d.OutEvents[0] = 'everettsignaldoor';
            AddSwitch( vect(-769.359985, -4417.855469, -96.485504), rot(0, 32768, 0), 'everettsignaldoor' );

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
        }
        break;
    case "10_PARIS_METRO":
        if (VanillaMaps){
            //If neither flag is set, JC never talked to Jaime, so he just didn't bother
            if (!dxr.flagbase.GetBool('JaimeRecruited') && !dxr.flagbase.GetBool('JaimeLeftBehind')){
                //Need to pretend he *was* recruited, so that he doesn't spawn
                dxr.flagbase.SetBool('JaimeRecruited',True);
            }
            // fix the night manager sometimes trying to talk to you while you're flying away https://www.youtube.com/watch?v=PeLbKPSHSOU&t=6332s
            c = GetConversation('MeetNightManager');
            if(c!=None) {
                c.bInvokeBump = false;
                c.bInvokeSight = false;
                c.bInvokeRadius = false;
            }
            foreach AllActors(class'#var(prefix)JaimeReyes', j) {
                RemoveFears(j);
            }

            // make the apartment stairs less hidden, not safe to have stairs without a light!
            CandleabraLight(vect(1825.758057, 1481.900024, 576.077698), rot(0, 16384, 0));
            CandleabraLight(vect(1162.240112, 1481.900024, 879.068848), rot(0, 16384, 0));

            //Add teleporter hint text to Jock
            foreach AllActors(class'#var(prefix)MapExit',exit,'ChopperExit'){break;}
            foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'BlackHelicopter'){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit);
            hoverHint.SetBaseActor(jock);

            if(dxr.flags.settings.goals > 0) {
                k = Spawn(class'#var(prefix)NanoKey',,, vectm(-1733,-2480,168));
                k.KeyID = 'apartment12';
                k.Description = "Key to Apartment #12";
                if(dxr.flags.settings.keysrando > 0)
                    GlowUp(k);

                foreach AllActors(class'DeusExMover', m){
                    if (m.Name=='DeusExMover10'){
                        m.KeyIDNeeded='apartment12';
                        break;
                    }
                }
            }
        }
        break;

    case "10_PARIS_CLUB":
        foreach AllActors(class'ScriptedPawn',sp){
            if (sp.BindName=="LDDPAchille" || sp.BindName=="Camille"){
                sp.bImportant=True;
            }
        }
        Spawn(class'PlaceholderItem',,, vectm(-607.8,-1003.2,59)); //Table near Nicolette Vanilla
        Spawn(class'PlaceholderItem',,, vectm(-239.927216,499.098633,43)); //Ledge near club owner
        Spawn(class'PlaceholderItem',,, vectm(-1164.5,1207.85,-133)); //Table near biocell guy
        Spawn(class'PlaceholderItem',,, vectm(-1046,-1393,-145)); //Bathroom counter 1
        Spawn(class'PlaceholderItem',,, vectm(-1545.5,-1016.7,-145)); //Bathroom counter 2
        Spawn(class'PlaceholderItem',,, vectm(-1464,-1649.6,-197)); //Bathroom stall 1
        Spawn(class'PlaceholderItem',,, vectm(-1096.7,-847,-197)); //Bathroom stall 2
        Spawn(class'PlaceholderItem',,, vectm(-2093.7,-293,-161)); //Club back room
        break;
    case "11_PARIS_UNDERGROUND":
        foreach AllActors(class'DXRMapVariants', mapvariants) { break; }
        foreach AllActors(class'#var(prefix)TobyAtanwe', toby) {
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, class'DXRMapInfo'.static.GetTeleporterName(mapvariants.VaryMap("11_PARIS_EVERETT"),"Entrance"), toby.Location, toby.CollisionRadius+5, toby.CollisionHeight+5);
            hoverHint.SetBaseActor(toby);
        }

        Spawn(class'PlaceholderItem',,, vectm(2268.5,-563.7,-101)); //Near ATM
        Spawn(class'PlaceholderItem',,, vectm(408.3,768.7,-37)); //Near Mechanic
        Spawn(class'PlaceholderItem',,, vectm(-729,809.5,-1061)); //Bench at subway
        Spawn(class'PlaceholderItem',,, vectm(-733,-251,-1061)); //Bench at subway
        Spawn(class'PlaceholderItem',,, vectm(300.7,491,-1061)); //Opposite side of tracks
        break;
    case "11_PARIS_CATHEDRAL":
        foreach AllActors(class'GuntherHermann', g) {
            g.ChangeAlly('mj12', 1, true);
        }
        foreach AllActors(class'#var(prefix)DamageTrigger',dt){
            //There should only be two damage triggers in the map,
            //but check the damage type anyway for safety
            //This will make the fireplaces actually set you on fire
            if(dt.DamageType=='Burned'){
                dt.DamageType='Flamed';
            }
        }
        //Restore default damage to this one turret.  The only one in the whole
        //game with non-standard damage (10 instead of 5).  It doesn't need it.
        foreach AllActors(class'#var(prefix)AutoTurret',at,'vault_turret'){
            at.gunDamage=class'#var(prefix)AutoTurret'.Default.gunDamage;
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

        //Add teleporter hint text to Jock
        foreach AllActors(class'#var(prefix)MapExit',exit,'CalledByDispatcher'){break;}
        foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'BlackHelicopter'){break;}
        hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit);
        hoverHint.SetBaseActor(jock);

        break;
    }
}

function AnyEntryMapFixes()
{
    local DXRNPCs npcs;
    local DXREnemies dxre;
    local ScriptedPawn sp;
    local Merchant m;
    local TobyAtanwe toby;
    local Conversation c;
    local ConEvent ce, cePrev;
    local ConEventSpeech ces;
    local ConEventSetFlag cesf;
    local ConEventAddSkillPoints ceasp;
    local ConEventTransferObject ceto;

    switch(dxr.localURL)
    {
    case "10_PARIS_CATACOMBS":
        if(dxr.flags.settings.swapitems > 0) {
            // spawn Le Merchant with a hazmat suit because there's no guarantee of one before the highly radioactive area
            // we need to do this in AnyEntry because we need to recreate the conversation objects since they're transient
            npcs = DXRNPCs(dxr.FindModule(class'DXRNPCs'));
            if(npcs != None) {
                sp = npcs.CreateForcedMerchant("Le Merchant", 'lemerchant', vectm(-3209.483154, 5190.826172,1199.610352), rotm(0, -10000, 0, 16384), class'#var(prefix)HazMatSuit');
                m = Merchant(sp);
                if (m!=None){  // CreateForcedMerchant returns None if he already existed, but we still need to call it to recreate the conversation since those are transient
                    m.MakeFrench();
                }
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
        break;
    case "10_PARIS_CATACOMBS_TUNNELS":
        SetTimer(1.0, True); //To update the Nicolette goal description
        break;
    case "10_PARIS_CLUB":
        FixConversationAddNote(GetConversation('MeetCassandra'),"with a keypad back where the offices are");
        break;
    case "10_PARIS_CHATEAU":
        FixConversationAddNote(GetConversation('NicoletteInStudy'),"I used to use that computer whenever I was at home");
        break;
    case "10_PARIS_METRO":
        //Tong gives you a map of the streets when you enter via the subway
        c = GetConversation('DL_military');
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

    switch(dxr.localURL) {
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
