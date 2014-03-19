#!/bin/bash -e

usage() { echo "Usage: $0 -s sphinx-version -p percona-version -d percona-deb-version [-o org-prefix]
Example: $0 -s 2.1.6 -p 5.5.36-34.1 -d 5.5.36-rel34.1-642.wheezy -o my_org" 1>&2; exit 1; }

# set default prefix for package version
ORG_PREFIX='wheezy'

# get options
while getopts s:p:d:o: option
do
  case "${option}"
  in
    s) SPHINX_VER=${OPTARG};;
    p) PERCONA_VER=${OPTARG};;
    d) PERCONA_DEB_VER=${OPTARG};;
    o) ORG_PREFIX=${OPTARG};;
    *) usage;;
  esac
done

# check is options empty
if [ -z "${SPHINX_VER}" ] || [ -z "${PERCONA_VER}" ] || [ -z "${PERCONA_DEB_VER}" ] ; then
  usage
fi

PERCONA_SHORT_VER=`echo ${PERCONA_VER} | cut -c 1-3`

WORK_DIR="${PWD}"
BUILD_DIR="${WORK_DIR}/_build"
INSTALL_DIR="${WORK_DIR}/_install"
PKG_DIR="${WORK_DIR}/_pkg"
# I know about nproc, but in openvz it fails.
CPU_COUNT=`grep processor /proc/cpuinfo | wc -l`

# prepare workspace
mkdir -p ${BUILD_DIR} ${INSTALL_DIR} ${PKG_DIR}
cd ${BUILD_DIR}

# download percona source
wget http://www.percona.com/downloads/Percona-Server-${PERCONA_SHORT_VER}/LATEST/source/tarball/percona-server-${PERCONA_VER}.tar.gz
tar xzf percona-server-${PERCONA_VER}.tar.gz

# download sphinxsearch source
wget http://sphinxsearch.com/files/sphinx-${SPHINX_VER}-release.tar.gz
tar xzf sphinx-${SPHINX_VER}-release.tar.gz

# install build depends for percona
sudo apt-get update
sudo apt-get -y install build-essential cmake libaio-dev libncurses5-dev

# configure and build ha_sphinx module
cp -R ${BUILD_DIR}/sphinx-${SPHINX_VER}-release/mysqlse ${BUILD_DIR}/percona-server-${PERCONA_VER}/storage/sphinx
cd ${BUILD_DIR}/percona-server-${PERCONA_VER}
cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_CONFIG=mysql_release -DFEATURE_SET=community -DWITH_EMBEDDED_SERVER=OFF
cd ${BUILD_DIR}/percona-server-${PERCONA_VER}/storage/sphinx
make -j${CPU_COUNT}

# copy compiled module to install dir
mkdir -p ${INSTALL_DIR}/usr/lib/mysql/plugin/
cp ${BUILD_DIR}/percona-server-${PERCONA_VER}/storage/sphinx/ha_sphinx.so ${INSTALL_DIR}/usr/lib/mysql/plugin/
chmod 644 ${INSTALL_DIR}/usr/lib/mysql/plugin/ha_sphinx.so

## create deb package with fpm
cd ${WORK_DIR}
fpm -s dir -t deb -C ${INSTALL_DIR}/ \
    -n sphinx-se -v ${SPHINX_VER} \
    --iteration ${ORG_PREFIX} \
    --description 'Sphinx SE plugin for Percona server' \
    --url 'https://github.com/dragolabs/dpkg-sphinx-se' \
    -d "percona-server-server-${PERCONA_SHORT_VER} = ${PERCONA_DEB_VER}" \
    --after-install ${WORK_DIR}/scripts/postinst \
    --before-remove ${WORK_DIR}/scripts/prerm \
    -p ${PKG_DIR}/sphinx-se-VERSION_ARCH.deb .


