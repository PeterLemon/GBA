; Game Boy Advance 'Bare Metal' Physics Velocity Demo by krom (Peter Lemon):
; L/R Buttons Rotate Cannon/Bullet OBJ Anti-Clockwise/Clockwise
; B Button Fires Bullet OBJ

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

  ; Fire Bullet On B
  ands r2,r1,#KEY_B ; Test B Button
  imm32eq r2,FireFlag
  moveq r3,1 ; Set Fire Flag To 1 (Fired)
  strbeq r3,[r2] ; Store Fire Flag

  ; Rotate On L & R
  ldrh r2,[r0,4] ; R2 = Rotation Variable
  ands r3,r1,#KEY_L ; Test L Button
  addeq r2,r2,$0100 ; IF (L Pressed) Rotate += 256 (Anti-Clockwise)
  ands r3,r1,#KEY_R ; Test R Button
  subeq r2,r2,$0100 ; IF (R Pressed) Rotate -= 256 (Clockwise)
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
  dh $0110 ; X
  dh $0110 ; Y
  ; Angle Of Rotation ($0000..$FFFF Anti-Clockwise)
  dh $0000

FireFlag:
  db 0 ; Fire Flag = 0

align 4
BulletX:
  dw 104*65536 ; Bullet X = 104 (Fixed Point 16.16)
BulletY:
  dw 64*65536 ; Bullet Y = 64 (Fixed Point 16.16)
BulletSpeed:
  dw 1024 ; Bullet Speed Of Velocity

include 'sincos256.asm' ; Sin & Cos Pre-Calculated Table (256 Rotations)

align 4
start:
  InitOBJ ; Initialize Sprites

  mov r0,IO
  imm32 r1,MODE_0+BG2_ENABLE+OBJ_ENABLE+OBJ_MAP_1D
  str r1,[r0]

  imm16 r1,$7FFF ; R1 = BG Color (White)
  mov r2,VPAL ; Load BG Palette Address
  strh r1,[r2] ; Store BG Color To BG Palette

  ; Cannon OBJ
  mov r1,OAM ; R1 = OAM ($7000000)
  imm32 r2,(TALL+COLOR_256+16+SIZE_DOUBLE+ROTATION_FLAG)+((SIZE_64+88) * 65536) ; R2 = Attributes 0 & 1
  str r2,[r1],4 ; Store Attributes 0 & 1 To OAM, Increment OAM Address To Attribute 2
  mov r2,0	; R2 = Attribute 2 (Tile number 0)
  str r2,[r1],4 ; Store Attribute 2 To OAM

  ; Bullet OBJ
  imm32 r2,(SQUARE+COLOR_256+64+ROTATION_FLAG)+((SIZE_32+104) * 65536) ; R2 = Attributes 0 & 1
  str r2,[r1],4 ; Store Attributes 0 & 1 To OAM, Increment OAM Address To Attribute 2
  mov r2,$40	; R2 = Attribute 2 (Tile number 64)
  str r2,[r1]	; Store Attribute 2 To OAM

  DMA32 SpritesPAL, OBJPAL, 29 ; DMA OBJ Palette To Color Mem
  DMA32 SpritesCHR, CHARMEM, 768 ; DMA OBJ Bitmap Data To VRAM

Loop:
    VBlank  ; Wait Until VBlank

    imm32 r0,FireFlag
    ldrb r1,[r0] ; Load Fire Flag
    cmp r1,1 ; Compare Fire Flag To 1
    beq Fired ; IF (Fire Flag == 1) Fired

    Control ; Update OBJ According To Controls
    b Loop

    Fired:
      imm32 r0,BulletX ; Load Bullet X Address
      ldr r1,[r0],4 ; R1 = Bullet X, Load Bullet Y Address
      ldr r2,[r0] ; R2 = Bullet Y

      ; Load Angle Of Rotation
      mov r0,OBJAffineSource ; Load OBJ Affine Transformations Table
      ldrh r3,[r0,4] ; R3 = Angle Of Rotation

      ; Load Speed Of Velocity
      imm32 r0,BulletSpeed ; Load Speed Of Velocity Address
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

      add r1,r5 ; Bullet X += X Velocity
      add r2,r6 ; Bullet Y += Y Velocity

      imm32 r0,BulletX ; Load Bullet X Address
      str r1,[r0],4 ; Store Bullet X, Load Bullet Y Address
      str r2,[r0] ; Store Bullet Y
      lsr r1,16 ; Bullet X >> 16
      lsl r1,16 ; Bullet X << 16
      lsr r2,16 ; Bullet Y >> 16

      and r1,$1FFFFFF ; Bullet X &= 511
      and r2,$FF ; Bullet Y &= 255

      add r3,r1,32*65536
      add r4,r2,32
      and r3,$1FFFFFF ; Bullet X &= 511
      and r4,$FF ; Bullet Y &= 255

      cmp r3,272*65536 ; Compare Bullet X To 272
      bge ResetOBJXY
      cmp r4,192 ; Compare Bullet Y To 192
      bge ResetOBJXY
      cmp r3,0 ; Compare Bullet X To 0
      ble ResetOBJXY
      cmp r4,0 ; Compare Bullet Y To 0
      ble ResetOBJXY
      b SetOBJXY

      ResetOBJXY:
	mov r1,104*65536 ; Bullet X = 104 (Fixed Point 16.16)
	mov r2,64*65536 ; Bullet Y = 64 (Fixed Point 16.16)
	imm32 r0,BulletX ; Load Bullet X Address
	str r1,[r0],4 ; Store Bullet X, Load Bullet Y Address
	str r2,[r0] ; Store Bullet Y
	lsr r2,16 ; Bullet Y >> 16

	imm32 r0,FireFlag
	mov r3,0 ; Reset Fire Flag To 0 (Not Fired)
	strb r3,[r0] ; Store Fire Flag

      SetOBJXY:
	mov r0,OAM ; R1 = OAM ($7000000)
	add r0,8 ; Bullet OBJ
	imm32 r3,(SQUARE+COLOR_256+ROTATION_FLAG)+((SIZE_32) * 65536) ; R3 = Attributes 0 & 1
	orr r1,r3 ; Attributes 0 & 1 += Bullet X
	orr r1,r2 ; Attributes 0 & 1 += Bullet Y
	str r1,[r0] ; Store Attributes 0 & 1

    b Loop

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org $80000C0 + (endcopy - IWRAM) + (startcode - copycode)
SpritesCHR: file 'Sprites.bin' ; Include Sprite Bitmap Data (3072 Bytes)
SpritesPAL: file 'Sprites.pal' ; Include Sprite Pallete (58 Bytes)