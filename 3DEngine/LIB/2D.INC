macro SwapBuffers src, dest, amount { ; Swap Buffers
  local .Loop
  mov r10,src ; Source Address
  mov r11,dest ; Destination Address
  orr r12,r11,amount ; Copy Amount
  .Loop:
    ldmia r10!,{r0-r9\}
    stmia r11!,{r0-r9\}
    cmp r11,r12
    bne .Loop
}

macro ClearCol col, dest, amount { ; Clear Color (32 Bits For CPU Fixed Copy)
  local .Loop
  imm32 r0,col ; Source Address
  mov r1,r0
  mov r2,r0
  mov r3,r0
  mov r4,r0
  mov r5,r0
  mov r6,r0
  mov r7,r0
  mov r8,r0
  mov r9,r0
  mov r10,r0
  mov r11,r0
  mov r12,dest ; Destination Address
  orr r14,r12,amount ; Copy Amount
  .Loop:
    stmia r12!,{r0-r11\}
    cmp r12,r14
    bne .Loop
}

macro DrawPoint x, y, col { ; x = PointX, y = PointY, col = Colour
  local .SkipPixel
  mov r0,WRAM ; R0 = WRAM Base Pointer
  mov r1,SCREEN_X ; R1 = ScreenX

  cmp x,0 ; Offscreen Cull
  blt .SkipPixel
  cmp y,0
  blt .SkipPixel
  cmp x,SCREEN_X
  bge .SkipPixel
  cmp y,SCREEN_Y
  bge .SkipPixel
  mla r2,y,r1,x ; R2 = Y * ScreenX + X
  lsl r2,1 ; R2 *= BPP
  strh col,[r0,r2] ; Store Pixel To Screen
  .SkipPixel:
}

macro DrawLine x1, y1, x2, y2, col { ; x1 = Point1X, y1 = Point1Y, x2 = Point2X, y2 = Point2Y, col = Colour
  local .LoopX, .SkipPixelX, .LoopY, .SkipPixelY, .LineEnd
  mov r0,WRAM ; R0 = WRAM Base Pointer
  mov r1,SCREEN_X ; R1 = ScreenX
  
  subs r2,x2,x1 ; X2 - X1
  rsbmi r2,0 ; Convert R2 (DX) To ABS(DX)
  mvnlt r3,0 ; IF (X2 < X1), R3 (SX) = -1
  movgt r3,1 ; IF (X2 > X1), R3 (SX) =	1

  subs r4,y2,y1 ; Y2 - Y1
  rsbmi r4,0 ; Convert R4 (DY) To ABS(DY)
  mvnlt r5,0 ; IF (Y2 < Y1), R5 (SY) = -1
  movgt r5,1 ; IF (Y2 > Y1), R5 (SY) =	1

  cmp r2,r4 ; Compare DX To DY
  movgt y2,r2,lsr 1 ; IF (DX >	DY), Y2 = DX / 2 (X Error)
  movle x2,r4,lsr 1 ; IF (DX <= DY), X2 = DY / 2 (Y Error)
  ble .LoopY

  .LoopX:
    cmp x1,0 ; Offscreen Cull
    blt .SkipPixelX
    cmp y1,0
    blt .SkipPixelX
    cmp x1,SCREEN_X
    bge .SkipPixelX
    cmp y1,SCREEN_Y
    bge .SkipPixelX
    mla r6,y1,r1,x1 ; R6 = Y * ScreenX + X
    lsl r6,1 ; R6 *= BPP
    strh col,[r0,r6] ; Store Pixel To Screen
    .SkipPixelX:

    cmp x1,x2 ; While (X1 != X2)
    beq .LineEnd ; IF (X1 == X2), Branch To Line End
    subs y2,r4 ; X Error -= DY
    addlt y1,r5 ; IF (X Error < 0), Y1 += SY
    addlt y2,r2 ; IF (X Error < 0), X Error += DX
    add x1,r3 ; X1 += SX
    b .LoopX ; Loop Line Drawing

  .LoopY:
    cmp x1,0 ; Offscreen Cull
    blt .SkipPixelY
    cmp y1,0
    blt .SkipPixelY
    cmp x1,SCREEN_X
    bge .SkipPixelY
    cmp y1,SCREEN_Y
    bge .SkipPixelY
    mla r6,y1,r1,x1 ; R6 = Y * ScreenX + X
    lsl r6,1 ; R6 *= BPP
    strh col,[r0,r6] ; Store Pixel To Screen
    .SkipPixelY:

    cmp y1,y2 ; While (Y1 != Y2)
    beq .LineEnd ; IF (Y1 == Y2), Branch To Line End
    subs x2,r2 ; Y Error -= DX
    addlt x1,r3 ; IF (Y Error < 0), X1 += SX
    addlt x2,r4 ; IF (Y Error < 0), Y Error += DY
    add y1,r5 ; Y1 += SY
    b .LoopY ; Loop Line Drawing

  .LineEnd: ; End of Line Drawing
}

