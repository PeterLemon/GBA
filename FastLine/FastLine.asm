; Game Boy Advance 'Bare Metal' Fast Line Plot Demo by krom (Peter Lemon):
; Uses L/R/A/B To Change Line Start Point X/Y Position
; Uses Direction Pad To Change Line End Point X/Y Position

format binary as 'gba'
org $8000000
include 'LIB\FASMARM.INC' ; Include FASMARM Macros
include 'LIB\GBA.INC' ; Include GBA Definitions
include 'LIB\GBA_DMA.INC' ; Include GBA DMA Macros
include 'LIB\GBA_KEYPAD.INC' ; Include GBA Keypad Macros
include 'LIB\GBA_LCD.INC' ; Include GBA LCD Macros
include 'LIB\GBA_HEADER.ASM' ; Include GBA Header & ROM Entry Point

macro Control {
  ldrb r0,[LineX1] ; R0 = Line Point X1
  IsKeyDown KEY_R ; IF (R Key Pressed)
  addeq r0,1 ; Line Point X1++
  strbeq r0,[LineX1] ; Line Point X1 = R0

  IsKeyDown KEY_L ; IF (L Key Pressed)
  subeq r0,1 ; Line Point X1--
  strbeq r0,[LineX1] ; Line Point X1 = R0

  ldrb r0,[LineY1] ; R0 = Line Point Y1
  IsKeyDown KEY_B ; IF (B Key Pressed)
  addeq r0,1 ; Line Point Y1++
  strbeq r0,[LineY1] ; Line Point Y1 = R0

  IsKeyDown KEY_A ; IF (A Key Pressed)
  subeq r0,1 ; Line Point Y1--
  strbeq r0,[LineY1] ; Line Point Y1 = R0

  ldrb r0,[LineX2] ; R0 = Line Point X2
  IsKeyDown KEY_RIGHT ; IF (Right Key Pressed)
  addeq r0,1 ; Line Point X2++
  strbeq r0,[LineX2] ; Line Point X2 = R0

  IsKeyDown KEY_LEFT ; IF (Left Key Pressed)
  subeq r0,1 ; Line Point X2--
  strbeq r0,[LineX2] ; Line Point X2 = R0

  ldrb r0,[LineY2] ; R0 = Line Point Y2
  IsKeyDown KEY_DOWN ; IF (Down Key Pressed)
  addeq r0,1 ; Line Point Y2++
  strbeq r0,[LineY2] ; Line Point Y2 = R0

  IsKeyDown KEY_UP ; IF (Up Key Pressed)
  subeq r0,1 ; Line Point Y2--
  strbeq r0,[LineY2] ; Line Point Y2 = R0
}

macro DrawLine x1, y1, x2, y2, color { ; Draw Line: Line Point X1, Line Point Y1, Line Point X2, Line Point Y2, Line Color
  local .LoopX, .LoopY, .LineEnd

  subs r0,x2,x1 ; R0 = DX (X2 - X1), Compare DX To Zero
  rsbmi r0,0 ; R0 = ABS(DX)
  movgt r1,2 ; IF (X2 > X1), R1 = 2 (SX)
  mvnlt r1,1 ; IF (X2 < X1), R1 = -2 (SX)

  subs r2,y2,y1 ; R2 = ABS(DY) (Y2 - Y1), Compare DY To Zero
  rsbmi r2,0 ; R2 = ABS(DY)
  mov   r3,480 ; IF (Y2 > Y1), R3 = 480 (SY)
  rsblt r3,0   ; IF (Y2 < Y1), R3 = -480 (SY)

  mov r4,240 ; R4 = 240 (Screen Width)

  mla x1,y1,r4,x1 ; X1 = (Y1 * Screen Width) + X1
  lsl x1,1 ; X1 <<= 1
  add x1,VRAM ; X1 = Point Start

  mla y1,y2,r4,x2 ; Y1 = (Y2 * Screen Width) + X2
  lsl y1,1 ; Y1 <<= 1
  add y1,VRAM ; Y1 = Point End

  cmp r0,r2 ; Compare DX To DY
  lsrgt x2,r0,1 ; IF (DX >  DY) X2 = DX / 2 (X Error)
  movgt y2,r0 ; IF (DX >  DY) Y2 = DX (X Count)
  lsrle x2,r2,1 ; IF (DX <= DY) X2 = DY / 2 (Y Error)
  movle y2,r2 ; IF (DX <= DY) Y2 = DY (Y Count)
  ble .LoopY

  .LoopX:
    strh color,[x1],r1 ; Store Color To Point Start, Point Start += SX
    subs y2,1 ; X Count--, Compare X Count To Zero
    blt .LineEnd ; IF (X Count < 0) Line End
    strh color,[y1],-r1 ; Store Color To Point End, Point End -= SX
    subs y2,1 ; X Count--, Compare X Count To Zero
    blt .LineEnd ; IF (X Count < 0) Line End
    subs x2,r2 ; X Error -= DY, Compare X Error To Zero
    addlt x1,r3 ; IF (X Error < 0) Point Start += SY
    sublt y1,r3 ; IF (X Error < 0) Point End -= SY
    addlt x2,r0 ; IF (X Error < 0) X Error += DX
    b .LoopX ; Loop Line Drawing

  .LoopY:
    strh color,[x1],r3 ; Store Color To Point Start, Point Start += SY
    subs y2,1 ; Y Count--, Compare Y Count To Zero
    blt .LineEnd ; IF (Y Count < 0) Line End
    strh color,[y1],-r3 ; Store Color To Point End, Point End -= SY
    subs y2,1 ; Y Count--, Compare Y Count To Zero
    blt .LineEnd ; IF (Y Count < 0) Line End
    subs x2,r0  ; Y Error -= DX, Compare Y Error To Zero
    addlt x1,r1 ; IF (Y Error < 0) Point Start += SX
    sublt y1,r1 ; IF (Y Error < 0) Point End -= SX
    addlt x2,r2 ; IF (Y Error < 0) Y Error += DY
    b .LoopY ; Loop Line Drawing

  .LineEnd: ; End of Line Drawing
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
Black: dw $00000000 ; Clear Color (Black)
White: dw $0000FFFF ; Line Color (White)
LineX1: db 120 ; Line X1: 120 Pixels Across
LineY1: db 80  ; Line Y1:  80 Pixels Down
LineX2: db 239 ; Line X2: 239 Pixels Across
LineY2: db 159 ; Line Y2: 159 Pixels Down

  align 4
start:
  mov r0,IO
  mov r1,MODE_3
  orr r1,BG2_ENABLE
  str r1,[r0]

ldr r10,[White] ; R10 = Line Color (White)

loop:
  VBlank ; Wait For VBlank
  Control ; Run Control
  DMA32SRCFIXED Black, VRAM, 19200 ; Clear Screen Using DMA

  ldrb r6,[LineX1]
  ldrb r7,[LineY1]
  ldrb r8,[LineX2]
  ldrb r9,[LineY2]
  DrawLine r6, r7, r8, r9, r10 ; Draw Line: Line Point X1, Line Point Y1, Line Point X2, Line Point Y2, Line Color
  b loop

endcopy: ; End Of Program Copy Code