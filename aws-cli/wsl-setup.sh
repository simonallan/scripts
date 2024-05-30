#!/bin/bash

:'
WSL Setup script
Run with bash using path/to/wsl-setup.sh

This script is intended to be run on new Ubuntu WSL instances to set-up a Linux dev environment.

The following tasks will be performed:
- OS Updates
- Install OhMyZSH
- Install NodeJS
- Copies NodeJS environment settings to ZSH profile
- Install AWS CLI and Session Manager plugins
- Install Apt packages
- Adds network MTU configuration to user profile
- Changes default shell to ZSH
'

# Exit script if commands fail
set -e

# Initialise Variables
zshProfile="${HOME}/.zshrc"
setMtuCmd="sudo /usr/sbin/ip link set dev eth0 mtu 1400"

# Array of Apt packages to install
declare -a AptPackages=(
    "pip"
    "tree"
    "net-tools"
)

# Run updates
echo "Performing updates - please enter your password to continue as sudo"
sudo apt update && sudo apt upgrade -y
cd ~
echo $'\nUpdates complete. Continuing with application install'

# ## Make it pretty
if ! [ -x "$(command -v zsh)" ]; then
    echo 'ZSH not found. Installing...'
    ## https://github.com/ohmyzsh/ohmyzsh/wiki for more info 
    sudo apt install -y zsh
    # Install OhMyZsh without changing the current shell
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "ZSH found - skipping install"
fi

## Install Node Version Manager
if ! [[ -f "${HOME}/.nvm/nvm.sh" ]]; then
    echo 'NVM not found. Installing...'
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    
    # Make NVM available to the current shell
    export NVM_DIR="$HOME/.nvm" 
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    ## Copy nodejs profile settings from ~/.bashrc to ~/.zshrc
    echo "Copying NVM environment variables to ZSH env"
    tail -n 4 ~/.bashrc >> ~/.zshrc

    # Install Latest version of Node
    nvm install node
else
    echo "NVM found - skipping install"
fi

## Install aws-cli and session manager plugin
if ! [ -x "$(command -v aws)" ]; then
    echo 'AWS-CLI Not found. Installing..'
    sudo apt install unzip
    mkdir ~/awsTemp && cd ~/awsTemp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
    sudo dpkg -i session-manager-plugin.deb
    cd ~
    sudo rm -r ~/awsTemp
else
    echo "AWS CLI found - skipping install"
fi

# install Apt packages
for i in ${AptPackages[@]}; do
    if ! [ -x "$(command -v $i)" ]; then
        echo '$i not found. Installing...'
        sudo apt-get install -y $i
    else
        echo "$i found - skipping install"
    fi
done

## Set WSL network adaptor MTU to 1400 for compatibility with CRUK VPN
# We need to add this to the ZSH user profile as it is reset every time WSL is restarted
if [ -f "${HOME}/.zshrc" ]; then
    # If the MTU setting isn't present in the user profile file then add it
    if grep -iFxq "${setMtuCmd}" $zshProfile; then
        echo "MTU setting command has been found in $zshProfile. Skipping setup"
    else
        # Write network setup comand into user profile so that it can be executed automatically on logon
        echo "Adding MTU setting command to $zshProfile "
        echo "" >> $zshProfile
        echo "# Set network MTU for compatibility with CRUK VPN" >> $zshProfile
        echo $setMtuCmd >> $zshProfile

        # Add command to visudoers file to override password requirement
        echo "Updating sudoers file for passwordless command use"
        echo "" | (sudo EDITOR="tee -a" visudo)
        echo "# Allow user to set MTU without password" | (sudo EDITOR="tee -a" visudo)
        echo "$USER ALL=(ALL) NOPASSWD:/usr/sbin/ip" | (sudo EDITOR="tee -a" visudo)
    fi
else
    echo "ZSH profile file not found in ${HOME}. Skipping MTU setup"
fi

# Change default shell to OhMyZsh
if [ "$(which zsh)" ]; then 
    echo "Changing default shell to ZSH. "
    sudo chsh -s $(which zsh) $USER
else
    echo "ZSH not installed. Skipping setup"
fi

# Exit script on keypress
echo $'\nAll done! Please close this instance of WSL and re-start to see changes'
read -n 1 -r -s -p $'\nPress any key to exit...\n'
exit $?

# TODO:
# - Install pip venv

