#!/bin/bash

echo ">> Building Linux executable for TCPLogAnalyzer.py ..."
docker run -v "$(pwd):/src/" cdrx/pyinstaller-linux "python3 -m pip install -r requirements.txt && pyinstaller TCPLogAnalyzer.py --onefile --windowed"
echo ">> Finished Build Process! - You can find the executable within ./dist/"