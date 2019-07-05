DEVICE=/dev/cu.usbmodem1411
avrdude -carduino -patmega32u4 -P$DEVICE -Uflash:w:anykey_bootloader.hex:i

