; Game Boy Advance 'Bare Metal' Fast Line Plot With Clipping Demo by krom (Peter Lemon):
; Uses L/R/A/B To Change Line Start Point X/Y Position
; Uses Direction Pad To Change Line End Point X/Y Position

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
include 'LIB\KEYPAD.INC'
include 'LIB\DMA.INC'

; Setup Frame Buffer
SCREEN_X = 240
SCREEN_Y = 160

org $8000000
b copycode
times $80000C0-($-0) db 0

macro Control {
  ldr r0,[LineX1] ; R0 = Line Point X1
  IsKeyDown KEY_R ; IF (R Key Pressed)
  addeq r0,1 ; Line Point X1++
  streq r0,[LineX1] ; Line Point X1 = R0

  IsKeyDown KEY_L ; IF (L Key Pressed)
  subeq r0,1 ; Line Point X1--
  streq r0,[LineX1] ; Line Point X1 = R0

  ldr r0,[LineY1] ; R0 = Line Point Y1
  IsKeyDown KEY_B ; IF (B Key Pressed)
  addeq r0,1 ; Line Point Y1++
  streq r0,[LineY1] ; Line Point Y1 = R0

  IsKeyDown KEY_A ; IF (A Key Pressed)
  subeq r0,1 ; Line Point Y1--
  streq r0,[LineY1] ; Line Point Y1 = R0

  ldr r0,[LineX2] ; R0 = Line Point X2
  IsKeyDown KEY_RIGHT ; IF (Right Key Pressed)
  addeq r0,1 ; Line Point X2++
  streq r0,[LineX2] ; Line Point X2 = R0

  IsKeyDown KEY_LEFT ; IF (Left Key Pressed)
  subeq r0,1 ; Line Point X2--
  streq r0,[LineX2] ; Line Point X2 = R0

  ldr r0,[LineY2] ; R0 = Line Point Y2
  IsKeyDown KEY_DOWN ; IF (Down Key Pressed)
  addeq r0,1 ; Line Point Y2++
  streq r0,[LineY2] ; Line Point Y2 = R0

  IsKeyDown KEY_UP ; IF (Up Key Pressed)
  subeq r0,1 ; Line Point Y2--
  streq r0,[LineY2] ; Line Point Y2 = R0
}

