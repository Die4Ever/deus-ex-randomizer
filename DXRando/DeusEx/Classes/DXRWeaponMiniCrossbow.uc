class DXRWeaponMiniCrossbow injects WeaponMiniCrossbow;

simulated function PlayFiringSound()
{
    // play the mini crossbow's unique sound instead of 'StealthPistolFire'
    PlaySimSound( FireSound, SLOT_None, TransientSoundVolume, 2048 );
}
