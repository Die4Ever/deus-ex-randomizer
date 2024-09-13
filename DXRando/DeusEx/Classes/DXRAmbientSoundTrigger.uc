class DXRAmbientSoundTrigger extends AmbientSound;
// Note that this class behaves very differently from AmbientSoundTriggered.

var sound TriggeredAmbientSound, UntriggeredAmbientSound;
var int TriggeredSoundRadius, UntriggeredSoundRadius, TriggeredSoundVolume, UntriggeredSoundVolume, TriggeredSoundPitch, UntriggeredSoundPitch;
var bool bTriggerOnceOnly, bUntriggerOnceOnly, bAlreadyTriggered, bAlreadyUntriggered;

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
