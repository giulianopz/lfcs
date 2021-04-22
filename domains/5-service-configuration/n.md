## Manage and configure containers

While virtualization is in many ways similar to containers, these are different and implemented via other solutions like **LXD**, **systemd-nspawn**, **containerd** and others.

LXD (pronounced lex-dee) is the lightervisor, or lightweight container hypervisor. LXC (lex-see) is a program which creates and administers “containers” on a local system. It also provides an API to allow higher level managers, such as LXD, to administer containers. In a sense, one could compare LXC to QEMU, while comparing LXD to libvirt.

### Docker

Prerequisites:

- Docker **Community Edition** (CE) is installed as described in the offical [doc](https://docs.docker.com/engine/install/ubuntu/)
- a personal account on **Docker Hub**

Docker containers are built from Docker images. By default, Docker pulls these images from Docker Hub, a Docker registry managed by Docker, the company behind the Docker project. Anyone can host their Docker images on Docker Hub, so most applications and Linux distributions you’ll need will have images hosted there.

If you want to avoid typing sudo whenever you run the docker command, add your username to the docker group: `sudo usermod -aG docker ${USER}`

To apply the new group membership, log out of the server and back in, or type the following: `newgrp docker`

To view all available subcommands, just type: `docker`

To view the options available to a specific command, type: `docker [docker-subcommand] --help`

To view system-wide information about Docker, use: `docker info`

To check whether you can access and download images from Docker Hub, type: `docker run hello-world`

You can search for images available on Docker Hub by using: `docker search ubuntu`

Once you’ve identified the image that you would like to use, you can download it to your computer using: `docker pull ubuntu`

After an image has been downloaded, you can then run a container using the downloaded image with the `run` subcommand. As you saw with the hello-world example, if an image has not been downloaded when docker is executed with the `run` subcommand, the Docker client will first download the image, then run a container using it.

To see the images that have been downloaded to your computer, type: `docker images`

After using Docker for a while, you’ll have many active (running) and inactive containers on your computer. To view the active ones, use: `docker ps`

To view all containers — active and inactive: `docker ps -a`

To view the latest container you created: `docker ps -l`

To start a stopped container, use docker start, followed by the container ID or the container’s name: `docker start d9b100f2f636`

To stop a running container, use docker stop, followed by the container ID or name: `docker stop [sharp_volhard]`

Once you’ve decided you no longer need a container anymore, remove it: `docker rm [festive_williams]`

Containers can be turned into images which you can use to build new containers.

When you start up a Docker image, you can create, modify, and delete files just like you can with a virtual machine. The changes that you make will only apply to that container. You can start and stop it, but once you destroy it with the docker rm command, the changes will be lost for good.  

To this purpose, save the state of a container as a new Docker image committing the changes to a new Docker image instance using:
`docker commit -m "What you did to the image" -a "Author Name" [container_id] [repository/new_image_name]`

When you commit an image, the new image is saved locally on your computer.

> Note: Listing the Docker images again will show the new image, as well as the old one that it was derived from.

> Note: You can also build Images from a `Dockerfile`, which lets you automate the installation of software in a new image. 

The next logical step after creating a new image from an existing image is to share it by pushing the image to Docker Hub (or any other Docker registry).

To push your image, first log into Docker Hub: `docker login -u docker-registry-username`

> Note: If your Docker registry username is different from the local username you used to create the image, you will have to tag your image with your registry username, e.g. : `docker tag [sammy/ubuntu-nodejs] [docker-registry-username/ubuntu-nodejs]`

Then you may push your own image using: `docker push [docker-registry-username/docker-image-name]`

You can now use `docker pull [docker-registry-username/docker-image-name]` to pull the image to a new machine and use it to run a new container.