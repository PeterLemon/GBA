; GBA 'Bare Metal' GRB 12-Bit LZSS DIFF RLE Video Decode 120x80 30FPS Demo by krom (Peter Lemon):

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

macro RLEDecode { ; Decode RLE DIFF Data
  local .RLELoop, .RLECopy, .RLEDecode, .RLEDecodeByte, .RLEEOF
  imm32 r0,WRAM + 6300 + 4 ; R0 = RLE Source Offset + 4
  mov r1,WRAM ; R1 = Destination Address (WRAM Start Offset)
  imm32 r2,WRAM + 6300 ; R2 = Destination End Offset (WRAM End Offset)

  .RLELoop:
    cmp r1,r2 ; Compare Destination Address To Destination End Offset
    beq .RLEEOF ; IF (Destination Address == Destination End Offset) RLEEOF

    ldrb r3,[r0],1 ; R3 = RLE Flag Data (Bit 0..6 = Expanded Data Length: Uncompressed N-1, Compressed N-3, Bit 7 = Flag: 0 = Uncompressed, 1 = Compressed)
    ands r4,r3,10000000b ; R4 = RLE Flag
    and r3,01111111b ; R3 = Expanded Data Length
    add r3,1 ; Expanded Data Length++
    bne .RLEDecode ; IF (BlockType != 0) RLE Decode Bytes

    .RLECopy: ; ELSE Copy Uncompressed Bytes
      ldrsb r4,[r0],1 ; R4 = Difference Signed Byte, RLE Offset++
      ldrsb r5,[r1] ; R5 = Source Data Byte
      add r5,r4 ; Add Signed Byte (R4) To Data Byte (R5)
      strb r5,[r1],1 ; Store Uncompressed Byte To Destination, Destination Address++
      subs r3,1 ; Expanded Data Length--
      bne .RLECopy ; IF (Expanded Data Length != 0) RLECopy
      b .RLELoop

    .RLEDecode:
      add r3,2 ; Expanded Data Length += 2
      ldrsb r4,[r0],1 ; R4 = Difference Signed Byte, RLE Offset++
      cmp r4,0 ; Compare Difference Signed Byte To 0
      bne .RLEDecodeByte ; IF (Difference Signed Byte != 0) RLEDecodeByte
      add r1,r3 ; ELSE Skip RLEDecodeByte, Add Expanded Data Length (R3) To WRAM Offset
      b .RLELoop

      .RLEDecodeByte:
        ldrsb r5,[r1] ; R5 = Source Data Byte
        add r5,r4 ; Add Signed Byte (R4) To Data Byte (R5)
        strb r5,[r1],1 ; Store Uncompressed Byte To Destination, Destination Address++
        subs r3,1 ; Expanded Data Length--
        bne .RLEDecodeByte ; IF (Expanded Data Length != 0) RLEDecodeByte
        b .RLELoop
    .RLEEOF:
}

