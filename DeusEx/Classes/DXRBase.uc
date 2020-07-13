class DXRBase extends Info;

var transient DXRando dxr;

function Init(DXRando tdxr)
{
    log("DXRando "$Class$".Init()");
    dxr = tdxr;
}

function FirstEntry()
{
    log("DXRando "$Class$".FirstEntry()");
}

function AnyEntry()
{
    log("DXRando "$Class$".AnyEntry()");
}

function ReEntry()
{
    log("DXRando "$Class$".ReEntry()");
}

function PreTravel()
{
}

function Timer()
{
}

event Destroyed()
{
    dxr = None;
}

function SetSeed(string name)
{
    dxr.SetSeed( dxr.Crc(dxr.seed $ "MS_" $ dxr.dxInfo.MissionNumber $ dxr.localURL $ name) );
}

function int rng(int max)
{
    return dxr.rng(max);
}

function l(string message)
{
    log(class @ message);
}
