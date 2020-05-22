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

macro Control { ; Macro To Handle Control Input
  mov r0,BGAffineSource ; R0 = Address Of Parameter Table
  mov r1,IO ; R1 = GBA I/O Base Offset
  ldr r2,[r1,KEYINPUT] ; R2 = Key Input

  ; Move Left & Right
  ldrh r3,[r0,8] ; R3 = X Center
  tst r2,KEY_RIGHT ; Test Right Direction Pad Button
  addeq r3,4 ; IF (Right Pressed) X Center += 4
  tst r2,KEY_LEFT ; Test Left Direction Pad Button
  subeq r3,4 ; IF (Left Pressed) X Center -= 4
  strh r3,[r0,8] ; Stores X Center To Parameter Table (Screen X Of Center)

  ; Move Up & Down
  ldrh r3,[r0,10] ; R3 = Y Center
  tst r2,KEY_DOWN ; Test Down Direction Pad Button
  addeq r3,4 ; IF (Down Pressed) Y Center += 4
  tst r2,KEY_UP ; Test Up Direction Pad Button
  subeq r3,4 ; IF (Up Pressed) Y Center -= 4
  strh r3,[r0,10] ; Stores Y Center To Parameter Table (Screen Y Of Center)

  ; Zoom On A & B (X & Y Zoom Is Equal)
  ldrh r3,[r0,12] ; R3 = Zoom Variable
  tst r2,KEY_A ; Test A Button
  addeq r3,4 ; IF (A Pressed) Zoom += 4
  tst r2,KEY_B ; Test B Button
  subeq r3,4 ; IF (B Pressed) Zoom -= 4
  cmp r3,0 ; IF (Zoom <= 0)
  movle r3,4 ; Zoom = 4
  strh r3,[r0,12] ; Store Zoom To Parameter Table (X Scale Factor)
  strh r3,[r0,14] ; Store Zoom To Parameter Table (Y Scale Factor)

  ; Rotate On L & R
  ldrh r3,[r0,16] ; R3 = Rotation Variable
  tst r2,KEY_L ; Test L Button
  addeq r3,512 ; IF (L Pressed) Rotate += 512 (Anti-Clockwise)
  tst r2,KEY_R ; Test R Button
  subeq r3,512 ; IF (R Pressed) Rotate -= 512 (Clockwise)
  strh r3,[r0,16] ; Store Rotate To Parameter Table (Rotation)

  ; Mosaic Level Increased IF Start Pressed
  ldrh r3,[r0,18] ; R3 = Mosaic Variable
  tst r2,KEY_START ; Test Start Button
  addeq r3,17 ; IF (Start Pressed) Mosaic += 17 (X & Y Size At Same Time)
  cmp r3,255 ; IF (Mosaic > 255) (255 = Full X & Y Mosaic Resolution)
  movgt r3,0 ; Mosaic = 0 (Mosaic Reset)
  strh r3,[r1,MOSAIC] ; Store Mosaic Amount To Mosaic Register
  strh r3,[r0,18] ; Store Mosaic Amount To Parameter Table (Mosaic Amount)

  ; Reset IF Select Pressed
  tst r2,KEY_SELECT ; Test Select Button
  bne ControlResetEnd ; IF (Select Not Pressed) Skip To ControlResetEnd
  mov r3,$00007800 ; R3 = Default Screen Center X
  str r3,[r0,0] ; Store Screen Center X To Parameter Table
  mov r3,$00005000 ; R3 = Default Screen Center Y
  str r3,[r0,4] ; Store Screen Center Y To Parameter Table
  mov r3,$0078 ; R3 = Default Screen X Of Center
  strh r3,[r0,8] ; Store Screen X Of Center To Parameter Table
  mov r3,$0050 ; R3 = Default Screen Y Of Center
  strh r3,[r0,10] ; Store Screen Y Of Center To Parameter Table
  mov r3,$0100 ; R3 = Default Screen X/Y Scale Factor
  strh r3,[r0,12] ; Store Default Screen X Scale Factor To Parameter Table
  strh r3,[r0,14] ; Store Default Screen Y Scale Factor To Parameter Table
  mov r3,$0000 ; R3 = Default Rotation & Mosaic Amount
  strh r3,[r0,16] ; Store Default Rotation To Parameter Table
  strh r3,[r0,18] ; Store Default Mosaic To Parameter Table
  ControlResetEnd:

  orr r1,BG2PA ; Update BG Parameters
  mov r2,1 ; (BIOS Call Requires R0 To Point To Parameter Table)
  swi $0E0000 ; Bios Call To Calculate All The Correct BG Parameters According To The Controls
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
org startcode + (endcopy - IWRAM)
BGIMG: file 'BG.img' ; Include BG Image Data (76800 Bytes)