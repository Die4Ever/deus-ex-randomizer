class DXRNPCs extends DXRActorsBase transient;

struct ItemPurchase
{
    var class<Inventory> item;
    var int price;
};

struct ForcedItemList
{
    var class<Inventory> forcedItem[4];
    var int forcedPrice[4];
};

const MERCH_TELEM_NO_BUY = -1;
const MERCH_TELEM_NO_ROOM = -2;
const MERCH_TELEM_NO_MONEY = -3;

function AnyEntry()
{
    Super.AnyEntry();

    CreateRandomMerchant();
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

//#region Generate Choices
function AddLoadoutPurchaseChoices(out ItemPurchase choices[75], out int numChoices, optional int priceLimit)
{
    local DXRLoadouts loadout;
    local class<Actor> spawns[10];
    local int chances[10];
    local int i, basePrice;

    loadout = DXRLoadouts(class'DXRLoadouts'.static.Find());

    if (loadout==None) return; //No loadouts, no need to add anything special

    loadout.GetItemSpawns(spawns,chances);

    for (i=0;i<ArrayCount(spawns);i++){
        if (spawns[i]==None) continue;
        if (!ClassIsChildOf(spawns[i],class'Inventory')) continue; //Just in case

        //Scale the prices automatically based on the specified chances
        //This makes 10% = 1000, 30% = 600,  45% = 300 (and clamped between 300 and 1500)
        basePrice = FClamp((-20 * chances[i]) + 1200,300,1500);

        //1 extra chance for every 10% seems reasonable?  Most things are around 30%, so 3 entries
        AddItemPurchaseChoice(choices,numChoices,class<Inventory>(spawns[i]),300,chances[i]/10, priceLimit);
    }

}

function AddItemPurchaseChoice(out ItemPurchase choices[75], out int numChoices, class<Inventory> choiceClass, int basePrice, int weight, int priceLimit)
{
    local int i;
    local DXRLoadouts loadout;

    if (priceLimit!=0 && basePrice>priceLimit) return;

    //Don't make banned items available to purchase
    loadout = DXRLoadouts(class'DXRLoadouts'.static.Find());
    if (loadout!=None && loadout.is_banned(choiceClass)) {
        l("Merchant rejected item choice "$choiceClass$" due to loadout");
        return;
    }

    for (i=0;i<weight;i++){
        if (numChoices==ArrayCount(choices)){
            l("No more room to add item purchase choices! "$choiceClass);
            continue;
        }
        choices[numChoices].item=choiceClass;
        choices[numChoices].price=basePrice;
        numChoices++;
    }
}

//This could theoretically take in the list of items so that it just wouldn't even add choices
//that have already been forced into the list?
function ItemPurchase SelectRandomPurchaseChoice(out ItemPurchase choices[75], out int numChoices)
{
    local ItemPurchase selected;
    local ItemPurchase newChoices[75]; //Make sure this is at least as big as choices
    local int i, numNewChoices;

    //Pick a random choice
    selected = choices[rng(numChoices)];

    //Remove any duplicates in the choices list
    for (i=0;i<numChoices;i++){
        if (choices[i].item!=selected.item){
            newChoices[numNewChoices++]=choices[i];
        }
    }

    //Copy the choices back to the original list
    for(i=0;i<ArrayCount(choices);i++){
        choices[i] = newChoices[i];
    }
    numChoices = numNewChoices;
    return selected;
}

function RandomizeItems(out ItemPurchase items[8], optional int forced, optional int priceLimit)
{
    local float r;
    local int i, k, num, numChoices;
    local class<Inventory> iclass;
    local ItemPurchase choices[75];

    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)Medkit',1000,8,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)Medkit',600,2,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)Lockpick',600,4,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)Multitool',600,4,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)BioelectricCell',1000,8,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)BioelectricCell',600,2,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)BallisticArmor',400,3,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)Ammo10mm',250,3,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)AmmoBattery',250,3,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)AmmoDartPoison',250,3,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)AmmoRocket',300,1,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)WeaponShuriken',1000,1,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)HazMatSuit',400,3,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)Rebreather',300,3,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)AdaptiveArmor',2000,1,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)WeaponLAM',1000,1,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)WeaponEMPGrenade',1000,1,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)WeaponGasGrenade',1000,1,priceLimit);
    AddItemPurchaseChoice(choices,numChoices,class'#var(prefix)WeaponNanoVirusGrenade',1000,1,priceLimit);

    //The merchant can also sell items you might find randomly spawned on the ground, based on your loadout
    AddLoadoutPurchaseChoices(choices,numChoices,priceLimit);

    //These are basically just increased odds?  In theory this is replaced by the increased weighting above
    //Is it actually equivalent?  ¯\_(ツ)_/¯
    /*
    if(chance_single(30)){
        items[forced].item = class'#var(prefix)Medkit';
        items[forced].price = 1000;
        forced++;
    }
    if(chance_single(30)){
        items[forced].item = class'#var(prefix)BioelectricCell';
        items[forced].price = 1000;
        forced++;
    }*/

    // Fill the rest of the item choices
    for(i=forced; i<ArrayCount(items); i++) {
        items[i] = SelectRandomPurchaseChoice(choices,numChoices);
    }

    // remove duplicates (Should only be from forced items at the moment)
    for(i=0; i+1<ArrayCount(items); i++) {
        for(k=i+1; k<ArrayCount(items); k++) {
            if( items[i].item == items[k].item ) items[k].item = None;
        }
    }

    // compress
    num = 0;
    for(i=0; i<ArrayCount(items) ; i++) {
        if(items[i].item == None) continue;
        iclass = items[i].item;
        items[i].item = None;
        items[num] = items[i];
        items[num++].item = iclass;
    }

    // limit to 4
    for(i=4; i<ArrayCount(items) ; i++) {
        items[i].item = None;
    }
}

