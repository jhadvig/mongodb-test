# MongoDB for OpenShift - Docker images

This repository contains Dockerfiles for MongoDB images for OpenShift.
Users can choose between RHEL and CentOS based images.

### Versions

MongoDB versions currently supported are:

* mongodb-2.4

RHEL versions currently supported are:

* RHEL7

CentOS versions currently supported are:

* CentOS7


## Installation
Choose between CentOS7 or RHEL7 based image:

*  **RHEL7 based image**

	This image is not available as automated build in [Docker Index](https://index.docker.io).

	To build a rhel7-based image, you need to run Docker build on a properly subscribed RHEL machine.

	```console
	git clone https://github.com/openshift/mongodb.git
	cd mongodb
	make build TARGET=rhel7
	```

*  **CentOS7 based image**

	```console
	git clone https://github.com/openshift/mongodb.git
	cd mongodb
	make build
	```

## Usage

### Environment variables

The image recognizes following environment variables that you can set
during initialization, by passing `-e VAR=VALUE` to the Docker run
command.

|    Variable name         |    Description                              |   Default  |
| :----------------------- | -----------------------------------------   | ---------- |
|  `MONGODB_USER`          | User name for MONGODB account to be created |
|  `MONGODB_PASSWORD`      | Password for the user account               |
|  `MONGODB_DATABASE`      | Database name (optional)                    | production |
|  `MONGODB_ROOT_PASSWORD` | Password for the root user (optional)       |

You can also set following mount points by passing `-v /host:/container`
flag to docker.

|  Volume mount point    | Description            |
| :--------------------- | ---------------------- |
|  `/var/lib/mongodb/`   | MongoDB data directory |


### Usage

We will assume that you are using the `openshift/mongodb-24-centos7`
image. Supposing that you want to set only mandatory required environment
variables and store the database on in the `/home/user/database`
directory on the host filesystem, you need to execute the following
command:

```console
docker run -d -e MONGODB_USER=<user> -e MONGODB_PASSWORD=<password> -e MONGODB_DATABASE=<database> -v /home/user/database:/var/lib/mongodb openshift/mongodb-24-centos7
```

If you are initializing the database and it's the first time you are using the
specified shared volume, the database will be created, together with database
administrator user and also MongoDB root user if `MONGODB_ADMIN_PASSWORD`
environment variable is specified. after that the MongoDB daemon will be
started
If you are re-attaching the volume to another container the creation of the
database admin user and the root user will be skipped and only the mongodb
daemon will be started


### MongoDB root user
The root user in not set by default. You can create him by setting 
`MONGODB_ROOT_PASSWORD` environment variable, in which case the root 
user name will be set to `admin`. This process is done upon initializing 
the database.


## Software Collections
We use [Software Collections](https://www.softwarecollections.org/) to
install and launch MongoDB. If you want to execute a command inside of a
running container (for debugging for example), you need to prefix it
with `scl enable` command. Some examples:

```console
# Running mongodb commands inside the container
scl enable mongodb24 -- mongo <db_name> -u <username> -p <password>

# Executing a command inside a running container from host
# Note: You will be able to run mongodb commands without invoking the scl commands
docker exec -ti <CONTAINER_ID> scl enable mongodb24 /bin/bash
```

## Test

This repository also provides test framework, which launches tests to check functionality of the MongoDB image.

User can choose between testing MongoDB based on RHEL or CentOS image.

*  **RHEL based image**

    This image is not available as automated build in [Docker Index](https://index.docker.io).

    To test a rhel7-based MongoDB image, you need to run the test on a properly
    subscribed RHEL machine.

    ```
    $ cd mongodb
    $ make test TARGET=rhel7 VERSION=2.4
    ```

*  **CentOS based image**

    ```
    $ cd mongodb
    $ make test VERSION=2.4
    ```

**Notice: By omitting the `VERSION` parameter, the build/test action will be performed
on all the supported versions of MongoDB. Since we are now supporting only version `2.4`
you can omit this parameter.**



