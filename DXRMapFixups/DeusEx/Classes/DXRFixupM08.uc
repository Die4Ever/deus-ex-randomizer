class DXRFixupM08 extends DXRFixup;

function AnyEntryMapFixes()
{
    local StantonDowd s;
    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    Super.AnyEntryMapFixes();

    switch(dxr.localURL) {
    case "08_NYC_STREET":
        SetTimer(1.0, True);
        foreach AllActors(class'StantonDowd', s) {
            RemoveReactions(s);
        }
        Player().StartDataLinkTransmission("DL_Entry");
        RearrangeMJ12ConvergingInfolink();
        RearrangeJockExitDialog();
        break;

    case "08_NYC_SMUG":
        if (VanillaMaps){
            FixConversationGiveItem(GetConversation('M08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
        }

        if (dxr.flagbase.getBool('SmugglerDoorDone')) {
            dxr.flagbase.setBool('MetSmuggler', true,, -1);
        }
        break;
    }
}

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

function PreFirstEntryMapFixes()
{
    local DataLinkTrigger dlt;
    local #var(prefix)NanoKey k;
    local #var(prefix)PigeonGenerator pg;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
    local OnceOnlyTrigger oot;
    local #var(DeusExPrefix)Mover d;
    local DXRHoverHint hoverHint;
    local bool VanillaMaps;
    local ScriptedPawn pawn;
    local #var(prefix)LaserTrigger lt;
    local Teleporter tel;
    local DynamicTeleporter dtel;

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
        case "08_NYC_STREET":
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
                    break;
                }
            }
            //Since we always spawn the helicopter on the roof immediately after the conversation,
            //the ambush should also always happen immediately after the conversation (instead of
            //after getting explosives)
            foreach AllActors(class'DataLinkTrigger',dlt)
            {
                if (dlt.CheckFlag=='PlayerHasExplosives'){
                    dlt.CheckFlag='StantonDowd_Played';
                }
            }

            pg=Spawn(class'#var(prefix)PigeonGenerator',,, vectm(-2102,1942,-503));//In park
            pg.MaxCount=3;

            //Add teleporter hint text to Jock
            foreach AllActors(class'#var(prefix)MapExit',exit){break;}
            foreach AllActors(class'#var(prefix)BlackHelicopter',jock){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit);
            hoverHint.SetBaseActor(jock);

            if (#defined(vanilla)) {
                class'MoverToggleTrigger'.static.CreateMTT(self, 'DXRSmugglerElevatorUsed', 'elevatorbutton', 0, 1, 0.0, 9);
                foreach AllActors(class'Teleporter', tel) {
                    if (tel.URL == "08_NYC_Smug#ToSmugFrontDoor") {
                        dtel = class'DynamicTeleporter'.static.ReplaceTeleporter(tel);
                        dtel.SetDestination("08_NYC_Smug", 'PathNode83',, 16384);
                        break;
                    }
                }
            }

            break;
        case "08_NYC_HOTEL":
            if (VanillaMaps){
                Spawn(class'#var(prefix)Binoculars',,, vectm(-610.374573,-3221.998779,94.160065)); //Paul's bedside table

                if(!dxr.flags.IsZeroRando()) {
                    SpawnDatacubeTextTag(vectm(-840,-2920,85), rotm(0,0,0,0), '02_Datacube07',False); //Paul's stash code, in closet

                    k = Spawn(class'#var(prefix)NanoKey',,, vectm(-967,-1240,-74));
                    k.KeyID = 'CrackRoom';
                    k.Description = "'Ton Hotel, North Room Key";
                    if(dxr.flags.settings.keysrando > 0)
                        GlowUp(k);

                    k = Spawn(class'#var(prefix)NanoKey',,, vectm(-845,-2920,180));
                    k.KeyID = 'Apartment';
                    k.Description = "Apartment key";
                    if(dxr.flags.settings.keysrando > 0)
                        GlowUp(k);
                }

                Spawn(class'PlaceholderItem',,, vectm(-732,-2628,75)); //Actual closet
                Spawn(class'PlaceholderItem',,, vectm(-732,-2712,75)); //Actual closet
                Spawn(class'PlaceholderItem',,, vectm(-129,-3038,127)); //Bathroom counter
                Spawn(class'PlaceholderItem',,, vectm(15,-2972,123)); //Kitchen counter
                Spawn(class'PlaceholderItem',,, vectm(-853,-3148,75)); //Crack next to Paul's bed
            }
            break;
        case "08_NYC_BAR":
            npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(-1171.976440,250.575806,53.729687),rotm(0,0,0,0),'08_Newspaper01'); //Joe Greene article, table near where Harley is in Vanilla
            Spawn(class'BarDancer',,,vectm(-2150,-500,48),rotm(0,0,0,0));

            break;
        case "08_NYC_SMUG":
            foreach AllActors(class'#var(DeusExPrefix)Mover', d,'botordertrigger') {
                d.tag = 'botordertriggerDoor';
            }
            oot = Spawn(class'OnceOnlyTrigger');
            oot.Event='botordertriggerDoor';
            oot.Tag='botordertrigger';

            SetAllLampsState(false, true, true); // smuggler has one table lamp, upstairs where no one is
            class'MoverToggleTrigger'.static.CreateMTT(self, 'DXRSmugglerElevatorUsed', 'elevatorbutton', 1, 0, 0.0, 9);

            break;

        case "08_NYC_FREECLINIC":
            SetAllLampsState(true, true, false); // the free clinic has one desk lamp, at a desk no one is using
            break;
        case "08_NYC_UNDERGROUND":
            foreach AllActors(class'#var(prefix)LaserTrigger',lt){
                if (lt.Location.Z < -574 && lt.Location.Z > -575){
                    lt.SetLocation(lt.Location+vect(0,0,11)); //Move them slightly higher up to match their location in missions 2 and 4, so you can crouch under
                }
            }
    }
}
