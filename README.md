# AnyKey protected bootloader

Work on the new bootloader will happen here. Any changes we make to these GPL parts we're submitting here for now until we've hit a stable
version. The current version works fine as to be expected but we've got some features planned to add here.
We need either a handshake or just a simple shared secret to block unwanted flashing to be added.

Meanwhile visit our kickstarter pages for any updates here:
https://www.kickstarter.com/projects/715415099/anykey-the-usb-password-key


## Compiling 

```
git checkout development
cd caterina
make

-------- begin --------
avr-gcc (GCC) 7.2.0
Copyright (C) 2017 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


Compiling C: Caterina.c
avr-gcc -c -mmcu=atmega32u4 -I. -gdwarf-2 -DF_CPU=16000000UL -DF_USB=16000000UL -DBOARD=BOARD_USER -DARCH=ARCH_AVR8 -DBOOT_START_ADDR=0x7000UL -DDEVICE_VID=0x2341UL -DDEVICE_PID=0x0036UL -D USB_DEVICE_ONLY -D DEVICE_STATE_AS_GPIOR=0 -D ORDERED_EP_CONFIG -D FIXED_CONTROL_ENDPOINT_SIZE=8 -D FIXED_NUM_CONFIGURATIONS=1 -D USE_RAM_DESCRIPTORS -D USE_STATIC_OPTIONS="(USB_DEVICE_OPT_FULLSPEED | USB_OPT_REG_ENABLED | USB_OPT_AUTO_PLL)" -D NO_INTERNAL_SERIAL -D NO_DEVICE_SELF_POWER -D NO_DEVICE_REMOTE_WAKEUP -D NO_SOF_EVENTS -D NO_LOCK_BYTE_WRITE_SUPPORT -Os -funsigned-char -funsigned-bitfields -ffunction-sections -fno-inline-small-functions -fpack-struct -fshort-enums -fno-strict-aliasing -Wall -Wstrict-prototypes -Wa,-adhlns=./Caterina.lst -I../lufa-LUFA-111009/ -std=c99 -MMD -MP -MF .dep/Caterina.o.d Caterina.c -o Caterina.o


...

Linking: Caterina.elf
avr-gcc -mmcu=atmega32u4 -I. -gdwarf-2 -DF_CPU=16000000UL -DF_USB=16000000UL -DBOARD=BOARD_USER -DARCH=ARCH_AVR8 -DBOOT_START_ADDR=0x7000UL -DDEVICE_VID=0x2341UL -DDEVICE_PID=0x0036UL -D USB_DEVICE_ONLY -D DEVICE_STATE_AS_GPIOR=0 -D ORDERED_EP_CONFIG -D FIXED_CONTROL_ENDPOINT_SIZE=8 -D FIXED_NUM_CONFIGURATIONS=1 -D USE_RAM_DESCRIPTORS -D USE_STATIC_OPTIONS="(USB_DEVICE_OPT_FULLSPEED | USB_OPT_REG_ENABLED | USB_OPT_AUTO_PLL)" -D NO_INTERNAL_SERIAL -D NO_DEVICE_SELF_POWER -D NO_DEVICE_REMOTE_WAKEUP -D NO_SOF_EVENTS -D NO_LOCK_BYTE_WRITE_SUPPORT -Os -funsigned-char -funsigned-bitfields -ffunction-sections -fno-inline-small-functions -fpack-struct -fshort-enums -fno-strict-aliasing -Wall -Wstrict-prototypes -Wa,-adhlns=Caterina.o -I../lufa-LUFA-111009/ -std=c99 -MMD -MP -MF .dep/Caterina.elf.d Caterina.o Descriptors.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Core/AVR8/Device_AVR8.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Core/AVR8/Endpoint_AVR8.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Core/AVR8/Host_AVR8.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Core/AVR8/Pipe_AVR8.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Core/AVR8/USBInterrupt_AVR8.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Core/AVR8/EndpointStream_AVR8.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Core/AVR8/PipeStream_AVR8.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Core/ConfigDescriptor.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Core/DeviceStandardReq.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Core/Events.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Core/HostStandardReq.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Core/USBTask.o ../lufa-LUFA-111009/LUFA/Drivers/USB/Class/Common/HIDParser.o --output Caterina.elf -Wl,-Map=Caterina.map,--cref -Wl,--section-start=.text=0x7000 -Wl,--relax -Wl,--gc-sections     -lm

Creating load file for Flash: Caterina.hex
avr-objcopy -O ihex -R .eeprom -R .fuse -R .lock Caterina.elf Caterina.hex

Creating load file for EEPROM: Caterina.eep
avr-objcopy -j .eeprom --set-section-flags=.eeprom="alloc,load" \
	--change-section-lma .eeprom=0 --no-change-warnings -O ihex Caterina.elf Caterina.eep || exit 0

Creating Extended Listing: Caterina.lss
avr-objdump -h -S -z Caterina.elf > Caterina.lss

Creating Symbol Table: Caterina.sym
avr-nm -n Caterina.elf > Caterina.sym

Size after:
AVR Memory Usage
----------------
Device: atmega32u4

Program:    3872 bytes (11.8% Full)
(.text + .data + .bootloader)

Data:        188 bytes (7.3% Full)
(.data + .bss + .noinit)


```

So this compiles already and generates our bootloader hex with a more recent avr-gcc than the previous releases.
We adjusted the makefile, and added the lufa libraries with correct version for it to compile with a simple make in the Caterina folder.
We're now ready to make our modifications and most likely release a seperate folder for anykey specific code much like the lilypad has done in the past.

In the original arduino git the lufa libraries are referenced and needed tracking down to be able to do a succesful build.
Furthermore the hex file now needs to be prepended with a minimal sketch and combined in a full 32k image for flashing.

## Burning new bootloader
Basically means flashing to atmega32u4 with avrdude. We've put a config and example of flashing in the avrdude folder. 
Avrdude is a free tool to write firmware.hex files to microcontrollers.
You can download avrdude here: https://github.com/sigmike/avrdude
This needs to be done only once and places the hex file at the end of the microcontrollers memory starting at 0x7000.

Any firmware specific code and security updates after that happen in the beginning of the flash (everything up to 0x7000).
This is basically how arduino's allow to upload sketches. We can use a similar mechanism to upgrade to newer firmware versions to allow security updates.

Not only are firmware updates possible now, we can still preserve the users set password salt between updates as these are stored in a seperate
eeprom not affected by the firmware updates.
The configurator will eventually have a stripped down version of the above avrdude tool to allow security updates to the AnyKey dongle itself.
Right now we however need to already prepare this so we can ship earlier and improve after the devices are spread into the world.
The locking of page write needs to happen so that tampering is not possible anymore. Basically only if you know the unlock hash you're allowed to write.



