#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
else
	if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
		echo "usage: "
    echo "./`basename "$0"` [luks_file] [passphrase_file]"
	else
		luks_file=$1
		passphrase_file=$2
		for passphrase in  $(cat $passphrase_file)
		do
			printf "$passphrase" | cryptsetup luksOpen --test-passphrase $luks_file  && echo -ne "There is a key available with this passphrase. $passphrase \n" && exit 0
		done
	fi
fi

