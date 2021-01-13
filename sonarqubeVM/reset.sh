#!/bin/bash

trace() {
    echo -e "\n>>> $@ ...\n"
}

error() {
    echo "Error: $@" 1>&2
}

# get the default runner script path to execute first before adding custom stuff
SCRIPT="$(find /docker-runner.d -maxdepth 1 -iname "$(basename "$0")")"

if [ ! -z "$ComponentResourceGroup" ]; then
	$(az vm list --subscription $ComponentSubscription -g $ComponentResourceGroup --query "[].name" -o tsv) | while read VMNAME; do

		IDS=$(az vm extension list --subscription $ComponentSubscription -g $ComponentResourceGroup --vm-name $VMNAME --query '[?typePropertiesType == 'CustomScript'].id' -o tsv)
		[ ! -z "$IDS" ] && az vm extension delete --ids ${IDS}

	done
fi

# isolate task script execution in sub shell  
( exec "$SCRIPT"; exit $? ) || exit $?