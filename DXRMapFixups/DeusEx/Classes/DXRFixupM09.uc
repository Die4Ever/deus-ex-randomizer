class DXRFixupM09 extends DXRFixup;

var int storedWeldCount;// ship weld points

function CheckConfig()
{
    local int i;

    add_datacubes[i].map = "09_NYC_Dockyard";
    add_datacubes[i].text = "Jenny I've got your number|nI need to make you mine|nJenny don't change your number|n 8675309";// DXRPasswords doesn't recognize |n as a wordstop
    i++;
    add_datacubes[i] = add_datacubes[i-1];// dupe
    i++;

    Super.CheckConfig();
}

function PreFirstEntryMapFixes()
{
    local #var(DeusExPrefix)Mover m;
    local ComputerSecurity cs;
    local #var(prefix)Keypad2 k;
    local Button1 b;
    local WeaponGasGrenade gas;
    local Teleporter t;
    local BlockPlayer bp;
    local DynamicBlockPlayer dbp;
    local #var(prefix)OrdersTrigger ord;
    local #var(prefix)Containers c;
    local Rotator rot;
    local #var(prefix)LAM lam;
    local #var(prefix)GasGrenade gasgren;
    local Switch1 s;
    local #var(prefix)Barrel1 barrel;
    local #var(prefix)RatGenerator rg;
    local #var(prefix)FlagTrigger ft;
    local #var(prefix)NanoKey key;
    local #var(prefix)BeamTrigger beam;
    local OnceOnlyTrigger oot;
    local #var(prefix)PigeonGenerator pg;
    local #var(prefix)Trigger trig;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
    local DXRHoverHint hoverHint;

    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL)
    {
    case "09_NYC_SHIP":
        if (VanillaMaps){
            foreach AllActors(class'#var(DeusExPrefix)Mover', m, 'DeusExMover') {
                if( m.Name == 'DeusExMover7' ) m.Tag = 'shipbelowdecks_door';
            }
            AddSwitch( vect(2534.639893, 227.583054, 339.803802), rot(0,-32760,0), 'shipbelowdecks_door' );

            //Button to open the office door
            AddSwitch( vect(2056.951904,-1792.230713,-170.444351), rot(16382, 0, 0), 'FrontDoor');

            foreach AllActors(class'Switch1',s){
                if (s.Event=='Eledoor01'){
                    s.Event='Elevator01_bottom';
                    break;
                }
            }

            //A button *behind* the elevator that sends it up, since it's possible to fall back there and live...
            AddSwitch( vect(2905.517578,-1641.676270,-430.253693), rot(0,0,0), 'Elevator01_top', "Ramisme's Escape Button");

            //Detach the triggers that opens the op room doors when you get near them from inside
            foreach AllActors(class'#var(prefix)Trigger',trig){
                if (trig.Event=='SecDoor1' || trig.Event=='SecDoor2'){
                    trig.Event='DontDoAnything';
                }
            }

            foreach AllActors(class'ComputerSecurity',cs){
                if (cs.ComputerNode==CN_UNATCO){
                    cs.ComputerNode=CN_China;
                }
            }

            rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(-738,-1412,-474));//Near sewer grate
            rg.MaxCount=1;

            //Add some new locations for containers and items
            Spawn(class'PlaceholderContainer',,, vectm(-3143,274,305)); //Front of ship
            Spawn(class'PlaceholderContainer',,, vectm(-3109,-73,305)); //Front of ship
            Spawn(class'PlaceholderContainer',,, vectm(-2764,186,305)); //Front of ship
            Spawn(class'PlaceholderItem',,, vectm(-3544.129150,112.244072,330.309601)); //Actual Front of ship
            Spawn(class'PlaceholderItem',,, vectm(-2538.4,38.5,283)); //Near stuff at front of ship
            Spawn(class'PlaceholderItem',,, vectm(-2554.4,-247,283)); //Near stuff at front of ship
            Spawn(class'PlaceholderItem',,, vectm(-254,557.8,302)); //Guard Post in shipping container
            Spawn(class'PlaceholderItem',,, vectm(3004.5,-453,523)); //Ship kitchen
            Spawn(class'PlaceholderItem',,, vectm(1788,107,509)); //Ship bathroom table
            Spawn(class'PlaceholderItem',,, vectm(2152,701,519)); //Ship bunkbed
            Spawn(class'PlaceholderItem',,, vectm(3000.4,511.28,526.4)); //Ship fume extractor
            Spawn(class'PlaceholderItem',,, vectm(1243,-2106,-432)); //Shipyard break room table
            Spawn(class'PlaceholderItem',,, vectm(2517.303467,-1384.390381,-250.690430)); //Shipyard showers locker 1
            Spawn(class'PlaceholderItem',,, vectm(2474.926270,-1385.917603,-250.689545)); //Shipyard showers locker 2
            Spawn(class'PlaceholderItem',,, vectm(2431.561279,-1385.172363,-250.690308)); //Shipyard showers locker 3
            Spawn(class'PlaceholderItem',,, vectm(2354.278809,-1383.854980,-250.689301)); //Shipyard showers locker 5
            Spawn(class'PlaceholderItem',,, vectm(2354,-1676,-223)); //Shipyard change room bench
            Spawn(class'PlaceholderItem',,, vectm(2605,-1839,-257)); //Shipyard bathroom stall 1
            Spawn(class'PlaceholderItem',,, vectm(2816,-1816,-257)); //Shipyard bathroom stall 2
            Spawn(class'PlaceholderItem',,, vectm(2808,-1511.5,-207)); //Shipyard bathroom sink
            Spawn(class'PlaceholderItem',,, vectm(1565.7,-994,-433.7)); //Shipyard ramp control panel
            Spawn(class'PlaceholderItem',,, vectm(3361,-1255.9,1187)); //Shipyard crane control room
            Spawn(class'PlaceholderContainer',,, vectm(-1248,-1248,-460)); //Shipyard dock near sewer entrance
            Spawn(class'PlaceholderContainer',,, vectm(-1185,-1175,-460)); //Shipyard dock near sewer entrance
            Spawn(class'PlaceholderContainer',,, vectm(3172,-1248,-460)); //Shipyard dock near maintenance ladder

            class'PlaceholderEnemy'.static.Create(self,vectm(2639,-1817,-220),,'Shitting');
            class'PlaceholderEnemy'.static.Create(self,vectm(2805,-1824,-220),,'Shitting');
            class'PlaceholderEnemy'.static.Create(self,vectm(2005,-68,512),,'Shitting');
        }
        break;

    case "09_NYC_SHIPBELOW":
        // make the weld points highlightable
        foreach AllActors(class'#var(DeusExPrefix)Mover', m, 'ShipBreech') {
            m.bHighlight = true;
            m.bLocked = true;
        }

        // locked storage closet overlooking the helipad
        foreach AllActors(class'#var(DeusExPrefix)Mover', m, 'AugSafe') {
            m.KeyIDNeeded = 'AugSafe';
            m.bHighlight = true;
            m.bFrobbable = true;
            m.bLocked = true;
        }
        key = Spawn(class'#var(prefix)NanoKey',,, vectm(-5330.727539, 326.412018, -426.790955));
        key.KeyID = 'AugSafe';
        key.Description = "Ship's Storage Closet Key";
        if(dxr.flags.settings.keysrando > 0)
            GlowUp(key);

        // remove the orders triggers that cause guys to attack when destroying weld points
        foreach AllActors(class'#var(prefix)OrdersTrigger', ord, 'wall1') {
            ord.Event = '';
            ord.Destroy();
        }
        foreach AllActors(class'#var(prefix)OrdersTrigger', ord, 'wall2') {
            ord.Event = '';
            ord.Destroy();
        }
        UpdateWeldPointGoal(5);

        if (VanillaMaps){
            foreach AllActors(class'ComputerSecurity',cs){
                if (cs.Name == 'ComputerSecurity4'){
                    cs.specialOptions[0].Text = "Disable Ventilation Fan";
                    cs.specialOptions[0].TriggerEvent='FanToggle';
                    cs.specialOptions[0].TriggerText="Ventilation Fan Disabled";
                }
            }

            //Remove the stupid gas grenades that are past the level exit
            foreach AllActors(class'Teleporter',t){
                if (t.Tag=='ToAbove') break;
            }
            gas = WeaponGasGrenade(findNearestToActor(class'WeaponGasGrenade',t));
            if (gas!=None){
                gas.Destroy();
            }
            gas = WeaponGasGrenade(findNearestToActor(class'WeaponGasGrenade',t));
            if (gas!=None){
                gas.Destroy();
            }
        }
        break;

    case "09_NYC_DOCKYARD":
        foreach AllActors(class'#var(prefix)LAM', lam) {
            if(lam.name != 'LAM2') continue;
            lam.bCollideWorld = false;
            lam.SetLocation(vectm(2073, 6085.963379, -235.489441));
            lam.bCollideWorld = true;
            break;
        }

        if (VanillaMaps){
            foreach AllActors(class'#var(prefix)GasGrenade',gasgren) {
                //This one has falling physics normally, so just fix it
                //It can fall out of position before the physics get fixed, so put it back
                if (gasgren.name=='GasGrenade0'){
                    gasgren.SetPhysics(PHYS_None);
                    gasgren.bCollideWorld = false;
                    gasgren.SetRotation(rotm(0,-16472,0,GetRotationOffset(gasgren.Class)));
                    gasgren.SetLocation(vectm(1602.174,2470.3386,-431.6885));
                    gasgren.bCollideWorld = true;
                    break;
                }
            }

            foreach AllActors(class'#var(prefix)BeamTrigger',beam){
                if (beam.Event=='BotDrop'){
                    beam.Tag='TunnelTrigger';
                    beam.Event='BotDropOnce';
                }
            }

            oot=Spawn(class'OnceOnlyTrigger');
            oot.Event='BotDrop';
            oot.Tag='BotDropOnce';

            //Add teleporter hint text to Jock
            foreach AllActors(class'#var(prefix)MapExit',exit,'ToGraveyard'){break;}
            foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'BlackHelicopter'){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit);
            hoverHint.SetBaseActor(jock);

            AddSwitch( vect(4973.640137, 6476.444336, 1423.943848), rot(0,32768,0), 'Crane');
        }

        //They put the key ID in the tag for some reason
        foreach AllActors(class'#var(prefix)NanoKey',key,'SupplyRoom'){
            if (key.keyID==''){
                key.keyID='SupplyRoom';
            }
        }

        //Button to open the sewer grate from the ship side
        AddSwitch( vect(1883.546753,6404.096191,-232.870697), rot(0, 0, 0), 'DrainGrate');


        foreach AllActors(class'Button1',b){
            if (b.Tag=='Button1' && b.Event=='Lift' && b.Location.Z < 200){ //vanilla Z is 97 for the lower button, just giving some slop in case it was changed in another mod?
                rot = b.Rotation;
                k = Spawn(class'#var(prefix)Keypad2',,,b.Location, rot);
                k.validCode="8675309"; //They really like Jenny in this place
                k.bToggleLock=False;
                k.Event='Lift';
                b.Event=''; //If you don't unset the event, it gets called when the button is destroyed...
                b.Destroy();
                break;
            }
        }
        // near the start of the map to jump over the wall, from (2536.565674, 1600.856323, 251.924713) to 3982.246826
        foreach RadiusActors(class'BlockPlayer', bp, 725, vectm(3259, 1601, 252)) {
            bp.bBlockPlayers=false;
        }
        // 4030.847900 to 4078.623779
        foreach RadiusActors(class'BlockPlayer', bp, 25, vectm(4055, 1602, 252)) {
            dbp = Spawn(class'DynamicBlockPlayer',,, bp.Location + vectm(0,0,200));
            dbp.SetCollisionSize(bp.CollisionRadius, bp.CollisionHeight + 101);
        }

        // ignore objects out of bounds
        foreach RadiusActors(class'#var(prefix)Containers', c, 450, vectm(4300, 1200, 31)) {
            c.bIsSecretGoal = true;
        }
        foreach RadiusActors(class'#var(prefix)Containers', c, 160, vectm(3823.322266, 365.613495, 36)) {
            c.bIsSecretGoal = true;
        }
        foreach RadiusActors(class'#var(prefix)Containers', c, 400, vectm(2274.548340, 730.766357, 31)) {
            c.bIsSecretGoal = true;
        }

        pg=Spawn(class'#var(prefix)PigeonGenerator',,, vectm(3941,6625,1385));//Rooftop, near vent entrance
        pg.MaxCount=3;

        class'PlaceholderEnemy'.static.Create(self,vectm(3292,4792,48));
        class'PlaceholderEnemy'.static.Create(self,vectm(4610,6714,1408));
        class'PlaceholderEnemy'.static.Create(self,vectm(3209,2333,48));

        class'PlaceholderEnemy'.static.Create(self,vectm(1475,3249,48),,'Shitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(2435,2271,48),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(1038,3391,48),,'Sitting');

        break;

    case "09_NYC_SHIPFAN":
        if (VanillaMaps){
            foreach AllActors(class'ComputerSecurity',cs){
                if (cs.Name == 'ComputerSecurity6'){
                    cs.specialOptions[0].Text = "Disable Ventilation Fan";
                    cs.specialOptions[0].TriggerEvent='FanToggle';
                    cs.specialOptions[0].TriggerText="Ventilation Fan Disabled";
                }
            }
        }
        break;

    case "09_NYC_GRAVEYARD":
        Spawn(class'PlaceholderItem',,, vectm(-509.5,-742.88,-213)); //Tunnels
        Spawn(class'PlaceholderItem',,, vectm(-1524.8,-943.9,-285.69)); //Empty Sarcophogus
        Spawn(class'PlaceholderItem',,, vectm(-1433.77,1161.87,-149)); //Escape tunnel
        Spawn(class'PlaceholderItem',,, vectm(-828.5,-266.1,27)); //Front of tomb
        Spawn(class'PlaceholderItem',,, vectm(-1499.35,-454.93,-293)); //Tomb stairs
        Spawn(class'PlaceholderItem',,, vectm(1108.85,808.15,71.309769)); //Secret room shelf 1
        Spawn(class'PlaceholderItem',,, vectm(1110,829.5,35.310154)); //Secret room shelf 2

        // for Stick With the Prod modes, in pre so these will get shuffled
        AddActor(class'#var(prefix)AmmoDartPoison', vect(-1508.116821,-939.598755,-293.900604));
        barrel = #var(prefix)Barrel1(AddActor(class'#var(prefix)Barrel1', vect(-1112.480469,1120.735840,29.096186)));
        barrel.SkinColor = SC_Explosive;
        barrel.BeginPlay();

        // just in case the gate keeper gets stuck, or if you wanna go fast!
        foreach AllActors(class'#var(prefix)FlagTrigger', ft, 'CheckGateFlag') {
            ft.FlagName = 'RingForService_Played';
            ft.SetCollision(false,false,false);
            ft.SetCollisionSize(0,0);
        }
        foreach AllActors(class'#var(prefix)FlagTrigger', ft, 'MakeGateOpen') {
            ft.SetCollision(false,false,false);
            ft.SetCollisionSize(0,0);
        }

        // allow jumping over the fence better, these are near the cars and the gatekeeper
        foreach RadiusActors(class'BlockPlayer', bp, 385, vectm(682.616821, 1052.459473, 291.541748)) {
            bp.bBlockPlayers = false;
        }
        // these are on the other side towards the tombstones
        foreach RadiusActors(class'BlockPlayer', bp, 150, vectm(255.896591, 976.539551, 291.541748)) {
            bp.bBlockPlayers = false;
        }

        //Add teleporter hint text to Jock
        foreach AllActors(class'#var(prefix)MapExit',exit,'CopterCam'){break;}
        foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'BlackHelicopter'){break;}
        hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit);
        hoverHint.SetBaseActor(jock);

        if (#defined(vanilla)) {
            dxr.dxInfo.startupMessage[0] = "New York City, Lower East Side Cemetery"; // fix "cemetery" misspelling
        }

        break;
    }
}

