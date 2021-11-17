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

minikube start --cpus $CPU_COUNT --memory $RAM
eval $(minikube docker-env)
echo "Running docker on ip:"
minikube ip