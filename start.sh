#!/bin/bash

create_ns () {
    ip netns add mon
    ip netns add con
    ip netns add rt0
    ip netns add rt1
    ip netns add rt2
    ip netns add user
}

attach_link () {
    ip link add name mon-con type veth peer name con-mon
    ip link add name con-rt0 type veth peer name rt0-con
    ip link add name rt0-rt1 type veth peer name rt1-rt0
    ip link add name rt0-rt2 type veth peer name rt2-rt0
    ip link add name rt1-user type veth peer name user-rt1
    ip link add name rt2-user type veth peer name user-rt2

    ip link set mon-con netns mon
    ip link set con-mon netns con
    ip link set con-rt0 netns con
    ip link set rt0-con netns rt0
    ip link set rt0-rt1 netns rt0
    ip link set rt0-rt2 netns rt0
    ip link set rt1-rt0 netns rt1
    ip link set rt1-user netns rt1
    ip link set rt2-rt0 netns rt2
    ip link set rt2-user netns rt2
    ip link set user-rt1 netns user
    ip link set user-rt2 netns user
}


connect_int () {
    ip netns exec mon ip a add 2001:db8:0:1::2/64 dev mon-con

    ip netns exec con ip a add 2001:db8:0:1::1/64 dev con-mon
    ip netns exec con ip a add 2001:db8:0:7::2/64 dev con-rt0

    ip netns exec rt0 ip a add 2001:db8:0:7::1/64 dev rt0-con
    ip netns exec rt0 ip a add 2001:db8:0:2::2/64 dev rt0-rt1
    ip netns exec rt0 ip a add 2001:db8:0:3::2/64 dev rt0-rt2

    ip netns exec rt1 ip a add 2001:db8:0:2::1/64 dev rt1-rt0
    ip netns exec rt1 ip a add 2001:db8:0:4::1/64 dev rt1-user

    ip netns exec rt2 ip a add 2001:db8:0:3::1/64 dev rt2-rt0
    ip netns exec rt2 ip a add 2001:db8:0:5::1/64 dev rt2-user

    ip netns exec user ip a add 2001:db8:0:4::2/64 dev user-rt1
    ip netns exec user ip a add 2001:db8:0:5::2/64 dev user-rt2
    ip netns exec user ip a add 2001:db8:0:6::1/128 dev lo
}


linkup_interface () {
    ip netns exec mon ip link set mon-con up
    ip netns exec con ip link set con-mon up
    ip netns exec con ip link set con-rt0 up
    ip netns exec rt0 ip link set rt0-con up
    ip netns exec rt0 ip link set rt0-rt1 up
    ip netns exec rt0 ip link set rt0-rt2 up
    ip netns exec rt1 ip link set rt1-rt0 up
    ip netns exec rt1 ip link set rt1-user up
    ip netns exec rt2 ip link set rt2-rt0 up
    ip netns exec rt2 ip link set rt2-user up
    ip netns exec user ip link set user-rt1 up
    ip netns exec user ip link set user-rt2 up
    ip netns exec user ip link set lo up
}

