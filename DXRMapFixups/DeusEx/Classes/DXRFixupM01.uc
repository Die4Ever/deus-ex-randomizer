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
        Spawn(class'PlaceholderItem',,, vectm(2378.5,-10810.9,-857)); //Sunken Ship
        Spawn(class'PlaceholderItem',,, vectm(2436,-10709.4,-857)); //Sunken Ship
        Spawn(class'PlaceholderContainer',,, vectm(1376,-9952.5,-271)); //Harley's house
        Spawn(class'PlaceholderItem',,, vectm(2702.5,-7721.7,-229)); //On boxes near Harley
        Spawn(class'PlaceholderItem',,, vectm(2373,-5003,-69)); //Boxes near ramp to Harley
        Spawn(class'PlaceholderItem',,, vectm(-2962.8,-1355,-53)); //Boxes near front of Statue
        Spawn(class'PlaceholderItem',,, vectm(-2838.7,1359.7,-53)); //Boxes near UNATCO HQ
        Spawn(class'PlaceholderItem',,, vectm(-4433.66,3103.38,-65)); //Concrete gate support at UNATCO HQ
        Spawn(class'PlaceholderItem',,, vectm(-4834.4,3667,-105)); //Bench in front of UNATCO
        Spawn(class'PlaceholderItem',,, vectm(-2991,5328.5,-131)); //Medbot crate near starting dock
        Spawn(class'PlaceholderItem',,, vectm(7670,737.7,-130)); //Medbot crate near Harley
        Spawn(class'PlaceholderItem',,, vectm(7297,-3204.5,-373)); //Forklift in bunker
        Spawn(class'PlaceholderItem',,, vectm(8981,26.9,-64)); //Boxes out front of bunker
        Spawn(class'PlaceholderContainer',,, vectm(3163,-1298,-207)); //Backroom near jail
        Spawn(class'PlaceholderItem',,, vectm(1750.75,275.7,-117.7)); //Near display of Statue torch
        Spawn(class'PlaceholderItem',,, vectm(5830.8,-344,539)); //Near statue head

        class'PlaceholderEnemy'.static.Create(self,vectm(-2374,543,-92), 17272, 'Standing');
        class'PlaceholderEnemy'.static.Create(self,vectm(-1211,198,-92), 25408, 'Standing');
        class'PlaceholderEnemy'.static.Create(self,vectm(-1843,5063,-96), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(-3020,1878,-96), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(86,3088,-96), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(2879,4083,-96), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(6500,4609,-92), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(9398,2403,-92), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(7705,-2019,79), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(6618,-1526,320), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(2842,-3539,-96), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(-1713,-5775,-92), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(1402,56,800), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(2231,985,1088), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(3777,-689,1088), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(4111,3260,512), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(-229,1438,512), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(2766,317,2528), 0, 'Standing');
        break;

    case "01_NYC_UNATCOHQ":
        FixUNATCOCarterCloset();
        //Spawn some placeholders for new item locations
        Spawn(class'PlaceholderItem',,, vectm(363.284149, 344.847, 50.32)); //Womens bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(211.227, 348.46, 50.32)); //Mens bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(982.255,1096.76,-7)); //Jaime's desk
        Spawn(class'PlaceholderItem',,, vectm(2033.8,1979.9,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vectm(2148,2249,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vectm(2433,1384,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vectm(-307.8,-1122,-7)); //Anna's Desk
        Spawn(class'PlaceholderItem',,, vectm(-138.5,-790.1,-1.65)); //Anna's bookshelf
        Spawn(class'PlaceholderItem',,, vectm(-27,1651.5,291)); //Breakroom table
        Spawn(class'PlaceholderItem',,, vectm(602,1215.7,295)); //Kitchen Counter
        Spawn(class'PlaceholderItem',,, vectm(-672.8,1261,473)); //Upper Left Office desk
        Spawn(class'PlaceholderContainer',,, vectm(-1187,-1154,-31)); //Behind Jail Desk
        Spawn(class'PlaceholderContainer',,, vectm(2384,1669,-95)); //MJ12 Door
        Spawn(class'PlaceholderContainer',,, vectm(-383.6,1376,273)); //JC's Office
        break;
    }
}
