#!/bin/bash

###Setup variables ###
key=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/key" -H "Metadata-Flavor: Google")

masterIpAddress=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/masterIpAddress" -H "Metadata-Flavor: Google")

instanceName=$(curl "http://metadata/computeMetadata/v1/instance/name" -H "Metadata-Flavor:Google")

zoneName=$(curl "http://metadata/computeMetadata/v1/instance/zone" -H "Metadata-Flavor:Google" | cut -d/ -f4)

### End Setup variables ###

### Install Dependancies ###

#Intall Node
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

#Install git
sudo apt-get install -y git

#Install Distributed Computatin program
git clone https://github.com/portsoc/clocoss-master-worker
cd clocoss-master-worker
npm install

### End Install Dependancies ###

#Run client
npm run client $key $masterIpAddress:8080

#Stop Instance
gcloud compute instances stop $instanceName --zone $zoneName
