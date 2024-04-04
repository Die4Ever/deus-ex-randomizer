class DXRMachines extends DXRActorsBase transient;

var int max_turrets;
var int turret_move_min_distance;
var int turret_move_max_distance;
var int max_datacube_distance;
var int min_datacube_distance;
var int camera_swing_angle;
var int camera_fov;
var int camera_range;
var int camera_swing_period;
var int camera_ceiling_pitch;

function CheckConfig()
{
    max_turrets = 4;
    turret_move_min_distance = 10*16;
    turret_move_max_distance = 500*16;
    max_datacube_distance = 200*16;
    min_datacube_distance = 75*16;
    camera_swing_angle = 8192;
    camera_fov = 5000;//default is 4096
    camera_range = 100*16;//default is 1024 aka 64 feet
    camera_swing_period = 8;//seconds?
    camera_ceiling_pitch = -4000;//the angle to look down when against a ceiling

    Super.CheckConfig();
}

function FirstEntry()
{
    Super.FirstEntry();
    RandoMedBotsRepairBots(dxr.flags.settings.medbots, dxr.flags.moresettings.empty_medbots, dxr.flags.settings.repairbots);
    RandoMedRepairBotAmountCooldowns(dxr.flags.settings.medbotamount,dxr.flags.settings.repairbotamount,dxr.flags.settings.medbotcooldowns,dxr.flags.settings.repairbotcooldowns);
    RandoTurrets(dxr.flags.settings.turrets_move, dxr.flags.settings.turrets_add);
}

function RandoTurrets(int percent_move, int percent_add)
{
    local #var(prefix)AutoTurret t;
    local #var(prefix)SecurityCamera cam;
    local #var(injectsprefix)ComputerSecurity c;
    local int i, hostile_turrets, t_max_turrets;
    local vector loc;

    SetSeed( "RandoTurrets move" );

    foreach AllActors(class'#var(prefix)AutoTurret', t) {
        if( t.bTrackPlayersOnly==true || t.bTrackPawnsOnly==false ) hostile_turrets++;
        if( chance_single(percent_move) == false ) continue;

        loc = GetRandomPositionFine(t.Location, turret_move_min_distance, turret_move_max_distance);
        if( class'DXRMissions'.static.IsCloseToStart(dxr, loc) ) {
            info("RandoTurret move "$loc$" is too close to start!");
            continue;
        }
        info("RandoTurret move "$t$" to near "$loc);
        cam = GetCameraForTurret(t);
        if( cam == None ) continue;
        if( ! MoveCamera(cam, loc) ) continue;
        MoveTurret(t, loc);
    }

    if( hostile_turrets == 0 ) return;

    SetSeed( "RandoTurrets add" );

    t_max_turrets = (percent_add+150) / 100;
    for(i=0; i < t_max_turrets ; i++) {
        if( chance_single(percent_add/t_max_turrets) == false ) continue;

        loc = GetRandomPositionFine();
        if( class'DXRMissions'.static.IsCloseToStart(dxr, loc) ) {
            info("RandoTurret add "$loc$" is too close to start!");
            continue;
        }
        info("RandoTurret add near "$loc);
        cam = SpawnCamera(loc);
        if( cam == None ) continue;
        t = SpawnTurret(loc);
        c = SpawnSecurityComputer(loc, t, cam);
        if( c != None ) {
            loc = GetRandomPosition(loc, min_datacube_distance, max_datacube_distance);
            SpawnDatacubeForComputer(loc, c);
        }
    }
}

function bool GetTurretLocation(out vector loc, out rotator rotation)
{
    local LocationNormal locnorm;
    local FMinMax distrange;
    locnorm.loc = loc;
    distrange.max = 16*50;

    locnorm.loc = JitterPosition(loc);
    if( ! NearestCeiling(locnorm, distrange) )
    {
        if( ! NearestFloor(locnorm, distrange) ) return false;
    }

    rotation = Rotator(locnorm.norm);
    rotation.pitch -= 16384;
    loc = locnorm.loc;
    return true;
}

