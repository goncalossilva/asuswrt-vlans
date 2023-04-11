#!/bin/sh

# 0. Docs
#
# $ brctl show
#
# Check bridges in the Linux kernel.
#
# 'vlan1' is a set of switch ports (ports 0 1 2 3 4 5)
# 'eth1' is 2.4GHz primary network
# 'eth2' is 5GHz primary network
# 'wl0.1' is 2.4GHz guest network 1, etc
# 'wl1.2' is 5GHz guest network 2, etc
#
# ---
# $ robocfg show
#
# Check switch ports (native broadcom, not on Linux kernel).
#
# WAN port is port 0
# LAN ports 1-4 are 1-4
# CPU port (i.e., port to Linux kernel) is port 8

configure_vlans_on_switch_ports() {
    robocfg vlans reset
    robocfg vlan 1 ports "0t 1t 2t 3t 4 8t"
    robocfg vlan 10 ports "0t 8t"
    robocfg vlan 20 ports "0t 1 2 3 8t" # Ryzen is on port 4, default to IoT for everything else
    robocfg vlan 30 ports "0t 8t" 
}

add_vlans_to_eth0() {
    vconfig add eth0 10
    vconfig add eth0 20
    vconfig add eth0 30
}

bring_vlans_up() {
    ifconfig vlan10 up
    ifconfig vlan20 up
    ifconfig vlan30 up
}

remove_guest_wifis_from_br0() {
    brctl delif br0 wl0.1
    brctl delif br0 wl1.1
    brctl delif br0 wl0.2
    brctl delif br0 wl1.2
    brctl delif br0 wl0.3
    brctl delif br0 wl1.3
}

add_linux_network_bridges() {
    brctl addbr br10
    brctl addbr br20
    brctl addbr br30
}

add_guest_wifis_to_network_bridges() {
    brctl addif br10 wl0.1
    brctl addif br10 wl1.1
    brctl addif br20 wl0.2
    brctl addif br20 wl1.2
    brctl addif br30 wl0.3
    brctl addif br30 wl1.3
}

add_interfaces_to_linux_network_bridges() {
    brctl addif br10 vlan10
    brctl addif br20 vlan20
    brctl addif br30 vlan30
}

bring_network_bridges_up() {
    ifconfig br10 up
    ifconfig br20 up
    ifconfig br30 up
}

update_nvram() {
    nvram set lan_ifname="br0"
    nvram set lan_ifnames="vlan1 eth1 eth2"
    nvram set br0_ifname="br0"
    nvram set br0_ifnames="vlan1 eth1 eth2"

    nvram set lan1_ifname="br10"
    nvram set lan1_ifnames="vlan10 wl0.1 wl1.1"
    nvram set br10_ifname="br10"
    nvram set br10_ifnames="vlan10 wl0.1 wl1.1"

    nvram set lan2_ifname="br20"
    nvram set lan2_ifnames="vlan20 wl0.2 wl1.2"
    nvram set br20_ifname="br20"
    nvram set br20_ifnames="vlan20 wl0.2 wl1.2"

    nvram set lan3_ifname="br30"
    nvram set lan3_ifnames="vlan30 wl0.3 wl1.3"
    nvram set br30_ifname="br30"
    nvram set br30_ifnames="vlan30 wl0.3 wl1.3"
}

restart_eapd() {
    killall eapd
    eapd
}

flush_ebtables() {
    ebtables -F
}

restart_http_gui() {
    service restart_httpd
}