function PostFirstEntryMapFixes()
{
    local #var(prefix)CrateUnbreakableLarge c;
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    switch(dxr.localURL) {
    case "09_NYC_DOCKYARD":
        if (!RevisionMaps){
            // this crate can block the way out of the start through the vent
            foreach RadiusActors(class'#var(prefix)CrateUnbreakableLarge', c, 160, vectm(2510.350342, 1377.569336, 103.858093)) {
                l("removing " $ c $ " dist: " $ VSize(c.Location - vectm(2510.350342, 1377.569336, 103.858093)) );
                c.Destroy();
            }
        }
        break;

    case "09_NYC_SHIPBELOW":
        if (!RevisionMaps){
            if(!dxr.flags.IsZeroRando()) {
                // add a tnt crate on top of the pipe, visible from the ground floor
                AddActor(class'#var(prefix)CrateExplosiveSmall', vect(141.944641, -877.442627, -175.899567));
            }
            // add a tnt crate in the locked storage closet overlooking the helipad
            AddActor(class'#var(prefix)CrateExplosiveSmall', vect(-4185.878906, -357.704376, -239.899658));
            // remove big crates blocking the window to the pipe, 16 units == 1 foot
            foreach RadiusActors(class'#var(prefix)CrateUnbreakableLarge', c, 16*4, vectm(-136.125000, -743.875000, -215.899323)) {
                c.Event = '';
                c.Destroy();
            }
        }
        break;
    }
}

