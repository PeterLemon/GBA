; Game Boy Advance 'Bare Metal' BIOS Functions Arithmetic ARCTAN demo by krom (Peter Lemon):

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
include 'LIB\DMA.INC'
include 'LIB\TIMER.INC'

macro PrintString Source, Destination, Length, Palette { ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  local .LoopChar
  imm32 r9,Source       ; Source Address
  mov r10,VRAM          ; Video RAM
  imm32 r11,Destination ; Destination Address
  add r10,r11           ; Video RAM += Destination Address
  mov r11,Length        ; String Length
  mov r12,Palette*4096  ; Palette Number << 12
  .LoopChar:
    ldrb r13,[r9],1  ; Load Character, Increment String Source Address
    orr r13,r12      ; OR Palette Number
    strh r13,[r10],2 ; Store Character To Map Data, Increment VRAM Destination Address
    subs r11,1       ; Decrement String Length, Compare String Length To Zero
    bne .LoopChar    ; IF(String Length != 0) Loop Character
}

macro PrintValue Source, Destination, Length, Palette { ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number
  local .LoopChar
  imm32 r8,Source       ; Source Address
  mov r9,VRAM           ; Video RAM
  imm32 r10,Destination ; Destination Address
  add r9,r10            ; Video RAM += Destination Address
  mov r10,Length-1      ; Value Length - 1
  mov r11,Palette*4096  ; Palette Number << 12
  mov r12,"$"           ; Load Character
  orr r12,r11           ; OR Palette Number
  strh r12,[r9],2       ; Store Character To Map Data, Increment VRAM Destination Address
  .LoopChar:
    ldrb r12,[r8,r10] ; Load Character
    lsr r13,r12,4     ; Hi Nibble
    cmp r13,9         ; Compare Hi Nibble To 9
    addle r13,$30     ; IF(Hi Nibble <= 9) Hi Nibble += ASCII Number
    addgt r13,$37     ; IF(Hi Nibble > 9)  Hi Nibble += ASCII Letter
    orr r13,r11       ; OR Palette Number
    strh r13,[r9],2   ; Store Character To Map Data, Increment VRAM Destination Address
    and r12,$F        ; Lo Nibble
    cmp r12,9         ; Compare Lo Nibble To 9
    addle r12,$30     ; IF(Lo Nibble <= 9) Lo Nibble += ASCII Number
    addgt r12,$37     ; IF(Lo Nibble > 9)  Lo Nibble += ASCII Letter
    orr r12,r11       ; OR Palette Number
    strh r12,[r9],2   ; Store Character To Map Data, Increment VRAM Destination Address
    subs r10,1        ; Decrement Value Length, Compare Value Length To Zero
    bge .LoopChar     ; IF(Value Length >= 0) Loop Character
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

  PrintString TitleTEXT, 4096, 29, 4 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString LineBreakTEXT, 4160, 30, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString ArcTanTEXT, 4224, 25, 5 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  imm32 r0,$FEDCBA98

  PrintString InputTEXT, 4292, 5, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString R0TEXT, 4304, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  imm32 r9,VALUE
  str r0,[r9]
  PrintValue VALUE, 4314, 4, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  PrintString TestTEXT, 4338, 4, 3 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString LineBreakTEXT, 4402, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  mov r10,IO ; GBA I/O Base Offset
  orr r11,r10,TM0CNT             ; Timer 0 Control Register
  mov r12,TM_ENABLE or TM_FREQ_1 ; Timer 0 Enable, Frequency/1
  str r12,[r11]                  ; Start Timer 0

  swi $090000 ; BIOS Function

  ldr r10,[r11] ; Load  Timer 0 Value
  imm32 r9,TIMER
  str r10,[r9]  ; Store Timer 0 Value
  mov r12,TM_DISABLE
  str r12,[r11] ; Reset Timer 0 Control

  PrintString OutputTEXT, 4418, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString R0TEXT, 4432, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  imm32 r9,VALUE
  str r0,[r9]
  PrintValue VALUE, 4442, 4, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  imm32 r9,$FFFFE024 ; Load Test Check
  cmp r0,r9          ; Compare Result
  bne TestFAILA      ; IF(Check != Result) FAIL, ELSE PASS
  PrintString PassTEXT, 4466, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  b TestENDA
  TestFAILA:
    PrintString FailTEXT, 4466, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDA:

  PrintString OutputTEXT, 4482, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString TimerTEXT, 4496, 8, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintValue TIMER, 4514, 2, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  imm32 r9,TIMER ; Load Result
  ldr r4,[r9]
  lsl r4,16
  lsr r4,16
  imm16 r9,$006A ; Load Test Check
  cmp r4,r9      ; Compare Result
  bne TestFAILB  ; IF(Check != Result) FAIL, ELSE PASS
  PrintString PassTEXT, 4530, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  b TestENDB
  TestFAILB:
    PrintString FailTEXT, 4530, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDB:


  PrintString LineBreakTEXT, 4544, 30, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  PrintString ArcTan2TEXT, 4608, 28, 5 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

;  imm32 r0,$FEDCBA98
;  imm32 r1,$12345678

;  PrintString InputTEXT, 4676, 5, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  PrintString R0TEXT, 4688, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  imm32 r9,VALUE
;  str r0,[r9]
;  PrintValue VALUE, 4698, 4, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

;  PrintString InputTEXT, 4740, 5, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  PrintString R1TEXT, 4752, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  imm32 r9,VALUE
;  str r1,[r9]
;  PrintValue VALUE, 4762, 4, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

;  PrintString TestTEXT, 4786, 4, 3 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  PrintString LineBreakTEXT, 4850, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

;  mov r10,IO ; GBA I/O Base Offset
;  orr r11,r10,TM0CNT             ; Timer 0 Control Register
;  mov r12,TM_ENABLE or TM_FREQ_1 ; Timer 0 Enable, Frequency/1
;  str r12,[r11]                  ; Start Timer 0

;  swi $0A0000 ; BIOS Function

;  ldr r10,[r11] ; Load  Timer 0 Value
;  imm32 r9,TIMER
;  str r10,[r9]  ; Store Timer 0 Value
;  mov r12,TM_DISABLE
;  str r12,[r11] ; Reset Timer 0 Control

;  PrintString OutputTEXT, 4866, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  PrintString R0TEXT, 4880, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  imm32 r9,VALUE
;  str r0,[r9]
;  PrintValue VALUE, 4890, 4, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

;  imm32 r9,$00003FFF ; Load Test Check
;  cmp r0,r9          ; Compare Result
;  bne TestFAILC      ; IF(Check != Result) FAIL, ELSE PASS
;  PrintString PassTEXT, 4914, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  b TestENDC
;  TestFAILC:
;    PrintString FailTEXT, 4914, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  TestENDC:

;  PrintString OutputTEXT, 4930, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  PrintString TimerTEXT, 4944, 8, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  PrintValue TIMER, 4962, 2, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

;  imm32 r9,TIMER ; Load Result
;  ldr r4,[r9]
;  lsl r4,16
;  lsr r4,16
;  imm16 r9,$006A ; Load Test Check
;  cmp r4,r9      ; Compare Result
;  bne TestFAILD  ; IF(Check != Result) FAIL, ELSE PASS
;  PrintString PassTEXT, 4978, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  b TestENDD
;  TestFAILD:
;    PrintString FailTEXT, 4978, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
;  TestENDD:


;  PrintString LineBreakTEXT, 4992, 30, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

Loop:
  b Loop

VALUE: dw 0
TIMER: dw 0

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org $80000C0 + (endcopy - IWRAM) + (startcode - copycode)
FONTIMG: file 'Font8x8.img'      ; Include BG 4BPP 8x8 Tile Font Character Data (4096 Bytes)
TitleTEXT:     db "GBA BIOS Arithmetic Functions"  ; Include BG Map Text Data (29 Bytes)
LineBreakTEXT: db "------------------------------" ; Include BG Map Text Data (30 Bytes)
ArcTanTEXT:    db "ARCTAN $09 (Arc Tangent):"      ; Include BG Map Text Data (25 Bytes)
;ArcTan2TEXT:   db "ARCTAN2 $0A (Arc Tangent 2):"   ; Include BG Map Text Data (28 Bytes)

InputTEXT:  db "INPUT"    ; Include BG Map Text Data (5 Bytes)
OutputTEXT: db "OUTPUT"   ; Include BG Map Text Data (6 Bytes)
R0TEXT:     db "R0 ="     ; Include BG Map Text Data (4 Bytes)
R1TEXT:     db "R1 ="     ; Include BG Map Text Data (4 Bytes)
TimerTEXT:  db "TIMER0 =" ; Include BG Map Text Data (8 Bytes)

TestTEXT:   db "TEST" ; Include BG Map Text Data (4 Bytes)
PassTEXT:   db "PASS" ; Include BG Map Text Data (4 Bytes)
FailTEXT:   db "FAIL" ; Include BG Map Text Data (4 Bytes)