#!/bin/bash

# build a exe with a window
docker run -v "$(pwd):/src/" cdrx/pyinstaller-windows "pip install -r requirements.txt && pyinstaller agent_startup.py --onefile"
mv ./dist/agent_startup.exe ./dist/agent_startup_window.exe

# build a exe without a window
docker run -v "$(pwd):/src/" cdrx/pyinstaller-windows "pip install -r requirements.txt && pyinstaller agent_startup.py --onefile --windowed"