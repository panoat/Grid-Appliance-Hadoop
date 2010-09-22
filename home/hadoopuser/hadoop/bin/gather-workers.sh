#!/bin/sh

#Checking if user is hadoopuser 
iam=`whoami`
if [ $iam != "hadoopuser" ]; then
    echo "This script must be run as 'hadoopuser'" 1>&2
    exit 1
fi

echo "creating site configuration file"

myhostname=`/bin/hostname`
sed -e s/localhost/$myhostname/ $HADOOP_HOME/conf/core-site-base.xml > $HADOOP_HOME/conf/core-site.xml

$HADOOP_HOME/bin/discover_workers.sh 2> /dev/null 
chmod 700 conf/slaves1
mv conf/slaves1 $HADOOP_HOME/conf/slaves 

echo "copying site configuration file to all workers"

$HADOOP_HOME/bin/scppush.sh $HADOOP_HOME/conf/core-site.xml
