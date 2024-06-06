Environment variables to define
-------------------------------

* `DT4ACC_PREFIX` prefix to be used by all EPICS variables
* `MONGODB_URL` to define an alternative MONGODDB uri


Installing data into the database container from a dump
-------------------------------------------------------

mongorestore --port 47017 --db bessyii --collection machines data/to_import/machines.bson


How to start the twin
-------------------------------------------------------

1. Start mongodb container

Open a terminal and do:

``cd /twin_containers_data/bin``

``apptainer run -B data/db/:/data/db ./mongo-container.sif``

This will start the mongo container and bind the data directory from the outside into the container.

2. Add machine data to the database (only required to do once)

Open new terminal and do:

``mongorestore --port 47017 --db bessyii --collection machines data/to_import/machines.bson``

This will import the data for BESSY II into the database.

3. Start the twin

First setup the environment variable to tell the twin which database to use.

``export MONGODB_URL=mongodb://localhost:47017/bessyii``

Then you need to tell the twin which prefix to use for the PVs. For example, you can name them after yourself. This prefix you will use later in scripts to switch between running on the twin and on the real machine.

``export DT4ACC_PREFIX="Pierre:DT"``

Start the twin:

``./pyat-as-twin-minimal.sif``
