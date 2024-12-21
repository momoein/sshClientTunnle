#!/bin/bash


# VPN config
user=""
ipv4=""
ipv6=""
port=""
local_port="3090"


# Initialize variables
gui_mode=0
sshuttle_mode=0
ipv=""
system_proxy_mode=0


usage() {
    echo "Usage: $0 [-g] [-s] [-v ip_version]"
    echo "  [-g | --gui]                      Launch GUI mode"
    echo "  [-v | --ip-version] ip_version    Specify IP version (4 or 6)"
    echo "  [-s | --sshuttle]                 Use sshuttle mode (requires -v)"
    echo "  [-p | --system-proxy]             set system proxy to manual"
}


clean_exit() {
    if [[ system_proxy_mode -eq 1 ]]; then
        gsettings set org.gnome.system.proxy mode 'none'
        system_proxy_mode=0
    fi
    echo "Gracefully shutting down..."
    exit "${1:-0}"  # Exit with the provided code or default to 0
}
# Trap SIGINT (Ctrl+C) and SIGTERM (termination signal) to call the cleanup function
trap clean_exit SIGINT SIGTERM

set_system_proxy() {
    gsettings set org.gnome.system.proxy mode 'manual'
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
        clean_exit 1
    fi

    if [ "$sshuttle_mode" -eq 0 ]; then
        if [ "$ipv" == "4" ]; then
            ssh_v4
        elif [ "$ipv" == "6" ]; then
            ssh_v6
        else
            echo "Error: Invalid IP version! Use 4 or 6."
            clean_exit 1
        fi
    elif [ "$sshuttle_mode" -eq 1 ]; then
        if [ "$ipv" == "4" ]; then
            sshuttle_v4
        elif [ "$ipv" == "6" ]; then
            sshuttle_v6
        else
            echo "Error: Invalid IP version! Use 4 or 6."
            clean_exit 1
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
        clean_exit 1
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


VALID_ARGS=$(getopt -o gsv:ph --long gui,sshuttle,ip-version:,system-proxy,help -- "$@")
if [[ $? -ne 0 ]]; then
    usage
    clean_exit 1
fi

eval set -- "$VALID_ARGS"
while [ $# -gt 0 ]; do
    case "$1" in
        -g | --gui)
            gui_mode=1
            shift
            ;;
        -s | --sshuttle)
            sshuttle_mode=1
            shift
            ;;
        -v | --ip-version)
            ipv=$2
            shift 2
            ;;
        -p | --system-proxy)
            system_proxy_mode=1
            set_system_proxy
            shift
            ;;
        -h | --help)
            usage
            clean_exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid option: $1"
            usage
            clean_exit 1
            ;;
    esac
done



# Logic to handle options
if [ "$gui_mode" -eq 1 ]; then
  launch_gui
else
  start_vpn
fi
