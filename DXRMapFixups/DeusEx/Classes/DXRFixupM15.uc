class DXRFixupM15 extends DXRFixup;

var int storedReactorCount;// Area 51 goal

function CheckConfig()
{
    local int i;
    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    add_datacubes[i].map = "15_AREA51_BUNKER";
    add_datacubes[i].text = "Security Personnel:|nDue to the the threat of a mass civilian raid of Area 51, we have updated the ventilation security system.|n|nUser: SECURITY |nPassword: NarutoRun |n|nBe on the lookout for civilians running with their arms swept behind their backs...";
    if (VanillaMaps){
        add_datacubes[i].Location = vect(1115,-1840,-460); //Boxes in Hangar
    } else {
        add_datacubes[i].Location = vect(1140,-1920,-460); //Boxes in Hangar
    }
    add_datacubes[i].plaintextTag = "A51VentComputerCode";
    i++;

    add_datacubes[i].map = "15_AREA51_BUNKER";
    add_datacubes[i].text = "Security Personnel:|nFor increased ventilation system security, we have replaced the elevator button with a keypad.  The code is 17092019.  Do not share the code with anyone and destroy this datacube after reading.";
    if (VanillaMaps){
        add_datacubes[i].Location = vect(1260,-2875,-260); //Pipes next to Xander in Hangar
    } else {
        add_datacubes[i].Location = vect(1600,-2875,-260); //Pipes next to Xander in Hangar
    }
    add_datacubes[i].plaintextTag = "A51VentElevatorCode";
    i++;


    add_datacubes[i].map = "15_AREA51_ENTRANCE";
    add_datacubes[i].text =
        "Julia, I must see you -- we have to talk, about us, about this project.  I'm not sure what we're doing here anymore and Page has made... strange requests of the interface team."
        $ "  I would leave, but not without you.  You mean too much to me.  After the duty shift changes, come to my chamber -- it's the only place we can talk in private."
        $ "  The code is 6786.  I love you."
        $ "|n|nJustin";
    add_datacubes[i].Location = vect(3200,-1400,-150); //First set of boxes down hall with doors
    add_datacubes[i].plaintextTag = "SleepPodCode1";
    i++;

    add_datacubes[i].map = "15_AREA51_ENTRANCE";
    add_datacubes[i].text =
        "Julia, I must see you -- we have to talk, about us, about this project.  I'm not sure what we're doing here anymore and Page has made... strange requests of the interface team."
        $ "  I would leave, but not without you.  You mean too much to me.  After the duty shift changes, come to my chamber -- it's the only place we can talk in private."
        $ "  The code is 3901.  I love you."
        $ "|n|nJohn";
    add_datacubes[i].Location = vect(4030,-610,-150); //Second set of boxes down the hall with doors
    add_datacubes[i].plaintextTag = "SleepPodCode2";
    i++;

    add_datacubes[i].map = "15_AREA51_ENTRANCE";
    add_datacubes[i].text =
        "Julia, I must see you -- we have to talk, about us, about this project.  I'm not sure what we're doing here anymore and Page has made... strange requests of the interface team."
        $ "  I would leave, but not without you.  You mean too much to me.  After the duty shift changes, come to my chamber -- it's the only place we can talk in private."
        $ "  The code is 4322.  I love you."
        $ "|n|nJim";
    add_datacubes[i].Location = vect(4008,662,-150); //Fourth set of boxes down the hall with doors
    add_datacubes[i].plaintextTag = "SleepPodCode3";
    i++;

    add_datacubes[i].map = "15_AREA51_PAGE";
    add_datacubes[i].text =
        "The security guys found my last datacube so they changed the UC Control Rooms code to 1234. I don't know what they're so worried about, no one could make it this far into Area 51. What's the worst that could happen?";

    //Boxes directly under Page
    if (class'DXRMapVariants'.static.IsVanillaMaps(player())){
        add_datacubes[i].Location = vect(6330,-7225,-5550);
    } else {
        add_datacubes[i].Location = vect(160,2350,-180);
    }
    add_datacubes[i].plaintextTag = "UCControlRoomPassword";
    i++;

    Super.CheckConfig();
}

function FixJockExplosion()
{
#ifdef injections
    local BlackHelicopter chopper;

    foreach AllActors(class'BlackHelicopter',chopper,'heli_sabotaged'){
        chopper.bDying=True;
    }
#endif
}

