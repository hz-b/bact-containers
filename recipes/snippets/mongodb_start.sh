#!/bin/sh

echo "This is a read only test installation. It is currently neither"
echo "mapping data in not storing it. Consider to install your local"
echo "instance for production use"

# Stops the daemon if it is already running
mongod --repair

# Starts the daemon
echo -n "Starting mongo database daemon at port $PORT... "

mongod --port $PORT &

echo "done"
# Starts the mongo shell in the hostname and port set from environment
# echo "Starting mongo shell connected to $HOSTNAME:$PORT "
# mongosh --host $HOSTNAME:$PORT

# start a shell so that we stay active and user can inspect what
# is happening
/bin/bash
