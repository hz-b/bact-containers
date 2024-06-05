Environment variables to define
-------------------------------

* `DT4ACC_PREFIX` prefix to be used by all EPICS variables
* `MONGODB_URL` to define an alternative MONGODDB uri


Installing data into the database container from a dump
-------------------------------------------------------

mongorestore --port 47017 --db bessyii --collection machines data/to_import/machines.bson
