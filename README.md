# Personal Lecture Notes for Docker and Kubernetes at Udemy
## Resources
- Download Docker for Mac: https://download.docker.com/mac/stable/Docker.dmg


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
docker start -a CONTAINER_ID # -a for attach
```

Remove stopped processes
```
docker system prune
```

Retrieve log outputs
```
docker logs CONTAINER_ID
```

Run in background
```
docker run -d redis
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

## Section 5: Docker Compose with Multiple Local Containers
#### Docker Compose 
A framework that allows developers to define container-based applications in a single YAML file. This is for the **same** host

#### Docker Swarm
For multiple hosts

#### Kubernetes
A container orchestration tool developed by Google. Kubernetes goal is very similar as that for Docker swarm.

### Components
- web browser
- Node.js container
- redis container: keeps track of # of visits

**Need a network connection between Node.js container and redis container**
### Docker Compose
- separate CLI
- automates repetitive commands
- encode commands in *docker-compose.yml*
#### docker-compose.yml
```
version: '3'
services:
  redis-server:
    image: 'redis'
  node-app:
    build: .
    ports:
      - "4001:8081" # dash '-' is for array in yml
```
#### Networking with Docker Compose
```
// index.js
const express = require('express');
const redis = require('redis');

const app = express();
const client = redis.createClient({
    host: 'redis-server', // the name specified in the yml file
    port: 6379
});

app.get('/', (req, res) => {
    client.get('visits', (err, visits) => {
        res.send('Number of visits is ' + visits);
        client.set('visits', parseInt(visits) + 1);
    });
});

app.listen(8081, () => {
    console.log('Listening on port 8081');
})

```

#### Docker Compose Commands
```
# docker run myimage: 
docker-compose up

# docker build . + docker run myimage: 
docker-compose up --build

# Launch in background
docker-compose up -d

# Stop containers
docker-compose down

```

#### Automatic Container Restarts
Restart Policies
- "no": never restart # no is reserved for false in yml files
- always: for any reson, tries to restart
- on-failure: only restart if the container stops with an error code
- unless-stopped: always restart unless we the developers forcibly stop it

```
version: '3'
services:
  redis-server:
    image: 'redis'
  node-app:
    restart: always
    build: .
    ports:
      - "4001:8081" # dash '-' is for array in yml
      
```

#### Container Status with Docker Compose
```
docker-compose ps # can run only in which that contains docker-compose.yml
```
## Section 6: Creating a Production-Grade Workflow

### Development Workflow
Development -> Testing -> Deployment

### Client React App
```
npx create-react-app front-end
cd front-end

npm run start
npm run test
npm run build
```

### Dev Dockerfile
```
# Dockerfile.dev

FROM node:alpine

WORKDIR '/app'

COPY package.json .
RUN npm install

COPY . .

CMD ["npm", "run", "start"]

```

Specify Dockerfile name
```
docker build -f Dockerfile.dev .
```

### Docker Volumes: Referencing Local Files
**Purpose: to apply code change instantly**

```
# -v /app/node_modules: put a bookmark on the node_modules folder
# -v $(pwd):/app: Map the pwd into the '/app' folder
docker run -p 3000:3000 -v /app/node_modules -v $(pwd):/app <image_id>
```
Command is too long. Avoid it using **docker-compose.yml** file.
```
# docker-compose.yml
# docker-compose up
version: '3'
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      - /app/node_modules
      - .:/app
```
### Executing Tests
```
docker run -it 05965a16b105 npm run test
```
### Live Updating Tests
One way: Attach to currently running container
```
docker exec -it eb32b34dbd5c npm run test
```

Another way: Setup a second service in docker-compose.yml
```
version: '3'
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      - /app/node_modules
      - .:/app
  test:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - /app/node_modules
      - .:/app
    command: ["npm", "run", "test"]
```
### Need fo Nginx
- npm run start: Starts up a development server. Development use only
- npm run test: Runs test associated with the project
- **npm run build: Builds a production version of the application**

We need a web container for production such as **Nginx** to serve static files

### Multi-Step Docker Builds
Build phase:
1. Use node:alpine
2. Copy the package.json file
3. Install dependencies --> npm run build will take care of it
4. Run 'npm run build'

Run phase:

5. Start nginx --> setup needed
6. Copy over the result of **npm run build**
7. Start nginx

```
# build phase
FROM node:alpine as builder
WORKDIR '/app'
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

# run phase
FROM nginx
COPY --from=builder /app/build /usr/share/nginx/html

```

```
docker build .
docker run -p 8080:80 CONTAINER_ID
```

## Section 7: Continuous Integration and Deployment with AWS
Github -> Travis CI (.travis.yml)

**.travis.yml**
```
sudo: required
services:
  - docker

before_install:
  - docker build -t IMAGE_NAME -f Dockerfile.dev .

```

### Lecture 88. Fix for Failing Travis Builds
In the upcoming lecture we will be adding a script to our .travis.yml file. Due to a change in how the Jest library works with Create React App, we need to make a small modification:
```
script:
  - docker run USERNAME/docker-react npm run test -- --coverage

instead should be:

script:
  - docker run -e CI=true USERNAME/docker-react npm run test

```
You can read up on the CI=true variable here: https://facebook.github.io/create-react-app/docs/running-tests#linux-macos-bash

and environment variables in Docker here: https://docs.docker.com/engine/reference/run/#env-environment-variables

Additionally, you may want to set the following property if your travis build fails with “rakefile not found” by adding to the top of your .travis.yml file:
```
language: generic 
```

### Elastic Beanstalk
Deployment orchestration services by AWS. Application performance monitoring, automatic upscaling, downscaling, better performance, fault-tolerant application, robust security features, user authentication, increased availability of an application are the benefits

It monitors the traffic. If the traffic increases, it automatically scales.

.travis.yml
```
sudo: required
services:
  - docker

before_install:
  - cd ./section6-frontend
  - docker build -t image_name -f Dockerfile.dev .

script:
  - docker run -e CI=true image_name npm run test

deploy:
  provider: elasticbeanstalk
  region: "ap-northeast-2"
  app: "docker-react-section6"
  env: "DockerReactSection6-env"
  bucket_name: "elasticbeanstalk-ap-northeast-2-988703214432"
  bucket_path: "ap-northeast-2"
  on:
    branch: master
  access_key_id:
    secure: $AWS_ACCESS_KEY
  secret_access_key:
    secure: $secret
```

### Port Mapping
Even if you go through the Docker and Elastic Beanstalk, it doesn't really tell about the port mapping.

Add EXPOSE in Dockerfile
```
# build phase
FROM node:alpine as builder
WORKDIR '/app'
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

# run phase
FROM nginx:stable-alpine
EXPOSE 80
COPY --from=builder /app/build /usr/share/nginx/html # check nginx document for directory
```

### Workflow with Github
1. Travis CI test gets run on PR. 
2. Deploy happens when merged

### Environment Cleanup
- Click on 'Delete Application' then confirm the delete

## Section 8: Building a Multi-Container Application

### Single Container Deployment Issues
- The app was simple - no outside dependencies
- Our image was built multiple times
- How do we connect to a database from a container
