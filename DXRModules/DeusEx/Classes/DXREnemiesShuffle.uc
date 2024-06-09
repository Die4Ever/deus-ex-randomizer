class DXREnemiesShuffle extends DXREnemiesPatrols abstract;

function SwapItems(Pawn a, Pawn b)
{
    local Inventory item, newa[64], newb[64];
    local int i, numa, numb;

    for(item=a.Inventory; item != None; item=item.Inventory) {
        if(Weapon(item) == None && Ammo(item) == None) {
            if(item.Owner == a)
                a.DeleteInventory(item);
            newb[numb++] = item;
        }
    }
    for(item=b.Inventory; item != None; item=item.Inventory) {
        if(Weapon(item) == None && Ammo(item) == None) {
            if(item.Owner == b)
                b.DeleteInventory(item);
            newa[numa++] = item;
        }
    }

    for(i=0; i<numa; i++) {
        GiveExistingItem(a, newa[i]);
    }
    for(i=0; i<numb; i++) {
        GiveExistingItem(b, newb[i]);
    }
}

function MergeAlliances(ScriptedPawn a, ScriptedPawn b)
{
    local int i;

    b.ChangeAlly(a.Alliance, 1, true);
    b.ChangeAlly(b.Alliance, 1, true);
    a.ChangeAlly(a.Alliance, 1, true);
    a.ChangeAlly(b.Alliance, 1, true);
    for(i=0; i<ArrayCount(a.InitialAlliances); i++ )
    {
        if(a.InitialAlliances[i].AllianceName != '' && a.InitialAlliances[i].AllianceLevel > 0) {
            b.ChangeAlly(a.InitialAlliances[i].AllianceName, a.InitialAlliances[i].AllianceLevel, a.InitialAlliances[i].bPermanent);
        }
        if(b.InitialAlliances[i].AllianceName != '' && b.InitialAlliances[i].AllianceLevel > 0) {
            a.ChangeAlly(b.InitialAlliances[i].AllianceName, b.InitialAlliances[i].AllianceLevel, b.InitialAlliances[i].bPermanent);
        }
    }
}

function SwapOrders(ScriptedPawn a, ScriptedPawn b)
{
    SwapNames(a.Orders, b.Orders);
    SwapNames(a.OrderTag, b.OrderTag);
}

function bool ShouldSwap(ScriptedPawn a, ScriptedPawn b) {
    // always ok to swap with a placeholder enemy
    if((PlaceholderEnemy(a) != None && a.Alliance=='') || (PlaceholderEnemy(b) != None && b.Alliance=='')) return true;
    // otherwise check alliance
    return a.GetAllianceType( b.Alliance ) == ALLIANCE_Friendly && b.GetAllianceType( a.Alliance ) == ALLIANCE_Friendly;
}

