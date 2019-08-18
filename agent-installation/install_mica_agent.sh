#!/bin/bash

# get the operating system
os=$(uname)
os=$(echo "$os" | sed -e 's/\(.*\)/\L\1/') # to lowercase

# depending on the os, define the corresponding installer paths
AUTOSTART_PATH=""
INSTALLER_PATH=""
DOCKER_PATH=""

echo "Running the installation on $os"
if [[ $os == cygwin ]] || [[ $os == mingw* ]]; then #we are on windows
	echo ".. configure for windows"
    AUTOSTART_PATH="/c/ProgramData/Microsoft/Windows/'Start Menu'/Programs/StartUp/"
    INSTALLER_PATH="/c/'Program Files'/MiCA-Framework/"
    DOCKER_PATH="C:\\Program Files\\Docker Toolbox;C:\\Program Files\\Git\\bin;"
elif [[ $os == linux* ]]; then #we are on linux (linux or linux2)
    # no autostart for now
	echo ".. configure for linux"
    INSTALLER_PATH="/opt/mica-framework/"
    DOCKER_PATH=""
else
    echo "The os $os is not supported for now. Agent will not be installed."
    exit
fi

# first cleanup all files silently
if [[ $os == cygwin ]] || [[ $os == mingw* ]]; then #we are on windows
    rm -rf "$INSTALLER_PATH" 2> /dev/null
    rm "$AUTOSTART_PATH"*mica*.cmd 2> /dev/null
    rm "$AUTOSTART_PATH"*mica*.vbs 2> /dev/null
    rm "$AUTOSTART_PATH"*mica*.exe 2> /dev/null
fi

# now we can install the agent
echo "Start installation to "$INSTALLER_PATH

# first install the autostart file
if [[ $os == cygwin ]] || [[ $os == mingw* ]]; then #we are on windows
    #echo ".. configure the autostart"
    cd "$AUTOSTART_PATH"
	echo "... >> current path: "$PWD
    curl -L https://github.com/mica-framework/tools/raw/master/agent-startup/dist/agent_startup.exe --output mica_agent_startup.exe
else
    echo ".. no autostart could be configured. Please do it manually!"
fi

# now create the installation dir
echo ".. install the mica-agent"
mkdir -p "$INSTALLER_PATH"
cd "$INSTALLER_PATH"
	#echo "... >> current path: "$PWD
if [[ $os == cygwin ]] || [[ $os == mingw* ]]; then #we are on windows
    curl -L https://raw.githubusercontent.com/mica-framework/tools/master/agent-installation/dependencies/prepare_environment.sh --output prepare_environment.sh
    curl -L https://github.com/mica-framework/tools/raw/master/agent-startup/dist/agent_startup.exe --output mica_agent_startup.exe
    curl -L https://github.com/mica-framework/agent/raw/master/dist/mica-agent-windows.exe --output mica-agent.exe
    touch 'config.yml'
elif [[ $os == linux* ]]; then #we are on linux (linux or linux2)
    curl -L https://github.com/mica-framework/agent/raw/master/dist/mica-agent-linux --output mica-agent
    touch 'config.yml'
else
    echo ".. no executable found for this os!"
fi


# now we need to set the environment first
echo ".. setting environment"
export PATH="$PATH;$DOCKER_PATH"
cmd.exe <<< 'setx /M PATH "%PATH%;'$DOCKER_PATH'" && Exit /b'


echo ".. finished the installation!"
