@echo off

rem set PORT="COM4"
set /p PORT=What is programmer serial port (example COM4)?:


:flash_firmware
echo "Writing firmware using programmer on PORT = %PORT% ..."
avrdude.exe -v -carduino -patmega32u4 -P%PORT% -b 19200 -Uflash:w:anykey_bootloader.hex:i  -U lfuse:w:0xFF:m	-U hfuse:w:0xD8:m	-U efuse:w:0xCB:m	
echo "Done."

echo "Writing lockbits ..."
avrdude.exe -q -patmega32u4 -carduino -D -U lock:w:0x3C:m -P %PORT%
echo "Done."

set /p flashAgain=Flash another anykey [y/n]?:

goto :flash_firmware

