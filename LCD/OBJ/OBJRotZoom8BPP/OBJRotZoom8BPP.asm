; Game Boy Advance 'Bare Metal' OBJ/Sprite 8BPP Rotate & Zoom Demo by krom (Peter Lemon):
; L/R Buttons Rotate OBJ Anti-Clockwise/Clockwise
; A/B Buttons Zoom OBJ Out/In
; Start Button Changes Mosaic Level
; Select Button Resets To Default Settings

format binary as 'gba'
org $8000000
include 'LIB\FASMARM.INC' ; Include FASMARM Macros
include 'LIB\GBA.INC' ; Include GBA Definitions
include 'LIB\GBA_DMA.INC' ; Include GBA DMA Macros
include 'LIB\GBA_KEYPAD.INC' ; Include GBA Keypad Macros
include 'LIB\GBA_LCD.INC' ; Include GBA LCD Macros
include 'LIB\GBA_OBJ.INC' ; Include GBA Object Macros
include 'LIB\GBA_HEADER.ASM' ; Include GBA Header & ROM Entry Point

macro Control { ; Macro To Handle Control Input
  mov r0,OBJAffineSource ; R0 = Address Of Parameter Table
  mov r1,IO ; R1 = GBA I/O Base Offset
  ldr r2,[r1,KEYINPUT] ; R2 = Key Input

  ; Zoom On A & B (X & Y Zoom Is Equal)
  ldrh r3,[r0,0] ; R3 = Zoom Variable
  tst r2,KEY_A ; Test A Button
  addeq r3,4 ; IF (A Pressed) Zoom += 4
  tst r2,KEY_B ; Test B Button
  subeq r3,4 ; IF (B Pressed) Zoom -= 4
  cmp r3,0 ; IF (Zoom <= 0)
  movle r3,4 ; Zoom = 4
  strh r3,[r0,0] ; Store Zoom To Parameter Table (X Scale Factor)
  strh r3,[r0,2] ; Store Zoom To Parameter Table (Y Scale Factor)

  ; Rotate On L & R
  ldrh r3,[r0,4] ; R3 = Rotation Variable
  tst r2,KEY_L ; Test L Button
  addeq r3,512 ; IF (L Pressed) Rotate += 512 (Anti-Clockwise)
  tst r2,KEY_R ; Test R Button
  subeq r3,512 ; IF (R Pressed) Rotate -= 512 (Clockwise)
  strh r3,[r0,4] ; Store Rotate To Parameter Table (Rotation)

  ; Mosaic Level Increased IF Start Pressed
  ldrh r3,[r0,6] ; R3 = Mosaic Variable
  tst r2,KEY_START ; Test Start Button
  addeq r3,$1100 ; IF (Start Pressed) Mosaic += 17 (X & Y Size At Same Time)
  cmp r3,$FF00 ; IF (Mosaic > 65280) (65280 = Full X & Y Mosaic Resolution)
  movgt r3,0 ; Mosaic = 0 (Mosaic Reset)
  strh r3,[r1,MOSAIC] ; Store Mosaic Amount To Mosaic Register
  strh r3,[r0,6] ; Store Mosaic Amount To Parameter Table (Mosaic Amount)

  ; Reset IF Select Pressed
  tst r2,KEY_SELECT ; Test Select Button
  bne ControlResetEnd ; IF (Select Not Pressed) Skip To ControlResetEnd
  mov r3,$0100 ; R3 = Default Screen X/Y Scale Factor
  strh r3,[r0,0] ; Store Default Screen X Scale Factor To Parameter Table
  strh r3,[r0,2] ; Store Default Screen Y Scale Factor To Parameter Table
  mov r3,$0000 ; R3 = Default Rotation & Mosaic Amount
  strh r3,[r0,4] ; Store Default Rotation To Parameter Table
  strh r3,[r0,6] ; Store Default Mosaic To Parameter Table
  ControlResetEnd:

  imm32 r1,PA_0 ; Update OBJ Parameters
  mov r2,1 ; (BIOS Call Requires R0 To Point To Parameter Table)
  mov r3,8 ; R3 Set To Make Structure Inline With OAM
  swi $0F0000 ; Bios Call To Calculate All The Correct OAM Parameters According To The Controls
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
OBJAffineSource: ; Memory Area Used To Set OBJ Affine Transformations Using BIOS Call
  ; Scaling Ratios (Last 8-Bits Fractional)
  dh $0100 ; X
  dh $0100 ; Y
  ; Angle Of Rotation ($0000..$FFFF Anti-Clockwise)
  dh $0000
  ; Mosaic Amount
  dh $0000

start:
  InitOBJ ; Initialize Sprites

  mov r0,IO
  imm32 r1,MODE_0+BG2_ENABLE+OBJ_ENABLE+OBJ_MAP_1D
  str r1,[r0]

  mov r1,OAM ; R1 = OAM ($7000000)

  ; Sprite 16x32
  imm32 r2,(TALL+COLOR_256+0+OBJ_MOSAIC+SIZE_DOUBLE+ROTATION_FLAG)+((SIZE_32+16) * 65536) ; R2 = Attributes 0 & 1
  str r2,[r1],4 ; Store Attributes 0 & 1 To OAM, Increment OAM Address To Attribute 2
  mov r2,0      ; R2 = Attribute 2 (Tile Number 0)
  str r2,[r1],4 ; Store Attribute 2 To OAM

  ; Sprite 32x16
  imm32 r2,(WIDE+COLOR_256+16+OBJ_MOSAIC+SIZE_DOUBLE+ROTATION_FLAG)+((SIZE_32+88) * 65536) ; R2 = Attributes 0 & 1
  str r2,[r1],4 ; Store Attributes 0 & 1 To OAM, Increment OAM Address To Attribute 2
  mov r2,$10    ; R2 = Attribute 2 (Tile Number 16)
  str r2,[r1],4 ; Store Attribute 2 To OAM

  ; Sprite 32x32
  imm32 r2,(SQUARE+COLOR_256+0+OBJ_MOSAIC+SIZE_DOUBLE+ROTATION_FLAG)+((SIZE_32+176) * 65536) ; R2 = Attributes 0 & 1
  str r2,[r1],4 ; Store Attributes 0 & 1 To OAM, Increment OAM Address To Attribute 2
  mov r2,$20    ; R2 = Attribute 2 (Tile Number 32)
  str r2,[r1],4 ; Store Attribute 2 To OAM

  ; Sprite 32x64
  imm32 r2,(TALL+COLOR_256+32+OBJ_MOSAIC+SIZE_DOUBLE+ROTATION_FLAG)+((SIZE_64+0) * 65536) ; R2 = Attributes 0 & 1
  str r2,[r1],4 ; Store Attributes 0 & 1 To OAM, Increment OAM Address To Attribute 2
  mov r2,$40    ; R2 = Attribute 2 (Tile Number 64)
  str r2,[r1],4 ; Store Attribute 2 To OAM

  ; Sprite 64x32
  imm32 r2,(WIDE+COLOR_256+64+OBJ_MOSAIC+SIZE_DOUBLE+ROTATION_FLAG)+((SIZE_64+56) * 65536) ; R2 = Attributes 0 & 1
  str r2,[r1],4 ; Store Attributes 0 & 1 To OAM, Increment OAM Address To Attribute 2
  mov r2,$80    ; R2 = Attribute 2 (Tile Number 128)
  str r2,[r1],4 ; Store Attribute 2 To OAM

  ; Sprite 64x64
  imm32 r2,(SQUARE+COLOR_256+32+OBJ_MOSAIC+SIZE_DOUBLE+ROTATION_FLAG)+((SIZE_64+144) * 65536) ; R2 = Attributes 0 & 1
  str r2,[r1],4 ; Store Attributes 0 & 1 To OAM, Increment OAM Address To Attribute 2
  mov r2,$C0    ; R2 = Attribute 2 (Tile Number 192)
  str r2,[r1]   ; Store Attribute 2 To OAM

  imm16 r1,$4E73 ; R1 = BG Color (Gray)
  mov r2,VPAL ; Load BG Palette Address
  strh r1,[r2] ; Store BG Color To BG Palette

  DMA32 SpritePAL, OBJPAL, 8 ; DMA OBJ Palette To Color Mem
  DMA32 SpriteIMG, CHARMEM, 2560 ; DMA OBJ Image Data To VRAM

Loop:
    VBlank  ; Wait Until VBlank
    Control ; Update OBJ According To Controls
    b Loop

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org startcode + (endcopy - IWRAM)
SpriteIMG: ; Include Sprite Image Data (10240 Bytes)
  file 'Sprite16x32.img' ; Include Sprite Image Data (512 Bytes)
  file 'Sprite32x16.img' ; Include Sprite Image Data (512 Bytes)
  file 'Sprite32x32.img' ; Include Sprite Image Data (1024 Bytes)
  file 'Sprite32x64.img' ; Include Sprite Image Data (2048 Bytes)
  file 'Sprite64x32.img' ; Include Sprite Image Data (2048 Bytes)
  file 'Sprite64x64.img' ; Include Sprite Image Data (4096 Bytes)
SpritePAL: file 'Sprite.pal' ; Include Sprite Pallete (32 Bytes)