; Game Boy Advance 'Bare Metal' Myst Demo by krom (Peter Lemon):
; Example of Compressed Video & Still Frame Decoding

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\MEM.INC'
include 'LIB\LCD.INC'
include 'LIB\DMA.INC'
include 'LIB\SOUND.INC'
include 'LIB\TIMER.INC'
include 'LIB\OBJ.INC'
include 'LIB\KEYPAD.INC'
org $8000000
b copycode
times $80000C0-($-0) db 0

macro IPSdecode { ; Decode IPS Headerless & Footerless data with 2 byte Offsets, Little Endian Offset, Size, & RLE Size
  local .IPSOffset, .IPSData, .IPSRLE, .IPSRLELoop, .IPSEOF
  imm32 r0,$201F0E0   ; Load IPS Location
  imm32 r5,$2012C00   ; Load WRAM Offset
  ldr r6,[IPSWRAMPos] ; Load IPS WRAM End Position
  .IPSOffset: ; Decode IPS Offset
    ldrb r2,[r0],1  ; Load 1st Offset Byte
    ldrb r4,[r0],1  ; Load 2nd Offset Byte
    orr r2,r4,lsl 8 ; Add 1st & 2nd Offset Bytes
    add r1,r5,r2    ; Add WRAM Offset + IPS Offset
  ; Decode IPS Size
    ldrb r3,[r0],1   ; Load 1st Size Byte
    ldrb r4,[r0],1   ; Load 2nd Size Byte
    orrs r3,r4,lsl 8 ; Add 1st & 2nd Size Bytes
    beq .IPSRLE      ; Decode IPS RLE If Zero
  .IPSData: ; Decode IPS Data
    ldrb r4,[r0],1 ; Load Data Byte
    strb r4,[r1],1 ; Store Data Byte
    subs r3,1	   ; Sub 1 From IPS Size
    bne .IPSData   ; Loop IPS Data If IPS Size Is Not Zero
    beq .IPSEOF    ; Run IPS EOF If IPS Size Is Zero
  .IPSRLE: ; Decode IPS RLE Data
    ldrb r3,[r0],1  ; Load 1st RLE Size Byte
    ldrb r4,[r0],1  ; Load 2nd RLE Size Byte
    orr r3,r4,lsl 8 ; Add 1st & 2nd RLE Size Bytes
    ldrb r4,[r0],1  ; Load RLE Repeated Byte
    .IPSRLELoop: ; IPS RLE Repeated Data Loop
      strb r4,[r1],1
      subs r3,1
      bne .IPSRLELoop
  .IPSEOF: ; Decode IPS EOF
    cmp r0,r6	   ; Compare WRAM Offset To IPS WRAM End Position
    bne .IPSOffset ; Run IPS Offset If EOF Not Reached
}

macro GRBdecode { ; Decode GRB Frame
  local .decodeGRBLoop
  mov r0,WRAM		  ; WRAM Offset
  imm32 r1,$2012C00	  ; G Offset
  add r2,r1,240 * 160	  ; R Offset
  add r3,r2,240 * 160 / 4 ; B Offset

  mov r4,240 * 160 / 16 ; Block Count
  mov r5,60 ; End Of Blue Scanline Counter (240 / 4 = 60)

  mov r9,239   ; Load 478
  lsl r9,1
  mov r10,237  ; Load 474
  lsl r10,1
  mov r11,1440 ; Load 1438
  sub r11,2
  .decodeGRBLoop: ; Loop 4x4 Block (16 pixels)
    ldrb r6,[r3],1    ; Load B Byte
    mov r12,r6,lsl 10 ; Pack B Pixel

    ; 1st 2x2 Block (4 Pixels)
    ldrb r7,[r2],1 ; Load R Byte
    orr r12,r7	   ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1],1 ; Load G Byte
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],2  ; Store Decoded GRB Pixel Into WRAM
    ; 2nd Pixel
    ldrb r8,[r1],r9,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7	      ; Pack R Pixel
    orr r12,r8,lsl 5  ; Pack G Pixel
    strh r12,[r0],r9  ; Store Decoded GRB Pixel Into WRAM
    ; 3rd Pixel
    ldrb r8,[r1],1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7	      ; Pack R Pixel
    orr r12,r8,lsl 5  ; Pack G Pixel
    strh r12,[r0],2   ; Store Decoded GRB Pixel Into WRAM
    ; 4th Pixel
    ldrb r8,[r1],-r9,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7	      ; Pack R Pixel
    orr r12,r8,lsl 5  ; Pack G Pixel
    strh r12,[r0],-r9 ; Store Decoded GRB Pixel Into WRAM

    ; 2nd 2x2 Block (4 Pixels)
    mov r12,r6,lsl 10 ; Pack B Pixel
    ldrb r7,[r2],119  ; Load R Byte
    orr r12,r7	      ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1],1 ; Load G Byte
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],2  ; Store Decoded GRB Pixel Into WRAM
    ; 2nd Pixel
    ldrb r8,[r1],r9,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7	      ; Pack R Pixel
    orr r12,r8,lsl 5  ; Pack G Pixel
    strh r12,[r0],r9  ; Store Decoded GRB Pixel Into WRAM
    ; 3rd Pixel
    ldrb r8,[r1],1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7	      ; Pack R Pixel
    orr r12,r8,lsl 5  ; Pack G Pixel
    strh r12,[r0],2   ; Store Decoded GRB Pixel Into WRAM
    ; 4th Pixel
    ldrb r8,[r1],r10,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7	      ; Pack R Pixel
    orr r12,r8,lsl 5  ; Pack G Pixel
    strh r12,[r0],r10 ; Store Decoded GRB Pixel Into WRAM

    ; 3rd 2x2 Block (4 Pixels)
    mov r12,r6,lsl 10 ; Pack B Pixel
    ldrb r7,[r2],1 ; Load R Byte
    orr r12,r7	   ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1],1 ; Load G Byte
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],2  ; Store Decoded GRB Pixel Into WRAM
    ; 2nd Pixel
    ldrb r8,[r1],r9,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7	      ; Pack R Pixel
    orr r12,r8,lsl 5  ; Pack G Pixel
    strh r12,[r0],r9  ; Store Decoded GRB Pixel Into WRAM
    ; 3rd Pixel
    ldrb r8,[r1],1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7	      ; Pack R Pixel
    orr r12,r8,lsl 5  ; Pack G Pixel
    strh r12,[r0],2   ; Store Decoded GRB Pixel Into WRAM
    ; 4th Pixel
    ldrb r8,[r1],-r9,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10  ; Pack B Pixel
    orr r12,r7	       ; Pack R Pixel
    orr r12,r8,lsl 5   ; Pack G Pixel
    strh r12,[r0],-r9  ; Store Decoded GRB Pixel Into WRAM

    ; 4th 2x2 Block (4 Pixels)
    subs r5,1 ; Decrement End Of Blue Scanline Counter
    moveq r5,60 ; End Of Blue Scanline
    mov r12,r6,lsl 10 ; Pack B Pixel
    ldrbeq r7,[r2],1	; Load R Byte End Of Blue Scanline
    ldrbne r7,[r2],-119 ; Load R Byte
    orr r12,r7		; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1],1 ; Load G Byte
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],2  ; Store Decoded GRB Pixel Into WRAM
    ; 2nd Pixel
    ldrb r8,[r1],r9,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7	      ; Pack R Pixel
    orr r12,r8,lsl 5  ; Pack G Pixel
    strh r12,[r0],r9  ; Store Decoded GRB Pixel Into WRAM
    ; 3rd Pixel
    ldrb r8,[r1],1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7	      ; Pack R Pixel
    orr r12,r8,lsl 5  ; Pack G Pixel
    strh r12,[r0],2   ; Store Decoded GRB Pixel Into WRAM
    ; 4th Pixel
    ldrbeq r8,[r1],1 ; Load G Byte End Of Blue Scanline
    ldrbne r8,[r1],-r11,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10	 ; Pack B Pixel
    orr r12,r7		 ; Pack R Pixel
    orr r12,r8,lsl 5	 ; Pack G Pixel
    strheq r12,[r0],2	 ; Store Decoded GRB Pixel Into WRAM End Of Blue Scanline
    strhne r12,[r0],-r11 ; Store Decoded GRB Pixel Into WRAM

    subs r4,1
    bne .decodeGRBLoop
}

