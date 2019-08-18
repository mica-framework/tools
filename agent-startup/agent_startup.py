import os
import subprocess
import json
import yaml
import sys

##### check operating systems
def _is_windows():
    return sys.platform == "win32" or sys.platform == "cygwin"

def _is_linux():
    return sys.platform == "linux" or sys.platform == "linux2"

def _is_mac_os():
    return sys.platform == "darwin"

##### Logging
def _log_state(state, message, file="C:\\TEMP\\agent.log", print_to_console=True, append=True):
    # print the message to console
    print('{} --> {}'.format(state, message))

    # select the write mode
    if not append:
        write_mode = 'w'
    else:
        write_mode = 'a'

    # check if the dir exists
    if not os.path.isdir(os.path.dirname(file)):
        os.makedirs(os.path.dirname(file))

    # check if the file exists
    if not os.path.exists(file):
        f = open(file, 'a')
        f.close()

    # write to logfile
    with open(file, write_mode) as log:
        log.write("{} --> {}\n".format(state, message))


##### PRE-CONFIGURATION
def _init_docker_toolbox_windows():
    # now we are able to run the docker toolbox script
    try:
        # create the command parts
        bash = '\"C:\\Program Files\\Git\\bin\\bash.exe\"'
        bash_options = '--login -i'
        arguments = '\"C:\\Program Files\\MiCA-Framework\\prepare_environment.sh\"'
        
        # execute the command
        command = "{} {} {}".format(bash, bash_options, arguments)
        process = subprocess.Popen(command, shell=True)
        process.wait()
        _log_state("SUCCESS", "Finished Docker Toolbox Configuration!")
    except Exception as err:
        _log_state("### ERROR ###", 'ERROR while Docker Toolbox Configuration: {}'.format(err))

    # now try to fix the registry entry
    try:
        # get the json destination
        file_path = "{}/config.json".format(os.environ['DOCKER_CERT_PATH'])
        with open(file_path) as f:
            config_data = json.load(f)

        # now edit the json
        insecure_registries = config_data['HostOptions']['EngineOptions']['InsecureRegistry']
        if "IM-SEC-001:5000" not in insecure_registries:
            insecure_registries.append("IM-SEC-001:5000")
        config_data['HostOptions']['EngineOptions']['InsecureRegistry'] = insecure_registries

        # now save that to the file
        with open(file_path, 'w+') as f:
            f.write(json.dumps(config_data))

        # now restart the docker machine
        os.system('start /MIN docker-machine provision default')
        #os.system('set PATH="C:\Program Files\Docker Toolbox"') # env for current session
        #os.system('setx /M PATH "C:\Program Files\Docker Toolbox"') # env for system session
        _log_state("SUCCESS", "Did add insecure registry to the config!")
    except Exception as err:
        _log_state("### ERROR ###", 'ERROR while Docker Toolbox Registry Configurations: {}'.format(err))

    # got everything configured
    _log_state("SUCCESS", "Finsihed the Preconfiguration of the Docker Toolbox!")


##### STARTUP AGENT
def _startup_agent():
    print('>> Start the Agent in the Background..')
    try:
        p = subprocess.Popen('powershell Invoke-Command -ScriptBlock { cd "C:\\\'Program Files\'\\MiCA-Framework\\" ; Start-Process "./mica-agent.exe" }', shell=True)
        p.wait()
        _log_state("SUCCESS", "Finished Agent Startup!")
    except Exception as err:
        _log_state("### ERROR ###", 'ERROR while Agent Startup: {}'.format(err))
        exit(500)


#### GENERAL WORKFLOW
if __name__ == '__main__':
    _log_state("START", "Start running the Script")
    _log_state("INFO", "Running on the OS: {}".format(sys.platform))
    if _is_windows():
        _init_docker_toolbox_windows() # 1
        _startup_agent() # 2
    else:
        _log_state("ERROR", "This agent startup does only support an automated startup on windows for now!")
    _log_state("END", "Autostart has finished")