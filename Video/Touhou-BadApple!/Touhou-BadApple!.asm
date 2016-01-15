; GBA 'Bare Metal' I4-Bit LZ Compressed RLE Video Decode Demo by krom (Peter Lemon):

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\MEM.INC'
include 'LIB\LCD.INC'
include 'LIB\DMA.INC'
include 'LIB\SOUND.INC'
include 'LIB\TIMER.INC'
org $8000000
b copycode
times $80000C0-($-0) db 0

macro RLEDecode { ; Decode RLE Data
  local .RLELoop, .RLECopy, .RLEDecode, .RLEDecodeByte, .IPSEOF
  imm32 r0,WRAM + 19200 + 4 ; R0 = RLE Source Offset + 4
  mov r1,WRAM ; R1 = Destination Address (WRAM Start Offset)
  imm32 r2,WRAM + 19200 ; R2 = Destination End Offset (WRAM End Offset)

  .RLELoop:
    cmp r1,r2 ; Compare Destination Address To Destination End Offset
    beq .RLEEOF ; IF (Destination Address == Destination End Offset) RLEEOF

    ldrb r3,[r0],1 ; R3 = RLE Flag Data (Bit 0..6 = Expanded Data Length: Uncompressed N-1, Compressed N-3, Bit 7 = Flag: 0 = Uncompressed, 1 = Compressed)
    ands r4,r3,10000000b ; R4 = RLE Flag
    and r3,01111111b ; T1 = Expanded Data Length
    add r3,1 ; Expanded Data Length++
    bne .RLEDecode ; IF (BlockType != 0) RLE Decode Bytes

    .RLECopy: ; ELSE Copy Uncompressed Bytes
      ldrb r4,[r0],1 ; R4 = Byte To Copy
      strb r4,[r1],1 ; Store Uncompressed Byte To Destination
      subs r3,1 ; Expanded Data Length--
      bne .RLECopy ; IF (Expanded Data Length != 0) RLECopy
      b .RLELoop

    .RLEDecode:
      add r3,2 ; Expanded Data Length += 2
      ldrb r4,[r0],1 ; R4 = Byte To Copy
      .RLEDecodeByte:
	strb r4,[r1],1 ; Store Uncompressed Byte To Destination
	subs r3,1 ; Expanded Data Length--
	bne .RLEDecodeByte ; IF (Expanded Data Length != 0) RLEDecodeByte
	b .RLELoop

    .RLEEOF:
}

macro I4Decode { ; Decode I4 Frame
  local .I4Loop
  mov r0,VRAM ; R0 = VRAM Offset
  mov r1,WRAM ; R1 = I4 Offset
  mov r2,4800 ; R2 = Block Count

  .I4Loop: ;
    ldr r3,[r1],4 ; R3 = 8 * I4 Pixels (32-bits)

    mov r4,r3,lsr 3 ; r4 = 1st Pixel
    and r4,$1E
    orr r5,r4,r4,lsl 5
    orr r5,r4,lsl 10
    and r4,r3,$F ; r4 = 2nd Pixel
    orr r5,r4,lsl 17
    orr r5,r4,lsl 22
    orr r5,r4,lsl 27
    str r5,[r0],4 ; Store 2 Decoded I4 Pixels To VRAM

    mov r4,r3,lsr 11 ; r4 = 3rd Pixel
    and r4,$1E
    orr r5,r4,r4,lsl 5
    orr r5,r4,lsl 10
    mov r4,r3,lsr 7 ; r4 = 4th Pixel
    and r4,$1E
    orr r5,r4,lsl 16
    orr r5,r4,lsl 21
    orr r5,r4,lsl 26
    str r5,[r0],4 ; Store 2 Decoded I4 Pixels To VRAM

    mov r4,r3,lsr 19 ; r4 = 5th Pixel
    and r4,$1E
    orr r5,r4,r4,lsl 5
    orr r5,r4,lsl 10
    mov r4,r3,lsr 15 ; r4 = 6th Pixel
    and r4,$1E
    orr r5,r4,lsl 16
    orr r5,r4,lsl 21
    orr r5,r4,lsl 26
    str r5,[r0],4 ; Store 2 Decoded I4 Pixels To VRAM

    mov r4,r3,lsr 27 ; r4 = 7th Pixel
    and r4,$1E
    orr r5,r4,r4,lsl 5
    orr r5,r4,lsl 10
    mov r4,r3,lsr 23 ; r4 = 8th Pixel
    and r4,$1E
    orr r5,r4,lsl 16
    orr r5,r4,lsl 21
    orr r5,r4,lsl 26
    str r5,[r0],4 ; Store 2 Decoded I4 Pixels To VRAM

    subs r2,1 ; Block Count--
    bne .I4Loop ; IF (Block Count != 0) Loop I4 Blocks
}

copycode:
  adr r1,startcode
  mov r2,start
  imm32 r3,endcopy
  clp:
    ldr r0,[r1],4
    str r0,[r2],4
    cmp r2,r3
    bmi clp
  mov r2,start
  bx r2
startcode:
org IWRAM

start:
  mov r0,IO
  mov r1,MODE_3
  orr r1,BG2_ENABLE
  str r1,[r0]

  imm32 r0,Video ; R0 = LZ Compressed Data Offset
  str r0,[LZOffset] ; Store LZ Compressed Data Offset Into LZ Offset

  PlaySoundA Audio, 22050 ; Play Sound Channel A Data
LoopFrames:
  ldr r0,[LZOffset] ; R0 = LZ Offset
  imm32 r1,WRAM + 19200 ; R1 = LZ IPS File Output Offset
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

  str r0,[LZOffset] ; Store Last LZ IPS Frame End Offset To LZ Offset

  RLEDecode ; Decode RLE Data To WRAM
  I4Decode ; Decode I4 Data To VRAM
  TimerWait TM1CNT, $36 ; Wait On Timer 1

  imm32 r1,LZOffset
  ldr r0,[r1] ; Load Last LZ IPS Frame End Offset
  imm32 r1,Audio ; Load Video End Offset
  cmp r0,r1 ; Check Video End Offset
  bne LoopFrames ; Decode Next Frame
  StopSoundA ; Stop Sound Channel A
  b start ; Restart Video

LZOffset: ; LZ ROM End Of File Offset
dw 0

endcopy:

org $80000C0 + (endcopy - start) + (startcode - copycode)
align 4
Video:
file 'video.lz'
Audio:
file 'audio.snd'