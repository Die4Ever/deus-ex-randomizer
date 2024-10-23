class DXRWeaponMiniCrossbow injects WeaponMiniCrossbow;

simulated function PlayFiringSound()
{
    // play the mini crossbow's unique sound instead of 'StealthPistolFire'
    PlaySimSound( default.FireSound, SLOT_None, TransientSoundVolume, 2048 );
}
