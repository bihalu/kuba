#!/bin/bash

NAME="minio"
VERSION="2023.7.18"
BUILD_START=$(date +%s)

################################################################################
# container images for airgap installation
readarray -t IMAGES <<EOL_IMAGES
################################################################################
# minio 2023.7.18 -> https://artifacthub.io/packages/helm/bitnami/minio/12.8.1
docker.io/bitnami/minio:2023.7.18-debian-11-r0
EOL_IMAGES

SKIP_IMAGES=0
PULL=true
CONTAINER_IMAGES=""

for IMAGE in "${IMAGES[@]}" ; do
  # don't process commented out images
  [[ ${IMAGE:0:1} = \# ]] && continue

  # skip images
  [[ ${SKIP_IMAGES} -gt 0 ]] && ((SKIP_IMAGES--)) && continue

  # pull image
  if [[ ${PULL} = true ]] ; then
    podman pull ${IMAGE}

    # exit on install error
    [[ $? != 0 ]] && exit 1
  fi

  CONTAINER_IMAGES+=" "
  CONTAINER_IMAGES+=${IMAGE}
done

SAVE=true

if [[ ${SAVE} = true ]] ; then
  # save images as tar file
  mkdir -p container

  # cleanup container images tar file
  [[ -f container/images.tar ]] && rm -f container/images.tar

  # save all images in container images tar file
  podman save --multi-image-archive --output container/images.tar ${CONTAINER_IMAGES}
fi

################################################################################
# helm charts -> chart_url chart_repo chart_name chart_version
readarray -t HELM_CHARTS <<EOL_HELM_CHARTS
https://charts.bitnami.com/bitnami bitnami minio 12.8.1
EOL_HELM_CHARTS

SKIP_CHARTS=0

mkdir -p helm/

for CHART in "${HELM_CHARTS[@]}" ; do
  # don't process commented out helm charts
  [[ ${CHART:0:1} = \# ]] && continue

  # skip helm charts
  [[ ${SKIP_CHARTS} -gt 0 ]] && ((SKIP_CHARTS--)) && continue

  # parse chart data
  CHART_DATA=($CHART)
  CHART_URL="${CHART_DATA[0]}"
  CHART_REPO="${CHART_DATA[1]}"
  CHART_NAME="${CHART_DATA[2]}"
  CHART_VERSION="${CHART_DATA[3]}"

  # add helm repo
  helm repo add ${CHART_REPO} ${CHART_URL} 

  # create folder for helm chart
  mkdir -p helm/${CHART_NAME}/

  # pull helm chart
  helm pull ${CHART_REPO}/${CHART_NAME} --version ${CHART_VERSION}

  # exit on pull error
  [[ $? != 0 ]] && exit 1

  # move helmchart to folder
  mv ${CHART_NAME}-${CHART_VERSION}.tgz helm/${CHART_NAME}/
done

################################################################################
# create app.sh
cat - > app.sh <<EOF_APP
#!/bin/sh

SETUP_START=\$(date +%s)

################################################################################
# specific routines for:
# - install
# - uninstall
echo "app \$1 \$2"

INSTALL=false
UNINSTALL=false
MINIO=true

[ "\$1" = install ] && INSTALL=true
[ "\$1" = uninstall ] && UNINSTALL=true

################################################################################
# install minio
if [ \$INSTALL = true ] && [ \$MINIO = true ] ; then
  helm upgrade --install minio helm/minio/minio-12.8.1.tgz \
    --create-namespace \
    --namespace minio \
    --version 12.8.1 \
    --set service.type=NodePort \
    --set service.nodePorts.console=30001 \
    --set service.nodePorts.api=30002
fi
  
################################################################################
# uninstall minio
if [ \$UNINSTALL = true ] && [ \$MINIO = true ] ; then
  helm uninstall minio --namespace minio
fi

################################################################################
# cleanup
rm -rf setup.sh container/ helm/ 

################################################################################
# finish
SETUP_END=\$(date +%s)
SETUP_MINUTES=\$(echo "(\$SETUP_END - \$SETUP_START) / 60" | bc)
SETUP_SECONDS=\$(echo "\$SETUP_END - \$SETUP_START - (\$SETUP_MINUTES * 60)" | bc)

echo "app \$1 \$2 took \$SETUP_MINUTES minutes \$SETUP_SECONDS seconds"
EOF_APP

chmod +x app.sh

################################################################################
# create self extracting archive
TAR_FILE="${NAME}-${VERSION}.tgz"
SELF_EXTRACTABLE="$TAR_FILE.self"
PACK=true

if [[ ${PACK} = true ]] ; then
  echo "Be patient creating self extracting archive ..."
  # pack and create self extracting archive
  tar -czf ${TAR_FILE} app.sh container/ helm/

  echo '#!/bin/sh' > $SELF_EXTRACTABLE
  echo 'echo Be patient extracting archive ...' >> $SELF_EXTRACTABLE
  echo 'dd bs=`head -5 $0 | wc -c` skip=1 if=$0 | gunzip -c | tar -x' >> $SELF_EXTRACTABLE
  echo 'exec ./app.sh $1 $2' >> $SELF_EXTRACTABLE
  echo '######################################################################' >> $SELF_EXTRACTABLE

  cat $TAR_FILE >> $SELF_EXTRACTABLE
  chmod a+x $SELF_EXTRACTABLE
fi

################################################################################
# cleanup
CLEANUP=true

if [[ ${CLEANUP} = true ]] ; then
  rm -rf $TAR_FILE app.sh container/ helm/
fi

################################################################################
# finish
BUILD_END=$(date +%s)
BUILD_MINUTES=$(echo "($BUILD_END - $BUILD_START) / 60" | bc)
BUILD_SECONDS=$(echo "$BUILD_END - $BUILD_START - ($BUILD_MINUTES * 60)" | bc)

echo "build $SELF_EXTRACTABLE took $BUILD_MINUTES minutes $BUILD_SECONDS seconds"
