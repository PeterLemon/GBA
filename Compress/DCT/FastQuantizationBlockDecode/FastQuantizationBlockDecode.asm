; GBA 'Bare Metal' Fast Quantization Block Decode Demo by krom (Peter Lemon):
; 1. Decode DCT Quantization Block To WRAM
; 2. Decode DCT Block To WRAM

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\MEM.INC'
org $8000000
b Start
times $80000C0-($-0) db 0

Start:
  imm32 r10,Q ; R10 = Q
  imm32 r11,DCTQ ; R11 = DCTQ
  mov r12,WRAM ; R12 = DCT/IDCT

  mov r0,64 ; R0 = 64

  ; DCT Block Decode (Inverse Quantization)
  QLoop:
    ldrb r1,[r10],1 ; R1 = Q, Q++
    ldrsb r2,[r11],1 ; R2 = DCTQ, DCTQ++
    mul r1,r2 ; R1 = DCTQ * Q
    strh r1,[r12],2 ; DCT = R1, DCT += 2
    subs r0,1 ; R0--
    bne QLoop ; IF (R0 != 0) Q Loop

  mov r13,WRAM ; R13 = DCT/IDCT
  imm32 r14,FIX_LUT ; R14 = FIX_LUT

  ; Fast IDCT Block Decode
  ; Pass 1: Process Columns From Input, Store Into Work Array.
  CTR = 0
  while CTR < 8 ; Static Loop Columns

  ; Even part: Reverse The Even Part Of The Forward DCT. The Rotator Is SQRT(2)*C(-6).
  ldrsh r0,[r13,(CTR+8*2)*2] ; R0 = Z2 = DCT[CTR + 8*2]
  ldrsh r1,[r13,(CTR+8*6)*2] ; R1 = Z3 = DCT[CTR + 8*6]

  add r2,r0,r1 ; Z1 = (Z2 + Z3) * FIX_0_541196100
  ldrsh r3,[r14,FIX_0_541196100-FIX_LUT] ; R3 = FIX_0_541196100
  mul r2,r3 ; R2 = Z1
  ldrsh r3,[r14,FIX_1_847759065-FIX_LUT] ; TMP2 = Z1 + (Z3 * -FIX_1_847759065)
  mla r1,r1,r3,r2 ; R1 = TMP2
  ldrsh r3,[r14,FIX_0_765366865-FIX_LUT] ; TMP3 = Z1 + (Z2 * FIX_0_765366865)
  mla r0,r0,r3,r2 ; R0 = TMP3

  ldrsh r4,[r13,(CTR+8*0)*2] ; R4 = Z2 = DCT[CTR + 8*0]
  ldrsh r5,[r13,(CTR+8*4)*2] ; R5 = Z3 = DCT[CTR + 8*4]

  add r2,r4,r5 ; TMP0 = (Z2 + Z3) << 13
  lsl r2,13 ; R2 = TMP0
  sub r3,r4,r5 ; TMP1 = (Z2 - Z3) << 13
  lsl r3,13 ; R3 = TMP1

  add r4,r2,r0 ; R4 = TMP10 = TMP0 + TMP3
  add r5,r3,r1 ; R5 = TMP11 = TMP1 + TMP2
  sub r6,r3,r1 ; R6 = TMP12 = TMP1 - TMP2
  sub r7,r2,r0 ; R7 = TMP13 = TMP0 - TMP3

  ; Odd Part Per Figure 8; The Matrix Is Unitary And Hence Its Transpose Is Its Inverse.
  ldrsh r0,[r13,(CTR+8*7)*2] ; R0 = TMP0 = DCT[CTR + 8*7]
  ldrsh r1,[r13,(CTR+8*5)*2] ; R1 = TMP1 = DCT[CTR + 8*5]
  ldrsh r2,[r13,(CTR+8*3)*2] ; R2 = TMP2 = DCT[CTR + 8*3]
  ldrsh r3,[r13,(CTR+8*1)*2] ; R3 = TMP3 = DCT[CTR + 8*1]

  add r10,r0,r2 ; R10 = Z3 = TMP0 + TMP2
  add r11,r1,r3 ; R11 = Z4 = TMP1 + TMP3
  add r12,r10,r11 ; Z5 = (Z3 + Z4) * FIX_1_175875602 # SQRT(2) * C3
  ldrsh r8,[r14,FIX_1_175875602-FIX_LUT] ; R8 = FIX_1_175875602
  mul r12,r8 ; R12 = Z5

  ldrsh r8,[r14,FIX_1_961570560-FIX_LUT] ; Z3 *= -FIX_1_961570560 # SQRT(2) * (-C3-C5)
  mul r10,r8 ; R10 = Z3
  ldrsh r8,[r14,FIX_0_390180644-FIX_LUT] ; Z4 *= -FIX_0_390180644 # SQRT(2) * ( C5-C3)
  mul r11,r8 ; R11 = Z4
  add r10,r12 ; R10 = Z3 += Z5
  add r11,r12 ; R11 = Z4 += Z5

  add r8,r0,r3 ; R8 = Z1 = TMP0 + TMP3
  add r9,r1,r2 ; R9 = Z2 = TMP1 + TMP2
  ldrsh r12,[r14,FIX_0_899976223-FIX_LUT] ; Z1 *= -FIX_0_899976223 # SQRT(2) * ( C7-C3)
  mul r8,r12 ; R8 = Z1
  ldrsh r12,[r14,FIX_2_562915447-FIX_LUT] ; Z2 *= -FIX_2_562915447 # SQRT(2) * (-C1-C3)
  mul r9,r12 ; R9 = Z2

  ldrsh r12,[r14,FIX_0_298631336-FIX_LUT] ; TMP0 *= FIX_0_298631336 # SQRT(2) * (-C1+C3+C5-C7)
  mul r0,r12 ; R0 = TMP0
  ldrsh r12,[r14,FIX_2_053119869-FIX_LUT] ; TMP1 *= FIX_2_053119869 # SQRT(2) * ( C1+C3-C5+C7)
  mul r1,r12 ; R1 = TMP1
  ldrsh r12,[r14,FIX_3_072711026-FIX_LUT] ; TMP2 *= FIX_3_072711026 # SQRT(2) * ( C1+C3+C5-C7)
  mul r2,r12 ; R2 = TMP2
  ldrsh r12,[r14,FIX_1_501321110-FIX_LUT] ; TMP3 *= FIX_1_501321110 # SQRT(2) * ( C1+C3-C5-C7)
  mul r3,r12 ; R3 = TMP3

  add r0,r8 ; TMP0 += Z1 + Z3
  add r0,r10 ; R0 = TMP0
  add r1,r9 ; TMP1 += Z2 + Z4
  add r1,r11 ; R1 = TMP1
  add r2,r9 ; TMP2 += Z2 + Z3
  add r2,r10 ; R2 = TMP2
  add r3,r8 ; TMP3 += Z1 + Z4
  add r3,r11 ; R3 = TMP3

  ; Final Output Stage: Inputs Are TMP10..TMP13, TMP0..TMP3
  add r8,r4,r3 ; DCT[CTR + 8*0] = (TMP10 + TMP3) >> 11
  asr r8,11
  strh r8,[r13,(CTR+8*0)*2]
  sub r8,r4,r3 ; DCT[CTR + 8*7] = (TMP10 - TMP3) >> 11
  asr r8,11
  strh r8,[r13,(CTR+8*7)*2]
  add r8,r5,r2 ; DCT[CTR + 8*1] = (TMP11 + TMP2) >> 11
  asr r8,11
  strh r8,[r13,(CTR+8*1)*2]
  sub r8,r5,r2 ; DCT[CTR + 8*6] = (TMP11 - TMP2) >> 11
  asr r8,11
  strh r8,[r13,(CTR+8*6)*2]
  add r8,r6,r1 ; DCT[CTR + 8*2] = (TMP12 + TMP1) >> 11
  asr r8,11
  strh r8,[r13,(CTR+8*2)*2]
  sub r8,r6,r1 ; DCT[CTR + 8*5] = (TMP12 - TMP1) >> 11
  asr r8,11
  strh r8,[r13,(CTR+8*5)*2]
  add r8,r7,r0 ; DCT[CTR + 8*3] = (TMP13 + TMP0) >> 11
  asr r8,11
  strh r8,[r13,(CTR+8*3)*2]
  sub r8,r7,r0 ; DCT[CTR + 8*4] = (TMP13 - TMP0) >> 11
  asr r8,11
  strh r8,[r13,(CTR+8*4)*2]

  CTR = CTR + 1
  end while ; End Of Static Loop Columns

  ; Pass 2: Process Rows From Work Array, Store Into Output Array.
  CTR = 0
  while CTR < 8 ; Static Loop Rows

  ; Even Part: Reverse The Even Part Of The Forward DCT. The Rotator Is SQRT(2)*C(-6).
  ldrsh r0,[r13,(CTR*8+2)*2] ; R0 = Z2 = DCT[CTR*8 + 2]
  ldrsh r1,[r13,(CTR*8+6)*2] ; R1 = Z3 = DCT[CTR*8 + 6]

  add r2,r0,r1 ; Z1 = (Z2 + Z3) * FIX_0_541196100
  ldrsh r3,[r14,FIX_0_541196100-FIX_LUT] ; R3 = FIX_0_541196100
  mul r2,r3 ; R2 = Z1
  ldrsh r3,[r14,FIX_1_847759065-FIX_LUT] ; TMP2 = Z1 + (Z3 * -FIX_1_847759065)
  mla r1,r1,r3,r2 ; R1 = TMP2
  ldrsh r3,[r14,FIX_0_765366865-FIX_LUT] ; TMP3 = Z1 + (Z2 * FIX_0_765366865)
  mla r0,r0,r3,r2 ; R0 = TMP3

  ldrsh r4,[r13,(CTR*8+0)*2] ; R4 = Z2 = DCT[CTR*8 + 0]
  ldrsh r5,[r13,(CTR*8+4)*2] ; R5 = Z3 = DCT[CTR*8 + 4]

  add r2,r4,r5 ; TMP0 = (Z2 + Z3) << 13
  lsl r2,13 ; R2 = TMP0
  sub r3,r4,r5 ; TMP1 = (Z2 - Z3) << 13
  lsl r3,13 ; R3 = TMP1

  add r4,r2,r0 ; R4 = TMP10 = TMP0 + TMP3
  add r5,r3,r1 ; R5 = TMP11 = TMP1 + TMP2
  sub r6,r3,r1 ; R6 = TMP12 = TMP1 - TMP2
  sub r7,r2,r0 ; R7 = TMP13 = TMP0 - TMP3

  ; Odd Part Per Figure 8; The Matrix Is Unitary And Hence Its Transpose Is Its Inverse.
  ldrsh r0,[r13,(CTR*8+7)*2] ; R0 = TMP0 = DCT[CTR*8 + 7]
  ldrsh r1,[r13,(CTR*8+5)*2] ; R1 = TMP1 = DCT[CTR*8 + 5]
  ldrsh r2,[r13,(CTR*8+3)*2] ; R2 = TMP2 = DCT[CTR*8 + 3]
  ldrsh r3,[r13,(CTR*8+1)*2] ; R3 = TMP3 = DCT[CTR*8 + 1]

  add r10,r0,r2 ; R10 = Z3 = TMP0 + TMP2
  add r11,r1,r3 ; R11 = Z4 = TMP1 + TMP3
  add r12,r10,r11 ; Z5 = (Z3 + Z4) * FIX_1_175875602 # SQRT(2) * C3
  ldrsh r8,[r14,FIX_1_175875602-FIX_LUT] ; R8 = FIX_1_175875602
  mul r12,r8 ; R12 = Z5

  ldrsh r8,[r14,FIX_1_961570560-FIX_LUT] ; Z3 *= -FIX_1_961570560 # SQRT(2) * (-C3-C5)
  mul r10,r8 ; R10 = Z3
  ldrsh r8,[r14,FIX_0_390180644-FIX_LUT] ; Z4 *= -FIX_0_390180644 # SQRT(2) * ( C5-C3)
  mul r11,r8 ; R11 = Z4
  add r10,r12 ; R10 = Z3 += Z5
  add r11,r12 ; R11 = Z4 += Z5

  add r8,r0,r3 ; R8 = Z1 = TMP0 + TMP3
  add r9,r1,r2 ; R9 = Z2 = TMP1 + TMP2
  ldrsh r12,[r14,FIX_0_899976223-FIX_LUT] ; Z1 *= -FIX_0_899976223 # SQRT(2) * ( C7-C3)
  mul r8,r12 ; R8 = Z1
  ldrsh r12,[r14,FIX_2_562915447-FIX_LUT] ; Z2 *= -FIX_2_562915447 # SQRT(2) * (-C1-C3)
  mul r9,r12 ; R9 = Z2

  ldrsh r12,[r14,FIX_0_298631336-FIX_LUT] ; TMP0 *= FIX_0_298631336 # SQRT(2) * (-C1+C3+C5-C7)
  mul r0,r12 ; R0 = TMP0
  ldrsh r12,[r14,FIX_2_053119869-FIX_LUT] ; TMP1 *= FIX_2_053119869 # SQRT(2) * ( C1+C3-C5+C7)
  mul r1,r12 ; R1 = TMP1
  ldrsh r12,[r14,FIX_3_072711026-FIX_LUT] ; TMP2 *= FIX_3_072711026 # SQRT(2) * ( C1+C3+C5-C7)
  mul r2,r12 ; R2 = TMP2
  ldrsh r12,[r14,FIX_1_501321110-FIX_LUT] ; TMP3 *= FIX_1_501321110 # SQRT(2) * ( C1+C3-C5-C7)
  mul r3,r12 ; R3 = TMP3

  add r0,r8 ; TMP0 += Z1 + Z3
  add r0,r10 ; R0 = TMP0
  add r1,r9 ; TMP1 += Z2 + Z4
  add r1,r11 ; R1 = TMP1
  add r2,r9 ; TMP2 += Z2 + Z3
  add r2,r10 ; R2 = TMP2
  add r3,r8 ; TMP3 += Z1 + Z4
  add r3,r11 ; R3 = TMP3

  ; Final Output Stage: Inputs Are TMP10..TMP13, TMP0..TMP3
  add r8,r4,r3 ; DCT[CTR*8 + 0] = (TMP10 + TMP3) >> 18
  asr r8,18
  strh r8,[r13,(CTR*8+0)*2]
  sub r8,r4,r3 ; DCT[CTR*8 + 7] = (TMP10 - TMP3) >> 18
  asr r8,18
  strh r8,[r13,(CTR*8+7)*2]
  add r8,r5,r2 ; DCT[CTR*8 + 1] = (TMP11 + TMP2) >> 18
  asr r8,18
  strh r8,[r13,(CTR*8+1)*2]
  sub r8,r5,r2 ; DCT[CTR*8 + 6] = (TMP11 - TMP2) >> 18
  asr r8,18
  strh r8,[r13,(CTR*8+6)*2]
  add r8,r6,r1 ; DCT[CTR*8 + 2] = (TMP12 + TMP1) >> 18
  asr r8,18
  strh r8,[r13,(CTR*8+2)*2]
  sub r8,r6,r1 ; DCT[CTR*8 + 5] = (TMP12 - TMP1) >> 18
  asr r8,18
  strh r8,[r13,(CTR*8+5)*2]
  add r8,r7,r0 ; DCT[CTR*8 + 3] = (TMP13 + TMP0) >> 18
  asr r8,18
  strh r8,[r13,(CTR*8+3)*2]
  sub r8,r7,r0 ; DCT[CTR*8 + 4] = (TMP13 - TMP0) >> 18
  asr r8,18
  strh r8,[r13,(CTR*8+4)*2]

  CTR = CTR + 1
  end while ; End Of Static Loop Rows