macro DrawLineClip x1, y1, x2, y2, color { ; Draw Line Clip: Line Point X1, Line Point Y1, Line Point X2, Line Point Y2, Line Color
  local .MDiv1, .CDiv1, .Y1Max, .X2Min, .Y2Max, .DiagonalPoint, .HorizontalLine, .LoopHorizontal, .VerticalLine, .LoopVertical, .Point, .DiagonalLine, .LoopX, .LoopY, .LineEnd

  cmp x1,0 ; IF (X1 < MinX) && (X2 < MinX) Line Is Outside (Skip Line)
  cmplt x2,0
  blt .LineEnd ; Line End

  cmp x1,SCREEN_X-1 ; IF (X1 > MaxX) && (X2 > MaxX) Line Is Outside (Skip Line)
  cmpgt x2,SCREEN_X-1
  bgt .LineEnd ; Line End

  cmp y1,0 ; IF (Y1 < MinY) && (Y2 < MinY) Line Is Outside (Skip Line)
  cmplt y2,0
  blt .LineEnd ; Line End

  cmp y1,SCREEN_Y-1 ; IF (Y1 > MaxY) Y1 = MaxY
  cmpgt y2,SCREEN_Y-1 ; IF (Y1 > MaxY) && (Y2 > MaxY) Line Is Outside (Skip Line)
  bgt .LineEnd ; Line End

  cmp x1,x2 ; IF (X1 != X2) Non Vertical Line
  beq .VerticalLine

  cmp y1,y2 ; IF (Y1 != Y2) Non Vertical And Non Horizontal Line
    beq .HorizontalLine

  imm32 r0,ReciprocalLUT ; R0 = Reciprical LUT

  sub r1,y1,y2 ; M = (Y1 - Y2) / (X1 - X2) Calculate The Gradient
  lsl r1,8
  subs r2,x1,x2
  rsbmi r2,0
  cmp r2,1 ; M Div 1 Check
  beq .MDiv1
  lsl r2,2
  ldr r2,[r0,r2]
  smull r2,r1,r1,r2
  .MDiv1:
  cmp x1,x2
  rsbmi r1,0 ; R1 = M (S.23.8)

  mul r2,x1,y2 ; C = (X1 * Y2 - X2 * Y1) / (X1 - X2) Calculate The Y-Intercept
  mul r3,x2,y1
  sub r2,r3
  lsl r2,8
  subs r3,x1,x2
  rsbmi r3,0
  cmp r3,1 ; C Div 1 Check
  beq .CDiv1
  lsl r3,2
  ldr r3,[r0,r3]
  smull r3,r2,r2,r3
  .CDiv1:
  cmp x1,x2
  rsbmi r2,0 ; R2 = C (S.23.8)

  cmp x1,0 ; IF (X1 < MinX) X1 = MinX, Y1 = M * MinX + C
  movlt x1,0
  asrlt y1,r2,8

  cmp x1,SCREEN_X-1 ; IF (X1 > MaxX) X1 = MaxX, Y1 = M * MaxX + C
  movgt x1,SCREEN_X-1
  mlagt y1,r1,x1,r2
  asrgt y1,8

  cmp y1,0 ; IF (Y1 < MinY) Y1 = MinY, X1 = (MinY - C) / M
  bge .Y1Max
  mov y1,0
  sub x1,y1,r2
  lsls r3,r1,2
  rsbmi r3,0
  ldr r3,[r0,r3]
  smull r3,x1,x1,r3
  cmp r1,0
  rsbmi x1,0

  .Y1Max:
  cmp y1,SCREEN_Y-1 ; IF (Y1 > MaxY) Y1 = MaxY, X1 = (MaxY - C) / M
  ble .X2Min
  mov y1,SCREEN_Y-1
  rsb x1,r2,y1,lsl 8
  lsls r3,r1,2
  rsbmi r3,0
  ldr r3,[r0,r3]
  smull r3,x1,x1,r3
  cmp r1,0
  rsbmi x1,0

  .X2Min:
  cmp x2,0 ; IF (X2 < MinX) X2 = MinX, Y2 = M * MinX + C
  movlt x2,0
  asrlt y2,r2,8

  cmp x2,SCREEN_X-1 ; IF (X2 > MaxX) X2 = MaxX, Y2 = M * MaxX + C
  movgt x2,SCREEN_X-1
  mlagt y2,r1,x2,r2
  asrgt y2,8

  cmp y2,0 ; IF (Y2 < MinY) Y2 = MinY, X2 = (MinY - C) / M
  bge .Y2Max
  mov y2,0
  sub x2,y2,r2
  lsls r3,r1,2
  rsbmi r3,0
  ldr r3,[r0,r3]
  smull r3,x2,x2,r3
  cmp r1,0
  rsbmi x2,0

  .Y2Max:
  cmp y2,SCREEN_Y-1 ; IF (Y2 > MaxY) Y2 = MaxY, X2 = (MaxY - C) / M
  ble .DiagonalPoint
  mov y2,SCREEN_Y-1
  rsb x2,r2,y2,lsl 8
  lsls r3,r1,2
  rsbmi r3,0
  ldr r3,[r0,r3]
  smull r3,x2,x2,r3
  cmp r1,0
  rsbmi x2,0

  .DiagonalPoint:
  cmp x1,0 ; IF (X1 < MinX) || (X2 < MinX) Line Is Outside (Skip Line)
  blt .LineEnd ; Line End
  cmp x2,0
  blt .LineEnd ; Line End

  cmp x1,SCREEN_X-1 ; IF (X1 > MaxX) || (X2 > MaxX) Line Is Outside (Skip Line)
  bgt .LineEnd ; Line End
  cmp x2,SCREEN_X-1
  bgt .LineEnd ; Line End

  cmp y1,0 ; IF (Y1 < MinY) || (Y2 < MinY) Line Is Outside (Skip Line)
  blt .LineEnd ; Line End
  cmp y2,0
  blt .LineEnd ; Line End

  cmp y1,SCREEN_Y-1 ; IF (Y1 > MaxY) || (Y2 > MaxY) Line Is Outside (Skip Line)
  bgt .LineEnd ; Line End
  cmp y2,SCREEN_Y-1
  bgt .LineEnd ; Line End

  cmp x1,x2 ; IF (X1 == X2) && (Y1 == Y2) Line Is Single Point
  cmpeq y1,y2
  beq .Point

  b .DiagonalLine

  .HorizontalLine: ; Horizontal Line
    cmp x1,0 ; IF (X1 < MinX) X1 = MinX
    movlt x1,0
    cmp x1,SCREEN_X-1 ; IF (X1 > MaxX) X1 = MaxX
    movgt x1,SCREEN_X-1

    cmp x2,0 ; IF (X2 < MinX) X2 = MinX
    movlt x2,0
    cmp x2,SCREEN_X-1 ; IF (X2 > MaxX) X2 = MaxX
    movgt x2,SCREEN_X-1

    cmp x1,x2 ; IF (X1 == X2) Line Is Single Point
    beq .Point

    ; Draw Horizontal Line
    subs r0,x2,x1 ; R0 = DX (X2 - X1), Compare DX With Zero
    rsbmi r0,0 ; R0 = ABS(DX)
    movgt r1,2 ; IF (X2 > X1), R1 = 2 (SX)
    mvnlt r1,1 ; IF (X2 < X1), R1 = -2 (SX)
    mov r2,SCREEN_X ; R2 = 240 (Screen Width)
    mla x1,y1,r2,x1 ; X1 = (Y1 * Screen Width) + X1
    lsl x1,1 ; X1 <<= 1
    add x1,VRAM ; X1 = Point Start
    .LoopHorizontal:
      strh color,[x1],r1 ; Store Color To Point Start, Point Start += SX
      subs r0,1 ; DX--
      bge .LoopHorizontal ; IF (DX >= 0) Loop Horizontal Line Drawing
      b .LineEnd ; Line End

  .VerticalLine: ; Vertical Line
    cmp y1,0 ; IF (Y1 < MinY) Y1 = MinY
    movlt y1,0
    cmp y1,SCREEN_Y-1 ; IF (Y1 > MaxY) Y1 = MaxY
    movgt y1,SCREEN_Y-1

    cmp y2,0 ; IF (Y2 < MinY) Y2 = MinY
    movlt y2,0
    cmp y2,SCREEN_Y-1 ; IF (Y2 > MaxY) Y2 = MaxY
    movgt y2,SCREEN_Y-1

    cmp y1,y2 ; IF (Y1 == Y2) Line Is Single Point
    beq .Point

    ; Draw Vertical Line
    subs r0,y2,y1 ; R0 = ABS(DY) (Y2 - Y1)
    rsbmi r0,0 ; R0 = ABS(DY)
    mov   r1,480 ; IF (Y2 > Y1), R1 = 480 (SY)
    rsblt r1,0   ; IF (Y2 < Y1), R1 = -480 (SY)
    mov r2,SCREEN_X ; R1 = 240 (Screen Width)
    mla x1,y1,r2,x1 ; X1 = (Y1 * Screen Width) + X1
    lsl x1,1 ; X1 <<= 1
    add x1,VRAM ; X1 = Point Start
    .LoopVertical:
      strh color,[x1],r1 ; Store Color To Point Start, Point Start += SY
      subs r0,1 ; DY--
      bge .LoopVertical ; IF (DY >= 0) Loop Vertical Line Drawing
      b .LineEnd ; Line End

  .Point: ; Draw Point
    mov r0,SCREEN_X ; R0 = 240 (Screen Width)
    mla x1,y1,r0,x1 ; X1 = (Y1 * Screen Width) + X1
    lsl x1,1 ; X1 <<= 1
    add x1,VRAM ; X1 = Point Start
    strh color,[x1] ; Store Color To Point Start
    b .LineEnd ; Line End

  .DiagonalLine:
    subs r0,x2,x1 ; R0 = DX (X2 - X1), Compare DX To Zero
    rsbmi r0,0 ; R0 = ABS(DX)
    movgt r1,2 ; IF (X2 > X1), R1 = 2 (SX)
    mvnlt r1,1 ; IF (X2 < X1), R1 = -2 (SX)

    subs r2,y2,y1 ; R2 = ABS(DY) (Y2 - Y1), Compare DY To Zero
    rsbmi r2,0 ; R2 = ABS(DY)
    mov   r3,480 ; IF (Y2 > Y1), R3 = 480 (SY)
    rsblt r3,0   ; IF (Y2 < Y1), R3 = -480 (SY)

    mov r4,SCREEN_X ; R4 = 240 (Screen Width)

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
LineX1: dw 120 ; Line X1: 120 Pixels Across
LineY1: dw  80 ; Line Y1:  80 Pixels Down
LineX2: dw 239 ; Line X2: 239 Pixels Across
LineY2: dw 159 ; Line Y2: 159 Pixels Down

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

  ldr r6,[LineX1]
  ldr r7,[LineY1]
  ldr r8,[LineX2]
  ldr r9,[LineY2]
  DrawLineClip r6, r7, r8, r9, r10 ; Draw Line Clip: Line Point X1, Line Point Y1, Line Point X2, Line Point Y2, Line Color
  b loop

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org startcode + (endcopy - start)
include 'ReciprocalLUT.asm' ; Reciprocal LUT