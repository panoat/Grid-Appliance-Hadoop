#!/bin/bash

#Time to scan for hadoop nodes in seconds 
TIME_TO_SCAN=30

#Checking if user is hadoopuser 
iam=`whoami`
if [ $iam != "hadoopuser" ]; then
        echo "This script must be run as 'hadoopuser'" 1>&2
        exit 1
fi

echo -ne "Scanning for worker nodes :    "

scan_again=1
while [ $scan_again = 1 ]
do
	scan_again=0
	avahi-browse -arp > /tmp/hadoop_discovery_1 2> /dev/null &
	avahi_pid=`ps -ef| grep "avahi-browse -arp" | grep -v grep| awk {'print $2'}`
	#Display rotating wheel while waiting..
	t1=0
	while [ "$t1" -lt "$TIME_TO_SCAN" ]
	do
		let t1=t1+2
                echo -en "\b\b- "
                sleep 0.5
                echo -en "\b\b\\ "
                sleep 0.5
                echo -en "\b\b| "
                sleep 0.5
                echo -en "\b\b/ "
                sleep 0.5
	done
	echo "kill -9 $avahi_pid" | at now  > /dev/null 2> /dev/null 
	#Check if any service went down while scanning was performed 
	i=0
	total_lines=`cat /tmp/hadoop_discovery_1 | wc -l `
	j=`expr "$total_lines" : '\([0-9]*\)'`
	while [ "$i" -lt "$j" ]
	do
  		let i=i+1
  		first_char=`head -n $i /tmp/hadoop_discovery_1 | tail -n 1| awk -F";" {'print $1'}`
  		if [ "$first_char" != "-" ]; then echo "OK" > /dev/null ;
  		else
   	 		scan_again=1
		 	#One of the serivces got removed while scanning. Hence, rescanning..
 		fi
	done
done

echo ""
#Creating second temp file of all IP addresses found
#Some of these IP addresses might not belong to Hadoop appliances
cat /tmp/hadoop_discovery_1 | grep "=;tapipop;" | grep Workstation| awk -F";" {'print $8'} > /tmp/hadoop_discovery_2

#Checking for Hadoop appliances which have the pre-shared RSA keys and same 'secret word'
rm -f conf/slaves1 
i=0
total_hosts=`cat /tmp/hadoop_discovery_2 | wc -l `
local_md5=`md5sum /home/hadoopuser/.ssh/id_rsa.pub`
j=`expr "$total_hosts" : '\([0-9]*\)'`
while [ "$i" -lt "$j" ]
do
	let i=i+1
	current_host=`head -n $i /tmp/hadoop_discovery_2 | tail -n 1| awk {'print $1'}`
	remote_md5=`ssh -oStrictHostKeyChecking=no -oBatchMode=yes $current_host 'md5sum /home/hadoopuser/.ssh/id_rsa.pub'`
	if [ "$remote_md5" = "$local_md5" ]; then
		echo $current_host >> conf/slaves1 
		echo "Found $current_host"
	else
		#Could not ssh into this server, Hence not including this server in slaves 
		echo "[Not Hadoop Appliance]" > /dev/null
	fi
done

exit 0
