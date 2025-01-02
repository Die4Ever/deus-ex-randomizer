class DXRReplacedActors extends Info;

struct ReplacedActor {
    var name origName;
    var name replacedName;
};

var int numReplacedActors;
var ReplacedActor replacedActors[200];

function AddReplacement(Actor orig, Actor replaced)
{
    //Do we need to theoretically think about HX's PrecessorName?  It can't be saved and reloaded at the moment, so maybe not?
    replacedActors[numReplacedActors].origName=orig.Name;
    replacedActors[numReplacedActors].replacedName=replaced.Name;
    numReplacedActors++;
}

function Name GetReplacementName(name origName){
    local int i;

    for (i=0;i<numReplacedActors;i++){
        if (replacedActors[i].origName==origName){
            return replacedActors[i].replacedName;
        }
    }
    return '';
}

function Actor FindReplacement(name origName)
{
    local name replName;
    local Actor a;

    replName=GetReplacementName(origName);

    if (replName=='') return None;

    foreach AllActors(class'Actor',a){
        if(a.Name==replName) return a;
    }

    return None;
}
