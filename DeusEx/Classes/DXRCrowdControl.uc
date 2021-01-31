class DXRCrowdControl extends DXRBase;

//var config bool enabled;
var config string crowd_control_addr;

var DXRandoCrowdControlLink link;

function Init(DXRando tdxr)
{
    Super.Init(tdxr);

    if (tdxr.flags.crowdcontrol == 1) {
        link = Spawn(class'DXRandoCrowdControlLink');
        info("spawned "$link);
        link.Init(tdxr,crowd_control_addr);
    } else info("crowd control disabled");
}

function CheckConfig()
{
    if ( crowd_control_addr=="" ) {
        crowd_control_addr = "localhost";
    }
    Super.CheckConfig();
}
