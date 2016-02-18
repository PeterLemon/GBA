; GBA 'Bare Metal' Nintendo Game Boy Emulator by krom (Peter Lemon):

format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\LCD.INC'
include 'LIB\SOUND.INC'
include 'LIB\MEM.INC'
include 'LIB\DMA.INC'
include 'MEM.INC'

; F Register (CPU Flag Register ZNHC0000 Low 4 Bits Always Zero)
C_FLAG = $10 ; F Register Bit 4 Carry Flag
H_FLAG = $20 ; F Register Bit 5 Half Carry Flag
N_FLAG = $40 ; F Register Bit 6 Negative Flag
Z_FLAG = $80 ; F Register Bit 7 Zero Flag

org $8000000
b copycode
times $80000C0-($-0) db 0

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
org WRAM

start:
mov r0,IO
mov r1,MODE_0
orr r1,BG0_ENABLE
str r1,[r0] ; Set Mode 0, Enable BG0

; Setup CPU Registers
mov r0,0 ; R0 = 16-Bit Register AF (Bits 0..7 = F, Bits 8..15 = A)
mov r1,0 ; R1 = 16-Bit Register BC (Bits 0..7 = C, Bits 8..15 = B)
mov r2,0 ; R2 = 16-Bit Register DE (Bits 0..7 = E, Bits 8..15 = D)
mov r3,0 ; R3 = 16-Bit Register HL (Bits 0..7 = L, Bits 8..15 = H)
mov r4,0 ; R4 = 16-Bit Register PC (Program Counter)
mov sp,0 ; SP = 16-Bit Register SP (Stack Pointer)

DMA32 GB_CART, MEM_MAP, 8192 ; Copy 32768 Bytes Cartridge ROM To Memory Map
DMA32 GB_BIOS, MEM_MAP, 64   ; Copy 256 Bytes BIOS ROM To Memory Map

;mov r8,0 ; Debug Instruction Count
Refresh: ; Refresh At 60 Hz
  mov r12,0 ; R12 = Reset QCycles
  imm16 r11,$4444 ; 4194304 Hz / 60 Hz = 69905 CPU Cycles / 4 = 17476 Quad Cycles
  imm32 r10,MEM_MAP ; R10 = MEM_MAP
  imm32 r9,CPU_INST ; R9 = CPU Instruction Table

  CPU_EMU:
    ldrb r5,[r10,r4] ; R5 = CPU Instruction
    add r5,r9,r5,lsl 8 ; R5 = CPU Instruction Table Opcode
    add r4,1 ; PC_REG++
    mov lr,pc
    bx r5

    include 'IOPORT.asm' ; Run IO Port
    cmp r12,r11 ; Compare Quad Cycles Counter
    blt CPU_EMU

  include 'VIDEO.asm' ; Run Video
  b Refresh

align 256
CPU_INST:
  include 'CPU.asm' ; CPU Instruction Table

LCDQCycles: dw 0 ; LCD Quad Cycle Count
DIVQCycles: dw 0 ; Divider Register Quad Cycle Count
OldQCycles: dw 0 ; Previous Quad Cycle Count
OldMode: dw 0 ; Previous LCD STAT Mode
OldTAC_REG: dw 4 ; Previous TAC_REG (4096Hz)
TimerQCycles: dw 0 ; Timer Quad Cycles
IME_FLAG: dw 0 ; (IME) Interrupt Master Enable Flag (0 = Disable Interrupts, 1 = Enable Interrupts, Enabled In IE Register)
MEM_MAP: ; Memory Map = $10000 Bytes

endcopy:
org $80000C0 + (endcopy - start) + (startcode - copycode)
GB_BIOS: file 'DMG_ROM.bin' ; Include Game Boy DMG BIOS ROM 

;GB_CART: file 'ROMS\Soukoban (J).gb'
;GB_CART: file 'ROMS\Tetris (W) (V1.1) [!].gb'
;GB_CART: file 'ROMS\Alleyway (W) [!].gb'
;GB_CART: file 'ROMS\Renju Club (J) [S].gb'
;GB_CART: file 'ROMS\Hon Shougi (J) [S].gb'

;GB_CART: file 'ROMS\HelloWorld.gb'

GB_CART: file 'ROMS\01-special.gb' ; PASSED
;GB_CART: file 'ROMS\02-interrupts.gb' ; PASSED
;GB_CART: file 'ROMS\03-op sp,hl.gb' ; PASSED
;GB_CART: file 'ROMS\04-op r,imm.gb' ; PASSED
;GB_CART: file 'ROMS\05-op rp.gb' ; PASSED
;GB_CART: file 'ROMS\06-ld r,r.gb' ; PASSED
;GB_CART: file 'ROMS\07-jr,jp,call,ret,rst.gb' ; PASSED
;GB_CART: file 'ROMS\08-misc instrs.gb' ; PASSED
;GB_CART: file 'ROMS\09-op r,r.gb' ; PASSED
;GB_CART: file 'ROMS\10-bit ops.gb' ; PASSED
;GB_CART: file 'ROMS\11-op a,(hl).gb' ; PASSED
;GB_CART: file 'ROMS\instr_timing.gb' ; PASSED