class DXRMachines extends DXRActorsBase;

var config int max_turrets;
var config int turret_move_min_distance;
var config int turret_move_max_distance;
var config int max_datacube_distance;
var config int min_datacube_distance;
var config int camera_swing_angle;
var config int camera_fov;
var config int camera_range;
var config int camera_ceiling_pitch;

function CheckConfig()
{
    local int i;
    local class<Actor> a;
    if( config_version < class'DXRFlags'.static.VersionToInt(1,5,0) ) {
        max_turrets = 3;
        turret_move_min_distance = 10*16;
        turret_move_max_distance = 500*16;
        max_datacube_distance = 200*16;
        min_datacube_distance = 50*16;
        camera_swing_angle = 8192;
        camera_fov = 5000;
        camera_range = 2000;
        camera_ceiling_pitch = -3568;
    }
    Super.CheckConfig();
}

function FirstEntry()
{
    Super.FirstEntry();
    RandoMedBotsRepairBots(dxr.flags.medbots, dxr.flags.repairbots);
    RandoTurrets(dxr.flags.turrets_move, dxr.flags.turrets_add);
}

function RandoTurrets(int percent_move, int percent_add)
{
    local AutoTurret t;
    local SecurityCamera cam;
    local ComputerSecurity c;
    local int i, hostile_turrets;
    local vector loc;

    SetSeed( "RandoTurrets move" );

    foreach AllActors(class'AutoTurret', t) {
        if( t.bTrackPlayersOnly==true || t.bTrackPawnsOnly==false ) hostile_turrets++;
        if( chance_single(percent_move) == false ) continue;

        loc = GetRandomPosition(t.Location, turret_move_min_distance, turret_move_max_distance);
        if( class'DXRMissions'.static.IsCloseToStart(dxr, loc) ) {
            info("RandoTurret move "$loc$" is too close to start!");
            continue;
        }
        info("RandoTurret move "$t$" to near "$loc);
        cam = GetCameraForTurret(t);
        if( cam != None ) {
            if( ! MoveCamera(cam, loc) ) continue;
        }
        MoveTurret(t, loc);
    }

    if( hostile_turrets == 0 ) return;

    SetSeed( "RandoTurrets add" );

    for(i=0; i < max_turrets ; i++) {//need to randomize hack strengths on these
        if( chance_single(percent_add/max_turrets) == false ) continue;

        loc = GetRandomPosition();
        if( class'DXRMissions'.static.IsCloseToStart(dxr, loc) ) {
            info("RandoTurret add "$loc$" is too close to start!");
            continue;
        }
        info("RandoTurret add near "$loc);
        cam = SpawnCamera(loc);
        if( cam == None ) continue;
        t = SpawnTurret(loc);
        c = SpawnSecurityComputer(loc, t, cam);
        loc = GetRandomPosition(loc, min_datacube_distance, max_datacube_distance);
        SpawnDatacube(loc, c);
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

function MoveTurret(AutoTurret t, vector loc)
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
    t.origRot = rot;
    v1.X = 0;
    v1.Y = 0;
    v1.Z = t.CollisionHeight + t.gun.Default.CollisionHeight;
    v2 = v1 >> t.Rotation;
    v2 += t.Location;
    t.gun.SetLocation(v2);
    t.gun.SetBase(t);
}

function AutoTurret SpawnTurret(vector loc)
{
    local AutoTurret t;
    local rotator rotation;

    if( ! GetTurretLocation(loc, rotation) ) {
        warning("SpawnTurret failed to GetTurretLocation at "$loc);
        return None;
    }

    t = Spawn(class'AutoTurret',,, loc, rotation);
    if( t == None ) {
        warning("SpawnTurret failed at "$loc);
        return None;
    }
    t.Tag = t.Name;
    t.bActive = false;
    t.bTrackPawnsOnly = false;
    t.bTrackPlayersOnly = true;
    info("SpawnTurret "$t$" done at ("$loc$"), ("$rotation$")");
    return t;
}

function SecurityCamera GetCameraForTurret(AutoTurret t)
{
    local ComputerSecurity comp;
    local SecurityCamera cam;
    local int i;

    foreach AllActors(class'ComputerSecurity',comp)
    {
        for (i = 0; i < ArrayCount(comp.Views); i++)
        {
            if (comp.Views[i].turretTag == t.Tag)
            {
                foreach AllActors(class'SecurityCamera', cam, comp.Views[i].cameraTag) {
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
    
    locnorm.norm = (locnorm.norm + wall1.norm) / 2;
    rotation = Rotator(locnorm.norm);

    //if( found_ceiling ) rotation.pitch += camera_ceiling_pitch;
    distrange.max = 16*10;
    if( NearestCeiling(locnorm, distrange, 16) ) rotation.pitch += camera_ceiling_pitch;
    loc = locnorm.loc;
    return true;
}

function bool MoveCamera(SecurityCamera c, vector loc)
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
    return true;
}

function SecurityCamera SpawnCamera(vector loc)
{
    local SecurityCamera c;
    local rotator rotation;
    local int i;
    local bool success;

    if( GetCameraLocation(loc, rotation) == false ) {
        warning("SpawnCamera("$loc$") failed to GetCameraLocation");
        return None;
    }

    c = Spawn(class'SecurityCamera',,, loc, rotation);
    if( c == None ) {
        warning("SpawnCamera failed at "$loc);
        return None;
    }
    
    c.Tag = c.Name;
    c.bSwing = true;
    c.bNoAlarm = false;//true means friendly
    c.swingAngle = camera_swing_angle;
    c.cameraFOV = camera_fov;
    c.cameraRange = camera_range;
    info("SpawnCamera "$c$" done at ("$loc$"), ("$rotation$")");
    return c;
}

function ComputerSecurity SpawnSecurityComputer(vector loc, optional AutoTurret t, optional SecurityCamera cam)
{
    local ComputerSecurity c;
    local LocationNormal locnorm;
    local int i;
    local FMinMax distrange;
    info("SpawnSecurityComputer near "$loc);
    locnorm.loc = loc;
    distrange.min = 0.1;

    loc = JitterPosition(loc);
    distrange.max = 16*50;
    NearestFloor(locnorm, distrange, 16*4);
    distrange.max = 16*75;
    NearestWallSearchZ(locnorm, distrange, 16*3, locnorm.loc, 2);

    c = Spawn(class'ComputerSecurity',,, locnorm.loc, Rotator(locnorm.norm));
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
    c.UserList[0].userName = String(c.Name);
    c.UserList[0].Password = class'DXRPasswords'.static.GeneratePassword(dxr, String(c.Name) );
    info("SpawnSecurityComputer "$c$" done at ("$loc$"), ("$rotation$") with password: "$c.UserList[0].Password );
    return c;
}

function Datacube SpawnDatacube(vector loc, ComputerSecurity c)
{
    local Datacube d;
    local LocationNormal locnorm;
    local FMinMax distrange;
    locnorm.loc = loc;
    distrange.min = 0.1;

    loc = JitterPosition(loc);
    distrange.max = 16*50;
    NearestFloor(locnorm, distrange);

    d = Spawn(class'Datacube',,, locnorm.loc, Rotator(locnorm.norm));
    if( d == None ) {
        warning("SpawnDatacube failed at "$locnorm.loc);
        return None;
    }
    d.plaintext = c.Name $ " password is " $ c.UserList[0].Password;
    info("SpawnDatacube "$d$" done at ("$locnorm.loc$"), ("$locnorm.norm$")");
    return d;
}

function RandoMedBotsRepairBots(int medbots, int repairbots)
{
    local RepairBot r;
    local MedicalBot m;
    local Datacube d;
    local Name medHint;
    local Name repairHint;

    medHint = '01_Datacube09';
    repairHint = '03_Datacube11';

    if( medbots > -1 ) {
        foreach AllActors(class'MedicalBot', m) {
            m.Destroy();
        }
        foreach AllActors(class'Datacube', d) {
            if( d.textTag == medHint ) d.Destroy();
        }
    }
    if( repairbots > -1 ) {
        foreach AllActors(class'RepairBot', r) {
            r.Destroy();
        }
        foreach AllActors(class'Datacube', d) {
            if( d.textTag == repairHint ) d.Destroy();
        }
    }

    SetSeed( "RandoMedBots" );
    if( chance_single(medbots) ) {
        SpawnBot(class'MedicalBot', medHint);
    }

    SetSeed( "RandoRepairBots" );
    if( chance_single(repairbots) ) {
        SpawnBot(class'RepairBot', repairHint);
    }
}

function Actor SpawnBot(class<Actor> c, Name datacubeTag)
{
    local Actor a;
    local Datacube d;

    a = SpawnNewActor(c);
    if( a == None ) return None;

    d = Datacube(SpawnNewActor(class'Datacube', a.Location, min_datacube_distance, max_datacube_distance));
    if( d == None ) return a;
    d.textTag = datacubeTag;
    d.bAddToVault = false;

    return a;
}

function Actor SpawnNewActor(class<Actor> c, optional vector target, optional float mindist, optional float maxdist)
{
    local Actor a;
    local vector loc;
    loc = GetRandomPositionFine(target, mindist, maxdist);
    a = Spawn(c,,, loc );
    if( a == None ) warning("SpawnNewActor "$c$" failed at "$loc);
    return a;
}
