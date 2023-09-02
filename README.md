# kuba
Kubernetes on Alpine Linux

# description
Kuba is a shell script that creates a self-executable package for installing kubernetes.  
It is intended for Alpine Linux and can also be used in an airgap environment.

# build
Alpine Linux version 3.18 is required to create the kuba installation package.  
In addition, bash and git are required.  
You should run the script as root, because the packages will be downloaded and installed during the build process.

The complete build process takes about 16 minutes (depending on the internet connection).

``` bash
apk add bash git
git clone https://github.com/bihalu/kuba.git
cd kuba
./kuba-build-1.28.0.sh
```

Finally a setup package with a size of 1.4GB is created :-)
> Be patient creating self extracting archive ...  
> build kuba-setup-1.28.0.tgz.self took 15 minutes 53 seconds

# setup
Setting up a Kubernetes cluster always starts with the initialization of the first control-plane node.  
Table with all parameters for kuba setup:  

| Parameters | Description |
| --- | --- |
| `init single` | Initialize single node kubernetes cluster |
| `init cluster` | Initialize first kubernetes control-plan |
| `join worker <ip-control-plane>` | add worker node to kubernetes cluster |
| `join controlplane <ip-control-plane>` | add control-plane node to kubernetes cluster |
| `upgrade` | not implemented yet - upgrade kubernetes version |
| `delete` | not implemented yet - delete node from kubernetes cluster |

## init single
For test and development environments, kuba offers to set up a single node cluster. This is the easiest and fastest way to create a working kubernetes cluster.

Just copy the previously created setup package to a new Alpine Linux server and start it with the parameters "init single".

``` bash
./kuba-setup-1.28.0.tgz.self init single
```

The installation takes about 6 minutes.
> setup took 5 minutes 54 seconds

## init cluster
Has yet to be documented

## join worker
Has yet to be documented

## join controlplane
Has yet to be documented

# kubernetes architecture
Just a short overview, reference to [kubernetes doku](https://kubernetes.io/docs/concepts/overview/)

# requirements
Kubernetes itself doesn't need a lot of resources. It is designed to distribute the load across many nodes. If you want to operate heavy workloads in the cluster, then the resources for worker nodes must be adjusted in any case.

| Node | Minimum | Recommended |
| --- | --- | --- |
| `single node cluster` | 2CPU, 4GB RAM, 20GB DISK | 4CPU, 8GB RAM, 80GB DISK |
| `control-plan node` | 2CPU, 4GB RAM, 20GB DISK | 4CPU, 8GB RAM, 80GB DISK |
| `worker node` | 2CPU, 4GB RAM, 20GB DISK | 4CPU, 8GB RAM, 80GB DISK + 200GB DISK |
| `heavy worker node` | 4CPU, 16GB RAM, 80GB DISK + additional data disks | 16CPU, 64GB RAM, 200GB DISK + additional data disks |

## storage
Kubernetes storage is a topic of its own.  
Kuba uses openEBS as a storage solution. openEBS local PV with Hostpath is used in a single node cluster. This is the carefree package.  

In a more complex scenario with multiple worker nodes, you need a different storage solution. I would also like to examine openEBS with mayastor and rook ceph.

# network
Kubernetes has no specifications regarding the network. Only the nodes need to be able to communicate with each other.  

In practice, of course, you have to take things like a firewall or subnets into account.  

You also need a load balancer if you want to access the cluster from outside.

## load balancer