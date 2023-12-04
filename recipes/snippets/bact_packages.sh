packages="bact-math-utils \
bact-device-models        \
bact-analysis             \
bact-bessyii-mls-ophyd    \
bact-mls-ophyd            \
bact-bessyii-ophyd        \
bact2_bessyii             \
"

WHEELS_DIR_DEFAULT=file:///build/wheels
WHEELS_DIR="$WHEELS_DIR_DEFAULT"

pip_install_use_cache ()
{
    local status=-1
    
    echo "pip install: with cache $WHEELS_DIR using args " $@
    if python3 -m pip install --find-links "$WHEELS_DIR" --no-index --check-build-dependencies $@
    then
	status=$?
	echo "pip install used wheel dir $WHEELS_DIR"
    else
	echo "pip install used wheel dir $WHEELS_DIR returned status $?, continuing without dir" 	
	python3 -m pip install $@
	status=$?
    fi
    return $status
}


for i in $packages
do
    echo "Building $i"
    git clone https://github.com/hz-b/$i.git
    cd $i

    if [ -f requirements.txt ] ; then
	# if not available in the directory
	pip_install_use_cache -r requirements.txt
    fi
    pip_install_use_cache . 
    cd ..
done

packages="bact-bessyii-bluesky bact-analysis-bessyii bessyii-dashboard"
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