function PreFirstEntryMapFixes_Bunker(bool isVanilla)
{
    local DeusExMover d;
    local ComputerSecurity c;
    local Keypad k;
    local #var(prefix)Button1 b;
    local Switch2 s2;
    local SequenceTrigger st;
    local DataLinkTrigger dlt;
    local Dispatcher disp;
    local OnceOnlyTrigger oot;
    local Trigger trig;
    local #var(prefix)RatGenerator rg;
    local Vector loc;
    local #var(prefix)Fan1 fan;
    local #var(prefix)WaltonSimons ws;

    //Make it only possible to turn the power on, make it impossible to turn the power off again
    foreach AllActors(class'Dispatcher',disp,'power_dispatcher'){
        disp.Tag = 'power_dispatcher_real';
        break;
    }

    oot = Spawn(class'OnceOnlyTrigger');
    oot.Event='power_dispatcher_real';
    oot.Tag='power_dispatcher';

    //Make sure the power turns on if you get to the bottom
    trig = Spawn(class'Trigger',,,vectm(4414,-1035,-7543));
    trig.SetCollisionSize(180,40);
    trig.event = 'power_dispatcher';

    //Make the movers way faster
    foreach AllActors(class'DeusExMover',d){
        switch(d.Tag){
            case 'upper_elevator_sw':
            case 'upper_elevator_sw_works':
            case 'lower_elevator_sw':
            case 'lower_elevator_sw_works':
                d.MoveTime=0.01; //So fast it just looks like the buttons and stuff swapped instantly, even if you're looking
                break;
        }
    }


    //This door can get stuck if a spiderbot gets jammed into the little bot-bay
    foreach AllActors(class'DeusExMover',d){
        if (d.Tag=='bot_door'){
            d.MoverEncroachType=ME_IgnoreWhenEncroach;
        }
    }

    //Button to open blast doors from inside
    AddSwitch( vect(2015.894653,1390.463867,-839.793091), rot(0, -16328, 0), 'blast_door');


    //The buttons on the big elevator down to the bunker entrance could be used if you reached around
    //the invisible panel that is supposed to block them.  Make them actually unusable until the power
    //is turned on.
    foreach AllActors(class'#var(prefix)Button1',b){
        if (b.Event=='level1'){
            b.Tag='level1_switch';
            class'DXRTriggerEnable'.static.Create(b,'power','level1_switch');
        } else if (b.Event=='level2'){
            b.Tag='level2_switch';
            class'DXRTriggerEnable'.static.Create(b,'power','level2_switch');
        }
    }

    foreach AllActors(class'#var(prefix)Fan1',fan,'Fan_vertical_shaft_1'){ //The "jump, you can make it!" fan
        fan.bHighlight=True;
    }

    FixJockExplosion();  //Only actually does anything with injections, but theoretically could work if we replaced the helicopter

    //Change vent entry security computer password so it isn't pre-known
    foreach AllActors(class'ComputerSecurity',c){
        if (c.UserList[0].UserName=="SECURITY" && c.UserList[0].Password=="SECURITY"){
            c.UserList[0].Password="NarutoRun"; //They can't stop all of us
        }
    }

    //Move the vent entrance elevator to the bottom to make it slightly less convenient
    foreach AllActors(class'SequenceTrigger',st){
        if (st.Tag=='elevator_mtunnel_down'){
            st.Trigger(Self,player());
        }
    }

    //Swap the button at the top of the elevator to a keypad to make this path a bit more annoying
    foreach AllActors(class'Switch2',s2){
        if (s2.Event=='elevator_mtunnel_up'){
            k = Spawn(class'Keypad2',,,s2.Location,s2.Rotation);
            k.validCode="17092019"; //September 17th, 2019 - First day of "Storm Area 51"
            k.bToggleLock=False;
            k.Event='elevator_mtunnel_up';
            s2.event='';
            s2.Destroy();
            break;
        }
    }

    // find the DataLinkTrigger where Page tells you to jump, we use this for finding the door and adjusting its position
    foreach AllActors(class'DataLinkTrigger',dlt){
        if (dlt.datalinkTag=='DL_Bunker_Fan') {
            //Lock the fan entrance top door
            d = DeusExMover(findNearestToActor(class'DeusExMover',dlt));
            if(d == None) break;
            d.bLocked=True;
            d.bBreakable=True;
            d.FragmentClass=Class'DeusEx.MetalFragment';
            d.ExplodeSound1=Sound'DeusExSounds.Generic.MediumExplosion1';
            d.ExplodeSound2=Sound'DeusExSounds.Generic.MediumExplosion2';
            d.minDamageThreshold=25;
            d.doorStrength = 0.20; //It's just grating on top of the vent, so it's not that strong

            //Make Page tell you to jump even if you enter the fan entrance through the hatch
            loc = dlt.Location;
            loc.z -= 100.0;
            dlt.SetLocation(loc);
            dlt.SetCollisionSize(dlt.CollisionRadius, dlt.CollisionHeight + 100.0);

            break;
        }
    }


    if (isVanilla) {
        // doors_lower is for backtracking
        AddSwitch( vect(4309.076660, -1230.640503, -7522.298340), rot(0, 16384, 0), 'doors_lower');

        Spawn(class'#var(prefix)LiquorBottle',,, vectm(1005.13,2961.26,-480)); //Liquor in a locker, so every mission has alcohol

        foreach AllActors(class'#var(prefix)WaltonSimons',ws){
            ws.MaxProvocations = 0;
            ws.AgitationSustainTime = 3600;
            ws.AgitationDecayRate = 0;
        }

        Spawn(class'PlaceholderItem',,, vectm(-1469.9,3238.7,-213)); //Storage building
        Spawn(class'PlaceholderItem',,, vectm(-1565.4,3384.8,-213)); //Back of Storage building
        Spawn(class'PlaceholderItem',,, vectm(-1160.9,256.3,-501)); //Tower basement
        Spawn(class'PlaceholderItem',,, vectm(1481,3192.7,-468)); //Command building bed
        Spawn(class'PlaceholderItem',,, vectm(923.008606,2962.796387,-482.689789)); //Command building locker
        Spawn(class'PlaceholderItem',,, vectm(1106.5,-2860.4,-165)); //Hangar building roof
        Spawn(class'PlaceholderItem',,, vectm(1104.7,-2925.7,-325)); //Hangar building next to guy who gives up
        Spawn(class'PlaceholderItem',,, vectm(520.26,-1482.3,-453)); //Boxes in Hangar
        Spawn(class'PlaceholderItem',,, vectm(1017.5,-1842.1,-453)); //Boxes in Hangar near enemies

        class'PlaceholderEnemy'.static.Create(self,vectm(-2237,3225,-192));
        class'PlaceholderEnemy'.static.Create(self,vectm(4234,3569,-736));
        class'PlaceholderEnemy'.static.Create(self,vectm(3744,-1030,-7481));
        class'PlaceholderEnemy'.static.Create(self,vectm(1341,3154,-464),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(1191,3035,-464),,'Sitting');

        rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(1658,2544,-522));//Behind Command 24
        rg.MaxCount=1;
        rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(4512,3747,-954));//Near generators inside bunker
        rg.MaxCount=1;
    } else {
        Spawn(class'#var(prefix)LiquorBottle',,, vectm(1165,2540,-280)); //Liquor in a locker, so every mission has alcohol

        Spawn(class'PlaceholderItem',,, vectm(-1738,2863,-210)); //Storage building
        Spawn(class'PlaceholderItem',,, vectm(-1816,3048,-210)); //Back of Storage building
        Spawn(class'PlaceholderItem',,, vectm(-1154,178,-560)); //Other storage building basement
        Spawn(class'PlaceholderItem',,, vectm(1709,2748,-265)); //Command building bed
        Spawn(class'PlaceholderItem',,, vectm(1285,2542,-280)); //Command building locker
        Spawn(class'PlaceholderItem',,, vectm(1663,-2874,-165)); //Hangar building roof
        Spawn(class'PlaceholderItem',,, vectm(1561,-2808,-320)); //Hangar building next to guy who gives up
        Spawn(class'PlaceholderItem',,, vectm(1706,-995,-450)); //Boxes in Hangar
        Spawn(class'PlaceholderItem',,, vectm(1590,-2074,-450)); //Boxes in Hangar near enemies

        class'PlaceholderEnemy'.static.Create(self,vectm(-2237,3225,-192)); //Behind Comm Building
        class'PlaceholderEnemy'.static.Create(self,vectm(4234,3569,-736)); //Roof of power building inside blast doors
        class'PlaceholderEnemy'.static.Create(self,vectm(3744,-1030,-7481)); //Bottom of elevator
        class'PlaceholderEnemy'.static.Create(self,vectm(1425,2600,-260),,'Sitting'); //Comm building couch 1
        class'PlaceholderEnemy'.static.Create(self,vectm(1540,2750,-260),,'Sitting'); //Comm building couch 2
    }

}