macro PlayVideoIPS Video, Audio, AudioHz, Wait { ; Play IPS & LZ Compressed GRB Frame Video & Audio
local .Loop, .LZLoop, .LZBlockLoop, .LZDecode, .LZCopy, .LZEnd, .LZEOF
  imm32 r0,Video      ; Load LZ77 Compressed Data Offset
  imm32 r1,LZPosition ; Load LZPosition
  str r0,[r1] ; Store LZ77 Compressed Data Offset Into LZPosition

  PlaySoundA Audio, AudioHz ; Play Sound Channel A Data
  .Loop:
    imm32 r1,LZPosition
    ldr r0,[r1] ; Load LZPosition
    imm32 r1,$201F0E0 ; Load LZ77 IPS File Output Offset
 ;   swi $110000       ; Uncompress LZ77 32 Bits Bios Call
    ldr r2,[r0],4 ; R2 = Data Length & Header Info
    lsr r2,8 ; R2 = Data Length
    add r2,r1 ; R2 = Destination End Offset

    .LZLoop:
      ldrb r3,[r0],1 ; R3 = Flag Data For Next 8 Blocks (0 = Uncompressed Byte, 1 = Compressed Bytes)
      mov r4,10000000b ; R4 = Flag Data Block Type Shifter
      .LZBlockLoop:
	cmp r1,r2 ; IF(Destination Address == Destination End Offset) LZEnd
	beq .LZEnd
	cmp r4,0 ; IF(Flag Data Block Type Shifter == 0) LZLoop
	beq .LZLoop
	tst r3,r4 ; Test Block Type
	lsr r4,1 ; Shift R4 To Next Flag Data Block Type
	bne .LZDecode ; IF(BlockType != 0) LZDecode Bytes
	ldrb r5,[r0],1 ; ELSE Copy Uncompressed Byte
	strb r5,[r1],1 ; Store Uncompressed Byte To Destination
	b .LZBlockLoop

	.LZDecode:
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
	  .LZCopy:
	    ldrb r7,[r6],1
	    strb r7,[r1],1
	    subs r5,1
	    bne .LZCopy
	    b .LZBlockLoop
    .LZEnd:

    imm32 r12,IPSWRAMPos
    str r1,[r12] ; Store IPS WRAM End Position

    .LZEOF: ; Skip Zero's At End Of LZ77 Compressed File
      tst r0,3 ; Compare LZ77 Offset To A Multiple Of 4
      addne r0,1 ; Add 1 To the LZ77 Offset If not a Multiple Of 4
      bne .LZEOF ; Run LZEOF If Not Multiple Of 4

    imm32 r1,LZPosition ; Load LZPosition
    str r0,[r1] ; Store Last LZ IPS Frame End Offset To LZPosition

    bl IPSdecoder ; Decode IPS Data
    bl GRBdecoder ; Decode GRB Data
    DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM
    TimerWait TM1CNT, Wait ; Wait On Timer 1

    imm32 r1,LZPosition
    ldr r0,[r1] ; Load Last LZ IPS Frame End Offset
    imm32 r1,Audio ; Load Video End Offset
    cmp r0,r1 ; Check Video End Offset
    bne .Loop ; Decode Next Frame
}