function AnyEntryMapFixes()
{
    local #var(DeusExPrefix)Mover m;

    switch(dxr.localURL)
    {
    case "09_NYC_SHIP":
        if(dxr.flagbase.GetBool('HelpSailor') && class'DXRMapVariants'.static.IsVanillaMaps(player())) {
            foreach AllActors(class'#var(DeusExPrefix)Mover', m, 'FrontDoor') {
                m.bLocked = false;
            }
        }
        break;

    case "09_NYC_SHIPBELOW":
        SetTimer(1, True);
        Tag = 'FanToggle';
        break;

    case "09_NYC_SHIPFAN":
        Tag = 'FanToggle';
        break;
    }
}

function TimerMapFixes()
{
    switch(dxr.localURL)
    {
    case "09_NYC_SHIPBELOW":
        NYC_09_CountWeldPoints();
        break;
    }
}

function UpdateWeldPointGoal(int count)
{
    local string goalText;
    local DeusExGoal goal;
    local int bracketPos;
    goal = player().FindGoal('ScuttleShip');

    if (goal!=None){
        goalText = goal.text;
        bracketPos = InStr(goalText,"(");

        if (bracketPos>0){ //If the extra text is already there, strip it.
            goalText = Mid(goalText,0,bracketPos-1);
        }

        goalText = goalText$" ("$count$" remaining)";

        goal.SetText(goalText);
    }
}

