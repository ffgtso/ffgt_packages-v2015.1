Packages for Gluon 2015.1 as used by Freifunk Gütersloh.

The whole picture, i. e. that's how it's build via Jenkins:

```
if [ ! -d gluon-2015.1-ffgt ]; then
    git clone https://github.com/ffgtso/gluon-v2015.1.git gluon-2015.1-ffgt
    mkdir gluon-2015.1-ffgt/site
    rsync -av --progress site-ffgt-v2015.1/ gluon-2015.1-ffgt/site/
else
    (cd gluon-2015.1-ffgt ; git pull)
fi

if [ ! -e baserelease.txt ]; then
    echo "0.7.0+0" >baserelease.txt
fi

GLUONPKGCOMMIT="`(cd gluon-packages-ffgt-v2015.1/; git rev-parse HEAD)`"
FFGTPKGCOMMIT="`(cd ffgt_packages-v2015.1/; git rev-parse HEAD)`"
FFGTSITECOMMIT="`(cd site-ffgt-v2015.1/; git rev-parse HEAD)`"
GLUONBASECOMMIT="`(cd gluon-2015.1-ffgt/; git rev-parse HEAD)`"
RELEASE="`cat baserelease.txt`-${BUILD_NUMBER}"
rsync -av --progress site-ffgt-v2015.1/ gluon-2015.1-ffgt/site/
sed -i -e "s/^DEFAULT_GLUON_RELEASE :=.*$/DEFAULT_GLUON_RELEASE := ${RELEASE}/" gluon-2015.1-ffgt/site/site.mk
sed -i -e "s/^PACKAGES_FFGT_PACKAGES_COMMIT=.*$/PACKAGES_FFGT_PACKAGES_COMMIT=${FFGTPKGCOMMIT}/" gluon-2015.1-ffgt/site/modules
sed -i -e "s/^PACKAGES_GLUON_COMMIT=.*$/PACKAGES_GLUON_COMMIT=${GLUONPKGCOMMIT}/" gluon-2015.1-ffgt/modules
sed -i -e "s%^PACKAGES_GLUON_REPO=.*$%PACKAGES_GLUON_REPO=https://github.com/ffgtso/gluon-packages-ffgt-v2015.1.git%" gluon-2015.1-ffgt/modules

cd gluon-2015.1-ffgt
make update
make -j6 V=s GLUON_TARGET=ar71xx-generic && make -j6 V=s GLUON_TARGET=mpc85xx-generic && make -j6 V=s GLUON_TARGET=x86-kvm_guest && make -j6 V=s GLUON_TARGET=x86-generic
#make -j6 V=s GLUON_TARGET=x86-kvm_guest
if [ $? -eq 0 ]; then
    touch images/factory/ffgt-firmware-buildinfo-${RELEASE}
    echo "Release: ${RELEASE}" >>images/factory/ffgt-firmware-buildinfo-${RELEASE}
    echo "PACKAGES_FFGT_PACKAGES_COMMIT=${FFGTPKGCOMMIT}" >>images/factory/ffgt-firmware-buildinfo-${RELEASE}
    echo "PACKAGES_GLUON_COMMIT=${GLUONPKGCOMMIT}" >>images/factory/ffgt-firmware-buildinfo-${RELEASE}
    echo "GLUON_BASE_COMMIT=${GLUONBASECOMMIT}" >>images/factory/ffgt-firmware-buildinfo-${RELEASE}
    echo "Buildslave: ${NODE_NAME}" >>images/factory/ffgt-firmware-buildinfo-${RELEASE}
    echo "Buildjob: ${JOB_URL}" >>images/factory/ffgt-firmware-buildinfo-${RELEASE}
fi
```

This assumes that each repo is checked out separately (by Jenkins) at job's root, obviously.
