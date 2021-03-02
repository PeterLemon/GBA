; Game Boy Advance 'Bare Metal' BIOS Functions Decompress LZ77 demo by krom (Peter Lemon):

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

  PrintString TitleTEXT, 4096, 29, 4 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString LineBreakTEXT, 4160, 30, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString LZ77WRAMTEXT, 4224, 28, 5 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  imm32 r0,DATAWRAM ; Source
  mov r1,WRAM       ; Destination

  PrintString InputTEXT, 4292, 5, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString R0TEXT, 4304, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  imm32 r9,VALUE
  str r0,[r9]
  PrintValue VALUE, 4314, 4, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  PrintString InputTEXT, 4356, 5, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString R1TEXT, 4368, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  imm32 r9,VALUE
  str r1,[r9]
  PrintValue VALUE, 4378, 4, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  PrintString TestTEXT, 4402, 4, 3 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString LineBreakTEXT, 4466, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  mov r10,IO ; GBA I/O Base Offset
  orr r11,r10,TM0CNT             ; Timer 0 Control Register
  mov r12,TM_ENABLE or TM_FREQ_1 ; Timer 0 Enable, Frequency/1
  str r12,[r11]                  ; Start Timer 0

  swi $110000 ; BIOS Function

  ldr r10,[r11] ; Load  Timer 0 Value
  imm32 r9,TIMER
  str r10,[r9]  ; Store Timer 0 Value
  mov r12,TM_DISABLE
  str r12,[r11] ; Reset Timer 0 Control

  PrintString OutputTEXT, 4482, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString DATATEXT, 4496, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  mov r0,WRAM      ; Data Address
  imm32 r1,FONTIMG ; Check Address
  mov r2,1024      ; Count = Data Length / 4
  TestLOOPA:
    ldr r3,[r0],4 ; Load Data Word, Increment Data Offset
    ldr r4,[r1],4 ; Load Check Word, Increment Check Offset
    cmp r3,r4     ; Compare Data To Check
    bne TestFAILA ; IF(Data != Check) FAIL
    subs r2,1     ; Decrement Count
    bne TestLOOPA ; IF(Count != 0) LOOP
    PrintString PassTEXT, 4530, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
    b TestENDA
  TestFAILA:
    PrintString FailTEXT, 4530, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDA:

  PrintString OutputTEXT, 4546, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString TimerTEXT, 4560, 8, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintValue TIMER, 4578, 2, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  imm32 r9,TIMER ; Load Result
  ldr r4,[r9]
  lsl r4,16
  lsr r4,16
  imm16 r9,$F643 ; Load Test Check
  cmp r4,r9      ; Compare Result
  bne TestFAILB  ; IF(Check != Result) FAIL, ELSE PASS
  PrintString PassTEXT, 4594, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  b TestENDB
  TestFAILB:
    PrintString FailTEXT, 4594, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDB:


  PrintString LineBreakTEXT, 4608, 30, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString LZ77VRAMTEXT, 4672, 29, 5 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  imm32 r0,DATAVRAM ; Source
  mov r1,VRAM       ; Destination

  PrintString InputTEXT, 4740, 5, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString R0TEXT, 4752, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  imm32 r9,VALUE
  str r0,[r9]
  PrintValue VALUE, 4762, 4, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  PrintString InputTEXT, 4804, 5, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString R1TEXT, 4816, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  imm32 r9,VALUE
  str r1,[r9]
  PrintValue VALUE, 4826, 4, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  PrintString TestTEXT, 4850, 4, 3 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString LineBreakTEXT, 4914, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  mov r10,IO ; GBA I/O Base Offset
  orr r11,r10,TM0CNT             ; Timer 0 Control Register
  mov r12,TM_ENABLE or TM_FREQ_1 ; Timer 0 Enable, Frequency/1
  str r12,[r11]                  ; Start Timer 0

  swi $120000 ; BIOS Function

  ldr r10,[r11] ; Load  Timer 0 Value
  imm32 r9,TIMER
  str r10,[r9]  ; Store Timer 0 Value
  mov r12,TM_DISABLE
  str r12,[r11] ; Reset Timer 0 Control

  PrintString OutputTEXT, 4930, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString DATATEXT, 4944, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  mov r0,VRAM      ; Data Address
  imm32 r1,FONTIMG ; Check Address
  mov r2,1024      ; Count = Data Length / 4
  TestLOOPC:
    ldr r3,[r0],4 ; Load Data Word, Increment Data Offset
    ldr r4,[r1],4 ; Load Check Word, Increment Check Offset
    cmp r3,r4     ; Compare Data To Check
    bne TestFAILC ; IF(Data != Check) FAIL
    subs r2,1     ; Decrement Count
    bne TestLOOPC ; IF(Count != 0) LOOP
    PrintString PassTEXT, 4978, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
    b TestENDC
  TestFAILC:
    PrintString FailTEXT, 4978, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDC:

  PrintString OutputTEXT, 4994, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString TimerTEXT, 5008, 8, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintValue TIMER, 5026, 2, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  imm32 r9,TIMER ; Load Result
  ldr r4,[r9]
  lsl r4,16
  lsr r4,16
  imm16 r9,$918E ; Load Test Check
  cmp r4,r9      ; Compare Result
  bne TestFAILD  ; IF(Check != Result) FAIL, ELSE PASS
  PrintString PassTEXT, 5042, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  b TestENDD
  TestFAILD:
    PrintString FailTEXT, 5042, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDD:


  PrintString LineBreakTEXT, 5056, 30, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number


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

Loop:
  b Loop

VALUE: dw 0
TIMER: dw 0

DATAWRAM: file 'DATAWRAM.lz' ; Include LZ WRAM Data (805 Bytes)
align 4
DATAVRAM: file 'DATAVRAM.lz' ; Include LZ VRAM Data (807 Bytes)
align 4

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org startcode + (endcopy - IWRAM)
FONTIMG: file 'Font8x8.img'    ; Include BG 4BPP 8x8 Tile Font Character Data (4096 Bytes)
TitleTEXT:     db "GBA BIOS Decompress Functions"  ; Include BG Map Text Data (29 Bytes)
LineBreakTEXT: db "------------------------------" ; Include BG Map Text Data (30 Bytes)
LZ77WRAMTEXT:  db "LZ77 $11 Write 8-BIT (WRAM):"   ; Include BG Map Text Data (28 Bytes)
LZ77VRAMTEXT:  db "LZ77 $12 Write 16-BIT (VRAM):"  ; Include BG Map Text Data (29 Bytes)

InputTEXT:  db "INPUT"    ; Include BG Map Text Data (5 Bytes)
OutputTEXT: db "OUTPUT"   ; Include BG Map Text Data (6 Bytes)
R0TEXT:     db "R0 ="     ; Include BG Map Text Data (4 Bytes)
R1TEXT:     db "R1 ="     ; Include BG Map Text Data (4 Bytes)
DATATEXT:   db "DATA"     ; Include BG Map Text Data (4 Bytes)
TimerTEXT:  db "TIMER0 =" ; Include BG Map Text Data (8 Bytes)

TestTEXT:   db "TEST" ; Include BG Map Text Data (4 Bytes)
PassTEXT:   db "PASS" ; Include BG Map Text Data (4 Bytes)
FailTEXT:   db "FAIL" ; Include BG Map Text Data (4 Bytes)