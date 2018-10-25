#!/bin/bash

function info() {
  echo -e "\e[32m$1\e[39m"
}

function helpInfo() {
    echo "auto-install OpenFOAM on Ubuntu 18.04, requires network and root"
    echo
    echo "usage: bash ${0##*/} <version_number>"
    echo
    echo "for example:"
    echo "       bash ${0##*/} 2.1.1"
    exit 0
}

function testPrivilige() {
  if hash sudo 2>/dev/null; then
    SUDO=sudo
  elif [[ "$EUID" -eq 0 ]]; then
    SUDO=
  else
    echo 'ERROR require ROOT priviledge please install `sudo` or `su root`.'
    exit
  fi
}



if [ -z "$1" ]; then
  helpInfo
fi

testPrivilige

export OpenFOAM_Version=$1




info '==> Checking and installing build dependencies ...'

$SUDO apt-get update

$SUDO apt-get -y install wget build-essential binutils-dev flex bison zlib1g-dev qt4-dev-tools libqt4-dev libqtwebkit-dev gnuplot \
libreadline-dev libncurses-dev libxt-dev libopenmpi-dev openmpi-bin libboost-system-dev libboost-thread-dev libgmp-dev \
libmpfr-dev python python-dev libcgal-dev gcc-4.8 g++-4.8

info '==> Downloaing and extracting OpenFOAM source codes ...'

#OpenFOAM downloading and installation
cd ~
mkdir -p OpenFOAM
cd OpenFOAM

if [ ! -f "$PWD/OpenFOAM-${OpenFOAM_Version}.tgz" ]; then
wget "http://downloads.sourceforge.net/foam/OpenFOAM-${OpenFOAM_Version}.tgz?use_mirror=mesh" -O OpenFOAM-${OpenFOAM_Version}.tgz
fi

if [ ! -f "$PWD/ThirdParty-${OpenFOAM_Version}.tgz" ]; then
wget "http://downloads.sourceforge.net/foam/ThirdParty-${OpenFOAM_Version}.tgz?use_mirror=mesh" -O ThirdParty-${OpenFOAM_Version}.tgz
fi

tar -xzf OpenFOAM-${OpenFOAM_Version}.tgz
tar -xzf ThirdParty-${OpenFOAM_Version}.tgz

ln -sf /usr/bin/mpicc.openmpi OpenFOAM-${OpenFOAM_Version}/bin/mpicc
ln -sf /usr/bin/mpirun.openmpi OpenFOAM-${OpenFOAM_Version}/bin/mpirun


info '==> Setup GCC build environment ...'

cp -r OpenFOAM-${OpenFOAM_Version}/wmake/rules/linux64Gcc47 OpenFOAM-${OpenFOAM_Version}/wmake/rules/linux64Gcc48
sed -i -e 's/gcc/gcc-4.8/' OpenFOAM-${OpenFOAM_Version}/wmake/rules/linux64Gcc48/c
sed -i -e 's/g++/g++-4.8/' OpenFOAM-${OpenFOAM_Version}/wmake/rules/linux64Gcc48/c++
echo "export WM_CC='gcc-4.8'" >> OpenFOAM-${OpenFOAM_Version}/etc/bashrc
echo "export WM_CXX='g++-4.8'" >> OpenFOAM-${OpenFOAM_Version}/etc/bashrc


info '==> Setup bashrc config `ofXXX` for future use ...'

OF_CONFIG_FILE="$HOME/.setupOpenFOAM-${OpenFOAM_Version}"

cat > "$OF_CONFIG_FILE" <<EOF
#!/bin/bash

OpenFOAM_Version=$OpenFOAM_Version

EOF


cat >> "$OF_CONFIG_FILE" <<'EOF'

function setupNProc() {

  if [[ -n "$WM_NCOMPPROCS" ]]; then
    :
  elif [[ -z $1 || $1 -lt 1 ]]; then
    export WM_NCOMPPROCS=`getconf _NPROCESSORS_ONLN`
  else
    export WM_NCOMPPROCS="$1"
  fi

}

: ${FOAM_SETTINGS:="WM_NCOMPPROCS=`setupNProc` WM_MPLIB=SYSTEMOPENMPI WM_COMPILER=Gcc48"}

STARTUP_SCRIPT="source $HOME/OpenFOAM/OpenFOAM-${OpenFOAM_Version}/etc/bashrc $FOAM_SETTINGS"

alias of${OpenFOAM_Version//./}="${STARTUP_SCRIPT}"
EOF


echo "source '$OF_CONFIG_FILE'" >> $HOME/.bashrc

source $OF_CONFIG_FILE

eval $STARTUP_SCRIPT

info '==> Fix FLEX version in source ...'

#Go into OpenFOAM's main source folder
cd $WM_PROJECT_DIR
find src applications -name "*.L" -type f | xargs sed -i -e 's=\(YY\_FLEX\_SUBMINOR\_VERSION\)=YY_FLEX_MINOR_VERSION < 6 \&\& \1='


info '==> Installing OpenFOAM, this may take a while ...'

# This next command will take a while... somewhere between 30 minutes to 3-6 hours.
./Allwmake 2>&1 | tee log.make

info '==> Post-Install checking for OpenFOAM, this should be quick ...'

#Run it a second time for getting a summary of the installation
./Allwmake 2>&1 | tee log.make


info '==> All done.'
