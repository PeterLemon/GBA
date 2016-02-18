;mov r5,IO ; GBA I/O Base Offset
;WaitVBL:
;  ldrh r6,[r5,VCOUNT] ; Current LCD Scanline Position
;  cmp r6,160  	    ; Compare Scanline 160
;  bne WaitVBL ; Wait for VBlank

; Convert Palette
mov r5,VPAL
imm16 r6,BGP_REG
ldrb r6,[r10,r6]

and r7,r6,3     ; BGP Colour 0 (PAL&3)
eor r7,r7,3     ; Invert Bits
mov r7,r7,lsl 8
strh r7,[r5,0]

and r7,r6,12    ; BGP Colour 1 ((PAL&12)>>2)
eor r7,r7,3 * 4 ; Invert Bits
mov r7,r7,lsl 6
strh r7,[r5,2]

and r7,r6,48     ; BGP Colour 2 ((PAL&48)>>4)
eor r7,r7,3 * 16 ; Invert Bits
mov r7,r7,lsl 4
strh r7,[r5,4]

and r7,r6,192    ; BGP Colour 3 ((PAL&192)>>6))
eor r7,r7,3 * 64 ; Invert Bits
mov r7,r7,lsl 2
strh r7,[r5,6]

; Convert Characters
add r8,r10,CHAR_RAM ; Get The WRAM Offset
mov r7,VRAM ; Get the VRAM Offset
LoopTiles:
  mov r6,0 ; Reset Conversion Word
  ldrh r5,[r8],2 ; Load Word From WRAM
  tst r5,0000000010000000b ; Test GB Pixel Colour 1 In Char Row Position 1
  orrne r6,r6,00000000000000000000000000000001b ; Put Color 1st Bit In Char Row Position 1
  tst r5,0000000001000000b ; Test GB Pixel Colour 1 In Char Row Position 2
  orrne r6,r6,00000000000000000000000000010000b ; Put Color 1st Bit In Char Row Position 2
  tst r5,0000000000100000b ; Test GB Pixel Colour 1 In Char Row Position 3
  orrne r6,r6,00000000000000000000000100000000b ; Put Color 1st Bit In Char Row Position 3
  tst r5,0000000000010000b ; Test GB Pixel Colour 1 In Char Row Position 4
  orrne r6,r6,00000000000000000001000000000000b ; Put Color 1st Bit In Char Row Position 4
  tst r5,0000000000001000b ; Test GB Pixel Colour 1 In Char Row Position 5
  orrne r6,r6,00000000000000010000000000000000b ; Put Color 1st Bit In Char Row Position 5
  tst r5,0000000000000100b ; Test GB Pixel Colour 1 In Char Row Position 6
  orrne r6,r6,00000000000100000000000000000000b ; Put Color 1st Bit In Char Row Position 6
  tst r5,0000000000000010b ; Test GB Pixel Colour 1 In Char Row Position 7
  orrne r6,r6,00000001000000000000000000000000b ; Put Color 1st Bit In Char Row Position 7
  tst r5,0000000000000001b ; Test GB Pixel Colour 1 In Char Row Position 8
  orrne r6,r6,00010000000000000000000000000000b ; Put Color 1st Bit In Char Row Position 8

  tst r5,1000000000000000b ; Test GB Pixel Colour 1 In Char Row Position 1
  orrne r6,r6,00000000000000000000000000000010b ; Put Color 2nd Bit In Char Row Position 1
  tst r5,0100000000000000b ; Test GB Pixel Colour 1 In Char Row Position 2
  orrne r6,r6,00000000000000000000000000100000b ; Put Color 2nd Bit In Char Row Position 2
  tst r5,0010000000000000b ; Test GB Pixel Colour 1 In Char Row Position 3
  orrne r6,r6,00000000000000000000001000000000b ; Put Color 2nd Bit In Char Row Position 3
  tst r5,0001000000000000b ; Test GB Pixel Colour 1 In Char Row Position 4
  orrne r6,r6,00000000000000000010000000000000b ; Put Color 2nd Bit In Char Row Position 4
  tst r5,0000100000000000b ; Test GB Pixel Colour 1 In Char Row Position 5
  orrne r6,r6,00000000000000100000000000000000b ; Put Color 2nd Bit In Char Row Position 5
  tst r5,0000010000000000b ; Test GB Pixel Colour 1 In Char Row Position 6
  orrne r6,r6,00000000001000000000000000000000b ; Put Color 2nd Bit In Char Row Position 6
  tst r5,0000001000000000b ; Test GB Pixel Colour 1 In Char Row Position 7
  orrne r6,r6,00000010000000000000000000000000b ; Put Color 2nd Bit In Char Row Position 7
  tst r5,0000000100000000b ; Test GB Pixel Colour 1 In Char Row Position 8
  orrne r6,r6,00100000000000000000000000000000b ; Put Color 2nd Bit In Char Row Position 8
  str r6,[r7],4 ; Store Char Row (8 Pixels)

  add r6,r10,BG1_RAM
  cmp r8,r6
  bne LoopTiles ; Loop All Tiles

; Convert Tile Map
add r8,r10,BG1_RAM ; Get The WRAM Offset
imm32 r7,VRAM + $9800 ; Get the VRAM Offset
LoopMap:
  mov r6,0      ; Reset Conversion Word
  ldr r5,[r8],2 ; Load Word From WRAM
  and r6,r5,$FF
  orr r6,r6,r5,lsl 8
  imm32 r5,$00FF00FF
  and r6,r6,r5
  str r6,[r7],4 ; Store Map Word To VRAM

  add r6,r10,BG2_RAM
  cmp r8,r6
  bne LoopMap ; Loop All Map

; Force Screen On
mov r8,0 ; Clear r8
orr r8,r8,0001001100000000b ; Screen Base Block Set To $6009800
orr r8,r8,0000000000000000b ; Character Base Block Set To $6000000
mov r7,IO
strh r8,[r7,8] ; Store Into BG0 Control Register (REG_BG0CNT)

imm16 r5,SCX_REG ; Load Scroll X Register
ldrb r6,[r10,r5]
strb r6,[r7,BG0HOFS]

imm16 r5,SCY_REG ; Load Scroll Y Register
ldrb r6,[r10,r5]
strb r6,[r7,BG0VOFS]