class DXRFixupM01 extends DXRFixup;

//#region Post First Entry
function PostFirstEntryMapFixes()
{
    local DeusExMover m;
    local BlockPlayer bp;

    switch(dxr.localURL) {
    case "01_NYC_UNATCOISLAND":
        AddBox(class'#var(prefix)CrateUnbreakableSmall', vectm(6720.866211, -3346.700684, -445.899597));// electrical hut

        foreach AllActors(class'DeusExMover', m, 'UN_maindoor') {
            m.bBreakable = false;
            m.bPickable = false;
            m.bIsDoor = false;// this prevents Lloyd from opening the door
        }

        if(class'MenuChoice_BalanceMaps'.static.MajorEnabled()) {
            foreach AllActors(class'BlockPlayer', bp) {
                if(bp.Group == 'waterblock') {
                    bp.bBlockPlayers = false;
                }
            }
        }

        SetAllLampsState(,, false, vect(-5724.620605, 1435.543213, -79.614632), 0.01);
        SetAllLampsState(,, false, vect(3313.0954215, -1662.294768, -176.938141), 0.01);

        break;
    case "01_NYC_UNATCOHQ":
        FixUNATCORetinalScanner();
        PreventUNATCOZombieDanger();
        break;
    }
}
//#endregion


//#region Pre First Entry
function PreFirstEntryMapFixes()
{
    local #var(prefix)MapExit exit;
    local #var(prefix)NYPoliceBoat b;
    local #var(prefix)GuntherHermann gunther;
    local #var(prefix)HumanCivilian hc;
    local #var(prefix)OrdersTrigger ot;
    local #var(prefix)AllianceTrigger at;
    local #var(prefix)FlagTrigger ft;
    local #var(prefix)ComputerPublic compublic;
    local #var(prefix)WeaponShuriken tk;
    local bool VanillaMaps;
#ifdef injections
    local #var(prefix)Newspaper np;
    local class<#var(prefix)Newspaper> npClass;
    local DXRHoverHint hoverHint;
    npClass = class'#var(prefix)Newspaper';
#else
    local DXRInformationDevices np;
    local class<DXRInformationDevices> npClass;
    npClass = class'DXRInformationDevices';
#endif

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL) {
    //#region UNATCO Island
    case "01_NYC_UNATCOISLAND":
        FixHarleyFilben();

        //Move this Joe Greene article from inside HQ to outside on the island
        npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(7297,-3204.5,-373),rotm(0,0,0,0),'01_Newspaper06');//Forklift in bunker
        npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(3163,-1298,-207),rotm(0,0,0,0),'01_Newspaper06');//Backroom near jail

        foreach AllActors(class'#var(prefix)MapExit',exit){break;}
        foreach AllActors(class'#var(prefix)NYPoliceBoat',b) {
            class'DXRTeleporterHoverHint'.static.Create(self, "", b.Location, b.CollisionRadius+5, b.CollisionHeight+5, exit,, true);
            break;
        }

        class'GuntherWeaponMegaChoice'.static.Create(Player());
        foreach AllActors(class'#var(prefix)GuntherHermann',gunther){
            //Make sure he has ammo for Assault Rifle (7.62mm), Stealth Pistol(10mm), Pistol (10mm)
            GiveItem(gunther, class'Ammo762mm',300);
            GiveItem(gunther, class'Ammo10mm',150);
            break;
        }

        // Prevent Gunther from going to WaitingFor orders if you talk to him before going to his cell door
        // (aka if you spawn in his cell)
        foreach AllActors(class'#var(prefix)OrdersTrigger',ot){
            if (ot.Orders=='WaitingFor' && ot.Event=='GuntherHermann'){
                ot.SetCollision(False,False,False); //You no longer interact directly with the OrdersTrigger
                ot.Tag='GuntherWaitingOrders';

                //Instead you will interact with this FlagTrigger to conditionally hit the OrdersTrigger instead
                ft=Spawn(class'#var(prefix)FlagTrigger',,,ot.Location);
                ft.SetCollisionSize(ot.CollisionRadius,ot.CollisionHeight);
                ft.Event='GuntherWaitingOrders';
                ft.bSetFlag=False;
                ft.bTrigger=True;
                ft.FlagName='GuntherRescued_Played'; //Only trigger the orders if you have *not* talked to Gunther yet
                ft.flagValue=False;
            }
        }

        if (class'MenuChoice_BalanceMaps'.static.ModerateEnabled()){
            //Leo will no longer directly be ordered to attack the player, he will just go hostile and face them
            //This prevents him from breaking stealth
            foreach AllActors(class'#var(prefix)OrdersTrigger',ot,'TerroristCommanderAttacks'){
                class'FacePlayerTrigger'.static.Create(self,'TerroristCommanderAttacks','TerroristCommander',ot.Location);
                class'DrawWeaponTrigger'.static.Create(self,'TerroristCommanderAttacks','TerroristCommander',ot.Location,true);

                at = Spawn(class'#var(injectsprefix)AllianceTrigger',,'TerroristCommanderAttacks',ot.Location);
                at.SetCollision(False,False,False);
                at.Event='TerroristCommander';
                at.Alliance='Leader';
                at.Alliances[0].allianceName='Player';
                at.Alliances[0].allianceLevel=-1.0;
                at.Alliances[0].bPermanent=true;

                ot.Destroy();
                break;
            }
        }


        Spawn(class'PlaceholderItem',,, vectm(2378.5,-10810.9,-857)); //Sunken Ship
        Spawn(class'PlaceholderItem',,, vectm(2436,-10709.4,-857)); //Sunken Ship
        Spawn(class'PlaceholderContainer',,, vectm(1376,-9952.5,-271)); //Harley's house
        Spawn(class'PlaceholderItem',,, vectm(2702.5,-7721.7,-229)); //On boxes near Harley
        Spawn(class'PlaceholderItem',,, vectm(2373,-5003,-69)); //Boxes near ramp to Harley
        Spawn(class'PlaceholderItem',,, vectm(-2962.8,-1355,-53)); //Boxes near front of Statue
        Spawn(class'PlaceholderItem',,, vectm(-2838.7,1359.7,-53)); //Boxes near UNATCO HQ
        Spawn(class'PlaceholderItem',,, vectm(-4433.66,3103.38,-65)); //Concrete gate support at UNATCO HQ
        Spawn(class'PlaceholderItem',,, vectm(-4834.4,3667,-105)); //Bench in front of UNATCO
        Spawn(class'PlaceholderItem',,, vectm(-2991,5328.5,-131)); //Medbot crate near starting dock
        Spawn(class'PlaceholderItem',,, vectm(7670,737.7,-130)); //Medbot crate near Harley
        Spawn(class'PlaceholderItem',,, vectm(8981,26.9,-64)); //Boxes out front of bunker
        Spawn(class'PlaceholderItem',,, vectm(1750.75,275.7,-117.7)); //Near display of Statue torch
        Spawn(class'PlaceholderItem',,, vectm(5830.8,-344,539)); //Near statue head

        class'PlaceholderEnemy'.static.Create(self,vectm(-2374,543,-92), 17272, 'Standing');
        class'PlaceholderEnemy'.static.Create(self,vectm(-1211,198,-92), 25408, 'Standing');
        class'PlaceholderEnemy'.static.Create(self,vectm(-1843,5063,-96));
        class'PlaceholderEnemy'.static.Create(self,vectm(-3020,1878,-96));
        class'PlaceholderEnemy'.static.Create(self,vectm(86,3088,-96));
        class'PlaceholderEnemy'.static.Create(self,vectm(2879,4083,-96));
        class'PlaceholderEnemy'.static.Create(self,vectm(6500,4609,-92));
        class'PlaceholderEnemy'.static.Create(self,vectm(9398,2403,-92));
        class'PlaceholderEnemy'.static.Create(self,vectm(7705,-2019,79));
        class'PlaceholderEnemy'.static.Create(self,vectm(6618,-1526,320));
        class'PlaceholderEnemy'.static.Create(self,vectm(2842,-3539,-96));
        class'PlaceholderEnemy'.static.Create(self,vectm(-1713,-5775,-92));
        class'PlaceholderEnemy'.static.Create(self,vectm(1402,56,800));
        class'PlaceholderEnemy'.static.Create(self,vectm(2231,985,1088));
        class'PlaceholderEnemy'.static.Create(self,vectm(3777,-689,1088));
        class'PlaceholderEnemy'.static.Create(self,vectm(4111,3260,512));
        class'PlaceholderEnemy'.static.Create(self,vectm(-229,1438,512));
        class'PlaceholderEnemy'.static.Create(self,vectm(2766,317,2528), 0, 'Standing');
        break;
    //#endregion

    //#region UNATCO HQ
    case "01_NYC_UNATCOHQ":
        FixUNATCOCarterCloset();
        MakeTurretsNonHostile(); //Revision has hostile turrets near jail
        SpeedUpUNATCOFurnaceVent();

        foreach AllActors(#switch(injections: class'Newspaper', class'DXRInformationDevices'), np)
        {
            //Make both Joe Greene articles in HQ the same one
            if (np.textTag=='01_Newspaper06'){
                np.textTag='01_Newspaper08';
            }
        }

        //To change it so Manderley will brief you if you talked to Sam and Jaime (instead of actually getting equipment from Sam)
        SetTimer(1.0, True);

        if (VanillaMaps) {
            foreach AllActors(class'#var(prefix)ComputerPublic', compublic) {
                compublic.bCollideWorld = false;
                compublic.SetLocation(vectm(741.36, 1609.34, 298.0));
                compublic.SetRotation(rotm(0, -16384, 0, GetRotationOffset(class'#var(prefix)ComputerPublic')));
                compublic.TextPackage = "#var(package)";
                compublic.BulletinTag = '01_BulletinMenu';
                break;
            }
            class'FakeMirrorInfo'.static.Create(self,vectm(2430,1872,-80),vectm(2450,2060,-16)); //Mirror window at level 4 entrance
        } else {
            foreach AllActors(class'#var(prefix)WeaponShuriken',tk){
                tk.bIsSecretGoal=true; //Keep the throwing knives in Anna's mannequin
            }
            class'FakeMirrorInfo'.static.Create(self,vectm(2475,1872,-80),vectm(2450,2064,-16)); //Mirror window at level 4 entrance
        }

        //Spawn some placeholders for new item locations
        Spawn(class'PlaceholderItem',,, vectm(363.284149, 344.847, 50.32)); //Womens bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(211.227, 348.46, 50.32)); //Mens bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(982.255,1096.76,-7)); //Jaime's desk
        Spawn(class'PlaceholderItem',,, vectm(-307.8,-1122,-7)); //Anna's Desk
        Spawn(class'PlaceholderItem',,, vectm(-138.5,-790.1,-1.65)); //Anna's bookshelf
        if (VanillaMaps){
            Spawn(class'PlaceholderItem',,, vectm(-27,1651.5,291)); //Breakroom table
            Spawn(class'PlaceholderItem',,, vectm(602,1215.7,295)); //Kitchen Counter

            Spawn(class'PlaceholderItem',,, vectm(2033.8,1979.9,-85)); //Near MJ12 Door
            Spawn(class'PlaceholderItem',,, vectm(2148,2249,-85)); //Near MJ12 Door
            Spawn(class'PlaceholderItem',,, vectm(2433,1384,-85)); //Near MJ12 Door
            Spawn(class'PlaceholderContainer',,, vectm(2384,1669,-95)); //MJ12 Door
        } else {
            //Revision Kitchen/Breakroom is in a different location
            Spawn(class'PlaceholderItem',,, vectm(295,1385,485)); //Breakroom table
            Spawn(class'PlaceholderItem',,, vectm(765,1500,440)); //Kitchen Counter

            //Level 4/MJ12 Lab area is blocked off in Revision, these are alternate locations for those placeholders
            Spawn(class'PlaceholderItem',,, vectm(110,-1050,-20)); //Desk at entrance to jail area
            Spawn(class'PlaceholderItem',,, vectm(1280,-180,-55)); //Next to couch/plant outside medical
            Spawn(class'PlaceholderItem',,, vectm(1335,300,-35)); //Under desk near medical beds
            Spawn(class'PlaceholderContainer',,, vectm(1490,975,-20)); //Near blocked door down to level 4

        }
        Spawn(class'PlaceholderItem',,, vectm(-672.8,1261,473)); //Upper Left Office desk
        Spawn(class'PlaceholderContainer',,, vectm(-1187,-1154,-31)); //Behind Jail Desk
        Spawn(class'PlaceholderContainer',,, vectm(-383.6,1376,273)); //JC's Office

        break;
        //#endregion
    }
}
//#endregion