Loop:
  b Loop

FIX_LUT:
FIX_0_298631336:
  dh 2446 ; FIX(0.298631336)
FIX_0_390180644:
  dh -3196 ; FIX(-0.390180644)
FIX_0_541196100:
  dh 4433 ; FIX(0.541196100)
FIX_0_765366865:
  dh 6270 ; FIX(0.765366865)
FIX_0_899976223:
  dh -7373 ; FIX(-0.899976223)
FIX_1_175875602:
  dh 9633 ; FIX(1.175875602)
FIX_1_501321110:
  dh 12299 ; FIX(1.501321110)
FIX_1_847759065:
  dh -15137 ; FIX(-1.847759065)
FIX_1_961570560:
  dh -16069 ; FIX(-1.961570560)
FIX_2_053119869:
  dh 16819 ; FIX(2.053119869)
FIX_2_562915447:
  dh -20995 ; FIX(-2.562915447)
FIX_3_072711026:
  dh 25172 ; FIX(3.072711026)

Q: ; JPEG Standard Quantization 8x8 Result Matrix (Quality = 50)
  db 16,11,10,16,24,40,51,61
  db 12,12,14,19,26,58,60,55
  db 14,13,16,24,40,57,69,56
  db 14,17,22,29,51,87,80,62
  db 18,22,37,56,68,109,103,77
  db 24,35,55,64,81,104,113,92
  db 49,64,78,87,103,121,120,101
  db 72,92,95,98,112,100,103,99

DCTQ: ; DCT Quantization 8x8 Result Matrix (Quality = 50)
  db 38,0,-26,0,-8,0,-2,0
  db -9,0,-14,0,10,0,3,0
  db -13,0,6,0,5,0,-3,0
  db 16,0,-8,0,2,0,-2,0
  db 0,0,0,0,0,0,0,0
  db -6,0,2,0,-1,0,1,0
  db 2,0,-1,0,-1,0,1,0
  db 0,0,0,0,0,0,0,0