macro PlayVideoLZ Video, Audio, AudioHz, Wait { ; Play LZ Compressed GRB Frame Video & Audio
local .Loop, .LZLoop, .LZBlockLoop, .LZDecode, .LZCopy, .LZEnd, .LZEOF
  imm32 r0,Video      ; Load LZ77 Compressed Data Offset
  imm32 r1,LZPosition ; Load LZPosition
  str r0,[r1] ; Store LZ77 Compressed Data Offset Into LZPosition

  PlaySoundA Audio, AudioHz ; Play Sound Channel A Data
  .Loop:
    imm32 r1,LZPosition  ; Load LZPosition
    ldr r0,[r1] ; Load LZPosition
    imm32 r1,$2012C00 ; Load LZ77 GRB File Output Offset
;    swi $110000       ; Uncompress LZ77 32 Bits Bios Call
       ldr r2,[r0],4 ; R2 = Data Length & Header Info
    lsr r2,8 ; R2 = Data Length
    add r2,r1 ; R2 = Destination End Offset

    .LZLoop:
      ldrb r3,[r0],1 ; R3 = Flag Data For Next 8 Blocks (0 = Uncompressed Byte, 1 = Compressed Bytes)
      mov r4,10000000b ; R4 = Flag Data Block Type Shifter
      .LZBlockLoop:
	cmp r1,r2 ; IF(Destination Address == Destination End Offset) LZEnd
	beq .LZEnd
	cmp r4,0 ; IF(Flag Data Block Type Shifter == 0) LZLoop
	beq .LZLoop
	tst r3,r4 ; Test Block Type
	lsr r4,1 ; Shift R4 To Next Flag Data Block Type
	bne .LZDecode ; IF(BlockType != 0) LZDecode Bytes
	ldrb r5,[r0],1 ; ELSE Copy Uncompressed Byte
	strb r5,[r1],1 ; Store Uncompressed Byte To Destination
	b .LZBlockLoop

	.LZDecode:
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
	  .LZCopy:
	    ldrb r7,[r6],1
	    strb r7,[r1],1
	    subs r5,1
	    bne .LZCopy
	    b .LZBlockLoop
    .LZEnd:

    imm32 r12,LZPosition  ; Load LZPosition
    str r1,[r12] ; Store LZ WRAM End Position

    .LZEOF: ; Skip Zero's At End Of LZ77 Compressed File
      tst r0,3 ; Compare LZ77 Offset To A Multiple Of 4
      addne r0,1 ; Add 1 To the LZ77 Offset If not a Multiple Of 4
      bne .LZEOF ; Run LZEOF If Not Multiple Of 4

    imm32 r1,LZPosition ; Load LZPosition
    str r0,[r1] ; Store Last LZ IPS Frame End Offset To LZPosition

    bl GRBdecoder ; Decode GRB Data
    DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM
    TimerWait TM1CNT, Wait ; Wait On Timer 1

    imm32 r1,LZPosition
    ldr r0,[r1] ; Load Last LZ IPS Frame End Offset
    imm32 r1,Audio ; Load Video End Offset
    cmp r0,r1 ; Check Video End Offset
    bne .Loop ; Decode Next Frame
}

macro LEFTRIGHT LZFrame, Audio, AudioHz, AudioVBLoop, Left, Right { ; Run Left, Right, Decode LZ77 Frame, Audio Loop & Resume
  local .Loop, .Resume, .VBLoop, .DOWN, .LEFT, .RIGHT, .MOVEOBJ, .MOVERIGHT, .MOVEEND
  imm32 r0,LZFrame ; Load LZPosition
  imm32 r1,$2012C00 ; Load LZ77 GRB File Output Offset
  swi $110000	    ; Uncompress LZ77 32 Bits Bios Call
  bl GRBdecoder ; Decode GRB Data
  DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM
  TimerWait TM1CNT, Second4th ; Wait 1/4 second on Timer 1

  imm32 r1,AUDIOVBLoop
  ldr r0,[r1]
  subs r0,32 ; Need to subtract V Blanks To Keep Audio Timed
  str r0,[r1]
  blt .Loop

  imm32 r1,AUDIOOffset
  ldr r0,[r1]
  imm32 r1,Audio
  cmp r0,r1
  beq .Resume

  .Loop:
    StopSoundA ; Stop Sound Channel A
    PlaySoundA Audio, AudioHz ; Play Sound Channel A Data
    imm32 r0,Audio
    imm32 r1,AUDIOOffset
    str r0,[r1]
    imm16 r0,AudioVBLoop ; Sound sample VBlank time
    imm32 r1,AUDIOVBLoop
    str r0,[r1]

  .Resume:
    imm32 r1,AUDIOVBLoop
    ldr r4,[r1]

  .VBLoop:
    bl VBlanker
    imm32 r2,POINTERX
    ldrb r0,[r2]
    imm32 r3,POINTERY
    ldrb r1,[r3]
    cmp r1,0
    beq .DOWN
    IsKeyDown KEY_UP
    subeq r1,1

    .DOWN:
      cmp r1,144
      beq .LEFT
      IsKeyDown KEY_DOWN
      addeq r1,1

    .LEFT:
      cmp r0,0
      beq .RIGHT
      IsKeyDown KEY_LEFT
      subeq r0,1

    .RIGHT:
      cmp r0,224
      beq .MOVEOBJ
      IsKeyDown KEY_RIGHT
      addeq r0,1

    .MOVEOBJ:
      MoveOBJ 0, r0, r1 ; OBJ, X, Y
      strb r0,[r2]
      strb r1,[r3]

    imm32 r2,OAM + 4 ; Load Pointer To OAM 1st Tile Number (0x7000004)
    mov r3,512	   ; Attribute 2: Tile Number 512 (Point Up)
    cmp r0,56
    imm16lt r3,528 ; Attribute 2: Tile Number 528 (Point Left)
    bgt .MOVERIGHT
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Left
    .MOVERIGHT:
    cmp r0,184
    imm16gt r3,536 ; Attribute 2: Tile Number 536 (Point Right)
    ble .MOVEEND
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Right
    .MOVEEND:
    str r3,[r2] ; Store Attribute 2

    subs r4,1
    bne .VBLoop
  b .Loop
}

