echo "Resetting anykey leonardo style..."

echo "RESETTING ANYKEY..."
#use resetlegacy or resetarduino for other resets
#DEVICE=`anykey_save -resetlegacy`
#DEVICE=`ls -1 /dev/*modem*`
DEVICE=`anykey_save -reset`
echo "READING firmware.hex from DEVICE=: $DEVICE"

avrdude -C./avrdude.conf -F -v -patmega32u4 -cavr109 -P$DEVICE -b19200 -D -Uflash:r:firmware.hex:i

#echo "done. now making firmware.dump..."
#avr-objdump -s -m avr35 firmware.hex > firmware.dump
#
#echo "done now making firmware.asm"
## we target atmega32u4 (list of architectures here: http://www.nongnu.org/avr-libc/user-manual/using_tools.html)
#avr-objdump -j .sec1 -m avr35 -d firmware.hex > firmware.asm

echo "done wrote firmware.hex"
