#!/bin/bash

#deploy this on mail node

get_reports() {

ssh host2 '(bash /foo/mail_alerts/gen_reports.sh)' > /foo/mail_alerts/mail.txt
echo >> /foo/mail_alerts/mail.txt

ssh host3 '(bash /foo/mail_alerts/gen_reports.sh)' >> /foo/mail_alerts/mail.txt
echo >> /foo/mail_alerts/mail.txt

bash /foo/mail_alerts/gen_reports.sh >> /foo/mail_alerts/mail.txt
echo >> /foo/mail_alerts/mail.txt


echo "=======================" >> /foo/mail_alerts/mail.txt
echo "Cluster Storage Report" >> /foo/mail_alerts/mail.txt
echo "=======================" >> /foo/mail_alerts/mail.txt
echo "Storage Health: " $( ceph -s | awk "NR==3" ) >> /foo/mail_alerts/mail.txt
echo "Storage Pool Usage" >> /foo/mail_alerts/mail.txt
ceph df | awk "NR<4" >> /foo/mail_alerts/mail.txt
echo >> /foo/mail_alerts/mail.txt

}
get_reports
