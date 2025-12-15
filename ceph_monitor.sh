customer='<>'
ceph -s | grep -E 'full|down'
if [ $? -eq 0 ]
then
  a=`ceph -s`
  MAILBODY="Storage Alert in <> Cluster\n $a "
  curl -s --user 'api:<id>' https://<link>/messages -F from='<> Alerts <alerts@enclouden.com>' -F to=<receiver-email-id> -F subject="$customer : $(hostname) - Cluster's Ceph Alert" -F text="$MAILBODY"

  curl -i --request POST '<microsoft-teams-channel-api>' -d '{"text":"  '$customer' - Ceph OSD Down/Full"}'

fi
