macro SwapBuffers src, dest, amount { ; Swap Buffers
  local .Loop
  mov r12,src ; Source Address
  mov r13,dest ; Destination Address
  add r14,r13,amount ; Copy Amount
  .Loop:
    ldmia r12!,{r0-r11\}
    stmia r13!,{r0-r11\}
    cmp r13,r14
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
  add r14,r12,amount ; Copy Amount
  .Loop:
    stmia r12!,{r0-r11\}
    cmp r12,r14
    bne .Loop
}

macro ClearZBuf { ; Clear Z-Buffer (Only Required When Using Z-buffer)
  local .Loop
  mov r0,$7FFFFFFF ; Clear Z To Maximum Distance
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
  mov r12,WRAM ; Destination Address
  add r12,76800
  add r14,r12,153600 ; Copy Amount
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
  mla r1,y,r1,x ; R1 = Y * ScreenX + X
  lsl r1,1 ; R1 *= BPP
  strh col,[r0,r1] ; Store Pixel To Screen
  .SkipPixel:
}

macro DrawPointZBuf x, y, z, col { ; x = PointX, y = PointY, z = PointZ, col = Colour
  local .SkipPixel
  mov r0,WRAM ; R0 = WRAM Base Pointer
  add r1,r0,76800 ; R1 = Z-Buffer Base Pointer
  mov r2,SCREEN_X ; R1 = ScreenX

  cmp x,0 ; Offscreen Cull
  blt .SkipPixel
  cmp y,0
  blt .SkipPixel
  cmp x,SCREEN_X
  bge .SkipPixel
  cmp y,SCREEN_Y
  bge .SkipPixel
  mla r2,y,r2,x ; R2 = Y * ScreenX + X
  lsl r2,1 ; R2 *= BPP
  lsl r3,r2,1 ; R3 = R2 * BPZ
  ldr r4,[r1,r3] ; Load Z-Buffer Depth
  cmp r4,z ; Compare Z-Buffer Depth To Z
  blt .SkipPixel ; IF (Z-Buffer Depth < Z) Skip Pixel
  strh col,[r0,r2] ; Store Pixel To Screen
  str z,[r1,r3] ; Store Pixel To Z-Buffer
  .SkipPixel:
}

macro DrawLine x1, y1, x2, y2, col { ; x1 = Point1X, y1 = Point1Y, x2 = Point2X, y2 = Point2Y, col = Colour
  local .LoopX, .SkipPixelX, .LoopY, .SkipPixelY, .LineEnd
  mov r0,WRAM ; R0 = WRAM Base Pointer
  mov r1,SCREEN_X ; R1 = ScreenX

  cmp y2,y1 ; IF (Y2 < Y1) Swap Points
  movlt r2,x1
  movlt r3,y1
  movlt x1,x2
  movlt x2,r2
  movlt y1,y2
  movlt y2,r3

  subs r2,x2,x1 ; X2 - X1
  rsbmi r2,0 ; Convert R2 (DX) To ABS(DX)
  mvnlt r3,0 ; IF (X2 < X1), R3 (SX) = -1
  movgt r3,1 ; IF (X2 > X1), R3 (SX) =	1
  moveq r3,0 ; IF (X2 == X1), R3 (SX) = 0

  sub r4,y2,y1 ; Y2 - Y1 ABS(DY)

  cmp r2,r4 ; Compare DX To DY
  lsrgt y2,r2,1 ; IF (DX > DY), Y2 = DX / 2 (X Error)
  lsrle x2,r4,1 ; IF (DX <= DY), X2 = DY / 2 (Y Error)
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
    mla r5,y1,r1,x1 ; R5 = Y * ScreenX + X
    lsl r5,1 ; R5 *= BPP
    strh col,[r0,r5] ; Store Pixel To Screen
    .SkipPixelX:

    cmp x1,x2 ; While (X1 != X2)
    beq .LineEnd ; IF (X1 == X2), Branch To Line End
    subs y2,r4 ; X Error -= DY
    addlt y1,1 ; IF (X Error < 0), Y1 += SY
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
    mla r5,y1,r1,x1 ; R5 = Y * ScreenX + X
    lsl r5,1 ; R5 *= BPP
    strh col,[r0,r5] ; Store Pixel To Screen
    .SkipPixelY:

    cmp y1,y2 ; While (Y1 != Y2)
    beq .LineEnd ; IF (Y1 == Y2), Branch To Line End
    subs x2,r2 ; Y Error -= DX
    addlt x1,r3 ; IF (Y Error < 0), X1 += SX
    addlt x2,r4 ; IF (Y Error < 0), Y Error += DY
    add y1,1 ; Y1 += SY
    b .LoopY ; Loop Line Drawing

  .LineEnd: ; End of Line Drawing
}

