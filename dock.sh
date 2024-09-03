#! /usr/bin/env bash

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
dk2s="$?"
dc1="$(docker-compose --version 2>&1)"
dc2="$(which docker-compose 2>&1)"
dc2s="$?"
}


dokstatus() {

dokvers

if [[ ( $dk2s != "0"  ) ]]
then
   echo "Docker is not installed"
fi

if [[ ( $dc2s != "0"  ) ]]
then
	echo "Docker compose is not installed"
fi

}

dokcomp() {


dcver="v2.29.2"
echo "The current version of docker compose to be installed is $dcver, check the website https://github.com/docker/compose/releases to confirm the release version or press enter"
read rever

if [[ $rever = "" ]]
then
	dcver=$rever
        #echo "inside dcver $dcver"
        #exit
fi

sudo curl -L "https://github.com/docker/compose/releases/download/${dcver}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
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



if [[ ( $1 = "status" ) ]]
then
dokstatus
exit
fi


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
                        vername=`cat /etc/*-release | grep VERSION_CODENAME | awk '{split($0,a,"="); print a[2]}'`
                        verid=`cat /etc/*-release | grep DISTRIB_RELEASE | awk '{split($0,a,"="); print a[2]}'`
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
                        #sudo curl -fsSL https://download.docker.com/linux/$ki/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

			if [ ! -f "/etc/apt/keyings" ]
                        then
                            echo "keyrings found\n"
			else       
				echo "Keyrings not found\n"
			sudo install -m 0755 -d /etc/apt/keyrings
                        fi 

	                sudo curl -fsSL https://download.docker.com/linux/$ki/gpg -o /etc/apt/keyrings/docker.asc
		        sudo chmod a+r /etc/apt/keyrings/docker.asc

			#sudo curl -fsSL https://download.docker.com/linux/ubuntu/dists/$mi2/pool/stable/amd64
	
			if [ -f "/etc/apt/sources.list.d/docker.list" ]
			then
				echo "docker.list found\n"
				sudo truncate -s 0 /etc/apt/sources.list.d/docker.list
			else
				echo "Creating docker.list file in /etc/apt/sources.list.d"
				sudo touch /etc/apt/sources.list.d/docker.list
			fi
			sudo chmod 777 /etc/apt/sources.list.d/docker.list


			#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	        	#sudo chmod a+r /etc/apt/keyrings/docker.gpg
			
                        sudo echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$ki $vername stable" >> /etc/apt/sources.list.d/docker.list
			sudo $cm1 -y update
		
			if [ "$mi2" == "bionic" ]
			then
				#	sudo snap install docker
				#sudo $cm1 install -yqq docker-ce --allow-unauthenticated
				#sudo apt install docker.io
				echo ""
	                 fi

			 #vercli=" docker-ce-cli_27.2.0-1~ubuntu.24.04~noble_amd64.deb
			 #vercli="docker-ce-cli_24.0.2-1~${ki}.${verid}~${vername}_amd64.deb"

                      
                         vercli1=`sudo apt-cache madison docker-ce-cli | head -1 | awk '{ split($0,a,"|"); print a[2]}' | awk '{ split($0,a,":"); print a[2]}' | xargs`
		      	 vercli="docker-ce-cli=${vercli1}"


			 #docker-ce_27.2.0-1~ubuntu.24.04~noble_amd64.deb 
			 verce1=`sudo apt-cache madison docker-ce | head -1 | awk '{ split($0,a,"|"); print a[2]}' | awk '{ split($0,a,":"); print a[2]}' | xargs`
			 verce="docker-ce=${verce1}"

                         #docker-compose-plugin_2.29.2-1~ubuntu.24.04~noble_amd64.deb  
                         vercomp1=`sudo apt-cache madison docker-compose-plugin | head -1 | awk '{ split($0,a,"|"); print a[2]}' | xargs `
	      		 vercomp="docker-compose-plugin=${vercomp1}"
                         
			 vercon1=`sudo apt-cache madison containerd.io | head -1 | awk '{ split($0,a,"|"); print a[2]}' | xargs `
			 vercon="containerd.io=${vercon1}"


                         dokbuild=`sudo apt-cache madison docker-buildx-plugin | head -1 | awk '{ split($0,a,"|"); print a[2]}'  | xargs`
                         dockerbuild="docker-buildx-plugin=${dokbuild}"

			 #sudo $cm1 -y install docker-ce${version1} docker-ce-cli${version2} containerd.io        
			 sudo $cm1 -y install $dockerbuild  $vercon $vercomp       
		         dokenable
		      	 #dokcomp
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

