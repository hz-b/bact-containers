Environment variables to define
-------------------------------

* `DT4ACC_PREFIX` prefix to be used by all EPICS variables
* `MONGODB_URL` to define an alternative MONGODDB uri
* `MONGODB_DB` to define an alternative MONGO database name other than bessyii



How to start the twin
-------------------------------------------------------

1. Start mongodb container

Open a terminal and do:

``cd /twin_containers_data/bin``

``apptainer run -B data/db/:/data/db ./mongo-container.sif``

This will start the mongo container and bind the data directory from the outside into the container.

2. Installing/Importing data into the database container from a dump (mongod container should be running)
-------------------------------------------------------

Open a terminal and do:
collection wise:

``mongorestore --port 47017 --db bessyii --collection machines data/to_import/machines.bson``

``mongorestore --port 47017 --db bessyii --collection accelerator.setup data/to_import/accelerator.bson``

``mongorestore --port 47017 --db bessyii --collection bpm.config data/to_import/bpm_config.bson``

``mongorestore --port 47017 --db bessyii --collection bpm.offset data/to_import/bpm_offset.bson``

OR

whole database dump:
mongorestore: the command to restore  the dump (data source)
--port 47017: the port where we set our mongodb for this twin in a container
--db bessyii: name of the database you want to restore
data/to_import/bessyii: the directory where your dump (copy of mongo data) is stored. 

``mongorestore --port 47017 --db bessyii data/to_import/bessyii``


3. Set the twin

First setup the environment variables.
e.g.
You can tell the twin which prefix to use for the PVs. For example, you can name them after yourself. This prefix you will use later in scripts to switch between running on the twin and on the real machine.


``export MONGODB_URL=mongodb://localhost:47017/bessyii``

``export MONGODB_DB=bessyii``

``export DT4ACC_PREFIX=MyTwin``

If ignored Anonym wil be the default prefix, localhost:27017 will be mongo url and port used and bessyii as a database.

4. Start the twin:

``./pyat-as-twin-minimal.sif``

5. Start the twin container on a shell to use it as a client.

``apptainer shell ./pyat-as-twin-softioc.sif``

Enjoy by acceing pvlist

 ``pvlist``

 ``pvlist <list Hash>``

 ``pvget pv_name``

 ``pvput pv_name value``
