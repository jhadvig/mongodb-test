FROM centos:centos7

# MongoDB image for OpenShift.
#
# Volumes:
#  * /data/db - Datastore for MongoDB
# Environment:
#  * $MYSQL_USER - Database user name
#  * $MYSQL_PASSWORD - User's password
#  * $MYSQL_DATABASE - Name of the database to create

# Image metadata
ENV MONGODB_VERSION         2.4  
ENV IMAGE_DESCRIPTION       MongoDB 2.4
ENV IMAGE_TAGS              mongodb,mongodb24
ENV IMAGE_EXPOSE_SERVICES   27017:mongodb

MAINTAINER  Jakub Hadvig <jhadvig@redhat.com>
EXPOSE 27017

RUN groupadd -g 184 -o -r mongodb && \
    useradd -M -N -g mongodb -o -r -d /data/db -s /sbin/nologin -c "MongoDB Database Server" -u 184 mongodb

RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum -y --setopt=tsflags=nodocs install \
    https://www.softwarecollections.org/en/scls/rhscl/v8314/epel-7-x86_64/download/rhscl-v8314-epel-7-x86_64.noarch.rpm \
    https://www.softwarecollections.org/en/scls/rhscl/mongodb24/epel-7-x86_64/download/rhscl-mongodb24-epel-7-x86_64.noarch.rpm && \
    yum -y --setopt=tsflags=nodocs install v8314 mongodb24 && \
    yum clean all

COPY mongodb /opt/openshift/
ENV PATH /opt/openshift/bin:$PATH
WORKDIR /opt/openshift

VOLUME ["/data/db"]

ENTRYPOINT ["run.sh"]
