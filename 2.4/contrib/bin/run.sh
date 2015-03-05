#!/bin/bash -e

# function usage {
# 	echo "You must specify following environment variables:"
# 	echo "  \$MONGODB_USER"
# 	echo "  \$MMONGODB_PASSWORD"
# 	#echo "  \$MONGODB_DATABASE"
# 	exit 1
# }

# test -z "$MONGODB_USER" && usage
# test -z "$MONGODB_PASSWORD" && usage
# #test -z "$MONGODB_DATABASE" && usage

if [ ! -f /.mongodb_password_set ]; then
	./etc/set_mongodb_password.sh
fi

export mongodb='/usr/bin/mongod --nojournal --auth --httpinterface --rest'

if [ ! -f /data/db/mongod.lock ]; then
    exec $mongodb
else
	export mongodb=$mongodb' --dbpath /data/db' 
    rm /data/db/mongod.lock
    mongod --dbpath /data/db --repair && exec $mongodb
fi