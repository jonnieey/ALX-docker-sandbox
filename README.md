# DOCKER FOR ALX COURSEWORK

Using docker as driver for ALX Courswork

`NOTE:`

 > **using Arch linux distro**

 > **"$" represents bash prompt**


## Prerequisites

### 1. Internet Connection
  > Building these images and containers requires internet access as builds are 
  relatively large. approx. > 1.0GB

### 2. Docker Engine
#### **Intall Docker as Non-Root (Rootless Mode)**

1. Install *newuidmap* and *newgidmap*

   `$ sudo pacman -S shadow`

2. `/etc/subuid` and `/etc/subgid` should contain at least **65,536** subordinate UIDs/GIDs for the user. Ex:

   ```
   $ id -u
   1001
   $ whoami
   testuser
   $ grep ^$(whoami): /etc/subuid
   testuser:231072:65536
   $ grep ^$(whoami): /etc/subgid$
   testuser:231072:65536
   ```

   <mark>**Edit /etc/subuid and /etc/subgid if necessary**</mark>

3. If the system-wide Docker daemon is already running, consider disabling it:

   `$ sudo systemctl disable --now docker.service docker.socket`

4. Install rootless docker

   `$ curl -fsSL https://get.docker.com/rootless | sh`

5. Set export variables to bashrc

   ```
   $ echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc`
   $ echo 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock' >> ~/.bashrc
   ```

#### [Run docker daemon as non-root user (Rootless mode)](https://docs.docker.com/engine/security/rootless/)

### 3. Docker-Compose
- Install docker-compose

  `$ sudo pacman -S docker-compose`

## Usage
#### Start Docker Service

   **NOTE: Do not use `sudo`**

   `$ systemctl --user start docker`

   - **Optional: Enable docker service; run at startup**

      ```
      $ systemctl --user enable docker`
      $ sudo loginctl enable-linger $(whoami)
      ```

#### Create images

  `$ bash ./generate_arch_linux_dockerfile.sh`

   > Enter Username to use in docker container:
  - It will prompt for username <mark>which will be used to create a sudoer user in 
  docker container</mark>. **If username is empty it will exit**
   > Enter base directory to persist container data: 
  - It will prompt for base directory. <mark>This will be the directory in the host
  machine where  container directories and files will be persisted.
  Your projects and configuration will be stored there.</mark> **If base directory is empty it will exit**

   > "Enter user password (archlinux sandbox): "
  - It will prompt for user password. <mark>This will used as sudoer password for arch linux user.</mark> **If user password is empty it will exit. Prompt doesn't show input.**
  - Docker files will be generated, ALX-Archlinux.Dockerfile, docker-compose.yml ,etc.

    **Optional:** Open and review to make sure they are generated correctly

- Build docker images and containers,

  `$ docker-compose up --build`

  <mark>**should be run in same directory as generated docker-compose.yml**</mark>

  **Wait for it to finish building images and containers, requires internet connection**

  On successful build you should see something like 

  ```...
  alx_mysql_test_auto      | 2023-02-18  1:24:08 0 [Note] mariadbd: ready for connections.
  alx_mysql_test_auto      | Version: '10.10.3-MariaDB-1:10.10.3+maria~ubu2204'  socket: '/run/mysqld/mysqld.sock'  port: 3306  mariadb.org binary distribution
  ...
  ```

 - To run in background after initial build

    `$ docker-compose up -d`

## connect to containers
  ```
  - Archlinux
  $ docker exec -it alx_archlinux_test_auto /bin/bash

  - MySQL
  $ docker exec -it alx_mysql_test_auto mysql -uroot -hdb -p
  [*] password is the username used during prompt

  - MySQL using mycli (A Terminal Client for MySQL with AutoCompletion and Syntax Highlighting)
  $ docker exec -it alx_mysql_test_auto mycli