macro DrawLineZBuf x1, y1, z1, x2, y2, z2, col { ; x1 = Point1X, y1 = Point1Y, z1 = Point1Z, x2 = Point2X, y2 = Point2Y, z2 = Point2Z, col = Colour
  local .divZPos, .divZNeg, .endZ, .LoopX, .SkipPixelX, .LoopY, .SkipPixelY, .LineEnd
  mov r0,WRAM ; R0 = WRAM Base Pointer

  cmp y2,y1 ; IF (Y2 < Y1) Swap Points
  movlt r1,x1
  movlt r2,y1
  movlt r3,z1
  movlt x1,x2
  movlt x2,r1
  movlt y1,y2
  movlt y2,r2
  movlt z1,z2
  movlt z2,r3

  subs r2,x2,x1 ; X2 - X1
  rsbmi r2,0 ; Convert R2 (DX) To ABS(DX)
  mvnlt r3,0 ; IF (X2 < X1), R3 (SX) = -1
  movgt r3,1 ; IF (X2 > X1), R3 (SX) =	1
  moveq r3,0 ; IF (X2 == X1), R3 (SX) = 0

  sub r4,y2,y1 ; Y2 - Y1 ABS(DY)

  subs r5,z2,z1 ; R5 = Z2 - Z1 (DZ)
  moveq z2,0 ; Z2 = 0 (SZ)
  beq .endZ
  adds r1,r2,r4 ; R1 = Amount Of Pixel To Draw (DXY)
  moveq z2,0 ; IF (DXY == 0) Z2 = 0 (SZ)
  beq .endZ
  mov z2,0 ; Divide DZ By DXY
  cmp r5,0 ; IF (DZ < 0) Negative Divide
  blt .divZNeg
  .divZPos:
  subs r5,r1
  addge z2,1
  bgt .divZPos
  b .endZ
  .divZNeg:
  adds r5,r1
  suble z2,1
  blt .divZNeg
  .endZ: ; Z2 = Quotient (SZ)

  cmp r2,r4 ; Compare DX To DY
  lsrgt y2,r2,1 ; IF (DX >	DY), Y2 = DX / 2 (X Error)
  lsrle x2,r4,1 ; IF (DX <= DY), X2 = DY / 2 (Y Error)
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

    mov r1,SCREEN_X ; R1 = ScreenX
    mla r5,y1,r1,x1 ; R5 = Y * ScreenX + X
    lsl r5,2 ; R5 *= BPZ
    add r1,r0,76800 ; R1 = Z-Buffer Base Pointer
    ldr r1,[r1,r5] ; Load Z-Buffer Depth
    cmp r1,z1 ; Compare Z-Buffer Depth To Z
    blt .SkipPixelX ; IF (Z-Buffer Depth < Z) Skip Pixel
    add r1,r0,76800 ; R1 = Z-Buffer Base Pointer
    str z1,[r1,r5] ; Store Pixel To Z-Buffer
    lsr r5,1 ; R5 = Y * ScreenX + X * BPP
    strh col,[r0,r5] ; Store Pixel To Screen
    .SkipPixelX:

    cmp x1,x2 ; While (X1 != X2)
    beq .LineEnd ; IF (X1 == X2), Branch To Line End
    subs y2,r4 ; X Error -= DY
    addlt y1,1 ; IF (X Error < 0), Y1 += SY
    addlt y2,r2 ; IF (X Error < 0), X Error += DX
    add x1,r3 ; X1 += SX
    add z1,z2 ; Z1 += SZ
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

    mov r1,SCREEN_X ; R1 = ScreenX
    mla r5,y1,r1,x1 ; R5 = Y * ScreenX + X
    lsl r5,2 ; R5 *= BPZ
    add r1,r0,76800 ; R1 = Z-Buffer Base Pointer
    ldr r1,[r1,r5] ; Load Z-Buffer Depth
    cmp r1,z1 ; Compare Z-Buffer Depth To Z
    blt .SkipPixelY ; IF (Z-Buffer Depth < Z) Skip Pixel
    add r1,r0,76800 ; R1 = Z-Buffer Base Pointer
    str z1,[r1,r5] ; Store Pixel To Z-Buffer
    lsr r5,1 ; R5 = Y * ScreenX + X * BPP
    strh col,[r0,r5] ; Store Pixel To Screen
    .SkipPixelY:

    cmp y1,y2 ; While (Y1 != Y2)
    beq .LineEnd ; IF (Y1 == Y2), Branch To Line End
    subs x2,r2 ; Y Error -= DX
    addlt x1,r3 ; IF (Y Error < 0), X1 += SX
    addlt x2,r4 ; IF (Y Error < 0), Y Error += DY
    add y1,1 ; Y1 += SY
    add z1,z2 ; Z1 += SZ
    b .LoopY ; Loop Line Drawing

  .LineEnd: ; End of Line Drawing
}