function MoveTurret(#var(prefix)AutoTurret t, vector loc)
{
    local rotator rotation;
    local Vector v1, v2;
    local Rotator rot;

    if( ! GetTurretLocation(loc, rotation) ) {
        warning("MoveTurret failed to GetTurretLocation at "$loc);
        return;
    }

    t.SetLocation(loc);
    t.SetRotation(rotation);

    //to move AutoTurretGun, copied from AutoTurret.uc PreBeginPlay()
    rot = t.Rotation;
    rot.Pitch = 0;
    rot.Roll = 0;
    // HACK: for GMDX v10
    t.SetPropertyText("origRot", "(Pitch="$rot.Pitch$",Yaw="$rot.Yaw$",Roll="$rot.Roll$")");
    v1.X = 0;
    v1.Y = 0;
    v1.Z = t.CollisionHeight + t.gun.Default.CollisionHeight;
    v2 = v1 >> t.Rotation;
    v2 += t.Location;
    t.gun.SetLocation(v2);
    t.gun.SetBase(t);
}

function #var(prefix)AutoTurret SpawnTurret(vector loc)
{
    local #var(prefix)AutoTurret t;
    local rotator rotation;

    if( ! GetTurretLocation(loc, rotation) ) {
        warning("SpawnTurret failed to GetTurretLocation at "$loc);
        return None;
    }

    t = Spawn(class'#var(prefix)AutoTurret',,, loc, rotation);
    if( t == None ) {
        warning("SpawnTurret failed at "$loc);
        return None;
    }
    t.Tag = t.Name;
    t.bActive = false;
    t.bTrackPawnsOnly = false;
    t.bTrackPlayersOnly = true;
    t.maxRange = t.maxRange * 2;
    t.fireRate *= 0.9;// lower numbers are stronger
    t.gunAccuracy *= 0.8;// lower numbers are stronger
    class'DXRPasswords'.static.RandoHackable(dxr, t.gun);
    info("SpawnTurret "$t$" done at ("$loc$"), ("$rotation$")");
    return t;
}

function #var(prefix)SecurityCamera GetCameraForTurret(#var(prefix)AutoTurret t)
{
    local #var(prefix)ComputerSecurity comp;
    local #var(prefix)SecurityCamera cam;
    local int i;

    foreach AllActors(class'#var(prefix)ComputerSecurity',comp)
    {
        for (i = 0; i < ArrayCount(comp.Views); i++)
        {
            if (comp.Views[i].turretTag == t.Tag)
            {
                foreach AllActors(class'#var(prefix)SecurityCamera', cam, comp.Views[i].cameraTag) {
                    return cam;
                }
            }
        }
    }
    warning("GetCameraForTurret failed to find camera for turret "$t);
    return None;
}

function bool GetCameraLocation(out vector loc, out rotator rotation)
{
    local bool found_ceiling;
    local LocationNormal locnorm, ceiling, wall1;
    local vector norm, flipped_norm;
    local rotator temp_rot, temp_rot_flipped;
    local float dist, flipped_dist;
    local FMinMax distrange;
    locnorm.loc = loc;
    distrange.min = 0.1;
    distrange.max = 16*100;

    if( NearestCeiling(locnorm, distrange, 16) ) {
        found_ceiling = true;
        ceiling = locnorm;
    } else {
        if( ! NearestFloor(locnorm, distrange, 16) ) return false;
        locnorm.loc.Z += 16*3;
        ceiling = locnorm;
        ceiling.loc.Z += 16*6;
    }
    distrange.max = 16*75;
    if( ! NearestWallSearchZ(locnorm, distrange, 16*3, ceiling.loc, 10) ) return false;
    ceiling.loc.X = locnorm.loc.X;
    ceiling.loc.Y = locnorm.loc.Y;
    wall1 = locnorm;
    distrange.max = 16*50;
    if( ! NearestCornerSearchZ(locnorm, distrange, wall1.norm, 16*3, ceiling.loc, 10) ) return false;

    norm = Normal((locnorm.norm + wall1.norm) / 2);
    flipped_norm = Normal(norm*vect(-1,-1,1));

    distrange.max = 16*30;
    found_ceiling = NearestCeiling(locnorm, distrange, 16);

    temp_rot = Rotator(norm);
    if( found_ceiling ) temp_rot.pitch += camera_ceiling_pitch;
    norm = vector(temp_rot);

    temp_rot_flipped = Rotator(flipped_norm);
    if( found_ceiling ) temp_rot_flipped.pitch += camera_ceiling_pitch;
    flipped_norm = vector(temp_rot_flipped);

    dist = GetDistanceFromSurface( locnorm.loc, locnorm.loc+(norm*50) );
    flipped_dist = GetDistanceFromSurface( locnorm.loc, locnorm.loc+(flipped_norm*40) );
    if( dist < 32 && flipped_dist < 32 ) {
        return false;
    }
    if( dist < flipped_dist ) {
        l("GetCameraLocation GetDistanceFromSurface facing wall! "$dist$", "$flipped_dist );
        norm = flipped_norm;
        rotation = temp_rot_flipped;
    } else {
        rotation = temp_rot;
    }

    loc = locnorm.loc;
    return true;
}

function bool GetLazyCameraLocation(out vector loc, int max_range)
{
    local LocationNormal locnorm, ceiling;
    local FMinMax distrange;
    local float mult;
    local Vector loc2;
    locnorm.loc = loc;
    distrange.min = 0.1;
    distrange.max = 16*max_range;

    if( NearestCeiling(locnorm, distrange, 16) ) {
        ceiling = locnorm;
    } else {
        if( ! NearestFloor(locnorm, distrange, 16) ) return false;
        locnorm.loc.Z += 16*3;
        ceiling = locnorm;
        ceiling.loc.Z += 16*6;
    }
    distrange.max = 16*75;
    if( ! NearestWallSearchZ(locnorm, distrange, 16*3, ceiling.loc, 10) ) return false;

    if (VSize(locnorm.loc-loc)>(max_range)){
        mult = (float(max_range)) / VSize(locnorm.loc-loc);
        loc2 = (locnorm.loc-loc) * mult;
        locnorm.loc = loc + loc2;
    }

    loc = locnorm.loc;

    return true;
}


function bool MoveCamera(#var(prefix)SecurityCamera c, vector loc)
{
    local rotator rotation;
    local int i;
    local bool success;

    if( GetCameraLocation(loc, rotation) == false ) {
        warning("MoveCamera("$loc$") "$c$" failed to GetCameraLocation");
        return false;
    }

    c.SetLocation(loc);
    c.SetRotation(rotation);
    c.origRot = rotation;
    c.DesiredRotation = rotation;
    return true;
}

function #var(prefix)SecurityCamera SpawnCamera(vector loc)
{
    local #var(prefix)SecurityCamera c;
    local rotator rotation;
    local int i;
    local bool success;

    if( GetCameraLocation(loc, rotation) == false ) {
        warning("SpawnCamera("$loc$") failed to GetCameraLocation");
        return None;
    }

    c = Spawn(class'#var(prefix)SecurityCamera',,, loc, rotation);
    if( c == None ) {
        warning("SpawnCamera failed at "$loc);
        return None;
    }

    c.Tag = c.Name;
    c.bSwing = true;
    c.bNoAlarm = false;//true means friendly
    c.swingAngle = camera_swing_angle;
    c.swingPeriod = camera_swing_period;
    c.cameraFOV = camera_fov;
    c.cameraRange = camera_range;
    c.triggerDelay *= 0.75;
    class'DXRPasswords'.static.RandoHackable(dxr, c);
    info("SpawnCamera "$c$" done at ("$loc$"), ("$rotation$")");
    return c;
}

function #var(injectsprefix)ComputerSecurity SpawnSecurityComputer(vector loc, optional #var(prefix)AutoTurret t, optional #var(prefix)SecurityCamera cam)
{
    local #var(injectsprefix)ComputerSecurity c;
    local LocationNormal locnorm;
    local int i;
    local FMinMax distrange;
    local DXRPasswords pass;

    info("SpawnSecurityComputer near "$loc);
    locnorm.loc = loc;
    distrange.min = 0.1;

    loc = JitterPosition(loc);
    distrange.max = 16*50;
    NearestFloor(locnorm, distrange, 16*4);
    distrange.max = 16*75;
    NearestWallSearchZ(locnorm, distrange, 16*3, locnorm.loc, 2);

    c = Spawn(class'#var(injectsprefix)ComputerSecurity',,, locnorm.loc, Rotator(locnorm.norm));
    if( c == None ) {
        warning("SpawnSecurityComputer failed at "$locnorm.loc);
        return None;
    }
    if( cam != None ) {
        c.Views[0].CameraTag = cam.Tag;
    }
    if( t != None ) {
        c.Views[0].TurretTag = t.Tag;
    }
    c.UserList[0].userName = ReplaceText(String(c.Name), "#var(injectsprefix)ComputerSecurity", "Comp");
    c.itemName = c.UserList[0].userName;

    c.ComputerNode = CN_PageIndustries; //Should this be randomized?

    pass = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
    if(pass != None) {
        c.UserList[0].Password = pass.GeneratePassword(dxr.localURL @ String(c.Name) );
    } else {
        c.UserList[0].Password = "security";
    }
    info("SpawnSecurityComputer "$c.UserList[0].userName$" done at ("$loc$"), ("$rotation$") with password: "$c.UserList[0].Password );
    return c;
}

function #var(injectsprefix)InformationDevices SpawnDatacubeForComputer(vector loc, #var(injectsprefix)ComputerSecurity c)
{
    local #var(injectsprefix)InformationDevices d;
    local LocationNormal locnorm;
    local FMinMax distrange;
    locnorm.loc = loc;
    distrange.min = 0.1;

    loc = JitterPosition(loc);
    distrange.max = 16*50;
    NearestFloor(locnorm, distrange);

    d = SpawnDatacubePlaintext(locnorm.loc, Rotator(locnorm.norm),
        c.UserList[0].userName $ " password is " $ c.UserList[0].Password);

    d.new_passwords[0] = c.UserList[0].Password;

    return d;
}

function RandoMedBotsRepairBots(int medbots, int empty_medbots, int repairbots)
{
    local #var(prefix)RepairBot r;
    local #var(prefix)MedicalBot m;
    local #var(prefix)Datacube d;
    local #var(injectsprefix)MedicalBot ab;
    local Name medHint;
    local Name augHint;
    local Name repairHint;

    // TODO: get rid of this later, but still delete the old ones for now to reduce confusion for players used to previous releases
    medHint = '01_Datacube09';
    repairHint = '03_Datacube11';

    if( medbots > -1 ) {
        DestroyMedbotDoors();
        foreach AllActors(class'#var(prefix)MedicalBot', m) {
            m.Destroy();
        }
        foreach AllActors(class'#var(prefix)Datacube', d) {
            if( d.textTag == medHint ) d.Destroy();
        }
    }
    if( repairbots > -1 ) {
        foreach AllActors(class'#var(prefix)RepairBot', r) {
            r.Destroy();
        }
        foreach AllActors(class'#var(prefix)Datacube', d) {
            if( d.textTag == repairHint ) d.Destroy();
        }
    }

    medHint = 'MedbotNearby';
    augHint = 'AugbotNearby';
    repairHint = 'RepairbotNearby';

    SetSeed( "RandoMedBots" );
    if( chance_single(medbots) ) {
        SpawnBot(class'#var(injectsprefix)MedicalBot', medHint, "Medical Bot Nearby", 89);
    } else if ( chance_single(empty_medbots) ) {
        ab = #var(injectsprefix)MedicalBot(SpawnBot(class'#var(injectsprefix)MedicalBot', augHint, "Augmentation Bot Nearby", 255));
        ab.MakeAugsOnly();
    }

    SetSeed( "RandoRepairBots" );
    if( chance_single(repairbots) ) {
        SpawnBot(class'#var(injectsprefix)RepairBot', repairHint, "Repair Bot Nearby", 89);
    }
}

function RandoMedRepairBotAmountCooldowns( int mbamount, int rbamount, int mbcooldown, int rbcooldown)
{
    local #var(prefix)RepairBot r;
    local #var(prefix)MedicalBot m;

    if (mbcooldown!=0 || mbamount!=0) {
         foreach AllActors(class'#var(prefix)MedicalBot', m) {
            RandoMedBot(m, mbamount, mbcooldown);
        }

    }

    if (rbcooldown!=0 || rbamount!=0) {
        foreach AllActors(class'#var(prefix)RepairBot', r) {
             RandoRepairBot(r, rbamount, rbcooldown);
        }
    }
}

simulated function RandoMedBot(#var(prefix)MedicalBot m, int mbamount, int mbcooldown)
{
    local float scale;

    if (mbcooldown!=0){
        if (mbcooldown == 1) { //Individual
            SetSeed("MedBotCooldown"$m.name); //Seed includes level name and the unique bot name
        } else if (mbcooldown == 2) { //Global
            SetGlobalSeed("MedBotCooldown"); //Don't include the level name, or anything unique
        }

        //Actually rando the cooldown
        m.healRefreshTime = rngrange(m.default.healRefreshTime, 0.1, 1.0);
        m.lastHealTime = -m.healRefreshTime;
    }

    if (mbamount!=0){
        if (mbamount == 1) { //Individual
            SetSeed("MedBotAmount"$m.name); //Seed includes level name and the unique bot name
        } else if (mbamount == 2) { //Global
            SetGlobalSeed("MedBotAmount"); //Don't include the level name, or anything unique
        }

        //Actually rando the healAmount
        scale = float(dxr.flags.settings.health) / 100.0;
        scale = FMax(scale, (scale+1.0)/2.0);
        m.healAmount = rngrange(m.default.healAmount, 0.5 * scale, 1.2 * scale);
    }
}

simulated function RandoRepairBot(#var(prefix)RepairBot r, int rbamount, int rbcooldown)
{
    local float scale;

    if (rbcooldown!=0){
        if (rbcooldown == 1) { //Individual
            SetSeed("RepairBotCooldown"$r.name); //Seed includes level name and the unique bot name
        } else if (rbcooldown == 2) { //Global
            SetGlobalSeed("RepairBotCooldown"); //Don't include the level name, or anything unique
        }

        //Actually rando the cooldown
        r.chargeRefreshTime = rngrange(r.default.chargeRefreshTime, 0.1, 1.0);
        r.lastChargeTime = -r.chargeRefreshTime;
    }

    if (rbamount!=0){
        if (rbamount == 1) { //Individual
            SetSeed("RepairBotAmount"$r.name); //Seed includes level name and the unique bot name
        } else if (rbamount == 2) { //Global
            SetGlobalSeed("RepairBotAmount"); //Don't include the level name, or anything unique
        }

        //Actually rando the chargeAmount
        scale = float(dxr.flags.settings.energy) / 100.0;
        scale = FMax(scale, (scale+1.0)/2.0);
        r.chargeAmount = rngrange(r.default.chargeAmount, 0.5 * scale, 1.2 * scale);
    }
}

function Actor SpawnBot(class<Actor> c, Name datacubeTag, string datacubename, int datacubehue)
{
    local Actor a;
    local #var(prefix)Datacube d;

    a = SpawnNewActor(c, false);
    if( a == None ) return None;

    // spawn with large collision to ensure enough space, then slightly shrink after to make them easier to get around
    #var(prefix)Robot(a).SetBasedPawnSize(a.CollisionRadius * 0.8, a.CollisionHeight * 0.7);

    d = #var(prefix)Datacube(SpawnNewActor(class'#var(prefix)Datacube', true, a.Location, min_datacube_distance, max_datacube_distance));
    if( d == None ) return a;
    d.TextPackage = "#var(package)";
    d.textTag = datacubeTag;
    d.bAddToVault = false;
    d.ItemName = datacubename;
    GlowUp(d, datacubehue);

    return a;
}

function Actor _SpawnNewActor(class<Actor> c, bool jitter, vector target, float mindist, float maxdist)
{
    local Actor a;
    local vector loc;
    if(jitter)
        loc = GetRandomPositionFine(target, mindist, maxdist);
    else
        loc = GetRandomPosition(target, mindist, maxdist);

    if(!CheckFreeSpace(loc, c.default.CollisionRadius * 2 + player().CollisionRadius, c.default.CollisionHeight * 2)) {
        info("_SpawnNewActor no free space for " $ c @ loc);
        return None;
    }
    a = Spawn(c,,, loc );

    if( ScriptedPawn(a) != None ) class'DXRNames'.static.GiveRandomName(dxr, ScriptedPawn(a) );

    if( a == None ) warning("_SpawnNewActor "$c$" failed at "$loc);
    else info("_SpawnNewActor "$a$" at ("$loc$")");
    return a;
}

function Actor SpawnNewActor(class<Actor> c, bool jitter, optional vector target, optional float mindist, optional float maxdist)
{
    local Actor a;
    local int i;

    for(i=0; i<20; i++) {
        a = _SpawnNewActor(c, jitter, target, mindist, maxdist);
        if( a != None ) return a;
    }

    return a;
}

function DestroyMedbotDoors()
{
    local DeusExMover m;

    switch(dxr.localURL) {
    case "01_NYC_UNATCOISLAND":
        foreach AllActors(class'DeusExMover', m) {
            if(m.name == 'DeusExMover0' || m.name == 'DeusExMover2') {
                DestroyMover(m);
            }
        }
        break;
    }
}

function ExtendedTests()
{
    local PathNode a;
    Super.ExtendedTests();

    teststring( dxr.localURL, "12_VANDENBERG_TUNNELS", "correct map for extended tests");
    TestCameraPlacement( vect(-388.001404, 1347.872559, -2433.890137), false, 160, -4000, 8191 );
    TestCameraPlacement( vect(900.931396, 1316.819946, -2347.568359), false, 160, -4000, 24575 );
    TestCameraPlacement( vect(-1090.995483, 2757.317871, -2550.324463), false );

    foreach AllActors(class'PathNode', a) {
        debug("testing camera positioning with "$a);
        TestCameraPlacement( a.Location, true );
    }
}

function TestCameraPlacement(vector from, bool none_ok, optional float max_dist, optional int expected_pitch, optional int expected_yaw)
{
    local bool success;
    local vector loc;
    local rotator rotation;
    loc = from;

    success = GetCameraLocation(loc, rotation);
    if( none_ok && !success ) return;
    else if( !none_ok ) test( success, "GetCameraLocation "$from);
    if( ! success )
        return;

    //l("GetCameraLocation got ("$loc$"), ("$rotation$")");
    if( max_dist>0 || expected_pitch != 0 || expected_yaw != 0 ) {
        _TestCameraPlacement(from, loc, rotation, max_dist, expected_pitch, expected_yaw);
    }
    TestFacingAwayFromWall(loc, rotation);
}

function _TestCameraPlacement(vector from, vector loc, rotator rotation, float max_dist, int expected_pitch, int expected_yaw)
{
    test( VSize(from-loc) < max_dist, "VSize(("$from$") - ("$loc$")) < "$max_dist);
    testint( rotation.pitch, expected_pitch, "expected pitch");
    testint( rotation.yaw, expected_yaw, "expected yaw");
}

function bool TestFacingAwayFromWall(vector loc, rotator rotation)
{
    local LocationNormal locnorm;
    local float dist;
    locnorm.loc = loc;
    locnorm.norm = vector(rotation);
    dist = GetDistanceFromSurface(loc, loc + (vector(rotation)*1600));
    return test( dist > 32, "facing away from wall, ("$loc$") "$dist$" > 32, rotation: "$rotation);
}
