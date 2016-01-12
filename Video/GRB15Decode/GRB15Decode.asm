; Game Boy Advance 'Bare Metal' GRB 15-Bit Decode Frame Demo by krom (Peter Lemon):
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
  add r2,r1,240 * 160 ; R2 = R Offset
  add r3,r2,240 * 160 / 4 ; R3 = B Offset

  mov r4,240 * 160 / 16 ; R4 = Block Count
  mov r5,60 ; R5 = End Of Blue Scanline Counter (240 / 4 = 60)

  mov r9,239 ; R9 = 478
  lsl r9,1
  mov r10,237 ; R10 = 474
  lsl r10,1
  mov r11,1440 ; R11 = 1438
  sub r11,2

  decodeGRBLoop: ; Loop 4x4 Block (16 pixels)
    ldrb r6,[r3],1 ; Load B Byte
    mov r12,r6,lsl 10 ; Pack B Pixel

    ; 1st 2x2 Block (4 Pixels)
    ldrb r7,[r2],1 ; Load R Byte
    orr r12,r7 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1],1 ; Load G Byte
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],r9,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7 ; Pack R Pixel
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],r9 ; Store Decoded GRB Pixel Into VRAM
    ; 3rd Pixel
    ldrb r8,[r1],1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7 ; Pack R Pixel
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 4th Pixel
    ldrb r8,[r1],-r9,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7 ; Pack R Pixel
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],-r9 ; Store Decoded GRB Pixel Into VRAM

    ; 2nd 2x2 Block (4 Pixels)
    mov r12,r6,lsl 10 ; Pack B Pixel
    ldrb r7,[r2],119 ; Load R Byte
    orr r12,r7 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1],1 ; Load G Byte
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],r9,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7 ; Pack R Pixel
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],r9 ; Store Decoded GRB Pixel Into VRAM
    ; 3rd Pixel
    ldrb r8,[r1],1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7 ; Pack R Pixel
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 4th Pixel
    ldrb r8,[r1],r10,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7 ; Pack R Pixel
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],r10 ; Store Decoded GRB Pixel Into VRAM

    ; 3rd 2x2 Block (4 Pixels)
    mov r12,r6,lsl 10 ; Pack B Pixel
    ldrb r7,[r2],1 ; Load R Byte
    orr r12,r7 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1],1 ; Load G Byte
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],r9,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7 ; Pack R Pixel
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],r9 ; Store Decoded GRB Pixel Into VRAM
    ; 3rd Pixel
    ldrb r8,[r1],1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7 ; Pack R Pixel
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 4th Pixel
    ldrb r8,[r1],-r9,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7 ; Pack R Pixel
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],-r9 ; Store Decoded GRB Pixel Into VRAM

    ; 4th 2x2 Block (4 Pixels)
    subs r5,1 ; Decrement End Of Blue Scanline Counter
    moveq r5,60 ; End Of Blue Scanline
    mov r12,r6,lsl 10 ; Pack B Pixel
    ldrbeq r7,[r2],1 ; Load R Byte End Of Blue Scanline
    ldrbne r7,[r2],-119 ; Load R Byte
    orr r12,r7 ; Pack R Pixel
    ; 1st Pixel
    ldrb r8,[r1],1 ; Load G Byte
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 2nd Pixel
    ldrb r8,[r1],r9,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7 ; Pack R Pixel
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],r9 ; Store Decoded GRB Pixel Into VRAM
    ; 3rd Pixel
    ldrb r8,[r1],1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7 ; Pack R Pixel
    orr r12,r8,lsl 5 ; Pack G Pixel
    strh r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM
    ; 4th Pixel
    ldrbeq r8,[r1],1 ; Load G Byte End Of Blue Scanline
    ldrbne r8,[r1],-r11,lsr 1 ; Load G Byte
    mov r12,r6,lsl 10 ; Pack B Pixel
    orr r12,r7 ; Pack R Pixel
    orr r12,r8,lsl 5 ; Pack G Pixel
    strheq r12,[r0],2 ; Store Decoded GRB Pixel Into VRAM End Of Blue Scanline
    strhne r12,[r0],-r11 ; Store Decoded GRB Pixel Into VRAM

    subs r4,1 ; Block Count--
    bne decodeGRBLoop ; IF (Block Count != 0) Loop GRB Blocks

Loop:
  b Loop

grb:
file 'frame.grb'