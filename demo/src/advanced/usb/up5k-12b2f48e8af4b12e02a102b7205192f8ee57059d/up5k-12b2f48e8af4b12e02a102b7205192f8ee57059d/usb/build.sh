#!/bin/bash

yosys \
        -q \
        -p 'read_verilog serial-demo.v' \
        -p 'synth_ice40 -top top -json serial-demo.json' \
        -E .spram-demo.d \

nextpnr-ice40 \
        --up5k \
        --package sg48 \
        --asc serial-demo.asc \
        --pcf ../icesugar.pcf \
        --json serial-demo.json \

icepack serial-demo.asc serial-demo.bin

