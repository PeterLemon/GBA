; Game Boy Advance 'Bare Metal' "Hello, World!" Text Printing demo by krom (Peter Lemon):

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
include 'LIB\DMA.INC'

macro PrintString String, Destination, Length, Palette { ; Print String: String Address, VRAM Destination, String Length, Palette Number
  local .LoopString
  imm32 r0,String       ; String Source Address
  mov r1,VRAM           ; Video RAM
  imm32 r2,Destination  ; Destination Address
  add r1,r2             ; Video RAM += Destination Address
  mov r2,Length         ; String Length
  mov r3,(Palette*4096) ; Palette Number << 12
  .LoopString:
    ldrb r4,[r0],1  ; Load String Character, Increment String Source Address
    orr r4,r3       ; OR Palette Number
    strh r4,[r1],2  ; Store String To Map Data, Increment VRAM Destination Address
    subs r2,1       ; Decrement String Length, Compare String Length To Zero
    bne .LoopString ; IF(String Length != 0) Loop String
}

org $8000000
b copycode
times $80000C0-($-0) db 0

copycode:
  adr r1,startcode
  mov r2,IWRAM
  imm32 r3,endcopy
  clp:
    ldr r0,[r1],4
    str r0,[r2],4
    cmp r2,r3
    bmi clp
  imm32 r2,start
  bx r2
startcode:
  org IWRAM

align 4
start:
  mov r0,IO
  mov r1,MODE_0
  orr r1,BG0_ENABLE
  str r1,[r0]

  imm16 r1,0000001000000000b ; BG Tile Offset = 0, Tiles 4BPP, BG Map Offset = 4096, Map Size = 32x32 Tiles
  str r1,[r0,BG0CNT]

  DMA32 WHITEPAL, VPAL, 1    ; DMA BG Font White Palette To Color Mem
  DMA32 REDPAL, VPAL+32, 1   ; DMA BG Font Red   Palette To Color Mem
  DMA32 GREENPAL, VPAL+64, 1 ; DMA BG Font Green Palette To Color Mem
  DMA32 FONTIMG, VRAM, 1024  ; DMA BG Font Image To VRAM

  PrintString TEXT, 4496, 13, 0 ; Print String: String Address, VRAM Destination, String Length, Palette Number
  PrintString TEXT, 4610, 13, 1 ; Print String: String Address, VRAM Destination, String Length, Palette Number
  PrintString TEXT, 4766, 13, 2 ; Print String: String Address, VRAM Destination, String Length, Palette Number

Loop:
    b Loop

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org $80000C0 + (endcopy - IWRAM) + (startcode - copycode)
WHITEPAL: dh $7C00, $7FFF   ; Include BG Font White Palette
REDPAL:   dh $7C00, $001F   ; Include BG Font Red   Palette
GREENPAL  dh $7C00, $03E0   ; Include BG Font Green Palette
FONTIMG: file 'Font8x8.img' ; Include BG 4BPP 8x8 Tile Font Character Data (4096 Bytes)
TEXT: db "Hello, World!"    ; Include BG Map Text Data (13 Bytes)