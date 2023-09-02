# kuba
Kubernetes on Alpine Linux

# description
kuba is a shell script that creates a self-executable package for installing kubernetes. It is intended for Alpine Linux and can also be used in an airgap environment.

# build
Alpine Linux version 3.18 is required to create the cuba installation package. In addition, bash and git are required. You should run the script as root, because the packages will be downloaded and installed during the build process.

The complete build process takes about 15 minutes (depending on the internet connection).

``` bash
apk add bash git
git clone https://github.com/bihalu/kuba.git
cd kuba
./kuba-build-1.28.0.sh
```

At the end, an installation package with a size of 1.4GB is created:
> kuba-setup-1.28.0.tgz.self

# install