macro ScanLine x1, y1, x2, y2, side { ; x1 = Point1X, y1 = Point1Y, x2 = Point2X, y2 = Point2Y, side = Left/Right
  local .LoopX, .SkipPixelX, .LoopY, .SkipPixelY, .LineEnd
  imm32 r0,side ; R0 = Scanline Buffer Offset

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
  moveq r2,0 ; IF (X2 == X1), R2 (SX) = 0

  sub r3,y2,y1 ; Y2 - Y1 ABS(DY)

  cmp r1,r3 ; Compare DX To DY
  lsrgt y2,r1,1 ; IF (DX > DY), Y2 = DX / 2 (X Error)
  lsrle x2,r3,1 ; IF (DX <= DY), X2 = DY / 2 (Y Error)
  ble .LoopY

  .LoopX:
    cmp y1,0 ; Offscreen Cull
    blt .SkipPixelX
    cmp y1,SCREEN_Y
    bge .SkipPixelX
    movs r4,x1
    mvnlt r4,0
    cmp r4,SCREEN_X
    movge r4,SCREEN_X
    lsl r5,y1,1 ; Shift Pixel X Position To Scanline Buffer Y Position
    strh r4,[r0,r5] ; Store Pixel X Position To Scanline Buffer Y Position
    .SkipPixelX:

    cmp x1,x2 ; While (X1 != X2)
    beq .LineEnd ; IF (X1 == X2), Branch To Line End
    subs y2,r3 ; X Error -= DY
    addlt y1,1 ; IF (X Error < 0), Y1 += SY
    addlt y2,r1 ; IF (X Error < 0), X Error += DX
    add x1,r2 ; X1 += SX
    b .LoopX ; Loop Line Drawing

  .LoopY:
    cmp y1,0 ; Offscreen Cull
    blt .SkipPixelY
    cmp y1,SCREEN_Y
    bge .SkipPixelY
    movs r4,x1
    mvnlt r4,0
    cmp r4,SCREEN_X
    movge r4,SCREEN_X
    lsl r5,y1,1 ; Shift Pixel X Position To Scanline Buffer Y Position
    strh r4,[r0,r5] ; Store Pixel X Position To Scanline Buffer Y Position
    .SkipPixelY:

    cmp y1,y2 ; While (Y1 != Y2)
    beq .LineEnd ; IF (Y1 == Y2), Branch To Line End
    subs x2,r1 ; Y Error -= DX
    addlt x1,r2 ; IF (Y Error < 0), X1 += SX
    addlt x2,r3 ; IF (Y Error < 0), Y Error += DY
    add y1,1 ; Y1 += SY
    b .LoopY ; Loop Line Drawing

  .LineEnd: ; End of Line Drawing
}