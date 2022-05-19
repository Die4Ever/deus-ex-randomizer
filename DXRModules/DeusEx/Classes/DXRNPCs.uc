class DXRNPCs extends DXRActorsBase;

struct ItemPurchase
{
    var class<Inventory> item;
    var int price;
};

function AnyEntry()
{
    Super.AnyEntry();

    if( dxr.dxInfo.MissionNumber > 0 && dxr.dxInfo.MissionNumber < 98 ) {
        CreateRandomMerchant();
        //LogAll('MeetKaplan');
    }
}

function LogAll(name conName)
{
    local ConItem item;
    local Conversation c;
    local ConEvent e;
    local ConEventSpeech s;
    local ConversationList list;
    local ConversationMissionList mlist;

    foreach AllObjects(class'ConversationList', list) {
        l("ConversationList: "$list$", missionDescription: "$list.missionDescription$", missionNumber: "$list.missionNumber$", conversations: "$list.conversations );
    }

    foreach AllObjects(class'ConversationMissionList', mlist) {
        l("ConversationMissionList: "$mlist$", missions: "$mlist.missions);
    }

    foreach AllObjects(class'Conversation', c) {
        if( c.conName == conName ) break;
    }

    if( c == None ) return;

    foreach AllObjects(class'ConItem', item) {
        if( item.conObject != c ) continue;
        l(item$": conObject: "$item.conObject$", next: "$item.next);
    }

    l(c);
    for(e=c.eventList; e!=None; e=e.nextEvent) {
        l(e$": eventType: "$e.eventType$", label: "$e.label);
        s = ConEventSpeech(e);
        if( s == None ) continue;
        l("    speaker: "$s.speaker$", speakerName: "$s.speakerName$", speakingTo: "$s.speakingTo$", speakingToName: "$s.speakingToName$", conSpeech: "$s.conSpeech$", bContinued: "$s.bContinued$", speechFont: "$s.speechFont);
        l(s.conSpeech.speech);
    }
}

function RandomizeItems(out ItemPurchase items[8], optional int forced)
{
    local float r;
    local int i, k, num;
    local class<Inventory> iclass;
    local class<Inventory> classes[16];

    i=0;
    classes[i++] = class'#var prefix Medkit';
    classes[i++] = class'#var prefix Lockpick';
    classes[i++] = class'#var prefix Multitool';
    classes[i++] = class'#var prefix BioelectricCell';
    classes[i++] = class'#var prefix BallisticArmor';
    classes[i++] = class'#var prefix Ammo10mm';
    classes[i++] = class'#var prefix AmmoBattery';
    classes[i++] = class'#var prefix AmmoDartPoison';
    classes[i++] = class'#var prefix AmmoRocket';
    classes[i++] = class'#var prefix WeaponShuriken';
    classes[i++] = class'#var prefix HazMatSuit';
    classes[i++] = class'#var prefix Rebreather';
    num=i;

    // randomize cost for forced items
    for(i=0; i<forced; i++) {
        items[i].price = rngrange(1500, 0.2, 1.5);
    }

    // randomize list
    for(i=forced; i<ArrayCount(items); i++) {
        iclass = classes[0];
        r = initchance();
        for(k=0; k < num; k++ ) {
            if( classes[k] == None ) continue;
            if( chance( 100/num, r ) ) iclass = classes[k];
        }
        chance_remaining(r);

        items[i].item = iclass;
        items[i].price = rngrange(1500, 0.2, 1.5);
    }

    // remove duplicates
    for(i=0; i+1<ArrayCount(items); i++) {
        for(k=i+1; k<ArrayCount(items); k++) {
            if( items[i].item == items[k].item ) items[k].item = None;
        }
    }

    // compress
    num = 0;
    for(i=0; i<ArrayCount(items) ; i++) {
        if(items[i].item == None) continue;
        items[num++] = items[i];
    }

    // limit to 4
    for(i=4; i<ArrayCount(items) ; i++) {
        items[i].item = None;
    }
}