macro LEFTRIGHTBOUND LZFrame, Audio, AudioHz, AudioVBLoop, Left, Right, Bound, BoundX1, BoundY1, BoundX2, BoundY2 { ; Run Left, Right, Bound, Decode LZ77 Frame, Audio Loop & Resume
  local .Loop, .Resume, .VBLoop, .DOWN, .LEFT, .RIGHT, .MOVEOBJ, .MOVERIGHT, .MOVEEND
  imm32 r0,LZFrame ; Load LZPosition
  imm32 r1,$2012C00 ; Load LZ77 GRB File Output Offset
  swi $110000	    ; Uncompress LZ77 32 Bits Bios Call
  bl GRBdecoder ; Decode GRB Data
  DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM
  TimerWait TM1CNT, Second4th ; Wait 1/4 second on Timer 1

  imm32 r1,AUDIOVBLoop
  ldr r0,[r1]
  subs r0,32 ; Need to subtract V Blanks To Keep Audio Timed
  str r0,[r1]
  blt .Loop

  imm32 r1,AUDIOOffset
  ldr r0,[r1]
  imm32 r1,Audio
  cmp r0,r1
  beq .Resume

  .Loop:
    StopSoundA ; Stop Sound Channel A
    PlaySoundA Audio, AudioHz ; Play Sound Channel A Data
    imm32 r0,Audio
    imm32 r1,AUDIOOffset
    str r0,[r1]
    imm16 r0,AudioVBLoop ; Sound sample VBlank time
    imm32 r1,AUDIOVBLoop
    str r0,[r1]

  .Resume:
    imm32 r1,AUDIOVBLoop
    ldr r4,[r1]

  .VBLoop:
    bl VBlanker
    imm32 r2,POINTERX
    ldrb r0,[r2]
    imm32 r3,POINTERY
    ldrb r1,[r3]
    cmp r1,0
    beq .DOWN
    IsKeyDown KEY_UP
    subeq r1,1

    .DOWN:
      cmp r1,144
      beq .LEFT
      IsKeyDown KEY_DOWN
      addeq r1,1

    .LEFT:
      cmp r0,0
      beq .RIGHT
      IsKeyDown KEY_LEFT
      subeq r0,1

    .RIGHT:
      cmp r0,224
      beq .MOVEOBJ
      IsKeyDown KEY_RIGHT
      addeq r0,1

    .MOVEOBJ:
      MoveOBJ 0, r0, r1 ; OBJ, X, Y
      strb r0,[r2]
      strb r1,[r3]

    imm32 r2,OAM + 4 ; Load Pointer To OAM 1st Tile Number (0x7000004)
    mov r3,512	   ; Attribute 2: Tile Number 512 (Point Up)
    cmp r0,56
    imm16lt r3,528 ; Attribute 2: Tile Number 528 (Point Left)
    bgt .MOVERIGHT
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Left
    .MOVERIGHT:
    cmp r0,184
    imm16gt r3,536 ; Attribute 2: Tile Number 536 (Point Right)
    ble .MOVEUP
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Right
    .MOVEUP:
    cmp r0,BoundX1
    blt .MOVEEND
    cmp r0,BoundX2
    bgt .MOVEEND
    cmp r1,BoundY1
    blt .MOVEEND
    cmp r1,BoundY2
    bgt .MOVEEND
    imm16 r3,544 ; Attribute 2: Tile Number 544 (Hand)
    IsKeyDown KEY_A
    imm16eq r3,552 ; Attribute 2: Tile Number 552 (Hand Grab)
    streq r3,[r2] ; Store Attribute 2
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Bound
    .MOVEEND:
    str r3,[r2] ; Store Attribute 2

    subs r4,1
    bne .VBLoop
  b .Loop
}

macro UPLEFTRIGHT LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right { ; Run Up, Left, Right, Decode LZ77 Frame, Audio Loop & Resume
  local .Loop, .Resume, .VBLoop, .DOWN, .LEFT, .RIGHT, .MOVEOBJ, .MOVERIGHT, .MOVEEND
  imm32 r0,LZFrame ; Load LZPosition
  imm32 r1,$2012C00 ; Load LZ77 GRB File Output Offset
  swi $110000	    ; Uncompress LZ77 32 Bits Bios Call
  bl GRBdecoder ; Decode GRB Data
  DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM
  TimerWait TM1CNT, Second4th ; Wait 1/4 second on Timer 1

  imm32 r1,AUDIOVBLoop
  ldr r0,[r1]
  subs r0,32 ; Need to subtract V Blanks To Keep Audio Timed
  str r0,[r1]
  blt .Loop

  imm32 r1,AUDIOOffset
  ldr r0,[r1]
  imm32 r1,Audio
  cmp r0,r1
  beq .Resume

  .Loop:
    StopSoundA ; Stop Sound Channel A
    PlaySoundA Audio, AudioHz ; Play Sound Channel A Data
    imm32 r0,Audio
    imm32 r1,AUDIOOffset
    str r0,[r1]
    imm16 r0,AudioVBLoop ; Sound sample VBlank time
    imm32 r1,AUDIOVBLoop
    str r0,[r1]

  .Resume:
    imm32 r1,AUDIOVBLoop
    ldr r4,[r1]

  .VBLoop:
    bl VBlanker
    imm32 r2,POINTERX
    ldrb r0,[r2]
    imm32 r3,POINTERY
    ldrb r1,[r3]
    cmp r1,0
    beq .DOWN
    IsKeyDown KEY_UP
    subeq r1,1

    .DOWN:
      cmp r1,144
      beq .LEFT
      IsKeyDown KEY_DOWN
      addeq r1,1

    .LEFT:
      cmp r0,0
      beq .RIGHT
      IsKeyDown KEY_LEFT
      subeq r0,1

    .RIGHT:
      cmp r0,224
      beq .MOVEOBJ
      IsKeyDown KEY_RIGHT
      addeq r0,1

    .MOVEOBJ:
      MoveOBJ 0, r0, r1 ; OBJ, X, Y
      strb r0,[r2] ; Store POINTERX
      strb r1,[r3] ; Store POINTERY

    imm32 r2,OAM + 4 ; Load Pointer To OAM 1st Tile Number (0x7000004)
    mov r3,512	   ; Attribute 2: Tile Number 512 (Point Up)
    cmp r0,56
    imm16lt r3,528 ; Attribute 2: Tile Number 528 (Point Left)
    bgt .MOVERIGHT
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Left
    .MOVERIGHT:
    cmp r0,184
    imm16gt r3,536 ; Attribute 2: Tile Number 536 (Point Right)
    ble .MOVEEND
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Right
    .MOVEEND:
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Up
    str r3,[r2] ; Store Attribute 2

    subs r4,1
    bne .VBLoop
  b .Loop
}

