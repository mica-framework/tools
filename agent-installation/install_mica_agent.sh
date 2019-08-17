#!/bin/bash

# get the operating system
os=$(uname)

# depending on the os, define the corresponding installer paths
AUTOSTART_PATH=""
INSTALLER_PATH=""

if [ os -eq "cygwin" ] then; #we are on windows
    AUTOSTART_PATH="/c/ProgramData/Microsoft/Windows/'Start Menu'/Programs/StartUp/"
    INSTALLER_PATH="/c/'Program Files'/MiCA-Framework/"
    DOCKER_PATH="C:\Program Files\Docker Toolbox;C:\Program Files\Git\bin;"
elif [ os -eq "linux"* ] then; #we are on linux (linux or linux2)
    # no autostart for now
    INSTALLER_PATH="/opt/mica-framework/"
    DOCKER_PATH=""
else
    echo "The os $os is not supported for now. Agent will not be installed."
    exit(403)
fi
echo "Running the installation on $os"

# first cleanup all files silently
if [ os -eq "cygwin" ] then; #we are on windows
    rm -rf ${INSTALLER_PATH} 2> /dev/null
    rm ${AUTOSTART_PATH}*mica*.cmd 2> /dev/null
    rm ${AUTOSTART_PATH}*mica*.vbs 2> /dev/null
    rm ${AUTOSTART_PATH}*mica*.exe 2> /dev/null
fi

# now we can install the agent
echo "Start installation to $INSTALLER_PATH ..."

# now we need to set the environment first
echo ".. setting environment"
export PATH="$PATH;$DOCKER_PATH"
cmd.exe <<< 'setx /M PATH "%PATH%;'${$DOCKER_PATH}'"'

# first install the autostart file
if [ os -eq "cygwin" ] then; #we are on windows
    echo ".. initialize the startup files"
    cd ${AUTOSTART_PATH}
    curl -L https://github.com/mica-framework/tools/raw/master/agent-startup/dist/agent_startup.exe --output mica_agent_startup.exe
else
    echo ".. no autostart could be configured. Please do it manually!"
fi

# now create the installation dir
echo ".. install the mica-agent"
mkdir -p ${INSTALLER_PATH}
cd ${INSTALLER_PATH}
if [ os -eq "cygwin" ] then; #we are on windows
    curl -L https://raw.githubusercontent.com/mica-framework/tools/master/agent-installation/dependencies/prepare_environment.sh --output prepare_environment.sh
    curl -L https://github.com/mica-framework/tools/raw/master/agent-startup/dist/agent_startup.exe --output mica_agent_startup.exe
    curl -L https://github.com/mica-framework/agent/raw/master/dist/mica-agent-windows.exe --output mica-agent.exe
    touch 'config.yml'
elif [ os -eq "linux"* ] then; #we are on linux (linux or linux2)
    curl -L https://github.com/mica-framework/agent/raw/master/dist/mica-agent-linux --output mica-agent
    touch 'config.yml'
else
    echo ".. no executable found for this os!"
fi

echo ".. finished the installation!"
