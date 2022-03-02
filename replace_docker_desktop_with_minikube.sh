#!/bin/sh

CPU_COUNT=$1
RAM=$2

if [ -z "$CPU_COUNT" ]
then
    CPU_COUNT=4
fi

if [ -z "$RAM" ]
then
    RAM=8g
else
    RAM=$RAM
fi

clear

echo "**********************************************************************"
echo "**********************************************************************"
echo "**********************************************************************"
echo " "
echo " "
echo "                                 ##        .                          "
echo "                           ## ## ##       ==                          "
echo "                        ## ## ## ##      ===                          "
echo "                    /""""""""""""""""\___/ ===                        "
echo "               ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~                 "
echo "                    \______ o          __/                            "
echo "                      \    \        __/                               "
echo "                       \____\______/                                  "
echo "                                                                      "
echo "                       |          |                                   "
echo "                    __ |  __   __ | _  __   _                         "
echo "                   /  \| /  \ /   |/  / _\ |                          "
echo "                   \__/| \__/ \__ |\_ \__  |                          "
echo " "
echo " "
echo "This procedure will remove Docker Desktop completely from your machine"
echo "and set a new instance of Docker running on top of Minikube and Hyperkit."
echo "The Minikube instance will be configure with " $CPU_COUNT " CPUs and " $RAM " of ram."
echo " "
echo "(Note that if your instance of docker-desktop was not installed using Brew,"
echo "you will have to uninstall it manually!"
echo "See: https://docs.docker.com/desktop/mac/install/#uninstall-docker-desktop)"
echo " "
echo "**********************************************************************"
echo "**********************************************************************"
echo "**********************************************************************"

echo " "
read -p "Are you sure you want to continue? [y/n]" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "exiting"
    exit 1
fi

##------------------------------------------------
echo " "
echo "#####################################"
echo "Removing all current docker images"
docker rm -f $(docker ps -q) || true
docker container rm -f $(docker container ls -qa) || true
docker image rm $(docker image ls -qa) || true

## If docker-desktop is installed, uninstall it.
BREW_OUTPUT=$(brew info --cask docker)
if [[ $BREW_OUTPUT != *"ot installed"* ]]
then
    echo " "
    echo "#####################################"
    echo "Uninstalling docker desktop"
    brew uninstall --cask --force docker
    rm -rf ~/.kube
    rm -rf /usr/local/bin/docker
fi

## If hyperkit is not installed, install it.
BREW_OUTPUT=$(brew info hyperkit)
if [[ $BREW_OUTPUT == *"ot installed"* ]]
then
    echo " "
    echo "#####################################"
    echo "Installing Hyperkit"
    brew install hyperkit
fi

## If MiniKube is not installed, install it.
BREW_OUTPUT=$(brew info minikube)
if [[ $BREW_OUTPUT == *"ot installed"* ]]
then
    echo " "
    echo "#####################################"
    echo "Installing MiniKube"
    brew install minikube
fi

## If Docker is not installed, install it.
BREW_OUTPUT=$(brew info docker)
if [[ $BREW_OUTPUT == *"ot installed"* ]]
then
    echo " "
    echo "#####################################"
    echo "Installing Docker CLI"
    brew install docker
    ln -sf $(brew --prefix docker)/bin/docker /usr/local/bin/docker
fi

## If docker-compose is not installed, install it.
BREW_OUTPUT=$(brew info docker-compose)
if [[ $BREW_OUTPUT == *"ot installed"* ]]
then
    echo " "
    echo "#####################################"
    echo "Installing docker-compose"
    brew install docker-compose
fi

echo " "
echo "#####################################"
echo "Starting MiniKube"
minikube config set driver hyperkit
minikube config set cpus $CPU_COUNT
minikube config set memory $RAM
minikube start

# Tell Docker CLI to talk to minikube's VM
eval $(minikube docker-env)

# Add the docker link to bash initialization
BREW_OUTPUT=$(cat ~/.bash_profile)
if [[ ! $BREW_OUTPUT == *"minikube docker-env"* ]]
then
    echo "eval \$(minikube docker-env)" >> ~/.bash_profile
    echo "alias docker-start=\"cd `pwd` && bash start-docker.sh && cd - && bash\"" >> ~/.bash_profile
fi

# Add the docker link to zsh initialization
BREW_OUTPUT=$(cat ~/.zshrc)
if [[ ! $BREW_OUTPUT == *"minikube docker-env"* ]]
then
    echo "eval \$(minikube docker-env)" >> ~/.zshrc
    echo "alias docker-start=\"cd `pwd` && bash start-docker.sh && cd - && zsh -l\"" >> ~/.zshrc
fi

# Save IP to a hostname
BREW_OUTPUT=$(cat /etc/hosts)
if [[ ! $BREW_OUTPUT == *"docker.local"* ]]
then
    echo "`minikube ip` docker.local" | sudo tee -a /etc/hosts > /dev/null
fi

# Fix docker-compose access config
echo "{ \"credsDstore\": \"desktop\" }" > ~/.docker/config.json

# Test
echo " "
echo "#####################################"
echo "Testing installation"
docker run hello-world

echo " "
echo "#####################################"
echo "Docker running on IP:"
minikube ip