macro UPLEFTRIGHTBOUND LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right, Bound, BoundX1, BoundY1, BoundX2, BoundY2 { ; Run Up, Left, Right, Bound, Decode LZ77 Frame, Audio Loop & Resume
  local .Loop, .Resume, .VBLoop, .DOWN, .LEFT, .RIGHT, .MOVEOBJ, .MOVERIGHT, .MOVEEND
  imm32 r0,LZFrame ; Load LZPosition
  imm32 r1,$2012C00 ; Load LZ77 GRB File Output Offset
  swi $110000	    ; Uncompress LZ77 32 Bits Bios Call
  bl GRBdecoder ; Decode GRB Data
  DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM
  TimerWait TM1CNT, Second4th ; Wait 1/4 second on Timer 1

  imm32 r1,AUDIOVBLoop
  ldr r0,[r1]
  subs r0,32 ; Need to subtract V Blanks To Keep Audio Timed
  str r0,[r1]
  blt .Loop

  imm32 r1,AUDIOOffset
  ldr r0,[r1]
  imm32 r1,Audio
  cmp r0,r1
  beq .Resume

  .Loop:
    StopSoundA ; Stop Sound Channel A
    PlaySoundA Audio, AudioHz ; Play Sound Channel A Data
    imm32 r0,Audio
    imm32 r1,AUDIOOffset
    str r0,[r1]
    imm16 r0,AudioVBLoop ; Sound sample VBlank time
    imm32 r1,AUDIOVBLoop
    str r0,[r1]

  .Resume:
    imm32 r1,AUDIOVBLoop
    ldr r4,[r1]

  .VBLoop:
    bl VBlanker
    imm32 r2,POINTERX
    ldrb r0,[r2]
    imm32 r3,POINTERY
    ldrb r1,[r3]
    cmp r1,0
    beq .DOWN
    IsKeyDown KEY_UP
    subeq r1,1

    .DOWN:
      cmp r1,144
      beq .LEFT
      IsKeyDown KEY_DOWN
      addeq r1,1

    .LEFT:
      cmp r0,0
      beq .RIGHT
      IsKeyDown KEY_LEFT
      subeq r0,1

    .RIGHT:
      cmp r0,224
      beq .MOVEOBJ
      IsKeyDown KEY_RIGHT
      addeq r0,1

    .MOVEOBJ:
      MoveOBJ 0, r0, r1 ; OBJ, X, Y
      strb r0,[r2]
      strb r1,[r3]

    imm32 r2,OAM + 4 ; Load Pointer To OAM 1st Tile Number (0x7000004)
    mov r3,512	   ; Attribute 2: Tile Number 512 (Point Up)
    cmp r0,56
    imm16lt r3,528 ; Attribute 2: Tile Number 528 (Point Left)
    bgt .MOVERIGHT
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Left
    .MOVERIGHT:
    cmp r0,184
    imm16gt r3,536 ; Attribute 2: Tile Number 536 (Point Right)
    ble .MOVEUP
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Right
    .MOVEUP:
    cmp r0,BoundX1
    blt .MOVEEND
    cmp r0,BoundX2
    bgt .MOVEEND
    cmp r1,BoundY1
    blt .MOVEEND
    cmp r1,BoundY2
    bgt .MOVEEND
    imm16 r3,544 ; Attribute 2: Tile Number 544 (Hand)
    IsKeyDown KEY_A
    imm16eq r3,552 ; Attribute 2: Tile Number 552 (Hand Grab)
    streq r3,[r2] ; Store Attribute 2
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Bound
    .MOVEEND:
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Up
    str r3,[r2] ; Store Attribute 2

    subs r4,1
    bne .VBLoop
  b .Loop
}

macro UPLEFTRIGHTIPS IPSFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right { ; Run Up, Left, Right, Decode LZ77 IPS Frame, Audio Loop & Resume
  local .Loop, .Resume, .VBLoop, .DOWN, .LEFT, .RIGHT, .MOVEOBJ, .MOVERIGHT, .MOVEEND
  imm32 r0,IPSFrame ; Load IPSPosition
  imm32 r1,$201F0E0 ; Load LZ77 IPS File Output Offset
  swi $110000	    ; Uncompress LZ77 32 Bits Bios Call
  imm32 r12,IPSWRAMPos
  str r1,[r12] ; Store IPS WRAM End Position
  bl IPSdecoder ; Decode IPS Data
  bl GRBdecoder ; Decode GRB Data
  DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM
  TimerWait TM1CNT, Second4th ; Wait 1/4 second on Timer 1

  imm32 r1,AUDIOVBLoop
  ldr r0,[r1]
  subs r0,32 ; Need to subtract V Blanks To Keep Audio Timed
  str r0,[r1]
  blt .Loop

  imm32 r1,AUDIOOffset
  ldr r0,[r1]
  imm32 r1,Audio
  cmp r0,r1
  beq .Resume

  .Loop:
    StopSoundA ; Stop Sound Channel A
    PlaySoundA Audio, AudioHz ; Play Sound Channel A Data
    imm32 r0,Audio
    imm32 r1,AUDIOOffset
    str r0,[r1]
    imm16 r0,AudioVBLoop ; Sound sample VBlank time
    imm32 r1,AUDIOVBLoop
    str r0,[r1]

  .Resume:
    imm32 r1,AUDIOVBLoop
    ldr r4,[r1]

  .VBLoop:
    bl VBlanker
    imm32 r2,POINTERX
    ldrb r0,[r2]
    imm32 r3,POINTERY
    ldrb r1,[r3]
    cmp r1,0
    beq .DOWN
    IsKeyDown KEY_UP
    subeq r1,1

    .DOWN:
      cmp r1,144
      beq .LEFT
      IsKeyDown KEY_DOWN
      addeq r1,1

    .LEFT:
      cmp r0,0
      beq .RIGHT
      IsKeyDown KEY_LEFT
      subeq r0,1

    .RIGHT:
      cmp r0,224
      beq .MOVEOBJ
      IsKeyDown KEY_RIGHT
      addeq r0,1

    .MOVEOBJ:
      MoveOBJ 0, r0, r1 ; OBJ, X, Y
      strb r0,[r2] ; Store POINTERX
      strb r1,[r3] ; Store POINTERY

    imm32 r2,OAM + 4 ; Load Pointer To OAM 1st Tile Number (0x7000004)
    mov r3,512	   ; Attribute 2: Tile Number 512 (Point Up)
    cmp r0,56
    imm16lt r3,528 ; Attribute 2: Tile Number 528 (Point Left)
    bgt .MOVERIGHT
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Left
    .MOVERIGHT:
    cmp r0,184
    imm16gt r3,536 ; Attribute 2: Tile Number 536 (Point Right)
    ble .MOVEEND
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Right
    .MOVEEND:
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Up
    str r3,[r2] ; Store Attribute 2

    subs r4,1
    bne .VBLoop
  b .Loop
}

