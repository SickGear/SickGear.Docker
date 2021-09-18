<table>
  <tr><th colspan="2">
    <img style="max-width:100%;" alt="SickGear Logo" src="https://raw.githubusercontent.com/wiki/SickGear/SickGear/images/SickGearLogoDocker_x250.png"><br>
    <a href="https://hub.docker.com/r/sickgear/sickgear"><img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/sickgear/sickgear.svg?color=246434&labelColor=333333&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker"></a><a href="https://hub.docker.com/r/sickgear/sickgear"><img alt="Docker Stars" src="https://img.shields.io/docker/stars/sickgear/sickgear.svg?color=246434&labelColor=333333&logoColor=ffffff&style=for-the-badge&label=stars&logo=docker"></a><a href="https://github.com/SickGear/SickGear.Docker"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/SickGear/SickGear.Docker.svg?color=246434&labelColor=333333&logoColor=ffffff&style=for-the-badge&logo=github"></a><br>
    <h2>Official SickGear Docker Containers</h2>
  </th></tr>
  <tr><th colspan="2">Table of content</th></tr>
  <tr><td>+ <a href="#meet-the-containers">Meet the Containers</a></td><td>+ <a href="#quick-migration">Quick Migration</a></td></tr>
  <tr><td>+ <a href="#set-up-a-running-container">Set up a Running Container</a></td><td>+ <a href="#permissions">Permissions</a></td></tr>
  <tr><td>+ <a href="#container-configuration">Container Configuration</a></td><td>+ <a href="#updating-images">Updating Images</a></td></tr>
  <tr><td>+ <a href="#sickgear-interface">Access the SickGear Interface</a></td><td>+ <a href="#docker-tips">Tips & Observations</a></td></tr>
  <tr><th colspan="2">Official container features</th></tr>
  <tr><td>containers for SickGear by SickGear</td><td>images maintained by SickGear</td></tr>
  <tr><td>easy user and group mappings</td><td>quick migration support</td></tr>
  <tr><td>super small base image</td><td>regular security updates</td></tr>
  <tr><th colspan="2">Multiple architecture image support</th></tr>
  <tr><td colspan="2" align="center">amd64(x86) -- arm64 -- arm32v7(armhf) -- ppc64le -- 386 -- s390x</td></tr>
</table>
  
---
  
## SickGear automates TV management
  
Some of the sick innovative gear you get;  
  
• Select a UI style anytime; Regular, Proview I, or Proview II  
• View new shows from Trakt, IMDb, TVmaze, AniDB and others  
• The longest track record of being stable, reliable, and trusted to work  
• Most recent added and updated shows available via menu quick links  
• Daily Schedule ... "Day by Day" display upcoming release fanart backgrounds  
• Automated search always works to save you time manually picking from lists  
• Delete watched episodes from any profile in Kodi, Emby, and/or Plex  
• Keep all, or a number of most recent episodes; e.g. keep the last 40 releases  
• Built-in source providers for max. efficiency with hit graphs and failure stats  
• Used on servers, to smaller SoC devices like RPi, BPi etc.  
  
---
  
<a id="meet-the-containers" name="meet-the-containers"></a>
## Meet the Containers  
  
These official images are made purposefully small and use Alpine Linux with Python 3.  
  
This `sickgear/sickgear:latest` image has no moving parts and can be invoked with the `--read-only` flag.  
  
The `sickgear/sickgear:develop` image uniquely gives access to new developed features.  
  
---
  
<a id="quick-migration" name="quick-migration"></a>
## Quick Migration  
  
Official SickGear containers support alternative parameters for hassle free experiences...
  
* environment variables `PUID` for user and `PGID` for group are supported
* directory `config` is supported for **existing** config.ini and database files
* directory `downloads` is supported to process incoming media from
  
---
  
<a id="sickgear-interface" name="sickgear-interface"></a>
## SickGear Interface  
  
To access the SickGear application in a running container, navigate in a browser to `<container-host-ip>:8081`
  
---
  
<a id="container" name="container"></a>
<a id="set-up-a-running-container" name="set-up-a-running-container"></a>
## Set up a Running Container
  
<table>
<tr><th>Choose container use case</th><th>Image tag</th><th>Docs</th></tr>
<tr><td><b>Track latest SickGear release</b></td><td><em>sickgear/sickgear:latest</em></td><td><b>Read below</b></td></tr>
<tr><td>Track latest development features</td><td><em>sickgear/sickgear:develop</em></td><td><a href="https://github.com/SickGear/SickGear.Docker/tree/updates_enabled/#container" target=_new>Click here</a></td></tr>
</table>
  
A basic example of running image:latest as root (not recommended) is:
```
docker run \
  -p 8081:8081 \
  -v /storage/sickgear-data:/data \
  -v /storage/incoming:/incoming \
  -v /storage/tv:/tv \
  sickgear/sickgear:latest
```
where volumes `/incoming` and `/tv` are mounted to use external data with SickGear.  
  
However, a far better example of running image:latest as a user is:
```
docker run \
  --name=sickgear \
  --rm -it \
  -e APP_UID=1000 -e APP_GID=44 \
  -p 8081:8081 \
  -v /storage/sickgear-data:/data \
  -v /storage/incoming:/incoming \
  -v /storage/tv:/tv \
  sickgear/sickgear:latest
```
which includes a uid and gid since it is not recommended to run services as root.  
Tips:  
* enter `id username` on the host OS to get uid and gid  
* `--name=<value>` secures a name for external apps to refer to a container  

