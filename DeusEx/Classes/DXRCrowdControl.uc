class DXRCrowdControl extends DXRBase;

var config bool enabled;
var config string crowd_control_addr;

var DXRandoCrowdControlLink link;

function Init(DXRando tdxr)
{
    Super.Init(tdxr);

    if (enabled) {
        link = Spawn(class'DXRandoCrowdControlLink');
        link.Init(tdxr,crowd_control_addr);
    }
}

function CheckConfig()
{
    if (config_version < 1 && crowd_control_addr=="") {
        crowd_control_addr = "localhost";
    }

    Super.CheckConfig();

}
