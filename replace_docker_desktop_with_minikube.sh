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
else
    echo "Starting the script..."
fi

#------------------------------------------------

echo "###########################"
echo "Uninstalling docker desktop"
brew uninstall --cask --force docker
rm -rf ~/.kube

echo "###########################"
echo "Installing hyperkit drivers"
brew install hyperkit
ln -sf $(brew --prefix hyperkit)/bin/hyperkit /usr/local/bin/hyperkit

echo "##############################"
echo "Checking hyperkit installation"
hyperkit -v

echo "#####################"
echo "Installing docker cli"
brew install docker

echo "#############################"
echo "Verifying docker installation"
docker info

echo "##################"
echo "Installing kubectl"
brew install kubectl
brew link kubernetes-cli

echo "###################"
echo "Installing minikube"
brew install minikube

echo "####################"
echo "Configuring minikube"
minikube config set cpus $CPU_COUNT
minikube config set memory $RAM

echo "###############################################"
echo "Starting kubernetes. This might take a while..."
minikube start --driver=hyperkit --container-runtime=docker

echo "##########################"
echo "Verifying kubernetes state"
minikube kubectl get nodes

echo "############################################"
echo "Adding minikube to the environment variables"
eval $(minikube docker-env)

echo "###################################"
echo "Verifying that docker is accessible"
docker info