; Game Boy Advance 'Bare Metal' BIOS Functions Decompress BIT UnPack 4BPP demo by krom (Peter Lemon):

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
include 'LIB\DMA.INC'
include 'LIB\TIMER.INC'

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

  PrintString TitleTEXT, 4096, 29, 4 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString LineBreakTEXT, 4160, 30, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString BIT4BPPTEXT, 4224, 22, 5 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  imm32 r0,BITDestWidth ; Destination Unit Bit Width Pointer Address
  mov r1,4              ; Destination Unit Bit Width
  strb r1,[r0]          ; Store Destination Unit Bit Width

  imm32 r0,DATA4BPP   ; Source
  mov r1,WRAM         ; Destination
  imm32 r2,BITPointer ; Pointer

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

  PrintString InputTEXT, 4420, 5, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString R2TEXT, 4432, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  imm32 r9,VALUE
  str r2,[r9]
  PrintValue VALUE, 4442, 4, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  PrintString TestTEXT, 4466, 4, 3 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString LineBreakTEXT, 4530, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  mov r10,IO ; GBA I/O Base Offset
  orr r11,r10,TM0CNT             ; Timer 0 Control Register
  mov r12,TM_ENABLE or TM_FREQ_1 ; Timer 0 Enable, Frequency/1
  str r12,[r11]                  ; Start Timer 0

  swi $100000 ; BIOS Function

  ldr r10,[r11] ; Load  Timer 0 Value
  imm32 r9,TIMER
  str r10,[r9]  ; Store Timer 0 Value
  mov r12,TM_DISABLE
  str r12,[r11] ; Reset Timer 0 Control

  PrintString OutputTEXT, 4546, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString DATATEXT, 4560, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString DEST4BPPTEXT, 4570, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  mov r0,WRAM       ; Data Address
  imm32 r1,DATA4BPP ; Check Address
  mov r2,1024       ; Count = Data Length / 4
  TestLOOPA:
    ldr r3,[r0],4 ; Load Data Word, Increment Data Offset
    ldr r4,[r1],4 ; Load Check Word, Increment Check Offset
    cmp r3,r4     ; Compare Data To Check
    bne TestFAILA ; IF(Data != Check) FAIL
    subs r2,1     ; Decrement Count
    bne TestLOOPA ; IF(Count != 0) LOOP
    PrintString PassTEXT, 4594, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
    b TestENDA
  TestFAILA:
    PrintString FailTEXT, 4594, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDA:

  PrintString OutputTEXT, 4610, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString TimerTEXT, 4624, 8, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintValue TIMER, 4642, 2, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  imm32 r9,TIMER ; Load Result
  ldr r4,[r9]
  lsl r4,16
  lsr r4,16
  imm16 r9,$B92B ; Load Test Check
  cmp r4,r9      ; Compare Result
  bne TestFAILB  ; IF(Check != Result) FAIL, ELSE PASS
  PrintString PassTEXT, 4658, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  b TestENDB
  TestFAILB:
    PrintString FailTEXT, 4658, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDB:


  imm32 r0,BITDestWidth ; Destination Unit Bit Width Pointer Address
  mov r1,8              ; Destination Unit Bit Width
  strb r1,[r0]          ; Store Destination Unit Bit Width

  imm32 r0,DATA4BPP   ; Source
  mov r1,WRAM         ; Destination
  imm32 r2,BITPointer ; Pointer

  mov r10,IO ; GBA I/O Base Offset
  orr r11,r10,TM0CNT             ; Timer 0 Control Register
  mov r12,TM_ENABLE or TM_FREQ_1 ; Timer 0 Enable, Frequency/1
  str r12,[r11]                  ; Start Timer 0

  swi $100000 ; BIOS Function

  ldr r10,[r11] ; Load  Timer 0 Value
  imm32 r9,TIMER
  str r10,[r9]  ; Store Timer 0 Value
  mov r12,TM_DISABLE
  str r12,[r11] ; Reset Timer 0 Control

  PrintString OutputTEXT, 4674, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString DATATEXT, 4688, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString DEST8BPPTEXT, 4698, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  mov r0,WRAM       ; Data Address
  imm32 r1,DATA8BPP ; Check Address
  mov r2,2048       ; Count = Data Length / 4
  TestLOOPC:
    ldr r3,[r0],4 ; Load Data Word, Increment Data Offset
    ldr r4,[r1],4 ; Load Check Word, Increment Check Offset
    cmp r3,r4     ; Compare Data To Check
    bne TestFAILC ; IF(Data != Check) FAIL
    subs r2,1     ; Decrement Count
    bne TestLOOPC ; IF(Count != 0) LOOP
    PrintString PassTEXT, 4722, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
    b TestENDC
  TestFAILC:
    PrintString FailTEXT, 4722, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDC:

  PrintString OutputTEXT, 4738, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString TimerTEXT, 4752, 8, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintValue TIMER, 4770, 2, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  imm32 r9,TIMER ; Load Result
  ldr r4,[r9]
  lsl r4,16
  lsr r4,16
  imm16 r9,$D52B ; Load Test Check
  cmp r4,r9      ; Compare Result
  bne TestFAILD  ; IF(Check != Result) FAIL, ELSE PASS
  PrintString PassTEXT, 4786, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  b TestENDD
  TestFAILD:
    PrintString FailTEXT, 4786, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDD:


  imm32 r0,BITDestWidth ; Destination Unit Bit Width Pointer Address
  mov r1,16             ; Destination Unit Bit Width
  strb r1,[r0]          ; Store Destination Unit Bit Width

  imm32 r0,DATA4BPP   ; Source
  mov r1,WRAM         ; Destination
  imm32 r2,BITPointer ; Pointer

  mov r10,IO ; GBA I/O Base Offset
  orr r11,r10,TM0CNT             ; Timer 0 Control Register
  mov r12,TM_ENABLE or TM_FREQ_1 ; Timer 0 Enable, Frequency/1
  str r12,[r11]                  ; Start Timer 0

  swi $100000 ; BIOS Function

  ldr r10,[r11] ; Load  Timer 0 Value
  imm32 r9,TIMER
  str r10,[r9]  ; Store Timer 0 Value
  mov r12,TM_DISABLE
  str r12,[r11] ; Reset Timer 0 Control

  PrintString OutputTEXT, 4802, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString DATATEXT, 4816, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString DEST16BPPTEXT, 4826, 5, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  mov r0,WRAM        ; Data Address
  imm32 r1,DATA16BPP ; Check Address
  mov r2,4096        ; Count = Data Length / 4
  TestLOOPE:
    ldr r3,[r0],4 ; Load Data Word, Increment Data Offset
    ldr r4,[r1],4 ; Load Check Word, Increment Check Offset
    cmp r3,r4     ; Compare Data To Check
    bne TestFAILE ; IF(Data != Check) FAIL
    subs r2,1     ; Decrement Count
    bne TestLOOPE ; IF(Count != 0) LOOP
    PrintString PassTEXT, 4850, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
    b TestENDE
  TestFAILE:
    PrintString FailTEXT, 4850, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDE:

  PrintString OutputTEXT, 4866, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString TimerTEXT, 4880, 8, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintValue TIMER, 4898, 2, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  imm32 r9,TIMER ; Load Result
  ldr r4,[r9]
  lsl r4,16
  lsr r4,16
  imm16 r9,$0D2B ; Load Test Check
  cmp r4,r9      ; Compare Result
  bne TestFAILF  ; IF(Check != Result) FAIL, ELSE PASS
  PrintString PassTEXT, 4914, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  b TestENDF
  TestFAILF:
    PrintString FailTEXT, 4914, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDF:


  imm32 r0,BITDestWidth ; Destination Unit Bit Width Pointer Address
  mov r1,32             ; Destination Unit Bit Width
  strb r1,[r0]          ; Store Destination Unit Bit Width

  imm32 r0,DATA4BPP   ; Source
  mov r1,WRAM         ; Destination
  imm32 r2,BITPointer ; Pointer

  mov r10,IO ; GBA I/O Base Offset
  orr r11,r10,TM0CNT             ; Timer 0 Control Register
  mov r12,TM_ENABLE or TM_FREQ_1 ; Timer 0 Enable, Frequency/1
  str r12,[r11]                  ; Start Timer 0

  swi $100000 ; BIOS Function

  ldr r10,[r11] ; Load  Timer 0 Value
  imm32 r9,TIMER
  str r10,[r9]  ; Store Timer 0 Value
  mov r12,TM_DISABLE
  str r12,[r11] ; Reset Timer 0 Control

  PrintString OutputTEXT, 4930, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString DATATEXT, 4944, 4, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString DEST32BPPTEXT, 4954, 5, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number

  mov r0,WRAM        ; Data Address
  imm32 r1,DATA32BPP ; Check Address
  mov r2,8192        ; Count = Data Length / 4
  TestLOOPG:
    ldr r3,[r0],4 ; Load Data Word, Increment Data Offset
    ldr r4,[r1],4 ; Load Check Word, Increment Check Offset
    cmp r3,r4     ; Compare Data To Check
    bne TestFAILG ; IF(Data != Check) FAIL
    subs r2,1     ; Decrement Count
    bne TestLOOPG ; IF(Count != 0) LOOP
    PrintString PassTEXT, 4978, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
    b TestENDG
  TestFAILG:
    PrintString FailTEXT, 4978, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDG:

  PrintString OutputTEXT, 4994, 6, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintString TimerTEXT, 5008, 8, 0 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  PrintValue TIMER, 5026, 2, 2 ; Print Value: Source Address, VRAM Destination, Value Length, Palette Number

  imm32 r9,TIMER ; Load Result
  ldr r4,[r9]
  lsl r4,16
  lsr r4,16
  imm16 r9,$7D2B ; Load Test Check
  cmp r4,r9      ; Compare Result
  bne TestFAILH  ; IF(Check != Result) FAIL, ELSE PASS
  PrintString PassTEXT, 5042, 4, 2 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  b TestENDH
  TestFAILH:
    PrintString FailTEXT, 5042, 4, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number
  TestENDH:


  PrintString LineBreakTEXT, 5056, 30, 1 ; Print String: Source Address, VRAM Destination, String Length, Palette Number


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

