class DXRHalloween extends DXRActorsBase;

var #var(DeusExPrefix)Carcass carcs[256];
var float times[256];
var int num_carcs;

function FirstEntry()
{
    local #var(prefix)WHPiano piano;
    Super.FirstEntry();

    if(dxr.flags.IsHalloweenMode()) {
        // Mr. X is only for the Halloween game mode, but other things will instead be controlled by IsOctober(), such as cosmetic changes
        class'MrX'.static.Create(self);
    }
    if(IsOctober()) {
        foreach AllActors(class'#var(prefix)WHPiano', piano) {
            piano.ItemName = "Staufway Piano";
        }
        MakeSpiderWebs();
    }
}

function ReEntry(bool IsTravel)
{
    if(IsTravel && dxr.flags.IsHalloweenMode()) {
        // recreate him if you leave the map and come back, but not if you load a save
        class'MrX'.static.Create(self);
    }
}

function AnyEntry()
{
    Super.AnyEntry();
    if(dxr.flags.IsHalloweenMode()) {
        SetTimer(1.0, true);
    }
}

function Timer()
{
    Super.Timer();
    if( dxr == None ) return;
    if(dxr.flags.IsHalloweenMode()) {
        CheckCarcasses();
    }
}

function CheckCarcasses()
{
    local int i;
    local #var(DeusExPrefix)Carcass carc;

    for(i=0; i < num_carcs; i++) {
        if(CheckResurrectCorpse(carcs[i], times[i])) {
            // compress the array
            num_carcs--;
            carcs[i] = carcs[num_carcs];
            times[i] = times[num_carcs];
            i--;// repeat this iteration
            continue;
        }
    }

    foreach AllActors(class'#var(DeusExPrefix)Carcass', carc) {
        if(#var(prefix)RatCarcass(carc) != None || #var(prefix)PigeonCarcass(carc) != None || #var(prefix)SeagullCarcass(carc) != None || #var(prefix)CatCarcass(carc) != None) {
            // skip critter carcasses, TODO: maybe find the PawnGenerator and increase its PawnCount so we can have zombie rats and birds without there being infinity of them? or track a maximum number of zombie critters here? cats have an override on the Attacking state
            continue;
        }
        for(i=0; i < num_carcs; i++) {
            if(carcs[i] == carc) {
                break;
            }
        }
        if(carcs[i] != carc) {
            carcs[num_carcs] = carc;
            times[num_carcs] = Level.TimeSeconds;
            carc.MaxDamage = 0.1 * carc.Mass;// easier to destroy carcasses
            num_carcs++;
        }
    }
}

