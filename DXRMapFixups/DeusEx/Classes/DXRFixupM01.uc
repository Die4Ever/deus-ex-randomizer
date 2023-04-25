class DXRFixupM01 extends DXRFixup;


function PostFirstEntryMapFixes()
{
    local DeusExMover m;
    local BlockPlayer bp;

    FixUNATCORetinalScanner();

    switch(dxr.localURL) {
    case "01_NYC_UNATCOISLAND":
        foreach AllActors(class'DeusExMover', m, 'UN_maindoor') {
            m.bBreakable = false;
            m.bPickable = false;
            m.bIsDoor = false;// this prevents Floyd from opening the door
        }
        foreach AllActors(class'BlockPlayer', bp) {
            if(bp.Group == 'waterblock') {
                bp.bBlockPlayers = false;
            }
        }
        break;
    }

}


function PreFirstEntryMapFixes()
{
    switch(dxr.localURL) {
    case "01_NYC_UNATCOISLAND":
        Spawn(class'PlaceholderItem',,, vect(2378.5,-10810.9,-857)); //Sunken Ship
        Spawn(class'PlaceholderItem',,, vect(2436,-10709.4,-857)); //Sunken Ship
        Spawn(class'PlaceholderContainer',,, vect(1376,-9952.5,-271)); //Harley's house
        Spawn(class'PlaceholderItem',,, vect(2702.5,-7721.7,-229)); //On boxes near Harley
        Spawn(class'PlaceholderItem',,, vect(2373,-5003,-69)); //Boxes near ramp to Harley
        Spawn(class'PlaceholderItem',,, vect(-2962.8,-1355,-53)); //Boxes near front of Statue
        Spawn(class'PlaceholderItem',,, vect(-2838.7,1359.7,-53)); //Boxes near UNATCO HQ
        Spawn(class'PlaceholderItem',,, vect(-4433.66,3103.38,-65)); //Concrete gate support at UNATCO HQ
        Spawn(class'PlaceholderItem',,, vect(-4834.4,3667,-105)); //Bench in front of UNATCO
        Spawn(class'PlaceholderItem',,, vect(-2991,5328.5,-131)); //Medbot crate near starting dock
        Spawn(class'PlaceholderItem',,, vect(7670,737.7,-130)); //Medbot crate near Harley
        Spawn(class'PlaceholderItem',,, vect(7297,-3204.5,-373)); //Forklift in bunker
        Spawn(class'PlaceholderItem',,, vect(8981,26.9,-64)); //Boxes out front of bunker
        Spawn(class'PlaceholderContainer',,, vect(3163,-1298,-207)); //Backroom near jail
        Spawn(class'PlaceholderItem',,, vect(1750.75,275.7,-117.7)); //Near display of Statue torch
        Spawn(class'PlaceholderItem',,, vect(5830.8,-344,539)); //Near statue head
        break;

    case "01_NYC_UNATCOHQ":
        //Spawn some placeholders for new item locations
        Spawn(class'PlaceholderItem',,, vect(363.284149, 344.847, 50.32)); //Womens bathroom counter
        Spawn(class'PlaceholderItem',,, vect(211.227, 348.46, 50.32)); //Mens bathroom counter
        Spawn(class'PlaceholderItem',,, vect(982.255,1096.76,-7)); //Jaime's desk
        Spawn(class'PlaceholderItem',,, vect(2033.8,1979.9,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vect(2148,2249,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vect(2433,1384,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vect(-307.8,-1122,-7)); //Anna's Desk
        Spawn(class'PlaceholderItem',,, vect(-138.5,-790.1,-1.65)); //Anna's bookshelf
        Spawn(class'PlaceholderItem',,, vect(-27,1651.5,291)); //Breakroom table
        Spawn(class'PlaceholderItem',,, vect(602,1215.7,295)); //Kitchen Counter
        Spawn(class'PlaceholderItem',,, vect(-672.8,1261,473)); //Upper Left Office desk
        Spawn(class'PlaceholderContainer',,, vect(-1187,-1154,-31)); //Behind Jail Desk
        Spawn(class'PlaceholderContainer',,, vect(2384,1669,-95)); //MJ12 Door
        Spawn(class'PlaceholderContainer',,, vect(-383.6,1376,273)); //JC's Office
        break;
    }
}
