# GCE Docker Swarm with Persistent Disk Setup 

- Docker (version: 18.06.1)
- Google Compute Engine 
- Docker stack with Google Persistent Disk

## Docker Script

### Docker script Features

- increase virtual memory for elasticsearch
- docker metrics setup at localhost:9323/metrics, used in Grafana
- rexray plugin for google cloud persistent disk

### Install docker script

Set execute permission for script:

`sudo chmod +x install-docker.sh`

Run install docker script:

`./install-docker.sh`

## Docker Swarm Setup

- 3 Managers -> minimum for a fault tolerance of 1
- x workers -> depends on your needs

### Initializing Docker Swarm And Add Managers/Workers

On master vm:

`sudo docker swarm init --advertise-addr <master-vm-ip-address>`

Get token for adding more managers:

`sudo docker swarm join-token manager`

Get token for adding workers:

`sudo docker swarm join-token worker`

Go to other Manager/Worker VM, run `install-docker.sh` then join swarm with token from above.

Check all the nodes in the swarm:

`sudo docker node ls`

### Drain Manager Nodes

**Note** If you do not want service containers deployed on the manager VM, drain the manager nodes:

`sudo docker node update --availability drain <manager-node-name>`

### Node Label

Label the nodes if you want to set constraints when deploying stacks

`docker node update --label-add <key>=<value> <node-id>`

Check labels on nodes:

`sudo docker node ls -q | xargs docker node inspect -f '[{{ .Description.Hostname }}]: {{ .Spec.Labels }}'`

Example:

`docker node update --label-add project=foobar foobar-worker-1`

`docker node update --label-add project=foobar foobar-worker-2`

**docker-stack-example.yml**

``` 
version: '3.3'

services:
    
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch-oss:6.2.4
    ...
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.labels.project == foobar
          - node.role == worker
```

## Google Cloud Persistent Volume

### Install Rex-Ray as Docker Plugin

Needs to be install on all docker swarm nodes (install via `install-docker.sh`)

Create google cloud persistent disk:

`docker volume create -d rexray/gcepd:latest --name <disk-name> --opt=size=10 --opt=type=pd-standard`

**Note** Size of disk must be a minimum of 10GB