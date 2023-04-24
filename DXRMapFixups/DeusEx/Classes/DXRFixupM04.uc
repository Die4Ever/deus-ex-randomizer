class DXRFixupM04 extends DXRFixup;

var int old_pawns;// used for NYC_04_CheckPaulRaid()

function PreTravelMapFixes()
{
    switch(dxr.localURL) {
    case "04_NYC_HOTEL":
        if(#defined(vanilla))
            NYC_04_LeaveHotel();
        break;
    }
}

function PreFirstEntryMapFixes()
{
    local FlagTrigger ft;
    local OrdersTrigger ot;
    local SkillAwardTrigger st;
    local #var(prefix)BoxSmall b;
    local #var(prefix)HackableDevices hd;
    local #var(prefix)UNATCOTroop lloyd;
    local #var(prefix)AutoTurret turret;
    local #var(prefix)ControlPanel panel;
    local #var(prefix)LaserTrigger laser;
    local #var(prefix)Containers c;

    switch (dxr.localURL)
    {
#ifdef vanilla
    case "04_NYC_HOTEL":
        foreach AllActors(class'OrdersTrigger', ot, 'PaulSafe') {
            if( ot.Orders == 'Leaving' )
                ot.Orders = 'Seeking';
        }
        foreach AllActors(class'FlagTrigger', ft) {
            if( ft.Event == 'PaulOutaHere' )
                ft.Destroy();
        }
        foreach AllActors(class'SkillAwardTrigger', st) {
            if( st.Tag == 'StayedWithPaul' ) {
                st.skillPointsAdded = 100;
                st.awardMessage = "Stayed with Paul";
                st.Destroy();// HACK: this trigger is buggy for some reason, just forget about it for now
            }
            else if( st.Tag == 'PaulOutaHere' ) {
                st.skillPointsAdded = 500;
                st.awardMessage = "Saved Paul";
            }
        }
        break;
#endif

    case "04_NYC_NSFHQ":
        foreach AllActors(class'#var(prefix)AutoTurret', turret) {
            turret.Event = '';
            turret.Destroy();
        }
        foreach AllActors(class'#var(prefix)ControlPanel', panel) {
            panel.Event = '';
            panel.Destroy();
        }
        foreach AllActors(class'#var(prefix)LaserTrigger', laser) {
            laser.Event = '';
            laser.Destroy();
        }
        foreach AllActors(class'#var(prefix)Containers', c) {
            if(#var(prefix)BoxLarge(c) != None || #var(prefix)BoxSmall(c) != None
                || #var(prefix)CrateUnbreakableLarge(c) != None || #var(prefix)CrateUnbreakableMed(c) != None)
            {
                c.Event = '';
                c.Destroy();
            }
        }
        foreach AllActors(class'#var(prefix)HackableDevices', hd) {
            hd.hackStrength /= 3.0;
        }
        break;

    case "04_NYC_UNATCOISLAND":
        if(!dxr.flags.IsReducedRando()) {
            foreach AllActors(class'#var(prefix)UNATCOTroop', lloyd) {
                if(lloyd.BindName != "PrivateLloyd") continue;
                lloyd.FamiliarName = "Sergeant Lloyd";
                lloyd.UnfamiliarName = "Sergeant Lloyd";
                lloyd.bImportant = true;
            }
        }
        break;
    case "04_NYC_UNATCOHQ":
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

function PostFirstEntryMapFixes()
{
    local DeusExMover m;

    FixUNATCORetinalScanner();

    switch(dxr.localURL) {
    case "04_NYC_NSFHQ":
        // no cheating!
        foreach AllActors(class'DeusExMover', m, 'SignalComputerDoorOpen') {
            m.bBreakable = false;
            m.bPickable = false;
        }
        break;
    }
}

function AnyEntryMapFixes()
{
    local FordSchick ford;
    local #var(prefix)AnnaNavarre anna;

    DeleteConversationFlag(GetConversation('AnnaBadMama'), 'TalkedToPaulAfterMessage_Played', true);
    if(dxr.flagbase.GetBool('NSFSignalSent')) {
        foreach AllActors(class'#var(prefix)AnnaNavarre', anna) {
            anna.EnterWorld();
        }
    }

    switch (dxr.localURL)
    {
#ifdef vanilla
    case "04_NYC_HOTEL":
        NYC_04_CheckPaulUndead();
        if( ! dxr.flagbase.GetBool('PaulDenton_Dead') )
            SetTimer(1, True);
        if(dxr.flagbase.GetBool('NSFSignalSent')) {
            dxr.flagbase.SetBool('PaulInjured_Played', true,, 5);
        }

        // conversations are transient, so they need to be fixed in AnyEntry
        FixConversationFlag(GetConversation('PaulAfterAttack'), 'M04RaidDone', true, 'PaulLeftHotel', true);
        FixConversationFlag(GetConversation('PaulDuringAttack'), 'M04RaidDone', false, 'PaulLeftHotel', false);
        break;
#endif

#ifdef vanillamaps
    case "04_NYC_SMUG":
        if( dxr.flagbase.GetBool('FordSchickRescued') )
        {
            foreach AllActors(class'FordSchick', ford)
                ford.EnterWorld();
        }
        break;
#endif
    }
}

function TimerMapFixes()
{
    switch(dxr.localURL)
    {
    case "04_NYC_HOTEL":
        if(#defined(vanilla))
            NYC_04_CheckPaulRaid();
        break;
    }
}

// if you bail on Paul but then have a change of heart and re-enter to come back and save him
function NYC_04_CheckPaulUndead()
{
    local PaulDenton paul;
    local int count;

    if( ! dxr.flagbase.GetBool('PaulDenton_Dead')) return;

    foreach AllActors(class'PaulDenton', paul) {
        if( paul.Health > 0 ) {
            dxr.flagbase.SetBool('PaulDenton_Dead', false,, -999);
            return;
        }
    }
}

function NYC_04_CheckPaulRaid()
{
    local PaulDenton paul;
    local ScriptedPawn p;
    local int count, dead, pawns;

    if( ! dxr.flagbase.GetBool('M04RaidTeleportDone') ) return;

    foreach AllActors(class'PaulDenton', paul) {
        // fix a softlock if you jump while approaching Paul
        if( ! dxr.flagbase.GetBool('TalkedToPaulAfterMessage_Played') ) {
            player().StartConversationByName('TalkedToPaulAfterMessage', paul, False, False);
        }

        count++;
        if( paul.Health <= 0 ) dead++;
        if( ! paul.bInvincible ) continue;

        paul.bInvincible = false;
        SetPawnHealth(paul, 400);
        paul.ChangeAlly('Player', 1, true);
    }

    foreach AllActors(class'ScriptedPawn', p) {
        if( PaulDenton(p) != None ) continue;
        if( IsCritter(p) ) continue;
        if( p.bHidden ) continue;
        if( p.GetAllianceType('Player') != ALLIANCE_Hostile ) continue;
        p.bStasis = false;
        pawns++;
    }

    if( dead > 0 || dxr.flagbase.GetBool('PaulDenton_Dead') ) {
        player().ClientMessage("RIP Paul :(",, true);
        dxr.flagbase.SetBool('PaulDenton_Dead', true,, 999);
        SetTimer(0, False);
    }
    else if( dead == 0 && (count == 0 || pawns == 0) ) {
        NYC_04_MarkPaulSafe();
        SetTimer(0, False);
    }
    else if( pawns == 1 && pawns != old_pawns )
        player().ClientMessage(pawns$" enemy remaining");
    else if( pawns <3 && pawns != old_pawns )
        player().ClientMessage(pawns$" enemies remaining");
    old_pawns = pawns;
}

function NYC_04_MarkPaulSafe()
{
    local PaulDenton paul;
    local FlagTrigger t;
    local SkillAwardTrigger st;
    local int health;
    if( dxr.flagbase.GetBool('PaulLeftHotel') ) return;

    dxr.flagbase.SetBool('PaulLeftHotel', true,, 999);

    foreach AllActors(class'PaulDenton', paul) {
        paul.GenerateTotalHealth();
        health = paul.Health * 100 / 400;// as a percentage
        if(health == 0) health = 1;
        paul.SetOrders('Leaving', 'PaulLeaves', True);
    }

    if(health > 0) {
        player().ClientMessage("Paul had " $ health $ "% health remaining.");
    }

    foreach AllActors(class'FlagTrigger', t) {
        switch(t.tag) {
            case 'KillPaul':
            case 'BailedOutWindow':
                t.Destroy();
                break;
        }
        if( t.Event == 'BailedOutWindow' )
            t.Destroy();
    }

    foreach AllActors(class'SkillAwardTrigger', st) {
        switch(st.Tag) {
            case 'StayedWithPaul':
            case 'PaulOutaHere':
                st.Touch(player());
        }
    }
    class'DXREvents'.static.SavedPaul(dxr, player(), health);
}

function NYC_04_LeaveHotel()
{
    local FlagTrigger t;
    // TODO: why touch the trigger when we can just change the flag directly?
    foreach AllActors(class'FlagTrigger', t) {
        if( t.Event == 'BailedOutWindow' )
        {
            t.Touch(player());
        }
    }
}
