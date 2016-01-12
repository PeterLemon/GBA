; Game Boy Advance 'Bare Metal' GRB 12-Bit Decode Frame Demo by krom (Peter Lemon):
format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\MEM.INC'
include 'LIB\LCD.INC'
org $8000000
b start
times $80000C0-($-0) db 0

start:
  mov r0,IO
  mov r1,MODE_3
  orr r1,BG2_ENABLE
  str r1,[r0]

decodeGRB:
  mov r0,VRAM ; R0 = VRAM Offset
  imm32 r1,grb ; R1 = G Offset
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

  decodeGRBLoop: ; Loop 4x4 Block (16 pixels)
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
    bne decodeGRBLoop ; IF (Block Count != 0) Loop GRB Blocks

Loop:
  b Loop

grb:
file 'frame.grb'