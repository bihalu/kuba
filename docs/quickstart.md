# Quickstart

You need a clean Alpine Linux v3.18 with 4CPU, 8GB RAM and 40GB DISK.

## 1. Build kuba setup package
```bash
cd ~
apk add bash git
git clone https://github.com/bihalu/kuba.git
cd kuba
git fetch
git pull
./kuba-build-1.28.0.sh
```
Takes about 15 minutes ...  
coffe break ;-)

## 2. Build kuba app package
```bash
./kuba-apps-2023.9.sh
```
Takes about 5 minutes ...  
pee break :-o 

## 3. Setup kubernetes single node cluster 
```bash
./kuba-setup-1.28.0.tgz.self init single
```
Takes about 6 minutes ...  
almost done   

You can have a look at the cluster with k9s tool.  

```bash
k9s
```
Pods are created.  
``/\_/\``  
``(='_')``   
``(,(")(")``  

## 4. Install wordpress 
```bash
./kuba-apps-2023.9.tgz.self install wordpress
```
Only 3 minutes left ...  
Done


