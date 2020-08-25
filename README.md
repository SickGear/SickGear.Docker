![SickGear Logo](https://raw.githubusercontent.com/SickGear/SickGear/master/gui/slick/images/sickgear-large.png)

This is the official SickGear Docker repository.  
  
[![Docker Pulls](https://img.shields.io/docker/pulls/sickgear/sickgear.svg?color=399439&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/sickgear/sickgear)[![Docker Stars](https://img.shields.io/docker/stars/sickgear/sickgear.svg?color=399439&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=stars&logo=docker)](https://hub.docker.com/r/sickgear/sickgear)[![GitHub Stars](https://img.shields.io/github/stars/SickGear/SickGear.Docker.svg?color=399439&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/SickGear/SickGear.Docker)
  
**Background**: This builder was first hosted under namespaces _ressu/_ and then _deed02392/_ (thanks guys) because the SickGear Docker account was borked. Docker fixed the backend on Jun 22, 2018 and this builder is now home at the [official sickgear](https://hub.docker.com/r/sickgear/sickgear) namespace.  
  
Finally, thanks to resno for his help :)
  
---

# SickGear Official Docker

There are no moving parts inside the `Daily user` image and it can be invoked with the `--read-only` flag.

The `Dev/Tester` image is unique here and gives access to the latest SG features.

The image is intentionally kept small and is based on the Alpine variation of the Python 3 image.

# Usage

Pick your Docker environment:  
  
* Daily user: *sickgear/sickgear:latest* (or simply *sickgear/sickgear*)  
    - Docker container tracking the latest SickGear master release  
* Dev/Tester: *sickgear/sickgear:develop*  
    - Docker container with the latest develop features.  
  
Since SickGear operates on external data, the `/incoming` and `/tv` volumes need to be mounted. The most simple form of running the image is:
```
docker run -v /storage/incoming:/incoming -v /storage/tv:/tv -v /storage/sickgear-data:/data -p 8081:8081 sickgear/sickgear
```

# Data persistence

This image stores data by default in `/data`, the path can be adjusted with `APP_DATA` environment variable. Usually this volume is mounted to a physical location for ease of access.

*Warning:* The image will automatically adjust the ownership of `/data` volume to match the uid and gid of SickGear, if they are different.

# Updating the image

## Manual updates

This image follows the idea that the container should be ephemeral. This means that the image does not update itself internally. Update procedure is simply shutting down the image, pulling an update image and starting the new image in place of the old one

An example update would be something like:
```

docker kill <container-id>
docker pull sickgear/sickgear
docker run -v /storage/incoming:/incoming -v /storage/tv:/tv -v /storage/sickgear-data:/data -p 8081:8081 sickgear/sickgear

```

## Automatic updates with Watchtower

If you want automatic updates, you can use watchtower. [Watchtower](https://containrrr.dev/watchtower/) is a small utility packed inside a container that periodically tries to update containers.

You can use watchtower as follows:
```
docker run -d --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower 
```

By default Docker launches containers under randomized names. If you want to change your SickGear container to a certain name You need to add a `--name <containername>` to the run command. For example:
```
docker run \
  --name sickgear \
  -v /storage/incoming:/incoming \
  -v /storage/tv:/tv \
  -v /storage/sickgear-data:/data \
  -p 8081:8081 sickgear/sickgear
```

# Volumes

By default there are 3 volumes for easy access. The default volumes are preconfigured in SickGear for ease of use.

## /data

The default location for SickGear databases and configuraiton files is set to /data, this volume will also contain the SickGear cache, since it is by default set to the same location

## /incoming

In the default configuration `/incoming` is marked as the post-processing directory.

## /tv

Default configuration includes `/tv` as the show root directory.

## Permissions

Apart from `/data`, file permissions are not adjusted automatically, so if you need to modify the user id (via `APP_UID`), you need to make sure that the user has proper permissions for the `/incoming` and `/tv` volumes.

# Environment variables

Since it is not recommended to run services as root, the image supports switching users on the fly. Here are some of the central environment variables

## APP_UID

Numeric user id for the service. On startup, the `/data` volume ownership is changed to this user. Default user id is 0 (root)

## APP_GID

Numeric group id for the service. Useful for making files available for the `video` or `users` group.

## APP_DATA

Location of the application data. Default value is `/data`.

The ownership of the path in `APP_DATA` is changed to match `APP_UID`.

## TZ

You should use the TZ environment to adjust the default timezone of the service. This makes it so that shows will search and fetch correctly for _your_ local time... plus, SickGear's config/general/Interface/timezone uses this.

# Exposed ports

By default SickGear listens on port 8081, this port is exposed from the image.

# Examples
A complete example of running the service with a certain UID and timezone would be:
## Docker Run
```
docker run --rm -it -e APP_UID=1000 -e APP_GID=44 -p 8081:8081 -v /storage/sickgear-data:/data -v /storage/tv:/tv -v /storage/incoming:/incoming -e TZ=UTC --name sickgear sickgear/sickgear
```
## Docker Compose File
```
version: "3"
services:
  sickgear:
    container_name: sickgear
    environment:
      - APP_UID=1000
      - APP_GID=44
      - TZ=UTC
    image: sickgear/sickgear
    ports:
      - 8081:8081/tcp
    volumes:
      - /storage/sickgear-data:/data
      - /storage/tv:/tv
      - /storage/incoming:/incoming
 ```