function CreateRandomMerchant()
{
    local ItemPurchase items[8];

    SetSeed("CreateMerchant");
    if( ! chance_single( dxr.flags.settings.merchants ) ) return;
    if( dxr.flags.f.GetBool('DXRNPCs1_Dead') ) {
        return;
    }

    RandomizeItems(items);

    CreateMerchant("The Merchant", 'DXRNPCs1', items, GetRandomMerchantPosition());
}

function ScriptedPawn CreateForcedMerchant(string name, Name bindname, vector loc, rotator rot, optional class<Inventory> forcedItem)
{
    local ItemPurchase items[8];
    local int forced;

    SetSeed("CreateForcedMerchant " $ name);
    if( dxr.flags.f.GetBool(StringToName(bindname $ "_Dead")) ) {
        return None;
    }

    if(forcedItem != None) {
        items[0].item = forcedItem;
        forced++;
    }
    RandomizeItems(items, forced);

    return CreateMerchant(name, bindname, items, loc, rot);
}

function ScriptedPawn CreateMerchant(string name, Name bindname, ItemPurchase items[8], vector loc, optional rotator rot)
{
    local #var prefix Businessman3 oldnpc;
    local Merchant npc;
    local Conversation c;
    local ConItem conItem;
    local ConversationList list;
    local ConEvent e;
    local int i;

    info("CreateMerchant "$name@bindname);
    for(i=0; i<ArrayCount(items); i++) {
        if(items[i].item != None) {
            info("CreateMerchant item " $ i @ items[i].item @ items[i].price);
        }
    }

    c = new(Level) class'Conversation';
    c.conName = bindname;
    c.CreatedBy = String(bindname);
    c.conOwnerName = String(bindname);
    c.bGenerateAudioNames = false;
    c.bInvokeFrob = true;

    //Got a selection of good things on sale, stranger.
    //Got somethin' that might interest ya'.
    //Got some rare things on sale, stranger!
    //Welcome!
    e = AddSpeech(c, e, "Whaddaya buyin'?", false, "BuyCommon");
    e = AddPurchaseChoices(c, e, items);
    e = AddSpeech(c, e, "Come back anytime.", false, "leave");
    e = AddJump(c, e, "bye");
    e = AddSpeech(c, e, "Hehehehe, thank you.", false, "bought");
    e = AddJump(c, e, "bye");
    e = AddSpeech(c, e, "Hold on, I can't carry any more right now.", true, "noRoom");
    e = AddJump(c, e, "leave");
    e = AddSpeech(c, e, "Not enough cash, stranger.", false, "failBuy");
    e = AddEnd(c, e);

    conItem = new(Level) class'ConItem';
    conItem.conObject = c;
    foreach AllObjects(class'ConversationList', list) {
        if( list.conversations != None ) {
            conItem.next = list.conversations;
            list.conversations = conItem;
            break;
        }
    }
    if(list == None) err(dxr.localURL $ " list == None");

    // old class for backwards compatibility
    foreach AllActors(class'#var prefix Businessman3', oldnpc, bindname) {
        oldnpc.BindName = String(bindname);
        oldnpc.ConBindEvents();
        // don't return if he already existed
        info("CreateMerchant reusing merchant "$oldnpc@bindname);
        return None;
    }
    npc = Spawn(class'Merchant',, bindname, loc, rot );
    if( npc == None ) {
        warning("CreateMerchant failed to spawn merchant");
        return None;
    }
    info("CreateMerchant spawned new merchant "$npc@bindname);
    npc.BindName = String(bindname);
    npc.SetOrders('Standing');
    npc.FamiliarName = name;
    npc.UnfamiliarName = npc.FamiliarName;
    for(i=0; i < ArrayCount(items); i++) {
        if(items[i].item == None) continue;
        GiveItem(npc, items[i].item);
    }
    npc.ConBindEvents();
    return npc;
}

function vector GetRandomMerchantPosition()
{
    local DeusExMover d;
    local vector loc;
    local int i;

    for(i=0; i<10; i++) {
        loc = GetRandomPosition();
        d = None;
        foreach RadiusActors(class'DeusExMover', d, 150.0, loc) {
            break;
        }
        if( d == None ) return loc;
    }

    return loc;
}

