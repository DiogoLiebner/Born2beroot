#!/bin/bash

while true; do
	clear
	echo "System Monitoring data:"
	echo "----------------------"

	echo "Architecture: "
	uname -a

	echo "Number of Physical Processors:"
	nproc

	# Display CPU load
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
	#lvmdisplay #or lvs

	#shell01 from piscine for IP and MAC address

	#sudo command "sudo grep sudo /var/logs/secure"


	sleep 6000
done
