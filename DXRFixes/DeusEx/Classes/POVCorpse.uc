class DXRPOVCorpse injects POVCorpse;

var float ZombieTime;

function InitFor(DeusExCarcass carc)
{
    carcClassString = String(carc.Class);
    KillerAlliance = carc.KillerAlliance;
    KillerBindName = carc.KillerBindName;
    Alliance = carc.Alliance;
    bNotDead = carc.bNotDead;
    bEmitCarcass = carc.bEmitCarcass;
    CumulativeDamage = carc.CumulativeDamage;
    MaxDamage = carc.MaxDamage;
    CorpseItemName = carc.itemName;
    CarcassName = carc.CarcassName;
    if(!bNotDead)
        ZombieTime = class'DXRHalloween'.static.GetZombieTime(carc);
}

static function POVCorpse Create(DeusExPlayer player, DeusExCarcass carc)
{
    local POVCorpse corpse;

    corpse = carc.Spawn(class'POVCorpse');
    if (corpse == None) return None;

    corpse.InitFor(carc);
    // destroy the actual carcass and put the fake one
    // in the player's hands
    corpse.Frob(player, None);
    corpse.SetBase(player);
    player.PutInHand(corpse);
    carc.bQueuedDestroy=True;

    return corpse;
}

function DeusExCarcass Drop(vector dropVect)
{
    local DeusExCarcass carc;
    local class<DeusExCarcass> carcClass;

    if (carcClassString == "") return None;

    carcClass = class<DeusExCarcass>(DynamicLoadObject(carcClassString, class'Class'));
    if (carcClass == None) return None;

    carc = Owner.Spawn(carcClass);
    if (carc == None) return None;

    carc.Mesh = carc.Mesh2;
    carc.KillerAlliance = KillerAlliance;
    carc.KillerBindName = KillerBindName;
    carc.Alliance = Alliance;
    carc.bNotDead = bNotDead;
    carc.bEmitCarcass = bEmitCarcass;
    carc.CumulativeDamage = CumulativeDamage;
    carc.MaxDamage = MaxDamage;
    carc.itemName = CorpseItemName;
    carc.CarcassName = CarcassName;
    carc.Velocity = Velocity * 0.5;
    Velocity = vect(0,0,0);
    carc.bHidden = False;
    carc.SetPhysics(PHYS_Falling);
    carc.SetScaleGlow();
    if (carc.SetLocation(dropVect))
    {
        if(!bNotDead)
            class'DXRHalloween'.static.SetZombieTime(carc, ZombieTime);
        Destroy();
        return carc;
    }
    else
    {
        carc.bHidden = True;
        carc.Destroy();
        return None;
    }

    return None;
}
