minikube start
eval $(minikube docker-env)
echo "Running docker on ip:"
minikube service list | grep "http://" | awk '{ print $6 }' | awk -F ":" '{ print $1":"$2 }' | tail -n1