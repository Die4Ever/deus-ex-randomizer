class DXRFixupVandenberg extends DXRFixup;

var bool M14GaryNotDone;
var bool M12GaryHostageBriefing;

function PreFirstEntryMapFixes()
{
    local ElevatorMover e;
    local Button1 b;
    local ComputerSecurity comp;
    local KarkianBaby kb;
    local DataLinkTrigger dlt;
    local FlagTrigger ft;
    local HowardStrong hs;
    local #var(DeusExPrefix)Mover door;
    local DXREnemies dxre;
    local #var(prefix)TracerTong tt;
    local SequenceTrigger st;
    local #var(prefix)ShopLight sl;
    local #var(prefix)RatGenerator rg;
    local #var(prefix)OrdersTrigger ot;
    local #var(prefix)NanoKey key;
    local #var(prefix)DamageTrigger dt;
    local #var(prefix)BeamTrigger bt;
    local OnceOnlyTrigger oot;
    local Actor a;
    local #var(prefix)PigeonGenerator pg;
    local #var(prefix)FishGenerator fg;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
    local DXRHoverHint hoverHint;
    local SecurityBot2 sb;
    local MilitaryBot mb;
    local int botNum;

    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL)
    {
    case "12_VANDENBERG_CMD":
        // add goals and keypad code

        foreach AllActors(class'#var(prefix)TracerTong', tt) {
            RemoveFears(tt);// he looks pretty sick
        }

        class'PlaceholderEnemy'.static.Create(self,vectm(-2467,866,-2000));
        class'PlaceholderEnemy'.static.Create(self,vectm(-2689,4765,-2143));
        class'PlaceholderEnemy'.static.Create(self,vectm(-163,7797,-2143));
        class'PlaceholderEnemy'.static.Create(self,vectm(2512,6140,-2162));
        class'PlaceholderEnemy'.static.Create(self,vectm(2267,643,-2000));

        sl = #var(prefix)ShopLight(AddActor(class'#var(prefix)ShopLight', vect(1.125000, 938.399963, -1025), rot(0, 16384, 0)));
        sl.bInvincible = true;
        sl.bCanBeBase = true;

        rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(-1975,227,-2191));//Near generator
        rg.MaxCount=1;
        rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(6578,8227,-3101));//Near guardhouse
        rg.MaxCount=1;

        //Clear out items in inaccessible containers far below the earth
        foreach RadiusActors(class'Actor', a, 250, vectm(-4350,3000,-5850)) {
            a.Destroy();
        }

        foreach AllActors(class'#var(prefix)DamageTrigger',dt){
            if (dt.DamageType=='Shocked'){
                dt.Tag='lab_water';
            }
        }

        pg=Spawn(class'#var(prefix)PigeonGenerator',,, vectm(2065,2785,-871));//CMD Rooftop
        pg.MaxCount=3;

        if (VanillaMaps){
            //Add a key to Tim's closet
            foreach AllActors(class'#var(DeusExPrefix)Mover',door){
                if (door.Name=='DeusExMover28'){
                    door.KeyIDNeeded='TimsClosetKey';
                }
            }

            key = Spawn(class'#var(prefix)NanoKey',,,vectm(-1502.665771,2130.560791,-1996.783691)); //Windowsill in Hazard Lab
            key.KeyID='TimsClosetKey';
            key.Description="Tim's Closet Key";
            key.SkinColor=SC_Level3;
            key.MultiSkins[0] = Texture'NanoKeyTex3';

            foreach AllActors(class'#var(DeusExPrefix)Mover',door){
                if(door.name=='DeusExMover15'){
                    door.Tag='CmdBackDoor';
                }
            }
            AddSwitch( vect(-278.854828,657.390503,-1977.144531), rot(0, 16384, 0), 'CmdBackDoor');

            //Add teleporter hint text to Jock
            foreach AllActors(class'#var(prefix)MapExit',exit,'mission_done'){break;}
            foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'Helicopter'){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit.Name);
            hoverHint.SetBaseActor(jock);
        }

        foreach AllActors(class'#var(prefix)SecurityBot2',sb,'enemy_bot') {
            hoverHint = class'DXRHoverHint'.static.Create(self, "MJ12 Security Bot " $ ++botNum, sb.Location, sb.CollisionRadius*1.11, sb.CollisionHeight*1.11, sb.Name);
            hoverHint.SetBaseActor(sb);
            hoverHint.VisibleDistance = 15000;
        }
        botNum = 0;
        foreach AllActors(class'#var(prefix)MilitaryBot',mb,'enemy_bot') {
            hoverHint = class'DXRHoverHint'.static.Create(self, "MJ12 Military Bot " $ ++botNum, mb.Location, mb.CollisionRadius*1.1, mb.CollisionHeight*1.1, mb.Name);
            hoverHint.SetBaseActor(mb);
            hoverHint.VisibleDistance = 15000;
        }

        break;

    case "12_VANDENBERG_TUNNELS":
        if (VanillaMaps){
            foreach AllActors(class'ElevatorMover', e, 'Security_door3') {
                e.BumpType = BT_PlayerBump;
                e.BumpEvent = 'SC_Door3_opened';
            }
            AddSwitch( vect(-396.634888, 2295, -2542.310547), rot(0, -16384, 0), 'SC_Door3_opened').bCollideWorld = false;
            foreach AllActors(class'Button1', b) {
                if( b.Event == 'Top' || b.Event == 'middle' || b.Event == 'Bottom' ) {
                    AddDelay(b, 5);
                }
            }
        }
        break;

    case "14_VANDENBERG_SUB":
        if (VanillaMaps){
            //Elevator down to lower level
            AddSwitch( vect(3790.639893, -488.639587, -369.964142), rot(0, 32768, 0), 'Elevator1');
            AddSwitch( vect(3799.953613, -446.640015, -1689.817993), rot(0, 16384, 0), 'Elevator1');

            //Door into base from shore (inside)
            AddSwitch( vect(2279.640137,3638.638184,-398.255676), rot(0, -16384, 0), 'door_base');

            foreach AllActors(class'KarkianBaby',kb) {
                if(kb.BindName == "tankkarkian"){
                    kb.BindName = "TankKharkian";
                }
            }
            rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(737,4193,-426));//In shoreside shed
            rg.MaxCount=1;

            Spawn(class'PlaceholderItem',,, vectm(755,4183,-421)); //Shed
            Spawn(class'PlaceholderItem',,, vectm(755,4101,-421)); //Shed
            Spawn(class'PlaceholderItem',,, vectm(462,4042,-421)); //Shed
            Spawn(class'PlaceholderItem',,, vectm(462,3986,-421)); //Shed
            Spawn(class'PlaceholderItem',,, vectm(462,3939,-421)); //Shed

            foreach AllActors(class'#var(DeusExPrefix)Mover',door){
                if(door.KeyIDNeeded=='shed'){
                    door.Tag='ShedDoor';
                }
                if (door.Tag=='Elevator1'){
                    door.MoverEncroachType=ME_CrushWhenEncroach;
                }
                if(door.Tag=='sub_doors'){
                    door.bLocked = true;
                    door.bHighlight = true;
                    door.bFrobbable = true;
                    door.bPickable = false;// make sure DXRDoors sees this as an undefeatable door, also in vanilla this door is obviously not pickable due to not being frobbable
                }
            }
            AddSwitch( vect(654.545,3889.5397,-367.262), rot(0, 16384, 0), 'ShedDoor');

            fg=Spawn(class'#var(prefix)FishGenerator',,, vectm(5657,-1847,-1377));//Near tunnel to sub bay
            fg.ActiveArea=20000; //Long line of sight on this one...  Want it to trigger early

            //Add teleporter hint text to Jock
            foreach AllActors(class'#var(prefix)MapExit',exit,'ChopperExit'){break;}
            foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'BlackHelicopter'){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit.Name);
            hoverHint.SetBaseActor(jock);
        }
        break;

    case "14_OCEANLAB_LAB":
        if (VanillaMaps){
            if(!#defined(vmd))// button to open the door heading towards the ladder in the water
                AddSwitch( vect(3077.360107, 497.609467, -1738.858521), rot(0, 0, 0), 'Access');

            foreach AllActors(class'#var(DeusExPrefix)Mover',door){
                if(door.KeyIDNeeded=='crewkey'){
                    door.Tag = 'crewkey';
                }
                if(door.KeyIDNeeded=='Glab'){
                    door.Tag = 'Glab';
                }
            }
            // backtracking button for crew module
            AddSwitch( vect(4888.692871, 3537.360107, -1753.115845), rot(0, 16384, 0), 'crewkey').bCollideWorld = false;
            // backtracking button for greasel lab
            AddSwitch( vect(1893.359985, 491.932892, -1535.522339), rot(0, 0, 0), 'Glab');

            foreach AllActors(class'ComputerSecurity', comp) {
                if( comp.UserList[0].userName == "Kraken" && comp.UserList[0].Password == "Oceanguard" ) {
                    comp.UserList[0].userName = "Oceanguard";
                    comp.UserList[0].Password = "Kraken";
                }
            }

            Spawn(class'PlaceholderItem',,, vectm(37.5,531.4,-1569)); //Secretary desk
            Spawn(class'PlaceholderItem',,, vectm(2722,226.5,-1481)); //Greasel Lab desk
            Spawn(class'PlaceholderItem',,, vectm(4097.8,395.4,-1533)); //Desk with zappy electricity near construction zone
            Spawn(class'PlaceholderItem',,, vectm(4636.1,1579.3,-1741)); //Electrical box in construction zone
            Spawn(class'PlaceholderItem',,, vectm(5359.5,3122.3,-1761)); //Construction vehicle tread
            Spawn(class'PlaceholderItem',,, vectm(3114.3,3711.2,-2549)); //Storage room in crew capsule

            Spawn(class'PlaceholderContainer',,, vectm(-71,775,-1599)); //Secretary desk corner
            Spawn(class'PlaceholderContainer',,, vectm(1740,156,-1599)); //Open storage room
            Spawn(class'PlaceholderContainer',,, vectm(2999,482,-1503)); //Greasel lab
            Spawn(class'PlaceholderContainer',,, vectm(1780,3725,-2483)); //Crew module bed
            Spawn(class'PlaceholderContainer',,, vectm(1733,3848,-4223)); //Corner in hall to UC
        }
        break;
    case "14_OCEANLAB_UC":
        if (VanillaMaps){
            //Make the datalink immediately trigger when you download the schematics, regardless of where the computer is
            foreach AllActors(class'FlagTrigger',ft){
                if (ft.name=='FlagTrigger0'){
                    ft.bTrigger = True;
                    ft.event = 'schematic2';
                }
            }
            foreach AllActors(class'DataLinkTrigger',dlt){
                if (dlt.name=='DataLinkTrigger2'){
                    dlt.Tag = 'schematic2';
                }
            }

            //This door can get stuck if a spiderbot gets jammed into the little bot-bay
            foreach AllActors(class'#var(DeusExPrefix)Mover', door, 'Releasebots') {
                door.MoverEncroachType=ME_IgnoreWhenEncroach;
            }

            foreach AllActors(class'#var(prefix)BeamTrigger',bt,'Lasertrip'){
                bt.Event='ReleasebotsOnce';
            }

            oot=Spawn(class'OnceOnlyTrigger');
            oot.Event='Releasebots';
            oot.Tag='ReleasebotsOnce';

            Spawn(class'PlaceholderItem',,, vectm(1020.93,8203.4,-2864)); //Over security computer
            Spawn(class'PlaceholderItem',,, vectm(348.9,8484.63,-2913)); //Turret room
            Spawn(class'PlaceholderItem',,, vectm(1280.84,8534.17,-2913)); //Turret room
            Spawn(class'PlaceholderItem',,, vectm(1892,8754.5,-2901)); //Turret room, opposite from bait computer
        }
        break;

    case "14_Oceanlab_silo":
        if (VanillaMaps){
            if(!dxr.flags.IsReducedRando()) {
                foreach AllActors(class'HowardStrong', hs) {
                    hs.ChangeAlly('', 1, true);
                    hs.ChangeAlly('mj12', 1, true);
                    hs.ChangeAlly('spider', 1, true);
                    RemoveFears(hs);
                    hs.MinHealth = 0;
                    hs.BaseAccuracy *= 0.1;

                    GiveItem(hs, class'#var(prefix)BallisticArmor');
                    dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
                    if(dxre != None) {
                        dxre.GiveRandomWeapon(hs, false, 2);
                        dxre.GiveRandomMeleeWeapon(hs);
                    }
                    hs.FamiliarName = "Howard Stronger";
                    hs.UnfamiliarName = "Howard Stronger";

                    if(!#defined(vmd)) {// vmd allows AI to equip armor, so maybe he doesn't need the health boost?
                        SetPawnHealth(hs, 200);
                    }
                }
            }

            //The door closing behind you when the ambush starts sucks if you came in via the silo.
            //Just make it not close.
            foreach AllActors(class'SequenceTrigger', st, 'doorclose') {
                if (st.Event=='blast_door4' && st.Tag=='doorclose'){
                    st.Event = '';
                    st.Tag = 'doorclosejk';
                    break;
                }
            }

            //Add teleporter hint text to Jock
            foreach AllActors(class'#var(prefix)MapExit',exit,'ExitPath'){break;}
            foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'BlackHelicopter'){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit.Name);
            hoverHint.SetBaseActor(jock);


            class'PlaceholderEnemy'.static.Create(self,vectm(-264,-6991,-553));
            class'PlaceholderEnemy'.static.Create(self,vectm(-312,-6886,327));
            class'PlaceholderEnemy'.static.Create(self,vectm(270,-6601,1500));
            class'PlaceholderEnemy'.static.Create(self,vectm(-1257,-3472,1468));
            class'PlaceholderEnemy'.static.Create(self,vectm(1021,-3323,1476));
        }
        break;
    case "12_VANDENBERG_COMPUTER":
        if (VanillaMaps){
            foreach AllActors(class'#var(prefix)OrdersTrigger',ot,'GaryWalksToPosition'){
                ot.Orders='RunningTo';
                ot.ordersTag='gary_patrol1';
            }

            //Show the strength of the fan grill
            foreach AllActors(class'#var(DeusExPrefix)Mover',door,'BreakableWall'){
                door.bHighlight = true;
                door.bLocked=true;
                door.bPickable=false;
            }

            Spawn(class'PlaceholderItem',,, vectm(579,2884,-1629)); //Table near entrance
            Spawn(class'PlaceholderItem',,, vectm(1057,2685.25,-1637)); //Table overlooking computer room
            Spawn(class'PlaceholderItem',,, vectm(1970,2883.43,-1941)); //In first floor computer room
        }
        break;

    case "12_VANDENBERG_GAS":
        if (VanillaMaps){
            class'PlaceholderEnemy'.static.Create(self,vectm(635,488,-930));
            rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(1000,745,-972));//Gas Station back room
            rg.MaxCount=1;
            rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(-2375,-644,-993));//Under trailer near Jock
            rg.MaxCount=1;

            //Add teleporter hint text to Jock
            foreach AllActors(class'#var(prefix)MapExit',exit,'UN_BlackHeli'){break;}
            foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'Heli'){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit.Name);
            hoverHint.SetBaseActor(jock);


            Spawn(class'PlaceholderItem',,, vectm(-366,-2276,-1553)); //Under collapsed bridge
            Spawn(class'PlaceholderItem',,, vectm(-394,-1645,-1565)); //Near bridge pillar
            Spawn(class'PlaceholderItem',,, vectm(-88,-2087,-1553)); //Collapsed bridge road surface
            Spawn(class'PlaceholderItem',,, vectm(909,-2474,-1551)); //Wrecked car
            Spawn(class'PlaceholderItem',,, vectm(-3152,-2780,-1364)); //Ledge near original key
        }
        break;
    }
}