Loop:
  b Loop

VALUE: dw 0
TIMER: dw 0

BITPointer:
  dh 4096 ; Source Data Byte Length
  db 4    ; Source Unit Bit Width (1,2,4,8)
BITDestWidth:
  db 4    ; Destination Unit Bit Width (1,2,4,8,16,32)
  dw 0    ; Data Offset (Bit 0..30), Zero Data Flag (Bit 31)

DATA4BPP: file 'DATA4BPP.bin' ; Include 4BPP Data (4096 Bytes)

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org startcode + (endcopy - start)
DATA8BPP:  file 'DATA8BPP.bin'  ; Include  8BPP Data (8192 Bytes)
DATA16BPP: file 'DATA16BPP.bin' ; Include 16BPP Data (16384 Bytes)
DATA32BPP: file 'DATA32BPP.bin' ; Include 16BPP Data (32768 Bytes)

FONTIMG: file 'Font8x8.img'      ; Include BG 4BPP 8x8 Tile Font Character Data (4096 Bytes)
TitleTEXT:     db "GBA BIOS Decompress Functions"  ; Include BG Map Text Data (29 Bytes)
LineBreakTEXT: db "------------------------------" ; Include BG Map Text Data (30 Bytes)
BIT4BPPTEXT:   db "BIT $10 (UnPack 4BPP):"         ; Include BG Map Text Data (22 Bytes)