macro GRBDecode { ; Decode GRB Frame
  local .GRBLoop
  mov r0,VRAM ; R0 = VRAM Offset
  mov r1,WRAM ; R1 = G Offset
  add r2,r1,120 * 80 / 2 ; R2 = R Offset
  add r3,r2,120 * 80 / 8 ; R3 = B Offset

  mov r4,120 * 80 / 32 ; R4 = Block Count
  mov r5,15 ; R5 = End Of Blue Scanline Counter (120 / 8 = 15)

  mov r9,239 ; R9 = 478
  lsl r9,1
  mov r10,237 ; R10 = 474
  lsl r10,1
  mov r11,1440 ; R11 = 1438
  sub r11,2

  .GRBLoop: ; Loop 4x4 Block (16 pixels)
  ; Hi 4-Bit
    ldrb r6,[r3],1 ; Load B Byte
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800

    ; 1st 2x2 Block (4 Pixels)
    ldrb r7,[r2] ; Load R Byte
    lsr r7,4
    orr r12,r7,lsl 1 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],60 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],r9 ; Store Decoded GRB Pixel Into VRAM
    ; 3rd Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 4th Pixel
    ldrb r8,[r1],-59 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],-r9 ; Store Decoded GRB Pixel Into VRAM

    ; 2nd 2x2 Block (4 Pixels)
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    ldrb r7,[r2],30 ; Load R Byte
    and r7,$F
    orr r12,r7,lsl 1 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],60 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],r9 ; Store Decoded GRB Pixel Into VRAM
    ; 3rd Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 4th Pixel
    ldrb r8,[r1],59 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],r10 ; Store Decoded GRB Pixel Into VRAM

    ; 3rd 2x2 Block (4 Pixels)
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    ldrb r7,[r2] ; Load R Byte
    lsr r7,4
    orr r12,r7,lsl 1 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],60 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],r9 ; Store Decoded GRB Pixel Into VRAM
    ; 3rd Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 4th Pixel
    ldrb r8,[r1],-59 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],-r9 ; Store Decoded GRB Pixel Into VRAM

    ; 4th 2x2 Block (4 Pixels)
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    ldrb r7,[r2],-29 ; Load R Byte
    and r7,$F
    orr r12,r7,lsl 1 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],60 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],r9 ; Store Decoded GRB Pixel Into VRAM
    ; 3rd Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 4th Pixel
    ldrb r8,[r1],-179 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],-r11 ; Store Decoded GRB Pixel Into VRAM


  ; LO 4-Bit
    mov r12,r6,lsl 11 ; Pack B Pixel

    ; 1st 2x2 Block (4 Pixels)
    ldrb r7,[r2] ; Load R Byte
    lsr r7,4
    orr r12,r7,lsl 1 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],60 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],r9 ; Store Decoded GRB Pixel Into VRAM
    ; 3rd Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 4th Pixel
    ldrb r8,[r1],-59 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],-r9 ; Store Decoded GRB Pixel Into VRAM

    ; 2nd 2x2 Block (4 Pixels)
    mov r12,r6,lsl 11 ; Pack B Pixel
    ldrb r7,[r2],30 ; Load R Byte
    and r7,$F
    orr r12,r7,lsl 1 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],60 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],r9 ; Store Decoded GRB Pixel Into VRAM
    ; 3rd Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 4th Pixel
    ldrb r8,[r1],59 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],r10 ; Store Decoded GRB Pixel Into VRAM

    ; 3rd 2x2 Block (4 Pixels)
    mov r12,r6,lsl 11 ; Pack B Pixel
    ldrb r7,[r2] ; Load R Byte
    lsr r7,4
    orr r12,r7,lsl 1 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],60 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],r9 ; Store Decoded GRB Pixel Into VRAM
    ; 3rd Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 4th Pixel
    ldrb r8,[r1],-59 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],-r9 ; Store Decoded GRB Pixel Into VRAM

    ; 4th 2x2 Block (4 Pixels)
    subs r5,1 ; Decrement End Of Blue Scanline Counter
    moveq r5,15 ; End Of Blue Scanline
    mov r12,r6,lsl 11 ; Pack B Pixel
    ldrbeq r7,[r2],1 ; Load R Byte End Of Blue Scanline
    ldrbne r7,[r2],-29 ; Load R Byte
    and r7,$F
    orr r12,r7,lsl 1 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],60 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],r9 ; Store Decoded GRB Pixel Into VRAM
    ; 3rd Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 4th Pixel
    ldrbeq r8,[r1],1 ; Load G Byte End Of Blue Scanline
    ldrbne r8,[r1],-179 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strheq r12,[r0],242 ; Store Decoded GRB Pixel Into VRAM End Of Blue Scanline
    strhne r12,[r0],-r11 ; Store Decoded GRB Pixel Into VRAM

    subs r4,1 ; Block Count--
    bne .GRBLoop ; IF (Block Count != 0) Loop GRB Blocks
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

  ; Clear GRB Frame
  mov r0,WRAM
  imm16 r1,6300/4
  mov r2,0
  ClearGRB:
    str r2,[r0],4
    subs r1,1
    bne ClearGRB

  ; Zoom 120x80 Screen To Fill Full Screen (200%)
  imm32 r0,BGAffineSource ; R0 = Address Of Parameter Table
  mov r1,IO ; GBA I/O Base Offset
  orr r1,BG2PA ; Update BG Parameters
  mov r2,1 ; (BIOS Call Requires R0 To Point To Parameter Table)
  swi $0E0000 ; Bios Call To Calculate All The Correct BG Parameters

  imm32 r0,VIDEO ; R0 = LZ Compressed Data Offset
  str r0,[LZOffset] ; Store LZ Compressed Data Offset Into LZ Offset

  PlaySoundA SOUND, 8600 ; Play Sound Channel A Data
LoopFrames:
  ; Start Timer
  mov r11,IO ; GBA I/O Base Offset
  orr r11,TM1CNT ; Timer Control Register
  mov r12,TM_ENABLE or TM_FREQ_1024 ; Timer Enable, Frequency/1024
  str r12,[r11] ; Start Timer

  ldr r0,[LZOffset] ; R0 = LZ Offset
  imm32 r1,WRAM + 6300 ; R1 = Destination Offset
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

  str r0,[LZOffset] ; Store Last LZ Frame End Offset To LZ Offset

  RLEDecode ; Decode RLE DIFF Data To WRAM

  ; Wait For Timer
  mov r11,IO ; GBA I/O Base Offset
  orr r11,TM1CNT ; Timer Control Register
  imm16 r10,$1A2 ; R10 = Time
  ldr r12,[TimerOverflow]
  sub r10,r12
  WaitTimer:
    ldrh r12,[r11] ; Current Timer Position
    cmp r12,r10 ; Compare Time
    blt WaitTimer
  sub r12,r10
  str r12,[TimerOverflow]
  mov r12,TM_DISABLE
  str r12,[r11] ; Reset Timer Control

  GRBDecode ; Decode GRB Data To VRAM

  ldr r0,[LZOffset] ; Load Last LZ Frame End Offset
  imm32 r1,SOUND ; Load Video End Offset
  cmp r0,r1 ; Check Video End Offset
  bne LoopFrames ; Decode Next Frame
  StopSoundA ; Stop Sound Channel A
  b start ; Restart Video

LZOffset: ; LZ ROM End Of File Offset
dw 0
TimerOverflow: ; Timer Overflow
dw 0

endcopy:

org $80000C0 + (endcopy - start) + (startcode - copycode)
align 4
BGAffineSource: ; Memory Area Used To Set BG Affine Transformations Using BIOS Call
  ; Center Of Rotation In Original Image (Last 8-Bits Fractional)
  dw $00000000 ; X
  dw $00000000 ; Y
  ; Center Of Rotation On Screen
  dh $0000 ; X
  dh $0000 ; Y
  ; Scaling Ratios (Last 8-Bits Fractional)
  dh $0080 ; X
  dh $0080 ; Y
  ; Angle Of Rotation ($0000..$FFFF Anti-Clockwise)
  dh $0000
  ; Mosaic Amount
  dh $0000

VIDEO:
file 'video.lz'
SOUND:
file 'audio.snd'