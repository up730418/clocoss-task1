#!/bin/bash

#set compute Zone
computeZone="europe-west1-d"

#set client VM name
clientName="robert-worker"

### Install/update Dependancis ###

#Install git
sudo apt-get install -y git

#Install Node
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

#Install Distributed Computatin program
sudo git clone https://github.com/portsoc/clocoss-master-worker
cd clocoss-master-worker
sudo npm install

###End Install/update Dependancis###

#Allow conections on 8080
sudo iptables -A INPUT -i eth0 -p tcp --dport 8080 -j ACCEPT

#Generate secret key
key=`openssl rand -base64 32`

#Get master server ip address
masterIpAddress=$(curl "http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor:Google")

#Run server
npm run server $key &

#Create workers 
for i in `seq 1 $1`
do

 gcloud compute instances create \
         --machine-type f1-micro  \
         --metadata masterIpAddress="$masterIpAddress",key="$key" \
         --metadata-from-file startup-script="../task1-worker.sh" \
         --scopes compute-rw \
         $clientName-$i \
         --zone $computeZone

done

#Wait for server to exit
wait "$!"

#On server exit destroy all workers
for i in `seq 1 $1`
do
 gcloud compute instances delete \
         $clientName-$i \
         --zone $computeZone \
         --quiet

done
