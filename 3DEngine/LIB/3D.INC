macro LoadXYZ x, y, z { ; Load X,Y,Z
  ldmfd r14!,{r0-r2\} ; R0 = X, R1 = Y, R2 = Z
  Calc3D r0, r1, r2, x, y, z
}

macro Calc3D x, y, z, xcalc, ycalc, zcalc { ; Calculate X,Y,Z 3D
  imm32 r3,Matrix3D  ; Load Matrix3D Data Start Address To R3
  ldmfd r3!,{r4-r7\} ; XCalc = (Matrix3D[0] * X) + (Matrix3D[1] * Y) + (Matrix3D[2] * Z) + Matrix3D[3]
  mul xcalc,r4,x
  mla xcalc,r5,y,xcalc
  mla xcalc,r6,z,xcalc
  add xcalc,r7,lsl 8
  ldmfd r3!,{r4-r7\} ; YCalc = (Matrix3D[4] * X) + (Matrix3D[5] * Y) + (Matrix3D[6] * Z) + Matrix3D[7]
  mul ycalc,r4,x
  mla ycalc,r5,y,ycalc
  mla ycalc,r6,z,ycalc
  add ycalc,r7,lsl 8
  ldmfd r3!,{r4-r7\} ; ZCalc = (Matrix3D[8] * X) + (Matrix3D[9] * Y) + (Matrix3D[10] * Z) + Matrix3D[11]
  mul zcalc,r4,x
  mla zcalc,r5,y,zcalc
  mla zcalc,r6,z,zcalc
  adds zcalc,r7,lsl 8 ; Compare To Zero

  Calc2D xcalc, ycalc, zcalc
}

macro Calc2D x, y, z { ; Calculate X,Y 2D
  lsrgt z,8 ; IF (Z > Zero), Shift Z Coordinate Right 8 (Divide By 256)

  movgt r0,x ; Move X To R0 For Bios Division
  movgt r1,z ; Move Z To R1 For Bios Division
  swigt $060000 ; Run Bios Call To Divide (X / Z)
  movgt x,r0 ; Move R0 (Quotient) To R5 (2D Screen X)
  addgt x,HALF_SCREEN_X ; X = X / Z + (ScreenX / 2)

  movgt r0,y ; Move Y To R0 For Bios Division
  movgt r1,z ; Move Z To R1 For Bios Division
  swigt $060000 ; Run Bios Call To Divide R0 By R1 (Y / Z)
  movgt y,r0 ; Move R0 (Quotient) To R6 (2D Screen Y)
  addgt y,HALF_SCREEN_Y ; Y = Y / Z + (ScreenY / 2)
}

macro CullFace x1, y1, x2, y2, x3, y3 { ; Cull Face Calculation
  mul r4,x1,y2 ; R4 = (X1*Y2 - X2*Y1) + (X2*Y3 - X3*Y2) + (X3*Y1 - X1*Y3)
  mul r5,x2,y1
  sub r4,r5

  mul r5,x2,y3
  mul r6,x3,y2
  sub r5,r6

  mul r6,x3,y1
  mul r7,x1,y3
  sub r6,r7

  add r4,r5
  adds r4,r6 ; Compare To Zero
}

macro ScanLineBack x1, y1, x2, y2 { ; Scan Line Back Face Cull
  local .Left, .Right, .Skip
  cmp y1,y2
  bgt .Left  ; IF(Y1 > Y2) ScanLeft
  blt .Right ; IF(Y1 < Y2) ScanRight
  b .Skip ; IF(Y1 == Y2) Skip
  .Left:
  ScanLine x1, y1, x2, y2, ScanLeft
  b .Skip
  .Right:
  ScanLine x1, y1, x2, y2, ScanRight
  .Skip:
}

