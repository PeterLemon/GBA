; Game Boy Advance 'Bare Metal' "Hello, World!" Text Printing demo by krom (Peter Lemon):

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
include 'LIB\DMA.INC'

macro PrintString Source, Destination, Length, Palette { ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  local .LoopChar
  imm32 r0,Source      ; Source Address
  mov r1,VRAM          ; Video RAM
  imm32 r2,Destination ; Destination Address
  add r1,r2            ; Video RAM += Destination Address
  mov r2,Length        ; String Length
  mov r3,Palette*4096  ; Palette Number << 12
  .LoopChar:
    ldrb r4,[r0],1 ; Load Character, Increment String Source Address
    orr r4,r3      ; OR Palette Number
    strh r4,[r1],2 ; Store Character To Map Data, Increment VRAM Destination Address
    subs r2,1      ; Decrement String Length, Compare String Length To Zero
    bne .LoopChar  ; IF(String Length != 0) Loop Character
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

  mov r0,VPAL        ; Load Color Mem Address
  imm32 r1,$7FFF7C00 ; Load  BG Font White Palette & Blue BG Color Zero
  str r1,[r0],32     ; Store BG Font Palette To Color Mem, Increment Color Mem Address To Next 4BPP Palette
  imm32 r1,$001F0000 ; Load  BG Font Red Palette
  str r1,[r0],32     ; Store BG Font Palette To Color Mem, Increment Color Mem Address To Next 4BPP Palette
  imm32 r1,$03E00000 ; Load  BG Font Green Palette
  str r1,[r0],32     ; Store BG Font Palette To Color Mem, Increment Color Mem Address To Next 4BPP Palette
  DMA32 FONTIMG, VRAM, 1024 ; DMA BG 4BPP 8x8 Tile Font Character Data To VRAM

  PrintString TEXT, 4496, 13, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString TEXT, 4610, 13, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString TEXT, 4766, 13, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

Loop:
    b Loop

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org $80000C0 + (endcopy - IWRAM) + (startcode - copycode)
FONTIMG: file 'Font8x8.img' ; Include BG 4BPP 8x8 Tile Font Character Data (4096 Bytes)
TEXT: db "Hello, World!"    ; Include BG Map Text Data (13 Bytes)