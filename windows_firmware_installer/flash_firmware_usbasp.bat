@echo off

:flash_firmware
echo "Writing firmware using programmer on PORT = %PORT% ..."
avrdude.exe -v -c usbasp -patmega32u4 -P usb -b 19200 -Uflash:w:anykey_bootloader.hex:i -U lfuse:w:0xFF:m -U hfuse:w:0xD8:m -U efuse:w:0xCB:m	
echo "Done."

echo "Writing lockbits ..."
avrdude.exe -q -patmega32u4 -c usbasp -D -U lock:w:0x3C:m -P usb
echo "Done."

set /p flashAgain=Flash another anykey [y/n]?:

goto :flash_firmware

