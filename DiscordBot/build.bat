@echo off
pip install -r requirements.txt
python -m PyInstaller --onefile DiscordCrowdControl.py -i icon.ico -F
pause