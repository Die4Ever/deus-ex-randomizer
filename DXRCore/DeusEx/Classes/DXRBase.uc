class DXRBase extends DXRInfo;

var transient DXRando dxr;
var transient float overallchances;

var transient bool inited;

replication
{
    reliable if( Role==ROLE_Authority )
        dxr, inited;
}

static function class<DXRBase> GetModuleToLoad(DXRando dxr, class<DXRBase> request)
{
    return request;
}

function Init(DXRando tdxr)
{
    //l(Self$".Init()");
    dxr = tdxr;
    CheckConfig();
    inited = true;
}

simulated function DXRando GetDXR()
{
    return dxr;
}

simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    l("PostNetBeginPlay()");
}

simulated function PreFirstEntry();
simulated function FirstEntry();
simulated function PostFirstEntry();

simulated function AnyEntry();
simulated function PostAnyEntry();

simulated function ReEntry(bool IsTravel);

simulated function bool CheckLogin(#var(PlayerPawn) player)
{
    info("CheckLogin("$player$"), inited: "$inited$", dxr.flagbase: "$dxr.flagbase$", dxr.flags.flags_loaded: "$dxr.flags.flags_loaded$", player.SkillSystem: "$player.SkillSystem$", player.SkillSystem.FirstSkill: "$player.SkillSystem.FirstSkill);
    if( inited == false ) return false;
    if( player == None ) return false;
    if( player.SkillSystem == None ) return false;
    if( player.SkillSystem.FirstSkill == None ) return false;
    return true;
}

simulated function PlayerLogin(#var(PlayerPawn) player)
{
    l("PlayerLogin("$player$")");
}

simulated function PlayerRespawn(#var(PlayerPawn) player)
{
    l("PlayerRespawn("$player$")");
}

simulated function PlayerAnyEntry(#var(PlayerPawn) player)
{
    l("PlayerAnyEntry("$player$")");
}

simulated event PreTravel()
{
    SetTimer(0, False);
}

simulated event Timer()
{
}

simulated event Tick(float deltaTime);

simulated event Destroyed()
{
    SetTimer(0, False);
    dxr = None;
    Super.Destroyed();
}

simulated function int SetSeed(coerce string name)
{
    return dxr.SetSeed( dxr.Crc(dxr.seed $ dxr.localURL $ name) );
}

simulated function int SetGlobalSeed(coerce string name)
{
    return dxr.SetSeed( dxr.seed + dxr.Crc(name) );
}

simulated function int rng(int max)
{
    return dxr.rng(max);
}

simulated function bool rngb()
{
    return dxr.rng(100) < 50;
}

simulated function float rngf()
{// 0 to 1.0
    local float f;
    f = float(dxr.rng(100001))/100000.0;
    //l("rngf() "$f);
    return f;
}

simulated function float rngfn()
{// -1.0 to 1.0
    return rngf() * 2.0 - 1.0;
}

simulated function float rngfn_min_dist(float min_dist)
{// -1.0 to 1.0, adding a minimum distance away from 0
    local float f;
    f = rngfn();
    if(f >= 0.0) return f + min_dist;
    else return f - min_dist;
}

simulated function float rngrange(float val, float min, float max)
{
    local float mult, r, ret;
    mult = max - min;
    r = rngf();
    ret = val * (r * mult + min);
    //l("rngrange r: "$r$", mult: "$mult$", min: "$min$", max: "$max$", val: "$val$", return: "$ret);
    return ret;
}

simulated function float rngrecip(float val, float max)
{
    local float f;
    f = rngrange(1, 1, max);
    if( rngb() ) {
        f = 1 / f;
    }
    return val * f;
}

simulated function float rngrangeseeded(float val, float min, float max, coerce string classname)
{
    local float mult, r, ret;
    local int oldseed;
    oldseed = dxr.SetSeed( dxr.seed + dxr.Crc(classname) );//manually set the seed to avoid using the level name in the seed
    mult = max - min;
    r = rngf();
    ret = val * (r * mult + min);
    //l("rngrange r: "$r$", mult: "$mult$", min: "$min$", max: "$max$", val: "$val$", return: "$ret);
    dxr.SetSeed(oldseed);
    return ret;
}

simulated function float rngexp(float origmin, float origmax, float curve)
{
    local float frange, f, min, max;
    min = origmin;
    max = origmax;
    if(min != 0)
        min = pow(min, 1/curve);
    max = pow(max+1.0, 1/curve);
    frange = max-min;
    f = rngf()*frange + min;
    f = pow(f, curve);
    f = FClamp( f, origmin, origmax );
    return f;
}

simulated function bool RandoLevelValues(Actor a, float min, float max, float wet, out string Desc, string add_desc)
{
    local #var(prefix)Augmentation aug;
    local #var(prefix)Skill sk;
    local string s, word;
    local int i, len, mid, oldseed, removals;
    local float v;
    local float d_min, d_max, avg_diff;
    local float points[16];

    wet = FClamp(wet, 0, 1);

    oldseed = SetGlobalSeed(" RandoLevelValues " $ a.class.name );

    aug = #var(prefix)Augmentation(a);
    sk = #var(prefix)Skill(a);

    if( aug != None ) len = ArrayCount(aug.LevelValues);
    else if( sk != None ) len = ArrayCount(sk.LevelValues);
    else {
        err("RandoLevelValues "$a$" isn't a skill or an augmentation");
        return false;
    }

    // figure out the range we will use
    if( aug != None ) {
        Desc = aug.default.Description;
        d_min = aug.Default.LevelValues[0];
        d_max = aug.Default.LevelValues[len-1];
    }
    else if( sk != None ) {
        Desc = sk.default.Description;
        d_min = sk.Default.LevelValues[0];
        d_max = sk.Default.LevelValues[len-1];
    }

    // expand the range for more variety
    avg_diff = (d_max - d_min) / float(len);
    d_min -= avg_diff*min;
    d_max += avg_diff*max;

    // we'll remove values later
    removals = 1;
    len += removals;

    // choose random points within the 0-1 range, with an extra point so we can remove the median
    for(i=0; i < len; i++) {
        v = rngexp(0, 100, 1.4) / 100.0;// should this be using a 1.4 curve?
        points[i] = v;
    }

    // sort the values
    for(i=1; i < len; i++) {
        if( points[i] < points[i-1] ) {
            v = points[i];
            points[i] = points[i-1];
            points[i-1] = v;
            i=0;
        }
    }

    // remove the smallest jumps, is this better than weighting the values?
    for(i=0; i < removals; i++) {
        RemoveSmallestJump(len--, points);
    }

    // apply the values
    for(i=0; i < len; i++) {
        v = points[i];

        if( aug != None ) aug.LevelValues[i] = WeightedLevelValue(aug.LevelValues[i], v, d_max, d_min, wet, i, len);
        else if( sk != None ) sk.LevelValues[i] = WeightedLevelValue(sk.LevelValues[i], v, d_max, d_min, wet, i, len);

        if( i>0 ) s = s $ ", ";
        s = s $ DescriptionLevel(a, i, word);
    }

    s = "(DXRando) " $ word $ ":|n    " $ s;

    info("RandoLevelValues "$a$" = "$s);
    dxr.SetSeed( oldseed );

    if(add_desc != "") {
        s = s $ "|n|n" $ add_desc;
    }
    if( InStr(Desc, s) == -1 ) {
        Desc = s $ "|n|n" $ Desc;
        return true;
    }
    return false;
}

simulated function float WeightedLevelValue(float orig, float v, float d_max, float d_min, float wet, int i, int len)
{
    local float dry;
    v = v * (d_max-d_min) + d_min;
    dry = 1.0 - wet;
    v = ( v * wet ) + ( orig * dry );
    return v;
}

simulated function RemoveSmallestJump(int len, out float a[16])
{
    local float v;
    local int i;

    v = a[1]-a[0];
    for(i=1; i < len; i++) {
        if( a[i] - a[i-1] < v ) {
            v = a[i] - a[i-1];
        }
    }

    for(i=1; i < len; i++) {
        if( a[i] - a[i-1] > v ) continue;

        if( i==1 )// retain the lowest value to keep the range large
            i++;

        for(v=0; i<len; i++) {
            a[i-1] = a[i];
        }
        break;
    }
}

simulated function string DescriptionLevel(Actor a, int i, out string word)
{
    local Skill sk;
    local Augmentation aug;
    local float f;

    err("DXRBase DescriptionLevel failed for "$a);
    sk = Skill(a);
    aug = Augmentation(a);
    if(sk != None) {
        word = "% of Normal";
        f = sk.LevelValues[i] / sk.default.LevelValues[i];
        return int(f * 100.0) $ "%";
    } else if(aug != None) {
        word = "% of Normal";
        f = aug.LevelValues[i] / aug.default.LevelValues[i];
        return int(f * 100.0) $ "%";
    }
    return "err";
}

simulated function static int staticrng(DXRando dxr, int max)
{
    return dxr.rng(max);
}

simulated function float initchance()
{
    if(overallchances > 0.01 && overallchances < 99.99) warning("initchance() overallchances == "$overallchances);
    overallchances=0;
    return rngf()*100.0;
}

simulated function bool chance(float percent, float r)
{
    overallchances+=percent;
    if(!(overallchances>=0 && overallchances<100.01)) warning("chance("$percent$", "$r$") overallchances == "$overallchances);
    return r>= (overallchances-percent) && r< overallchances;
}

simulated function bool chance_remaining(int r)
{
    local int percent;
    percent = 100 - overallchances;
    return chance(percent, r);
}

simulated function bool chance_single(float percent)
{
    return rngf()*100.0 < percent;
}

final function Class<Inventory> ModifyInventoryClass( out Class<Inventory> InventoryClass )
{
#ifdef hx
    HXGameInfo(Level.Game).ModifyInventoryClass( InventoryClass );
#endif
    return InventoryClass;
}

final function Class<Actor> ModifyActorClass( out Class<Actor> ActorClass )
{
#ifdef hx
    HXGameInfo(Level.Game).ModifyActorClass( ActorClass );
#endif
    return ActorClass;
}

//Based on function MessageBox from DeusExRootWindow
//msgBoxMode = 0 or 1, 0 = Yes/No box, 1 = OK box
//module will presumably be the module you are creating the message box for
//id lets you provide an ID so you can identify where the response should go
simulated function CreateMessageBox( String msgTitle, String msgText, int msgBoxMode,
                           DXRBase module, int id, optional bool noPause) {

    local DXRMessageBoxWindow msgBox;

    info(module$" CreateMessageBox "$msgTitle$" - "$msgText);

    msgBox = DXRMessageBoxWindow(DeusExRootWindow(player().rootWindow).PushWindow(Class'DXRMessageBoxWindow', False, noPause ));
    msgBox.SetTitle(msgTitle);
    msgBox.SetMessageText(msgText);
    msgBox.SetMode(msgBoxMode);
    msgBox.SetCallback(module,id);
    msgBox.SetDeferredKeyPress(True);
}

//As above, except you can provide a list of button labels to use instead of Yes, no, or OK
//You can only fit 3 buttons along a box, and the labels can't be too long.
//7 Characters is about the label limit before the button box starts expanding.
//You can likely fit about 34ish characters between all three labels before it looks bad
simulated function CreateCustomMessageBox (String msgTitle, String msgText, int numBtns, String buttonLabels[3],
                                 DXRBase module, int id, optional bool noPause) {
    local DXRMessageBoxWindow msgBox;

    info(module$" CreateCustomMessageBox "$msgTitle$" - "$msgText);

    msgBox = DXRMessageBoxWindow(DeusExRootWindow(player().rootWindow).PushWindow(Class'DXRMessageBoxWindow', False, noPause ));
    msgBox.SetTitle(msgTitle);
    msgBox.SetMessageText(msgText);
    msgBox.SetCustomMode(numBtns,buttonLabels);
    msgBox.SetCallback(module,id);
    msgBox.SetDeferredKeyPress(True);

}

//Implement this in your DXRBase subclass to handle message boxes for your particular needs
simulated function MessageBoxClicked(int button, int callbackId) {
    local DXRMessageBoxWindow msgBox;
    local string title, message;

    msgBox = DXRMessageBoxWindow(DeusExRootWindow(player().rootWindow).GetTopWindow());
    if( msgBox != None ) {
        title = msgBox.winTitle.titleText;
        message = msgBox.winText.GetText();
    }

    if (msgBox.mbMode == 0 || msgBox.mbMode == 1) {
        switch(button) {
            case 0:
                info("MessageBoxClicked Yes: "$title$" - "$message);
                break;
            case 1:
                info("MessageBoxClicked No: "$title$" - "$message);
                break;
            case 2:
                info("MessageBoxClicked OK: "$title$" - "$message);
                break;
        }
    } else if (msgBox.mbMode == 2) {
        //Custom mode
        info("MessageBoxClicked "$msgBox.customBtn[button].buttonText$": "$title$" - "$message);
    }

    DXRMessageBoxWindow(DeusExRootWindow(player().rootWindow).PopWindow());

    //Implementations in subclasses just need to call Super to pop the window, then can handle the message however they want
    //Buttons:
    //Yes = 0
    //No = 1
    //OK = 2
}

simulated function AddDXRCredits(CreditsWindow cw)
{
}
