class DXRFixupM08 extends DXRFixup;

function AnyEntryMapFixes()
{
    local StantonDowd s;

    Super.AnyEntryMapFixes();

    switch(dxr.localURL) {
    case "08_NYC_STREET":
        SetTimer(1.0, True);
        foreach AllActors(class'StantonDowd', s) {
            RemoveReactions(s);
        }
        Player().StartDataLinkTransmission("DL_Entry");
        break;

#ifdef vanillamaps
    case "08_NYC_SMUG":
        FixConversationGiveItem(GetConversation('M08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
        break;
#endif
    }
}

function TimerMapFixes()
{
    local BlackHelicopter chopper;

    switch(dxr.localURL)
    {
    case "08_NYC_STREET":
        if (#defined(vanillamaps) && dxr.flagbase.GetBool('StantonDowd_Played') )
        {
            foreach AllActors(class'BlackHelicopter', chopper, 'CopterExit')
                chopper.EnterWorld();
            dxr.flagbase.SetBool('MS_Helicopter_Unhidden', True,, 9);
        }
        break;
    }
}

function PreFirstEntryMapFixes()
{
    local DataLinkTrigger dlt;
#ifdef injections
    local #var(prefix)Newspaper np;
    local class<#var(prefix)Newspaper> npClass;
    npClass = class'#var(prefix)Newspaper';
#else
    local DXRInformationDevices np;
    local class<DXRInformationDevices> npClass;
    npClass = class'DXRInformationDevices';
#endif

    switch(dxr.localURL)
    {
        case "08_NYC_STREET":
            AdjustRaidStartLocation();

            //Since we always spawn the helicopter on the roof immediately after the conversation,
            //the ambush should also always happen immediately after the conversation (instead of
            //after getting explosives)
            foreach AllActors(class'DataLinkTrigger',dlt)
            {
                if (dlt.CheckFlag=='PlayerHasExplosives'){
                    dlt.CheckFlag='StantonDowd_Played';
                }
            }
            break;
        case "08_NYC_HOTEL":
            Spawn(class'#var(prefix)Binoculars',,, vectm(-610.374573,-3221.998779,94.160065)); //Paul's bedside table
            SpawnDatacubeTextTag(vectm(-840,-2920,85), rotm(0,0,0), '02_Datacube07',False); //Paul's stash code, in closet
            Spawn(class'PlaceholderItem',,, vectm(-732,-2628,75)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(-732,-2712,75)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(-129,-3038,127)); //Bathroom counter
            Spawn(class'PlaceholderItem',,, vectm(15,-2972,123)); //Kitchen counter
            Spawn(class'PlaceholderItem',,, vectm(-853,-3148,75)); //Crack next to Paul's bed
            break;
        case "08_NYC_BAR":
            npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(-1171.976440,250.575806,53.729687),rotm(0,0,0),'08_Newspaper01'); //Joe Greene article, table near where Harley is in Vanilla
            Spawn(class'BarDancer',,,vectm(-2150,-500,48),rotm(0,0,0));

            break;
    }
}

//GOTY edition has the attack force spawn in weird spots within line of sight.
//Revert their starting locations to where they were in the original release.
function AdjustRaidStartLocation()
{
    local MJ12Troop t;
    local vector locations[10];
    local int i;

    i=0;

    //In theory we could add more starting locations for the raids (basketball court, hotel)

    //Alley 1 (Sandra Renton) - Vanilla Non-GOTY
    locations[i++]=vectm(-2086,-706,-426);
    locations[i++]=vectm(-2041,-761,-426);
    locations[i++]=vectm(-1886,-719,-426);
    locations[i++]=vectm(-1849,-779,-426);
    locations[i++]=vectm(-1692,-695,-426);

    //Alley 2 (Road to NSF HQ) - Vanilla Non-GOTY
    locations[i++]=vectm(-1907,-1534,-434);
    locations[i++]=vectm(-1856,-1584,-434);
    locations[i++]=vectm(-1817,-1497,-441);
    locations[i++]=vectm(-1693,-1494,-452);
    locations[i++]=vectm(-1577,-1585,-438);


   //Ambush guys are tagged with MJ12AttackForce and start out of world
   i=0;
   foreach AllActors(class'MJ12Troop',t,'MJ12AttackForce'){
       t.WorldPosition = locations[i];
       t.SetLocation(locations[i++]+vectm(0,0,20000));
   }
}
