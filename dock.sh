#! /bin/bash
li=$(uname -s)
li2="${li,,}"

u1=$(cat /etc/*-release | grep ubuntu)
f1=$(cat /etc/*-release | grep ID= | grep fedora)
c1=$(cat /etc/*-release | grep ID= | grep centos)
s1=$(cat /etc/*-release | grep suse)
d1=$(cat /etc/*-release | grep ID= | grep debian)

dk1="$(docker --version 2>&1)"
dk2="$(which docker 2>&1)"
dc1="$(docker-compose --version 2>&1)"
dc2="$(which docker-compose 2>&1)"

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

			sudo $cm1 update
			sudo $cm1 install -yqq apt-transport-https ca-certificates
			sudo $cm2 adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

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
		
				if [ "$mi2" == "bionic" ]
			then
					sudo snap install docker
			else
      
	                        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
				sudo apt update
	
				sudo $cm1 install -yqq docker-ce --allow-unauthenticated
				fi
			sudo apt-get install -yqq python-pip
				sudo pip install docker-compose
		fi


		if [ ! -z "$f1" ]
		then
				ji=$(cat /etc/*-release | grep '^ID=' |awk '{split($0,a,"=");print a[2]}')
				ki="${ji,,}"
				sudo dnf -y install dnf-plugins-core
				sudo dnf config-manager --add-repo https://download.docker.com/$li2/$ki/docker-ce.repo
				sudo dnf -y install docker-ce --releasever=28
			cm1="dnf -y"
				sudo dnf install -yqq python-pip
				sudo pip install docker-compose
		fi #end of fedora

		if [ ! -z "$c1" ]
		then
			echo "it is a centos"
				ji=$(cat /etc/*-release | grep '^ID=' |awk '{split($0,a,"\"");print a[2]}')
				ki="${ji,,}"
			sudo yum install -y yum-utils device-mapper-persistent-data lvm2
			sudo yum-config-manager --add-repo https://download.docker.com/$li2/$ki/docker-ce.repo
				sudo yum -y install docker-ce 
				sudo yum install -y epel-release
				sudo yum install -yqq python-pip
				sudo pip install docker-compose
				cm1="yum -y"
		fi #end of centos

		sudo groupadd docker
		sudo usermod -aG docker $USER
		sudo systemctl enable docker
		sudo $cm1 update
		docker --version
		docker-compose --version
elif [  -z "$dc1" -a -z "$dc2" ] ||  [[ "$dc1" =~ .*"No".* ]] || [[ "$dc2" =~ .*"No".* ]]
then
       echo "installing docker-compose"
       sudo pip install docker-compose
else
    echo "Nothing to install"
fi

    echo "Docker version is: $dk1"
    echo "Docker is installed in: $dk2"
    echo "Docker compose version is: $dc1"
    echo "Docker compose is installed in: $dc2"

