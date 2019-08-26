# Personal Lecture Notes for Docker and Kubernetes at Udemy

## Section 1: Dive Into Docker
Why use Docker: easy to install and run software without worrying about setup or dependencies

Docker Ecosystem:
- Docker Client
- Docker Server
- Docker Machine
- Docker Images
- Docker Hub
- Docker Compose

**Docker is a platform or ecosystem for creating and running containers**

Container is an instance of an Image!

### Docker for Windows/Mac
- Docker Client(CLI): Tool that we are going to issue commands to
- Docker Server(Daemon): Tool that is responseible for creating images, running containers, etc

### Commands
```
docker version
docker run hello-world
```

### Kernel
Kernel directs appropriate segment of the hardware resource based on process using namespacing

### Namespacing
Technique that isolates resources per process(or group of processes)

### Control Groups (cgroups)
Limit amount of resources used per process

### Container
Set of processes + Kernel + portion of hardware resources

### Architecture
Linux Virtual Machine(Running Processes -> Linux Kernel) -> MacOS / Windows -> Your computer's hardware

## Section 2: Manipulating Containers with the Docker Client

docker run image-name commands

```
// Examples
docker run busybox echo hi there
docker run busybox ls
```
List all running containers
```
docker ps

# All the containers I have executed
docker ps --all 
```

### Lifecycle of Containers
docker run = docker create + docker start
```
docker create hello-world
> b3b140c9412af2baf5cb1613070b6f8c5d82575b7373b1eb6abc4e5a2c02b5f0

# Print the output to my terminal
docker start -a b3b140c9412af2baf5cb1613070b6f8c5d82575b7373b1eb6abc4e5a2c02b5f0

```

Restart a exited container
```
docker start -a CONTAINER_ID # -a for attch
```

Remove stopped processes
```
docker system prune
```

Retrieve log outputs
```
docker logs CONTAINER_ID
```

Stop currently running containers
```
docker stop CONTAINER_ID # Recommended: after about 10 sec. grace period
docker kill CONTAINER_ID # immediate system call
```

Execute an additional command in a container
```
# -it allows us to input to the container
docker exec -it CONTAINER_ID command

# start a shell of the running container
docker exec -it CONTAINER_ID sh

# can start sh using busybox
docker run -it busybox sh
```

### Container Isolation
**Two running containers absolutely don't share file system or hardware resources**

## Section 3: Building Custom Images Through Docker Server