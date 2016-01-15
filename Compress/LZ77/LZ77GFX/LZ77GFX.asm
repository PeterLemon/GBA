; GBA 'Bare Metal' LZ77 GFX Demo by krom (Peter Lemon):
; 1. Decode LZ77 Chunks To WRAM
; 2. DMA Contents Of WRAM To VRAM

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\MEM.INC'
include 'LIB\DMA.INC'
org $8000000
b Start
times $80000C0-($-0) db 0

Start:
  imm32 r0,LZ ; R0 = Source Address
  imm32 r1,WRAM ; R1 = Destination Address

  ldr r2,[r0],4 ; R2 = Data Length & Header Info
  lsr r2,8 ; R2 = Data Length
  add r2,r1 ; R2 = Destination End Offset

  LZLoop:
    ldrb r3,[r0],1 ; R3 = Flag Data For Next 8 Blocks (0 = Uncompressed Byte, 1 = Compressed Bytes)
    mov r4,10000000b ; R4 = Flag Data Block Type Shifter
    LZBlockLoop:
      cmp r1,r2 ; IF (Destination Address == Destination End Offset) LZ End
      beq LZEnd
      cmp r4,0 ; IF (Flag Data Block Type Shifter == 0) LZ Loop
      beq LZLoop
      tst r3,r4 ; Test Block Type
      lsr r4,1 ; Shift R4 To Next Flag Data Block Type
      bne LZDecode ; IF (BlockType != 0) LZ Decode Bytes
      ldrb r5,[r0],1 ; ELSE Copy Uncompressed Byte
      strb r5,[r1],1 ; Store Uncompressed Byte To Destination
      b LZBlockLoop

      LZDecode:
	ldrb r5,[r0],1 ; R5 = Number Of Bytes To Copy & Disp MSB's
	ldrb r6,[r0],1 ; R6 = Disp LSB's
	add r6,r5,lsl 8
	lsr r5,4 ; R5 = Number Of Bytes To Copy (Minus 3)
	add r5,3 ; R5 = Number Of Bytes To Copy
	mov r7,$1000
	sub r7,1 ; R7 = $FFF
	and r6,r7 ; R6 = Disp
	add r6,1 ; R6 = Disp + 1
	rsb r6,r1 ; R6 = Destination - Disp - 1
	LZCopy:
	  ldrb r7,[r6],1 ; R7 = Byte To Copy
	  strb r7,[r1],1 ; Store Byte To WRAM
	  subs r5,1 ; Number Of Bytes To Copy -= 1
	  bne LZCopy ; IF (Number Of Bytes To Copy != 0) LZ Copy Bytes
	  b LZBlockLoop
    LZEnd:

  ; Skip Zero's At End Of LZ Compressed File
  ands r1,r0,3 ; Compare LZ Offset To A Multiple Of 4
  subne r0,r1 ; IF (LZ Offset != Multiple Of 4) Add R1 To the LZ Offset
  addne r0,4 ; LZ Offset += 4

  mov r0,IO
  mov r1,MODE_3
  orr r1,BG2_ENABLE
  str r1,[r0]

  DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM

Loop:
  b Loop

LZ:
file 'BG.lz'