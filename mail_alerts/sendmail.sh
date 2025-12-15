#!/bin/bash

send_mail() {
        sh /foo/mail_alerts/collect.sh
        counter=$(cat /foo/mail_alerts/mail.txt | grep -i "warning" | wc -l)
        threshold=0
	MAILBODY=$(cat /foo/mail_alerts/mail.txt)
        if [ $counter -gt $threshold ]
        then
	        curl -s --user 'api:<id>' https://<link>/messages -F from='<Company> Alerts <alert-email-id>' -F to=<receiver-email-id> -F subject='<Customer Name> - Cluster Health Report ('$counter' warnings)' -F text="$MAILBODY"
        else
		curl -s --user 'api:<id>' https://<link>/messages -F from='<Company> Alerts <alert-email-id>' -F to=<receiver-email-id> -F subject='<Customer Name> - Cluster Health Report' -F text="$MAILBODY"
        fi
}
send_mail

