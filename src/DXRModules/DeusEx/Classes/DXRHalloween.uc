class DXRHalloween extends DXRActorsBase transient;

function PostFirstEntry()
{
    local #var(prefix)WHPiano piano;
    Super.PostFirstEntry();

    if(dxr.flags.IsHalloweenMode()) {
        // Mr. H is only for the Halloween game mode, but other things will instead be controlled by IsOctober(), such as cosmetic changes
        if(!dxr.OnTitleScreen()) {
            class'MrH'.static.Create(self);
        }
        MapFixes();
    }
    if(IsOctober()) {
        foreach AllActors(class'#var(prefix)WHPiano', piano) {
            piano.ItemName = "Staufway Piano";
        }
        MakeCosmetics();
    }

    MakeBlackCats(); //Black cats always exist
}

function ReEntry(bool IsTravel)
{
    if(IsTravel && dxr.flags.IsHalloweenMode()) {
        // recreate him if you leave the map and come back, but not if you load a save
        class'MrH'.static.Create(self);
    }
}

function MapFixes()
{
    local PathNode p;
    local #var(DeusExPrefix)Carcass carc;
    local class<#var(DeusExPrefix)Carcass> carcclass;
    local ScriptedPawn sp;
    local float dist;

    switch(dxr.localURL) {
    case "01_NYC_UNATCOHQ":
    case "03_NYC_UNATCOHQ":
    case "04_NYC_UNATCOHQ":
        //Make people fearless so they don't get spooked by Mr. H
        foreach AllActors(class'ScriptedPawn', sp) {
            if(sp.bInvincible) {
                RemoveFears(sp);
            }
        }
        break;
    case "09_NYC_GRAVEYARD":
        SetSeed("DXRHalloween MapFixes graveyard bodies");
        foreach AllActors(class'PathNode', p) {
            // only the region with tombstones
            if(p.Location.Z < 10 || p.Location.Z > 20) continue;
            if(p.Location.X / coords_mult.X > 300) continue;

            // exclude the paved path
            if(p.name=='PathNode26' || p.name=='PathNode12' || p.name=='PathNode70' || p.name=='PathNode69' || p.name=='PathNode68') continue;

            if(chance_single(80)) continue;

            switch(rng(7)){
            case 0:
                carcclass = class'#var(prefix)BumFemaleCarcass';
                break;
            case 1:
                carcclass = class'#var(prefix)BumMale2Carcass';
                break;
            case 2:
                carcclass = class'#var(prefix)BumMale3Carcass';
                break;
            case 3:
                carcclass = class'#var(prefix)BumMaleCarcass';
                break;
            case 4:
                carcclass = class'#var(prefix)JunkieFemaleCarcass';
                break;
            case 5:
                carcclass = class'#var(prefix)JunkieMaleCarcass';
                break;
            case 6:
                carcclass = class'#var(prefix)Female4Carcass';
                break;
            default:
                carcclass = class'#var(prefix)BumMaleCarcass';
                break;
            }
            carc = spawn(carcclass,, 'ForceZombie', p.Location);
            if(carc==None) continue;
            carc.bHidden = true;// ForceZombie tag allows zombies to spawn out of hidden and bNotDead carcasses
            carc.bNotDead=true;// prevent blood
            RandomizeSize(carc);
            class'DXRNames'.static.GiveRandomCarcassName(dxr, carc);
        }
        break;
    }
}

