#!/bin/bash

DOTFILE_PATH="$(pwd)"

function update-grade {
    echo "--> Updating and upgrading packages..."
    sudo apt update
    sudo apt upgrade -y
}

function prompt {
    read -p "> Do you want to $1? (y/n) : " choice
    if [ "$choice" = 'y' ]; then
        echo "y"
    else
        echo "n"
    fi
}

function apt-install {
    arr=("$@")
    for i in "${arr[@]}"; do
        echo "--> Installing $i"
        sudo apt install -y "$i"
    done
}

# update & upgrade everything
if [ "$(prompt 'update and upgrade')" = "y" ]; then
    update-grade
fi

# install the basics
if [ "$(prompt 'install basics')" = "y" ]; then
    basics=("git" "vim" "tmux" "ssh" "shellcheck"
            "htop" "tree" "xtermcontrol")
    apt-install "${basics[@]}"
fi
 
# symlink stuff
if [ "$(prompt 'setup bash symlinks')" = "y" ]; then
    echo "--> Setting up symlinks..."

    if [ -f "$HOME/.bashrc" ]; then
	echo "backing up existing .bashrc to .bashrc.bak"
	mv $HOME/.bashrc $HOME/.bashrc.bak
    fi

    if [ -f "$HOME/.bash_aliases" ]; then
	echo "backing up existing .bash_aliases to .bash_aliases.bak"
	mv $HOME/.bash_aliases $HOME/.bash_aliases.bak
    fi

    if [ -f "$HOME/.tmux.conf" ]; then
	echo "backing up existing .tmux.conf to .tmux.conf.bak"
	mv $HOME/.tmux.conf $HOME/.tmux.bak
    fi


    ln -sv $DOTFILE_PATH/.bashrc $HOME
    ln -sv $DOTFILE_PATH/.bash_aliases $HOME
    ln -sv $DOTFILE_PATH/.tmux.conf $HOME
    source "$HOME/.bashrc"
    source "$HOME/.bash_aliases"
fi

# vim setup
if [ "$(prompt 'setup vim')" = "y" ]; then
    echo "--> Setting up vim configuration..." 
    git clone https://github.com/VundleVim/Vundle.vim.git vim/.vim/bundle/Vundle.vim
    ln -sv $DOTFILE_PATH/vim/.vim $HOME
    ln -sv $DOTFILE_PATH/vim/.vimrc $HOME
    vim +PluginInstall +qall
fi

# install dependencies for python
if [ "$(prompt 'install python dependencies')" = "y" ]; then
    echo "--> Installing python dependencies and virtualenvs..."
    python_deps=("python" "python-pip" "python3" "python3-pip" "virtualenv"
                 "virtualenvwrapper" "libssl-dev" "libffi-dev" "build-essential")
    apt-install "${python_deps[@]}"
    echo "--> Setting up virtualenv cpy2..."
    mkvirtualenv -p "/usr/bin/python2.7" cpy2
    deactivate
    mkvirtualenv -p "/usr/bin/python3" cpy3
    deactivate
fi

# install wine
if [ "$(prompt "install wine")" = "y" ]; then
    echo "--> Installing wine for Ubuntu 18.04"
    wget -nc https://dl.winehq.org/wine-builds/winehq.key
    sudo apt-key add winehq.key
    sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'
    sudo apt update
    sudo apt install --install-recommends winehq-stable
    rm winehq.key
fi

# install reversing tools
if [ "$(prompt 'install reversing tools')" = "y" ]; then
    echo "--> Installing reversing tools"
    reverse_tools=("binwalk" "unrar")
    apt-install "${reverse_tools[@]}" 
fi

# build ghidra with docker-builder
if [ "$(prompt 'build ghidra in docker')" = "y" ]; then
    echo "--> Getting docker"
    sudo apt-get remove docker docker-engine docker.io
    sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
    
    echo "--> Checking for docker group"
    if [ ! "$(getent group docker)" ]; then
        echo "--> Creating docker group"
        sudo groupadd docker
        sudo usermod -aG docker $USER
    fi

    if [ ! -d "ghidra-builder" ]; then
    	echo "--> Getting ghidra docker repo"
    	git clone https://github.com/dukebarman/ghidra-builder.git
    fi

    echo "--> Building Ghidra (can take a while)"
    # building ghidra with docker according to github instructions
    sg docker -c "./ghidra-builder/docker-tpl/run ./ghidra-builder/workdir/build_ghidra.sh"

fi

# install network tools
if [ "$(prompt 'install network tools')" = "y" ]; then
    echo "--> Installing network tools"
    network_tools=("wireshark" "tshark" "arp-scan" "traceroute" "nmap" "aircrack-ng" "curl")
    apt-install "${network_tools[@]}"
fi

echo "Done"