macro ScanLineFront x1, y1, x2, y2 { ; Scan Line Front Face Cull
  local .Left, .Right, .Skip
  cmp y1,y2
  blt .Left  ; IF(Y1 < Y2) ScanLeft
  bgt .Right ; IF(Y1 > Y2) ScanRight
  b .Skip ; IF(Y1 == Y2) Skip
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
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X1 & Y1 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X2, R9 = 2D Y2
    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X2 & Y2 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X3, R9 = 2D Y3
    imm32 r7,LineCache+16 ; Load 3rd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X3 & Y3 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X4, R9 = 2D Y4
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r10-r11\} ; Load X1,Y1 To R10,R11
    ldr r12,[r14],4 ; R12 = Colour
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache+16 ; Load 3rd LineCache Start Address To R7
    ldmia r7,{r8-r9\} ; Load X3,Y3 To R8,R9
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X2,Y2,X3,Y3 To R8,R9,R10,R11
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r8-r9\} ; Load X1,Y1 To R8,R9
    DrawLine r10, r11, r8, r9, r12

    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12
    bne .Loop
}

macro WireQuadCullBack start, end { ; Wire Quad Back Face Cull
  local .Loop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X1 & Y1 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X2, R9 = 2D Y2
    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X2 & Y2 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X3, R9 = 2D Y3
    imm32 r7,LineCache+16 ; Load 3rd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X3 & Y3 To LineCache Word

    sub r7,16 ; Load 1st LineCache Start Address To R7
    ldmia r7,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r8, r9 ; Back Face Cull
    addle r14,16 ; IF((X1*Y2 - X2*Y1) + (X2*Y3 - X3*Y2) + (X3*Y1 - X1*Y3)) <= 0 SkipPoly
    ble .SkipPoly

    LoadXYZ r8, r9, r10 ; R8 = 2D X4, R9 = 2D Y4
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r10-r11\} ; Load X1,Y1 To R10,R11
    ldr r12,[r14],4 ; R12 = Colour
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache+16 ; Load 3rd LineCache Start Address To R7
    ldmia r7,{r8-r9\} ; Load X3,Y3 To R8,R9
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X2,Y2,X3,Y3 To R8,R9,R10,R11
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r8-r9\} ; Load X1,Y1 To R8,R9
    DrawLine r10, r11, r8, r9, r12

    .SkipPoly:
    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12
    bne .Loop
}

macro WireQuadCullFront start, end { ; Wire Quad Front Face Cull
  local .Loop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X1 & Y1 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X2, R9 = 2D Y2
    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X2 & Y2 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X3, R9 = 2D Y3
    imm32 r7,LineCache+16 ; Load 3rd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X3 & Y3 To LineCache Word

    sub r7,16 ; Load 1st LineCache Start Address To R7
    ldmia r7,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r8, r9 ; Back Face Cull
    addge r14,16 ; IF((X1*Y2 - X2*Y1) + (X2*Y3 - X3*Y2) + (X3*Y1 - X1*Y3)) >= 0 SkipPoly
    bge .SkipPoly

    LoadXYZ r8, r9, r10 ; R8 = 2D X4, R9 = 2D Y4
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r10-r11\} ; Load X1,Y1 To R10,R11
    ldr r12,[r14],4 ; R12 = Colour
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache+16 ; Load 3rd LineCache Start Address To R7
    ldmia r7,{r8-r9\} ; Load X3,Y3 To R8,R9
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X2,Y2,X3,Y3 To R8,R9,R10,R11
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r8-r9\} ; Load X1,Y1 To R8,R9
    DrawLine r10, r11, r8, r9, r12

    .SkipPoly:
    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12
    bne .Loop
}

