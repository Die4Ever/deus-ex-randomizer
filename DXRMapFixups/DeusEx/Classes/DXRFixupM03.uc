class DXRFixupM03 extends DXRFixup;

function PostFirstEntryMapFixes()
{
    local Actor a;

    FixUNATCORetinalScanner();

    switch(dxr.localURL) {
#ifndef revision
    case "03_NYC_BrooklynBridgeStation":
        a = _AddActor(Self, class'Barrel1', vect(-27.953907, -3493.229980, 45.101418), rot(0,0,0));
        Barrel1(a).SkinColor = SC_Explosive;
        a.BeginPlay();
        break;

    case "03_NYC_AirfieldHeliBase":
        //crates to get back over the beginning of the level
        _AddActor(Self, class'#var(prefix)CrateUnbreakableSmall', vect(-9463.387695, 3377.530029, 60), rot(0,0,0));
        _AddActor(Self, class'#var(prefix)CrateUnbreakableMed', vect(-9461.959961, 3320.718750, 75), rot(0,0,0));
        break;
#endif
    }
}

function TimerMapFixes()
{
    switch(dxr.localURL)
    {
    case "03_NYC_747":
        FixAnnaAmbush();
        break;
    }
}

function PreFirstEntryMapFixes()
{
    local Mover m;
    local Actor a;
    local Trigger t;
    local Teleporter tele;
    local NanoKey k;
    local #var(prefix)InformationDevices i;
    local #var(prefix)UNATCOTroop unatco;

    switch (dxr.localURL)
    {
    case "03_NYC_BATTERYPARK":
        foreach AllActors(class'NanoKey', k) {
            // unnamed key normally unreachable
            if( k.KeyID == '' || k.KeyID == 'KioskDoors' ) {
                k.Destroy();
            }
        }
        foreach AllActors(class'#var(prefix)InformationDevices', i) {
            if( i.textTag == '03_Book06' ) {
                i.bAddToVault = true;
            }
        }

        //rebreather because of #TOOCEAN connection
        _AddActor(Self, class'Rebreather', vect(-936.151245, -3464.031006, 293.710968), rot(0,0,0));

        //Add some junk around the park so that there are some item locations outside of the shanty town
        _AddActor(Self, class'Liquor40oz', vect(933.56,-3554.86,279.04), rot(0,0,0));
        _AddActor(Self, class'Sodacan', vect(2203.28,-3558.84,279.04), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(-980.83,-3368.42,286.24), rot(0,0,0));
        _AddActor(Self, class'Cigarettes', vect(-682.67,-3771.20,282.24), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(-2165.67,-3546.039,285.30), rot(0,0,0));
        _AddActor(Self, class'Sodacan', vect(-2170.83,-3094.94,330.24), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(-3180.75,-3546.79,281.43), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(-2619.56,-2540.80,330.25), rot(0,0,0));
        _AddActor(Self, class'Cigarettes', vect(-3289.43,-919.07,360.80), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(-2799.94,-922.68,361.86), rot(0,0,0));
        _AddActor(Self, class'Sodacan', vect(800.76,1247.99,330.25), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(1352.29,2432.98,361.58), rot(0,0,0));
        _AddActor(Self, class'Cigarettes', vect(788.50,2359.26,360.63), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(3153.26,-310.73,326.25), rot(0,0,0));
        _AddActor(Self, class'Sodacan', vect(-2132.21,1838.89,326.25), rot(0,0,0));

        break;

#ifdef vanillamaps
    case "03_NYC_AirfieldHeliBase":
        foreach AllActors(class'Mover',m) {
            // call the elevator at the end of the level when you open the appropriate door
            if (m.Tag == 'BasementDoorOpen')
            {
                m.Event = 'BasementFloor';
            }
            else if (m.Tag == 'GroundDoorOpen')
            {
                m.Event = 'GroundLevel';
            }
            // sewer door backtracking so we can make a switch for this
            else if ( DeusExMover(m) != None && DeusExMover(m).KeyIDNeeded == 'Sewerdoor')
            {
                m.Tag = 'Sewerdoor';
            }
        }
        foreach AllActors(class'Trigger', t) {
            //disable the platforms that fall when you step on them
            if( t.Name == 'Trigger0' || t.Name == 'Trigger1' ) {
                t.Event = '';
            }
        }
        foreach AllActors(class'#var(prefix)UNATCOTroop', unatco) {
            unatco.bHateCarcass = false;
            unatco.bHateDistress = false;
        }

        // Sewerdoor backtracking
        AddSwitch( vect(-6878.640137, 3623.358398, 150.903931), rot(0,0,0), 'Sewerdoor');

        //stepping stone valves out of the water, I could make the collision radius a little wider even if it isn't realistic?
        _AddActor(Self, class'Valve', vect(-3105,-385,-210), rot(0,0,16384));
        a = _AddActor(Self, class'DynamicBlockPlayer', vect(-3105,-385,-210), rot(0,0,0));
        SetActorScale(a, 1.3);

        _AddActor(Self, class'Valve', vect(-3080,-395,-170), rot(0,0,16384));
        a = _AddActor(Self, class'DynamicBlockPlayer', vect(-3080,-395,-170), rot(0,0,0));
        SetActorScale(a, 1.3);

        _AddActor(Self, class'Valve', vect(-3065,-405,-130), rot(0,0,16384));
        a = _AddActor(Self, class'DynamicBlockPlayer', vect(-3065,-405,-130), rot(0,0,0));
        SetActorScale(a, 1.3);

        //rebreather because of #TOOCEAN connection
        Spawn(class'Rebreather',,, vect(1411.798950, 546.628845, 247.708572));
        break;
#endif

    case "03_NYC_AIRFIELD":
        //rebreather because of #TOOCEAN connection
        Spawn(class'Rebreather',,, vect(-2031.959473, 995.781067, 75.709816));
        // extra spot for datacube
        Spawn(class'PlaceholderItem',,, vect(5113, 3615, 1.3));
        if(#defined(vanillamaps)) {
            foreach AllActors(class'Teleporter', tele) {
                if(tele.Event == 'HangarEnt') {
                    tele.SetCollisionSize(tele.CollisionRadius, tele.CollisionHeight + 10);
                }
            }
        }
        break;

#ifdef vanillamaps
    case "03_NYC_BROOKLYNBRIDGESTATION":
        //Put a button behind the hidden bathroom door
        //Mostly for entrance rando, but just in case
        AddSwitch( vect(-1673, -1319.913574, 130.813538), rot(0, 32767, 0), 'MoleHideoutOpened' );
        break;

    case "03_NYC_MOLEPEOPLE":
        foreach AllActors(class'Mover', m, 'DeusExMover') {
            if( m.Name == 'DeusExMover65' ) m.Tag = 'BathroomDoor';
        }
        AddSwitch( vect(3745, -2593.711914, 140.335358), rot(0, 0, 0), 'BathroomDoor' );
        break;
#endif

    case "03_NYC_747":
        // fix Jock's conversation state so he doesn't play the dialog for unatco->battery park but now plays dialog for airfield->unatco
        // DL_Airfield is "You're entering a helibase terminal below a private section of LaGuardia."
        dxr.flagbase.SetBool('DL_Airfield_Played', true,, 4);
        if(#defined(vanillamaps)) {
            foreach AllActors(class'#var(prefix)InformationDevices', i) {
                if(i.imageClass == Class'Image03_747Diagram') {
                    // move the out of bounds datacabe onto the bed of the empty room
                    i.SetLocation(vect(1554.862549, -741.237427, 363.370605));
                }
            }
        }
        Spawn(class'PlaceholderItem',,, vect(1702,-359.8,373)); //Bathroom counter
        Spawn(class'PlaceholderItem',,, vect(1624.15,-740.12,373)); //Guest bed headboard
        Spawn(class'PlaceholderItem',,, vect(1412.5,-297.7,406.32)); //Closet shelf
        Spawn(class'PlaceholderItem',,, vect(1445.97,-294.6,316.31)); //Closet floor
        Spawn(class'PlaceholderItem',,, vect(733.2,-462.57,342.5)); //Middle seat row
        Spawn(class'PlaceholderItem',,, vect(617.1,-511.35,342.51)); //Back row seat
        Spawn(class'PlaceholderItem',,, vect(327.4,-524.8,342.5)); //Weird solo seating row
        Spawn(class'PlaceholderItem',,, vect(342.4,-730.14,196.3)); //Shelf in cargo area
        Spawn(class'PlaceholderItem',,, vect(495.4,-733.96,196.3)); //Shelf in cargo area
        break;

    case "03_NYC_UNATCOISLAND":
        foreach AllActors(class'#var(prefix)UNATCOTroop', unatco) {
            if(unatco.BindName != "PrivateLloyd") continue;
            unatco.FamiliarName = "Corporal Lloyd";
            unatco.UnfamiliarName = "Corporal Lloyd";
        }
        break;
    case "03_NYC_UNATCOHQ":
        //Spawn some placeholders for new item locations
        Spawn(class'PlaceholderItem',,, vect(363.284149, 344.847, 50.32)); //Womens bathroom counter
        Spawn(class'PlaceholderItem',,, vect(211.227, 348.46, 50.32)); //Mens bathroom counter
        Spawn(class'PlaceholderItem',,, vect(982.255,1096.76,-7)); //Jaime's desk
        Spawn(class'PlaceholderItem',,, vect(2033.8,1979.9,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vect(2148,2249,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vect(2433,1384,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vect(-307.8,-1122,-7)); //Anna's Desk
        Spawn(class'PlaceholderItem',,, vect(-138.5,-790.1,-1.65)); //Anna's bookshelf
        Spawn(class'PlaceholderItem',,, vect(-27,1651.5,291)); //Breakroom table
        Spawn(class'PlaceholderItem',,, vect(602,1215.7,295)); //Kitchen Counter
        Spawn(class'PlaceholderItem',,, vect(-672.8,1261,473)); //Upper Left Office desk
        Spawn(class'PlaceholderContainer',,, vect(-1187,-1154,-31)); //Behind Jail Desk
        Spawn(class'PlaceholderContainer',,, vect(2384,1669,-95)); //MJ12 Door
        Spawn(class'PlaceholderContainer',,, vect(-383.6,1376,273)); //JC's Office
        break;
    }
}

function AnyEntryMapFixes()
{
    switch(dxr.localURL) {
    case "03_NYC_747":
        SetTimer(1, true);
        break;
    }
}

function FixAnnaAmbush()
{
    local #var(prefix)AnnaNavarre anna;
    local #var(prefix)ThrownProjectile p;

    foreach AllActors(class'#var(prefix)AnnaNavarre', anna) {break;}

    // if she's angry then let her blow up
    if(anna != None && anna.GetAllianceType('player') == ALLIANCE_Hostile) anna = None;

    foreach AllActors(class'#var(prefix)ThrownProjectile', p) {
        if(!p.bProximityTriggered || !p.bStuck) continue;
        if(p.Owner==player() && anna != None) p.SetOwner(anna);
        if(anna == None && p.Owner!=player()) p.SetOwner(player());
    }
}
