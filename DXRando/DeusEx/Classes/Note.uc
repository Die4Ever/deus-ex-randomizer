class RandoNote injects DeusExNote;

var travel string new_passwords[16];
var travel int mission;
var travel string level_name;

function SetNewPassword(string password)
{
    local int i;
    for(i=0; i < ArrayCount(new_passwords); i++) {
        if( new_passwords[i] == "" ) {
            new_passwords[i] = password;
            return;
        }
        if( password == new_passwords[i] ) return;
    }
}

function bool HasPassword(string password)
{
    local int i;
    for(i=0; i < ArrayCount(new_passwords); i++) {
        if( password == new_passwords[i] ) return true;
    }
    return false;
}

function bool HasEitherPassword(string password_a, string password_b)
{
    local int i;
    for(i=0; i < ArrayCount(new_passwords); i++) {
        if( password_a == new_passwords[i] ) return true;
        if( password_b == new_passwords[i] ) return true;
    }
    return false;
}

function DumpPasswords(DeusExPlayer p)
{
    local int i;
    for(i=0; i < ArrayCount(new_passwords); i++) {
        if (new_passwords[i]!=""){
            p.ClientMessage("Password: "$new_passwords[i]);
        }
    }
}
