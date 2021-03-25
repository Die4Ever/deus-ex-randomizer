class DXRStats extends DXRBase;

var name NameConversion;

static function IncStatFlag(DeusExPlayer p, name flagname)
{
    local int val;
    val = p.FlagBase.GetInt(flagname);
    p.FlagBase.SetInt(flagname,val+1,,999);
    
}

static function IncDataStorageStat(DeusExPlayer p, name valname)
{
    local DataStorage datastorage;
    local int val;
    datastorage = class'DataStorage'.static.GetObj(p);
    val = int(datastorage.GetConfigKey(valname));
    datastorage.SetConfig(valname, val+1, 3600*12);

}

static function AddShotFired(DeusExPlayer p)
{
    IncStatFlag(p,'DXRStats_shotsfired');
}
static function AddWeaponSwing(DeusExPlayer p)
{
    IncStatFlag(p,'DXRStats_weaponswings');
}
static function AddJump(DeusExPlayer p)
{
    IncStatFlag(p,'DXRStats_jumps');
}
static function AddDeath(DeusExPlayer p)
{
    IncDataStorageStat(p,'DXRStats_deaths');
}

function int GetDataStorageStat(name valname)
{
    local DataStorage datastorage;
    datastorage = class'DataStorage'.static.GetObj(dxr.Player);
    return int(datastorage.GetConfigKey(valname));
}


function AddDXRCredits(CreditsWindow cw) 
{  
    local int fired,swings,jumps,deaths;
    
    fired = dxr.Player.FlagBase.GetInt('DXRStats_shotsfired');    
    swings = dxr.Player.FlagBase.GetInt('DXRStats_weaponswings');
    jumps = dxr.Player.FlagBase.GetInt('DXRStats_jumps');
    deaths = GetDataStorageStat('DXRStats_deaths');
    
    cw.PrintHeader("Statistics");
    
    cw.PrintText("Shots Fired: "$fired);
    cw.PrintText("Weapon Swings: "$swings);
    cw.PrintText("Jumps: "$jumps);
    cw.PrintText("Nano Keys: "$dxr.player.KeyRing.GetKeyCount());
    cw.PrintText("Skill Points Earned: "$dxr.Player.SkillPointsTotal);
    cw.PrintText("Deaths: "$deaths);
    
    cw.PrintLn();

}
