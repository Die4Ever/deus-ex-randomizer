class DXRCrowdControl extends DXRBase;

//var config bool enabled;
var config string crowd_control_addr;

var DXRandoCrowdControlLink link;

function Init(DXRando tdxr)
{
    local bool anon;
    Super.Init(tdxr);

    if (tdxr.flags.crowdcontrol != 0) {
        link = Spawn(class'DXRandoCrowdControlLink');
        info("spawned "$link);
        if (tdxr.flags.crowdcontrol == 1) {
            anon = False;
        } else if (tdxr.flags.crowdcontrol == 2) {
            anon = True;
        }
        link.Init(tdxr,crowd_control_addr,anon);
    } else info("crowd control disabled");
}

function CheckConfig()
{
    if ( crowd_control_addr=="" ) {
        crowd_control_addr = "localhost";
    }
    Super.CheckConfig();
}