macro FillQuadCullBack start, end { ; Fill Quad Back Face Cull
  local .Loop, .Fill, .SkipPixel, .FillLoop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X1 & Y1 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X2, R9 = 2D Y2
    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X2 & Y2 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X3, R9 = 2D Y3
    imm32 r7,LineCache+16 ; Load 3rd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X3 & Y3 To LineCache Word

    sub r7,16 ; Load 1st LineCache Start Address To R7
    ldmia r7,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r8, r9 ; Back Face Cull
    addle r14,16 ; IF((X1*Y2 - X2*Y1) + (X2*Y3 - X3*Y2) + (X3*Y1 - X1*Y3)) <= 0 SkipPoly
    ble .SkipPoly

    LoadXYZ r8, r9, r10 ; R8 = 2D X4, R9 = 2D Y4
    imm32 r7,LineCache+24 ; Load 4th LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X4 & Y4 To LineCache Word

    sub r7,24 ; Load 1st LineCache Start Address To R7
    ldmia r7,{r10-r11\} ; Load X1,Y1 To R10,R11
    ScanLineBack r8, r9, r10, r11

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X1,Y1,X2,Y2 To R8,R9,R10,R11
    ScanLineBack r8, r9, r10, r11

    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X2,Y2,X3,Y3 To R8,R9,R10,R11
    ScanLineBack r8, r9, r10, r11

    imm32 r7,LineCache+16 ; Load 3rd LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X3,Y3,X4,Y4 To R8,R9,R10,R11
    ScanLineBack r8, r9, r10, r11

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldr r0,[r7,4]  ; Load 1st Line Point Y Coordinate From LineCache Word
    ldr r1,[r7,12] ; Load 2nd Line Point Y Coordinate From LineCache Word
    ldr r2,[r7,20] ; Load 3rd Line Point Y Coordinate From LineCache Word
    ldr r3,[r7,28] ; Load 4th Line Point Y Coordinate From LineCache Word
    cmp r0,r1
    movle r4,r0 ; IF(Y1 <= Y2) R4 = Y1 (Top)
    movgt r4,r1 ; IF(Y1 >  Y2) R4 = Y2 (Top)
    movgt r5,r0 ; IF(Y1 >  Y2) R5 = Y1 (Bottom)
    movle r5,r1 ; IF(Y1 <= Y2) R5 = Y2 (Bottom)

    cmp r2,r4
    movle r4,r2 ; IF(Y3 <= Top) R4 = Y3 (Top)
    cmp r2,r5
    movgt r5,r2 ; IF(Y3 > Bottom) R5 = Y3 (Bottom)

    cmp r3,r4
    movle r4,r3 ; IF(Y4 <= Top) R4 = Y4 (Top)
    cmp r3,r5
    movgt r5,r3 ; IF(Y4 > Bottom) R5 = Y4 (Bottom)

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
    ldr r12,[r14],4 ; R12 = Colour
    imm32 r10,ScanLeft ; R10 = Scanline Left Buffer Offset
    imm32 r9,ScanRight ; R9 = Scanline Right Buffer Offset
    .Fill:
      mov r3,r4,lsl 1 ; Shift To Scanline Buffer Y Position
      ldrsh r1,[r10,r3] ; R1 = Scanline Left Buffer X
      ldrsh r2,[r9,r3] ; R2 = Scanline Right Buffer X

      mla r3,r4,r11,r1 ; R3 = (Top * ScreenX) + X
      lsl r3,1 ; R3 *= BPP
      add r3,r0 ; R3 = WRAM Start Address

      cmp r2,SCREEN_X ; IF(X >= ScreenX) Skip Pixel
      sub r2,r1 ; R2 = Scanline Length
      add r2,r3,r2,lsl 1 ; R2 = WRAM End Address
      subge r2,2
      bge .SkipPixel

      cmp r1,0 ; IF(X < 0) Skip Pixel
      addlt r3,4
      blt .SkipPixel
      .FillLoop:
	strh r12,[r3],2 ; Store Pixel Colour To Screen
	.SkipPixel:
	cmp r3,r2 ; IF(X <= Scanline Right Buffer X) Fill Scanline
	ble .FillLoop

      add r4,1
      cmp r4,r5 ; IF(Top <= Bottom) Fill
      ble .Fill

    .SkipPoly:
    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12
    bne .Loop
}

