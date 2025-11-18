#!/bin/bash

	clear
	echo "System Monitoring data:"
	echo "----------------------"

	echo "Architecture: "
	uname -a

	echo "Number of Physical Processors:"
	lscpu | grep Socket | awk '{print $2}'

	echo "Number of Virtual Processors:"
	nproc

	# Display CPU loadRemoved infinite loop and sleep command for monitoring script.
	echo "CPU load:"
	mpstat | tail -n 1 | awk '{print $4+$6"%"}'

	# Display memory usage
	echo -e "Memory Usage:"
	free -m | grep Mem | awk '{print $3"/"$2"Mb" "("$3/$2 * 100 "%)"}'

	# Display disk space usage
	echo -e "Disk Space Usage:"
	df -h

	# Display last reboot time
	echo -e "Last boot: "
	last reboot | head -1 | awk '{print $5" "$6" "$7" "$8}'
	
	# Display whether LVM is active or not
	echo -e "LVM Use: "
	cmd=$(cat /etc/fstab | grep /dev/mapper | wc -l)
	if [ $cmd -gt 0 ]
	then
		echo "yes"
	else
		echo "no"
	fi

	echo "Network:"
	hostname -I
	ip a s | grep ether | awk '{print "("$2")"}'

	echo "User log:"
	users | wc -w

	#sudo command "sudo grep sudo /var/logs/secure
