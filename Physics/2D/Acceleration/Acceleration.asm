; Game Boy Advance 'Bare Metal' Physics Acceleration Demo by krom (Peter Lemon):
; Left/Right Buttons Turn Car Anti-Clockwise/Clockwise
; A Button Accelerate Car OBJ
; B Button Deccelerate Car OBJ

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

macro Control { ; - Macro to handle all control input
  mov r0,IO ; GBA I/O Base Offset
  ldr r1,[r0,KEYINPUT] ; R1 = Key Input
  mov r0,OBJAffineSource ; R0 = Address Of Parameter Table

  ; Accelerate Car With A
  ands r2,r1,#KEY_A ; Test A Button
  imm32eq r2,CarSpeed ; R2 = Car Speed Of Velocity Address
  ldreq r3,[r2] ; R3 = Car Speed Of Velocity
  ldreq r4,[r2,4] ; R4 = Car Acceleration Amount
  addeq r3,r4 ; Car Speed Of Velocity += Car Acceleration Amount
  streq r3,[r2] ; Store Car Speed Of Velocity

  ; Deccelerate Car With B
  ands r2,r1,#KEY_B ; Test B Button
  imm32eq r2,CarSpeed ; R2 = Car Speed Of Velocity Address
  ldreq r3,[r2] ; R3 = Car Speed Of Velocity
  ldreq r4,[r2,4] ; R4 = Car Acceleration Amount
  subeq r3,r4 ; Car Speed Of Velocity -= Car Acceleration Amount
  streq r3,[r2] ; Store Car Speed Of Velocity

  ; Rotate On Left & Right
  ldrh r2,[r0,4] ; R2 = Rotation Variable
  ands r3,r1,#KEY_LEFT ; Test Left Button
  addeq r2,r2,$0200 ; IF (L Pressed) Rotate += 512 (Anti-Clockwise)
  ands r3,r1,#KEY_RIGHT ; Test Right Button
  subeq r2,r2,$0200 ; IF (R Pressed) Rotate -= 512 (Clockwise)
  strh r2,[r0,4] ; Store Rotate To Parameter Table (Rotation)

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
  dh $0000

align 4
CarX:
  dw 88*65536 ; Car X = 88 (Fixed Point 16.16)
CarY:
  dw 48*65536 ; Car Y = 48 (Fixed Point 16.16)
CarSpeed:
  dw 0 ; Car Speed Of Velocity
CarAcceleration:
  dw 4 ; Car Acceleration Amount

include 'sincos256.asm' ; Sin & Cos Pre-Calculated Table (256 Rotations)

align 4
start:
  InitOBJ ; Initialize Sprites

  imm16 r1,$7FFF ; R1 = BG Color (White)
  mov r2,VPAL ; Load BG Palette Address
  strh r1,[r2] ; Store BG Color To BG Palette

  ; Car OBJ
  mov r1,OAM ; R1 = OAM ($7000000)
  imm32 r2,(SQUARE+COLOR_256+48+ROTATION_FLAG)+((SIZE_64+88) * 65536) ; R2 = Attributes 0 & 1
  str r2,[r1],4 ; Store Attributes 0 & 1 To OAM, Increment OAM Address To Attribute 2
  mov r2,0	; R2 = Attribute 2 (Tile number 0)
  str r2,[r1]	; Store Attribute 2 To OAM

  DMA32 CarPAL, OBJPAL, 32 ; DMA OBJ Palette To Color Mem
  DMA32 CarCHR, CHARMEM, 1024 ; DMA OBJ Bitmap Data To VRAM

  mov r0,IO
  imm32 r1,MODE_0+BG2_ENABLE+OBJ_ENABLE+OBJ_MAP_1D
  str r1,[r0]

Loop:
    VBlank  ; Wait Until VBlank

    Control ; Update OBJ According To Controls

    imm32 r0,CarX ; Load Car X Address
    ldr r1,[r0],4 ; R1 = Car X, Load Car Y Address
    ldr r2,[r0] ; R2 = Car Y

    ; Load Angle Of Rotation
    mov r0,OBJAffineSource ; Load OBJ Affine Transformations Table
    ldrh r3,[r0,4] ; R3 = Angle Of Rotation

    ; Load Speed Of Velocity
    imm32 r0,CarSpeed ; Load Speed Of Velocity Address
    ldr r4,[r0] ; R4 = Speed Of Velocity

    ; Load X & Y Scale (Cosine Of The Angle)
    imm32 r0,SinCos256 ; Load Sin & Cos Pre-Calculated Table (COS Position)
    lsr r3,8 ; Angle Of Rotation >>= 8
    lsl r3,2 ; Angle Of Rotation <<= 2
    ldrsh r5,[r0,r3] ; R5 = X Scale COS(Angle)
    add r0,2 ; SIN Position
    ldrsh r6,[r0,r3] ; R6 = Y Scale SIN(Angle)

    ; Load X & Y Velocity (Speed * Scale)
    mul r5,r4 ; R5 = X Velocity (Speed Of Velocity * X Scale)
    mul r6,r4 ; R6 = Y Velocity (Speed Of Velocity * Y Scale)

    add r1,r5 ; Car X += X Velocity
    add r2,r6 ; Car Y += Y Velocity

    imm32 r0,CarX ; Load Car X Address
    str r1,[r0],4 ; Store Car X, Load Car Y Address
    str r2,[r0] ; Store Car Y
    lsr r1,16 ; Car X >> 16
    lsl r1,16 ; Car X << 16
    lsr r2,16 ; Car Y >> 16

    and r1,$1FFFFFF ; Car X &= 511
    and r2,$FF ; Car Y &= 255

    SetOBJXY:
      mov r0,OAM ; R1 = OAM ($7000000)
      imm32 r3,(SQUARE+COLOR_256+ROTATION_FLAG)+((SIZE_64) * 65536) ; R3 = Attributes 0 & 1
      orr r1,r3 ; Attributes 0 & 1 += Car X
      orr r1,r2 ; Attributes 0 & 1 += Car Y
      str r1,[r0] ; Store Attributes 0 & 1

    b Loop

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org $80000C0 + (endcopy - IWRAM) + (startcode - copycode)
CarCHR: file 'Car.bin' ; Include Sprite Bitmap Data (4096 Bytes)
CarPAL: file 'Car.pal' ; Include Sprite Pallete (64 Bytes)