macro FillQuadCullFront start, end { ; Fill Quad Front Face Cull
  local .Loop, .Fill, .SkipPixel, .FillLoop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X1 & Y1 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X2, R9 = 2D Y2
    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X2 & Y2 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X3, R9 = 2D Y3
    imm32 r7,LineCache+16 ; Load 3rd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X3 & Y3 To LineCache Word

    sub r7,16 ; Load 1st LineCache Start Address To R7
    ldmia r7,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r8, r9 ; Back Face Cull
    addge r14,16 ; IF((X1*Y2 - X2*Y1) + (X2*Y3 - X3*Y2) + (X3*Y1 - X1*Y3)) >= 0 SkipPoly
    bge .SkipPoly

    LoadXYZ r8, r9, r10 ; R8 = 2D X4, R9 = 2D Y4
    imm32 r7,LineCache+24 ; Load 4th LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X4 & Y4 To LineCache Word

    sub r7,24 ; Load 1st LineCache Start Address To R7
    ldmia r7,{r10-r11\} ; Load X1,Y1 To R10,R11
    ScanLineFront r8, r9, r10, r11

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X1,Y1,X2,Y2 To R8,R9,R10,R11
    ScanLineFront r8, r9, r10, r11

    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X2,Y2,X3,Y3 To R8,R9,R10,R11
    ScanLineFront r8, r9, r10, r11

    imm32 r7,LineCache+16 ; Load 3rd LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X3,Y3,X4,Y4 To R8,R9,R10,R11
    ScanLineFront r8, r9, r10, r11

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldr r0,[r7,4]  ; Load 1st Line Point Y Coordinate From LineCache Word
    ldr r1,[r7,12] ; Load 2nd Line Point Y Coordinate From LineCache Word
    ldr r2,[r7,20] ; Load 3rd Line Point Y Coordinate From LineCache Word
    ldr r3,[r7,28] ; Load 4th Line Point Y Coordinate From LineCache Word
    cmp r0,r1
    movle r4,r0 ; IF(Y1 <= Y2) R4 = Y1 (Top)
    movgt r4,r1 ; IF(Y1 >  Y2) R4 = Y2 (Top)
    movgt r5,r0 ; IF(Y1 >  Y2) R5 = Y1 (Bottom)
    movle r5,r1 ; IF(Y1 <= Y2) R5 = Y2 (Bottom)

    cmp r2,r4
    movle r4,r2 ; IF(Y3 <= Top) R4 = Y3 (Top)
    cmp r2,r5
    movgt r5,r2 ; IF(Y3 > Bottom) R5 = Y3 (Bottom)

    cmp r3,r4
    movle r4,r3 ; IF(Y4 <= Top) R4 = Y4 (Top)
    cmp r3,r5
    movgt r5,r3 ; IF(Y4 > Bottom) R5 = Y4 (Bottom)

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
    ldr r12,[r14],4 ; R12 = Colour
    imm32 r10,ScanLeft ; R10 = Scanline Left Buffer Offset
    imm32 r9,ScanRight ; R9 = Scanline Right Buffer Offset
    .Fill:
      mov r3,r4,lsl 1 ; Shift To Scanline Buffer Y Position
      ldrsh r1,[r10,r3] ; R1 = Scanline Left Buffer X
      ldrsh r2,[r9,r3] ; R2 = Scanline Right Buffer X

      mla r3,r4,r11,r1 ; R3 = (Top * ScreenX) + X
      lsl r3,1 ; R3 *= BPP
      add r3,r0 ; R3 = WRAM Start Address

      cmp r2,SCREEN_X ; IF(X >= ScreenX) Skip Pixel
      sub r2,r1 ; R2 = Scanline Length
      add r2,r3,r2,lsl 1 ; R2 = WRAM End Address
      subge r2,2
      bge .SkipPixel

      cmp r1,0 ; IF(X < 0) Skip Pixel
      addlt r3,4
      blt .SkipPixel
      .FillLoop:
	strh r12,[r3],2 ; Store Pixel Colour To Screen
	.SkipPixel:
	cmp r3,r2 ; IF(X <= Scanline Right Buffer X) Fill Scanline
	ble .FillLoop

      add r4,1
      cmp r4,r5 ; IF(Top <= Bottom) Fill
      ble .Fill

    .SkipPoly:
    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12
    bne .Loop
}

macro WireTri start, end { ; Wire Tri
  local .Loop
  imm32 r14,start ; R14 = Object Start Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X1 & Y1 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X2, R9 = 2D Y2
    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X2 & Y2 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X3, R9 = 2D Y3
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r10-r11\} ; Load X1,Y1 To R10,R11
    ldr r12,[r14],4 ; R12 = Colour
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    ldmia r7,{r8-r9\} ; Load X2,Y2 To R8,R9
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X1,Y1,X2,Y2 To R8,R9,R10,R11
    DrawLine r10, r11, r8, r9, r12

    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12
    bne .Loop
}

