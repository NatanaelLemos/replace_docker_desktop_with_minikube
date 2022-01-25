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
    RAM=$RAM'g'
fi

echo "This procedure will remove Docker Desktop completely from your machine and set a new instance of Docker running with Minikube."
echo "The Minikube instance will be configure with " $CPU_COUNT " CPUs and " $RAM " of ram."

read -p "Are you sure you want to continue? [y/n]" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "exiting"
    exit 1
fi

##------------------------------------------------
echo "#####################################"
echo "Removing all current docker images"
docker rm -f $(docker ps -q) || true
docker container rm -f $(docker container ls -qa) || true
docker image rm $(docker image ls -qa) || true

## If docker-desktop is installed, uninstall it.
BREW_OUTPUT=$(brew info --cask docker)
if [[ $BREW_OUTPUT != *"ot installed"* ]]
then
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
    echo "#####################################"
    echo "Installing Hyperkit"
    brew install hyperkit
fi

## If MiniKube is not installed, install it.
BREW_OUTPUT=$(brew info minikube)
if [[ $BREW_OUTPUT == *"ot installed"* ]]
then
    echo "#####################################"
    echo "Installing MiniKube"
    brew install minikube
fi

## If Docker is not installed, install it.
BREW_OUTPUT=$(brew info docker)
if [[ $BREW_OUTPUT == *"ot installed"* ]]
then
    echo "#####################################"
    echo "Installing Docker CLI"
    brew install docker
    ln -sf $(brew --prefix docker)/bin/docker /usr/local/bin/docker
fi

## If docker-compose is not installed, install it.
BREW_OUTPUT=$(brew info docker-compose)
if [[ $BREW_OUTPUT == *"ot installed"* ]]
then
    echo "#####################################"
    echo "Installing docker-compose"
    brew install docker-compose
fi

echo "#####################################"
echo "Starting MiniKube"
minikube config set cpus $CPU_COUNT
minikube config set memory $RAM
minikube start

# Tell Docker CLI to talk to minikube's VM
eval $(minikube docker-env)

# Add the docker link to bash initialization
echo "eval \$(minikube docker-env)" >> ~/.bash_profile

# Add the docker link to zsh initialization
echo "eval \$(minikube docker-env)" >> ~/.zshrc

# Save IP to a hostname
echo "`minikube ip` docker.local" | sudo tee -a /etc/hosts > /dev/null

# Test
echo "#####################################"
echo "Testing installation"
docker run hello-world

echo "#####################################"
echo "Docker running on IP:"
minikube ip