DEVICE=`ls -1 /dev/cu.usbmodem*`
avrdude -carduino -patmega32u4 -P$DEVICE -Uflash:w:anykey_bootloader.hex:i

