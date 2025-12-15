#!/bin/bash 

#function based approach
#getall_warnings() - takes care of the warning messages
#get_status - responsible for getting server level Details
#get_instance - responsible for showing consolidated instance level Details
#get_network - does ping test and sends the report of packet drops

Last_Node="Yes" #Yes or No based on the factor

#Installation info:
#Deploy gen_reports.sh on /foo/build/alert_reports on all the nodes in the cluster
#Deploy sendmail.sh on /foo/build/alert_reports on the node that is responsible for sending the email
#Add a cron entry to run sendmail.sh
#Please be sure before altering anything in gen_reports.sh


getall_warnings() {
	up=$(uptime | grep -io day)
	total_ram=$(free -h | awk 'NR==2{print $2}' | cut -d 'G' -f1) #if Total RAM is in GB then total_ram=$(free -h | awk 'NR==2{print $2}' | cut -d 'G' -f1) and convert TB to GB using holding_var=1024; total_ram=$(echo $total_ram $holding_var | awk '{printf "%4.3f\n",$1*$2}' ) also change the if condition for ram compare as if (( $(echo "$used_ram > $total_ram" |bc -l) ))
	#holding_var=1024
	#total_ram=$(echo $total_ram $holding_var | awk '{printf "%4.3f\n",$1*$2}')
	used_ram=$(free -h | awk 'NR==2{print $3}' | cut -d 'G' -f1)
	avcpu=$(virsh list | awk '{print $1}' | grep -oIE "[0-9]*" | while read word; do virsh dominfo ${word} | grep "CPU.s"; done | awk 'BEGIN {a=0;} {a=a+$2;} END {print a;}')
	ce=$(lscpu | grep "Core(s)" | grep -o '[0-9]\+')
	se=$(lscpu | grep "Socket" | grep -o '[0-9]\+')
	te=$((ce*se))
	ve=4
	tvcpu=$((te*ve))
	hostname=$(hostname)

	if [ $up == 'day' ] 
	then
		sleep 1
	else
		echo "Warning: A reboot was detected on" $hostname "within the last 24 hours"
	fi
	
	if [ $used_ram -gt $total_ram ] #use this if total ram is in gb
	#if (( $(echo "$used_ram > $total_ram" |bc -l) ))  use this if total ram is in tb
	then
		echo "Warning: Ram on "$hostname" has been overprovisioned"
	fi
	
	if [ $avcpu -gt $tvcpu ]
	then
		echo "Warning: VCPUs on" $hostname "has been overprovisioned"
	fi
}
get_status() {
	hostname=$(hostname)
	uptime=$(uptime | awk '{printf "Server Uptime: %s %s", $3+1, $4}' | cut -d ',' -f1)
	ram=$(free -h | awk 'NR==2{printf "Used RAM: %sB/%sB" , $3,$2 }')
        rootpart=$(df -Ph / | awk 'NR == 2{print $5+0}')
	cpu=$(sar 1 5 | grep "Average" | sed 's/^.* //')
	cpu=$(printf "%.0f" $cpu )
	val=100
	diff=$((val-cpu))
	date=$(date | awk '{print $4}')	
	echo	
	echo "=========================="
	echo "Server Status -" $hostname 
	echo "=========================="	
	echo $uptime
	echo $ram
        echo "Root Partition Utilised: " $rootpart"%"
	echo "Used CPU:" $diff"%"

}

get_instance() {
	
	total=$(virsh list --all | awk 'NR>3' |wc -l)
	running=$(virsh list --all |grep -i running |wc -l)	
	shut=$(virsh list --all | grep -i shut |wc -l)
	allocvcpu=$(virsh list | awk '{print $1}' | grep -oIE "[0-9]*" | while read word; do virsh dominfo ${word} | grep "CPU.s"; done | awk 'BEGIN {a=0;} {a=a+$2;} END {print a;}')
	cores=$(lscpu | grep "Core(s)" | grep -o '[0-9]\+')
	sockets=$(lscpu | grep "Socket" | grep -o '[0-9]\+')
	t=$((cores*sockets))
	v=4
	totalvcpu=$((t*v))
		
	echo 	
	echo "====================================="
	echo "Instance Details - Server:" $hostname
	echo "====================================="
	echo "Total instances:" $total
	echo "Running instances:" $running
	echo "Powered off instances:" $shut  
	echo "Total VCPUs:" $totalvcpu
	echo "Allocated VCPUs:" $allocvcpu
	echo 
}

get_network() {
	echo "====================================="
	echo "Network Details - Server:" $hostname
	echo "====================================="
	gateway=$(ip route | awk '$1=="default"{print $3; exit}')
	ping $gateway -c 5 > iptest.txt
	cat iptest.txt | grep -i "packet loss"
	drop=$(cat iptest.txt | grep -i "packet loss" | awk '{print $6}' | cut -d '%' -f1)

	if [ $drop -gt 0 ]
	then
		echo $drop"% packet loss has been observed when pinged to the gateway("$gateway")"
	else
		echo $drop"% packet loss has been observed when pinged to the gateway("$gateway")"
	fi
	echo
}

footer() {
	echo $Original_Author "Reports"
}

write_footer() {
	if [ $Last_Node = "Yes" ]
	then
		footer
	fi
}
getall_warnings
get_status
get_instance
get_network
write_footer

