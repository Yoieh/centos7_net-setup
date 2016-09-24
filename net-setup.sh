#!/usr/bin/env bash

# Import yColor
yColor_tools="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
source ${yColor_tools}"/yColor-tools/test_yColor.sh"

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
		"-d")
			mainArray[DOMAIN]=${arg}
			;;
		"-di")
			mainArray[HOSTS_IPADDRESS]=${arg}
			;;
		"-dh")
			mainArray[HOSTS_HOSTNAME]=${arg}
			;;
		"-da")
			mainArray[HOSTS_ALIAS]=${arg}
			;;
		"-d1")
			mainArray[DNS1]=${arg}
			;;
		"-d2")
			mainArray[DNS2]=${arg}
			;;
		"-h")
			printf "%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s\n" \
				"${yc[YE_B]}" "Help!" \
				"${yc[YE_B]}" "-n  ${yc[RESET]}" "${yc[YE]}" "Set Hostname" \
				"${yc[YE_B]}" "-i  ${yc[RESET]}" "${yc[YE]}" "Set Static IPaddress"\
				"${yc[YE_B]}" "-f  ${yc[RESET]}" "${yc[YE]}" "Set Interface"\
		       	"${yc[YE_B]}" "-g  ${yc[RESET]}" "${yc[YE]}" "Set Gateway"\
				"${yc[YE_B]}" "-d  ${yc[RESET]}" "${yc[YE]}" "Set Domain used in /etc/hosts"\
				"${yc[YE_B]}" "-d1 ${yc[RESET]}" "${yc[YE]}" "Set DNS1"\
				"${yc[YE_B]}" "-d2 ${yc[RESET]}" "${yc[YE]}" "Set DNS2"\
				"${yc[YE_B]}" "-di ${yc[RESET]}" "${yc[YE]}" "Set Ipaddress in hosts"\
				"${yc[YE_B]}" "-dh ${yc[RESET]}" "${yc[YE]}" "Set Hostname in hosts"\
				"${yc[YE_B]}" "-da ${yc[RESET]}" "${yc[YE]}" "Set Alias in hosts"\
				"${yc[RESET]}"
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
		flag_case ${flag}
	fi

	argNum=$(( ${argNum} + 1))
done

# Print all in mainArray
for i in "${!mainArray[@]}"; do
	printf "%s%s%s = %s%s\n%s"\
			"${yc[YE_B]}" "${i}" "${yc[RESET]}${yc[YE]}"\
			"${yc[YE_B]}" "${mainArray[$i]}"\
			"${yc[RESET]}"
done

# Set hostname /etc/hostname
if [ ${mainArray[HOSTNAME]} ]; then
	sudo echo "${mainArray[HOSTNAME]}" > /etc/hostname
	if [ $? -eq 0 ]; then
		printf "%sChanged hostname to:\n %s%s%s\n"\
				"${yc[GR]}"\
				"${yc[GR_B]}" "${mainArray[HOSTNAME]}"\
				"${yc[RESET]}"
	else
		printf "%sError: Cant change hostname!\n Code: %s%s%s"\
				"${yc[RE]}"\
				"${yc[RE_B]}" "$?"\
				"${yc[RESET]}"
	fi
fi


# Add domain to /etc/hosts
if [[ ${mainArray[IPADDRESS]} && ${mainArray[HOSTNAME]} && ${mainArray[DOMAIN]} ]]; then
	hosts="${mainArray[IPADDRESS]} ${mainArray[HOSTNAME]}.${mainArray[DOMAIN]} ${mainArray[HOSTNAME]}"
	sudo echo "${hosts}" >> /etc/hosts
	if [ $? -eq 0 ]; then
		printf "%sHost %s%s%s added to host.%s\n"\
				"${yc[GR]}"\
				"${yc[GR_B]}" "${hosts}" "${yc[RESET]}${yc[GR]}"\
				"${yc[RESET]}"
	fi
elif [[ ${mainArray[HOSTS_IPADDRESS]} && ${mainArray[HOSTS_HOSTNAME]} && ${mainArray[HOSTS_ALIAS]} ]]; then
	hosts="${mainArray[HOSTS_IPADDRESS]} ${mainArray[HOSTS_HOSTNAME]} ${mainArray[HOSTS_ALIAS]}"
	sudo echo "${hosts}" >> /etc/hosts
	if [ $? -eq 0 ]; then
		printf "%sHost %s%s%s added to host.%s\n"\
				"${yc[GR]}"\
				"${yc[GR_B]}" "${hosts}" "${yc[RESET]}${yc[GR]}"\
				"${yc[RESET]}"
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
		printf "%sIP %s%s%s set on interface %s%s%s.%s\n"\
				"${yc[GR]}"\
				"${yc[GR_B]}" "${ipaddress} "${yc[RESET]}${yc[GR]}""\
				"${yc[GR_B]}" "${interface} "${yc[RESET]}${yc[GR]}""\
				"${yc[RESET]}"

		printf "%sGATEWAY %s%s%s set on interface %s%s%s.%s\n"\
				"${yc[GR]}"\
				"${yc[GR_B]}" "${gateway} "${yc[RESET]}${yc[GR]}""\
				"${yc[GR_B]}" "${interface} "${yc[RESET]}${yc[GR]}""\
				"${yc[RESET]}"

		printf "%sDNS1 %s%s%s set on interface %s%s%s.%s\n"\
				"${yc[GR]}"\
				"${yc[GR_B]}" "${dns1} "${yc[RESET]}${yc[GR]}""\
				"${yc[GR_B]}" "${interface} "${yc[RESET]}${yc[GR]}""\
				"${yc[RESET]}"

		printf "%sDNS2 %s%s%s set on interface %s%s%s.%s\n"\
				"${yc[GR]}"\
				"${yc[GR_B]}" "${dns2}" "${yc[RESET]}${yc[GR]}"\
				"${yc[GR_B]}" "${interface}" "${yc[RESET]}${yc[GR]}"\
				"${yc[RESET]}"
	else
		printf "%sError: \nIP %s%s%s on Interface %s%s%s could not be sett. \nCode: %s%s%s\n"\
				"${yc[RE]}"\
				"${yc[RE_B]}" "${ipaddress}" "${yc[RESET]}${yc[RE]}"\
				"${yc[RE_B]}" "${interface}" "${yc[RESET]}${yc[RE]}"\
				"${yc[RE_B]}" "$?"\
				"${yc[RESET]}"
	fi
fi

exit 0
