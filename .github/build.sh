#!/bin/bash
#shellcheck disable=SC2086,SC2046,SC2155

get_toolchain() {
    case "$1" in
        "linux")
            case "$2" in
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
                    echo "Unsupported architecture: $2"
                    exit 1
                ;;
            esac
        ;;
        *)
            echo "Unsupported platform: $1"
            exit 1
        ;;
    esac

    echo "TOOLCHAIN=$TOOLCHAIN"
    echo "CROSS_CXX=$CROSS_CXX"
    echo "CROSS_STRIP=$CROSS_STRIP"
}

install_dependencies() {
    local CURRENT_ARCHITECTURE="$(dpkg-architecture -q DEB_HOST_ARCH)"

    case "$1" in
        "arm64"|"armhf")
            echo "Modifying /etc/apt/sources.list for $1"

            #shellcheck disable=SC1091
            . /etc/os-release

            [ -z "$VERSION_CODENAME" ] && { echo "Unable to fetch VERSION_CODENAME from /etc/os-release"; exit 1; }

            echo "VERSION_CODENAME=$VERSION_CODENAME"

            sudo sed "s/^deb /deb [arch=$CURRENT_ARCHITECTURE] /" -i /etc/apt/sources.list
            sudo bash -c "cat >> /etc/apt/sources.list" << EOF
deb [arch=$1] http://ports.ubuntu.com/ $VERSION_CODENAME main multiverse universe
deb [arch=$1] http://ports.ubuntu.com/ $VERSION_CODENAME-security main multiverse universe
deb [arch=$1] http://ports.ubuntu.com/ $VERSION_CODENAME-backports main multiverse universe
deb [arch=$1] http://ports.ubuntu.com/ $VERSION_CODENAME-updates main multiverse universe
EOF
        ;;
        "amd64"|"i386")
            # Nothing to do here
        ;;
        *)
            echo "Unsupported architecture: $1"
            exit 1
        ;;
    esac

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
}

build() {
    EXTRA=""
    if [ "$3" = true ]; then
        export UFLAGS=-static
        EXTRA="-static"

        echo "Binary will be statically linked"
    fi

    echo "Building for $1 $2$EXTRA..."

    make
    file xupnpd
    tar -czvf xupnpd2-$1-$2$EXTRA.tar.gz xupnpd xupnpd.cfg xupnpd.lua www/ media/ doc/ LICENSE
}

###################

[ -z "$1" ] && exit 1
[ -z "$GITHUB_WORKSPACE" ] && exit 1
cd $GITHUB_WORKSPACE || exit 1

set -e

VARIANT="$1"

PLATFORM="$(echo "$VARIANT" | cut -d '/' -f 1)"
ARCHITECTURE="$(echo "$VARIANT" | cut -d '/' -f 2)"

echo "VARIANT=$VARIANT"
echo "PLATFORM=$PLATFORM"
echo "ARCHITECTURE=$ARCHITECTURE"
[ -n "$STATIC" ] && echo "STATIC=$STATIC"

get_toolchain "$PLATFORM" "$ARCHITECTURE"

echo "PLATFORM=$PLATFORM" >> $GITHUB_ENV
echo "ARCHITECTURE=$ARCHITECTURE" >> $GITHUB_ENV

install_dependencies "$ARCHITECTURE"

build "$PLATFORM" "$ARCHITECTURE"
{ [ "$STATIC" = "true" ] || [ "$STATIC" = true ] ; } && build "$PLATFORM" "$ARCHITECTURE" true

echo "Done"
