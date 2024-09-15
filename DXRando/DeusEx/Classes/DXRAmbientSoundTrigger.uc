// Note that this class behaves very differently from AmbientSoundTriggered.
class DXRAmbientSoundTrigger extends AmbientSound;

var sound TriggeredAmbientSound, UntriggeredAmbientSound;
var() byte TriggeredSoundRadius, UntriggeredSoundRadius, TriggeredSoundVolume, UntriggeredSoundVolume, TriggeredSoundPitch, UntriggeredSoundPitch;
var() bool bTriggerOnceOnly, bUntriggerOnceOnly, bAlreadyTriggered, bAlreadyUntriggered;

function Trigger(Actor Other, Pawn Instigator)
{
    if (bTriggerOnceOnly && bAlreadyTriggered) return;

    Super.Trigger(Other, Instigator);
    AmbientSound = TriggeredAmbientSound;
    SoundRadius = TriggeredSoundRadius;
    SoundVolume = TriggeredSoundVolume;
    SoundPitch = TriggeredSoundPitch;

    bAlreadyTriggered = true;
}

function UnTrigger(Actor Other, Pawn Instigator)
{
    if (bUntriggerOnceOnly && bAlreadyUntriggered) return;

    Super.UnTrigger(Other, Instigator);
    AmbientSound = UntriggeredAmbientSound;
    SoundRadius = UntriggeredSoundRadius;
    SoundVolume = UntriggeredSoundVolume;
    SoundPitch = UntriggeredSoundPitch;

    bAlreadyUntriggered = true;
}

static function DXRAmbientSoundTrigger ReplaceAmbientSound(AmbientSound as, optional name spawnTag, optional Vector spawnLocation)
{
    local DXRAmbientSoundTrigger ast;

    if (as == None) return None;

    if (spawnLocation == vect(0.0, 0.0, 0.0)) {
        spawnLocation = as.Location;
    }
    ast = as.Spawn(class'DXRAmbientSoundTrigger',, spawnTag, spawnLocation);
    ast.CopyVals(as);
    ast.CopyValsToTriggered(ast);

    as.AmbientSound = None;

    return ast;
}

function CopyVals(Actor other)
{
    AmbientSound = other.AmbientSound;
    SoundRadius = other.SoundRadius;
    SoundVolume = other.SoundVolume;
    SoundPitch = other.SoundPitch;
}

function CopyValsToTriggered(Actor other)
{
    TriggeredAmbientSound = other.AmbientSound;
    TriggeredSoundRadius = other.SoundRadius;
    TriggeredSoundVolume = other.SoundVolume;
    TriggeredSoundPitch = other.SoundPitch;
}

function CopyValsToUntriggered(Actor other)
{
    UntriggeredAmbientSound = other.AmbientSound;
    UntriggeredSoundRadius = other.SoundRadius;
    UntriggeredSoundVolume = other.SoundVolume;
    UntriggeredSoundPitch = other.SoundPitch;
}

defaultproperties
{
    bStatic=false
    bCollideActors=false
}
