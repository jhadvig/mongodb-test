#!/bin/bash

# SCL in CentOS/RHEL 7 doesn't support --exec, we need to do it ourselves
source scl_source enable mongodb24
set -e

function usage {
	echo "You must specify following environment variables:"
	echo "  \$MONGODB_USER"
	echo "  \$MONGODB_PASSWORD"
	#echo "  \$MONGODB_DB"
	echo "  \$MONGODB_ADMIN_PASSWORD"
	exit 1
}

function create_mongodb_users {
	mongod -f /opt/openshift/etc/mongodb.conf &

	RET=1
	while [[ RET -ne 0 ]]; do
	    echo "=> Waiting for confirmation of MongoDB service startup"
	    sleep 3
	    mongo admin --eval "help" >/dev/null 2>&1
	    RET=$?
	done

	# Make sure env variables don't propagate to mongod process.
	mongo_user="$MONGODB_USER" ; unset MONGODB_USER
	mongo_pass="$MONGODB_PASSWORD" ; unset MONGODB_PASSWORD
	#mongo_db=${MONGODB_DB:-"production"} ; unset MONGODB_DB


	if [ "$MONGODB_ADMIN_PASSWORD" ]; then
		echo "=> Creating an admin user with a ${MONGODB_ADMIN_PASSWORD} password in MongoDB"
		mongo admin --eval "db.addUser({user: 'admin', pwd: '$MONGODB_ADMIN_PASSWORD', roles: [ 'userAdminAnyDatabase', 'dbAdminAnyDatabase' ]});"
		unset MONGODB_ADMIN_PASSWORD
	fi

	mongo admin --eval "db.addUser({user: '${mongo_user}', pwd: '${mongo_pass}', roles: [ 'readWrite', 'dbAdmin' ]});"
	mongo admin --eval "db.shutdownServer();"
}

test -z "$MONGODB_USER" && usage
test -z "$MONGODB_PASSWORD" && usage


if [ "$MONGODB_USER" -o "$MONGODB_PASSWORD" -o "$MONGODB_ADMIN_PASSWORD" ]; then
	create_mongodb_users
fi

if [ -f /var/lib/mongodb/mongod.lock ]; then
    rm /var/lib/mongodb/mongod.lock
    mongod --dbpath /data/db --repair 
fi

exec mongod -f /opt/openshift/etc/mongodb.conf