<div align="center">
  <img alt="SickGear Logo" width="250" src="https://raw.githubusercontent.com/wiki/SickGear/SickGear/images/SickGearLogoDocker_x250.png"><br>
  <!-- hub-badges-start -->
  <a href="https://hub.docker.com/r/sickgear/sickgear"><img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/sickgear/sickgear.svg?color=246434&labelColor=333333&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker"></a> <a href="https://hub.docker.com/r/sickgear/sickgear"><img alt="Docker Stars" src="https://img.shields.io/docker/stars/sickgear/sickgear.svg?color=246434&labelColor=333333&logoColor=ffffff&style=for-the-badge&label=stars&logo=docker"></a> <a href="https://github.com/SickGear/SickGear.Docker"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/SickGear/SickGear.Docker.svg?color=246434&labelColor=333333&logoColor=ffffff&style=for-the-badge&logo=github"></a>
  <!-- hub-badges-end -->
  <h2>Official SickGear Docker Containers</h2>
</div>

<div align="center">
<table align="center">
  <tr><th align="left"><b>Table of contents</b></th><th align="left"><b>Official container features</b></th></tr>
  <tr>
    <td align="left" valign="top">
      + <a href="#user-content-meet-the-containers">Meet the Containers</a><br>
      + <a href="#user-content-quick-migration">Quick Migration</a><br>
      + <a href="#user-content-set-up-a-running-container">Set up a Running Container</a><br>
      + <a href="#user-content-permissions">Permissions</a><br>
      + <a href="#user-content-container-configuration">Container Configuration</a><br>
      + <a href="#user-content-updating-images">Updating Images</a><br>
      + <a href="#user-content-sickgear-interface">Access the SickGear Interface</a><br>
      + <a href="#user-content-docker-tips">Tips & Observations</a><br>
      + <a href="#user-content-versions">Versions</a>
    </td>
    <td align="left" valign="top">
      + containers for SickGear by SickGear<br>
      + images maintained by SickGear<br>
      + easy user and group mappings<br>
      + quick migration support<br>
      + super small base image<br>
      + regular security updates<br>
      <!-- three empty lines, so the six features start level with the nine contents links on Docker Hub, which centres cells vertically -->
      &nbsp;<br>&nbsp;<br>&nbsp;
    </td>
  </tr>
</table>
</div>

<p align="center"><b>Multiple architecture image support</b><br>amd64 -- arm64 -- arm/v7 -- arm/v6 -- 386 -- ppc64le -- s390x -- riscv64</p>
  
---
  
## SickGear automates TV management
  
Some of the sick innovative gear you get;  
  
* Pick a UI style at any time: Regular, Proview I or Proview II
* Discover new shows from Trakt, IMDb, TVmaze, AniDB and others
* The longest track record of being stable, reliable and trusted to work
* Recently added and updated shows one click away in the menu
* Daily Schedule shows upcoming releases day by day on fanart backgrounds
* Automated search that saves picking releases from lists by hand
* Delete watched episodes from any Kodi, Emby or Plex profile
* Keep all episodes, or only the latest, e.g. the last 40 releases
* Built-in providers for max. efficiency, with hit graphs and failure stats
* Runs on servers and on small boards such as RPi and BPi
  
---
  
<a id="meet-the-containers" name="meet-the-containers"></a>
## Meet the Containers

These official images are made purposefully small and use Alpine Linux with Python 3.  
  
This `sickgear/sickgear:develop` tagged image uniquely gives access to new developed features.  
  
The `sickgear/sickgear:latest` tagged image has no moving parts and can be invoked with the `--read-only` flag.  
  
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
<tr><th><b>Choose container use case</b></th><th><b>Image tag</b></th><th><b>Docs</b></th></tr>
<tr><td>Track latest SickGear release</td><td><em>sickgear/sickgear:latest</em></td><td><a href="https://github.com/SickGear/SickGear.Docker/tree/master/#container">Setup for latest</a></td></tr>
<tr><td><b>Track latest development features</b></td><td><em>sickgear/sickgear:develop</em></td><td><b>Read below</b></td></tr>
</table>
  
