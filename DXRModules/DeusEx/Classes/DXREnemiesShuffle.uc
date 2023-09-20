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
        item = GiveExistingItem(a, newa[i]);
        if(Robot(a) != None)
            ThrowItem(item, 0.1);
    }
    for(i=0; i<numb; i++) {
        item = GiveExistingItem(b, newb[i]);
        if(Robot(b) != None)
            ThrowItem(item, 0.1);
    }
}


function SwapOrders(ScriptedPawn a, ScriptedPawn b)
{
    SwapNames(a.Orders, b.Orders);
    SwapNames(a.OrderTag, b.OrderTag);
}

function bool ShouldSwap(ScriptedPawn a, ScriptedPawn b) {
    // always ok to swap with a placeholder enemy
    if(PlaceholderEnemy(a) != None || PlaceholderEnemy(b) != None) return true;
    // otherwise check alliance
    return a.GetAllianceType( b.Alliance ) != ALLIANCE_Hostile;
}

function SwapScriptedPawns(int percent, bool enemies)
{
    local ScriptedPawn temp[512];
    local ScriptedPawn a;
    local name exceptTag, exceptAlliance, keepTagName;
    local bool keepTags;
    local int num, i, slot;

    num=0;
    switch(dxr.localURL) {
    case "06_HONGKONG_MJ12LAB":
        if(enemies)
            SwapScriptedPawns(percent, false);
        else
            exceptAlliance = 'Researcher';
        break;

    case "08_NYC_STREET":
        keepTags = true;
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
        if( IsCritter(a) ) continue;
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
        if( !keepTags && temp[i].Tag != keepTagName && temp[slot].Tag != keepTagName )
            SwapNames(temp[i].Tag, temp[slot].Tag);
        SwapNames(temp[i].Event, temp[slot].Event);
        SwapNames(temp[i].AlarmTag, temp[slot].AlarmTag);
        SwapNames(temp[i].SharedAlarmTag, temp[slot].SharedAlarmTag);
        SwapNames(temp[i].HomeTag, temp[slot].HomeTag);
        SwapVector(temp[i].HomeLoc, temp[slot].HomeLoc);
        SwapVector(temp[i].HomeRot, temp[slot].HomeRot);
        SwapProperty(temp[i], temp[slot], "HomeExtent");
        SwapProperty(temp[i], temp[slot], "bUseHome");
        SwapProperty(temp[i], temp[slot], "RaiseAlarm");

        SwapOrders(temp[i], temp[slot]);
    }

    for(i=0; i<num; i++) {
        a = temp[i];
        if(#var(prefix)MJ12Commando(a) != None && a.Orders=='Sitting') {
            a.Orders='Standing';
            a.OrderTag='';
        }
        if(a.Orders != 'DynamicPatrolling')// we pick these up later in DXREnemiesPatrols
            ResetOrders(a);
    }
}