function MakeCosmetics()
{
    local NavigationPoint p;
    local Light lgt;
    local vector locs[4096];
    local int i, num, len, slot;
    local SkyZoneInfo z;
    local #var(DeusExPrefix)Carcass carc;

    foreach AllActors(class'SkyZoneInfo', z) {
        z.AmbientBrightness = 5;
        z.AmbientSaturation = 100;
        z.AmbientHue = 255;
    }

    foreach AllActors(class'NavigationPoint', p) {
        if(p.Region.Zone.bWaterZone) continue;
        locs[len++] = p.Location;
    }

    SetSeed("MakeJackOLanterns");
    ConsoleCommand("set DXRJackOLantern bBlockActors " $ (!dxr.flags.IsSpeedrunMode()));
    ConsoleCommand("set DXRJackOLantern bBlockPlayers " $ (!dxr.flags.IsSpeedrunMode()));
    if(IsHalloween()) num = len/30;
    else num = len/30 * Level.Day/40;// divided by 40 instead of 31 to make it weaker
    for(i=0; i<num; i++) {
        slot = rng(len);
        SpawnJackOLantern(locs[slot]);
    }

    // spiderwebs near lights?
    foreach AllActors(class'Light', lgt) {
        if(lgt.Region.Zone.bWaterZone) continue;
        locs[len++] = lgt.Location;
    }

    SetSeed("MakeSpiderWebs");
    // random order gives better results
    if(IsHalloween()) num = len/2;
    else num = len/2 * Level.Day/40;// divided by 40 instead of 31 to make it weaker
    for(i=0; i<num; i++) {
        slot = rng(len);
        SpawnSpiderweb(locs[slot]);
    }
}

function MakeBlackCats()
{
    local #var(prefix)Cat cat;
    local #var(prefix)CatCarcass catCarc;
    local float catChance;

    SetSeed("MakeBlackCats");

    if (IsFridayThe13th())                catChance = 50.0;
    else if (dxr.flags.IsHalloweenMode()) catChance = 30.0;
    else if (IsOctober())                 catChance = 10.0;
    else                                  catChance =  1.0;

    //Chance to convert living cats
    foreach AllActors(class'#var(prefix)Cat',cat){
        if (!chance_single(catChance)) continue;
        class'BlackCat'.static.ConvertNormalCat(cat);
    }

    //Chance to convert dead cats
    foreach AllActors(class'#var(prefix)CatCarcass',catCarc){
        if (!chance_single(catChance)) continue;
        class'BlackCatCarcass'.static.ConvertNormalCat(catCarc);
    }
}

function SpawnJackOLantern(vector loc)
{
    local DXRJackOLantern jacko;
    local LocationNormal floor, wall1;
    local FMinMax distrange;
    local float size;
    local Rotator r, r2;
    local int i, num;
    local ZoneInfo zone;

    loc.X += rngfn() * 256.0;// 16 feet in either direction
    loc.Y += rngfn() * 256.0;// 16 feet in either direction
    loc.Z += rngf() * 80.0;// 5 feet upwards (this can make them end up above counters and stuff where there aren't normally PathNodes)

    floor.loc = loc;
    distrange.min = 0.1;
    distrange.max = 16*100;
    size = rngf() + 0.6;

    if(!NearestFloor(floor, distrange, size)) return;

    distrange.max = 16*75;
    wall1 = floor;
    if( ! NearestWallSearchZ(wall1, distrange, 16*3, floor.loc, size) ) return;

    zone = GetZone(wall1.loc);
    if (zone.bWaterZone || SkyZoneInfo(zone)!=None){
        //No underwater or skybox Jack O Lanterns
        return;
    }

    r.Yaw = Rotator(wall1.norm).Yaw;
    jacko = spawn(class'DXRJackOLantern',,, wall1.loc, r);
    if(jacko == None) return;
    jacko.DrawScale *= size;
    jacko.SetCollisionSize(jacko.CollisionRadius*size,jacko.CollisionHeight*size);

    num = rng(6);
    for(i=0; i<num; i++) {
        r2.Yaw = rng(20000) - 10000;
        loc = wall1.loc + (wall1.norm << r2) * 64;
        jacko = spawn(class'DXRJackOLantern',,, loc, r);
        if(jacko == None) continue;
        size = rngf() + 0.6;
        jacko.DrawScale *= size;
        jacko.SetCollisionSize(jacko.CollisionRadius*size, jacko.CollisionHeight*size);
    }
}