function RandomizeItemPrices(out ItemPurchase items[8], float lower, float upper)
{
    local int i;

    //Randomize the item prices
    for (i=0;i<ArrayCount(items);i++){
        if (items[i].item==None) continue;
        if (items[i].price==0) items[i].price=1000; //Just in case - all items SHOULD have prices defined
        items[i].price = rngrange(items[i].price, lower, upper);  //Range was previously 0.3 to 2.0
    }
}

//#endregion

//#region Create Merchants
function CreateRandomMerchant()
{
    local ItemPurchase items[8];

    if(dxr.dxInfo.MissionNumber < 0) return;

    SetSeed("CreateMerchant");
    if( ! chance_single( dxr.flags.settings.merchants ) ) return;
    if( dxr.flags.f.GetBool('DXRNPCs1_Dead') ) {
        return;
    }

    RandomizeItems(items);
    RandomizeItemPrices(items, 0.5, 1.5);

    CreateMerchant("The Merchant", 'DXRNPCs1', class'Merchant', items, GetRandomMerchantPosition());
}

function ScriptedPawn CreateForcedMerchant(string name, Name bindname, class<Merchant> mClass, vector loc, rotator rot,
                                           bool addRandomItems, bool randomizePrices, optional int priceLimit,
                                           optional ForcedItemList forcedItems)
{
    local ItemPurchase items[8];
    local int forced, i;

    SetSeed("CreateForcedMerchant " $ name);
    if( dxr.flags.f.GetBool(StringToName(bindname $ "_Dead")) ) {
        return None;
    }

    for (i=0;i<ArrayCount(forcedItems.forcedItem);i++){
        if (forcedItems.forcedItem[i]==None) continue;
        items[forced].item = forcedItems.forcedItem[i];
        items[forced].price = forcedItems.forcedPrice[i];
        forced++;
    }

    if (addRandomItems){
        RandomizeItems(items, forced, priceLimit);
    }

    if (randomizePrices){
        RandomizeItemPrices(items, 0.5, 1.5);
    }

    return CreateMerchant(name, bindname, mclass, items, loc, rot);
}

function ForcedItemList CreateForcedItems(optional class<Inventory> forcedItem1, optional int forcedItemPrice1,
                                       optional class<Inventory> forcedItem2, optional int forcedItemPrice2,
                                       optional class<Inventory> forcedItem3, optional int forcedItemPrice3,
                                       optional class<Inventory> forcedItem4, optional int forcedItemPrice4)
{
    local ForcedItemList items;
    local int i;

    if(forcedItem1 != None) {
        items.forcedItem[i] = forcedItem1;
        items.forcedPrice[i] = forcedItemPrice1;
        i++;
    }
    if(forcedItem2 != None) {
        items.forcedItem[i] = forcedItem2;
        items.forcedPrice[i] = forcedItemPrice2;
        i++;
    }
    if(forcedItem3 != None) {
        items.forcedItem[i] = forcedItem3;
        items.forcedPrice[i] = forcedItemPrice3;
        i++;
    }
    if(forcedItem4 != None) {
        items.forcedItem[i] = forcedItem4;
        items.forcedPrice[i] = forcedItemPrice4;
        i++;
    }

    return items;
}