macro WireTriCullBack start, end { ; Wire Tri Back Face Cull
  local .Loop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X1 & Y1 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X2, R9 = 2D Y2
    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X2 & Y2 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X3, R9 = 2D Y3
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r8, r9 ; Back Face Cull
    addle r14,4 ; IF((X1*Y2 - X2*Y1) + (X2*Y3 - X3*Y2) + (X3*Y1 - X1*Y3)) <= 0 SkipPoly
    ble .SkipPoly

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r10-r11\} ; Load X1,Y1 To R10,R11
    ldr r12,[r14],4 ; R12 = Colour
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    ldmia r7,{r8-r9\} ; Load X2,Y2 To R8,R9
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X1,Y1,X2,Y2 To R8,R9,R10,R11
    DrawLine r10, r11, r8, r9, r12

    .SkipPoly:
    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12
    bne .Loop
}

macro WireTriCullFront start, end { ; Wire Tri Front Face Cull
  local .Loop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X1 & Y1 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X2, R9 = 2D Y2
    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X2 & Y2 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X3, R9 = 2D Y3
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r8, r9 ; Back Face Cull
    addge r14,4 ; IF((X1*Y2 - X2*Y1) + (X2*Y3 - X3*Y2) + (X3*Y1 - X1*Y3)) >= 0 SkipPoly
    bge .SkipPoly

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r10-r11\} ; Load X1,Y1 To R10,R11
    ldr r12,[r14],4 ; R12 = Colour
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    ldmia r7,{r8-r9\} ; Load X2,Y2 To R8,R9
    DrawLine r10, r11, r8, r9, r12

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X1,Y1,X2,Y2 To R8,R9,R10,R11
    DrawLine r10, r11, r8, r9, r12

    .SkipPoly:
    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12
    bne .Loop
}

macro FillTriCullBack start, end { ; Fill Tri Back Face Cull
  local .Loop, .Fill, .SkipPixel, .FillLoop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X1 & Y1 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X2, R9 = 2D Y2
    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X2 & Y2 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X3, R9 = 2D Y3
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r8, r9 ; Back Face Cull
    addle r14,4 ; IF((X1*Y2 - X2*Y1) + (X2*Y3 - X3*Y2) + (X3*Y1 - X1*Y3)) <= 0 SkipPoly
    ble .SkipPoly

    imm32 r7,LineCache+16 ; Load 3rd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X3 & Y3 To LineCache Word

    sub r7,16 ; Load 1st LineCache Start Address To R7
    ldmia r7,{r10-r11\} ; Load X1,Y1 To R10,R11
    ScanLineBack r8, r9, r10, r11

    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X2,Y2,X3,Y3 To R8,R9,R10,R11
    ScanLineBack r8, r9, r10, r11

    imm32 r7,LineCache ; Load 3rd LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X1,Y1,X2,Y2 To R8,R9,R10,R11
    ScanLineBack r8, r9, r10, r11

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldr r0,[r7,4]  ; Load 1st Line Point Y Coordinate From LineCache Word
    ldr r1,[r7,12] ; Load 2nd Line Point Y Coordinate From LineCache Word
    ldr r2,[r7,20] ; Load 3rd Line Point Y Coordinate From LineCache Word

    cmp r0,r1
    movle r4,r0 ; IF(Y1 <= Y2) R4 = Y1 (Top)
    movgt r4,r1 ; IF(Y1 >  Y2) R4 = Y2 (Top)
    movgt r5,r0 ; IF(Y1 >  Y2) R5 = Y1 (Bottom)
    movle r5,r1 ; IF(Y1 <= Y2) R5 = Y2 (Bottom)

    cmp r2,r4
    movle r4,r2 ; IF(Y3 <= Top) R4 = Y3 (Top)
    cmp r2,r5
    movgt r5,r2 ; IF(Y3 > Bottom) R5 = Y3 (Bottom)

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
    ldr r12,[r14],4 ; R12 = Colour
    imm32 r10,ScanLeft ; R10 = Scanline Left Buffer Offset
    imm32 r9,ScanRight ; R9 = Scanline Right Buffer Offset
    .Fill:
      mov r3,r4,lsl 1 ; Shift To Scanline Buffer Y Position
      ldrsh r1,[r10,r3] ; R1 = Scanline Left Buffer X
      ldrsh r2,[r9,r3] ; R2 = Scanline Right Buffer X

      mla r3,r4,r11,r1 ; R3 = (Top * ScreenX) + X
      lsl r3,1 ; R3 *= BPP
      add r3,r0 ; R3 = WRAM Start Address

      cmp r2,SCREEN_X ; IF(X >= ScreenX) Skip Pixel
      sub r2,r1 ; R2 = Scanline Length
      add r2,r3,r2,lsl 1 ; R2 = WRAM End Address
      subge r2,2
      bge .SkipPixel

      cmp r1,0 ; IF(X < 0) Skip Pixel
      addlt r3,4
      blt .SkipPixel
      .FillLoop:
	strh r12,[r3],2 ; Store Pixel Colour To Screen
	.SkipPixel:
	cmp r3,r2 ; IF(X <= Scanline Right Buffer X) Fill Scanline
	ble .FillLoop

      add r4,1
      cmp r4,r5 ; IF(Top <= Bottom) Fill
      ble .Fill

    .SkipPoly:
    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12
    bne .Loop
}

