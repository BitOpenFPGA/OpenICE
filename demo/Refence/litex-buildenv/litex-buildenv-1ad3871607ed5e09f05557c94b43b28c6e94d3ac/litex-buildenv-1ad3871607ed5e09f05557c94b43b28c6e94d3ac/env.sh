#!/bin/bash

# Build targets
export CPU=lm32             # Soft CPU architecture
export CPU_VARIANT=minimal  # Use a resource-constrained variant to make up5k happy
export PLATFORM=icebreaker  # Target platform Icebreaker, or PLATFORM=tinyfpga_bx for TinyFPGA BX
export FIRMWARE=micropython
export TARGET=base
