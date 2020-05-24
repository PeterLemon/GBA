; GBA Memory Map
BIOS          = $0000000 ; BIOS - System ROM                    (16 KBytes)
WRAM          = $2000000 ; On-board Work RAM                    (256 KBytes) 2 Wait
IWRAM         = $3000000 ; In-chip Work RAM                     (32 KBytes)
IO            = $4000000 ; I/O Registers
VPAL          = $5000000 ; BG/OBJ Palette RAM                   (1 Kbyte)
OBJPAL        = $5000200 ; OBJ Palette RAM                      (512 bytes)
VRAM          = $6000000 ; Video RAM                            (96 KBytes)
CHARMEM       = $6010000 ; Character RAM                        (16 KBytes)
CHARMEM_MODE3 = $6012C00 ; Character RAM Mode 3                 (4 KBytes)
CHARMEM_512   = $6014000 ; Character RAM 512                    (16 KBytes)
OAM           = $7000000 ; OBJ Attributes                       (1 KByte)
CART          = $8000000 ; Game Pak ROM/FlashROM - Wait State 0 (32MB)
CART1         = $A000000 ; Game Pak ROM/FlashROM - Wait State 1 (32MB)
CART2         = $C000000 ; Game Pak ROM/FlashROM - Wait State 2 (32MB)
SRAM          = $E000000 ; Game Pak SRAM - 8bit Bus width       (64 KBytes)