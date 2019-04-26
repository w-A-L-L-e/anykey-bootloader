#!/bin/bash

DEVICE=`ls -1 /dev/*usbmodem* | head -n 1`
echo "FLASHING BOOTLOADER TO ANYKEY DEV: $DEVICE"
avrdude -C./avrdude.conf -v -patmega32u4 -cavr109 -P$DEVICE -b19200 -D -Uflash:w:anykey_blank.hex:i
