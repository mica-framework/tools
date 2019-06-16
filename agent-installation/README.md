# MiCA-Agent Installer

This Installer-Script basically is used to simplify the installation of the Agent
within the Laboratory. This script can be executed on each PC by an administrator
and installs the MiCA-Agent.

## Requirements
* Bash (Linux-based Systems)
* Git-Bash / Ubuntu-Bash (Windows-based Systems)
* Administration Rights

## How to use
You can install the Agent by just entering the command below. Please check, that
you have admin-rights within the bash-session your currently running. On Windows
you might need to run the Git-Bash / Ubuntu-Bash as an admin to gain an admin-session.

As soon as you've got admin rights within the shell-session, only execute the 
following commands (NOTE: you need to modify the USER and PASSWORD with you're actual
credentials)
```bash
curl https://raw.githubusercontent.com/mica-framework/tools/master/agent-installation/install_mica_agent.sh --output install.sh && ./install.sh && rm ./install.sh
```

If you want to delete the history for security reasons ;-) just enter the`
history clean` command. That cleans up the history and does not show any credentials
within the history.