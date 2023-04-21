class DXRFixupVandenberg extends DXRFixup;

function PreFirstEntryMapFixes()
{
    local ElevatorMover e;
    local Button1 b;
    local ComputerSecurity comp;
    local KarkianBaby kb;
    local DataLinkTrigger dlt;
    local FlagTrigger ft;
    local HowardStrong hs;
    local #var(Mover) door;
    local DXREnemies dxre;

    switch(dxr.localURL)
    {
    case "12_VANDENBERG_CMD":
        // add goals and keypad code
        Player().StartDataLinkTransmission("DL_no_carla");
        break;

#ifdef vanillamaps
    case "12_VANDENBERG_TUNNELS":
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
        break;

    case "14_VANDENBERG_SUB":
        AddSwitch( vect(3790.639893, -488.639587, -369.964142), rot(0, 32768, 0), 'Elevator1');
        AddSwitch( vect(3799.953613, -446.640015, -1689.817993), rot(0, 16384, 0), 'Elevator1');

        foreach AllActors(class'KarkianBaby',kb) {
            if(kb.BindName == "tankkarkian"){
                kb.BindName = "TankKharkian";
            }
        }
        break;

    case "14_OCEANLAB_LAB":
        if(!#defined(vmd))// button to open the door heading towards the ladder in the water
            AddSwitch( vect(3077.360107, 497.609467, -1738.858521), rot(0, 0, 0), 'Access');
        foreach AllActors(class'ComputerSecurity', comp) {
            if( comp.UserList[0].userName == "Kraken" && comp.UserList[0].Password == "Oceanguard" ) {
                comp.UserList[0].userName = "Oceanguard";
                comp.UserList[0].Password = "Kraken";
            }
        }
        break;
    case "14_OCEANLAB_UC":
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
        foreach AllActors(class'#var(Mover)', door, 'Releasebots') {
            door.MoverEncroachType=ME_IgnoreWhenEncroach;
        }
        break;

    case "14_Oceanlab_silo":
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
        break;
#endif
    }
}

function PostFirstEntryMapFixes()
{
    local #var(prefix)CrateUnbreakableLarge c;
    local Actor a;

    switch(dxr.localURL) {
#ifndef revision
    case "12_VANDENBERG_CMD":
        foreach RadiusActors(class'#var(prefix)CrateUnbreakableLarge', c, 16, vect(570.835083, 1934.114014, -1646.114746)) {
            info("removing " $ c $ " dist: " $ VSize(c.Location - vect(570.835083, 1934.114014, -1646.114746)) );
            c.Destroy();
        }
        break;

    case "14_OCEANLAB_LAB":
        // ensure rebreather before greasel lab, in case the storage closet key is in the flooded area
        a = _AddActor(Self, class'#var(prefix)Rebreather', vect(1569, 24, -1628), rot(0,0,0));
        a.SetPhysics(PHYS_None);
        l("PostFirstEntryMapFixes spawned "$ActorToString(a));
        break;
#endif
    }
}

function AnyEntryMapFixes()
{
    local MIB mib;
    local NanoKey key;
    local #var(prefix)HowardStrong hs;

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
    }
}
