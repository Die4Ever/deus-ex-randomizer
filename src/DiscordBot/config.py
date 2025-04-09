import os
import random
import sys
from configparser import ConfigParser

__config = ConfigParser()

if getattr(sys, 'frozen', False):
    application_path = os.path.dirname(sys.executable)
elif __file__:
    abs_pth = os.path.abspath(sys.argv[0])
    application_path = os.path.dirname(abs_pth)

if not os.path.exists(os.path.join(application_path, 'config.ini')):
    __config["DISCORD"] = {
        "TOKEN": "YOUR_TOKEN",
        "GUILD_ID": "YOUR_GUILD_ID",
        "CHANNEL_ID": "YOUR_CHANNEL_ID",
    }
    __config["EMBED"] = {
        "TITLE": "Deus Ex Discord Randomizer",
        "DESCRIPTION": "React to this message to get a random effect!",
        "INLINE": True,
        "COLOR": "0x00FF00",
        "THUMBNAIL": "https://avatars.githubusercontent.com/u/30947252",
        "FOOTER": "This will end in {VOITING_TIME} seconds!",
        "EFFECTS_HISTORY": 5,
    }
    __config["GAME"] = {
        "EFFETS_COUNT": 6,
        "VOITING_TIME": 30,
        "AUGS": "augaqualung, augballistic, augcloak, augcombat, augdefense, augdrone, augemp, augenviro, aughealing, augheartlung, augmuscle, augpower, augradartrans, augshield, augspeed, augstealth, augtarget, augvision",
        "AMMO": "Ammo10mm, Ammo20mm, Ammo762mm, Ammo3006, AmmoBattery, AmmoDart, AmmoDartFlare, AmmoDartPoison, AmmoNapalm, AmmoPepper, AmmoPlasma, AmmoRocket, AmmoRocketWP, AmmoSabot, AmmoShell",
    }
    __config["SERVER"] = {
        "HOST": "127.0.0.1",
        "PORT": 43384,
    }
    __config["EFFECTS"] = {
        "poison": 2,
        "glass_legs": 3,
        "set_fire": 1,
        "drop_lam": 2,
        "drop_empgrenade": 2,
        "drop_gasgrenade": 2,
        "drop_nanovirusgrenade": 2,
        "give_medkit": 3,
        "full_heal": 2,
        "drunk_mode": 1,
        "drop_selected_item": 5,
        "matrix": 1,
        "emp_field": 1,
        "give_bioelectriccell": 3,
        "disable_jump": 2,
        "gotta_go_fast": 4,
        "gotta_go_slow": 2,
        "ice_physics": 5,
        "third_person": 2,
        "dmg_double": 3,
        "dmg_half": 3,
        "lamthrower": 2,
        "give_weaponhideagun": 3,
        "ask_a_question": 4,
        "nudge": 4,
        "swap_player_position": 2,
        "floaty_physics": 1,
        "invert_mouse": 1,
        "invert_movement": 1,
    }
    __config["give_health"] = {
        "count": 3,
        "min": 10,
        "max": 50,
    }
    __config["give_energy"] = {
        "count": 3,
        "min": 10,
        "max": 100,
    }
    __config["give_skillpoints"] = {
        "count": 3,
        "min": 1,
        "max": 10,
    }
    __config["remove_skillpoints"] = {
        "count": 3,
        "min": 1,
        "max": 10,
    }
    __config["add_credits"] = {
        "count": 3,
        "min": 1,
        "max": 10,
    }
    __config["remove_credits"] = {
        "count": 3,
        "min": 1,
        "max": 10,
    }

    with open(os.path.join(application_path, 'config.ini'), 'w') as configfile:
        __config.write(configfile)

    sys.exit(0)


__config.read(os.path.join(application_path, "config.ini"))


TOKEN = __config["DISCORD"]["TOKEN"]
GUILD_ID = int(__config["DISCORD"]["GUILD_ID"])
CHANNEL_ID = int(__config["DISCORD"]["CHANNEL_ID"])

TITLE = __config["EMBED"]["TITLE"]
DESCRIPTION = __config["EMBED"]["DESCRIPTION"]
INLINE = __config["EMBED"].getboolean("INLINE", fallback=False)
COLOR = int(__config["EMBED"]["COLOR"], 16)
THUMBNAIL = __config["EMBED"]["THUMBNAIL"]
FOOTER = __config["EMBED"]["FOOTER"]
EFFECTS_HISTORY = int(__config["EMBED"]["EFFECTS_HISTORY"])

EFFECTS_COUNT = int(__config["GAME"]["EFFECTS_COUNT"])
VOITING_TIME = float(__config["GAME"]["VOITING_TIME"])

AUGS = [aug.replace(" ", "") for aug in __config["GAME"]["AUGS"] if aug]
AMMO = [ammo.replace(" ", "") for ammo in __config["GAME"]["AMMO"] if ammo]

HOST = __config["SERVER"]["HOST"]
PORT = int(__config["SERVER"]["PORT"])

EFFECTS = []
__effects = __config["EFFECTS"]
for key, value in __effects.items():
    EFFECTS.extend((key, None) for _ in range(int(value)))

__give_health = __config["give_health"]
__give_energy = __config["give_energy"]
__give_skillpoints = __config["give_skillpoints"]
__remove_skillpoints = __config["remove_skillpoints"]
__add_credits = __config["add_credits"]
__remove_credits = __config["remove_credits"]
EFFECTS.extend(("give_health", [str(random.randint(__give_health.getint(
    "min"), __give_health.getint("max"))),]) for _ in range(1, __give_health.getint("count") + 1))
EFFECTS.extend(("give_energy", [str(random.randint(__give_energy.getint(
    "min"), __give_energy.getint("max"))),]) for _ in range(1, __give_energy.getint("count") + 1))
EFFECTS.extend(("give_skillpoints", [str(random.randint(__give_skillpoints.getint(
    "min"), __give_skillpoints.getint("max"))),]) for _ in range(1, __give_skillpoints.getint("count") + 1))
EFFECTS.extend(("remove_skillpoints", [str(random.randint(__remove_skillpoints.getint(
    "min"), __remove_skillpoints.getint("max"))),]) for _ in range(1, __remove_skillpoints.getint("count") + 1))
EFFECTS.extend(("add_credits", [str(random.randint(__add_credits.getint(
    "min"), __add_credits.getint("max"))),]) for _ in range(1, __add_credits.getint("count") + 1))
EFFECTS.extend(("remove_credits", [str(random.randint(__remove_credits.getint(
    "min"), __remove_credits.getint("max"))),]) for _ in range(1, __remove_credits.getint("count") + 1))

print("Loaded Config")
print("------------------")
