GBA
===
<br />
Game Boy Advance Bare Metal Code by krom (Peter Lemon).<br />
<br />
All code compiles out of box with the FASMARM assembler by revolution:<br />
http://arm.flatassembler.net<br />
I have included binaries of all the demos.<br />
<br />
For more information about coding the ARM CPU please visit my webpage that I run with SimonB:<br />
http://gbadev.org<br />
http://forum.gbadev.org<br />
<br />
Howto Compile:<br />
All the code compiles into a single binary (ROMNAME.gba) file.<br />
Using FASMARM open up ROMNAME.asm & click the Run/Compile button.<br />
You will need to fix the header checksum of the assembled GBA binary.<br />
I use the util gbafix todo this in windows:<br />
http://gbadev.org/tools.php?showinfo=76<br />
I have made a fixrom.bat file todo this.<br />
<br />
Howto Run:<br />
I only test with a real GBA using a flash cartridge.<br />
<br />
You can also use GBA emulators like no$gba & the MESS GBA Driver.
