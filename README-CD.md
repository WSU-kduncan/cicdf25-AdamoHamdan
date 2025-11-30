# Project 4 - CD (NOTE: Made an oopsie! If you're reading this please go to the other read me file for full documentation contents!)

## Generating Tags
Tags in git are affiliated with semantic versioning, which help with pulling, pushing, or just simply obtaining a specific version of a docker image without always using the latest version. In order to see tags simply use the `git tags` command within your repository directory: as it would list down every version tag you have, heres an example:
```
adamohamdan@Adamo:~/cicdf25-AdamoHamdan$ git tag
v1.0.0
v3.8.1
```
And if you want to see the knits and grits of the version tag, you can use the `git show` command to print out the entire data information of it, as heres another example:
```
adamohamdan@Adamo:~/cicdf25-AdamoHamdan$ git show v1.0.0
tag v1.0.0
Tagger: AdamoHamdan <adamohamdan05@gmail.com>
Date:   Mon Nov 24 23:09:54 2025 -0500

testing commit tag

commit 56e9293734a0d095bfa3b5be84d857653e162c91 (tag: v1.0.0)
Author: AdamoHamdan <adamohamdan05@gmail.com>
Date:   Mon Nov 24 22:33:22 2025 -0500

    finished up the yml file within workflow folder

diff --git a/.github/workflows/docker-publish.yml b/.github/workflows/docker-publish.yml
index 1c41fb4..5d2218b 100644
--- a/.github/workflows/docker-publish.yml
+++ b/.github/workflows/docker-publish.yml
@@ -1,6 +1,35 @@
-name: build and push Docker Images to main branch
+name: build and push Docker images to main branch

 on:
   push:
     branches:
       - main
+
+jobs:
+  build-and-push:
+    runs-on: ubuntu-latest
+
```
In order to create a tag use the following formatted example as reference (used v1.0.0) within the repository directory: `git tag -a v1.0.0 -m "testing commit tag"`, and in order to push said tags to github use the following example as reference as well: `git push origin v1.0.0.0`

## Semantic Versioning Container Images with GitHub Actions
In correlation with part 3 of the project, the workflow yml file has been revamped to extract the tags data and uses its version to build the docker image, as the trigger works with multiple tag types/values. There are also three tag types: `latest` (admahamdan2005/brawlstars-site:latest), `major` (admahamdan2005/brawlstars-site:1), `major.minor` (admahamdan2005/brawlstars-site:1.3)

- Workflow Trigger: Below would be what I had in my yml code block for the trigger for part 3 of the project:
```
on:
  push:
    branches:
      - 'v*.*.*'
```
This ensures that the workflow triggers only when tags with the listed format of semantic versioning are listed in git

- Workflow Steps: Below is what I had in my yml code block for the actions the workflow would make in part 3 of the project:
```
steps:
      - name: check the repository
        uses: actions/checkout@v4

      - name: setting up the QEMU
        uses: docker/setup-qemu-action@v3

      - name: setting up Docker buildx
        uses: docker/setup-buildx-action@v3

      - name: logging into Dockerhub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}
      
      - name: get metadata through tags and labels
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ secrets.DOCKER_USERNAME }}/brawlstars-site

      - name: build and push Docker images
        uses: docker/build-push-action@v4
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
 
```
Below is a summary of the above listed steps in order:
1. Uses the GitHub checkout action in order to check out/get the data of the target repository
2. Does the default QEMU set up action in order to perform cross-platform image building
3. Sets up the docker build action in order to build an image
4. Logs into Docker with the standard of asking for username and password (which we use the mentioned PAT as authorization)
5. Obtains the metadata for the git tag on the docker image
6. Builds and pushes the docker image from my web content folder with the initialization from the Dockerfile for reference/context, now incorporating the tag data

- Values that would need updating on a new repository:
- Workflow changes:
  - docker image in the meta action step/section: would need to match docker username/repository
  - Tag values: must fit the targeted version type
  - Dockerfile: Maybe changed, depending on if it is in root or within a folder (I kept mine in root for this project and project 3)
  - Branch trigger/tag patterns: must match the workflow deployment type/strategy
- Repository changes:
  - secret names/variables: secret values must copy that of the docker username and token meant to be used for that repository (ex: the DOCKER_USERNAME and DOCKER_TOKEN)
  - Like the workflow in part 2, repository on DockerHub must exist

Workflow folder with yml file within it for reference (made for part 3 of the project): [.github/workflows](https://github.com/WSU-kduncan/cicdf25-AdamoHamdan/blob/main/.github/workflows/docker-publish.yml)

## Testing & Validating
The following steps are to ensure the workflow did its tasking:
1. First make sure you have set up a tag using the `git tag` and `git push` commands
2. Within repository, navigate to Actions tab, as there you should see the list of all the workflow runs with their commit messages
3. If the commits have a checkmark next to them, that means the workflow succeeded!
4. You can click on these workflow runs to see the logs for further data to be able to see if the steps were all passed and such
5. Also you can check the repository Tags button to see the list of all tags pushed to the repository

The following steps are to verify the DockerHub Image works:
1. On DockerHub, check the repository containing the image and inspect its tag history as it should contain different version tags and such
2. Within the repository on the terminal, pull the docker image (everything should be up to date when doing so in terms of image version): `docker pull admahamdan2005/brawlstars-site:latest`
3. After pulling, run the image within the repository: `docker run -d -p 8080:80 admahamdan2005/brawlstars-site:latest`
4. When going to a local browser, the link `http://localhost:8080/` should be running the web content within the docker image (which in my case is the brawl stars website), which would mean the CI is working all good!

Link to my DockerHub Repository once more: [DockerHub - admahamdan2005](https://hub.docker.com/repositories/admahamdan2005)

## Citations/Resources