function ConEventSpeech AddSpeech(Conversation c, ConEvent prev, string text, bool player_talking, optional string label)
{
    local ConEventSpeech e;
    local ConEventMoveCamera cam;

    cam = new(c) class'ConEventMoveCamera';
    cam.cameraType = CT_Actor;
    cam.cameraPosition = CP_SideMid;
    cam.cameraTransition = TR_Jump;
    cam.eventType = ET_MoveCamera;
    cam.label = label;

    AddConEvent(c, prev, cam);
    prev = cam;

    e = new(c) class'ConEventSpeech';
    e.conversation = c;
    if( player_talking ) {
        e.speakerName = "JCDenton";
        e.speakingToName = c.conOwnerName;
    }
    else {
        e.speakerName = c.conOwnerName;
        e.speakingToName = "JCDenton";
    }
    e.conSpeech = new(c) class'ConSpeech';
    e.conSpeech.speech = text;

    AddConEvent(c, prev, e);

    return e;
}

function ConEventEnd AddEnd(Conversation c, ConEvent prev)
{
    local ConEventEnd e;
    e = new(c) class'ConEventEnd';
    e.conversation = c;
    e.eventType = ET_End;
    e.label = "bye";

    AddConEvent(c, prev, e);

    return e;
}

function ConEvent AddPurchaseChoices(Conversation c, ConEvent prev, ItemPurchase items[8])
{
    local string text, label;
    local ConEventChoice e;
    local ConChoice choice;
    local int i;

    prev = AddPersonaChecks(c, prev, "choices", items);

    e = new(c) class'ConEventChoice';
    e.conversation = c;
    e.eventType = ET_Choice;
    e.label = "choices";
    e.bClearScreen = true;

    choice = AddChoice(e, choice, "Nevermind", "leave");

    for(i=0; i<ArrayCount(items); i++) {
        if( items[i].item == None ) continue;
        choice = AddItemChoice(e, choice, items[i]);
    }

    AddConEvent(c, prev, e);
    prev = e;

    for(i=0; i<ArrayCount(items); i++) {
        if( items[i].item == None ) continue;
        // transfer object, if it fails then jump to noRoom
        BuildBuyItemText(items[i], true, text, label);
        prev = AddSpeech(c, prev, text, true, label);
        prev = AddTransfer(c, prev, items[i].item);

        //set flag for bought item, give negative credits, jump to bought
        prev = AddSetFlag(c, prev, "", "bought"$items[i].item.name, true);
        prev = AddGiveCredits(c, prev, -items[i].price );
        prev = AddJump(c, prev, "bought");
    }

    return prev;
}

function ConEventTransferObject AddTransfer(Conversation c, ConEvent prev, class<Inventory> item)
{
    local ConEventTransferObject e;

    e = new(c) class'ConEventTransferObject';
    e.eventType = ET_TransferObject;
    e.objectName = string(item.name);
    e.giveObject = item;
    e.transferCount = 1;
    e.fromName = c.conOwnerName;
    e.toName = "JCDenton";
    e.failLabel = "noRoom";
    AddConEvent(c, prev, e);
    return e;
}

function ConEventAddCredits AddGiveCredits(Conversation c, ConEvent prev, int amount)
{
    local ConEventAddCredits e;
    e = new(c) class'ConEventAddCredits';
    e.eventType = ET_AddCredits;
    e.creditsToAdd = amount;
    AddConEvent(c, prev, e);
    return e;
}

function BuildBuyItemText(ItemPurchase item, bool canBuy, out string text, out string label)
{
    if(canBuy) {
        text = "I'll take the " $ item.item.default.ItemName $ " for " $ item.price $ " credits.";
        label = "buy"$item.item.name;
    }
    else {
        text = "I don't have " $ item.price $ " credits for the "$ item.item.default.ItemName $ ".";
        label = "failBuy";
    }
}

function ConChoice AddChoice(ConEventChoice e, ConChoice prev, string text, string label)
{
    local ConChoice choice;
    choice = new(e) class'ConChoice';
    choice.bDisplayAsSpeech = true;
    choice.choiceText = text;
    choice.choiceLabel = label;

    if(prev != None)
        prev.nextChoice = choice;
    if(e.ChoiceList == None)
        e.ChoiceList = choice;

    return choice;
}

