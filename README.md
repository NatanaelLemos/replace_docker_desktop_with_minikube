# replace_docker_desktop_with_minikube.sh

## About

Script for MacOS to remove Docker Desktop and replace it with Minikube (because of the new licensing of Docker Desktop).

---

## Requirements

You need Homebrew [download here](https://brew.sh/) to run this script.

## Installation

Execute the script using bash:
```
bash replace_docker_desktop_with_minikube.sh
```

Optionally, two parameters can be passed, the first being the CPU count and the second the amount of RAM in GB to be used. By default, the script is going to assume 4 CPUs and 8GB of RAM.