InputTEXT:     db "INPUT"    ; Include BG Map Text Data (5 Bytes)
OutputTEXT:    db "OUTPUT"   ; Include BG Map Text Data (6 Bytes)
R0TEXT:        db "R0 ="     ; Include BG Map Text Data (4 Bytes)
R1TEXT:        db "R1 ="     ; Include BG Map Text Data (4 Bytes)
R2TEXT:        db "R2 ="     ; Include BG Map Text Data (4 Bytes)
DATATEXT:      db "DATA"     ; Include BG Map Text Data (4 Bytes)
DEST4BPPTEXT:  db "4BPP"     ; Include BG Map Text Data (4 Bytes)
DEST8BPPTEXT:  db "8BPP"     ; Include BG Map Text Data (4 Bytes)
DEST16BPPTEXT: db "16BPP"    ; Include BG Map Text Data (5 Bytes)
DEST32BPPTEXT: db "32BPP"    ; Include BG Map Text Data (5 Bytes)
TimerTEXT:     db "TIMER0 =" ; Include BG Map Text Data (8 Bytes)

TestTEXT:   db "TEST" ; Include BG Map Text Data (4 Bytes)
PassTEXT:   db "PASS" ; Include BG Map Text Data (4 Bytes)
FailTEXT:   db "FAIL" ; Include BG Map Text Data (4 Bytes)