#! /bin/sh

VER="$0 version 1.0.0 (24 Oct 2011) Initial version"

# print version

echo "${VER}"

PROD="ALL"

if [ -z "$1" ];then
    echo "The release product is for all!"
else
    PROD=$1
    echo "The release product is ${PROD}!"
fi
# implement
INSTALL_PATH="./automation"
AUTO_ROOT=${SQAROOT}

# make dir
if [ -d "automation" ];then
    echo "folder automation is already exist ,please remove(backup) it and try again!"
    exit 1
else
    mkdir automation
fi

# get the release tag name and create release note file
FILE_RN="${INSTALL_PATH}/release_note"
touch ${FILE_RN}

echo "release at `date`" > ${FILE_RN}
RESP=`git log -1 | grep commit | awk '{print \$2}'`
echo "The release git tag name is : ${RESP}" 
echo "The release git tag name is : ${RESP}"  >> ${FILE_RN}

# copy file
PROD_VER=1.0
echo "copy folder bin/${PROD_VER}"
mkdir ${INSTALL_PATH}/bin;cp -rf ${AUTO_ROOT}/bin/${PROD_VER} ${INSTALL_PATH}/bin/

mkdir ${INSTALL_PATH}/tools
mkdir ${INSTALL_PATH}/tools/${PROD_VER}
echo "copy folder tools/${PROD_VER}/autoconf"
cp -rf ${AUTO_ROOT}/tools/${PROD_VER}/autoconf ${INSTALL_PATH}/tools/${PROD_VER}/
echo "copy folder tools/${PROD_VER}/ATE"
cp -rf ${AUTO_ROOT}/tools/${PROD_VER}/ATE ${INSTALL_PATH}/tools/${PROD_VER}/


echo "copy folder platform/${PROD_VER}"
mkdir ${INSTALL_PATH}/platform
if [ "${PROD}" == "ALL" ];then
    cp -rf ${AUTO_ROOT}/platform/${PROD_VER} ${INSTALL_PATH}/platform/
else
    mkdir ${INSTALL_PATH}/platform/${PROD_VER}
    cp -rf ${AUTO_ROOT}/platform/${PROD_VER}/${PROD} ${INSTALL_PATH}/platform/${PROD_VER}/
    cp -rf ${AUTO_ROOT}/platform/${PROD_VER}/common ${INSTALL_PATH}/platform/${PROD_VER}/
fi
echo "copy folder testsuites/${PROD_VER}"
mkdir ${INSTALL_PATH}/testsuites;cp -rf ${AUTO_ROOT}/testsuites/${PROD_VER} ${INSTALL_PATH}/testsuites/

echo "copy folder config/${PROD_VER}"
mkdir ${INSTALL_PATH}/config;cp -rf ${AUTO_ROOT}/config/${PROD_VER} ${INSTALL_PATH}/config/





