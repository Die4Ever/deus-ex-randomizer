class DXRBase extends Info;

var transient DXRando dxr;

function Init(DXRando tdxr)
{
    l(".Init()");
    dxr = tdxr;
}

function FirstEntry()
{
    l(".FirstEntry()");
}

function AnyEntry()
{
    l(".AnyEntry()");
}

function ReEntry()
{
    l(".ReEntry()");
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
