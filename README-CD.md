# Project 5 - CD 

## Continuous Deployment Project Overview 
The general goal of this project was to get used to the concept of working with and creating CD (Continuous Deployment), as we had to fully operate building, pushing, tagging, and publishing my Docker image container. In order to accomplish these tasks, we had to create a script that pulls my image and removes previous running container with a new one to run the image and assign a webhook listener that runs that script, where at the end the image should always be constantly updating the container holding the latest version of the docker web content image.

The following list of tools were used in order to carry out the implementation of Continuos Deployment (left the tools from Project 4 becasue they feel fitting):
- GitHub CI/CD Course Repository: The main placeholder of the entire Project as it was used to contain the deloyment folder containing the bash script and webhooks, web content for the docker image, the Dockerfile associated with said content, store the saved/pushed tags, and where all the commits to the main branch go to
- GitHub Actions/Workflow: The main engine of the project CI as it was responsible for the many actions and steps occured to build and push the Docker image, used many Actions like checkout, set-up-buildx, login-action, and etc
- GitHub Secrets: Used to contain the private values of my DockerHub username and a Docker Personal Access Token for the login step within the workflow, as it securely keeps said values secret and secure, as well as assigning "secretValue" to webhook listener
- Docker/DockerHub: Responsible for containing the Docker Image made from the web-content (initialized and set up via Dockerfile within the project) and all its versions and tags, and used throughout the workflow within the steps block of the yml file to login and push the image, as well as copies of the webhooks used for the webhooks and bash script
- Bash Script (refresh.sh): Script in deployment folder meant to be the action a webhook istener does in order to update the current container for the web content Docker image
- EC2 Instance: Set up to contain a copy of the GitHub Repository for reference, as well as used to operate the actual webhook listener, service file, and bash script
- Adnanh/webhook: Used his webhook package to create the webhook listener and the service file, basically he is responsible for the entire webhook bananza
- hooks listener: Used to represent where the webhook will run the bash script and when it would do so based on trigger condition
- webhook service: Script file meant to initialize the webhooks to properly run and ping on port 9000 and such

Throughout the Project, there were a few issues that occured when creating the webhooks, as it mostly came from the idea where I couldn't truly tell if my hook is properly working. The listener appears to be properly set up with exisiting file locations and directories within the repository as the trigger would not fully show the entire bash script output (the four steps as seen in the script in deployment folder), and it was hard to tell if my webhook was getting the payload from git. I will continue to constantly revamp the webhook content to make sure everything is properly set to go for the in person presentation (will refer to any more details and such during said presentation)

### Continuous Deployment Diagram
The following diagram is a visual representation of how the CD process moves in relation to the project context and objectives:

(Image will go here)

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
  - Allows TCP anywhere on Port 9000
- Security Group Configuration: The SSH rules limit where one can access the instance containing the Continuous Deployment, only to be in my personal home or at WSU, HTTP on Ports 80 and 8080 need to be from anywhere in order to make it publicly accessable from within the instance, as well as 9000 needed for webhooks to work

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

You can also use `sudo systemctl status webhook` to make sure the webhook is properly running the listener as it should show the script running as followed (for some reason is shows most of it but not all of it):

```
ubuntu@Project5-Instance:~$ sudo systemctl status webhook
● webhook.service - Webhook Listener
     Loaded: loaded (/usr/lib/systemd/system/webhook.service; enabled; pres>
     Active: active (running) since Tue 2025-12-09 05:05:40 UTC; 16min ago
   Main PID: 2638 (webhook)
      Tasks: 8 (limit: 4667)
     Memory: 27.0M (peak: 35.9M)
        CPU: 206ms
     CGroup: /system.slice/webhook.service
             └─2638 /usr/bin/webhook -hooks /var/webhook/hooks.json -hotrel>

Dec 09 05:13:03 Project5-Instance webhook[2638]: Step 3 Complete!
Dec 09 05:13:03 Project5-Instance webhook[2638]: Step 4: runs a new contain>
Dec 09 05:13:03 Project5-Instance webhook[2638]: 731c3933952e8ea370f0de14d3>
Dec 09 05:13:03 Project5-Instance webhook[2638]: Step 4 Complete!
Dec 09 05:13:03 Project5-Instance webhook[2638]: All Steps Completed!
Dec 09 05:13:03 Project5-Instance webhook[2638]: [webhook] 2025/12/09 05:13>
Dec 09 05:18:01 Project5-Instance webhook[2638]: [webhook] 2025/12/09 05:18>
Dec 09 05:18:01 Project5-Instance webhook[2638]: [webhook] 2025/12/09 05:18>
Dec 09 05:18:01 Project5-Instance webhook[2638]: [webhook] 2025/12/09 05:18>
Dec 09 05:18:01 Project5-Instance webhook[2638]: [webhook] 2025/12/09 05:18
```

When monitoring the webhook, use the `journalctl -u webhook -f` command to get a listed output of how your webhook listener worked, as the following output shows what that would look like (yet again the same weird stuff showing but it works when putting it on the browser):

