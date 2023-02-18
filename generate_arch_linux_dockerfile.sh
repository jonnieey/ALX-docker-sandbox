#!/usr/bin/env bash

# Get username
# Get base_directory - where user want to store files in local machine
# Create necessary directories and files

echo "Enter Username to use in docker container: "
read username
if [ -z "$username" ]; then
	echo "** Username must be defined"
	exit
fi

echo "Enter base directory to persist container data: "
read base_dir

if [ -z "$base_dir" ]; then
	echo "** Base directory to store files is needed **"
	exit
	# base_dir="$(pwd)"
fi

echo "Enter user password (archlinux sandbox): "
read -s user_password;
if [ -z "$user_password" ]; then
	echo "** User password required **"
	exit
	# base_dir="$(pwd)"
fi

# Needed directories
mkdir -p $base_dir/.ALX/{arch/{config,ssh,ALX},mysql/etc/conf.d}

# Needed files
cp ./bashrc.default $base_dir/.ALX/arch/bashrc
cp ./myclirc.default $base_dir/.ALX/mysql/myclirc
cp ./custom.cnf.default $base_dir/.ALX/mysql/etc/conf.d/custom.cnf

Arch_Linux_Dockerfile=$(cat <<EOF > ALX_Archlinux.Dockerfile
FROM archlinux:latest
RUN pacman -Syu --noconfirm \
&& pacman -S openssh git gcc perl python python-pip sudo mariadb-clients \
python-pynvim neovim github-cli shellcheck --noconfirm \
&& pacman -Scc --noconfirm \
&& find /var/cache/pacman/pkg -mindepth 1 -delete

RUN useradd -ms /bin/bash $username \
&& echo "$username:$user_password" | chpasswd \
&& usermod -aG wheel $username \
&& echo '%wheel ALL=(ALL) ALL' > /etc/sudoers

RUN git clone https://github.com/holbertonschool/Betty && cd Betty && bash install.sh

USER $username
WORKDIR /home/$username

RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim \
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim \
&& chmod 777 -R ~/.local/share/nvim/site/pack/packer/start/packer.nvim \
&& pip install pycodestyle
EOF
)

MySQL_Dockerfile=$(cat <<EOF > ALX_MySQL.Dockerfile
FROM mariadb:10.10
RUN apt-get update -y && apt-get install mycli pspg -y && apt-get clean
EOF
)

Docker_Compose_File=$(cat <<EOF > docker-compose.yml
version: '3'
services:
  sandbox:
    build:
      context: .
      dockerfile: ALX_Archlinux.Dockerfile
    container_name: "alx_archlinux_test_auto"
    volumes:
      - $base_dir/.ALX/arch/ALX:/home/$username/ALX
      - $base_dir/.ALX/arch/bashrc:/home/$username/.bashrc
      - $base_dir/.ALX/arch/config:/home/$username/.config
      - $base_dir/.ALX/arch/ssh:/home/$username/.ssh
    tty: true
    privileged: true
    networks:
      - sandbox_network

  db:
    build:
      context: .
      dockerfile: ALX_MySQL.Dockerfile
    container_name: "alx_mysql_test_auto"
    restart: always
    volumes:
      - db_data:/var/lib/mysql
      - $base_dir/.ALX/mysql/etc/conf.d:/etc/mysql/conf.d
      - $base_dir/.ALX/mysql/myclirc:/root/.myclirc
    tty: true
    environment:
      - MARIADB_ROOT_PASSWORD=password
      - MARIADB_USER=$username
      - MARIADB_PASSWORD=password
    privileged: true
    networks:
      - sandbox_network

volumes:
  db_data:

networks:
  sandbox_network:
    driver: bridge
EOF
)
