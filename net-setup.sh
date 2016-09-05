#!/usr/bin/env bash

declare -A mainArray

# Case for flags
function flag_case {
	flag=$1
	arg=$2

	case ${flag} in
		"-n")
			mainArray[HOSTNAME]=${arg}	
			;;
		"-i")
			mainArray[IPADDRESS]=${arg}
			;;
		"-f")
			mainArray[INTERFACE]=${arg}
			;;
		"-g")
			mainArray[GATEWAY]=${arg}
			;;
		"-d1")
			mainArray[DNS1]=${arg}
			;;
		"-d2")
			mainArray[DNS2]=${arg}
			;;
		"-h")
			printf "Help!\n -n Set Hostname\n -i Set Static IPaddress\n -f Set Interface\n -g Set gateway\n -d1 Set DNS1\n -d2 Set DNS2"
			exit 0
			;;
	esac
}

# check if is flag or arg
function ifFlagOrArg {
	out=$(( $1 % 2 )) 
	return ${out}
}


# loop for seperating flags from args
argNum=1
for arg in $@; do
	ifFlagOrArg ${argNum}
	out=$?
	
	if [ $out -eq 0 ]; then
		argIn=${arg}
		flag_case ${flag} ${argIn}
	else
		flag=${arg}
	fi

	argNum=$(( ${argNum} + 1))
done

# Print all in mainArray
for i in "${!mainArray[@]}"; do
	printf "%s = %s\n" "${i}" "${mainArray[$i]}"
done


if [ ${mainArray[HOSTNAME]} ]; then
	sudo echo "${mainArray[HOSTNAME]}" > /etc/hostname 
	if [ $? -eq 0 ]; then
		printf "Changed hostname to: %s\n" "${mainArray[HOSTNAME]}"	
	else
		printf "Error: Cant change hostname! Code:%s" "$?"
	fi
fi

# If ip set whe have to build the interface file.
if [ ${mainArray[IPADDRESS]} ]; then
	ipaddress=${mainArray[IPADDRESS]}
	
	if [ ${mainArray[INTERFACE]} ]; then
		interface=${mainArray[INTERFACE]}
	else
		interface=eth0
	fi
	
	if [ ${mainArray[GATEWAY]} ]; then
		gateway=${mainArray[GATEWAY]}
	else
		baseip=$(echo $ipaddress | cut -d"." -f1-3)
		gateway="${baseip}.1"
	fi
	
	if [ ${mainArray[DNS1]} ]; then
		dns1=${mainArray[DNS1]}
	else
		dns1="8.8.8.8"
	fi
	
	if [ ${mainArray[DNS2]} ]; then
		dns2=${mainArray[DNS2]}
	else
		dns2="8.8.4.4"
	fi

	sudo printf "TYPE=Ethernet\nBOOTPROTO=static\nGATEWAY=%s\nIPADDR=%s\nNETMASK=255.255.255.0\nDEVICE=%s\nONBOOT=yes\nDNS1=%s\nDNS2=%s\n" "${gateway}" "${ipaddress}" "${interface}" "${dns1}" "${dns2}" > /etc/sysconfig/network-scripts/ifcfg-${interface}
	if [ $? -eq 0 ]; then
		printf "IP %s set on interface %s.\n" "${ipaddress}" "${interface}"
		printf "GATEWAY %s set on interface %s.\n" "${gateway}" "${interface}"
		printf "DNS1 %s set on interface %s.\n" "${dns1}" "${interface}"
		printf "DNS2 %s set on interface %s.\n" "${dns2}" "${interface}"
	else
		printf "Error: IP %s on Interface %s could not be sett. Code: %s.\n" "${ipaddress}" "${interface}" "$?"
	fi
fi

printf "\n\nHelp!\n -n Set Hostname\n -i Set Static IPaddress\n -f Set Interface\n -g Set Gateway\n -d1 Set DNS1\n -d2 Set DNS2\n"

exit 0
