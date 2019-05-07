# AnyKey protected bootloader

This is a modified arduino caterina bootloader that allows itself to be locked and unlocked from the user space
application (or any arduino sketch).

![anykey_boot_lock](https://user-images.githubusercontent.com/710803/57279189-a6fe2180-70a8-11e9-800c-29a2a3d38ab8.JPG)

By setting the right EEPROM byte you can disable or temporarely enable or fully unlock all bootloader features like
reading, writing to flash, eeprom, fuses etc. In this picture you see an example of an arduino being used as ISP
to flash another similar arduino. By protecting the bootloader on the programmer ISP you can't accidentally loose your
trusty programming device that allowed you to flash chips (see examples for full example isp sketch). 
It's just an example but there are many use cases for a protected lockable bootloader. 

Meanwhile visit our kickstarter pages for any updates here as our anykey needs this to allow upgrades of firmware
while still blocking all unwanted copies or reads on regular use:
https://www.kickstarter.com/projects/715415099/anykey-the-usb-password-key


## Compiling 

```
git checkout development
cd anykey
make
```
This results in an anykey.hex file that has the bootlocking functionality.
You still need to add an empty sketch and combine the hex file into one larger hex file. 
Luckily for the lazy this is already done and saved as anykey_bootloader.hex in this repo.

To flash the lockable bootloader there is also an example script in the anykey directory flash_fast.sh.
This uses avrdude and an arduino as isp to get the job done. Feel free to use another programmer and just update the avrdude command here.
The flash_fast.sh also sets the lock bits LB1 and LB2 so you cant flash with external ISP anymore etc. You can only undo this by doing a chip
erase (which is allowed using ISP).

We first wanted to build in a challenge-response type to unlock but we ran out of flash space (bootloader starts at 0x7000 and 
current arduino caterina is already close to that). We managed however to squeeze out some bytes with latest avr-gcc and using -Os flags.
Then we added a way to disable and enable the bootloader from within a sketch by sacrificing one eeprom byte at address 1023 (the last byte).
This way the sketch can implement any complex or simple scheme to lock and unlock the bootloader depending on the application.
For our anykey device we plan on using a SHA-HMAC1 challenge response. However a plain simple example is also provided in the examples directory (more info down this page)

The byte at 1023 pos in EEPROM is now used to signal the bootloader if is allowed to start.
With the default value of 0xFF (which eeprom has for all bytes when you do chip erase) the bootloader is active and functions
exactly like Caterina. Meaning you can use avrdude and other tools to read/write etc.
However once you want to protect your bootloader you can set the last eeprom byte to 0x187 (murder! ;) ) and then the bootloader
jumps strait to the sketch without doing anything. This way you can't read nor write to your chip using usb.
Combined with lockbits LB1 and LB2 (which de-activate external reading/writing with ISP) this is an effective way to protect the contents
of your flash and eeprom data.

It doesn't always have to be about protecting your secret data (keys, or hashes or passwords) on the chip.
Another example I bumped into myself is when you use a second arduino as an ISP. This is handy but sometimes you can
overwrite the ArduinoISP accidently if you choose the wrong port. One way would be to not use a bootloader on your programmer.
But that would make it a little cumbersome to update to a newer version (you need a second programmer to program your programmer etc...).

Well in the examples dir is a nice solution useing the anykey bootloader (that works on any arduino compatible device or rather on any
atmega32u4). You basically first flash the anykey bootloader and then use the modified ISP sketch.
To unlock the bootloader you open a serial window to your ArduinoISP and just enter 'X'. To lock it you enter 'L'.
The effect is if you lock it then you can't accidently flash your programmer anymore.

The changes to ArduinoISP are really small all you need to add is this (and this has already been done in examples folder):
```
void avrisp() {
  uint8_t ch = getch();
  switch (ch) {
    case 'X':
      SERIAL.print("Unlocking bootloader...");
      eeprom_update_byte ( 1023, 255 ); //0xFF regular bootloader reloaded
      SERIAL.println("done");
      break;
    case 'L':
      SERIAL.print("Locking bootloader...");
      eeprom_update_byte ( 1023, 187 ); //187 we murder the bootloader ;)
      SERIAL.println("done");
      break;
```

## Burning new bootloader
Basically means flashing to atmega32u4 with avrdude. We've put a config and example of flashing in the avrdude folder. 
Avrdude is a free tool to write firmware.hex files to microcontrollers.
You can download avrdude here: https://github.com/sigmike/avrdude
This needs to be done only once and places the hex file at the end of the microcontrollers memory starting at 0x7000.
The file you want to flash is anykey/anykey_bootloader.hex.

The configurator will eventually have a stripped down version of the above avrdude tool to allow security updates to the AnyKey dongle itself that are only
allowed to be official signed hex files that way you can't brick your anykey and you can rest assured it hasn't been tampered with.

## Warning
When using this first test your lock/unlock procedure with either Serial.print's like done above before actually writing to your eeprom. 
Once you lock the bootloader down you can't change the application (arduino sketch) anymore until you unlock it (and yes it survives power cycles). 
So make sure you have a way to toggle lock/unlock in some way. This can be with a button, switch, or like in the example a simple serial message or 
any elaborate challenge-response or proprietary way you can think off. Basically the anykey_bootloader applies the same versatile way of locking that is done
with LB1 and LB2 for external programming but using an eeprom byte instead of a fuse.

Worst case if you do lock yourself out due to some bug you can indeed do a chip erase and then reflash bootloader+sketch (that is debugged 
or one that leaves pos 1023 at 0xFF ). The cool thing is you see that only way out is erasing the entire chip with an external programmer 
and therefore also the secured information you want to protect. For our anykey device we're contemplating of even setting SPIEN off once the
firmware is deemed stable enough. That way you can only use HVP to reset but that requires desoldering the smd chip and having professional equipment and
skills. And it would only allow you to reset it to a blank so most likely you'd be quicker with just replacing the chip in this case or calling it a 'brick' ;).
The thing is even with SPIEN off and LB1+LB2 you can still update. You need to just always be able to set your toggle byte correctly after which the bootloader is still
allowed to update application space.

## Todos/future work
Maybe also allow this to run on different atmega's. And try to get this undocumentend LB1 + LB2 setting method to work:
https://www.avrfreaks.net/forum/changing-lb1-and-lb2-lock-bits-programmatically
That's currently tried with the 185 value on pos 1023 then it works like the single unlock method + adds setting lb1 and lb2 if they're not set
yet. Ideal for upgrading devices that have not set the lock bits in factory. This is the only feature currently not working. For our
usecase/kickstarter we can luckily give the right fuses + lockbits to our supplier, so it's not a showstopper. But if anyone has
any tips to get our current code actually changing LB1and2 without a programmer feel free to let us know.


Feel free to comment or suggest improvements.

Original Caterina bootloader:
Copyright ?

LUFA library used for USB communication:
Copyright 2011  Dean Camera

Derived anykey_bootloader (MIT-license):
Copyright 2019 Walter Schreppers

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