A basic example of running image:develop as user sickgear (uid 1000, gid 1000) is:
```sh
docker run \
  -p 8081:8081 \
  -v /storage/sickgear-data:/data \
  -v /storage/incoming:/incoming \
  -v /storage/tv:/tv \
  sickgear/sickgear:develop
```
where volumes `/incoming` and `/tv` are mounted to use external data with SickGear.  
  
An example of running image:develop as a host user is:
```sh
docker run \
  --name=sickgear \
  --rm -it \
  -e APP_UID=1000 -e APP_GID=44 \
  -p 8081:8081 \
  -v /storage/sickgear-data:/data \
  -v /storage/incoming:/incoming \
  -v /storage/tv:/tv \
  sickgear/sickgear:develop
```
which includes a uid and gid to run SickGear as an existing host user and group.  
Tips:  
* enter `id username` on the host OS to get uid and gid  
* `--name=<value>` secures a name for external apps to refer to a container  
  
[Docker CLI reference](https://docs.docker.com/engine/reference/commandline/cli/)
  
Alternatively, the following can be a basis for a `docker-compose.yml` with Docker Compose:
```yaml
services:
  sickgear:
    container_name: sickgear
    image: sickgear/sickgear:develop
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
[Docker Compose reference](https://docs.docker.com/compose/reference/)
  
<a id="container-configuration" name="container-configuration"></a>
## Container Configuration
  
Configure a SickGear container with the following environment variables and parameters...
<table>
<tr><th><b>Environment</b></th><th><b>Description for environment variable</b></th></tr>
<tr><td>-e APP_UID=[<em>number</em>]</td><td>run SickGear as user id, default: 1000 (user sickgear)<br>ownership of <code>/data</code> is changed to this user on startup</td></tr>
<tr><td>-e APP_GID=[<em>number</em>]</td><td>run SickGear as group id, default: 1000 (group sickgear)<br>useful for making files available for the <code>video</code> or <code>users</code> group</td></tr>
<tr><td>-e TZ=[<em>string</em>]</td><td>manage shows in supplied timezone e.g. <code>Europe/Berlin</code>, default: UTC<br>and used by SickGear's config/General/Interface/Timezone</td></tr>
<tr><th width="200"><b>Param [host]:[image]</b></th><th><b>Description for host(ext):image(int) value</b></th></tr>
<tr><td>-p <em>8081</em>:<em>8081</em></td><td>access port for the SickGear application interface</td></tr>
<tr><td>-v [<em>/path</em>]:/data</td><td>where to store cache, database, and configuration files</td></tr>
<tr><td>-v [<em>/path</em>]:/incoming</td><td>location where to process incoming media from</td></tr>
<tr><td>-v [<em>/path</em>]:/tv</td><td>location for parent folders to store processed media</td></tr>
</table>

### Data persistence

The `/data` location can be adjusted using `APP_DATA` environment variable, which will override the volume that is normally mounted for ease of access to a physical location.

*Warning:* The ownership of `/data` will be adjusted to match APP_UID and APP_GID, if they are different.
  
<a id="permissions" name="permissions"></a>
### Permissions

File permissions are only automatically adjusted for `/data`, so if `user id` is modified via `APP_UID`, make sure that `user id` has proper permissions for `/incoming` and `/tv` volumes.

In the above examples, APP_UID was set 1000, and APP_GID set 44, these values were found by running the following on a host Ubuntu set up...
```console
$ id username
uid=1000(username) gid=1000(username) groups=1000(username),4(adm),24(cdrom) ... etc.
```

### Upgrading from an image that ran as root

Images before this one ran SickGear as root (uid 0) by default. SickGear now runs as user `sickgear` (uid 1000, gid 1000) unless `APP_UID`/`APP_GID` (or `PUID`/`PGID`) are set.

On first start, the ownership of `/data` changes to the new user. The `/incoming` and `/tv` volumes are not changed, so check that uid 1000 (or your `APP_UID`) can read and write them, for example on the host:
```console
$ sudo chown -R 1000:1000 /storage/incoming /storage/tv
```

To keep the old behaviour, set `-e APP_UID=0 -e APP_GID=0`. Running as root is not recommended.

Python packages that SickGear installs at runtime go to `/opt/SickGear/.local`.
  
---
  
<a id="updating-images" name="updating-images"></a>
## Updating Images

### Manually update

This image follows the idea that a container should be ephemeral, meaning that the image does not update itself internally. Therefore, the update procedure is to shut down the image, pull an update image, and start the new image in place of the old one.
  
Container id example update:
* `docker ps` - to get the `<container id>`
* `docker stop <container id>`
* `docker pull sickgear/sickgear:develop` - get new image
* `docker image prune` - optionally remove dangling images
* `docker run ...` - as above, set up a running container  

Named `sickgear` example update:
* `docker stop sickgear`
* `docker pull sickgear/sickgear:develop` - get new image
* `docker image prune` - optionally remove dangling images
* `docker run ...` - as above, set up a running container  

Docker Compose example update (omit `sickgear` to act on all images):
* `docker compose pull sickgear` - update image
* `docker compose up -d sickgear` - update containers
* `docker image prune` - optionally remove dangling images

### Watchtower update

Watchtower is a small container utility to simplify or automate updating.

Manual Watchtower example update:  
```sh
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --run-once sickgear
```
* `docker image prune` - optionally remove old images  
  
Automatic Watchtower example update:  
```sh
docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  sickgear watchtower
```
The last two parameters declare container names to watch and update.  
  
[Watchtower usage overview](https://containrrr.dev/watchtower/usage-overview/)
  
---
  
<a id="docker-tips" name="docker-tips"></a>
## Docker Tips

* `docker exec -it sickgear sh` - shell access to the running container  
* `docker logs -f sickgear` - display sickgear runtime output  
  
---
  
## Observations
  
* docker cli `read: connection refused` was fixed by explicitly stating the `:latest` tag where not including this tag was fine elsewhere  
* avoided using `~/` in the `docker run...` line as SickGear container failed on startup with `cp: can't create '/data/config.ini': Permission denied`
  
### arm32v7(armhf)
  
* docker failure to run on [OSMC](https://docs.docker.com/engine/install/debian/) was solved with [this thread](https://discourse.osmc.tv/t/installing-docker-on-rpi-3/89654), and by running
`sudo update-alternatives --config iptables`, entering `1` when prompted (iptables-legacy), and rebooting (docker was installed but its service "Failed to start")
  
---
  
<a id="versions" name="versions"></a>
## Versions

* **2026-11-27:** - Add rtls, so ECH works on platforms with a wheel: amd64, arm64, arm/v7, 386, riscv64.
* **2026-11-22:** - Rebuild latest automatically within a day of a new SickGear release.
* **2026-11-22:** - Run SickGear as user sickgear (uid/gid 1000) by default, not root, see [Permissions](#permissions).
* **2026-11-22:** - Rebase to Alpine 3.24 (pinned, was edge) with Python 3.14.
* **2026-11-22:** - Add arm32v6 and riscv64 images, 8 platforms in total.
* **2026-11-22:** - Bump UnRAR 6.2.1 to 7.23, built from source with a checksum check.
* **2026-11-22:** - Fix a `TZ` city setting such as Europe/London falling back to UTC (latest).
* **2026-11-22:** - Packages now match SickGear recommended.txt: add brotli, orjson, rapidfuzz, drop python-Levenshtein.
* **2026-11-22:** - develop: install the latest Python packages at build, so the first start has no package updates, and in-app package installs work.
* **2023-06-07:** - Last build on Alpine 3.18 with Python 3.11.
* **2021-11-25:** - Rebase to Alpine latest.
* **2021-09-18:** - Switch to Python 3.9.
* **2020-01-15:** - Switch to Python 3.8.
* **2019-11-20:** - Add unrar.
* **2018-06-22:** - Move to the official sickgear namespace.
* **2017-12-17:** - Switch base to Alpine, replace gosu with su-exec.

---

## Historical

SickGear was sited under namespace ressu/ and then deed02392/ (thanks guys). The backend was fixed Jun 22, 2018 and the image has since been hosted at the official sickgear namespace.  Special thanks to resno for his initial help.
