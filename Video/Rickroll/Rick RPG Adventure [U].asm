; GBA 'Bare Metal' GRB 12-Bit LZ Compressed Video Decode Demo by krom (Peter Lemon):

format binary as 'gba'
org $8000000
include 'LIB\FASMARM.INC' ; Include FASMARM Macros
include 'LIB\GBA.INC' ; Include GBA Definitions
include 'LIB\GBA_DMA.INC' ; Include GBA DMA Macros
include 'LIB\GBA_LCD.INC' ; Include GBA LCD Macros
include 'LIB\GBA_SOUND.INC' ; Include GBA Sound Macros
include 'LIB\GBA_TIMER.INC' ; Include GBA Timer Macros
include 'LIB\GBA_HEADER.ASM' ; Include GBA Header & ROM Entry Point

macro GRBDecode { ; Decode GRB Frame
  local .GRBLoop
  mov r0,VRAM ; R0 = VRAM Offset
  mov r1,WRAM ; R1 = G Offset
  add r2,r1,240 * 160 / 2 ; R2 = R Offset
  add r3,r2,240 * 160 / 8 ; R3 = B Offset

  mov r4,240 * 160 / 16 ; R4 = Block Count
  mov r5,30 ; R5 = End Of Blue Scanline Counter (240 / 8 = 30)

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
    ldrb r8,[r1],120 ; Load G Byte
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
    ldrb r8,[r1],-119 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],-r9 ; Store Decoded GRB Pixel Into VRAM

    ; 2nd 2x2 Block (4 Pixels)
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    ldrb r7,[r2],60 ; Load R Byte
    and r7,$F
    orr r12,r7,lsl 1 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],120 ; Load G Byte
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
    ldrb r8,[r1],119 ; Load G Byte
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
    ldrb r8,[r1],120 ; Load G Byte
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
    ldrb r8,[r1],-119 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],-r9 ; Store Decoded GRB Pixel Into VRAM

    ; 4th 2x2 Block (4 Pixels)
    mov r12,r6,lsl 7 ; Pack B Pixel
    and r12,$F800
    ldrb r7,[r2],-59 ; Load R Byte
    and r7,$F
    orr r12,r7,lsl 1 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],120 ; Load G Byte
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
    ldrb r8,[r1],-359 ; Load G Byte
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
    ldrb r8,[r1],120 ; Load G Byte
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
    ldrb r8,[r1],-119 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],-r9 ; Store Decoded GRB Pixel Into VRAM

    ; 2nd 2x2 Block (4 Pixels)
    mov r12,r6,lsl 11 ; Pack B Pixel
    ldrb r7,[r2],60 ; Load R Byte
    and r7,$F
    orr r12,r7,lsl 1 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],120 ; Load G Byte
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
    ldrb r8,[r1],119 ; Load G Byte
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
    ldrb r8,[r1],120 ; Load G Byte
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
    ldrb r8,[r1],-119 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],-r9 ; Store Decoded GRB Pixel Into VRAM

    ; 4th 2x2 Block (4 Pixels)
    subs r5,1 ; Decrement End Of Blue Scanline Counter
    moveq r5,30 ; End Of Blue Scanline
    mov r12,r6,lsl 11 ; Pack B Pixel
    ldrbeq r7,[r2],1 ; Load R Byte End Of Blue Scanline
    ldrbne r7,[r2],-59 ; Load R Byte
    and r7,$F
    orr r12,r7,lsl 1 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1] ; Load G Byte
    lsr r8,4
    orr r12,r8,lsl 6 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],120 ; Load G Byte
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
    ldrbne r8,[r1],-359 ; Load G Byte
    and r8,$F
    mov r12,r6,lsl 11 ; Pack B Pixel
    orr r12,r7,lsl 1 ; Pack R Pixel
    orr r12,r8,lsl 6 ; Pack G Pixel
    strheq r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM End Of Blue Scanline
    strhne r12,[r0],-r11 ; Store Decoded GRB Pixel Into VRAM

    subs r4,2 ; Block Count -= 2
    bne .GRBLoop ; IF (Block Count != 0) Loop GRB Blocks
}

copycode:
  adr r0,startcode
  mov r1,IWRAM
  imm32 r2,endcopy
  clp:
    ldr r3,[r0],4
    str r3,[r1],4
    cmp r1,r2
    bmi clp
  imm32 r0,start
  bx r0
startcode:
  org IWRAM

start:
  mov r0,IO
  mov r1,MODE_3
  orr r1,BG2_ENABLE
  str r1,[r0]

  imm32 r0,video ; R0 = LZ Compressed Data Offset
  str r0,[LZOffset] ; Store LZ Compressed Data Offset Into LZ Offset

  PlaySoundA audio, 8078 ; Play Sound Channel A Data
LoopFrames:
  ; Start Timer
  mov r11,IO ; GBA I/O Base Offset
  orr r11,TM1CNT ; Timer Control Register
  mov r12,TM_ENABLE or TM_FREQ_1024 ; Timer Enable, Frequency/1024
  str r12,[r11] ; Start Timer

  ldr r0,[LZOffset] ; R0 = LZ Offset
  add r0,4 ; LZ Offset += 4
  mov r1,WRAM ; R1 = LZ GRB File Output Offset
  imm32 r2,WRAM + 25200 ; R2 = Destination End Offset
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

  str r0,[LZOffset] ; Store Last LZ GRB Frame End Offset To LZ Offset

  ; Wait For Timer
  mov r11,IO ; GBA I/O Base Offset
  orr r11,TM1CNT ; Timer Control Register
  imm16 r10,$240 ; R10 = Time
  WaitTimer:
    ldrh r12,[r11] ; Current Timer Position
    cmp r12,r10 ; Compare Time
    blt WaitTimer
  mov r12,TM_DISABLE
  str r12,[r11] ; Reset Timer Control

  GRBDecode ; Decode GRB Data

  imm32 r1,LZOffset
  ldr r0,[r1] ; Load Last LZ IPS Frame End Offset
  imm32 r1,audio ; Load Video End Offset
  cmp r0,r1 ; Check Video End Offset
  bne LoopFrames ; Decode Next Frame
  StopSoundA ; Stop Sound Channel A
  b start ; Restart Video

LZOffset: ; LZ ROM End Of File Offset
dw 0

endcopy:

; Static Data (ROM)
org startcode + (endcopy - start)
video:
file 'video.lz'
audio:
file 'audio.snd'