```
ubuntu@Project5-Instance:~$ journalctl -u webhook -f
Dec 09 05:13:03 Project5-Instance webhook[2638]: Step 3 Complete!
Dec 09 05:13:03 Project5-Instance webhook[2638]: Step 4: runs a new container image
Dec 09 05:13:03 Project5-Instance webhook[2638]: 731c3933952e8ea370f0de14d3346c908a1d2d1a9eaeb98a2558c14c44243df5
Dec 09 05:13:03 Project5-Instance webhook[2638]: Step 4 Complete!
Dec 09 05:13:03 Project5-Instance webhook[2638]: All Steps Completed!
Dec 09 05:13:03 Project5-Instance webhook[2638]: [webhook] 2025/12/09 05:13:03 [5589eb] finished handling deployment-container
Dec 09 05:18:01 Project5-Instance webhook[2638]: [webhook] 2025/12/09 05:18:01 [913bb4] incoming HTTP POST request from 140.82.115.12:26294
Dec 09 05:18:01 Project5-Instance webhook[2638]: [webhook] 2025/12/09 05:18:01 [913bb4] deployment-container got matched
Dec 09 05:18:01 Project5-Instance webhook[2638]: [webhook] 2025/12/09 05:18:01 [913bb4] deployment-container got matched, but didn't get triggered because the trigger rules were not satisfied
Dec 09 05:18:01 Project5-Instance webhook[2638]: [webhook] 2025/12/09 05:18:01 [913bb4] 200 | 30 B | 275.266µs | 100.30.142.170:9000 | POST /hooks/deployment-container
```

When looking at the journal output it is important to check if the script is running (the echo outputs stating the steps made and completed) as well as any docker commands running and giving outputs (the long string of text below step 4), and requests for where these webhook calls are being made.

For reference for my hook listener, you can view it here: [hooks.json](/deployment/hooks.json)

### Configurating a webhook Service on EC2 Instance
The webhook service file intializes and sest everything up for the hook listener to work, as it does the following:
- Starts hook at boot
- Uses hot reload for said hook
- Runs scripting as Ubuntu user
- Restarts if errors occur to avoid jamming

In order to make sure the service is applied, use `sudo systemctl daemon-reload` to save and initialize new changes as well as restarting, enabling, and starting up again the webhook service. You can also use the above webhook status command to make sure the service is good, as for the service you would have to track if it is running on port 9000 as needed, having a running service, and having correct hooks loaded.

For reference for my hook listener, you can view it here: [webhook.service](/deployment/webhook.service)

## Sending a Payload
For this Project, I decided to go with GitHub for this part because Im already more familiar with it in general, as the workflow in the repository is already set up to help build and push the docker images.

The following steps help to step up the webhooks in GitHub:
- Navigate to Settings > WebHooks > Add WebHooks
- Payload Url: http://100.30.142.170:9000/hooks/deployment-container
- Content Type: application/json
- Secret: secretValue
- SSL: Disabled since we dont use it
- Event Trigger: Just push tag events

Referring back to the workflow from Project 4, the trigger that would be used to send the payload would be when a new git tag is pushed to v*.*.*, as within the terminal you should see the webhook operate the bash script within the hook listener using `journalctl -u webhook -f`, and within github you can go within the recent deliveries and see the payload information from in there, as everything should be green check marked just like how a workflow would be.

To ensure the security verification is good, refer to the following code block in the hooks.json listener:

```
"trigger-rule": {
      "match": {
        "type": "payload-hash-sha256",
        "secret": "secretValue",
        "parameter": {
          "source": "header",
          "name": "X-Hub-Signature-256"
        }
```

That ensures that requests involving "X-Hub Signatures: secretValue" can only trigger as any requests missing will be rejected.

## Citations/Resources
- Resources used throughout the Project:
    - Course Webex Videos: Used to go back to for rewatching past lectures on the topics of bash scripting recaps, webhook initialization, listeners and services files, and etc as well as watching those in class demos going over said topics
    - ChatGPT: Used as a backup resource when either wanting a simple overview of a topic used in this project or an example of something, as well as helping me when really stumped at certain parts in the project, gave it prompts like "Provide an overview of how to properly set up a webhook listener trigger", "Ways and methods to set up a webhook service", and "Troubleshooting methods to make sure webhook works properly regarding payload"
- Resources used for Part 1:
  - CloudFormation Template: A revised version from Project 2/3 to help make a placeholder for creating the instance used in the project, as within the instance is where all the content is done and made
  - [LinuxBash](https://www.linuxbash.sh/post/how-to-create-bash-scripts-for-container-management-docker): Provided methods and ways to create the bash script that pulls docker images and removes and creates new containers for running my image
  - [Docker](https://docs.docker.com/reference/dockerfile/): Used to understand the docker commands usable in these types of files and which ones are most fitting for project requirements
  - ChatGPT: Of course I just had to use this bad boy to help me create a quick and easy web page to work off of for the rest of the project (Gave it the following prompt: "write a very basic index.html file with a theme of my favorite mobile game of all time: brawl stars! Have it simply share what its about and that its my favorite mobile game! make it obvious it was written by you and made for me! have it include another html page as well as a css file to go with it", it also helped in the bash script file to set up a proper way to run commands without errors halting it
- Resources used for Part 2 of the Project: 
  - [adnanh's `webhook`](https://github.com/adnanh/webhook): Used the webhook package to operate the whole Continuous Deployment, also provided info on creating webhook listeners and how to structure them with certain code blocks
  - [Using GitHub actions and `webhook`s](https://levelup.gitconnected.com/automated-deployment-using-docker-github-actions-and-webhooks-54018fc12e32): Provided information on how to integrate webhooks to the git workflow in order to properly link the webhook listener in order to carry out the bash script
  - [Using DockerHub and `webhook`s](https://blog.devgenius.io/build-your-first-ci-cd-pipeline-using-docker-github-actions-and-webhooks-while-creating-your-own-da783110e151): Same purpose as the above resource
  - [Linux Handbook - How to Create a `systemd` Service](https://linuxhandbook.com/create-systemd-services/): Provides information on how to set up the webhook service to properly initialize the webhook to work and track properly for Continuous Deployment
- Resource used for the Part 4 diagram:
  - [LucidChart](https://lucid.app/documents#/home?folder_id=recent): Used this website to create the diagram
