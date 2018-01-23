macro LoadXYZ x, y, z { ; Load X,Y,Z
  ldmia r14!,{r0-r2\} ; R0 = X, R1 = Y, R2 = Z
  Calc3D r0, r1, r2, x, y, z
}

macro Calc3D x, y, z, xcalc, ycalc, zcalc { ; Calculate X,Y,Z 3D
  mov r3,IWRAM ; Load Matrix3D Address
  orr r3,Matrix3D-IWRAM
  ldmia r3!,{r4-r7\} ; XCalc = (Matrix3D[0] * X) + (Matrix3D[1] * Y) + (Matrix3D[2] * Z) + Matrix3D[3]
  mul xcalc,r4,x
  mla xcalc,r5,y,xcalc
  mla xcalc,r6,z,xcalc
  add xcalc,r7,lsl 8
  ldmia r3!,{r4-r7\} ; YCalc = (Matrix3D[4] * X) + (Matrix3D[5] * Y) + (Matrix3D[6] * Z) + Matrix3D[7]
  mul ycalc,r4,x
  mla ycalc,r5,y,ycalc
  mla ycalc,r6,z,ycalc
  add ycalc,r7,lsl 8
  ldmia r3!,{r4-r7\} ; ZCalc = (Matrix3D[8] * X) + (Matrix3D[9] * Y) + (Matrix3D[10] * Z) + Matrix3D[11]
  mul zcalc,r4,x
  mla zcalc,r5,y,zcalc
  mla zcalc,r6,z,zcalc
  adds zcalc,r7,lsl 8 ; Compare To Zero

  Calc2D xcalc, ycalc, zcalc
}

macro Calc2D x, y, z { ; Calculate X,Y 2D
local .skip, .divXPos, .divYPos, .divXNeg, .divYNeg, .endX, .endY
  ble .skip ; IF (Z <= 0) Skip

  lsr z,8 ; Z /= 256

  mov r0,x ; R0 = X
  mov x,0 ; Divide R0 By Z (X / Z)
  cmp r0,0 ; IF (X < 0) Negative Divide
  blt .divXNeg
  .divXPos:
  subs r0,z
  addge x,1
  bgt .divXPos
  b .endX
  .divXNeg:
  adds r0,z
  suble x,1
  blt .divXNeg
  .endX: ; X = Quotient (2D Screen X)
  add x,HALF_SCREEN_X ; X = X / Z + (ScreenX / 2)

  mov r0,y ; R0 = Y
  mov y,0 ; Divide R0 By Z (Y / Z)
  cmp r0,0 ; IF (Y < 0) Negative Divide
  blt .divYNeg
  .divYPos:
  subs r0,z
  addge y,1
  bgt .divYPos
  b .endY
  .divYNeg:
  adds r0,z
  suble y,1
  blt .divYNeg
  .endY: ; Y = Quotient (2D Screen Y)
  add y,HALF_SCREEN_Y ; Y = Y / Z + (ScreenY / 2)

  .skip:
}

macro CullFace x1, y1, x2, y2, x3, y3 { ; Cull Face Calculation
  sub r4,x3,x1 ; R4 = HDX (X3 - X1)
  sub r5,y2,y1 ; R5 = MDY (Y2 - Y1)
  mul r4,r5 ; R4 = HDX * MDY

  sub r5,y3,y1 ; R5 = HDY (Y3 - Y1)
  sub r6,x2,x1 ; R6 = MDX (X2 - X1)
  mul r5,r6 ; R5 = HDY * MDX

  subs r4,r5 ; R4 = R (HDX * MDY) - (HDY * MDX) Compare To Zero
}

macro ScanLineSide x1, y1, x2, y2 { ; Scan Line Side
  local .Left, .Right, .Skip
  cmp y1,y2
  bgt .Left  ; IF (Y1 > Y2) ScanLeft
  blt .Right ; IF (Y1 < Y2) ScanRight
  b .Skip ; IF (Y1 == Y2) Skip
  .Left:
  ScanLine x1, y1, x2, y2, ScanLeft
  b .Skip
  .Right:
  ScanLine x1, y1, x2, y2, ScanRight
  .Skip:
}

