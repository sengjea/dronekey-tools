#/bin/bash

sudo iw phy phy0 interface add mon0 type monitor flags fcsfail plcpfail
sudo ifconfig mon0 up

ping 192.168.0.42 2>&1 > /dev/null &

cd workspace/dronekey-tools/collection/ber
sudo python server.py >> collection.log
