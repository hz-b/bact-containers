WHEELS_DIR_DEFAULT=file:///build/wheels
WHEELS_DIR="$WHEELS_DIR_DEFAULT"

pip_install_use_cache ()
{
    local status=-1

    echo "pip install: with cache $WHEELS_DIR using args " $@
    if python3 -m pip install -q --progress-bar=off --find-links "$WHEELS_DIR" --no-index --check-build-dependencies $@
    then
	status=$?
	echo "pip install used wheel dir $WHEELS_DIR"
    else
	echo '# ----------------------------------------------------------------------'
	echo "pip install used wheel dir $WHEELS_DIR returned status $?, continuing without dir"
	echo '# ----------------------------------------------------------------------'
	python3 -m pip install -q --progress-bar=off $@
	status=$?
    fi
    return $status
}


install_python_package_from_github ()
{
    package="$1"
    echo "Building $package"
    git clone "https://github.com/hz-b/$package.git"
    cd "$package"
    git pull
    if [ -f requirements.txt ] ; then
	# if not available in the directory
	pip_install_use_cache -r requirements.txt
    fi
    # analysis does not properly install data file yet
    # thus use local install
    pip_install_use_cache  .
    cd ..

}
