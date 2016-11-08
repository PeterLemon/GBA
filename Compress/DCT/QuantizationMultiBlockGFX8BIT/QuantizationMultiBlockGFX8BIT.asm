; GBA 'Bare Metal' Quantization Multi Block GFX 8-Bit Demo by krom (Peter Lemon):
; 1. Decode DCT Quantization Block To WRAM
; 2. Decode DCT Block To WRAM
; 3. Copy DCT Block To VRAM

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
org $8000000
b Start
times $80000C0-($-0) db 0

Start:
  mov r0,IO
  mov r1,MODE_3
  orr r1,BG2_ENABLE
  str r1,[r0]

  imm32 r7,DCTQBLOCKS ; R7 = DCTQ Blocks
  mov r8,VRAM ; R8 = VRAM
  mov r13,30 ; R13 = Block Row Count
  mov r14,20 ; R14 = Block Column Count

  LoopBlocks:

  imm32 r10,Q ; R10 = Q
  mov r12,WRAM ; R12 = DCT
  add r12,128

  mov r0,64 ; R0 = 64

  ; DCT Block Decode (Inverse Quantization)
  QLoop:
    ldrb r1,[r10],1 ; R1 = Q, Q++
    ldrsb r2,[r7],1 ; R2 = DCTQ, DCTQ++
    mul r1,r2 ; R1 = DCTQ * Q
    strh r1,[r12],2 ; DCT = R1, DCT += 2
    subs r0,1 ; R0--
    bne QLoop ; IF (R0 != 0) Q Loop


  mov r9,WRAM ; R9 = IDCT
  imm32 r11,CLUT ; R11 = CLUT
  imm32 r12,COSLUT ; R12 = COSLUT

  ; IDCT Block Decode
  mov r0,0 ; R0 = Y
  IDCTY: ; While (Y < 8)
    mov r1,0 ; R1 = X
    IDCTX: ; While (X < 8)
      mov r2,0 ; R2 = V
      mov r6,0 ; R6 = IDCT
      mov r10,WRAM ; R10 = DCT
      add r10,128
      IDCTV: ; While (V < 8)
	mov r3,0 ; R3 = U
	IDCTU: ; While (U < 8)
	  ; IDCT[Y*8 + X] += DCT[V*8 + U]
	  ldrsh r4,[r10],2 ; R4 = DCT[V*8 + U]
	  ; * C[U]
	  lsl r5,r3,1 ; R5 = U Offset
	  ldrh r5,[r11,r5] ; R5 = C[U]
	  mul r4,r5 ; R4 *= C[U]
	  asr r4,16 ; Shift S.16
	  ; * C[V]
	  lsl r5,r2,1 ; R5 = V Offset
	  ldrh r5,[r11,r5] ; R5 = C[V]
	  mul r4,r5 ; R4 *= C[V]
	  asr r4,16 ; Shift S.16
	  ; * COS[U*8 + X]
	  add r5,r1,r3,lsl 3 ; R5 = U*8 + X
	  lsl r5,2 ; R5 = U*8 + X Offset
	  ldr r5,[r12,r5] ; R5 = COS[U*8 + X]
	  mul r4,r5 ; R4 *= COS[U*8 + X]
	  asr r4,16 ; Shift S.16
	  ; * COS[V*8 + Y]
	  add r5,r0,r2,lsl 3 ; R5 = V*8 + Y
	  lsl r5,2 ; R5 = V*8 + Y Offset
	  ldr r5,[r12,r5] ; R5 = COS[V*8 + Y]
	  mul r4,r5 ; R4 *= COS[V*8 + Y]
	  asr r4,16 ; Shift S.16

	  add r6,r4 ; IDCT += R4

	  add r3,1 ; U++
	  cmp r3,8 ; Compare U To 8
	  blt IDCTU ; IF (U < 8) IDCTU

	add r2,1 ; V++
	cmp r2,8 ; Compare V To 8
	blt IDCTV ; IF (V < 8) IDCTV

      strh r6,[r9],2 ; IDCT[Y*8 + X] = IDCT

      add r1,1 ; X++
      cmp r1,8 ; Compare X To 8
      blt IDCTX ; IF (X < 8) IDCTX

    add r0,1 ; Y++
    cmp r0,8 ; Compare Y To 8
    blt IDCTY ; IF (Y < 8) IDCTY

  ; Copy IDCT Block To VRAM
  mov r0,WRAM
  mov r2,8 ; R2 = Y
  LoopY: ; While Y
    mov r3,8 ; R3 = X
    LoopX: ; While X
      ldrsh r4,[r0],2 ; R4 = IDCT Block Pixel
      cmp r4,0 ; Compare Pixel To 0
      movlt r4,0 ; IF (Pixel < 0) Pixel = 0
      cmp r4,255 ; Compare Pixel To 255
      movgt r4,255 ; IF (Pixel > 255) Pixel = 255
      lsr r4,3 ; R4 = 5-Bit Pixel
      orr r4,r4,lsl 5
      orr r4,r4,lsl 5 ; R4 = 15-BIT RGB Pixel
      strh r4,[r8],2 ; Store Pixel To VRAM

      subs r3,1 ; X--
      bne LoopX ; IF (X != 0) Loop X
      add r8,464 ; Jump 1 Scanline Down, 8 Pixels Back

    subs r2,1 ; Y--
    bne LoopY ; IF (Y != 0) Loop Y

  sub r8,(240*8*2)-8*2 ; Jump 8 Scanlines Up, 8 Pixels Forwards
  subs r13,1 ; Block Row Count--
  bne LoopBlocks ; IF (Block Row Count != 0) LoopBlocks

  add r8,(240*7*2) ; Jump 7 Scanlines Down
  mov r13,30 ; Block Row Count = 30

  subs r14,1 ; Block Column Count--
  bne LoopBlocks ; IF (Block Column Count != 0) LoopBlocks

