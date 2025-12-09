# Project 4 - CD 

## Scripting a Refresh

### EC2 Instance Details
For this Project, I went back to the good ole days within the course (literally like three Projects ago) and used the CloudFormation template I made from project 2 and tinkered it a little bit to fit requirements expected in Project 5. The following changes and overall resources went into the instance is as followed:

- AMI Information: Uses Ubuntu once more (can't ever get enough of it) with model version of 24.04 and ID of `ami-0ecb62995f68bb549`
- Instance Type: t2.medium (purpose of this instance type listed below)
- Recommended Volume Size: 30 GB Storage (as mentioned in the Project overview) with 2 CPU Core and 4 GB Ram, which is all included in the usage of t2.medium instance type, making it preferable for this Project
- Security Group Configuration:
  - Allows SSH from the following places:
  - My Home
  - WSU Campus
  - Within Instance VPC/Subnet
  - Allows HTTP on Port 80 and Port 8080 from anywhere
- Security Group Configuration: The SSH rules limit where one can access the instance containing the Continuous Deployment, only to be in my personal home or at WSU, HTTP on Ports 80 and 8080 need to be from anywhere in order to make it publicly accessable from within the instance

For reference to the CloudFormation template, heres the entire yml file that I used to build the instance for this Project: [HAMDANP5-CF.yml](HAMDANP5-CF.yml)

### Docker Setup on OS on the EC2 instance
To install docker on the OS/EC2 instance, the following code block from the CF UserData section helped install Docker.io and other important packages for the project, as well as enabling and starting Docker and providing user permission to use it:

```
#!/bin/bash -xe
            apt-get update && \
            
            # installs git and docker and other miscellaneous things
            apt-get install -y \
               git \
               htop \
               apache2 \
               docker.io && \

            # starts and enables docker
            systemctl enable docker && \
            systemctl start docker && \

            # fixes docker permissions on default
            sudo usermod -aG docker $USER
```

To make sure it works, you can check if `docker --version` shows any output on the current Docker version you have installed, and if you do you can run a docker command to make sure it works as I used `docker run hello-world`

### Testing an EC2 Instance
Also within the CF UserData section, the code pulls my docker image from my repository and runs it on 80/80, can be seen as followed:

```
# pulls my docker image 
docker pull admahamdan2005/brawlstars-site:latest && \
            
# runs docker image in detatched mode (host port 80, user 80), container restarts automatically if system reboots
docker run -d -p 80:80  admahamdan2005/brawlstars-site:latest --restart unless-stopped && \
```

The use of `-d` represents detached mode, meaning the docker image with all its content would be running in the background without the user manually within the containers terminal, as using `-it` (which means interactive terminal) would be when the user goes within the terminal to interact with its functionality, as detached mode would be the better use for testing due to web content production being better non-interactively.
