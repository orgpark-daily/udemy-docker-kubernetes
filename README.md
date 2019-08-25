# Personal Lecture Notes for Docker and Kubernetes at Udemy
## Section 2: Manipulating Containers with the Docker Client


## Section 1: Dive Into Docker
Why use Docker: easy to install and run software without worrying about setup or dependencies

Docker Ecosystem:
- Docker Client
- Docker Server
- Docker Machine
- Docker Images
- Docker Hub
- Docker Compose

**Docker is a platform or ecosystem around creating and running containers**

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
