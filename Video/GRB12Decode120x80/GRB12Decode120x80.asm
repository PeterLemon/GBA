; Game Boy Advance 'Bare Metal' GRB 12-Bit Decode 120x80 Frame Demo by krom (Peter Lemon):

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

  ; Zoom 120x80 Screen To Fill Full Screen (200%)
  imm32 r0,BGAffineSource ; R0 = Address Of Parameter Table
  mov r1,IO ; GBA I/O Base Offset
  orr r1,BG2PA ; Update BG Parameters
  mov r2,1 ; (BIOS Call Requires R0 To Point To Parameter Table)
  swi $0E0000 ; Bios Call To Calculate All The Correct BG Parameters

GRBDecode:
  mov r0,VRAM ; R0 = VRAM Offset
  imm32 r1,grb ; R1 = G Offset
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

  GRBLoop: ; Loop 4x4 Block (16 pixels)
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
    bne GRBLoop ; IF (Block Count != 0) Loop GRB Blocks

Loop:
  b Loop

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

grb:
file 'frame.grb'