function ScriptedPawn CreateMerchant(string name, Name bindname, class<Merchant> mClass, ItemPurchase items[8], vector loc, optional rotator rot)
{
    local #var(prefix)Businessman3 oldnpc;
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
    c.CreatedBy = name;
    c.conOwnerName = String(bindname);
    c.bGenerateAudioNames = false;
    c.bInvokeFrob = true;
    c.Description = "Merchant";

    //Got a selection of good things on sale, stranger.
    //Got somethin' that might interest ya'.
    //Got some rare things on sale, stranger!
    //Welcome!
    e = AddTransferRepairTrigger(c,e);
    e = AddSpeech(c, e, "Whaddaya buyin'?", false, "BuyCommon");
    e = AddPurchaseChoices(c, e, items);
    e = AddSpeech(c, e, "Come back anytime.", false, "leave");
    e = AddMerchantTelem(c, e, items, MERCH_TELEM_NO_BUY);
    e = AddJump(c, e, "bye");
    e = AddSpeech(c, e, "Hehehehe, thank you.", false, "bought");
    e = AddJump(c, e, "bye");
    e = AddSpeech(c, e, "Hold on, I can't carry any more right now.", true, "noRoom");
    e = AddMerchantTelem(c, e, items, MERCH_TELEM_NO_ROOM);
    e = AddJump(c, e, "leave");
    e = AddSpeech(c, e, "Not enough cash, stranger.", false, "failBuy");
    e = AddMerchantTelem(c, e, items, MERCH_TELEM_NO_MONEY);
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
    if(dxr.dxInfo.missionNumber >= 1 && dxr.dxInfo.missionNumber <= 15 && list == None) err(dxr.localURL $ " list == None");

    // old class for backwards compatibility
    foreach AllActors(class'#var(prefix)Businessman3', oldnpc, bindname) {
        oldnpc.BindName = String(bindname);
        oldnpc.ConBindEvents();
        // don't return if he already existed
        info("CreateMerchant reusing merchant "$oldnpc@bindname);
        return None;
    }
    npc = Spawn(mClass,, bindname, loc, rot );
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
//#endregion

function vector GetRandomMerchantPosition()
{
    local DeusExMover d;
    local vector loc;
    local int i;

    for(i=0; i<20; i++) {
        loc = GetRandomPosition();
        d = None;
        foreach RadiusActors(class'DeusExMover', d, 150.0, loc) {
            break;
        }
        if(!CheckFreeSpace(loc, player().CollisionRadius * 4, player().CollisionHeight * 2)) {
            continue;
        }
        if( d == None ) return loc;
    }

    return loc;
}

function String UniqueFlagString(string baseFlag, string ownerName)
{
    local string finalName;

    finalName = baseFlag$"_"$ownerName$"_"$StripMapName(dxr.LocalURL);

    return finalName;
}

function Name UniqueFlagName(string baseFlag, string ownerName)
{
    return StringToName(UniqueFlagString(baseFlag,ownerName));
}

//#region Generate Convo
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

    choice = AddChoice(e, choice, "Nevermind.", "leave");

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
        prev = AddMerchantTelem(c, prev, items, i);
        prev = AddSetFlag(c, prev, "", UniqueFlagName("bought"$items[i].item.name,c.conOwnerName), true);
        prev = AddGiveCredits(c, prev, -items[i].price );
        prev = AddJump(c, prev, "bought");
    }

    return prev;
}