function bool CanSit(ScriptedPawn sp)
{
    if (#var(prefix)MJ12Commando(sp) != None) return False;
    if (#var(prefix)SpiderBot2(sp) != None) return True; //Small spiderbots are very funny in chairs
    if (#var(prefix)Robot(sp) != None) return False; //Normal robots are lame in chairs
    if (#var(prefix)ChildMale(sp) != None) return False; //Kids don't have sitting animations
    if (#var(prefix)ChildMale2(sp) != None) return False; //(They probably aren't getting shuffled, but might as well note it)
    //Animals don't have any special sitting animations, but are very funny also
    return True;
}

function SwapScriptedPawns(int percent, bool enemies)
{
    local ScriptedPawn temp[512];
    local ScriptedPawn a;
    local name exceptTag, exceptAlliance, keepTagName;
    local bool keepTags;
    local int num, i, slot;
    local Inventory item, nextItem;

    num=0;
    keepTagName = 'SwapAll';// don't match any real tags so that all tags get swapped by default, this used to be the empty name ''
    switch(dxr.localURL) {
    case "04_NYC_NSFHQ":
        if(enemies)
            SwapScriptedPawns(percent, false);
        break;

    case "06_HONGKONG_MJ12LAB":
        if(enemies)
            SwapScriptedPawns(percent, false);
        else
            exceptAlliance = 'Researcher';
        break;

    case "08_NYC_STREET":
        keepTags = true;// fix M08 street unatco troops spawning early https://github.com/Die4Ever/deus-ex-randomizer/issues/522
        break;

    case "12_VANDENBERG_CMD":
        keepTagName = 'enemy_bot';// 12_VANDENBERG_CMD fix, see Mission12.uc https://discord.com/channels/823629359931195394/823629360929046530/974454774034497567
        break;

    case "14_OCEANLAB_SILO":
        exceptTag = 'Doberman';
        break;
    }

    SetSeed( "SwapScriptedPawns" );
    foreach AllActors(class'ScriptedPawn', a )
    {
        if( a.bHidden || a.bStatic ) continue;
        if( a.bImportant || a.bIsSecretGoal ) continue;
        if( !IsRelevantPawn(a.class) ) continue;
        if( IsInitialEnemy(a) != enemies ) continue;
        if( !chance_single(percent) ) continue;
        if( a.Region.Zone.bWaterZone || a.Region.Zone.bPainZone ) continue;
        if( exceptTag != '' && a.Tag == exceptTag ) continue;
        if( exceptAlliance != '' && a.Alliance == exceptAlliance ) continue;
        if( #var(prefix)Robot(a) != None && a.Orders == 'Idle' ) continue;
        if( class'DXRMissions'.static.IsCloseToRandomStart(dxr, a.Location) ) continue;
#ifdef gmdx
        if( SpiderBot2(a) != None && SpiderBot2(a).bUpsideDown ) continue;
#endif

        temp[num++] = a;
    }

    l("SwapScriptedPawns num: "$num);
    for(i=0; i<num; i++) {
        slot=rng(num);
        if(slot==i) {// we're in the list too
            l("not swapping "$ActorToString(temp[i]));
            continue;
        }

        if( ! ShouldSwap(temp[i], temp[slot]) ) {
            continue;
        }

        if( ! Swap(temp[i], temp[slot], true) ) {
            l("SwapScriptedPawns failed swapping "$i@ActorToString(temp[i])$" with "$slot@ActorToString(temp[slot]));
            continue;
        }

        l("SwapScriptedPawns swapping "$i@ActorToString(temp[i])$" with "$slot@ActorToString(temp[slot]));

        // TODO: swap non-weapons/ammo inventory, only need to swap nanokeys?
        SwapItems(temp[i], temp[slot]);
        if( !keepTags &&
            temp[i].Tag != keepTagName && temp[slot].Tag != keepTagName &&
            temp[i].Tag != '' && temp[slot].Tag != ''){

            SwapNames(temp[i].Tag, temp[slot].Tag);
        }
        SwapNames(temp[i].Event, temp[slot].Event);
        SwapNames(temp[i].AlarmTag, temp[slot].AlarmTag);
        SwapNames(temp[i].SharedAlarmTag, temp[slot].SharedAlarmTag);
        SwapNames(temp[i].HomeTag, temp[slot].HomeTag);
        SwapVector(temp[i].HomeLoc, temp[slot].HomeLoc);
        SwapVector(temp[i].HomeRot, temp[slot].HomeRot);
        SwapProperty(temp[i], temp[slot], "HomeExtent");
        SwapProperty(temp[i], temp[slot], "bUseHome");
        SwapProperty(temp[i], temp[slot], "RaiseAlarm");
        MergeAlliances(temp[i], temp[slot]);

        SwapOrders(temp[i], temp[slot]);
    }

    for(i=0; i<num; i++) {
        a = temp[i];
        if(a.Orders=='Sitting' && !CanSit(a)) {
            a.Orders='Standing';
            a.OrderTag='';
        }
        if(a.Orders != 'DynamicPatrolling')// we pick these up later in DXREnemiesPatrols
            ResetOrders(a);
        if(#var(prefix)Robot(a) != None || PlaceholderEnemy(a) != None) {
            for(item=a.Inventory; item != None; item=nextItem) {
                nextItem = item.Inventory;
                if(#var(prefix)NanoKey(item) != None) {
                    ThrowItem(item, 0.1);
                }
            }
        }
    }
}
