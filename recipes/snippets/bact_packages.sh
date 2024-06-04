#!/bin/sh

packages="bact-math-utils \
bact-device-models        \
bact-analysis             \
bact-bessyii-mls-ophyd    \
bact-mls-ophyd            \
bact-bessyii-ophyd        \
lat2db        \
"

. bact_packages_function.sh

for i in $packages
do
    install_python_package_from_github $i
done

pip_install_use_cache bact2_bessyii


packages="bact-bessyii-bluesky"
for i in $packages
do
    echo "Building $i"
    git clone https://github.com/hz-b/$i.git
    cd $i
    # git checkout dev/feature/argparse
    git pull
    if [ -f requirements.txt ] ; then
	# if not available in the directory
	pip_install_use_cache -r requirements.txt
    fi
    # analysis does not properly install data file yet
    # thus use local install
    pip_install_use_cache -e .
    cd ..
done

packages="bact-analysis-bessyii bessyii-dashboard"
for i in $packages
do
    echo "Building $i"
    git clone https://github.com/hz-b/$i.git
    cd $i
    # git checkout dev/feature/machine-deployment
    git pull
    if [ -f requirements.txt ] ; then
	# if not available in the directory
	pip_install_use_cache -r requirements.txt
    fi
    # analysis does not properly install data file yet
    # thus use local install
    pip_install_use_cache -e .
    cd ..
done
