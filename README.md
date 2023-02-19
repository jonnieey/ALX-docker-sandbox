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
  arch linux sandbox docker container</mark>. **If username is empty it will exit**

   > Enter base directory to persist container data: 
  - It will prompt for base directory. <mark>This will be the directory in the host
  machine where  container directories and files will be persisted.
  Your projects and configuration will be stored there.</mark> **If base directory is empty it will exit**


  ```
  ** VOLUME PERMISSIONS PART 1 **

  Note: I've had problems with volume permissions and not being able to modify mouted volumes in container.
  Workaround (hacky) is to change the .ALX/arch/ALX permissions to allow rwx permissions to all

  $ sudo chmod a+rwx "your_base_directory"/.ALX/arch/ALX

  ** This will be the first part. Read on after we lauch our containers at the end
  ```


   > Enter user password (archlinux sandbox):
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

  - You'll have prompt in container (archlinux sandbox)
    [username@host ~]$ ls -a
    .  ..  .bash_history  .bash_logout  .bash_profile  .bashrc  .cache  .config  .local  .ssh  ALX

  - To access mysql from archlinux container
  [username@host ~]$ mysql -hdb -uroot -p
  [*] password is "password"

  - Execute sql script to hbtnbd database
  [username@host ~]$ cat example.sql | mysql -hdb -uroot -p hbtndb
  ```

  ```
  ** VOLUME PERMISSIONS PART 2 **

  - Change to ALX directory we changed permissions 
  - make sure you are in the container and not host system
   $ cd ALX/

  - create file
   $ touch dummy

  - Get owner name/owner group of user who created file
   $ ls -al dummy
  -rw-r--r-- 1 232071 232071 0 Feb 19 09:05 dummy 

  - In this case it owner is 232071 and group is 232071
  - note OWNER_NAME and OWNER_GROUP as we'll use it to change folder owners on host

  - stop docker running containers
  - make sure you are in same directory as docker-compose.yml (IN THE HOST SYSTEM)
  $ docker-compose stop

  - make sure containers are not running)
  $ docker container ps ; should not show arch linux container running

  - change owner/group of files in host system
  $ sudo chown "$OWNER_NAME:$OWNER_GROUP" -R "path_to_base_directory/.ALX"
  - OWNER_NAME and OWNER_GROUP are values got above (in this case 232071 and 232071)

  - Relaunch containers (in background)
  $ docker-compose up -d
  ```

 ```
  - MySQL
  $ docker exec -it alx_mysql_test_auto mysql -uroot -hdb -p
  [*] password is "password"

  - MySQL using mycli (A Terminal Client for MySQL with AutoCompletion and Syntax Highlighting)
  - It will connect via socket
  $ docker exec -it alx_mysql_test_auto mycli
  [*] password is "password"

  $ docker exec -it alx_mysql_test_auto /bin/bash
  - Log in as root user to mysql container. (BE CAREFUL)

  - To access mysql from archlinux container
  [username@host ~]$ mysql -hdb -uroot -p
  [*] password is "password"

  - Execute sql script to hbtnbd database
  [username@host ~]$ cat example.sql | mysql -hdb -uroot -p hbtndb
  ```

