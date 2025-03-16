#!/bin/sh

#Place this script as a cron job and call it according to your preference

#Mailgun API ID
mailgunid=''
#mailgun API link
mailgunapi=''
#Teams channel webhook
teamswebhook=''

#Memory usage calculation
x=$(free -m | awk 'NR==2{printf "Memory Usage - %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
d=$(df -h | awk '$NF=="/"{printf "Disk Usage - %d/%dGB (%s)\n", $3,$2,$5}')
t=$(date)
#Average CPU usage calculation
c=$(sar 1 5 | grep "Average" | sed 's/^.* //')
c=$( printf "%.0f" $c )
val=100
xmod=$(free -m | awk 'NR==2{printf "%.2i", $3*100/$2}')
diff=$((val-c))

#Customer name for the email and message alert
customer=''
check() {

if [ $xmod -ge 94 ]
then
#The command to send an email through mailgun
curl -s  --user $mailgunid $mailgunapi -F from='Company Alerts <alerts@company.com>' -F to=a@a.com -F to=b@a.com -F to=c@a.com -F to=d@a.com -F subject="  $customer  -  $(hostname)   : RAM Spike  " -F text="  $customer  -  $(hostname)   is expected to reboot due to RAM spike. Current RAM is  $xmod %  "
#The command to send a Team channel alert
curl -i --request POST $teamswebhook -d '{"text":" '$customer' : '$(hostname)' is expected to reboot due to RAM spike. Current RAM is '$xmod'%"}'
fi

if [ "$c" -lt 4 ]
then
#The command to send an email through mailgun
curl -s  --user $mailgunid $mailgunapi -F from='Company Alerts <alerts@company.com>' -F to=a@a.com -F to=b@a.com -F to=c@a.com -F to=d@a.com -F subject="  $customer  -  $(hostname)   : CPU Spike  " -F text="  $customer  -  $(hostname)   is expected to reboot due to CPU spike. Current CPU is  $diff %  "
#The command to send a Team channel alert
curl -i --request POST $teamswebhook -d '{"text":" '$customer' : '$(hostname)' is expected to reboot due to CPU spike. Current CPU is '$diff'%"}'
fi

}

check
