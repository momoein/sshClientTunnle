#!/bin/bash


# VPN config
user=""
ipv4=""
ipv6=""
port=""
local_port=""


# Initialize variables
gui_mode=0
sshuttle_mode=0
ipv=""


usage() {
    echo "Usage: $0 [-g] [-s] [-v ip_version]"
    echo "  -g                Launch GUI mode"
    echo "  -v ip_version     Specify VPN server ip/address version (4 or 6)"
    echo "  -s                sshuttle (requires -v)"
    exit 1
}


ssh_v4() {
    while true; do
        echo "Connecting to $ipv4 via SSH..."
        ssh $user@$ipv4 -p $port -D $local_port -N
        echo "Disconnected. Reconnecting..."
        sleep 2
    done
}

ssh_v6() {
    while true; do
        echo "Connecting to $ipv6 via SSH..."
        ssh $user@$ipv6 -p $port -D $local_port -N
        echo "Disconnected. Reconnecting..."
        sleep 2
    done
}

sshuttle_v4() {
    echo "Connecting to $ipv4 via sshuttle..."
    sshuttle --dns --no-latency-control -r $user@$ipv4:$port 0/0 -x $ipv4:$port
}

sshuttle_v6() {
    echo "Connecting to $ipv6 via sshuttle..."
    sshuttle --dns --no-latency-control -r $user@$ipv6:$port 0/0
}

# Function to start the VPN
start_vpn() {

    if [ -z "$ipv" ]; then
        echo "Error: IP version is required!"
        usage
    fi

    if [ "$sshuttle_mode" -eq 0 ]; then
        if [ "$ipv" == "4" ]; then
            ssh_v4
        elif [ "$ipv" == "6" ]; then
            ssh_v6
        else
            echo "Error: Invalid IP version! Use 4 or 6."
            exit 1
        fi
    elif [ "$sshuttle_mode" -eq 1 ]; then
        if [ "$ipv" == "4" ]; then
            sshuttle_v4
        elif [ "$ipv" == "6" ]; then
            sshuttle_v6
        else
            echo "Error: Invalid IP version! Use 4 or 6."
            exit 1
        fi
    fi
}


# Function to launch the GUI
launch_gui() {

    action=$(zenity --list --title="VPN Control" \
        --column="Action" \
        "SSH IPv4" \
        "SSH IPv6" \
        "sshuttle IPv4" \
        "sshuttle IPv6" \
        --height=250 --width=300)

    if [ -z "$action" ]; then
        zenity --error --text="No action selected. Exiting."
        exit 1
    fi

    case "$action" in
        "SSH IPv4")
            ssh_v4
            ;;
        "SSH IPv6")
            ssh_v6
            ;;
        "sshuttle IPv4")
            sshuttle_v4
            ;;
        "sshuttle IPv6")
            sshuttle_v6
            ;;
        *)
            zenity --error --text="Invalid action selected."
            ;;
    esac

}


# Parse options using getopts
while getopts ":gsv:" opt; do
  case $opt in
    g)  # Enable GUI mode
        gui_mode=1
        ;;
    v)  # Ip Version
        ipv=$OPTARG
        ;;
    s)  # sshuttle
        sshuttle_mode=1
        ;;
    \?) # Invalid option
        echo "Invalid option: -$OPTARG" >&2
        usage
        ;;
    :)  # Missing argument for an option
        echo "Option -$OPTARG requires an argument." >&2
        usage
        ;;
  esac
done

# Logic to handle options
if [ "$gui_mode" -eq 1 ]; then
  launch_gui
elif [ "$gui_mode" -eq 0 ]; then
  start_vpn
else
  usage
fi
