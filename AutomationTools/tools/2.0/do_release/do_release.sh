#! /bin/bash
#
# Author        :   Rayofox(lhu@actiontec.com)
# Description   :
#   This tool is for release new version for automation.
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#24 Oct 2011    |   1.0.0   | rayofox   | Inital Version       
#29 Oct 2011    |   2.0.1   | rayofox   | new for Automation 2.0
#15 Nov 2011    |   2.0.2   | rayofox   | add tools/2.0/common in special release package also
#31 May 2012    |   2.0.3   | rayofox   | add tools/2.0/wine and remove tools/2.0/autoconf
#
#
#
#REV="$0 version 1.0.0 (24 Oct 2011) Initial version"
#REV="$0 version 2.0.1 (29 Oct 2011) New for Automation 2.0"
#REV="$0 version 2.0.2 (15 Nov 2011) New for Automation 2.0"
REV="$0 version 2.0.3 (31 May 2012) for Automation 2.0"
# print REV

echo "${REV}"

PROD="ALL"
RN_FILE=""

# USAGE
USAGE()
{
    cat <<usge
USAGE : 

    bash $0 -f RELEASE_NODE_FILE [-d PROD]

    OPTIONS:

    -d:     release for special product , such as Q2KH, BHR2, default is ALL for all products
    -f:     the release note file
usge
}

# parse command line
while [ -n "$1" ];
do
    case "$1" in
        -d)
            PROD=$2
            echo "the node to be searched in GPV log is ${node2ser}"
            shift 2
            ;;
        -f)
            RN_FILE=$2
            echo "the source file is ${src}"
            shift 2
            ;;
        *)
            USAGE
            exit 1
    esac
done


#
if [ -f "${RN_FILE}" ]; then
    echo "release note file : ${RN_FILE}"
else
    echo "release note file : not exist!"
    exit 1
fi

#
echo "The release product is ${PROD}!"

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

# copy file
AUTO_VER=2.0

# bin
if [ ${PROD} == "ALL" ];then
    echo "create folder bin/${AUTO_VER}"
    mkdir -p ${INSTALL_PATH}/bin/${AUTO_VER}
    echo "copy folder bin/${AUTO_VER}/*"
    cp -rf ${AUTO_ROOT}/bin/${AUTO_VER}/* ${INSTALL_PATH}/bin/${AUTO_VER}/
else
    echo "create folder bin/${AUTO_VER}/${PROD}"
    mkdir -p ${INSTALL_PATH}/bin/${AUTO_VER}/${PROD}
    
    echo "copy folder bin/${AUTO_VER}/common"
    cp -rf ${AUTO_ROOT}/bin/${AUTO_VER}/common ${INSTALL_PATH}/bin/${AUTO_VER}/common
    
    echo "copy folder bin/${AUTO_VER}/${PROD}"
    cp ${AUTO_ROOT}/bin/${AUTO_VER}/${PROD}/* ${INSTALL_PATH}/bin/${AUTO_VER}/${PROD}/
fi

# tools
echo "create folder tools/${AUTO_VER}"
mkdir -p ${INSTALL_PATH}/tools/${AUTO_VER}
#echo "copy folder tools/${AUTO_VER}/autoconf"
#cp -rf ${AUTO_ROOT}/tools/${AUTO_VER}/autoconf ${INSTALL_PATH}/tools/${AUTO_VER}/
echo "copy folder tools/${AUTO_VER}/ATE"
cp -rf ${AUTO_ROOT}/tools/${AUTO_VER}/ATE ${INSTALL_PATH}/tools/${AUTO_VER}/

echo "copy folder tools/${AUTO_VER}/tr69"
cp -rf ${AUTO_ROOT}/tools/${AUTO_VER}/tr69 ${INSTALL_PATH}/tools/${AUTO_VER}/

echo "copy folder tools/${AUTO_VER}/http_player"
cp -rf ${AUTO_ROOT}/tools/${AUTO_VER}/http_player ${INSTALL_PATH}/tools/${AUTO_VER}/

echo "copy folder tools/${AUTO_VER}/common"
cp -rf ${AUTO_ROOT}/tools/${AUTO_VER}/common ${INSTALL_PATH}/tools/${AUTO_VER}/

echo "copy folder tools/${AUTO_VER}/wine"
cp -rf ${AUTO_ROOT}/tools/${AUTO_VER}/wine ${INSTALL_PATH}/tools/${AUTO_VER}/

echo "copy folder tools/${AUTO_VER}/START_SERVERS"
cp -rf ${AUTO_ROOT}/tools/${AUTO_VER}/START_SERVERS ${INSTALL_PATH}/tools/${AUTO_VER}/

# platform
echo "create folder platform/${AUTO_VER}"
mkdir -p ${INSTALL_PATH}/platform/${AUTO_VER}
if [ "${PROD}" == "ALL" ];then
    echo "copy folder platform/${AUTO_VER}"
    cp -rf ${AUTO_ROOT}/platform/${AUTO_VER} ${INSTALL_PATH}/platform/
else
    echo "copy folder platform/${AUTO_VER}/common"
    cp -rf ${AUTO_ROOT}/platform/${AUTO_VER}/common ${INSTALL_PATH}/platform/${AUTO_VER}/
    echo "copy folder platform/${AUTO_VER}/${PROD}"
    cp -rf ${AUTO_ROOT}/platform/${AUTO_VER}/${PROD} ${INSTALL_PATH}/platform/${AUTO_VER}/
fi

# testsuites
echo "copy folder testsuites/${AUTO_VER}"
mkdir -p ${INSTALL_PATH}/testsuites
cp -rf ${AUTO_ROOT}/testsuites/${AUTO_VER} ${INSTALL_PATH}/testsuites/

# cert
echo "create folder certs"
mkdir -p ${INSTALL_PATH}/certs

# firmware
echo "create folder firmware"
mkdir -p ${INSTALL_PATH}/firmware

echo "copy folder firmware/readme"
cp -rf ${AUTO_ROOT}/firmware/readme ${INSTALL_PATH}/firmware/

#echo "copy folder config/${AUTO_VER}"
#mkdir -p ${INSTALL_PATH}/config
#cp -rf ${AUTO_ROOT}/config/${AUTO_VER} ${INSTALL_PATH}/config/


# add automation rule for bash
cp ./addrule.sh ${INSTALL_PATH}/
cp automationrc ${INSTALL_PATH}/


# get the release tag name and create release note file
FILE_RN="${INSTALL_PATH}/release_note"
touch ${FILE_RN}

ATR_DATE=`date`
ATR_TAG=`git log -1 | grep commit | awk '{print \$2}'`

#
echo "release Date  : ${ATR_DATE}" >> ${FILE_RN}
echo "release Tag   : ${ATR_TAG}" >> ${FILE_RN}
echo "release INFO  : " >> ${FILE_RN}

# add custom release note 

while read LINE
do
    echo ${LINE} >> ${FILE_RN}
done < ${RN_FILE}