function PreFirstEntryMapFixes_Final(bool isVanilla)
{
    local DeusExMover d;
    local Switch1 s;
    local Switch2 s2;
    local SpecialEvent se;
    local DataLinkTrigger dlt;
    local SkillAwardTrigger sat;
    local Dispatcher disp;
    local FlagTrigger ft;
    local OnceOnlyTrigger oot;
    local int i;

    if (isVanilla) {
        AddSwitch( vect(-5112.805176, -2495.639893, -1364), rot(0, 16384, 0), 'blastdoor_final');// just in case the dialog fails
        AddSwitch( vect(-5112.805176, -2530.276123, -1364), rot(0, -16384, 0), 'blastdoor_final');// for backtracking
        AddSwitch( vect(-3745, -1114, -1950), rot(0,0,0), 'Page_Blastdoors' );

        foreach AllActors(class'DeusExMover', d, 'doors_lower') {
            d.bLocked = false;
            d.bHighlight = true;
            d.bFrobbable = true;
        }

        //Fix the Tong Ending skip for real for real
        foreach AllActors(class'Switch1',s){
            if (s.Event=='destroy_generator'){
                s.Tag='destroy_generator_switch';
                class'DXRTriggerEnable'.static.Create(s,'Generator_overload','destroy_generator_switch');
            }
        }

        //but like... for REAL
        foreach AllActors(class'Switch2',s2){
            if (s2.Event=='button_1'){
                s2.Event = 'button_1_once';
                oot = Spawn(class'OnceOnlyTrigger',, 'button_1_once');
                oot.Event = 'button_1';
                s2.Tag='button_1_switch';
                class'DXRTriggerEnable'.static.Create(s2,'Generator_panel','button_1_switch');
            } else if (s2.Event=='button_2'){
                s2.Event = 'button_2_once';
                oot = Spawn(class'OnceOnlyTrigger',, 'button_2_once');
                oot.Event = 'button_2';
                s2.Tag='button_2_switch';
                class'DXRTriggerEnable'.static.Create(s2,'injector2','button_2_switch');
            } else if (s2.Event=='button_3'){
                s2.Event = 'button_3_once';
                oot = Spawn(class'OnceOnlyTrigger',, 'button_3_once');
                oot.Event = 'button_3';
                s2.Tag='button_3_switch';
                class'DXRTriggerEnable'.static.Create(s2,'injector3','button_3_switch');
            }
        }

        // make the Tong ending flag trigger not based on collision
        foreach AllActors(class'FlagTrigger', ft, 'FlagTrigger') {
            if(ft.event != 'Generator_overload') continue;
            ft.Tag = 'Check_Generator_overload';
            ft.SetCollision(false,false,false);
        }

        foreach AllActors(class'Dispatcher', disp) {
            switch(disp.Tag) {
            case 'button_3':
                disp.OutEvents[6] = 'Check_Generator_overload';
                // fallthrough
            case 'button_1':
            case 'button_2':
                if(dxr.flags.moresettings.splits_overlay > 0) {// also make Tong ending a little faster
                    for(i=0; i<ArrayCount(disp.OutDelays); i++) {
                        disp.OutDelays[i] /= 3;
                    }
                }
                break;
            }
        }

        // also make Tong ending a little faster
        if(dxr.flags.moresettings.splits_overlay > 0) {
            foreach AllActors(class'DeusExMover', d) {
                switch(d.Tag) {
                case 'Generator_panel':
                case 'injector2':
                case 'injector3':
                case 'Generator_overload':
                    d.MoveTime /= 2;
                    break;
                }
            }
        }

        //Generator Failsafe buttons should spit out some sort of message if the coolant isn't cut
        //start_buzz1 and start_buzz2 are the tags that get hit when the coolant isn't cut
        se = Spawn(class'SpecialEvent',,'start_buzz1');
        se.Message = "Coolant levels normal - Failsafe cannot be disabled";
        se = Spawn(class'SpecialEvent',,'start_buzz2');
        se.Message = "Coolant levels normal - Failsafe cannot be disabled";

        //Increase the radius of the datalink that opens the sector 4 blast doors
        foreach AllActors(class'DataLinkTrigger',dlt){
            if (dlt.datalinkTag=='DL_Helios_Door2'){
                dlt.SetCollisionSize(900,dlt.CollisionHeight);
            }
        }

        //There's a trigger for this at the top of the elevator, but it has collide actors false.
        //Easier to just spawn a new one near the elevator so you can actually hear it before
        //the game is over.
        dlt = Spawn(class'DataLinkTrigger',,,vectm(-3988,1215,-1542));
        dlt.SetCollisionSize(200,40);
        dlt.datalinkTag='DL_Final_Helios07';

        foreach AllActors(class'SkillAwardTrigger',sat){
            if (sat.awardMessage=="Critical Loctaion Bonus"){
                sat.awardMessage="Critical Location Bonus";
                break;
            }
        }

        Spawn(class'PlaceholderItem',,, vectm(-4185.2,-207.35,-1386)); //Helios storage room
        Spawn(class'PlaceholderItem',,, vectm(-4346.5,-1404.5,-2020)); //Storage room near sector 4 door
        Spawn(class'PlaceholderItem',,, vectm(-5828.7,-412.6,-1514)); //Storage room on stairs to sector 4
        Spawn(class'PlaceholderItem',,, vectm(-4984.8,-3713.8,-1354)); //On top of control panels near cooling pool near entrance
        Spawn(class'PlaceholderItem',,, vectm(-5242.45,-2675.55,-1364)); //Boxes right near Tong at entrance
        Spawn(class'PlaceholderItem',,, vectm(-3110.8,-4931.9,-1555)); //Reactor control room

        Spawn(class'PlaceholderContainer',,, vectm(-4100,2345,-384)); //Arms under Helios
        Spawn(class'PlaceholderContainer',,, vectm(-3892,2397,1147)); //Arms under Helios
        Spawn(class'PlaceholderContainer',,, vectm(-4253.9,771.4,-1564)); //Under staircase near Helios
        Spawn(class'PlaceholderContainer',,, vectm(-3040,-4960,-1607)); //Reactor control room

        class'PlaceholderEnemy'.static.Create(self,vectm(-5113,-989,-1995));
        class'PlaceholderEnemy'.static.Create(self,vectm(-5899,-1112,-1323));
        class'PlaceholderEnemy'.static.Create(self,vectm(-4795,-1596,-1357));

    } else {
        Spawn(class'PlaceholderItem',,, vectm(-4151,-173,-1350)); //Helios storage room
        Spawn(class'PlaceholderItem',,, vectm(-4140,-632,-2000)); //Storage room near sector 4 door
        Spawn(class'PlaceholderItem',,, vectm(-5796,-393,-1480)); //Storage room on stairs to sector 4
        Spawn(class'PlaceholderItem',,, vectm(-5132.3,-3933.3,-1235)); //On top of control panels near cooling pool near entrance
        Spawn(class'PlaceholderItem',,, vectm(-5211,-2640,-1330)); //Boxes right near Tong at entrance
        Spawn(class'PlaceholderItem',,, vectm(-3223,-5792,-1520)); //Reactor control room


        Spawn(class'PlaceholderContainer',,, vectm(-4055,2350,145)); //Arms under Helios
        Spawn(class'PlaceholderContainer',,, vectm(-4055,2350,-360)); //Arms under Helios
        Spawn(class'PlaceholderContainer',,, vectm(-4253.9,771.4,-1564)); //Under staircase near Helios
        Spawn(class'PlaceholderContainer',,, vectm(-3040,-4960,-1730)); //Reactor control room

        class'PlaceholderEnemy'.static.Create(self,vectm(-5113,-989,-1995));
        class'PlaceholderEnemy'.static.Create(self,vectm(-5899,-1112,-1323));
        class'PlaceholderEnemy'.static.Create(self,vectm(-4795,-1596,-1357));
    }
}