macro FillTriCullFront start, end { ; Fill Tri Front Face Cull
  local .Loop, .Fill, .SkipPixel, .FillLoop, .SkipPoly
  imm32 r14,start ; R14 = Object Start Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X1 & Y1 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X2, R9 = 2D Y2
    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X2 & Y2 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X3, R9 = 2D Y3
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r0-r3\} ; Load X1,Y1,X2,Y2 To R0,R1,R2,R3
    CullFace r0, r1, r2, r3, r8, r9 ; Back Face Cull
    addge r14,4 ; IF((X1*Y2 - X2*Y1) + (X2*Y3 - X3*Y2) + (X3*Y1 - X1*Y3)) >= 0 SkipPoly
    bge .SkipPoly

    imm32 r7,LineCache+16 ; Load 3rd LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X3 & Y3 To LineCache Word

    sub r7,16 ; Load 1st LineCache Start Address To R7
    ldmia r7,{r10-r11\} ; Load X1,Y1 To R10,R11
    ScanLineFront r8, r9, r10, r11

    imm32 r7,LineCache+8 ; Load 2nd LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X2,Y2,X3,Y3 To R8,R9,R10,R11
    ScanLineFront r8, r9, r10, r11

    imm32 r7,LineCache ; Load 3rd LineCache Start Address To R7
    ldmia r7,{r8-r11\} ; Load X1,Y1,X2,Y2 To R8,R9,R10,R11
    ScanLineFront r8, r9, r10, r11

    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldr r0,[r7,4]  ; Load 1st Line Point Y Coordinate From LineCache Word
    ldr r1,[r7,12] ; Load 2nd Line Point Y Coordinate From LineCache Word
    ldr r2,[r7,20] ; Load 3rd Line Point Y Coordinate From LineCache Word

    cmp r0,r1
    movle r4,r0 ; IF(Y1 <= Y2) R4 = Y1 (Top)
    movgt r4,r1 ; IF(Y1 >  Y2) R4 = Y2 (Top)
    movgt r5,r0 ; IF(Y1 >  Y2) R5 = Y1 (Bottom)
    movle r5,r1 ; IF(Y1 <= Y2) R5 = Y2 (Bottom)

    cmp r2,r4
    movle r4,r2 ; IF(Y3 <= Top) R4 = Y3 (Top)
    cmp r2,r5
    movgt r5,r2 ; IF(Y3 > Bottom) R5 = Y3 (Bottom)

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
    ldr r12,[r14],4 ; R12 = Colour
    imm32 r10,ScanLeft ; R10 = Scanline Left Buffer Offset
    imm32 r9,ScanRight ; R9 = Scanline Right Buffer Offset
    .Fill:
      mov r3,r4,lsl 1 ; Shift To Scanline Buffer Y Position
      ldrsh r1,[r10,r3] ; R1 = Scanline Left Buffer X
      ldrsh r2,[r9,r3] ; R2 = Scanline Right Buffer X

      mla r3,r4,r11,r1 ; R3 = (Top * ScreenX) + X
      lsl r3,1 ; R3 *= BPP
      add r3,r0 ; R3 = WRAM Start Address

      cmp r2,SCREEN_X ; IF(X >= ScreenX) Skip Pixel
      sub r2,r1 ; R2 = Scanline Length
      add r2,r3,r2,lsl 1 ; R2 = WRAM End Address
      subge r2,2
      bge .SkipPixel

      cmp r1,0 ; IF(X < 0) Skip Pixel
      addlt r3,4
      blt .SkipPixel
      .FillLoop:
	strh r12,[r3],2 ; Store Pixel Colour To Screen
	.SkipPixel:
	cmp r3,r2 ; IF(X <= Scanline Right Buffer X) Fill Scanline
	ble .FillLoop

      add r4,1
      cmp r4,r5 ; IF(Top <= Bottom) Fill
      ble .Fill

    .SkipPoly:
    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12
    bne .Loop
}