function bool CheckResurrectCorpse(#var(DeusExPrefix)Carcass carc, float time)
{
    local float ZombieTime;

    // return true to compress the array
    if(carc == None) return true;

    ZombieTime = 20;
    if(#var(prefix)MuttCarcass(carc) != None || #var(prefix)DobermanCarcass(carc) != None) {
        // special sauce for dogs?
        ZombieTime = 2;
    }

    // wait for Zombie Time!
    if(time + ZombieTime > Level.TimeSeconds) return false;

    return ResurrectCorpse(self, carc);
}

static function bool ResurrectCorpse(DXRActorsBase module, #var(DeusExPrefix)Carcass carc, optional String pawnname)
{
    local string livingClassName;
    local class<Actor> livingClass;
    local vector respawnLoc;
    local ScriptedPawn sp,otherSP;
    local int i;
    local Inventory item, nextItem;
    local bool removeItem;

    //At least in vanilla, all carcasses are the original class name + Carcass
    livingClassName = string(carc.class.Name);
    livingClassName = module.ReplaceText(livingClassName,"Carcass","");

    livingClass = module.GetClassFromString(livingClassName,class'ScriptedPawn');

    if (livingClass==None){
        module.warning("ResurrectCorpse " $ carc $ " failed livingClass==None");
        return False;
    }

    respawnLoc = carc.Location;
    respawnLoc.Z += livingClass.Default.CollisionHeight;

    sp = ScriptedPawn(carc.Spawn(livingClass,,,respawnLoc,carc.Rotation));

    if (sp==None){
        module.warning("ResurrectCorpse " $ carc $ " failed sp==None");
        return False;
    }

    if(pawnname != "") {
        sp.FamiliarName = pawnname;
        sp.UnfamiliarName = sp.FamiliarName;
    } else {
        sp.FamiliarName = sp.FamiliarName $ " Zombie";
        sp.UnfamiliarName = sp.FamiliarName;
    }
    sp.bInvincible = false; // If they died, they can't have been invincible
    sp.bImportant = false; // already marked as dead, don't overwrite or destroy on travel
    sp.BindName = "";// Zombies don't talk
    sp.BarkBindName = "";

    sp.DrawScale = carc.DrawScale;
    sp.SetCollisionSize(sp.CollisionRadius*sp.DrawScale, sp.CollisionHeight*sp.DrawScale);
    sp.Fatness = carc.Fatness;

    //Clear out initial inventory (since that should all be in the carcass)
    for (i=0;i<ArrayCount(sp.InitialInventory);i++){
        sp.InitialInventory[i].Inventory=None;
    }

    sp.InitializePawn();

    //Make it hostile to EVERYONE.  This thing has seen the other side
    sp.SetAlliance('Resurrected');
    module.HateEveryone(sp, 'MrX');
    module.RemoveFears(sp);
    if(#var(prefix)Animal(sp) != None) {
        #var(prefix)Animal(sp).bFleeBigPawns = false;
    }
    sp.MinHealth = 0;
    sp.ResetReactions();
    sp.bCanStrafe = false;// messes with melee attack animations, especially on commandos

    //Transfer inventory from carcass back to the pawn
    item = carc.Inventory;
    do
    {
        item = carc.Inventory;
        nextItem = item.Inventory;
        carc.DeleteInventory(item);
        if (DeusExWeapon(item) != None) {// Zombies don't use weapons
            if(DeusExWeapon(item).bNativeAttack) {
                item.Destroy();
            } else {
                module.ThrowItem(item, 0.1);
            }
        }
        else {
            sp.AddInventory(item);
        }
        item = nextItem;
    }
    until (item == None);

    //Give the resurrected guy a zombie swipe (a guaranteed melee weapon)
    module.GiveItem(sp,class'WeaponZombieSwipe');
    sp.bKeepWeaponDrawn=True;

    //Pop out a little meat for fun
    for (i=0; i<10; i++)
    {
        if (FRand() > 0.2)
            carc.spawn(class'FleshFragment',,,carc.Location);
    }

    carc.Destroy();

    return True;
}

function MakeSpiderWebs()
{
    local NavigationPoint p;
    local Light lgt;
    local vector locs[4096];
    local int i, num, slot;

    SetSeed("MakeSpiderWebs");

    foreach AllActors(class'NavigationPoint', p) {
        locs[num++] = p.Location;
        if(rngb()) continue;
        SpawnSpiderweb(p.Location);
    }
    // spiderwebs near lights?
    foreach AllActors(class'Light', lgt) {
        locs[num++] = lgt.Location;
    }
    // random order gives better results
    for(i=0; i<num; i++) {
        slot = rng(num);
        SpawnSpiderweb(locs[slot]);
    }
}

function SpawnSpiderweb(vector loc)
{
    local Spiderweb web;
    local float dist;
    local rotator rot;

    loc.X += rngfn() * 256.0;// 16 feet in either direction
    loc.Y += rngfn() * 256.0;// 16 feet in either direction
    loc.Z += rngf() * 80.0;// 5 feet upwards

    if(!GetSpiderwebLocation(loc, rot)) return;

    foreach RadiusActors(class'Spiderweb', web, 100, loc) {
        dist = VSize(loc-web.Location);
        if(chance_single(100-dist)) return;
    }

    rot.roll = rng(65536);
    web = Spawn(class'Spiderweb',,, loc, rot);
}

function bool GetSpiderwebLocation(out vector loc, out rotator rot)
{
    local bool found_ceiling, found_floor;
    local LocationNormal ceiling, floor, ceiling_or_floor, wall1, wall2;
    local vector norm;
    local float dist, f;
    local FMinMax distrange;

    ceiling.loc = loc;
    floor.loc = loc;
    distrange.min = 0.1;
    distrange.max = 16*100;

    found_ceiling = NearestCeiling(ceiling, distrange, 16);
    found_floor = NearestFloor(floor, distrange, 16);
    //floor.loc.Z += 16*9;

    if(found_ceiling && chance_single(50)) {
        ceiling_or_floor = ceiling;
    } else if(found_floor && chance_single(40)) {
        ceiling_or_floor = floor;
        found_ceiling = false;
    } else if(found_ceiling && found_floor) {
        f = rngf();
        ceiling_or_floor.loc = (ceiling.loc*f) + (floor.loc*(1-f));
        found_ceiling = false;
        found_floor = false;
    } else if(!found_ceiling) {
        f = rngf() * 512;// 32 feet
        loc.Z += f;
        ceiling_or_floor.loc = loc;
        found_ceiling = false;
        found_floor = false;
    } else {
        ceiling_or_floor.loc = loc;
        found_ceiling = false;
        found_floor = false;
    }

    distrange.max = 16*75;
    wall1 = ceiling_or_floor;
    if( ! NearestWallSearchZ(wall1, distrange, 16*3, ceiling_or_floor.loc, 10) ) return false;
    ceiling_or_floor.loc.X = wall1.loc.X;
    ceiling_or_floor.loc.Y = wall1.loc.Y;

    // TODO: ensure ceiling/floor is still with us

    distrange.max = 16*50;
    wall2 = wall1;
    if(chance_single(40) || !NearestCornerSearchZ(wall2, distrange, wall1.norm, 16*3, ceiling_or_floor.loc, 10) ) {
        // just 2 axis (ceiling/floor + wall1)
        rot = Rotator(wall1.norm);
        if( found_ceiling ) rot.pitch -= 4096;
        else if( found_floor ) rot.pitch += 4096;
        loc = wall1.loc;
        return true;
    }

    norm = Normal((wall1.norm + wall2.norm) / 2);

    rot = Rotator(norm);
    if( found_ceiling ) rot.pitch -= 4096;
    else if( found_floor ) rot.pitch += 4096;
    //norm = vector(rot);

    loc = wall2.loc;

    // TODO: ensure wall1 is still with us
    return true;
}

static function MakeGhost(#var(prefix)ScriptedPawn p)
{
    p.Style = STY_Translucent;
    p.ScaleGlow = 0.7;
    p.bHasShadow = false;
    p.KillShadow();

    switch(p.Mesh) {
    case LodMesh'DeusExCharacters.GFM_SuitSkirt':
    case LodMesh'DeusExCharacters.GFM_SuitSkirt_F':
        p.MultiSkins[3] = Texture'DeusExItems.Skins.PinkMaskTex';// remove legs
        p.MultiSkins[6] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        p.MultiSkins[7] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        break;

    case LodMesh'DeusExCharacters.GFM_Dress':
        p.MultiSkins[1] = Texture'DeusExItems.Skins.PinkMaskTex';// remove legs
        break;

    case LodMesh'DeusExCharacters.GFM_Trench':
        p.MultiSkins[2] = Texture'DeusExItems.Skins.PinkMaskTex';// remove legs
        p.MultiSkins[6] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        p.MultiSkins[7] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        break;

    case LodMesh'DeusExCharacters.GFM_TShirtPants':
        p.MultiSkins[6] = Texture'DeusExItems.Skins.PinkMaskTex';// remove legs
        p.MultiSkins[3] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        p.MultiSkins[4] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        break;

    case LodMesh'DeusExCharacters.GM_Trench':
    case LodMesh'DeusExCharacters.GM_Trench_F':
        p.MultiSkins[2] = Texture'DeusExItems.Skins.PinkMaskTex';// remove legs
        p.MultiSkins[6] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        p.MultiSkins[7] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        break;

    case LodMesh'DeusExCharacters.GMK_DressShirt':
    case LodMesh'DeusExCharacters.GMK_DressShirt_F':
        p.MultiSkins[3] = Texture'DeusExItems.Skins.PinkMaskTex';// remove legs
        p.MultiSkins[6] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        p.MultiSkins[7] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        break;

    case LodMesh'DeusExCharacters.GM_Jumpsuit':
        p.MultiSkins[1] = Texture'DeusExItems.Skins.PinkMaskTex';// remove legs
        p.MultiSkins[5] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses/goggles lens
        break;

    case LodMesh'DeusExCharacters.GM_DressShirt':
        p.MultiSkins[3] = Texture'DeusExItems.Skins.PinkMaskTex';// remove legs
        p.MultiSkins[6] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        break;

    //case LodMesh'DeusExCharacters.GM_DressShirt_B':
    case LodMesh'DeusExCharacters.GM_DressShirt_F':
        p.MultiSkins[3] = Texture'DeusExItems.Skins.PinkMaskTex';// remove legs
        p.MultiSkins[6] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        break;

    case LodMesh'DeusExCharacters.GM_DressShirt_S':
        p.MultiSkins[3] = Texture'DeusExItems.Skins.PinkMaskTex';// remove legs
        p.MultiSkins[6] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        p.MultiSkins[7] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        break;

    case LodMesh'DeusExCharacters.GM_Suit':
        p.MultiSkins[1] = Texture'DeusExItems.Skins.PinkMaskTex';// remove legs
        p.MultiSkins[5] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        //p.MultiSkins[7] = Texture'DeusExItems.Skins.PinkMaskTex';// remove glasses
        break;
    }
}
