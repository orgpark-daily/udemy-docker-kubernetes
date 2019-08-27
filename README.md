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

Dockerfile -> Docker Client -> Docker Server -> Usable Image!
### Creating Dockerfile
1. Specify a base image
2. Run some commands to install additional programs
3. Specify a command to run on container startup

### Create an image that runs redis-server

```
# ./redis-image/Dockerfile

# Use an existing docker image as a base
FROM alpine

# Download and install a dependency
RUN apk add --update redis

# Tell the image what to do when it starts as a container
CMD ["redis-server"]

```
```
docker build redis-image
```
Step 1/3 : FROM alpine
latest: Pulling from library/alpine
9d48c3bd43c5: Pull complete 
Digest: ... 
Status: Downloaded newer image for alpine:latest
 ---> 961769676411

Step 2/3 : RUN apk add --update redis
 ---> Running in ff92c19cf5f8
fetch http://dl-cdn.alpinelinux.org/alpine/v3.10/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.10/community/x86_64/APKINDEX.tar.gz
(1/1) Installing redis (5.0.5-r0)
Executing redis-5.0.5-r0.pre-install
Executing redis-5.0.5-r0.post-install
Executing busybox-1.30.1-r2.trigger
OK: 7 MiB in 15 packages
Removing intermediate container ff92c19cf5f8
 ---> e3038021e057

Step 3/3 : CMD ["redis-server"]
 ---> Running in 6c723b22e152
Removing intermediate container 6c723b22e152
 ---> fe2d76f691b9

Successfully built fe2d76f691b9

```
docker run fe2d76f691b9
```

### Base Images
> Writing a dockerfile == Being given a computer with no OS and being told to install Chrome

 ### Caching
 Order of installing dependencies is important in terms of using cache

### Tagging an Image

> Docker ID / Project Name : Version
```
docker build -t orgpark/redis:latest redis-server
docker run orgpark/redis:latest
```

## Section 4: Making Real Projects with Docker
### Agenda
1. Create Node.js web app
2. Create a Dockerfile
3. Build image from dockerfile
4. Run image as container
5. Connect to web app from a browser

Find appropriate base images on https://hub.docker.com/

### Copying Build Files
```
# Dockerfile: add for dependencies
COPY ./ ./

# then build
docker build -t orgpark/simpleweb .
```

### Container Port Mapping
```
# docker run -p LOCAL_PORT:CONTAINER_PORT IMAGE_NAME

docker run -p 5000:8080 orgpark/simpleweb
```

### Specifying a Working Directory
```
Dockerfile: add before dependencies section
WORKDIR /usr/app
```

### Minimizing Cache Busting and Rebuilds
We should avoid unnecessary ```npm install```. In real world application, it might take minutes. Following **Dockerfile** executes ```npm install``` only when package.json file is modified.

```
# Specify a base image
FROM node:alpine

WORKDIR /usr/app

# Install some dependencies
COPY ./package.json ./
RUN npm install

COPY ./ ./

# Default command
CMD ["npm", "start"]
```