[click here for docker help](https://docs.docker.com/engine/reference/commandline/cli/)
  
Alternatively, the following can be a basis `docker-compose.yml` for docker-compose:
```yaml
version: "3"
services:
  sickgear:
    container_name: sickgear
    image: sickgear/sickgear:latest
    environment:
      - APP_UID=1000
      - APP_GID=44
      - TZ=UTC
    ports:
      - 8081:8081/tcp
    volumes:
      - /storage/sickgear-data:/data
      - /storage/incoming:/incoming
      - /storage/tv:/tv
```
[click here for docker-compose help](https://docs.docker.com/compose/reference/)
  
<a id="container-configuration" name="container-configuration"></a>
### Container Configuration
  
Configure a SickGear container with the following environment variables and parameters...
<table>
<tr><th>Environment</th><th>Description for environment variable</th></tr>
<tr><td>-e APP_UID=[<em>number</em>]</td><td>run SickGear as user id, default: 0 (root)<br>ownership of <code>/data</code> is changed to this user on startup</td></tr>
<tr><td>-e APP_GID=[<em>number</em>]</td><td>run SickGear as group id, default: 0<br>useful for making files available for the <code>video</code> or <code>users</code> group</td></tr>
<tr><td>-e TZ=[<em>string</em>]</td><td>manage shows in supplied timezone e.g. <code>Europe/Berlin</code><br>and used by SickGear's config/General/Interface/Timezone</td></tr>

<tr><th width="200">Param [host]:[image]</th><th>Description for host(ext):image(int) value</th></tr>
<tr><td>-p <em>8081</em>:<em>8081</em></td><td>access port for the SickGear application interface</td></tr>
<tr><td>-v [<em>/path</em>]:/data</td><td>where to store cache, database, and configuraton files</td></tr>
<tr><td>-v [<em>/path</em>]:/incoming</td><td>location where to process incoming media from</td></tr>
<tr><td>-v [<em>/path</em>]:/tv</td><td>location for parent folders to store processed media</td></tr>
</table>

#### Data persistence

The `/data` location can be adjusted using `APP_DATA` environment variable, which will override the volume that is normally mounted for ease of access to a physical location.

*Warning:* The ownership of `/data` will be adjusted to match APP_UID and APP_GID, if they are different.
  
<a id="permissions" name="permissions"></a>
#### Permissions

File permissions are only automatically adjusted for `/data`, so if `user id` is modified via `APP_UID`, make sure that `user id` has proper permissions for `/incoming` and `/tv` volumes.

In the above examples, APP_UID was set 1000, and APP_GID set 44, these values were found by running the following on a host Ubuntu set up...
```
$ id username
uid=1000(username) gid=1000(username) groups=1000(username),4(adm),24(cdrom) ... etc.
```
  
---
  
<a id="updating-images" name="updating-images"></a>
### Updating Images

#### Manually update  

This image follows the idea that a container should be ephemeral, meaning that the image does not update itself internally. Therefore, the update procedure is to shut down the image, pull an update image, and start the new image in place of the old one
  
container id example update:
* `docker ps` - to get the `<container id>`
* `docker stop <container id>`
* `docker pull sickgear/sickgear:latest` - get new image
* `docker image prune` - optionally remove dangling images
* `docker run ...` - as above, set up a running container  

named `sickgear` example update:
* `docker stop sickgear`
* `docker pull sickgear/sickgear:latest` - get new image
* `docker image prune` - optionally remove dangling images
* `docker run ...` - as above, set up a running container  

docker-compose example update (omit `sickgear` to act on all images):
* `docker-compose pull sickgear` - update image
* `docker-compose up -d sickgear` - update containers
* `docker image prune` - optionally remove dangling images

#### Watchtower update 

Watchtower is a small container utility to simplify or automate updating.

manual Watchtower example update:  
* <pre>docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower \
    --run-once sickgear</pre>
* `docker image prune` - optionally remove old images  
  
automatic Watchtower example update:  
* <pre>docker run -d \
    --name watchtower \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower \
    sickgear watchtower</pre>
The last two parameters declare container names to watch and update.   
  
[click here for more Watchtower help](https://containrrr.dev/watchtower/usage-overview/)
  
---
  
<a id="docker-tips" name="docker-tips"></a>
## Docker Tips

* `docker exec -it sickgear sh` - shell access to the running container  
* `docker logs -f sickgear` - display sickgear runtime output  
  
---
  
## Observations
  
* docker cli `read: connection refused` was fixed by explicitly stating the `:latest` tag where not including this tag was fine elsewhere  
* avoided using `~/` in the `docker run...` line as SickGear container failed on startup with `cp: can't create '/data/config.ini': Permission denied`
  
#### arm32v7(armhf)
  
* docker failure to run on [OSMC](https://docs.docker.com/engine/install/debian/) was solved with [this thread](https://discourse.osmc.tv/t/installing-docker-on-rpi-3/89654), and by running
`sudo update-alternatives --config iptables`, entering `1` when prompted (iptables-legacy), and rebooting (docker was installed but its service "Failed to start")
  
---
  
## Historical

SickGear was sited under namespace ressu/ and then deed02392/ (thanks guys) because the SickGear Docker account was borked. Docker fixed the backend Jun 22, 2018 and the image has since been hosted at the official sickgear namespace.  Special thanks to resno for his initial help.
  
Docker ceased building FOSS images mid 2021, so the build process was remade at Microsoft owned GitHub with images _currently_ pushed to DockerHub registry for legacy reasons. This readme was also overhauled to (hopefully) make these things easier to use.

  
