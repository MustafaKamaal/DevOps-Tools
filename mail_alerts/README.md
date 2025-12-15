Clone this repository
Keep all the 3 files in the node you want the script to be executed.
Copy the gen_report.sh file to all the other nodes at the location "/foo/mail_alerts/".
Check the "free -h" output to check the RAM is in GB or TB. If in TB edit the respective gen_report.sh file as mentioned in the file.
Edit the variable "last node" in gen_report.sh to "yes" if its the last node in the script execution.
In the main node, edit the collect.sh with the hostnames of the nodes. Run the collect.sh file and check if all the details are correctly appearing in mail.txt
Edit the sendmail.sh file with the required mails of customer.
Make the crontab entry in the main node.(The node with all the 3 files)

crontab -e

00 21 * * * bash /foo/mail_alerts/sendmail.sh    (send mail at 21:00 daily)
