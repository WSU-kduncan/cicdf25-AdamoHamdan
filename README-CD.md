# Project 4 - CD

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
