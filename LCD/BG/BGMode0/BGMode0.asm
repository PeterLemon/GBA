; Game Boy Advance 'Bare Metal' BG Mode 0 Scroll Demo by krom (Peter Lemon):
; Direction Pad Changes BG X/Y Position
; L/R Buttons Rotate BG Anti-Clockwise/Clockwise
; A/B Buttons Zoom BG Out/In
; Start Button Changes Mosaic Level
; Select Button Resets To Default Settings

format binary as 'gba'
org $8000000
include 'LIB\FASMARM.INC' ; Include FASMARM Macros
include 'LIB\GBA.INC' ; Include GBA Definitions
include 'LIB\GBA_DMA.INC' ; Include GBA DMA Macros
include 'LIB\GBA_KEYPAD.INC' ; Include GBA Keypad Macros
include 'LIB\GBA_LCD.INC' ; Include GBA LCD Macros
include 'LIB\GBA_HEADER.ASM' ; Include GBA Header & ROM Entry Point

macro Control { ; Macro To Handle Control Input
  mov r0,BGSource ; R0 = Address Of Parameter Table
  mov r1,IO ; R1 = GBA I/O Base Offset
  ldr r2,[r1,KEYINPUT] ; R2 = Key Input

  ; Move Left & Right
  ldrh r3,[r0,0] ; R3 = X Offset
  tst r2,KEY_RIGHT ; Test Right Direction Pad Button
  addeq r3,1 ; IF (Right Pressed) X Offset ++
  tst r2,KEY_LEFT ; Test Left Direction Pad Button
  subeq r3,1 ; IF (Left Pressed) X Offset --
  strh r3,[r1,BG2HOFS] ; Store X Offset To BG2 X-Offset Register
  strh r3,[r0,0] ; Stores X Offset To Parameter Table

  ; Move Up & Down
  ldrh r3,[r0,2] ; R3 = Y Offset
  tst r2,KEY_DOWN ; Test Down Direction Pad Button
  addeq r3,1 ; IF (Down Pressed) Y Offset ++
  tst r2,KEY_UP ; Test Up Direction Pad Button
  subeq r3,1 ; IF (Up Pressed) Y Offset --
  strh r3,[r1,BG2VOFS] ; Store Y Offset To BG2 Y-Offset Register
  strh r3,[r0,2] ; Stores Y Offset To Parameter Table

  ; Mosaic Level Increased IF Start Pressed
  ldrh r3,[r0,4] ; R3 = Mosaic Variable
  tst r2,KEY_START ; Test Start Button
  addeq r3,17 ; IF (Start Pressed) Mosaic += 17 (X & Y Size At Same Time)
  cmp r3,255 ; IF (Mosaic > 255) (255 = Full X & Y Mosaic Resolution)
  movgt r3,0 ; Mosaic = 0 (Mosaic Reset)
  strh r3,[r1,MOSAIC] ; Store Mosaic Amount To Mosaic Register
  strh r3,[r0,4] ; Store Mosaic Amount To Parameter Table

  ; Reset IF Select Pressed
  tst r2,KEY_SELECT ; Test Select Button
  bne ControlResetEnd ; IF (Select Not Pressed) Skip To ControlResetEnd
  mov r3,$0000 ; R3 = Default Screen X/Y Offset & Mosaic Amount
  strh r3,[r0,0] ; Store Default Screen X Offset To Parameter Table
  strh r3,[r0,2] ; Store Default Screen Y Offset To Parameter Table
  strh r3,[r0,4] ; Store Default Mosaic To Parameter Table
  ControlResetEnd:
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
  strh r1,[r0,BG2CNT]

  DMA32 BGPAL, VPAL, 128 ; DMA BG Palette To Color Mem
  DMA32 BGIMG, VRAM, 6416 ; DMA BG Image To VRAM
  DMA32 BGMAP, VRAM+26624, 2048 ; DMA BG Map To VRAM

Loop:
    VBlank  ; Wait Until VBlank
    Control ; Update BG According To Controls
    b Loop

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org startcode + (endcopy - IWRAM)
BGIMG: file 'BG.img' ; Include BG Image Data (25664 Bytes)
BGMAP: file 'BG.map' ; Include BG Map Data (8192 Bytes)
BGPAL: file 'BG.pal' ; Include BG Palette Data (512 Bytes)