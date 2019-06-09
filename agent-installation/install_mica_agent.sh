#!/bin/bash

# first we need the credentials
echo "Please Enter your SecLab-Git Credentials.."
read -p 'Username: ' USER
read -sp 'Password: ' PASS

# first cleanup all files silently
rm -rf /c/'Program Files'/MiCA-Framework 2> /dev/null
rm /c/ProgramData/Microsoft/Windows/'Start Menu'/Programs/StartUp/*mica*.cmd 2> /dev/null
rm /c/ProgramData/Microsoft/Windows/'Start Menu'/Programs/StartUp/*mica*.vbs 2> /dev/null

# now we can install the agent
echo "Start installation..."

# first install the autostart file
echo ".. initialize the startup files"
cd /c/ProgramData/Microsoft/Windows/'Start Menu'/Programs/StartUp/
curl -u ${USER}:${PASS} https://github.com/mica-framework/tools/raw/master/agent-startup/dist/agent_startup.exe --output mica_agent_startup.exe

# now create the installation dir
echo ".. install the mica-agent"
mkdir -p /c/'Program Files'/MiCA-Framework/
cd /c/'Program Files'/MiCA-Framework/
curl -u ${USER}:${PASS} https://raw.githubusercontent.com/mica-framework/tools/master/agent-installation/dependencies/prepare_environment.sh --output prepare_environment.sh
curl -u ${USER}:${PASS} https://github.com/mica-framework/tools/raw/master/agent-startup/dist/agent_startup.exe --output mica_agent_startup.exe
curl -u ${USER}:${PASS} https://github.com/mica-framework/agent/raw/master/dist/mica-agent-windows.exe --output mica-agent.exe

echo ".. finished the installation!"
