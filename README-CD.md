# Project 5 - CD 

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

To make sure the Docker image works properly, go on a browser and input `http://100.30.142.170/` as it should display the website (the ip is the elastic ip/public ip from the instance used for the project)

### Bash Script
The script creates two variables to represent value tracking a container name and docker image name (use of variables creates easier method of plugging in other images for future use if needed). The script then pulls the latest Docker image version > stops current container > removes current container > then runs newest container with Docker image.

To verify it works, within the deployment folder make sure the executable permissions for the file is good using `chmod +x refresh.sh` and then run it using `./refresh.sh`, as it an example successful run is seen as followed:

```
ubuntu@Project5-Instance:~/cicdf25-AdamoHamdan/deployment$ ./refresh.sh
Step 1: pulls latest Docker image
latest: Pulling from admahamdan2005/brawlstars-site
Digest: sha256:2b42c039510d1746d0101f6e26445a2e2df1e535ea78b13ff43f7cf098e21674
Status: Image is up to date for admahamdan2005/brawlstars-site:latest
docker.io/admahamdan2005/brawlstars-site:latest
Step 1 Complete!
Step 2: stops previous running container image
webapp
Step 2 Complete!
Step 3: removes previous running container image
webapp
Step 3 Complete!
Step 4: runs a new container image
bbc844fb25e01fe74cafd5d231aa1b518d1d3a8e9b322284e288e2bb08faed06
Step 4 Complete!
All Steps Completed!
```

And of course run the same browser search `http://100.30.142.170/` to make sure the content is still being displayed properly with the new container!

For reference to my bash script, here is a direct link to it: [refresh.sh](/deployment/refresh.sh)

## Listening

### Configurating a `webhook` Listener on EC2 Instance
Here's how to properly install Adnans webhook for the project:
- On instance, use the command `sudo apt install webhook`
- To make sure its installed, run `webhook --version` to make sure it is there

For the webhook, the `hooks.json` file is set to configure a hook definition for webhook to load and run, as details of the hook is as followed:
- Custom name of "deployment container" (I thought it was fitting)
- Executes the command from the refresh script located in the deployment folder within instance and does so on home directory
- Only triggers when HTTP contains a header

To test it works, run `sudo webhook -hooks /var/webhook/hooks.json -verbose`, as the following output should show if successful:

```
ubuntu@Project5-Instance:~/cicdf25-AdamoHamdan$ sudo webhook -hooks /var/webhook/hooks.json -verbose
[webhook] 2025/12/09 03:53:22 version 2.8.0 starting
[webhook] 2025/12/09 03:53:22 setting up os signal watcher
[webhook] 2025/12/09 03:53:22 attempting to load hooks from /var/webhook/hooks.json
[webhook] 2025/12/09 03:53:22 found 1 hook(s) in file
[webhook] 2025/12/09 03:53:22   loaded: deployment-container
[webhook] 2025/12/09 03:53:22 serving hooks on http://0.0.0.0:9000/hooks/{id}
[webhook] 2025/12/09 03:53:22 os signal watcher ready
```
