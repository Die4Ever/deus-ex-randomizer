class DXRActorsBase extends DXRBase;

var class<Actor> _skipactor_types[6];

struct LocationNormal {
    var vector loc;
    var vector norm;
};

struct FMinMax {
    var float min;
    var float max;
};

struct safe_rule {
    var name item_name;
    var vector min_pos;
    var vector max_pos;
    var bool allow;
};

function CheckConfig()
{
    local int i;

    i=0;
    _skipactor_types[i++] = class'#var(prefix)BarrelAmbrosia';
    _skipactor_types[i++] = class'#var(prefix)NanoKey';
    if(#defined(gmdx))
        _skipactor_types[i++] = class'#var(prefix)CrateUnbreakableLarge';

    Super.CheckConfig();
}

function SwapAll(string classname, float percent_chance)
{
    local Actor temp[4096];
    local Actor a, b;
    local int num, i, slot;
    local class<Actor> c;

    SetSeed( "SwapAll " $ classname );
    num=0;
    c = GetClassFromString(classname, class'Actor');
    foreach AllActors(c, a)
    {
        if( SkipActor(a) ) continue;
        temp[num++] = a;
    }

    for(i=0; i<num; i++) {
        if( percent_chance<100 && !chance_single(percent_chance) ) continue;
        slot=rng(num-1);// -1 because we skip ourself
        if(slot >= i) slot++;
        Swap(temp[i], temp[slot]);
    }
}

static function vector AbsEach(vector v)
{// not a real thing in math? but it's convenient
    v.X = abs(v.X);
    v.Y = abs(v.Y);
    v.Z = abs(v.Z);
    return v;
}

static function bool AnyGreater(vector a, vector b)
{
    return a.X > b.X || a.Y > b.Y || a.Z > b.Z;
}

function bool CarriedItem(Actor a)
{// I need to check Engine.Inventory.bCarriedItem
    if( PlayerPawn(a.Base) != None )
        return true;
    return a.Owner != None && a.Owner.IsA('Pawn');
}

static function bool IsHuman(class<Actor> a)
{
    return ClassIsChildOf(a, class'#var(prefix)HumanMilitary') || ClassIsChildOf(a, class'#var(prefix)HumanThug') || ClassIsChildOf(a, class'#var(prefix)HumanCivilian');
}

static function bool IsRobot(class<Actor> a)
{
    return ClassIsChildOf(a, class'Robot');
}

static function bool IsCombatRobot(class<Actor> a)
{
    return
        IsRobot(a) &&
        !ClassIsChildOf(a, class'#var(prefix)MedicalBot') &&
        !ClassIsChildOf(a, class'#var(prefix)RepairBot') &&
        !ClassIsChildOf(a, class'#var(prefix)CleanerBot');
}

static function bool IsCombatAnimal(class<Actor> a)
{
    return
        ClassIsChildOf(a, class'#var(prefix)Animal') && (
            ClassIsChildOf(a, class'#var(prefix)Doberman') ||
            ClassIsChildOf(a, class'#var(prefix)Gray') ||
            ClassIsChildOf(a, class'#var(prefix)Greasel') ||
            ClassIsChildOf(a, class'#var(prefix)Karkian')
        );
}

// Returns True if the class is an animal that never starts as an enemy
static function bool IsCritter(class<Actor> a)
{
    return ClassIsChildOf(a, class'#var(prefix)Animal') && !IsCombatAnimal(a);
}

// Returns True if the class ever starts as an enemy, even if some instances don't
static function bool IsCombatPawn(class<Actor> a)
{
    return IsHuman(a) || IsCombatRobot(a) || IsCombatAnimal(a);
}

static function bool IsRelevantPawn(class<Actor> a)
{
    return IsCombatPawn(a) && !ClassIsChildOf(a, class'Merchant');
}

function bool IsInitialEnemy(ScriptedPawn p)
{
    local int i;

    return p.GetAllianceType( class'#var(PlayerPawn)'.default.Alliance ) == ALLIANCE_Hostile;
}

static function bool RemoveItem(Pawn p, class c)
{
    local ScriptedPawn sp;
    local Inventory Inv, next;
    local int i;
    local bool found;
    sp = ScriptedPawn(p);
    found = false;

    if( sp != None ) {
        for (i=0; i<ArrayCount(sp.InitialInventory); i++)
        {
            if ((sp.InitialInventory[i].Inventory != None) && (sp.InitialInventory[i].Count > 0))
            {
                if( ClassIsChildOf(sp.InitialInventory[i].Inventory, c) ) {
                    sp.InitialInventory[i].Count = 0;
                    found = True;
                }
            }
        }
    }

    for( Inv=p.Inventory; Inv!=None; Inv=next ) {
        next = Inv.Inventory;
        if ( ClassIsChildOf(Inv.class, c) ) {
            Inv.Destroy();
            found = true;
        }
    }

    return found;
}

static function bool HasItem(Pawn p, class c)
{
    local ScriptedPawn sp;
    local int i;
    sp = ScriptedPawn(p);

    if( sp != None ) {
        for (i=0; i<ArrayCount(sp.InitialInventory); i++)
        {
            if ((sp.InitialInventory[i].Inventory != None) && (sp.InitialInventory[i].Count > 0))
            {
                if( sp.InitialInventory[i].Inventory == c ) return True;
            }
        }
    }
    return p.FindInventoryType(c) != None;
}

static function bool HasItemSubclass(Pawn p, class<Inventory> c)
{
    local Inventory Inv;
    local ScriptedPawn sp;
    local int i;
    sp = ScriptedPawn(p);

    if( sp != None ) {
        for (i=0; i<ArrayCount(sp.InitialInventory); i++)
        {
            if ((sp.InitialInventory[i].Inventory != None) && (sp.InitialInventory[i].Count > 0))
            {
                if( ClassIsChildOf(sp.InitialInventory[i].Inventory, c) ) return True;
            }
        }
    }

    for( Inv=p.Inventory; Inv!=None; Inv=Inv.Inventory )
        if ( ClassIsChildOf(Inv.class, c) )
            return true;
    return false;
}

static function bool HasMeleeWeapon(Pawn p)
{
    return HasItem(p, class'#var(prefix)WeaponBaton')
        || HasItem(p, class'#var(prefix)WeaponCombatKnife')
        || HasItem(p, class'#var(prefix)WeaponCrowbar')
        || HasItem(p, class'#var(prefix)WeaponSword')
        || HasItem(p, class'#var(prefix)WeaponNanoSword');
}

static function bool IsMeleeWeapon(Inventory item)
{
    return item.IsA('#var(prefix)WeaponBaton')
        || item.IsA('#var(prefix)WeaponCombatKnife')
        || item.IsA('#var(prefix)WeaponCrowbar')
        || item.IsA('#var(prefix)WeaponSword')
        || item.IsA('#var(prefix)WeaponNanoSword');
}

static function Ammo GiveAmmoForWeapon(Pawn p, DeusExWeapon w, int add_ammo)
{
    local int i;

    if( w == None || add_ammo <= 0 )
        return None;

    if ( w.AmmoName == None || w.AmmoName == Class'AmmoNone' )
        return None;

    for(i=0; i<add_ammo; i++)
        w.AmmoType = Ammo(GiveItem(p, w.AmmoName));
    return w.AmmoType;
}

static function Inventory GiveExistingItem(Pawn p, Inventory item, optional int add_ammo)
{
    local DeusExWeapon w;
    local Ammo a;
    local DeusExPickup pickup;
    local DeusExPlayer player;
    local bool PlayerTraveling;

    if( item == None ) return None;

    player = #var(PlayerPawn)(p);
    if( Ammo(item) != None ) {
        a = Ammo(p.FindInventoryType(item.class));
        if( a != None ) {
            a.AmmoAmount += a.default.AmmoAmount + add_ammo;
            if( player != None )
                player.UpdateAmmoBeltText(a);
            item.Destroy();
            return a;
        } else {
            //Make sure the extra ammo is included even if the pawn doesn't have it already
            Ammo(item).AmmoAmount += add_ammo;
        }
    }

    if( DeusExWeapon(item) != None ) {
        w = DeusExWeapon(p.FindInventoryType(item.class));
        if( w != None ) {
            GiveAmmoForWeapon(p, w, 1 + add_ammo);
            item.Destroy();
            return w;
        }
    }

    if( DeusExPickup(item) != None ) {
        pickup = DeusExPickup(p.FindInventoryType(item.class));
        if( pickup != None ) {
            if( pickup.bCanHaveMultipleCopies && pickup.NumCopies < pickup.MaxCopies ) {
                pickup.NumCopies++;
                item.Destroy();
                if( player != None )
                    player.UpdateBeltText(pickup);
                return pickup;
            } else if (pickup.bCanHaveMultipleCopies && pickup.NumCopies >= pickup.MaxCopies) {
                //Player has some, but can't get more.  Don't try to pick it up or set them as the base.
                //Disown the player entirely, otherwise if they try to pick it up again, it will follow them
                item.SetOwner(None);
                return item;
            }
        }
    }

    item.InitialState='Idle2';
    item.SetLocation(p.Location);

    if( (#defined(gmdx) || #defined(revision) ) && player != None ) {
        PlayerTraveling = player.FlagBase.GetBool('PlayerTraveling');
        if(PlayerTraveling) {
            player.FlagBase.SetBool('PlayerTraveling', false);
        }
    }

    if( player != None ) {
        player.FrobTarget = item;
        item.SetOwner(None);// just in case the right click fails
        player.ParseRightClick();
    } else {
        item.GiveTo(p);
        item.SetBase(p);
    }

    if(PlayerTraveling) {
        player.FlagBase.SetBool('PlayerTraveling', true);
    }

    GiveAmmoForWeapon(p, DeusExWeapon(item), add_ammo);

    if( player != None )
        player.UpdateBeltText(item);

    return item;
}

static function inventory GiveItem(Pawn p, class<Inventory> iclass, optional int add_ammo)
{
    local inventory item;

    item = p.Spawn(iclass, p);
    if( item == None ) return None;
    return GiveExistingItem(p, item, add_ammo);
}

static function ThrowItem(Inventory item, float VelocityMult)
{
    local Actor a;
    local vector loc, rot;
    local int i;

    a = item.Owner;
    if( Pawn(a) != None )
        Pawn(a).DeleteInventory(item);
    if( a != None ) {
        loc = a.Location;
        rot = vector(a.Rotation);
    } else {
        loc = item.Location;
        rot = vector(item.Rotation);
    }
    // retain PickupAmmoCount, vanilla DropFrom ditches the PickupAmmoCount because it assumes the player is doing this
    if(DeusExWeapon(item) != None)
        i = DeusExWeapon(item).PickupAmmoCount;
    item.DropFrom(loc + (VRand()*vect(32,32,16)) + vect(0,0,16) );
    if(DeusExWeapon(item) != None && DeusExWeapon(item).PickupAmmoCount < i)
        DeusExWeapon(item).PickupAmmoCount = i;

    // Nanokeys glow
    if(NanoKey(item) != None)
        GlowUp(item);

    // kinda copied from DeusExPlayer DropItem function
    item.Velocity = rot * 300 + vect(0,0,220) + VRand()*32;
    item.Velocity *= VelocityMult;
    item.SetCollision(true, false, false); // prevent this from blocking NPCs
}

function Inventory MoveNextItemTo(Inventory item, vector Location, name Tag)
{
    // code similar to Revision Mission05.uc
    local Inventory nextItem;
    local #var(PlayerPawn) player;
    local int i;
    l("MoveNextItemTo("$item@Location@Tag$")");
    // Find the next item we can process.
    while(item != None && (item.IsA('NanoKeyRing') || (!item.bDisplayableInv) || Ammo(item) != None))
        item = item.Inventory;

    if(item == None) return None;

    nextItem = item.Inventory;
    player = #var(PlayerPawn)(item.owner);
    l("MoveNextItemTo found: " $ item $ "(" $ item.Location $ ") with owner: " $ item.owner $ ", nextItem: " $ nextItem);

    //== Y|y: Turn off any charged pickups we were using and remove the associated HUD.  Per Lork on the OTP forums
    if(player != None) {
        if (item.IsA('ChargedPickup'))
            ChargedPickup(item).ChargedPickupEnd(player);
    }

    for(i=0; i<100; i++) {
        if(item.SetLocation(Location)) {
            break;
        }
        Location.Z += 20;
    }
    item.DropFrom(Location);
    item.Tag = Tag;// so we can find the item again later
    item.bIsSecretGoal = true;// so they don't get deleted by DXRReduceItems
    l("MoveNextItemTo "$item$" drop from: ("$Location$"), now at ("$item.Location$"), attempts: "$i);

    // restore any ammo amounts for a weapon to default; Y|y: except for grenades
    if (item.IsA('Weapon') && (Weapon(item).AmmoType != None) && !item.IsA('WeaponLAM') && !item.IsA('WeaponGasGrenade') && !item.IsA('WeaponEMPGrenade') && !item.IsA('WeaponNanoVirusGrenade'))
        Weapon(item).PickupAmmoCount = Weapon(item).Default.PickupAmmoCount;

    return nextItem;
}

static function DataVaultImage GivePlayerImage(DeusExPlayer player, class<DataVaultImage> imageClass)
{
    local DataVaultImage image;

    image = DataVaultImage(player.FindInventoryType(imageClass));
    if (image == None) {
        image = player.Spawn(imageClass);
        image.ItemName = imageClass.default.imageDescription;
        image.ItemArticle = "-";
        image.Frob(player, None);
    }

    return image;
}

function bool SkipActorBase(Actor a)
{
    if( a.Owner != None || a.bStatic || a.bHidden || a.bMovable==False || a.bIsSecretGoal || a.bDeleteMe )
        return true;
    return false;
}

function bool SkipActor(Actor a)
{
    local int i;
    if( SkipActorBase(a) ) {
        return true;
    }
    for(i=0; i < ArrayCount(_skipactor_types); i++) {
        if(_skipactor_types[i] == None) break;
        if( a.IsA(_skipactor_types[i].name) ) return true;
    }
    return false;
}

function bool SetActorLocation(Actor a, vector newloc, optional bool retainOrders)
{
    local ScriptedPawn p;

    if( ! a.SetLocation(newloc) ) return false;

    p = ScriptedPawn(a);
    if( p != None && p.Orders == 'Patrolling' && !retainOrders ) {
        p.SetOrders('Wandering');
        p.HomeTag = 'Start';
        p.HomeLoc = p.Location;
    }

    return true;
}

function RemoveFears(ScriptedPawn p)
{
    if( p == None ) {
        err("RemoveFears "$p);
        return;
    }
    p.bFearHacking = false;
    p.bFearWeapon = false;
    p.bFearShot = false;
    p.bFearInjury = false;
    p.bFearIndirectInjury = false;
    p.bFearCarcass = false;
    p.bFearDistress = false;
    p.bFearAlarm = false;
    p.bFearProjectiles = false;
}

function RemoveReactions(ScriptedPawn p)
{
    if( p == None ) {
        err("RemoveReactions "$p);
        return;
    }
    RemoveFears(p);
    p.bHateHacking = false;
    p.bHateWeapon = false;
    p.bHateShot = false;
    p.bHateInjury = false;
    p.bHateIndirectInjury = false;
    p.bHateCarcass = false;
    p.bHateDistress = false;
    p.bReactFutz = false;
    p.bReactPresence = false;
    p.bReactLoudNoise = false;
    p.bReactAlarm = false;
    p.bReactShot = false;
    p.bReactCarcass = false;
    p.bReactDistress = false;
    p.bReactProjectiles = false;
}

function SetPawnHealth(ScriptedPawn p, int health)
{
    // we need to set defaults so that GenerateTotalHealth() works properly
    p.default.HealthHead = health;
    p.default.HealthTorso = health;
    p.default.HealthLegLeft = health;
    p.default.HealthLegRight = health;
    p.default.HealthArmLeft = health;
    p.default.HealthArmRight = health;
    p.HealthHead = health;
    p.HealthTorso = health;
    p.HealthLegLeft = health;
    p.HealthLegRight = health;
    p.HealthArmLeft = health;
    p.HealthArmRight = health;
    p.GenerateTotalHealth();
}

static function bool PawnIsInCombat(Pawn p)
{
    local #var(prefix)ScriptedPawn npc;
    local Pawn CurPawn;

    // check a 100 foot radius around me for combat
    // XXXDEUS_EX AMSD Slow Pawn Iterator
    //foreach RadiusActors(class'ScriptedPawn', npc, 1600)
    for (CurPawn = p.Level.PawnList; CurPawn != None; CurPawn = CurPawn.NextPawn)
    {
        npc = #var(prefix)ScriptedPawn(CurPawn);
        if ((npc != None) && (VSize(npc.Location - p.Location) < (1600 + npc.CollisionRadius)))
        {
            if ((npc.GetStateName() == 'Attacking') && (npc.Enemy == p))
            {
                return true;
            }
        }
    }

    return false;
}

function bool Swap(Actor a, Actor b, optional bool retainOrders)
{
    local vector newloc, oldloc;
    local rotator newrot;
    local bool asuccess, bsuccess;
    local Actor abase, bbase;
    local bool AbCollideActors, AbBlockActors, AbBlockPlayers;
    local EPhysics aphysics, bphysics;

    if( a == b ) return true;

    l("swapping "$ActorToString(a)$" and "$ActorToString(b)$" distance == " $ VSize(a.Location - b.Location) );

    AbCollideActors = a.bCollideActors;
    AbBlockActors = a.bBlockActors;
    AbBlockPlayers = a.bBlockPlayers;
    a.SetCollision(false, false, false);

    oldloc = a.Location;
    newloc = b.Location;

    bsuccess = SetActorLocation(b, oldloc + (b.CollisionHeight - a.CollisionHeight) * vect(0,0,1), retainOrders );
    a.SetCollision(AbCollideActors, AbBlockActors, AbBlockPlayers);
    if( bsuccess == false ) {
        warning("bsuccess failed to move " $ ActorToString(b) $ " into location of " $ ActorToString(a) );
        return false;
    }

    asuccess = SetActorLocation(a, newloc + (a.CollisionHeight - b.CollisionHeight) * vect(0,0,1), retainOrders);
    if( asuccess == false ) {
        warning("asuccess failed to move " $ ActorToString(a) $ " into location of " $ ActorToString(b) );
        SetActorLocation(b, newloc, retainOrders);
        return false;
    }

    newrot = b.Rotation;
    b.SetRotation(a.Rotation);
    a.SetRotation(newrot);

    aphysics = a.Physics;
    bphysics = b.Physics;
    abase = a.Base;
    bbase = b.Base;

    a.SetPhysics(bphysics);
    if(abase != bbase) a.SetBase(bbase);
    b.SetPhysics(aphysics);
    if(abase != bbase) b.SetBase(abase);

    return true;
}

function SwapNames(out Name a, out Name b) {
    local Name t;
    t = a;
    a = b;
    b = t;
}

function SwapVector(out vector a, out vector b) {
    local vector t;
    t = a;
    a = b;
    b = t;
}

function SwapProperty(Actor a, Actor b, string propname) {
    local string t;
    t = a.GetPropertyText(propname);
    a.SetPropertyText(propname, b.GetPropertyText(propname));
    b.SetPropertyText(propname, t);
}

function ResetOrders(ScriptedPawn p) {
    p.OrderActor = None;
    p.NextState = '';
    p.NextLabel = '';

    if(p.Orders == 'Idle') {
        p.Orders = 'Standing';
        p.OrderTag = '';
    }
    p.SetOrders(p.Orders, p.OrderTag, false);
    p.FollowOrders();
}

function bool HasConversation(Actor a) {
    local ConListItem i;

    for(i=ConListItem(a.ConListItems); i!=None; i=i.next) {
        //warning(a$" HasConversation "$i.con.conName@i.con.bFirstPerson@i.con.bNonInteractive@i.con.bDataLinkCon@i.con.conOwnerName@i.con.bCanBeInterrupted@i.con.bCannotBeInterrupted);
        return true;
    }
    return false;
}

function bool HasBased(Actor a) {
    local Actor b;
    foreach a.BasedActors(class'Actor', b)
        return true;
    return false;
}

function bool DestroyActor( Actor d )
{
    // If this item is in an inventory chain, unlink it.
    local Decoration downer;

    if( d.IsA('Inventory') && d.Owner != None && d.Owner.IsA('Pawn') )
    {
        Pawn(d.Owner).DeleteInventory( Inventory(d) );
    }
    return d.Destroy();
}

// only used by DXRMemes title screen? doesn't copy the tag or event or anything
function Actor ReplaceActor(Actor oldactor, string newclassstring)
{
    local Actor a;
    local class<Actor> newclass;
    local vector loc;
    local float scalefactor;
    local float largestDim;

    loc = oldactor.Location;
    oldactor.bHidden = true;
    newclass = class<Actor>(DynamicLoadObject(newclassstring, class'class'));
    if( newclass == None) {
        err("ReplaceActor(" $ newclassstring $ ") can't find class");
        oldactor.bHidden = false;
        return None;
    }
    if( newclass.default.bStatic ) warning("ReplaceActor: " $ newclassstring $ " defaults to bStatic, Spawn probably won't work");

    a = Spawn(newclass,,,loc);

    if( a == None ) {
        warning("ReplaceActor("$oldactor$", "$newclassstring$"), failed to spawn in location "$oldactor.Location);
        oldactor.bHidden = false;
        return None;
    }

    //Get the scaling to match
    if (a.CollisionRadius > a.CollisionHeight) {
        largestDim = a.CollisionRadius;
    } else {
        largestDim = a.CollisionHeight;
    }
    scalefactor = oldactor.CollisionHeight/largestDim;

    //DrawScale doesn't work right for Inventory objects
    a.DrawScale = scalefactor;
    if (a.IsA('Inventory')) {
        Inventory(a).PickupViewScale = scalefactor;
    }

    //Floating decorations don't rotate
    if (a.IsA('DeusExDecoration')) {
        DeusExDecoration(a).bFloating = False;
    }

    //Get it at the right height
    a.move(a.PrePivot);
    oldactor.Destroy();

    return a;
}

function Conversation GetConversation(Name conName)
{
    local Conversation c, fallback;
    local Name fallbackConName;

    fallbackConName='';
    if (dxr.flagbase.GetBool('LDDPJCIsFemale')) {
        fallbackConName=conName;
        conName = StringToName("FemJC"$string(conName));
    }
    foreach AllObjects(class'Conversation', c) {
        if( c.conName == conName ) return c;
        if( c.conName == fallbackConName ) fallback = c;
    }

    if (fallbackConName!='') return fallback;

    return None;
}

static function RemoveConvEventByLabel(Conversation conv, string label)
{
    local ConEvent prev, ce;

    for(ce=conv.eventList; ce != None; ce=ce.nextEvent) {
        if(ce.label == label) {
            FixConversationDeleteEvent(ce, prev);
            break;
        }
        prev = ce;
    }
}

static function ConEvent FixConversationDeleteEvent(ConEvent del, ConEvent prev)
{
    local ConEvent next;
    if(del == del.Conversation.eventList) {
        del.Conversation.eventList = del.nextEvent;
    }
    if(prev != None) {
        prev.nextEvent = del.nextEvent;
    }
    next = del.nextEvent;
    if(next != None && next.label == "") {
        next.label = del.label;
    }
    del.Conversation = None;
    del.nextEvent = None;
    CriticalDelete(del);
    return next;
}

static function ConEvent NewConEvent(Conversation c, ConEvent prev, class<ConEvent> newclass)
{
    local ConEvent e;
    e = new(c) newclass;
    AddConEvent(c, prev, e);
    return e;
}

static function AddConEvent(Conversation c, ConEvent prev, ConEvent e)
{
    e.conversation = c;
    if( prev != None ) {
        e.nextEvent = prev.nextEvent;
        prev.nextEvent = e;
    }
    else {
        c.eventList = e;
    }
}

static function DeleteConversationFlag(Conversation c, name Name, bool Value)
{
    local ConFlagRef f, prev;
    if( c == None ) return;
    for(f = c.flagRefList; f!=None; f=f.nextFlagRef) {
        if( f.flagName == Name && f.value == Value ) {
            if( prev == None )
                c.flagRefList = f.nextFlagRef;
            else
                prev.nextFlagRef = f.nextFlagRef;
            return;
        }
        prev = f;
    }
}

static function DeleteChoiceFlag(ConChoice c, name Name, bool Value)
{
    local ConFlagRef f, prev;
    if( c == None ) return;
    for(f = c.flagRef; f!=None; f=f.nextFlagRef) {
        if( f.flagName == Name && f.value == Value ) {
            if( prev == None )
                c.flagRef = f.nextFlagRef;
            else
                prev.nextFlagRef = f.nextFlagRef;
            return;
        }
        prev = f;
    }
}

static function ConEventSpeech GetSpeechEvent(ConEvent start, string speech) {
    while (start != None) {
        if (start.eventType == ET_Speech && InStr(ConEventSpeech(start).conSpeech.speech, speech) != -1) {
            return ConEventSpeech(start);
        }
        start = start.nextEvent;
    }
    return None;
}

static function string GetGoalText(name goalName, Conversation con)
{
    local ConEvent ce;
    local ConEventAddGoal ceag;

    if (con == None || goalName == '') return "";

    for (ce = con.eventList; ce != None; ce = ce.nextEvent) {
        ceag = ConEventAddGoal(ce);
        if (ceag != None && ceag.goalName == goalName)
            return ceag.goalText;
    }

    return "";
}

function string GetGoalTextGC(name goalName, name conversationName)
{
    return GetGoalText(goalName, GetConversation(conversationName));
}


static function string GetActorName(Actor a)
{
    local #var(PlayerPawn) player;
    local #var(prefix)ScriptedPawn sp;

    if(a == None)
        return "";

    player = #var(PlayerPawn)(a);
    sp = #var(prefix)ScriptedPawn(a);

#ifdef hx
    if(player != None) {
        return player.PlayerReplicationInfo.PlayerName;
    }
#else
    if(player != None) {
        return player.TruePlayerName;
    }
#endif
    // bImportant ScriptedPawns don't get their names randomized
    else if(sp != None && (sp.bImportant || sp.bIsSecretGoal))
        return a.FamiliarName;
    // randomized names aren't really meaningful here so use their default name
    else if(a.default.FamiliarName != "")
        return a.default.FamiliarName;

    return string(a.class.name);
}

static function DeusExDecoration _AddSwitch(Actor a, vector loc, rotator rotate, name Event, optional string description)
{
    local DeusExDecoration d;
    d = DeusExDecoration( _AddActor(a, class'Switch2', loc, rotate) );
    d.Buoyancy = 0;
    d.Event = Event;
    d.FamiliarName=description;
    d.UnfamiliarName=description;
    return d;
}

// DON'T PASS A VECTM OR ROTM TO THIS FUNCTION! PASS A PLAIN VECT AND ROT!
function DeusExDecoration AddSwitch(vector loc, rotator rotate, name Event, optional string description)
{
    loc = vectm(loc.X, loc.Y, loc.Z);
    rotate = rotm(rotate.pitch, rotate.yaw, rotate.roll, 16384);
    return _AddSwitch(Self, loc, rotate, Event, description);
}

static function Actor _AddActor(Actor a, class<Actor> c, vector loc, rotator rotate, optional Actor owner, optional Name tag)
{
    local Actor d;
    local bool oldCollideWorld;

    oldCollideWorld = c.default.bCollideWorld;
    c.default.bCollideWorld = false;
    d = a.Spawn(c, owner, tag, loc, rotate );
    if(d == None) {
        return None;
    }

    d.bCollideWorld = false;
    d.SetLocation(loc);
    d.SetRotation(rotate);
    d.bCollideWorld = oldCollideWorld;
    c.default.bCollideWorld = oldCollideWorld;
    return d;
}

//DO NOT ASSUME THIS LIST IS COMPLETE!
//THIS IS UPDATED AS WE ENCOUNTER ISSUES!
//IF SOMETHING ISN'T LISTED HERE AND ISN'T ROTATING CORRECTLY, GET IN THE EDITOR AND DOUBLE CHECK!
//YOU CAN ALSO CHECK THE LIST IN THE unreal-map-flipper REPOSITORY INSIDE MapLibs/actor.py AND LOOK AT THE classes_rot_offsets DICTIONARY!
static function int GetRotationOffset(class<Actor> c)
{
    if(ClassIsChildOf(c, class'Pawn'))
        return 16384;
    if(ClassIsChildOf(c, class'#var(prefix)HackableDevices'))
        return 16384;
    if(ClassIsChildOf(c, class'#var(prefix)Vehicles'))
        return 16384;
    if(ClassIsChildOf(c, class'#var(prefix)ThrownProjectile'))
        return 16384;
    if(ClassIsChildOf(c, class'#var(prefix)WHRedCandleabra'))
        return 16384;
    if(ClassIsChildOf(c, class'#var(prefix)WeaponNanoSword'))
        return 10755;
    if(ClassIsChildOf(c, class'#var(prefix)ComputerSecurity'))
        return 16384;
    if(ClassIsChildOf(c, class'#var(prefix)ComputerPublic'))
        return 16384;
    if(ClassIsChildOf(c, class'ProjectileGenerator'))
        return 16384;
    if(ClassIsChildOf(c, class'#var(prefix)Button1'))
        return 16384;
    //ComputerPersonal is fine without this, so just leave it commented out
    //if(ClassIsChildOf(c, class'#var(prefix)ComputerPersonal'))
    //    return 32768;
    if(ClassIsChildOf(c, class'Brush')) {
        log("WARNING: GetRotationOffset for "$c$", Brushes/Movers have negative scaling so they don't need rotation adjustments!");
        return -1;
    }
    return 0;
}

// DON'T PASS A VECTM OR ROTM TO THIS FUNCTION! PASS A PLAIN VECT AND ROT!
function Actor AddActor(class<Actor> c, vector loc, optional rotator rotate, optional Actor owner, optional Name tag)
{
    local int offset;
    offset = GetRotationOffset(c);
    loc = vectm(loc.X, loc.Y, loc.Z);
    rotate = rotm(rotate.pitch, rotate.yaw, rotate.roll, offset);
    return _AddActor(Self, c, loc, rotate, owner, tag);
}

function Actor Spawnm(class<actor> SpawnClass, optional actor SpawnOwner, optional name SpawnTag, optional vector SpawnLocation, optional rotator SpawnRotation)
{
    local int offset;
    offset = GetRotationOffset(SpawnClass);
    SpawnLocation = vectm(SpawnLocation.X, SpawnLocation.Y, SpawnLocation.Z);
    SpawnRotation = rotm(SpawnRotation.pitch, SpawnRotation.yaw, SpawnRotation.roll, offset);
    return Spawn(SpawnClass, SpawnOwner, SpawnTag, SpawnLocation, SpawnRotation);
}

function #var(prefix)Containers AddBox(class<#var(prefix)Containers> c, vector loc, optional rotator rotate)
{
    local #var(prefix)Containers box;
    box = #var(prefix)Containers(_AddActor(Self, c, loc, rotate));
    box.bInvincible = true;
    box.bIsSecretGoal = true;
    return box;
}

function #var(injectsprefix)InformationDevices SpawnDatacube(vector loc, rotator rot, optional bool dont_move)
{
#ifdef injections
    local #var(prefix)DataCube dc;
    dc = Spawn(class'#var(prefix)DataCube',,, loc, rot);
#else
    local DXRInformationDevices dc;
    dc = Spawn(class'DXRInformationDevices',,, loc, rot);
#endif

    if(dc != None) {
        dc.bIsSecretGoal = dont_move;
        info("SpawnDatacube "$dc$" at ("$loc$"), ("$rot$")");
        if(dxr.flags.settings.infodevices > 0)
            GlowUp(dc);
    } else {
        warning("SpawnDatacube failed at "$loc);
    }
    return dc;
}


function #var(injectsprefix)InformationDevices SpawnDatacubePlaintext(vector loc, rotator rot, string text, optional bool dont_move)
{
    local #var(injectsprefix)InformationDevices dc;

    dc = SpawnDatacube(loc,rot,dont_move);

    if(dc != None) {
        dc.plaintext = text;
    }
    return dc;
}

function #var(injectsprefix)InformationDevices SpawnDatacubeTextTag(vector loc, rotator rot, name texttag, optional bool dont_move)
{
    local #var(injectsprefix)InformationDevices dc;

    dc = SpawnDatacube(loc,rot,dont_move);

    if(dc != None) {
        dc.textTag = texttag;
    }
    return dc;
}

function #var(injectsprefix)InformationDevices SpawnDatacubeImage(vector loc, rotator rot, class<DataVaultImage> imageClass, optional bool dont_move)
{
    local #var(injectsprefix)InformationDevices dc;

    dc = SpawnDatacube(loc,rot,dont_move);

    if(dc != None) {
        dc.imageClass = imageClass;
    }
    return dc;
}

// used by DXRReplaceActors
function Actor SpawnReplacement(Actor a, class<Actor> newclass, optional bool dont_copy_appearance)
{
    local int i;
    local Actor newactor;
    local bool bCollideActors, bBlockActors, bBlockPlayers;
    local name tag, event;

    if(a.class == newclass)
        return None;

    bCollideActors = a.bCollideActors;
    bBlockActors = a.bBlockActors;
    bBlockPlayers = a.bBlockPlayers;
    a.SetCollision(false, false, false);
    tag = a.Tag;
    a.Tag = '';
    event = a.Event;
    a.Event = '';

    newactor = _AddActor(a, newclass, a.Location, a.Rotation, a.Owner, tag);
    if(newactor == None) {
        err("SpawnReplacement("$a$", "$newclass$") failed");
        a.SetCollision(bCollideActors, bBlockActors, bBlockPlayers);
        a.Tag = tag;
        a.Event = event;
        return None;
    }

    l("SpawnReplacement("$a$", "$newclass$") " $ newactor);

    newactor.SetCollision(bCollideActors, bBlockActors, bBlockPlayers);
    newactor.SetPhysics(a.Physics);
    newactor.SetBase(a.Base);
    newactor.Event = event;
    newactor.bHidden = a.bHidden;

    if(!dont_copy_appearance) {
        newactor.SetCollisionSize(a.CollisionRadius, a.CollisionHeight);
        newactor.DrawScale = a.DrawScale;
        newactor.Mass = a.Mass;
        newactor.Buoyancy = a.Buoyancy;
        newactor.Texture = a.Texture;
        newactor.Mesh = a.Mesh;
        for(i=0; i<ArrayCount(a.Multiskins); i++) {
            newactor.Multiskins[i] = a.Multiskins[i];
        }
        newactor.LightType=a.LightType;
        newactor.LightEffect=a.LightEffect;
        newactor.LightBrightness=a.LightBrightness;
        newactor.LightHue=a.LightHue;
        newactor.LightRadius=a.LightRadius;
    }

    if(#defined(hx)){
        newactor.SetPropertyText("PrecessorName", a.GetPropertyText("PrecessorName"));
    }

    return newactor;
}

static function DestroyMover(DeusExMover m)
{
    local DeusExDecal D;

    // force the mover to stop
    if (m.Leader != None)
        m.Leader.MakeGroupStop();

    // destroy all effects that are on us
    foreach m.BasedActors(class'DeusExDecal', D)
        D.Destroy();

    m.DropThings();

    //DEUS_EX AMSD Mover is dead, make it a dumb proxy so location updates
    m.RemoteRole = ROLE_DumbProxy;
    m.SetLocation(m.Location+vect(0,0,20000));		// move it out of the way
    m.SetCollision(False, False, False);			// and make it non-colliding
    m.bDestroyed = True;
}

static function SetActorScale(Actor a, float scale)
{
    local Vector newloc;

    scale *= a.DrawScale;
    newloc = a.Location + ( (a.CollisionHeight*scale - a.CollisionHeight*a.DrawScale) * vect(0,0,1) );
    a.SetCollisionSize(a.CollisionRadius / a.DrawScale * scale, a.CollisionHeight / a.DrawScale * scale);
    a.SetLocation(newloc);
    a.DrawScale = scale;
}

function bool CheckFreeSpace(out vector loc, float radius, float height)
{
    local bool success;

    SetCollisionSize(radius, height);
    SetCollision(true, true, true);
    bCollideWhenPlacing = true;
    bCollideWorld = true;

    success = SetLocation(loc);

    SetCollision(false, false, false);
    bCollideWhenPlacing = false;
    bCollideWorld = false;

    if(!success || VSize(Location - loc) > 128) {
        l("CheckFreeSpace failed for " $ loc);
        return false;
    }
    loc = Location;
    return true;
}

function ZoneInfo GetZone(vector loc)
{
    SetLocation(loc);
    return Region.Zone;
}

function vector GetRandomPosition(optional vector target, optional float mindist, optional float maxdist, optional bool allowWater, optional bool allowPain, optional bool allowSky)
{
    local PathNode temp[4096];
    local PathNode p;
    local int i, num, slot;
    local float dist;

    if( maxdist <= mindist )
        maxdist = 9999999;

    foreach AllActors(class'PathNode', p) {
        if( (!allowSky) && p.Region.Zone.IsA('SkyZoneInfo') ) continue;
        if( (!allowWater) && p.Region.Zone.bWaterZone ) continue;
        if( (!allowPain) && (p.Region.Zone.bKillZone || p.Region.Zone.bPainZone ) ) continue;
        dist = VSize(p.Location-target);
        if( dist < mindist ) continue;
        if( dist > maxdist ) continue;
        temp[num++] = p;
    }
    if( num == 0 ) return target;
    slot = rng(num);
    return temp[slot].Location;
}

function vector JitterPosition(vector loc)
{
    loc.X += rngfn() * 160.0;//10 feet in any direction
    loc.Y += rngfn() * 160.0;
    return loc;
}

function vector GetRandomPositionFine(optional vector target, optional float mindist, optional float maxdist, optional bool allowWater, optional bool allowPain, optional bool allowSky)
{
    local vector loc;
    loc = GetRandomPosition(target, mindist, maxdist, allowWater, allowPain, allowSky);
    loc = JitterPosition(loc);
    return loc;
}

function vector GetCloserPosition(vector target, vector current, optional float maxdist)
{
    local PathNode p;
    local float dist, farthest_dist, dist_move;
    local vector farthest;

    if( maxdist == 0.0 || VSize(target-current) < maxdist )
        maxdist = VSize(target-current);
    farthest = current;
    foreach AllActors(class'PathNode', p) {
        dist = VSize(target-p.Location);
        dist_move = VSize(p.Location-current);//make sure the distance that we're moving is shorter than the distance to the target (aka move forwards, not to the opposite side)
        if( dist > farthest_dist && dist < maxdist && dist > maxdist/2 && dist > dist_move ) {
            farthest_dist = dist;
            farthest = p.Location;
        }
    }
    return farthest;
}

function Actor findNearestToActor(class<Actor> nearestClass, Actor nearThis){
    local Actor thing,nearestThing;

    foreach AllActors(nearestClass,thing) {
        if (nearestThing==None){
            nearestThing = thing;
        } else {
            if ((VSize(nearThis.Location-thing.Location)) < (VSize(nearThis.Location-nearestThing.Location))){
                nearestThing = thing;
            }
        }
    }
    return nearestThing;
}

function RemoveComputerUser(#var(prefix)Computers comp, string userName)
{
    local int i, num;
    // we can't have empty slots in the middle
    for(i=0; i<ArrayCount(comp.userList); i++) {
        if(comp.userList[i].userName ~= userName) {
            comp.userList[i].userName = "";
            comp.userList[i].Password = "";
        }
        if(comp.userList[i].userName == "") continue;
        if(i != num) {
            comp.userList[num] = comp.userList[i];
            comp.userList[i].userName = "";
            comp.userList[i].Password = "";
        }
        num++;
    }
}

function AddComputerUserAt(#var(prefix)Computers comp, string userName, string Password, int slot)
{
    local int i;

    for(i=ArrayCount(comp.userList)-2; i>=slot; i--) {
        comp.userList[i+1] = comp.userList[i];
    }
    comp.userList[slot].userName = userName;
    comp.userList[slot].Password = Password;
}

function RemoveComputerSpecialOption(#var(prefix)Computers comp, Name TriggerEvent)
{
    local int i, num;
    // we can't have empty slots in the middle
    for(i=0; i<ArrayCount(comp.specialOptions); i++) {
        if(comp.specialOptions[i].TriggerEvent == TriggerEvent) {
            comp.specialOptions[i].TriggerEvent = '';
            comp.specialOptions[i].Text = "";
        }
        if(comp.specialOptions[i].Text == "") continue;
        if(i != num) {
            comp.specialOptions[num] = comp.specialOptions[i];
            comp.specialOptions[i].TriggerEvent = '';
            comp.specialOptions[i].Text = "";
        }
        num++;
    }
}

//I could have fuzzy logic and allow these Is___Normal functions to have overlap? or make them more strict where some normals don't classify as any of these?
function bool IsWallNormal(vector n)
{
    return n.Z > -0.5 && n.Z < 0.5;
}

function bool IsFloorNormal(vector n)
{
    return n.Z > 0.5;
}

function bool IsCeilingNormal(vector n)
{
    return n.Z < -0.5;
}

function bool NearestSurface(vector StartTrace, vector EndTrace, out LocationNormal ret)
{
    local Actor HitActor;
    local vector HitLocation, HitNormal;

    HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
    if( StartTrace == HitLocation ) {
        return false;
    }
    if ( HitActor == Level ) {
        ret.loc = HitLocation;
        ret.norm = HitNormal;
        return true;
    }
    return false;
}

function float GetDistanceFromSurface(vector StartTrace, vector EndTrace)
{
    local LocationNormal locnorm;
    locnorm.loc = EndTrace;
    NearestSurface(StartTrace, EndTrace, locnorm);
    return VSize( StartTrace - locnorm.loc );
}

function bool NearestCeiling(out LocationNormal out, FMinMax distrange, optional float away_from_wall)
{
    local vector EndTrace, MoveOffWall;
    EndTrace = out.loc;
    EndTrace.Z += distrange.max;
    if( NearestSurface(out.loc + (vect(0,0,1)*distrange.min), EndTrace, out) == false ) {
        return false;
    }
    if( ! IsCeilingNormal(out.norm) ) {
        return false;
    }
    MoveOffWall.X = away_from_wall;
    MoveOffWall.Y = away_from_wall;
    MoveOffWall.Z = away_from_wall;
    MoveOffWall *= out.norm;
    out.loc += MoveOffWall;
    return true;
}

function bool NearestFloor(out LocationNormal out, FMinMax distrange, optional float away_from_wall)
{
    local vector EndTrace, MoveOffWall;
    EndTrace = out.loc;
    EndTrace.Z -= distrange.max;
    if( NearestSurface(out.loc - (vect(0,0,1)*distrange.min), EndTrace, out) == false ) {
        return false;
    }
    if( ! IsFloorNormal(out.norm) ) {
        return false;
    }
    MoveOffWall.X = away_from_wall;
    MoveOffWall.Y = away_from_wall;
    MoveOffWall.Z = away_from_wall;
    MoveOffWall *= out.norm;
    out.loc += MoveOffWall;
    return true;
}

function bool _FindWallAlongNormal(out LocationNormal out, vector against, FMinMax distrange)
{
    local LocationNormal t, ret;
    local vector end, along;
    local float closest_dist, dist;
    local int i;

    closest_dist = distrange.max;
    along = Normal(against cross vect(0, 0, 1));

    for(i=0; i<2; i++) {
        end = out.loc;
        along *= -1;//negative first and then positive
        end += along * closest_dist;
        t = out;
        t.loc += along * distrange.min;
        if( NearestSurface(t.loc, end, t) ) {
            if( IsWallNormal(t.norm) ) {
                ret = t;
                dist = VSize(t.loc - out.loc);
                closest_dist = dist;
            }
        }
    }

    if( closest_dist >= distrange.max ) {
        return false;
    }
    out = ret;
    return true;
}

function bool _NearestWall(out LocationNormal out, FMinMax distrange)
{
    local LocationNormal t, ret;
    local vector along;
    local float closest_dist, dist;
    local int i;

    closest_dist = distrange.max;
    along = vect(1,0,0);//first we do the X axis

    for(i=0; i<2; i++) {
        t = out;
        if( _FindWallAlongNormal(t, along, distrange) ) {
            dist = VSize(t.loc - out.loc);
            if( dist < closest_dist ) {
                ret = t;
                closest_dist = dist;
            }
        }
        along = vect(0,1,0);//next we do the Y axis
    }

    if( closest_dist >= distrange.max ) {
        return false;
    }
    out = ret;
    return true;
}

function bool NearestWall(out LocationNormal out, FMinMax distrange, optional float away_from_wall)
{
    local vector MoveOffWall, normal;

    if( _NearestWall(out, distrange) == false ) {
        return false;
    }
    MoveOffWall.X = away_from_wall;
    MoveOffWall.Y = away_from_wall;
    MoveOffWall.Z = away_from_wall;
    MoveOffWall *= out.norm;
    out.loc += MoveOffWall;
    return true;
}

function bool NearestWallSearchZ(out LocationNormal out, FMinMax distrange, float z_range, vector target, optional float away_from_wall)
{
    local LocationNormal wall, ret;
    local vector MoveOffWall;
    local float closest_dist, dist;
    local int i;
    local float len;

    closest_dist = distrange.max;
    len = 4.0;// 4 checks plus the center
    for(i=0; i<5; i++) {
        wall = out;
        wall.loc.Z += z_range * (Float(i) / len * 2.0 - 1.0);
        if( _NearestWall(wall, distrange) ) {
            dist = VSize(wall.loc - target);
            if( dist < closest_dist && dist >= distrange.min ) {
                closest_dist = dist;
                ret = wall;
            }
        }
    }

    if( closest_dist >= distrange.max ) {
        return false;
    }
    MoveOffWall.X = away_from_wall;
    MoveOffWall.Y = away_from_wall;
    MoveOffWall.Z = away_from_wall;
    MoveOffWall *= ret.norm;
    ret.loc += MoveOffWall;
    out = ret;
    return true;
}

function bool NearestCornerSearchZ(out LocationNormal out, FMinMax distrange, vector against, float z_range, vector target, optional float away_from_wall)
{
    local LocationNormal wall, ret;
    local vector MoveOffWall;
    local float closest_dist, dist;
    local int i;
    local float len;

    closest_dist = distrange.max;
    len = 4.0;// 4 checks plus the center
    for(i=0; i<5; i++) {
        wall = out;
        wall.loc.Z += z_range * (Float(i) / len * 2.0 - 1.0);
        if( _FindWallAlongNormal(wall, against, distrange) ) {
            dist = VSize(wall.loc - target);
            if( dist < closest_dist && dist >= distrange.min ) {
                closest_dist = dist;
                ret = wall;
            }
        }
    }

    if( closest_dist >= distrange.max ) {
        return false;
    }
    MoveOffWall.X = away_from_wall;
    MoveOffWall.Y = away_from_wall;
    MoveOffWall.Z = away_from_wall;
    MoveOffWall *= ret.norm;
    ret.loc += MoveOffWall;
    out = ret;
    return true;
}

function Vector GetCenter(Actor test)
{
    local Vector MinVect, MaxVect;

    test.GetBoundingBox(MinVect, MaxVect);
    return (MinVect+MaxVect)/2;
}

function safe_rule FixSafeRule(safe_rule r)
{
    local float a, b;
    r.min_pos *= coords_mult;
    r.max_pos *= coords_mult;

    a = FMin(r.min_pos.X, r.max_pos.X);
    b = FMax(r.min_pos.X, r.max_pos.X);
    r.min_pos.X = a;
    r.max_pos.X = b;

    a = FMin(r.min_pos.Y, r.max_pos.Y);
    b = FMax(r.min_pos.Y, r.max_pos.Y);
    r.min_pos.Y = a;
    r.max_pos.Y = b;

    a = FMin(r.min_pos.Z, r.max_pos.Z);
    b = FMax(r.min_pos.Z, r.max_pos.Z);
    r.min_pos.Z = a;
    r.max_pos.Z = b;

    return r;
}

function int GetSafeRule(safe_rule rules[16], name item_name, vector newpos)
{
    local int i;

    for(i=0; i<ArrayCount(rules); i++) {
        if( item_name != rules[i].item_name ) continue;
        if( AnyGreater( rules[i].min_pos, newpos ) ) continue;
        if( AnyGreater( newpos, rules[i].max_pos ) ) continue;
        return i;
    }
    return -1;
}

function bool _PositionIsSafeOctant(Vector oldloc, Vector TestPoint, Vector newloc)
{
    local Vector distsold, diststest, distsoldtest;
    //l("results += testbool( _PositionIsSafeOctant(vect("$oldloc$"), vect("$ TestPoint $"), vect("$newloc$")), truefalse, \"test\");");
    distsoldtest = AbsEach(oldloc - TestPoint);
    distsold = AbsEach(newloc - oldloc) - (distsoldtest*0.999);
    diststest = AbsEach(newloc - TestPoint);
    if ( AnyGreater( distsold, diststest ) ) return False;
    return True;
}

function bool PositionIsSafe(Vector oldloc, Actor test, Vector newloc)
{// https://github.com/Die4Ever/deus-ex-randomizer/wiki#smarter-key-randomization
    local Vector TestPoint;
    local float distold, disttest;

    TestPoint = GetCenter(test);

    distold = VSize(newloc - oldloc);
    disttest = VSize(newloc - TestPoint);

    return _PositionIsSafeOctant(oldloc, TestPoint, newloc);
}

function bool PositionIsSafeLenient(Vector oldloc, Actor test, Vector newloc)
{// https://github.com/Die4Ever/deus-ex-randomizer/wiki#smarter-key-randomization
    return _PositionIsSafeOctant(oldloc, GetCenter(test), newloc);
}

static function GlowUp(Actor a, optional byte hue, optional byte saturation)
{
    a.LightType=LT_Steady;
    a.LightEffect=LE_None;
    a.LightBrightness=160;
    if(hue == 0) hue = 155;
    a.LightHue=hue;
    if(saturation !=0) a.LightSaturation=saturation;
    a.LightRadius=6;
}

function DebugMarkKeyActor(Actor a, coerce string id)
{
    local ActorDisplayWindow actorDisplay;
    if( ! #defined(debug)) {
        err("Don't call DebugMarkKeyActor without debug mode! Add debug to the compiler_settings.default.json file");
        return;
    }

    if(DeusExDecoration(a) != None) {
        DeusExDecoration(a).ItemName = id @ DeusExDecoration(a).ItemName;
    } else if(Inventory(a) != None) {
        Inventory(a).ItemName = id @ Inventory(a).ItemName;
    } else if(DXRGoalMarker(a) != None) {
        a.BindName = id;
        a.bHidden = False;
    }
    GlowUp(a);
    debug("DebugMarkKeyActor "$a$ " ("$a.Location$") " $ id);

    actorDisplay = DeusExRootWindow(player().rootWindow).actorDisplay;
    actorDisplay.SetViewClass(a.class);
    actorDisplay.ShowLOS(false);
    actorDisplay.ShowPos(true);
}

function DebugMarkKeyPosition(vector pos, coerce string id)
{
    local ActorDisplayWindow actorDisplay;
    local Actor a;
    if( ! #defined(debug)) {
        err("Don't call DebugMarkKeyPosition without debug mode! Add debug to the compiler_settings.default.json file");
        return;
    }

    a = Spawn(class'DXRGoalMarker',,,pos);
    DebugMarkKeyActor(a, id);
}

static function bool IsNonlethal(coerce string damageType)
{
    return (damageType == "Stunned") || (damageType == "KnockedOut") || (damageType == "Poison") || (damageType == "PoisonEffect");
}

// returns true if the damage type can knock the pawn out
static function bool CanKnockUnconscious(ScriptedPawn sp, coerce string damageType)
{
    if (#defined(injections)) {
        return sp.mass > 5.0 && IsNonlethal(damageType) && (Animal(sp) != None || IsHuman(sp.class));
    } else {
        return IsNonlethal(damageType) && IsHuman(sp.class);
    }
}

static function LogInventory(Actor actor)
{
    local Inventory item;

    log(actor.class @ actor @ actor.bindname $ " inventory:");
    for (item = actor.inventory; item != None; item = item.inventory) {
        log("  " $ item);
    }
}

static function bool ChangeInitialAlliance(ScriptedPawn pawn, Name allianceName, float allianceLevel, bool bPermanent) {
    local int i;

    for (i = 0; i < ArrayCount(pawn.InitialAlliances); i++) {
		if ((pawn.InitialAlliances[i].AllianceName == allianceName) || (pawn.InitialAlliances[i].AllianceName == ''))
			break;
    }
    if (i == ArrayCount(pawn.InitialAlliances))
        return false;

    pawn.InitialAlliances[i].AllianceName = allianceName;
    pawn.InitialAlliances[i].AllianceLevel = FClamp(allianceLevel, -1.0, 1.0);
    pawn.InitialAlliances[i].bPermanent = bPermanent;

    return true;
}
