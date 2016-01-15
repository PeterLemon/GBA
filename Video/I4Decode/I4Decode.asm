; Game Boy Advance 'Bare Metal' I4-Bit Decode Frame Demo by krom (Peter Lemon):

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

I4Decode:
  mov r0,VRAM ; R0 = VRAM Offset
  imm32 r1,I4 ; R1 = I4 Offset
  mov r2,4800 ; R2 = Block Count

  I4Loop: ;
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
    bne I4Loop ; IF (Block Count != 0) Loop I4 Blocks

Loop:
  b Loop

I4:
file 'frame.i4'