//#region Timer
function TimerMapFixes()
{
    switch(dxr.localURL)
    {
    case "01_NYC_UNATCOHQ":
        if (!dxr.flagbase.GetBool('M01ReadyForBriefing') && dxr.flagbase.GetBool('MeetCarter_Played') && dxr.flagbase.GetBool('MeetJaime_Played')){
            dxr.flagbase.SetBool('M01ReadyForBriefing',True,,999);
            SetTimer(0,false);
        }
        break;
    }
}
//#endregion

//#region Any Entry
function AnyEntryMapFixes()
{
    local Conversation c;
    local ConEvent ce,before,after;
    local ConEventSpeech ces;
    local name conName;
    local string afterTextLine;

    // if you can talk to gunther then obviously he's been rescued
    DeleteConversationFlag(GetConversation('GuntherRescued'), 'GuntherFreed', true);

    // you can't take a corpse alive and conscious
    GetConversation('DL_Top').AddFlagRef('TerroristCommander_Dead', false);
    // "the NSF have set up patchwork security systems here"
    GetConversation('DL_FrontEntrance').AddFlagRef('StatueMissionComplete', false);
    // "you might be able to avoid some of the security by entering this way"
    GetConversation('DL_BackEntrance').AddFlagRef('StatueMissionComplete', false);
    // NSF everywhere, JC.  Your orders are to shoot on sight.
    GetConversation('DL_LeaveDockNoGun').AddFlagRef('StatueMissionComplete', false);

    //Cut out the dialog for Paul giving you equipment
    if(dxr.flags.IsReducedRando()) return; // but not in reduced rando

    c = GetConversation('MeetPaul');
    ce = c.eventList;

    SetSeed("MeetPaul");
    if (rngb()){
        afterTextLine="I get the idea.  What's the first move?";
    } else {
        afterTextLine="Great.  What's the first move?";
    }

    while (ce!=None){
        if (ce.eventType==ET_Speech){
            ces = ConEventSpeech(ce);
            if (InStr(ces.conSpeech.speech,"NSF took one of our agents hostage")!=-1){
                before = ce;
            }
            if (InStr(ces.conSpeech.speech,afterTextLine)!=-1){
                after = ce;
            }
            if (before!=None && after!=None){
                break;
            }
        }
        ce = ce.nextEvent;
    }

    //Just in case something went wrong
    if (before!=None && after!=None){
        before.nextEvent = after;
    }
}
//#endregion