macro WireQuad start, end { ; Wire Quad
  local .Loop
  imm32 r14,start ; R14 = Object Start Offset
  imm32 r13,end ; R13 = Object End Offset
  mov r12,IWRAM ; R12 = Line Cache Offset
  orr r12,LineCache-IWRAM
  .Loop:
    LoadXYZ r9, r10, r11 ; R9 = 2D X1, R10 = 2D Y1
    stmia r12!,{r9-r10\} ; Store X1 & Y1 To 1st LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X2, R10 = 2D Y2
    stmia r12!,{r9-r10\} ; Store X2 & Y2 To 2nd LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X3, R10 = 2D Y3
    stmia r12!,{r9-r10\} ; Store X3 & Y3 To 3rd LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X4, R10 = 2D Y4
    stmia r12,{r9-r10\}  ; Store X4 & Y4 To 4th LineCache Address

    sub r12,24 ; Load 1st LineCache Address
    ldmia r12!,{r7-r8\} ; Load X1,Y1 To R7,R8
    ldr r6,[r14],4 ; R6 = Colour
    DrawLine r7, r8, r9, r10, r6

    ldmia r12,{r7-r10\} ; Load X2,Y2,X3,Y3 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    add r12,8 ; Load 3rd LineCache Address
    ldmia r12,{r7-r10\} ; Load X3,Y3,X4,Y4 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    sub r12,16 ; Load 1st LineCache Address
    ldmia r12,{r7-r10\} ; Load X1,Y1,X2,Y2 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro WireQuadZBuf start, end { ; Wire Quad Z-Buffer
  local .Loop
  imm32 r14,start ; R14 = Object Start Offset
  mov r13,IWRAM ; R13 = Line Cache Offset
  orr r13,LineCache-IWRAM
  .Loop:
    LoadXYZ r10, r11, r12 ; R10 = 2D X1, R11 = 2D Y1, R12 = 3D Z1
    stmia r13!,{r10-r12\} ; Store X1 & Y1 & Z1 To 1st LineCache Address

    LoadXYZ r10, r11, r12 ; R10 = 2D X2, R11 = 2D Y2, R12 = 3D Z2
    stmia r13!,{r10-r12\} ; Store X2 & Y2 & Z2 To 2nd LineCache Address

    LoadXYZ r10, r11, r12 ; R10 = 2D X3, R11 = 2D Y3, R12 = 3D Z3
    stmia r13!,{r10-r12\} ; Store X3 & Y3 & Z3 To 3rd LineCache Address

    LoadXYZ r10, r11, r12 ; R10 = 2D X4, R11 = 2D Y4, R12 = 3D Z4
    stmia r13,{r10-r12\}  ; Store X4 & Y4 & Z4 To 4th LineCache Address

    sub r13,36 ; Load 1st LineCache Address
    ldmia r13!,{r7-r9\} ; Load X1,Y1,Z1 To R7,R8,R9
    ldr r6,[r14],4 ; R6 = Colour
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    ldmia r13,{r7-r12\} ; Load X2,Y2,Z2,X3,Y3,Z3 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    add r13,12 ; Load 3rd LineCache Address
    ldmia r13,{r7-r12\} ; Load X3,Y3,Z3,X4,Y4,Z4 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    sub r13,24 ; Load 1st LineCache Address
    ldmia r13,{r7-r12\} ; Load X1,Y1,Z1,X2,Y2,Z2 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro WireQuadCullBack start, end { ; Wire Quad Back Face Cull
  local .Loop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  imm32 r13,end ; R13 = Object End Offset
  mov r12,IWRAM ; R12 = Line Cache Offset
  orr r12,LineCache-IWRAM
  .Loop:
    LoadXYZ r9, r10, r11 ; R9 = 2D X1, R10 = 2D Y1
    stmia r12!,{r9-r10\} ; Store X1 & Y1 To 1st LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X2, R10 = 2D Y2
    stmia r12!,{r9-r10\} ; Store X2 & Y2 To 2nd LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X3, R10 = 2D Y3
    stmia r12,{r9-r10\}  ; Store X3 & Y3 To 3rd LineCache Address

    sub r12,16 ; Load 1st LineCache Address
    ldmia r12,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r9, r10 ; Back Face Cull
    addge r14,16 ; IF ((X3-X1 * Y2-Y1) - (Y3-Y1 * X2-X1)) >= 0 SkipPoly
    bge .SkipPoly

    add r12,24 ; Load 4th LineCache Address
    LoadXYZ r9, r10, r11 ; R9 = 2D X4, R10 = 2D Y4
    stmia r12,{r9-r10\}  ; Store X4 & Y4 To 4th LineCache Address

    sub r12,24 ; Load 1st LineCache Address
    ldmia r12!,{r7-r8\} ; Load X1,Y1 To R7,R8
    ldr r6,[r14],4 ; R6 = Colour
    DrawLine r7, r8, r9, r10, r6

    ldmia r12,{r7-r10\} ; Load X2,Y2,X3,Y3 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    add r12,8 ; Load 3rd LineCache Address
    ldmia r12,{r7-r10\} ; Load X3,Y3,X4,Y4 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    sub r12,16 ; Load 1st LineCache Address
    ldmia r12,{r7-r10\} ; Load X1,Y1,X2,Y2 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    .SkipPoly:
    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro WireQuadCullBackZBuf start, end { ; Wire Quad Back Face Cull Z-Buffer
  local .Loop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  mov r13,IWRAM ; R13 = Line Cache Offset
  orr r13,LineCache-IWRAM
  .Loop:
    LoadXYZ r10, r11, r12 ; R10 = 2D X1, R11 = 2D Y1, R12 = 3D Z1
    stmia r13!,{r10-r12\} ; Store X1 & Y1 & Z1 To 1st LineCache Address

    LoadXYZ r10, r11, r12 ; R10 = 2D X2, R11 = 2D Y2, R12 = 3D Z2
    stmia r13!,{r10-r12\} ; Store X2 & Y2 & Z2 To 2nd LineCache Address

    LoadXYZ r10, r11, r12 ; R10 = 2D X3, R11 = 2D Y3, R12 = 3D Z3
    stmia r13!,{r10-r12\} ; Store X3 & Y3 & Z3 To 3rd LineCache Address

    sub r4,r13,36 ; Load 1st LineCache Address
    ldmia r4,{r0-r1\} ; Load X1,Y1 To R0,R1
    add r4,12 ; Load 2nd LineCache Address
    ldmia r4,{r2-r3\} ; Load X2,Y2 To R2,R3
    CullFace r0, r1, r2, r3, r10, r11 ; Back Face Cull
    addge r14,16 ; IF ((X3-X1 * Y2-Y1) - (Y3-Y1 * X2-X1)) >= 0 SkipPoly
    bge .SkipPoly

    LoadXYZ r10, r11, r12 ; R10 = 2D X4, R11 = 2D Y4, R12 = 3D Z4
    stmia r13,{r10-r12\}  ; Store X4 & Y4 & Z4 To 4th LineCache Address

    sub r13,36 ; Load 1st LineCache Address
    ldmia r13!,{r7-r9\} ; Load X1,Y1,Z1 To R7,R8,R9
    ldr r6,[r14],4 ; R6 = Colour
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    ldmia r13,{r7-r12\} ; Load X2,Y2,Z2,X3,Y3,Z3 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    add r13,12 ; Load 3rd LineCache Address
    ldmia r13,{r7-r12\} ; Load X3,Y3,Z3,X4,Y4,Z4 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    sub r13,24 ; Load 1st LineCache Address
    ldmia r13,{r7-r12\} ; Load X1,Y1,Z1,X2,Y2,Z2 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    .SkipPoly:
    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro WireQuadCullFront start, end { ; Wire Quad Front Face Cull
  local .Loop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  imm32 r13,end ; R13 = Object End Offset
  mov r12,IWRAM ; R12 = Line Cache Offset
  orr r12,LineCache-IWRAM
  .Loop:
    LoadXYZ r9, r10, r11 ; R9 = 2D X1, R10 = 2D Y1
    stmia r12!,{r9-r10\} ; Store X1 & Y1 To 1st LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X2, R10 = 2D Y2
    stmia r12!,{r9-r10\} ; Store X2 & Y2 To 2nd LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X3, R10 = 2D Y3
    stmia r12,{r9-r10\}  ; Store X3 & Y3 To 3rd LineCache Address

    sub r12,16 ; Load 1st LineCache Address
    ldmia r12,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r9, r10 ; Front Face Cull
    addle r14,16 ; IF ((X3-X1 * Y2-Y1) - (Y3-Y1 * X2-X1)) <= 0 SkipPoly
    ble .SkipPoly

    add r12,24 ; Load 4th LineCache Address
    LoadXYZ r9, r10, r11 ; R9 = 2D X4, R10 = 2D Y4
    stmia r12,{r9-r10\}  ; Store X4 & Y4 To 4th LineCache Address

    sub r12,24 ; Load 1st LineCache Address
    ldmia r12!,{r7-r8\} ; Load X1,Y1 To R7,R8
    ldr r6,[r14],4 ; R6 = Colour
    DrawLine r7, r8, r9, r10, r6

    ldmia r12,{r7-r10\} ; Load X2,Y2,X3,Y3 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    add r12,8 ; Load 3rd LineCache Address
    ldmia r12,{r7-r10\} ; Load X3,Y3,X4,Y4 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    sub r12,16 ; Load 1st LineCache Address
    ldmia r12,{r7-r10\} ; Load X1,Y1,X2,Y2 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    .SkipPoly:
    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro WireQuadCullFrontZBuf start, end { ; Wire Quad Front Face Cull Z-Buffer
  local .Loop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  mov r13,IWRAM ; R13 = Line Cache Offset
  orr r13,LineCache-IWRAM
  .Loop:
    LoadXYZ r10, r11, r12 ; R10 = 2D X1, R11 = 2D Y1, R12 = 3D Z1
    stmia r13!,{r10-r12\} ; Store X1 & Y1 & Z1 To 1st LineCache Address

    LoadXYZ r10, r11, r12 ; R10 = 2D X2, R11 = 2D Y2, R12 = 3D Z2
    stmia r13!,{r10-r12\} ; Store X2 & Y2 & Z2 To 2nd LineCache Address

    LoadXYZ r10, r11, r12 ; R10 = 2D X3, R11 = 2D Y3, R12 = 3D Z3
    stmia r13!,{r10-r12\} ; Store X3 & Y3 & Z3 To 3rd LineCache Address

    sub r4,r13,36 ; Load 1st LineCache Address
    ldmia r4,{r0-r1\} ; Load X1,Y1 To R0,R1
    add r4,12 ; Load 2nd LineCache Address
    ldmia r4,{r2-r3\} ; Load X2,Y2 To R2,R3
    CullFace r0, r1, r2, r3, r10, r11 ; Front Face Cull
    addle r14,16 ; IF ((X3-X1 * Y2-Y1) - (Y3-Y1 * X2-X1)) <= 0 SkipPoly
    ble .SkipPoly

    LoadXYZ r10, r11, r12 ; R10 = 2D X4, R11 = 2D Y4, R12 = 3D Z4
    stmia r13,{r10-r12\}  ; Store X4 & Y4 & Z4 To 4th LineCache Address

    sub r13,36 ; Load 1st LineCache Address
    ldmia r13!,{r7-r9\} ; Load X1,Y1,Z1 To R7,R8,R9
    ldr r6,[r14],4 ; R6 = Colour
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    ldmia r13,{r7-r12\} ; Load X2,Y2,Z2,X3,Y3,Z3 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    add r13,12 ; Load 3rd LineCache Address
    ldmia r13,{r7-r12\} ; Load X3,Y3,Z3,X4,Y4,Z4 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    sub r13,24 ; Load 1st LineCache Address
    ldmia r13,{r7-r12\} ; Load X1,Y1,Z1,X2,Y2,Z2 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    .SkipPoly:
    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro FillQuadCullBack start, end { ; Fill Quad Back Face Cull
  local .Loop, .Fill, .SkipPixel, .FillLoop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  imm32 r13,end ; R13 = Object End Offset
  mov r12,IWRAM ; R12 = Line Cache Offset
  orr r12,LineCache-IWRAM
  .Loop:
    LoadXYZ r9, r10, r11 ; R9 = 2D X1, R10 = 2D Y1
    stmia r12!,{r9-r10\} ; Store X1 & Y1 To 1st LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X2, R10 = 2D Y2
    stmia r12!,{r9-r10\} ; Store X2 & Y2 To 2nd LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X3, R10 = 2D Y3
    stmia r12,{r9-r10\}  ; Store X3 & Y3 To 3rd LineCache Address

    sub r12,16 ; Load 1st LineCache Address
    ldmia r12,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r9, r10 ; Back Face Cull
    addge r14,16 ; IF ((X3-X1 * Y2-Y1) - (Y3-Y1 * X2-X1)) >= 0 SkipPoly
    bge .SkipPoly

    LoadXYZ r9, r10, r11 ; R9 = 2D X4, R10 = 2D Y4
    add r12,24 ; Load 4th LineCache Address
    stmia r12,{r9-r10\} ; Store X4 & Y4 To 4th LineCache Address

    sub r12,24 ; Load 1st LineCache Address
    ldmia r12,{r7-r8\} ; Load X1,Y1 To R7,R8
    ScanLineSide r9, r10, r7, r8

    ldmia r12,{r7-r10\} ; Load X1,Y1,X2,Y2 To R7,R8,R9,R10
    ScanLineSide r7, r8, r9, r10

    add r12,8 ; Load 2nd LineCache Address
    ldmia r12,{r7-r10\} ; Load X2,Y2,X3,Y3 To R7,R8,R9,R10
    ScanLineSide r7, r8, r9, r10

    add r12,8 ; Load 3rd LineCache Address
    ldmia r12,{r7-r10\} ; Load X3,Y3,X4,Y4 To R7,R8,R9,R10
    ScanLineSide r7, r8, r9, r10

    sub r12,16 ; Load 1st LineCache Address
    ldr r0,[r12,4]  ; Load 1st Line Point Y Coordinate From LineCache
    ldr r1,[r12,12] ; Load 2nd Line Point Y Coordinate From LineCache
    ldr r2,[r12,20] ; Load 3rd Line Point Y Coordinate From LineCache
    ldr r3,[r12,28] ; Load 4th Line Point Y Coordinate From LineCache
    cmp r0,r1
    movle r4,r0 ; IF (Y1 <= Y2) R4 = Y1 (Top)
    movgt r4,r1 ; IF (Y1 >  Y2) R4 = Y2 (Top)
    movgt r5,r0 ; IF (Y1 >  Y2) R5 = Y1 (Bottom)
    movle r5,r1 ; IF (Y1 <= Y2) R5 = Y2 (Bottom)

    cmp r2,r4
    movle r4,r2 ; IF (Y3 <= Top) R4 = Y3 (Top)
    cmp r2,r5
    movgt r5,r2 ; IF (Y3 > Bottom) R5 = Y3 (Bottom)

    cmp r3,r4
    movle r4,r3 ; IF (Y4 <= Top) R4 = Y4 (Top)
    cmp r3,r5
    movgt r5,r3 ; IF (Y4 > Bottom) R5 = Y4 (Bottom)

    cmp r4,0 ; Offscreen Y Cull
    cmplt r5,0
    addlt r14,4
    blt .SkipPoly
    cmp r4,SCREEN_Y
    cmpge r5,SCREEN_Y
    addge r14,4
    bge .SkipPoly

    cmp r4,0
    movlt r4,0
    cmp r5,SCREEN_Y
    movge r5,SCREEN_Y

    mov r0,WRAM ; R0 = WRAM Base Pointer
    mov r11,SCREEN_X ; R11 = ScreenX
    ldr r6,[r14],4 ; R6 = Colour
    imm32 r10,ScanLeft ; R10 = Scanline Left Buffer Offset
    imm32 r9,ScanRight ; R9 = Scanline Right Buffer Offset
    .Fill:
      lsl r3,r4,1 ; Shift To Scanline Buffer Y Position
      ldrsh r1,[r10,r3] ; R1 = Scanline Left Buffer X
      ldrsh r2,[r9,r3] ; R2 = Scanline Right Buffer X

      mla r3,r4,r11,r1 ; R3 = (Top * ScreenX) + X
      add r3,r0,r3,lsl 1 ; R3 *= BPP (WRAM Start Address)

      cmp r2,SCREEN_X ; IF (X >= ScreenX) Skip Pixel
      sub r2,r1 ; R2 = Scanline Length
      add r2,r3,r2,lsl 1 ; R2 = WRAM End Address
      subge r2,2
      bge .SkipPixel

      cmp r1,0 ; IF (X < 0) Skip Pixel
      addlt r3,2
      blt .SkipPixel
      .FillLoop:
        strh r6,[r3],2 ; Store Pixel Colour To Screen
        .SkipPixel:
        cmp r3,r2 ; IF (X <= Scanline Right Buffer X) Fill Scanline
        ble .FillLoop

      add r4,1
      cmp r4,r5 ; IF (Top <= Bottom) Fill
      ble .Fill

    .SkipPoly:
    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro FillQuadCullFront start, end { ; Fill Quad Front Face Cull
  local .Loop, .Fill, .SkipPixel, .FillLoop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  imm32 r13,end ; R13 = Object End Offset
  mov r12,IWRAM ; R12 = Line Cache Offset
  orr r12,LineCache-IWRAM
  .Loop:
    LoadXYZ r9, r10, r11 ; R9 = 2D X1, R10 = 2D Y1
    stmia r12!,{r9-r10\} ; Store X1 & Y1 To 1st LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X2, R10 = 2D Y2
    stmia r12!,{r9-r10\} ; Store X2 & Y2 To 2nd LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X3, R10 = 2D Y3
    stmia r12,{r9-r10\}  ; Store X3 & Y3 To 3rd LineCache Address

    sub r12,16 ; Load 1st LineCache Address
    ldmia r12,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r9, r10 ; Front Face Cull
    addle r14,16 ; IF ((X3-X1 * Y2-Y1) - (Y3-Y1 * X2-X1)) <= 0 SkipPoly
    ble .SkipPoly

    LoadXYZ r9, r10, r11 ; R9 = 2D X4, R10 = 2D Y4
    add r12,24 ; Load 4th LineCache Address
    stmia r12,{r9-r10\} ; Store X4 & Y4 To 4th LineCache Address

    sub r12,24 ; Load 1st LineCache Address
    ldmia r12,{r7-r8\} ; Load X1,Y1 To R7,R8
    ScanLineSide r7, r8, r9, r10

    ldmia r12,{r7-r10\} ; Load X1,Y1,X2,Y2 To R7,R8,R9,R10
    ScanLineSide r9, r10, r7, r8

    add r12,8 ; Load 2nd LineCache Address
    ldmia r12,{r7-r10\} ; Load X2,Y2,X3,Y3 To R7,R8,R9,R10
    ScanLineSide r9, r10, r7, r8

    add r12,8 ; Load 3rd LineCache Address
    ldmia r12,{r7-r10\} ; Load X3,Y3,X4,Y4 To R7,R8,R9,R10
    ScanLineSide r9, r10, r7, r8

    sub r12,16 ; Load 1st LineCache Address
    ldr r0,[r12,4]  ; Load 1st Line Point Y Coordinate From LineCache
    ldr r1,[r12,12] ; Load 2nd Line Point Y Coordinate From LineCache
    ldr r2,[r12,20] ; Load 3rd Line Point Y Coordinate From LineCache
    ldr r3,[r12,28] ; Load 4th Line Point Y Coordinate From LineCache
    cmp r0,r1
    movle r4,r0 ; IF (Y1 <= Y2) R4 = Y1 (Top)
    movgt r4,r1 ; IF (Y1 >  Y2) R4 = Y2 (Top)
    movgt r5,r0 ; IF (Y1 >  Y2) R5 = Y1 (Bottom)
    movle r5,r1 ; IF (Y1 <= Y2) R5 = Y2 (Bottom)

    cmp r2,r4
    movle r4,r2 ; IF (Y3 <= Top) R4 = Y3 (Top)
    cmp r2,r5
    movgt r5,r2 ; IF (Y3 > Bottom) R5 = Y3 (Bottom)

    cmp r3,r4
    movle r4,r3 ; IF (Y4 <= Top) R4 = Y4 (Top)
    cmp r3,r5
    movgt r5,r3 ; IF (Y4 > Bottom) R5 = Y4 (Bottom)

    cmp r4,0 ; Offscreen Y Cull
    cmplt r5,0
    addlt r14,4
    blt .SkipPoly
    cmp r4,SCREEN_Y
    cmpge r5,SCREEN_Y
    addge r14,4
    bge .SkipPoly

    cmp r4,0
    movlt r4,0
    cmp r5,SCREEN_Y
    movge r5,SCREEN_Y

    mov r0,WRAM ; R0 = WRAM Base Pointer
    mov r11,SCREEN_X ; R11 = ScreenX
    ldr r6,[r14],4 ; R6 = Colour
    imm32 r10,ScanLeft ; R10 = Scanline Left Buffer Offset
    imm32 r9,ScanRight ; R9 = Scanline Right Buffer Offset
    .Fill:
      lsl r3,r4,1 ; Shift To Scanline Buffer Y Position
      ldrsh r1,[r10,r3] ; R1 = Scanline Left Buffer X
      ldrsh r2,[r9,r3] ; R2 = Scanline Right Buffer X

      mla r3,r4,r11,r1 ; R3 = (Top * ScreenX) + X
      add r3,r0,r3,lsl 1 ; R3 *= BPP (WRAM Start Address)

      cmp r2,SCREEN_X ; IF (X >= ScreenX) Skip Pixel
      sub r2,r1 ; R2 = Scanline Length
      add r2,r3,r2,lsl 1 ; R2 = WRAM End Address
      subge r2,2
      bge .SkipPixel

      cmp r1,0 ; IF (X < 0) Skip Pixel
      addlt r3,2
      blt .SkipPixel
      .FillLoop:
        strh r6,[r3],2 ; Store Pixel Colour To Screen
        .SkipPixel:
        cmp r3,r2 ; IF (X <= Scanline Right Buffer X) Fill Scanline
        ble .FillLoop

      add r4,1
      cmp r4,r5 ; IF (Top <= Bottom) Fill
      ble .Fill

    .SkipPoly:
    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro WireTri start, end { ; Wire Tri
  local .Loop
  imm32 r14,start ; R14 = Object Start Offset
  imm32 r13,end ; R13 = Object End Offset
  mov r12,IWRAM ; R12 = Line Cache Offset
  orr r12,LineCache-IWRAM
  .Loop:
    LoadXYZ r9, r10, r11 ; R9 = 2D X1, R10 = 2D Y1
    stmia r12!,{r9-r10\} ; Store X1 & Y1 To 1st LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X2, R10 = 2D Y2
    stmia r12!,{r9-r10\} ; Store X2 & Y2 To 2nd LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X3, R10 = 2D Y3
    stmia r12,{r9-r10\}  ; Store X3 & Y3 To 3rd LineCache Address

    sub r12,16 ; Load 1st LineCache Address
    ldmia r12!,{r7-r8\} ; Load X1,Y1 To R7,R8
    ldr r6,[r14],4 ; R6 = Colour
    DrawLine r7, r8, r9, r10, r6

    ldmia r12,{r7-r10\} ; Load X2,Y2,X3,Y3 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    sub r12,8 ; Load 1st LineCache Address
    ldmia r12,{r7-r10\} ; Load X1,Y1,X2,Y2 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro WireTriZBuf start, end { ; Wire Tri Z-Buffer
  local .Loop
  imm32 r14,start ; R14 = Object Start Offset
  mov r13,IWRAM ; R13 = Line Cache Offset
  orr r13,LineCache-IWRAM
  .Loop:
    LoadXYZ r10, r11, r12 ; R10 = 2D X1, R11 = 2D Y1, R12 = 3D Z1
    stmia r13!,{r10-r12\} ; Store X1 & Y1 & Z1 To 1st LineCache Address

    LoadXYZ r10, r11, r12 ; R10 = 2D X2, R11 = 2D Y2, R12 = 3D Z2
    stmia r13!,{r10-r12\} ; Store X2 & Y2 & Z2 To 2nd LineCache Address

    LoadXYZ r10, r11, r12 ; R10 = 2D X3, R11 = 2D Y3, R12 = 3D Z3
    stmia r13,{r10-r12\}  ; Store X3 & Y3 & Z3 To 3rd LineCache Address

    sub r13,24 ; Load 1st LineCache Address
    ldmia r13!,{r7-r9\} ; Load X1,Y1,Z1 To R7,R8,R9
    ldr r6,[r14],4 ; R6 = Colour
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    ldmia r13,{r7-r12\} ; Load X2,Y2,Z2,X3,Y3,Z3 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    sub r13,12 ; Load 1st LineCache Address
    ldmia r13,{r7-r12\} ; Load X1,Y1,Z1,X2,Y2,Z2 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro WireTriCullBack start, end { ; Wire Tri Back Face Cull
  local .Loop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  imm32 r13,end ; R13 = Object End Offset
  mov r12,IWRAM ; R12 = Line Cache Offset
  orr r12,LineCache-IWRAM
  .Loop:
    LoadXYZ r9, r10, r11 ; R9 = 2D X1, R10 = 2D Y1
    stmia r12!,{r9-r10\} ; Store X1 & Y1 To 1st LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X2, R10 = 2D Y2
    stmia r12!,{r9-r10\} ; Store X2 & Y2 To 2nd LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X3, R10 = 2D Y3
    stmia r12,{r9-r10\}  ; Store X3 & Y3 To 3rd LineCache Address

    sub r12,16 ; Load 1st LineCache Address
    ldmia r12,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r9, r10 ; Back Face Cull
    addge r14,4 ; IF ((X3-X1 * Y2-Y1) - (Y3-Y1 * X2-X1)) >= 0 SkipPoly
    bge .SkipPoly

    ldmia r12!,{r7-r8\} ; Load X1,Y1 To R7,R8
    ldr r6,[r14],4 ; R6 = Colour
    DrawLine r7, r8, r9, r10, r6

    ldmia r12,{r7-r10\} ; Load X2,Y2,X3,Y3 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    sub r12,8 ; Load 1st LineCache Address
    ldmia r12,{r7-r10\} ; Load X1,Y1,X2,Y2 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    .SkipPoly:
    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro WireTriCullBackZBuf start, end { ; Wire Tri Back Face Cull Z-Buffer
  local .Loop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  mov r13,IWRAM ; R13 = Line Cache Offset
  orr r13,LineCache-IWRAM
  .Loop:
    LoadXYZ r10, r11, r12 ; R10 = 2D X1, R11 = 2D Y1, R12 = 3D Z1
    stmia r13!,{r10-r12\} ; Store X1 & Y1 & Z1 To 1st LineCache Address

    LoadXYZ r10, r11, r12 ; R10 = 2D X2, R11 = 2D Y2, R12 = 3D Z2
    stmia r13!,{r10-r12\} ; Store X2 & Y2 & Z2 To 2nd LineCache Address

    LoadXYZ r10, r11, r12 ; R10 = 2D X3, R11 = 2D Y3, R12 = 3D Z3
    stmia r13,{r10-r12\}  ; Store X3 & Y3 & Z3 To 3rd LineCache Address

    sub r13,24 ; Load 1st LineCache Address
    ldmia r13,{r0-r1\} ; Load X1,Y1 To R0,R1
    add r4,r13,12 ; Load 2nd LineCache Address
    ldmia r4,{r2-r3\} ; Load X2,Y2 To R2,R3
    CullFace r0, r1, r2, r3, r10, r11 ; Back Face Cull
    addge r14,4 ; IF ((X3-X1 * Y2-Y1) - (Y3-Y1 * X2-X1)) >= 0 SkipPoly
    bge .SkipPoly

    ldmia r13!,{r7-r9\} ; Load X1,Y1,Z1 To R7,R8,R9
    ldr r6,[r14],4 ; R6 = Colour
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    ldmia r13,{r7-r12\} ; Load X2,Y2,Z2,X3,Y3,Z3 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    sub r13,12 ; Load 1st LineCache Address
    ldmia r13,{r7-r12\} ; Load X1,Y1,Z1,X2,Y2,Z2 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    .SkipPoly:
    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro WireTriCullFront start, end { ; Wire Tri Front Face Cull
  local .Loop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  imm32 r13,end ; R13 = Object End Offset
  mov r12,IWRAM ; R12 = Line Cache Offset
  orr r12,LineCache-IWRAM
  .Loop:
    LoadXYZ r9, r10, r11 ; R9 = 2D X1, R10 = 2D Y1
    stmia r12!,{r9-r10\} ; Store X1 & Y1 To 1st LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X2, R10 = 2D Y2
    stmia r12!,{r9-r10\} ; Store X2 & Y2 To 2nd LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X3, R10 = 2D Y3
    stmia r12,{r9-r10\}  ; Store X3 & Y3 To 3rd LineCache Address

    sub r12,16 ; Load 1st LineCache Address
    ldmia r12,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r9, r10 ; Front Face Cull
    addle r14,4 ; IF ((X3-X1 * Y2-Y1) - (Y3-Y1 * X2-X1)) <= 0 SkipPoly
    ble .SkipPoly

    ldmia r12!,{r7-r8\} ; Load X1,Y1 To R7,R8
    ldr r6,[r14],4 ; R6 = Colour
    DrawLine r7, r8, r9, r10, r6

    ldmia r12,{r7-r10\} ; Load X2,Y2,X3,Y3 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    sub r12,8 ; Load 1st LineCache Address
    ldmia r12,{r7-r10\} ; Load X1,Y1,X2,Y2 To R7,R8,R9,R10
    DrawLine r7, r8, r9, r10, r6

    .SkipPoly:
    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro WireTriCullFrontZBuf start, end { ; Wire Tri Front Face Cull Z-Buffer
  local .Loop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  mov r13,IWRAM ; R13 = Line Cache Offset
  orr r13,LineCache-IWRAM
  .Loop:
    LoadXYZ r10, r11, r12 ; R10 = 2D X1, R11 = 2D Y1, R12 = 3D Z1
    stmia r13!,{r10-r12\} ; Store X1 & Y1 & Z1 To 1st LineCache Address

    LoadXYZ r10, r11, r12 ; R10 = 2D X2, R11 = 2D Y2, R12 = 3D Z2
    stmia r13!,{r10-r12\} ; Store X2 & Y2 & Z2 To 2nd LineCache Address

    LoadXYZ r10, r11, r12 ; R10 = 2D X3, R11 = 2D Y3, R12 = 3D Z3
    stmia r13,{r10-r12\}  ; Store X3 & Y3 & Z3 To 3rd LineCache Address

    sub r13,24 ; Load 1st LineCache Address
    ldmia r13,{r0-r1\} ; Load X1,Y1 To R0,R1
    add r4,r13,12 ; Load 2nd LineCache Address
    ldmia r4,{r2-r3\} ; Load X2,Y2 To R2,R3
    CullFace r0, r1, r2, r3, r10, r11 ; Front Face Cull
    addle r14,4 ; IF ((X3-X1 * Y2-Y1) - (Y3-Y1 * X2-X1)) <= 0 SkipPoly
    ble .SkipPoly

    ldmia r13!,{r7-r9\} ; Load X1,Y1,Z1 To R7,R8,R9
    ldr r6,[r14],4 ; R6 = Colour
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    ldmia r13,{r7-r12\} ; Load X2,Y2,Z2,X3,Y3,Z3 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    sub r13,12 ; Load 1st LineCache Address
    ldmia r13,{r7-r12\} ; Load X1,Y1,Z1,X2,Y2,Z2 To R7,R8,R9,R10,R11,R12
    DrawLineZBuf r7, r8, r9, r10, r11, r12, r6

    .SkipPoly:
    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro FillTriCullBack start, end { ; Fill Tri Back Face Cull
  local .Loop, .Fill, .SkipPixel, .FillLoop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  imm32 r13,end ; R13 = Object End Offset
  mov r12,IWRAM ; R12 = Line Cache Offset
  orr r12,LineCache-IWRAM
  .Loop:
    LoadXYZ r9, r10, r11 ; R9 = 2D X1, R10 = 2D Y1
    stmia r12!,{r9-r10\} ; Store X1 & Y1 To 1st LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X2, R10 = 2D Y2
    stmia r12,{r9-r10\}  ; Store X2 & Y2 To 2nd LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X3, R10 = 2D Y3
    sub r12,8 ; Load 1st LineCache Address
    ldmia r12,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r9, r10 ; Back Face Cull
    addge r14,4 ; IF ((X3-X1 * Y2-Y1) - (Y3-Y1 * X2-X1)) >= 0 SkipPoly
    bge .SkipPoly

    add r12,16 ; Load 3rd LineCache Address
    stmia r12,{r9-r10\} ; Store X3 & Y3 To 3rd LineCache Address

    sub r12,16 ; Load 1st LineCache Address
    ldmia r12!,{r7-r8\} ; Load X1,Y1 To R7,R8
    ScanLineSide r9, r10, r7, r8

    ldmia r12,{r7-r10\} ; Load X2,Y2,X3,Y3 To R7,R8,R9,R10
    ScanLineSide r7, r8, r9, r10

    sub r12,8 ; Load 1st LineCache Address
    ldmia r12,{r7-r10\} ; Load X1,Y1,X2,Y2 To R7,R8,R9,R10
    ScanLineSide r7, r8, r9, r10

    ldr r0,[r12,4]  ; Load 1st Line Point Y Coordinate From LineCache
    ldr r1,[r12,12] ; Load 2nd Line Point Y Coordinate From LineCache
    ldr r2,[r12,20] ; Load 3rd Line Point Y Coordinate From LineCache

    cmp r0,r1
    movle r4,r0 ; IF (Y1 <= Y2) R4 = Y1 (Top)
    movgt r4,r1 ; IF (Y1 >  Y2) R4 = Y2 (Top)
    movgt r5,r0 ; IF (Y1 >  Y2) R5 = Y1 (Bottom)
    movle r5,r1 ; IF (Y1 <= Y2) R5 = Y2 (Bottom)

    cmp r2,r4
    movle r4,r2 ; IF (Y3 <= Top) R4 = Y3 (Top)
    cmp r2,r5
    movgt r5,r2 ; IF (Y3 > Bottom) R5 = Y3 (Bottom)

    cmp r4,0 ; Offscreen Y Cull
    cmplt r5,0
    addlt r14,4
    blt .SkipPoly
    cmp r4,SCREEN_Y
    cmpge r5,SCREEN_Y
    addge r14,4
    bge .SkipPoly

    cmp r4,0
    movlt r4,0
    cmp r5,SCREEN_Y
    movge r5,SCREEN_Y

    mov r0,WRAM ; R0 = WRAM Base Pointer
    mov r11,SCREEN_X ; R11 = ScreenX
    ldr r6,[r14],4 ; R6 = Colour
    imm32 r10,ScanLeft ; R10 = Scanline Left Buffer Offset
    imm32 r9,ScanRight ; R9 = Scanline Right Buffer Offset
    .Fill:
      lsl r3,r4,1 ; Shift To Scanline Buffer Y Position
      ldrsh r1,[r10,r3] ; R1 = Scanline Left Buffer X
      ldrsh r2,[r9,r3] ; R2 = Scanline Right Buffer X

      mla r3,r4,r11,r1 ; R3 = (Top * ScreenX) + X
      add r3,r0,r3,lsl 1 ; R3 *= BPP (WRAM Start Address)

      cmp r2,SCREEN_X ; IF (X >= ScreenX) Skip Pixel
      sub r2,r1 ; R2 = Scanline Length
      add r2,r3,r2,lsl 1 ; R2 = WRAM End Address
      subge r2,2
      bge .SkipPixel

      cmp r1,0 ; IF (X < 0) Skip Pixel
      addlt r3,2
      blt .SkipPixel
      .FillLoop:
        strh r6,[r3],2 ; Store Pixel Colour To Screen
        .SkipPixel:
        cmp r3,r2 ; IF (X <= Scanline Right Buffer X) Fill Scanline
        ble .FillLoop

      add r4,1
      cmp r4,r5 ; IF (Top <= Bottom) Fill
      ble .Fill

    .SkipPoly:
    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro FillTriCullFront start, end { ; Fill Tri Front Face Cull
  local .Loop, .Fill, .SkipPixel, .FillLoop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  imm32 r13,end ; R13 = Object End Offset
  mov r12,IWRAM ; R12 = Line Cache Offset
  orr r12,LineCache-IWRAM
  .Loop:
    LoadXYZ r9, r10, r11 ; R9 = 2D X1, R10 = 2D Y1
    stmia r12!,{r9-r10\} ; Store X1 & Y1 To 1st LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X2, R10 = 2D Y2
    stmia r12,{r9-r10\}  ; Store X2 & Y2 To 2nd LineCache Address

    LoadXYZ r9, r10, r11 ; R9 = 2D X3, R10 = 2D Y3
    sub r12,8 ; Load 1st LineCache Address
    ldmia r12,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r9, r10 ; Front Face Cull
    addle r14,4 ; IF ((X3-X1 * Y2-Y1) - (Y3-Y1 * X2-X1)) <= 0 SkipPoly
    ble .SkipPoly

    add r12,16 ; Load 3rd LineCache Address
    stmia r12,{r9-r10\} ; Store X3 & Y3 To 3rd LineCache Address

    sub r12,16 ; Load 1st LineCache Address
    ldmia r12!,{r7-r8\} ; Load X1,Y1 To R7,R8
    ScanLineSide r7, r8, r9, r10

    ldmia r12,{r7-r10\} ; Load X2,Y2,X3,Y3 To R7,R8,R9,R10
    ScanLineSide r9, r10, r7, r8

    sub r12,8 ; Load 1st LineCache Address
    ldmia r12,{r7-r10\} ; Load X1,Y1,X2,Y2 To R7,R8,R9,R10
    ScanLineSide r9, r10, r7, r8

    ldr r0,[r12,4]  ; Load 1st Line Point Y Coordinate From LineCache
    ldr r1,[r12,12] ; Load 2nd Line Point Y Coordinate From LineCache
    ldr r2,[r12,20] ; Load 3rd Line Point Y Coordinate From LineCache

    cmp r0,r1
    movle r4,r0 ; IF (Y1 <= Y2) R4 = Y1 (Top)
    movgt r4,r1 ; IF (Y1 >  Y2) R4 = Y2 (Top)
    movgt r5,r0 ; IF (Y1 >  Y2) R5 = Y1 (Bottom)
    movle r5,r1 ; IF (Y1 <= Y2) R5 = Y2 (Bottom)

    cmp r2,r4
    movle r4,r2 ; IF (Y3 <= Top) R4 = Y3 (Top)
    cmp r2,r5
    movgt r5,r2 ; IF (Y3 > Bottom) R5 = Y3 (Bottom)

    cmp r4,0 ; Offscreen Y Cull
    cmplt r5,0
    addlt r14,4
    blt .SkipPoly
    cmp r4,SCREEN_Y
    cmpge r5,SCREEN_Y
    addge r14,4
    bge .SkipPoly

    cmp r4,0
    movlt r4,0
    cmp r5,SCREEN_Y
    movge r5,SCREEN_Y

    mov r0,WRAM ; R0 = WRAM Base Pointer
    mov r11,SCREEN_X ; R11 = ScreenX
    ldr r6,[r14],4 ; R6 = Colour
    imm32 r10,ScanLeft ; R10 = Scanline Left Buffer Offset
    imm32 r9,ScanRight ; R9 = Scanline Right Buffer Offset
    .Fill:
      lsl r3,r4,1 ; Shift To Scanline Buffer Y Position
      ldrsh r1,[r10,r3] ; R1 = Scanline Left Buffer X
      ldrsh r2,[r9,r3] ; R2 = Scanline Right Buffer X

      mla r3,r4,r11,r1 ; R3 = (Top * ScreenX) + X
      add r3,r0,r3,lsl 1 ; R3 *= BPP (WRAM Start Address)

      cmp r2,SCREEN_X ; IF (X >= ScreenX) Skip Pixel
      sub r2,r1 ; R2 = Scanline Length
      add r2,r3,r2,lsl 1 ; R2 = WRAM End Address
      subge r2,2
      bge .SkipPixel

      cmp r1,0 ; IF (X < 0) Skip Pixel
      addlt r3,2
      blt .SkipPixel
      .FillLoop:
        strh r6,[r3],2 ; Store Pixel Colour To Screen
        .SkipPixel:
        cmp r3,r2 ; IF (X <= Scanline Right Buffer X) Fill Scanline
        ble .FillLoop

      add r4,1
      cmp r4,r5 ; IF (Top <= Bottom) Fill
      ble .Fill

    .SkipPoly:
    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro Point start, end { ; Point
  local .Loop
  imm32 r14,start ; R14 = Object Start Offset
  imm32 r13,end ; R13 = Object End Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X, R9 = 2D Y
    ldr r10,[r14],4 ; R10 = Colour
    DrawPoint r8, r9, r10
    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro PointZBuf start, end { ; Point Z-Buffer
  local .Loop
  imm32 r14,start ; R14 = Object Start Offset
  imm32 r13,end ; R13 = Object End Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X, R9 = 2D Y, R10 = Z
    ldr r11,[r14],4 ; R11 = Colour
    DrawPointZBuf r8, r9, r10, r11
    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro Line start, end { ; Line
  local .Loop
  imm32 r14,start ; R14 = Object Start Offset
  imm32 r13,end ; R13 = Object End Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1
    LoadXYZ r10, r11, r12 ; R10 = 2D X1, R11 = 2D Y1
    ldr r12,[r14],4 ; R12 = Colour
    DrawLine r8, r9, r10, r11, r12
    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro LineZBuf start, end { ; Line Z-Buffer
  local .Loop
  imm32 r14,start ; R14 = Object Start Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1, R10 = 3D Z
    LoadXYZ r11, r12, r13 ; R11 = 2D X1, R12 = 2D Y1, R13 = 3D Z
    ldr r7,[r14],4 ; R7 = Colour
    DrawLineZBuf r8, r9, r10, r11, r12, r13, r7
    imm32 r13,end ; R13 = Object End Offset
    cmp r14,r13 ; IF (Object Start Offset != Object End Offset) Loop
    bne .Loop
}

macro XPos x { ; Object X Translation
  imm32 r0,x ; Load X Translation Value
  mov r1,IWRAM ; Load Matrix3D Address
  orr r1,Matrix3D-IWRAM
  str r0,[r1,12] ; Matrix3D[3] = (Translation X)
}

macro YPos y { ; Object Y Translation
  imm32 r0,y ; Load Y Translation Value
  mov r1,IWRAM ; Load Matrix3D Address
  orr r1,Matrix3D-IWRAM
  str r0,[r1,28] ; Matrix3D[7] = (Translation Y)
}

macro ZPos z { ; Object Z Translation
  imm32 r0,z ; Load Z Translation Value
  mov r1,IWRAM ; Load Matrix3D Address
  orr r1,Matrix3D-IWRAM
  str r0,[r1,44] ; Matrix3D[11] = (Translation Z)
}

macro XYZPos x, y, z { ; Object X, Y, Z Translation
  imm32 r0,x ; Load X, Y, Z Translation Value
  imm32 r1,y ; Load Y Translation Value
  imm32 r2,z ; Load Z Translation Value
  mov r3,IWRAM ; Load Matrix3D Address
  orr r3,Matrix3D-IWRAM
  str r0,[r3,12] ; Matrix3D[3] = (Translation X)
  str r1,[r3,28] ; Matrix3D[7] = (Translation Y)
  str r2,[r3,44] ; Matrix3D[11] = (Translation Z)
}

macro XRotCalc xrot, precalc { ; Return X Rotation
  imm32 r1,precalc ; Load Matrix Sin & Cos Pre-Calculated Table
  imm32 r12,XRot ; Load X Rotation Start Address
  ldr r0,[r12],12 ; Load X Rotate Value To R0 (R12 = Matrix3D)
  add r0,r1,r0,lsl 4 ; Add X Rotate Matrix Offset To R0 (* 16)
  ldmia r0,{r1-r3\} ; Load XC,-XS,XS To R1,R2,R3

  str r1,[r12,20] ; Store R1  (XC) To Matrix3D  6th Word
  str r2,[r12,24] ; Store R2 (-XS) To Matrix3D  7th Word
  str r3,[r12,36] ; Store R3  (XS) To Matrix3D 10th Word
  str r1,[r12,40] ; Store R1  (XC) To Matrix3D 11th Word
}

macro YRotCalc yrot, precalc { ; Return Y Rotation
  imm32 r1,precalc ; Load Matrix Sin & Cos Pre-Calculated Table
  imm32 r12,YRot ; Load Y Rotation Start Address
  ldr r0,[r12],8 ; Load Y Rotate Value To R0 (R12 = Matrix3D)
  add r0,r1,r0,lsl 4 ; Add Y Rotate Matrix Offset To R0 (* 16)
  ldmia r0,{r1-r3\} ; Load YC,-YS,YS To R1,R2,R3

  str r1,[r12]    ; Store R1  (YC) To Matrix3D  1st Word
  str r3,[r12,8]  ; Store R3  (YS) To Matrix3D  3rd Word
  str r2,[r12,32] ; Store R2 (-YS) To Matrix3D  9th Word
  str r1,[r12,40] ; Store R1  (YC) To Matrix3D 11th Word
}

macro ZRotCalc zrot, precalc { ; Return Z Rotation
  imm32 r1,precalc ; Load Matrix Sin & Cos Pre-Calculated Table
  imm32 r12,ZRot ; Load Z Rotation Start Address
  ldr r0,[r12],4 ; Load Z Rotate Value To R0 (R12 = Matrix3D)
  add r0,r1,r0,lsl 4 ; Add Z Rotate Matrix Offset To R0 (* 16)
  ldmia r0,{r1-r3\} ; Load ZC,-ZS,ZS To R1,R2,R3

  str r1,[r12]    ; Store R1  (ZC) To Matrix3D 1st Word
  str r2,[r12,4]  ; Store R2 (-ZS) To Matrix3D 2nd Word
  str r3,[r12,16] ; Store R3  (ZS) To Matrix3D 5th Word
  str r1,[r12,20] ; Store R1  (ZC) To Matrix3D 6th Word
}

macro XYRotCalc xrot, yrot, precalc { ; Return XY Rotation
  imm32 r0,precalc ; Load Matrix Sin & Cos Pre-Calculated Table
  imm32 r12,XRot ; Load X Rotation Start Address
  ldr r2,[r12],4 ; Load X Rotate Value To R2 (R12 = Y Rotation)
  add r1,r0,r2,lsl 4 ; Add X Rotate Matrix Offset To R1 (* 16)

  ldr r2,[r12],8 ; Load Y Rotate Value To R2 (R12 = Matrix3D)
  add r2,r0,r2,lsl 4 ; Add Y Rotate Matrix Offset To R2 (* 16)

  ldmia r2,{r6-r8\} ; Load YC,-YS,YS To R6,R7,R8
  ldmia r1,{r2-r5\} ; Load XC,-XS,XS,-XC To R2,R3,R4,R5
  
  str r6,[r12] ; Store R6 (YC) To Matrix3D 1st Word
  mul r0,r4,r8 ; Load (XS * YS) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,4] ; Store R0 (XS * YS) To Matrix3D 2nd Word
  mul r0,r5,r8 ; Load (-XC * YS) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,8]  ; Store R0 (-XC * YS) To Matrix3D 3rd Word
  str r2,[r12,20] ; Store R2 (XC) To Matrix3D 6th Word
  str r4,[r12,24] ; Store R4 (XS) To Matrix3D 7th Word
  str r8,[r12,32] ; Store R8 (YS) To Matrix3D 9th Word
  mul r0,r3,r6 ; Load (-XS * YC) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,36] ; Store R0 (-XS * YC) To Matrix3D 10th Word
  mul r0,r2,r6 ; Load (XC * YC) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,40] ; Store R0 (XC * YC) To Matrix3D 11th Word
}

macro XZRotCalc xrot, zrot, precalc { ; Return XZ Rotation
  imm32 r0,precalc ; Load Matrix Sin & Cos Pre-Calculated Table
  imm32 r12,XRot ; Load X Rotation Start Address
  ldr r2,[r12],8 ; Load X Rotate Value To R2 (R12 = Z Rotation)
  add r1,r0,r2,lsl 4 ; Add X Rotate Matrix Offset To R1 (* 16)

  ldr r2,[r12],4 ; Load Z Rotate Value To R2 (R12 = Matrix3D)
  add r2,r0,r2,lsl 4 ; Add Z Rotate Matrix Offset To R2 (* 16)

  ldmia r2,{r5-r8\} ; Load ZC,-ZS,ZS,-ZC To R5,R6,R7,R8
  ldmia r1,{r2-r4\} ; Load XC,-XS,XS To R2,R3,R4

  str r5,[r12]   ; Store R5 (ZC) To Matrix3D 1st Word
  str r7,[r12,4] ; Store R7 (ZS) To Matrix3D 2nd Word
  mul r0,r2,r6 ; Load (XC * -ZS) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,16] ; Store R0 (XC * -ZS) To Matrix3D 5th Word
  mul r0,r2,r5 ; Load (XC * ZC) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,20] ; Store R0 (XC * ZC) To Matrix3D 6th Word
  str r4,[r12,24] ; store R4 (XS) To Matrix3D 7th Word
  mul r0,r4,r7 ; Load (XS * ZS) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,32] ; Store R0 (XS * ZS) To Matrix3D 9th Word
  mul r0,r4,r8 ; Load (XS * -ZC) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,36] ; Store R0 (XS * -ZC) To Matrix3D 10th Word
  str r2,[r12,40] ; Store R2 (XC) To Matrix3D 11th Word
}

macro YZRotCalc yrot, zrot, precalc { ; Return YZ Rotation
  imm32 r0,precalc ; Load Matrix Sin & Cos Pre-Calculated Table
  imm32 r12,YRot ; Load Y Rotation Start Address
  ldr r2,[r12],4 ; Load Y Rotate Value To R2 (R12 = Z Rotation)
  add r1,r0,r2,lsl 4 ; Add Y Rotate Matrix Offset To R1 (* 16)

  ldr r2,[r12],4 ; Load Z Rotate Value To R2 (R12 = Matrix3D)
  add r2,r0,r2,lsl 4 ; Add Z Rotate Matrix Offset To R2 (* 16)

  ldmia r2,{r5-r8\} ; Load ZC,-ZS,ZS,-ZC To R5,R6,R7,R8
  ldmia r1,{r2-r4\} ; Load YC,-YS,YS To R2,R3,R4

  mul r0,r2,r5 ; Load (YC * ZC) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12] ; Store R0 (YC * ZC) To Matrix3D 1st Word
  str r7,[r12,4] ; Store R0 (ZS) To Matrix3D 2nd Word
  mul r0,r4,r8 ; Load (YS * -ZC) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,8] ; Store R0 (YS * -ZC) To Matrix3D 3rd Word
  mul r0,r2,r6 ; Load (YC * -ZS) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,16] ; Store R0 (YC * -ZS) To Matrix3D 5th Word
  str r5,[r12,20] ; Store R5 (ZC) To Matrix3D 6th Word
  mul r0,r4,r7 ; Load (YS * ZS) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,24] ; Store R0 (YS * ZS) To Matrix3D 7th Word
  str r4,[r12,32] ; Store R4 (YS) To Matrix3D  9th Word
  str r2,[r12,40] ; Store R2 (YC) To Matrix3D 11th Word
}

macro XYZRotCalc xrot, yrot, zrot, precalc { ; Return XYZ Rotation
  imm32 r3,precalc ; Load Matrix Sin & Cos Pre-Calculated Table
  imm32 r12,XRot ; Load X Rotation Start Address
  ldr r0,[r12],4 ; Load X Rotate Value To R0 (R12 = Y Rotation)
  add r1,r3,r0,lsl 4 ; Add X Rotate Matrix Offset To R1 (* 16)

  ldr r0,[r12],4 ; Load Y Rotate Value To R0 (R12 = Z Rotation)
  add r2,r3,r0,lsl 4 ; Add Y Rotate Matrix Offset To R2 (* 16)

  ldr r0,[r12],4 ; Load Z Rotate Value To R0 (R12 = Matrix3D)
  add r3,r0,lsl 4 ; Add Z Rotate Matrix Offset To R3 (* 16)

  ldmia r3,{r9-r11\} ; Load ZC,-ZS,ZS To R9,R10,R11
  ldmia r2,{r6-r8\}  ; Load YC,-YS,YS To R6,R7,R8
  ldmia r1,{r2-r5\}  ; Load XC,-XS,XS,-XC To R2,R3,R4,R5

  mul r0,r2,r6 ; Load (XC * YC) To R0
  asr r0,8 ; Divide R0 By 256
  mul r0,r9     ; Load (XC * YC * ZC) To R0
  asr r0,8 ; Divide R0 By 256
  mul r1,r4,r11 ; Load (XS * ZS) To R1
  sub r0,r1,asr 8
  str r0,[r12] ; Store R0 (XC * YC * ZC) - (XS * ZS) To Matrix3D 1st Word

  mul r0,r2,r6 ; Load (XC * YC) To R0
  asr r0,8 ; Divide R0 By 256
  mul r0,r11 ; Load (XC * YC * ZS) To R0
  asr r0,8 ; Divide R0 By 256
  mul r1,r4,r9 ; Load (XS * ZC) To R1
  add r0,r1,asr 8
  str r0,[r12,4] ; Store R0 (XC * YC * ZS) + (XS * ZC) To Matrix3D 2nd Word

  mul r0,r5,r8 ; Load (-XC * YS) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,8] ; Store R0 (-XC * YS) To Matrix3D 3rd Word

  mul r0,r3,r6 ; Load (-XS * YC) To R0
  asr r0,8 ; Divide R0 By 256
  mul r0,r9     ; Load (-XS * YC * ZC) To R0
  asr r0,8 ; Divide R0 By 256
  mul r1,r2,r11 ; Load (XC * ZS) To R1
  sub r0,r1,asr 8
  str r0,[r12,16] ; Store R0 (-XS * YC * ZC) - (XC * ZS) To Matrix3D 5th Word

  mul r0,r3,r6 ; Load (-XS * YC) To R0
  asr r0,8 ; Divide R0 By 256
  mul r0,r11 ; Load (-XS * YC * ZS) To R0
  asr r0,8 ; Divide R0 By 256
  mul r1,r2,r9 ; Load (XC * ZC) To R1
  add r0,r1,asr 8
  str r0,[r12,20] ; Stores R0 (-XS * YC * ZS) + (XC * ZC) To Matrix3D 6th Word

  mul r0,r4,r8 ; Load (XS * YS) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,24] ; Store R0 (XS * YS) To Matrix3D 7th Word
  mul r0,r8,r9 ; Load (YS * ZC) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,32] ; Store R0 (YS * ZC) To Matrix3D 9th Word
  mul r0,r8,r11 ; Load (YS * ZS) To R0
  asr r0,8 ; Divide R0 By 256
  str r0,[r12,36] ; Store R0 (YS * ZS) To Matrix3D 10th Word
  str r6,[r12,40] ; Store R6 (YC) To Matrix3D 11th Word
}