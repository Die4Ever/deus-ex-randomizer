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
    l(".PreTravel()");
    dxr = None;
    Self.Destroy();
}

function Timer()
{
}

event Destroyed()
{
    l(".Destroyed()");
    dxr = None;
    Super.Destroyed();
}

/*function Destroy()
{
    l(".Destroy()");
    dxr = None;
    Super.Destroy();
}*/

function SetSeed(string name)
{
    if( dxr == None ) {
        log(class $ " has no dxr");
        return;
    }
    dxr.SetSeed( dxr.Crc(dxr.seed $ "MS_" $ dxr.dxInfo.MissionNumber $ dxr.localURL $ name) );
}

function int rng(int max)
{
    if( dxr == None ) {
        log(class $ " has no dxr");
        return 0;
    }
    return dxr.rng(max);
}

function l(string message)
{
    if( dxr == None ) log(class $ " has no dxr");
    log(class @ message);
}
