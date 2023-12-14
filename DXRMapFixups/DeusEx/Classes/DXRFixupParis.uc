class DXRFixupParis extends DXRFixup;

function PreFirstEntryMapFixes()
{
    local GuntherHermann g;
    local DeusExMover m;
    local Trigger t;
    local Dispatcher d;
    local ScriptedPawn sp;
    local Conversation c;
    local #var(prefix)DataLinkTrigger dlt;
    local #var(prefix)JaimeReyes j;
    local ZoneInfo zi;
    local #var(prefix)DamageTrigger dt;
    local #var(prefix)ComputerSecurity cs;
    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    // shut up, Tong! (reduced rando is not as focused on replays compared to normal rando)
    if(!dxr.flags.IsReducedRando()) {
        foreach AllActors(class'#var(prefix)DataLinkTrigger', dlt) {
            switch(dlt.dataLinkTag) {
            case 'DL_paris_10_shaft':
            case 'DL_paris_10_radiation':
            case 'DL_paris_10_catacombs':
            case 'DL_tunnels_oldplace':
            case 'DL_tunnels_oldplace2':
            case 'DL_tunnels_oldplace3':
            case 'DL_metroentrance':
            case 'DL_club_entry':
            case 'DL_apartments':
            case 'DL_hotel':
            case 'DL_bakery':
            case 'DL_entered_graveyard':
            case 'DL_restaurant':
                dlt.Event='';
                dlt.Destroy();
            }
        }
    }

    switch(dxr.localURL)
    {
    case "10_PARIS_CATACOMBS":
        FixConversationAddNote(GetConversation('MeetAimee'), "Stupid, stupid, stupid password.");
        foreach AllActors(class'ZoneInfo',zi){
            if (zi.DamageType=='Radiation'){
                zi.DamagePerSec=Clamp(7/player().CombatDifficulty, 1, 7);
            }
        }
        break;

    case "10_PARIS_CATACOMBS_TUNNELS":
        if (VanillaMaps){
            foreach AllActors(class'Trigger', t)
                if( t.Event == 'MJ12CommandoSpecial' )
                    t.Touch(player());// make this guy patrol instead of t-pose

            AddSwitch( vect(897.238892, -120.852928, -9.965580), rot(0,0,0), 'catacombs_blastdoor02' );
            AddSwitch( vect(-2190.893799, 1203.199097, -6.663990), rot(0,0,0), 'catacombs_blastdoorB' );

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

    switch(dxr.localURL)
    {
    case "10_PARIS_CATACOMBS":
        if(!dxr.flags.IsReducedRando()) {
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
    case "11_PARIS_EVERETT":
        foreach AllActors(class'TobyAtanwe', toby) {
            toby.bInvincible = false;
        }
        break;
    }
}

function PostFirstEntryMapFixes()
{
    switch(dxr.localURL) {
    case "11_PARIS_CATHEDRAL":
        AddBox(class'#var(prefix)CrateUnbreakableSmall', vectm(-3570.950684, 2238.034668, -783.901367));// right at the start
        break;
    }
}
