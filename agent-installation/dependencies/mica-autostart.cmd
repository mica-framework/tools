@echo off

if not DEFINED IS_MINIMIZED set IS_MINIMIZED=1 && start "" /min "%~dpnx0" %* && exit

echo ######## Running the MiCA-Startup Script #######
echo ATTENTION: Please do not close this Window!!
echo This is the startup script for the Microservice-based Simulation of Cyber Attacks
echo It may take some time till this startup finisihed. The CMD will automatically close after the configuration.
echo You can minimize the window, but don't close it!

REM Setting the ENV
ping 127.0.0.1 -n 5 > nul
echo .. setting the environment ..
SETX DOCKER_TLS_VERIFY "1"
SETX DOCKER_CERT_PATH "C:\Users\%USERNAME%\.docker\machine\machines\default"
SETX DOCKER_MACHINE_NAME "default"
SETX COMPOSE_CONVERT_WINDOWS_PATHS "true"
SETX PATH "%PATH%;C:\Program Files\Docker Toolbox;"

REM Starting the Startup Agent Runner
echo .. running the agent initialization ..
START /B "" "C:\Program Files\MiCA-Framework\agent_startup.exe"

exit