function SpawnSpiderweb(vector loc)
{
    local Spiderweb web;
    local float dist, size;
    local rotator rot;
    local ZoneInfo zone;
    local class<Spiderweb> webClass;
    // Used for texture trace
    local vector  EndTrace, StartTrace, HitLocation, HitNormal;
    local actor   target;
    local int     texFlags;
    local name    texName, texGroup;
    local bool    bInvisibleWall;

    loc.X += rngfn() * 256.0;// 16 feet in either direction
    loc.Y += rngfn() * 256.0;// 16 feet in either direction
    loc.Z += rngf() * 80.0;// 5 feet upwards

    size = rngf() + 0.5;
    if(!GetSpiderwebLocation(loc, rot, size * 12)) return;

    zone = GetZone(loc);
    if (zone.bWaterZone || SkyZoneInfo(zone)!=None){
        //No underwater or skybox spiderwebs
        return;
    }

    foreach RadiusActors(class'Spiderweb', web, 100, loc) {
        dist = VSize(loc-web.Location);
        if(chance_single(100-dist)) return;
    }

    EndTrace = loc + vector(rot) * -32;
    foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace, loc) {
        if ((texFlags & 0x81) !=0) { // 1 = PF_Invisible, 0x80 == PF_FakeBackdrop
            return;
        }
        break;
    }
    if(target == None) return;

    rot.roll = rng(65536);

    switch(rng(3)){
        case 0: webClass=class'Spiderweb1'; break;
        case 1: webClass=class'Spiderweb2'; break;
        case 2: webClass=class'Spiderweb3'; break;
        default: webClass=class'Spiderweb1'; break; //just in case
    }
    web = Spawn(webClass,,, loc, rot);
    web.DrawScale = size;
    if(Mover(target)!=None) web.SetBase(target);
}

function bool GetSpiderwebLocation(out vector loc, out rotator rot, float size)
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

    found_ceiling = NearestCeiling(ceiling, distrange, size);
    found_floor = NearestFloor(floor, distrange, size);
    //floor.loc.Z += size*9;

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
    if( ! NearestWallSearchZ(wall1, distrange, 16*3, ceiling_or_floor.loc, size) ) return false;
    ceiling_or_floor.loc.X = wall1.loc.X;
    ceiling_or_floor.loc.Y = wall1.loc.Y;

    distrange.max = 16*50;
    wall2 = wall1;
    if(chance_single(40) || !NearestCornerSearchZ(wall2, distrange, wall1.norm, 16*3, ceiling_or_floor.loc, size) ) {
        // just 2 axis (ceiling/floor + wall1)
        loc = wall1.loc;
        rot = Rotator(wall1.norm);

        // ensure ceiling/floor is still with us
        distrange.max = size * 2;
        if(found_ceiling) {
            ceiling.loc = loc;
            found_ceiling = NearestCeiling(ceiling, distrange);
        }
        if(found_floor) {
            floor.loc = loc;
            found_floor = NearestFloor(floor, distrange);
        }

        if( found_ceiling ) rot.pitch -= 4096;
        else if( found_floor ) rot.pitch += 4096;
        else loc -= wall1.norm * (size * 0.9);

        return true;
    }

    loc = wall2.loc;

    // ensure wall1 is still with us
    distrange.max = size*2;
    wall1.loc = wall2.loc - (wall1.norm*(size*2));
    if(Trace(wall1.loc, wall1.norm, wall1.loc, loc, false, vect(1,1,1))==None) {
        norm = wall2.norm;
    } else {
        norm = Normal((wall1.norm + wall2.norm) / 2);
    }

    rot = Rotator(norm);

    // ensure ceiling/floor is still with us
    distrange.max = size*2;
    if(found_ceiling) {
        ceiling.loc = loc;
        found_ceiling = NearestCeiling(ceiling, distrange);
    }
    if(found_floor) {
        floor.loc = loc;
        found_floor = NearestFloor(floor, distrange);
    }

    if( found_ceiling ) rot.pitch -= 4096;
    else if( found_floor ) rot.pitch += 4096;
    else if(norm == wall2.norm) loc -= wall2.norm * (size * 0.9);

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
