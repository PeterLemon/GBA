; Game Boy Advance 'Bare Metal' BG Mode 0 Scroll Demo by krom (Peter Lemon):
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

macro Control { ; Macro to handle all control input
  mov r0,IO ; R0 = GBA I/O Base Offset
  ldr r1,[r0,KEYINPUT] ; R1 = Key Input
  mov r2,BGSource ; R2 = Address Of Parameter Table

  ; Move Left & Right
  ldrh r3,[r2,0] ; R3 = X Offset
  tst r1,KEY_RIGHT ; Test Right Direction Pad Button
  addeq r3,1 ; IF (Right Pressed) X Offset ++
  tst r1,KEY_LEFT ; Test Left Direction Pad Button
  subeq r3,1 ; IF (Left Pressed) X Offset --
  strh r3,[r0,BG2HOFS] ; Store X Offset To BG2 X-Offset Register
  strh r3,[r2,0] ; Stores X Offset To Parameter Table

  ; Move Up & Down
  ldrh r3,[r2,2] ; R3 = Y Offset
  tst r1,KEY_DOWN ; Test Down Direction Pad Button
  addeq r3,1 ; IF (Down Pressed) Y Offset ++
  tst r1,KEY_UP ; Test Up Direction Pad Button
  subeq r3,1 ; IF (Up Pressed) Y Offset --
  strh r3,[r0,BG2VOFS] ; Store Y Offset To BG2 Y-Offset Register
  strh r3,[r2,2] ; Stores Y Offset To Parameter Table

  ; Mosaic Level Increased IF Start Pressed
  ldrh r3,[r2,4] ; R3 = Mosaic Variable
  tst r1,KEY_START ; Test Start Button
  addeq r3,17 ; IF (Start Pressed) Mosaic += 17 (X & Y Size At Same Time)
  cmp r3,$FF ; IF (Mosaic > 255) (255 = Full X & Y Mosaic Resolution)
  movgt r3,0 ; Mosaic = 0 (Mosaic Reset)
  strh r3,[r0,MOSAIC] ; Store Mosaic Amount To Mosaic Register
  strh r3,[r2,4] ; Store Mosaic Amount To Parameter Table

  ; Reset IF Select Pressed
  tst r1,KEY_SELECT ; Test Select Button
  bne ControlResetEnd ; IF (Select Not Pressed) Skip To ControlResetEnd
  mov r3,$0000 ; R3 = Default Screen X/Y Offset & Mosaic Amount
  strh r3,[r2,0] ; Store Default Screen X Offset To Parameter Table
  strh r3,[r2,2] ; Store Default Screen Y Offset To Parameter Table
  strh r3,[r2,4] ; Store Default Mosaic To Parameter Table
  ControlResetEnd:
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
BGSource: ; Memory Area Used To Set BG Screen Offset & Mosaic
  ; X/Y BG Screen Offset
  dh $0000 ; X Offset
  dh $0000 ; Y Offset
  ; Mosaic Amount
  dh $0000

align 4
start:
  mov r0,IO
  mov r1,MODE_0
  orr r1,BG2_ENABLE
  str r1,[r0]

  imm16 r1,1100110111000000b ; BG Tile Offset = 0, Enable Mosaic, Tiles 8BPP, BG Map Offset = 26624, Map Size = 64x64 Tiles
  str r1,[r0,BG2CNT]

  DMA32 BGPAL, VPAL, 128 ; DMA BG Palette To Color Mem
  DMA32 BGIMG, VRAM, 6416 ; DMA BG Image To VRAM
  DMA32 BGMAP, VRAM+26624, 2048 ; DMA BG Map To VRAM

Loop:
    VBlank  ; Wait Until VBlank
    Control ; Update BG According To Controls
    b Loop

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org $80000C0 + (endcopy - IWRAM) + (startcode - copycode)
BGIMG: file 'BG.img' ; Include BG Image Data (25664 Bytes)
BGMAP: file 'BG.map' ; Include BG Map Data (8192 Bytes)
BGPAL: file 'BG.pal' ; Include BG Palette Data (512 Bytes)