function PreFirstEntryMapFixes_Entrance(bool isVanilla)
{
    local DeusExMover d;
    local ComputerSecurity c;
    local #var(prefix)FlagTrigger ft;

    if (isVanilla) {
        foreach AllActors(class'DeusExMover', d, 'DeusExMover') {
            if( d.Name == 'DeusExMover20' ) d.Tag = 'final_door';
        }
        AddSwitch( vect(-867.193420, 244.553101, 17.622702), rot(0, 32768, 0), 'final_door');

        //Button to call elevator to bottom of shaft
        AddSwitch( vect(-1715.487427,493.516571,-1980.708008), rot(0, 32768, 0), 'elevator_floor2');

        foreach AllActors(class'DeusExMover', d, 'doors_lower') {
            d.bLocked = false;
            d.bHighlight = true;
            d.bFrobbable = true;
        }

        //Change break room security computer password so it isn't pre-known
        //This code isn't written anywhere, so you shouldn't have knowledge of it
        foreach AllActors(class'ComputerSecurity',c){
            if (c.UserList[0].UserName=="SECURITY" && c.UserList[0].Password=="SECURITY"){
                c.UserList[0].Password="TinFoilHat";
            }
        }

        //Make the floor hatch near Morgan easier to get into
        //If you make this breakable, the explosion right next
        //to it will destroy it every time.  Maybe it could
        //only become breakable after the explosion happens?
        foreach AllActors(class'DeusExMover', d) {
            if (d.name=='DeusExMover13'){
                d.lockStrength=0.25;
            }
        }

        //After Bob says "I'm sending up the man who did the job", the elevator call button will also open the doors
        ft=Spawn(class'#var(prefix)FlagTrigger');
        ft.SetCollision(False,False,False);
        ft.bSetFlag=False;
        ft.bTrigger=True;
        ft.FlagName='DL_elevator_Played';
        ft.flagValue=True;
        ft.Tag='elevator_floor1';
        ft.Event='elevator_doors';

        Spawn(class'#var(prefix)Liquor40oz',,, vectm(4585,72,-174)); //Beers on the table in the sleeping quarters
        Spawn(class'#var(prefix)Liquor40oz',,, vectm(4611,27,-174));

        Spawn(class'PlaceholderItem',,, vectm(1542.28,-2080,-349)); //Near karkians under Everett
        Spawn(class'PlaceholderItem',,, vectm(3310.14,-2512.35,10.3)); //Boxes right at entrance
        Spawn(class'PlaceholderItem',,, vectm(4022.8,-710.4,-149)); //Boxes near barracks
        Spawn(class'PlaceholderItem',,, vectm(4811,63.7,-173)); //Barracks table
        Spawn(class'PlaceholderItem',,, vectm(3262.9,1492.9,-149)); //Boxes out front of rec room
        Spawn(class'PlaceholderItem',,, vectm(3163.7,2306.2,-169)); //Rec Room ping pong table
        Spawn(class'PlaceholderItem',,, vectm(-404.7,1624.6,-349)); //Near corpse under cherry picker
        Spawn(class'PlaceholderItem',,, vectm(18.6,1220.4,-149)); //Boxes near cherry picker
        Spawn(class'PlaceholderItem',,, vectm(-1712.9,191.25,26)); //In front of ambush elevator

        class'PlaceholderEnemy'.static.Create(self,vectm(4623,210,-176));
        class'PlaceholderEnemy'.static.Create(self,vectm(3314,2276,-176));
        class'PlaceholderEnemy'.static.Create(self,vectm(-190,-694,-180));
        class'PlaceholderEnemy'.static.Create(self,vectm(-444,-171,-16));
        class'PlaceholderEnemy'.static.Create(self,vectm(-394,516,-16));
        class'PlaceholderEnemy'.static.Create(self,vectm(-105,769,-176));
        class'PlaceholderEnemy'.static.Create(self,vectm(-116,432,-176));
        class'PlaceholderEnemy'.static.Create(self,vectm(-63,-147,-176));
        class'PlaceholderEnemy'.static.Create(self,vectm(-578,313,-16));

        class'PlaceholderEnemy'.static.Create(self,vectm(3286,2750,-176),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(3316,2527,-176),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(3297,2079,-176),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(2930,2106,-176),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(2977,2306,-176),,'Sitting');

    } else {
        Spawn(class'PlaceholderItem',,, vectm(1584,-628,-350)); //Near karkians under Everett
        Spawn(class'PlaceholderItem',,, vectm(4078,-2469,10)); //Boxes right at entrance
        Spawn(class'PlaceholderItem',,, vectm(4022.8,-710.4,-149)); //Boxes near barracks
        Spawn(class'PlaceholderItem',,, vectm(3035,-400,-170)); //Barracks table
        Spawn(class'PlaceholderItem',,, vectm(3262.9,1492.9,-149)); //Boxes out front of rec room
        Spawn(class'PlaceholderItem',,, vectm(2685,1960,45)); //Rec Room ping pong table
        Spawn(class'PlaceholderItem',,, vectm(-1517,124,-350)); //Near corpse under cherry picker
        Spawn(class'PlaceholderItem',,, vectm(-844,26,-150)); //Boxes near cherry picker
        Spawn(class'PlaceholderItem',,, vectm(-4240,165,-145)); //In front of ambush elevator

        class'PlaceholderEnemy'.static.Create(self,vectm(2600,650,-175)); //Near sleeping pods
        class'PlaceholderEnemy'.static.Create(self,vectm(3500,3290,45)); //BBall Viewing Room
        class'PlaceholderEnemy'.static.Create(self,vectm(3000,3700,-175)); //Basketball court
        class'PlaceholderEnemy'.static.Create(self,vectm(-1250,-450,-175)); //Area in front of locked door
        class'PlaceholderEnemy'.static.Create(self,vectm(-2050,575,-175)); //Area in front of locked door
        class'PlaceholderEnemy'.static.Create(self,vectm(-2000,-400,-175)); //Area in front of locked door
        class'PlaceholderEnemy'.static.Create(self,vectm(4030,2630,-175)); //Near van door
        class'PlaceholderEnemy'.static.Create(self,vectm(900,600,-175)); //Hallway to locked door room
        class'PlaceholderEnemy'.static.Create(self,vectm(-2500,200,-175)); //Right in front of locked door
        class'PlaceholderEnemy'.static.Create(self,vectm(1780,3200,-135)); //Diving Board
        class'PlaceholderEnemy'.static.Create(self,vectm(4300,65,-175)); //Side tunnel opposite sleeping area
        class'PlaceholderEnemy'.static.Create(self,vectm(2600,-750,-180)); //Showers
        class'PlaceholderEnemy'.static.Create(self,vectm(3400,-800,-180)); //Locker Rooms
        class'PlaceholderEnemy'.static.Create(self,vectm(2900,2100,45)); //Near pingpong table

    }
}


