; GBA 'Bare Metal' DCT Block GFX Demo by krom (Peter Lemon):
; 1. Decode DCT Block To WRAM
; 2. Copy DCT Block To VRAM

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
org $8000000
b Start
times $80000C0-($-0) db 0

Start:
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
      imm32 r10,DCT ; R10 = DCT
      IDCTV: ; While (V < 8)
	mov r3,0 ; R3 = U
	IDCTU: ; While (U < 8)
	  ; IDCT[Y*8 + X] += DCT[V*8 + U]
	  ldrh r4,[r10],2 ; R4 = DCT[V*8 + U]
	  ; * C[U]
	  lsl r5,r3,1 ; R5 = U Offset
	  ldrh r5,[r11,r5] ; R5 = C[U]
	  mul r4,r5 ; R4 *= C[U]
	  lsr r4,16 ; Shift .16
	  ; * C[V]
	  lsl r5,r2,1 ; R5 = V Offset
	  ldrh r5,[r11,r5] ; R5 = C[V]
	  mul r4,r5 ; R4 *= C[V]
	  lsr r4,16 ; Shift .16
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

  mov r0,IO
  mov r1,MODE_3
  orr r1,BG2_ENABLE
  str r1,[r0]

  ; Copy IDCT Block To VRAM
  mov r0,WRAM
  mov r1,VRAM
  mov r2,8 ; R2 = Y
  LoopY: ; While Y
    mov r3,8 ; R3 = X
    LoopX: ; While X
      ldrsh r4,[r0],2 ; R2 = IDCT Block Pixel
      cmp r4,0 ; Compare Pixel To 0
      movlt r4,0 ; IF (Pixel < 0) Pixel = 0
      cmp r4,255 ; Compare Pixel To 255
      movgt r4,255 ; IF (Pixel > 255) Pixel = 255
      lsr r4,3 ; R2 = 5-Bit Pixel
      orr r4,r4,lsl 5
      orr r4,r4,lsl 5 ; R2 = 15-BIT RGB Pixel
      strh r4,[r1],2 ; Store Pixel To VRAM

      subs r3,1 ; X--
      bne LoopX ; IF (X != 0) Loop X
      add r1,464 ; Jump 1 Scanline Down, 8 Pixels Back

    subs r2,1 ; Y--
    bne LoopY ; IF (Y != 0) Loop Y

Loop:
  b Loop

DCT: ; Discrete Cosine Transform (DCT) 8x8 Result Matrix
  ;dh 700,0,0,0,0,0,0,0 ; We Apply The IDCT To A Matrix, Only Containing A DC Value Of 700.
  ;dh 0,0,0,0,0,0,0,0   ; It Will Produce A Grey Colored Square.
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0

  ;dh 700,100,0,0,0,0,0,0 ; Now Let's Add An AC Value Of 100, At The 1st Position.
  ;dh 0,0,0,0,0,0,0,0     ; It Will Produce A Bar Diagram With A Curve Like A Half Cosine Line.
  ;dh 0,0,0,0,0,0,0,0     ; It Is Said It Has A Frequency Of 1 In X-Direction.
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0

  ;dh 700,0,100,0,0,0,0,0 ; What Happens If We Place The AC Value Of 100 At The Next Position?
  ;dh 0,0,0,0,0,0,0,0     ; The Shape Of The Bar Diagram Shows A Cosine Line, Too.
  ;dh 0,0,0,0,0,0,0,0     ; But Now We See A Full Period.
  ;dh 0,0,0,0,0,0,0,0     ; The Frequency Is Twice As High As In The Previous Example.
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0

  ;dh 700,100,100,0,0,0,0,0 ; But What Happens If We Place Both AC Values?
  ;dh 0,0,0,0,0,0,0,0       ; The Shape Of The Bar Diagram Is A Mix Of Both The 1st & 2nd Cosines.
  ;dh 0,0,0,0,0,0,0,0       ; The Resulting AC Value Is Simply An Addition Of The Cosine Lines.
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0

  ;dh 700,100,100,0,0,0,0,0 ; Now Let's Add An AC Value At The Other Direction.
  ;dh 200,0,0,0,0,0,0,0     ; Now The Values Vary In Y Direction, Too. The Principle Is:
  ;dh 0,0,0,0,0,0,0,0       ; The Higher The Index Of The AC Value The Greater The Frequency Is.
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0
  ;dh 0,0,0,0,0,0,0,0

  dh 950,0,0,0,0,0,0,0 ; Placing An AC Value At The Opposite Side Of The DC Value.
  dh 0,0,0,0,0,0,0,0   ; The Highest Possible Frequency Of 8 Is Applied In Both X- & Y- Direction.
  dh 0,0,0,0,0,0,0,0   ; Because Of The High Frequency The Neighbouring Values Differ Numerously.
  dh 0,0,0,0,0,0,0,0   ; The Picture Shows A Checker-Like Appearance.
  dh 0,0,0,0,0,0,0,0
  dh 0,0,0,0,0,0,0,0
  dh 0,0,0,0,0,0,0,0
  dh 0,0,0,0,0,0,0,500

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