macro Point start, end { ; Point
  local .Loop
  imm32 r14,start ; R14 = Object Start Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X, R10 = 2D Y
    ldr r12,[r14],4 ; R12 = Colour
    DrawPoint r8, r9, r12

    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12
    bne .Loop
}

macro Line start, end { ; Line
  local .Loop
  imm32 r14,start ; R14 = Object Start Offset
  .Loop:
    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    stmia r7,{r8-r9\} ; Store X1 & Y1 To LineCache Word

    LoadXYZ r8, r9, r10 ; R8 = 2D X1, R9 = 2D Y1
    imm32 r7,LineCache ; Load 1st LineCache Start Address To R7
    ldmia r7,{r10-r11\} ; Load X1,Y1 To R10,R11
    ldr r12,[r14],4 ; R12 = Colour
    DrawLine r10, r11, r8, r9, r12

    imm32 r12,end ; R12 = Object End Offset
    cmp r14,r12
    bne .Loop
}

macro XRotCalc xrot, precalc { ; Return X Rotation
  imm32 r1,precalc ; Load Matrix Sin & Cos Pre-Calculated Table Start Address To R1
  imm32 r12,XRot ; Load X Rotation Start Address To R12
  ldr r0,[r12],12 ; Load X Rotate Value To R0 (R12 = Matrix3D Start Address)
  add r0,r1,r0,lsl 4 ; Add X Rotate Matrix Offset To R0 (* 16)
  ldmfd r0!,{r1-r3\} ; Load XC,-XS,XS To R1,R2,R3

  str r1,[r12,20] ; Store R1  (XC) To Matrix3D	6th Word
  str r2,[r12,24] ; Store R2 (-XS) To Matrix3D	7th Word
  str r3,[r12,36] ; Store R3  (XS) To Matrix3D 10th Word
  str r1,[r12,40] ; Store R1  (XC) To Matrix3D 11th Word
}

macro YRotCalc yrot, precalc { ; Return Y Rotation
  imm32 r1,precalc ; Load Matrix Sin & Cos Pre-Calculated Table Start Address To R1
  imm32 r12,YRot ; Load Y Rotation Start Address To R12
  ldr r0,[r12],8 ; Load Y Rotate Value To R0 (R12 = Matrix3D Start Address)
  add r0,r1,r0,lsl 4 ; Add Y Rotate Matrix Offset To R0 (* 16)
  ldmfd r0!,{r1-r3\} ; Load YC,-YS,YS To R1,R2,R3

  str r1,[r12]	  ; Store R1  (YC) To Matrix3D	1st Word
  str r3,[r12,8]  ; Store R3  (YS) To Matrix3D	3rd Word
  str r2,[r12,32] ; Store R2 (-YS) To Matrix3D	9th Word
  str r1,[r12,40] ; Store R1  (YC) To Matrix3D 11th Word
}

macro ZRotCalc zrot, precalc { ; Return Z Rotation
  imm32 r1,precalc ; Load Matrix Sin & Cos Pre-Calculated Table Start Address To R1
  imm32 r12,ZRot ; Load Z Rotation Start Address To R12
  ldr r0,[r12],4 ; Load Z Rotate Value To R0 (R12 = Matrix3D Start Address)
  add r0,r1,r0,lsl 4 ; Add Z Rotate Matrix Offset To R0 (* 16)
  ldmfd r0!,{r1-r3\} ; Load ZC,-ZS,ZS To R1,R2,R3

  str r1,[r12]	  ; Store R1  (ZC) To Matrix3D 1st Word
  str r2,[r12,4]  ; Store R2 (-ZS) To Matrix3D 2nd Word
  str r3,[r12,16] ; Store R3  (ZS) To Matrix3D 5th Word
  str r1,[r12,20] ; Store R1  (ZC) To Matrix3D 6th Word
}