function PreFirstEntryMapFixes_Page(bool isVanilla)
{
    local ComputerSecurity c;
    local Keypad k;
    local Switch1 s;
    local ComputerPersonal comp_per;
    local int i;
    local #var(prefix)DataLinkTrigger dlt;
    local #var(prefix)FlagTrigger ft;
    local #var(prefix)ScriptedPawn sp;
    local vector cloneCubeLoc[4];
    local string cloneCubeText[4];
    local AmbientSound as;
    local DXRAmbientSoundTrigger ast;

    if (isVanilla) {
        // fix in-fighting
        foreach AllActors(class'#var(prefix)ScriptedPawn', sp) {
            if(#var(prefix)MJ12Commando(sp) != None && sp.Alliance=='') {
                sp.SetAlliance('MJ12');
            }
            if(sp.Alliance=='') {
                continue;// probably the security bots you can release
            }
            sp.ChangeAlly('MJ12', 1, true);
            sp.ChangeAlly('Karkian', 1, true);
            sp.ChangeAlly('Gray', 1, true);
            sp.ChangeAlly('Greasel', 1, true);
            sp.ChangeAlly('Subject1', 1, true);
            sp.ChangeAlly('bots', 1, true);
        }

        foreach AllActors(class'ComputerSecurity', c) {
            if( c.UserList[0].userName != "graytest" || c.UserList[0].Password != "Lab12" ) continue;
            c.UserList[0].userName = "Lab 12";
            c.UserList[0].Password = "graytest";
        }
        foreach AllActors(class'Keypad', k) {
            if( k.validCode == "9248" )
                k.validCode = "2242";
            else if (k.validCode == "6188")
                k.validCode = "6765";
        }
        foreach AllActors(class'Switch1',s){
            if (s.Name == 'Switch21'){
                s.Event = 'door_page_overlook';
            } else if (s.Event=='kill_page'){
                //Fix the Illuminati ending skip
                s.Tag='kill_page_switch';
                class'DXRTriggerEnable'.static.Create(s,'Page_button','kill_page_switch');
            }
        }

        // fix the Helios ending skip
        foreach AllActors(class'ComputerPersonal', comp_per) {
            if(comp_per.Name == 'ComputerPersonal0') {
                comp_per.Tag = 'router_computer';
                class'DXRTriggerEnable'.static.Create(comp_per, 'router_door', 'router_computer');
                break;
            }
        }

        if(!dxr.flags.IsZeroRando()) {
            //Rather than duplicating the existing cubes, add new clone text so there are more possibilities
            cloneCubeLoc[0]=vectm(6197.620117,-8455.201172,-5117.649902); //Weird little window near broken door (on Page side)
            cloneCubeLoc[1]=vectm(5663.339355,-7955.502441,-5557.624512); //On boxes outside middle level UC door
            cloneCubeLoc[2]=vectm(6333.112305,-7241.149414,-5557.636719); //On boxes right near middle level blue fusion reactor
            cloneCubeLoc[3]=vectm(7687.463867,-8845.201172,-5940.627441); //On control panel that has flame button in coolant area
            cloneCubeText[0]="SUBJECT MJID-5493OP2702|nINCEPT DATE: 3/19/65|nASSIGNED BIRTH DATE: 7/20/41|nASSIGNED BIRTH NAME: Stan Carnegie|nBASE GENETIC SAMPLE: SIMONSWALTON32A|nPROFILE: AABCAAB|nVITALS: 45/80/0.89/33/1.2|n|n             [[[[[PENDING]]]]]";
            cloneCubeText[1]="SUBJECT MJID-2938BU3209|nINCEPT DATE: 7/30/66|nASSIGNED BIRTH DATE: 9/07/40|nASSIGNED BIRTH NAME: Greg Pequod|nBASE GENETIC SAMPLE: |nPAGEBOB86G|nPROFILE: BAABACA|nVITALS: 51/72/1.02/20/2.1|n|n             [[[[[PENDING]]]]]";
            cloneCubeText[2]="SUBJECT MJID-3209FG2938|nINCEPT DATE: 7/30/66|nASSIGNED BIRTH DATE: 9/07/40|nASSIGNED BIRTH NAME: Jacob Queequeg|nBASE GENETIC SAMPLE: STRONGHOWARD52L|nPROFILE: CAAGATA|nVITALS: 52/73/1.01/20/2.2|n|n             [[[[[PENDING]]]]]";
            cloneCubeText[3]="SUBJECT MJID-3209FG2938|nINCEPT DATE: 6/17/54|nASSIGNED BIRTH DATE: 11/30/35|nASSIGNED BIRTH NAME: Jason Frudnick|nBASE GENETIC SAMPLE: GARDNERKANE88J|nPROFILE: BABTAGA|nVITALS: 51/81/1.13/20/2.0|n|n             [[[[[PENDING]]]]]";
            for(i=0;i<4;i++){
                SpawnDatacubePlaintext(cloneCubeLoc[i],rotm(0,0,0,0),cloneCubeText[i],"CloneCube"$string(i+1));
            }
        }

        if(!dxr.flags.IsZeroRando()) {
            //Add a switch to manually trigger the infolink that gives you the Helios computer password
            AddSwitch( vect(5635.609375,-5352.036133,-5240.890625), rot(0, 0, 0), 'PasswordCallReset', "Forgot your Password?");
        }

        ft=Spawn(class'#var(prefix)FlagTrigger');
        ft.bSetFlag=True;  //Setting both of these means it will set the flag
        ft.bTrigger=True;  //and then trigger the event after the flag is set
        ft.flagName='DL_Final_Helios06_Played';
        ft.flagValue=False;
        ft.Event='PasswordCall';
        ft.Tag='PasswordCallReset';
        ft.SetCollision(false,false,false);

        //Make sure the datalink trigger has a unique tag to get hit
        foreach AllActors(class'#var(prefix)DataLinkTrigger',dlt){
            if (dlt.datalinkTag=='DL_Final_Helios06'){
                dlt.Tag='PasswordCall';
                break;
            }
        }

        foreach AllActors(class'AmbientSound', as) {
            if (as.AmbientSound == Sound'Ambient.Ambient.GeigerLoop') {
                ast = class'DXRAmbientSoundTrigger'.static.ReplaceAmbientSound(as, 'Gray_rad');
                ast.CopyValsToUntriggered(ast);
                ast.UntriggeredSoundVolume /= 3;
                break;
            }
        }
    }
}

