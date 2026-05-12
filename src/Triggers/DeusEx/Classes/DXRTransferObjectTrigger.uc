// For doing stuff when a ConEventTransferObject runs
class DXRTransferObjectTrigger extends Trigger;

var() ConEventTransferObject ceto;

function Trigger(Actor other, Pawn instigator)
{
    local DXRando dxr;
    local string itemName;
    local int amount;

    local class<DeusExAmmo> ammoClass;
    local DeusExAmmo ammoInv;

    dxr = class'DXRando'.default.dxr;

    if (class<DeusExAmmo>(ceto.giveObject) != None) {
        if (dxr.player != ceto.toActor) return;
        ammoClass = class<DeusExAmmo>(ceto.giveObject);

        if (Pawn(ceto.fromActor) != None) {
            ammoInv = DeusExAmmo(Pawn(ceto.fromActor).FindInventoryType(ammoClass));
        }
        if (ammoInv != None) {
            itemName = ammoInv.itemName;
            amount = ammoInv.AmmoAmount;
        } else {
            itemName = ammoClass.default.itemName;
            amount = ammoClass.default.AmmoAmount;
        }
        if (itemName == class'DeusExAmmo'.default.itemName) return;

        ammoInv = DeusExAmmo(dxr.player.FindInventoryType(ammoClass));
        if (ammoInv != None) {
            amount = Min(amount, ammoInv.MaxAmmo - ammoInv.AmmoAmount);
        }

        if (amount > 0) {
            dxr.player.ClientMessage("You got" @ amount @ itemName, 'Pickup');
        }
    }
    // else do something else with some other Inventory class...
}

static function DXRTransferObjectTrigger CreateForEvent(ConEventTransferObject ceto, optional Conversation con, optional ConEvent prevEvent)
{
    local DXRando dxr;
    local name triggerTag;
    local ConEventTrigger cet;
    local DXRTransferObjectTrigger tot;

    dxr = class'DXRando'.default.dxr;
    triggerTag = ceto.Name;

    if (prevEvent == None) prevEvent = class'DXRActorsBase'.static.FindPrevConEvent(ceto, con);
    if (ConEventTrigger(prevEvent) == None || ConEventTrigger(prevEvent).triggerTag != triggerTag) {
        cet = ConEventTrigger(class'DXRActorsBase'.static.NewConEvent(ceto.Conversation, prevEvent, class'ConEventTrigger'));
        cet.triggerTag = triggerTag;
    }

    foreach dxr.AllActors(class'DXRTransferObjectTrigger', tot, triggerTag) break;
    if (tot == None) tot = dxr.Spawn(class'DXRTransferObjectTrigger',, triggerTag);
    tot.ceto = ceto;

    return tot;
}
