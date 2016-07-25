; Game Boy Advance 'Bare Metal' BG Mode 7 H-Blank DMA Demo by krom (Peter Lemon):
; Special Thanks To Cearn For The Tonc Mode7 Tutorials
; Direction Pad Changes BG Mode7 X/Z Position
; A/B Buttons Changes BG Mode7 Y Position (Height)
; L/R Buttons Rotate BG Mode7 Clockwise/Anti-Clockwise
; Select/Start Buttons Changes BG Mode7 FOV (Mode7 Distance)

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
include 'LIB\KEYPAD.INC'
include 'LIB\DMA.INC'
org $8000000
b copycode
times $80000C0-($-0) db 0

macro MODE7Calc { ; Macro To Calculate Mode7 Scanline (R12 = Scanline)
  local .WaitScanline
  mov r0,IO ; R0 = GBA I/O Base Offset
  .WaitScanline: ; Label loop to wait the correct amount of scanlines
    ldrh r1,[r0,VCOUNT] ; R1 = Current LCD Scanline Position
    cmp r1,r12 ; Compare To Scanline
    bne .WaitScanline ; IF (Scanline != Amount) Wait Scanline

  ; --- Type C ---
  ; (Offset * Zoom) * Rotation
  ; Mixed Fixed Point: lam, lxr, lyr Use .12
  ; lxr & lyr Have Different Calculation Methods

  ; lam = int(cam_pos_y * DIVLUT(REG_VCOUNT)) >> 12 ; .8 * .16 / .12 = .12 = 20.12
  mov r1,M7_D
  add r2,r1,24 ; R2 = Division LUT
  lsl r3,r12,1 ; R3 = R12 * 2 (Division LUT Offset)
  ldrh r2,[r2,r3] ; R2 = DIVLUT(REG_VCOUNT)

  ldr r3,[r1,8] ; R3 = cam_pos_y
  mul r2,r3
  asr r2,12 ; R2 = lam

  ; lcf = lam * g_cosf >> 8 # .12 * .8 / .8 = .12
  ldrsh r3,[r1,16] ; R3 = g_cosf
  mul r3,r2
  asr r3,8 ; R3 = lcf

  ; lsf = lam * g_sinf >> 8 # .12 * .8 / .8 = .12
  ldrsh r4,[r1,18] ; R4 = g_sinf
  mul r4,r2
  asr r4,8 ; R4 = lsf

  ; REG_BG2PA = lcf >> 4
  asr r5,r3,4 ; R5 = lcf >> 4
  strh r5,[r0,BG2PA] ; Store REG_BG2PA

  ; REG_BG2PC = lsf >> 4
  asr r6,r4,4 ; R6 = lsf >> 4
  strh r6,[r0,BG2PC] ; Store REG_BG2PC

  ; Calculate Offsets
  ; Note That The lxr Shifts Down First!

  ; Horizontal Offset
  ; lxr = 120 * (lcf >> 4)
  mov r7,120 ; R7 = 120 (1/2 Screen Width)
  mul r5,r7 ; R5 = lxr

  ; lyr = (M7_D * lsf) >> 4
  ldr r8,[r1] ; R8 = M7_D
  mul r4,r8
  asr r4,4 ; R4 = lyr

  ; REG_BG2X = cam_pos_x - lxr + lyr
  ldr r9,[r1,4] ; R9 = cam_pos_x
  sub r9,r5
  add r9,r4
  str r9,[r0,BG2X] ; Store REG_BG2X

  ; Vertical Offset
  ; lxr = 120 * (lsf >> 4)
  mul r5,r7,r6 ; R5 = lxr

  ; lyr = (M7_D * lcf) >> 4
  mul r4,r8,r3
  asr r4,4 ; R4 = lyr

  ; REG_BG2Y = cam_pos_z - lxr - lyr
  ldr r9,[r1,12] ; R9 = cam_pos_z
  sub r9,r5
  sub r9,r4
  str r9,[r0,BG2Y] ; Store REG_BG2Y
}

