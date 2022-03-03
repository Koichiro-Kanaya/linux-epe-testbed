#!/bin/bash
ip netns delete mon
ip netns delete user # TODO: delete
ip netns delete con # TODO: delete
ip netns delete rt0 # TODO: delete
ip netns delete rt1 # TODO: delete
ip netns delete rt2 # TODO: delete 