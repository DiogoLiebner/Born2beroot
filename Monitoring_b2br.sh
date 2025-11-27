#!/bin/bash

	#echo "Architecture: "
	ARCH=$(uname -a)

	#echo "Number of Physical Processors:"
	NPP=$(lscpu | grep Socket | awk '{print $2}')

	#echo "Number of Virtual Processors:"
	NVP=$(nproc)

	# Display CPU loadRemoved infinite loop and sleep command for monitoring script.
	#echo "CPU load:"
	CPU=$(mpstat | tail -n 1 | awk '{print $4+$6+$7"%"}')

	# Display memory usage
	#echo -e "Memory Usage:"
	RAM=$(free -m | grep Mem | awk '{print $3"/"$2"Mb" "("$3/$2 * 100 "%)"}')

	# Display disk space usage
	#echo -e "Disk Space Usage:"
	FDS=$(df -Bg | grep '^/dev/' | grep -v '/boot' | awk '{ft += $2} END {print ft}')
	UDS=$(df -Bm | grep '^/dev/' | grep -v '/boot' | awk '{ut += $2} END {print ut}')
	PDS=$(df -Bm | grep '^/dev/' | grep -v '/boot' | awk '{ut += $2} {ft+= $3} END {printf("%d"), ut/ft*100}')
	
	# Display last reboot time
	#echo -e "Last boot: "
	LRT=$(last reboot | head -1 | awk '{print $5" "$6" "$7" "$8}')
	
	# Display whether LVM is active or not
	#echo -e "LVM Use: "
	cmd=$(cat /etc/fstab | grep /dev/mapper | wc -l)
	LVM=$(if [ $cmd -eq 0 ]; then echo "no"; else echo "yes"; fi)

	#TCP Connections
	TCP=$(ss -neopt state established | wc -l)

	#echo "Network:"
	IP4=$(hostname -I)
	MAC=$(ip a s | grep ether | awk '{print "("$2")"}')

	#echo "User log:"
	USR=$(users | wc -w)

	#echo "Sudo Count:"
	SUDO=$(grep COMMAND /var/log/sudo/sudo.log | wc -l)
		
	#WALL
	wall	"
			System Monitoring Data

			Architecture:					$ARCH
			Number of Physical Processors:	$NPP
			Number of Virtual Processors:	$NVP
			CPU Load:						$CPU
			Memory Usage:					$RAM
			Disk Space Usage:				$UDS/${FDS}Gb ($PDS%)
			Last Boot:						$LRT
			LVM Use:						$LVM
			Connections TCP:				$TCP ESTABLISHED
			Network:						$IP4 ($MAC)
			User log:						$USR
			Sudo Count:						$SUDO
			"
			
