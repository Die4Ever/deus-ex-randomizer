class DXRStats extends DXRBase;

var name NameConversion;

static function IncStatFlag(DeusExPlayer p, name flagname)
{
    local int val;
    val = p.FlagBase.GetInt(flagname);
    p.FlagBase.SetInt(flagname,val+1,,999);
    
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



function AddDXRCredits(CreditsWindow cw) 
{  
    local int fired,swings,jumps;
    
    fired = dxr.Player.FlagBase.GetInt('DXRStats_shotsfired');    
    swings = dxr.Player.FlagBase.GetInt('DXRStats_weaponswings');
    jumps = dxr.Player.FlagBase.GetInt('DXRStats_jumps');
    
    cw.PrintHeader("Statistics");
    
    cw.PrintText("Shots Fired: "$fired);
    cw.PrintText("Weapon Swings: "$swings);
    cw.PrintText("Jumps: "$jumps);
    
    cw.PrintLn();

}
