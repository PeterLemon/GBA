; Game Boy Advance 'Bare Metal' 3D Engine Demo by krom (Peter Lemon):
; Direction Pad Changes Translation X/Y Position
; L/R Buttons X Rotate
; A/B Buttons Y Rotate
; Start/Select Buttons Z Rotate

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
include 'LIB\KEYPAD.INC'
include 'LIB\DMA.INC'
include 'LIB\2D.INC'
include 'LIB\3D.INC'

; Setup Frame Buffer
SCREEN_X       = 240
SCREEN_Y       = 160
BITS_PER_PIXEL = 16

; Setup 3D
HALF_SCREEN_X = (SCREEN_X / 2)
HALF_SCREEN_Y = (SCREEN_Y / 2)

org $8000000
b copycode
times $80000C0-($-0) db 0

macro Control {
  imm32 r0,Matrix3D+12 ; Load Matrix Translation Address To R0 (Starts Of X Translation)

  ldr r1,[r0] ; Load X Translation Variable To R1
  IsKeyDown KEY_LEFT
  subeq r1,256 ; Translate Screen Left  Using Decrements Of 1.0
  IsKeyDown KEY_RIGHT
  addeq r1,256 ; Translate Screen Right Using Increments Of 1.0
  str r1,[r0],16 ; Store Word To Matrix Parameter Table (Screen X Translation) & Increment Matrix Address To R0 (Start Of Y Translation)

  ldr r1,[r0] ; Load Y Translation Variable To R1
  IsKeyDown KEY_UP
  subeq r1,256 ; Translate Screen Up,   In Increments Of 1.0
  IsKeyDown KEY_DOWN
  addeq r1,256 ; Translate Screen Down, In Decrements Of 1.0
  str r1,[r0],16 ; Store Word To Matrix Parameter Table (Screen Y Translation) & Increment Matrix Address To R0 (Start Of Z Translation)

  IsKeyDown KEY_A
  imm32eq r0,YRot ; Load Y Rotate Address To R0
  ldreq r1,[r0] ; Load Y Rotate Word To R1
  addeq r1,1
  andeq r1,255
  streq r1,[r0] ; Store Word To Y Rotate

  IsKeyDown KEY_B
  imm32eq r0,YRot ; Load Y Rotate Address To R0
  ldreq r1,[r0] ; Load Y Rotate Word To R1
  subeq r1,1
  andeq r1,255
  streq r1,[r0] ; Store Word To Y Rotate

  IsKeyDown KEY_R
  imm32eq r0,XRot ; Load X Rotate Address To R0
  ldreq r1,[r0] ; Load X Rotate Word To R1
  addeq r1,1
  andeq r1,255
  streq r1,[r0] ; Store Word To X Rotate

  IsKeyDown KEY_L
  imm32eq r0,XRot ; Load X Rotate Address To R0
  ldreq r1,[r0] ; Load X Rotate Word To R1
  subeq r1,1
  andeq r1,255
  streq r1,[r0] ; Store Word To X Rotate

  IsKeyDown KEY_SELECT
  imm32eq r0,ZRot ; Load Z Rotate Address To R0
  ldreq r1,[r0] ; Load Z Rotate Word To R1
  addeq r1,1
  andeq r1,255
  streq r1,[r0] ; Store Word To Z Rotate

  IsKeyDown KEY_START
  imm32eq r0,ZRot ; Load Z Rotate Address To R0
  ldreq r1,[r0] ; Load Z Rotate Word To R1
  subeq r1,1
  andeq r1,255
  streq r1,[r0] ; Store Word To Z Rotate
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

; Variable Data (IWRAM)
XRot: dw 0 ; X Rotate Word (0..255) (Jump To Correct X Rotation Pre Calculated Table Memory)
YRot: dw 0 ; Y Rotate Word (0..255) (Jump To Correct X Rotation Pre Calculated Table Memory)
ZRot: dw 0 ; Z Rotate Word (0..255) (Jump To Correct X Rotation Pre Calculated Table Memory)

Matrix3D: ; 3D Matrix: Set To Default Identity Matrix (All Numbers Multiplied By 256 For 24.8 Fixed Point Format)
  dw 256, 0, 0, 0 ; X = 1.0, 0.0, 0.0, X Translation = 0.0
  dw 0, 256, 0, 0 ; 0.0, Y = 1.0, 0.0, Y Translation = 0.0
  dw 0, 0, 256, 25600 ; 0.0, 0.0, Z = 1.0, Z Translation = 100.0

LineCache:
  dw 0, 0, 0 ; Cache 1st X, Y, Z Point In Line
  dw 0, 0, 0 ; Cache 2nd X, Y, Z Point In Line
  dw 0, 0, 0 ; Cache 3rd X, Y, Z Point In Line
  dw 0, 0, 0 ; Cache 4th X, Y, Z Point In Line

ScanLeft:  dh SCREEN_Y dup 0 ; Left  Hand Scanline X Buffer (Size Of Screen Y)
ScanRight: dh SCREEN_Y dup 0 ; Right Hand Scanline X Buffer (Size Of Screen Y)

include 'sincos256.asm' ; Matrix Sin & Cos Pre-Calculated Table (256 Rotations)

start:
  mov r0,IO
  mov r1,MODE_3
  orr r1,BG2_ENABLE
  str r1,[r0]

Refresh:
  Control
  XYZRotCalc XRot, YRot, ZRot, SinCos256 ; Combine X,Y,Z Rotation Matrix

  ClearCol $FFFFFFFF, WRAM, 76800 ; Clear Color (32 Bits For CPU Fixed Copy)
  ClearZBuf ; Clear Z-Buffer (Only Required When Using Z-buffer)

  FillQuadCullBack CubeQuad, CubeQuadEnd
  FillTriCullBack PyramidTri, PyramidTriEnd
  LineZBuf GrassLine, GrassLineEnd
  PointZBuf StarPoint, StarPointEnd

  SwapBuffers WRAM, VRAM, 76800 ; Swap Buffers

  b Refresh

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org $80000C0 + (endcopy - IWRAM) + (startcode - copycode)
include 'ReciprocalLUT.asm' ; Reciprocal LUT
include 'objects.asm' ; Objects Data