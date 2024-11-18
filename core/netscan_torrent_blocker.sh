#!/bin/bash

# Function to block torrent access
dvhost_block_torrent() {
    echo "Blocking torrent access..."
    iptables -A OUTPUT -p tcp --dport 6881:6889 -j REJECT
    iptables -A OUTPUT -p udp --dport 6881:6889 -j REJECT
    iptables -A OUTPUT -p tcp --dport 6969 -j REJECT
    iptables -A OUTPUT -p udp --dport 6969 -j REJECT
    iptables -A OUTPUT -p udp --dport 4444 -j REJECT
    iptables -A OUTPUT -p udp --dport 8999 -j REJECT
    iptables -A OUTPUT -p udp -m string --string "announce" --algo bm -j REJECT
    iptables -A OUTPUT -p udp --dport 443 -j REJECT
    echo "Torrent access has been blocked completely."
}

# Function to unblock torrent access
dvhost_unblock_torrent() {
    echo "Unblocking torrent access..."
    iptables -D OUTPUT -p tcp --dport 6881:6889 -j REJECT
    iptables -D OUTPUT -p udp --dport 6881:6889 -j REJECT
    iptables -D OUTPUT -p tcp --dport 6969 -j REJECT
    iptables -D OUTPUT -p udp --dport 6969 -j REJECT
    iptables -D OUTPUT -p udp --dport 4444 -j REJECT
    iptables -D OUTPUT -p udp --dport 8999 -j REJECT
    iptables -D OUTPUT -p udp -m string --string "announce" --algo bm -j REJECT
    iptables -D OUTPUT -p udp --dport 443 -j REJECT
    echo "Torrent access has been unblocked."
}

# Function to check the status of torrent blocking
dvhost_torrent_status() {
    echo "Checking Torrent blocking status..."
    status=$(iptables -L OUTPUT -n | grep -E "6881:6889|6969|4444|8999|announce|443" | wc -l)
    if [[ "$status" -gt 0 ]]; then
        echo "Torrent access is BLOCKED."
    else
        echo "Torrent access is OPEN."
    fi
}

# Function to enable NetScan protection
dvhost_enable_netscan_protection() {
    echo "Enabling NetScan protection..."
    iptables -N PORTSCAN
    iptables -A PORTSCAN -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 4 -j RETURN
    iptables -A PORTSCAN -j DROP
    iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -j PORTSCAN
    iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
    echo "NetScan protection is now ENABLED."
}

# Function to disable NetScan protection
dvhost_disable_netscan_protection() {
    echo "Disabling NetScan protection..."
    iptables -D INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -j PORTSCAN
    iptables -F PORTSCAN
    iptables -X PORTSCAN
    iptables -D INPUT -p icmp --icmp-type echo-request -j DROP
    echo "NetScan protection is now DISABLED."
}

# Function to check the status of NetScan protection
dvhost_netscan_status() {
    echo "Checking NetScan protection status..."
    status=$(iptables -L INPUT -n | grep -E "PORTSCAN|icmp" | wc -l)
    if [[ "$status" -gt 0 ]]; then
        echo "NetScan protection is ACTIVE."
    else
        echo "NetScan protection is INACTIVE."
    fi
}

# Main menu
while true; do
    echo ""
    echo "-------- Torrent Management --------"
    echo "1) Block Torrent Access"
    echo "2) Unblock Torrent Access"
    echo "3) Check Torrent Blocking Status"
    echo ""
    echo "-------- NetScan Management --------"
    echo "4) Enable NetScan Protection"
    echo "5) Disable NetScan Protection"
    echo "6) Check NetScan Protection Status"
    echo ""
    echo "-------- General Management --------"
    echo "7) Exit"
    echo ""

    read -p "Choose an option [1-7]: " choice

    case $choice in
        1)
            dvhost_block_torrent
            ;;
        2)
            dvhost_unblock_torrent
            ;;
        3)
            dvhost_torrent_status
            ;;
        4)
            dvhost_enable_netscan_protection
            ;;
        5)
            dvhost_disable_netscan_protection
            ;;
        6)
            dvhost_netscan_status
            ;;
        7)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