function ConChoice _AddItemChoice(ConEventChoice e, ConChoice prev, ItemPurchase item, bool canBuy)
{
    local ConChoice choice;
    local ConFlagRef f;
    local string text, label;

    BuildBuyItemText(item, canBuy, text, label);
    choice = AddChoice(e, prev, text, label);

    f = new(e) class'ConFlagRef';
    f.flagName = StringToName("canBuy"$item.item.name);
    f.value = canBuy;
    choice.flagRef = f;
    f.nextFlagRef = new(e) class'ConFlagRef';
    f = f.nextFlagRef;
    f.flagName = StringToName("bought"$item.item.name);
    f.value = false;

    return choice;
}

function ConChoice AddItemChoice(ConEventChoice e, ConChoice prev, ItemPurchase item)
{
    prev = _AddItemChoice(e, prev, item, true);
    prev = _AddItemChoice(e, prev, item, false);
    return prev;
}

function ConEvent AddPersonaChecks(Conversation c, ConEvent prev, string after_label, ItemPurchase items[8])
{
    local int i;
    local string label;

    // clear flags
    for(i=0; i<ArrayCount(items); i++) {
        if( items[i].item == None ) continue;
        prev = AddSetFlag(c, prev, "", "canBuy"$items[i].item.name, false);
    }

    // create persona checks
    for(i=0; i<ArrayCount(items); i++) {
        if( items[i].item == None ) continue;
        prev = AddPersonaCheck(c, prev, items[i]);
    }

    // jump to after set flags
    prev = AddJump(c, prev, after_label);

    // write to flags and jump back to checks
    for(i=0; i<ArrayCount(items); i++) {
        if( items[i].item == None ) continue;
        if( i+1 < ArrayCount(items) && items[i+1].item != None )
            label = "checkBuy"$items[i+1].item.name;
        else
            label = after_label;
        prev = AddSetFlag(c, prev, label, "canBuy"$items[i].item.name, true);
    }
    return prev;
}

function ConEvent AddPersonaCheck(Conversation c, ConEvent prev, ItemPurchase item)
{
    local ConEventCheckPersona p;

    p = new(c) class'ConEventCheckPersona';
    p.eventType = ET_CheckPersona;
    p.personaType = EP_Credits;
    p.condition = EC_GreaterEqual;
    p.value = item.price;
    p.label = "checkBuy"$item.item.name;
    p.jumpLabel = "canBuy"$item.item.name $ "true";

    AddConEvent(c, prev, p);
    prev = p;
    return p;
}

function ConEvent AddSetFlag(Conversation c, ConEvent prev, string after_label, string flag_name, bool value)
{
    local ConEventSetFlag ef;
    local ConFlagRef f;

    ef = new(c) class'ConEventSetFlag';
    ef.eventType = ET_SetFlag;
    ef.label = flag_name $ value;
    f = new(c) class'ConFlagRef';
    f.flagName = StringToName(flag_name);
    f.value = value;
    f.expiration = dxr.dxInfo.missionNumber;
    ef.flagRef = f;

    AddConEvent(c, prev, ef);
    prev = ef;

    if( after_label != "" )
        prev = AddJump(c, prev, after_label);

    return prev;
}

function ConEventJump AddJump(Conversation c, ConEvent prev, string after_label)
{
    local ConEventJump j;
    j = new(c) class'ConEventJump';
    j.eventType = ET_Jump;
    j.jumpLabel = after_label;
    AddConEvent(c, prev, j);
    return j;
}

function AddConEvent(Conversation c, ConEvent prev, ConEvent e)
{
    if( prev != None ) {
        if( prev.nextEvent != None )// this might be good to do intentionally sometimes
            warning("prev.nextEvent != None, c: "$c$", prev: "$prev$", e: "$e);
        e.nextEvent = prev.nextEvent;
        prev.nextEvent = e;
    }
    else
        c.eventList = e;
}
