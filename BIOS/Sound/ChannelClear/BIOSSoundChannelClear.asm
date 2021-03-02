; Game Boy Advance 'Bare Metal' BIOS Functions Sound ChannelClear demo by krom (Peter Lemon):

format binary as 'gba'
org $8000000
include 'LIB\FASMARM.INC' ; Include FASMARM Macros
include 'LIB\GBA.INC' ; Include GBA Definitions
include 'LIB\GBA_DMA.INC' ; Include GBA DMA Macros
include 'LIB\GBA_LCD.INC' ; Include GBA LCD Macros
include 'LIB\GBA_TIMER.INC' ; Include GBA Timer Macros
include 'LIB\GBA_HEADER.ASM' ; Include GBA Header & ROM Entry Point

macro PrintString Source, Destination, Length, Palette { ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  local .LoopChar
  imm32 r8,Source       ; Source Address
  mov r9,VRAM           ; Video RAM
  imm32 r10,Destination ; Destination Address
  add r9,r10            ; Video RAM += Destination Address
  mov r10,Length        ; String Length
  mov r11,Palette*4096  ; Palette Number << 12
  .LoopChar:
    ldrb r12,[r8],1 ; Load Character, Increment String Source Address
    orr r12,r11     ; OR Palette Number
    strh r12,[r9],2 ; Store Character To Map Data, Increment VRAM Destination Address
    subs r10,1      ; Decrement String Length, Compare String Length To Zero
    bne .LoopChar   ; IF(String Length != 0) Loop Character
}

macro PrintValue Source, Destination, Length, Palette { ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number
  local .LoopChar
  imm32 r7,Source      ; Source Address
  mov r8,VRAM          ; Video RAM
  imm32 r9,Destination ; Destination Address
  add r8,r9            ; Video RAM += Destination Address
  mov r9,Length-1      ; Value Length - 1
  mov r10,Palette*4096 ; Palette Number << 12
  mov r11,"$"          ; Load Character
  orr r11,r10          ; OR Palette Number
  strh r11,[r8],2      ; Store Character To Map Data, Increment VRAM Destination Address
  .LoopChar:
    ldrb r11,[r7,r9] ; Load Character
    lsr r12,r11,4    ; Hi Nibble
    cmp r12,9        ; Compare Hi Nibble To 9
    addle r12,$30    ; IF(Hi Nibble <= 9) Hi Nibble += ASCII Number
    addgt r12,$37    ; IF(Hi Nibble > 9)  Hi Nibble += ASCII Letter
    orr r12,r10      ; OR Palette Number
    strh r12,[r8],2  ; Store Character To Map Data, Increment VRAM Destination Address
    and r11,$F       ; Lo Nibble
    cmp r11,9        ; Compare Lo Nibble To 9
    addle r11,$30    ; IF(Lo Nibble <= 9) Lo Nibble += ASCII Number
    addgt r11,$37    ; IF(Lo Nibble > 9)  Lo Nibble += ASCII Letter
    orr r11,r10      ; OR Palette Number
    strh r11,[r8],2  ; Store Character To Map Data, Increment VRAM Destination Address
    subs r9,1        ; Decrement Value Length, Compare Value Length To Zero
    bge .LoopChar    ; IF(Value Length >= 0) Loop Character
}

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
  strh r1,[r0,BG0CNT]

  mov r0,VPAL        ; Load Color Mem Address
  imm32 r1,$7FFF7C00 ; Load  BG Font White Palette & Blue BG Color Zero
  str r1,[r0],32     ; Store BG Font Palette To Color Mem, Increment Color Mem Address To Next 4BPP Palette
  imm32 r1,$001F0000 ; Load  BG Font Red Palette
  str r1,[r0],32     ; Store BG Font Palette To Color Mem, Increment Color Mem Address To Next 4BPP Palette
  imm32 r1,$03E00000 ; Load  BG Font Green Palette
  str r1,[r0],32     ; Store BG Font Palette To Color Mem, Increment Color Mem Address To Next 4BPP Palette
  imm32 r1,$03FF0000 ; Load  BG Font Yellow Palette
  str r1,[r0],32     ; Store BG Font Palette To Color Mem, Increment Color Mem Address To Next 4BPP Palette
  imm32 r1,$7C1F0000 ; Load  BG Font Purple Palette
  str r1,[r0],32     ; Store BG Font Palette To Color Mem, Increment Color Mem Address To Next 4BPP Palette
  imm32 r1,$7FE00000 ; Load  BG Font Cyan Palette
  str r1,[r0],32     ; Store BG Font Palette To Color Mem, Increment Color Mem Address To Next 4BPP Palette
  DMA32 FONTIMG, VRAM, 1024 ; DMA BG 4BPP 8x8 Tile Font Character Data To VRAM

  PrintString TitleTEXT, 4096, 24, 4 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString LineBreakTEXT, 4160, 30, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString SoundChannelClearTEXT, 4224, 22, 5 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  PrintString TestTEXT, 4274, 4, 3 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString LineBreakTEXT, 4338, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  mov r10,IO ; GBA I/O Base Offset
  orr r11,r10,TM0CNT             ; Timer 0 Control Register
  mov r12,TM_ENABLE or TM_FREQ_1 ; Timer 0 Enable, Frequency/1
  str r12,[r11]                  ; Start Timer 0

  swi $1E0000 ; BIOS Function

  ldr r10,[r11] ; Load  Timer 0 Value
  imm32 r9,TIMER
  str r10,[r9]  ; Store Timer 0 Value
  mov r12,TM_DISABLE
  str r12,[r11] ; Reset Timer 0 Control

  PrintString OutputTEXT, 4354, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString TimerTEXT, 4368, 8, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintValue TIMER, 4386, 2, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  imm32 r9,TIMER ; Load Result
  ldr r4,[r9]
  lsl r4,16
  lsr r4,16
  imm16 r9,$0052 ; Load Test Check
  cmp r4,r9      ; Compare Result
  bne TestFAILA  ; IF(Check != Result) FAIL, ELSE PASS
  PrintString PassTEXT, 4402, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  b TestENDA
  TestFAILA:
    PrintString FailTEXT, 4402, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDA:


  PrintString LineBreakTEXT, 4416, 30, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

Loop:
  b Loop

TIMER: dw 0

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org startcode + (endcopy - IWRAM)
FONTIMG: file 'Font8x8.img'            ; Include BG 4BPP 8x8 Tile Font Character Data (4096 Bytes)
TitleTEXT:             db "GBA BIOS Sound Functions"       ; Include BG Map Text Data (24 Bytes)
LineBreakTEXT:         db "------------------------------" ; Include BG Map Text Data (30 Bytes)
SoundChannelClearTEXT: db "SoundChannelClear $1E:"         ; Include BG Map Text Data (22 Bytes)

OutputTEXT: db "OUTPUT"   ; Include BG Map Text Data (6 Bytes)
TimerTEXT:  db "TIMER0 =" ; Include BG Map Text Data (8 Bytes)

TestTEXT:   db "TEST" ; Include BG Map Text Data (4 Bytes)
PassTEXT:   db "PASS" ; Include BG Map Text Data (4 Bytes)
FailTEXT:   db "FAIL" ; Include BG Map Text Data (4 Bytes)