macro XYRotCalc xrot, yrot, precalc { ; Return XY Rotation
  imm32 r0,precalc ; Load Matrix Sin & Cos Pre-Calculated Table Start Address To R0
  imm32 r12,XRot ; Load X Rotation Start Address To R12
  ldr r2,[r12],4 ; Load X Rotate Value To R2 (R12 = Y Rotation Start Address)
  add r1,r0,r2,lsl 4 ; Add X Rotate Matrix Offset To R1 (* 16)

  ldr r2,[r12],8 ; Load Y Rotate Value To R2 (R12 = Matrix3D Start Address)
  add r2,r0,r2,lsl 4 ; Add Y Rotate Matrix Offset To R2 (* 16)

  ldmfd r2!,{r6-r8\} ; Load YC,-YS,YS To R6,R7,R8
  ldmfd r1!,{r2-r5\} ; Load XC,-XS,XS,-XC To R2,R3,R4,R5
  
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
  imm32 r0,precalc ; Load Matrix Sin & Cos Pre-Calculated Table Start Address To R0
  imm32 r12,XRot ; Load X Rotation Start Address To R12
  ldr r2,[r12],8 ; Load X Rotate Value To R2 (R12 = Z Rotation Start Address)
  add r1,r0,r2,lsl 4 ; Add X Rotate Matrix Offset To R1 (* 16)

  ldr r2,[r12],4 ; Load Z Rotate Value To R2 (R12 = Matrix3D Start Address)
  add r2,r0,r2,lsl 4 ; Add Z Rotate Matrix Offset To R2 (* 16)

  ldmfd r2!,{r5-r8\} ; Load ZC,-ZS,ZS,-ZC To R5,R6,R7,R8
  ldmfd r1!,{r2-r4\} ; Load XC,-XS,XS To R2,R3,R4

  str r5,[r12]	 ; Store R5 (ZC) To Matrix3D 1st Word
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
  imm32 r0,precalc ; Load Matrix Sin & Cos Pre-Calculated Table Start Address To R0
  imm32 r12,YRot ; Load Y Rotation Start Address To R12
  ldr r2,[r12],4 ; Load Y Rotate Value To R2 (R12 = Z Rotation Start Address)
  add r1,r0,r2,lsl 4 ; Add Y Rotate Matrix Offset To R1 (* 16)

  ldr r2,[r12],4 ; Load Z Rotate Value To R2 (R12 = Matrix3D Start Address)
  add r2,r0,r2,lsl 4 ; Add Z Rotate Matrix Offset To R2 (* 16)

  ldmfd r2!,{r5-r8\} ; Load ZC,-ZS,ZS,-ZC To R5,R6,R7,R8
  ldmfd r1!,{r2-r4\} ; Load YC,-YS,YS To R2,R3,R4

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
  imm32 r3,precalc ; Load Matrix Sin & Cos Pre-Calculated Table Start Address To R3
  imm32 r12,XRot ; Load X Rotation Start Address To R12
  ldr r0,[r12],4 ; Load X Rotate Value To R0 (R12 = Y Rotation Start Address)
  add r1,r3,r0,lsl 4 ; Add X Rotate Matrix Offset To R1 (* 16)

  ldr r0,[r12],4 ; Load Y Rotate Value To R0 (R12 = Z Rotation Start Address)
  add r2,r3,r0,lsl 4 ; Add Y Rotate Matrix Offset To R2 (* 16)

  ldr r0,[r12],4 ; Load Z Rotate Value To R0 (R12 = Matrix3D Start Address)
  add r3,r0,lsl 4 ; Add Z Rotate Matrix Offset To R3 (* 16)

  ldmfd r3!,{r9-r11\} ; Load ZC,-ZS,ZS To R9,R10,R11
  ldmfd r2!,{r6-r8\}  ; Load YC,-YS,YS To R6,R7,R8
  ldmfd r1!,{r2-r5\}  ; Load XC,-XS,XS,-XC To R2,R3,R4,R5

  mul r0,r2,r6 ; Load (XC * YC) To R0
  asr r0,8 ; Divide R0 By 256
  mul r0,r9	; Load (XC * YC * ZC) To R0
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
  mul r0,r9	; Load (-XS * YC * ZC) To R0
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