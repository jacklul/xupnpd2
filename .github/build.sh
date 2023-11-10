#!/bin/bash
#shellcheck disable=SC2086,SC2046

[ -z "$1" ] && exit 1
[ -z "$GITHUB_WORKSPACE" ] && exit 1
cd $GITHUB_WORKSPACE || exit

VARIANT="$1"
PLATFORM="$(echo "$VARIANT" | cut -d '/' -f 1)"
ARCHITECTURE="$(echo "$VARIANT" | cut -d '/' -f 2)"
CURRENT_ARCHITECTURE="$(dpkg-architecture -qDEB_HOST_ARCH)"

echo "VARIANT=$VARIANT"
echo "PLATFORM=$PLATFORM"
echo "ARCHITECTURE=$ARCHITECTURE"
echo "CURRENT_ARCHITECTURE=$CURRENT_ARCHITECTURE"

case "$PLATFORM" in
    "linux")
        case "$ARCHITECTURE" in
            "amd64")
                TOOLCHAIN=g++-x86-64-linux-gnu
                CROSS_CXX=x86-64-linux-gnu-g++
                CROSS_STRIP=x86-64-linux-gnu-strip
            ;;
            "i386")
                TOOLCHAIN=g++-i686-linux-gnu
                CROSS_CXX=i686-linux-gnu-g++
                CROSS_STRIP=i686-linux-gnu-strip
            ;;
            "arm64")
                TOOLCHAIN=g++-aarch64-linux-gnu
                CROSS_CXX=aarch64-linux-gnu-g++
                CROSS_STRIP=aarch64-linux-gnu-strip
            ;;
            "armhf")
                TOOLCHAIN=g++-arm-linux-gnueabihf
                CROSS_CXX=arm-linux-gnueabihf-g++
                CROSS_STRIP=arm-linux-gnueabihf-strip
            ;;
            "armel")
                TOOLCHAIN=g++-arm-linux-gnueabi
                CROSS_CXX=arm-linux-gnueabi-g++
                CROSS_STRIP=arm-linux-gnueabi-strip
            ;;
            *)
                echo "Unsupported architecture: $ARCHITECTURE"
                exit 1
            ;;
        esac
    ;;
    *)
        echo "Unsupported platform: $PLATFORM"
        exit 1
    ;;
esac

echo "PLATFORM=$PLATFORM" >> $GITHUB_ENV
echo "ARCHITECTURE=$ARCHITECTURE" >> $GITHUB_ENV

case "$ARCHITECTURE" in
    "arm64"|"armhf")
        echo "Modifying /etc/apt/sources.list"

        #shellcheck disable=SC1091
        . /etc/os-release

        [ -z "$VERSION_CODENAME" ] && { echo "Unable to fetch VERSION_CODENAME from /etc/os-release"; exit 1; }

        echo "VERSION_CODENAME=$VERSION_CODENAME"

        sudo sed "s/^deb /deb [arch=$CURRENT_ARCHITECTURE] /" -i /etc/apt/sources.list
        sudo bash -c "cat >> /etc/apt/sources.list" << EOF
deb [arch=$ARCHITECTURE] http://ports.ubuntu.com/ $VERSION_CODENAME main multiverse universe
deb [arch=$ARCHITECTURE] http://ports.ubuntu.com/ $VERSION_CODENAME-security main multiverse universe
deb [arch=$ARCHITECTURE] http://ports.ubuntu.com/ $VERSION_CODENAME-backports main multiverse universe
deb [arch=$ARCHITECTURE] http://ports.ubuntu.com/ $VERSION_CODENAME-updates main multiverse universe
EOF
    ;;
    "amd64"|"i386")
        # Nothing to do here
    ;;
    *)
        echo "Unsupported architecture: $ARCHITECTURE"
        exit 1
    ;;
esac

echo "TOOLCHAIN=$TOOLCHAIN"
echo "CROSS_CXX=$CROSS_CXX"
echo "CROSS_STRIP=$CROSS_STRIP"

set -e

sudo dpkg --add-architecture $ARCHITECTURE
sudo apt-get update

echo "Installing dependencies..."

if [ "$CURRENT_ARCHITECTURE" != "$ARCHITECTURE" ]; then
    sudo apt-get install -y build-essential make $TOOLCHAIN $(echo "$DEPENDENCIES" | sed -E "s/([^ ]+)/\1:$ARCHITECTURE/g")

    export CXX=$CROSS_CXX
    export STRIP=$CROSS_STRIP
else
    sudo apt-get install -y build-essential make $TOOLCHAIN $DEPENDENCIES
fi

echo "Building..."

make
file xupnpd