function ConEventTrigger AddMerchantTelem(Conversation c, ConEvent prev, ItemPurchase items[8], int i)
{
    local ConEventTrigger e;
    local DXRMerchantTelemetryTrigger tt; //telemMessage
    local string tagName, j;
    local class<Json> js;
    local int k;

    if (i==MERCH_TELEM_NO_BUY){
        tagName="MerchantBoughtNothing";
    } else if (i==MERCH_TELEM_NO_ROOM) {
        tagName="MerchantNoRoom";
    } else if (i==MERCH_TELEM_NO_MONEY) {
        tagName="MerchantNoMoney";
    } else {
        if (items[i].item!=None){
            tagName="MerchantBought"$items[i].item.name;
        } else {
            tagName="MerchantPurchaseError";
        }
    }
    tagName=tagName$c.conName; //Append the bindname to the end

    e = new(c) class'ConEventTrigger';
    e.eventType=ET_Trigger;
    e.triggerTag = StringToName(tagName);
    AddConEvent(c, prev, e);

    //Make sure the Telemetry Triggers actually exist
    foreach AllActors(class'DXRMerchantTelemetryTrigger',tt,e.triggerTag){break;}
    if (tt==None){
        tt=Spawn(class'DXRMerchantTelemetryTrigger',,e.triggerTag);

        js = class'Json';

        j = js.static.Start("MerchantInfo");
        js.static.Add(j,"Credits","__CURPLAYERCREDITS__"); //This will be replaced in the Merchant Telemetry Trigger
        js.static.Add(j,"MerchantBindName",c.conName);
        js.static.Add(j,"MerchantName",c.CreatedBy);
        if (i>=0){
            js.static.Add(j,"Purchase",items[i].item.name);
            js.static.Add(j,"PurchaseName",items[i].item.default.ItemName);
            js.static.Add(j,"PurchaseArticle",items[i].item.default.ItemArticle);
            js.static.Add(j,"PurchasePrice",items[i].price);
        } else if (i==MERCH_TELEM_NO_BUY) {
            js.static.Add(j,"Failure","NoPurchase");
        } else if (i==MERCH_TELEM_NO_ROOM) {
            js.static.Add(j,"Failure","NoRoom");
        } else if (i==MERCH_TELEM_NO_MONEY) {
            js.static.Add(j,"Failure","NoCash");
        }
        for (k=0;k<ArrayCount(items);k++) {
            if (items[k].item!=None){
                js.static.Add(j,"Option"$k$"Type",items[k].item.name);
                js.static.Add(j,"Option"$k$"Name",items[k].item.default.ItemName);
                js.static.Add(j,"Option"$k$"Article",items[k].item.default.ItemArticle);
                js.static.Add(j,"Option"$k$"Price",items[k].price);
            }
        }
        class'DXREventsBase'.static.GeneralEventData(dxr,j);
        js.static.End(j);

        tt.telemMsg=j;
    }

    return e;

}

function ConEventTrigger AddTransferRepairTrigger(Conversation c, ConEvent prev)
{
    local ConEventTrigger e;
    local RepairConObjTransferTrigger rt;
    local string tagName, j;
    local class<Json> js;
    local int k;

    tagName="ConEventTransferObjectRepair"$c.conName; //Append the bindname to the end

    e = new(c) class'ConEventTrigger';
    e.eventType=ET_Trigger;
    e.triggerTag = StringToName(tagName);
    AddConEvent(c, prev, e);

    //Make sure the Repair Triggers actually exist
    foreach AllActors(class'RepairConObjTransferTrigger',rt,e.triggerTag){break;}
    if (rt==None){
        rt=Spawn(class'RepairConObjTransferTrigger',,e.triggerTag);
        rt.conName = c.conName;
        rt.AddPackage("#var(package)"); //Add our package to the list of possibilities
    }

    return e;
}

function ConEventTransferObject AddTransfer(Conversation c, ConEvent prev, class<Inventory> item)
{
    local ConEventTransferObject e;

    e = new(c) class'ConEventTransferObject';
    e.eventType = ET_TransferObject;
    e.objectName = string(item);  //Fully qualify the class name so it includes the package name (for safety)
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
    f.flagName = UniqueFlagName("canBuy"$item.item.name,e.conversation.conOwnerName);
    f.value = canBuy;
    choice.flagRef = f;
    f.nextFlagRef = new(e) class'ConFlagRef';
    f = f.nextFlagRef;
    f.flagName = UniqueFlagName("bought"$item.item.name, e.conversation.conOwnerName);
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
        prev = AddSetFlag(c, prev, "", UniqueFlagName("canBuy"$items[i].item.name,c.conOwnerName), false);
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
            label = UniqueFlagString("checkBuy"$items[i+1].item.name,c.conOwnerName);
        else
            label = after_label;
        prev = AddSetFlag(c, prev, label, UniqueFlagName("canBuy"$items[i].item.name,c.conOwnerName), true);
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
    p.label = UniqueFlagString("checkBuy"$item.item.name,c.conOwnerName);
    p.jumpLabel = UniqueFlagString("canBuy"$item.item.name,c.conOwnerName) $ "true";

    AddConEvent(c, prev, p);
    prev = p;
    return p;
}

function ConEvent AddSetFlag(Conversation c, ConEvent prev, string after_label, coerce string flag_name, bool value)
{
    local ConEventSetFlag ef;
    local ConFlagRef f;

    ef = new(c) class'ConEventSetFlag';
    ef.eventType = ET_SetFlag;
    ef.label = flag_name $ value;
    f = new(c) class'ConFlagRef';
    f.flagName = StringToName(flag_name);
    f.value = value;
    f.expiration = dxr.dxInfo.missionNumber + 1;
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
//#endregion
