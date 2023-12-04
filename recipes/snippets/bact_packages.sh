packages="bact-math-utils \
bact-device-models        \
bact-analysis             \
bact-bessyii-mls-ophyd    \
bact-mls-ophyd            \
bact-bessyii-ophyd        \
bact2_bessyii             \
"

for i in $packages
do
    echo "Building $i"
    git clone https://github.com/hz-b/$i.git
    cd $i

    if [ -e requirements.txt ] ; then
         pip3 install -r requirements.txt --find-links file:///build/wheels --no-index
    fi
    pip3 install .
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
    if [ -e requirements.txt ] ; then
         pip3 install -r requirements.txt --find-links file:///build/wheels --no-index
    fi
    # analysis does not properly install data file yet
    # thus use local install
    pip3 install -e .
    cd ..
done
