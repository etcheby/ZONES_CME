#!/bin/bash

: '
------- No supported in production -------
Needs to be run in Autoprovision template with "ZONE" as a custom parameter and also 
Rulebase name to install as second Parameter and Name of the GW where we will take the identities
------- No supported in production -------
'

. /var/opt/CPshrd-R80.40/tmp/.CPprofile.sh

AUTOPROV_ACTION=$1
GW_NAME=$2
CUSTOM_PARAMETERS=$3
RULEBASE=$4

if [[ $AUTOPROV_ACTION == delete ]]
then
		exit 0
fi

if [[ $CUSTOM_PARAMETERS != ZONE ]];
then
	exit 0
fi

if [[ $CUSTOM_PARAMETERS == ZONE ]]
then

INSTALL_STATUS=1
POLICY_PACKAGE_NAME=$RULEBASE

echo "Connection to API server"
	SID=$(mgmt_cli -r true login -f json | jq -r '.sid')
	GW_JSON=$(mgmt_cli --session-id $SID show simple-gateway name $GW_NAME -f json)
	GW_UID=$(echo $GW_JSON | jq '.uid')
  GW_ETH0_NAME=$(echo $GW_JSON | jq '.interfaces[0] .name')
  GW_ETH0_ADDRESS=$(echo $GW_JSON | jq '."interfaces"[0] ."ipv4-address"')
  GW_ETH0_MASK=$(echo $GW_JSON | jq '."interfaces"[0] ."ipv4-network-mask"')
  GW_ETH1_NAME=$(echo $GW_JSON | jq '.interfaces[1] .name')
  GW_ETH1_ADDRESS=$(echo $GW_JSON | jq '."interfaces"[1] ."ipv4-address"')
  GW_ETH1_MASK=$(echo $GW_JSON | jq '."interfaces"[1] ."ipv4-network-mask"')
	
echo "adding zones and interfaces"
  mgmt_cli --session-id $SID set simple-gateway uid $GW_UID interfaces.0.name $GW_ETH0_NAME interfaces.0.ipv4-address $GW_ETH0_ADDRESS interfaces.0.ipv4-network-mask $GW_ETH0_MASK interfaces.0.anti-spoofing false interfaces.0.security-zone true interfaces.0.security-zone-settings.specific-zone "ExternalZone" interfaces.0.topology external interfaces.1.name $GW_ETH1_NAME interfaces.1.ipv4-address $GW_ETH1_ADDRESS interfaces.1.ipv4-network-mask $GW_ETH1_MASK interfaces.1.anti-spoofing false interfaces.1.security-zone true interfaces.1.security-zone-settings.specific-zone "InternalZone" interfaces.1.topology internal interfaces.1.topology-settings.ip-address-behind-this-interface "network defined by the interface ip and net mask"

echo "Publishing changes"
  mgmt_cli publish --session-id $SID
		
echo "Install policy"
		until [[ $INSTALL_STATUS != 1 ]]; do
			mgmt_cli --session-id $SID -f json install-policy policy-package $POLICY_PACKAGE_NAME targets $GW_UID
			INSTALL_STATUS=$?
		done
		
echo "Policy Installed" 

        echo "Logging out of session"
        mgmt_cli logout --session-id $SID
			
		exit 0
fi

exit 0