macro UPLEFTRIGHTBOUNDIPS IPSFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right, Bound, BoundX1, BoundY1, BoundX2, BoundY2 { ; Run Up, Left, Right, Bound, Decode LZ77 IPS Frame, Audio Loop & Resume
  local .Loop, .Resume, .VBLoop, .DOWN, .LEFT, .RIGHT, .MOVEOBJ, .MOVERIGHT, .MOVEEND
  imm32 r0,IPSFrame ; Load IPSPosition
  imm32 r1,$201F0E0 ; Load LZ77 IPS File Output Offset
  swi $110000	    ; Uncompress LZ77 32 Bits Bios Call
  imm32 r12,IPSWRAMPos
  str r1,[r12] ; Store IPS WRAM End Position
  bl IPSdecoder ; Decode IPS Data
  bl GRBdecoder ; Decode GRB Data
  DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM
  TimerWait TM1CNT, Second4th ; Wait 1/4 second on Timer 1

  imm32 r1,AUDIOVBLoop
  ldr r0,[r1]
  subs r0,32 ; Need to subtract V Blanks To Keep Audio Timed
  str r0,[r1]
  blt .Loop

  imm32 r1,AUDIOOffset
  ldr r0,[r1]
  imm32 r1,Audio
  cmp r0,r1
  beq .Resume

  .Loop:
    StopSoundA ; Stop Sound Channel A
    PlaySoundA Audio, AudioHz ; Play Sound Channel A Data
    imm32 r0,Audio
    imm32 r1,AUDIOOffset
    str r0,[r1]
    imm16 r0,AudioVBLoop ; Sound sample VBlank time
    imm32 r1,AUDIOVBLoop
    str r0,[r1]

  .Resume:
    imm32 r1,AUDIOVBLoop
    ldr r4,[r1]

  .VBLoop:
    bl VBlanker
    imm32 r2,POINTERX
    ldrb r0,[r2]
    imm32 r3,POINTERY
    ldrb r1,[r3]
    cmp r1,0
    beq .DOWN
    IsKeyDown KEY_UP
    subeq r1,1

    .DOWN:
      cmp r1,144
      beq .LEFT
      IsKeyDown KEY_DOWN
      addeq r1,1

    .LEFT:
      cmp r0,0
      beq .RIGHT
      IsKeyDown KEY_LEFT
      subeq r0,1

    .RIGHT:
      cmp r0,224
      beq .MOVEOBJ
      IsKeyDown KEY_RIGHT
      addeq r0,1

    .MOVEOBJ:
      MoveOBJ 0, r0, r1 ; OBJ, X, Y
      strb r0,[r2]
      strb r1,[r3]

    imm32 r2,OAM + 4 ; Load Pointer To OAM 1st Tile Number (0x7000004)
    mov r3,512	   ; Attribute 2: Tile Number 512 (Point Up)
    cmp r0,56
    imm16lt r3,528 ; Attribute 2: Tile Number 528 (Point Left)
    bgt .MOVERIGHT
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Left
    .MOVERIGHT:
    cmp r0,184
    imm16gt r3,536 ; Attribute 2: Tile Number 536 (Point Right)
    ble .MOVEUP
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Right
    .MOVEUP:
    cmp r0,BoundX1
    blt .MOVEEND
    cmp r0,BoundX2
    bgt .MOVEEND
    cmp r1,BoundY1
    blt .MOVEEND
    cmp r1,BoundY2
    bgt .MOVEEND
    imm16 r3,544 ; Attribute 2: Tile Number 544 (Hand)
    IsKeyDown KEY_A
    imm16eq r3,552 ; Attribute 2: Tile Number 552 (Hand Grab)
    streq r3,[r2] ; Store Attribute 2
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Bound
    .MOVEEND:
    IsKeyDown KEY_A
    imm32eq r5,AUDIOVBLoop
    streq r4,[r5]
    beq Up
    str r3,[r2] ; Store Attribute 2

    subs r4,1
    bne .VBLoop
  b .Loop
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
  imm32 r1,MODE_3 or BG2_ENABLE or OBJ_ENABLE or OBJ_MAP_1D
  str r1,[r0]

  BGOAMBlackFade ; BG & OAM Fade 2 Black

  mov r0,OAM ; Load Pointer To OAM ($7000000)
  imm32 r1,(SQUARE or COLOR_256 or 160) or ((SIZE_16 or 72) * 65536)
  str r1,[r0],4 ; Attributes 0 & 1 Into OAM, Pointer Set Attribute 2
  mov r1,512	; Attribute 2: Tile Number 512
  str r1,[r0]

  DMA32 POINTERPAL, OBJPAL, 128   ; 1 * 256 Cols
  DMA32 POINTER, CHARMEM_512, 384 ; 6 * 16x16 Sprites

PlayVideoIPS CYANLOGO, CYANLOGOSND, 22050, $200 ; PlayVideoIPS Video, Audio, AudioHz, Wait

INTROStart:
  TimerWait TM1CNT, Second4 ; Wait 4 seconds on Timer 1
  StopSoundA ; Stop Sound Channel A

PlayVideoIPS INTRO, INTROSND, 11127, $2B0 ; PlayVideoIPS Video, Audio, AudioHz, Wait

INTROSLIDESStart:
  StopSoundA ; Stop Sound Channel A
  TimerWait TM1CNT, Second2 ; Wait 2 seconds on Timer 1

PlayVideoIPS INTROSLIDES, INTROSLIDESSND, 22050, SecondHalf ; PlayVideoIPS Video, Audio, AudioHz, Wait

INTROPOINT:
  mov r0,72 ; Load Pointer X&Y Start position
  imm32 r1,POINTERX
  strb r0,[r1] ; Store Pointer X Position
  imm32 r1,POINTERY
  strb r0,[r1] ; Store Pointer Y Position

INTROClick:
  StopSoundA ; Stop Sound Channel A
  PlaySoundA INTROSLIDESSND, 22050 ; Play Sound Channel A Data
  imm16 r9,1460 ; Sound sample VBlank time
  INCVB:
    bl VBlanker

    imm32 r1,POINTERX
    ldrb r0,[r1]
    imm32 r2,POINTERY
    ldrb r1,[r2]
    cmp r1,0
    beq INTRODOWN
    IsKeyDown KEY_UP
    subeq r1,1

    INTRODOWN:
      cmp r1,144
      beq INTROLEFT
      IsKeyDown KEY_DOWN
      addeq r1,1

    INTROLEFT:
      cmp r0,0
      beq INTRORIGHT
      IsKeyDown KEY_LEFT
      subeq r0,1

    INTRORIGHT:
      cmp r0,224
      beq INTROMOVE
      IsKeyDown KEY_RIGHT
      addeq r0,1

    INTROMOVE:
      MoveOBJ 0, r0, r1 ; OBJ, X, Y
      imm32 r4,POINTERX
      strb r0,[r4]
      imm32 r4,POINTERY
      strb r1,[r4]

    imm32 r2,OAM + 4 ; Load Pointer To OAM 1st Tile Number (0x7000004)
    cmp r0,132
    blt INTROSHOWPOINT
    cmp r0,186
    bgt INTROSHOWPOINT
    cmp r1,34
    blt INTROSHOWPOINT
    cmp r1,76
    bgt INTROSHOWPOINT
    imm16 r3,544 ; Attribute 2: Tile Number 544 (Hand)
    IsKeyDown KEY_A
    beq STARTGAME
    b INTROSHOWEND

    INTROSHOWPOINT:
      mov r3,512 ; Attribute 2: Tile Number 512 (Point Up)

    INTROSHOWEND:
      str r3,[r2] ; Store Attribute 2

    subs r9,1
    bne INCVB
  StopSoundA ; Stop Sound Channel A
  b INTROClick

STARTGAME:
  StopSoundA ; Stop Sound Channel A
  imm32 r0,OAM + 4 ; Load Pointer To OAM 1st Tile Number (0x7000004)
  imm16 r1,552 ; Attribute 2: Tile Number 552 (Hand Grab)
  str r1,[r0] ; Store Attribute 2
  PlaySoundA INTROCLICKSND, 22050 ; Play Sound Channel A Data
  FadeOut Second16th
  TimerWait TM1CNT, Second3 ; Wait 3 seconds on Timer 1
  StopSoundA ; Stop Sound Channel A
  MoveOBJ 0, 0, 160 ; OBJ, X, Y

  imm32 r0,INTRO2   ; Load LZPosition
  imm32 r1,$2012C00 ; Load LZ77 GRB File Output Offset
  swi $110000	    ; Uncompress LZ77 32 Bits Bios Call

  bl GRBdecoder ; Decode GRB Data
  DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM
  FadeIn Second16th

PlayVideoLZ INTRO2, INTRO2SND, 22050, $40 ; PlayVideoLZ Video, Audio, AudioHz, Wait

MYSTStart:
  BGOAMWhiteFade ; Enable BG & OAM Fade 2 White
  FadeOut Second16th

  imm32 r0,MYST4134 ; Load LZPosition
  imm32 r1,$2012C00 ; Load LZ77 GRB File Output Offset
  swi $110000	    ; Uncompress LZ77 32 Bits Bios Call
  bl GRBdecoder ; Decode GRB Data
  DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM
  FadeIn Second16th

  StopSoundA ; Stop Sound Channel A
  imm32 r0,OAM + 4 ; Load Pointer To OAM 1st Tile Number (0x7000004)
  mov r1,512  ; Attribute 2: Tile Number 512 (Point)
  str r1,[r0] ; Store Attribute 2

  mov r0,112 ; Load Pointer X Position
  imm32 r1,POINTERX
  strb r0,[r1] ; Store Pointer X Position
  mov r0,72 ; Load Pointer Y Position
  imm32 r1,POINTERY
  strb r0,[r1] ; Store Pointer Y Position

MYST4134Start:
  UPLEFTRIGHT MYST4134, BRSEAGWA2SND, 22050, 840, MYST4143Start, MYST4138Start, MYST4140Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right

MYST4138Start:
  LEFTRIGHTBOUND MYST4138, BRSEAGWA2SND, 22050, 840, MYST4142Start, MYST4134Start, MYST4139Start, 90, 88, 136, 144 ; LZFrame, Audio, AudioHz, AudioVBLoop, Left, Right, Bound, BoundX1, BoundY1, BoundX2, BoundY2

MYST4139Start:
  imm32 r1,AUDIOVBLoop
  ldr r0,[r1]
  sub r0,45 ; Need to subtract V Blanks To Keep Audio Timed
  str r0,[r1]

  PlaySoundB DRGRAYRD2SND, 22050 ; Play Sound Channel A Data
  TimerWait TM2CNT, $3800 ; Wait On Timer 2
  StopSoundB ; Stop Sound Channel B
  UPLEFTRIGHTIPS MYST4139IPS, BRSEAGWA2SND, 22050, 840, MYST4670Start, MYST4139Left, MYST4139Right ; LZIPSFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right

  MYST4139Left:
    imm32 r0,MYST4138 ; Load LZPosition
    imm32 r1,$2012C00 ; Load LZ77 GRB File Output Offset
    swi $110000       ; Uncompress LZ77 32 Bits Bios Call
    bl GRBdecoder ; Decode GRB Data
    DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM

    imm32 r1,AUDIOVBLoop
    ldr r0,[r1]
    sub r0,45 ; Need to subtract V Blanks To Keep Audio Timed
    str r0,[r1]

    PlaySoundB DRGRAYRD2SND, 22050 ; Play Sound Channel B Data
    TimerWait TM2CNT, $3800 ; Wait On Timer 2
    StopSoundB ; Stop Sound Channel B
    b MYST4142Start

  MYST4139Right:
    imm32 r0,MYST4138 ; Load LZPosition
    imm32 r1,$2012C00 ; Load LZ77 GRB File Output Offset
    swi $110000       ; Uncompress LZ77 32 Bits Bios Call
    bl GRBdecoder ; Decode GRB Data
    DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM

    imm32 r1,AUDIOVBLoop
    ldr r0,[r1]
    sub r0,45 ; Need to subtract V Blanks To Keep Audio Timed
    str r0,[r1]

    PlaySoundB DRGRAYRD2SND, 22050 ; Play Sound Channel B Data
    TimerWait TM2CNT, $3800 ; Wait On Timer 2
    StopSoundB ; Stop Sound Channel B
    b MYST4134Start

MYST4140Start:
  LEFTRIGHT MYST4140, BRSEAGWA2SND, 22050, 840, MYST4134Start, MYST4142Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Left, Right

MYST4142Start:
  LEFTRIGHT MYST4142, BRSEAGWA2SND, 22050, 840, MYST4140Start, MYST4138Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Left, Right

MYST4143Start:
  UPLEFTRIGHTBOUND MYST4143, BRSEAGWA2SND, 22050, 840, MYST4150Start, MYST4148Start, MYST4148Start, MYST4145Start, 140, 84, 168, 104 ; LZFrame, Audio, AudioHz, AudioVBLoop, Left, Right, Bound, BoundX1, BoundY1, BoundX2, BoundY2

MYST4145Start:
  imm32 r1,AUDIOVBLoop
  ldr r0,[r1]
  sub r0,8 ; Need to subtract V Blanks To Keep Audio Timed
  str r0,[r1]

  PlaySoundB SWMARKER3SND, 22050 ; Play Sound Channel B Data
  TimerWait TM2CNT, Second8th; Wait On Timer 2
  StopSoundB ; Stop Sound Channel B
  UPLEFTRIGHTBOUNDIPS MYST4145IPS, BRSEAGWA2SND, 22050, 840, MYST4150Start, MYST4148Start, MYST4148Start, MYST4145Bound, 140, 84, 168, 104 ; LZIPSFrame, Audio, AudioHz, AudioVBLoop, Left, Right, Bound, BoundX1, BoundY1, BoundX2, BoundY2

  MYST4145Bound:
    imm32 r1,AUDIOVBLoop
    ldr r0,[r1]
    sub r0,8 ; Need to subtract V Blanks To Keep Audio Timed
    str r0,[r1]

    PlaySoundB SWMARKER3SND, 22050 ; Play Sound Channel B Data
    TimerWait TM2CNT, Second8th; Wait On Timer 2
    StopSoundB ; Stop Sound Channel B
    b MYST4143Start

MYST4148Start:
  UPLEFTRIGHT MYST4148, BRSEAGWA2SND, 22050, 840, MYST4142Start, MYST4143Start, MYST4143Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right

MYST4150Start:
  UPLEFTRIGHT MYST4150, BRSEAGWA2SND, 22050, 840, MYST4150Start, MYST4148Start, MYST4148Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right

MYST4670Start:
  UPLEFTRIGHT MYST4670, MUVAULT_1SND, 22050, 2160, MYST4676Start, MYST4671Start, MYST4671Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right

MYST4671Start:
  UPLEFTRIGHT MYST4671, MUVAULT_1SND, 22050, 2160, MYST4671Up, MYST4670Start, MYST4670Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right

  MYST4671Up:
    imm32 r0,MYST4140 ; Load LZPosition
    imm32 r1,$2012C00 ; Load LZ77 GRB File Output Offset
    swi $110000       ; Uncompress LZ77 32 Bits Bios Call
    bl GRBdecoder ; Decode GRB Data
    DMA32 WRAM, VRAM, $4B00 ; DMA32 Copy Decoded Frame Into VRAM

    StopSoundA ; Stop Sound Channel A
    PlaySoundA DRGRAYRD2SND, 22050 ; Play Sound Channel A Data
    TimerWait TM1CNT, $3000 ; Wait On Timer 1
    b MYST4140Start

MYST4676Start:
  UPLEFTRIGHT MYST4676, MUVAULT_1SND, 22050, 2160, MYST4682Start, MYST4677Start, MYST4677Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right

MYST4677Start:
  UPLEFTRIGHT MYST4677, MUVAULT_1SND, 22050, 2160, MYST4671Start, MYST4676Start, MYST4676Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right

MYST4682Start:
  UPLEFTRIGHT MYST4682, MUVAULT_1SND, 22050, 2160, MYST4688Start, MYST4683Start, MYST4683Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right

MYST4683Start:
  UPLEFTRIGHT MYST4683, MUVAULT_1SND, 22050, 2160, MYST4677Start, MYST4682Start, MYST4682Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right

MYST4688Start:
  UPLEFTRIGHT MYST4688, MUVAULT_1SND, 22050, 2160, MYST4694Start, MYST4689Start, MYST4689Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right

MYST4689Start:
  UPLEFTRIGHT MYST4689, MUVAULT_1SND, 22050, 2160, MYST4683Start, MYST4688Start, MYST4688Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right

MYST4694Start:
  UPLEFTRIGHT MYST4694, MUVAULT_1SND, 22050, 2160, MYST4694Start, MYST4695Start, MYST4695Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right

MYST4695Start:
  UPLEFTRIGHT MYST4695, MUVAULT_1SND, 22050, 2160, MYST4689Start, MYST4694Start, MYST4694Start ; LZFrame, Audio, AudioHz, AudioVBLoop, Up, Left, Right


VBlanker:
  VBlank
  bx lr

IPSdecoder:
  IPSdecode
  bx lr

GRBdecoder:
  GRBdecode
  bx lr

IPSWRAMPos: ; IPS WRAM End Of File Offset
dw 0
LZPosition: ; LZ77 ROM End Of File Offset
dw 0

AUDIOVBLoop: ; Audio VBlank Loop Counter
dw 0
AUDIOOffset: ; Audio Sample Offset
dw 0

POINTERX: ; Pointer X Position
db 0
POINTERY: ; Pointer Y Position
db 0

endcopy:

org $80000C0 + (endcopy - start) + (startcode - copycode)
align 4
POINTERPAL:
file 'DATA\POINTER.pal'
POINTER:
file 'DATA\POINTER.bin'

align 4
CYANLOGO:
file 'DATA\INTRO\CYANLOGO.lz'
CYANLOGOSND:
file 'DATA\INTRO\CYANLOGO.snd'

align 4
INTRO:
file 'DATA\INTRO\INTRO.lz'
INTROSND:
file 'DATA\INTRO\INTRO.snd'

align 4
INTROSLIDES:
file 'DATA\INTRO\INTROSLIDES.lz'
INTROSLIDESSND:
file 'DATA\INTRO\INTROSLIDES.snd'

align 4
INTROCLICKSND:
file 'DATA\INTRO\INTROCLICK.snd'

align 4
INTRO2:
file 'DATA\INTRO\INTRO2.lz'
INTRO2SND:
file 'DATA\INTRO\INTRO2.snd'

align 4
MYST4134:
file 'DATA\MYST\MYST4134.lz'
MYST4138:
file 'DATA\MYST\MYST4138.lz'
MYST4139IPS:
file 'DATA\MYST\MYST4139IPS.lz'
MYST4140:
file 'DATA\MYST\MYST4140.lz'
MYST4142:
file 'DATA\MYST\MYST4142.lz'
MYST4143:
file 'DATA\MYST\MYST4143.lz'
MYST4145IPS:
file 'DATA\MYST\MYST4145IPS.lz'
MYST4148:
file 'DATA\MYST\MYST4148.lz'
MYST4150:
file 'DATA\MYST\MYST4150.lz'
;MYST4667:
;file 'DATA\MYST\MYST4667.lz'
MYST4670:
file 'DATA\MYST\MYST4670.lz'
MYST4671:
file 'DATA\MYST\MYST4671.lz'
MYST4676:
file 'DATA\MYST\MYST4676.lz'
MYST4677:
file 'DATA\MYST\MYST4677.lz'
MYST4682:
file 'DATA\MYST\MYST4682.lz'
MYST4683:
file 'DATA\MYST\MYST4683.lz'
MYST4688:
file 'DATA\MYST\MYST4688.lz'
MYST4689:
file 'DATA\MYST\MYST4689.lz'
MYST4694:
file 'DATA\MYST\MYST4694.lz'
MYST4695:
file 'DATA\MYST\MYST4695.lz'

align 4
BRSEAGWA2SND:
file 'DATA\MYST\brseagwa2.snd'

align 4
DRGRAYRD2SND:
file 'DATA\MYST\drgrayrd2.snd'

align 4
MUVAULT_1SND:
file 'DATA\MYST\muvault_1.snd'

align 4
SWMARKER3SND:
file 'DATA\MYST\swmarker3.snd'