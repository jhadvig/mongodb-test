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

function set_mongodb_password {
	mongod --smallfiles --nojournal &

	#PASS=${MONGODB_PASS:-$(pwgen -s 12 1)}
	PASS="random"
	_word=$( [ ${MONGODB_PASS} ] && echo "preset" || echo "random" )

	RET=1
	while [[ RET -ne 0 ]]; do
	    echo "=> Waiting for confirmation of MongoDB service startup"
	    sleep 5
	    mongo admin --eval "help" >/dev/null 2>&1
	    RET=$?
	done

	echo "=> Creating an admin user with a ${_word} password in MongoDB"
	mongo admin --eval "db.addUser({user: 'admin', pwd: '$PASS', roles: [ 'userAdminAnyDatabase', 'dbAdminAnyDatabase' ]});"
	mongo admin --eval "db.shutdownServer();"

	echo "=> Done!"
	touch /.mongodb_password_set

	echo "========================================================================"
	echo "You can now connect to this MongoDB server using:"
	echo ""
	echo "    mongo admin -u admin -p $PASS --host <host> --port <port>"
	echo ""
	echo "Please remember to change the above password as soon as possible!"
	echo "========================================================================"
}

if [ ! -f /.mongodb_password_set ]; then
	set_mongodb_password
fi

export mongodb='mongod --auth --dbpath /var/lib/mongodb/ --httpinterface --rest'

# SCL in CentOS/RHEL 7 doesn't support --exec, we need to do it ourselves
source scl_source enable mongodb24

# DB dir - /var/lib/mongodb/
if [ ! -f /var/lib/mongodb/mongod.lock ]; then
    exec $mongodb
else
	export mongodb=$mongodb' --dbpath /data/db' 
    rm /data/db/mongod.lock
    mongod --dbpath /var/lib/mongodb/ --repair && exec $mongodb
fi