function PreFirstEntryMapFixes()
{
    local bool isVanilla;

    isVanilla = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL)
    {
    case "15_AREA51_BUNKER":
        PreFirstEntryMapFixes_Bunker(isVanilla);
        break;

    case "15_AREA51_FINAL":
        PreFirstEntryMapFixes_Final(isVanilla);
        break;

    case "15_AREA51_ENTRANCE":
        PreFirstEntryMapFixes_Entrance(isVanilla);
        break;

    case "15_AREA51_PAGE":
        PreFirstEntryMapFixes_Page(isVanilla);
        break;
    }

}

function AnyEntryMapFixes()
{
    local Gray g;
    local ElectricityEmitter ee;
    local #var(DeusExPrefix)Mover d;
    local bool RevisionMaps;
    local bool VanillaMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());
    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    if(dxr.localURL != "15_AREA51_BUNKER") {
        player().GoalCompleted('EnterBlastDoors');
        player().GoalCompleted('PenetrateBunker');
    }

    switch(dxr.localURL)
    {
    case "15_AREA51_FINAL":
        SetTimer(1, true);// fix ReactorReady flag being set by infolinks
        if (VanillaMaps){
            foreach AllActors(class'Gray', g) {
                if( g.Tag == 'reactorgray1' ) g.BindName = "ReactorGray1";
                else if( g.Tag == 'reactorgray2' ) g.BindName = "ReactorGray2";
            }
        }
        break;

    case "15_AREA51_PAGE":
        // get the password from Helios sooner
        FixConversationAddNote(GetConversation('DL_Final_Helios06'), "Use the login");
        // timer to count the blue fusion reactors
        SetTimer(1, True);
        if(#defined(vanilla)) {
            dxr.flagbase.SetBool('MS_DL_Played', True,, 16);// don't let vanilla run checks for the BFR, we're gonna do it in our own timer
        }

        foreach AllActors(class'ElectricityEmitter', ee, 'emitter_relay_room') {
            if(ee.DamageAmount >= 30) {// these are OP
                ee.DamageAmount /= 2;
                ee.damageTime *= 2.0;
                ee.randomAngle /= 2.0;
            }
        }
        break;
    }
}


