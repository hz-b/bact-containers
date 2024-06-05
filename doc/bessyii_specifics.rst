Environment variables to define
-------------------------------

* `DT4ACC`


Installing data into the database container from a dump
-------------------------------------------------------

mongorestore --port 47017 --db bessyii --collection machines data/to_import/machines.bson
