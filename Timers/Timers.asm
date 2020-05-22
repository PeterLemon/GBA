; Game Boy Advance 'Bare Metal' Timers demo by krom (Peter Lemon):

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
include 'LIB\DMA.INC'
include 'LIB\TIMER.INC'

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

macro PrintValue Source, Destination, Length, Palette { ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number
  local .LoopChar
  imm32 r0,Source      ; Source Address
  mov r1,VRAM          ; Video RAM
  imm32 r2,Destination ; Destination Address
  add r1,r2            ; Video RAM += Destination Address
  mov r2,Length-1      ; Value Length - 1
  mov r3,Palette*4096  ; Palette Number << 12
  mov r4,"$"           ; Load Character
  orr r4,r3            ; OR Palette Number
  strh r4,[r1],2       ; Store Character To Map Data, Increment VRAM Destination Address
  .LoopChar:
    ldrb r4,[r0,r2] ; Load Character
    lsr r5,r4,4     ; Hi Nibble
    cmp r5,9        ; Compare Hi Nibble To 9
    addle r5,$30    ; IF(Hi Nibble <= 9) Hi Nibble += ASCII Number
    addgt r5,$37    ; IF(Hi Nibble > 9)  Hi Nibble += ASCII Letter
    orr r5,r3       ; OR Palette Number
    strh r5,[r1],2  ; Store Character To Map Data, Increment VRAM Destination Address
    and r4,$F       ; Lo Nibble
    cmp r4,9        ; Compare Lo Nibble To 9
    addle r4,$30    ; IF(Lo Nibble <= 9) Lo Nibble += ASCII Number
    addgt r4,$37    ; IF(Lo Nibble > 9)  Lo Nibble += ASCII Letter
    orr r4,r3       ; OR Palette Number
    strh r4,[r1],2  ; Store Character To Map Data, Increment VRAM Destination Address
    subs r2,1       ; Decrement Value Length, Compare Value Length To Zero
    bge .LoopChar   ; IF(Value Length >= 0) Loop Character
}

org $8000000
b copycode
times $80000C0-($-0) db 0

copycode:
  adr r0,startcode
  mov r1,IWRAM
  imm32 r2,endcopy
  clp:
    ldr r3,[r0],4
    str r3,[r1],4
    cmp r1,r2
    bmi clp
  imm32 r0,start
  bx r0
startcode:
  org IWRAM

start:
  mov r0,00011100b ; Clear Palette, VRAM, OAM
  swi $010000      ; BIOS Function

  mov r0,IO
  mov r1,MODE_0
  orr r1,BG0_ENABLE
  str r1,[r0]

  imm16 r1,0000001000000000b ; BG Tile Offset = 0, Tiles 4BPP, BG Map Offset = 4096, Map Size = 32x32 Tiles
  str r1,[r0,BG0CNT]

  mov r0,VPAL        ; Load Color Mem Address
  imm32 r1,$7FFF7C00 ; Load  BG Font White Palette & Blue BG Color Zero
  str r1,[r0],32     ; Store BG Font Palette To Color Mem, Increment Color Mem Address To Next 4BPP Palette
  imm32 r1,$03E00000 ; Load  BG Font Green Palette
  str r1,[r0],32     ; Store BG Font Palette To Color Mem, Increment Color Mem Address To Next 4BPP Palette
  DMA32 FONTIMG, VRAM, 1024 ; DMA BG 4BPP 8x8 Tile Font Character Data To VRAM

  PrintString TitleTEXT, 4162, 16, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString Timer0TEXT, 4290, 22, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString Timer1TEXT, 4354, 22, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString Timer2TEXT, 4418, 22, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString Timer3TEXT, 4482, 22, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  mov r0,IO ; GBA I/O Base Offset

  orr r1,r0,TM0CNT              ; Timer 0 Control Register
  mov r2,TM_ENABLE or TM_FREQ_1 ; Timer 0 Enable, Frequency/1
  str r2,[r1]                   ; Start Timer 0

  orr r1,r0,TM1CNT               ; Timer 1 Control Register
  mov r2,TM_ENABLE or TM_FREQ_64 ; Timer 1 Enable, Frequency/64
  str r2,[r1]                    ; Start Timer 1

  orr r1,r0,TM2CNT                ; Timer 2 Control Register
  mov r2,TM_ENABLE or TM_FREQ_256 ; Timer 2 Enable, Frequency/256
  str r2,[r1]                     ; Start Timer 2

  orr r1,r0,TM3CNT                 ; Timer 3 Control Register
  mov r2,TM_ENABLE or TM_FREQ_1024 ; Timer 3 Enable, Frequency/1024
  str r2,[r1]                      ; Start Timer 3

Loop:
  PrintValue $4000100, 4336, 2, 1 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number
  PrintValue $4000104, 4400, 2, 1 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number
  PrintValue $4000108, 4464, 2, 1 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number
  PrintValue $400010C, 4528, 2, 1 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number
  b Loop

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org startcode + (endcopy - start)
FONTIMG: file 'Font8x8.img'      ; Include BG 4BPP 8x8 Tile Font Character Data (4096 Bytes)
TitleTEXT: db "GBA Timers Test:" ; Include BG Map Text Data (16 Bytes)
Timer0TEXT: db "Timer0 Frequency/1   =" ; Include BG Map Text Data (22 Bytes)
Timer1TEXT: db "Timer1 Frequency/64  =" ; Include BG Map Text Data (22 Bytes)
Timer2TEXT: db "Timer2 Frequency/256 =" ; Include BG Map Text Data (22 Bytes)
Timer3TEXT: db "Timer3 Frequency/1024=" ; Include BG Map Text Data (22 Bytes)