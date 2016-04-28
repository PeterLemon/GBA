; GBA 'Bare Metal' Sound 8-Bit Compressed BRR Mono Single Shot DMA Playback Demo by krom (Peter Lemon):
format binary as 'gba'
include 'LIB\FASMARM.INC'
include 'LIB\MEM.INC'
include 'LIB\DMA.INC'
include 'LIB\SOUND.INC'
include 'LIB\TIMER.INC'
org $8000000
b copycode
times $80000C0-($-0) db 0

copycode:
  adr r1,startcode
  mov r2,IWRAM
  imm32 r3,endcopy
  clp:
    ldr r0,[r1],4
    str r0,[r2],4
    cmp r2,r3
    bmi clp
  imm32 r2,start
  bx r2
startcode:
  org IWRAM

start:
  ; Decode BRR Sound Sample
  imm32 r0,SOUND ; R0 = Sample Address
  imm32 r1,SOUNDEND ; R1 = Sample End Address
  mov r2,WRAM ; R2 = Decode Sample Address
  mov r3,0 ; R3 = New Sample (Current Sample)
  mov r4,0 ; R4 = Old Sample (Last Sample)
  mov r5,0 ; R5 = Older Sample (Previous To Last Sample)
  BRRBlockDecode: ; Decode 9 Byte Block, Byte 0 = Block Header
    ldrb r6,[r0],1 ; R6 = BRR Block Header, Sample Address++
    lsr r7,r6,4 ; R7 = Shift Amount (Bits 4..7)
    lsr r6,2
    and r6,3 ; R6 = Filter Number (Bits 2..3)

    mov r8,8 ; R8 = Sample Counter
    BRRSampleDecode: ; Next 8 Bytes Contain 2 Signed 4-Bit Sample Nibbles Each (-8..+7) (Sample 1 = Bits 4..7 & Sample 2 = Bits 0..3)
      ldrb r9,[r0],1 ; R9  = Sample Byte, Sample Address++
      and r10,r9,$F  ; R10 = Sample 2 Unsigned Nibble
      lsr r9,4	     ; R9  = Sample 1 Unsigned Nibble

      cmp r9,7	; IF (Sample 1 > 7) Sample 1 -= 16 (Convert Sample 1 To Signed Nibble)
      subgt r9,16
      cmp r10,7 ; IF (Sample 2 > 7) Sample 2 -= 16 (Convert Sample 2 To Signed Nibble)
      subgt r10,16

      ; Shift Samples
      cmp r7,12 ; IF (Shift Amount > 12) Use Default Shift For Reserved Shift Amount (13..15)
      ble SampleShift
      lsl r9,12  ; Sample 1 SHL 12
      asr r9,3	 ; Sample 1 SAR 3
      lsl r10,12 ; Sample 2 SHL 12
      asr r10,3  ; Sample 2 SAR 3
      b ShiftEnd
      SampleShift: ; ELSE Apply Shift Amount To Samples
      lsl r9,r7  ; Sample 1 SHL Shift Amount
      asr r9,1	 ; Sample 1 SAR 1
      lsl r10,r7 ; Sample 2 SHL Shift Amount
      asr r10,1  ; Sample 2 SAR 1
      ShiftEnd:

      ; Filter Samples
      ; Sample 1 Filter 0
      mov r3,r9 ; Filter 0: New Sample = Sample 1
      cmp r6,0 ; Compare Filter Number To 0
      beq S1FilterEnd ; IF (Filter Number == 0) GOTO Sample 1 Filter End

      ; Sample 1 Filter 1
      cmp r6,1 ; Compare Filter Number To 1
      bne S1Filter2 ; IF (Filter Number != 1) GOTO Sample 1 Filter 2
      add r3,r4 ; Filter 1: New Sample += Old Sample + (-Old Sample SAR 4)
      asr r11,r4,4 ; R11 = Old Sample SAR 4
      neg r11 ; R11 = -Old Sample SAR 4
      add r3,r11 ; New Sample = Filter 1
      b S1FilterEnd

      S1Filter2: ; Sample 1 Filter 2
      cmp r6,2 ; Compare Filter Number To 2
      bne S1Filter3 ; IF (Filter Number != 2) GOTO Sample 1 Filter 3
      add r3,r4,lsl 1 ; Filter 2: New Sample += (Old Sample SHL 1) + ((-Old Sample * 3) SAR 5) - Older Sample + (Older Sample SAR 4)
      add r11,r4,r4,lsl 1 ; R11 = Old Sample * 3
      neg r11 ; R11 = -Old Sample * 3
      add r3,r11,asr 5 ; New Sample += (-Old Sample * 3) SAR 5
      sub r3,r5 ; New Sample -= Older Sample
      add r3,r5,asr 4 ; New Sample = Filter 2
      b S1FilterEnd

      S1Filter3: ; Sample 1 Filter 3
      add r3,r4,lsl 1 ; Filter 3: New Sample += (Old Sample SHL 1) + ((-Old Sample * 13) SAR 6) - Older Sample + ((Older Sample * 3) SAR 4)
      neg r11,r4 ; R11 = -Old Sample
      mov r12,13 ; R12 = 13
      mul r11,r12 ; R11 = -Old Sample * 13
      add r3,r11,asr 6 ; New Sample += (-Old Sample * 13) SAR 6
      sub r3,r5 ; New Sample -= Older Sample
      lsl r11,r5,1
      add r11,r5 ; R11 = Older Sample * 3
      add r3,r11,asr 4 ; New Sample = Filter 3

      S1FilterEnd:
      mov r5,r4 ; Older Sample = Old Sample
      mov r4,r3 ; Old Sample = New Sample
      asr r11,r3,8 ; Convert 16-bit Signed Sample to 8-Bit Signed Sample
      strb r11,[r2],1 ; Store Decoded Sample 1, Decode Sample Address++


      ; Sample 2 Filter 0
      mov r3,r10 ; Filter 0: New Sample = Sample 2
      cmp r6,0 ; Compare Filter Number To 0
      beq S2FilterEnd ; IF (Filter Number == 0) GOTO Sample 2 Filter End

      ; Sample 2 Filter 1
      cmp r6,1 ; Compare Filter Number To 1
      bne S2Filter2 ; IF (Filter Number != 1) GOTO Sample 2 Filter 2
      add r3,r4 ; Filter 1: New Sample += Old Sample + (-Old Sample SAR 4)
      asr r11,r4,4 ; R11 = Old Sample SAR 4
      neg r11 ; R11 = -Old Sample SAR 4
      add r3,r11 ; New Sample = Filter 1
      b S2FilterEnd

      S2Filter2: ; Sample 2 Filter 2
      cmp r6,2 ; Compare Filter Number To 2
      bne S2Filter3 ; IF (Filter Number != 2) GOTO Sample 2 Filter 3
      add r3,r4,lsl 1 ; Filter 2: New Sample += (Old Sample SHL 1) + ((-Old Sample * 3) SAR 5) - Older Sample + (Older Sample SAR 4)
      add r11,r4,r4,lsl 1 ; R11 = Old Sample * 3
      neg r11 ; R11 = -Old Sample * 3
      add r3,r11,asr 5 ; New Sample += (-Old Sample * 3) SAR 5
      sub r3,r5 ; New Sample -= Older Sample
      add r3,r5,asr 4 ; New Sample = Filter 2
      b S2FilterEnd

      S2Filter3: ; Sample 2 Filter 3
      add r3,r4,lsl 1 ; Filter 3: New Sample += (Old Sample SHL 1) + ((-Old Sample * 13) SAR 6) - Older Sample + ((Older Sample * 3) SAR 4)
      neg r11,r4 ; R11 = -Old Sample
      mov r12,13 ; R12 = 13
      mul r11,r12 ; R11 = -Old Sample * 13
      add r3,r11,asr 6 ; New Sample += (-Old Sample * 13) SAR 6
      sub r3,r5 ; New Sample -= Older Sample
      lsl r11,r5,1
      add r11,r5 ; R11 = Older Sample * 3
      add r3,r11,asr 4 ; New Sample = Filter 3

      S2FilterEnd:
      mov r5,r4 ; Older Sample = Old Sample
      mov r4,r3 ; Old Sample = New Sample
      asr r11,r3,8 ; Convert 16-bit Signed Sample to 8-Bit Signed Sample
      strb r11,[r2],1 ; Store Decoded Sample 2, Decode Sample Address++

      subs r8,1 ; Sample Counter--
      bne BRRSampleDecode ; IF (Sample Counter != 0) Decode Samples

      cmp r0,r1 ; Compare Sample Address To Sample End Address
      bne BRRBlockDecode ; IF (Sample Address != Sample End Address) BRR Block Decode


  PlaySoundA WRAM, 44100 ; Play Sound Channel A Data

  imm16 r0,80 ; R0 = Number Of 1/16 Seconds To Wait
  Loop:
    TimerWait TM2CNT, Second16th ; Wait On Timer 2 For 1/16 Second
    subs r0,1 ; Number Of 1/16 Seconds To Wait--
    bne Loop ; IF (Number Of 1/16 Seconds To Wait != 0) Loop

  StopSoundA ; Stop Sound Channel A Data

  b start ; Repeat Sound Playback

endcopy: ; End Of Program Copy Code

; Static Data (ROM)
org $80000C0 + (endcopy - IWRAM) + (startcode - copycode)
SOUND: ; 16-Bit 32000Hz Signed Mono Compressed BRR Sound Sample
file 'audio.brr'
SOUNDEND: