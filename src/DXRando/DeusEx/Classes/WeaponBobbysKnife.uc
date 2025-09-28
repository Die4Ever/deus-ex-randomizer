class WeaponBobbysKnife extends #var(prefix)WeaponCombatKnife;

//So that we can adjust the pitch of the select sound
function PlaySelect()
{
    PlayAnim('Select',1.0,0.0);

    //Sound, Slot, Volume, bNoOverride, Radius, Pitch
    Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening,,,1.25);
}

defaultproperties
{
    HitDamage=10
    ItemName="Bobby's Knife"
    Description="This is Bobby's special knife.  You should give it back."
    beltDescription="BOBBY"
    SelectSound=Sound'DeusExSounds.Weapons.SwordSelect'
}
