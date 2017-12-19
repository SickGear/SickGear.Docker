# SickGear Dockerized Official

This is the official SickGear Docker repository.
There are no moving parts inside the image and the image can be invoked with
the `--read-only` flag.

The image is intentionally kept small and is based on the Alpine variation of
the Python image.

# Usage

Pick your Docker environment:

* User: *deed02392/sickgear:latest* (or simply *deed02392/sickgear*) - Docker container with the latest SickGear release.
* Developer/Tester: *deed02392/sickgear:develop* - Docker container with the latest develop features of SickGear - may be unstable! Only use if you are a developer and keep backups of your `/data` directory. 

Since SickGear operates on external data, the `/incoming` and `/tv` volumes
need to be mounted. The most simple form of running the image is:

```
docker run -v /storage/incoming:/incoming -v /storage/tv:/tv -v /storage/sickgear-data:/data -p 8081:8081 deed02392/sickgear
```

# Data persistence

This image stores data by default in `/data`, the path can be adjusted with
`APP_DATA` environment variable. Usually this volume is mounted to a physical
location for ease of access.

*Warning:* The image will automatically adjust the ownership of `/data` volume
to match the uid and gid of SickGear, if they are different.

# Updating the image

## Manual updates

This image follows the idea that the container should be ephemeral. This means that the image does not update itself internally. Update procedure is simply shutting down the image, pulling an update image and starting the new image in place of the old one

An example update would be something like:
```
docker kill <container-id>
docker pull deed02392/sickgear
docker run -v /storage/incoming:/incoming -v /storage/tv:/tv -v /storage/sickgear-data:/data -p 8081:8081 deed02392/sickgear
```

## Automatic updates with Watchtower

If you want automatic updates, you can use watchtower. Watchtower is a small utility packed inside a container that periodically tries to update containers.

You can use watchtower as follows:
```
docker run -d --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  centurylink/watchtower \
  sickgear watchtower
```

The last two parameters define names of the containers you want to watch. By default Docker launches containers under randomized names. If you want to change your SickGear container to a certain name You need to add a `--name <containername>` to the run command. For example:
```
docker run \
  --name sickgear
  -v /storage/incoming:/incoming \
  -v /storage/tv:/tv \
  -v /storage/sickgear-data:/data \
  -p 8081:8081 deed02392/sickgear
```

# Volumes

By default there are 3 volumes for easy access. The default volumes are
preconfigured in SickGear for ease of use.

## /data

The default location for SickGear databases and configuraiton files is set to
/data, this volume will also contain the SickGear cache, since it is by default
set to the same location

## /incoming

In the default configuration `/incoming` is marked as the post-processing
directory.

## /tv

Default configuration includes `/tv` as the show root directory.

## Permissions

Apart from `/data`, file permissions are not adjusted automatically, so if you need
to modify the user id (via `APP_UID`), you need to make sure that the user has
proper permissions for the `/incoming` and `/tv` volumes.

# Environment variables

Since it is not recommended to run services as root, the image supports
switching users on the fly. Here are some of the central environment variables

## APP_UID

Numeric user id for the service. On startup, the `/data` volume ownership is
changed to this user. Default user id is 0 (root)

## APP_GID

Numeric group id for the service. Useful for making files available for the
`video` or `users` group.

## APP_DATA

Location of the application data. Default value is `/data`.

The ownership of the path in `APP_DATA` is changed to match `APP_UID`.

## TZ

You can use the TZ environment to adjust the default timezone of the service.

# Exposed ports

By default SickGear listens on port 8081, this port is exposed from the image.

# Examples

A complete example of running the service with a certain UID and timezone would be:

```
docker run --rm -it -e APP_UID=1000 -e APP_GID=44 -p 8081:8081 -v /storage/sickgear-data:/data -v /storage/tv:/tv -v /storage/incoming:/incoming -e TZ=Europe/Berlin deed02392/sickgear
```
