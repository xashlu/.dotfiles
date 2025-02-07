#!/usr/bin/env bash

while [ : ]; do
    /usr/bin/screenkey --geometry 711x900+604+90 -s medium --opacity 0.4
    pid=$!
    sleep 1
    kill $pid
done