set_kernel_params () {
    sysctl -w net.ipv6.conf.all.forwarding=1
    sysctl -w net.ipv6.conf.def-mon.forwarding=1
    sysctl -w net.ipv6.conf.all.seg6_enabled=1
    sysctl -w net.ipv6.conf.lo.seg6_enabled=1
    sysctl -w net.ipv6.conf.def-mon.seg6_enabled=1

    ip netns exec mon sysctl -w net.ipv6.conf.all.forwarding=1
    ip netns exec mon sysctl -w net.ipv6.conf.lo.forwarding=1
    ip netns exec mon sysctl -w net.ipv6.conf.mon-con.forwarding=1
    ip netns exec mon sysctl -w net.ipv6.conf.all.seg6_enabled=1
    ip netns exec mon sysctl -w net.ipv6.conf.lo.seg6_enabled=1
    ip netns exec mon sysctl -w net.ipv6.conf.mon-con.seg6_enabled=1

    ip netns exec con sysctl -w net.ipv6.conf.all.forwarding=1
    ip netns exec con sysctl -w net.ipv6.conf.lo.forwarding=1
    ip netns exec con sysctl -w net.ipv6.conf.con-mon.forwarding=1
    ip netns exec con sysctl -w net.ipv6.conf.con-rt0.forwarding=1
    ip netns exec con sysctl -w net.ipv6.conf.all.seg6_enabled=1
    ip netns exec con sysctl -w net.ipv6.conf.lo.seg6_enabled=1
    ip netns exec con sysctl -w net.ipv6.conf.con-mon.seg6_enabled=1
    ip netns exec con sysctl -w net.ipv6.conf.con-rt0.seg6_enabled=1

    ip netns exec rt0 sysctl -w net.ipv6.conf.all.forwarding=1
    ip netns exec rt0 sysctl -w net.ipv6.conf.lo.forwarding=1
    ip netns exec rt0 sysctl -w net.ipv6.conf.rt0-con.forwarding=1
    ip netns exec rt0 sysctl -w net.ipv6.conf.rt0-rt1.forwarding=1
    ip netns exec rt0 sysctl -w net.ipv6.conf.rt0-rt2.forwarding=1
    ip netns exec rt0 sysctl -w net.ipv6.conf.all.seg6_enabled=1
    ip netns exec rt0 sysctl -w net.ipv6.conf.lo.seg6_enabled=1
    ip netns exec rt0 sysctl -w net.ipv6.conf.rt0-con.seg6_enabled=1
    ip netns exec rt0 sysctl -w net.ipv6.conf.rt0-rt1.seg6_enabled=1
    ip netns exec rt0 sysctl -w net.ipv6.conf.rt0-rt2.seg6_enabled=1

    ip netns exec rt1 sysctl -w net.ipv6.conf.all.forwarding=1
    ip netns exec rt1 sysctl -w net.ipv6.conf.lo.forwarding=1
    ip netns exec rt1 sysctl -w net.ipv6.conf.rt1-rt0.forwarding=1
    ip netns exec rt1 sysctl -w net.ipv6.conf.rt1-user.forwarding=1
    ip netns exec rt1 sysctl -w net.ipv6.conf.all.seg6_enabled=1
    ip netns exec rt1 sysctl -w net.ipv6.conf.lo.seg6_enabled=1
    ip netns exec rt1 sysctl -w net.ipv6.conf.rt1-rt0.seg6_enabled=1
    ip netns exec rt1 sysctl -w net.ipv6.conf.rt1-user.seg6_enabled=1

    ip netns exec rt2 sysctl -w net.ipv6.conf.all.forwarding=1
    ip netns exec rt2 sysctl -w net.ipv6.conf.lo.forwarding=1
    ip netns exec rt2 sysctl -w net.ipv6.conf.rt2-rt0.forwarding=1
    ip netns exec rt2 sysctl -w net.ipv6.conf.rt2-user.forwarding=1
    ip netns exec rt2 sysctl -w net.ipv6.conf.all.seg6_enabled=1
    ip netns exec rt2 sysctl -w net.ipv6.conf.lo.seg6_enabled=1
    ip netns exec rt2 sysctl -w net.ipv6.conf.rt2-rt0.seg6_enabled=1
    ip netns exec rt2 sysctl -w net.ipv6.conf.rt2-user.seg6_enabled=1

    ip netns exec user sysctl -w net.ipv6.conf.all.forwarding=1
    ip netns exec user sysctl -w net.ipv6.conf.lo.forwarding=1
    ip netns exec user sysctl -w net.ipv6.conf.user-rt1.forwarding=1
    ip netns exec user sysctl -w net.ipv6.conf.user-rt2.forwarding=1
    ip netns exec user sysctl -w net.ipv6.conf.all.seg6_enabled=1
    ip netns exec user sysctl -w net.ipv6.conf.lo.seg6_enabled=1
    ip netns exec user sysctl -w net.ipv6.conf.user-rt1.seg6_enabled=1
    ip netns exec user sysctl -w net.ipv6.conf.user-rt2.seg6_enabled=1

}

configure_route () {
    # mon
    ip netns exec mon ip -6 route add 2001:db8:0:6::1 encap seg6 mode encap segs 2001:db8:1111:ffff::2 dev mon-con via 2001:db8:0:1::1
    ip netns exec mon ip -6 route add default dev mon-con via 2001:db8:0:1::1

    # con
    ip netns exec con ip -6 route add default dev con-rt0 via 2001:db8:0:7::1

    # rt0
    ip netns exec rt0 ip -6 route add 2001:db8:0:1::/64 dev rt0-con via 2001:db8:0:7::2 
    ip netns exec rt0 ip -6 route add default dev rt0-rt1 via 2001:db8:0:2::1
    ip netns exec rt0 ip -6 route add 2001:db8:1111:ffff::2/128 encap seg6local action End.DX6 nh6 2001:db8:0:2::1 via 2001:db8:0:2::1
    ip netns exec rt0 ip -6 route add 2001:db8:1111:ffff::3/128 encap seg6local action End.DX6 nh6 2001:db8:0:3::1 via 2001:db8:0:3::1


    # rt1
    ip netns exec rt1 ip -6 route add 2001:db8:0:6::/64 dev rt1-user via 2001:db8:0:4::2
    ip netns exec rt1 ip -6 route add default dev rt1-rt0 via 2001:db8:0:2::2

    # rt2
    ip netns exec rt2 ip -6 route add 2001:db8:0:6::/64 dev rt2-user via 2001:db8:0:5::2
    ip netns exec rt2 ip -6 route add default dev rt2-rt0 via 2001:db8:0:3::2

    # user
    ip netns exec user ip -6 route add default dev user-rt1 via 2001:db8:0:4::1
}

create_ns
attach_link
connect_int
linkup_interface
set_kernel_params
configure_route