function PostFirstEntryMapFixes()
{
    local #var(prefix)CrateUnbreakableLarge c;
    local Actor a;
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    switch(dxr.localURL) {
    case "12_VANDENBERG_CMD":
        if(!RevisionMaps){
            foreach RadiusActors(class'#var(prefix)CrateUnbreakableLarge', c, 16, vectm(570.835083, 1934.114014, -1646.114746)) {
                info("removing " $ c $ " dist: " $ VSize(c.Location - vectm(570.835083, 1934.114014, -1646.114746)) );
                c.Destroy();
            }
        }
        break;
    case "14_OCEANLAB_LAB":
        // ensure rebreather before greasel lab, in case the storage closet key is in the flooded area
        a = AddActor(class'#var(prefix)Rebreather', vect(1569, 24, -1628));
        a.SetPhysics(PHYS_None);
        l("PostFirstEntryMapFixes spawned "$ActorToString(a));
        break;
    }
}

function AnyEntryMapFixes()
{
    local MIB mib;
    local NanoKey key;
    local #var(prefix)HowardStrong hs;

    if(dxr.flagbase.GetBool('schematic_downloaded') && !dxr.flagbase.GetBool('DL_downloaded_Played')) {
        dxr.flagbase.SetBool('DL_downloaded_Played', true);
    }

    switch(dxr.localURL)
    {
    case "12_Vandenberg_gas":
        foreach AllActors(class'MIB', mib, 'mib_garage') {
            key = NanoKey(mib.FindInventoryType(class'NanoKey'));
            l(mib$" has key "$key$", "$key.KeyID$", "$key.Description);
            if(key == None) continue;
            if(key.KeyID != '') continue;
            l("fixing "$key$" to garage_entrance");
            key.KeyID = 'garage_entrance';
            key.Description = "Garage Door";
            key.Timer();// make sure to fix the ItemName in vanilla
        }
        break;

    case "14_VANDENBERG_SUB":
        FixSavageSkillPointsDupe();
        break;

    case "14_OCEANLAB_SILO":
        foreach AllActors(class'#var(prefix)HowardStrong', hs) {
            hs.ChangeAlly('', 1, true);
            hs.ChangeAlly('mj12', 1, true);
            hs.ChangeAlly('spider', 1, true);
            RemoveFears(hs);
            hs.MinHealth = 0;
        }
        Player().StartDataLinkTransmission("DL_FrontGate");
        break;
    case "12_VANDENBERG_COMPUTER":
        SetTimer(1, true);
        break;
    case "12_VANDENBERG_CMD":
        Player().StartDataLinkTransmission("DL_no_carla");
        break;
    }
}

