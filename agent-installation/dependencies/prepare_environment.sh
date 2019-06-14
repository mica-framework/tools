#!/bin/bash

# initialy we can wait for arount 5 secs till the pc started completely
echo ">> Waiting 5 seconds till startup is completed"
sleep 5s

# now we can prepare the shell
echo ">> Configure environment variables"
export DOCKER_MACHINE_NAME="default"
export DOCKER_TLS_VERIFY="1"
export DOCKER_TOOLBOX_INSTALL_PATH="C:\Program Files\Docker Toolbox"
export VBOX_MSI_INSTALL_PATH="C:\\Program Files\\Oracle\\VirtualBox\\"

# now set the environment of the users system
cmd.exe <<< 'setx PATH "C:\Program Files\Docker Toolbox;"'
export PATH="$PATH;C:\Program Files\Docker Toolbox;"

# now run the actual docker startup script
echo ">> Start running Docker initialization"
. "C:\Program Files\Docker Toolbox\start.sh" 'exit'