macro Control { ; Macro To Handle Control Input
  mov r0,IO ; R0 = GBA I/O Base Offset
  ldr r1,[r0,KEYINPUT] ; R1 = Key Input
  mov r2,M7_D ; R2 = Address Of Parameter Table

  ; X & Z Translation
  ldr r3,[r2,4] ; R3 = X Translation
  ldr r4,[r2,12] ; R4 = Z Translation
  ldrsh r5,[r2,16] ; R5 = COS
  ldrsh r6,[r2,18] ; R6 = SIN
  tst r1,KEY_RIGHT ; Test Right Direction Pad Button
  addeq r3,r5 ; X Translation += COS
  addeq r4,r6 ; Z Translation += SIN
  tst r1,KEY_LEFT ; Test Left Direction Pad Button
  subeq r3,r5 ; X Translation -= COS
  subeq r4,r6 ; Z Translation -= SIN
  tst r1,KEY_UP ; Test Up Direction Pad Button
  addeq r3,r6 ; X Translation += SIN
  subeq r4,r5 ; Z Translation -= COS
  tst r1,KEY_DOWN ; Test Down Direction Pad Button
  subeq r3,r6 ; X Translation -= SIN
  addeq r4,r5 ; Z Translation += COS
  str r3,[r2,4] ; Store X Translation
  str r4,[r2,12] ; Store Z Translation

  ; Y Translation
  ldr r3,[r2,8] ; R3 = Y Translation
  tst r1,KEY_B ; Test B Button
  addeq r3,256 ; Y Translation += 256
  tst r1,KEY_A ; Test A Button
  subeq r3,256 ; Y Translation -= 256
  str r3,[r2,8] ; Store Y Translation

  ; Mode7 Distance / FOV
  ldr r3,[r2,0] ; R3 = Mode7 Distance
  tst r1,KEY_START ; Test Start Button
  addeq r3,1 ; Y Translation += 1
  tst r1,KEY_SELECT ; Test Select Button
  subeq r3,1 ; Y Translation -= 1
  str r3,[r2,0] ; Store Mode7 Distance

  ; Rotate On L & R
  ldrb r3,[r2,20] ; R3 = Rotation Angle Variable
  tst r1,KEY_R ; Test R Button
  addeq r3,1 ; IF (L Pressed) Rotate += 1 (Anti-Clockwise)
  tst r1,KEY_L ; Test L Button
  subeq r3,1 ; IF (R Pressed) Rotate -= 1 (Clockwise)
  and r3,$FF ; R3 &= $FF
  strb r3,[r2,20] ; Store Rotation Angle Variable

  imm32 r0,SinCos256 ; R0 = Sin & Cos Pre-Calculated Table
  lsl r3,2 ; R3 *= 4 (Get To Correct Address In Sin & Cos)
  ldrsh r4,[r0,r3] ; R4 = COS
  strh r4,[r2,16] ; Store COS
  add r3,2 ; R3 += 2
  ldrsh r4,[r0,r3] ; R4 = SIN
  strh r4,[r2,18] ; Store SIN
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
M7_D:
 dw 128

cam_pos_x:
 dw 10 * 256 ; Camera Position X, .8f
cam_pos_y:
 dw 80 * 256 ; Camera Position Y, .8f
cam_pos_z:
 dw 512 * 256 ; Camera Position Z, .8f

g_cosf:
 dh 0 * 256 ; cos(phi), .8f
g_sinf:
 dh 1 * 256 ; sin(phi), .8f

r_angle:
 dw 0 ; Angle Of Rotation

include 'DIVLUT.asm' ; Include Division LUT

include 'sincos256.asm' ; Sin & Cos Pre-Calculated Table (256 Rotations)

MODE7Count: ; Mode7 Count (0-160)
  db $00 ; Set To zero

align 4
start:
  mov r0,IO
  mov r1,MODE_2
  orr r1,BG2_ENABLE
  str r1,[r0]

  imm16 r1,1100100000000000b ; BG Tile Offset = 0, BG Map Offset = 16384, Map Size = 128x128 Tiles
  str r1,[r0,BG2CNT]

  DMA32 BGPAL, VPAL, 16 ; DMA BG Palette To Color Mem
  DMA32 BGIMG, VRAM, 2736 ; DMA BG Image To VRAM
  DMA32 BGMAP, VRAM+16384, 4096 ; DMA BG Map To VRAM

MODE7Loop: ; Label To Loop Mode 7 Scanlines
  imm32 r11,MODE7Count ; R11 = Mode7 Count
  ldrb r12,[r11] ; R12 = Mode7 Count
  MODE7Calc ; Run Mode7 Calculation
  add r12,1 ; R12++
  strb r12,[r11] ; Store Mode7 Count
  cmp r12,161 ; Compares Mode7 Count To 161 (Bottom Of Screen)
  bne MODE7Loop ; IF (Mode7 Count != 161) Mode7 Loop

  mov r12,0 ; R12 = 0 (Reset Mode7 Count)
  strb r12,[r11] ; Store Mode7 Count

  Control ; Update Mode7 BG According To Controls

  b MODE7Loop

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org $80000C0 + (endcopy - IWRAM) + (startcode - copycode)
BGIMG: file 'BG.img' ; Include BG Image Data (10944 Bytes)
BGMAP: file 'BG.map' ; Include BG Map Data (16384 Bytes)
BGPAL: file 'BG.pal' ; Include BG Palette Data (64 Bytes)