function FixSavageSkillPointsDupe()
{
    local Conversation c;
    local ConEventAddSkillPoints sk;
    local ConEvent e, prev, next;

    c = GetConversation('GaryWaitingForSchematics');
    if(c==None) return;
    for(e = c.eventList; e != None; e=next) {
        next = e.nextEvent;// keep this when we delete e
        sk = ConEventAddSkillPoints(e);
        if(sk != None) {
            FixConversationDeleteEvent(sk, prev);
        }
        else {
            prev = e;
        }
    }

    if(!dxr.flagbase.GetBool('M14GaryDone')) {
        M14GaryNotDone = true;
        SetTimer(1, true);
    }
}

function TimerMapFixes()
{
    local #var(prefix)GarySavage gary;
    switch(dxr.localURL)
    {
    case "14_VANDENBERG_SUB":
        if(M14GaryNotDone && dxr.flagbase.GetBool('M14GaryDone')) {
            M14GaryNotDone = false;
            player().SkillPointsAdd(500);
        }
        break;
    case "12_VANDENBERG_COMPUTER":
        //Immediately start the conversation with Gary after the message from Page
        if (!M12GaryHostageBriefing && dxr.flagbase.GetBool('PageHostageBriefing_played') && !dxr.flagbase.GetBool('GaryHostageBriefing_played')){
            if (player().conPlay==None){
                foreach AllActors(class'#var(prefix)GarySavage',gary){ break;}
                if (dxr.FlagBase.GetBool('LDDPJCIsFemale')){
                    M12GaryHostageBriefing = (player().StartConversationByName('FemJCGaryHostageBriefing',gary));
                } else {
                    M12GaryHostageBriefing = (player().StartConversationByName('GaryHostageBriefing',gary));
                }
            }
        }
        break;
    }
}
