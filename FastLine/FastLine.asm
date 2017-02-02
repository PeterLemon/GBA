; Game Boy Advance 'Bare Metal' Fast Line Plot Demo by krom (Peter Lemon):
; Uses Direction Pad To Change Line End Point X/Y Position

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
include 'LIB\KEYPAD.INC'
include 'LIB\DMA.INC'
org $8000000
b copycode
times $80000C0-($-0) db 0

macro Control {
  ldrb r0,[LineX]
  IsKeyDown KEY_RIGHT
  addeq r0,1
  strbeq r0,[LineX]

  IsKeyDown KEY_LEFT
  subeq r0,1
  strbeq r0,[LineX]

  ldrb r0,[LineY]
  IsKeyDown KEY_DOWN
  addeq r0,1
  strbeq r0,[LineY]

  IsKeyDown KEY_UP
  subeq r0,1
  strbeq r0,[LineY]
}

macro DrawLine X0, Y0, X1, Y1, Colour {
  local .LoopX, .LoopY, .LineEnd
  mov r0,X0 ; Moves X0 To R0 (X0)
  mov r1,Y0 ; Moves Y0 To R1 (Y0)
  mov r2,X1 ; Moves X1 To R2 (X1)
  mov r3,Y1 ; Moves Y1 To R3 (Y1)
  mov r8,240 ; Moves 240 To R8 (Screen Width)
  ldr r9,[Colour] ; Load Color To R9 (Color)
  mov r10,VRAM ; Load VRAM Base Pointer To R9 (VRAM Base Pointer)
  
  subs r4,r2,r0 ; Subtract R0 (X0) From R4 (DX) & Compare R4 (DX) To Zero (X1 - X0)
  rsbmi r4,0 ; Convert R4 (DX) To ABS(DX)
  mvnlt r6,0 ; IF (X1 < X0), R6 (SX) = -1
  movgt r6,1 ; IF (X1 > X0), R6 (SX) =	1

  subs r5,r3,r1 ; Subtract R2 (Y0) From R5 (DY) & Compare R5 (DY) To Zero (Y1 - Y0)
  rsbmi r5,0 ; Convert R5 (DY) To ABS(DX)
  mvnlt r7,0 ; IF (Y1 < Y0), R7 (SY) = -1
  movgt r7,1 ; IF (Y1 > Y0), R7 (SY) =	1

  cmp r4,r5 ; Compare DX To DY
  movgt r3,r4,lsr 1 ; IF (DX >	DY), R3 (X Error) = R4 (DX) / 2 (X Error = DX / 2)
  movle r2,r5,lsr 1 ; IF (DX <= DY), R1 (Y Error) = R5 (DY) / 2 (Y Error = DY / 2)
  ble .LoopY

  .LoopX:
    mla r11,r1,r8,r0 ; Multiplies R2 (Y0) By R8 (Screen Width) To R2 (Y Byte Position), Add R8 To R0 (X0) To R11 (XY Byte Position)
    lsl r11,1 ; Double R11 (XY Byte Position) To R11 (XY Half Word Position)
    strh r9,[r10,r11] ; Store R9 (Colour) To R10 (VRAM Base Pointer) Added To R11 (XY VRAM Position)

    cmp r0,r2 ; While (X0 != X1)
    beq .LineEnd ; IF (X0 == X1), Branch To Line End
    subs r3,r5	; Subtract R5 (DY) From R3 (X Error) & Compare R3 (X Error) To Zero (X Error -= DY)
    addlt r1,r7 ; IF (X Error < 0), Add R7 (SY) To R1 (Y0) (Y0 += SY)
    addlt r3,r4 ; IF (X Error < 0), Add R4 (DX) To R3 (X Error) (X Error += DX)
    add r0,r6 ; Add R6 (SX) To R0 (X0) (X0 += SX)
    b .LoopX ; Loop Line Drawing

  .LoopY:
    mla r11,r1,r8,r0 ; Multiplies R2 (Y0) By R8 (Screen Width) To R2 (Y Byte Position), Add R8 To R0 (X0) To R11 (XY Byte Position)
    lsl r11,1 ; Double R11 (XY Byte Position) To R11 (XY Half Word Position)
    strh r9,[r10,r11] ; Store R9 (Colour) To R10 (VRAM Base Pointer) Added To R11 (XY VRAM Position)

    cmp r1,r3 ; While (Y0 != Y1)
    beq .LineEnd ; IF (Y0 == Y1), Branch To Line End
    subs r2,r4	; Subtract R4 (DX) From R1 (Y Error) & Compare R1 (Y Error) To Zero
    addlt r0,r6 ; IF (Y Error < 0), Add R6 (SX) To R0 (X0) (X0 += SX)
    addlt r2,r5 ; IF (Y Error < 0), Add R5 (DY) To R2 (Y Error) (Y Error += DY)
    add r1,r7 ; Add R7 (SY) To R1 (Y0) (Y0 += SY)
    b .LoopY ; Loop Line Drawing

  .LineEnd: ; End of Line Drawing
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
Black: dw $00000000 ; Black Clear Color
White: dw $0000FFFF ; White Line Color
LineX: db 239 ; Line X Amount: 239 Pixels Across
LineY: db 159 ; Line Y Amount: 159 Pixels Down

  align 4
start:
  mov r0,IO
  mov r1,MODE_3
  orr r1,BG2_ENABLE
  str r1,[r0]

loop:
  VBlank
  Control
  DMA32SRCFIXED Black, VRAM, 19200 ; Clear Screen

  ldrb r10,[LineX]
  ldrb r11,[LineY]
  DrawLine 120, 80, r10, r11, White
  b loop

endcopy: ; End Of Program Copy Code