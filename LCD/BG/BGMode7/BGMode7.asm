; Game Boy Advance 'Bare Metal' BG Mode 7 H-Blank Interrupt Demo by krom (Peter Lemon):
; Special Thanks To Cearn For The Tonc Mode7 Tutorials
; Direction Pad Changes BG Mode7 X/Z Position
; A/B Buttons Changes BG Mode7 Y Position (Height)
; L/R Buttons Rotate BG Mode7 Clockwise/Anti-Clockwise
; Select/Start Buttons Changes BG Mode7 FOV (Mode7 Distance)

format binary as 'gba'
org $8000000
include 'LIB\FASMARM.INC' ; Include FASMARM Macros
include 'LIB\GBA.INC' ; Include GBA Definitions
include 'LIB\GBA_DMA.INC' ; Include GBA DMA Macros
include 'LIB\GBA_INTERRUPT.INC' ; Include GBA Interrupt Macros
include 'LIB\GBA_KEYPAD.INC' ; Include GBA Keypad Macros
include 'LIB\GBA_LCD.INC' ; Include GBA LCD Macros
include 'LIB\GBA_HEADER.ASM' ; Include GBA Header & ROM Entry Point

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

align 4
start:
  mov r0,IO
  mov r1,MODE_2
  orr r1,BG2_ENABLE
  str r1,[r0]

  imm16 r1,1100100000000000b ; BG Tile Offset = 0, BG Map Offset = 16384, Map Size = 128x128 Tiles
  strh r1,[r0,BG2CNT]

  DMA32 BGPAL, VPAL, 16 ; DMA BG Palette To Color Mem
  DMA32 BGIMG, VRAM, 2736 ; DMA BG Image To VRAM
  DMA32 BGMAP, VRAM+16384, 4096 ; DMA BG Map To VRAM

  ; Interrupt Service Routine (ISR)
  imm32 r1,MODE7CalcHBL ; R1 = H-Blank Interrupt Routine (ISR)
  imm32 r2,ISR ; R2 = ISR Address ($03007FFC)
  str r1,[r2] ; Store H-Blank Interrupt Routine Offset To ISR Address

  mov r1,00010000b ; R1 = H-Blank IRQ
  strb r1,[r0,DISPSTAT] ; Set DISPSTAT To Fire H-Blank Interrupt ($4000004)
  mov r1,00000010b ; R1 = H-Blank IRQ
  mov r2,IE ; R2 = IE
  strh r1,[r0,r2] ; Set IE To Catch H-Blank Interrupt ($4000200)
  mov r1,1 ; R1 = 1
  mov r2,IME ; R2 = IME
  strh r1,[r0,r2] ; Set IME To Enable Interrupt ($4000208)

MODE7Loop: ; Label To Loop Mode 7 Scanlines
  b MODE7Loop

MODE7CalcHBL: ; Calculate Mode7 Scanline (H-Blank Routine)
  mov r0,IO ; R0 = GBA I/O Base Offset
  ldrh r12,[r0,VCOUNT] ; R12 = Current LCD Scanline Position

  cmp r12,160 ; Compare VCOUNT To 160 (V-Blank)
  beq ControlHBL ; IF (VCOUNT = 160) Run Control H-Blank Routine
  bgt NoInterrupt ; IF (VCOUNT > 160) No Interrupt

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

  mov r1,2 ; R1 = H-Blank
  imm16 r2,IF_ACK ; R2 = IF_ACK
  strh r1,[r0,r2] ; Set IF_ACK To Acknowledge H-Blank Interrupt ($4000202)
  bx lr ; Return From Interrupt Routine

ControlHBL: ; Control Input (H-Blank Routine)
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

  imm32 r1,SinCos256 ; R1 = Sin & Cos Pre-Calculated Table
  lsl r3,2 ; R3 *= 4 (Get To Correct Address In Sin & Cos)
  ldrsh r4,[r1,r3] ; R4 = COS
  strh r4,[r2,16] ; Store COS
  add r3,2 ; R3 += 2
  ldrsh r4,[r1,r3] ; R4 = SIN
  strh r4,[r2,18] ; Store SIN

NoInterrupt:
  mov r1,2 ; R1 = H-Blank
  imm16 r2,IF_ACK ; R2 = IF_ACK
  strh r1,[r0,r2] ; Set IF_ACK To Acknowledge H-Blank Interrupt ($4000202)
  bx lr ; Return From Interrupt Routine

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org startcode + (endcopy - IWRAM)
BGIMG: file 'BG.img' ; Include BG Image Data (10944 Bytes)
BGMAP: file 'BG.map' ; Include BG Map Data (16384 Bytes)
BGPAL: file 'BG.pal' ; Include BG Palette Data (64 Bytes)