
Running the twin in containers
==============================

Operating a measurement script
------------------------------

Measurement scripts are provided inside the container `bact-container` .
This container installs all the required packages inside virtual
environment at `/twin/apps/venv`. This environment is automatically
loaded by default. Package repositories are provided for convenience
at ``/twin/code`.

Running an analysis script requires

* a running twin (or access to the `BESSY II`) machine
* a database running containing information of the BESSY II lattice.

Furthermore the catalog should be specified where the data should
be stored. Examples are provided in `catalog_examples.tar.gz`.

Executing steerer response measurement
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Running the script requires some set up so that liveplots can be
displayed using matplotlib.

As first step find out what your numeric user id is by typing

.. code-block:: shell

    id -u


into a shell. The example below is given for a numeric user id of `12345`.

Some parts requires access to some special files and directories.
These we have to `bind` from the host system to the system into
the container. Following binds are made:

* your run user directory (see text after first -B)
* machine id from dbus (see text after second -B)

Furthermore the example below executes the script as stored in
the container itself.

.. code-block:: shell
    :linenos:

    singularity run                                                             \
        -B /run/user/12345/:/run/user/12345/                                    \
        -B /var/lib/dbus/machine-id:/var/lib/dbus/machine-id                    \
            bact-container.sif                                                  \
            /twin/code/bact-bessyii-bluesky/scripts/measure_steerer_response.py \
	        --full-run --catalog-name mongo_in_container

The repositories are available at https://github.com/hz-b/. Furthermore
copies are stored inside the container at `/twin/code`.
