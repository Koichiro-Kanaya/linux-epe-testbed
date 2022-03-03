#/bin/bash

ip netns exec user ping 2001:db8:0:1::2 -I 2001:db8:0:6::1