Loop:
  b Loop

CLUT: ; C Look Up Table (/2 Applied) (.16)
  dh 23170,32768,32768,32768,32768,32768,32768,32768

COSLUT: ; COS Look Up Table (S.16)
  dw 65536,65536,65536,65536,65536,65536,65536,65536
  dw 64277,54491,36410,12785,-12785,-36410,-54491,-64277
  dw 60547,25080,-25080,-60547,-60547,-25080,25080,60547
  dw 54491,-12785,-64277,-36410,36410,64277,12785,-54491
  dw 46341,-46341,-46341,46341,46341,-46341,-46341,46341
  dw 36410,-64277,12785,54491,-54491,-12785,64277,-36410
  dw 25080,-60547,60547,-25080,-25080,60547,-60547,25080
  dw 12785,-36410,54491,-64277,64277,-54491,36410,-12785

;Q: ; JPEG Standard Quantization 8x8 Result Matrix (Quality = 10)
;  db 80,55,50,80,120,200,255,255
;  db 60,60,70,95,130,255,255,255
;  db 70,65,80,120,200,255,255,255
;  db 70,85,110,145,255,255,255,255
;  db 90,110,185,255,255,255,255,255
;  db 120,175,255,255,255,255,255,255
;  db 245,255,255,255,255,255,255,255
;  db 255,255,255,255,255,255,255,255

Q: ; JPEG Standard Quantization 8x8 Result Matrix (Quality = 50)
  db 16,11,10,16,24,40,51,61
  db 12,12,14,19,26,58,60,55
  db 14,13,16,24,40,57,69,56
  db 14,17,22,29,51,87,80,62
  db 18,22,37,56,68,109,103,77
  db 24,35,55,64,81,104,113,92
  db 49,64,78,87,103,121,120,101
  db 72,92,95,98,112,100,103,99

;Q: ; JPEG Standard Quantization 8x8 Result Matrix (Quality = 90)
;  db 3,2,2,3,5,8,10,12
;  db 2,2,3,4,5,12,12,11
;  db 3,3,3,5,8,11,14,11
;  db 3,3,4,6,10,17,16,12
;  db 4,4,7,11,14,22,21,15
;  db 5,7,11,13,16,21,23,18
;  db 10,13,16,17,21,24,24,20
;  db 14,18,19,20,22,20,21,20

DCTQBLOCKS: ; DCT Quantization 8x8 Matrix Blocks (Signed 8-Bit)
  ;file 'frame10.dct' ; Frame Quality = 10
  file 'frame50.dct' ; Frame Quality = 50
  ;file 'frame90.dct' ; Frame Quality = 90