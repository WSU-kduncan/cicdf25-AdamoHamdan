# Project 4 - CI

## Dockerfile & Building Images
Since this is basically a repeat of the actions done in Project 3, the following description is mostly a repeat: There is another folder within the directory `web-content`, and as the name says: it contains content you can read on a website. For my site, I asked my good friend ChatGPT (you may have heard about him/her as a professor/instructor for all the bad reasons if you know what I mean...) to create a site based off my favorite mobile game of all time that I still play to this day (and may have shamelessly found myself playing a few times during lecture): Brawl Stars, you can learn about it when you checkout my project submission and access the site!

Link directly to the `web-content` folder: [web-content](/web-content/)

Also in the project folder, the `Dockerfile` was created in correlation to the web content with the purpose of being able to put the web content into a apache container and move it into apaches default directory to be able to create access it on a website link/browser

Link directly to the `Dockerfile`: [Dockerfile](Dockerfile)

The following steps follow along with the process of creating a Docker Image and using it:
1. Be in Terminal within the directory containing the web-content
2. Use the following docker command to build a container image containing the web content: `docker build -t admahamdan2005/brawlstars-site:latest .`
3. Input `docker login` to sign into your docker hub account, you will be given a prompt to enter your username and such and then given a PAT (personal access token) to input in order to fully enter in the desired account
4. Push the docker image into personal repository within docker hub: `docker push admahamdan2005/brawlstars-site:latest`
5. Now you should be able to run your image: `docker run -d -p 8080:80 admahamdan2005/brawlstars-site:latest` (runs on detatched mode and on container port 80 and host port 8080)
6. To test if it worked, go on a browser and input the following link: `http://localhost:8080`
7. Boom! Now go check out my Brawl Stars Website!

Link to my DockerHub Repository where my one and lonely docker image sits: [DockerHub - admahamdan2005](https://hub.docker.com/repositories/admahamdan2005)