macro ScanLine x1, y1, x2, y2, side { ; x1 = Point1X, y1 = Point1Y, x2 = Point2X, y2 = Point2Y, side = Left/Right
  local .LoopX, .SkipPixelX, .LoopY, .SkipPixelY, .LineEnd
  imm32 r0,side ; R0 = = Scanline Buffer Offset

  cmp y2,y1 ; IF (Y2 < Y1) Swap Points
  movlt r1,x1
  movlt r2,y1
  movlt x1,x2
  movlt x2,r1
  movlt y1,y2
  movlt y2,r2

  subs r1,x2,x1 ; X2 - X1
  rsbmi r1,0 ; Convert R1 (DX) To ABS(DX)
  mvnlt r2,0 ; IF (X2 < X1), R2 (SX) = -1
  movgt r2,1 ; IF (X2 > X1), R2 (SX) =	1

  sub r3,y2,y1 ; Y2 - Y1 ABS(DY)
  mov r4,1 ; IF (Y2 > Y1), R4 (SY) =  1

  cmp r1,r3 ; Compare DX To DY
  movgt y2,r1,lsr 1 ; IF (DX >	DY), Y2 = DX / 2 (X Error)
  movle x2,r3,lsr 1 ; IF (DX <= DY), X2 = DY / 2 (Y Error)
  ble .LoopY

  .LoopX:
    cmp y1,0 ; Offscreen Cull
    blt .SkipPixelX
    cmp y1,SCREEN_Y
    bge .SkipPixelX
    movs r5,x1
    mvnlt r5,1
    cmp r5,SCREEN_X
    movge r5,SCREEN_X
    mov r6,y1,lsl 1 ; Shift Pixel X Position To Scanline Buffer Y Position
    strh r5,[r0,r6] ; Store Pixel X Position To Scanline Buffer Y Position
    .SkipPixelX:

    cmp x1,x2 ; While (X1 != X2)
    beq .LineEnd ; IF (X1 == X2), Branch To Line End
    subs y2,r3 ; X Error -= DY
    addlt y1,r4 ; IF (X Error < 0), Y1 += SY
    addlt y2,r1 ; IF (X Error < 0), X Error += DX
    add x1,r2 ; X1 += SX
    b .LoopX ; Loop Line Drawing

  .LoopY:
    cmp y1,0 ; Offscreen Cull
    blt .SkipPixelY
    cmp y1,SCREEN_Y
    bge .SkipPixelY
    movs r5,x1
    mvnlt r5,1
    cmp r5,SCREEN_X
    movge r5,SCREEN_X
    mov r6,y1,lsl 1 ; Shift Pixel X Position To Scanline Buffer Y Position
    strh r5,[r0,r6] ; Store Pixel X Position To Scanline Buffer Y Position
    .SkipPixelY:

    cmp y1,y2 ; While (Y1 != Y2)
    beq .LineEnd ; IF (Y1 == Y2), Branch To Line End
    subs x2,r1 ; Y Error -= DX
    addlt x1,r2 ; IF (Y Error < 0), X1 += SX
    addlt x2,r3 ; IF (Y Error < 0), Y Error += DY
    add y1,r4 ; Y1 += SY
    b .LoopY ; Loop Line Drawing

  .LineEnd: ; End of Line Drawing
}