function NYC_09_CountWeldPoints()
{
    local int newWeldCount;
    local DeusExMover m;

    newWeldCount=0;

    //Search for the weld point movers
    foreach AllActors(class'DeusExMover',m, 'ShipBreech') {
        if (!m.bDestroyed){
            newWeldCount++;
        }
    }

    if (newWeldCount != storedWeldCount) {
        //A weld point has been destroyed!
        storedWeldCount = newWeldCount;

        switch(newWeldCount){
            case 0:
                player().ClientMessage("All weld points destroyed!");
                SetTimer(0, False);  //Disable the timer now that all weld points are gone
                break;
            case 1:
                player().ClientMessage("1 weld point remaining");
                break;
            default:
                player().ClientMessage(newWeldCount$" weld points remaining");
                break;
        }

        UpdateWeldPointGoal(newWeldCount);
    }
}


function Trigger(Actor Other, Pawn Instigator)
{
    if (Tag=='FanToggle' && class'DXRMapVariants'.static.IsVanillaMaps(player())){
        ToggleFan();
    }
}

function ToggleFan()
{
    local Fan1 f;
    local ParticleGenerator pg;
    local ZoneInfo z;
    local AmbientSound as;
    local ComputerSecurity cs;
    local bool enable;
    local name compName;
    local DeusExMover dxm;

    if (class'DXRMapVariants'.static.IsVanillaMaps(player())==False){
        return;
    }

    //This function is now used in two maps
    switch(dxr.localURL)
    {
        case "09_NYC_SHIPBELOW":
            compName = 'ComputerSecurity4';
            break;
        case "09_NYC_SHIPFAN":
            compName = 'ComputerSecurity6';
            break;
        default:
            player().ClientMessage("Not in a map that understands how to toggle a fan!");
            return;
            break;
    }

    foreach AllActors(class'ComputerSecurity',cs){
        if (cs.Name == compName){
            //If you press disable, you want to disable...
            if (cs.SpecialOptions[0].Text == "Disable Ventilation Fan"){
                enable = False;
            } else {
                enable = True;
            }

            if (enable){
                cs.specialOptions[0].Text = "Disable Ventilation Fan";
                cs.specialOptions[0].TriggerText="Ventilation Fan Enabled"; //Unintuitive, but it prints the text before the trigger call
            } else {
                cs.specialOptions[0].Text = "Enable Ventilation Fan";
                cs.specialOptions[0].TriggerText="Ventilation Fan Disabled";
            }
            break;
        }
    }

    if (dxr.localURL=="09_NYC_SHIPBELOW"){
        //Fan1
        foreach AllActors(class'Fan1',f){
            if (f.Name == 'Fan1'){
                if (enable) {
                    f.RotationRate.Yaw = 50000;
                } else {
                    f.RotationRate.Yaw = 0;
                }
            }
        }

        //ParticleGenerator3
        foreach AllActors(class'ParticleGenerator',pg){
            if (pg.Name == 'ParticleGenerator3'){
                pg.bSpewing = enable;
                pg.bFrozen = !enable;
                pg.proxy.bHidden=!enable;
                break;
            }
        }

        //ZoneInfo0
        foreach AllActors(class'ZoneInfo',z){
            if (z.Name=='ZoneInfo0') {
                if (enable){
                    z.ZoneGravity.Z = 100;
                } else {
                    z.ZoneGravity.Z = -950;
                }
                break;
            }
        }

        //AmbientSound7
        //AmbientSound8
        foreach AllActors(class'AmbientSound',as){
            if (as.Name=='AmbientSound7'){
                if (enable){
                    as.AmbientSound = Sound(DynamicLoadObject("Ambient.Ambient.HumTurbine2", class'Sound'));
                } else {
                    as.AmbientSound = None;
                }
            } else if (as.Name=='AmbientSound8'){
                if (enable){
                    as.AmbientSound = Sound(DynamicLoadObject("Ambient.Ambient.StrongWind", class'Sound'));
                } else {
                    as.AmbientSound = None;
                }
            }
        }
    } else if (dxr.localURL=="09_NYC_SHIPFAN"){
        foreach AllActors(class'DeusExMover',dxm){
            if (dxm.Name == 'DeusExMover1'){
                if (enable) {
                    dxm.RotationRate.Yaw = -20000;
                } else {
                    dxm.RotationRate.Yaw = 0;
                }
            }
        }
        foreach AllActors(class'AmbientSound',as){
            if (as.Name=='AmbientSound6'){
                if (enable){
                    as.AmbientSound = Sound(DynamicLoadObject("Ambient.Ambient.FanLarge", class'Sound'));
                } else {
                    as.AmbientSound = None;
                }
            } else if (as.Name=='AmbientSound0'){
                if (enable){
                    as.AmbientSound = Sound(DynamicLoadObject("Ambient.Ambient.MachinesLarge3", class'Sound'));
                } else {
                    as.AmbientSound = None;
                }
            }
        }
    }
}
