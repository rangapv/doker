#! /bin/bash

source <(curl -s https://raw.githubusercontent.com/rangapv/bash-source/main/s1.sh) >>/dev/null 2>&1

li=$(uname -s)
li2="${li,,}"

u1=$(cat /etc/*-release | grep ubuntu)
f1=$(cat /etc/*-release | grep ID= | grep fedora)
c1=$(cat /etc/*-release | grep ID= | grep centos)
s1=$(cat /etc/*-release | grep suse)
d1=$(cat /etc/*-release | grep ID= | grep debian)


dokvers() {

dk1="$(docker --version 2>&1)"
dk2="$(which docker 2>&1)"
dc1="$(docker-compose --version 2>&1)"
dc2="$(which docker-compose 2>&1)"

}

dokcomp() {

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

}

dokenable() {
 sudo mkdir /etc/docker
 cat <<EOF | sudo tee /etc/docker/daemon.json
 {
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
 }
EOF
 sudo systemctl enable docker
 sudo systemctl daemon-reload
 sudo systemctl restart docker

}

dokvers

if [  -z "$dk2" ] || [[ $dk2 =~ .*"no".* ]]
    then 
    echo "Docker is NOT INSTALLED"
		if [ ! -z "$d1" ]
		then
			echo "It is an Debian"
			cm1="apt-get"
			cm2="apt-key"
			sudo $cm1 update
			sudo $cm1 install -yqq apt-transport-https ca-certificates
			sudo $cm2 adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
					
			ji=$(cat /etc/*-release | grep '^ID' | awk '{split($0,a,"=");print a[2]}')
			ki="${ji,,}"

			mi=$(cat /etc/*-release | grep '^VERSION=' | awk '{split($0,a,"(");print a[2]}' | awk '{split($0,b,")");print b[1]}')
			mi2="${mi,,}"

			if [ -f "/etc/apt/sources.list.d/docker.list" ]
			then
					echo "docker.list found\n"
				sudo truncate -s 0 /etc/apt/sources.list.d/docker.list
			else
				echo "Creating docker.list file in /etc/apt/sources.list.d"
				sudo touch /etc/apt/sources.list.d/docker.list
			fi
			sudo chmod 777 /etc/apt/sources.list.d/docker.list
			sudo echo "deb https://download.docker.com/$li2/$ki $mi2 stable" >> /etc/apt/sources.list.d/docker.list
			sudo chmod 777 /etc/apt/sources.list.d/docker.list

			sudo $cm1 update
		fi

		if [ ! -z "$u1" ]
		then 
			mi=$(lsb_release -cs)
			mi2="${mi,,}"
			ji=$(cat /etc/*-release | grep DISTRIB_ID | awk '{split($0,a,"=");print a[2]}')
			ki="${ji,,}"

			if [ "$ki" == "ubuntu" ]
			then
			echo "IT IS UBUNTU"
			cm1="apt-get"
			cm2="apt-key"
			fi

			sudo $cm1 -y update
			sudo $cm1 -y upgrade
			sudo $cm1 install -yqq apt-transport-https ca-certificates curl gnupg libffi-dev lsb-release
			#sudo $cm2 adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
                        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
			if [ -f "/etc/apt/sources.list.d/docker.list" ]
			then
				echo "docker.list found\n"
				sudo truncate -s 0 /etc/apt/sources.list.d/docker.list
			else
				echo "Creating docker.list file in /etc/apt/sources.list.d"
				sudo touch /etc/apt/sources.list.d/docker.list
			fi
			sudo chmod 777 /etc/apt/sources.list.d/docker.list
		#	sudo echo "deb https://download.docker.com/$li2/$ki $mi2 stable" >> /etc/apt/sources.list.d/docker.list
	                sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >> /etc/apt/sources.list.d/docker.list 
			sudo $cm1 update
		
			if [ "$mi2" == "bionic" ]
			then
				#	sudo snap install docker
				#sudo $cm1 install -yqq docker-ce --allow-unauthenticated
				#sudo apt install docker.io
				echo ""
		        fi

			 sudo $cm1 -y install docker-ce docker-ce-cli containerd.io        
		         #sudo pip install docker-compose
		         dokenable
		      	 dokcomp
		fi

		if [ ! -z "$f1" ]
		then
				ji=$(cat /etc/*-release | grep '^ID=' |awk '{split($0,a,"=");print a[2]}')
				ki="${ji,,}"
          			cm1="dnf -y"
				sudo $cm1 install dnf-plugins-core
				sudo $cm1 config-manager --add-repo https://download.docker.com/$li2/$ki/docker-ce.repo
				sudo $cm1 install docker-ce --releasever=28
				sudo $cm1 install -yqq python-pip
				sudo pip install docker-compose
		fi #end of fedora

		if [ ! -z "$c1" ]
		then
			echo "it is a centos"
				ji=$(cat /etc/*-release | grep '^ID=' |awk '{split($0,a,"\"");print a[2]}')
				ki="${ji,,}"
				cm1="yum -y"
          			sudo $cm1 install yum-utils device-mapper-persistent-data lvm2
	        		sudo yum-config-manager --add-repo https://download.docker.com/$li2/$ki/docker-ce.repo
				sudo $cm1 install docker-ce 
				sudo $cm1 install epel-release
				sudo $cm1 install -yqq python-pip
				sudo pip install docker-compose
		fi #end of centos

elif [  -z "$dc1" -a -z "$dc2" ] ||  [[ "$dc1" =~ .*"No".* ]] || [[ "$dc2" =~ .*"No".* ]]
then
       echo "installing docker-compose"
       #sudo pip install docker-compose
       dokcomp
else
    echo "Nothing to install"
fi
   
    `sudo groupadd docker`
    `sudo usermod -aG docker $USER`
    `sudo chmod 666 /var/run/docker.sock`
    `sudo systemctl enable docker`
    `sudo $cm1 update`

    dokvers

    echo "Docker version is: $dk1"
    echo "Docker is installed in: $dk2"
    echo "Docker compose version is: $dc1"
    echo "Docker compose is installed in: $dc2"

