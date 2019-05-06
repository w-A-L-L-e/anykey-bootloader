#this is without chiperase, not recommended
# avrdude -carduino -patmega32u4 -P/dev/cu.usbmodem14301 -D -Uflash:w:Anykey.hex:i
#avrdude -carduino -patmega32u4 -P/dev/cu.usbmodem14301 -b 57600 -Uflash:w:anykey_bootloader.hex:i
# makes no difference 115200 or 57600 all same speed as 19200 so take that one to be more reliable

#avrdude -carduino -patmega32u4 -P/dev/cu.usbmodem14301 -b 19200 -Uflash:w:anykey_bootloader.hex:i
avrdude -v -carduino -patmega32u4 -P/dev/cu.usbmodem14301 -b 19200 -Uflash:w:anykey_bootloader.hex:i  -U lfuse:w:0xFF:m	-U hfuse:w:0xD8:m	-U efuse:w:0xCB:m	

#set lock bits
avrdude -q -patmega32u4 -carduino -D -U lock:w:0xFC:m -P /dev/cu.usbmodem14301
echo "if its 0x3C instead this is also good"


echo "now read out lockbits"
avrdude -q -patmega32u4 -carduino  -P /dev/cu.usbmodem14301 -D -U hfuse:r:-:h -U lock:r:-:h 