function PostFirstEntryMapFixes()
{
    local #var(prefix)Keypad k;

    switch(dxr.localURL) {
    case "15_area51_final":
        if(dxr.flags.IsSpeedrunMode() && FeatureFlag(3,3,0, "Area51EndingBalancePass2")) {
            foreach AllActors(class'#var(prefix)Keypad', k) {
                if(k.Event == 'blastdoor_upper') {
                    k.bHackable = false;
                    break;
                }
            }
        }
        break;
    }
}

function TimerMapFixes()
{
    switch(dxr.localURL)
    {
    case "15_AREA51_FINAL":
        if(dxr.flagbase.GetBool('ReactorSwitch1') && dxr.flagbase.GetBool('ReactorSwitch2')) {
            dxr.flagbase.SetBool('ReactorReady', true);
        }
        break;
    case "15_AREA51_PAGE":
        Area51_CountBlueFusion();
        break;
    }
}

function Area51_CountBlueFusion()
{
    local int remaining;
    local int required;
    local FlagBase f;

    f = dxr.flagbase;

    required = 4;
    //SetSeed("Area51_CountBlueFusion");
    //if(chance_single(50) && #defined(vanilla) && dxr.flags.settings.goals > 0) required = 3;
    remaining = required;

    if (f.GetBool('Node1_Frobbed'))
        remaining--;
    if (f.GetBool('Node2_Frobbed'))
        remaining--;
    if (f.GetBool('Node3_Frobbed'))
        remaining--;
    if (f.GetBool('Node4_Frobbed'))
        remaining--;

    UpdateReactorGoal(remaining, required);
    if (remaining != storedReactorCount) {
        // A fusion reactor has been shut down!
        storedReactorCount = remaining;

        switch(Max(remaining, 0)) {// don't do negative numbers
        case 0:
            player().ClientMessage("All Blue Fusion reactors shut down!");
            SetTimer(0, False);  // Disable the timer now that all fusion reactors are shut down
            break;
        case 1:
            player().ClientMessage("1 Blue Fusion reactor remaining");
            break;
        default:
            player().ClientMessage(remaining$" Blue Fusion reactors remaining");
            break;
        }
    }

    if(#defined(vanilla) && !f.GetBool('DL_Blue4_Played') && remaining < required) {
        // play datalinks when devices are frobbed
        if (remaining == 3 && !f.GetBool('DL_Blue1_Played')) {
            player().StartDataLinkTransmission("DL_Blue1");
        }
        else if (remaining == 2 && !f.GetBool('DL_Blue2_Played')) {
            player().StartDataLinkTransmission("DL_Blue2");
        }
        else if (remaining == 1 && !f.GetBool('DL_Blue3_Played')) {
            player().StartDataLinkTransmission("DL_Blue3");
        }
        else if (remaining <= 0 && !f.GetBool('DL_Blue4_Played'))
        {
            player().StartDataLinkTransmission("DL_Blue4");
        }
    }
}

function bool UpdateReactorGoal(int count, int required)
{
    local string goalText;
    local DeusExGoal goal;
    local int bracketPos;
    goal = player().FindGoal('OverloadForceField');

    if (goal!=None) {
        count = Max(count, 0);// don't do negative numbers
        goalText = goal.text;
        bracketPos = InStr(goalText,"[");

        if (bracketPos>0) { //If the extra text is already there, strip it.
            goalText = Mid(goalText,0,bracketPos-1);
        }

        goalText = goalText$" ["$count$" remaining]";

        if(required == 2) goalText = ReplaceText(goalText, "the four blue-fusion", "the two blue-fusion");
        if(required == 3) goalText = ReplaceText(goalText, "the four blue-fusion", "the three blue-fusion");

        goal.SetText(goalText);
        return true;
    }
    return false;
}

defaultproperties
{
    storedReactorCount=-1
}
