#!/bin/bash

#########################################################################
#                                                                       #
#       Name of Script: network-manager                                 #
#       Author: Yaniv setton                                            #
#       Email: yaniv@cylus.com                                          #
#                                                                       #
#########################################################################

# if temp files found, delete em
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT

# Store menu options selected by the user
INPUT=/tmp/menu.sh.$$

# Storage file for displaying cal and date command output
OUTPUT=/tmp/output.sh.$$

btitle="Cylus managment network interface"
function display_output(){
  local h=${1-20}      # box height default 10
  local w=${2-81}     # box width default 41
  local t=${3-Output}   # box title
  dialog --backtitle "Linux Shell Script" --title "${t}" --clear --msgbox "$(<$OUTPUT)" ${h} ${w}
}

prerequisites()
{
    if [ $USER != 'root' ]
    then
        echo "You need privileges of administrator"
        echo

        exit 1
    fi

    which apt > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        echo "Your operating system is not compatible with this script"
        echo

        exit 2
    fi

    if [ ! -d /etc/netplan/original ]
        then
            mkdir -p /etc/netplan/original
            mv /etc/netplan/*.yaml /etc/netplan/original || mv /etc/netplan/*.yml /etc/netplan/original
    fi
} 

echo_params() #For debug only
{
    echo "$ip, $cidr, $gw, $dns1, $dns2"

}

list_interfaces()
{
    interfaces=$(ls /sys/class/net/)
}

select_interface()
{
    list_interfaces
    interfaceArray=()
        while read name; do
            interfaceArray+=($name "")
    done <<< "$interfaces"

    interface=$(dialog    --stdout \
                          --title "Network Interfaces" \
                          --backtitle "Linux managment network interface" \
                          --ok-label "Next" \
                          --no-cancel \
                          --menu "Select an interface:" \
                          20 30 30 \
                          "${interfaceArray[@]}")
   echo $interface
}

set_ip ()
{
    dialog --title "Network interface $interface config" \
    --backtitle "$btitle" \
    --inputbox "Configure full IP address " 8 60 2>$INPUT

    if test $? -eq 0
    then
        ip=$(<"${INPUT}")
    else
        echo "Error"
    fi
}

set_cidr ()
{
    dialog --title "Network interface $interface config" \
    --backtitle "$btitle" \
    --inputbox "Configure CIDR prefix for example 8, 16, 24 " 8 60 2>$INPUT

    if test $? -eq 0
    then
        cidr=$(<"${INPUT}")
    else
        echo "Error"
    fi
}

set_gw ()
{
    dialog --title "Network interface $interface config" \
    --backtitle "$btitle" \
    --inputbox "Configure Gateway address " 8 60 2>$INPUT

    if test $? -eq 0
    then
        gw=$(<"${INPUT}")
    else
        echo "Error"
    fi
}

set_dns1 ()
{
    dialog --title "Network interface $interface config" \
    --backtitle "$btitle" \
    --inputbox "Configure full DNS-1 address " 8 60 2>$INPUT

    if test $? -eq 0
    then
        dns1=$(<"${INPUT}")
    else
        echo "Error"
    fi
}

set_dns2 ()
{
    dialog --title "Network interface $interface config" \
    --backtitle "$btitle" \
    --inputbox "Configure full DNS-2 address " 8 60 2>$INPUT

    if test $? -eq 0
    then
        dns2=$(<"${INPUT}")
    else
        echo "Error"
    fi
}

create_netplan_config_file()
{
    echo "
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
       dhcp4: no
       dhcp6: no
       addresses: [$ip/$cidr]
       gateway4: $gw
       nameservers:
           addresses: [$dns1,$dns2]" > /etc/netplan/01-netcfg.yaml
    echo
}

apply()
{
    echo -e "Checking for syntax and applying netplan" >$OUTPUT
    display_output 40 120 "Message"
    netplan --debug generate > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        echo
        echo "Error of sintax"
        echo

        exit 4

    else
        echo
            netplan apply

        echo "Done"
    fi

    networkctl status >$OUTPUT
    display_output 40 120 "Message"
    echo -e "Netplan configuration has been apllied successfully, The wizard will exit now." >$OUTPUT
    display_output 40 120 "Message"
}

prerequisites
select_interface
set_ip
set_cidr
set_gw
set_dns1
set_dns2
echo_params
create_netplan_config_file
apply