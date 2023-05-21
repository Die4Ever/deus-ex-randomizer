class DXRMutators extends DXRBase;

function AnyEntry()
{
    local Mutator m;
    local class<Mutator> c;
    for(m=Level.Game.BaseMutator; m!=None; m=m.NextMutator) {
        l(m);
    }
    c = class<Mutator>(GetClassFromString("DXRMutators.DXRMutatorBase", class'Mutator'));
    m = Spawn(c, self);
    m.BindName = "#var(package)";
    l(m);
    Level.Game.BaseMutator.AddMutator(m);

    Level.Game.RegisterDamageMutator(m);
}
