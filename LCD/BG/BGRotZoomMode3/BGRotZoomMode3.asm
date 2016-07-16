; Game Boy Advance 'Bare Metal' BG Mode 3 Rotate & Zoom Demo by krom (Peter Lemon):
; Direction Pad Changes BG X/Y Position
; L/R Buttons Rotate BG Anti-Clockwise/Clockwise
; A/B Buttons Zoom BG Out/In
; Start Button Changes Mosaic Level
; Select Button Resets To Default Settings

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
include 'LIB\KEYPAD.INC'
include 'LIB\DMA.INC'
org $8000000
b copycode
times $80000C0-($-0) db 0

macro Control { ; - Macro to handle all control input
  mov r0,IO ; GBA I/O Base Offset
  ldr r1,[r0,KEYINPUT] ; R1 = Key Input
  mov r0,BGAffineSource ; R0 = Address Of Parameter Table

  ; Move Left & Right
  ldrh r2,[r0,8] ; R2 = X Center
  ands r3,r1,#KEY_RIGHT ; Test Right Direction Pad Button
  addeq r2,r2,$0004 ; IF (Right Pressed) X Center += 4
  ands r3,r1,#KEY_LEFT ; Test Left Direction Pad Button
  subeq r2,r2,$0004 ; IF (Left Pressed) X Center -= 4
  strh r2,[r0,8] ; Stores X Center To Parameter Table (Screen X Of Center)

  ; Move Up & Down
  ldrh r2,[r0,10] ; R2 = Y Center
  ands r3,r1,#KEY_DOWN ; Test Down Direction Pad Button
  addeq r2,r2,$0004 ; IF (Down Pressed) Y Center += 4
  ands r3,r1,#KEY_UP ; Test Up Direction Pad Button
  subeq r2,r2,$0004 ; IF (Up Pressed) Y Center -= 4
  strh r2,[r0,10] ; Stores Y Center To Parameter Table (Screen Y Of Center)

  ; Zoom On A & B (X & Y Zoom Is Equal)
  ldrh r2,[r0,12] ; R2 = Zoom Variable
  ands r3,r1,#KEY_A ; Test A Button
  addeq r2,r2,$0004 ; IF (A Pressed) Zoom += 4
  ands r3,r1,#KEY_B ; Test B Button
  subeq r2,r2,$0004 ; IF (B Pressed) Zoom -= 4
  cmp r2,0 ; IF (Zoom <= 0)
  movle r2,$0004 ; Zoom = 4
  strh r2,[r0,12] ; Store Zoom To Parameter Table (X Scale Factor)
  strh r2,[r0,14] ; Store Zoom To Parameter Table (Y Scale Factor)

  ; Rotate On L & R
  ldrh r2,[r0,16] ; R2 = Rotation Variable
  ands r3,r1,#KEY_L ; Test L Button
  addeq r2,r2,$0200 ; IF (L Pressed) Rotate += 512 (Anti-Clockwise)
  ands r3,r1,#KEY_R ; Test R Button
  subeq r2,r2,$0200 ; IF (R Pressed) Rotate -= 512 (Clockwise)
  strh r2,[r0,16] ; Store Rotate To Parameter Table (Rotation)

  ; Mosaic Level Increased IF Start Pressed
  ldrh r2,[r0,18] ; R2 = Mosaic Variable
  mov r3,IO ; GBA I/O Base Offset
  add r3,MOSAIC ; R3 = Mosaic Register
  ands r4,r1,#KEY_START ; Test Start Button
  addeq r2,r2,$0011 ; IF (Start Pressed) Mosaic += 17 (X & Y Size At Same Time)
  cmp r2,255 ; IF (Mosaic > 255) (255 = Full X & Y Mosaic Resolution)
  movgt r2,$0000 ; Mosaic = 0 (Mosaic Reset)
  strh r2,[r3,0] ; Store Mosaic Amount To Mosaic Register
  strh r2,[r0,18] ; Store Mosaic Amount To Parameter Table (Mosaic Amount)

  ; Reset IF Select Pressed
  ands r2,r1,#KEY_SELECT ; Test Select Button
  bne ControlResetEnd ; IF (Select Not Pressed) Skip To ControlResetEnd
  mov r2,$00007800 ; R2 = Default Screen Center X
  str r2,[r0,0] ; Store Screen Center X To Parameter Table
  mov r2,$00005000 ; R2 = Default Screen Center Y
  str r2,[r0,4] ; Store Screen Center Y To Parameter Table
  mov r2,$0078 ; R2 = Default Screen X Of Center
  strh r2,[r0,8] ; Store Screen X Of Center To Parameter Table
  mov r2,$0050 ; R2 = Default Screen Y Of Center
  strh r2,[r0,10] ; Store Screen Y Of Center To Parameter Table
  mov r2,$0100 ; R2 = Default Screen X & Y Scale Factor
  strh r2,[r0,12] ; Store Default Screen X Scale Factor To Parameter Table
  strh r2,[r0,14] ; Store Default Screen Y Scale Factor To Parameter Table
  mov r2,$0000 ; R2 = Default Rotation & Mosaic Amount
  strh r2,[r0,16] ; Store Default Rotation To Parameter Table
  strh r2,[r0,18] ; Store Default Mosaic To Parameter Table
  ControlResetEnd:

  mov r1,IO ; GBA I/O Base Offset
  orr r1,BG2PA ; Update BG Parameters
  mov r2,1 ; (BIOS Call Requires R0 To Point To Parameter Table)
  swi $0E0000 ; Bios Call To Calculate All The Correct BG Parameters According To The Controls
}

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

; Variable Data
BGAffineSource: ; Memory Area Used To Set BG Affine Transformations Using BIOS Call
  ; Center Of Rotation In Original Image (Last 8-Bits Fractional)
  dw $00007800 ; X
  dw $00005000 ; Y
  ; Center Of Rotation On Screen
  dh $0078 ; X
  dh $0050 ; Y
  ; Scaling Ratios (Last 8-Bits Fractional)
  dh $0100 ; X
  dh $0100 ; Y
  ; Angle Of Rotation ($0000..$FFFF Anti-Clockwise)
  dh $0000
  ; Mosaic Amount
  dh $0000

start:
  mov r0,IO
  mov r1,MODE_3
  orr r1,BG2_ENABLE
  str r1,[r0]

  mov r1,0000000001000000b ; Enable Mosaic
  str r1,[r0,BG2CNT]

  imm16 r1,$4E73 ; R1 = BG Color (Gray)
  mov r2,VPAL ; Load BG Palette Address
  strh r1,[r2] ; Store BG Color To BG Palette

  DMA32 BGIMG, VRAM, 19200 ; DMA BG Image To VRAM

Loop:
    VBlank  ; Wait Until VBlank
    Control ; Update BG According To Controls
    b Loop

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org $80000C0 + (endcopy - IWRAM) + (startcode - copycode)
BGIMG: file 'BG.img' ; Include BG Image Data (76800 Bytes)