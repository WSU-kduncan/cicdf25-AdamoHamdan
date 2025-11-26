# Project 4 - CI

## Dockerfile & Building Images
Since this is basically a repeat of the actions done in Project 3, the following description is mostly a repeat: There is another folder within the directory `web-content`, and as the name says: it contains content you can read on a website. For my site, I asked my good friend ChatGPT (you may have heard about him/her as a professor/instructor for all the bad reasons if you know what I mean...) to create a site based off my favorite mobile game of all time that I still play to this day (and may have shamelessly found myself playing a few times during lecture): Brawl Stars, you can learn about it when you checkout my project submission and access the site!

Link directly to the `web-content` folder: [web-content](/web-content/)

Also in the project folder, the `Dockerfile` was created in correlation to the web content with the purpose of being able to pull from Apache put the web content into a apache container and move it into apaches default directory to be able to create access it on a website link/browser

Link directly to the `Dockerfile`: [Dockerfile](Dockerfile)

The following steps follow along with the process of creating a Docker Image and using it:
1. Be in Terminal within the directory containing the web-content
2. Use the following docker command to build a container image containing the web content: `docker build -t admahamdan2005/brawlstars-site:latest .` (latest tag makes sure to always show the most recent version of the image)
3. Input `docker login` to sign into your docker hub account, you will be given a prompt to enter your username and such and then given a PAT (personal access token) to input in order to fully enter in the desired account
4. Push the docker image into personal repository within docker hub: `docker push admahamdan2005/brawlstars-site:latest`
5. Now you should be able to run your image: `docker run -d -p 8080:80 admahamdan2005/brawlstars-site:latest` (runs on detatched mode and on container port 80 and host port 8080)
6. To test if it worked, go on a browser and input the following link: `http://localhost:8080`
7. Boom! Now go check out my Brawl Stars Website!

Link to my DockerHub Repository where my one and lonely docker image sits: [DockerHub - admahamdan2005](https://hub.docker.com/repositories/admahamdan2005)

## Configurating GitHub Repository Secrets
1. Go to DockerHubs website > Navigate to Account Settings: Personal Access Tokens (PAT)
2. Click Generate New Access Token > Assign it a name value (went with CEG3120-Project4) and access permissions/scope (for this project, I went with read/write so that GitHub is able to read the images and push them onto repository)
3. Create the token and copy its access value
4. In the GitHub repository, go to Settings > Secrets and Variables: Actions > Repository Secrets
5. Create two new secret variables: DOCKER_USERNAME and DOCKER_TOKEN and assign them the secret values (docker username and docker access token value) and save both variables
6. With these two secret values, we are now able to use my personal Docker username (admahamdan2005, yes that typo is part of the name), to be used as account authentication in order for GitHub to be able to push from the repository via actions towards my DockerHub repository

## CI With GitHub Actions:
Regarding the yml file part of the Workflow, there are different parts/segments that makeup the entire CI:

- Workflow Trigger: Below would be what I had in my yml code block for the trigger:
```
on:
  push:
    branches:
      - main
```
This ensures that the workflow triggers only when a commit is pushed to main within the repository so that CI runs on ready changes

- Workflow Steps: Below were what I had in my yml code block for the actions the workflow would make
```
steps:
      - name: check the repository
        uses: actions/checkout@v4

      - name: seeting up the QEMU
        uses: docker/setup-qemu-action@v3

      - name: setting up Docker buildx
        uses: docker/setup-buildx-action@v3

      - name: logging into Dockerhub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      - name: build and push Docker images
        uses: docker/build-push-action@v4
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/brawlstars-site:latest
```
Below is a summary of the above listed steps in order:
1. Uses the GitHub checkout action in order to check out/get the data of the target repository
2. Does the default QEMU set up action in order to perform cross-platform image building
3. Sets up the docker build action in order to build an image
4. Logs into Docker with the standard of asking for username and password (which we use the mentioned PAT as authorization)
5. Builds and pushes the docker image from my webcontent folder with the initialization from the Dockerfile for reference/context

- Values that would need updating on a new repository:
- Workflow changes:
  - docker image name: would need to match docker username/repository
  - Dockerfile: Maybe changed, depending on if it is in root or within a folder (I kept mine in root for this project and project 3)
  - Branch trigger: must match the workflow deployment type/strategy
- Repository changes:
  - secret names/variables: secret values must copy that of the docker username and token meant to be used for that repository (ex: the DOCKER_USERNAME and DOCKER_TOKEN)
Workflow folder with yml file within it for reference (by this point the yml file may have been updated to fit part 3's standards, you can alwasy refer to the code blocks I provided in this section or commit history!): [.github/workflows](https://github.com/WSU-kduncan/cicdf25-AdamoHamdan/blob/main/.github/workflows/docker-publish.yml)

## Testing & Validating
The following steps are to ensure the workflow did its tasking:
1. Make a commit within the repository that leads to the main branch
2. Within repository, navigate to Actions tab, as there you should see the list of all the workflow runs with their commit messages
3. If the commits have a checkmark next to them, that means the workflow succeeded!
4. You can click on these workflow runs to see the logs for further data to be able to see if the steps were all passed and such

The following steps are to verify the DockerHub Image works:
1. Within the repository on the terminal, pull the docker image (everything should be up to date when doing so in terms of image version): `docker pull admahamdan2005/brawlstars-site:latest`
2. After pulling, run the image within the repository: `docker run -d -p 8080:80 admahamdan2005/brawlstars-site:latest`
3. When going to a local browser, the link `http://localhost:8080/` should be running the web content within the docker image (which in my case is the brawl stars website), which would mean the CI is working all good!

Link to my DockerHub Repository once more: [DockerHub - admahamdan2005](https://hub.docker.com/repositories/admahamdan2005)
