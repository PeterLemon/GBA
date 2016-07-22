; Game Boy Advance 'Bare Metal' Physics Gravity Demo by krom (Peter Lemon):
; Left/Right Buttons Turn Car Anti-Clockwise/Clockwise
; A Button Thrust Ship OBJ

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
include 'LIB\KEYPAD.INC'
include 'LIB\DMA.INC'
include 'LIB\OBJ.INC'
org $8000000
b copycode
times $80000C0-($-0) db 0

macro Control { ; Macro To Handle Control Input
  mov r0,OBJAffineSource ; R0 = Address Of Parameter Table
  mov r1,IO ; R1 = GBA I/O Base Offset
  ldr r2,[r1,KEYINPUT] ; R2 = Key Input

  ; Thrust Ship With A
  tst r2,KEY_A ; Test A Button
  bne NoThrust

  ; Load Angle Of Rotation
  ldrh r3,[r0,4] ; R3 = Angle Of Rotation

  ; Load X & Y Scale (Cosine Of The Angle)
  imm32 r4,SinCos256 ; Load Sin & Cos Pre-Calculated Table (COS Position)
  lsr r3,8 ; Angle Of Rotation >>= 8
  lsl r3,2 ; Angle Of Rotation <<= 2
  ldrsh r5,[r4,r3] ; R5 = X Scale COS(Angle)
  add r4,2 ; SIN Position
  ldrsh r6,[r4,r3] ; R6 = Y Scale SIN(Angle)

  ; Load Speed Of Velocity
  ldr r3,[r0,24] ; R3 = Speed Of Velocity

  ; Load X & Y Velocity (Speed * Scale)
  mul r5,r3 ; R5 = X Velocity (Speed Of Velocity * X Scale)
  mul r6,r3 ; R6 = Y Velocity (Speed Of Velocity * Y Scale)

  ; Add X & Y Velocity To Current X & Y Velocity
  ldr r3,[r0,16] ; R3 = Current X Velocity
  ldr r4,[r0,20] ; R4 = Current X Velocity
  add r5,r3 ; X Velocity += Current X Velocity
  add r6,r4 ; X Velocity += Current Y Velocity

  str r5,[r0,16] ; Store X Velocity
  str r6,[r0,20] ; Store Y Velocity

  NoThrust:

  ; Rotate On Left & Right
  ldrh r3,[r0,4] ; R3 = Rotation Variable
  tst r2,KEY_LEFT ; Test Left Button
  addeq r3,512 ; IF (L Pressed) Rotate += 512 (Anti-Clockwise)
  tst r2,KEY_RIGHT ; Test Right Button
  subeq r3,512 ; IF (R Pressed) Rotate -= 512 (Clockwise)
  strh r3,[r0,4] ; Store Rotate To Parameter Table (Rotation)

  imm32 r1,PA_0 ; Update OBJ Parameters
  mov r2,1 ; (BIOS Call Requires R0 To Point To Parameter Table)
  mov r3,8 ; R3 Set To Make Structure Inline With OAM
  swi $0F0000 ; Bios Call To Calculate All The Correct OAM Parameters According To The Controls
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
OBJAffineSource: ; Memory Area Used To Set OBJ Affine Transformations Using BIOS Call
  ; Scaling Ratios (Last 8-Bits Fractional)
  dh $0100 ; X
  dh $0100 ; Y
  ; Angle Of Rotation ($0000..$FFFF Anti-Clockwise)
  dh $0000 ; Angle
  dh $0000 ; 2 Byte Padding

ShipX:
  dw 88*65536 ; Ship X = 88 (Fixed Point 16.16)
ShipY:
  dw 112*65536 ; Ship Y = 112 (Fixed Point 16.16)
ShipXVelocity:
  dw 0 ; Ship X Velocity
ShipYVelocity:
  dw 0 ; Ship Y Velocity
ShipSpeed:
  dw 20 ; Ship Speed Of Velocity
Gravity:
  dw 2048 ; Gravity

include 'sincos256.asm' ; Sin & Cos Pre-Calculated Table (256 Rotations)

align 4
start:
  InitOBJ ; Initialize Sprites

  imm16 r1,$7FFF ; R1 = BG Color (White)
  mov r2,VPAL ; Load BG Palette Address
  strh r1,[r2] ; Store BG Color To BG Palette

  ; Ship Sprite
  mov r1,OAM ; R1 = OAM ($7000000)
  imm32 r2,(SQUARE+COLOR_16+112+SIZE_DOUBLE+ROTATION_FLAG)+((SIZE_32+88) * 65536) ; R2 = Attributes 0 & 1
  str r2,[r1],4 ; Store Attributes 0 & 1 To OAM, Increment OAM Address To Attribute 2
  mov r2,0	; R2 = Attribute 2 (Tile Number 0)
  str r2,[r1]	; Store Attribute 2 To OAM

  DMA32 ShipPAL, OBJPAL, 8 ; DMA OBJ Palette To Color Mem
  DMA32 ShipIMG, CHARMEM, 128 ; DMA OBJ Image Data To VRAM

  mov r0,IO
  imm32 r1,MODE_0+BG2_ENABLE+OBJ_ENABLE+OBJ_MAP_1D
  str r1,[r0]

Loop:
    VBlank  ; Wait Until VBlank

    Control ; Update OBJ According To Controls

    imm32 r0,ShipX ; Load Ship X Address
    ldr r1,[r0] ; R1 = Ship X
    ldr r2,[r0,4] ; R2 = Ship Y
    ldr r3,[r0,8] ; R3 = X Velocity
    ldr r4,[r0,12] ; R4 = Y Velocity

    ; Ground
    cmp r2,112*65536 ; Compare Ship Y To 112 (Ground)
    ldrle r5,[r0,20] ; R5 = Gravity
    addle r4,r5 ; Y Velocity += Gravity
    movgt r2,112*65536 ; Ship Y = 112
    movgt r3,0 ; X Velocity = 0
    movgt r4,0 ; Y Velocity = 0
    str r3,[r0,8] ; Store X Velocity
    str r4,[r0,12] ; Store Y Velocity

    ; Ship Position
    add r1,r3 ; Ship X += X Velocity
    add r2,r4 ; Ship Y += Y Velocity

    str r1,[r0] ; Store Ship X
    str r2,[r0,4] ; Store Ship Y
    lsr r1,16 ; Ship X >> 16
    lsl r1,16 ; Ship X << 16
    lsr r2,16 ; Ship Y >> 16

    and r1,$1FFFFFF ; Ship X &= 511
    and r2,$FF ; Ship Y &= 255

    SetOBJXY:
      mov r0,OAM ; R1 = OAM ($7000000)
      imm32 r3,(SQUARE+COLOR_16+SIZE_DOUBLE+ROTATION_FLAG)+((SIZE_32) * 65536) ; R3 = Attributes 0 & 1
      orr r1,r3 ; Attributes 0 & 1 += Ship X
      orr r1,r2 ; Attributes 0 & 1 += Ship Y
      str r1,[r0] ; Store Attributes 0 & 1

    b Loop

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org $80000C0 + (endcopy - IWRAM) + (startcode - copycode)
ShipIMG: file 'Ship.img' ; Include Sprite Image Data (512 Bytes)
ShipPAL: file 'Ship.pal' ; Include Sprite Pallete (32 Bytes)