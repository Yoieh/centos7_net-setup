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
		"-d1")
			mainArray[DNS1]=${arg}
			;;
		"-d2")
			mainArray[DNS2]=${arg}
			;;
		"-h")
			printf "%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\ns%s%s%s\n%s\n" \
				"${yc[YE_B]}" "Help!" \
				"${yc[YE_B]}" "-n  " "${yc[YE]}" "Set Hostname" \
				"${yc[YE_B]}" "-i  " "${yc[YE]}" "Set Static IPaddress"\
				"${yc[YE_B]}" "-f  " "${yc[YE]}" "Set Interface"\
		       	"${yc[YE_B]}" "-g  " "${yc[YE]}" "Set gateway"\
				"${yc[YE_B]}" "-d1 " "${yc[YE]}" "Set DNS1"\
				"${yc[YE_B]}" "-d2 " "${yc[YE]}" "Set DNS2"\
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
	fi

	argNum=$(( ${argNum} + 1))
done

# Print all in mainArray
for i in "${!mainArray[@]}"; do
	printf "%s%s%s = %s%s\n%s"\
			"${yc[YE_B]}" "${i}" "${yc[YE]}"\
			"${yc[YE_B]}" "${mainArray[$i]}"\
			"${yc[RESET]}"
done


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
				"${yc[GR_B]}" "${ipaddress} "${yc[GR]}""\
				"${yc[GR_B]}" "${interface} "${yc[GR]}""\
				"${yc[RESET]}"

		printf "%sGATEWAY %s%s%s set on interface %s%s%s.%s\n"\
				"${yc[GR]}"\
				"${yc[GR_B]}" "${gateway} "${yc[GR]}""\
				"${yc[GR_B]}" "${interface} "${yc[GR]}""\
				"${yc[RESET]}"

		printf "%sDNS1 %s%s%s set on interface %s%s%s.%s\n"\
				"${yc[GR]}"\
				"${yc[GR_B]}" "${dns1} "${yc[GR]}""\
				"${yc[GR_B]}" "${interface} "${yc[GR]}""\
				"${yc[RESET]}"

		printf "%sDNS2 %s%s%s set on interface %s%s%s.%s\n"\
				"${yc[GR]}"\
				"${yc[GR_B]}" "${dns2}" "${yc[GR]}"\
				"${yc[GR_B]}" "${interface}" "${yc[GR]}"\
				"${yc[RESET]}"
	else
		printf "%sError: \nIP %s%s%s on Interface %s%s%s could not be sett. \nCode: %s%s%s\n"\
				"${yc[RE]}"\
				"${yc[RE_B]}" "${ipaddress}" "${yc[RESET]}"\
				"${yc[RE_B]}" "${interface}" "${yc[RESET]}"\
				"${yc[RE_B]}" "$?"\
				"${yc[RESET]}"
	fi
fi

printf "\n\n\n"
printf "%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s%s%s%s\n%s\n"\
		"${yc[YE_B]}" "Help!" \
		"${yc[YE_B]}" "-n  " "${yc[YE]}" "Set Hostname" \
		"${yc[YE_B]}" "-i  " "${yc[YE]}" "Set Static IPaddress"\
		"${yc[YE_B]}" "-f  " "${yc[YE]}" "Set Interface"\
	   	"${yc[YE_B]}" "-g  " "${yc[YE]}" "Set gateway"\
		"${yc[YE_B]}" "-d1 " "${yc[YE]}" "Set DNS1"\
		"${yc[YE_B]}" "-d2 " "${yc[YE]}" "Set DNS2"\
		"${yc[RESET]}"

exit 0
