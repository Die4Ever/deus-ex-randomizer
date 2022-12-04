class DXRAlarmLight injects AlarmLight;

var bool kludged;

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();

    if (Name=='AlarmLight0' && InStr(Level.GetLocalURL(),"99_EndGame4")!=-1){ //Only one light should do anything
        SetTimer(0.1,true);
    }
}

simulated function Timer()
{
    local DeusExPlayer p;
    if (!kludged){
        foreach AllActors(class'DeusExPlayer',p){
            break;
        }
        if (p!=None){ //Wait until the player is here
            SetTimer(0,false);
            kludged=True;
            DancePartyKludge();
        }
    }

}
//Just kludging some Rando logic into the Alarm Lights so we can do some goofy stuff to the dance party ending
function DancePartyKludge()
{
    local DeusExPlayer p;
    local POVCorpse c;
    local vector loc;
    local Rotator rot;
    local bool broughtLeo;
    local bool alive;
    local TerroristCommander leo;

    foreach AllActors(class'DeusExPlayer',p){
        log("Player has "$p.inHand$" in hands");
        if (p.inHand.IsA('POVCorpse')){
            c = POVCorpse(p.InHand);
            if (c.carcClassString == "DeusEx.TerroristCommanderCarcass"){
                broughtLeo = true;
                alive = c.bNotDead;
            }
        }
    }

    if (broughtLeo){
        loc.X = -736;
        loc.Y = -22;
        loc.Z = -32;

        rot.Yaw = -8064;

        if (alive){
            leo = Spawn(class'TerroristCommander',,,loc,rot);
            leo.SetOrders('Standing','',True);
        } else {
            Spawn(class'TerroristCommanderCarcass',,,loc,rot);
        }
    }
}
